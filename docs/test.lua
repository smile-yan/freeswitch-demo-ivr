session:answer()
menu =  "ivr/ivr-welcome_to_freeswitch.wav"

grammar = "hello"
no_input_timeout = 5000
recognition_timeout = 5000
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
session:set_tts_params("unimrcp", "xiaofang");
session:speak("今天天气不错啊");
session:sleep(2000)
session:streamFile("silence_stream://-1,1400") 

--session:hangup()