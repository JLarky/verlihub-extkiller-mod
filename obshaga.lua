-- obshaga.lua

-- JLarky <jlarky@gmail.com>
-- ������� ��� � ����� ������ ����

LastTenMessages = {}
NumberOfMessages = 0

_, botname = VH:GetConfig("config", "hub_security")
deny_max_time=10
deny_max_attempt=5

function GetMessages()
		return "���� ���������"
end

function VH_OnUserLogin(nick)
        VH:SendDataToUser ("$UserCommand 1 3 ip$<%[mynick]> .ip %[nick]&#124;|", nick)
	res, sIp = VH:GetUserIP(nick)
	_, obsh = str2ip(sIp)
	if obsh == 0 then obsh = "�����"; else obsh = obsh.." ������"; end
--	msg=string.format("������, %s! �� ������ ��������� ����� �������� �� �����, ���� �� ��������� �� ����. �� ���� �������� ����������� http://wiki.punklan.net/news:2009-01-22_conficker\n�� � ������, ������� satter ������ ������ ��� ���������� �����, ��� ��� ���� �� �� ��� ����������� �������, �� ��� ���� http://wiki.punklan.net/lan:wsus", nick )
--	msg=string.format("������, %s! ��� jlarky.punklan.net ����������� ������ ���� ������� ����� - adc://jlarky.punklan.net:4111\n� ������ ���� ���� ������ �� ������������ ADC �������� ���������� �� ftp://jlarky.punklan.net/incom/ADC/ ", nick )
--	SendMessageToUser(msg, nick, "info_bot")

        res, sIp = VH:GetUserIP(nick)
        _, obsh = str2ip(sIp)

	result, iClass = VH:GetUserClass(nick)
	if iClass==0 and obsh==0 then
	  SendMessageToUser("��� ����� ����, �� ��� �� ��������� ����� ������� ������ ������������������ �����. �����! :)", nick, "jlarky@gmail.com")
	  deny_login(nick, sIp)
	end
	return 1
end

function VH_OnParsedMsgConnectToMe(nick,othernick)
 return ban(nick, othernick)
end

function VH_OnParsedMsgRevConnectToMe(nick,othernick)
 return ban(nick, othernick)
end


function deny_login(nick, sIp)
  local time=os.time()
  add_attempt(sIp, time)
  local count=get_attempts(sIp, time)
  if count >= deny_max_attempt then
    msg="���������� ���������� ��� ������� ���� ��������� ������."
    VH:KickUser(botname, nick, msg)
    SendMsgToAdmins("������� �� ������ ����������� ".."nick:"..nick.." ip:"..sIp)
  else
    VH:CloseConnection(nick)
  end
end

function get_denylog()
  if deny_log then
    return deny_log
  else
    return {}
  end
end

function add_attempt(sIp, time)
  local d=0
  deny_log=get_denylog()
  if deny_log[time] then
    if deny_log[time][sIp] then
      d=deny_log[time][sIp]
    end
  else
    deny_log[time]={}
  end
  deny_log[time][sIp]=d+1
end

function get_attempts(sIp, time)
  local count=0
  local new_deny_log={}
  for i = 0, deny_max_time, 1 do
    if deny_log then
      if deny_log[time-i] then
        if deny_log[time-i][sIp] then
	  count = count+deny_log[time-i][sIp]
	end
        new_deny_log[time-i]=deny_log[time-i]
      end
    end
  end
  deny_log=new_deny_log -- delete old records
  return count
end

function ban(nick,othernick)
	if not unbanlist then unbanlist = {};end
        if not unbanlist[nick] then unbanlist[nick] = 0; end
	
	local count=unbanlist[nick]

        res, sIp1 = VH:GetUserIP(nick)
        res, sIp2 = VH:GetUserIP(othernick)
	_, obsh = str2ip(sIp1)
        _, obsh2 = str2ip(sIp2)
	if (not obsh) then
            obsh=0
         end
	 if (not obsh2) then
            obsh2=0
         end

	 if obsh==0 or obsh2==0 then
	    if obsh==0 then
	       ob1="��������"
	    else
	       ob1=obsh.." ������"
	    end
	    if obsh2==0 then
	       ob2="��������"
	    else
	       ob2=obsh2.." ������"
	    end
         msg=string.format("���������� %s(%s) � %s(%s) �� ����� ������������, ��� ��� ���-�� �� ������ ��������� � �����, � �� ������ ����� �������. ���� �� �� ����� �������, ��� ������ ������� �������, �� ������� http://dchub.punklan.net/node/15 �� ������� ������������.", nick, ob1, othernick, ob2)
--	 SendPmMessageToUser(msg.." - "..count, "JLarky", botname)

	 if (not (obsh == 0)) and (unbanlist[nick] > 0) then -- ������ ������� �� ������ � �� �������� ���� ���������
	  unbanlist[nick]=unbanlist[nick]-1
	  SendPmMessageToUser(string.format("������� ������� �� %s(%s). �������� ����������� %s", othernick, sIp2, unbanlist[nick]) , nick, botname)
	  return 1
	 elseif (not (obsh2 == 0)) and (unbanlist[othernick]) and (unbanlist[othernick] > 0) then -- ������ c �������� �� ������ � �� �������� � ���� ���������
	  unbanlist[othernick]=unbanlist[othernick]-1
	  SendPmMessageToUser(string.format("������� ������� � %s(%s). �������� ����������� %s", nick, sIp1, unbanlist[othernick]) , nick, botname)
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
if string.find(data, "^%.ip", 1) then
 nnick = data:match("^.ip (.+)$")
 if nnick then nnick = data:match("^.ip (.+)$"); else nnick=nick; end
 result, sIP = VH:GetUserIP(nnick)
 local ip, obsh=str2ip(sIP)
    if result and ip then
    	if nnick==nick then msg = "���� �����"; else msg= "����� "..nnick;end
    	 if obsh == 0 then 
    	  msg=msg..": "..sIP..". ��������! ������� �� �� ������!"
    	 else
    	  msg=msg..": "..sIP..". "..obsh.." ���������."
    	 end
    	 SendMessageToUser(string.format(msg), nick, botname)
	else
	 SendMessageToUser(string.format("������������ "..nnick.." ��� ��� ��-�� ������"), nick, botname)
	end
 return nil
elseif string.find(data, "^%.allowme", 1) then
	if not unbanlist then unbanlist = {};end
	if not unbanlist[nick] then unbanlist[nick] = 0; end
	unbanlist[nick]=unbanlist[nick]+1
	local c = unbanlist[nick]
         SendMessageToUser(string.format("���������� ������� ���������� ������� ����� ������� - "..c), nick, botname)
 return nil
elseif string.find(data, "^%.allowten", 1) then
	if not unbanlist then unbanlist = {};end
	if not unbanlist[nick] then unbanlist[nick] = 0; end
	unbanlist[nick]=unbanlist[nick]+10
	local c = unbanlist[nick]
         SendMessageToUser(string.format("���������� ������� ���������� ������� ����� ������� - "..c), nick, botname)
 return nil

elseif string.find(data, "^%.denyme", 1) then
        if not unbanlist then unbanlist = {};end
        unbanlist[nick]=0
         SendMessageToUser(string.format("���������� ������� ���������� ������� ����� ������� - 0"), nick, botname)
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

function SendMsgToAdmins(msg)
	VH:SendPMToAll(msg,botname, 5, 10)
end