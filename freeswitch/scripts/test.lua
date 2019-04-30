--- 用来记录当前进入的状态
grade_now = 1
sound_now = 0
function onInput(s,type,obj,arg)
    if (type == "dtmf")  then
        freeswitch.consoleLog("INFO", "DTMF: ".. obj.digit .. "Duration:" .. obj.duration .. "\n")
        if (obj.digit == "0") then
           -- actionVoice(1)
        -- 返回上一级
        elseif (obj.digit == "#") then
            grade_now = 1
            session:streamFile("/usr/share/freeswitch/sounds/index.wav")
            session:streamFile("silence_stream://-1,1400") 
        elseif (obj.digit == "*") then
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

function actionVoice(which)
    if (grade_now == 1) then 
        grade_now = 2
        sound_now = which
        session:streamFile("/usr/share/freeswitch/sounds/g"..which..".wav")
        session:streamFile("silence_stream://-1,1400") 
    end
end 
session:answer()
session:setInputCallback('onInput','')
session:streamFile("tone_stream://%(1000,2000,450)") 
session:streamFile("silence_stream://2000,1400") 
session:streamFile("/usr/share/freeswitch/sounds/index.wav")
session:streamFile("silence_stream://-1,1400") 

