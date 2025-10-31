-- portable, pc, nx, mobile
local build_type = "portable"
if love.system.getOS() == "Windows" then
    build_type = "windows"
end
if love.system.getOS() == "OS X" then
    build_type = "macos"
end
if love.system.getOS() == "Linux" then
    build_type = "linux"
end
if love.system.getOS() == "NX" then
    build_type = "nx"
end
return build_type