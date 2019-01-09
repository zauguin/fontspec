#!/usr/bin/env texlua

module = "fontspec"

--[================[
      PARAMETERS
--]================]

sourcefiles  = {"*.ins","*.dtx","*.ltx","*.cfg","*.tex","fontspec-doc-style.sty"}
installfiles = {"fontspec.sty","fontspec-xetex.sty","fontspec-luatex.sty","fontspec.lua","fontspec.cfg"}
demofiles    = {"fontspec-example.tex"}
textfiles    = {"README.md","CHANGES.md","LICENSE"}
tagfiles     = {"fontspec.dtx","CHANGES.md"}

typesetfiles = {"fontspec.ltx","fontspec-code.ltx"}
typesetexe   = "xelatex"
typesetopts  = " -shell-escape -interaction=errorstopmode "

unpackopts  = " -interaction=batchmode "

checkengines = {"xetex","luatex"}
recordstatus = true

packtdszip = true


--[=============[
      VERSION
--]=============]

changeslisting = nil
do
  local f = assert(io.open("CHANGES.md", "r"))
  changeslisting = f:read("*all")
  f:close()
end
pkgversion = string.match(changeslisting,"## v(%S+) %(.-%)")
print('Current version (from first entry in CHANGES.md): '..pkgversion)



--[============[
     TAGGING
--]============]

function update_tag(file, content, tagname, tagdate)
  local date = string.gsub(tagdate, "%-", "/")

  if string.match(content, "{%d%d%d%d/%d%d/%d%d}%s*{[^}]+}%s*{[^}]+}") then
    print("Found expl3 version line in file: "..file)
    content = content:gsub("{%d%d%d%d/%d%d/%d%d}(%s*){[^}]+}(%s*){([^}]+)}",
    "{"..date.."}%1{"..pkgversion.."}%2{%3}")
  end
  if string.match(content, "\\def\\filedate{%d%d%d%d/%d%d/%d%d}") then
    print("Found filedate line in file: "..file)
    content = content:gsub("\\def\\filedate{[^}]+}", "\\def\\filedate{"..date.."}")
  end
  if string.match(content, "\\def\\fileversion{[^}]+}") then
    print("Found fileversion line in file: "..file)
    content = content:gsub("\\def\\fileversion{[^}]+}", "\\def\\fileversion{"..pkgversion.."}")
  end
  content = content:gsub("version       = \"[^\"]+\",", "version       = \""..pkgversion.."\",")
  content = content:gsub("date          = \"[^\"]+\",", "date          = \""..date.."\",")

  if string.match(content, "## (%S+) %([^)]+%)") then
    print("Found changes line in file: "..file)
    content = content:gsub("## (%S+) %([^)]+%)","## %1 ("..date..")",1)
  end

  return content
end



--[=================[
      CTAN UPLOAD
--]=================]

uploadconfig = {
  version     = pkgversion,
  author      = "Will Robertson",
  license     = "lppl1.3c",
  summary     = "Unify and control maths subscript heights",
  ctanPath    = "/macros/latex/contrib/subdepth",
  repository  = "https://github.com/wspr/will2e/",
  bugtracker  = "https://github.com/wspr/will2e/issues",
}

local f=io.open("l3build-wspr.lua","r")
if f ~= nil then
  io.close(f)
  require("l3build-wspr.lua")
end
