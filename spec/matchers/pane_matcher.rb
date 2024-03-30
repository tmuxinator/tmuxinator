# frozen_string_literal: true

RSpec::Matchers.alias_matcher :be_a_pane, :a_pane
RSpec::Matchers.define :a_pane do
  attr_reader :commands

  match do
    result = is_pane

    result && attributes_match if @expected_attrs
    result &&= commands_match if commands

    result
  end

  failure_message do |actual|
    return "Expected #{actual} to be a Tmuxinator::Pane" unless is_pane

    msg = "Actual pane does not match expected"
    msg << "\n  Expected #{@commands} but has #{actual.commands}" if @commands
    msg << "\n  Expected pane to have #{@expected_attrs}" if @expected_attrs
  end

  chain :with do |attrs|
    @expected_attrs = attrs
  end

  chain :with_commands do |*expected|
    @commands = expected
  end
  alias_method :and_commands, :with_commands

  private

  def attributes_match
    expect(@actual).to have_attributes(@expected_attrs)
  end

  def commands_match
    @actual.commands == commands
  end

  def is_pane
    @actual.is_a? Tmuxinator::Pane
  end
end
