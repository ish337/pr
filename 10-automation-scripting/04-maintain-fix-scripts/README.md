# Maintain and fix the shutdown scripts

Fixes in the nightly shutdown scripts from [05-routine-automation-scripts](../05-routine-automation-scripts/). The original version is commit 853701a, the diff and test runs are in [outputs/](outputs/).

## Changes in parser.py

- The log path is an argument now, with the old path as default, so the cron job works the same.
- `--help` shows the usage.
- A missing log was printed as "No log file" with exit code 0, so it went to Telegram as a normal message. Now it's an error on stderr with exit code 1.
- A log without read permission gives a clear error too.
- Fixed the extra space before the second building in the message (`f" *{building}*"` → `f"*{building}*"`).
- Fixed the text "There are no turned computers" → "No computers were turned off".
- The building names are in one dict instead of if/elif.
- pathlib for the file, `import sys` is used now, the f-string without variables is gone.

## Changes in shutdown.sh

- TOKEN and CHAT_ID were in the script, now they are in telegram.env with chmod 600, telegram.env is in .gitignore.
- Paths are in variables instead of repeating them.
- `set -uo pipefail`, without `-e` because ansible-playbook exits with 4 when some hosts are unreachable.
- If the parser fails, the message says the log can't be read instead of being empty.
- curl uses `--fail-with-body`, so a Telegram error is visible in cron_debug.log and the script exits with 1.

## How to use

The same as before, see the [README](../05-routine-automation-scripts/README.md) of the scripts. The only new step is telegram.env.

## Testing

- parser.py on the log with turned off computers and on the log where all hosts are unreachable.
- parser.py with a file that doesn't exist and without arguments, both give exit code 1.
- `parser.py --help`.
- shutdown.sh is checked with `bash -n`, it is not run by hand because it really turns off the computers.
