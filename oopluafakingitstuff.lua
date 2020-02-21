--- OOP stuff, like making a class in C/C#/Java, 
-- but not really, modules are better for this 
-- as you can type these but not instance them

Animal = {height = 0, weight = 0, name = "Dude", sound = "Sweet"}

function Animal:new(height, weight, name, sound)
	setmetatable({}, Animal)

	self.height = height
	self.weight = weight
	self.name = name
	self.sound = sound

	return self
end

function Animal:toString()
	animalString = string.format("%s weighs %.1f lbs, is %.1f in tall and says %s", self.name, self.weight, self.height, self.sound)

	return animalString
end

local spot = Animal:new(10, 15, "Spot", "Woof")
local fido = Animal:new(3, 9, "Fido", "Bork Bork")

io.write("\n", spot.weight, "\n")
io.write("\n", spot:toString(), "\n")

io.write("\n", fido.weight, "\n")
io.write("\n", fido:toString(), "\n")

Cat = Animal:new()

function Cat:new(height, weight, name, sound, faveFood)
	setmetatable({}, Animal)

	self.height = height
	self.weight = weight
	self.name = name
	self.sound = sound
	self.faveFood = faveFood

	return self
end

function Cat:toString()
	animalString = string.format(
		"%s weighs %.1f lbs, is %.1f in tall and says %s, favorite food %s", 
		self.name, 
		self.weight, 
		self.height, 
		self.sound,
		self.faveFood)

	return animalString
end

local fluffy = Cat:new(3, 32, "Fluffy", "Mew", "Dead Birds")

io.write("\n", fluffy.weight, "\n")
io.write("\n", fluffy:toString(), "\n")

