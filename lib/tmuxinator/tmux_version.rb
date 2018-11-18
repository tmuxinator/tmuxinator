module Tmuxinator
  module TmuxVersion
    SUPPORTED_TMUX_VERSIONS = [
      1.5,
      1.6,
      1.7,
      1.8,
      1.9,
      2.0,
      2.1,
      2.2,
      2.3,
      2.4,
      2.5,
      2.6,
      2.7,
      2.8
    ].freeze
    UNSUPPORTED_VERSION_MSG = <<-MSG.freeze
    DEPRECATION: You are running tmuxinator with an unsupported version of tmux.
    Please consider using a supported version:
    (#{SUPPORTED_TMUX_VERSIONS.join(', ')})
    MSG

    def self.supported?(version = Tmuxinator::Config.version)
      SUPPORTED_TMUX_VERSIONS.include?(version)
    end
  end
end
