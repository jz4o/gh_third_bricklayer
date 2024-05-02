# gh_third_bricklayer

gh_third_bricklayer is a script for setting secrets and variables in a github repository.

## Usage

1. `git clone ...`

1. `cp -p .env.example .env`
1. `$EDITOR .env`

1. `cp -p src/setting.json.example src/setting.json`
1. `$EDITOR src/setting.json`

1. `docker compose up`

## Required

* required scope for the token are: `repo`.

