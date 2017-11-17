{% set swapfile = '/.salt-runtests.swapfile' %}
{% set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- if pillar.get('disable_swap') != True %}

create-swap-file:
  {# because everytime a new subprocess.Popen() is instantiated, a copy of the current python
     interpreter memory is cloned. Yes, it's copy-on-write, however, due to python's refcount
     for garbage collection, copy-on-write's happen to often and we endup with getting out of
     memory errors in the tests suite.
     Let's see if this solves that issue.
  #}
  cmd.run:
    - name: dd if=/dev/zero of={{ swapfile }} bs=2048 count=1M
    - unless: grep -q {{ swapfile }} /proc/swaps

{% if grains['os'] == 'FreeBSD' %}
chmod-swap:
  cmd.run:
    - name: chmod 0600 {{ swapfile }}
    - unless: grep -q {{ swapfile }} /proc/swaps
    - require:
      - cmd: create-swap-file

mdconfig:
  cmd.run:
    - name: mdconfig -a -t vnode -f {{ swapfile }}
    - require:
      - cmd: chmod-swap

add-extra-swap:
  cmd.run:
    - name: swapon /dev/md0
    - require:
      - cmd: mdconfig
{% else %}
make-swap:
  cmd.run:
    - name: mkswap {{ swapfile }}
    - unless: grep -q {{ swapfile }} /proc/swaps
    - require:
      - cmd: create-swap-file

add-extra-swap:
  cmd.run:
    - name: chmod 0600 {{ swapfile }}
    - unless: grep -q {{ swapfile }} /proc/swaps
    - require:
      - cmd: create-swap-file
  {%- if on_docker == False %}
  mount.swap:
    - name: {{ swapfile }}
    - persist: False
    - require:
      - cmd: make-swap
    - unless: grep -q {{ swapfile }} /proc/swaps
  {%- endif %}
{% endif %}
{% endif %}
