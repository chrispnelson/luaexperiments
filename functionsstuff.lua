function increment(tvar)
	return tvar + 1
end

function getSum(num1, num2)
	return num1 + num2
end

io.write(string.format("\n5 + 2 = %d", getSum(5,2)), "\n")

function splitStr(theString)
	stringTable = {}

	local i = 1

	for word in string.gmatch(theString, "[^%s]+") do
		stringTable[i] = word
		i = increment(i)
	end

	return stringTable, i
end

splitStringTable, numofStr = splitStr("The Turtle walks faster than normal")

io.write("\n")

for j = 1, numofStr-1 do
	io.write(string.format("%d : %s", j, splitStringTable[j]), "\n")
end

io.write("\n")