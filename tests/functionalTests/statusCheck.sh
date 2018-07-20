#!/bin/bash

function logTest {
  echo -e "$(date): ${FUNCNAME[1]}: $1" | tee -a autoTest.log
}

# Set variables
if AUTEREXEC="$(which auter 2>/dev/null)"; then
  logTest "INFO: AUTEREXEC set to ${AUTEREXEC}"
else
  logTest "FAIL: auter not found in PATH. Has auter been installed? ... Exiting"
  exit 1
fi

function AssessTest {
  logTest "OUTPUT:\n${OUTPUT}"
  logTest "Exit Code: ${EXITCODE}"
  if [[ $OUTCOME =~ FAIL ]]; then
    logTest "$1 failed. Check $(pwd)/autoTest.log for details"
  else
    logTest "[ PASS ] $1"
  fi
}

function TestEnable {
  # Enable auter
  logTest "Enabling auter: ${AUTEREXEC} --enable"
  OUTPUT=$(${AUTEREXEC} --enable 2>&1)
  EXITCODE=$?
  [[ $OUTPUT == "INFO: auter enabled" ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  [[ -f /var/lib/auter/enabled ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  AssessTest "Enable Auter"
}

function TestDisable {
  # Disable auter
  logTest "Disabling auter: ${AUTEREXEC} --disable"
  OUTPUT=$(${AUTEREXEC} --disable 2>&1)
  EXITCODE=$?
  [[ $OUTPUT == "INFO: auter disabled" ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  [[ ! -f /var/lib/auter/enabled ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  AssessTest "Disable Auter"
}

function TestStatus { 
  # Test status
  logTest "Checking auter status: ${AUTEREXEC} --status"
  OUTPUT=$(${AUTEREXEC} --status 2>&1)
  EXITCODE=$?
  if [[ $1 == "enabled" ]]; then
    [[ $OUTPUT == "auter is currently enabled and not running" ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
    [[ -f /var/lib/auter/enabled ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  elif [[ $1 == "disabled" ]]; then
    [[ $OUTPUT == "auter is currently disabled" ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
    [[ ! -f /var/lib/auter/enabled ]] && OUTCOME+="PASS" || OUTCOME+="FAIL"
  else
    logTest "Invalid option passed to ${FUNCNAME[0]}"
    exit 1
  fi
  AssessTest "Auter Status: $1"
}
TestEnable
TestStatus enabled
TestDisable
TestStatus disabled
