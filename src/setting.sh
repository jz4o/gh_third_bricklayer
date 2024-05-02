setting=`cat setting.json | jq .`

repo=`echo "$setting" | jq -r '.repo // ""'`
if [ "$repo" = '' ]; then
  echo 'repo not found'
  exit
fi

# repository variables and secrets
for type in 'variable' 'secret'; do
  echo -n > .repository_${type}s
  echo "$setting" |
  jq -c ".repository_${type}s // {}" | jq -c 'to_entries[]' |
  while read -r entry; do
    key=`echo "$entry" | jq -r '.key'`
    value=`echo "$entry" | jq -r '.value'`

    echo "${key}=${value}" >> .repository_${type}s
  done
  if [ -s .repository_${type}s ]; then
    gh --repo $repo $type set -f .repository_${type}s
  fi
done

# environment variables and secrets
echo "$setting" |
jq -c '(.environments // [])[]' |
while read -r environment; do
  name=`echo "$environment" | jq -r '.name // ""'`
  if [ "$name" = '' ]; then
    echo "name not found: $environment"
    exit
  fi

  gh api --method GET -H 'Accept: application/vnd.github+json' "/repos/${repo}/environments/${name}" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    gh api --method PUT -H 'Accept: application/vnd.github+json' "/repos/${repo}/environments/${name}" --silent
  fi

  for type in 'variable' 'secret'; do
    echo -n > .environment_${type}s_${name}
    echo "$environment" | jq -c ".${type}s // {}" | jq -c 'to_entries[]' |
    while read -r entry; do
      key=`echo "$entry" | jq -r '.key'`
      value=`echo "$entry" | jq -r '.value'`

      echo "${key}=${value}" >> .environment_${type}s_${name}
    done
    if [ -s .environment_${type}s_${name} ]; then
      gh --repo $repo $type set -e $name -f .environment_${type}s_${name}
    fi
  done
done

