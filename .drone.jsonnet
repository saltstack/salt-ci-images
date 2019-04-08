local distros = [
# { name: 'Arch', slug: 'arch', multiplier: 0 },
# { name: 'CentOS 6', version: 'centos-6', multiplier: 1 },
 { name: 'centos', version: '7' },
# { name: 'Debian 8', slug: 'debian-8', multiplier: 3 },
# { name: 'Debian 9', slug: 'debian-9', multiplier: 4 },
# { name: 'Fedora 28', slug: 'fedora-28', multiplier: 5 },
# { name: 'Fedora 29', slug: 'fedora-29', multiplier: 6 },
# { name: 'Opensuse 15.0', slug: 'opensuse-15', multiplier: 7 },
# { name: 'Opensuse 42.3', slug: 'opensuse-42', multiplier: 8 },
# { name: 'Ubuntu 14.04', slug: 'ubuntu-1404', multiplier: 9 },
# { name: 'Ubuntu 16.04', slug: 'ubuntu-1604', multiplier: 10 },
# { name: 'Ubuntu 18.04', slug: 'ubuntu-1804', multiplier: 11 },
];
local Build(os, os_version) = {
 kind: 'pipeline',
 name: std.format('build-%s-%s', [os, os_version]),

 steps: [
   {
     name: 'build',
     privileged: true,
     image: 'saltstack/drone-plugin-kitchen',
     settings: {
       target: std.format('%s-%s', [os, os_version]),
       requirements: "",
     },
     when: { event: ['pull_request'] },
     },
 ],
};

local Sign() = {
  kind: 'signature',
  hmac: '2065d89588e9f4d0c612f88921f09b8260884dda35af76faced19a3197266a88',
};



[Build(distro.name, distro.version)for distro in distros] + [Sign()]

