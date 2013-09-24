module Cucumberator::Commands
  class Save
    class << self
      def perform(scenario, step_line, last_input, saved_stack, *args, &block)
        new(scenario, step_line, last_input, saved_stack).save
        false
      end

      def save_empty_line(scenario, step_line, saved_stack)
        new(scenario, step_line, "", saved_stack).force_save_empty_line
        false
      end
    end

    attr_accessor :step_line, :saved_stack

    def initialize(scenario, step_line, last_input, saved_stack)
      @step_line, @last_input, @saved_stack = step_line, last_input, saved_stack
      @feature_file = Cucumberator::FeatureFile.new(scenario)
    end

    def save
      if @last_input.to_s.empty?
        puts "Hm... nothing to save yet?"
      else
        string_to_save = (" " * spaces_in_last_input) + @last_input
        save_to_feature_file(string_to_save)

        puts "Saved `#{@last_input}` to #{@feature_file}"
        @last_input = nil
      end
    end

    def force_save_empty_line
      save_to_feature_file("")
      @last_input = nil
    end

    def save_to_feature_file(string)
      if step_line
        lines = @feature_file.lines
        lines.insert(step_line - 1, string.to_s+$/) # $/ - default newline separator
        @feature_file.overwrite(lines.join)
        self.saved_stack << [step_line.number, string]
        self.step_line.increment!
      else
        @feature_file.append(string)
        self.saved_stack << [@feature_file.lines.size, string]
      end
    end

    def spaces_in_last_input
      lines = @feature_file.lines
      line = nil

      if step_line
        line  = lines[step_line-1]
        lines = lines.slice(0, step_line-1) if line.to_s.empty?
      end

      if line.to_s.empty?
        line = lines.reverse.detect { |l| !l.to_s.empty? }
      end

      spaces = line.to_s =~ /\S/
      spaces.to_i
    end
  end
end
