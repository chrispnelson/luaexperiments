aMultiTable = {}

for i = 0, 9 do
	aMultiTable[i] = {}
	for j = 0, 9 do
		aMultiTable[i][j] = tostring(i) .. tostring(j)
	end
end

for i = 0, 9 do
	io.write("\n")
	for j = 0, 9 do
		io.write(aMultiTable[i][j], " : ")
	end
end

io.write("\n")