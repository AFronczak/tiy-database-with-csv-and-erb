require "csv"
require "erb"


class Employee
  attr_accessor :name, :phone, :address, :position, :salary, :slack, :github
  # multiple instance variables may be redundant for the purposes of initialize
  def initialize(name)
    @name = name
  end
end

class Menu
  def initialize
    @employee = []

    CSV.foreach("employees.csv", { headers: true, header_converters: :symbol }) do |employee|
      person = Employee.new(employee)

      person.name     = employee[:name]
      person.phone    = employee[:phone]
      person.address  = employee[:address]
      person.position = employee[:position]
      person.salary   = employee[:salary].to_i
      person.slack    = employee[:slack]
      person.github   = employee[:github]

      @employee << person
    end
  end

  def prompt
    loop do
      puts "Welcome to the TIY Database!"
      puts "For adding personnel, press A"
      puts "For searching, press S"
      puts "For deleting, press D"
      puts "To exit, press E"
      puts "For a report, R"

      choice = gets.chomp
      break if choice == "E"

      case choice
      when "A"
        add_person
      when "S"
        search_person
      when "D"
        delete_person
      when "R"
        report
      else
        puts "Try another option"
      end
    end
  end

  def write_to_csv
    CSV.open("employees.csv", "w") do |csv|
      csv << ["Name", "Phone", "Address", "Position", "Salary", "Slack", "Github"]
      @employee.each do |person|
        csv << [person.name, person.phone, person.address, person.position, person.salary, person.slack, person.github]
        end
      end
    end

  def add_person
    puts "Enter employee first and last name"
    name = gets.chomp

    person = Employee.new(name)

    person.name = name

    puts "Enter employee phone number"
    person.phone = gets.chomp

    puts "Enter employee address"
    person.address = gets.chomp

    puts "Employee's position"
    person.position = gets.chomp

    puts "Employee's salary"
    person.salary = gets.chomp.to_i

    puts "Employee's slack account"
    person.slack = gets.chomp

    puts "Employee's github account"
    person.github = gets.chomp

    @employee << person

    write_to_csv
    #using [-1] index confirms person has been added to peope array
    puts "#{@employee [-1].name} has been added to your database."
  end

  def found(person)
    #additional puts statments left out
    puts "Match!:
          #{person.name}
          #{person.phone}
          #{person.address}
          #{person.position}
          #{person.salary}
          #{person.slack}
          #{person.github}"
  end

  #search person modified to include github, slack, and partial name matches

  def search_person
    puts "Whom is it for which you look?"
    search_person = gets.chomp
    matching_person = @employee.find { |person| person.name.include?(search_person) || person.slack == search_person || person.github == search_person}
    if !matching_person.nil?
      found(matching_person)
    else puts "#{search_person}not found"
    end
  end

  # puts "Enter name to delete"
  # delete_name = gets.chomp
  # matches = matching_employees(delete_name)
  # if matches.empty?
  #   p search_name "not found"
  # else
  #   for person in @employee
  #     if person.name == delete_name
  #       puts "#{person.name} & all their info. has been deleted."
  #       @employee.delete(person)
  #       write_to_csv
  #       end
  #     end
  #   end

  def delete_person
    puts "Enter name to delete "
    delete_employee = gets.chomp
    matching_person = @employee.find { |person| person.name == delete_person }
    for person in @employee
      if !matching_person.nil?
        @employee.delete(matching_person)
        write_to_csv
        puts "#{person.name} has been deleted."
        break
      else
        puts "Person not found"
      end
    end
  end

  # This method *takes* a position as an *argument*
  # and *returns* the number of entries in @people
  # that have that position
  def employee_count(search_position)
    number_of_people_with_position = @employee.count { |person| person.position == search_position }
  end

  # This method *takes* a position as an *argument*
  # and returns the minimum salary of all people
  # that have that position
  def minimum_salary(search_position)
    matching_people = @employee.select { |person| person.position == search_position }

    person_with_smallest_salary = matching_people.min_by { |person| person.salary }

    return person_with_smallest_salary.salary
  end

  def minimum_salary_by_using_map_and_min(search_position)
    matching_people = @employee.select { |person| person.position == search_position }

    salaries = matching_people.map { |person| person.salary }

    smallest_salary = salaries.min

    return smallest_salary
  end

  # This method *takes* a position as an *argument*
  # and returns the maximum salary of all people
  # that have that position
  def maximum_salary(search_position)
    matching_people = @people.select { |person| person.position == search_position }

    person_with_largest_salary = matching_people.max_by { |person| person.salary }

    return person_with_largest_salary.salary
  end

  # This method *takes* a position as an *argument*
  # and returns the average salary of all people
  # that have that position
  def average_salary(search_position)
    matching_people = @people.select { |person| person.position == search_position }

    salaries = matching_people.map { |person| person.salary }

    total = 0
    salaries.each do |salary|
      total = total + salary
    end

    average = total / salaries.count

    return average
  end

  # This method *takes* a position as an *argument*
  # and *returns* a String with the names of entries
  # in @people that have that position, combined by commas
  def employee_names(search_position)
    matching_people = @people.select { |person| person.position == search_position}

    names = matching_people.map { |person| person.name }

    combined_names = names.join(",")

    return combined_names
  end

  def report
    puts "An employee report is being created for you now"

    # Read the template.html.erb and shove it into a variable
    # called html_template_from_disk.
    html_template_from_disk = File.read("template.html.erb")

    # Make a new ERB object and give it the `String` from html_template_from_disk
    erb_template = ERB.new(html_template_from_disk)

    # Make an array of the positions (dummy data for now)
    positions = ["Prime Minister", "President", "Campus Director", "Vice President", "Senator", "Programmer", "Instructor", "Lorem Ipsum"]

    # Get the *REAL* positions
    positions = @employee.map { |person| person.position }

    # Remove duplicates
    #! means that the array is changed in place, not as a new array
    positions.uniq!

    # Do the "mail merge" like `magic`
    output = erb_template.result(binding)

    # Write that out to a report.html file
    File.open("report.html", "w") do |file|
      file.puts output
    end
  end
end

menu = Menu.new()
menu.prompt
