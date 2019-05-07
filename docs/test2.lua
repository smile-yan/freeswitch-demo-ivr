
session:answer()
session:set_tts_params("unimrcp", "xiaofang");
session:speak("请您说话");
menu =  "silence_stream://-1,1400"
grammar = "hello"
no_input_timeout = 8000
recognition_timeout = 8000
confidence_threshold = 0.2

tryagain = 1
while (tryagain == 1) do
	session:execute("play_and_detect_speech",menu .. "detect:unimrcp {start-input-timers=false,no-input-timeout=" .. no_input_timeout .. ",recognition-timeout=" .. recognition_timeout .. "}" .. grammar)
	xml = session:getVariable('detect_speech_result')
	
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

tag1="<result>"
tag2 ="</result>"
_,_,value=string.find(xml, tag1.."(.-)"..tag2 )
tag3 = "<interpretation"
tag4="</interpretation>"
_,_,value2=string.find(value, tag3.."(.-)"..tag4 )
tag5="<instance>"
tag6="</instance>"
_,_,value3=string.find(value2, tag5.."(.-)"..tag6 )
freeswitch.consoleLog("CRIT","value3==" .. value3 .. "\n")
		
--_,_,pre,result,suf = string.find(xml,"(.*)" .. asrtag .. ":(.*)}(.*)")
session:speak("您所说的是"..value3);
session:sleep(2000)
session:streamFile("silence_stream://-1,1400") 

--session:hangup()