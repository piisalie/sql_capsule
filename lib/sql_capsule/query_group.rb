require_relative 'query'

module SQLCapsule
  class QueryGroup
    attr_reader :queries, :wrapper, :query_object
    private     :queries, :wrapper, :query_object

    def initialize(wrapper, query_object = Query)
      @wrapper      = wrapper
      @queries      = { }
      @query_object = query_object
    end

    def register(name, query, *args, &block)
      queries[name] = query_object.new(query, *args, &block)
    end

    def registered_queries
      queries.keys
    end

    def run name, args = { }, &handler
      query = find_query name
      check_args query.args, args.keys

      block = query.add_post_processor handler
      wrapper.run(query.to_sql, query.filter_args(args), &block)
    end

    private

    def find_query name
      queries.fetch(name) { fail MissingQueryError.new "Query #{name} not registered" }
    end

    def check_args required_args, args
      required_args.each do |keyword|
        fail MissingKeywordArgumentError.new "Missing query argument: #{keyword}" unless args.include? keyword
      end
    end

    class MissingQueryError           < RuntimeError; end
    class MissingKeywordArgumentError < RuntimeError; end

  end
end
