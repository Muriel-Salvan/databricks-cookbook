require 'diffy'

# Some helpers to our actions
module ActionClassHelpers

  # Augment the converge_if_changed method with a nice diff for properties that are complex (like Hash)
  #
  # Parameters::
  # * *properties* (Array<Symbol>): Property names applicable to those changes
  # * *converge_block* (Proc): The code block given to converge_if_changed
  # Result::
  # * Boolean: Has the block been executed?
  def converge_if_changed(*properties, &converge_block)
    block_executed = super
    unless ENV['databricks_details'] == '0'
      # Display diffs on complex structures in a sexy way
      (properties.empty? ? new_resource.class.state_properties.map(&:name) : properties).each do |property|
        current_value = current_resource.send(property)
        new_value = new_resource.send(property)
        next if current_value == new_value || (!current_value.is_a?(Hash) && !new_value.is_a?(Hash))
        header_diff = "----- Diffs of #{property} -----"
        indent = ' ' * 6
        puts
        puts "#{indent}#{header_diff}"
        Diffy::Diff.default_format = :color
        puts Diffy::Diff.new(
          current_value.is_a?(Hash) ? "#{JSON.pretty_generate(Hash[current_value.sort])}\n" : current_value.to_s,
          new_value.is_a?(Hash) ? "#{JSON.pretty_generate(Hash[new_value.sort])}\n" : new_value.to_s,
          context: 2
        ).to_s.split("\n").map { |line| "#{indent}#{line}" }.join("\n")
        puts "#{indent}#{'-' * header_diff.size}"
      end
    end
    block_executed
  end

end
