aTable = {}

for i = 1, 10 do
	aTable[i] = i
end

io.write("aTable[3]:", aTable[3], "\n")
io.write("aTable[9]:", aTable[9], "\n")

aMixedTable = { "Things", 1, "two", 5, "nine", 10}

io.write("\n")

for key, value in pairs(aTable) do
	io.write(value, " ")
end

io.write("\n")

for key, value in pairs(aMixedTable) do
	io.write(value, " ")
end

io.write("\n")

io.write("\nSize of aTable:", #aTable, "\nSize of aMixedTable:", #aMixedTable, "\n")

io.write("\n")

table.insert(aMixedTable, 1, "one")

io.write("\nSize of aMixedTable:", #aMixedTable, "\n")

io.write("\n")

for key, value in pairs(aMixedTable) do
	io.write(value, " ")
end

io.write("\n")

table.insert(aMixedTable, 2, "two two")

io.write("\nSize of aMixedTable:", #aMixedTable, "\n")

io.write("\n")

for key, value in pairs(aMixedTable) do
	io.write(value, " ")
end

amtString = table.concat(aMixedTable, ",\n")

io.write(amtString)

io.write("\n\n")
io.write("\nSize of aMixedTable:", #aMixedTable, "\n")
io.write("\n")

for key, value in pairs(aMixedTable) do
	io.write(value, " ")
end

table.remove(aMixedTable, 5)
io.write("\n\n")
io.write("\nSize of aMixedTable:", #aMixedTable, "\n")
io.write("\n")

for key, value in pairs(aMixedTable) do
	io.write(value, " ")
end

io.write("\n")

amtString = table.concat(aMixedTable, ",\n")

io.write(amtString, "\n")