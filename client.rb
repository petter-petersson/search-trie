require 'io/console'
require 'net/http'
require 'json'

brk = ->(c) { ["\u0003"].include?(c) }
backspace = ->(c) { ["\x0008", "\u007F"].include?(c) }
u = URI::HTTP.build(host: "localhost", port: 8080, path: "/search")
queue = Thread::Queue.new
result_queue = Thread::Queue.new

screen_updated = Thread.new do
  current_input = []
  while update = result_queue.pop do
    current_input = update[:input] unless update[:input].nil?
    print "\033[2J"
    5.times do
      print "\r"
      print "\033[A"
      print "\033[K"
    end
    print "\r"
    print "\033[K"
    puts update[:result]&.[]("suggestions")&.join(" ")
    print "\r"
    print "\033[K"
    puts "---"
    print "\r"
    print "\033[K"
    puts update[:result]&.[]("beginning_with")&.join(" ")
    print "\r"
    print "\033[K"
    puts
    print "\r"
    print "\033[K"
    puts "enter text:"
    print "\r"
    print "\033[K"
    puts current_input.join
  end
end

net_client = Thread.new do
  while search = queue.pop
    if search.size > 1
      u.query = "s=#{search.join}"
      res = JSON.parse(Net::HTTP.get(u))
      result_queue << {input: nil, result: res }
    end
  end
end

# trigger screen update first
result_queue << {input: [], result: {}}
input_buffer = []
while c = STDIN.getch do
  case c
    when /[a-zåäö]/
      input_buffer << c
      queue << input_buffer
      result_queue << {input: input_buffer, result: {}}
    when brk
      break
    when backspace
      input_buffer = input_buffer[0..-2]
      queue << input_buffer
      result_queue << {input: input_buffer, result: {}}
    end
end
