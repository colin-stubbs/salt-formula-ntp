# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden using Pillar.
{% from "ntp/map.jinja" import ntp with context %}
{% set service = {True: 'running', False: 'dead'} %}

{# create sane default in case someone forgot to create in pillar #}
{% if ntp.settings.servers == [] %}
{%   set ntpservers = [ '0.pool.ntp.org' ] %}
{% else %}
{%   set ntpservers = ntp.settings.servers %}
{% endif %}

{% if grains.os == 'Windows' %}

ntp_servers:
  ntp.managed:
    - servers: {{ ntpservers }}

{{ ntp.lookup.service }}:
  service.running:
    - enable: True
    - require:
      - ntp: ntp_servers

{% elif grains.os == 'MacOS' %}

ntp_servers:
  module.run:
    - name: timezone.set_time_server
    - time_server: {{ ntpservers[0] }}
    - unless:
      - systemsetup -getnetworktimeserver | grep {{ ntpservers[0] }}

timed_config:
  module.run:
    - name: timezone.set_using_network_time
    - enable: True
    - unless:
      - systemsetup -getusingnetworktime | grep -i network\ time.*on
    - require:
      - module: ntp_servers

{{ ntp.lookup.service }}:
  service.running:
    - enable: True
    - require:
      - module: ntp_servers
      - module: timed_config

{% else %} {# not Windows and not MacOS #}

{# install all necessary packages #}
{% if 'pkgs' in ntp.lookup %}
ntp:
  pkg.installed:
    - pkgs: {{ ntp.lookup.pkgs }}
{% endif %}

{% if 'step_tickers' in ntp.settings and ntp.settings.step_tickers and 'step_tickers' in ntp.lookup %}
step_tickers:
  file.managed:
    - name: {{ ntp.lookup.step_tickers }}
    - source: salt://ntp/files/step-tickers
    - template: jinja
    - context:
      servers: {{ ntpservers }}
    {% if 'pkgs' in ntp.lookup %}
    - require:
      - pkg: ntp
    {% endif %}
{% endif %}

{% if 'ntp_conf' in ntp.lookup %}
ntpd_conf:
  file.managed:
    - name: {{ ntp.lookup.ntp_conf }}
    - source: salt://ntp/files/ntp.conf
    - template: jinja
    - context:
      config: {{ ntp.settings.ntp_conf }}
      servers: {{ ntpservers }}
      servers_iburst: {{ ntp.settings.servers_iburst }}
    - watch_in:
      - service: {{ ntp.lookup.service }}
    {% if 'pkgs' in ntp.lookup %}
    - require:
      - pkg: ntp
    {% endif %}
{% endif %}

{% if 'ntp_keys' in ntp.settings %}
ntp_keys:
  file.managed:
    - name: {{ ntp.lookup.keys_file }}
    - makedirs: True
    - user: root
    - group: root
    - dir_mode: 0750
    - source: salt://ntp/files/keys
    - template: jinja
    - context:
      config: {{ ntp.settings }}
    - watch_in:
      - service: {{ ntp.lookup.service }}
    {% if 'pkgs' in ntp.lookup %}
    - require:
      - pkg: ntp
    {% endif %}
{% endif %}

{% if 'ntpdate' in ntp.settings and ntp.settings.ntpdate %}
ntpdate:
  service.enabled:
    - name: {{ ntp.lookup.ntpdate_service }}
    - enable: {{ ntp.settings.ntpdate }}
{% endif %}

{% if 'ntpd' in ntp.settings %}
ntpd:
  service.{{ service.get(ntp.settings.ntpd) }}:
    - name: {{ ntp.lookup.service }}
    - enable: {{ ntp.settings.ntpd }}
    {%- if 'init_delay' in ntp.settings %}
    - init_delay: {{ ntp.settings.init_delay }}
    {% endif %}
    {% if 'pkgs' in ntp.lookup %}
    - require:
      - pkg: ntp
    - watch:
      - pkg: ntp
    {% endif %}
{% endif %}

{% endif %} {# grains.os #}
