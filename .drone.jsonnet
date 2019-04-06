local py2_distros = [
  { name: 'centos', version: '6' },
  { name: 'centos', version: '7' },
  { name: 'debian', version: '8' },
  { name: 'debian', version: '9' },
  { name: 'ubuntu', version: '14' },
  { name: 'ubuntu', version: '16' },
  { name: 'ubuntu', version: '18' },
];

local py3_distros = [
  { name: 'centos', version: '7' },
  { name: 'debian', version: '8' },
  { name: 'debian', version: '9' },
  { name: 'ubuntu', version: '16' },
  { name: 'ubuntu', version: '18' },
];

local Build(py_version, build_type, os, os_version) = {
  kind: 'pipeline',
  name: std.format('%s-%s-%s-%s', [py_version, build_type, os, os_version]),

  steps: [
    {
      name: 'build',
      privileged: true,
      image: 'saltstack/drone-plugin-kitchen',
      settings: {
        target: std.format('%s-%s-%s-%s', [py_version, build_type, os, os_version]),
        requirements: '',
      },
    },
  ],
};

[
  Build('py2', build_type, distro.name, distro.version)
  for distro in py2_distros
  for build_type in ['minimal', 'full']
] + [
  Build('py3', build_type, distro.name, distro.version)
  for distro in py3_distros
  for build_type in ['minimal', 'full']
]
