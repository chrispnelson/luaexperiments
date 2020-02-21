doubleIt = function(x) return x * 2 end

function getSumOf( ... )
	local sum = 1
	local count = 0

	for key, value in pairs{...} do
		sum = sum + value
		count = count + 1
	end

	return sum, count
end

sum, count = getSumOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

io.write("\nSum of ", count, " values: ", sum, "\n")

function outerFunc()
-- closure function example
	local i = 0

	return function ()
	-- varable state is retained at runtime
		i = i + 1
		return i
	end
end

getI = outerFunc()

io.write(getI(), "\n")
io.write(getI(), "\n")
io.write(doubleIt(getI()), "\n")
