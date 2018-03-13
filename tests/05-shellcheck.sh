#!/bin/bash
r='\033[31m'
w='\033[0m'
g='\033[32m'

EXITCODE=0
AUTERDIR="$(cd "$(dirname "$0")" ; cd ../ ; pwd -P )"

# Create a list of script files to be checked. These are files 
echo "DEBUG: Current directory: $(pwd)"
echo "DEBUG: AUTERDIR: ${AUTERDIR}"
echo "DEBUG: CHANGEDFILES location: $(find / -name CHANGEDFILES)"
if [[ -f "${AUTERDIR}"/CHANGEDFILES ]]; then
  ALLFILES=$(find "${AUTERDIR}" -type f -not -path '*/\.*' | egrep "$(cat CHANGEDFILES | xargs | tr ' ' '|')")
  
else
  ALLFILES=$(find "${AUTERDIR}" -type f -not -path '*/\.*')
fi

for FILE in ${ALLFILES}; do
  grep -q '^#!/.*sh' "${FILE}" && SCRIPTSTOTEST+="${FILE} "
done

echo "${SCRIPTSTOTEST}"

# Add non-shebang scripts manually
grep -q "auter.aptModule" "${AUTERDIR}"/CHANGEDFILES && SCRIPTSTOTEST+=" auter.aptModule "
grep -q "auter.yumdnfModule" "${AUTERDIR}"/CHANGEDFILES && SCRIPTSTOTEST+=" auter.yumdnfModule "

# Custom shellcheck exclusions
SHELLCHECK_EXCLUSIONS=",SC2102,SC2124,SC2155,SC2148"

for SCRIPT in ${SCRIPTSTOTEST}; do
  SCRIPT=$(realpath "${SCRIPT}")
  SHELLCHECK_OUTPUT=$(shellcheck -e SC2044"${SHELLCHECK_EXCLUSIONS}" "${SCRIPT}")
  if [[ $? -eq 0 ]]; then
    echo -e "$g[ OK ] $w Tested ${SCRIPT} for common coding mistakes"
  else
    EXITCODE=1
    echo -e "${r} [ FAILED ]${w} Tested ${SCRIPT} for common coding mistakes"
    echo "${SHELLCHECK_OUTPUT}"
  fi
  echo "===================================="
done
exit "${EXITCODE}"
