# checks the exit status of the last run command ($? captures the exit status of the last executed command).
# If the command failed (exit status not equal to 0), it prints an error message in red using the predefined colors 
# and the additional error message passed to the function. Then, it exits the script with an exit status of 1, indicating an error.

checkerror() {
  RC=$?
  if [ $RC -ne 0 ]; then
    printf "${RED}ERROR: $* ${NC}\n"
    exit 1
  fi
}


# your script logic here after it run the checkerror
checkerror "Error Doing <your logic above worst case scenario>"
