#!/bin/env bash
## https://t.me/bashdays/47

# Hide the cursor in the terminal for a cleaner display
tput civis
# Save the current screen state (alternate buffer)
tput smcup
# Move the cursor to the top-left corner of the screen (row 0, column 0)
tput cup 0 0

# Set up a handler for the EXIT event
# When the script exits, restore the screen and show the cursor
trap 'tput rmcup; tput cvvis' EXIT

echo 'Bash Cheat Sheet'
echo '----------------'
echo '1. File Operations:'
echo '   ls              - List files'
echo '   cp <src> <dst>  - Copy file'
echo '   mv <src> <dst>  - Move/rename file'
echo '   rm <file>       - Remove file'
echo '   touch <file>    - Create empty file'
echo '   cat <file>      - Display file content'
echo '----------------'
echo '2. Directory Operations:'
echo '   cd <dir>        - Change directory'
echo '   mkdir <dir>     - Create directory'
echo '   rmdir <dir>     - Remove empty directory'
echo '   pwd             - Print working directory'
echo '----------------'
echo '3. Text Processing:'
echo '   grep <pattern> <file> - Search text'
echo '   sed -i "s/old/new/g" <file> - Replace text'
echo '   awk "{print $1}" <file> - Process columns'
echo '----------------'
echo '4. System Info:'
echo '   uname -a        - Show system info'
echo '   df -h           - Disk usage'
echo '   free -h         - Memory usage'
echo '   top             - Process monitor'
echo '----------------'
echo '5. Scripting:'
echo '   #!/bin/bash     - Shebang for Bash scripts'
echo '   $1, $2, ...     - Script arguments'
echo '   $#              - Number of arguments'
echo '   $?              - Exit status of last command'
echo '   if [ ]; then    - Conditional statement'
echo '   for i in; do    - Loop'
echo '   while [ ]; do   - While loop'
echo '----------------'
echo 'Press any key to exit...'

read -srn1
exit
