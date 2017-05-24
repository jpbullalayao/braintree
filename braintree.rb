require './luhn'

class BraintreeCCProcessor

	@@people = {}

	def add_card(person_name, card_number, limit) 
		card_valid = validate_card(card_number)

		person = {}
		person[:name] = person_name

		if card_valid
			person[:card_number] = card_number
			person[:limit]			 = amount_without_dollar_sign(limit) 
			person[:balance]		 = 0
			person[:error]			 = false
		else 
			person[:error] = true
		end

		@@people["#{person_name}"] = person
	end

	def charge_card(person_name, amount)
		person = @@people["#{person_name}"]
		
		if !person[:error] 
			new_amount = person[:balance] + amount
			if new_amount <= person[:limit]
				person[:balance] = new_amount
				@@people["#{person_name}"] = person
			end
		end
	end

	def credit_card(person_name, amount)
		person = @@people["#{person_name}"]

		if !person[:error]
			new_amount = person[:balance] - amount
			person[:balance] = new_amount
			@@people["#{person_name}"] = person
		end
	end

	def validate_card(card_number)
		luhn = Luhn.new 
		luhn.card_valid?(card_number)
	end

	def amount_without_dollar_sign(amount)
		amount.slice(1..-1).to_i
	end

	def amount_with_dollar_sign(amount)
		"$#{amount}"
	end

	def summarize
		sorted_people = @@people.keys.sort 

		sorted_people.each do |person|
			person_hash   = @@people["#{person}"]
			line_to_print = person_hash[:name] + ": "

			if person_hash[:error]
				line_to_print += "error"
			else 
				line_to_print += amount_with_dollar_sign(person_hash[:balance])
			end

			print "#{line_to_print}\n"
		end
	end

	def delegate_command(command, stdin) 
		case command 
			when 'add'
				person_name = stdin[1]
				card_number = stdin[2]
				limit				= stdin[3]

				add_card(person_name, card_number, limit)
			when 'charge'
				person_name = stdin[1]
				amount			= amount_without_dollar_sign(stdin[2])

				charge_card(person_name, amount)
			when 'credit'
				person_name = stdin[1]
				amount			= amount_without_dollar_sign(stdin[2])

				credit_card(person_name, amount)
		end
	end

	def read_input(input)
		stdin   = input.split(" ")
		command = stdin[0].downcase
		delegate_command(command, stdin)
	end

	if __FILE__ == $0
		cc_processor = BraintreeCCProcessor.new

		if ARGV.length.zero?
			lines = ARGF.read.split("\n")
			lines.each do |line|
				cc_processor.read_input(line)
			end
		else 
			File.readlines(ARGV[0]).each do |fileline|
				cc_processor.read_input(fileline)
			end
		end

		cc_processor.summarize
	end

end