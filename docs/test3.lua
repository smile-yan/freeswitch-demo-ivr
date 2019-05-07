------------------------------------
-- ASR TTS 例子
-- 运行效果： 拨通后制定时间内若无声音则会自动挂机。
-- 重复用户说的话
-- 作者 Smileyan
-- 2019年5月7日
-------------------------------------


-- get value by key from xml 
function getValue(tempxml,key)
	local tag1 = "<"..key
	local tag2 = "</"..key..">"
	_,_,value=string.find(tempxml, tag1.."(.-)"..tag2 )
	return value
end

session:answer()
session:set_tts_params("unimrcp", "xiaofang");
session:streamFile("tone_stream://%(1000,2000,450)") 
session:speak("请您说话");
menu =  "silence_stream://-1,1400"
grammar = "hello"
no_input_timeout = 10000
recognition_timeout = 8000
confidence_threshold = 0.2

-- 循环等待结果（10s)
tryagain = 1
while (tryagain == 1) do
	session:execute("play_and_detect_speech",menu .. "detect:unimrcp {start-input-timers=false,no-input-timeout=" .. no_input_timeout .. ",recognition-timeout=" .. recognition_timeout .. "}" .. grammar)
	xml = session:getVariable('detect_speech_result')
	-- 如果没有获得结果
	if (xml == nil) then
		session:excute("play_and_detect_speech","pause")
		tryagain = 1
	else
		freeswitch.consoleLog("CRIT","Result is '" .. xml .. "'\n")
		tryagain = 0
	end
end

freeswitch.consoleLog("NOTICE","End of recog\n")
session:sleep(250)

v1 = getValue(xml,"result")
v2 = getValue(v1,"interpretation")
v3 = getValue(v2,"instance")

freeswitch.consoleLog("CRIT","v3==" .. v3 .. "\n")
		
session:speak("您所说的是"..v3);
-- 3秒后挂机
session:streamFile("silence_stream://3000,1400") 
session:hangup()