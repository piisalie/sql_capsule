module SQLCapsule
  class QueryGroup
    attr_reader :queries, :wrapper
    private     :queries, :wrapper

    def initialize(wrapper)
      @wrapper = wrapper
      @queries = { }
    end

    def register name, query, *args
      queries[name] = [ query, args ]
    end

    def registered_queries
      queries.keys
    end

    def run name, args = { }, &block
      query = queries.fetch(name) { fail MissingQueryError.new "Query #{name} not registered" }
      check_args query.last, args.keys
      if block_given?
        wrapper.run queries[name], args.values, &block
      else
        wrapper.run queries[name], args.values
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
