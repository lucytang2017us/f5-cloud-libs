# Library code and scripts for deploying BIG-IP in a cloud

This project consists of two main parts
- scripts
    - Command line scripts for configuring BIG-IP
    - These are meant to be called either directly from the command line or from cloud deployment templates
    - See usage below

- lib
    - Library code for controlling a BIG-IP
    - Called from the scripts
    - Documentation at go/f5-cloud-libs

## Scripts

### onboard.js

Does initial configuration and provisioning of a BIG-IP.

    Usage: onboard [options]

    Options:

      -h, --help                                               output usage information
      --host <ip_address>                                      BIG-IP management IP to which to send commands.
      -u, --user <user>                                        BIG-IP admin user name.
      -p, --password <password>                                BIG-IP admin user password.
      --port <port>                                            BIG-IP management SSL port to connect to. Default 443.
      --ntp <ntp-server>                                       Set NTP server. For multiple NTP servers, use multiple --ntp entries.
      --tz <timezone>                                          Set timezone for NTP setting.
      --dns <DNS server>                                       Set DNS server. For multiple DNS severs, use multiple --dns entries.
      --ssl-port <ssl_port>                                    Set the SSL port for the management IP
      -l, --license <license_key>                              License BIG-IP with <license_key>.
      -a, --add-on <add_on_key>                                License BIG-IP with <add_on_key>. For multiple keys, use multiple -a entries.
      -n, --hostname <hostname>                                Set BIG-IP hostname.
      -g, --global-setting <name:value>                        Set global setting <name> to <value>. For multiple settings, use multiple -g entries.
      -d, --db <name:value>                                    Set db variable <name> to <value>. For multiple settings, use multiple -d entries.
      --set-password <user:new_password>                       Set <user> password to <new_password>. For multiple users, use multiple --set-password entries.
      --set-root-password <old:old_password,new:new_password>  Set the password for the root user from <old_password> to <new_password>.
      -m, --module <name:level>                                Provision module <name> to <level>. For multiple modules, use multiple -m entries.
      --ping [address]                                         Do a ping at the end of onboarding to verify that the network is up. Default address is f5.com
      --no-reboot                                              Skip reboot even if it is recommended.
      --background                                             Spawn a background process to do the work. If you are running in cloud init, you probably want this option.
      --signal <signal>                                        Signal to send when done. Default ONBOARD_DONE.
      --wait-for <signal>                                      Wait for the named signal before running.
      --log-level <level>                                      Log level (none, error, warn, info, verbose, debug, silly). Default is info.
      -o, --output <file>                                      Log to file as well as console. This is the default if background process is spawned. Default is /tmp/onboard.log

### cluster.js

Sets up BIG-IPs in a cluster.

    Usage: onboard [options]

    Options:

      -h, --help                                               output usage information
      --host <ip_address>                                      BIG-IP management IP to which to send commands.
      -u, --user <user>                                        BIG-IP admin user name.
      -p, --password <password>                                BIG-IP admin user password.
      --port <port>                                            BIG-IP management SSL port to connect to. Default 443.
      --ntp <ntp-server>                                       Set NTP server. For multiple NTP servers, use multiple --ntp entries.
      --tz <timezone>                                          Set timezone for NTP setting.
      --dns <DNS server>                                       Set DNS server. For multiple DNS severs, use multiple --dns entries.
      --ssl-port <ssl_port>                                    Set the SSL port for the management IP
      -l, --license <license_key>                              License BIG-IP with <license_key>.
      -a, --add-on <add_on_key>                                License BIG-IP with <add_on_key>. For multiple keys, use multiple -a entries.
      -n, --hostname <hostname>                                Set BIG-IP hostname.
      -g, --global-setting <name:value>                        Set global setting <name> to <value>. For multiple settings, use multiple -g entries.
      -d, --db <name:value>                                    Set db variable <name> to <value>. For multiple settings, use multiple -d entries.
      --set-password <user:new_password>                       Set <user> password to <new_password>. For multiple users, use multiple --set-password entries.
      --set-root-password <old:old_password,new:new_password>  Set the password for the root user from <old_password> to <new_password>.
      -m, --module <name:level>                                Provision module <name> to <level>. For multiple modules, use multiple -m entries.
      --ping [address]                                         Do a ping at the end of onboarding to verify that the network is up. Default address is f5.com
      --update-sigs                                            Update ASM signatures
      --no-reboot                                              Skip reboot even if it is recommended.
      --background                                             Spawn a background process to do the work. If you are running in cloud init, you probably want this option.
      --signal <signal>                                        Signal to send when done. Default ONBOARD_DONE.
      --wait-for <signal>                                      Wait for the named signal before running.
      --log-level <level>                                      Log level (none, error, warn, info, verbose, debug, silly). Default is info.
      -o, --output <file>                                      Log to file as well as console. This is the default if background process is spawned. Default is /tmp/onboard.log

### runScript.js

Runs an arbitrary script.

    Usage: runScript [options]

    Options:

      -h, --help                     output usage information
      --background                   Spawn a background process to do the work. If you are running in cloud init, you probably want this option.
      -f, --file <script>            File name of script to run.
      -u, --url <url>                URL from which to download script to run. This will override --file.
      --cl-args <command_line_args>  String of arguments to send to the script as command line arguments.
      --signal <signal>              Signal to send when done. Default SCRIPT_DONE.
      --wait-for <signal>            Wait for the named signal before running.
      --cwd <directory>              Current working directory for the script to run in.
      --log-level <level>            Log level (none, error, warn, info, verbose, debug, silly). Default is info.
      -o, --output <file>            Log to file as well as console. This is the default if background process is spawned. Default is /tmp/runScript.log
