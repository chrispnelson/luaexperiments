quote = "Do, a Deer, a Female Deer, Ray, a Drop of Golden Sun"

countWords = {
	"Once",
	"Twice",
	"Thrice",
	"Four Times",
	"Five Times",
	"Six Times",
	"Seven Times",
	"Eight Times",
	"Nine Times",
	"Ten Times"
}

cwSize = #countWords

io.write(quote, "\n")
io.write("\nQuote Upper: \n", string.upper(quote), "\n")
io.write("\nQuote Lower: \n", string.lower(quote), "\n")
io.write("\nIndex of word \"ray\":\t", string.find(string.lower(quote), "ray"), "\n")
io.write("\nQuote Length : ", string.len(quote), "\t", #quote, "\n")
io.write("\ncwSize:", cwSize, "\n")

newQuote = quote

i = 5

--while (i < 15) do
--	i = i + 1
for i, value in pairs(countWords) do

	io.write("\nINDEX: ", i, " VALUE: ", value, "\n")

	--if (i <= cwSize) then
		newQuote = string.gsub(newQuote, "a", "aha boots n pants")
		io.write("\nReplace \"a\" with \"aha\" " , value, ": \n", newQuote, "\n")
	--end
end


