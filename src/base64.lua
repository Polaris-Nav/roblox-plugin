local B64chars = {
[0]='A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'}

local B64index = {
[0]=0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  62, 63, 62, 62, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0,  0,  0,  0,  0,  0,
	0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0,  0,  0,  0,  63,
	0,  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
}

local s18 = 2^18
local s12 = 2^12
local s6 = 2^6
local s56 = 2^56
local s48 = 2^48
local s40 = 2^40
local s32 = 2^32
local s24 = 2^24
local s16 = 2^16
local s10 = 2^10
local s8 = 2^8
local s4 = 2^4
local s2 = 2^2

local function encode(p)
	local bytes = {}
	
	local len = #p
	local pad = len % 3
	local last = len - pad
	local j = 1

	for i = 1, last, 3 do
		local n = s16 * p[i]
				+ s8  * p[i + 1]
				+       p[i + 2]
		bytes[j    ] = B64chars[math.floor(n / s18)]
		bytes[j + 1] = B64chars[bit32.band(n / s12, 0x3F)]
		bytes[j + 2] = B64chars[bit32.band(n / s6,  0x3F)]
		bytes[j + 3] = B64chars[bit32.band(n,       0x3F)]
		j = j + 4
	end
	if pad > 0 then
		local n = p[last + 1]
		if pad == 2 then
			local n = s8 * n + p[last + 2]
			bytes[j    ] = B64chars[bit32.band(n / s10, 0x3F)]
			bytes[j + 1] = B64chars[bit32.band(n / s4, 0x03F)]
			bytes[j + 2] = B64chars[bit32.band(n * s2, 0x3F)]
		else
			bytes[j    ] = B64chars[math.floor(n / s2)]
			bytes[j + 1] = B64chars[bit32.band(n * s4, 0x3F)]
			bytes[j + 2] = '='
		end
		bytes[j + 3] = '='
	end
	return table.concat(bytes)
end

local function decode(p)
	local len = #p
	if len == 0 then
		return ''
	end
	
	local bytes = {}
	
	local pad1 = len % 4 > 0 or p[len] == string.byte '='
	local pad2 = pad1 and (len % 4 == 2 or p[len - 1] == string.byte '=')
	local last = math.floor((pad1 and len - 1 or len) / 4) * 4
	local i = 1
	
	local n
	while i <= last do
		n = s18 * B64index[p[i]]
		  + s12 * B64index[p[i + 1]]
		  + s6  * B64index[p[i + 2]]
		  + B64index[p[i + 3]]
		bytes[#bytes + 1] = math.floor(n / s16)
		bytes[#bytes + 1] = bit32.band(n / s8, 0xFF)
		bytes[#bytes + 1] = bit32.band(n, 0xFF)
		i = i + 4
	end
	
	if pad1 then
		local n = s18 * B64index[p[i]]
			+ s12 * B64index[p[i + 1]]
		bytes[#bytes + 1] = math.floor(n / s16)
		if not pad2 then
			n = n + s6 * B64index[p[i + 2]]
			bytes[#bytes + 1] = bit32.band(n / s8, 0xFF);
		end
	end
	
	return bytes
end

local function encode_str(p)
	local bytes = {}
	
	local len = #p
	local pad = len % 3
	local last = len - pad
	local j = 1

	for i = 1, last, 3 do
		local n = s16 * p:byte(i)
				+ s8  * p:byte(i + 1)
				+       p:byte(i + 2)
		bytes[j    ] = B64chars[math.floor(n / s18)];
		bytes[j + 1] = B64chars[bit32.band(n / s12, 0x3F)]
		bytes[j + 2] = B64chars[bit32.band(n / s6,  0x3F)]
		bytes[j + 3] = B64chars[bit32.band(n,       0x3F)]
		j = j + 4
	end
	if pad > 0 then
		local n = p:byte(last + 1)
		if pad == 2 then
			local n = s8 * n + p:byte(last + 2)
			bytes[j    ] = B64chars[bit32.band(n / s10, 0x3F)]
			bytes[j + 1] = B64chars[bit32.band(n / s4, 0x03F)]
			bytes[j + 2] = B64chars[bit32.band(n * s2, 0x3F)]
		else
			bytes[j    ] = B64chars[math.floor(n / s2)]
			bytes[j + 1] = B64chars[bit32.band(n * s4, 0x3F)]
			bytes[j + 2] = '='
		end
		bytes[j + 3] = '='
	end
	return table.concat(bytes)
end

local function decode_str(p)
	local len = #p
	if len == 0 then
		return ''
	end
	
	local bytes = {}
	
	local pad1 = len % 4 > 0 or p:byte(len) == string.byte '='
	local pad2 = pad1 and (len % 4 == 2 or p:byte(len - 1) == string.byte '=')
	local last = math.floor((pad1 and len - 1 or len) / 4) * 4
	local i = 1
	
	local n
	while i <= last do
		n = s18 * B64index[p:byte(i)]
		  + s12 * B64index[p:byte(i + 1)]
		  + s6  * B64index[p:byte(i + 2)]
		  + B64index[p:byte(i + 3)]
		bytes[#bytes + 1] = string.char(math.floor(n / s16))
		bytes[#bytes + 1] = string.char(bit32.band(n / s8, 0xFF))
		bytes[#bytes + 1] = string.char(bit32.band(n, 0xFF))
		i = i + 4
	end
	
	if pad1 then
		local n = s18 * B64index[p:byte(i)]
			+ s12 * B64index[p:byte(i + 1)]
		bytes[#bytes + 1] = string.char(math.floor(n / s16))
		if not pad2 then
			n = n + s6 * B64index[p:byte(i + 2)]
			bytes[#bytes + 1] = string.char(bit32.band(n / s8, 0xFF));
		end
	end
	
	return table.concat(bytes)
end

return {
	encode = encode;
	decode = decode;
	encode_str = encode_str;
	decode_str = decode_str;
}