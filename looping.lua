i = 0

while (i < 10) do
	io.write(i, "\n")
	i = i + 1

	if i == 8 then 
		break 
	end
end

io.write("\n")

repeat
	io.write("\n", "Enter your guess: ")

	guess = io.read()

until tonumber(guess) == 15

io.write("\n")

-- start, end, increment similar to BASIC "STEP"
for i = 0, 20, 2 do
	io.write(i, "\n")
end

io.write("\n")

-- TABLE

months = {
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec"
}

for key, value in pairs(months) do
	io.write(value, " ")
end

io.write("\n")