{%- if grains['os_family'] == 'Debian' %}
vault-prereqs:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
{%- endif %}

{%- if grains['os_family'] in ('Debian', 'RedHat') %}
vault-repo:
  cmd.run:
  {%- if grains['os_family'] == 'Debian' %}
    - name: |
        curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    - require:
      - vault-prereqs
  {%- elif grains['os'] == 'Fedora' %}
  {#- Fedora must be addressed first because of the os_family logical check below #}
    - name: |
        dnf -y install dnf-plugins-core
        dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  {%- elif grains['os'] == 'Amazon' %}
  {#- Amazon must be addressed first because of the os_family logical check below #}
    - name: |
        yum install -y yum-utils
        yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  {%- elif grains['os_family'] == 'RedHat' %}
    - name: |
        yum install -y yum-utils
        yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  {%- endif %}
{%- endif %}

install-vault:
  pkg.installed:
    - name: vault
{%- if grains['os_family'] in ('Debian', 'RedHat') %}
    - refresh: True
    - require:
      - vault-repo
{%- endif %}
