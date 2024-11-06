class Trie
  class Node
    property parent : Node?
    property value : Char?
    property children : Set(Node)

    def_equals_and_hash @value

    def initialize(parent : Node?, value : Char?)
      @parent = parent
      @value = value
      @children = Set(Node).new
    end

    # unused
    def is_root?
      parent.nil? && value.nil?
    end

    def is_end?
      !parent.nil? && value.nil?
    end

    def add(ord : Array(Char))
      if ord.size > 0
        c = ord.delete_at(0)
        n = Node.new(parent: self, value: c)
        n1 = @children.find { |i| i == n }
        if n1.nil?
          @children.add(n)
          n.add(ord)
        else
          n1.add(ord)
        end
      else
        @children.add(Node.new(parent: self, value: nil))
      end
    end

    def to_s
      res = [] of Char?
      node = self
      while (node != nil)
        n = node.not_nil!
        res << n.value unless n.value.nil?
        node = n.parent
      end
      res.reverse.join
    end
  end

  property root : Node

  def initialize
    @root = Node.new(parent: nil, value: nil)
  end

  def add(word : String)
    root.add(word.chars)
  end

  def all
    res = [] of String
    root.children.each do |child|
      collect(child, res)
    end
    res
  end

  def count
    all.size
  end

  def beginning_with(word : String)
    res = [] of String
    root.children.each do |child|
      recursive_lookup(child, word.chars, 0, res)
    end
    res
  end

  private def collect(node : Node,
                      result : Enumerable(String))
    node.children.each do |child|
      collect(child, result)
    end
    if node.is_end?
      result << node.to_s
    end
  end

  private def recursive_lookup(node : Node,
                               word : Array(Char),
                               position : Int,
                               result : Array(String))
    if word.size > 0 &&
       position < word.size &&
       node.value != word[position]
      return
    end
    node.children.each do |child|
      recursive_lookup(child, word, position + 1, result)
    end
    if node.is_end?
      result << node.to_s
    end
  end
end
