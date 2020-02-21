-- metatable events are accessed through special identifiers,
-- which can be used or reassigned
-- 
-- http://lua-users.org/wiki/MetatableEvents

aTable = {}
anotherTable = { 4, 5, 6 }
yetAnotherTable = { 4, 5, 6 }

for x = 1, 10 do
	aTable[x] = x
end

mt = {
	__add = function ( table1, table2 )
		sumTable = {}

		for y = 1, #table1 do
			if (table1[y] ~= nil) and (table2 ~= nil) then
				sumTable[y] = table1[y] + table2[y]
			else
				sumTable[y] = 0
			end
		end

		return sumTable
	end,
	__sub = function ( table1, table2 )
		sumTable = {}

		for y = 1, #table1 do
			if (table1[y] ~= nil) and (table2 ~= nil) then
				sumTable[y] = table1[y] - table2[y]
			else
				sumTable[y] = 0
			end
		end

		return sumTable
	end,
	__mul = function ( table1, table2 )
		sumTable = {}

		for y = 1, #table1 do
			if (table1[y] ~= nil) and (table2 ~= nil) then
				sumTable[y] = table1[y] * table2[y]
			else
				sumTable[y] = 0
			end
		end

		return sumTable
	end,
	__div = function ( table1, table2 )
		sumTable = {}
		for y = 1, #table1 do
			if (table1[y] ~= nil) and (table2 ~= nil) then
				if (table2[y] == 0) then
					sumTable[y] = 0
				else
					sumTable[y] = table1[y] / table2[y]
				end
			else
				sumTable[y] = 0
			end
		end

		return sumTable
	end,
	__eq = function ( table1, table2 )
		return table1.value == table2.value
	end,
	__lt = function ( table1, table2 )
		return table1.value < table2.value
	end,
	__gt = function ( table1, table2 )
		return table1.value > table2.value
	end,
	__le = function ( table1, table2 )
		return table1.value <= table2.value
	end,
	__ge = function ( table1, table2 )
		return table1.value >= table2.value
	end
}

setmetatable(aTable, mt)

io.write("\n", tostring(aTable == aTable), "\n")

addTable = aTable + aTable

for z = 1, #addTable do
	io.write(addTable[z], "\n")
end
