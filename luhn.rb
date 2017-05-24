class Luhn
  def checksum(number)
    products = luhn_doubled(number)
    sum = products.inject(0) { |t,p| t + sum_of(p) }
    checksum = 10 - (sum % 10)
    checksum == 10 ? 0 : checksum
  end

  def luhn_doubled(number)
    numbers = split_digits(number).reverse
    numbers.map.with_index do |n,i|
      i.even? ? n*2 : n*1
    end.reverse
  end

  def sum_of(number)
    split_digits(number).inject(:+)
  end

  def card_valid?(number)
    numbers = split_digits(number)
    numbers.pop == checksum(numbers.join)
  end

  def split_digits(number)
    number.to_s.split(//).map(&:to_i)
  end
end