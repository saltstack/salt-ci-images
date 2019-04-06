local distros = [
  'arch',
  // 'amazon-1',
  // 'amazon-2',
  'centos-6',
  'centos-7',
  'debian-8',
  'debian-9',
  'fedora-28',
  'fedora-29',
  'opensuse-15',
  'opensuse-42',
  'ubuntu-1404',
  'ubuntu-1604',
  'ubuntu-1804',
];

local py3_blacklist = [
  'centos-6',
  'ubuntu-1404',
];

local Build(distro) = {
  kind: 'pipeline',
  name: distro,

  local py_vers = if std.count(py3_blacklist, distro) > 0 then ['py2'] else ['py2', 'py3'],
  local types = ['minimal', 'full'],
  local suites = [
    std.format('%s-%s', [pyver, type])
    for type in types
    for pyver in py_vers
  ],

  steps: [
    {
      name: 'throttle-build',
      image: 'alpine',
      commands: [
        "sh -c 't=$(shuf -i 10-60 -n 1); echo Sleeping $t seconds; sleep $t'",
      ],
    },
  ] + [
    {
      name: suite,
      privileged: true,
      image: 'saltstack/drone-plugin-kitchen',
      depends_on: [
        'throttle-build',
      ],
      settings: {
        target: std.format('%s-%s', [suite, distro]),
        requirements: '',
      },
    }
    for suite in suites
  ],
};

[
  Build(distro)
  for distro in distros
]
