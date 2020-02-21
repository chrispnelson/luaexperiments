co = coroutine.create(
	function ()
		for i = 1, 10 do
			io.write("\n", i, " co status: ", coroutine.status(co), "\n")
			if i == 5 then 
				coroutine.yield()
			end
		end
	end
)

co2 = coroutine.create(
	function ()
		for i = 101, 110, 1 do
			io.write("\n" , i, "co2 status: ", coroutine.status(co2), "\n")
			if i == 105 then 
				coroutine.yield()
			end
		end
	end
)

io.write("\nco status: ", coroutine.status(co), "\t")
io.write("co2 status: ", coroutine.status(co2), "\n")

coroutine.resume(co)
io.write("\nco status: ", coroutine.status(co), "\n")
coroutine.resume(co2)
io.write("\nco2 status: ", coroutine.status(co2), "\n")

io.write("\nco status: ", coroutine.status(co), "\t")
io.write("co2 status: ", coroutine.status(co2), "\n")

coroutine.resume(co2)
io.write("\nco2 status: ", coroutine.status(co2), "\n")

io.write("\nco status: ", coroutine.status(co), "\t")
io.write("co2 status: ", coroutine.status(co2), "\n")

coroutine.resume(co)
io.write("\nco status: ", coroutine.status(co), "\n")

io.write("\nco status: ", coroutine.status(co), "\t")
io.write("co2 status: ", coroutine.status(co2), "\n")

coroutine.resume(co2)
io.write("\nco2 status: ", coroutine.status(co2), "\n")

io.write("\nco status: ", coroutine.status(co), "\t")
io.write("co2 status: ", coroutine.status(co2), "\n")