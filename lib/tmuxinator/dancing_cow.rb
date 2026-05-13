# frozen_string_literal: true

module Tmuxinator
  class DancingCow
    # ASCII art frames for the dancing cow
    FRAMES = [
      # Frame 1 - Cow standing
      <<~COW,
        ^__^
        (oo)\_______
        (__)\       )\/\\
            ||----w |
            ||     ||
      COW
      # Frame 2 - Cow leaning left
      <<~COW,
       ^__^
       (oo)\_______
       (__)\       )\/\\
           ||----w |
           ||     ||
      COW
      # Frame 3 - Cow leaning right
      <<~COW,
         ^__^
         (oo)\_______
         (__)\       )\/\\
             ||----w |
             ||     ||
      COW
      # Frame 4 - Cow jumping
      <<~COW,
          ^__^
          (oo)\_______
          (__)\       )\/\\
              ||----w |
              ||     ||
      COW
    ].freeze

    def self.random_frame
      FRAMES.sample
    end

    def self.frame_at(index)
      FRAMES[index % FRAMES.length]
    end

    def self.all_frames
      FRAMES
    end

    def self.frame_count
      FRAMES.length
    end

    # Generate a tmux status bar segment with the dancing cow
    def self.status_bar_segment(frame_index = 0)
      frame = frame_at(frame_index)
      # Compress the cow for status bar display
      compressed = frame.split("\n").map(&:strip).join(" ")
      " 🐄 #{compressed} "
    end

    # Generate a command to display the cow in a pane
    def self.display_command(pane_target, frame_index = 0)
      frame = frame_at(frame_index)
      # Escape the frame for shell
      escaped_frame = frame.gsub('"', '\\"').gsub('$', '\$')
      "echo \"#{escaped_frame}\""
    end

    # Generate animation loop command for continuous dancing
    def self.animation_loop_command(pane_target, interval = 1)
      commands = []
      commands << "while true; do"
      FRAMES.each_with_index do |_frame, index|
        commands << "  clear"
        commands << "  #{display_command(pane_target, index)}"
        commands << "  sleep #{interval}"
      end
      commands << "done"
      commands.join("; ")
    end
  end
end
