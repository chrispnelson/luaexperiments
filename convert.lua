-- convert.lua has to be named for the module
-- a module is self contained lua script similar to making a class
-- it returns itself to be assigned to the calling script attribute/variable
local convert = {}

function convert.ftToCm(feet)
	return feet + 30.48
end

return convert