local function getindex(t,id) 
for i,v in pairs(t) do 
if v == id then 
return i 
end 
end 
return nil 
end

local function index_function(user_id)
  for k,v in pairs(_config.admins) do
    if user_id == v[1] then
    	print(k)
      return k
    end
  end
  return false
end

local function reload_plugins( ) 
  plugins = {} 
  load_plugins() 
end

local function already_sudo(user_id)
  for k,v in pairs(_config.sudo_users) do
    if user_id == v then
      return k
    end
  end
  return false
end

local function already_admin(user_id)
  for k,v in pairs(_config.admins) do
    if user_id == v[1] then
    	print(k)
      return k
    end
  end
  return false
end


local function sudolist(msg)
local sudo_users = _config.sudo_users
local text = "Sudo Users :\n"
for i=1,#sudo_users do
    text = text..i.." - "..sudo_users[i].."\n"
end
return text
end

local function adminlist(msg)
 text = '*List of bot admins :*\n'
		  	local compare = text
		  	local i = 1
		  	for v,user in pairs(_config.admins) do
			    text = text..i..'- '..(user[2] or '')..' ➣ ('..user[1]..')\n'
		  	i = i +1
		  	end
		  	if compare == text then
		  		text = '_No_ *admins* _available_'
		  	end
		  	return text
    end

local function chat_list(msg)
	i = 1
	local data = load_data(_config.moderation.data)
    local groups = 'groups'
    if not data[tostring(groups)] then
        return 'No groups at the moment'
    end
    local message = 'List of Groups:\n*Use #join (ID) to join*\n\n'
    for k,v in pairsByKeys(data[tostring(groups)]) do
		local group_id = v
		if data[tostring(group_id)] then
			settings = data[tostring(group_id)]['settings']
		end
        for m,n in pairsByKeys(settings) do
			if m == 'set_name' then
				name = n:gsub("", "")
				chat_name = name:gsub("‮", "")
				group_name_id = name .. '\n(ID: ' ..group_id.. ')\n\n'
				if name:match("[\216-\219][\128-\191]") then
					group_info = i..' - \n'..group_name_id
				else
					group_info = i..' - '..group_name_id
				end
				i = i + 1
			end
        end
		message = message..group_info
    end
	return message
end
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  return false
end
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_all_plugins(only_enabled)
  local tmp = '\n\n[MaTaDoRTeaM](Telegram.Me/MaTaDoRTeaM)'
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    local status = '*|✖️|>*'
    nsum = nsum+1
    nact = 0
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '*|✔|>*'
      end
      nact = nact+1
    end
    if not only_enabled or status == '*|✔|>*'then
      v = string.match (v, "(.*)%.lua")
      text = text..nsum..'.'..status..' '..check_markdown(v)..' \n'
    end
  end
  local text = text..'\n\n'..nsum..' *📂plugins installed*\n\n'..nact..' _✔️plugins enabled_\n\n'..nsum-nact..' _❌plugins disabled_\n\n[MaTaDoRTeaM](Telegram.Me/MaTaDoRTeaM)'
  return text
end

local function list_plugins(only_enabled)
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    local status = '*|✖️|>*'
    nsum = nsum+1
    nact = 0
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '*|✔|>*'
      end
      nact = nact+1
    end
    if not only_enabled or status == '*|✔|>*'then
      v = string.match (v, "(.*)%.lua")
    end
  end
  local text = text.."\n_🔃All Plugins Reloaded_\n\n"..nact.." *✔️Plugins Enabled*\n"..nsum.." *📂Plugins Installed*\n\n[MaTaDoRTeaM](Telegram.Me/MaTaDoRTeaM)"
return text
end

local function reload_plugins( )
   bot_run()
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')
  if plugin_enabled(plugin_name) then
    return ''..plugin_name..' _is enabled_'
  end
  if plugin_exists(plugin_name) then
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    return reload_plugins( )
  else
    return ''..plugin_name..' _does not exists_'
  end
end

local function disable_plugin( name, chat )
  if not plugin_exists(name) then
    return ' '..name..' _does not exists_'
  end
  local k = plugin_enabled(name)
  if not k then
    return ' '..name..' _not enabled_'
  end
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return "_Plugin doesn't exists_"
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return ' '..plugin..' _disabled on this chat_'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'There aren\'t any disabled plugins'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return 'There aren\'t any disabled plugins for this chat'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return '_This plugin is not disabled_'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return ' '..plugin..' is enabled again'
end
local function modadd(msg)
    if not is_admin(msg) then
        return '*#》Ƴσυ αяє ησт вσт αɗмιη 🚷*\n*〰〰〰〰〰〰〰〰*\n💠 `Run this command only for Admins and deputies is`'
end
    local data = load_data(_config.moderation.data)
if data[tostring(msg.to.id)] then
  return '#》 *Ɠяσυρ ιѕ αƖяєαɗу αɗɗєɗ* ‼️\n*〰〰〰〰〰〰〰〰*\n💠 `The robot is already in the group, the robot was is no longer need to do not`'
end
local status = getChatAdministrators(msg.to.id).result
for k,v in pairs(status) do
if v.status == "creator" then
if v.user.username then
creator_id = v.user.id
user_name = '@'..check_markdown(v.user.username)
else
user_name = check_markdown(v.user.first_name)
end
end
end
        -- create data array in moderation.json
      data[tostring(msg.to.id)] = {
              owners = {[tostring(creator_id)] = user_name},
      mods ={},
      banned ={},
      is_silent_users ={},
      filterlist ={},
      settings = {
          set_name = msg.to.title,
          lock_link = 'yes',
          lock_tag = 'yes',
          lock_spam = 'yes',
          lock_edit = 'no',
          lock_mention = 'no',
          lock_webpage = 'no',
          lock_markdown = 'no',
          flood = 'yes',
          lock_bots = 'yes',
          lock_pin = 'no',
          welcome = 'no',
		  lock_join = 'no',
		  lock_arabic = 'no',
		  num_msg_max = '5',
		  set_char = '40',
		  time_check = '2'
          },
   mutes = {
                  mute_forward = 'no',
                  mute_audio = 'no',
                  mute_video = 'no',
                  mute_contact = 'no',
                  mute_text = 'no',
                  mute_photo = 'no',
                  mute_gif = 'no',
                  mute_location = 'no',
                  mute_document = 'no',
                  mute_sticker = 'no',
                  mute_voice = 'no',
                   mute_all = 'no',
				   mute_tgservice = 'no'
          }
      }
  save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
    return '#》 *Ɠяσυρ нαѕ вєєη αɗɗєɗ* ✅🤖\n\n*Ɠяσυρ Ɲαмє :*'..msg.to.title..'\n*OяɗєяƁу :* @'..check_markdown(msg.from.username or '')..'*|*`'..msg.from.id..'`\n*〰〰〰〰〰〰〰〰*\n💠 `Group now to list the groups the robot was added`\n\n*Ɠяσυρ cнαяgєɗ 3 мιηυтєѕ  fσя ѕєттιηgѕ.*'
end

local function modrem(msg)
      if not is_admin(msg) then
        return '*#》Ƴσυ αяє ησт вσт αɗмιη 🚷*\n*〰〰〰〰〰〰〰〰*\n💠 `Run this command only for Admins and deputies is`'
   end
    local data = load_data(_config.moderation.data)
    local receiver = msg.to.id
  if not data[tostring(msg.to.id)] then
    return '#》 *Ɠяσυρ ιѕ ησт αɗɗєɗ* 🚫\n*〰〰〰〰〰〰〰〰*\n💠 `Group from the first to the group list, the robot was not added`'
  end

  data[tostring(msg.to.id)] = nil
  save_data(_config.moderation.data, data)
     local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
  return '#》 *Ɠяσυρ нαѕ вєєη яємσνєɗ* ❌🤖\n\n*Ɠяσυρ Ɲαмє :*'..msg.to.title..'\n*OяɗєяƁу :* @'..check_markdown(msg.from.username or '')..'*|*`'..msg.from.id..'`\n*〰〰〰〰〰〰〰〰*\n💠 `The group now from the list of groups, the robot was removed`'
end

local function modlist(msg)
    local data = load_data(_config.moderation.data)
    local i = 1
  if not data[tostring(msg.to.id)] then
    return "#》 *Ɠяσυρ ιѕ ησт αɗɗєɗ* 🚫\n*〰〰〰〰〰〰〰〰*\n💠 `Group from the first to the group list, the robot was not added`"
 end
  if next(data[tostring(msg.to.id)]['mods']) == nil then
    return "_No_ *moderator* _in this group_"
end
   message = '*List of moderators :*\n'
  for k,v in pairs(data[tostring(msg.to.id)]['mods'])
do
    message = message ..i.. '- '..v..' [' ..k.. '] \n'
   i = i + 1
end
  return message
end

local function ownerlist(msg)
    local data = load_data(_config.moderation.data)
    local i = 1
  if not data[tostring(msg.to.id)] then
    return "#》 *Ɠяσυρ ιѕ ησт αɗɗєɗ* 🚫\n*〰〰〰〰〰〰〰〰*\n💠 `Group from the first to the group list, the robot was not added`"
end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['owners']) == nil then --fix way
    return "_No_ *owner* _in this group_"
end
   message = '*List of owners :*\n'
  for k,v in pairs(data[tostring(msg.to.id)]['owners']) do
    message = message ..i.. '- '..v..' [' ..k.. '] \n'
   i = i + 1
end
  return message
end

local function filter_word(msg, word)
    local data = load_data(_config.moderation.data)
    if not data[tostring(msg.to.id)]['filterlist'] then
      data[tostring(msg.to.id)]['filterlist'] = {}
      save_data(_config.moderation.data, data)
    end
    if data[tostring(msg.to.id)]['filterlist'][(word)] then
        return "_Word_ *"..word.."* _is already filtered_"
      end
    data[tostring(msg.to.id)]['filterlist'][(word)] = true
    save_data(_config.moderation.data, data)
      return "_Word_ *"..word.."* _added to filtered words list_"
    end

local function unfilter_word(msg, word)
    local data = load_data(_config.moderation.data)
    if not data[tostring(msg.to.id)]['filterlist'] then
      data[tostring(msg.to.id)]['filterlist'] = {}
      save_data(_config.moderation.data, data)
    end
    if data[tostring(msg.to.id)]['filterlist'][word] then
      data[tostring(msg.to.id)]['filterlist'][(word)] = nil
      save_data(_config.moderation.data, data)
        return "_Word_ *"..word.."* _removed from filtered words list_"
    else
        return "_Word_ *"..word.."* _is not filtered_"
    end
  end

local function pre_process(msg)
if not msg.query then
local status = getChatAdministrators(msg.to.id)
local data = load_data(_config.moderation.data)
local chat = msg.to.id
local user = msg.from.id
local is_channel = msg.to.type == "supergroup"
local is_chat = msg.to.type == "group"
local auto_leave = 'AutoLeaveBot'
        local TIME_CHECK = 2
        if data[tostring(chat)] then
          if data[tostring(chat)]['settings']['time_check'] then
            TIME_CHECK = tonumber(data[tostring(chat)]['settings']['time_check'])
          end
        end
   if is_channel or is_chat then
    if msg.text then
  if msg.text:match("(.*)") then
    if not data[tostring(msg.to.id)] and not redis:get(auto_leave) and not is_admin(msg) then
  send_msg(msg.to.id, "برای خرید ربات به پیوی \n@MahDiRoO\nمراجعه کنید.!", nil, "md")
  leave_group(chat)
      end
   end
