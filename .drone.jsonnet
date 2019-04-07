local distros = [
  { name: 'Arch', slug: 'arch', multiplier: 0 },
  //{ name: 'Amazon 1', slug: 'amazon-1', multiplier: 1 },
  //{ name: 'Amazon 2', slug: 'amazon-2', multiplier: 2 },
  { name: 'CentOS 6', slug: 'centos-6', multiplier: 3 },
  { name: 'CentOS 7', slug: 'centos-7', multiplier: 4 },
  { name: 'Debian 8', slug: 'debian-8', multiplier: 5 },
  { name: 'Debian 9', slug: 'debian-9', multiplier: 6 },
  { name: 'Fedora 28', slug: 'fedora-28', multiplier: 7 },
  { name: 'Fedora 29', slug: 'fedora-29', multiplier: 8 },
  { name: 'Opensuse 15.0', slug: 'opensuse-15', multiplier: 9 },
  { name: 'Opensuse 42.3', slug: 'opensuse-42', multiplier: 10 },
  { name: 'Ubuntu 14.04', slug: 'ubuntu-1404', multiplier: 11 },
  { name: 'Ubuntu 16.04', slug: 'ubuntu-1604', multiplier: 12 },
  { name: 'Ubuntu 18.04', slug: 'ubuntu-1804', multiplier: 13 },
];

local py3_blacklist = [
  'centos-6',
  'ubuntu-1404',
];

local Build(distro) = {
  kind: 'pipeline',
  name: distro.name,

  local py_vers = if std.count(py3_blacklist, distro.slug) > 0 then ['py2'] else ['py2', 'py3'],
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
        std.format(
          "sh -c 'echo Sleeping %(offset)s seconds; sleep %(offset)s'",
          { offset: 5 * std.length(py_vers) * distro.multiplier }
        ),
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
        target: std.format('%s-%s', [suite, distro.slug]),
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
