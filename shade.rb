class VirtualMachine < Struct.new(:statement, :env)
  def step
    self.statement, self.env = statement.reduce(env)  # => <5>, <12 * 5>, <60>, <5 < 7>, <true>, [<no-op>, {:x=><3>}], [<10 + 2>, nil], <12>
  end

  def run
    while statement.reducible?     # => true, false, true, true, false, true, true, false, true, false, true, true, false
      puts "#{statement}, #{env}"  # => nil, nil, nil, nil, nil, nil, nil, nil
      step                         # => <5>, <12 * 5>, <60>, <5 < 7>, <true>, [<no-op>, {:x=><3>}], [<10 + 2>, nil], <12>
    end                            # => nil, nil, nil, nil, nil

    puts "#{statement}, #{env}"  # => nil, nil, nil, nil, nil
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s                      # => "true", "true", "true", "true", "true", "false", "false", "false", "false"
  end

  def inspect
    "<#{self}>"  # => "<true>", "<true>", "<true>", "<true>", "<false>", "<false>"
  end

  def reducible?
    false         # => false, false
  end
end

class Number < Struct.new(:value)
  def to_s
    value.to_s                     # => "2", "3", "2", "3", "2", "3", "5", "5", "5", "5", "5", "4", "8", "5", "4", "8", "5", "4", "8", "5", "12", "12", "12", "5", "12", "5", "12", "5", "12", "5", "12", "5", "60", "60", "60", "60", "60", "5", "4", "3", "4", "3", "5", "4", "3", "5", "4", "3", "7", "7", "5", "7", "5", "7", "5", "7", "5", "7", "5", "7", "3", "3", "3", "3", "3", "3", "3", "2", "11", "2", "11", "10", "2", "10", "2", "2", "11", "10", "2", "2", "11", "10", "2", "10", "2", "10", "2", "10", "2", "10", "2", "10", "2", "10", "2", "12", "12", "12", "12", "12"
  end

  def inspect
    "<#{self}>"  # => "<2>", "<3>", "<5>", "<5>", "<5>", "<5>", "<5>", "<12>", "<12>", "<60>", "<60>", "<60>", "<60>", "<5>", "<4>", "<3>", "<7>", "<7>", "<3>", "<3>", "<3>", "<3>", "<3>", "<2>", "<11>", "<10>", "<2>", "<12>", "<12>", "<12>", "<12>"
  end

  def reducible?
    false         # => false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"               # => "2 + 3", "2 + 3", "4 + 8", "4 + 8", "4 + 8", "4 + 3", "4 + 3", "4 + 3", "10 + 2", "10 + 2", "10 + 2", "10 + 2", "10 + 2", "10 + 2", "10 + 2", "10 + 2", "10 + 2"
  end

  def inspect
    "<#{self}>"  # => "<2 + 3>", "<4 + 8>", "<4 + 3>", "<10 + 2>", "<10 + 2>", "<10 + 2>", "<10 + 2>", "<10 + 2>", "<10 + 2>"
  end

  def reduce(env)
    if left.reducible?                      # => false, false, false, false
      Add.new(left.reduce(env), right)
    elsif right.reducible?                  # => false, false, false, false
      Add.new(left, right.reduce(env))
    else
      Number.new(left.value + right.value)  # => <5>, <12>, <7>, <12>
    end                                     # => <5>, <12>, <7>, <12>
  end

  def reducible?
    true          # => true, true, true, true
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"                    # => "4 + 8 * 5", "4 + 8 * 5", "12 * 5", "12 * 5", "12 * 5", "12 * 5", "12 * 5", "2 * 11", "2 * 11", "2 * 11"
  end

  def inspect
    "<#{self}>"  # => "<4 + 8 * 5>", "<12 * 5>", "<12 * 5>", "<12 * 5>", "<12 * 5>", "<2 * 11>"
  end

  def reduce(env)
    if left.reducible?                       # => true, false
      Multiply.new(left.reduce(env), right)  # => <12 * 5>
    elsif right.reducible?                   # => false
      Multiply.new(left, right.reduce(env))
    else
      Number.new(left.value * right.value)   # => <60>
    end                                      # => <12 * 5>, <60>
  end

  def reducible?
    true          # => true, true
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"                    # => "5 < 4 + 3", "5 < 4 + 3", "5 < 7", "5 < 7", "5 < 7", "5 < 7", "5 < 7"
  end

  def inspect
    "<#{self}>"  # => "<5 < 4 + 3>", "<5 < 7>", "<5 < 7>", "<5 < 7>", "<5 < 7>"
  end

  def reduce(env)
    if left.reducible?                       # => false, false
      LessThan.new(left.reduce(env), right)
    elsif right.reducible?                   # => true, false
      LessThan.new(left, right.reduce(env))  # => <5 < 7>
    else
      Boolean.new(left.value < right.value)  # => <true>
    end                                      # => <5 < 7>, <true>
  end

  def reducible?
    true          # => true, true
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    env[name]
  end

  def reducible?
    true
  end
