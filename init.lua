-- =============================================
-- Project Kham (คำ) v1.0
-- Thai/English input switcher for macOS
-- github.com/sutticue/project-kham-thswitch
-- =============================================

local LAYOUT_EN = "ABC"
local LAYOUT_TH = "Thai"

local en_to_th = {
	-- แถวตัวเลข (ไม่กด Shift)
	["1"]="ๅ", ["2"]="/", ["3"]="-", ["4"]="ภ", ["5"]="ถ",
	["6"]="ุ",  ["7"]="ึ", ["8"]="ค", ["9"]="ต", ["0"]="จ",
	["-"]="ข",  ["="]="ช", ["`"]="_",

	-- แถวตัวเลข (กด Shift)
	["!"]="+", ["@"]="๑", ["#"]="๒", ["$"]="๓", ["%"]="๔",
	["^"]="ู",  ["&"]="฿", ["*"]="๕", ["("]="๖", [")"]="๗",
	["_"]="๘",  ["+"]="๙", ["~"]="%",

	-- ตัวอักษรพิมพ์เล็ก (ไม่กด Shift)
	["q"]="ๆ", ["w"]="ไ", ["e"]="ำ", ["r"]="พ", ["t"]="ะ", ["y"]="ั", ["u"]="ี",
	["i"]="ร",  ["o"]="น", ["p"]="ย", ["a"]="ฟ", ["s"]="ห", ["d"]="ก", ["f"]="ด",
	["g"]="เ",  ["h"]="้", ["j"]="่", ["k"]="า", ["l"]="ส", [";"]="ว", ["'"]="ง",
	["z"]="ผ",  ["x"]="ป", ["c"]="แ", ["v"]="อ", ["b"]="ิ", ["n"]="ื", ["m"]="ท",
	[","]="ม",  ["."]="ใ", ["/"]="ฝ", ["["]="บ", ["]"]="ล", ["\\"]="ฃ",

	-- ตัวอักษรพิมพ์ใหญ่ (กด Shift)
	["Q"]="๐", ["W"]='"',  ["E"]="ฎ", ["R"]="ฑ", ["T"]="ธ", ["Y"]="ํ", ["U"]="๊",
	["I"]="ณ",  ["O"]="ฯ", ["P"]="ญ", ["A"]="ฤ", ["S"]="ฆ", ["D"]="ฏ", ["F"]="โ",
	["G"]="ฌ",  ["H"]="็", ["J"]="๋", ["K"]="ษ", ["L"]="ศ", [":"]="ซ", ['"']=".",
	["Z"]="(",  ["X"]=")", ["C"]="ฉ", ["V"]="ฮ", ["B"]="ฺ", ["N"]="์", ["M"]="?",
	["<"]="ฒ",  [">"]="ฬ", ["?"]="ฦ", ["{"]="ฐ", ["}"]="," , ["|"]="ฅ",
}

local th_to_en = {}
for en, th in pairs(en_to_th) do
	th_to_en[th] = en
end

local buffer = ""
local bufferLayout = ""

local function isPasswordField()
	local el = hs.uielement.focusedElement()
	if not el then
		return false
	end
	local ok, role = pcall(function()
		return el:role()
	end)
	return ok and role == "AXSecureTextField"
end

local function toThai(text)
	local res = ""
	for i = 1, #text do
		local c = text:sub(i, i)
		res = res .. (en_to_th[c] or c)
	end
	return res
end

local function toEnglish(text)
	local res = ""
	for _, cp in utf8.codes(text) do
		local ch = utf8.char(cp)
		res = res .. (th_to_en[ch] or ch)
	end
	return res
end

local function charCount(text)
	local ok, n = pcall(utf8.len, text)
	return ok and n or #text
end

local function doConvert()
	if #buffer == 0 then
		return
	end
	local converted, targetLayout
	if bufferLayout == LAYOUT_TH then
		converted = toEnglish(buffer)
		targetLayout = LAYOUT_EN
	else
		converted = toThai(buffer)
		targetLayout = LAYOUT_TH
	end
	for i = 1, charCount(buffer) do
		hs.eventtap.keyStroke({}, "delete", 0)
	end
	hs.keycodes.setLayout(targetLayout)
	hs.eventtap.keyStrokes(converted)
	if not isPasswordField() then
		hs.alert.show(buffer .. " -> " .. converted, 1.5)
	end
	buffer = ""
	bufferLayout = targetLayout
end

_G.kham = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local char = event:getCharacters(true)

	-- CapsLock: instant language toggle
	if keyCode == 57 then
		local cur = hs.keycodes.currentLayout()
		hs.keycodes.setLayout(cur == LAYOUT_TH and LAYOUT_EN or LAYOUT_TH)
		return true
	end

	-- Shift+Backspace: convert last word
	if flags.shift and keyCode == 51 then
		doConvert()
		return true
	end

	-- Cmd/Ctrl: reset buffer
	if flags.cmd or flags.ctrl then
		buffer = ""
		bufferLayout = ""
		return false
	end

	-- Backspace: trim buffer
	if keyCode == 51 then
		if #buffer > 0 then
			local lastPos = 1
			for pos in utf8.codes(buffer) do
				lastPos = pos
			end
			buffer = buffer:sub(1, lastPos - 1)
		end
		return false
	end

	-- Space / Enter / Tab: reset buffer
	if keyCode == 49 or keyCode == 36 or keyCode == 48 then
		buffer = ""
		bufferLayout = ""
		return false
	end

	-- Regular character: collect into buffer
	if char and #char >= 1 and not flags.alt and not flags.cmd then
		local currentLayout = hs.keycodes.currentLayout()
		if buffer == "" then
			bufferLayout = currentLayout
		end
		if currentLayout ~= bufferLayout then
			buffer = char
			bufferLayout = currentLayout
		else
			buffer = buffer .. char
		end
		if #buffer > 60 then
			buffer = ""
			bufferLayout = ""
		end
	end

	return false
end)

_G.kham:start()

hs.alert.show("Kham v1.0 Online", 2)
