-- convert.lua has to be named for the module
convertModule = require("convert")

io.write(string.format("\n%.3f cm", convertModule.ftToCm(12)), "\n")