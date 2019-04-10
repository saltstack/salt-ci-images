local distros = [
 { name: 'centos', version: '7' },
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



[Build(distro.name, distro.version)for distro in distros]
