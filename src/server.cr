require "log"
require "http/server"
require "./http/*"

Log.info { "starting server" }

trie_service = TrieServiceImpl.new
search_service =
  {% if flag?(:use_brute_force_spell) %}
    BruteForceSpellingSearchService.new
  {% else %}
    BKTreeSpellingSearchService.new
  {% end %}

app_context = AppContext.new(trie_service, search_service)

w_file = File.join(File.dirname(__FILE__), "..", "spec", "fixtures", "swe_wordlist.txt")
t = Time.measure do
  File.each_line(w_file) do |line|
    app_context.add(line)
  end
end

Log.info { "loading data in #{t}" }

server = HTTP::Server.new(
  [
    HTTP::ErrorHandler.new,
    HTTP::LogHandler.new,
    RoutingHandler.new(app_context),
  ]
)

server.bind_tcp "127.0.0.1", 8080
server.listen
