# Tmuxinator

Create and manage tmux sessions easily. Inspired by Jon Druse's ([Screeninator](https://github.com/jondruse/screeninator)) and Arthur Chiu's ([Terminitor](http://github.com/achiu/terminitor))

## Installation


    $ gem install tmuxinator
  
Then follow the instructions.  You just have to drop a line in your ~/.bashrc file, similar to RVM if you've used that before:

    if [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] ; then source $HOME/.tmuxinator/scripts/tmuxinator ; fi

## Editor

tmuxinator uses your shell's default editor for opening files.  If you're not sure what that is type:
  
    $ echo $EDITOR
    
For me that produces "mate -w"  
If you want to change your default editor simple put a line in ~/.bashrc that changes it. Mine looks like this:

    export EDITOR='mate -w'

## Usage

  
### Create a project ###
  
    $ tmuxinator open project_name
  
Create or edit your projects with this command. Your default editor ($EDITOR) is used to open the file. If this is a new project you will see this default config:

    # ~/.tmuxinator/project_name.yml
    # you can make as many tabs as you wish...

    escape: ``
    project_name: tmuxinator
    project_root: ~/code/rails_project
    tabs:
      - shell: git pull
      - database: rails db
      - console: rails c
      - logs: 
        - cd logs
        - tail -f development.log
      - ssh: ssh me@myhost
  

If a tab contains multiple commands, they will be 'joined' together with '&&'.

If you want to have your own default config, place it into $HOME/.tmuxinator/default.yml


Starting a project
------------------

    $ start_project_name
  
This will fire up tmux with all the tabs you configured.

### Limitations ###

After you create a project, you will have to open a new shell window. This is because tmuxinator adds an alias to bash to open tmux with the project config.


Example
-------

![Sample](http://f.cl.ly/items/3e3I1l1t3D2U472n1h0h/Screen%20shot%202010-12-10%20at%2010.59.17%20PM.png)


Other Commands
--------------

    $ tmuxinator copy existing_project new_project

Copy an existing project.


    $ tmuxinator update_scripts

Re-create the tmux scripts and aliases from the configs. Use this only if you edit your project configs outside of tmuxinator, i.e. not using "tmuxinator open xxx".


    $ tmuxinator list
  
List all the projects you have configured

    $ tmuxinator delete project_name
  
Remove a project

    $ tmuxinator implode
  
Remove all tmuxinator configs, aliases and scripts.


Questions? Comments? Feature Request?
-------------------------------------

I would love to hear your feedback on this project!  Send me a message!

## Contributing to tmuxinator
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010 Allen Bargi. See LICENSE.txt for
further details.