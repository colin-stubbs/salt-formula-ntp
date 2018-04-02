===
ntp
===

Formula to set up and configure the ntp client or server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/development/conventions/formulas.html>`_.

.. note::

    This is a heavy rewrite/cleanup of the formula originally `here <https://github.com/saltstack-formulas/ntp-formula>`

Available States
================

.. contents::
    :local:

``ntp``
-------

Installs and configures ntp dependent upon operating system variant and pillar configuration.

On Windows:
  - Configures NTP server list
  - Ensures 'w32time' service is running

On MacOS
  - Configures "remote time server" (aka. a single NTP server)
  - Ensures remote time is enabled

On Linux/other *nix variants:
  - Manages ntpdate and the step tickers file, if directed by pillar config
  - Manages ntpd and ntp.conf file, if directed by pillar config

For Linux; there is only a single state as regardless of whether you're running an NTP server or simply configuring a system as a client they all need to run ntpd (unless you only run ntpdate on boot). If you want a minion to function as an NTP server provide it a different pillar config to that given to a client-only system.

Tested on:
  - CentOS 7
  - Windows 10 Pro
  - Windows Server 2016
  - MacOS 10.13.3
  - Ubuntu 16.04.4 LTS
  - Debian GNU/Linux 9.4 (stretch)

Example State Application
=========================

.. code-block:: yaml

    [salt@master ~]# salt --state-verbose --state-output=full 'macos.example.routedlogic.net' state.apply ntp
    macos.example.routedlogic.net:
    ----------
              ID: ntp_servers
        Function: module.run
            Name: timezone.set_time_server
          Result: True
         Comment: unless execution succeeded
         Started: 19:05:23.009464
        Duration: 55.276 ms
         Changes:
    ----------
              ID: timed_config
        Function: module.run
            Name: timezone.set_using_network_time
          Result: True
         Comment: unless execution succeeded
         Started: 19:05:23.067472
        Duration: 42.113 ms
         Changes:
    ----------
              ID: com.apple.timed
        Function: service.running
          Result: True
         Comment: The service com.apple.timed is already running
         Started: 19:05:23.112246
        Duration: 15.563 ms
         Changes:

    Summary for macos.example.routedlogic.net
    ------------
    Succeeded: 3
    Failed:    0
    ------------
    Total states run:     3
    Total run time: 112.952 ms


    -------------------------------------------
    Summary
    -------------------------------------------
    # of minions targeted: 1
    # of minions returned: 1
    # of minions that did not return: 0
    # of minions with errors: 0
    -------------------------------------------
    [salt@master ~]# salt --state-verbose --state-output=full 'mdt.example.routedlogic.net' state.apply ntp
    mdt.example.routedlogic.net:
    ----------
              ID: ntp_servers
        Function: ntp.managed
          Result: True
         Comment: NTP servers already configured as specified
         Started: 19:05:39.086904
        Duration: 114.626 ms
         Changes:
    ----------
              ID: w32time
        Function: service.running
          Result: True
         Comment: The service w32time is already running
         Started: 19:05:39.201530
        Duration: 0.0 ms
         Changes:

    Summary for mdt.example.routedlogic.net
    ------------
    Succeeded: 2
    Failed:    0
    ------------
    Total states run:     2
    Total run time: 114.626 ms


    -------------------------------------------
    Summary
    -------------------------------------------
    # of minions targeted: 1
    # of minions returned: 1
    # of minions that did not return: 0
    # of minions with errors: 0
    -------------------------------------------
    [salt@master ~]#
    [salt@master ~]# salt --state-verbose --state-output=full 'centos.example.routedlogic.net' state.apply ntp
    centos.example.routedlogic.net:
    ----------
              ID: ntp
        Function: pkg.installed
          Result: True
         Comment: All specified packages are already installed
         Started: 19:07:32.553702
        Duration: 994.417 ms
         Changes:
    ----------
              ID: step_tickers
        Function: file.managed
            Name: /etc/ntp/step-tickers
          Result: True
         Comment: File /etc/ntp/step-tickers is in the correct state
         Started: 19:07:33.887216
        Duration: 15.83 ms
         Changes:
    ----------
              ID: ntpd_conf
        Function: file.managed
            Name: /etc/ntp.conf
          Result: True
         Comment: File /etc/ntp.conf updated
         Started: 19:07:33.906942
        Duration: 29.427 ms
         Changes:
                  ----------
                  diff:
                      ---
                      +++
                      @@ -10,10 +10,10 @@
                       restrict -6 default kod nomodify notrap nopeer noquery
                       restrict 127.0.0.1
                       restrict ::1
                      +restrict restrict 203.0.113.0 mask 255.255.255.0 nomodify notrap nopeer
                      +restrict restrict 192.0.2.0 mask 255.255.255.0 nomodify notrap nopeer
                      +restrict 2001:db8:: mask ffff:ffff:: nomodify notrap nopeer
                       requestkey 1
                       trustedkey 1
                       controlkey 1
    ----------
              ID: ntp_keys
        Function: file.managed
            Name: /etc/ntp/keys
          Result: True
         Comment: File /etc/ntp/keys is in the correct state
         Started: 19:07:33.940588
        Duration: 14.451 ms
         Changes:
    ----------
              ID: ntpdate
        Function: service.enabled
          Result: True
         Comment: Service ntpdate is already enabled, and is in the desired state
         Started: 19:07:33.958686
        Duration: 36.594 ms
         Changes:
    ----------
              ID: ntpd
        Function: service.running
          Result: True
         Comment: Service restarted
         Started: 19:07:34.034343
        Duration: 5046.075 ms
         Changes:
                  ----------
                  ntpd:
                      True

    Summary for centos.example.routedlogic.net
    ------------
    Succeeded: 6 (changed=2)
    Failed:    0
    ------------
    Total states run:     6
    Total run time:   6.137 s


    -------------------------------------------
    Summary
    -------------------------------------------
    # of minions targeted: 1
    # of minions returned: 1
    # of minions that did not return: 0
    # of minions with errors: 0
    -------------------------------------------
    [salt@master ~]#
