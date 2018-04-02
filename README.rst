===
ntp
===

Formula to set up and configure the ntp client or server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/development/conventions/formulas.html>`_.

.. note::

    This is a heavy rewrite/cleanup of the formula originally `here <https://github.com/saltstack-formulas/ntp-formula>`

Available states
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
