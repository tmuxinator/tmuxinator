require "spec_helper"

describe Tmuxinator::AssetPath do
  describe "#sample" do
    it "gets the path of the sample project" do
      expect(described_class.sample).to include("sample.yml")
    end
  end
  describe "#template" do
    it "gets the path of the project template" do
      expect(described_class.template).to include("template.erb")
    end
  end
  describe "#stop_template" do
    it "gets the path of the stop_template template" do
      expect(described_class.stop_template).to include("template-stop.erb")
    end
  end
  describe "#wemux_template" do
    it "gets the path of the wemux_template template" do
      expect(described_class.wemux_template).to include("wemux_template.erb")
    end
  end
end
