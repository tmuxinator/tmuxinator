module TmuxVersionHelpers
  def stub_tmux_version(version)
    allow(Tmuxinator::TmuxVersion).to receive_messages(version: version)
  end
end