end
    if data[tostring(chat)] and data[tostring(chat)]['mutes'] then
		mutes = data[tostring(chat)]['mutes']
	else
		return
	end
	if mutes.mute_all then
		mute_all = mutes.mute_all
	else
		mute_all = 'no'
	end
	if mutes.mute_gif then
		mute_gif = mutes.mute_gif
	else
		mute_gif = 'no'
	end
   if mutes.mute_photo then
		mute_photos = mutes.mute_photo
	else
		mute_photos = 'no'
	end
	if mutes.mute_sticker then
		mute_sticker = mutes.mute_sticker
	else
		mute_sticker = 'no'
	end
	if mutes.mute_contact then
		mute_contact = mutes.mute_contact
	else
		mute_contact = 'no'
	end
	if mutes.mute_text then
		mute_text = mutes.mute_text
	else
		mute_text = 'no'
	end
	if mutes.mute_forward then
		mute_forward = mutes.mute_forward
	else
		mute_forward = 'no'
	end
	if mutes.mute_location then
		mute_location = mutes.mute_location
	else
		mute_location = 'no'
	end
   if mutes.mute_document then
		mute_document = mutes.mute_document
	else
		mute_document = 'no'
	end
	if mutes.mute_voice then
		mute_voice = mutes.mute_voice
	else
		mute_voice = 'no'
	end
	if mutes.mute_audio then
		mute_audio = mutes.mute_audio
	else
		mute_audio = 'no'
	end
	if mutes.mute_video then
		mute_video = mutes.mute_video
	else
		mute_video = 'no'
	end
	if mutes.mute_tgservice then
		mute_tgservice = mutes.mute_tgservice
	else
		mute_tgservice = 'no'
	end
	if data[tostring(chat)] and data[tostring(chat)]['settings'] then
		settings = data[tostring(chat)]['settings']
	else
		return
	end
	if settings.lock_link then
		lock_link = settings.lock_link
	else
		lock_link = 'no'
	end
	if settings.lock_bots then
		lock_bot = settings.lock_bots
	else
		lock_bot = 'no'
	end
	if settings.lock_tag then
		lock_tag = settings.lock_tag
	else
		lock_tag = 'no'
	end
	if settings.lock_pin then
		lock_pin = settings.lock_pin
	else
		lock_pin = 'no'
	end
	if settings.lock_mention then
		lock_mention = settings.lock_mention
	else
		lock_mention = 'no'
	end
		if settings.lock_edit then
		lock_edit = settings.lock_edit
	else
		lock_edit = 'no'
	end
		if settings.lock_spam then
		lock_spam = settings.lock_spam
	else
		lock_spam = 'no'
	end
	if settings.flood then
		lock_flood = settings.flood
	else
		lock_flood = 'no'
	end
	if settings.lock_markdown then
		lock_markdown = settings.lock_markdown
	else
		lock_markdown = 'no'
	end
	if settings.lock_webpage then
		lock_webpage = settings.lock_webpage
	else
		lock_webpage = 'no'
	end

     if msg.newuser then
    if msg.newuser.username ~= nil then
      if string.sub(msg.newuser.username:lower(), -3) == 'bot' and not is_owner(msg) and lock_bot == "yes" then
kick_user(msg.newuser.id, chat)
        end
      end
    end
if msg.service and mute_tgservice == "yes" then
del_msg(chat, tonumber(msg.id))
  end
      if not msg.cb and not is_mod(msg) and not is_whitelist(msg.from.id, msg.to.id) then
   if msg.pinned_message and is_channel then
  if lock_pin == "yes" and not is_owner(msg) then
    local pin_msg = data[tostring(msg.to.id)]['pin']
      if pin_msg then
pinChatMessage(msg.to.id, pin_msg)
       elseif not pin_msg then
   unpinChatMessage(msg.to.id)
          end
    send_msg(msg.to.id, '<b>User ID :</b> <code>'..msg.from.id..'</code>\n<b>Username :</b> '..('@'..msg.from.username or '<i>No Username</i>')..'\n<i>You Have Not Permission To Pin Message, Last Message Has Been Pinned Again</i>', msg.id, "html")
      end
  end
if msg.message_edited and lock_edit == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
    end
  end
if msg.fwd_from and mute_forward == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
    end
  end
if msg.photo and mute_photos == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.video and mute_video == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.document and mute_document == "yes" and msg.document.mime_type ~= "audio/mpeg" and msg.document.mime_type ~= "video/mp4" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.sticker and mute_sticker == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.document and msg.document.mime_type == "video/mp4" and mute_gif == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.contact and mute_contact == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.location and mute_location == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.voice and mute_voice == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
    if msg.document and msg.document.mime_type == "audio/mpeg" and mute_audio == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
if msg.caption then
local link_caption = msg.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") or msg.caption:match("[Tt].[Mm][Ee]/") or msg.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
if link_caption
and lock_link == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
local tag_caption = msg.caption:match("@") or msg.caption:match("#")
if tag_caption and lock_tag == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
if is_filter(msg, msg.caption) then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
      end
    end
end
if msg.text then
			local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
        local max_chars = 40
        if data[tostring(msg.to.id)] then
          if data[tostring(msg.to.id)]['settings']['set_char'] then
            max_chars = tonumber(data[tostring(msg.to.id)]['settings']['set_char'])
          end
        end
			 local _nl, real_digits = string.gsub(msg.text, '%d', '')
			local max_real_digits = tonumber(max_chars) * 50
			local max_len = tonumber(max_chars) * 51
			if lock_spam == "yes" then
			if string.len(msg.text) > max_len or ctrl_chars > max_chars or real_digits > max_real_digits then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
      end
   end
end
local link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") or msg.text:match("[Tt].[Mm][Ee]/") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
if link_msg
and lock_link == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
local tag_msg = msg.text:match("@") or msg.text:match("#")
if tag_msg and lock_tag == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
if is_filter(msg, msg.text) then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
      end
    end

if msg.text:match("(.*)")
and mute_text == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
     end
   end
end
if mute_all == "yes" then 
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
   end
end
if msg.entities then
  for i,entity in pairs(msg.entities) do
    if entity.type == "text_mention" then
      if lock_mention == "yes" then
 if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
             end
          end
      end
  if entity.type == "url" or entity.type == "text_link" then
      if lock_webpage == "yes" then
if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
             end
          end
      end
  if entity.type == "bold" or entity.type == "code" or entity.type == "italic" then
      if lock_markdown == "yes" then
if is_channel then
 del_msg(chat, tonumber(msg.id))
  elseif is_chat then
kick_user(user, chat)
                 end
             end
          end
      end
 end
if msg.to.type ~= 'private' and not is_mod(msg) and not is_whitelist(msg.from.id, msg.to.id) then
  if lock_flood == "yes" then
    local hash = 'user:'..user..':msgs'
    local msgs = tonumber(redis:get(hash) or 0)
        local NUM_MSG_MAX = 5
        if data[tostring(chat)] then
          if data[tostring(chat)]['settings']['num_msg_max'] then
            NUM_MSG_MAX = tonumber(data[tostring(chat)]['settings']['num_msg_max'])
          end
        end
    if msgs > NUM_MSG_MAX then
   if msg.from.username then
      user_name = "@"..check_markdown(msg.from.username)
         else
      user_name = escape_markdown(msg.from.first_name)
     end
if redis:get('sender:'..user..':flood') then
return
else
   del_msg(chat, msg.id)
    kick_user(user, chat)
   del_msg(chat, msg.id)
send_msg(chat, "_User_ "..user_name.." `[ "..user.." ]` _has been_ *kicked* _because of_ *flooding*", nil, "md")
redis:setex('sender:'..user..':flood', 30, true)
      end
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
                   end
               end
           end
      end
   end
end
---------------Lock link-------------------
local function lock_link(msg, data, target)
local lock_link = data[tostring(target)]["settings"]["lock_link"] 
if lock_link == "yes" then
 return "*>Lιηк* `Ƥσѕтιηg Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
data[tostring(target)]["settings"]["lock_link"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>Lιηк* `Ƥσѕтιηg Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* {@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`}"
end
end

local function unlock_link(msg, data, target)
local lock_link = data[tostring(target)]["settings"]["lock_link"]
 if lock_link == "no" then
return "*>Lιηк* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_link"] = "no" save_data(_config.moderation.data, data) 
return "*>Lιηк* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* {@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`}" 
end
end

---------------Lock Tag-------------------
local function lock_tag(msg, data, target) 
local lock_tag = data[tostring(target)]["settings"]["lock_tag"] 
if lock_tag == "yes" then
 return "*Ƭαg* `Ƥσѕтιηg Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_tag"] = "yes"
save_data(_config.moderation.data, data) 
 return "*Ƭαg* `Ƥσѕтιηg Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* {@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`}"
end
end

local function unlock_tag(msg, data, target)
local lock_tag = data[tostring(target)]["settings"]["lock_tag"]
 if lock_tag == "no" then
return "*Ƭαg* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_tag"] = "no" save_data(_config.moderation.data, data) 
return "*Ƭαg* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* {@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`}"  
end
end

---------------Lock Mention-------------------
local function lock_mention(msg, data, target)
local lock_mention = data[tostring(target)]["settings"]["lock_mention"] 
if lock_mention == "yes" then
return "*>Mєηтιση* `Ƥσѕтιηg Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_mention"] = "yes"
save_data(_config.moderation.data, data)
return "*>Mєηтιση* `Ƥσѕтιηg Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* {@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`}"
end
end

local function unlock_mention(msg, data, target)

local lock_mention = data[tostring(target)]["settings"]["lock_mention"]
 if lock_mention == "no" then
return "*>Mєηтιση* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐"
else 
data[tostring(target)]["settings"]["lock_mention"] = "no" save_data(_config.moderation.data, data) 
return "*>Mєηтιση* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock Arabic--------------
local function lock_arabic(msg, data, target)
local lock_arabic = data[tostring(target)]["settings"]["lock_arabic"] 
if lock_arabic == "yes" then
 return "*>Aяαвιc/Ƥєяѕιαη* `Ƥσѕтιηg Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
data[tostring(target)]["settings"]["lock_arabic"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>Aяαвιc/Ƥєяѕιαη* `Ƥσѕтιηg Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_arabic(msg, data, target)
local lock_arabic = data[tostring(target)]["settings"]["lock_arabic"]
 if lock_arabic == "no" then
return "*>Aяαвιc/Ƥєяѕιαη* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_arabic"] = "no" save_data(_config.moderation.data, data) 
return "*>Aяαвιc/Ƥєяѕιαη* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock Edit-------------------
local function lock_edit(msg, data, target)
local lock_edit = data[tostring(target)]["settings"]["lock_edit"] 
if lock_edit == "yes" then
return "*>Ɛɗιтιηg* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_edit"] = "yes"
save_data(_config.moderation.data, data) 
return "*>Ɛɗιтιηg* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_edit(msg, data, target)
local lock_edit = data[tostring(target)]["settings"]["lock_edit"]
 if lock_edit == "no" then
return "*>Ɛɗιтιηg* `Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_edit"] = "no" save_data(_config.moderation.data, data) 
return "*>Ɛɗιтιηg* `Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock spam-------------------
local function lock_spam(msg, data, target)
local lock_spam = data[tostring(target)]["settings"]["lock_spam"] 
if lock_spam == "yes" then
 return "*>Sραм* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_spam"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>Sραм* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_spam(msg, data, target)
local lock_spam = data[tostring(target)]["settings"]["lock_spam"]
 if lock_spam == "no" then
return "*>Sραм* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_spam"] = "no" 
save_data(_config.moderation.data, data)
return "*>Sραм* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"  
end
end

---------------Lock Flood-------------------
local function lock_flood(msg, data, target) 
local lock_flood = data[tostring(target)]["settings"]["lock_flood"] 
if lock_flood == "yes" then
 return "*>ƑƖσσɗιηg* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_flood"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>ƑƖσσɗιηg* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_flood(msg, data, target)
local lock_flood = data[tostring(target)]["settings"]["lock_flood"]
 if lock_flood == "no" then
return "*>ƑƖσσɗιηg* `Iѕ Ɲσт Lσcкєɗ` ❌🔐"  
else 
data[tostring(target)]["settings"]["lock_flood"] = "no" save_data(_config.moderation.data, data) 
return "*>ƑƖσσɗιηg* `Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock Bots-------------------
local function lock_bots(msg, data, target)
local lock_bots = data[tostring(target)]["settings"]["lock_bots"] 
if lock_bots == "yes" then
 return "*>Ɓσтѕ* `Ƥяσтєcтιση Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_bots"] = "yes"
save_data(_config.moderation.data, data) 
return "*>Ɓσтѕ* `Ƥяσтєcтιση Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖✅\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_bots(msg, data, target)
local lock_bots = data[tostring(target)]["settings"]["lock_bots"]
 if lock_bots == "no" then
return "*>Ɓσтѕ* `Ƥяσтєcтιση Iѕ Ɲσт ƐηαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["settings"]["lock_bots"] = "no" save_data(_config.moderation.data, data) 
return "*>Ɓσтѕ* `Ƥяσтєcтιση Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖❌\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock Join-------------------
local function lock_join(msg, data, target) 
local lock_join = data[tostring(target)]["settings"]["lock_join"] 
if lock_join == "yes" then
 return "*>Lσcк Jσιη* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_join"] = "yes"