end

class NoOp
  def to_s
    "no-op"  # => "no-op", "no-op", "no-op", "no-op", "no-op"
  end

  def inspect
    "<#{self}>"  # => "<no-op>", "<no-op>", "<no-op>", "<no-op>"
  end

  def ==(other_statement)
    other_statement.instance_of?(NoOp)
  end

  def reducible?
    false         # => false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"                  # => "x = 3", "x = 3"
  end

  def inspect
    "<#{self}>"  # => "<x = 3>"
  end

  def reduce(env)
    if expression.reducible?                           # => false
      [Assign.new(name, expression.reduce(env)), env]
    else
      [NoOp.new, env.merge({ name => expression })]    # => [<no-op>, {:x=><3>}]
    end                                                # => [<no-op>, {:x=><3>}]
  end
  
  def reducible?
    true                                               # => true
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if #{condition} then #{consequence} else #{alternative}"  # => "if false then 2 * 11 else 10 + 2", "if false then 2 * 11 else 10 + 2"
  end

  def inspect
    "<#{self}>"  # => "<if false then 2 * 11 else 10 + 2>"
  end

  def reduce(env)
    if condition.reducible?                                           # => false
      [If.new(condition.reduce(env), consequence, alternative), env]
    else
      case condition                                                  # => <false>
      when Boolean.new(true) then [consequence, env]
      when Boolean.new(false) then [alternative, env]                 # => [<10 + 2>, nil]
      end                                                             # => [<10 + 2>, nil]
    end                                                               # => [<10 + 2>, nil]
  end

  def reducible?
    true          # => true
  end
end

VirtualMachine.new(  # => VirtualMachine
  Add.new(           # => Add
    Number.new(2),   # => <2>
    Number.new(3)    # => <3>
  )                  # => <2 + 3>
).run                # => nil

VirtualMachine.new(                         # => VirtualMachine
  Multiply.new(                             # => Multiply
    Add.new(Number.new(4), Number.new(8)),  # => <4 + 8>
    Number.new(5)                           # => <5>
  )                                         # => <4 + 8 * 5>
).run                                       # => nil

VirtualMachine.new(   # => VirtualMachine
  LessThan.new(       # => LessThan
    Number.new(5),    # => <5>
    Add.new(          # => Add
      Number.new(4),  # => <4>
      Number.new(3)   # => <3>
    )                 # => <4 + 3>
  )                   # => <5 < 4 + 3>
).run                 # => nil

VirtualMachine.new(               # => VirtualMachine
  Assign.new(:x, Number.new(3)),  # => <x = 3>
  {}                              # => {}
).run                             # => nil

VirtualMachine.new(      # => VirtualMachine
  If.new(                # => If
    Boolean.new(false),  # => <false>
    Multiply.new(        # => Multiply
      Number.new(2),     # => <2>
      Number.new(11)     # => <11>
    ),                   # => <2 * 11>
    Add.new(             # => Add
      Number.new(10),    # => <10>
      Number.new(2)      # => <2>
    )                    # => <10 + 2>
  )                      # => <if false then 2 * 11 else 10 + 2>
).run                    # => nil

# >> 2 + 3, 
# >> 5, 
# >> 4 + 8 * 5, 
# >> 12 * 5, 
# >> 60, 
# >> 5 < 4 + 3, 
# >> 5 < 7, 
# >> true, 
# >> x = 3, {}
# >> no-op, {:x=><3>}
# >> if false then 2 * 11 else 10 + 2, 
# >> 10 + 2, 
# >> 12, 