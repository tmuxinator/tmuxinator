# Contributing

## First

* Check if the issue you're going to submit isn't already submitted in
  the [Issues](https://github.com/tmuxinator/tmuxinator/issues) page.

## Issues

* Submit a ticket for your issue, assuming one does not already exist.
* The issue must:
  * Clearly describe the problem including steps to reproduce when it is a bug.
  * Also include all the information you can to make it easier for us to reproduce it,
    like OS version, gem versions, rbenv or rvm versions etc...
  * Even better, provide a failing test case for it.

## Development

Their are 2 ways of testing it's quite flexible due vagrant and docker. 

### Ruby version

You need to set the ruby version in 2 places, by changing these values it 
will set the version for next builds. It's currently set to the minimum
ruby version.

You only have to build the environment 1 time per ruby version per distribution.

1. Dockerfile
```docker
RUN ./init.sh "2.3.6" 
```

2. Vagrantfile
```vagrant
RUBY_V = "2.3.6"
```

## Docker

To use the docker image first build it.

```bash
docker build -t tmuxinator .
```

This will setup the environment for you. It was quite slow on my mac.

This creates an image named `tmuxinator`, you can see it with the
`docker ls` command.

The Dockerfile will copy your current directory to `/opt/tmuxinator`, this is currently required for setting up rbenv.
For running tests in another source directory you can always overwrite it with the -v flag.

```bash
docker exec -tiv /opt/someotherdir:/opt/tmuxinator /bin/bash
$ > rake spec
```

## Vagrant

You can now emulate completely different operating systems.

Currently it builds on, ubuntu and centos. You can add systems by changing the
distros hash. So you are able to solve bugs for other systems on
the fly!


### Required step

You need the virtualbox guest tools installed to use mounts.

```bash
vagrant plugin install vagrant-vbguest
```

#### How to use

First you have to build the virtual machine, you can see what machines are
available with ``vagrant status``

```bash
vagrant up <name>
# or withouth specifying the machine, it will do all.
vagrant up
```

This will setup the environment for you, it will take quite
a while! 

Afterwards you are able to run your tests with a command like such.

```bash
vagrant ssh centos_7 -c "cd /opt/tmuxinator; rake spec"
```

## Pull Requests

If you've gone the extra mile and have a patch that fixes the issue, you
should submit a Pull Request!

* Please follow the [GitHub Styleguide](https://github.com/styleguide/ruby) for
  Ruby in both implementation and tests!
* Fork the repo on Github.
* Create a topic branch from where you want to base your work.
* Add a test for your change. Only refactoring and documentation changes
  require no new tests. If you are adding functionality or fixing a bug,
  we need a test!
* Run _all_ the tests to ensure nothing else was broken. We only take pull requests with passing tests. You can run the tests with `rake test`.
* Make a note in the `CHANGELOG.md` file with a brief summary of your change under the heading "Unreleased" at the top of the file. If that heading does not exist, you should add it.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Structure your commit messages like this:

```
Summarize clearly in one line what the commit is about

Describe the problem the commit solves or the use
case for a new feature. Justify why you chose
the particular solution.
```

* Use "fix", "add", "change" instead of "fixed", "added", "changed" in your commit messages.
* Push to your fork and submit a pull request.
