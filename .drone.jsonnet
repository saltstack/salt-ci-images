local distros = [
  { name: 'Arch', slug: 'arch', multiplier: 0 },
  { name: 'Amazon Linux 1', slug: 'amazonlinux-1', multiplier: 1 },
  { name: 'Amazon Linux 2', slug: 'amazonlinux-2', multiplier: 2 },
  { name: 'CentOS 6', slug: 'centos-6', multiplier: 3 },
  { name: 'CentOS 7', slug: 'centos-7', multiplier: 4 },
  { name: 'Debian 8', slug: 'debian-8', multiplier: 5 },
  { name: 'Debian 9', slug: 'debian-9', multiplier: 6 },
  { name: 'Fedora 29', slug: 'fedora-29', multiplier: 4 },
  { name: 'Fedora 30', slug: 'fedora-30', multiplier: 3 },
  { name: 'Opensuse 15.0', slug: 'opensuse-15', multiplier: 2 },
  { name: 'Ubuntu 16.04', slug: 'ubuntu-1604', multiplier: 1 },
  { name: 'Ubuntu 18.04', slug: 'ubuntu-1804', multiplier: 0 },
];

local py3_blacklist = [
  'centos-6',
  'amazonlinux-1',
];

local Build(distro) = {
  kind: 'pipeline',
  name: distro.name,
  node: {
    project: 'open',
  },

  local py_vers = if std.count(py3_blacklist, distro.slug) > 0 then [{ k: 1, v: 'py2' }] else [{ k: 1, v: 'py2' }, { k: 2, v: 'py3' }],
  local types = [{ k: 3, v: 'minimal' }, { k: 4, v: 'full' }],
  local suites = [
    {
      k: std.parseInt(std.format('%s', [pyver.k * type.k])),
      v: std.format('%s-%s', [pyver.v, type.v]),
      //d: if type.v == 'full' then [std.format('%s-minimal', [pyver.v])] else [],
      //d: if type.v == 'full' then [std.format('%s-minimal', [pyver.v])] else ['throttle-build'],
      d: [],
    }
    for pyver in py_vers
    for type in types
  ],

  steps: [
    {
      name: 'throttle-build',
      image: 'alpine',
      commands: [
        std.format(
          "sh -c 'echo Sleeping %(offset)s seconds; sleep %(offset)s'",
          { offset: 3 * std.length(py_vers) * std.length(types) * distro.multiplier }
        ),
      ],
    },
    {
      name: 'create',
      image: 'saltstack/drone-salt-jenkins-testing',
      environment: {
        DOCKER_HOST: 'tcp://docker:2375',
      },
      depends_on: [
        'throttle-build',
      ],
      commands: [
        'bundle install --with docker --without opennebula ec2 windows vagrant',
        "echo 'Waiting for docker to start'",
        'sleep 10',  // give docker enough time to start
        'docker ps -a',
        std.format('bundle exec kitchen create %s', [distro.slug]),
      ],
    },
  ] + [
    {
      name: suite.v,
      image: 'saltstack/drone-salt-jenkins-testing',
      environment: {
        DOCKER_HOST: 'tcp://docker:2375',
      },
      depends_on: ['create'] + suite.d,
      commands: [
        'bundle install --with docker --without opennebula ec2 windows vagrant',
        std.format('bundle exec kitchen test %s-%s', [suite.v, distro.slug]),
      ],
    }
    for suite in suites
  ],

  trigger: {
    event: [
      'pull_request',
    ],
  },

  services: [
    {
      name: 'docker',
      image: 'saltstack/drone-salt-jenkins-testing',
      privileged: true,
      environment: {},
      command: [
        '--storage-driver=overlay2',
      ],
    },
  ],
};

[
  Build(distro)
  for distro in distros
]
