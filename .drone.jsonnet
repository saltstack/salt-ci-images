local distros = [
 { name: 'centos', version: '6' },
 { name: 'centos', version: '7' },
 { name: 'debian', version: '8' },
 { name: 'debian', version: '9' },
 { name: 'ubuntu', version: '14' },
 { name: 'py2-ubuntu', version: '16' },
 { name: 'py3-ubuntu', version: '16' },
 { name: 'ubuntu', version: '18' },

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

