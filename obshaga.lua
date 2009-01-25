-- obshaga.lua

-- JLarky <jlarky@gmail.com>
-- √оворит кто в какой общаге живЄт

LastTenMessages = {}
NumberOfMessages = 0

_, botname = VH:GetConfig("config", "hub_security")

function GetMessages()
		return "тест кодировки"
end

function VH_OnUserLogin(nick)
	res, sIp = VH:GetUserIP(nick)
	_, obsh = str2ip(sIp)
	if obsh == 0 then obsh = "инета"; else obsh = obsh.." общаги"; end
	msg=string.format("ѕривет, %s! Ќе забудь поставить новые заплатки на винду, дабы не отлючили от сети. Ќа вики написаны подробности http://wiki.punklan.net/news:2009-01-22_conficker\n стати если вдруг перестало пускать в icq (ну или боишс€, что перестанет), почитай это, может пригодитс€ http://dchub.punklan.net/node/27", nick )
	SendMessageToUser(msg, nick, "info_bot")
	return 1
end

function VH_OnParsedMsgConnectToMe(nick,othernick)
 return ban(nick, othernick)
end

function VH_OnParsedMsgRevConnectToMe(nick,othernick)
 return ban(nick, othernick)
end

function ban(nick,othernick)
	if not unbanlist then unbanlist = {};end
        if not unbanlist[nick] then unbanlist[nick] = 0; end
	
	local count=unbanlist[nick]

        res, sIp1 = VH:GetUserIP(nick)
        res, sIp2 = VH:GetUserIP(othernick)
	_, obsh = str2ip(sIp1)
        _, obsh2 = str2ip(sIp2)
        if obsh==0 or obsh2==0 then
         msg=string.format("соединение %s(%s общага) с %s(%s общага) не будет установленно. чтобы разрешить соединение напишите .allowme в чат. более подробно о том что произошло читаем тут http://dchub.punklan.net/node/15", nick, obsh, othernick, obsh2)
--	 SendPmMessageToUser(msg.." - "..count, "JLarky", botname)

	 if (not (obsh == 0)) and (unbanlist[nick] > 0) then -- качает человек из общаги и он разрешил себе скачивать
	  unbanlist[nick]=unbanlist[nick]-1
	  SendPmMessageToUser(string.format("внешний коннект на %s(%s). осталось разрешЄнных %s", othernick, sIp2, unbanlist[nick]) , nick, botname)
	  return 1
	 elseif (not (obsh2 == 0)) and (unbanlist[othernick] > 0) then -- качает c человека из общаги и он разрешил с себ€ скачивать
	  unbanlist[othernick]=unbanlist[othernick]-1
	  SendPmMessageToUser(string.format("внешний коннект с %s(%s). осталось разрешЄнных %s", nick, sIp1, unbanlist[othernick]) , nick, botname)
	  return 1
	 else
          SendPmMessageToUser(msg, nick, botname)
          --SendMessageToUser(msg, othernick, botname)
          return 0
	 end
        else
	 return 1
	end
end


function VH_OnParsedMsgChat(nick,data)
if string.find(data, "^\.ip", 1) then
 nnick = data:match("^.ip (.+)$")
 if nnick then nnick = data:match("^.ip (.+)$"); else nnick=nick; end
 result, sIP = VH:GetUserIP(nnick)
 local ip, obsh=str2ip(sIP)
    if result and ip then
    	if nnick==nick then msg = "“вой адрес"; else msg= "јдрес "..nnick;end
    	 if obsh == 0 then 
    	  msg=msg..": "..sIP..". ¬нимание! человек не из общаги!"
    	 else
    	  msg=msg..": "..sIP..". "..obsh.." общежитие."
    	 end
    	 SendMessageToUser(string.format(msg), nick, botname)
	else
	 SendMessageToUser(string.format("ѕользовател€ "..nnick.." нет или чЄ-то глючит"), nick, botname)
	end
 return nil
elseif string.find(data, "^.allowme", 1) then
	if not unbanlist then unbanlist = {};end
	if not unbanlist[nick] then unbanlist[nick] = 0; end
	unbanlist[nick]=unbanlist[nick]+1
	local c = unbanlist[nick]
         SendMessageToUser(string.format(" оличество внешних соединений которые будут прин€ты - "..c), nick, botname)
 return nil
elseif string.find(data, "^.denyme", 1) then
        if not unbanlist then unbanlist = {};end
        unbanlist[nick]=0
         SendMessageToUser(string.format(" оличество внешних соединений которые будут прин€ты - 0"), nick, botname)
 return nil
end

return 1
end

function str2ip(str)
 local b1, b2, b3, b4 = str:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
 if b4 then
  local ip=b4+256*(b3+256*(b2+b1*256))
  a, b = VH:SQLQuery("select residence from vtc.localnets where '"..ip.."'>`start` and '"..ip.."'<`end` limit 1")
  if b>0 then
   result, res = VH:SQLFetch(0)
   VH:SQLFree()
   return ip, res
  else
   VH:SQLFree()
   return ip, 0
  end
 end
  return nil
end

function SendMessageToUser(data, nick, from)
	result, err = VH:SendDataToUser("<"..from.."> "..data.."|", nick)
	return 1
end

function SendPmMessageToUser(data, nick, from)
	result, err = VH:SendDataToUser("$To: "..nick.." From: "..from.." $<"..from.."> "..data.."|", nick)
	return 1
end