save_data(_config.moderation.data, data) 
   return "*>Lσcк Jσιη* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_join(msg, data, target) 
local lock_join = data[tostring(target)]["settings"]["lock_join"]
 if lock_join == "no" then
return "*>Lσcк Jσιη* `Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_join"] = "no"
save_data(_config.moderation.data, data) 
return "*>Lσcк Jσιη* `Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

---------------Lock Markdown-------------------
local function lock_markdown(msg, data, target) 
local lock_markdown = data[tostring(target)]["settings"]["lock_markdown"] 
if lock_markdown == "yes" then
  return "*>Mαякɗσωη* `Ƥσѕтιηg Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_markdown"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>Mαякɗσωη* `Ƥσѕтιηg Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_markdown(msg, data, target)
local lock_markdown = data[tostring(target)]["settings"]["lock_markdown"]
 if lock_markdown == "no" then
return "*>Mαякɗσωη* `Ƥσѕтιηg Iѕ Ɲσт Lσcкєɗ` ❌🔐"
else 
data[tostring(target)]["settings"]["lock_markdown"] = "no" save_data(_config.moderation.data, data) 
return "*>Mαякɗσωη* `Ƥσѕтιηg Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

---------------Lock Webpage-------------------
local function lock_webpage(msg, data, target) 
local lock_webpage = data[tostring(target)]["settings"]["lock_webpage"] 
if lock_webpage == "yes" then
 return "*>Ɯєвραgє* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_webpage"] = "yes"
save_data(_config.moderation.data, data) 
 return "*>Ɯєвραgє* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_webpage(msg, data, target)
local lock_webpage = data[tostring(target)]["settings"]["lock_webpage"]
 if lock_webpage == "no" then
return "*>Ɯєвραgє* `Iѕ Ɲσт Lσcкєɗ` ❌🔐" 
else 
data[tostring(target)]["settings"]["lock_webpage"] = "no"
save_data(_config.moderation.data, data) 
return "*>Ɯєвραgє* `Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

---------------Lock Pin-------------------
local function lock_pin(msg, data, target) 
local lock_pin = data[tostring(target)]["settings"]["lock_pin"] 
if lock_pin == "yes" then
 return "*>Ƥιηηєɗ Mєѕѕαgє* `Iѕ AƖяєαɗу Lσcкєɗ` ♻️⚠️"
else
 data[tostring(target)]["settings"]["lock_pin"] = "yes"
save_data(_config.moderation.data, data) 
return "*>Ƥιηηєɗ Mєѕѕαgє* `Hαѕ Ɓєєη Lσcкєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unlock_pin(msg, data, target)
local lock_pin = data[tostring(target)]["settings"]["lock_pin"]
 if lock_pin == "no" then
return "*>Ƥιηηєɗ Mєѕѕαgє* `Iѕ Ɲσт Lσcкєɗ` ❌🔐"
else 
data[tostring(target)]["settings"]["lock_pin"] = "no"
save_data(_config.moderation.data, data) 
return "*>Ƥιηηєɗ Mєѕѕαgє* `Hαѕ Ɓєєη UηƖσcкєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end
--------Lock all--------------------------
local function mute_all(msg, data, target) 
local mute_all = data[tostring(target)]["mutes"]["mute_all"] 
if mute_all == "yes" then 
 return "*>Lσcк All* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️" 
else 
data[tostring(target)]["mutes"]["mute_all"] = "yes"
 save_data(_config.moderation.data, data) 
 return "*>Lσcк All* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end

local function unmute_all(msg, data, target) 
local mute_all = data[tostring(target)]["mutes"]["mute_all"] 
if mute_all == "no" then 
return "*>Lσcк All* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐" 
else 
data[tostring(target)]["mutes"]["mute_all"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк All* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"   
end
end

---------------Lock Gif-------------------
local function mute_gif(msg, data, target) 
local mute_gif = data[tostring(target)]["mutes"]["mute_gif"] 
if mute_gif == "yes" then
 return "*>Lσcк Ɠιf* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_gif"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Ɠιf* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_gif(msg, data, target)
local mute_gif = data[tostring(target)]["mutes"]["mute_gif"]
 if mute_gif == "no" then
return "*>Lσcк Ɠιf* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"  
else 
data[tostring(target)]["mutes"]["mute_gif"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Ɠιf* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"  
end
end
---------------Lock Text-------------------
local function mute_text(msg, data, target) 
local mute_text = data[tostring(target)]["mutes"]["mute_text"] 
if mute_text == "yes" then
 return "*>Lσcк Ƭєxт* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_text"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Ƭєxт* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_text(msg, data, target)
local mute_text = data[tostring(target)]["mutes"]["mute_text"]
 if mute_text == "no" then
return "*>Lσcк Ƭєxт* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["mutes"]["mute_text"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Ƭєxт* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"  
end
end
---------------Lock photo-------------------
local function mute_photo(msg, data, target) 
local mute_photo = data[tostring(target)]["mutes"]["mute_photo"] 
if mute_photo == "yes" then
return "*>Lσcк Ƥнσтσ* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_photo"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Ƥнσтσ* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_photo(msg, data, target)
 
local mute_photo = data[tostring(target)]["mutes"]["mute_photo"]
 if mute_photo == "no" then
return "*>Lσcк Ƥнσтσ* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐" 
else 
data[tostring(target)]["mutes"]["mute_photo"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Ƥнσтσ* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end
---------------Lock Video-------------------
local function mute_video(msg, data, target) 
local mute_video = data[tostring(target)]["mutes"]["mute_video"] 
if mute_video == "yes" then
return "*>Lσcк Ʋιɗєσ* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_video"] = "yes" 
save_data(_config.moderation.data, data)
 return "*>Lσcк Ʋιɗєσ* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_video(msg, data, target)
 
local mute_video = data[tostring(target)]["mutes"]["mute_video"]
 if mute_video == "no" then
return "*>Lσcк Ʋιɗєσ* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["mutes"]["mute_video"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Ʋιɗєσ* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end
---------------Lock Audio-------------------
local function mute_audio(msg, data, target) 
local mute_audio = data[tostring(target)]["mutes"]["mute_audio"] 
if mute_audio == "yes" then
 return "*>Lσcк Aυɗισ* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_audio"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Aυɗισ* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_audio(msg, data, target)
local mute_audio = data[tostring(target)]["mutes"]["mute_audio"]
 if mute_audio == "no" then
return "*>Lσcк Aυɗισ* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐" 
else 
data[tostring(target)]["mutes"]["mute_audio"] = "no"
 save_data(_config.moderation.data, data)
return "*>Lσcк Aυɗισ* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end
---------------Lock Voice-------------------
local function mute_voice(msg, data, target) 
local mute_voice = data[tostring(target)]["mutes"]["mute_voice"] 
if mute_voice == "yes" then
 return "*>Lσcк Ʋσιcє* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_voice"] = "yes" 
save_data(_config.moderation.data, data) 
return "*>Lσcк Ʋσιcє* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_voice(msg, data, target)
local mute_voice = data[tostring(target)]["mutes"]["mute_voice"]
 if mute_voice == "no" then
return "*>Lσcк Ʋσιcє* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"  
else 
data[tostring(target)]["mutes"]["mute_voice"] = "no"
 save_data(_config.moderation.data, data)
return "*>Lσcк Ʋσιcє* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"  
end
end
---------------Lock Sticker-------------------
local function mute_sticker(msg, data, target) 
local mute_sticker = data[tostring(target)]["mutes"]["mute_sticker"] 
if mute_sticker == "yes" then
 return "*>Lσcк Sтιcкєя* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_sticker"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Sтιcкєя* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_sticker(msg, data, target)
local mute_sticker = data[tostring(target)]["mutes"]["mute_sticker"]
 if mute_sticker == "no" then
return "*>Lσcк Sтιcкєя* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["mutes"]["mute_sticker"] = "no"
 save_data(_config.moderation.data, data)
return "*>Lσcк Sticker* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end
---------------Lock Contact-------------------
local function mute_contact(msg, data, target) 
local mute_contact = data[tostring(target)]["mutes"]["mute_contact"] 
if mute_contact == "yes" then
 return "*>Lσcк Ƈσηтαcт* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_contact"] = "yes" 
save_data(_config.moderation.data, data) 
return "*>Lσcк Ƈσηтαcт* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_contact(msg, data, target)
local mute_contact = data[tostring(target)]["mutes"]["mute_contact"]
 if mute_contact == "no" then
return "*>Lσcк Ƈσηтαcт* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐" 
else 
data[tostring(target)]["mutes"]["mute_contact"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Ƈσηтαcт* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"  
end
end
---------------Lock Forward-------------------
local function mute_forward(msg, data, target) 
local mute_forward = data[tostring(target)]["mutes"]["mute_forward"] 
if mute_forward == "yes" then
 return "*>Lσcк Ƒσяωαяɗ* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_forward"] = "yes" 
save_data(_config.moderation.data, data) 
 return "*>Lσcк Ƒσяωαяɗ* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_forward(msg, data, target)
local mute_forward = data[tostring(target)]["mutes"]["mute_forward"]
 if mute_forward == "no" then
return "*>Lσcк Ƒσяωαяɗ* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["mutes"]["mute_forward"] = "no"
 save_data(_config.moderation.data, data)
return "*>Lσcк Ƒσяωαяɗ* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end
---------------Lock Location-------------------
local function mute_location(msg, data, target) 
local mute_location = data[tostring(target)]["mutes"]["mute_location"] 
if mute_location == "yes" then
 return "*>Lσcк Lσcαтιση* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_location"] = "yes" 
save_data(_config.moderation.data, data)
 return "*>Lσcк Lσcαтιση* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_location(msg, data, target)
local mute_location = data[tostring(target)]["mutes"]["mute_location"]
 if mute_location == "no" then
return "*>Lσcк Lσcαтιση* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"  
else 
data[tostring(target)]["mutes"]["mute_location"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Lσcαтιση* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end
---------------Lock Document-------------------
local function mute_document(msg, data, target) 
local mute_document = data[tostring(target)]["mutes"]["mute_document"] 
if mute_document == "yes" then
return "*>Lσcк Dᴏᴄᴜᴍᴇɴᴛ* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_document"] = "yes" 
save_data(_config.moderation.data, data) 
return "*>Lσcк Dᴏᴄᴜᴍᴇɴᴛ* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_document(msg, data, target)
local mute_document = data[tostring(target)]["mutes"]["mute_document"]
 if mute_document == "no" then
return "*>Lσcк Dᴏᴄᴜᴍᴇɴᴛ* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"  
else 
data[tostring(target)]["mutes"]["mute_document"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк Dᴏᴄᴜᴍᴇɴᴛ* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]" 
end
end
---------------Lock TgService-------------------
local function mute_tgservice(msg, data, target) 
local mute_tgservice = data[tostring(target)]["mutes"]["mute_tgservice"] 
if mute_tgservice == "yes" then
 return "*>Lσcк ƬgSєяνιcє* `Iѕ AƖяєαɗу ƐηαвƖєɗ` ♻️⚠️"
else
 data[tostring(target)]["mutes"]["mute_tgservice"] = "yes" 
save_data(_config.moderation.data, data) 
return "*>Lσcк ƬgSєяνιcє* `Hαѕ Ɓєєη ƐηαвƖєɗ` 🤖🔒\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

local function unmute_tgservice(msg, data, target)
local mute_tgservice = data[tostring(target)]["mutes"]["mute_tgservice"]
 if mute_tgservice == "no" then
return "*>Lσcк ƬgSєяνιcє* `Iѕ AƖяєαɗу ƊιѕαвƖєɗ` ❌🔐"
else 
data[tostring(target)]["mutes"]["mute_tgservice"] = "no"
 save_data(_config.moderation.data, data) 
return "*>Lσcк ƬgSєяνιcє* `Hαѕ Ɓєєη ƊιѕαвƖєɗ` 🤖🔓\n*OяɗєяƁу :* [@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]"
end
end

function group_settings(msg, target) 	
if not is_mod(msg) then
 	return "`Ƴσυ'яє Ɲσт` *Mσɗєяαтσя* 🚷"
