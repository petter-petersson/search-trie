require "json"

class SearchAction
  def initialize(app_context : AppContextProtocol)
    @app_context = app_context
  end

  def execute(context)
    Log.info { context }

    params = context.request.query_params
    search = params.fetch("s") { "" }

    context.response.content_type = "application/json"
    context.response.status_code = 200

    if search.nil?
      beginning_with = [] of String
      suggestions = [] of String
    else
      beginning_with = @app_context.beginning_with(search)
      suggestions = if beginning_with.size > 0
                      [] of String
                    else
                      @app_context.search(search)
                    end
    end
    result = {
      suggestions:    suggestions,
      beginning_with: beginning_with,
    }

    response = JSON.build do |json|
      json.object do
        json.field "suggestions" do
          json.array do
            result[:suggestions].each do |w|
              json.string w
            end
          end
        end
        json.field "beginning_with" do
          json.array do
            result[:beginning_with].each do |w|
              json.string w
            end
          end
        end
      end
    end

    context.response.print response
  end
end
