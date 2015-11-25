require_relative 'query'

module SQLCapsule
  class QueryGroup
    attr_reader :queries, :wrapper
    private     :queries, :wrapper

    def initialize(wrapper)
      @wrapper = wrapper
      @queries = { }
    end

    def register(name, query, *args, &block)
      queries[name] = Query.new(query, *args, &block)
    end

    def registered_queries
      queries.keys
    end

    def run name, args = { }, &handler
      query = queries.fetch(name) { fail MissingQueryError.new "Query #{name} not registered" }
      check_args query.args, args.keys

      block = handler ? ->(row) { handler.call(query.pre_processor.call(row)) } : query.pre_processor
      wrapper.run(query.to_sql, query.filter_args(args), &block)
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
