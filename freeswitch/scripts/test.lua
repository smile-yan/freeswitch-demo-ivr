--- 用来记录当前进入的状态
grade_now = 1
sound_now = 0


session:set_tts_params("unimrcp", "xiaofang");
-- ars
menu =  "silence_stream://-1,1400"
grammar = "hello"
no_input_timeout = 10000
recognition_timeout = 8000
confidence_threshold = 0.2

function onInput(s,type,obj,arg)
    if (type == "dtmf")  then
        freeswitch.consoleLog("INFO", "DTMF: ".. obj.digit .. "Duration:" .. obj.duration .. "\n")
        if (obj.digit == 0 or obj.digit == "0") then
			if(sound_now=="2") then 
				session:speak("请您说出您希望了解的学院名称.......");
				local result = getARSResult()
				session:speak("您所说的是"..result)
			else
				if(sound_now == "4" or sound_now=="5") then
					session:speak("请您说出您希望了解的专业.......");
					local result = getARSResult()
					session:speak("您所说的是"..result)
				end
			end
		-- 返回上一级
        elseif (obj.digit == "#") then
            grade_now = 1
            session:streamFile("/usr/share/freeswitch/sounds/index.wav")
            session:streamFile("silence_stream://-1,1400") 
		-- listen again
        elseif (obj.digit == "*") then
			-- index
            if(sound_now == 0) then      
                session:streamFile("/usr/share/freeswitch/sounds/index.wav")
                session:streamFile("silence_stream://-1,1400") 
            else  	   
               session:streamFile("/usr/share/freeswitch/sounds/g"..sound_now..".wav")
               session:streamFile("silence_stream://-1,1400") 
            end
        else 
            actionVoice(obj.digit)
        end	
    end
    return ''
end

-- action for key(1~9) 
function actionVoice(which)
    if (grade_now == 1) then 
        grade_now = 2
        sound_now = which
        session:streamFile("/usr/share/freeswitch/sounds/g"..which..".wav")
        session:streamFile("silence_stream://-1,1400") 
    end
end 

-- get ARS Result
function getARSResult()
	local tryagain = 1
	local xml
	-- until get Result
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
	
	local v1 = getValue(xml,"result")
	local v2 = getValue(v1,"interpretation")
	local v3 = getValue(v2,"instance")
	return v3
end

-- get value by key from xml 
function getValue(tempxml,key)
	local tag1 = "<"..key
	local tag2 = "</"..key..">"
	_,_,value=string.find(tempxml, tag1.."(.-)"..tag2 )
	return value
end


session:answer()
session:setInputCallback('onInput','')
session:streamFile("tone_stream://%(1000,2000,450)") 
session:streamFile("silence_stream://2000,1400") 
session:streamFile("/usr/share/freeswitch/sounds/index.wav")
session:streamFile("silence_stream://-1,1400") 

