# frozen_string_literal: true

require "timeout"
require "pycall/import"
include PyCall::Import

RSpec.describe Interscript do
  mask = ENV["TRANSLIT_SYSTEM"] || "*"
  maps = {}
  Dir["maps/#{mask}.yaml"].each do |system_file|
    context "#{system_file} system" do
      system = YAML.load_file(system_file)
      system_name = File.basename(system_file, ".yaml")

      system["tests"]&.reduce([]) do |_, test|
        it "test for #{test}" do
          Timeout::timeout(5) do
            result = Interscript.transliterate(system_name, test["source"], maps) || ""
            expected = (test["expected"] || "").unicode_normalize
            expect(result).to eq(expected)
          end
        end
      end
    end
  end
end
