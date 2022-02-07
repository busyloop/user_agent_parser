require "yaml"
require "semantic_version"
require "./user_agent_parser/util/property_reflection"

FAMILY_REPLACEMENT_KEYS = %w[
  family_replacement
  v1_replacement
  v2_replacement
  v3_replacement
]

OS_REPLACEMENT_KEYS = %w[
  os_replacement
  os_v1_replacement
  os_v2_replacement
  os_v3_replacement
]

DEVICE_REPLACEMENT_KEYS = %w[
  device_replacement
  model_replacement
  brand_replacement
]

class UserAgent
  # :nodoc:
  class ParserDefinition
    include YAML::Serializable

    property regex : String
    property regex_flag : String?
    property family_replacement : String?
    property v1_replacement : String?
    property v2_replacement : String?
    property v3_replacement : String?
    property os_v1_replacement : String?
    property os_v2_replacement : String?
    property os_v3_replacement : String?
    property os_replacement : String?
    property device_replacement : String?
    property brand_replacement : String?
    property model_replacement : String?

    include PropertyReflection
  end

  # :nodoc:
  class ParserCollections
    include YAML::Serializable

    property user_agent_parsers : Array(ParserDefinition)
    property os_parsers : Array(ParserDefinition)
    property device_parsers : Array(ParserDefinition)

    include PropertyReflection
  end

  record Device, model : String? = nil, brand : String? = nil, name : String? = nil do
    # :nodoc:
    def self.from_match(match, parser_definition)
      result = {
        "device" => (match[1] rescue nil),
        "model"  => (match[1] rescue nil),
        "brand"  => nil,
      }

      DEVICE_REPLACEMENT_KEYS.each do |template_id|
        template = parser_definition.get(template_id)
        result[template_id.sub("_replacement", "")] = Parser.interpolate(template, match).strip if template
      end

      if result["device"].nil? && result["model"].nil? && result["brand"].nil?
        nil
      else
        new name: result["device"], model: result["model"], brand: result["brand"]
      end
    end
  end

  record Os, family : String? = nil, version : SemanticVersion? = nil do
    # :nodoc:
    def self.from_match(match, parser_definition)
      result = {
        "os" => (match[1] rescue nil),
      }
      version = ""
      (2..4).each do |i|
        result["v#{i - 1}"] = (match[i] rescue "0")
      end
      result["version"] = version

      OS_REPLACEMENT_KEYS.each do |template_id|
        template = parser_definition.get(template_id)
        result[template_id.sub("_replacement", "")] = Parser.interpolate(template, match).strip if template
      end

      if result["os"].nil?
        nil
      else
        new family: result["os"], version: SemanticVersion.new(result["v1"].not_nil!.to_i, result["v2"].not_nil!.to_i, result["v3"].not_nil!.to_i)
      end
    end
  end

  getter user_agent : String
  getter family : String?
  getter version : SemanticVersion?
  getter device : Device?
  getter os : Os?

  # Load [Browserscope pattern library](https://github.com/ua-parser/uap-core) from String.
  def self.load_regexes(regexes_yaml)
    Parser.instance(regexes_yaml)
  end

  # Parse *user_agent_string* using the [Browserscope pattern library](https://github.com/ua-parser/uap-core).
  def initialize(user_agent_string)
    @user_agent = user_agent_string
    @family, @version, @device, @os = Parser.parse(@user_agent) unless @user_agent.nil?
  end

  private class Parser
    @regexes = {} of String => Array(Regex)

    def self.instance(regexes_yaml)
      raise Exception.new("Must load patterns with UserAgent.load_regexes() first") if @@instance.nil? && regexes_yaml.nil?
      return @@instance unless @@instance.nil?
      @@instance = new(regexes_yaml.not_nil!)
    end

    def initialize(regexes_yaml)
      @parser_collections = ParserCollections.from_yaml(regexes_yaml)
      @parser_collections.props.each do |pc_id|
        compile_regex(pc_id, @parser_collections.get(pc_id))
      end
    end

    def self.parse(ua_str)
      instance(nil).not_nil!.parse(ua_str)
    end

    def parse(ua_str)
      device = nil
      os = nil
      family = nil
      version = nil

      @parser_collections.props.each do |pc_id|
        @regexes[pc_id].each_with_index do |re, i|
          m = re.match(ua_str)
          next unless m

          case pc_id
          when "device_parsers"
            device = Device.from_match(m, @parser_collections.device_parsers[i])
          when "os_parsers"
            os = Os.from_match(m, @parser_collections.os_parsers[i])
          when "user_agent_parsers"
            family, version = from_match(m, @parser_collections.user_agent_parsers[i])
          end
          break
        end
      end

      return family, version, device, os
    end

    def from_match(match, parser_definition)
      result = {
        "family" => (match[1] rescue nil),
      }
      (2..4).each do |i|
        result["v#{i - 1}"] = (match[i] rescue "0")
      end

      FAMILY_REPLACEMENT_KEYS.each do |template_id|
        template = parser_definition.get(template_id)
        result[template_id.sub("_replacement", "")] = Parser.interpolate(template, match).strip if template
      end

      return result["family"], SemanticVersion.new(result["v1"].not_nil!.to_i, result["v2"].not_nil!.to_i, result["v3"].not_nil!.to_i)
    end

    def self.interpolate(template : String, m : Regex::MatchData)
      begin
        (0..m.size - 1).each do |i|
          template = template.sub("$#{i}", m[i])
        end
      rescue
      end
      template
    end

    def compile_regex(parser_type : String, parsers)
      @regexes[parser_type] = [] of Regex
      parsers.each do |parser|
        options = Regex::Options::None
        options |= Regex::Options::IGNORE_CASE if parser.regex_flag == 'i'
        @regexes[parser_type] << Regex.new(parser.regex, options)
      end
    end
  end
end
