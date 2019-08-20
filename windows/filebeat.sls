include:
  - windows.repo

install-filebeat:
  pkg.installed:
    - name: filebeat
    - require:
      - win-pkg-refresh

configure-filebeat:
  file.managed:
    - name: C:\Program Files\Filebeat\filebeat.yml
    - contents: |
        filebeat.inputs:
          - type: log
            enabled: true
            paths:
              - C:\Users\Administrator\AppData\Local\Temp\kitchen\testing\**\*.log
        processors:
          - add_cloud_metadata:
              overwrite: true
          - add_host_metadata:
              netinfo.enabled: true
          - add_fields:
              fields:
                account: ci
              target: aws
          - add_fields:
              target: test
              fields:
                pyver: PYVERVALUE
                transport: TRANSPORTVALUE
                buildnumber: 99999
                buildname: BUILDNAMEVALUE
    - require:
      - install-filebeat

install-service-filebeat:
  cmd.wait:
    - name: '.\install-service-filebeat.ps1'
    - cwd: 'C:\Program Files\Filebeat'
    - watch:
      - file: configure-filebeat

disable-service-filebeat:
  service.disabled:
    - name: filebeat
