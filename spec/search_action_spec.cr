require "./spec_helper"

class HttpContextMock
  class RequestMock
    property query_params = Hash(String, String).new
    def initialize(search)
      @query_params["s"] = search
    end
  end
  class ResponseMock

    property output : String = ""
    property content_type : String = ""
    property status_code : Int32 = 0

    def print(output)
      @output = output
    end
  end

  property request : RequestMock
  property response : ResponseMock

  def initialize(search)
    @request = RequestMock.new(search)
    @response = ResponseMock.new
  end

  def output
    @response.output
  end
end

class AppContextMock < AppContextProtocol
  def beginning_with(word)
    if word == "hit"
      return %w{ett två tre}
    elsif word == "miss"
      return [] of String
    end
    [] of String
  end

  def search(word)
    %w{nio tio elva}
  end
end

describe SearchAction do
  context "searching" do
    it "should load context and perform a search returning words beginning with" do
      subject = SearchAction.new(AppContextMock.new)

      http_context = HttpContextMock.new("hit")
      subject.execute(http_context)

      http_context.output.should eq("{\"suggestions\":[],\"beginning_with\":[\"ett\",\"två\",\"tre\"]}")
    end

    it "should load context and perform a search returning spelling suggestions" do
      subject = SearchAction.new(AppContextMock.new)

      http_context = HttpContextMock.new("miss")
      subject.execute(http_context)

      http_context.output.should eq("{\"suggestions\":[\"nio\",\"tio\",\"elva\"],\"beginning_with\":[]}")
    end
  end
end
