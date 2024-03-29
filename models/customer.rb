require_relative('../db/sql_runner')
require_relative('film')

class Customer

  attr_accessor :name, :funds
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @name = options["name"]
    @funds = options["funds"]
  end

  def save
    sql = "INSERT INTO customers (name, funds)
    VALUES ($1, $2) RETURNING id"
    values = [@name, @funds]
    result = SqlRunner.run(sql, values)[0]
    @id = result["id"].to_i
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end

  def self.all
    sql = "SELECT*FROM customers"
    customers = SqlRunner.run(sql)
    return customers.map { |customer| Customer.new(customer)}
  end

  def delete
    sql = "DELETE FROM customers WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def update
    sql = "UPDATE customers SET (name, funds) = ($1, $2) WHERE id = $3"
    values = [@name, @funds, @id]
    SqlRunner.run(sql, values)
  end

  def films
    sql = "SELECT films.* FROM films INNER JOIN tickets
    ON films.id = film_id WHERE customer_id = $1"
    values = [@id]
    films = SqlRunner.run(sql, values)
    films.map { |film| Film.new(film)}
  end

  def funds
    sql = "SELECT funds FROM customers WHERE id = $1"
    values = [@id]
    return SqlRunner.run(sql, values)[0]["funds"].to_i
  end

  def buy_ticket(film)
    # Get price of film
    cost = film.price
    # Get customer's funds
    funds = self.funds
    # Update customer funds by funds minus film price
    funds -= cost
    sql = 'UPDATE customers SET funds = $1 WHERE id = $2'
    values = [funds, @id]
    SqlRunner.run(sql, values)
  end

  def ticket_count
    sql = "SELECT*FROM tickets WHERE customer_id = $1"
    values = [@id]
    tickets = SqlRunner.run(sql, values)
    return tickets.count
  end

end