end
local data = load_data(_config.moderation.data)
local settings = data[tostring(target)]["settings"] 
local mutes = data[tostring(target)]["mutes"]
text = "*MαƬαƊσR SєƬƬιηgѕ :*\n🔐 `ƓяσUρ` #>Lσcк ` Lιѕт :`\n\n*>Lσcк edit :* "..settings.lock_edit.."\n*>Lσcк links :* "..settings.lock_link.."\n*>Lσcк tags :* "..settings.lock_tag.."\n*>Lσcк Join :* "..settings.lock_join.."\n*>Lσcк flood :* "..settings.flood.."\n*>Lσcк spam :* "..settings.lock_spam.."\n*>Lσcк mention :* "..settings.lock_mention.."\n*>Lσcк arabic :* "..settings.lock_arabic.."\n*>Lσcк webpage :* "..settings.lock_webpage.."\n*>Lσcк markdown :* "..settings.lock_markdown.."\n*>Lσcк all :* "..mutes.mute_all.."\n*>Lσcк gif :* "..mutes.mute_gif.."\n*>Lσcк text :* "..mutes.mute_text.."\n*>Lσcк photo :* "..mutes.mute_photo.."\n*>Lσcк video :* "..mutes.mute_video.."\n*>Lσcк audio :* "..mutes.mute_audio.."\n*>Lσcк voice :* "..mutes.mute_voice.."\n*>Lσcк sticker :* "..mutes.mute_sticker.."\n*>Lσcк contact :* "..mutes.mute_contact.."\n*>Lσcк forward :* "..mutes.mute_forward.."\n*>Lσcк location :* "..mutes.mute_location.."\n*>Lσcк document :* "..mutes.mute_document.."\n*>Lσcк TgService :* "..mutes.mute_tgservice.."\n*>Lσcк pin message :* "..settings.lock_pin.."\n=============\n💠 `ƓяσUρ` #OƬнƐя `SєттιηƓѕ :`\n\n*>Ɠяσυρ ƜєƖcσмє :* "..settings.welcome.."\n*>Ɓσтѕ Ƥяσтєcтιση :* "..settings.lock_bots.."\n*>ƑƖσσɗ Sєηѕιтινιту :* `"..settings.num_msg_max.."`\n*>ƑƖσσɗ Ƈнєcк Ƭιмє :* `"..settings.time_check.."`\n*>Ƈнαяαcтєя Sєηѕιтινιту :* `"..settings.set_char.."`\n\n=============\n🌐 `IηfσRмαƬιση :`\n\n*>Ɠяσυρ Ɲαмє :* "..(check_markdown(msg.to.title) or "").."\n*>Ɠяσυρ IƊ :* `"..msg.to.id.."`\n*>Ƴσυя Ɲαмє :* "..(check_markdown(msg.from.first_name) or "No ɳαɱҽ").."\n*>Ƴσυя IƊ :* `"..msg.from.id.."`\n*>Uѕєяηαмє :* @"..check_markdown(msg.from.username or "").."\n\n=============\n*>ƇнαηηєƖ :* @MaTaDoRTeaM\n*>Ƥσωєяєɗ Ɓу :* @MahDiRoO"
text = string.gsub(text, "yes", "`Enable ✅`")
text = string.gsub(text, "no", "`Disabled ❌`")
return text
end

local function run(msg, matches)
local data = load_data(_config.moderation.data)
local target = msg.to.id
----------------Begin Msg Matches--------------
if matches[1] == "add" and is_admin(msg) then
return modadd(msg)
   end
if matches[1] == "rem" and is_admin(msg) then
return modrem(msg)
   end
if matches[1] == "ownerlist" and is_mod(msg) then
return ownerlist(msg)
   end
if matches[1] == "filterlist" and is_mod(msg) then
return filter_list(msg)
   end
if matches[1] == "modlist" and is_mod(msg) then
return modlist(msg)
   end
if matches[1] == "whitelist" and is_mod(msg) then
return whitelist(msg.to.id)
   end
if matches[1] == "whois" and matches[2] and (matches[2]:match('^%d+') or matches[2]:match('-%d+')) and is_mod(msg) then
		local usr_name, fst_name, lst_name, biotxt = '', '', '', ''
		local user = getUser(matches[2])
		if not user.result then
			return '`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣'
		end
		user = user.information
		if user.username then
			usr_name = '@'..check_markdown(user.username)
		else
			usr_name = '---'

		end
		if user.lastname then
			lst_name = escape_markdown(user.lastname)
		else
			lst_name = '---'
		end
		if user.firstname then
			fst_name = escape_markdown(user.firstname)
		else
			fst_name = '---'
		end
		if user.bio then
			biotxt = escape_markdown(user.bio)
		else
			biotxt = '---'
		end
		local text = 'Username: '..usr_name..' \nFirstName: '..fst_name..' \nLastName: '..lst_name..' \nBio: '..biotxt
		return text
end
if matches[1] == "res" and matches[2] and not matches[2]:match('^%d+') and is_mod(msg) then
		local usr_name, fst_name, lst_name, biotxt, UID = '', '', '', '', ''
		local user = resolve_username(matches[2])
		if not user.result then
			return '`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣'
		end
		user = user.information
		if user.username then
			usr_name = '@'..check_markdown(user.username)
		else
			usr_name = '_Error! Please Try Again._'
			return usr_name
		end
		if user.lastname then
			lst_name = escape_markdown(user.lastname)
		else
			lst_name = '---'
		end
		if user.firstname then
			fst_name = escape_markdown(user.firstname)
		else
			fst_name = '---'
		end
		if user.id then
			UID = user.id
		else
			UID = '---'
		end
		if user.bio then
			biotxt = escape_markdown(user.bio)
		else
			biotxt = '---'
		end
		local text = 'Username: '..usr_name..' \nUser ID: '..UID..'\nFirstName: '..fst_name..' \nLastName: '..lst_name..' \nBio: '..biotxt
		return text
end
if matches[1] == 'matador' then
return _config.info_text
end
if matches[1] == 'ping' then
return "ƤσηƓ"
end
if matches[1] == "id" then
   if not matches[2] and not msg.reply_to_message then
local status = getUserProfilePhotos(msg.from.id, 0, 0)
   if status.result.total_count ~= 0 then
	sendPhotoById(msg.to.id, status.result.photos[1][1].file_id, msg.id, "Ɠяσυρ ηαмє : "..(check_markdown(msg.to.title)).."\nƓяσυρ IƊ : "..msg.to.id.."\nƝαмє : "..(msg.from.first_name or "----").."\nUѕєяƝαмє : @"..(msg.from.username or "----").."\nUѕєя IƊ : "..msg.from.id.."")
	else
   return "*Chat ID :* `"..tostring(msg.to.id).."`\n*User ID :* `"..tostring(msg.from.id).."`"
   end
   elseif msg.reply_to_message and not msg.reply.fwd_from and is_mod(msg) then
     return "`"..msg.reply.id.."`"
   elseif not string.match(matches[2], '^%d+$') and matches[2] ~= "from" and is_mod(msg) then
    local status = resolve_username(matches[2])
		if not status.result then
			return '`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣'
		end
     return "`"..status.information.id.."`"
   elseif matches[2] == "from" and msg.reply_to_message and msg.reply.fwd_from then
     return "`"..msg.reply.fwd_from.id.."`"
   end
end
if matches[1] == "pin" and is_mod(msg) and msg.reply_id then
local lock_pin = data[tostring(msg.to.id)]["settings"]["lock_pin"] 
 if lock_pin == 'yes' then
if is_owner(msg) then
    data[tostring(msg.to.id)]['pin'] = msg.reply_id
	  save_data(_config.moderation.data, data)
pinChatMessage(msg.to.id, msg.reply_id)
return "*Mєѕѕαgє Hαѕ Ɓєєη Ƥιηηє∂*"
elseif not is_owner(msg) then
   return
 end
 elseif lock_pin == 'no' then
    data[tostring(msg.to.id)]['pin'] = msg.reply_id
	  save_data(_config.moderation.data, data)
pinChatMessage(msg.to.id, msg.reply_id)
return "*Mєѕѕαgє Hαѕ Ɓєєη Ƥιηηє∂*"
end
end
if matches[1] == 'unpin' and is_mod(msg) then
local lock_pin = data[tostring(msg.to.id)]["settings"]["lock_pin"] 
 if lock_pin == 'yes' then
if is_owner(msg) then
unpinChatMessage(msg.to.id)
return "*Ƥιη мєѕѕαgє нαѕ вєєη υηριηηє∂*"
elseif not is_owner(msg) then
   return 
 end
 elseif lock_pin == 'no' then
