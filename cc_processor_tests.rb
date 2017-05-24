require_relative "braintree"
require "test/unit"

class BraintreeCCPRocessorTest < Test::Unit::TestCase 

	def setup
		@cc_processor = BraintreeCCProcessor.new
	end

	def teardown
		BraintreeCCProcessor.class_variable_set(:@@people, {})
	end

	def test_should_add_card 
		@cc_processor.add_card("Jourdan", "4242424242424242", "$1000")

		jourdan_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Jourdan"]

		assert_equal "Jourdan", 				 jourdan_hash[:name]
		assert_equal "4242424242424242", jourdan_hash[:card_number]
		assert_equal 1000, 							 jourdan_hash[:limit]
		assert_equal 0, 								 jourdan_hash[:balance]
		assert_equal false, 						 jourdan_hash[:error]
	end

	def test_should_add_invalid_card
		@cc_processor.add_card("Jourdan", "1234567890123456", "$1000") # Invalid Card

		jourdan_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Jourdan"]

		assert_equal "Jourdan", jourdan_hash[:name]
		assert jourdan_hash[:error]
	end

	def test_should_charge_card 
		@cc_processor.add_card("Jourdan", "4242424242424242", "$1000") # Valid Card

		@cc_processor.charge_card("Jourdan", 500)
		jourdan_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Jourdan"]

		assert_equal 500, jourdan_hash[:balance]
	end

	def test_should_not_charge_card
		@cc_processor.add_card("Jourdan", "4242424242424242", "$1000") # Valid Card

		@cc_processor.charge_card("Jourdan", 1500) # Can't charge amount that's over limit
		jourdan_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Jourdan"]

		assert_equal 0, jourdan_hash[:balance]		
	end

	def test_should_credit_card
		@cc_processor.add_card("Jourdan", "4242424242424242", "$1000") # Valid Card

		@cc_processor.credit_card("Jourdan", 500)
		jourdan_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Jourdan"]

		assert_equal -500, jourdan_hash[:balance]		
	end

	def test_should_validate_card_and_return_valid
		assert @cc_processor.valid_card?("4242424242424242")
	end

	def test_should_validate_card_and_return_invalid
		assert_equal false, @cc_processor.valid_card?("1234567890123456")
	end

	def test_should_get_amount_without_dollar_sign
		amount = "$1000"
		assert_equal 1000, @cc_processor.amount_without_dollar_sign(amount)
	end

	def test_should_get_amount_with_dollar_sign
		amount = 1000
		assert_equal "$1000", @cc_processor.amount_with_dollar_sign(amount)
	end

	def test_should_summarize
		@cc_processor.add_card("Jourdan", "4242424242424242", "$1000") # Valid Card
		@cc_processor.charge_card("Jourdan", 500)
		@cc_processor.credit_card("Jourdan", 200)
		@cc_processor.add_card("Jericho", "1234567890123456", "$1000") # Invalid Card

		people_hash = BraintreeCCProcessor.class_variable_get(:@@people)

		jourdan_hash = people_hash["Jourdan"]
		jericho_hash = people_hash["Jericho"]

		summary = "Jericho: error\nJourdan: $300\n" # Alphabetized
		assert_equal summary, @cc_processor.summarize
	end

	def test_should_delegate_command_correctly
		add_command 	 = "Add Tom 4111111111111111 $1000".split(" ")
		charge_command = "Charge Tom $100".split(" ")
		credit_command = "Credit Tom $50".split(" ")

		@cc_processor.delegate_command("add", add_command)
		tom_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Tom"]

		assert_equal "Tom", tom_hash[:name] # Only test one key since we're already testing add_card above

		@cc_processor.delegate_command("charge", charge_command)
		tom_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Tom"]

		assert_equal 100, tom_hash[:balance]

		@cc_processor.delegate_command("credit", credit_command)
		tom_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Tom"]

		assert_equal 50, tom_hash[:balance]
	end

	def test_should_read_input
		add_command = "Add Tom 4111111111111111 $1000"
		@cc_processor.read_input(add_command)

		tom_hash = BraintreeCCProcessor.class_variable_get(:@@people)["Tom"]

		assert_equal "Tom", tom_hash[:name] # Only test one key since we're already testing add_card above
	end

end