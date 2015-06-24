## include puppet modules: this (also) runs 'apt-get update'
include apt
include nodejs

## variables
$packages_build_dep   = ['matplotlib', 'scikit-learn', 'librarian-puppet']
$packages_general_apt = ['inotify-tools', 'python-pip']
$packages_general_pip = ['redis', 'jsonschema', 'xmltodict', 'six', 'matplotlib']
$packages_general_gem = ['librarian-puppet', 'sass']
$packages_general_npm = ['uglify-js', 'imagemin']
$packages_flask_pip   = ['flask', 'requests']
$packages_mariadb_apt = ['mariadb-server', 'mariadb-client', 'python-mysqldb']
$packages_build_size  = size($packages_build_dep) - 1

## define $PATH for all execs, paths
Exec {path => ['/usr/bin/', '/bin/', '/usr/local', '/usr/sbin/', '/sbin/']}

## enable 'multiverse' repository (part 1, replace line)
exec {'enable-multiverse-repository-1':
    command => 'sed -i "s/# deb http:\/\/security.ubuntu.com\/ubuntu trusty-security multiverse/deb http:\/\/security.ubuntu.com\/ubuntu trusty-security multiverse/g" /etc/apt/sources.list',
    notify => Exec["build-package-dependencies-${packages_build_size}"],
}

## enable 'multiverse' repository (part 2, replace line)
exec {'enable-multiverse-repository-2':
    command => 'sed -i "s/# deb-src http:\/\/security.ubuntu.com\/ubuntu trusty-security multiverse/deb-src http:\/\/security.ubuntu.com\/ubuntu trusty-security multiverse/g" /etc/apt/sources.list',
    notify => Exec["build-package-dependencies-${packages_build_size}"],
}

## build package dependencies
each($packages_build_dep) |$index, $package| {
    exec {"build-package-dependencies-${index}":
        command => "apt-get build-dep $package -y",
        before => Package[$packages_general_apt],
        refreshonly => true,
    }
}

## packages: install general packages (apt)
package {$packages_general_apt:
    ensure => 'installed',
    before => Package[$packages_general_pip],
}

## packages: install general packages (pip)
package {$packages_general_pip:
    ensure => 'installed',
    provider => 'pip',
    before => Package[$packages_general_gem],
}

## packages: install general packages (gem)
package {$packages_general_gem:
    ensure => 'installed',
    provider => 'gem',
    before => Package[$packages_general_npm],
}

## package: install general packages (npm)
package {$packages_general_npm:
    ensure => 'present',
    provider => 'npm',
    before => Package[$packages_flask_pip],
    require => Package['npm'],
}

## packages: install flask via 'pip'
package {$packages_flask_pip:
    ensure => 'installed',
    provider => 'pip',
    before => Package[$packages_mariadb_apt],
}

## packages: install mariadb
package {$packages_mariadb_apt:
    ensure => 'installed',
    before => Package['redis-server'],
}

## package: install redis-server
package {'redis-server':
    ensure => 'installed',
}
