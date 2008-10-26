require "elevator"
require "person"

class Simulator
  def initialize(people, elevators)
    @people   = people
    @elevators = elevators
    @steps     = 0
  end
  
  attr_reader :people, :elevator
  
  def update_people
    @people.each do |person|
      @elevators.each do |elevator|
        if person.at_destination?
          if elevator.people.include?(person)
            elevator.remove_person(person)
            puts "P#{person.object_id} reached destination floor #{elevator.floor}"
          end
        elsif elevator.floor == person.floor
          unless @elevators.any? { |e| e.people.include?(person) } || elevator.at_capacity?
            elevator.add_person(person) 
            puts "P#{person.object_id} gets on the elevator at #{elevator.floor}"
          end
        end
      end
    end
  end
  
  def run
    until @people.all? { |person| person.at_destination? }
      @elevators.each do |elevator|
        0.upto(elevator.top_floor) do |floor|
          @steps += 1
          puts "E#{elevator.object_id} is now on floor #{elevator.floor}" <<
               " with #{elevator.occupants} people"
          update_people
          elevator.move_up
        end
      end
    
      @elevators.each do |elevator|
         @steps += 1
        elevator.top_floor.downto(0) do |floor|
          puts "E#{elevator.object_id} is now on floor #{elevator.floor}" <<
               " with #{elevator.occupants} people"
          update_people
          elevator.move_down
        end
      end
    end
  end
  
  attr_reader :steps

end

if __FILE__ == $PROGRAM_NAME
  people = (1..100).map { Person.new(:floor => rand(11), :destination => rand(11)) } 
  
  elevator = Elevator.new(:capacity => 2, :top_floor => 10)
  elevator2 = Elevator.new(:capacity => 4, :top_floor => 10)

  sim = Simulator.new(people, [elevator, elevator2])
  sim.run
  puts "Took #{sim.steps} steps"
end