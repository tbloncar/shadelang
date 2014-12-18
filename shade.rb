# See @tomstuart's 'Understanding Computation'

class VirtualMachine < Struct.new(:statement, :env)
  def step
    self.statement, self.env = statement.reduce(env)
  end

  def run
    while statement.reducible?
      puts "#{statement}, #{env}"
      step
    end

    puts "#{statement}, #{env}"
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end

  def reducible?
    false
  end
end

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<#{self}>"
  end

  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    if left.reducible?
      Add.new(left.reduce(env), right)
    elsif right.reducible?
      Add.new(left, right.reduce(env))
    else
      Number.new(left.value + right.value)
    end
  end

  def reducible?
    true
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    if left.reducible?
      Multiply.new(left.reduce(env), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(env))
    else
      Number.new(left.value * right.value)
    end
  end

  def reducible?
    true
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    if left.reducible?
      LessThan.new(left.reduce(env), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(env))
    else
      Boolean.new(left.value < right.value)
    end
  end

  def reducible?
    true
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
    "no-op"
  end

  def inspect
    "<#{self}>"
  end

  def ==(other_statement)
    other_statement.instance_of?(NoOp)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    if expression.reducible?
      [Assign.new(name, expression.reduce(env)), env]
    else
      [NoOp.new, env.merge({ name => expression })]
    end
  end
  
  def reducible?
    true
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if #{condition} then #{consequence} else #{alternative}"
  end

  def inspect
    "<#{self}>"
  end

  def reduce(env)
    if condition.reducible?
      [If.new(condition.reduce(env), consequence, alternative), env]
    else
      case condition
      when Boolean.new(true) then [consequence, env]
      when Boolean.new(false) then [alternative, env]
      end
    end
  end

  def reducible?
    true
  end
end

VirtualMachine.new(
  Add.new(
    Number.new(2),
    Number.new(3)
  )
).run

VirtualMachine.new(
  Multiply.new(
    Add.new(Number.new(4), Number.new(8)),
    Number.new(5)
  )
).run

VirtualMachine.new(
  LessThan.new(
    Number.new(5),
    Add.new(
      Number.new(4),
      Number.new(3)
    )
  )
).run

VirtualMachine.new(
  Assign.new(:x, Number.new(3)),
  {}
).run

VirtualMachine.new(
  If.new(
    Boolean.new(false),
    Multiply.new(
      Number.new(2),
      Number.new(11)
    ),
    Add.new(
      Number.new(10),
      Number.new(2)
    )
  )
).run