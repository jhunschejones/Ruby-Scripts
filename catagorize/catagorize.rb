require_relative './lib/module_loader.rb'

expenses = []
CSV.foreach("./expenses.csv") do |row|
  if row[2] == "DEBIT"
    expenses << Expense.new(
      transaction_date: row[0],
      description: row[1],
      category: Expense.category_for_description(row[1]),
      amount: row[3]
    )
  end
end

CSV.open("./parsed_expenses.csv", "wb") do |csv|
  csv << [
    "Transaction Date",
    "Description",
    "Amount",
    "Category"
  ]
  expenses.each do |expense|
    csv << [
      expense.transaction_date,
      expense.description,
      expense.amount,
      expense.category
    ]
  end
end


