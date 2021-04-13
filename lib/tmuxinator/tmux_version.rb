module Tmuxinator
  module TmuxVersion
    SUPPORTED_TMUX_VERSIONS = [
      3.2,
      "3.1c",
      "3.1b",
      "3.1a",
      3.1,
      "3.0a",
      3.0,
      "2.9a",
      2.9,
      2.8,
      2.7,
      2.6,
      2.5,
      2.4,
      2.3,
      2.2,
      2.1,
      2.0,
      1.9,
      1.8,
      1.7,
      1.6,
      1.5,
    ].freeze
    UNSUPPORTED_VERSION_MSG = <<-MSG.freeze
    WARNING: You are running tmuxinator with an unsupported version of tmux.
    Please consider using a supported version:
    (#{SUPPORTED_TMUX_VERSIONS.join(', ')})
    MSG

    def self.supported?(version = Tmuxinator::Config.version)
      SUPPORTED_TMUX_VERSIONS.include?(version)
    end
  end
end
