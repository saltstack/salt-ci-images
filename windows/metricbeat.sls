include:
  - windows.repo

install-metricbeat:
  pkg.installed:
    - name: metricbeat
    - require:
      - win-pkg-refresh

start-metricbeat-service:
  service.disabled:
    - name: metricbeat
    - watch:
        - install-metricbeat

configure-metricbeat:
  file.managed:
    - name: C:\Program Files\Metricbeat\metricbeat.yml
    - contents: |
        metricbeat.modules:
        - module: system
          metricsets:
            - cpu
            - load
            - memory
            - network
            - process
            - process_summary
            - uptime
            - socket_summary
            - diskio
            - filesystem
          enabled: true
          period: 10s
          processes: ['.*']
          cpu.metrics:  ["percentages"]
        processors:
        - add_cloud_metadata:
            overwrite: true
        - add_host_metadata:
            netinfo.enabled: true
        - add_fields:
            target: aws
            fields:
              account: ci
        - add_fields:
            target: test
            fields:
              pyver: PYVERVALUE
              transport: TRANSPORTVALUE
              buildnumber: 99999
              buildname: BUILDNAMEVALUE
    - require:
      - install-metricbeat