unpinChatMessage(msg.to.id)
return "*Ƥιη мєѕѕαgє нαѕ вєєη υηριηηє∂*"
end
end
if matches[1] == 'settings' then
return group_settings(msg, target)
end
   if matches[1] == "setowner" and is_admin(msg) then
   if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if data[tostring(msg.to.id)]['owners'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(msg.reply.id)] = username
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ ησω` *Ɠяσυρ Oωηєя*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
	  if data[tostring(msg.to.id)]['owners'][tostring(matches[2])] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(matches[2])] = user_name
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ ησω` *Ɠяσυρ Oωηєя*"
   end
   elseif matches[2] and not matches[2]:match('^%d+') then
  if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2]).information
   if data[tostring(msg.to.id)]['owners'][tostring(status.id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(status.id)] = check_markdown(status.username)
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ ησω` *Ɠяσυρ Oωηєя*"
   end
end
end
   if matches[1] == "remowner" and is_admin(msg) then
      if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if not data[tostring(msg.to.id)]['owners'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσт` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(msg.reply.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Oωηєя*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
	  if not data[tostring(msg.to.id)]['owners'][tostring(matches[2])] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσт` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(matches[2])] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Oωηєя*"
      end
   elseif matches[2] and not matches[2]:match('^%d+') then
  if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2]).information
   if not data[tostring(msg.to.id)]['owners'][tostring(status.id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ Ɲσт` *Ɠяσυρ Oωηєя*"
    else
  data[tostring(msg.to.id)]['owners'][tostring(status.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Oωηєя*"
      end
end
end
   if matches[1] == "promote" and is_owner(msg) then
   if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if data[tostring(msg.to.id)]['mods'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(msg.reply.id)] = username
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ ησω` *Ɠяσυρ Mσ∂єяαтσя*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
	  if data[tostring(msg.to.id)]['mods'][tostring(matches[2])] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(matches[2])] = user_name
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ ησω` *Ɠяσυρ Mσ∂єяαтσя*"
   end
   elseif matches[2] and not matches[2]:match('^%d+') then
  if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2]).information
   if data[tostring(msg.to.id)]['mods'][tostring(user_id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ αℓяєα∂у` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(status.id)] = check_markdown(status.username)
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ ησω` *Ɠяσυρ Mσ∂єяαтσя*"
   end
end
end
   if matches[1] == "demote" and is_owner(msg) then
      if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if not data[tostring(msg.to.id)]['mods'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσт` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(msg.reply.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Mσ∂єяαтσя*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
	  if not data[tostring(msg.to.id)]['mods'][tostring(matches[2])] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσт` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(matches[2])] = user_name
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Mσ∂єяαтσя*"
      end
   elseif matches[2] and not matches[2]:match('^%d+') then
  if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2]).information
   if not data[tostring(msg.to.id)]['mods'][tostring(status.id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ Ɲσт` *Ɠяσυρ Mσ∂єяαтσя*"
    else
  data[tostring(msg.to.id)]['mods'][tostring(status.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` `ιѕ Ɲσ Lσηgєя` *Ɠяσυρ Mσ∂єяαтσя*"
      end
end
end
   if matches[1] == "whitelist" and matches[2] == "+" and is_mod(msg) then
   if not matches[3] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if data[tostring(msg.to.id)]['whitelist'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _is already in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(msg.reply.id)] = username
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _added to_ *Ɯнιтє Lιѕт*"
      end
	  elseif matches[3] and matches[3]:match('^%d+') then
  if not getUser(matches[3]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[3]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[3]).information.first_name)
	  end
	  if data[tostring(msg.to.id)]['whitelist'][tostring(matches[3])] then
    return "✴️》*Uѕєя :* ["..user_name.."]\n🆔》*IƊ :* `["..matches[3].."]` _is already in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(matches[3])] = user_name
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..user_name.."]\n🆔》*IƊ :* `["..matches[3].."]` _added to_ *Ɯнιтє Lιѕт*"
   end
   elseif matches[3] and not matches[3]:match('^%d+') then
  if not resolve_username(matches[3]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[3]).information
   if data[tostring(msg.to.id)]['whitelist'][tostring(status.id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` _is already in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(status.id)] = check_markdown(status.username)
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` _added to_ *Ɯнιтє Lιѕт*"
   end
end
end
   if matches[1] == "whitelist" and matches[2] == "-" and is_mod(msg) then
      if not matches[3] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if not data[tostring(msg.to.id)]['whitelist'][tostring(msg.reply.id)] then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _is not in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(msg.reply.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _removed from_ *Ɯнιтє Lιѕт*"
      end
	  elseif matches[3] and matches[3]:match('^%d+') then
  if not getUser(matches[3]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[3]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[3]).information.first_name)
	  end
	  if not data[tostring(msg.to.id)]['whitelist'][tostring(matches[3])] then
    return "✴️》*Uѕєя :* ["..user_name.."]\n🆔》*IƊ :* `["..matches[3].."]` _is not in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(matches[3])] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* ["..user_name.."]\n🆔》*IƊ :* `["..matches[3].."]` _removed from_ *Ɯнιтє Lιѕт*"
      end
   elseif matches[3] and not matches[3]:match('^%d+') then
  if not resolve_username(matches[3]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[3]).information
   if not data[tostring(msg.to.id)]['whitelist'][tostring(status.id)] then
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` _is not in_ *Ɯнιтє Lιѕт*"
    else
  data[tostring(msg.to.id)]['whitelist'][tostring(status.id)] = nil
    save_data(_config.moderation.data, data)
    return "✴️》*Uѕєя :* [@"..check_markdown(status.username).."]\n🆔》*IƊ :* `["..status.id.."]` _removed_ *Ɯнιтє Lιѕт*"
      end
end
end
if matches[1]:lower() == "lock" and is_mod(msg) then
if matches[2] == "link" then
return lock_link(msg, data, target)
end
if matches[2] == "tag" then
return lock_tag(msg, data, target)
end
if matches[2] == "mention" then
return lock_mention(msg, data, target)
end
if matches[2] == "arabic" then
return lock_arabic(msg, data, target)
end
if matches[2] == "edit" then
return lock_edit(msg, data, target)
end
if matches[2] == "spam" then
return lock_spam(msg, data, target)
end
if matches[2] == "flood" then
return lock_flood(msg, data, target)
end
if matches[2] == "bots" then
return lock_bots(msg, data, target)
end
if matches[2] == "markdown" then
return lock_markdown(msg, data, target)
end
if matches[2] == "webpage" then
return lock_webpage(msg, data, target)
end
if matches[2] == "pin" and is_owner(msg) then
return lock_pin(msg, data, target)
end
if matches[2] == "join" then
return lock_join(msg, data, target)
end
if matches[2] == "gif" then
return mute_gif(msg, data, target)
end
if matches[2] == "text" then
return mute_text(msg ,data, target)
end
if matches[2] == "photo" then
return mute_photo(msg ,data, target)
end
if matches[2] == "video" then
return mute_video(msg ,data, target)
end
if matches[2] == "audio" then
return mute_audio(msg ,data, target)
end
if matches[2] == "voice" then
return mute_voice(msg ,data, target)
end
if matches[2] == "sticker" then
return mute_sticker(msg ,data, target)
end
if matches[2] == "contact" then
return mute_contact(msg ,data, target)
end
if matches[2] == "forward" then
return mute_forward(msg ,data, target)
end
if matches[2] == "location" then
return mute_location(msg ,data, target)
end
if matches[2] == "document" then
return mute_document(msg ,data, target)
end
if matches[2] == "tgservice" then
return mute_tgservice(msg ,data, target)
end
if matches[2] == 'all' then
return mute_all(msg ,data, target)
end
end
if matches[1]:lower() == "unlock" and is_mod(msg) then
if matches[2] == "link" then
return unlock_link(msg, data, target)
end
if matches[2] == "tag" then
return unlock_tag(msg, data, target)
end
if matches[2] == "mention" then
return unlock_mention(msg, data, target)
end
if matches[2] == "arabic" then
return unlock_arabic(msg, data, target)
end
if matches[2] == "edit" then
return unlock_edit(msg, data, target)
end
if matches[2] == "spam" then
return unlock_spam(msg, data, target)
end
if matches[2] == "flood" then
return unlock_flood(msg, data, target)
end
if matches[2] == "bots" then
return unlock_bots(msg, data, target)
end
if matches[2] == "markdown" then
return unlock_markdown(msg, data, target)
end
if matches[2] == "webpage" then
return unlock_webpage(msg, data, target)
end
if matches[2] == "pin" and is_owner(msg) then
return unlock_pin(msg, data, target)
end
if matches[2] == "join" then
return unlock_join(msg, data, target)
end
if matches[2] == "gif" then
return unmute_gif(msg, data, target)
end
if matches[2] == "text" then
return unmute_text(msg, data, target)
end
if matches[2] == "photo" then
return unmute_photo(msg ,data, target)
end
if matches[2] == "video" then
return unmute_video(msg ,data, target)
end
if matches[2] == "audio" then
return unmute_audio(msg ,data, target)
end
if matches[2] == "voice" then
return unmute_voice(msg ,data, target)
end
if matches[2] == "sticker" then
return unmute_sticker(msg ,data, target)
end
if matches[2] == "contact" then
return unmute_contact(msg ,data, target)
end
if matches[2] == "forward" then
return unmute_forward(msg ,data, target)
end
if matches[2] == "location" then
return unmute_location(msg ,data, target)
end
if matches[2] == "document" then
return unmute_document(msg ,data, target)
end
if matches[2] == "tgservice" then
return unmute_tgservice(msg ,data, target)
end
 if matches[2] == 'all' then
return unmute_all(msg ,data, target)
end
end
if matches[1] == 'filter' and matches[2] and is_mod(msg) then
    return filter_word(msg, matches[2])
end
if matches[1] == 'unfilter' and matches[2] and is_mod(msg) then
    return unfilter_word(msg, matches[2])
end
if matches[1] == 'newlink' and is_mod(msg) then
  local administration = load_data(_config.moderation.data)
  local link = exportChatInviteLink(msg.to.id)
	if not link then
		return "_Error! Bot is not Admin or not restrict invite link._"
	else
		administration[tostring(msg.to.id)]['settings']['linkgp'] = link.result
		save_data(_config.moderation.data, administration)
		return "*Newlink Created And Saved.*"
	end
   end
		if matches[1] == 'setlink' and is_owner(msg) then
		data[tostring(target)]['settings']['linkgp'] = 'waiting'
			save_data(_config.moderation.data, data)
			return '_Please send the new group_ *link* _now_'
	   end
		if msg.text then
   local is_link = msg.text:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or msg.text:match("^([https?://w]*.?t.me/joinchat/%S+)$")
			if is_link and data[tostring(target)]['settings']['linkgp'] == 'waiting' and is_owner(msg) then
				data[tostring(target)]['settings']['linkgp'] = msg.text
				save_data(_config.moderation.data, data)
				return "*Newlink* _has been set_"
       end
		end
    if matches[1] == 'link' and is_mod(msg) then
      local linkgp = data[tostring(target)]['settings']['linkgp']
      if not linkgp then
        return "_First set a link for group with using_ /setlink _or send_ /newlink _to export new invite link._"
      end
       text = "[Tap Here To Join ➣ { "..escape_markdown(msg.to.title).." }]("..linkgp..")"
        return text
     end
  if matches[1] == "setrules" and matches[2] and is_mod(msg) then
    data[tostring(target)]['rules'] = matches[2]
	  save_data(_config.moderation.data, data)
    return "*Group rules* _has been set_"
  end
  if matches[1] == "rules" then
 if not data[tostring(target)]['rules'] then
     rules = "No Rules\n By @MahDiRoO"
        else
     rules = "*Group Rules :*\n"..data[tostring(target)]['rules']
      end
    return rules
  end
		if matches[1]:lower() == 'setchar' then
			if not is_mod(msg) then
				return
			end
			local chars_max = matches[2]
			data[tostring(msg.to.id)]['settings']['set_char'] = chars_max
			save_data(_config.moderation.data, data)
     return "*Character sensitivity* _has been set to :_ *[ "..matches[2].." ]*"
  end
  if matches[1]:lower() == 'setflood' and is_mod(msg) then
			if tonumber(matches[2]) < 1 or tonumber(matches[2]) > 50 then
				return "_Wrong number, range is_ *[2-50]*"
      end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['num_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
    return "_Group_ *flood* _sensitivity has been set to :_ *[ "..matches[2].." ]*"
       end
  if matches[1]:lower() == 'setfloodtime' and is_mod(msg) then
			if tonumber(matches[2]) < 2 or tonumber(matches[2]) > 10 then
				return "_Wrong number, range is_ *[2-10]*"
      end
			local time_max = matches[2]
			data[tostring(msg.to.id)]['settings']['time_check'] = time_max
			save_data(_config.moderation.data, data)
    return "_Group_ *flood* _check time has been set to :_ *[ "..matches[2].." ]*"
       end
		if matches[1]:lower() == 'clean' and is_owner(msg) then
			if matches[2] == 'mods' then
				if next(data[tostring(msg.to.id)]['mods']) == nil then
					return "_No_ *moderators* _in this group_"
            end
				for k,v in pairs(data[tostring(msg.to.id)]['mods']) do
					data[tostring(msg.to.id)]['mods'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				return "_All_ *moderators* _has been demoted_"
         end
			if matches[2] == 'filterlist' then
				if next(data[tostring(msg.to.id)]['filterlist']) == nil then
					return "*Filtered words list* _is empty_"
				end
				for k,v in pairs(data[tostring(msg.to.id)]['filterlist']) do
					data[tostring(msg.to.id)]['filterlist'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				return "*Filtered words list* _has been cleaned_"
			end
			if matches[2] == 'rules' then
				if not data[tostring(msg.to.id)]['rules'] then
					return "_No_ *rules* _available_"
				end
					data[tostring(msg.to.id)]['rules'] = nil
					save_data(_config.moderation.data, data)
				return "*Group rules* _has been cleaned_"
       end
			if matches[2] == 'welcome' then
				if not data[tostring(msg.to.id)]['setwelcome'] then
					return "*Welcome Message not set*"
				end
					data[tostring(msg.to.id)]['setwelcome'] = nil
					save_data(_config.moderation.data, data)
				return "*Welcome message* _has been cleaned_"
       end
			if matches[2] == 'about' then
        if msg.to.type == "group" then
				if not data[tostring(msg.to.id)]['about'] then
					return "_No_ *description* _available_"
				end
					data[tostring(msg.to.id)]['about'] = nil
					save_data(_config.moderation.data, data)
        elseif msg.to.type == "supergroup" then
   setChatDescription(msg.to.id, "")
             end
				return "*Group description* _has been cleaned_"
		   	end
        end
		if matches[1]:lower() == 'clean' and is_admin(msg) then
			if matches[2] == 'owners' then
				if next(data[tostring(msg.to.id)]['owners']) == nil then
					return "_No_ *owners* _in this group_"
				end
				for k,v in pairs(data[tostring(msg.to.id)]['owners']) do
					data[tostring(msg.to.id)]['owners'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				return "_All_ *owners* _has been demoted_"
			end
     end
if matches[1] == "setname" and matches[2] and is_mod(msg) then
local gp_name = matches[2]
setChatTitle(msg.to.id, gp_name)
end
if matches[1] == 'setphoto' and is_mod(msg) then
gpPhotoFile = "./data/photos/group_photo_"..msg.to.id..".jpg"
     if not msg.caption and not msg.reply_to_message then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			return '_Please send the new group_ *photo* _now_'
     elseif not msg.caption and msg.reply_to_message then
if msg.reply_to_message.photo then
if msg.reply_to_message.photo[3] then
fileid = msg.reply_to_message.photo[3].file_id
elseif msg.reply_to_message.photo[2] then
fileid = msg.reply_to_message.photo[2].file_id
   else
fileid = msg.reply_to_message.photo[1].file_id
  end
downloadFile(fileid, gpPhotoFile)
sleep(1)
setChatPhoto(msg.to.id, gpPhotoFile)
    data[tostring(msg.to.id)]['settings']['set_photo'] = gpPhotoFile
    save_data(_config.moderation.data, data)
    end
  return "*Photo Saved*"
     elseif msg.caption and not msg.reply_to_message then
if msg.photo then
if msg.photo[3] then
fileid = msg.photo[3].file_id
elseif msg.photo[2] then
fileid = msg.photo[2].file_id
   else
fileid = msg.photo[1].file_id
  end
downloadFile(fileid, gpPhotoFile)
sleep(1)
setChatPhoto(msg.to.id, gpPhotoFile)
    data[tostring(msg.to.id)]['settings']['set_photo'] = gpPhotoFile
    save_data(_config.moderation.data, data)
    end
  return "*Photo Saved*"
		end
  end
if matches[1] == "delphoto" and is_mod(msg) then
deleteChatPhoto(msg.to.id)
  return "*Group Photo* _has been_ *removed*"
end
  if matches[1] == "setabout" and matches[2] and is_mod(msg) then
     if msg.to.type == "supergroup" then
   setChatDescription(msg.to.id, matches[2])
    elseif msg.to.type == "group" then
    data[tostring(msg.to.id)]['about'] = matches[2]
	  save_data(_config.moderation.data, data)
     end
    return "*Group description* _has been set_"
  end
  if matches[1] == "about" and msg.to.type == "group" then
 if not data[tostring(msg.to.id)]['about'] then
     about = "_No_ *description* _available_"
        else
     about = "*Group Description :*\n"..data[tostring(chat)]['about']
      end
    return about
  end
if matches[1] == "config" and is_owner(msg) then
local status = getChatAdministrators(msg.to.id).result
for k,v in pairs(status) do
if v.status == "administrator" then
if v.user.username then
admins_id = v.user.id
user_name = '@'..check_markdown(v.user.username)
else
user_name = escape_markdown(v.user.first_name)
      end
  data[tostring(msg.to.id)]['mods'][tostring(admins_id)] = user_name
    save_data(_config.moderation.data, data)
    end
  end
    return "`AƖƖ gяσυρ αɗмιηѕ нαѕ вєєη ρяσмσтєɗ αηɗ gяσυρ cяєαтσя ιѕ ησω gяσυρ σωηєя`👤😎"
end
if matches[1] == 'rmsg' and matches[2] and is_owner(msg) then
local num = matches[2]
if 200 < tonumber(num) then
return "*Ɯяσηg Ɲυмвєя !*\n*Ɲυмвєя Sнσυℓ∂ вє Ɓєтωєєη* 1-200 *Ɲυмвєяѕ !*"
end
print(num)
for i=1,tonumber(num) do
del_msg(msg.to.id,msg.id - i)
end
end
--------------------- Welcome -----------------------
	if matches[1] == "welcome" and is_mod(msg) then
		if matches[2] == "enable" then
			welcome = data[tostring(msg.to.id)]['settings']['welcome']
			if welcome == "yes" then
				return "_Group_ *welcome* _is already enabled_"
			else
		data[tostring(msg.to.id)]['settings']['welcome'] = "yes"
	    save_data(_config.moderation.data, data)
				return "_Group_ *welcome* _has been enabled_"
			end
		end
		
		if matches[2] == "disable" then
			welcome = data[tostring(msg.to.id)]['settings']['welcome']
			if welcome == "no" then
				return "_Group_ *Welcome* _is already disabled_"
			else
		data[tostring(msg.to.id)]['settings']['welcome'] = "no"
	    save_data(_config.moderation.data, data)
				return "_Group_ *welcome* _has been disabled_"
			end
		end
	end
	if matches[1] == "setwelcome" and matches[2] and is_mod(msg) then
		data[tostring(msg.to.id)]['setwelcome'] = matches[2]
	    save_data(_config.moderation.data, data)
		return "_Welcome Message Has Been Set To :_\n*"..matches[2].."*\n\n*You can use :*\n_{gpname} Group Name_\n_{rules} ➣ Show Group Rules_\n_{time} ➣ Show time english _\n_{date} ➣ Show date english _\n_{timefa} ➣ Show time persian _\n_{datefa} ➣ show date persian _\n_{name} ➣ New Member First Name_\n_{username} ➣ New Member Username_"
	end
-------------Help-------------
if matches[1] == "help" and is_mod(msg) then
    local text = [[
*MaTaDoR Api Bot Commands:*

*/add* 
_Add Group To Database_
➖➖➖➖➖➖
*/rem*
 _Remove Group From Database_
➖➖➖➖➖➖
*/setowner* `[username|id|reply]` 
_Set Group Owner(Multi Owner)_
➖➖➖➖➖➖
*/remowner* `[username|id|reply]` 
 _Remove User From Owner List_
➖➖➖➖➖➖
*/promote* `[username|id|reply]` 
_Promote User To Group Admin_
➖➖➖➖➖➖
*/demote* `[username|id|reply]` 
_Demote User From Group Admins List_
➖➖➖➖➖➖
*/setflood* `[1-50]`
_Set Flooding Number_
➖➖➖➖➖➖
*/setchar* `[Number]`
_Set Flooding Characters_
➖➖➖➖➖➖
*/setfloodtime* `[1-10]`
_Set Flooding Time_
➖➖➖➖➖➖
*/silent* `[username|id|reply]` 
_Silent User From Group_
➖➖➖➖➖➖
*/unsilent* `[username|id|reply]` 
_Unsilent User From Group_
➖➖➖➖➖➖
*/kick* `[username|id|reply]` 
_Kick User From Group_
➖➖➖➖➖➖
*/ban* `[username|id|reply]` 
_Ban User From Group_
➖➖➖➖➖➖
*/unban* `[username|id|reply]` 
_UnBan User From Group_
➖➖➖➖➖➖
*/whitelist* [+-] `[username|id|reply]` 
_Add Or Remove User From White List_
➖➖➖➖➖➖
*/res* `[username]`
_Show User ID_
➖➖➖➖➖➖
*/id* `[reply | username]`
_Show User ID_
➖➖➖➖➖➖
*/whois* `[id]`
_Show User's Username And Name_
➖➖➖➖➖➖
*/lock* `[link | join | tag | edit | arabic | webpage | bots | spam | flood | markdown | mention | pin | cmds | gif | photo | document | sticker | keyboard | video | text | forward | location | audio | voice | contact | all]`
_If This Actions Lock, Bot Check Actions And Delete Them_
➖➖➖➖➖➖
*/unlock* `[link | join | tag | edit | arabic | webpage | bots | spam | flood | markdown | mention | pin | cmds | gif | photo | document | sticker | keyboard | video | text | forward | location | audio | voice | contact | all]`
_If This Actions Unlock, Bot Not Delete Them_
➖➖➖➖➖➖
*/set*`[rules | name | photo[also reply] | link | about | welcome]`
_Bot Set Them_
➖➖➖➖➖➖
*/clean* `[bans | mods | bots | rules | about | silentlist | filtelist | welcome]`   
_Bot Clean Them_
➖➖➖➖➖➖
*/delphoto*
_Delete Group Photo_
➖➖➖➖➖➖
*/filter* `[word]`
_Word filter_
➖➖➖➖➖➖
*/unfilter* `[word]`
_Word unfilter_
➖➖➖➖➖➖
*/pin* `[reply]`
_Pin Your Message_
➖➖➖➖➖➖
*/unpin* 
_Unpin Pinned Message_
➖➖➖➖➖➖
*/welcome enable/disable*
_Enable Or Disable Group Welcome_
➖➖➖➖➖➖
*/settings*
_Show Group Settings_
➖➖➖➖➖➖
*/silentlist*
_Show Silented Users List_
➖➖➖➖➖➖
*/filterlist*
_Show Filtered Words List_
➖➖➖➖➖➖
*/banlist*
_Show Banned Users List_
➖➖➖➖➖➖
*/ownerlist*
_Show Group Owners List_ 
➖➖➖➖➖➖
*/modlist* 
_Show Group Moderators List_
➖➖➖➖➖➖
*/whitelist* 
_Show Group White List Users_
➖➖➖➖➖➖
*/rules*
_Show Group Rules_
➖➖➖➖➖➖
*/about*
_Show Group Description_
➖➖➖➖➖➖
*/id*
_Show Your And Chat ID_
➖➖➖➖➖➖
*/gpinfo*
_Show Group Information_
➖➖➖➖➖➖
*/link*
_Show Group Link_
➖➖➖➖➖➖
*/setwelcome [text]*
_set Welcome Message_
➖➖➖➖➖➖
*/helptools*
_Show Tools Help_


_You Can Use_ *[!/]* _To Run The Commands_
_This Help List Only For_ *Moderators/Owners!*
_Its Means, Only Group_ *Moderators/Owners* _Can Use It!_

*Good luck ;)*]]
    return text
  end
if matches[1] == "helptools" and is_admin(msg) then
    local text = [[

_Sudoer And Admins MaTaDoR Api Bot Help :_

*/visudo* `[username|id|reply]`
_Add Sudo_
➖➖➖➖➖➖
*/desudo* `[username|id|reply]`
_Demote Sudo_
➖➖➖➖➖➖
*/sudolist *
_Sudo(s) list_
➖➖➖➖➖➖
*/adminprom* `[username|id|reply]`
_Add admin for bot_
➖➖➖➖➖➖
*/admindem* `[username|id|reply]`
_Demote bot admin_
➖➖➖➖➖➖
*/adminlist *
_Admin(s) list_
➖➖➖➖➖➖
*/leave *
_Leave current group_
➖➖➖➖➖➖
*/autoleave* `[disable/enable]`
_Automatically leaves group_
➖➖➖➖➖➖
*/chats*
_List of added groups_
➖➖➖➖➖➖
*/rem* `[id]`
_Remove a group from Database_
➖➖➖➖➖➖
*/broadcast* `[text]`
_Send message to all added groups_
➖➖➖➖➖➖
*/bc* `[text] [GroupID]`
_Send message to a specific group_
➖➖➖➖➖➖
*/sendfile* `[folder] [file]`
_Send file from folder_
➖➖➖➖➖➖
*/sendplug* `[plug]`
_Send plugin_
➖➖➖➖➖➖
*/save* `[plugin name] [reply]`
_Save plugin by reply_
➖➖➖➖➖➖
*/savefile* `[address/filename] [reply]`
_Save File by reply to specific folder_
➖➖➖➖➖➖
*/config*
_Set Owner and Admin Group_

_You can use_ *[!/]* _at the beginning of commands._

`This help is only for sudoers/bot admins.`
 
*This means only the sudoers and its bot admins can use mentioned commands.*]]
    return text
  end
if matches[1] == 'kick' and is_mod(msg) then
   if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't kick my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't kick mods, owners, bot admins"
    else
	kick_user(msg.reply.id, msg.to.id) 
 end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
if tonumber(User.id) == tonumber(our_id) then
   return "I can't kick my self"
    end
if is_mod1(msg.to.id, User.id) then
   return "You can't kick mods, owners, bot admins"
     else
	kick_user(User.id, msg.to.id) 
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
if tonumber(matches[2]) == tonumber(our_id) then
   return "I can't kick my self"
    end
if is_mod1(msg.to.id, tonumber(matches[2])) then
   return "You can't kick mods, owners, bot admins"
   else
     kick_user(tonumber(matches[2]), msg.to.id) 
        end
     end
   end 

---------------Ban-------------------      
                   
if matches[1] == 'ban' and is_mod(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't ban my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't ban mods, owners, bot admins"
    end
  if is_banned(msg.reply.id, msg.to.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is already banned"
    else
ban_user(("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)), msg.reply.id, msg.to.id)
     kick_user(msg.reply.id, msg.to.id) 
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." has been banned"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
if tonumber(User.id) == tonumber(our_id) then
   return "I can't ban my self"
    end
if is_mod1(msg.to.id, User.id) then
   return "You can't ban mods, owners, bot admins"
    end
  if is_banned(User.id, msg.to.id) then
    return "User "..check_markdown(User.username).." "..User.id.." is already banned"
    else
   ban_user(check_markdown(User.username), User.id, msg.to.id)
     kick_user(User.id, msg.to.id) 
    return "User "..check_markdown(User.username).." "..User.id.." has been banned"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
if tonumber(matches[2]) == tonumber(our_id) then
   return "I can't ban my self"
    end
if is_mod1(msg.to.id, tonumber(matches[2])) then
   return "You can't ban mods, owners, bot admins"
    end
  if is_banned(tonumber(matches[2]), msg.to.id) then
    return "User "..matches[2].." is already banned"
    else
   ban_user('', matches[2], msg.to.id)
     kick_user(tonumber(matches[2]), msg.to.id)
    return "User "..matches[2].." has been banned"
        end
     end
   end

---------------Unban-------------------                         

if matches[1] == 'unban' and is_mod(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't ban mods, owners, bot admins"
    end
  if not is_banned(msg.reply.id, msg.to.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is already banned"
    else
unban_user(msg.reply.id, msg.to.id)
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." has been unbanned"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
  if not is_banned(User.id, msg.to.id) then
    return "User @"..check_markdown(User.username).." "..User.id.." is not banned"
    else
   unban_user(User.id, msg.to.id)
    return "User @"..check_markdown(User.username).." "..User.id.." has been unbanned"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
  if not is_banned(tonumber(matches[2]), msg.to.id) then
    return "User "..matches[2].." is not banned"
    else
   unban_user(matches[2], msg.to.id)
    return "User "..matches[2].." has been unbanned"
        end
     end
   end

------------------------Silent-------------------------------------

if matches[1] == 'silent' and is_mod(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't silent mods, owners, bot admins"
    end
  if is_silent_user(msg.reply.id, msg.to.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is already silent"
    else
silent_user(("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)), msg.reply.id, msg.to.id)
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." added to silent users list"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
if tonumber(User.id) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, User.id) then
   return "You can't silent mods, owners, bot admins"
    end
  if is_silent_user(User.id, msg.to.id) then
    return "User @"..check_markdown(User.username).." "..User.id.." is already silent"
    else
   silent_user("@"..check_markdown(User.username), User.id, msg.to.id)
    return "User @"..check_markdown(User.username).." "..User.id.." added to silent users list"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
if tonumber(matches[2]) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, tonumber(matches[2])) then
   return "You can't silent mods, owners, bot admins"
    end
  if is_silent_user(tonumber(matches[2]), msg.to.id) then
    return "User "..matches[2].." is already silent"
    else
   ban_user('', matches[2], msg.to.id)
     kick_user(tonumber(matches[2]), msg.to.id)
    return "User "..matches[2].." added to silent users list"
        end
     end
   end

------------------------Unsilent----------------------------
if matches[1] == 'unsilent' and is_mod(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't ban mods, owners, bot admins"
    end
  if not is_silent_user(msg.reply.id, msg.to.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is not silent"
    else
unsilent_user(msg.reply.id, msg.to.id)
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." removed from silent users list"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
  if not is_silent_user(User.id, msg.to.id) then
    return "User @"..check_markdown(User.username).." "..User.id.." is not silent"
    else
   unsilent_user(User.id, msg.to.id)
    return "User @"..check_markdown(User.username).." "..User.id.." removed from silent users list"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
  if not is_silent_user(tonumber(matches[2]), msg.to.id) then
    return "User "..matches[2].." is not silent"
    else
   unsilent_user(matches[2], msg.to.id)
    return "User "..matches[2].." removed from silent users list"
        end
     end
   end
-------------------------Banall-------------------------------------
                   
if matches[1] == 'banall' and is_admin(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't global ban my self"
    end
if is_admin1(msg.reply.id) then
   return "You can't global ban other admins"
    end
  if is_gbanned(msg.reply.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is already globally banned"
    else
banall_user(("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)), msg.reply.id)
     kick_user(msg.reply.id, msg.to.id) 
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." has been globally banned"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
if tonumber(User.id) == tonumber(our_id) then
   return "I can't global ban my self"
    end
if is_admin1(User.id) then
   return "You can't global ban other admins"
    end
  if is_gbanned(User.id) then
    return "User @"..check_markdown(User.username).." "..User.id.." is already globally banned"
    else
   banall_user("@"..check_markdown(User.username), User.id)
     kick_user(User.id, msg.to.id) 
    return "User @"..check_markdown(User.username).." "..User.id.." has been globally banned"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
if is_admin1(tonumber(matches[2])) then
if tonumber(matches[2]) == tonumber(our_id) then
   return "I can't global ban my self"
    end
   return "You can't global ban other admins"
    end
  if is_gbanned(tonumber(matches[2])) then
    return "User "..matches[2].." is already globally banned"
    else
   banall_user('', matches[2])
     kick_user(tonumber(matches[2]), msg.to.id)
    return "User "..matches[2].." has been globally banned"
        end
     end
   end
--------------------------Unbanall-------------------------

if matches[1] == 'unbanall' and is_admin(msg) then
if msg.reply_id then
if tonumber(msg.reply.id) == tonumber(our_id) then
   return "I can't silent my self"
    end
if is_mod1(msg.to.id, msg.reply.id) then
   return "You can't ban mods, owners, bot admins"
    end
  if not is_gbanned(msg.reply.id) then
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." is already globally banned"
    else
unbanall_user(msg.reply.id)
    return "User "..("@"..check_markdown(msg.reply.username) or escape_markdown(msg.reply.print_name)).." "..msg.reply.id.." has been globally unbanned"
  end
	elseif matches[2] and not string.match(matches[2], '^%d+$') then
   if not resolve_username(matches[2]).result then
   return "`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣"
    end
	local User = resolve_username(matches[2]).information
  if not is_gbanned(User.id) then
    return "User @"..check_markdown(User.username).." "..User.id.." is not globally banned"
    else
   unbanall_user(User.id)
    return "User @"..check_markdown(User.username).." "..User.id.." has been globally unbanned"
  end
   elseif matches[2] and string.match(matches[2], '^%d+$') then
  if not is_gbanned(tonumber(matches[2])) then
    return "User "..matches[2].." is not globally banned"
    else
   unbanall_user(matches[2])
    return "User "..matches[2].." has been globally unbanned"
        end
     end
   end
   -----------------------------------LIST---------------------------
   if matches[1] == 'banlist' and is_mod(msg) then
   return banned_list(msg.to.id)
   end
   if matches[1] == 'silentlist' and is_mod(msg) then
   return silent_users_list(msg.to.id)
   end
   if matches[1] == 'gbanlist' and is_admin(msg) then
   return gbanned_list(msg)
   end
   ---------------------------clean---------------------------
   if matches[1] == 'clean' and is_mod(msg) then
	if matches[2] == 'banlist' then
		if next(data[tostring(msg.to.id)]['banned']) == nil then
			return "_No_ *banned* _users in this group_"
		end
		for k,v in pairs(data[tostring(msg.to.id)]['banned']) do
			data[tostring(msg.to.id)]['banned'][tostring(k)] = nil
			save_data(_config.moderation.data, data)
		end
		return "_All_ *banned* _users has been unbanned_"
	end
	if matches[2] == 'silentlist' then
		if next(data[tostring(msg.to.id)]['is_silent_users']) == nil then
			return "_No_ *silent* _users in this group_"
		end
		for k,v in pairs(data[tostring(msg.to.id)]['is_silent_users']) do
			data[tostring(msg.to.id)]['is_silent_users'][tostring(k)] = nil
			save_data(_config.moderation.data, data)
		end
		return "*Silent list* _has been cleaned_"
	end
	if matches[2] == 'gbans' and is_admin(msg) then
		if next(data['gban_users']) == nil then
			return "_No_ *globally banned* _users available_"
		end
		for k,v in pairs(data['gban_users']) do
			data['gban_users'][tostring(k)] = nil
			save_data(_config.moderation.data, data)
		end
		return "_All_ *globally banned* _users has been unbanned_"
	end
   end
if matches[1] == "sudolist" and is_sudo(msg) then
    return sudolist(msg)
   end
  if tonumber(msg.from.id) == tonumber(sudo_id) then
   if matches[1] == "visudo" then
   if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if already_sudo(tonumber(msg.reply.id)) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ αℓяєα∂у` *sudoer*"
    else
          table.insert(_config.sudo_users, tonumber(msg.reply.id)) 
      print(msg.reply.id..' added to sudo users') 
     save_config() 
     reload_plugins(true) 
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ ησω` *sudoer*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
   if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
   if already_sudo(tonumber(matches[2])) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ αℓяєα∂у` *sudoer*"
    else
           table.insert(_config.sudo_users, tonumber(matches[2])) 
      print(matches[2]..' added to sudo users') 
     save_config() 
     reload_plugins(true) 
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ ησω` *sudoer*"
   end
   elseif matches[2] and not matches[2]:match('^%d+') then
   if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2])
   if already_sudo(tonumber(status.information.id)) then
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` `ιѕ αℓяєα∂у` *sudoer*"
    else
          table.insert(_config.sudo_users, tonumber(status.information.id)) 
      print(status.information.id..' added to sudo users') 
     save_config() 
     reload_plugins(true) 
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` `ιѕ ησω` *sudoer*"
     end
  end
end
   if matches[1] == "desudo" then
      if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if not already_sudo(tonumber(msg.reply.id)) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσт` *sudoer*"
    else
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(msg.reply.id)))
		save_config()
     reload_plugins(true) 
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσ Lσηgєя` *sudoer*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
   if not already_sudo(tonumber(matches[2])) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσт` *sudoer*"
    else
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(matches[2])))
		save_config()
     reload_plugins(true) 
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσ Lσηgєя` *sudoer*"
      end
   elseif matches[2] and not matches[2]:match('^%d+') then
   if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2])
   if not already_sudo(tonumber(status.information.id)) then
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` `ιѕ Ɲσт` *sudoer*"
    else
          table.remove(_config.sudo_users, getindex( _config.sudo_users, tonumber(status.information.id)))
		save_config()
     reload_plugins(true) 
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` `ιѕ Ɲσ Lσηgєя` *sudoer*"
          end
      end
   end
end
  if is_sudo(msg) then
   if matches[1] == "adminprom" then
   if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if already_admin(tonumber(msg.reply.id)) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _is already an_ *admin*"
    else
	    table.insert(_config.admins, {tonumber(msg.reply.id), username})
		save_config() 
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _has been promoted as_ *admin*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
   if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
   if already_admin(tonumber(matches[2])) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` _is already an_ *admin*"
    else
	    table.insert(_config.admins, {tonumber(matches[2]), user_name})
		save_config()
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` _has been promoted as_ *admin*"
   end
   elseif matches[2] and not matches[2]:match('^%d+') then
   if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2])
   if already_admin(tonumber(status.information.id)) then
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` _is already an_ *admin*"
    else
	    table.insert(_config.admins, {tonumber(status.information.id), check_markdown(status.information.username)})
		save_config()
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` _has been promoted as_ *admin*"
     end
  end
