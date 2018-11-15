# :nodoc:
module PropertyReflection
  def get(key : String)
    keys : Array(String) = props
    idx : Int32? = keys.index(key)
    raise "No property with name #{key}" if idx.nil?
    {{@type.instance_vars.map &.name}}[idx]
  end

  def props
    {{@type.instance_vars.map &.name.stringify}}
  end
end
