require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Tmuxinator::ConfigWriter do
  context "With no defined filename" do
    its(:file_path){ should be_nil }
    its(:project_name){ should be_nil }
    its(:project_root){ should be_nil }
    its(:rvm){ should be_nil }
    its(:tabs){ should be_nil }
    its(:config_path){ should be_nil }
    its(:pre){ should be_nil }
    its(:socket){ should be_nil }
    its(:rbenv){ should be_nil }
    its(:server_options){ should be_nil }
    its(:global_session_options){ should be_nil }
    its(:global_window_options){ should be_nil }
    its(:session_options){ should be_nil }
    its(:window_options){ should be_nil }
  end

  context "When :rvm and :rbenv are both defined in the config file" do
    it "should exit with an error message" do
      lambda { Tmuxinator::ConfigWriter.new(INVALID_CONFIG) }.should raise_error SystemExit
    end
  end

  context "While Defining the filename on init" do
    subject{ Tmuxinator::ConfigWriter.new(SAMPLE_CONFIG) }
    its(:file_path){ should eql SAMPLE_CONFIG }
    its(:file_name){ should eql "sample" }
  end

  context "After filename has been defined without options" do
    before do
      subject.file_path = SAMPLE_CONFIG
    end

    its(:file_path){ should eql SAMPLE_CONFIG }
    its(:file_name){ should eql File.basename(SAMPLE_CONFIG, '.yml')}
    its(:project_name){ should eql 'Tmuxinator' }
    its(:project_root){ should eql '~/code/rails_project' }
    its(:rvm){ should eql '1.9.2@rails_project' }
    its(:tabs){ should be_an Array  }
    its(:pre){ should eql 'rvm use 1.9.2@rails_project && sudo /etc/rc.d/mysqld start' }
    its(:socket){ should eql '-L foo' }
    its(:global_session_options){ should be_a NilClass  }
    its(:global_window_options){ should be_a NilClass  }
    its(:server_options){ should be_a NilClass  }
    its(:session_options){ should be_an NilClass  }
    its(:window_options){ should be_an NilClass  }
    its(:session_environment){ should be_an NilClass  }

    let(:first_tab){ subject.tabs[0] }

    specify{ first_tab.should be_an OpenStruct }
    specify{ first_tab.name.should eql "editor" }
    specify{ first_tab.layout.should eql "main-vertical" }
    specify{ first_tab.panes.should be_an Array }
    specify{ first_tab.pre.should eql "rvm use 1.9.2@rails_project && echo 'I get run in each pane.  Before each pane command!'" }

    it "should prepend each pane with the rvm string" do
      first_tab.panes.map{|p| p.split(/ && /)[0] }.should eql ["rvm use 1.9.2@rails_project"] * 3
    end

    it "should append each pane with the command string" do
      first_tab.panes.map{|p| p.split(/ && /)[1] }.should eql ["vim", nil, "top"]
    end

    let(:second_tab){ subject.tabs[1] }
    specify{ second_tab.name.should eql "shell" }
    specify{ second_tab.command.should eql "rvm use 1.9.2@rails_project && git pull"}

    let(:third_tab){ subject.tabs[2] }
    specify{ third_tab.should be_an OpenStruct }
    specify{ third_tab.name.should eql "guard" }
    specify{ third_tab.layout.should eql "tiled" }
    specify{ third_tab.panes.should be_an Array }
    specify{ third_tab.pre.should eql "rvm use 1.9.2@rails_project && echo 'I get run in each pane.' && echo 'Before each pane command!'"}
  end

  context "when using a configuration that includes rbenv" do
    before do
      subject.file_path = RBENV_SAMPLE_CONFIG
    end

    its(:rbenv){ should eql '1.9.2-p290' }
    its(:pre){ should eql 'rbenv shell 1.9.2-p290 && sudo /etc/rc.d/mysqld start' }

    let(:first_tab){ subject.tabs[0] }

    it "should prepend each pane with the rvm string" do
      first_tab.panes.map{|p| p.split(/ && /)[0] }.should eql ["rbenv shell 1.9.2-p290"] * 3
    end

    let(:second_tab){ subject.tabs[1] }
    specify{ second_tab.name.should eql "shell" }
    specify{ second_tab.command.should eql "rbenv shell 1.9.2-p290 && git pull"}

  end

  describe "A configuration that uses options" do
    before do
      subject.file_path = RBENV_SAMPLE_CONFIG
    end

    its(:server_options){ should be_a Hash  }
    its(:global_session_options){ should be_a Hash  }
    its(:global_window_options){ should be_a Hash  }
    its(:session_options){ should be_an Hash  }
    its(:window_options){ should be_an Hash  }
    its(:session_environment){ should be_an Hash  }


    context "when configuring the tmux server" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_option){ subject.server_options.shift }
      specify{ first_option.should be_an Array }
      specify{ first_option.first.should eql "opt-name-1" }
      specify{ first_option.last.should eql "value 1" }

    end
    context "when configuring sessions globally" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_option){ subject.global_session_options.shift }
      specify{ first_option.should be_an Array }
      specify{ first_option.first.should eql "opt-name-1" }
      specify{ first_option.last.should eql "value 1" }

    end

    context "when configuring windows globally" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_option){ subject.global_window_options.shift }
      specify{ first_option.should be_an Array }
      specify{ first_option.first.should eql "opt-name-1" }
      specify{ first_option.last.should eql "value 1" }

    end
    context "when configuring windows globally" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_option){ subject.global_window_options.shift }
      specify{ first_option.should be_an Array }
      specify{ first_option.first.should eql "opt-name-1" }
      specify{ first_option.last.should eql "value 1" }
    end

    context "when configuring specific sessions" do
        before do
          subject.file_path = RBENV_SAMPLE_CONFIG
        end

        let(:first_option){ subject.session_options.shift }
        specify{ first_option.should be_an Array }
        specify{ first_option.first.should eql "Tmuxinator" }
        specify{ first_option.last.should eql({"opt-name-1"=>"value 1", "opt-name-2"=>"val2"}) }

    end

    context "when configuring specific windows" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_option){ subject.window_options.shift }
      specify{ first_option.should be_an Array }
      specify{ first_option.first.should eql "editor" }
      specify{ first_option.last.should eql({"opt-name-1"=>"value 1", "opt-name-2"=>"val2"}) }

    end

    context "when configuring global session environment variables" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_env_var){ subject.global_session_environment.shift }
      specify{ first_env_var.should be_an Array }
      specify{ first_env_var.first.should eql "ENV_VAR_A" }
      specify{ first_env_var.last.should eql "value1" }

    end

    context "when configuring specific session environments" do
      before do
        subject.file_path = RBENV_SAMPLE_CONFIG
      end

      let(:first_env_var){ subject.session_environment.shift }
      specify{ first_env_var.should be_an Array }
      specify{ first_env_var.first.should eql "Tmuxinator" }
      specify{ first_env_var.last.should eql({"ENV_VAR_A"=>"value1"}) }

    end

  end


end
