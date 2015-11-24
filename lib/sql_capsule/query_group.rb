module SQLCapsule
  class QueryGroup
    attr_reader :queries, :wrapper
    private     :queries, :wrapper

    def initialize(wrapper)
      @wrapper = wrapper
      @queries = { }
    end

    def register(name, query, *args, &block)
      queries[name] = [ query, block, args ]
    end

    def registered_queries
      queries.keys
    end

    def run name, args = { }
      query = queries.fetch(name) { fail MissingQueryError.new "Query #{name} not registered" }
      check_args query.last, args.keys
      block = queries[name][1]
      if block
        if block_given?
          wrapper.run(queries[name].first, args.values).each do |row|
            yield block.call(row)
          end
        else
          block.call(wrapper.run queries[name].first, args.values)
        end
      else
        if block_given?
          wrapper.run(queries[name].first, args.values).each do |row|
            yield row
          end
        else
          wrapper.run queries[name].first, args.values
        end
      end
    end

    private

    def check_args required_args, args
      required_args.each do |keyword|
        fail MissingKeywordArgumentError.new "Missing query argument: #{keyword}" unless args.include? keyword
      end
    end

    class MissingQueryError < RuntimeError; end
    class MissingKeywordArgumentError < RuntimeError; end

  end
end
