require "http/server"

class RoutingHandler
  include HTTP::Handler

  def initialize(app_context : AppContext)
    super()
    @app_context = app_context
  end

  def call(context)
    begin
      Log.info { context.request.resource }
      if (context.request.resource =~ /^\/search*/)
        action = SearchAction.new(@app_context)
        action.execute(context)
        return
      end
    rescue ex
      Log.fatal { "exception caught at routing handler level #{__FILE__}:#{__LINE__}" }
      Log.fatal { ex.message }
      Log.fatal { ex.backtrace.join("\n") }

      return
    end
    call_next(context)
  end
end
