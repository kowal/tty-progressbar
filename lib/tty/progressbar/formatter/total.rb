# coding: utf-8

module TTY
  class ProgressBar
    class TotalFormatter
      MATCHER = /:total/.freeze

      def initialize(progress, *args, &block)
        @progress = progress
      end

      # Determines whether this formatter is applied or not.
      #
      # @param [Object] value
      #
      # @return [Boolean]
      #
      # @api private
      def matches?(value)
        !!(value.to_s =~ MATCHER)
      end

      def format(value)
        value.gsub(MATCHER, @progress.total.to_s)
      end
    end # TotalFormatter
  end # ProgressBar
end # TTY