end
   if matches[1] == "admindem" then
      if not matches[2] and msg.reply_to_message then
	if msg.reply.username then
	username = "@"..check_markdown(msg.reply.username)
    else
	username = escape_markdown(msg.reply.print_name)
    end
   if not already_admin(tonumber(msg.reply.id)) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` `ιѕ Ɲσт` *admin*"
    else
	local nameid = index_function(tonumber(msg.reply.id))
		table.remove(_config.admins, nameid)
		save_config()
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..msg.reply.id.."]` _has been demoted from_ *admin*"
      end
	  elseif matches[2] and matches[2]:match('^%d+') then
  if not getUser(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
	  local user_name = '@'..check_markdown(getUser(matches[2]).information.username)
	  if not user_name then
		user_name = escape_markdown(getUser(matches[2]).information.first_name)
	  end
   if not already_admin(tonumber(matches[2])) then
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` `ιѕ Ɲσт` *admin*"
    else
	local nameid = index_function(tonumber(matches[2]))
		table.remove(_config.admins, nameid)
		save_config()
    return "✴️》*Uѕєя :* ["..username.."]\n🆔》*IƊ :* `["..matches[2].."]` _has been demoted from_ *admin*"
      end
   elseif matches[2] and not matches[2]:match('^%d+') then
   if not resolve_username(matches[2]).result then
   return "*`Uѕєя Ɲσт Ƒσυηɗ`⚠️👣*"
    end
   local status = resolve_username(matches[2])
   if not already_admin(tonumber(status.information.id)) then
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` `ιѕ Ɲσт` *admin*"
    else
	local nameid = index_function(tonumber(status.information.id))
		table.remove(_config.admins, nameid)
		save_config()
    return "_User_ @"..check_markdown(status.information.username).." `"..status.information.id.."` _has been demoted from_ *admin*"
          end
      end
   end
end
  if is_sudo(msg) then
	if matches[1]:lower() == "sendfile" and matches[2] and matches[3] then
		local send_file = "./"..matches[2].."/"..matches[3]
		sendDocument(msg.to.id, send_file, msg.id, "@MaTaDoRTeaM")
	end
	if matches[1]:lower() == "sendplug" and matches[2] then
	    local plug = "./plugins/"..matches[2]..".lua"
		sendDocument(msg.to.id, plug, msg.id, "@MaTaDoRTeaM")
    end
	if matches[1]:lower() == "savefile" and matches[2]then
	local fn = matches[2]:gsub('(.*)/', '')
	local pt = matches[2]:gsub('/'..fn..'$', '')
if msg.reply_to_message then
if msg.reply_to_message.photo then
if msg.reply_to_message.photo[3] then
fileid = msg.reply_to_message.photo[3].file_id
elseif msg.reply_to_message.photo[2] then
fileid = msg.reply_to_message.photo[2].file_id
   else
fileid = msg.reply_to_message.photo[1].file_id
  end
elseif msg.reply_to_message.sticker then
fileid = msg.reply_to_message.sticker.file_id
elseif msg.reply_to_message.voice then
fileid = msg.reply_to_message.voice.file_id
elseif msg.reply_to_message.video then
fileid = msg.reply_to_message.video.file_id
elseif msg.reply_to_message.document then
fileid = msg.reply_to_message.document.file_id
end
downloadFile(fileid, "./"..pt.."/"..fn)
return "*File* `"..fn.."` _has been saved in_ *"..pt.."*"
  end
end
	if matches[1]:lower() == "save" and matches[2] then
if msg.reply_to_message then
if msg.reply_to_message.document then
fileid = msg.reply_to_message.document.file_id
filename = msg.reply_to_message.document.file_name
if tostring(filename):match(".lua") then
downloadFile(fileid, "./plugins/"..matches[2]..".lua")
return "*Plugin* `"..matches[2]..".lua` _has been saved_"
        end
     end
  end
end
if matches[1] == 'adminlist' and is_admin(msg) then
return adminlist(msg)
    end
if matches[1] == 'chats' and is_admin(msg) then
return chat_list(msg)
    end
		if matches[1] == 'rem' and matches[2] and is_admin(msg) then
    local data = load_data(_config.moderation.data)
			-- Group configuration removal
			data[tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
			local groups = 'groups'
			if not data[tostring(groups)] then
				data[tostring(groups)] = nil
				save_data(_config.moderation.data, data)
			end
			data[tostring(groups)][tostring(matches[2])] = nil
			save_data(_config.moderation.data, data)
	   send_msg(matches[2], "Group has been removed by admin command", nil, 'md')
    return '_Group_ *'..matches[2]..'* _removed_'
		end
     if matches[1] == 'leave' and is_admin(msg) then
  leave_group(msg.to.id)
   end
     if matches[1] == 'bc' and is_admin(msg) and matches[2] and matches[3] then
		local text = matches[2]
send_msg(matches[3], text)	end
 end
if matches[1] == 'broadcast' and is_sudo(msg) then		
  local data = load_data(_config.moderation.data)		
  local bc = matches[2]			
  for k,v in pairs(data) do				
send_msg(k, bc)			
  end	
end
if matches[1] == 'autoleave' and is_admin(msg) then
    local hash = 'AutoLeaveBot'
     if matches[2] == 'enable' then
    redis:del(hash)
   return 'Auto leave has been enabled'
     elseif matches[2] == 'disable' then
    redis:set(hash, true)
   return 'Auto leave has been disabled'
      elseif matches[2] == 'status' then
      if not redis:get(hash) then
   return 'Auto leave is enable'
       else
   return 'Auto leave is disable'
         end
      end
   end
   if is_sudo(msg) then
  if matches[1]:lower() == 'plist' then
    return list_all_plugins()
  end
end
   if matches[1] == 'pl' then
  if matches[2] == '+' and matches[4] == 'chat' then
      if is_momod(msg) then
    local receiver = msg.to.id
    local plugin = matches[3]
    print("enable "..plugin..' on this chat')
    return reenable_plugin_on_chat(receiver, plugin)
  end
    end
  if matches[2] == '+' and is_sudo(msg) then
      if is_mod(msg) then
    local plugin_name = matches[3]
    print("enable: "..matches[3])
    return enable_plugin(plugin_name)
  end
    end
  if matches[2] == '-' and matches[4] == 'chat' then
      if is_mod(msg) then
    local plugin = matches[3]
    local receiver = msg.to.id
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(receiver, plugin)
  end
    end
  if matches[2] == '-' and is_sudo(msg) then
    if matches[3] == 'plugins' then
    	return 'This plugin can\'t be disabled'
    end
    print("disable: "..matches[3])
    return disable_plugin(matches[3])
  end
  if matches[2] == '*' and is_sudo(msg) then
    return reload_plugins(true)
  end
end
  if matches[1]:lower() == 'reload' and is_sudo(msg) then
    return reload_plugins(true)
  end
----------------End Msg Matches--------------
end
local function pre_processs(msg)
local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] and data[tostring(msg.to.id)]['settings'] and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_mod(msg) then
gpPhotoFile = "./data/photos/group_photo_"..msg.to.id..".jpg"
    if msg.photo then
  if msg.photo[3] then
fileid = msg.photo[3].file_id
elseif msg.photo[2] then
fileid = msg.photo[2].file_id
   else
fileid = msg.photo[1].file_id
  end
downloadFile(fileid, gpPhotoFile)
sleep(1)
setChatPhoto(msg.to.id, gpPhotoFile)
    data[tostring(msg.to.id)]['settings']['set_photo'] = gpPhotoFile
    save_data(_config.moderation.data, data)
     end
		send_msg(msg.to.id, "*Photo Saved*", msg.id, "md")
  end
	local url , res = http.request('http://api.beyond-dev.ir/time/')
          if res ~= 200 then return "No connection" end
      local jdat = json:decode(url)
		local data = load_data(_config.moderation.data)
 if msg.newuser then
	if data[tostring(msg.to.id)] and data[tostring(msg.to.id)]['settings'] then
		wlc = data[tostring(msg.to.id)]['settings']['welcome']
		if wlc == "yes" and tonumber(msg.newuser.id) ~= tonumber(bot.id) then
    if data[tostring(msg.to.id)]['setwelcome'] then
     welcome = data[tostring(msg.to.id)]['setwelcome']
      else
     welcome = "*Welcome Dude*"
     end
 if data[tostring(msg.to.id)]['rules'] then
rules = data[tostring(msg.to.id)]['rules']
else
     rules = "ℹ️ The Default Rules :\n1⃣ No Flood.\n2⃣ No Spam.\n3⃣ No Advertising.\n4⃣ Try to stay on topic.\n5⃣ Forbidden any racist, sexual, homophobic or gore content.\n➡️ Repeated failure to comply with these rules will cause ban.\n@MaTaDoRTeaM"
end
if msg.newuser.username then
user_name = "@"..check_markdown(msg.newuser.username)
else
user_name = ""
end
		welcome = welcome:gsub("{rules}", rules)
		welcome = welcome:gsub("{name}", escape_markdown(msg.newuser.print_name))
		welcome = welcome:gsub("{username}", user_name)
		welcome = welcome:gsub("{time}", jdat.ENtime)
		welcome = welcome:gsub("{date}", jdat.ENdate)
		welcome = welcome:gsub("{timefa}", jdat.FAtime)
		welcome = welcome:gsub("{datefa}", jdat.FAdate)
		welcome = welcome:gsub("{gpname}", msg.to.title)
		send_msg(msg.to.id, welcome, msg.id, "md")
        end
		end
	end
 if msg.newuser then
 if msg.newuser.id == bot.id and is_admin(msg) then
 local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
   modadd(msg)
   send_msg(msg.to.id, '#》 *Ɠяσυρ нαѕ вєєη αɗɗєɗ* ✅🤖\n\n*Ɠяσυρ Ɲαмє :*'..msg.to.title..'\n*OяɗєяƁу :* @'..check_markdown(msg.from.username or '')..'*|*`'..msg.from.id..'`\n*〰〰〰〰〰〰〰〰*\n💠 `Group now to list the groups the robot was added`', msg.id, "md")
      end
    end
  end
end
return {
  patterns = {
    "^[!/](help)$",
	"^[!/](ping)$",
    "^[!/](add)$",
    "^[!/](rem)$",
    "^[!/](config)$",
    "^[!/](setowner)$",
    "^[!/](remowner)$",
    "^[!/](setowner) (.*)$",
    "^[!/](remowner) (.*)$",
    "^[!/](promote)$",
    "^[!/](demote)$",
    "^[!/](promote) (.*)$",
	"^[!/](demote) (.*)$",
	"^[!/](whitelist) ([+-])$",
	"^[!/](whitelist) ([+-]) (.*)$",
	"^[!/](whitelist)$",
	"^[!/](lock) (.*)$",
	"^[!/](unlock) (.*)$",
	"^[!/](mute) (.*)$",
	"^[!/](unmute) (.*)$",
	"^[!/](settings)$",
	"^[!/](mutelist)$",
	"^[!/](filter) (.*)$",
	"^[!/](unfilter) (.*)$",
    "^[!/](filterlist)$",
    "^[!/](ownerlist)$",
    "^[!/](modlist)$",
    "^[!/](del)$",
	"^[!/](setrules) (.*)$",
    "^[!/](rules)$",
    "^[!/](setlink)$",
    "^[!/](link)$",
	"^[!/](newlink)$",
    "^[!/](setphoto)$",
    "^[!/](delphoto)$",
    "^[!/](id)$",
    "^[!/](id) (.*)$",
	"^[!/](res) (.*)$",
	"^[!/](clean) (.*)$",
	"^[!/](setname) (.*)$",
	"^[!/](welcome) (.*)$",
	"^[!/](setwelcome) (.*)$",
	"^[!/](pin)$",
    "^[!/](unpin)$",
    "^[!/](about)$",
	"^[!/](setabout) (.*)$",
    "^[!/](setchar) (%d+)$",
    "^[!/](setflood) (%d+)$",
    "^[!/](setfloodtime) (%d+)$",
    "^[!/](whois) (.*)$",
    "^[!/](rmsg) (%d+)$",
	"^[!/](matador)$",
	"^[!/](ban) (.*)$",
    "^[!/](ban)$",
    "^[!/](unban) (.*)$",
    "^[!/](unban)$",
    "^[!/](kick) (.*)$",
    "^[!/](kick)$",
    "^[!/](banall) (.*)$",
    "^[!/](banall)$",
    "^[!/](unbanall) (.*)$",
    "^[!/](unbanall)$",
    "^[!/](unsilent) (.*)$",
    "^[!/](unsilent)$",
    "^[!/](silent) (.*)$",
    "^[!/](silent)$",
    "^[!/](silentlist)$",
    "^[!/](banlist)$",
    "^[!/](gbanlist)$",
    "^[!/](clean) (.*)$", 
    "^[!/](helptools)$",
    "^[!/](visudo)$",
    "^[!/](desudo)$",
    "^[!/](visudo) (.*)$",
    "^[!/](desudo) (.*)$",
    "^[!/](sudolist)$",
    "^[!/](adminprom)$",
    "^[!/](admindem)$",
    "^[!/](adminprom) (.*)$",
    "^[!/](admindem) (.*)$",
    "^[!/](adminlist)$",
    "^[!/](chats)$",
    "^[!/](sendfile) (.*) (.*)$",
    "^[!/](savefile) (.*)$",
    "^[!/](bc) (.*) (-%d+)$",
    "^[!/](broadcast) (.*)$",
    "^[!/](sendplug) (.*)$",
    "^[!/](save) (.*)$",
    "^[!/](leave)$",
    "^[!/](autoleave) (.*)$",
    "^[!/](rem) (-%d+)$",
    "^[!/](plist)$",
    "^[!/](pl) (+) ([%w_%.%-]+)$",
    "^[!/](pl) (-) ([%w_%.%-]+)$",
    "^[!/](pl) (+) ([%w_%.%-]+) (chat)",
    "^[!/](pl) (-) ([%w_%.%-]+) (chat)",
    "^[!/](pl) (*)$",
    "^[!/](reload)$",
	"^([https?://w]*.?telegram.me/joinchat/%S+)$",
	"^([https?://w]*.?t.me/joinchat/%S+)$"
    },
  run = run,
  pre_process = pre_process,
  pre_processs = pre_processs
}
