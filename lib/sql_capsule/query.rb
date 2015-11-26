module SQLCapsule
  class Query
    attr_reader :sql, :args, :pre_processor
    private     :sql

    def initialize(sql, *args, &pre_processor)
      @sql  = sql
      @args = args
      @pre_processor = pre_processor || Proc.new { |row| row }
      verify_arguments
    end

    def to_sql
      sql.end_with?(";") ? sql : sql + ";"
    end

    def filter_args(given_args)
      given_args.values_at(*args)
    end

    def add_post_processor(block)
      block ||= Proc.new { |row| row }
      Proc.new { |row| block.call(pre_processor.call(row)) }
    end

    private

    def verify_arguments
      raise ArgumentCountMismatchError.new(sql,args) unless args_count_matches_sql_args_count?
    end

    def args_count_matches_sql_args_count?
      sql.scan(/\$\d+/).count == args.count
    end

    class ArgumentCountMismatchError < RuntimeError
      def initialize(sql, args)
        message = "Argument count mismatch\n#{args.count} arguments provided for\nSQL: #{sql}\nArgs:#{args}"
        super(message)
      end
    end

  end
end
