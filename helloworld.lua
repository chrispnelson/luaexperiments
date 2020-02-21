name = "Chris"
age = 46
abletoDrive = true
longString = 
[[Roses are red
Violets are blue
Valentines day sucks
and so do you!]]

longString = longString .. "\n" .. name .. " age:" .. age .. "\n" 

io.write("Konichiwa isekai!\n", #name, "\n", age, "\n")
io.write("name\t", type(name), "\tage\t", type(age), "\tAble to Drive\t", type(abletoDrive), "\tMadeUpVar\t", type(MadeUpVar))
io.write("\n\n" .. longString .. "\n" .. #longString .. "\n")

adding = "5 + 3 = " .. 5+3 .. "\n"
subtracting = "5 - 3 = " .. 5-3 .. "\n"
multiplying = "5 * 3 = " .. 5*3 .. "\n"
dividing = "5 / 3 = " .. 5/3 .. "\n"
modulousing = "5.35 % 3 = " .. 5.35%3 .. "\n"

io.write(
	"\n MATHS: \n", 
	adding, 
	subtracting, 
	multiplying, 
	dividing, 
	modulousing)

io.write(
	"\n",
[[
Math Funcitons: 
floor, ceil, max, min, sin, cos, 
tan, asin, acos, exp, log, log10, 
pow, sqrt, random, randomseed

http://lua-users.org/wiki/MathLibraryTutorial
]],
"\n")

showFloor = "floor(2.345) = " .. math.floor(2.345) .. "\n"
showCeil = "ceil(2.345) = " .. math.ceil(2.345) .. "\n"
showMax = "max(2, 5) = " .. math.max(2, 5) .. "\n"
showMin = "min(2, 5) = " .. math.min(2, 5) .. "\n"
showPow = "pow(8, 2) = " .. math.pow(8, 2) .. "\n"
showExp = "exp(2) = " .. math.exp(2) .. "\n"
showSqrt = "sqrt(64) = " .. math.sqrt(64) .. "\n"

io.write(
	"\n",
	showFloor, 
	showCeil, 
	showMax, 
	showMin, 
	showPow, 
	showExp, 
	showSqrt
	)

io.write("\nrandomseed using os.time: ", os.time(), "\tseed: ", math.randomseed(os.time()))
io.write("\nrandom: ", math.random())
io.write("\nrandom: ", math.random())
io.write("\nrandom: ", math.random())
io.write("\nrandom: ", math.random())
io.write("\nrandom: ", math.random())
io.write("\nrandom(100): ", math.random(100))
io.write("\nrandom(100): ", math.random(100))
io.write("\nrandom(100): ", math.random(100))
io.write("\nrandom(100): ", math.random(100))
io.write("\nrandom(100): ", math.random(100))
io.write("\nrandom(70, 80): ", math.random(70, 80))
io.write("\nrandom(70, 80): ", math.random(70, 80))
io.write("\nrandom(70, 80): ", math.random(70, 80))
io.write("\nrandom(70, 80): ", math.random(70, 80))
io.write("\nrandom(70, 80): ", math.random(70, 80))
io.write("\n")

io.write("\nFormated string string.format()\n", string.format("Pi = %.10f", math.pi), "\n")

io.write("\nRelational Operators:\t>\t<\t>=\t<=\t==\t~=\n")
io.write("\nLogical Operators:\tand\tor\tnot\n")

age = 13

if (age < 16) then
	io.write("\nis less than 16\n")
elseif (age >= 16) and (age < 18) then
	io.write("\nis between 16 and 18\n")
elseif (age >= 21) and (age < 35) then
	io.write("\nis >= 21 and < 35\n")
else
	io.write("\nis > 35 \n")
end

io.write("\nNOT TRUE = ", tostring(not true), "\n")

io.write("\nInline Ternary logic \"age > 18 and true or false\"\n")
io.write(tostring(age > 18 and true or false), "\n")
io.write(tostring(age > 18 and true), "\n")
io.write(tostring(age > 18), "\n")
