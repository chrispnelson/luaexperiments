-- Different ways to work with files
-- r: read only (default)
-- w: Overwrite or create a new file
-- a: Append or create new file
-- r+: Read & Write existing file
-- w+: Overwrite, read, or create file
-- a+: Append, read, or create a file

file = io.open("fileiotest.lua", "w+")

file:write("Random String of text\n")
file:write("Some more text\n")

file:seek("set", 0)

io.write(file:read("*a"), "\n")

file:close()

file = io.open("fileiotest.lua", "a+")

file:write("Even more text\n")

file:seek("set", 0)

io.write(file:read("*a"), "\n")

file:close()