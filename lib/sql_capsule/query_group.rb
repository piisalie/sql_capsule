module SQLCapsule
  class QueryGroup
    attr_reader :queries, :wrapper
    private     :queries, :wrapper

    def initialize(wrapper)
      @wrapper = wrapper
      @queries = { }
    end

    def register(name, query, *args, &block)
      queries[name] = [ query, block || ->(row) { row }, args ]
    end

    def registered_queries
      queries.keys
    end

    def run name, args = { }, &handler
      query = queries.fetch(name) { fail MissingQueryError.new "Query #{name} not registered" }
      check_args query.last, args.keys

      block = handler ? ->(row) { handler.call(queries[name][1].call(row)) } : queries[name][1]
      wrapper.run(queries[name].first, args.values, &block)
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
