# helpful_bash_scripts
Repo that holds useful bash script that can be used in real.

exercise_create_local_users2.sh - Provide an username for the user to be created
The script creates an user and generates a password for it.
- Example of how to run the script  - sudo ./exercise_create_local_users2.sh jaylocker

exercise_disable_local_user2.sh - Provide an username for the user to be disabled.
- Disables the user by default.
- Specify more usernames and all of the would be disabled at once.
- -d option would delete the user
- -r option would delete the home directory of the given user(s)
- -a option would backup the home directory of the given user(s)
- Example of how to run the script - sudo ./exercise_disable_local_user2.sh -dra user1 user2
