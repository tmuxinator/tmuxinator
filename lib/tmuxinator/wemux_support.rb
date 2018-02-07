module Tmuxinator
  module WemuxSupport
    def render
      Tmuxinator::Project.render_template(
        Tmuxinator::Config.wemux_template,
        binding
      )
    end

    %i(name tmux).each do |m|
      define_method(m) { "wemux" }
    end
  end
end
