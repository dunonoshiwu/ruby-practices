#!/usr/bin/env ruby

x = 1
while x < 21 do
  if x % 3 == 0 && x % 5 == 0 
    puts "FizzBuzz"
  elsif x % 5 == 0 
    puts "Buzz"
  elsif x % 3 == 0 
    puts "Fizz"
  else
    puts x
  end
  x += 1
end
