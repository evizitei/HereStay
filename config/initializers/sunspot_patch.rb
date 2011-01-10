# Patch Sunspot to allow wildcard search
module Sunspot
  module Query
    class Dismax
      def to_params

        if @keywords.match(/\*\Z/)
          params = { :'q.alt' => @keywords }
        else
          params = { :q => @keywords }
        end
        
        params[:fl] = '* score'
        params[:qf] = @fulltext_fields.values.map { |field| field.to_boosted_field }.join(' ')
        params[:defType] = 'dismax'
        if @phrase_fields
          params[:pf] = @phrase_fields.map { |field| field.to_boosted_field }.join(' ')
        end
        unless @boost_queries.empty?
          params[:bq] = @boost_queries.map do |boost_query|
            boost_query.to_boolean_phrase
          end
        end
        unless @boost_functions.empty?
          params[:bf] = @boost_functions.map do |boost_function|
            boost_function.to_s
          end
        end
        if @minimum_match
          params[:mm] = @minimum_match
        end
        if @phrase_slop
          params[:ps] = @phrase_slop
        end
        if @query_phrase_slop
          params[:qs] = @query_phrase_slop
        end
        if @tie
          params[:tie] = @tie
        end
        @highlights.each do |highlight|
          Sunspot::Util.deep_merge!(params, highlight.to_params)
        end
        params
      end
    end

    class CommonQuery
      def to_params
        params = {}
        @components.each do |component|
          Sunspot::Util.deep_merge!(params, component.to_params)
        end
        @parameter_adjustment.call(params) if @parameter_adjustment
        params[:q] ||= '*:*' unless params[:'q.alt'] 
        params
      end
    end
  end
end