require 'pg'

module SQLCapsule
  class Wrapper
    attr_reader :db
    private     :db

    def initialize(db)
      @db = db
    end

    def run(query, arguments = [ ], &block)
      db.exec_params(query, arguments) do |result|
        raise DuplicateColumnNamesError.new(result.fields, query) if duplicate_result_columns?(result.fields)

        if block_given?
          result.each do |row|
            block.call(row)
          end
        else
          if result.to_a.size == 1
            result.to_a.first
          else
            result.to_a
          end
        end
      end
    end

    private

    def duplicate_result_columns?(fields)
      fields.uniq.count != fields.count
    end

    class DuplicateColumnNamesError < RuntimeError
      def initialize(fields, query)
        message = "Error duplicate column names in resulting table: #{fields}\nThis usually happens when using a `JOIN` with a `SELECT *`\nYou may need use `AS` to name your columns.\nQUERY: #{query}"
        super(message)
      end
    end

  end
end
