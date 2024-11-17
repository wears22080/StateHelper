script_name('StateHelper')
script_authors('Kane')
script_description('Script for employees of state organizations on the Arizona Role Playing Game')
script_version('2.6')
script_properties('work-in-pause')
beta_version = 0

local text_err_and_read = {
	[1] = [[
 �� ��������� ���� SAMPFUNCS.asi � ����� ����, ���������� ����
������� �� ������� �����������.

		��� ������� ��������:
1. �������� ����;
2. ������� �� ������� "����" � �������� �������.
������� �� ������� "����" ���������� "Moonloader" � ������� ������ "����������".
����� ���������� ��������� ����� ��������� ����. �������� ��������.

���� ��� ��� �� �������, �� ����������� � ��������� ���������:
		vk.com/marseloy

���� ���� ��������, ������� ������ ���������� ������. 
]],
	[2] = [[
		  ��������! 
�� ���������� ��������� ������ ����� ��� ������ �������.
� ��������� ����, ������ �������� ��������.
	������ �������������� ������:
		%s

		��� ������� ��������:
1. �������� ����;
2. ������� �� ������� "����" � �������� �������.
������� �� ������� "����" ���������� "Moonloader" � ������� ������ "����������".
����� ���������� ��������� ����� ��������� ����. �������� ��������.

���� ��� ��� �� �������, �� ����������� � ���������:
		vk.com/marseloy

���� ���� ��������, ������� ������ ���������� ������. 
]],
	[3] = {
		'/lib/imgui.lua',
		'/lib/samp/events.lua',
		'/lib/rkeys.lua',
		'/lib/fAwesome5.lua',
		'/lib/crc32ffi.lua',
		'/lib/bitex.lua',
		'/lib/MoonImGui.dll',
		'/lib/matrix3x3.lua'
	},
	[4] = {}
}

for i,v in ipairs(text_err_and_read[3]) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(text_err_and_read[4], v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

--> ����������� ��������� � �������
require 'lib.sampfuncs'
require 'lib.moonloader'
local mem = require 'memory'
local vkeys = require 'vkeys'
local encoding = require 'encoding'

if not doesFileExist(getWorkingDirectory()..'/lib/effil.lua') then
	effil_lib_NOT = true
else
	effil = require 'effil'
	effil_lib_NOT = false
end

if not doesFileExist(getWorkingDirectory()..'/lib/bass.lua') then
	bass_lib_NOT = true
else
	bass = require 'bass'
	bass.BASS_Stop()
	bass.BASS_Start()
	bass_lib_NOT = false
end

encoding.default = 'CP1251'
local u8 = encoding.UTF8
local dlstatus = require('moonloader').download_status
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory()..'/SAMPFUNCS.asi') then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[1], 'StateHelper', 0x00000030 + 0x00010000)
end
if #text_err_and_read[4] > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[2]:format(table.concat(text_err_and_read[4], '\n\t\t')), 'StateHelper', 0x00000030 + 0x00010000)
end
text_err_and_read = nil

local lfs = require('lfs')
local res, hook = pcall(require, 'lib.samp.events')
assert(res, '���������� SAMP Event �� �������')
---------------------------------------------------
local res, imgui = pcall(require, 'imgui')
assert(res, '���������� Imgui �� �������')
---------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, '���������� faIcons �� �������')
---------------------------------------------------
local res, rkeys = pcall(require, 'rkeys')
assert(res, '���������� rkeys �� �������')
vkeys.key_names[vkeys.VK_RBUTTON] = 'RBut'
vkeys.key_names[vkeys.VK_XBUTTON1] = 'XBut1'
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'

--> ���������� �����������
IMG_Record = {}
IMG_Radio = {}
function download_image()
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/�����������/') then
		print('{F54A4A}������. ����������� ����� ��� �����������. {82E28C}�������� ����� ��� �����������...')
		createDirectory(getWorkingDirectory()..'/StateHelper/�����������/')
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/No label.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/Zud78GE.png', getWorkingDirectory()..'/StateHelper/�����������/No label.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/No label.png')
				local texture_im = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/No label.png')
				IMG_Record = {texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im}
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/Background.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/fuPlVzV.png', getWorkingDirectory()..'/StateHelper/�����������/Background.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/Background Black.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/yi98wxe.png', getWorkingDirectory()..'/StateHelper/�����������/Background Black.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background Black.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/Background White.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/CHJ54FR.png', getWorkingDirectory()..'/StateHelper/�����������/Background White.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background White.png')
			end
		end)
	end
	
	local function download_record_label(url_label_record, name_label, i_rec)
		if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png') then
			download_id = downloadUrlToFile(url_label_record, getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					IMG_Record[i_rec] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png')
				end
			end)
		end
	end
	local function download_radio_label(url_label_radio, name_label, i_radio)
		if not doesFileExist(getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png') then
			download_id = downloadUrlToFile(url_label_radio, getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					IMG_Radio[i_radio] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/'..name_label..'.png')
				end
			end)
		end
	end
	
	download_record_label('https://i.imgur.com/F6hxtdC.png', 'Record Dance Label', 1)
	download_record_label('https://imgur.com/lsYixKr.png', 'Record Megamix Label', 2)
	download_record_label('https://imgur.com/lEpOpLy.png', 'Record Party Label', 3)
	download_record_label('https://imgur.com/UWHK1nN.png', 'Record Phonk Label', 4)
	download_record_label('https://imgur.com/GkovIZT.png', 'Record GopFM Label', 5)
	download_record_label('https://imgur.com/ZftaAuK.png', 'Record Ruki Vverh Label', 6)
	download_record_label('https://imgur.com/Q8Jed4R.png', 'Record Dupstep Label', 7)
	download_record_label('https://imgur.com/OeGdMu8.png', 'Record Bighits Label', 8)
	download_record_label('https://imgur.com/xuOZVCU.png', 'Record Organic Label', 9)
	download_record_label('https://imgur.com/SnA1FR8.png', 'Record Russianhits Label', 10)
	
	download_radio_label('https://i.imgur.com/lUk9LZO.png', 'Europa Plus', 1)
	download_radio_label('https://i.imgur.com/sanZtaP.png', 'DFM', 2)
	download_radio_label('https://i.imgur.com/03gAXqE.png', 'Chanson', 3)
	download_radio_label('https://i.imgur.com/lQX0xBv.png', 'Dacha', 4)
	download_radio_label('https://i.imgur.com/VBT9uFN.png', 'Road', 5)
	download_radio_label('https://i.imgur.com/gz22phj.png', 'Mayak', 6)
	download_radio_label('https://i.imgur.com/aAm4wxg.png', 'Nashe', 7)
	download_radio_label('https://i.imgur.com/mCR7zbX.png', 'LoFi Hip-Hop', 8)
	download_radio_label('https://i.imgur.com/VvGBnO8.png', 'Maximum', 9)
	download_radio_label('https://i.imgur.com/NVtDlRE.png', '90s Eurodance', 10)
end
download_image()

--> ���������� �������
installation_success_font = {false, false}
secc_load_font = false
function download_font()
	local link_meduim_font = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/Fonts/SF600.ttf'
	local link_bold_font = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/Fonts/SF800.ttf'
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/Fonts/') then
		print('{F54A4A}������. ����������� ����� ��� �������. {82E28C}�������� ����� ��� �������...')
		createDirectory(getWorkingDirectory()..'/StateHelper/Fonts/')
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf') or not doesFileExist(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf') then
		download_id = downloadUrlToFile(link_meduim_font, getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				installation_success_font[1] = true
				secc_load_font = true
			end
		end)
		download_id = downloadUrlToFile(link_bold_font, getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				installation_success_font[2] = true
				secc_load_font = true
			end
		end)
	else
		installation_success_font = {true, true}
		secc_load_font = true
	end
end
download_font()

--> �������� �������
dirml = getWorkingDirectory()
dirGame = getGameDirectory()
scr = thisScript()
font = renderCreateFont('Trebuchet MS', 14, 5)
fontPD = renderCreateFont('Trebuchet MS', 12, 5)
font_metka = renderCreateFont('Trebuchet MS', 9, 5)
sx, sy = getScreenResolution()

--> ���� imgui � �� �����������
local win = {
	main = imgui.ImBool(false), --> �������
	spur_big = imgui.ImBool(false), --> ������� ���� �����
	icon = imgui.ImBool(false), --> ������
	action_choice = imgui.ImBool(false), --> ������� ��������������
	reminder = imgui.ImBool(false), --> �����������
	notice = imgui.ImBool(false), --> ����������� �������
	music = imgui.ImBool(false), --> ����������� �����
	stat_online = imgui.ImBool(false) --> ����������� �����
}
local select_main_menu = {false, false, false, false, false, false, false, false, false, false, false, false, false} --> ��� �������� ����
local select_basic = {false, false, false, false, false, false, false, false, false, false, false, false} --> ��� ���� ��������
local notice = {} --> �������� ����������� (�����, ���������, ��� - ��������������/�����������/����)

--> ���������� � � �����������
upd = {}
url_upd = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/StateHelper.lua'
upd_status = 0
scr_version = scr.version:gsub('%D','')
scr_version = tonumber(scr_version)

math.randomseed(os.time())

local function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

local function generate_random_cipher(length)
	local cipher = {}
	local chars = {}
	for i = 97, 122 do
		table.insert(chars, string.char(i))
	end
	for i = 48, 57 do
		table.insert(chars, string.char(i))
	end
	shuffle(chars)
	for i = 1, length do
		cipher[i] = chars[i]
	end

	return table.concat(cipher)
end

--> ������������� ����������
local pers = {
	frac = {org = '�������� ��', title = '', rank = 1}
}
org_all_done = {u8'�������� ��', u8'�������� ��', u8'�������� ��', u8'�������� ����������', u8'����� ��������������', u8'�������������', u8'���'}
num_of_the_selected_org = 1
my = {id = 0, nick = 'Nick_Name'}
off_butoon_end = false
error_spawn = false
wind_act_wait = false
edit_key = false
right_mb = false
current_key = {'', {}}
stop_key_move = false
num_give_gov = -1
flies_nick = 'Nick_Name'
sel_big_spur = 1
text_spur = ''
spur_text_size = 2
inp_text_dep = ''
dep_history = {}
id_sobes = ''
sobes_menu = false
pl_sob = {id = 0, nm = 'Nick_Name'}
inp_text_sob = ''
sob_history = {}
sob_info = {
	level = -1,
	legal = -1,
	work = -1,
	narko = -1,
	hp = -1,
	bl = -1,
	lic = -1,
	lico = -1,
	warn = -1,
	writ = -1
}
scroll_sob = 0
reminder_buf = {}
reminder_edit = false
rem_fl_h = imgui.ImFloat(1.0)
rem_fl_m = imgui.ImFloat(1.0)
remove_reminder = 0
rem_text = ''
scene_active = false
col_sc = {}
script_cursor_sc = false
speed = 0.25
preview_sc = false
edit_sc = false
scene_edit_i = false
price_lic = 0
pos_Y_cmd = 35
active_child_cmd = false
POS_Y_CMD_F = -50
bool_rubber_stick = false
rp_gun_all = false
targ_id = 0
lec_buf = {}
select_lec = 0
lec_err_nm = false
lec_err_fact = false
sdvig = 0
sdgiv_bool = false
sdvig_num = 0
session_clean = imgui.ImInt(0)
session_afk = imgui.ImInt(0)
session_all = imgui.ImInt(0)
select_stat = 0
num_give_lic_term = 0
anim_menu_draw = {177, false}
lastTime = os.clock()
anim_menu_cmd = {130, os.clock(), 0.00}
close_stats = true
new_pos_win_size = {0, 0}
size_win = false
new_pos = 0
start_pos = 0
num_give_bank = -1
anim_menu_shpora = {0, os.clock(), false, 0}
update_box = false
time_os_shp = os.clock()
audio_vizual = 0
start_time_mus = os.time()
current_time_mus = start_time_mus
local deltaTime = 0
target_audio_vizual = 0
level_potok = 0
frequency = 0
t_pr = {os.clock(), os.clock()}
kick_afk_buf = 0
close_serv = false
dep_num_text = 0
done_active_dep = false
history_chat = {}
scroll_hchat = false
search = {chat = '', cmd = '', shpora = ''}
start_session = false
change_pos_onstat = false
script_ac = {reset = 0, del = 0}
nickname_dialog = false
nickname_dialog2 = false
time_dialog_nickname = 20
select_ticket = 0
get_scroll_max_help = 2
check_ticket = 100
token_respone = ''
text_godeath = ''
id_player_godeath = '0'
debug_crush_help = 0
ret_check = 0

--> ������� ���������
setting = {
	int = {first_start = true, script = 'Helper', theme = 'White'},
	frac = {org = u8'�������� ��', title = u8'�������', rank = 10},
	nick = '',
	teg = '',
	act_time = '',
	act_r = '',
	sex = u8'�������',
	price = {
		lec = '5000',
		mede = {'20000', '40000', '60000', '80000'},
		upmede = {'40000', '60000', '80000', '100000'},
		rec = '20000',
		narko = '100000',
		tatu = '120000',
		ant = '20000'
	},
	price_list_cl = {
		auto = {'200.000', '360.000', '410.000'},
		moto = {'300.000', '350.000', '450.000'},
		fly = {'1.200.000', '0', '0'},
		fish = {'500.000', '550.000', '590.000'},
		swim = {'500.000', '550.000', '590.000'},
		gun = {'1.000.000', '1.090.000', '1.150.000'},
		hunt = {'1.000.000', '1.100.000', '1.190.000'},
		exc = {'1.100.000', '1.200.000', '1.290.000'},
		taxi = {'800.000', '1.150.000', '1.250.000'},
		meh = {'800.000', '1.150.000', '1.250.000'}
	},
	chat_pl = false,
	chat_help = false,
	chat_smi = false,
	chat_racia = false,
	chat_dep = false,
	chat_vip = false,
	chat_all = false,
	time_hud = false,
	fix_text = true,
	auto_lec = false,
	accent = {func = false, text = '', r = false, f = false, d = false, s = false},
	members = {
		func = false, 
		dialog = false, 
		invers = false, 
		form = false, 
		rank = false, 
		id = false, 
		afk = false, 
		warn = false, 
		size = 12, 
		flag = 5, 
		dist = 21, 
		vis = 180, 
		color = {title = 0xFFFF8585, default = 0xFFFFFFFF, work = 0xFFFF8C00},
		pos = {x = sx - 30, y = sy / 3},
	},
	notice = {car = false, dep = false},
	dep = {my_tag = '', my_tag_en = ''},
	depart = {format = u8'[����] - [����]:', my_tag = '', else_tag = '', volna = ''},
	speed_door = false,
	dep_off = false,
	anim_main = false,
	cmd = {
		{'z', u8'�����������', {}, '1'},
		{'exp', u8'������� �� ���������', {}, '3'},
		{'za', u8'�������� ����� "�������� �� ����"', {}, '1'},
		{'show', u8'�������� ������ ���� ���������', {}, '1'},
		{'cam', u8'������ ��� ���������� �������������', {}, '1'},
		{'mb', u8'����������� ������� /members', {}, '1'},
		{'+mute', u8'������ ��� ���� ����������� ����������', {}, '8'},
		{'-mute', u8'����� ��� ���� ����������� ����������', {}, '8'},
		{'+warn', u8'������ ���������� �������', {}, '8'},
		{'-warn', u8'����� ������� ����������', {}, '8'},
		{'inv', u8'������� ������ � �����������', {}, '9'},
		{'uninv', u8'������� ����������', {}, '9'},
		{'rank', u8'���������� ���������� ����', {}, '9'},
	},
	show_dialog_auto = false,
	fast_acc = {
		func = true,
		sl = {}
	},
	shpora = {},
	sob = {
		level = 3,
		legal = 35,
		narko = 5,
		qq = {{
			nm = u8'��������� ���������', 
			q = {
			u8'��� ��������������� ���������� ������������ ��������� ����� ����������:',
			u8'�������, ����������� ����� � ��������.',
			u8'/n ���������, � �������������� ������ /me, /do, /todo'}},
			{
			nm = u8'���������� � ����',
			q = {
			u8'������, ���������� ������� � ����.'}},
			{
			nm = u8'������ �� ������� ���',
			q = {
			u8'������, �������, ������ �� ������� ������ ���?'}},
			{
			nm = u8'��� �������?',
			q = {
			u8'������, ������� �������� ���� �������.',
			u8'�������, ��� �����-������ �������?'}},
			{
			nm = u8'��� �� ����������?',
			q = {
			u8'������, �������, ��� �� ������ ����������?'}},
			{
			nm = u8'�������� �����',
			q = {
			u8'�������, �������, ��� ���������� ������, �������� �� ���������������?'}},
			{
			nm = u8'����� �������',
			q = {
			u8'������, �������, ������� �� � ��� ����. ����� Discord?'}}}
		},
	reminder = {},
	stat = {
		hosp = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			lec = {0, 0, 0, 0, 0, 0, 0},
			medcard = {0, 0, 0, 0, 0, 0, 0},
			apt = {0, 0, 0, 0, 0, 0, 0},
			ant = {0, 0, 0, 0, 0, 0, 0},
			rec = {0, 0, 0, 0, 0, 0, 0},
			medcam = {0, 0, 0, 0, 0, 0, 0},
			cure = {0, 0, 0, 0, 0, 0, 0},
			tatu = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
		},
		school = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			auto = {0, 0, 0, 0, 0, 0, 0},
			moto = {0, 0, 0, 0, 0, 0, 0},
			fish = {0, 0, 0, 0, 0, 0, 0},
			swim = {0, 0, 0, 0, 0, 0, 0},
			gun = {0, 0, 0, 0, 0, 0, 0},
			hun = {0, 0, 0, 0, 0, 0, 0},
			exc = {0, 0, 0, 0, 0, 0, 0},
			taxi = {0, 0, 0, 0, 0, 0, 0},
			meh = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
			date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
		},
	},
	mus = {
		rep = false,
		win = true,
		volume = 1
	},
	rp_zone = false,
	auto_update = false,
	ts = true,
	rubber_stick = false,
	lec = {},
	color_accent_num = 1,
	col_acc_non = {0.26, 0.45, 0.94},
	col_acc_act = {0.26, 0.35, 0.94},
	online_stat = {
		clean = {0, 0, 0, 0, 0, 0, 0},
		afk = {0, 0, 0, 0, 0, 0, 0},
		all = {0, 0, 0, 0, 0, 0, 0},
		total_week = 0,
		total_all = 0,
		date_num = {0, 0},
		date_today = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
		date_last = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
		date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''} --> ���� �� ������ � ������� [����, �����, ���]
	},
	priceosm = '200000',
	start_pos = 0,
	new_pos = 0,
	new_mus_fix = true,
	pos_act = {
		x = sx / 2,
		y = sy / 2
	},
	kick_afk = {func = false, mode = u8'������ ������� ����������', time_kick = '10'},
	anti_alarm_but = false,
	my_tag_en2 = '',
	my_tag_en3 = '',
	auto_roleplay_text = true,
	auto_weapon = true,
	fun_block = false,
	blank_text_dep = {u8'�� �����.', u8'�� �����.', u8'����� �����.', u8'����� ��������, ����� �����...', u8'�� � ��� ������ �������� ��� ��������?', u8'', u8'', u8'', u8'', u8''},
	prikol = false,
	new_act_cl_and_bl = true,
	new_stat_bl = {
		osm = {0, 0, 0, 0, 0, 0, 0},
		ticket = {0, 0, 0, 0, 0, 0, 0},
		awards = {0, 0, 0, 0, 0, 0, 0}
	},
	stat_online_display = false,
	pos_onstat = {x = sx / 2, y = sy / 2},
	fast_action_save = true,
	fast_chat = {false, false},
	off_nick = false,
	unicum_id = generate_random_cipher(12),
	unicum_git = generate_random_cipher(10),
	tickets = {},
	stat_on_members = {
		time = false,
		date = false,
		clean_on_day = true,
		afk_on_day = false,
		all_on_day = true,
		clean_on_session = true,
		afk_on_session = false,
		all_on_session = true
	},
	godeath = {
		func = false,
		cmd_go = false,
		meter = true,
		two_text = false,
		auto_send = false,
		color = 0
	},
	color_godeath = {1.00, 0.33, 0.31},
	display_map_distance = {user = false, server = false},
	notice_help = false,
	stat_online_display_hiding = true,
	info_about_new_version = true,
	hello_mes = false
}

local buf_setting = {
	theme = {imgui.ImBool(true), imgui.ImBool(false)}
}
script_tag = '[SH] '
color_tag = 0xFF5345
color_tag_ht = 'FF5345'
--> ��� �� ����
scene = {bq = {}}
scene_buf = {}
select_scene = 0

--> ��� ������
local select_cmd = 0
cmd = {
	nm = '',
	desc = u8'',
	delay = 2000,
	key = {},
	arg = {},
	var = {},
	act = {},
	num_d = 1,
	tr_fl = {0, 0, 0},
	add_f = {false, 1},
	not_send_chat = false,
	rank = '1'
}
cmds = {}

--> ��� ����
local select_shpora = 0
shpora = {
	nm = '',
	text = ''
}

--> ������ � ������
week = {'�����������', '�����������', '�������', '�����', '�������', '�������', '�������'}
month = {'������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������'}

--> ��� ����������
new_version = {beta = beta_version, version = scr_version}
type_version = {rel = false, beta = false}
upd_info = nil

--> ��������� �������
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local the_path_to_the_file_font = 'moonloader/lib/fontawesome-webfont.ttf'
if not doesFileExist(getWorkingDirectory()..'/lib/fontawesome-webfont.ttf') then
	the_path_to_the_file_font = 'moonloader/resource/fonts/fontawesome-webfont.ttf'
end

local font = {}
local bold_font = {}
local fa_font = {}

function update_render_font()
	function imgui.BeforeDrawFrame()
		if fa_font[1] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true

			fa_font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 18.0, font_config, fa_glyph_ranges)
		end
		if fa_font[2] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 10.0, font_config, fa_glyph_ranges)
		end
		if fa_font[3] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 8.0, font_config, fa_glyph_ranges)
		end
		if fa_font[4] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 15.0, font_config, fa_glyph_ranges)
		end
		if fa_font[5] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[5] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 25.0, font_config, fa_glyph_ranges)
		end
		if fa_font[6] == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = false

			fa_font[6] = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 35.0, font_config, fa_glyph_ranges)
		end
		if font[1] == nil then
			font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'), 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'), 60.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'), 13.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'),  20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[5] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'),  40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[6] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'),  10.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			font[7] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF600.ttf'),  18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		end
		if bold_font[1] == nil then
			bold_font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf'), 22.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf'), 60.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf'), 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
			bold_font[4] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(getWorkingDirectory()..'/StateHelper/Fonts/SF800.ttf'), 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		end
	end
end

--> �������� ������������� ����� � � ��������
if not doesDirectoryExist(dirml..'/StateHelper/') then
	print('{F54A4A}������. ����������� ����� State Helper. {82E28C}�������� ����� ��� �������...')
	createDirectory(dirml..'/StateHelper/')
end

function check_existence(name_folder, description_folder) --> �������� �����, ���� � ���
	local status_folder = true
	if not doesDirectoryExist(dirml..'/StateHelper/'..name_folder..'/') then
		print('{F54A4A}������. ����������� ����� '..description_folder..'. {82E28C}�������� ����� '..description_folder..'...')
		createDirectory(dirml..'/StateHelper/'..name_folder..'/')
		status_folder = false
	end
	
	return status_folder
end

function apply_settings(name_file, description_file, array_arg) --> �������� �������� ��� �������� ����� ��������
	if doesFileExist(dirml..'/StateHelper/'..name_file) then
		print('{82E28C}������ ����� '..description_file..'...')
		local f = io.open(dirml..'/StateHelper/'..name_file)
		local set = f:read('*a')
		f:close()
		local res, sets = pcall(decodeJson, set)
		if res and type(sets) == 'table' then 
			for nm_array_orig, value_orig in pairs(array_arg) do
				local success_check = false
				for nm_array_set, value_set in pairs(sets) do
					if nm_array_orig == nm_array_set then
						success_check = true
						array_arg[nm_array_orig] = value_set
					end
				end
				if not success_check then
					array_arg[nm_array_orig] = value_orig
				end
			end
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		else
			os.remove(dirml..'/StateHelper/'..name_file)
			print('{F54A4A}������. ���� '..description_file..' ��������. {82E28C}�������� ������ �����...')
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	else
		print('{F54A4A}������. ���� '..description_file..' �� ������. {82E28C}�������� ������ �����...')
		if not doesFileExist(dirml..'/StateHelper/'..name_file) then
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	end
	
	return array_arg
end

--> ������
select_music = 1
stream_music = nil
site_link = 'rus.hitmotop.com'
record = {
	[1] = 'http://radio-srv1.11one.ru/record192k.mp3',
	[2] = 'http://radiorecord.hostingradio.ru/mix96.aacp',
	[3] = 'http://radiorecord.hostingradio.ru/party96.aacp',
	[4] = 'http://radiorecord.hostingradio.ru/phonk96.aacp',
	[5] = 'http://radiorecord.hostingradio.ru/gop96.aacp',
	[6] = 'http://radiorecord.hostingradio.ru/rv96.aacp',
	[7] = 'http://radiorecord.hostingradio.ru/dub96.aacp',
	[8] = 'http://radiorecord.hostingradio.ru/bighits96.aacp',
	[9] = 'http://radiorecord.hostingradio.ru/organic96.aacp',
	[10] = 'http://radiorecord.hostingradio.ru/russianhits96.aacp'
}
record_name = {'Dance', 'Megamix', 'Party 24/7', 'Phonk', '��� FM', '���� �����', 'Dubstep', 'Big Hits', 'Organic', 'Russian Hits'}
radio = {
	[1] = 'https://ep128.hostingradio.ru:8030/ep128',
	[2] = 'https://dfm.hostingradio.ru/dfm128.mp3',
	[3] = 'https://chanson.hostingradio.ru:8041/chanson-uncensored128.mp3',
	[4] = 'http://listen.vdfm.ru:8000/dacha',
	[5] = 'http://dorognoe.hostingradio.ru:8000/dorognoe',
	[6] = 'http://icecast.vgtrk.cdnvideo.ru/mayakfm_mp3_192kbps',
	[7] = 'http://nashe1.hostingradio.ru/nashe-128.mp3',
	[8] = 'http://node-33.zeno.fm/0r0xa792kwzuv?rj-ttl=5&rj-tok=AAABfMtdjJ4AtC1pGWo1_ohFMw',
	[9] = 'https://maximum.hostingradio.ru/maximum128.mp3',
	[10] = 'http://listen1.myradio24.com:9000/5967'
}
radio_name = {u8'������ ����', u8'DFM', u8'������', u8'����� ����', u8'��������', u8'����', u8'���� �����', u8'LoFi Hip-Hop', u8'��������', u8'90\'s Eurodance'}
volume_buf = imgui.ImFloat(1.0)
status_potok = 0
text_find_track = ''
selectis = 0
qua_page = 1
current_page = 1
timetr = {0, 0}
track_time_hc = 0
status_track_pl = 'STOP'
url_track_pack = url_track
status_image = -1
menu_play_track = {false, false, false, false}
sectime_track = imgui.ImFloat(1.0)
artist = ''
name_tr = ''
select_record = 0
select_radio = 0
sel_link = ''
tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}
save_tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}

function get_status_potok_song() --> �������� ������ ������
	local status_potok
	if stream_music ~= nil then
		status_potok = bass.BASS_ChannelIsActive(stream_music)
		status_potok = tonumber(status_potok)
	else
		status_potok = 0
	end
	return status_potok
	--[[
	[0] - ������ �� ���������������
	[1] - ������
	[2] - ����
	[3] - �����
	--]]
end

function rewind_song(time_position) --> ��������� ����� �� ��������� ������� (������� ����� � ��������)
	if status_track_pl ~= 'STOP' and not menu_play_track[3] and not menu_play_track[4] and get_status_potok_song() ~= 0 then
		local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
		length = tostring(length)
		length = length:gsub('(%D+)', '')
		length = tonumber(length)
		local poslt = ((length/track_time_hc) * time_position) - 100
		bass.BASS_ChannelSetPosition(stream_music, poslt, BASS_POS_BYTE)
		local time_song = 0
		time_song = time_song_position(track_time_hc)
		time_song = round(time_song, 1)
		timetr[1] = time_song % 60
		timetr[2] = math.floor(time_song / 60)
	end
end

function time_song_position(song_length) --> �������� ������� ����� � ��������
	song_length = tonumber(song_length)
	local posByte = bass.BASS_ChannelGetPosition(stream_music, BASS_POS_BYTE)
	posByte = tostring(posByte)
	posByte = posByte:gsub('(%D+)', '')
	posByte = tonumber(posByte)
	local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
	length = tostring(length)
	length = length:gsub('(%D+)', '')
	length = tonumber(length)
	local postrack = posByte / (length / song_length)
	
	return postrack
end

function find_track_link(search_text, page) --> ����� ����� � ���������
	tracks = {
		link = {},
		artist = {},
		name = {},
		time = {},
		image = {}
	}
	local page_ssl = ''
	local all_page_num = 1
	local page_table = {'1'}
	current_page = page
	local function remove_duplicates(array)
		local seen = {}
		local result = {}

		for _, value in ipairs(array) do
			if not seen[value] then
				table.insert(result, value)
				seen[value] = true
			end
		end

		return result
	end
	if page == 2 then
		page_ssl = '/start/48'
	elseif page == 3 then
		page_ssl = '/start/96'
	elseif page == 4 then
		page_ssl = '/start/144'
	end
	
	asyncHttpRequest('GET', 'https://'..site_link..'/search'..page_ssl..'?q='..urlencode(u8(u8:decode(search_text))), nil,
		function(response)
			if page == 1 then
				for link in string.gmatch(u8:decode(response.text), '/search/start/48') do
					table.insert(page_table, '48')
				end
				for link in string.gmatch(u8:decode(response.text), '/search/start/96') do
					table.insert(page_table, '96')
				end
				for link in string.gmatch(u8:decode(response.text), '/search/start/144') do
					table.insert(page_table, '144')
				end
				local new_arr = remove_duplicates(page_table)
				qua_page = #new_arr
			end
			for link in string.gmatch(u8:decode(response.text), '�� ������ ������� ������ �� �������') do
				tracks.link[1] = '������404'
				tracks.artist[1] = '������404'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://'..site_link..'/get/music/') then
					track = link:match('(.+).mp3')
					tracks.link[#tracks.link + 1] = track..'.mp3'
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				local nametrack = link:match('(.+)')
				nametrack = nametrack and nametrack:gsub('^%s+', '') or '����������'
				tracks.name[#tracks.name + 1] = nametrack:gsub('%s+$', '')
			end

			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				local artist = link:match('(.+)')
				artist = artist and artist:gsub('^%s+', '') or "����������"
				tracks.artist[#tracks.artist + 1] = artist
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_fulltime"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.time[#tracks.time + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_img" style="background%-image: url%(\'(.-)\'%)%;"%>%</div%>') do
				if link:find('(.+)') then
					tracks.image[#tracks.image + 1] = link:match('(.+)')
				end
			end
		end,
		function(err)
		print(err)
	end)
end

function get_track_length() --> �������� ����� ����� � ��������
	local len_song = 0
	if menu_play_track[1] or menu_play_track[2] then
		local min_tr = 0
		local sec_tr = 0
		if menu_play_track[1] then
			min_tr = tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = tracks.time[selectis]:gsub('(.+):', '')
		else
			min_tr = save_tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = save_tracks.time[selectis]:gsub('(.+):', '')
		end
		min_tr = tonumber(min_tr)
		sec_tr = tonumber(sec_tr)
		len_song = (min_tr * 60) + sec_tr
	end
	
	return len_song
end

function play_song(url_track, loop_track) --> �������� �����
	timetr = {0, 0}
	track_time_hc = 0
	status_track_pl = 'PLAY'
	url_track_pack = url_track
	if menu_play_track[1] then
		local tri = tracks.time[selectis]:gsub(':(.+)$', '')
		local tri2 = tracks.time[selectis]:gsub('^(.+):', '')
		timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		artist = tracks.artist[selectis]
		name_tr = tracks.name[selectis]
		sel_link = url_track
	elseif menu_play_track[2] then
		local tri = save_tracks.time[selectis]:gsub(':(.+)$', '')
		local tri2 = save_tracks.time[selectis]:gsub('^(.+):', '')
		timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		artist = save_tracks.artist[selectis]
		name_tr = save_tracks.name[selectis]
	end
	track_time_hc = get_track_length()
	if get_status_potok_song() ~= 0 then
		bass.BASS_ChannelStop(stream_music)
	end
	stream_music = bass.BASS_StreamCreateURL(url_track, 0, BASS_STREAM_AUTOFREE, nil, nil)
	if loop_track ~= true then
		bass.BASS_ChannelPlay(stream_music, false)
	elseif loop_track == true then
		bass.BASS_ChannelPlay(stream_music, BASS_SAMPLE_LOOP)
	end
	bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_buf.v)
	if menu_play_track[1] then
		if not tracks.image[selectis]:find('no%-cover%-150') then
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory()..'/StateHelper/�����������/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	elseif menu_play_track[2] then
		if not save_tracks.image[selectis]:find('no%-cover%-150') then
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory()..'/StateHelper/�����������/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	end
end

function action_song(action_music) --> ����������/�����/����������
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		if action_music == 'PLAY' then
			status_track_pl = 'PLAY'
			bass.BASS_ChannelPlay(stream_music, false)
		elseif action_music == 'PAUSE' then
			status_track_pl = 'PAUSE'
			bass.BASS_ChannelPause(stream_music)
		elseif action_music == 'STOP' then
			selectis = 0
			select_record = 0
			select_radio = 0
			menu_play_track = {false, false, false, false}
			status_track_pl = 'STOP'
			bass.BASS_ChannelStop(stream_music)
		end
	end
end

function volume_song(volume_music) --> ���������� ��������� �����
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music)
	end
end

function back_track()
	if menu_play_track[1] then
		if selectis > 1 and tracks.link[selectis] == url_track_pack then
			selectis = selectis - 1
			play_song(tracks.link[selectis], false)
		elseif selectis == 1 or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis > 1 and save_tracks.link[selectis - 1] ~= nil then
			selectis = selectis - 1
			play_song(save_tracks.link[selectis], false)
		elseif selectis == 1 or save_tracks.link[selectis - 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function next_track()
	if menu_play_track[1] then
		if selectis ~= 0 and selectis < #tracks.link and tracks.link[selectis] == url_track_pack then
			selectis = selectis + 1
			play_song(tracks.link[selectis], false)
		elseif (selectis ~= 0 and selectis == #tracks.link) or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis ~= 0 and selectis < #save_tracks.link and save_tracks.link[selectis + 1] ~= nil then
			selectis = selectis + 1
			play_song(save_tracks.link[selectis], false)
		elseif (selectis ~= 0 and selectis == #save_tracks.link) or save_tracks.link[selectis + 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function stalecatin()
	if get_status_potok_song() == 3 and status_track_pl == 'PLAY' then
		action_song('PLAY')
	elseif get_status_potok_song() == 0 and status_track_pl == 'PLAY' then
		if setting.mus.rep then
			play_song(url_track_pack, false)
		else
			next_track()
		end
	end
end

function main()
	repeat wait(300) until isSampAvailable()
	local base = getModuleHandle('samp.dll')
	local sampVer = mem.tohex(base + 0xBABE, 10, true)
	if sampVer == 'E86D9A0A0083C41C85C0' then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find('%.luac') then
		os.rename(getWorkingDirectory()..'\\StateHelper.luac', getWorkingDirectory()..'\\StateHelper.lua') 
	end
	thread = lua_thread.create(function() return end)
	pos_new_memb = lua_thread.create(function() return end)
	
	--> �������� ������ � ��������� ��������
	check_existence('��� ����������', '��� ����������')
	check_existence('���������', '��� ���������')
	check_existence('���������', '��� ���������')
	
	setting = apply_settings('���������.json', '��������', setting)
	save_tracks = apply_settings('�����.json', '������', save_tracks)
	scene = apply_settings('�����.json', '����', scene)
	
	repeat wait(100) until sampIsLocalPlayerSpawned()
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	my = {id = myid, nick = sampGetPlayerNickname(myid)}
	
	if doesFileExist(dirml..'/MedicalHelper.lua') then
		os.remove(dirml..'/MedicalHelper.lua')
	end
	
	if setting.int.first_start then
		first_start_anim = {
			text = {false, false, false, false, false, false},
			done = {false, false, false, false, false, false},
			vis = {0, 0},
			pos = {200, 200}
		}
	end

	fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag)
	if setting.speed_door then
		rkeys.registerHotKey({72}, 1, false, function() on_hot_key({72}) end)
	end
	if #setting.cmd ~= 0 then
		for i = 1, #setting.cmd do
			if #setting.cmd[i][3] ~= 0 then
				rkeys.registerHotKey(setting.cmd[i][3], 3, true, function() on_hot_key(setting.cmd[i][3]) end)
			end
		end
	end
	if setting.dep_off then
		sampRegisterChatCommand('d', function()
			sampAddChatMessage(script_tag..'{FFFFFF}�� ��������� ������� /d � ����������.', color_tag)
		end)
	end
	if setting.accent.d and not setting.dep_off then
		sampRegisterChatCommand('d', function(text_accents_d) 
			if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
				sampSendChat('/d ['..u8:decode(setting.accent.text)..' ������]: '..text_accents_d)
			else
				sampSendChat('/d '..text_accents_d)
			end 
		end)
	end
	
	if setting.ts then
		sampRegisterChatCommand('ts', print_scr_time)
	end
	
	if setting.int.theme ~= 'White' then
		buf_setting.theme[1].v = false
		buf_setting.theme[2].v = true
	end
	col = {
		title = convert_color(setting.members.color.title),
		default = convert_color(setting.members.color.default),
		work = convert_color(setting.members.color.work)
	}
	
	if setting.frac.org:find(u8'��������') then
		if setting.new_act_cl_and_bl and not setting.int.first_start then
			setting.new_act_cl_and_bl = false
			add_table_act(setting.frac.org, false)
		end
		setting.stat.hosp.date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
		if setting.stat.hosp.date_today[1] ~= setting.stat.hosp.date_last[1] or setting.stat.hosp.date_today[2] ~= setting.stat.hosp.date_last[2]
		or setting.stat.hosp.date_today[3] ~= setting.stat.hosp.date_last[3] then
			setting.stat.hosp.date_num[1] = setting.stat.hosp.date_num[1] + 1
		end
		if setting.stat.hosp.date_num[1] > setting.stat.hosp.date_num[2] then
			setting.stat.hosp.date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
			setting.stat.hosp.date_num[2] = setting.stat.hosp.date_num[1]
			for i = 6, 1, -1 do
				setting.stat.hosp.date_week[i + 1] = setting.stat.hosp.date_week[i]
				setting.stat.hosp.payday[i + 1] = setting.stat.hosp.payday[i]
				setting.stat.hosp.lec[i + 1] = setting.stat.hosp.lec[i]
				setting.stat.hosp.medcard[i + 1] = setting.stat.hosp.medcard[i]
				setting.stat.hosp.apt[i + 1] = setting.stat.hosp.apt[i]
				setting.stat.hosp.ant[i + 1] = setting.stat.hosp.ant[i]
				setting.stat.hosp.rec[i + 1] = setting.stat.hosp.rec[i]
				setting.stat.hosp.medcam[i + 1] = setting.stat.hosp.medcam[i]
				setting.stat.hosp.tatu[i + 1] = setting.stat.hosp.tatu[i]
				setting.stat.hosp.cure[i + 1] = setting.stat.hosp.cure[i]
				setting.new_stat_bl.osm[i + 1] = setting.new_stat_bl.osm[i]
				setting.new_stat_bl.ticket[i + 1] = setting.new_stat_bl.ticket[i]
				setting.new_stat_bl.awards[i + 1] = setting.new_stat_bl.awards[i]
			end
			setting.stat.hosp.date_week[1] = os.date('%d.%m.%Y')
			setting.stat.hosp.payday[1] = 0
			setting.stat.hosp.lec[1] = 0
			setting.stat.hosp.medcard[1] = 0
			setting.stat.hosp.apt[1] = 0
			setting.stat.hosp.ant[1] = 0
			setting.stat.hosp.rec[1] = 0
			setting.stat.hosp.medcam[1] = 0
			setting.stat.hosp.tatu[1] = 0
			setting.stat.hosp.cure[1] = 0
			setting.new_stat_bl.osm[1] = 0
			setting.new_stat_bl.ticket[1] = 0
			setting.new_stat_bl.awards[1] = 0
		end
		save('setting')
	elseif setting.frac.org:find(u8'����� ��������������') then
		setting.stat.school.date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
		if setting.stat.school.date_today[1] ~= setting.stat.school.date_last[1] or setting.stat.school.date_today[2] ~= setting.stat.school.date_last[2]
		or setting.stat.school.date_today[3] ~= setting.stat.school.date_last[3] then
			setting.stat.school.date_num[1] = setting.stat.school.date_num[1] + 1
		end
		if setting.stat.school.date_num[1] > setting.stat.school.date_num[2] then
			setting.stat.school.date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))}
			setting.stat.school.date_num[2] = setting.stat.school.date_num[1]
			for i = 6, 1, -1 do
				setting.stat.school.date_week[i + 1] = setting.stat.school.date_week[i]
				setting.stat.school.payday[i + 1] = setting.stat.school.payday[i]
				setting.stat.school.auto[i + 1] = setting.stat.school.auto[i]
				setting.stat.school.moto[i + 1] = setting.stat.school.moto[i]
				setting.stat.school.fish[i + 1] = setting.stat.school.fish[i]
				setting.stat.school.swim[i + 1] = setting.stat.school.swim[i]
				setting.stat.school.gun[i + 1] = setting.stat.school.gun[i]
				setting.stat.school.hun[i + 1] = setting.stat.school.hun[i]
				setting.stat.school.exc[i + 1] = setting.stat.school.exc[i]
				setting.stat.school.taxi[i + 1] = setting.stat.school.taxi[i]
				setting.stat.school.meh[i + 1] = setting.stat.school.meh[i]
			end
			setting.stat.school.date_week[1] = os.date('%d.%m.%Y')
			setting.stat.school.payday[1] = 0
			setting.stat.school.auto[1] = 0
			setting.stat.school.moto[1] = 0
			setting.stat.school.fish[1] = 0
			setting.stat.school.swim[1] = 0
			setting.stat.school.gun[1] = 0
			setting.stat.school.hun[1] = 0
			setting.stat.school.exc[1] = 0
			setting.stat.school.taxi[1] = 0
			setting.stat.school.meh[1] = 0
		end
		for i = 1, 7 do
			setting.stat.school.total_week = setting.stat.school.payday[i] + setting.stat.school.auto[i] + setting.stat.school.moto[i] + 
			setting.stat.school.fish[i] + setting.stat.school.swim[i] + setting.stat.school.gun[i] + setting.stat.school.exc[i] + 
			setting.stat.school.taxi[i] + setting.stat.school.meh[i] + setting.stat.school.hun[i]
		end
		save('setting')
	end
	
	setting.online_stat.date_today[1] = tonumber(os.date('%d'))
	setting.online_stat.date_today[2] = tonumber(os.date('%m'))
	setting.online_stat.date_today[3] = tonumber(os.date('%Y'))
	if setting.online_stat.date_today[1] ~= setting.online_stat.date_last[1] or setting.online_stat.date_today[2] ~= setting.online_stat.date_last[2] 
	or setting.online_stat.date_today[3] ~= setting.online_stat.date_last[3] then
		setting.online_stat.date_num[1] = setting.online_stat.date_num[1] + 1
	end
	if setting.online_stat.date_num[1] > setting.online_stat.date_num[2] then --> ���� ����������� ���� ���������� �� ���������
		setting.online_stat.date_last[1] = tonumber(os.date('%d'))
		setting.online_stat.date_last[2] = tonumber(os.date('%m'))
		setting.online_stat.date_last[3] = tonumber(os.date('%Y'))
		setting.online_stat.date_num[2] = setting.online_stat.date_num[1]
		for i = 6, 1, -1 do
			setting.online_stat.date_week[i + 1] = setting.online_stat.date_week[i]
			setting.online_stat.clean[i + 1] = setting.online_stat.clean[i]
			setting.online_stat.afk[i + 1] = setting.online_stat.afk[i]
			setting.online_stat.all[i + 1] = setting.online_stat.all[i]
		end
		setting.online_stat.date_week[1] = os.date('%d.%m.%Y')
		setting.online_stat.clean[1] = 0
		setting.online_stat.afk[1] = 0
		setting.online_stat.all[1] = 0
		save('setting')
	end
	
	local save_bool = false
	if setting.price.lec == '' or setting.price.lec == '0' then
		setting.price.lec = '1'
		save_bool = true
	end
	if setting.price.rec == '' or setting.price.rec == '0' then
		setting.price.rec = '1'
		save_bool = true
	end
	if setting.price.tatu == '' or setting.price.tatu == '0' then
		setting.price.tatu = '1'
		save_bool = true
	end
	if setting.price.ant == '' or setting.price.ant == '0' then
		setting.price.ant = '1'
		save_bool = true
	end
	if setting.price.narko == '' or setting.price.narko == '0' then
		setting.price.narko = '1'
		save_bool = true
	end
	if setting.priceosm == '' or setting.priceosm == '0' then
		setting.priceosm = '1'
		save_bool = true
	end
	if setting.price.mede[1] == '' or setting.price.mede[1] == '0' then
		setting.price.mede[1] = '1'
		save_bool = true
	end
	if setting.price.mede[2] == '' or setting.price.mede[2] == '0' then
		setting.price.mede[2] = '1'
		save_bool = true
	end
	if setting.price.mede[3] == '' or setting.price.mede[3] == '0' then
		setting.price.mede[3] = '1'
		save_bool = true
	end
	if setting.price.mede[4] == '' or setting.price.mede[4] == '0' then
		setting.price.mede[4] = '1'
		save_bool = true
	end
	if setting.price.upmede[1] == '' or setting.price.upmede[1] == '0' then
		setting.price.upmede[1] = '1'
		save_bool = true
	end
	if setting.price.upmede[2] == '' or setting.price.upmede[2] == '0' then
		setting.price.upmede[2] = '1'
		save_bool = true
	end
	if setting.price.upmede[3] == '' or setting.price.upmede[3] == '0' then
		setting.price.upmede[3] = '1'
		save_bool = true
	end
	if setting.price.upmede[4] == '' or setting.price.upmede[4] == '0' then
		setting.price.upmede[4] = '1'
		save_bool = true
	end
	if save_bool then
		save('setting')
	end
	
	start_pos = setting.start_pos
	new_pos = setting.new_pos
	interf = {
		main = {
			size = {x = 869, y = 469 + start_pos + new_pos},
			size_def = {x = 869, y = 469},
			anim_win = {move = false, par = false, x = 0, y = 0},
			func = true,
			cond = imgui.Cond.Always,
			collapse = false
		},
		list = ''
	}
	
	if setting.new_mus_fix then
		if #save_tracks.link ~= 0 then
			for i = 1, #save_tracks.link do
				if save_tracks.link[i]:find('ru%.apporange%.space') then
					save_tracks.link[i] = save_tracks.link[i]:gsub('ru%.apporange%.space', 'rur%.hitmotop%.com')
					save_tracks.image[i] = save_tracks.image[i]:gsub('ru%.apporange%.space', 'rur%.hitmotop%.com')
				end
			end
		end
		
		setting.new_mus_fix = false
		save('save_tracks')
		save('setting')
	end
	
	lua_thread.create(time)
	lua_thread.create(activate_function_members)
	lua_thread.create(save_coun_onl)
	lua_thread.create(update_check)
	lua_thread.create(time_potok)
	
	if #setting.cmd ~= 0 then
		for i = 1, #setting.cmd do
			sampRegisterChatCommand(setting.cmd[i][1], function(arg) cmd_start(arg, setting.cmd[i][1]) end)
		end
	end
	
	if #setting.lec ~= 0 then
		for i = 1, #setting.lec do
			sampRegisterChatCommand(setting.lec[i].cmd, function(arg) lec_start(arg, setting.lec[i].cmd) end)
		end
	end
	
	if setting.godeath.func and setting.godeath.cmd_go then
		sampRegisterChatCommand('go', function()
			sampSendChat('/godeath '.. id_player_godeath)
		end)
	end
	
	members_wait.members = true
	sampSendChat('/members')
	sampSendChat('/stats')
	
	if setting.stat_online_display then
		start_session = true
		win.stat_online.v = true
	else
		win.stat_online.v = false
	end
	
	style_window()
	if setting.info_about_new_version and not setting.int.first_start then
		sampAddChatMessage(script_tag..'{FFFFFF}������ ������� ��������� �� ������ {4EEB40}'.. tostring(scr.version) ..'{FFFFFF}. ��������� � ������������� �� ������� "����������".', color_tag)
		setting.info_about_new_version = false
		save('setting')
	elseif not setting.hello_mes then
		sampAddChatMessage(string.format(script_tag..'{FFFFFF}%s, ��� ��������� �������� ����, ��������� � ��� {a8a8a8}/sh', sampGetPlayerNickname(my.id):gsub('_',' ')), color_tag)
	end
	
	while true do wait(0)
		if sampIsDialogActive() then
    		lastDialogWasActive = os.clock()
    	end
		res_targ, ped_tar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if res_targ then
			_, targ_id = sampGetPlayerIdByCharHandle(ped_tar)
			if setting.fast_acc.func and isKeyJustPressed(VK_E) and #setting.fast_acc.sl > 0 and targ_id ~= -1 then
				if sampIsPlayerConnected(targ_id) then
					flies_nick = sampGetPlayerNickname(targ_id)
					flies_id = targ_id
					win.action_choice.v = true
					imgui.ShowCursor = true
				end
			end
		end
		if setting.frac.org == u8'���' then
		local ped = PLAYER_PED
		if isCharInAnyCar(ped) then
			local vehicle = getCarCharIsUsing(ped)
			if getCarModel(vehicle) == 548 then
				if isKeyJustPressed(VK_2) then
					sampSendChat("/carm")
				end
			end
		end
	end
		if secc_load_font and installation_success_font[1] and installation_success_font[2] then
			update_render_font()
			secc_load_font = false
		end
		
		imgui.Process = win.main.v or win.icon.v or win.spur_big.v or win.action_choice.v or win.reminder.v or win.notice.v 
		or win.music.v or win.stat_online.v
		
		if setting.time_hud or setting.display_map_distance.user or setting.display_map_distance.server then
			if not isPauseMenuActive() and not scene_active then time_hud_func_and_distance_point() end
		end
		
		if setting.members.func and isCursorAvailable() and isKeyJustPressed(0xA5) then
			script_cursor = not script_cursor
			showCursor(script_cursor, false)
		end
		if setting.members.func and not isGamePaused() and not scene_active and ((setting.members.dialog and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive()) or not setting.members.dialog) then
			render_members()
		elseif setting.members.func and pos_new_memb:status() ~= 'dead' then
			render_members()
		end
		
		if not win.main.v and not win.icon.v and not win.spur_big.v and not win.action_choice.v and not win.reminder.v then
			imgui.ShowCursor = false
		end
		
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() and not isGamePaused() then
			if thread:status() ~= 'dead' then
				thread:terminate()
				new_notice('off')
			end
		end
		
		if not isGamePaused() and status_track_pl ~= 'STOP' then
			stalecatin()
		elseif isGamePaused() and status_track_pl == 'PLAY' then
			if get_status_potok_song() == 1 then
				bass.BASS_ChannelPause(stream_music)
			end
		end
		
		if scene_active or scene_edit_i or (preview_sc and edit_sc) then
			if not isGamePaused() then
				scene_work()
			end
		end
		
		if setting.rubber_stick then
			local num_weap = getCurrentCharWeapon(playerPed)
			if num_weap == 3 and not bool_rubber_stick then 
				sampSendChat('/me ���� ������� � �����, ����'.. chsex('', '�') ..' � � ������ ����')
				bool_rubber_stick = true
			elseif num_weap ~= 3 and bool_rubber_stick then
				sampSendChat('/me �������'.. chsex('', '�') ..' ������� �� ����')
				bool_rubber_stick = false
			end
		end
		
		if setting.auto_weapon then
			if setting.auto_weapon and setting.frac.org == u8'���' then
			local num_weap = getCurrentCharWeapon(playerPed)
			local weapons = {
				[3] = {desc = "����" .. chsex('', '�') ..  " ������� � �������� ���������", desc_put = "�����" .. chsex('', '�') ..  " ������� �� ����"},
				[22] = {desc = "��������" .. chsex('', '�') ..  " �������� \"Pistol\", ����" .. chsex('', '�') .. " ��� � ��������������", desc_put = "�����".. chsex('', '�') .. " �������� � ������"},
				[23] = {desc = "������ ������".. chsex('', '�') .. " ������", desc_put = "�������".. chsex('', '�') .. " ������ � ������"},
				[24] = {desc = "������".. chsex('', '��') .. " \"Desert Eagle\" �� ������", desc_put = "�����".. chsex('', '�') .. " \"Desert Eagle\" ������� � ������"},
				[25] = {desc = "����".. chsex('', '�') .. " �������� �� �����", desc_put = "�������".. chsex('', '�') .. " �������� �� �����"},
				[26] = {desc = "������".. chsex('', '�') .. " ������ �� ������", desc_put = "�������".. chsex('', '�') .. " ����� ��� ������"},
				[27] = {desc = "������".. chsex('', '�') .. " �������������� ��������", desc_put = "�������".. chsex('', '�') .. " �������������� �������� �� �����"},
				[28] = {desc = "����� �������" .. chsex('', '�') .. " UZI", desc_put = "�����" .. chsex('', '�') .. " UZI � �����"},
				[29] = {desc = "�������� ������".. chsex('', '�') .. " ������� MP5", desc_put = "�������".. chsex('', '�') .. " MP5 �� �����"},
				[30] = {desc = "����".. chsex('', '�') .. " ������� \"AK-47\"  �� �����", desc_put = "�������".. chsex('', '�') .. " \"AK-47\" �� ��������������, �����".. chsex('', '�') .. " �� �����"},
				[31] = {desc = "������ � �������� ����".. chsex('', '�') .. " \"M4\" � �����", desc_put = "�������".. chsex('', '�') .. " \"M4\" �� �����"},
				[33] = {desc = "����".. chsex('', '�') .. " �������� � �����", desc_put = "��������".. chsex('', '�') .. " �������� �� �����"},
				[34] = {desc = "������".. chsex('', '�') .. " ����������� ��������", desc_put = "��������".. chsex('', '�') .. " ����������� �������� �� �����"},
				[71] = {desc = "������".. chsex('', '��') .. " \"Desert Eagle Steel\" �� ������", desc_put = "�����".. chsex('', '�') .. " \"Desert Eagle Steel\" ������� � ������"},
				[72] = {desc = "������".. chsex('', '��') .. " \"Desert Eagle Gold\" �� ������", desc_put = "�����".. chsex('', '�') .. " \"Desert Eagle Gold\" ������� � ������"},
				[73] = {desc = "��������".. chsex('', '�') .. " �������� \"Glock\", ����".. chsex('', '�') .. " ��� � ��������������", desc_put = "�����".. chsex('', '�') .. " �������� \"Glock\" � ������"},
				[74] = {desc = "������".. chsex('', '��') .. " \"Desert Eagle Flame\" �� ������", desc_put = "�����".. chsex('', '�') .. " \"Desert Eagle Flame\" ������� � ������"},
				[75] = {desc = "��������".. chsex('', '�') .. " �������� \"Colt Python\", ����".. chsex('', '�') .. " ��� � ��������������", desc_put = "�����".. chsex('', '�') .. " �������� \"Colt Python\" � ������"},
				[76] = {desc = "��������".. chsex('', '�') .. " �������� \"Colt Python Silver\", ����".. chsex('', '�') .. " ��� � ��������������", desc_put = "�����".. chsex('', '�') .. " �������� \"Colt Python Silver\" � ������"},
				[77] = {desc = "����".. chsex('', '�') .. " ������� \"AK-47 Roses\" �� �����", desc_put = "�����".. chsex('', '�') .. " ������� \"AK-47 Roses\" �� �����"},
				[78] = {desc = "����".. chsex('', '�') .. " ������� \"AK-47 Gold\" �� �����", desc_put = "�����".. chsex('', '�') .. " ������� \"AK-47 Gold\" �� �����"},
				[79] = {desc = "����".. chsex('', '�') .. " ������� \"M249 Graffiti\" �� �����", desc_put = "�����".. chsex('', '�') .. " ������� \"M249 Graffiti\" �� �����"},
				[80] = {desc = "����".. chsex('', '�') .. " ������� \"������� �����\" �� �����", desc_put = "�����".. chsex('', '�') .. " ������� \"������� �����\" �� �����"},
				[81] = {desc = "������".. chsex('', '�') .. " ��������-������ \"Standart\" � ������", desc_put = "�����".. chsex('', '�') .. " ��������-������ \"Standart\" � ������"},
				[82] = {desc = "����".. chsex('', '�') .. " ������� \"M249\" �� �����", desc_put = "�����".. chsex('', '�') .. " ������� \"M249\" �� �����"},
				[83] = {desc = "������".. chsex('', '�') .. " ��������-������ \"Skorp\" � ������", desc_put = "�����".. chsex('', '�') .. " ��������-������ \"Skorp\" � ������"},
				[84] = {desc = "����".. chsex('', '�') .. " ����������� ������� \"AKS-74\" �� �����", desc_put = "�����".. chsex('', '�') .. " ����������� ������� \"AKS-74\" �� �����"},
				[85] = {desc = "����".. chsex('', '�') .. " ����������� ������� \"AK-47\" �� �����", desc_put = "�����".. chsex('', '�') .. " ����������� ������� \"AK-47\" �� �����"},
				[86] = {desc = "����".. chsex('', '�') .. " �������� \"Rebecca\" �� �����", desc_put = "�����".. chsex('', '�') .. " �������� \"Rebecca\" �� �����"},
				[92] = {desc = "������".. chsex('', '�') .. " ����������� �������� \"McMillian TAC-50\"", desc_put = "�����".. chsex('', '�') .. " ����������� �������� \"McMillian TAC-50\" �� �����"}
			}
		
				for weapon_id, weapon_info in pairs(weapons) do
					local rp_gun_flag = _G["rp_gun_" .. weapon_id]
					if num_weap == weapon_id and not rp_gun_flag then
						sampSendChat('/me ' .. weapon_info.desc)
						_G["rp_gun_" .. weapon_id] = true
					elseif num_weap ~= weapon_id and rp_gun_flag then
						local new_weapon_is_known = false
						for id, _ in pairs(weapons) do
							if num_weap == id then
								new_weapon_is_known = true
								break
							end
						end
						if not new_weapon_is_known then
							sampSendChat('/me ' .. weapon_info.desc_put)
						end
						_G["rp_gun_" .. weapon_id] = false
					end
				end
			end
		end
	end
end

function time_potok()
	while true do wait(20)
		if status_track_pl == 'PLAY' then
			target_audio_vizual = audio_vizual
			local lengt = ffi.new("char[?]", 16)
			
			local gbit = bass.BASS_ChannelGetData(stream_music, lengt, 16)
			if gbit == 16 then
				local value = ffi.cast("int*", lengt)
				if tonumber(value[0]) > 0 then
					local kegla = tonumber(value[0])  / 42768000
					if kegla < 33 then
						audio_vizual = kegla
					end
				end

				ffi.fill(lengt, 16, 0)
			end
			
			level_potok = tonumber(bass.BASS_ChannelGetLevel(stream_music)) / 100000000
			
			if level_potok > 33 then level_potok = 33 end
			
			math.randomseed(os.time())
			local randomValue = math.random(50000000, 200000000)
			frequency = tonumber(bass.BASS_ChannelGetLevel(stream_music)) / randomValue
			
			if frequency > 33 then frequency = 33 end
		end
	end
end

function create_act(add_command)
	local function cr_file(name_file, content)
		if not doesFileExist(dirml..'/StateHelper/���������/'..name_file..'.json') then
			local f = io.open(dirml..'/StateHelper/���������/'..name_file..'.json', 'w')
			f:write(content)
			f:flush()
			f:close()
		end
	end
end

function new_frame_theme()
	if setting.int.theme == 'White' then
		if col_end.text > color_w.text then
			col_end.text = col_end.text - 0.035
		end
		
		if col_end.fond_one[1] < color_w.fond_one[1] then
			col_end.fond_one[1] = col_end.fond_one[1] + 0.035
		else
			col_end.fond_one[1] = color_w.fond_one[1]
		end
		if col_end.fond_one[2] < color_w.fond_one[2] then
			col_end.fond_one[2] = col_end.fond_one[2] + 0.035
		else
			col_end.fond_one[2] = color_w.fond_one[2]
		end
		if col_end.fond_one[3] < color_w.fond_one[3] then
			col_end.fond_one[3] = col_end.fond_one[3] + 0.035
		else
			col_end.fond_one[3] = color_w.fond_one[3]
		end
		
		if col_end.fond_two[1] < color_w.fond_two[1] then
			col_end.fond_two[1] = col_end.fond_two[1] + 0.035
		else
			col_end.fond_two[1] = color_w.fond_two[1]
		end
		if col_end.fond_two[2] < color_w.fond_two[2] then
			col_end.fond_two[2] = col_end.fond_two[2] + 0.035
		else
			col_end.fond_two[2] = color_w.fond_two[2]
		end
		if col_end.fond_two[3] < color_w.fond_two[3] then
			col_end.fond_two[3] = col_end.fond_two[3] + 0.035
		else
			col_end.fond_two[3] = color_w.fond_two[3]
		end
		style_window()
	else
		if col_end.text < color_b.text then
			col_end.text = col_end.text + 0.035
		end

		if col_end.fond_one[1] > color_b.fond_one[1] then
			col_end.fond_one[1] = col_end.fond_one[1] - 0.035
		else
			col_end.fond_one[1] = color_b.fond_one[1]
		end
		if col_end.fond_one[2] > color_b.fond_one[2] then
			col_end.fond_one[2] = col_end.fond_one[2] - 0.035
		else
			col_end.fond_one[2] = color_b.fond_one[2]
		end
		if col_end.fond_one[3] > color_b.fond_one[3] then
			col_end.fond_one[3] = col_end.fond_one[3] - 0.035
		else
			col_end.fond_one[3] = color_b.fond_one[3]
		end
		
		if col_end.fond_two[1] > color_b.fond_two[1] then
			col_end.fond_two[1] = col_end.fond_two[1] - 0.035
		else
			col_end.fond_two[1] = color_b.fond_two[1]
		end
		if col_end.fond_two[2] > color_b.fond_two[2] then
			col_end.fond_two[2] = col_end.fond_two[2] - 0.035
		else
			col_end.fond_two[2] = color_b.fond_two[2]
		end
		if col_end.fond_two[3] > color_b.fond_two[3] then
			col_end.fond_two[3] = col_end.fond_two[3] - 0.035
		else
			col_end.fond_two[3] = color_b.fond_two[3]
		end
		style_window()
	end
end

function imgui.OnDrawFrame()
	new_frame_theme()
	if win.main.v then
		if setting.int.first_start then
			window.main_first_start()
		else
			window.main()
		end
	end
	if win.icon.v then
		window.icon()
	end
	if win.notice.v then
		window.notice()
	end
	if win.action_choice.v then
		window.act_choice()
	end
	if win.spur_big.v then
		window.spur()
	end
	if win.reminder.v then
		window.reminder()
	end
	if win.music.v and status_track_pl ~= 'STOP' and setting.mus.win then
		window.music()
	end
	if win.stat_online.v then
		if not setting.stat_online_display_hiding  or change_pos_onstat or (setting.stat_online_display_hiding and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() 
		and not isSampfuncsConsoleActive() and not scene_active) then
			window.stat_online()
		end
	end
end

local pos_win_closed
function styleAnimationOpen(win_name)
	if not setting.anim_main then
		local fps = mem.getfloat(0xB7CB50, true)
		local pert = 15
		if fps < 60 and fps >= 50 then
			pert = 20
		elseif fps < 50 and fps >= 40 then
			pert = 40
		elseif fps < 40 and fps >= 30 then
			pert = 70
		elseif fps < 30 then
			pert = 120
		end
		if win_name == 'Main' then
			interf.main.anim_win.y = sy / 2
			interf.main.anim_win.x = sx * 2
			
			lua_thread.create(function()
				interf.main.anim_win.move = true
				repeat wait(0)
					interf.main.anim_win.x = (interf.main.anim_win.x/1.04) - pert
				until interf.main.anim_win.x < sx / 2
				interf.main.anim_win.x = sx / 2
				interf.main.anim_win.move = false
			end)
		end
		imgui.ShowCursor = true
	else
		if win_name == 'Main' then
			interf.main.anim_win.y = sy / 2
			interf.main.anim_win.x = sx / 2
			imgui.ShowCursor = true
		end
	end
end

function styleAnimationClose(win_name, x_win, y_win)
	if not setting.anim_main then
		local fps = mem.getfloat(0xB7CB50, true)
		local pert = 18
		if fps < 60 and fps >= 50 then
			pert = 20
		elseif fps < 50 and fps >= 40 then
			pert = 40
		elseif fps < 40 and fps >= 30 then
			pert = 70
		elseif fps < 30 then
			pert = 120
		end
		if win_name == 'Main' then
			if not win.spur_big.v and not win.icon.v and not win.action_choice.v and not win.reminder.v then
				imgui.ShowCursor = false
			end
			interf.main.anim_win.y = pos_win_closed.y + (y_win / 2)
			if pos_win_closed.x > 0 then
				interf.main.anim_win.x = pos_win_closed.x + (x_win / 2)
			else
				interf.main.anim_win.x = x_win / 2
			end
			lua_thread.create(function()
				interf.main.anim_win.move = true
				repeat wait(0)
					interf.main.anim_win.x = (interf.main.anim_win.x * 1.04) + pert
				until interf.main.anim_win.x > sx + x_win
				win.main.v = false
				interf.main.anim_win.move = false
				imgui.ShowCursor = true
			end)
		end
	else
		if win_name == 'Main' then
			win.main.v = false
		end
	end
end

interface = {}

sampRegisterChatCommand('sh', function()
	if installation_success_font[1] and installation_success_font[2] then
		if not win.main.v then
			styleAnimationOpen('Main')
			win.main.v = true
		else
			interf.main.anim_win.par = true
		end
		if not setting.members.func then
			EXPORTS.sendRequest()
		end
		if IMG_No_Label == nil then
			IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/No label.png')
		end
		if IMG_Background == nil then
			IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background.png')
		end
		if IMG_Background_White == nil then
			IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background White.png')
		end
		if IMG_Background_Black == nil then
			IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Background Black.png')
		end
		if #IMG_Record == 0 then
			IMG_Record = {
				[1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Dance Label.png'),
				[2] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Megamix Label.png'),
				[3] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Party Label.png'),
				[4] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Phonk Label.png'),
				[5] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record GopFM Label.png'),
				[6] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Ruki Vverh Label.png'),
				[7] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Dupstep Label.png'),
				[8] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Bighits Label.png'),
				[9] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Organic Label.png'),
				[10] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Record Russianhits Label.png'),
			}
		end
		if #IMG_Radio == 0 then
			IMG_Radio = {
				[1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Europa Plus.png'),
				[2] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/DFM.png'),
				[3] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Chanson.png'),
				[4] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Dacha.png'),
				[5] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Road.png'),
				[6] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Mayak.png'),
				[7] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Nashe.png'),
				[8] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/LoFi Hip-Hop.png'),
				[9] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/Maximum.png'),
				[10] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/90s Eurodance.png'),
			}
		end
	else
		sampAddChatMessage(script_tag..'{FFFFFF}������ ����������� �������. ���������� ����� ����� ��������� ������...', color_tag)
	end
end)

skin = {}
function skin.Button(text_button, x_button, y_button, x_size_button, y_size_button, function_button)
	local stylecol = false
	local invtext = false
	if x_size_button == nil then
		x_size_button = 100
	end
	if y_size_button == nil then
		y_size_button = 35
	end
	if text_button:find('false_func') then
		stylecol = true
		text_button = text_button:gsub('##false%_func', '')
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
	end
	if text_button:find('false_non') then
		stylecol = true
		invtext = true
		text_button = text_button:gsub('##false%_non', '')
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
		imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.50, 0.50, 0.30))
	end
	local fiks_text = text_button
	if text_button:find('##') then
		text_button = text_button:gsub('##(.+)', '')
	end
	local calc = imgui.CalcTextSize(text_button)
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(x_button, y_button))
	if imgui.Button(u8'##'..fiks_text, imgui.ImVec2(x_size_button, y_size_button)) then
		if function_button ~= nil then
			function_button()
		end
	end
	if stylecol then
		imgui.PopStyleColor(3)
	end
	imgui.PopFont()
	
	imgui.SetCursorPos(imgui.ImVec2(x_button + ( (x_size_button/2) - calc.x / 2 ), y_button + (y_size_button / 2) - 8))
	if not invtext then
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
	else
		if setting.int.theme == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.70))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.30))
		end
	end
	imgui.Text(text_button)
	imgui.PopStyleColor(1)
end

function skin.CheckboxOne(text_checkbox_one, x_pos_checkbox_one, y_pos_checkbox_one, param_checkbox_one) 
	local func_yes_or_no = false
	local non_text_checkbox = {}
	if setting.int.theme == 'White' then
		non_text_checkbox = {imgui.ImVec4(0.60, 0.60, 0.60, 1.00), imgui.ImVec4(0.70, 0.70, 0.70, 1.00)}
	else
		non_text_checkbox = {imgui.ImVec4(0.17, 0.17, 0.17, 1.00), imgui.ImVec4(0.27, 0.27, 0.27, 1.00)}
	end
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one - 5, y_pos_checkbox_one - 2))
	if imgui.InvisibleButton(u8'##21'..text_checkbox_one, imgui.ImVec2(20, 20)) then func_yes_or_no = true end
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one + 5, y_pos_checkbox_one + 8))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemActive() then
		if text_checkbox_one:find('false_func') then
			text_checkbox_one = text_checkbox_one:gsub('##false%_func', '')
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 7, imgui.GetColorU32(non_text_checkbox[1]), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 7, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00)), 60)
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 3.3, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 3.3, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
			end
		end
	else
		if text_checkbox_one:find('false_func') then
			text_checkbox_one = text_checkbox_one:gsub('##false%_func', '')
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 8, imgui.GetColorU32(non_text_checkbox[2]), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.3), 8, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 60)
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 4, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.2, p.y + 0.3), 4, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
			end
		end
	end
	if text_checkbox_one:find('##') then
		text_checkbox_one = text_checkbox_one:gsub('##(.+)', '')
	end
	imgui.SetCursorPos(imgui.ImVec2(x_pos_checkbox_one + 20, y_pos_checkbox_one))
	imgui.Text(text_checkbox_one)
	imgui.PopFont()
	
	return func_yes_or_no
end

function skin.InputText(x_pos_input_text, y_pos_input_text, hint_text, arg_var_next_buf, buffer_size, input_text_size, filter_buf, saving_it, text_flag)
	local tbl_per = {}
	local arg_buf_format
	local saveinter
	local ret_enter = false
	if arg_var_next_buf:find('%.') then
		for word in arg_var_next_buf:gmatch('([%w_]+)%.?') do
			if word:find('^%d+$') then
				word = tonumber(word)
			end
			table.insert(tbl_per, word)
		end
	else
		tbl_per = {arg_var_next_buf}
	end
	if #tbl_per == 1 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]]), buffer_size)
	elseif #tbl_per == 2 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]]), buffer_size)
	elseif #tbl_per == 3 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]]), buffer_size)
	elseif #tbl_per == 4 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]]), buffer_size)
	elseif #tbl_per == 5 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]]), buffer_size)
	elseif #tbl_per == 6 then
		arg_buf_format = imgui.ImBuffer(tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]]), buffer_size)
	end
	if arg_buf_format.v == 'nil' then
		arg_buf_format.v = ''
	end
	saveinter = arg_buf_format.v
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text, y_pos_input_text - 3))
	local p = imgui.GetCursorScreenPos()
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text, y_pos_input_text))
	if setting.int.theme == 'White' then
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + input_text_size, p.y + 28), imgui.GetColorU32(imgui.ImVec4(0.78, 0.78, 0.78, 1.00)), 8, 15)
	else
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + input_text_size, p.y + 28), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30, 1.00)), 8, 15)
	end
	imgui.PushItemWidth(input_text_size)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	if text_flag == 'enterflag' then
		if imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.EnterReturnsTrue) then ret_enter = true end
	else
		if filter_buf ~= nil then
			if filter_buf:find('num') then
				imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.CharsDecimal)
			else
				imgui.InputText('##'..u8(hint_text), arg_buf_format, imgui.InputTextFlags.CallbackCharFilter, filter(1, filter_buf))
			end
		else
			imgui.InputText('##'..u8(hint_text), arg_buf_format)
		end
	end
	
	if hint_text:find('##') then
		hint_text = hint_text:gsub('##(.+)', '')
	end
	imgui.PopStyleColor(1)
	imgui.SetCursorPos(imgui.ImVec2(x_pos_input_text + 10, y_pos_input_text + 2))
	if not imgui.IsItemActive() and arg_buf_format.v == '' then
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), hint_text)
	end
	if #tbl_per == 1 then
		_G[tbl_per[1]] = arg_buf_format.v
	elseif #tbl_per == 2 then
		_G[tbl_per[1]][tbl_per[2]] = arg_buf_format.v
	elseif #tbl_per == 3 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = arg_buf_format.v
	elseif #tbl_per == 4 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = arg_buf_format.v
	elseif #tbl_per == 5 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = arg_buf_format.v
	elseif #tbl_per == 6 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = arg_buf_format.v
	end
	
	if saving_it ~= nil and arg_buf_format.v ~= saveinter then
		save(saving_it)
	end
	
	if ret_enter then return true else return false end
end

function skin.EmphText(text_emph, x_emph_text, y_emph_text, text_info)
	imgui.SetCursorPos(imgui.ImVec2(x_emph_text, y_emph_text))
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
	imgui.Text(text_emph)
	imgui.PopStyleColor(1)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
	if imgui.IsItemHovered() and text_info ~= nil then
		imgui.SetTooltip(text_info)
	end
	imgui.PopStyleColor(1)
end

function skin.DrawFond(pos_draw, pos_plus_imvec2, size_plus_imvec2, col_draw_imvec4, radius_draw, flag_draw)
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_plus_imvec2[1], p.y + pos_plus_imvec2[2]), imgui.ImVec2(p.x + size_plus_imvec2[1], p.y + size_plus_imvec2[2]), imgui.GetColorU32(col_draw_imvec4), radius_draw, flag_draw)
end

function skin.List(pos_s_list, select_s_list, all_s_list, length_s_list, par_znach)
	local find_check = select_s_list:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%-', '%%-'):gsub('%.', '%%.')
	local tbl_per = {}
	if par_znach:find('%.') then
		for word in par_znach:gmatch('([%w_]+)%.?') do
			if word:find('^%d+$') then
				word = tonumber(word)
			end
			table.insert(tbl_per, word)
		end
	else
		tbl_per = {par_znach}
	end
	local gete_fg = false
	local func_true_or_false = false
	local num_sel_list = 1
	local calc = imgui.CalcTextSize(select_s_list)

	
	for b = 1, #all_s_list do
		if all_s_list[b]:find('^'..find_check..'$') then
			num_sel_list = b
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
	if interf.list ~= select_s_list..pos_s_list[2] then
		if imgui.Button(u8'##t32y4'..select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then
			if interf.list ~= select_s_list..pos_s_list[1]..pos_s_list[2] then
				interf.list = select_s_list..pos_s_list[1]..pos_s_list[2]
				gete_fg = true
			else
				interf.list = ''
			end
		end
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1] - 2 + ( (length_s_list / 2) - calc.x / 2 ), pos_s_list[2] + (30 / 2) - 8))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.Text(select_s_list)
		imgui.PopStyleColor(1)
		imgui.PopFont()
	end

	imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
	if interf.list == select_s_list..pos_s_list[1]..pos_s_list[2] then
		imgui.SetCursorPos(imgui.ImVec2(pos_s_list[1], pos_s_list[2]))
		imgui.BeginChild(select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, (#all_s_list + 1) * 30), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			if imgui.InvisibleButton(u8'##t32y4'..select_s_list..all_s_list[1]..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) and not gete_fg then
				interf.list = ''
			end
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 3)
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(- 2 + ( (length_s_list / 2) - calc.x / 2 ), (30 / 2) - 8))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			imgui.Text(select_s_list)
			imgui.PopStyleColor(1)
			imgui.PopFont()
			
			for n = 1, #all_s_list do
				imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
				local p = imgui.GetCursorScreenPos()
				local get_w_d_l = imgui.ImVec4(0.30, 0.30, 0.30, 0.95)
				local get_w_d_l_c = imgui.ImVec4(0.20, 0.20, 0.20, 0.99)
				local get_w_d_l_c_line = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
				if setting.int.theme == 'White' then
					get_w_d_l = imgui.ImVec4(0.75, 0.75, 0.75, 0.95)
					get_w_d_l_c = imgui.ImVec4(0.65, 0.65, 0.65, 0.99)
					get_w_d_l_c_line = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
				end
				if n == 1 then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 0, 0)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 0, 0)
					end
					if not imgui.IsItemHovered() then
						
					end
					imgui.SetCursorPos(imgui.ImVec2(0, (30 * n) + 30))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 1), imgui.GetColorU32(get_w_d_l_c_line), 0, 0)
				elseif n ~= #all_s_list then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 0, 0)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 0, 0)
					end
					
					imgui.SetCursorPos(imgui.ImVec2(0, (30 * n) + 30))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 1), imgui.GetColorU32(get_w_d_l_c_line), 0, 0)
				elseif n == #all_s_list then
					imgui.SetCursorPos(imgui.ImVec2(0, 30 * n))
					if imgui.InvisibleButton(u8'##t32ky4'..select_s_list..all_s_list[1]..n..pos_s_list[1]..pos_s_list[2], imgui.ImVec2(length_s_list, 30)) then select_s_list = all_s_list[n] func_true_or_false = true interf.list = '' end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l_c), 8, 12)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + length_s_list, p.y + 30), imgui.GetColorU32(get_w_d_l), 8, 12)
					end
				end
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(27, (30 * n) + 6))
				imgui.Text(all_s_list[n])
				imgui.PopFont()
				
				if num_sel_list == n then
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(6, (30 * n) + 6))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHECK)
					imgui.PopFont()
				end
			end
		imgui.EndChild()
	end
	if imgui.IsMouseReleased(0) and not imgui.IsItemHovered() and interf.list == select_s_list..pos_s_list[1]..pos_s_list[2] then
		interf.list = ''
	end
	if func_true_or_false then
		if #tbl_per == 1 then
			_G[tbl_per[1]] = select_s_list
		elseif #tbl_per == 2 then
			_G[tbl_per[1]][tbl_per[2]] = select_s_list
		elseif #tbl_per == 3 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = select_s_list
		elseif #tbl_per == 4 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = select_s_list
		elseif #tbl_per == 5 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = select_s_list
		elseif #tbl_per == 6 then
			_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = select_s_list
		end
	end
	
	return func_true_or_false
end

function skin.Switch(namebut, bool)
    local rBool = false
    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
    local function ImSaturate(f)
        return f < 0.06 and 0.06 or (f > 1.0 and 1.0 or f)
    end
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local height = imgui.GetTextLineHeightWithSpacing() * 1.15
    local width = height * 1.35
    local radius = height * 0.30
    local ANIM_SPEED = 0.09
    local butPos = imgui.GetCursorPos()
    if imgui.InvisibleButton(namebut, imgui.ImVec2(width, height)) then
        bool = not bool
        rBool = true
        LastActiveTime[tostring(namebut)] = os.clock()
        LastActive[tostring(namebut)] = true
    end
    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 3, butPos.y + 3.8))
    imgui.Text( namebut:gsub('##.+', ''))
    local t = bool and 1.0 or 0.06
    if LastActive[tostring(namebut)] then
        local time = os.clock() - LastActiveTime[tostring(namebut)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(namebut)] = false
        end
    end
	local col_neitral = 0xFF606060
	if setting.int.theme == 'White' then
		col_neitral =  0xFFD4CFCF
	end
    local col_static = 0xFFFFFFFF
    local col = bool and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)) or col_neitral
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 7.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3), p.y + 4 + radius), radius - 0.75, col_static)

    return rBool
end

function skin.Slider(slider_text, slider_arg, slider_min, slider_max, slider_width, slider_pos, saving_it)
	local function convert(param)
		param = tonumber(param) * 100
		return round(param, 1)
	end
	local tbl_per = {}
	local arg_buf_format
	local pere_arg
	local saveinter
	local tap_slid = false
	if slider_arg:find('%.') then
		for word in slider_arg:gmatch('([%w_]+)%.?') do
		if word:find('^%d+$') then
			word = tonumber(word)
		end
		   table.insert(tbl_per, word)
		end
	else
		tbl_per = {slider_arg}
	end
	if #tbl_per == 1 then
		pere_arg = tostring(_G[tbl_per[1]])
	elseif #tbl_per == 2 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]])
	elseif #tbl_per == 3 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]])
	elseif #tbl_per == 4 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]])
	elseif #tbl_per == 5 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]])
	elseif #tbl_per == 6 then
		pere_arg = tostring(_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]])
	end
	arg_buf_format = tonumber(pere_arg)
	arg_buf_format = imgui.ImFloat(arg_buf_format)
	if arg_buf_format.v == 'nil' then
		arg_buf_format.v = ''
	end
	saveinter = arg_buf_format.v

	local slider_width_end = (slider_width-15) / slider_max
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1]+5, slider_pos[2]+9))
	local p = imgui.GetCursorScreenPos()
	local DragPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1], slider_pos[2]))
	imgui.PushItemWidth(slider_width)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.SliderFloat(u8'##'..slider_text, arg_buf_format, slider_min, slider_max, u8'')
	imgui.PopStyleColor(3)
	
	local col_sl_non = imgui.ImVec4(0.60, 0.60, 0.60 ,1.00)
	local col_sl_circle = imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)
	if setting.int.theme == 'White' then
		col_sl_non = imgui.ImVec4(0.83, 0.81, 0.81 ,1.00)
	end
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + slider_width - 15, p.y + 5), imgui.GetColorU32(col_sl_non), 10, 15)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (arg_buf_format.v * slider_width_end), p.y + 5), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3] ,1.00)), 10, 15)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (arg_buf_format.v * slider_width_end), p.y + 2), 9, imgui.GetColorU32(col_sl_circle), 60)
	imgui.SameLine()
	if not slider_text:find('##') then
		imgui.PushFont(font[1])
		imgui.Text(slider_text)
		imgui.PopFont()
	end
	
	if #tbl_per == 1 then
		_G[tbl_per[1]] = arg_buf_format.v
	elseif #tbl_per == 2 then
		_G[tbl_per[1]][tbl_per[2]] = arg_buf_format.v
	elseif #tbl_per == 3 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]] = arg_buf_format.v
	elseif #tbl_per == 4 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]] = arg_buf_format.v
	elseif #tbl_per == 5 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]] = arg_buf_format.v
	elseif #tbl_per == 6 then
		_G[tbl_per[1]][tbl_per[2]][tbl_per[3]][tbl_per[4]][tbl_per[5]][tbl_per[6]] = arg_buf_format.v
	end
	
	if saving_it ~= nil and arg_buf_format.v ~= saveinter then
		save(saving_it)
		tap_slid = true
	end
	
	return tap_slid
end


sampRegisterChatCommand('ic', function() win.icon.v = not win.icon.v end)
window = {}
function window.main_first_start()
	imgui.SetNextWindowPos(imgui.ImVec2(interf.main.anim_win.x, interf.main.anim_win.y), interf.main.cond, imgui.ImVec2(0.5, 0.5)) -- 
	imgui.SetNextWindowSize(imgui.ImVec2(interf.main.size.x, interf.main.size.y))
	imgui.Begin('Window Main first start', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	if interf.main.func or interf.main.anim_win.move then
		interf.main.cond = imgui.Cond.Always
	else
		interf.main.cond = imgui.Cond.FirstUseEver
	end
	if interf.main.func then
		interf.main.func = false
	end
	
	imgui.SetCursorPos(imgui.ImVec2(828, 428))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.25, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y + 0.1 + start_pos + new_pos), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 788, p.y - 0.1 + start_pos + new_pos), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 788, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
	skin.DrawFond({4, 4}, {0, 0}, {860, 460}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 42, 15)
	imgui.SetCursorPos(imgui.ImVec2(18, 16))
	if imgui.InvisibleButton(u8'##������� ����', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
		pos_win_closed = imgui.GetWindowPos()
		styleAnimationClose('Main', interf.main.size.x, interf.main.size.y)
		interf.main.anim_win.par = false
	end
	imgui.SetCursorPos(imgui.ImVec2(28, 26))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(24, 19))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	if not first_start_anim.text[1] and not first_start_anim.done[1] then
		first_start_anim.text[1] = true
	end
	
	if first_start_anim.text[2] or first_start_anim.text[3] or first_start_anim.text[4] or first_start_anim.text[5] or first_start_anim.text[6]then
		local function text_big_main_screen(text_big, vis_texte)
			imgui.PushFont(bold_font[2])
			local calc = imgui.CalcTextSize(text_big)
			imgui.SetCursorPos(imgui.ImVec2((434 - calc.x / 2 ), first_start_anim.pos[2]))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, vis_texte), text_big)
			imgui.PopFont()
		end
		if first_start_anim.text[2] then
			text_big_main_screen(u8'�������� ����������', first_start_anim.vis[2])
		elseif first_start_anim.text[3] then
			text_big_main_screen(u8'�������� �����������', 1.00)
		elseif first_start_anim.text[4] then
			text_big_main_screen(u8'��� ������� �� �������', 1.00)
		elseif first_start_anim.text[5] then
			text_big_main_screen(u8'���������������� ����������', first_start_anim.vis[2])
		elseif first_start_anim.text[6] then
			text_big_main_screen(u8'����������', first_start_anim.vis[2])
		end
	end
	
	local result_time = os.clock() - t_pr[1]
	if result_time > 0.12 then result_time = 0.12 end
	t_pr[1] = os.clock()
	
	if first_start_anim.text[1] then
		imgui.PushFont(bold_font[2])
		imgui.SetCursorPos(imgui.ImVec2(338, 200))
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, first_start_anim.vis[1]), u8'������')
		imgui.PopFont()
		
		if first_start_anim.vis[1] < 1.6 and not first_start_anim.done[1] then
			first_start_anim.vis[1] = first_start_anim.vis[1] + 0.7 * result_time
		else
			first_start_anim.done[1] = true
			first_start_anim.vis[1] = first_start_anim.vis[1] - 0.7 * result_time
			if first_start_anim.vis[1] < 0 then
				first_start_anim.text[1] = false
				first_start_anim.text[2] = true
			end
		end
	end
	if first_start_anim.text[2] then
		if first_start_anim.vis[2] < 1.6 and not first_start_anim.done[2] then
			first_start_anim.vis[2] = first_start_anim.vis[2] + 0.7 * result_time
		else
			if first_start_anim.pos[2] > 80 then
				first_start_anim.pos[2] = first_start_anim.pos[2] - 310 * result_time
			else
				if buf_setting.theme[1].v then
					skin.DrawFond({199, 169}, {- 1.0,- 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				if buf_setting.theme[2].v then
					skin.DrawFond({469, 169}, {- 1.0, - 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				skin.DrawFond({200, 170}, {0, 0}, {200, 109}, imgui.ImVec4(1.00, 1.00, 1.00, 1.00), 15, 15)
				skin.DrawFond({200, 170}, {0, 0}, {40, 109}, imgui.ImVec4(0.91, 0.89, 0.76, 0.80), 15, 9)
				
				skin.DrawFond({205, 185}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 208}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 231}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({205, 255}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({300, 185}, {0, 0}, {40, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 208}, {0, 0}, {130, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 231}, {0, 0}, {70, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({250, 255}, {0, 0}, {110, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				
				skin.DrawFond({470, 170}, {0, 0}, {200, 109}, imgui.ImVec4(0.08, 0.08, 0.08, 1.00), 15, 15)
				skin.DrawFond({470, 170}, {0, 0}, {40, 109}, imgui.ImVec4(0.15, 0.13, 0.13, 0.70), 15, 9)
				
				skin.DrawFond({475, 185}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 208}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 231}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({475, 255}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({570, 185}, {0, 0}, {40, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 208}, {0, 0}, {130, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 231}, {0, 0}, {70, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({520, 255}, {0, 0}, {110, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				
				if not buf_setting.theme[1].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(274, 300))
				imgui.Text(u8'�������')
				
				if buf_setting.theme[1].v then
					if skin.CheckboxOne(u8'##whitebox', 295, 330) then
						
					end
				else
					if skin.CheckboxOne(u8'##whitebox##false_func', 295, 330) then
						buf_setting.theme[1].v = true
						buf_setting.theme[2].v = false
						setting.int.theme = 'White'
					end
				end
				imgui.PopStyleColor(3)
				if not buf_setting.theme[2].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end
				
				imgui.SetCursorPos(imgui.ImVec2(546, 300))
				imgui.Text(u8'Ҹ����')
				if buf_setting.theme[2].v then
					if skin.CheckboxOne(u8'##blackebox', 565, 330) then
						
					end
				else
					if skin.CheckboxOne(u8'##blackbox##false_func', 565, 330) then
						buf_setting.theme[1].v = false
						buf_setting.theme[2].v = true
						setting.int.theme = 'Black'
					end
				end
				imgui.PopStyleColor(3)
				
				skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
				skin.Button(u8'����������', 630, 400, nil, nil, function() 
					first_start_anim.text[2] = false
					first_start_anim.text[3] = true
				end)
				skin.Button(u8'�����##false_non', 515, 400, nil, nil, function() end)
				skin.EmphText(u8'������ ���������', 140, 410, u8'��������� ���� ���������� ����� ������������\n�� ���� ����� ���������.\n\n���� ����� ����� �������� � ����������.')
				imgui.PopFont()
			end
		end
	end
	if first_start_anim.text[3] then
		local carta_org = {u8'�������� ��', u8'�������� ��', u8'�������� ��', u8'�������� ����������', u8'����� ��������������', u8'�������������', u8'���'}
		for i = 1, #carta_org do
			if num_of_the_selected_org == i then
				setting.frac.org = carta_org[i]
			end
		end
		imgui.PushFont(font[1])
		if num_of_the_selected_org == 1 then
			if skin.CheckboxOne(u8'�������� ��', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'�������� ��' end
		else
			if skin.CheckboxOne(u8'�������� ��##false_func', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'�������� ��' end
		end
		if num_of_the_selected_org == 2 then
			if skin.CheckboxOne(u8'�������� ��', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'�������� ��' end
		else
			if skin.CheckboxOne(u8'�������� ��##false_func', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'�������� ��' end
		end
		if num_of_the_selected_org == 3 then
			if skin.CheckboxOne(u8'�������� ��', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'�������� ��' end
		else
			if skin.CheckboxOne(u8'�������� ��##false_func', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'�������� ��' end
		end
		if num_of_the_selected_org == 4 then
			if skin.CheckboxOne(u8'�������� ����������', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'�������� ����������' end
		else
			if skin.CheckboxOne(u8'�������� ����������##false_func', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'�������� ����������' end
		end
		if num_of_the_selected_org == 5 then
			if skin.CheckboxOne(u8'����� ��������������', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'����� ��������������' end
		else
			if skin.CheckboxOne(u8'����� ��������������##false_func', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'����� ��������������' end
		end
		if num_of_the_selected_org == 6 then
			if skin.CheckboxOne(u8'�������������', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'�������������' end
		else
			if skin.CheckboxOne(u8'�������������##false_func', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'�������������' end
		end
		if num_of_the_selected_org == 7 then
			if skin.CheckboxOne(u8'���', 350, 350) then num_of_the_selected_org = 7 setting.frac.org = u8'���' end
		else
			if skin.CheckboxOne(u8'���##false_func', 350, 350) then num_of_the_selected_org = 7 setting.frac.org = u8'���' end
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'����������', 630, 400, nil, nil, function() 
			first_start_anim.text[3] = false
			first_start_anim.text[4] = true
		end)
		skin.Button(u8'�����', 515, 400, nil, nil, function()
			first_start_anim.text[2] = true
			first_start_anim.text[3] = false
		end)
		skin.EmphText(u8'������ ���������', 140, 410, u8'�������� �����������, � ������� �� �������� �� ������ ������.\n��� ������� ��������� ������ ��� ���� ������.')
		imgui.PopFont()
	end
	if first_start_anim.text[4] then
		imgui.PushFont(font[1])
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not setting.nick:find('%S+%s+%S+') then
			skin.Button(u8'����������##false_non', 630, 400, nil, nil, function() end)
		else
			skin.Button(u8'����������', 630, 400, nil, nil, function() 
				first_start_anim.text[4] = false
				first_start_anim.text[5] = true
			end)
		end
		skin.Button(u8'�����', 515, 400, nil, nil, function()
			first_start_anim.text[2] = true
			first_start_anim.text[4] = false
		end)
		skin.EmphText(u8'������ ���������', 140, 410, u8'������� � ���� ����� ��� ������� �� ������� �����.\n��������, �������� ����')
		local my_nickname = sampGetPlayerNickname(my.id):gsub('_',' ')
		skin.InputText(255, 255, u8'��� ��� '..my_nickname..u8' �� �������', 'setting.nick', 74, 350, '[�-�%s]+')
		imgui.PopFont()
	end
	
	if first_start_anim.text[5] then
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(134, 150))
		imgui.BeginChild(u8'���������������� ����������', imgui.ImVec2(600, 217), false)
		imgui.PushFont(font[4])
		imgui.Text(u8'1. �������� ������� � �����������')
		imgui.PopFont()
		imgui.TextWrapped(u8'1.1 ��������������� - ��� ������� ���������: ��� ����, ������� �������� ������� ������������� �� ���������������� �������������, ����� ��� ��������� �����, �������, �������� ����� � ������ �����, ��������� � ��������� � �������������� ���������������� ��������� ��� �����������. ������ "���������������" ����� �������� � ���� ������������, ���������, ���������, ���������� � ������ ������������� ������, ����������� � ��������, ���������� � �������� ��������� (��. ����������� ����). ��� ������������ ������, ���������� ��� ���������������� �������, ������� ����� ����� ������������� ���������� �� ������������� ��������� (��. ����������� ����) � ��������� ������� ������� � ������������ � ������ ������������ ����������� (������ ������� ����� ����� ���������: (������������ (��. ����������� ����) � ���������������), ����� "����������").\n���������������� ������ ��������� (��. ����������� ����), � ����� ����������� ����������� ��������� ���� � ���������������� �������������, �������� ������������ ����. ��� ���� ����, ���������� � ��������, ����������, ��������� � ������ �������� ���������� � ���� ����������� �� ������� ���������������, �� ����������� ������� ������������� �� ���������������� �������������, ����� ��� ��������� �����, �������, �������� ����� � ������ �����, ��������� � ��������� � �������������� ���������������� ��������� ��� ����������� ������� ������������ ����������� (����� "��"), �������� ��������� (����� "������", "�������") ���������������.\n')
		imgui.TextWrapped(u8'������ ��������� � ��, � ������� ��������� ������ ������������ ���������� ��� �� ����� �����������, �������� ��� �������� ��������, ������� ������ ������ ������������ ����� �������, ����� ��� ���������, �� ������� ����������� ��.\n\n')
		imgui.TextWrapped(u8'1.2 ��������� - ��� ��, ������������� ���������������, ������� ���� ����������� � ����������� �� �������� (��. ����������� ����) ������������ ����������. �� ������ ���������� ���������������� ��������, ������ ������ ��������� �� ���� ��, ���������� � ���� �������� �������������� "State Helper", ���������� �� ���������� ����� � ����� �� ��������� ��������� �������� ����.\n������������ �� ����� ����� � ��������� ����� �������������� � ���������� ��������������� � ������, ���� ���� �� ��� �������������� � ����������� ����������� ��� �� �������� (��. ����������� ����) ������������ ����������.\n\n')
		imgui.TextWrapped(u8'1.3 �������� - ���������� ��� ��������, ������������ ��� �������� � �������� ������. ��� ����� ���� ���������� ������, ����� ��� ������ ����, USB-������, CD, DVD, Blu-ray ���� ��� ������ ������� ���������� �������� ����������.\n\n1.4 Arizona Role Play - ��� ������ ������� ���� (Role-Play) �� ��������� SA:MP (San Andreas Multiplayer), ������������� ������� �������� Arizona Games. � ���� ������� ������ ����� ����������������� � ����������� ����, �������� ������������ ���� � �������� ������� � ���������, ��������� �� ���� ���� Grand Theft Auto: San Andreas � �������������� �������������� ��������� SA:MP.\n\n1.5 ����������� ������������ - ��������, ������� �������� ���������� � ���, ��� ��������� ������������ ���������, ��������������� ����������������.\n\n1.6 ������������ - �������, ������������ ��� ������������ ���������, ��������������� ����������������.\n\n1.7 ���������� ��������� - ��� ����������� ��� ����������� ����, ������� ������������� ������������ ������ ������������ � ������������ ��������, ������ ��� �������� ���������.\n\n1.8 �������� - �������������-�������������������� ����, �. �. ��������������� �������, ��������������� ��� �������� �� ������ ����� ����������, ������ � ������� �������������� � �������������� ������� �������������� �������.\n\n1.9 ��������� - ������� ���������� ��������� �� ���������� ��� ����������, ����� ��� ����� ��������� � ������� � �������������. �� ����� ��������� ���������� ����������� ������ ��������� �� ������ ���� ��� ������ ���������� ���������, ����� ���, ������ � ������� ������� ������� ���������.\n\n')
		imgui.TextWrapped(u8'1.10 ���� - ���������� ��� ��������������� ������������, �� ��������� � ����������������� �������� ����������������, ����������� ������� ���������� ������ ��������.\n\n1.11 ������ ��������� - ����������� ����� ���������, ����������� ���������� ������� ��, �. �. ���� ��� ������, � ����� �������� ������������ ���������� ������ ���������.\n������ ��������� ���������� � ����� ��������� ��� ��������������� ��������� ���������� � ���� �������������� ����� "������".\n\n1.12 �������� ������������ - ������� ������������, ��������� ��, ������� ����� ����� �������� ������������ ����� �������� ���������� ��������� � � ��������� ���������� �� �������� ������ ������, ��������� ����������� �������.\n������� �������������� ��� ����� ����������� ���������� ������ �� � ����� ������, ������ ����������� ������ ������������ ����������� ��������� ��.\n������ ����������� � ���������, ������� � ���� ����������� ���� �������� �������� ���������� "Beta" �� ��������������� ������� ����� ������� ������ ���������.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'2. ��������')
		imgui.PopFont()
		imgui.TextWrapped(u8'2.1 ��������������� ������������� ��� ���������������� �������� �� ������������� ��������� ��� ��������� �������� ���� �� ������� Arizona Role Play, ��������� � ����������� ������������, ��� �������, � ������� ���� ��������� ��� ����������� ����������, ��������� � ����������� ������������, � ����� ���� ����������� � ������� ������������� ���������, ��������� � ��������� ����������.\n� ������ ������������� ��������� ��� ������������ ����������������, ��������������� ������������� ��� ���������������� �������� �� ������������ ��������� ��� ������� ���������� ���� ���� ����������� ����������, ��������� � ����������� ������������, � ����� ���� ����������� � ������� ������������� ���������, ��������� � ��������� ����������.\n\n')
		imgui.TextWrapped(u8'2.2 ��� ���������� ����������� ������� �� ������ ������� ����� ��������� ���� "�������� ������������" � ������������ ����� ������������� � ������ ���������� �������������� ���������� � ������ ��� �����, ����������� ��� �������������. ��� �� �����, ������������� ����� ����� ��� ���� ����� ���������, � �������� �� ������ ������������, ���� ��������� ����������� ����������� ��������� ������������.\n\n')
		imgui.TextWrapped(u8'2.3 ����� ��������� ��������� ���, �� �����������, ��������������� ����� �������� �� ��������������� ��� ��� ��������:\n- ����� ������ �� �� ���� �� ������ (����� ��������)\n- ����������� ��������� (����� ��������)\n- ������ � �������������� � ��������������� �������� ���������������.\n������ ����������� �� ����� ���� ������������� ���������������� � � ����� ��������� ���� ���������� ������ ������������ ��������� � ����� ������ ������� ��� ���������� ������.\n\n')
		imgui.TextWrapped(u8'2.4 � ������ ��������� ��������� ���� "�������� ������������" ����� ��������, �� ������ ����� ������������ ����� ����� ��������� ������������� �� ����� ����������� ���������� ��� �������. ���������� ��������� ����� ��������� �� ����� ���������� �������������. ����������� ���������, ��������������, ���������� ����� ����� ��������� ����� �������� ���������, ��� ������ � ��� ����� �������� ������ ����, ����� ���. ����������� ���������� ����� ��������� �� ��������, ���������� ������ � �������� � ��� �����������. ��������� ������������� ����� ����� ��������� �� ����� �������� � ����������, �� ���������� � ��������, ��������� � ������ ����������.\n\n')
		imgui.TextWrapped(u8'2.5 ��������� ��������� ������������� � ������� � ���������� �� �������� ������������, ���������� �� ����, �������� ��� ������������ ������������� ��� ���.\n\n')
		
		imgui.PushFont(font[4])
		imgui.Text(u8'3. ����������')
		imgui.PopFont()
		imgui.TextWrapped(u8'����� ��������� ��������� �� ��������, ��������������� ������������� ����������� ������������� �������� ������ ���������� ���������. ���� ������������ ��� ����� ������������ �������������� ����������, �������� ��������������� ������� � ����� ���������, ����� ���������� ����� ����������� ��� ��������������� ���������� ��� �������� � ��� �������.\n\n� ��������� ������, ���� ������������ �� ������ �������������� ����������, ������� ��������� ���������� ����� ��������� ������������� ������������ � ����� ���������. ������������ ����� ������������� ����������� ������������ � �������� ���������� � ���� �������� �� ��� ��������� ����� ������� ��������.\n\n')
		imgui.TextWrapped(u8'���������� �� ���������� ������� ����������, ������ ���������� ����� �������������� ��������� �����������, � ����������, ������� � ����������� ����������� ��������� ������������ ������������� ����������������. ��� ���������� ����� �������� ��� ����������, ��� � �������� ������� ���������, � ����� ������ ������ ���������. ��� ���� ��� ����� ���� ���������� ������������� ��������� ��� ���������� (������� ������������ �������) �� ��� ���, ���� ���������� �� ����� ��������� ����������� ��� ������������.\n\n��������������� ����� ���������� �������������� ��������� ���������, ���� �� �� ���������� ��� ��������� ����������. ������������� � ������������� �������������� ���������� ������������ ���������������� �� ��� ����������, � ��������������� �� ������ ������������� ��� ����������. ����� ��������������� ����� ���������� �������������� ���������� ��� ������ ���������, �������� �� �������� ����� ������, ��� ��� ����������, ������� �� ������������ ������������� ��������� � ���������� �������� ������������ ������ ��� ������ ��.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'4. ����� �������������')
		imgui.PopFont()
		imgui.TextWrapped(u8'4.1 ��������� � � ����������� ��� �������� ���������������� �������������� ��������������� � �������� ���������� ��������� ������, � ����� �������������� ���������� � ����������������� ���������� ���������. ���� �� ��������� �������������, ������������ ��������� �� �������� ����������, �� �� ������ ����� ������������� �������� ����������� ��� ���������. ������������ ���� ����������� � �����������, ���������� ���������, �� �������������� ��������������� ���������� �� �� ������������� ��� ���������� ����� ��������� ��� ������� ��������� ��� �����. ��� ����, �� ������������, ��� ����� ������������� �� ��������� ������� ����������� � ��������������� ���������� �� ��� �� �������� ��� ������������� ����� ����������.\n\n')
		imgui.TextWrapped(u8'4.2 ������ ��������� � ��������� ����������, �������� ���������� � � ������������� �� ������������� ��� �����-���� ����� �� ��������� ��� ����������� ���, ������� ��������� �����, �������, �������� ����� � ������ ����� ���������������� �������������. ��� ����� ����� ��������� ����������� ��������������� ���������.\n\n')
		imgui.TextWrapped(u8'4.3 �� �� ������ ����� ���������� ��� ������������ ��������� ��� � ����������� ���, �� ����������� �������, ��������� � ������� 2 ���������� ����������.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'5. ������������������')
		imgui.PopFont()
		imgui.TextWrapped(u8'�� ����� ��������������� � �������� ��������������� �������� �� ������������� ����� ������ � ������������ � ��������� ������������������. �� ���������, ��� ���� ������ ����� �������������� ��� ��������� �����, ����� ��� ��������� ������� ������������� ���������, ��������� ���������, �������������� ��� ���������� �� ������������� ��������� � ����������� ��� ������ ��������.\n\n�� ����� �������������, ��� ��������������� ����� ���������� ���� ������ �������� ���������������, ����� ��� ���������� ��������� ����������� ���������, ����������� ��������, ���������� ���������, ����� � �������� �� ����� ���������������, � ����� ����������, ��������������� ��������������� ��� �������� ��������������� ������������� ������ � �������� � ����� � ������ ���������.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'6. ����������� ��������')
		imgui.PopFont()
		imgui.TextWrapped(u8'6.1 ���� �� �������� ����� �� ������������, ������������� � ������ ����������, ������� �������������, ����������� � �������� 2 ��� 5, ��������� ���������� ������������� ����������� � �� �������� ����� �� ��������� ���������� ���������. ��� ������������� ���������, ������� ��������� ����� ���������������, ��������������� ����� ����� ���������� � �������� ��������� ������, ��������������� �����������������. ����� �� ��������������� � �����������, ������������� ��� ��������������� � ������ ����������, ����� ����������� � ����� ��� �����������.\n\n')
		imgui.TextWrapped(u8'6.2 ��������������� ����� ����� ��������� ��� � ���������� �������� ������� ���������� ������������ ���������� ��������� ��� ���� �������� � ����� ������� �����. ����� ������������ ����������� �������� ���������� �� ������� ����� �� ������������� ���������.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'7. �������� ��������� ��������������� ������')
		imgui.PopFont()
		imgui.TextWrapped(u8'7.1 ��������������� �� ���� ������� ��������������� � ��������� �������:\n\n7.1.1 ��������� �� �������� ������� ������� � ����� � ������������ ������������ ���������, ����������� ��� ������������������ ������������ ���������������� ���������� ��� ��������, �� ������� ����������� ���������, ����������� �������������� ��, ������� ������������ ����������� ������ ���������, ���� ��-�� ����������������� �������������� ������������ ���� ���������.\n\n7.1.2 ��������� ������ � ����� ������� ������� ����������, ����� ��������� ���������.\n\n')
		imgui.TextWrapped(u8'7.1.3 ����� ����� ��� ���������� ����� ��������� ����� � ���������.\n\n7.1.4 ������ ���������������� ������������ �� ����� �������, ���������� ���� ������������ �� ����� ����� ���������� ����������� ������������ ���������.\n\n7.1.5 ������������ ���������� ������������ ���������, �������� ������������ ����������, �� � �����������, �� ����������� ����������, ����� ���������� �� ������������� ���������.\n\n7.1.6 ������������ �� �������� ���������� ���������.\n\n7.1.7 ������������ �� ����� ���������� ����� ��� ��������� ��������� �� ��������.\n\n7.1.8 ������������ �� ����� ����������� ���������� ��������� � ����� � ����������� ��� ������������ ������������ ���������.\n\n7.1.9 ������������ �� ����� ����������� ���������� ��������� � ����� � ������������� � ������ ��� �������, � ������� �� ���������.\n\n7.1.10 ������������ �� ����� ����������� ���������� ��������� � ����� � ��, ����� ������� �� �������� ��������� ���������.\n\n')
		imgui.TextWrapped(u8'7.1.11 ������������ �� ������������� �������� �������� ������ ��������� ��� ��� �������������� �����������.\n\n7.1.12 ������������ �����, ���� ������� ���������� ��� ��������� ������ � ���������� ����������� ����������.\n\n7.2 ������������ ���� ������ ��������������� ����� ���������������� �� ���������� ������� ����������.\n\n7.3 ��������� ��������������� �� ������������� �������� ���� ����� (as is). ��������������� �� ����������� ������������ � ������������� ������ ���������, � ��������� �����������, ����������������, �����-���� ����� � ��������� ������������, � ����� �� ������������� ������� ���� ��������, ����� �� ��������� � ����������.\n\n7.4 ��������������� ������ �������� ������� ���������� ���������� � ����� ������ ������� ��� ���������������� ����������� ������������ �� ����.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'8. ����� ���������')
		imgui.PopFont()
		imgui.TextWrapped(u8'8.1 �����������. � ������������ ����� ��������� ����� ��������� ��� ����������� �� ����������� �����, ����� ����������� ����, ���������� ���� ��� ������ ��������, ���� ���� � ��������� ������� �� ������ �� �������� ����������� �� ��� ���, ���� �� ��������� ���������. ����� ����������� ��������� ������������ � �������, ����� ��������������� ������ ��� ��������� ����� ���������, ���������� �� ������������ ������� ���������.\n\n8.2 ������� �� ������� ����������. ���� � ��� ��������� ������� ������������ ������� ���������� ��� ����������� �������� �������������� ���������� �� ���������������, ���������� �� ���������� ���� ������ ����������� �����: morte4569@vk.com.\n\n')
		imgui.TextWrapped(u8'8.3 ���������� ���������� ������������. � ������ �����-���� ����� ��� �������� ������������������, ��������� ��� �������� ������������� ��������������� ���������� � �������������� ������������ ����� (������� ��������������), ���������� � ������������ � ���������, �������������� �������������������� ��� �������������-��������������� �����, ��������������� ��������������������� ��� ��-������������, ������������ � ������� ��������� �������, ����������������� ������, DDoS-������� � ������� ������� � ����������� ��-���������, ���������� ���������� ��� ����������������, ������� ��������� ��� �������� ���������������, ������� ����������, �������, ������, �����, ����. ������� ��������, ���������, ������� � ������ �������������� ������������� ����, � ����� ������ ������� ���������, ������� �� ��������� ������������� ������� �� ������� ���������������, ��������������� ������������� �� ��������������� �� ����� �������.\n\n')
		imgui.TextWrapped(u8'8.4 �������� ���� � ������������. ��� �� ����������� ���������� ���� ����� ��� �������������, ������������� ��������� �����������, ��� ���������������� ����������� �������� ���������������. ����� ��������, ��������������� ������ �������� ��������� ���������� � ����� ������ �� ������ ����������, ��� ������������� ��������� ������ ���������������� �������� � ���������� �����.\n\n8.5 ����������� � ���������. ��� ������ ��������� ���������� ���������� �������� � ���������� ����������� � ���������. �� ����������� ����������� ��������� � ����������� ��������-���������� �������� ����� ������������.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'9. ��������������� ������ ��� ������������� ���������')
		imgui.PopFont()
		imgui.TextWrapped(u8'9.1 ��������� �������� �������� ����������, �������������� ���� �������� ������ �� ��� �� ��������, �� ������� ����������� ���������.\n\n9.2 ��� ��������� � ������� ���������, ������������ �������� ��� �������� �� ��������� ��������������� ���������� ����������� ������ ��� ������ ��������� � ������������ ����������� ������ � �������� jpg, png, ttf, json, lua � txt � ����� ������ ������� � �������� ������ ���������, � ����� �� ��������� ������ ������ �������, �� ������������ 8589934592 ���.\n\n9.3 ������������ ����������� � ���, ��� ��������� ����� ����� �� �������������� ���������� ����������� � ������ ������������� ������ � �������� � ������, ��� ���������������� ����������� ������������ ��������� �� ����.\n\n9.4 ������������ ��������� ���� � ����������� � ���, ��� � ����� ������ ������� �� ����� ������� ��������� ��� � ����� ����� ���� ������������ ���������� � ����� � ������ ���������.\n\n')
		imgui.TextWrapped(u8'9.5 ��������������� �� ���� ��������������� � ������ ���� ������������ ������� ������������ (����� "��"), ������� ����� �������� � ��������� ��� ���������� ������������� ����������� ��, � ����� � ���������� ����������� �� � �������� ������������ � ���� ���������� ���������.\n\n9.6 ��������������� �� ���� ��������������� �� ������, ���������� ������������� ��� ������������� ���������, ������� ����� ������� �������� � ���� ����, � ����� ����� �������� � ������������ � ������������� ����, ������� ���������� �������� ��������.\n\n9.7 ��������������� ������� ��������������� �� ���������� �����, ������� �����, ���������������, ������������� ������������� ������ ������ ������������ � ��� ������������ ��������. ��������������� ��������� �� ���� ���������������, ��� ������� ��������� ��������� �� ������������ ���� � ���� ��������������� ���������, ��� ��������������� ������ ��������������� �������� 273 ��. ���������� ������� ���������� ��������� (������ ���������� ���������������) � ������ ��������������� ����������� �������� �� ����������� ���������� ��� ����������� �������� ������������.\n')
		imgui.TextWrapped(u8'��������������� ����������� ���������� ����������� ������, ����������� �������� � ����������� � ��������� � ������������ �� ������.\n\n9.8 ��������������� ������ ���������� ������������ ����������� ������ ����, ������ ����������, ����� ������������ �����������, � ����� ������ �������, � ����� ���������� � ��� ���������������� �������������� ������������ �� ���� ������� � ����� ���������.\n\n9.9 ��������������� ������� ��������� ������������ � �������� � ������ ������������ ����������, �������� ���������� ��� �������� ������ ������ ����������, ������� ����������� ��������������� ��� ���� ������� ����� ���������� � ���� � ������. ������������ ����������� � ���� ��������.')
		imgui.EndChild()
		
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'�������', 630, 400, nil, nil, function()
			first_start_anim.text[5] = false
			first_start_anim.text[6] = true
		end)
		skin.Button(u8'�����', 515, 400, nil, nil, function()
			first_start_anim.text[4] = true
			first_start_anim.text[5] = false
		end)
		skin.EmphText(u8'������ ���������', 140, 410, u8'������ ���������������� ����������, �� ������������\n� ��������� ������ ���������.')
		imgui.PopFont()
	end
	
	if first_start_anim.text[6] then
		imgui.PushFont(font[1])
		
		skin.DrawFond({275, 242}, {-0.5, 0}, {24, 24}, imgui.ImVec4(0.35, 0.35, 0.35 ,1.00), 5, 15)
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(279, 248))
		imgui.Text(fa.ICON_COG)
		imgui.PopFont()
		imgui.PopStyleColor(1)
		imgui.SetCursorPos(imgui.ImVec2(310, 246))
		if not type_version.rel then
			imgui.Text(u8'�� �������! � ��� ��������� ������ �������.')
		else
			imgui.Text(u8'������� ���������� �� ������ '..new_version.version)
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not type_version.rel then
			skin.Button(u8'���������', 630, 400, nil, nil, function()
				first_start_anim.text[6] = false
				setting.int.first_start = false
				setting.info_about_new_version = false
				add_table_act(setting.frac.org, true)
				save('setting')
				create_act(1)
			end)
		else
			if not off_butoon_end then
				skin.Button(u8'��������', 630, 400, nil, nil, function()
					setting.int.first_start = false
					setting.info_about_new_version = false
					add_table_act(setting.frac.org, true)
					save('setting')
					update_download()
					off_butoon_end = true
				end)
			else
				skin.Button(u8'��������##false_non', 630, 400, nil, nil, function() end)
			end
		end
		skin.Button(u8'�����', 515, 400, nil, nil, function()
			first_start_anim.text[5] = true
			first_start_anim.text[6] = false
		end)
		skin.EmphText(u8'������ ���������', 140, 410, u8'���������� ����� ��� ���������� ������ ������ �������.\n��� ���������� ������ ���������� ��������� ������.')
		imgui.PopFont()
	end
	imgui.End()
end

local pos_el = {
	r_menu = 1,
	v_el = nil
}

function rp_zona_win()
	local function new_draw(pos_draw, par_dr_y)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)

			if par_dr_y ~= 50 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 24.8, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			
			if par_dr_y ~= 50 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 24.8, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			end
		end
	end
	
	
	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'�� ����', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	
	if select_scene == 0 then
		if not setting.rp_zone then
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(93, 155 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'����� �� ������ ������� Role Play SS ��� ������ ������')
			imgui.SetCursorPos(imgui.ImVec2(168, 185 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'����� � ���� ��� ��������� ��������!')
			imgui.PopFont()
			imgui.PushFont(font[1])
			skin.Button(u8'������', 270, 225 + ((start_pos + new_pos) / 2), 125, 35, function()
				setting.rp_zone = true
				save('setting')
			end)
			imgui.PopFont()
		else
			if #scene.bq == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(258, 159 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'��� ����')
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'�������� �����', 270, 212 + ((start_pos + new_pos) / 2), 125, 35, function()
					local new_scene = {
						nm = u8'����� '..(#scene + 1),
						pos = {x = 20, y = 20},
						size = 13,
						dist = 21,
						vis = 255,
						flag = 5,
						invers = false,
						qq = {}
					}
					table.insert(scene.bq, new_scene)
					col_sc = {}
					save('scene')
					scene_buf = new_scene
					font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag)
					select_scene = #scene.bq
					edit_sc = true
				end)
				imgui.PopFont()
			else
				new_draw(17, -1 + (#scene.bq * 68))
				imgui.PushFont(font[1])
				for i = 1, #scene.bq do
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##������� � �������� �����'..i, imgui.ImVec2(666, 68)) then 
						POS_Y = 380
						col_sc = {}
						if scene.bq[i].qq ~= 0 then
							for m = 1, #scene.bq[i].qq do
								table.insert(col_sc, convert_color(scene.bq[i].qq[m].color))
							end
						end
						scene_buf = scene.bq[i]
						font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag)
						select_scene = i
						edit_sc = true
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemActive() then
						if i == 1 and #scene.bq ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 3)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 3) -- ������ ��� ����
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						elseif i == 1 and #scene.bq == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 15)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 15) -- ���������
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end 
						elseif i == #scene.bq then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 12)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 12) -- ���� ��� ����
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 0) -- �������
							end
						end
					end
					imgui.PushFont(fa_font[5])
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(17, 41 + ( (i - 1) * 68)))
					imgui.Text(scene.bq[i].nm)
				end
				if #scene.bq > 1 then
					for draw = 1, #scene.bq - 1 do
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
					end
				end
				skin.Button(u8'�������� �����', 270, 34 + (#scene.bq * 68), 125, 35, function()
					local new_scene = {
						nm = u8'����� '..(#scene + 1),
						pos = {x = 20, y = 20},
						size = 13,
						dist = 21,
						vis = 255,
						flag = 5,
						invers = false,
						qq = {}
					}
					table.insert(scene.bq, new_scene)
					col_sc = {}
					save('scene')
					scene_buf = new_scene
					select_scene = #scene.bq
					edit_sc = true
				end)
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 20))
		end
	else
		imgui.PushFont(font[1])
		new_draw(17, 84)
		skin.Button(u8'��������� �����', 15, 29, 202, 30, function() 
			scene.bq[select_scene] = scene_buf
			save('scene')
			select_scene = 0
			edit_sc = false
		end)
		skin.Button(u8'������� �����', 232, 29, 202, 30, function()
			imgui.OpenPopup(u8'�������� �����')
			
		end)
		skin.Button(u8'�������� �����', 449, 29, 202, 30, function()
			scene_active = true
			scene_edit_i = false
			win.main.v = false
			imgui.ShowCursor = false
			displayRadar(false)
			displayHud(false)
			lockPlayerControl(true)
			posX, posY, posZ = getCharCoordinates(playerPed)
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			angZ = getCharHeading(playerPed)
			angZ = angZ * -1.0
			angY = 0.0
			sampTextdrawDelete(449)
		end)
		if imgui.BeginPopupModal(u8'�������� �����', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(15, 12))
			imgui.Text(u8'�� �������, ��� ������ ������� ��� �����?     ')
			skin.Button(u8'�������##�����', 15, 40, 145, 30, function() 
				table.remove(scene.bq, select_scene)
				save('scene')
				select_scene = 0
				edit_sc = false
				imgui.CloseCurrentPopup()
			end)
			skin.Button(u8'��������##�����', 170, 40, 145, 30, function() imgui.CloseCurrentPopup() end)
			imgui.PopFont()
			imgui.Dummy(imgui.ImVec2(0, 7))
			imgui.EndPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(15, 73))
		imgui.Text(u8'����������')
		imgui.SetCursorPos(imgui.ImVec2(620, 72))
		if skin.Switch(u8'##����������', preview_sc) then preview_sc = not preview_sc end
		
		new_draw(113, 50)
		skin.InputText(15, 127, u8'������� ��� �����', 'scene_buf.nm', 80, 636)
		
		new_draw(175, 213)
		if skin.Slider('##������ ������', 'scene_buf.size', 1, 30, 205, {455, 186}, '') then font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag) end
		if skin.Slider('##���� ������', 'scene_buf.flag', 1, 30, 205, {455, 217}, '') then font_sc = renderCreateFont('Arial', scene_buf.size, scene_buf.flag) end
		skin.Slider('##���������� ����� ��������', 'scene_buf.dist', 1, 40, 205, {455, 247})
		skin.Slider('##������������ ������', 'scene_buf.vis', 1, 255, 205, {455, 277})
		imgui.SetCursorPos(imgui.ImVec2(620, 309))
		if skin.Switch(u8'##������������� �����', scene_buf.invers) then scene_buf.invers = not scene_buf.invers end
		imgui.SetCursorPos(imgui.ImVec2(15, 188))
		imgui.Text(u8'������ ������')
		imgui.SetCursorPos(imgui.ImVec2(15, 219))
		imgui.Text(u8'���� ������')
		imgui.SetCursorPos(imgui.ImVec2(15, 249))
		imgui.Text(u8'���������� ����� ��������')
		imgui.SetCursorPos(imgui.ImVec2(15, 279))
		imgui.Text(u8'������������ ������')
		imgui.SetCursorPos(imgui.ImVec2(15, 310))
		imgui.Text(u8'������������� �����')
		skin.Button(u8'�������� ��������� ������', 15, 346, 636, 30, function() scene_edit() end)
		
		local pos_X_sc = 470
		imgui.PushFont(bold_font[4])
		imgui.SetCursorPos(imgui.ImVec2(243, pos_X_sc - 58))
		imgui.Text(u8'���������')
		imgui.PopFont()
		new_draw(pos_X_sc - 12, 58 + (#scene_buf.qq * 95))
		skin.Button(u8'�������� ���������', 238, pos_X_sc + (#scene_buf.qq * 95), 202, 30, function() 
			table.insert(scene_buf.qq, {
				text = '',
				act = '',
				type_color = u8'���� ����� � ����',
				nm = sampGetPlayerNickname(my.id),
				color = 0xFFFFFFFF
			})
			table.insert(col_sc, convert_color(scene_buf.qq[#scene_buf.qq].color))
		end)
		
		local remove_table_qq = nil
		for i = 1, #scene_buf.qq do
			local pos_Y_scene = pos_X_sc + ((i - 1) * 95)
			if scene_buf.qq[i].type_color ~= u8'/todo' then
				skin.InputText(15, pos_Y_scene, u8'����� ���������##'..i, 'scene_buf.qq.'..i..'.text', 300, 595)
			else
				skin.InputText(15, pos_Y_scene, u8'����� ����##'..i, 'scene_buf.qq.'..i..'.text', 300, 290)
				skin.InputText(320, pos_Y_scene, u8'����� ���������##'..i, 'scene_buf.qq.'..i..'.act', 300, 290)
			end
			local scroll_bool = false
			if skin.List({15, pos_Y_scene + 35}, scene_buf.qq[i].type_color, {u8'���� ����� � ����', u8'/me', u8'/do', u8'/todo', u8'����', u8'�������'}, 200, 'scene_buf.qq.'..i..'.type_color', '') then
			end
			if scene_buf.qq[i].type_color == u8'���� ����� � ����' then
				imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
				imgui.Text(u8'����')
				imgui.SetCursorPos(imgui.ImVec2(270, pos_Y_scene + 40))
				if imgui.ColorEdit4('##Color'..i, col_sc[i], imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
					local c = imgui.ImVec4(col_sc[i].v[1], col_sc[i].v[2], col_sc[i].v[3], col_sc[i].v[4])
					local argb = imgui.ColorConvertFloat4ToARGB(c)
					scene_buf.qq[i].color = imgui.ColorConvertFloat4ToARGB(c)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
				imgui.Text(u8'��� ���������')
				skin.InputText(340, pos_Y_scene + 39, u8'��� ���������##'..i, 'scene_buf.qq.'..i..'.nm', 150, 270)
			end
			imgui.SetCursorPos(imgui.ImVec2(632, pos_Y_scene - 1))
			if imgui.InvisibleButton(u8'##�������'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(636, pos_Y_scene + 4))
			imgui.Text(fa.ICON_TRASH)
			imgui.PopFont()
			
			skin.DrawFond({17, pos_Y_scene + 78}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		end
		if remove_table_qq ~= nil then table.remove(scene_buf.qq, remove_table_qq) end
		imgui.PopFont()
		if #scene_buf.qq ~= 0 then
			imgui.Dummy(imgui.ImVec2(0, 76))
		else
			imgui.Dummy(imgui.ImVec2(0, 30))
		end
		
	end
	
	imgui.EndChild()
end

function reminder_win_fix()
	local function new_draw(pos_draw, par_dr_y)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)

			if par_dr_y ~= 44 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			
			if par_dr_y ~= 44 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			end
		end
	end


		if setting.int.theme == 'White' then
			skin.DrawFond({162, 429 + start_pos + new_pos}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
		else
			skin.DrawFond({162, 429 + start_pos + new_pos}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
		end
		skin.DrawFond({162, 428 + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
	if not reminder_edit then
		imgui.SetCursorPos(imgui.ImVec2(190, 446 + start_pos + new_pos))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 12, imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(177, 433 + start_pos + new_pos))
		if imgui.InvisibleButton(u8'##����� �����������', imgui.ImVec2(175, 25)) then
			reminder_buf = {
				nm = u8'����������� '..(#setting.reminder + 1),
				year = tonumber(os.date('%Y')),
				mon = tonumber(os.date('%m')),
				day = tonumber(os.date('%d')),
				min = tonumber(os.date('%M')),
				hour = tonumber(os.date('%H')),
				repeats = {false, false, false, false, false, false, false},
				sound = false,
				execution = false
			}
			if tonumber(os.date('%M')) <= 55 then
				reminder_buf.min = tonumber(os.date('%M')) + 2
			else
				reminder_buf.min = 0
				if tonumber(os.date('%H')) ~= 23 then
					reminder_buf.hour = tonumber(os.date('%H')) + 1
				else
					reminder_buf.hour = 0
				end
			end
			reminder_edit = true
		end
		imgui.SetCursorPos(imgui.ImVec2(212, 435 + start_pos + new_pos))
		imgui.PushFont(font[4])
		imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), u8'�����������')
		imgui.PopFont()
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(183, 441 + start_pos + new_pos))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.Text(fa.ICON_PLUS)
		imgui.PopStyleColor(1)
		imgui.PopFont()
	else
		imgui.PushFont(font[1])
		local mont = {'������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������'}
		local hr = tostring(reminder_buf.hour)
		local mn = tostring(reminder_buf.min)
		if reminder_buf.hour <= 9 then
			hr = '0'..hr
		end
		if reminder_buf.min <= 9 then
			mn = '0'..mn
		end
		local calc = imgui.CalcTextSize(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' �. � '..hr..':'..mn)
		imgui.SetCursorPos(imgui.ImVec2(512 - calc.x / 2, 437 + start_pos + new_pos))
		imgui.Text(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' �. � '..hr..':'..mn)
		imgui.PopFont()
		skin.Button(u8'���������', 179, 433 + start_pos + new_pos, 180, 26, function() 
			reminder_edit = false
			table.insert(setting.reminder, 1, reminder_buf)
			save('setting')
			reminder_buf = {}
		end)
		skin.Button(u8'�������', 666, 433 + start_pos + new_pos, 180, 26, function()
			reminder_edit = false
			reminder_buf = {}
		end)
	end

	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'�����������', imgui.ImVec2(682, 387 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	if not reminder_edit then
		if #setting.reminder == 0 then
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(185, 170 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'��� �����������')
			imgui.PopFont()
		else
			for i = 1, #setting.reminder do
				local pos_y = 17 + ((i - 1) * 107)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
				if imgui.InvisibleButton(u8'##�������� �����������'..i, imgui.ImVec2(666, 95)) then imgui.OpenPopup(u8'�������� �����������') remove_reminder = i end
				if imgui.IsItemActive() then
					
					if setting.int.theme == 'White' then
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.14, col_end.fond_two[2] - 0.14, col_end.fond_two[3] - 0.14, 1.00)), 60)
					else
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)), 60)
					end
				elseif imgui.IsItemHovered() then
					if setting.int.theme == 'White' then
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.08, col_end.fond_two[2] - 0.08, col_end.fond_two[3] - 0.08, 1.00)), 60)
					else
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
					end
				elseif not imgui.IsItemActive() and not imgui.IsItemHovered() then
					if setting.int.theme == 'White' then
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
					else
						skin.DrawFond({0, pos_y}, {0, 0}, {666, 95}, imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00), 30, 15)
						imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 67), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
					end
				end
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(17, pos_y + 12))
				if not string.match(setting.reminder[i].nm, '%S') or setting.reminder[i].nm == '' then
					imgui.Text(u8'��� ����������')
				else
					imgui.Text(setting.reminder[i].nm)
				end
				skin.DrawFond({17, pos_y + 43}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40))
				local week_dot = {u8'��, ', u8'��, ', u8'��, ', u8'��, ', u8'��, ', u8'��, ', u8'��, '}
				local repeat_true = false
				local repeat_text = u8''
				for m = 1, #setting.reminder[i].repeats do
					if setting.reminder[i].repeats[m] then
						repeat_true = true
						repeat_text = repeat_text..week_dot[m]
					end
				end
				if repeat_true then
					repeat_text = string.gsub(repeat_text, ', $', '')
				else
					repeat_text = u8'��� ����������'
				end
				local calc = imgui.CalcTextSize(repeat_text)
				imgui.SetCursorPos(imgui.ImVec2(649 - calc.x, pos_y + 12))
				imgui.Text(repeat_text)
				skin.DrawFond({17, pos_y + 57}, {0, 0}, {4, 25}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
				local mont = {'������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������'}
				local hr = tostring(setting.reminder[i].hour)
				local mn = tostring(setting.reminder[i].min)
				if setting.reminder[i].hour <= 9 then
					hr = '0'..hr
				end
				if setting.reminder[i].min <= 9 then
					mn = '0'..mn
				end
				imgui.SetCursorPos(imgui.ImVec2(31, pos_y + 62))
				imgui.Text(setting.reminder[i].day..' '..u8(mont[setting.reminder[i].mon])..' '..setting.reminder[i].year..u8' �. � '..hr..':'..mn)
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 28))
			if imgui.BeginPopupModal(u8'�������� �����������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(15, 12))
				imgui.Text(u8'�� �������, ��� ������ ������� �����������?  ')
				skin.Button(u8'�������##�����������', 15, 40, 145, 30, function() table.remove(setting.reminder, remove_reminder) save('setting') imgui.CloseCurrentPopup() end)
				skin.Button(u8'��������##�����������', 170, 40, 145, 30, function() imgui.CloseCurrentPopup() end)
				imgui.PopFont()
				imgui.Dummy(imgui.ImVec2(0, 7))
				imgui.EndPopup()
			end
		end
	else
		new_draw(17, 44)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 29))
		imgui.Text(u8'����� �����������')
		skin.InputText(150, 28, u8'������� �����##df', 'reminder_buf.nm', 100, 500)
		
		imgui.SetCursorPos(imgui.ImVec2(0, 73))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 422, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 267), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 422, p.y + 267.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 422, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 267), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 422, p.y + 267.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
		end
		imgui.SetCursorPos(imgui.ImVec2(462, 73))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 217), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 217), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 188), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 188.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 217), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 188), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 188.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
		end
		imgui.SetCursorPos(imgui.ImVec2(555, 73))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 111, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 83, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 267), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 83, p.y + 267.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 111, p.y + 296), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 83, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 267), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 83, p.y + 267.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
		end
		imgui.SetCursorPos(imgui.ImVec2(462, 302))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 67), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 38), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 38.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 81, p.y + 67), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 38), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 53, p.y + 38.5), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(475, 84))
		imgui.Text(u8'��\n\n��\n\n��\n\n��\n\n��\n\n��\n\n��')
		for i = 1, 7 do
			imgui.SetCursorPos(imgui.ImVec2(500, 82 + ((i - 1) * 30)))
			if skin.Switch(u8'##���������� ��������'..i, reminder_buf.repeats[i]) then reminder_buf.repeats[i] = not reminder_buf.repeats[i] end
		end
		imgui.SetCursorPos(imgui.ImVec2(488, 314))
		imgui.Text(u8'����')
		imgui.SetCursorPos(imgui.ImVec2(488.5, 335))
		if skin.Switch(u8'##�������� ������', reminder_buf.sound) then reminder_buf.sound = not reminder_buf.sound end
		imgui.SetCursorPos(imgui.ImVec2(583, 84))
		imgui.PushFont(font[4])
		local hr = tostring(reminder_buf.hour)
		local mn = tostring(reminder_buf.min)
		if reminder_buf.hour <= 9 then
			hr = '0'..hr
		end
		if reminder_buf.min <= 9 then
			mn = '0'..mn
		end
		imgui.Text(hr..':'..mn)
		imgui.PopFont()
		skin.DrawFond({568, 116}, {0, 0}, {83, 1.0}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.SetCursorPos(imgui.ImVec2(571, 133))
		if imgui.VSliderFloat(u8'##���� ��������', imgui.ImVec2(18, 220), rem_fl_h, 0, 22, '') then reminder_buf.hour = round(rem_fl_h.v, 1) end
		imgui.SetCursorPos(imgui.ImVec2(630, 133))
		if imgui.VSliderFloat(u8'##������ ��������', imgui.ImVec2(18, 220), rem_fl_m, 0, 58, '') then reminder_buf.min = round(rem_fl_m.v, 1) end
		
		local col_neitral = imgui.GetColorU32(imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
		if setting.int.theme == 'White' then
			col_neitral =  imgui.GetColorU32(imgui.ImVec4(0.84, 0.82, 0.82, 1.00))
		end
		imgui.SetCursorPos(imgui.ImVec2(571, 133))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + 219), col_neitral, 8, 15)
		imgui.SetCursorPos(imgui.ImVec2(571, 128 + (225 - (reminder_buf.hour * 9))))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + (reminder_buf.hour * 9)), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 12)
		imgui.SetCursorPos(imgui.ImVec2(566, 113 + (225 - (reminder_buf.hour * 9))))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 28, p.y + 15), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 8, 15)
		
		imgui.SetCursorPos(imgui.ImVec2(630, 133))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + 219), col_neitral, 8, 15)
		imgui.SetCursorPos(imgui.ImVec2(630, 128 + (225 - (reminder_buf.min * 3.6))))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 18, p.y + (reminder_buf.min * 3.6)), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 12)
		imgui.SetCursorPos(imgui.ImVec2(625, 113 + (225 - (reminder_buf.min * 3.6))))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 28, p.y + 15), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 8, 15)
		imgui.PopStyleColor(3)
		
		local month = {u8'������', u8'�������', u8'����', u8'������', u8'���', u8'����', u8'����', u8'������', u8'��������', u8'�������', u8'������', u8'�������'}
		imgui.SetCursorPos(imgui.ImVec2(15, 89))
		imgui.PushFont(font[4])
		imgui.Text(month[tonumber(reminder_buf.mon)]..' '..reminder_buf.year..u8' �.')
		imgui.PopFont()
		skin.DrawFond({15, 124}, {0, 0}, {420, 1.0}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		imgui.SetCursorPos(imgui.ImVec2(373, 88))
		if imgui.InvisibleButton('##���� �����', imgui.ImVec2(25, 25)) then
			if reminder_buf.mon == 1 then
				reminder_buf.mon = 12
				reminder_buf.year = reminder_buf.year - 1
			else
				reminder_buf.mon = reminder_buf.mon - 1
			end
			reminder_buf.day = 1
		end
		imgui.SetCursorPos(imgui.ImVec2(375, 89))
		imgui.PushFont(fa_font[5])
		if imgui.IsItemHovered() then
			imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_LEFT)
		else
			imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_LEFT)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(417, 88))
		if imgui.InvisibleButton('##���� ������', imgui.ImVec2(25, 25)) then
			if reminder_buf.mon == 12 then
				reminder_buf.mon = 1
				reminder_buf.year = reminder_buf.year + 1
			else
				reminder_buf.mon = reminder_buf.mon + 1
			end
			reminder_buf.day = 1
		end
		imgui.SetCursorPos(imgui.ImVec2(419, 89))
		if imgui.IsItemHovered() then
			imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_RIGHT)
		else
			imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_RIGHT)
		end
		imgui.PopFont()
		
		local week_name = {u8'��', u8'��', u8'��', u8'��', u8'��', u8'��', u8'��'}
		for i = 1, 7 do
			imgui.SetCursorPos(imgui.ImVec2(42 + ((i - 1) * 58), 139))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), week_name[i])
		end
		
		local function get_first_day_of_week(month, year)
			local first_day_of_month = os.date('%w', os.time({year = year, month = month, day = 1}))
			if first_day_of_month == '0' then
				first_day_of_month = '7'
			end

			return tonumber(first_day_of_month)
		end
		local function get_days_in_month(month, year)
			local days_in_month = 31
			if month == 4 or month == 6 or month == 9 or month == 11 then
				days_in_month = 30
			elseif month == 2 then
				if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
					days_in_month = 29
				else
					days_in_month = 28
				end
			end

			return days_in_month
		end
		
		local week_buf = get_first_day_of_week(reminder_buf.mon, reminder_buf.year)
		local pos_y_week = 0
		for i = 1, get_days_in_month(reminder_buf.mon, reminder_buf.year) do
			imgui.SetCursorPos(imgui.ImVec2(38 + ((week_buf - 1) * 58), 175 + (pos_y_week * 32)))
			if imgui.InvisibleButton(u8'##����� ���'..i, imgui.ImVec2(24, 24)) then reminder_buf.day = i end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(51 + ((week_buf - 1) * 58), 183 + (pos_y_week * 32)))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.4), 14, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
			end
			if i == reminder_buf.day then
				imgui.SetCursorPos(imgui.ImVec2(51 + ((week_buf - 1) * 58), 183 + (pos_y_week * 32)))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.4), 14, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
			end
			if i >= 10 then
				imgui.SetCursorPos(imgui.ImVec2(43 + ((week_buf - 1) * 58), 175 + (pos_y_week * 32)))
			else
				imgui.SetCursorPos(imgui.ImVec2(47 + ((week_buf - 1) * 58), 175 + (pos_y_week * 32)))
			end
			imgui.Text(tostring(i))
			week_buf = week_buf + 1
			if week_buf == 8 then
				week_buf = 1
				pos_y_week = pos_y_week + 1
			end
		end
		
		imgui.PopFont()
	end
	imgui.EndChild()
end

-- ������������� �������� (( ���������� ))
sampRegisterChatCommand('sob', function(id)
    id = tonumber(id)
    if id and id >= 0 and id <= 1000 then
        local playerExists = sampIsPlayerConnected(id)
        if playerExists then
            sob_history = {}
            sob_info = {
                level = -1,
                legal = -1,
                work = -1,
                narko = -1,
                hp = -1,
                bl = -1,
                lic = -1,
				lico = -1,
				warn = -1,
                writ = -1
            }

            if not win.main.v then
                styleAnimationOpen('Main')
                win.main.v = true
            end

            if not select_main_menu[5] then
                select_main_menu[5] = true
                for i = 1, 13 do
                    if i ~= 5 then
                        select_main_menu[i] = false
                    end
                end
            end

            sobes_menu = true
            pl_sob.id = id
            pl_sob.nm = sampGetPlayerNickname(id)
            sampAddChatMessage(script_tag.. "{FFFFFF}�� ������ ������������� � {FF5345}" .. pl_sob.nm, color_tag)
        else
            sampAddChatMessage(script_tag.. "{FFFFFF}����, ����� �� ����������� �� �������.", color_tag)
        end
    else
        sampAddChatMessage(script_tag.. "{FFFFFF}���-�� �� ���. ���������� ������ ID �� 0 �� 1000.", color_tag)
    end
end)



function win_sobes_fix()
	local function new_draw(pos_draw, par_dr_y)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)

			if par_dr_y ~= 43 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.4, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645.5, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			
			if par_dr_y ~= 43 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.4, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645.5, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			end
		end
	end

	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'���� �������������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	if not sobes_menu then
		new_draw(17, 43)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 29))
		imgui.Text(u8'������� id ������')
		skin.InputText(144, 27, u8'������� id ������', 'id_sobes', 4, 150, 'num')
		if setting.sob.level ~= '' and setting.sob.legal ~= '' and setting.sob.narko ~= '' and id_sobes ~= '' then
			skin.Button(u8'������ �������������', 310, 24, 170, 28, function()
				if sampIsPlayerConnected(id_sobes) then
					sob_history = {}
					sob_info = {
						level = -1,
						legal = -1,
						work = -1,
						narko = -1,
						hp = -1,
						bl = -1,
						lic = -1,
						lico = -1,
						warn = -1,
						writ = -1
					}
					sobes_menu = true
					pl_sob.id = tonumber(id_sobes)
					pl_sob.nm = sampGetPlayerNickname(id_sobes)
				end
			end)
		elseif id_sobes ~= '' then
			skin.Button(u8'������ �������������##false_non', 310, 24, 170, 28, function() end)
			imgui.SetCursorPos(imgui.ImVec2(490, 29))
			imgui.TextColoredRGB('{cf2727}��������� ��� ���� ����!')
		else
			skin.Button(u8'������ �������������##false_non', 310, 24, 170, 28, function() end)
			imgui.SetCursorPos(imgui.ImVec2(490, 29))
			imgui.TextColoredRGB('{cf2727}������� id ������!')
		end
		imgui.PopFont()
		
		imgui.PushFont(bold_font[3])
		imgui.SetCursorPos(imgui.ImVec2(198, 75))
		imgui.Text(u8'��������� ���� �������������')
		imgui.PopFont()
		
		new_draw(103, 103)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 115))
		imgui.Text(u8'����������� ������� ������ ��� ����������')
		imgui.SetCursorPos(imgui.ImVec2(15, 145))
		imgui.Text(u8'����������� �������� ����������������� ������ ��� ����������')
		imgui.SetCursorPos(imgui.ImVec2(15, 175))
		imgui.Text(u8'���������� ���������� ����������������� ������ ��� ����������')
		
		skin.InputText(531, 113, u8'��������##1', 'setting.sob.level', 3, 120, 'num', 'setting')
		skin.InputText(531, 143, u8'��������##2', 'setting.sob.legal', 4, 120, 'num', 'setting')
		skin.InputText(531, 173, u8'��������##3', 'setting.sob.narko', 4, 120, 'num', 'setting')
		imgui.PopFont()
		
		imgui.PushFont(bold_font[3])
		imgui.SetCursorPos(imgui.ImVec2(251, 221))
		imgui.Text(u8'�������� ��������')
		imgui.PopFont()
		
		local POS_QY = 249
		imgui.PushFont(font[1])
		if #setting.sob.qq ~= 0 then
			local tabl_rem = 0
			for i = 1, #setting.sob.qq do
				new_draw(POS_QY, 106 + (#setting.sob.qq[i].q * 35))
				imgui.SetCursorPos(imgui.ImVec2(15, POS_QY + 12))
				imgui.Text(u8'��� �������')
				skin.InputText(110, POS_QY + 11, u8'������� ��� �������##sel'..i, 'setting.sob.qq.'..i..'.nm', 50, 541, nil, 'setting')
				if #setting.sob.qq[i].q ~= 0 then
					local tabl_rem_2 = 0
					for m = 1, #setting.sob.qq[i].q do
						skin.InputText(15, POS_QY + 55 + ((m - 1) * 35), u8'�������� ���� ���������, ������� ���������� � ���##sel'..i..m, 'setting.sob.qq.'..i..'.q.'..m, 512, 608, nil, 'setting')
						imgui.SetCursorPos(imgui.ImVec2(630, POS_QY + 57 + ((m - 1) * 35)))
						if imgui.InvisibleButton(u8'##DEL_F'..i..m, imgui.ImVec2(20, 20)) then tabl_rem_2 = m end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(633, POS_QY + 60 + ((m - 1) * 35)))
						imgui.Text(fa.ICON_TRASH)
						imgui.PopFont()
					end
					if tabl_rem_2 ~= 0 then table.remove(setting.sob.qq[i].q, tabl_rem_2) save('setting') end
				end
				if #setting.sob.qq[i].q >= 10 then
					skin.Button(u8'�������� �����##false_non', 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() end)
				else
					skin.Button(u8'�������� �����##sel'..i, 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() 
						table.insert(setting.sob.qq[i].q, '')
						save('setting')
					end)
				end
				skin.Button(u8'������� ������##fas'..i, 180, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() tabl_rem = i end)
				POS_QY = POS_QY + 118 + (#setting.sob.qq[i].q * 35)
			end
			if tabl_rem ~= 0 then table.remove(setting.sob.qq, tabl_rem) save('setting') end
		end
		POS_QY = POS_QY + 2
		if #setting.sob.qq >= 26 then
			skin.Button(u8'������� ����� ������##false_non', 208, POS_QY, 250, 33, function() end)
		else
			skin.Button(u8'������� ����� ������', 208, POS_QY, 250, 33, function()
				table.insert(setting.sob.qq, {
					nm = u8'������ '..(#setting.sob.qq + 1),
					q = {}
				})
				save('setting')
			end)
		end
		imgui.PopFont()
		imgui.Dummy(imgui.ImVec2(0, 20))
	else
		new_draw(17, 115)
		
		imgui.PushFont(font[4])
		local cl_nm = imgui.CalcTextSize(pl_sob.nm)
		imgui.SetCursorPos(imgui.ImVec2(332 - cl_nm.x / 2, 23))
		imgui.Text(pl_sob.nm)
		imgui.SameLine()
		if sob_info.warn == -1 then
    		imgui.TextColoredRGB('')
		elseif sob_info.warn == 0 then
    		imgui.TextColoredRGB('')
		elseif sob_info.warn == 1 then
    		imgui.TextColoredRGB('{CF0000}(���� ����)')
		end
		imgui.PopFont()
		skin.DrawFond({17, 52}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({225, 60}, {0, 0}, {1, 65}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({445, 60}, {0, 0}, {1, 65}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		
		if setting.frac.org == u8'���' then
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 62))
			imgui.Text(u8'��� � �����:')
			imgui.SetCursorPos(imgui.ImVec2(17, 84))
			imgui.Text(u8'�������������:')
			imgui.SetCursorPos(imgui.ImVec2(17, 106))
			imgui.Text(u8'��������:')
			imgui.SetCursorPos(imgui.ImVec2(240, 62))
			imgui.Text(u8'����������:')
			imgui.SetCursorPos(imgui.ImVec2(240, 84))
			imgui.Text(u8'��������:')
			imgui.SetCursorPos(imgui.ImVec2(240, 106))
			imgui.Text(u8'׸���� ������:')
			imgui.SetCursorPos(imgui.ImVec2(460, 62))
			imgui.Text(u8'���. �� ����:')
			imgui.SetCursorPos(imgui.ImVec2(460, 84))
			imgui.Text(u8'���. �� ������:')
			imgui.SetCursorPos(imgui.ImVec2(460, 106))
			imgui.Text(u8'��������:')
		else
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 62))
			imgui.Text(u8'��� � �����:')
			imgui.SetCursorPos(imgui.ImVec2(17, 84))
			imgui.Text(u8'�������������.:')
			imgui.SetCursorPos(imgui.ImVec2(17, 106))
			imgui.Text(u8'��������:')
			imgui.SetCursorPos(imgui.ImVec2(240, 62))
			imgui.Text(u8'�����������.:')
			imgui.SetCursorPos(imgui.ImVec2(240, 84))
			imgui.Text(u8'��������:')
			imgui.SetCursorPos(imgui.ImVec2(240, 106))
			imgui.Text(u8'׸���� ������:')
			imgui.SetCursorPos(imgui.ImVec2(460, 68))
			imgui.Text(u8'���. �� ����:')
			imgui.SetCursorPos(imgui.ImVec2(460, 97))
			imgui.Text(u8'��������:')
		end
		imgui.SetCursorPos(imgui.ImVec2(104, 62))
		if sob_info.level == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.level >= tonumber(setting.sob.level) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.level)..' �� '..setting.sob.level)
		elseif sob_info.level < tonumber(setting.sob.level) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.level)..' �� '..setting.sob.level)
		end
		imgui.SetCursorPos(imgui.ImVec2(135, 84))
		if sob_info.legal == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.legal >= tonumber(setting.sob.legal) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.legal)..' �� '..setting.sob.legal)
		elseif sob_info.legal < tonumber(setting.sob.legal) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.legal)..' �� '..setting.sob.legal)
		end
		imgui.SetCursorPos(imgui.ImVec2(86, 106))
		if sob_info.work == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.work == 0 then
			imgui.TextColoredRGB('{00A115}�����������')
		elseif sob_info.work == 1 then
			imgui.TextColoredRGB('{CF0000}����. �� �������')
		end
		imgui.SetCursorPos(imgui.ImVec2(332, 62))
		if sob_info.narko == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.narko <= tonumber(setting.sob.narko) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.narko)..' �� '..setting.sob.narko)
		elseif sob_info.narko > tonumber(setting.sob.narko) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.narko)..' �� '..setting.sob.narko)
		end
		imgui.SetCursorPos(imgui.ImVec2(311, 84))
		if sob_info.hp == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.hp == 0 then
			imgui.TextColoredRGB('{00A115}����. ������')
		elseif sob_info.hp == 1 then
			imgui.TextColoredRGB('{CF0000}���� ����������')
		end
		imgui.SetCursorPos(imgui.ImVec2(348, 106))
		if sob_info.bl == -1 then
			imgui.TextColoredRGB('{CF0000}����������')
		elseif sob_info.bl == 0 then
			imgui.TextColoredRGB('{00A115}�� �������')
		elseif sob_info.bl == 1 then
			imgui.TextColoredRGB('{CF0000}������� � ��')
		end
		if setting.frac.org == u8'���' then
			imgui.SetCursorPos(imgui.ImVec2(551, 62))
			if sob_info.lic == -1 then
				imgui.TextColoredRGB('{CF0000}����������')
			elseif sob_info.lic == 0 then
				imgui.TextColoredRGB('{00A115}�������')
			elseif sob_info.lic == 1 then
				imgui.TextColoredRGB('{CF0000}�����������')
			end
			imgui.SetCursorPos(imgui.ImVec2(570, 84))
			if sob_info.lico == -1 then
				imgui.TextColoredRGB('{CF0000}����������')
			elseif sob_info.lico == 0 then
				imgui.TextColoredRGB('{00A115}�������')
			elseif sob_info.lico == 1 then
				imgui.TextColoredRGB('{CF0000}�����������')
			end
			imgui.SetCursorPos(imgui.ImVec2(531, 106))
			if sob_info.writ == -1 then
				imgui.TextColoredRGB('{CF0000}����������')
			elseif sob_info.writ == 0 then
				imgui.TextColoredRGB('{00A115}�����������')
			elseif sob_info.writ == 1 then
				imgui.TextColoredRGB('{CF0000}�������')
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(551, 68))
			if sob_info.lic == -1 then
				imgui.TextColoredRGB('{CF0000}����������')
			elseif sob_info.lic == 0 then
				imgui.TextColoredRGB('{00A115}�������')
			elseif sob_info.lic == 1 then
				imgui.TextColoredRGB('{CF0000}�����������')
			end
			imgui.SetCursorPos(imgui.ImVec2(531, 97))
			if sob_info.writ == -1 then
				imgui.TextColoredRGB('{CF0000}����������')
			elseif sob_info.writ == 0 then
				imgui.TextColoredRGB('{00A115}�����������')
			elseif sob_info.writ == 1 then
				imgui.TextColoredRGB('{CF0000}�������')
			end
		end
		imgui.PopFont()
		
		imgui.PushFont(font[4])
		imgui.SetCursorPos(imgui.ImVec2(270, 145))
		imgui.Text(u8'��������� ���')
		imgui.PopFont()
		new_draw(172, 190)
		
		imgui.PushFont(font[1])
		if #setting.sob.qq ~= 0 then
			skin.Button(u8'������ ������', 0, 373, 219, 32, function() imgui.OpenPopup(u8'������ ������') end)
		else
			skin.Button(u8'������ ������##false_non', 0, 373, 219, 32, function() end)
		end
		skin.Button(u8'���������� ��������', 224, 373, 218, 32, function() imgui.OpenPopup(u8'����������� ��������') end)
		skin.Button(u8'���������� �������������', 447, 373, 219, 32, function()
			sobes_menu = false
			sob_history = {}
			sob_info = {
				level = -1,
				legal = -1,
				work = -1,
				narko = -1,
				hp = -1,
				bl = -1,
				lic = -1,
				lico = -1,
				warn = -1,
				writ = -1
			}
		end)
		
		if imgui.BeginPopupModal(u8'������ ������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##������� ������ ����������� ��������', imgui.ImVec2(20, 20)) then
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(20, 20))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				imgui.SetCursorPos(imgui.ImVec2(16, 13))
				imgui.PushFont(fa_font[2])
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 40))
			imgui.BeginChild(u8'������ ������', imgui.ImVec2(300, 15 + (#setting.sob.qq * 35)), false, imgui.WindowFlags.NoScrollbar)
			imgui.PushFont(font[1])
			for i = 1, #setting.sob.qq do
				skin.Button(setting.sob.qq[i].nm, 15, (i - 1) * 35, 270, 28, function()
					if #setting.sob.qq[i].q ~= 0 and thread:status() == 'dead' then
						thread = lua_thread.create(function()
							for k = 1, #setting.sob.qq[i].q do
								sampSendChat(u8:decode(setting.sob.qq[i].q[k]))
								if k ~= #setting.sob.qq[i].q then wait(2100) end
							end
						end)
					end
					imgui.CloseCurrentPopup()
				end)
			end
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		if imgui.BeginPopupModal(u8'����������� ��������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##������� ������ ����������� ��������', imgui.ImVec2(20, 20)) then
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(20, 20))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				imgui.SetCursorPos(imgui.ImVec2(16, 13))
				imgui.PushFont(fa_font[2])
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 40))
			imgui.BeginChild(u8'����������� ��������', imgui.ImVec2(300, 460), false, imgui.WindowFlags.NoScrollbar)
			imgui.PushFont(font[1])
			skin.Button(u8'������� ������', 15, 0, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('�������, �� ������� � ��� �� ������!')
						wait(2100)
						sampSendChat('������ � ����� ��� ����� �� �������� � ������ � ������� ������.')
						wait(2100)
						sampSendChat('/do � ������� ��������� ����� �� ���������.')
						wait(2100)
						sampSendChat('/me ����������� �� ���������� ������, ������'.. chsex('', '�') ..' ������ ����')
						wait(2100)
						sampSendChat('/me �������'.. chsex('', '�') ..' ���� �� �������� � ������ �������� ��������')
						wait(2100)
						sampSendChat('/invite '..pl_sob.id)
						wait(2100)
						sampSendChat('/r ������������ ������ ���������� ����� ����������� - '.. pl_sob.nm:gsub('_', ' ') ..'.')
					end)
				end
			end)
			skin.Button(u8'�������� � �������� (����� ���)', 15, 60, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. � ��� �������� � ��������.')
						wait(2100)
						sampSendChat('/n ����� ���. � ����� �����, � ���������, ������ � �����������.')
					end)
				end
			end)
			skin.Button(u8'���� ��� ����������', 15, 95, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. ��� ������� ���������� � ����� ������� ���.')
						wait(2100)
						sampSendChat('����������� ������� ���������� � ����� ������ ���� �� �����, ��� '..setting.sob.level)
					end)
				end
			end)
			skin.Button(u8'�������� � �������', 15, 130, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. � ��� �������� � �������.')
						wait(2100)
						sampSendChat('/n ��������� ������� '..setting.sob.legal..' �����������������.')
					end)
				end
			end)
			skin.Button(u8'��� ������� �� �������', 15, 165, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������.')
						wait(2100)
						sampSendChat('�� ������ ������ �� ��� ��������� � ������ �����������.')
						wait(2100)
						sampSendChat('���� ������ � ���, �� ��� ������ ��� ���������� ��������� ������.')
					end)
				end
			end)
			skin.Button(u8'����� �����������������', 15, 200, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. � ��� ������� �����������������.')
						wait(2100)
						sampSendChat('�� ������ ���������� �� �����������������, �������� �� ���� ����� ��������.')
					end)
				end
			end)
			skin.Button(u8'�������� � ����. ���������', 15, 235, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. � ��� �������� � ����. ���������.')
					end)
				end
			end)
			skin.Button(u8'������� � ������ ������', 15, 270, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� �� ��� �� ���������. �� �������� � ������ ������ �����������.')
					end)
				end
			end)
			skin.Button(u8'��� ��������', 15, 305, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��� ��������������� ���������� ������������ �������.')
						wait(2100)
						sampSendChat('�������� ��� ����� � ����� �. ���-������.')
						wait(2100)
						sampSendChat('��� ����, � ���������, ���������� �� �� ������. ��������� ����� ��� ���������.')
					end)
				end
			end)
			skin.Button(u8'��� ���. �����', 15, 340, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��� ��������������� ���������� ���. ����� � �������� "��������� ������".')
						wait(2100)
						sampSendChat('�������� � ����� � ����� ��������.')
						wait(2100)
						sampSendChat('��� ��, � ���������, ���������� �� �� ������.')
					end)
				end
			end)
			skin.Button(u8'��� ��������', 15, 375, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��� ��������������� ���������� �������� �� ���������� �����������.')
						wait(2100)
						sampSendChat('�������� � ����� � ������ ��������������.')
						wait(2100)
						sampSendChat('��� ��, � ���������, ���������� �� �� ������. ��������� ����� � ���������.')
					end)
				end
			end)
			skin.Button(u8'��������', 15, 410, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('��������, �� � ����� ��� �������������, ��� ��� � ��� �� ����� ������� ��������.')
						wait(2100)
						sampSendChat('��� ��������������� ���������� ����� ������� �����, ���� �� ����� ��������.')
						wait(2100)
						sampSendChat('��������� ����� ��������� �������� ������.')
					end)
				end
			end)
			
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		imgui.SetCursorPos(imgui.ImVec2(0, 172))
		imgui.BeginChild(u8'��������� ��� �������������', imgui.ImVec2(667, 141), false)
		if not imgui.IsMouseDown(1) then
			imgui.SetScrollY(imgui.GetScrollMaxY())
		end
		if #sob_history ~= 0 then
			for i = 1, #sob_history do
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
				if setting.int.theme ~= 'White' then
					imgui.TextColoredRGB('{b3e6f5}'..sob_history[i])
				else
					imgui.TextColoredRGB('{464d4f}'..sob_history[i])
				end
				imgui.PopFont()
			end
		end
		imgui.EndChild()
		
		skin.InputText(10, 329, u8'����� ���������', 'inp_text_sob', 512, 555)
		if inp_text_sob ~= '' then
			if imgui.IsItemHovered() and imgui.IsKeyPressed(13) then
				sampSendChat(u8:decode(inp_text_sob))
				inp_text_sob = ''
			end
			skin.Button(u8'���������', 575, 326, 81, 28, function()
				sampSendChat(u8:decode(inp_text_sob))
				inp_text_sob = ''
			end)
		else
			skin.Button(u8'���������##false_non', 575, 326, 81, 28, function() end)
		end

		imgui.PopFont()
	end
	imgui.EndChild()
end

function history_chats()
	local function new_draw(pos_draw, par_dr_y)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
			
			if par_dr_y ~= 47 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			
			if par_dr_y ~= 47 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 22.5, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			end
		end
	end
	local function draw_search(pos_draw)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 21), imgui.GetColorU32(imgui.ImVec4(1.00, 0.20, 1.00, 0.50)))
	end
	skin.InputText(670, 11, u8'�����', 'search.chat', 100, 170) -- ICON_ANGLE_LEFT
	
	local matching_indices = {}
	if search.chat ~= '' then
		--[[imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(645, 6))
		imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHEVRON_UP)
		imgui.SetCursorPos(imgui.ImVec2(645, 25))
		imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHEVRON_DOWN)
		imgui.PopFont()]]
		
		if #history_chat ~= 0 then
			search.chat = search.chat:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
			for i, message in ipairs(history_chat) do
				if string.find(message, u8:decode(search.chat)) then
					table.insert(matching_indices, i)
				end
			end
		end
		imgui.PushFont(font[3])

		local ind_end = 0
		local ind_two_end = 0
		if #matching_indices ~= 0 then
			ind_end = #matching_indices % 10
			ind_two_end = #matching_indices % 100
		end
		if ind_end == 1 and ind_two_end ~= 11 then
			local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'������� '..#matching_indices..u8' ����������')
		elseif ind_end > 1 and ind_end < 5 and ind_two_end ~= 12 and ind_two_end ~= 13 and ind_two_end ~= 14 then
			local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'������� '..#matching_indices..u8' ����������')
		else
			local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'������� '..#matching_indices..u8' ����������')
		end
			imgui.PopFont()
	end
	
	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'������� ����', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	
	if #history_chat > 0 then
		new_draw(17, 24 + (23 * #history_chat))
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(226, 49 + (#history_chat * 23)))
		imgui.TextColoredRGB('{808080}�������� ��������� 300 ���������.')
		imgui.PopFont()
	end
	
	if #matching_indices ~= 0 then
		for i = 1, #matching_indices do
			draw_search(30 + (23 * (matching_indices[i] - 1)))
		end
	end
	
	if #history_chat ~= 0 then
		for i = 1, #history_chat do
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(12, 31 + ((i - 1) * 23)))
			imgui.TextColoredRGB(history_chat[i])
			imgui.PopFont()
		end
	else
		imgui.PushFont(bold_font[4])
		imgui.SetCursorPos(imgui.ImVec2(104, 187 + ((start_pos + new_pos) / 2)))
		imgui.Text(u8'��� �� ������ ���������')
		imgui.PopFont()
	end
	
	if scroll_hchat then imgui.SetScrollY(imgui.GetScrollMaxY()) scroll_hchat = false end
	imgui.Dummy(imgui.ImVec2(0, 39))
	
	imgui.EndChild()
end

function dep_win()
	local function new_draw(pos_draw, par_dr_y)
		imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)

			if par_dr_y ~= 44 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
			
			if par_dr_y ~= 44 then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
			end
		end
	end
	
	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'�����������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	new_draw(17, 44)
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(15, 29))
	imgui.Text(u8'������ ���������')
	
	new_draw(73, 44)
	
	local text_blank = ''
	if dep_num_text > 0 then
		text_blank = setting.blank_text_dep[dep_num_text]
	end
	
	if skin.List({350, 24}, setting.depart.format, {u8'[����] - [����]:', u8'� ����,', u8'[�������� ��] - [100,3] - [������� ��]:', u8'[�������� ��] �.�. [���]:'}, 300, 'setting.depart.format') then 
		save('setting')
		if setting.depart.format == u8'[����] - [����]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
		elseif setting.depart.format == u8'� ����,' then
			dep_num_text = 0
			inp_text_dep = '/d '..u8'�'..' '..setting.depart.else_tag..', '
		elseif setting.depart.format == u8'[�������� ��] - [100,3] - [������� ��]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
		elseif setting.depart.format == u8'[�������� ��] �.�. [���]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' �.�. ['..setting.depart.else_tag..']: '
		end
	end
	
	if setting.depart.format == u8'[����] - [����]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'��� ���')
		imgui.SetCursorPos(imgui.ImVec2(310, 85))
		imgui.Text(u8'��� � �����������')
		local dans = {setting.depart.my_tag, setting.depart.else_tag}
		skin.InputText(79, 84, u8'��� ���', 'setting.depart.my_tag', 40, 170, nil, 'setting')
		skin.InputText(450, 84, u8'��� � �����������', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
		end
	elseif setting.depart.format == u8'� ����,' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'��� � �����������')
		local dans = setting.depart.else_tag
		skin.InputText(155, 84, u8'��� � �����������', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d '..u8'�'..' '..setting.depart.else_tag..', '
		end
	elseif setting.depart.format == u8'[�������� ��] - [100,3] - [������� ��]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'��� ���')
		imgui.SetCursorPos(imgui.ImVec2(214, 85))
		imgui.Text(u8'�����')
		imgui.SetCursorPos(imgui.ImVec2(403, 85))
		imgui.Text(u8'��� � �����������')
		local dans = {setting.depart.my_tag, setting.depart.volna, setting.depart.else_tag}
		skin.InputText(73, 84, u8'��� ���', 'setting.depart.my_tag', 40, 111, nil, 'setting')
		skin.InputText(261, 84, u8'�����', 'setting.depart.volna', 40, 111, nil, 'setting')
		skin.InputText(538, 84, u8'�����������', 'setting.depart.else_tag', 40, 111, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.volna or dans[3] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
		end
	elseif setting.depart.format == u8'[�������� ��] �.�. [���]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'��� ���')
		imgui.SetCursorPos(imgui.ImVec2(310, 85))
		imgui.Text(u8'��� � �����������')
		local dans = {setting.depart.my_tag, setting.depart.else_tag}
		skin.InputText(79, 84, u8'��� ���', 'setting.depart.my_tag', 40, 170, nil, 'setting')
		skin.InputText(450, 84, u8'��� � �����������', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' �.�. ['..setting.depart.else_tag..']: '
		end
	end
	imgui.PopFont()
	imgui.PushFont(bold_font[3])
	imgui.SetCursorPos(imgui.ImVec2(270, 130))
	imgui.Text(u8'��������� ���')
	imgui.PopFont()
	new_draw(157, 248)
	
	imgui.SetCursorPos(imgui.ImVec2(0, 157))
	imgui.BeginChild(u8'�����������', imgui.ImVec2(667, 199), false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	imgui.SetScrollY(imgui.GetScrollMaxY())
	
	if #dep_history > 30 then
		for i = 1, #dep_history - 20 do
			table.remove(dep_history, 1)
		end
	end
	
	if #dep_history ~= 0 then
		start_index = math.max(#dep_history - 19, 1)
		for i = start_index, #dep_history do
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
			if setting.int.theme ~= 'White' then
				imgui.TextColoredRGB('{23A6FC}'..dep_history[i])
			else
				imgui.TextColoredRGB('{005994}'..dep_history[i])
			end
			imgui.PopFont()
		end
	end
	imgui.EndChild()
	
	imgui.PushFont(fa_font[5])
	imgui.SetCursorPos(imgui.ImVec2(13, 369))
	imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_ANGLE_LEFT)
	imgui.SetCursorPos(imgui.ImVec2(50, 369))
	imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_ANGLE_RIGHT)
	imgui.PopFont()
	imgui.PushFont(font[4])
	imgui.SetCursorPos(imgui.ImVec2(31, 371))
	if dep_num_text == 10 then 
		imgui.SetCursorPos(imgui.ImVec2(27, 371))
	end
	if dep_num_text ~= 0 then
		imgui.Text(tostring(dep_num_text))
	else
		imgui.Text('-')
	end
	imgui.PopFont()
	imgui.SetCursorPos(imgui.ImVec2(8, 373))
	if imgui.InvisibleButton(u8'##����� ����', imgui.ImVec2(20, 20)) then
		if dep_num_text > 0 then dep_num_text = dep_num_text - 1 done_active_dep = false end
	end
	imgui.SetCursorPos(imgui.ImVec2(45, 373))
	if imgui.InvisibleButton(u8'##����� ����', imgui.ImVec2(20, 20)) then
		if dep_num_text < 10 then dep_num_text = dep_num_text + 1 done_active_dep = false end
	end
	
	if dep_num_text == 0 then
		skin.InputText(70, 372, u8'����� ���������', 'inp_text_dep', 512, 495)
	elseif not done_active_dep then
		skin.InputText(70, 372, u8'������������� ����� ���������', 'setting.blank_text_dep.'..tostring(dep_num_text), 512, 495, nil, 'setting')
	end
	if dep_num_text == 0 or done_active_dep then
		if inp_text_dep ~= '' then
			skin.Button(u8'���������', 575, 369, 81, 28, function()
				dep_num_text = 0
				sampSendChat(u8:decode(inp_text_dep))
				if setting.depart.format == u8'[����] - [����]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
				elseif setting.depart.format == u8'� ����,' then
					inp_text_dep = '/d '..u8'�'..' '..setting.depart.else_tag..', '
				elseif setting.depart.format == u8'[�������� ��] - [100,3] - [������� ��]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
				elseif setting.depart.format == u8'[�������� ��] �.�. [���]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' �.�. ['..setting.depart.else_tag..']: '
				end
			end)
		else
			skin.Button(u8'���������##false_non', 575, 369, 81, 28, function() end)
		end
	elseif dep_num_text > 0 and not done_active_dep then
		skin.Button(u8'��������', 575, 369, 81, 28, function()
			done_active_dep = true
			if setting.depart.format == u8'[����] - [����]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'� ����,' then
				inp_text_dep = '/d '..u8'�'..' '..setting.depart.else_tag..', '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'[�������� ��] - [100,3] - [������� ��]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'[�������� ��] �.�. [���]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' �.�. ['..setting.depart.else_tag..']: '
			end
			dep_num_text = 0
		end)
	end
	imgui.EndChild()
end

function window.main()
	if pos_el.r_menu < 158 then
		pos_el.r_menu = (pos_el.r_menu * 0.9625) + 6
	else
		pos_el.r_menu = 158
	end
	local function button_menu(text_but_menu, pos_but_menu, imvec4_icon_but_menu, icon_but_menu, pos_icon_but_menu, arg_but_menu, par_plus_stoika, text_yk)
		local param_act_but = false
		if par_plus_stoika == nil then
			par_plus_stoika = {0, 0}
		end
		if text_yk == nil then
			text_yk = 0
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] + 4, pos_but_menu[2] + 4))
		local p = imgui.GetCursorScreenPos()
		if not arg_but_menu then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
			if setting.int.theme == 'White' then
				imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(1.00, 1.00, 1.00, 0.60))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 1.00, 1.00, 0.80))
			else
				imgui.PushStyleColor(imgui.Col.ButtonHovered,imgui.ImVec4(1.00, 1.00, 1.00, 0.06))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.00, 1.00, 1.00, 0.16))
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] - 3, pos_but_menu[2] - 0.5))
		if imgui.Button(u8'##a2f'..text_but_menu, imgui.ImVec2(138, 30)) then param_act_but = true end
		imgui.PushFont(font[1])
		if arg_but_menu then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.80))
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_but_menu[1] + 36, pos_but_menu[2] + 6 + par_plus_stoika[2] + text_yk))
		imgui.Text(text_but_menu)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		if not arg_but_menu then
			imgui.PopStyleColor(3)
		end
		--imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + par_plus_stoika[1] + 12, p.y + par_plus_stoika[2] + 12), 13, imgui.GetColorU32(imvec4_icon_but_menu), 60)
		--imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + par_plus_stoika[1], p.y + par_plus_stoika[2]), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_icon_but_menu), 8, 15)
		imgui.PushFont(fa_font[4])
		imgui.SetCursorPos(imgui.ImVec2(pos_icon_but_menu[1] - 3, pos_icon_but_menu[2] - 2))
		if arg_but_menu then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.80))
		end
		imgui.Text(icon_but_menu)
		imgui.PopStyleColor(1)
		imgui.PopFont()
		
		return param_act_but
	end
	local function transition(num_trans)
		if not interf.main.collapse then
			if select_main_menu[num_trans] then
				for i = 1, #select_main_menu do
					select_main_menu[i] = false
				end
			else
				for i = 1, #select_main_menu do
					if i ~= num_trans then
						select_main_menu[i] = false
					else
						select_main_menu[i] = true
					end
				end
			end
		end
	end
	imgui.SetNextWindowPos(imgui.ImVec2(interf.main.anim_win.x, interf.main.anim_win.y), interf.main.cond, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(interf.main.size.x, interf.main.size.y))
	imgui.Begin('Window Main', win.main.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + (size_win and imgui.WindowFlags.NoMove or 0))
	
	if interf.main.func or interf.main.anim_win.move then
		interf.main.cond = imgui.Cond.Always
	else
		interf.main.cond = imgui.Cond.FirstUseEver
	end
	if interf.main.func then
		interf.main.func = false
	end
	if not interf.main.collapse then
		imgui.SetCursorPos(imgui.ImVec2(828, 428))
		local p = imgui.GetCursorScreenPos()
		local all_false_sel_menu = true
		table.foreach(select_main_menu, function(k, v)
			if v then
				all_false_sel_menu = false
				return
			end
		end)

		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y + 0.1 + start_pos + new_pos), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
		if not all_false_sel_menu then
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.25, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 60)
			end
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00)), 60)
		end
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 788, p.y - 0.1 + start_pos + new_pos), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00)), 60)
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 788, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00)), 60)
		skin.DrawFond({4, 4}, {0, 0}, {860, 460 + start_pos + new_pos}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 42, 15)
	end
	--> ����� ����
	if not interf.main.collapse then
		skin.DrawFond({4, 4}, {0, 0}, {pos_el.r_menu, 460 + start_pos + new_pos}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 42, 9)
	else
		skin.DrawFond({4, 4}, {0, 0}, {100, 50}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 42, 15)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 456 + start_pos + new_pos))
	if imgui.InvisibleButton(u8'##�������', imgui.ImVec2(pos_el.r_menu, 12)) then end
	if imgui.IsItemHovered() or size_win then
		skin.DrawFond({40, 452 + start_pos + new_pos}, {0, 0}, {98, 12}, imgui.ImVec4(0.7, 0.7, 0.7, 1.00), 0, 8)
	end
	if imgui.IsItemClicked(0) then 
		new_pos_win_size = imgui.GetMousePos()
		size_win = true
		start_pos = interf.main.size.y - 469
		setting.start_pos = start_pos
		save('setting')
	end
	if imgui.IsMouseReleased(0) and size_win then 
		size_win = false
		setting.new_pos = new_pos
		setting.start_pos = start_pos
		save('setting')
	end
	
	if size_win then
		local gp = imgui.GetMousePos()
		new_pos = gp.y - new_pos_win_size.y
		local vert = 469 + start_pos + new_pos
		if vert > 469 then
			interf.main.size.y = 469 + start_pos + new_pos
		else
			start_pos = 0
			new_pos = 0
		end
	end
	
	--> ������ ������� � ��������
	imgui.SetCursorPos(imgui.ImVec2(18, 16))
	if imgui.InvisibleButton(u8'##������� ����', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
		pos_win_closed = imgui.GetWindowPos()
		styleAnimationClose('Main', interf.main.size.x, interf.main.size.y)
		interf.main.anim_win.par = false
	end
	imgui.SetCursorPos(imgui.ImVec2(28, 26))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(24, 19))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(41, 16))
	if imgui.InvisibleButton(u8'##�������� ����', imgui.ImVec2(20, 20)) then
		
		if interf.main.collapse then
			interf.main.func = true
			interf.main.size.x = interf.main.size_def.x
			interf.main.size.y = interf.main.size_def.y + start_pos + new_pos
		else
			interf.main.func = true
			interf.main.size.x = 110
			interf.main.size.y = 60
		end
		interf.main.collapse = not interf.main.collapse
	end
	imgui.SetCursorPos(imgui.ImVec2(51, 26))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.35, 0.70, 0.30 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(48, 20))
		imgui.PushFont(fa_font[3])
		if not interf.main.collapse then
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.80), fa.ICON_COMPRESS)
		else
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.80), fa.ICON_EXPAND)
		end
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.35, 0.80, 0.30 ,1.00)), 60)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(65, 16))
	if imgui.InvisibleButton(u8'##������� ����', imgui.ImVec2(20, 20)) then
		
		if not interf.main.collapse then
			transition(12)
			scroll_hchat = true
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(75, 26))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.10, 0.60, 1.00 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(72, 20.7))
		imgui.PushFont(fa_font[3])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.80), fa.ICON_BARS)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.4, p.y - 0.3), 7, imgui.GetColorU32(imgui.ImVec4(0.10, 0.70, 1.00 ,1.00)), 60)
	end
	imgui.GetCursorStartPos()
	if not interf.main.collapse then

		if button_menu(u8'�������', {17, 48}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_COG, {30, 55}, select_main_menu[1], {0.5, -0.5}, 0.0) then 
			transition(1)
		end
		if button_menu(u8'�������', {17, 82}, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_TERMINAL, {29, 88}, select_main_menu[2], nil, -0.5) then 
			sdvig_bool = false
			sdvig_num = 0
			sdvig = 0
			transition(2)
		end
		if button_menu(u8'�����', {17, 116}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BOOK, {29, 123}, select_main_menu[3], nil, -1) then 
			transition(3)
			anim_menu_shpora[1] = 0
			anim_menu_shpora[3] = false
			anim_menu_shpora[4] = 0
		end
		if button_menu(u8'�����������', {17, 150}, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_SIGNAL, {29, 156}, select_main_menu[4], {0.5, -0.5}, -0.5) then
			if setting.depart.format == u8'[����] - [����]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
			elseif setting.depart.format == u8'� ����,' then
				inp_text_dep = '/d '..u8'�'..' '..setting.depart.else_tag..', '
			elseif setting.depart.format == u8'[�������� ��] - [100,3] - [������� ��]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
			end
			transition(4)
		end
		if button_menu(u8'�����', {17, 184}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_USER_PLUS, {28, 190}, select_main_menu[5], {0.5, -0.5}, -0.5) then 
			transition(5)
		end
		if button_menu(u8'�����������', {17, 218}, imgui.ImVec4(0.97, 0.27, 0.19 ,1.00), fa.ICON_BELL, {29, 225}, select_main_menu[6], {0.5, -0.5}) then 
			transition(6)
		end
		if button_menu(u8'����������', {17, 252}, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_AREA_CHART, {28, 259}, select_main_menu[7], {0.5, -0.5}, -0.5) then 
			transition(7)
		end
		if button_menu(u8'������', {17, 286}, imgui.ImVec4(1.00, 0.14, 0.33 ,1.00), fa.ICON_MUSIC, {29, 293}, select_main_menu[8], {-0.5, 0}, -0.5) then 
			transition(8)
			win.music.v = true
		end
		if button_menu(u8'�� ����', {17, 320}, imgui.ImVec4(0.15, 0.77, 0.38 ,1.00), fa.ICON_OBJECT_GROUP, {28, 327}, select_main_menu[9], nil, -0.5) then 
			transition(9)
		end
		if button_menu(u8'����������', {17, 354}, imgui.ImVec4(0.75, 0.30, 1.00, 1.00), fa.ICON_MICROPHONE, {31, 361}, select_main_menu[11], nil, -1) then
			transition(11)
		end
		if button_menu(u8'��������', {17, 388}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_CODEPEN, {28, 395}, select_main_menu[13], nil, -1) then
			transition(13)
		end
		if button_menu(u8'������', {17, 422}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_BULLHORN, {28, 429}, select_main_menu[10], nil, -1) then
			transition(10)
			if setting.notice_help then
				setting.notice_help = false
				save('setting')
			end
			get_scroll_max_help = 2
			local git_link = ''
			if #setting.tickets ~= 0 and debug_crush_help == 0 then
				if setting.tickets[1].text ~= 0 then
					if setting.tickets[1].status == 0 then
						check_ticket = 100
						debug_crush_help = 15
						asyncHttpRequest('GET', 'https://raw.githubusercontent.com/KaneScripter/q/main/'.. setting.unicum_git .. #setting.tickets[1].text ..'.txt', nil,
							function(response)
								if response.text:find('404: Not Found') then
									--print('�� �������')
								else
									token_respone = response.text
								end
							end,
							function(err)
							print(err)
						end)
					end
				end
			end
		end
		if setting.notice_help then
			imgui.SetCursorPos(imgui.ImVec2(120, 436))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 7, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)))
		end
	end
	
	if not setting.fun_block then
		----> [0] ������� ����
		local all_false_sel_menu = true
		table.foreach(select_main_menu, function(k, v)
		  if v then
			all_false_sel_menu = false
			return
		  end
		end)

		if all_false_sel_menu then
			imgui.PushFont(bold_font[2])
			imgui.SetCursorPos(imgui.ImVec2(362, 198 + ((start_pos + new_pos) / 2)))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), u8'State Helper')
			imgui.PopFont()
		end
		
		local all_false_sel_basic = true
		table.foreach(select_basic, function(k, v)
		  if v then
			all_false_sel_basic = false
			return
		  end
		end)
		
		local function menu_draw_up(text_m_d_up, meaning_f_t)
			local speed = 140
			local target_value = anim_menu_draw[2] and 203 or 177
			local currentTime = os.clock()
			local deltaTime = currentTime - lastTime
			lastTime = currentTime

			local target_value = anim_menu_draw[2] and 203 or 177

			if anim_menu_draw[1] < target_value then
				anim_menu_draw[1] = math.min(anim_menu_draw[1] + speed * deltaTime, target_value)
			elseif anim_menu_draw[1] > target_value then
				anim_menu_draw[1] = math.max(anim_menu_draw[1] - speed * deltaTime, target_value)
			end
			--imgui.SetCursorPos(imgui.ImVec2(828, 428))
			--local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				--imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 60)
				skin.DrawFond({162, 4}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 42, 2)
			else
				--imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.11, p.y - 388), 36, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 60)
				skin.DrawFond({162, 4}, {0, 0}, {702, 35}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 42, 2)
			end
			skin.DrawFond({162, 39}, {0, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 42, 2)
			
			imgui.PushFont(bold_font[1])
			if meaning_f_t == nil then
				imgui.SetCursorPos(imgui.ImVec2(anim_menu_draw[1], 8))
			else
				imgui.SetCursorPos(imgui.ImVec2(anim_menu_draw[1], 8))
			end
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text , 0.70), text_m_d_up)
			imgui.PopFont()
			
			if meaning_f_t ~= nil then
				anim_menu_draw[2] = true
				local pof_fsa = false
				imgui.PushFont(fa_font[6])
				imgui.SetCursorPos(imgui.ImVec2(176, 2))
				imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_ANGLE_LEFT)
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(171, 9))
				if imgui.InvisibleButton(u8'##4s2f'..text_m_d_up, imgui.ImVec2(26, 23)) then pof_fsa = true end
				return pof_fsa
			else
				anim_menu_draw[2] = false
			end
		end
		
		if status_track_pl ~= 'STOP' then
			imgui.SetCursorPos(imgui.ImVec2(93, 25))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + level_potok / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			imgui.SetCursorPos(imgui.ImVec2(93, 25))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - level_potok / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			
			imgui.SetCursorPos(imgui.ImVec2(100, 25))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + audio_vizual / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			imgui.SetCursorPos(imgui.ImVec2(100, 25))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - audio_vizual / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			
			imgui.SetCursorPos(imgui.ImVec2(107, 25)) 
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y + frequency / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			imgui.SetCursorPos(imgui.ImVec2(107, 25))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 4, p.y - frequency / 2), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
			
		end
			
		----> [1] �������
		if select_main_menu[1] and all_false_sel_basic then
			menu_draw_up(u8'�������')
			
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'�������', imgui.ImVec2(683, 423 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			local function drawn_button(y_p_b, flag_d_b, text_d_b, pl_text_d_b)
				if pl_text_d_b == nil then
					pl_text_d_b = 0
				end
				local par_b_d = false
				imgui.SetCursorPos(imgui.ImVec2(0, y_p_b))
				local p = imgui.GetCursorScreenPos()

				imgui.SetCursorPos(imgui.ImVec2(0, y_p_b))
				if imgui.InvisibleButton(u8'##fd3'..y_p_b, imgui.ImVec2(666, 40)) then par_b_d = true end
				if imgui.IsItemActive() then
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, flag_d_b)
						if flag_d_b == 3 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						elseif flag_d_b == 12 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 11.6), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638.5, p.y + 11.8), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						elseif flag_d_b == 15 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 20, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 646, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
						end
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 30, flag_d_b)
						if flag_d_b == 3 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
						elseif flag_d_b == 12 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 11.6), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638.5, p.y + 11.8), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
						elseif flag_d_b == 15 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 20, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 646, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 60)
						end
					end
				else
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, flag_d_b)
						if flag_d_b == 3 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						elseif flag_d_b == 12 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 11.6), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638.5, p.y + 11.8), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						elseif flag_d_b == 15 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 20, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 646, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						end
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 40), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, flag_d_b)
						if flag_d_b == 3 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						elseif flag_d_b == 12 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 11.6), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638.5, p.y + 11.8), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						elseif flag_d_b == 15 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 20, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 646, p.y + 20), 20.1, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						end
					end
				end
				imgui.PushFont(fa_font[5])
				imgui.SetCursorPos(imgui.ImVec2(637, y_p_b + 6))
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
				imgui.Text(fa.ICON_ANGLE_RIGHT)
				imgui.PopStyleColor(1)
				imgui.PopFont()
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(50, y_p_b + 11 + pl_text_d_b))
				imgui.Text(text_d_b)
				imgui.PopFont()
				
				return par_b_d
			end
			local function drawn_icon_b(y_p_i, imvec4_i, icon_i, pos_i, deviation_i)
				if deviation_i == nil then
					deviation_i = {0, 0}
				end
				imgui.SetCursorPos(imgui.ImVec2(15, y_p_i + 5))
				local p = imgui.GetCursorScreenPos()
				--imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + deviation_i[1], p.y + deviation_i[2]), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_i), 5, 15)
				
				if pos_i ~= nil then
				imgui.PushFont(fa_font[4])
				imgui.SetCursorPos(imgui.ImVec2(pos_i[1] - 5, pos_i[2]))
				if setting.int.theme == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.00, 0.00, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
				end
				imgui.Text(icon_i)
				imgui.PopStyleColor(1)
				imgui.PopFont()
				end
				
			end
			if drawn_button(17, 3, u8'������ ����������') then select_basic = {true, false, false, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(19, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_LOCK, {26, 28}, {-0.3, 0})
			
			if drawn_button(57, 0, u8'��������� ����') then select_basic = {false, true, false, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(60, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BARS, {24, 68}, {0.5, -0.5})
			
			if drawn_button(97, 0, u8'������� ��������') then select_basic = {false, false, true, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(100, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_USD, {26, 108})
			
			if drawn_button(177, 12, u8'������') then select_basic = {false, false, false, false, false, false, false, false, false, false, false, true} end
			drawn_icon_b(180, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00), fa.ICON_AMBULANCE, {24, 188})
			
			if drawn_button(137, 0, u8'������� ������') then select_basic = {false, false, false, false, false, false, true, false, false, false, false, false} end
			drawn_icon_b(140, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00), fa.ICON_LINK, {24, 148})
			
			skin.DrawFond({51, 57}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 97}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 137}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 177}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			if drawn_button(235, 3, u8'�������') then select_basic = {false, false, false, false, true, false, false, false, false, false, false, false} end
			drawn_icon_b(237, imgui.ImVec4(0.0, 0.47, 0.99 ,1.00), fa.ICON_USER_CIRCLE_O, {24, 245}, {-0.4, 0.7})
			
			if drawn_button(275, 0, u8'�����������') then select_basic = {false, false, false, false, false, true, false, false, false, false, false, false} end
			drawn_icon_b(278, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_PAPER_PLANE, {23, 286})
			
			if drawn_button(355, 12, u8'�������������� �������') then select_basic = {false, false, false, false, false, false, false, true, false, false, false, false} end
			drawn_icon_b(358, imgui.ImVec4(0.22, 0.82, 0.55, 1.00), fa.ICON_TOGGLE_ON, {22, 366})
			
			if drawn_button(315, 0, u8'������', 1) then select_basic = {false, false, false, true, false, false, false, false, false, false, false, false} end
			drawn_icon_b(318, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_COMMENTING, {24, 326})
			
			skin.DrawFond({51, 275}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 315}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 355}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			if drawn_button(413, 3, u8'��������� �������', 1) then select_basic = {false, false, false, false, false, false, false, false, true, false, false, false} end
			drawn_icon_b(417, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_SLIDERS, {25, 425}, {0, 0.5})
			
			if drawn_button(493, 12, u8'� �������', 1) then select_basic = {false, false, false, false, false, false, false, false, false, false, true, false} end
			drawn_icon_b(496, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_CODE,  {25, 504})
			
			if drawn_button(453, 0, u8'����������', 1) then select_basic = {false, false, false, false, false, false, false, false, false, true, false, false} end
			drawn_icon_b(456, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_DOWNLOAD,  {25, 465})
			
			skin.DrawFond({51, 453}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 493}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			imgui.Dummy(imgui.ImVec2(0, 54))
			
			imgui.EndChild()
		elseif select_main_menu[1] and not all_false_sel_basic then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(17, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 and par_dr_y ~= 43 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					elseif par_dr_y == 43 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.4, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645.5, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 and par_dr_y ~= 43 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					elseif par_dr_y == 43 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.4, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645.5, p.y + 21.5), 21.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			if select_basic[1] then
				if menu_draw_up(u8'������ ����������', true) then select_basic[1] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'������ ����������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 75)
				skin.InputText(33, 36, u8'��� ��� �� ������� �����',' setting.nick', 74, 633, '[�-�%s]+', 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 65))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��� ��� �� ������� ����� ����� ������� ��� ������������� � ��������� ����������.')
				imgui.PopFont()
				
				new_draw(110, 91)
				imgui.SetCursorPos(imgui.ImVec2(34, 156))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'�� ��������� �����������, � ������� �� ��������, ������� ����������� ������-')
				imgui.SetCursorPos(imgui.ImVec2(34, 170))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��� ������� � ������. ������ ������������ ������ ����������� �� ������.')
				imgui.PopFont()
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 127))
				imgui.Text(u8'�����������')
				imgui.PopFont()
				if skin.List({480, 121}, setting.frac.org, {u8'�������� ��', u8'�������� ��', u8'�������� ��', u8'�������� ����������', u8'����� ��������������', u8'�������������', u8'���'}, 185, 'setting.frac.org') then 
					add_table_act(setting.frac.org, false)
					save('setting')
					create_act(1)
				end
				
				new_draw(219, 73)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 236))
				imgui.Text(u8'���������')
				local calc = imgui.CalcTextSize(setting.frac.title)
				imgui.SetCursorPos(imgui.ImVec2(660 - calc.x, 236))
				imgui.Text(setting.frac.title)
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 261))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���������� �������������.')
				imgui.PopFont()
				
				new_draw(310, 73)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 327))
				imgui.Text(u8'���')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 352))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���������� ��� ���������.')
				imgui.PopFont()
				if skin.List({480, 321}, setting.sex, {u8'�������', u8'�������'}, 185, 'setting.sex') then save('setting') end
				
				new_draw(401, 75)
				skin.InputText(33, 420, u8'��� � ����� �����������','setting.teg', 74, 633, '[�-�%s]+', 'setting')
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 449))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'� ������������� ������������� ����, �������� � ������ �����������.')
				imgui.PopFont()
				
				imgui.Dummy(imgui.ImVec2(0, 27))
				imgui.EndChild()
			elseif select_basic[2] then
				if menu_draw_up(u8'��������� ����', true) then select_basic[2] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'��������� ����', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 229)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##���������� �� �������', setting.chat_pl) then setting.chat_pl = not setting.chat_pl save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 60))
				if skin.Switch(u8'##��������� ������� ���', setting.chat_smi) then setting.chat_smi = not setting.chat_smi save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 90))
				if skin.Switch(u8'##������ ��������� �������', setting.chat_help) then setting.chat_help = not setting.chat_help save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 120))
				if skin.Switch(u8'##����� �����������', setting.chat_racia) then setting.chat_racia = not setting.chat_racia save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 150))
				if skin.Switch(u8'##����� ������������', setting.chat_dep) then setting.chat_dep = not setting.chat_dep save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 180))
				if skin.Switch(u8'##��� ���', setting.chat_vip) then setting.chat_vip = not setting.chat_vip save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 210))
				if skin.Switch(u8'##������ ���� ���������', setting.chat_all) then setting.chat_all = not setting.chat_all save('setting') end

				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'������ ���������� �� ������� � ���')
				imgui.SetCursorPos(imgui.ImVec2(34, 61))
				imgui.Text(u8'������ ��������� � ������� �� ���')
				imgui.SetCursorPos(imgui.ImVec2(34, 91))
				imgui.Text(u8'������ ������ ��������� �������')
				imgui.SetCursorPos(imgui.ImVec2(34, 120))
				imgui.Text(u8'������ ����� ����������� /r � /rb')
				imgui.SetCursorPos(imgui.ImVec2(34, 150))
				imgui.Text(u8'������ ����� ������������ /d')
				imgui.SetCursorPos(imgui.ImVec2(34, 180))
				imgui.Text(u8'������ VIP ���')
				imgui.SetCursorPos(imgui.ImVec2(34, 210))
				imgui.Text(u8'�������� ������ ���� ���������')
				imgui.PopFont()
				
				new_draw(256, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 270))
				if skin.Switch(u8'##���� � ����� �����', setting.time_hud) then setting.time_hud = not setting.time_hud save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 270))
				imgui.Text(u8'���������� ���� � ����� ��� ����������')
				imgui.PopFont()
				
				new_draw(313, 143)
				skin.InputText(33, 348, u8'����� ��������� ������� /time', 'setting.act_time', 128, 633, nil, 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 324))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��������� ����� ����� /time. �������� ������, ���� �� �����.')
				imgui.PopFont()
				skin.InputText(33, 409, u8'����� ��������� ����� /r', 'setting.act_r', 128, 633, nil, 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 385))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��������� ����� ����� /r. �������� ������, ���� �� �����.')
				imgui.PopFont()
				
				new_draw(466, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 479))
				if skin.Switch(u8'##��������� /time', setting.ts) then setting.ts = not setting.ts save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 479))
				imgui.Text(u8'/time + �������� ������ �������� /ts')
				imgui.PopFont()
				
				new_draw(523, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 537))
				if skin.Switch(u8'##��������� ����� ���������', setting.rubber_stick) then setting.rubber_stick = not setting.rubber_stick save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 537))
				imgui.Text(u8'��������� �������')
				imgui.PopFont()

				new_draw(580, 67)
				imgui.SetCursorPos(imgui.ImVec2(639, 598))
				if skin.Switch(u8'##������������� �������� ����������', setting.auto_roleplay_text) then setting.auto_roleplay_text = not setting.auto_roleplay_text save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 598))
				imgui.Text(u8'�������������� ��������� �������� ����������')
				imgui.PopFont()
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 618))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'�� ������� ��������� ��������� � ����������, ������� ����� ����������� �������������.')
				imgui.PopFont()

				new_draw(657, 67)
				imgui.SetCursorPos(imgui.ImVec2(639, 676))
				if skin.Switch(u8'##����������� ���������', setting.fix_text) then setting.fix_text = not setting.fix_text save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 678))
				imgui.Text(u8'����������� ���������� ��������� � ���� � ���������� �������')
				imgui.PopFont()

				
				imgui.Dummy(imgui.ImVec2(0, 27))
				imgui.EndChild()
			elseif select_basic[3] then
				if menu_draw_up(u8'������� ��������', true) then select_basic[3] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'������� ��������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				if setting.frac.org == u8'����� ��������������' then
					new_draw(17, 518)
					
					imgui.PushFont(bold_font[1])
					imgui.SetCursorPos(imgui.ImVec2(230, 33))
					imgui.Text(u8'1 �����')
					imgui.SetCursorPos(imgui.ImVec2(384, 33))
					imgui.Text(u8'2 ������')
					imgui.SetCursorPos(imgui.ImVec2(544, 33))
					imgui.Text(u8'3 ������')
					
					imgui.SetCursorPos(imgui.ImVec2(40, 77))
					imgui.Text(u8'����')
					imgui.SetCursorPos(imgui.ImVec2(40, 122))
					imgui.Text(u8'����')
					imgui.SetCursorPos(imgui.ImVec2(40, 167))
					imgui.Text(u8'�����')
					imgui.SetCursorPos(imgui.ImVec2(363, 167))
					imgui.Text(u8'����������')
					imgui.SetCursorPos(imgui.ImVec2(523, 167))
					imgui.Text(u8'����������')
					imgui.SetCursorPos(imgui.ImVec2(40, 212))
					imgui.Text(u8'�������')
					imgui.SetCursorPos(imgui.ImVec2(40, 257))
					imgui.Text(u8'������ �/�')
					imgui.SetCursorPos(imgui.ImVec2(40, 302))
					imgui.Text(u8'������')
					imgui.SetCursorPos(imgui.ImVec2(40, 347))
					imgui.Text(u8'�����')
					imgui.SetCursorPos(imgui.ImVec2(40, 392))
					imgui.Text(u8'��������')
					imgui.SetCursorPos(imgui.ImVec2(40, 437))
					imgui.Text(u8'�����')
					imgui.SetCursorPos(imgui.ImVec2(40, 482))
					imgui.Text(u8'�������')
					imgui.PopFont()
					
					imgui.PushFont(font[1])
					skin.InputText(203, 80, u8'���� 1 ���.', 'setting.price_list_cl.auto.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 80, u8'���� 2 ���.', 'setting.price_list_cl.auto.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 80, u8'���� 3 ���.', 'setting.price_list_cl.auto.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 125, u8'���� 1 ���.', 'setting.price_list_cl.moto.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 125, u8'���� 2 ���.', 'setting.price_list_cl.moto.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 125, u8'���� 3 ���.', 'setting.price_list_cl.moto.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 170, u8'����� 1 ���.', 'setting.price_list_cl.fly.1', 10, 130, 'num', 'setting')
					skin.InputText(203, 215, u8'������� 1 ���.', 'setting.price_list_cl.fish.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 215, u8'������� 2 ���.', 'setting.price_list_cl.fish.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 215, u8'������� 3 ���.', 'setting.price_list_cl.fish.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 260, u8'������ 1 ���.', 'setting.price_list_cl.swim.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 260, u8'������ 2 ���.', 'setting.price_list_cl.swim.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 260, u8'������ 3 ���.', 'setting.price_list_cl.swim.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 305, u8'������ 1 ���.', 'setting.price_list_cl.gun.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 305, u8'������ 2 ���.', 'setting.price_list_cl.gun.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 305, u8'������ 3 ���.', 'setting.price_list_cl.gun.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 350, u8'����� 1 ���.', 'setting.price_list_cl.hunt.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 350, u8'����� 2 ���.', 'setting.price_list_cl.hunt.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 350, u8'����� 3 ���.', 'setting.price_list_cl.hunt.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 395, u8'�������� 1 ���.', 'setting.price_list_cl.exc.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 395, u8'�������� 2 ���.', 'setting.price_list_cl.exc.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 395, u8'�������� 3 ���.', 'setting.price_list_cl.exc.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 440, u8'����� 1 ���.', 'setting.price_list_cl.taxi.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 440, u8'����� 2 ���.', 'setting.price_list_cl.taxi.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 440, u8'����� 3 ���.', 'setting.price_list_cl.taxi.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 485, u8'������� 1 ���.', 'setting.price_list_cl.meh.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 485, u8'������� 2 ���.', 'setting.price_list_cl.meh.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 485, u8'������� 3 ���.', 'setting.price_list_cl.meh.3', 10, 130, 'num', 'setting')
					imgui.PopFont()
					
					imgui.Dummy(imgui.ImVec2(0, 61))
				elseif setting.frac.org == u8'�������������' or setting.frac.org == u8'���' then
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(92, 187 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'��� ��� ��� ������� ��������')
					imgui.PopFont()
				else
					if setting.price.lec == '' or setting.price.lec == '0' then
						setting.price.lec = '1'
					elseif setting.price.rec == '' or setting.price.rec == '0' then
						setting.price.rec = '1'
					elseif setting.price.tatu == '' or setting.price.tatu == '0' then
						setting.price.tatu = '1'
					elseif setting.price.ant == '' or setting.price.ant == '0' then
						setting.price.ant = '1'
					elseif setting.price.narko == '' or setting.price.narko == '0' then
						setting.price.narko = '1'
					elseif setting.priceosm == '' or setting.priceosm == '0' then
						setting.priceosm = '1'
					elseif setting.price.mede[1] == '' or setting.price.mede[1] == '0' then
						setting.price.mede[1] = '1'
					elseif setting.price.mede[2] == '' or setting.price.mede[2] == '0' then
						setting.price.mede[2] = '1'
					elseif setting.price.mede[3] == '' or setting.price.mede[3] == '0' then
						setting.price.mede[3] = '1'
					elseif setting.price.mede[4] == '' or setting.price.mede[4] == '0' then
						setting.price.mede[4] = '1'
					elseif setting.price.upmede[1] == '' or setting.price.upmede[1] == '0' then
						setting.price.upmede[1] = '1'
					elseif setting.price.upmede[2] == '' or setting.price.upmede[2] == '0' then
						setting.price.upmede[2] = '1'
					elseif setting.price.upmede[3] == '' or setting.price.upmede[3] == '0' then
						setting.price.upmede[3] = '1'
					elseif setting.price.upmede[4] == '' or setting.price.upmede[4] == '0' then
						setting.price.upmede[4] = '1'
					end
				
					new_draw(17, 140)
					imgui.PushFont(font[1])
					skin.InputText(105, 36, u8'�������', 'setting.price.lec', 10, 200, 'num', 'setting')
					skin.InputText(105, 76, u8'������', 'setting.price.rec', 10, 200, 'num', 'setting')
					skin.InputText(105, 116, u8'����������', 'setting.price.tatu', 10, 200, 'num', 'setting')
					skin.InputText(465, 36, u8'����������', 'setting.price.ant', 10, 200, 'num', 'setting')
					skin.InputText(465, 76, u8'�����������������', 'setting.price.narko', 10, 200, 'num', 'setting')
					skin.InputText(465, 116, u8'����������� ������', 'setting.priceosm', 10, 200, 'num', 'setting')
					
					new_draw(169, 182)
					skin.InputText(163, 188, u8'���. ����� 7 ����', 'setting.price.mede.1', 10, 140, 'num', 'setting')
					skin.InputText(163, 228, u8'���. ����� 14 ����', 'setting.price.mede.2', 10, 140, 'num', 'setting')
					skin.InputText(163, 268, u8'���. ����� 30 ����', 'setting.price.mede.3', 10, 140, 'num', 'setting')
					skin.InputText(163, 308, u8'���. ����� 60 ����', 'setting.price.mede.4', 10, 140, 'num', 'setting')
					skin.InputText(524, 188, u8'����� 7 ����', 'setting.price.upmede.1', 10, 140, 'num', 'setting')
					skin.InputText(524, 228, u8'����� 14 ����', 'setting.price.upmede.2', 10, 140, 'num', 'setting')
					skin.InputText(524, 268, u8'����� 30 ����', 'setting.price.upmede.3', 10, 140, 'num', 'setting')
					skin.InputText(524, 308, u8'����� 60 ����', 'setting.price.upmede.4', 10, 140, 'num', 'setting')
					
					imgui.SetCursorPos(imgui.ImVec2(34, 37))
					imgui.Text(u8'�������')
					imgui.SetCursorPos(imgui.ImVec2(34, 77))
					imgui.Text(u8'������')
					imgui.SetCursorPos(imgui.ImVec2(34, 117))
					imgui.Text(u8'����')
					imgui.SetCursorPos(imgui.ImVec2(370, 37))
					imgui.Text(u8'����������')
					imgui.SetCursorPos(imgui.ImVec2(370, 77))
					imgui.Text(u8'���������.')
					imgui.SetCursorPos(imgui.ImVec2(370, 117))
					imgui.Text(u8'���. ������')
					imgui.SetCursorPos(imgui.ImVec2(34, 189))
					imgui.Text(u8'���. ����� 7 ����')
					imgui.SetCursorPos(imgui.ImVec2(34, 229))
					imgui.Text(u8'���. ����� 14 ����')
					imgui.SetCursorPos(imgui.ImVec2(34, 269))
					imgui.Text(u8'���. ����� 30 ����')
					imgui.SetCursorPos(imgui.ImVec2(34, 309))
					imgui.Text(u8'���. ����� 60 ����')
					imgui.SetCursorPos(imgui.ImVec2(353, 189))
					imgui.Text(u8'���. ����� ����� 7 ����')
					imgui.SetCursorPos(imgui.ImVec2(353, 229))
					imgui.Text(u8'���. ����� ����� 14 ����')
					imgui.SetCursorPos(imgui.ImVec2(353, 269))
					imgui.Text(u8'���. ����� ����� 30 ����')
					imgui.SetCursorPos(imgui.ImVec2(353, 309))
					imgui.Text(u8'���. ����� ����� 60 ����')
					imgui.PopFont()
				end

				imgui.EndChild()
			elseif select_basic[4] then
				if menu_draw_up(u8'������', true) then select_basic[4] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##������������ ������', setting.accent.func) then setting.accent.func = not setting.accent.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'������������ ������')
				imgui.PopFont()
				
				if setting.accent.func then
					new_draw(76, 76)
					skin.InputText(33, 95, u8'������� ��� ����������� ������', 'setting.accent.text', 128, 633, '[�-�%s]+', 'setting')
					imgui.SetCursorPos(imgui.ImVec2(34, 124))
					imgui.PushFont(font[3])
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'������� � ��������� �����. ����� "������" ������ �� �����. ��������, "����������".')
					imgui.PopFont()
					
					new_draw(164, 137)
					imgui.SetCursorPos(imgui.ImVec2(639, 177))
					if skin.Switch(u8'##������ � �����', setting.accent.r) then setting.accent.r = not setting.accent.r save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 207))
					if skin.Switch(u8'##������ ��� �����', setting.accent.s) then setting.accent.s = not setting.accent.s save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 237))
					if skin.Switch(u8'##������ � ����� ����', setting.accent.d) then 
						setting.accent.d = not setting.accent.d 
						save('setting')
						if setting.accent.d and not setting.dep_off then
							sampRegisterChatCommand('d', function(text_accents_d) 
								if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
									sampSendChat('/d ['..u8:decode(setting.accent.text)..' ������]: '..text_accents_d)
								else
									sampSendChat('/d '..text_accents_d)
								end 
							end)
						elseif not setting.accent.d and not setting.dep_off then
							sampUnregisterChatCommand('d')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(639, 267))
					if skin.Switch(u8'##������ � ����� �����', setting.accent.f) then setting.accent.f = not setting.accent.f save('setting') end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 178))
					imgui.Text(u8'������ � ����� ����������� (/r)')
					imgui.SetCursorPos(imgui.ImVec2(34, 208))
					imgui.Text(u8'������ �� ����� ����� (/s)')
					imgui.SetCursorPos(imgui.ImVec2(34, 238))
					imgui.Text(u8'������ � ����� ������������ (/d)')
					imgui.SetCursorPos(imgui.ImVec2(34, 268))
					imgui.Text(u8'������ � ��� �����/����� (/f)')
					
					imgui.PopFont()
				end
				imgui.EndChild()
			elseif select_basic[5] then
				if menu_draw_up(u8'�������', true) then select_basic[5] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'�������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##������� �� ������', setting.members.func) then setting.members.func = not setting.members.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'������� ����������� �� ����� ������')
				imgui.PopFont()
				
				if setting.members.func then
					new_draw(76, 77)
					imgui.SetCursorPos(imgui.ImVec2(639, 89))
					if skin.Switch(u8'##�������� ��� �������', setting.members.dialog) then setting.members.dialog = not setting.members.dialog save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 119))
					if skin.Switch(u8'##������������� �����', setting.members.invers) then setting.members.invers = not setting.members.invers save('setting') end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 90))
					imgui.Text(u8'�������� �����, ���� ������ ������')
					imgui.SetCursorPos(imgui.ImVec2(34, 120))
					imgui.Text(u8'������������� �����')
					
					new_draw(165, 166)
					imgui.SetCursorPos(imgui.ImVec2(639, 178))
					if skin.Switch(u8'##�������� ������ � �����', setting.members.form) then setting.members.form = not setting.members.form save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 208))
					if skin.Switch(u8'##���������� id', setting.members.id) then setting.members.id = not setting.members.id save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 238))
					if skin.Switch(u8'##���������� ����', setting.members.rank) then setting.members.rank = not setting.members.rank save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 268))
					if skin.Switch(u8'##���������� afk', setting.members.afk) then setting.members.afk = not setting.members.afk save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 298))
					if skin.Switch(u8'##���������� ��������', setting.members.warn) then setting.members.warn = not setting.members.warn save('setting') end
					
					imgui.SetCursorPos(imgui.ImVec2(34, 179))
					imgui.Text(u8'�������� ������ ���, ��� � �����')
					imgui.SetCursorPos(imgui.ImVec2(34, 209))
					imgui.Text(u8'���������� id �������')
					imgui.SetCursorPos(imgui.ImVec2(34, 239))
					imgui.Text(u8'���������� ���� �������')
					imgui.SetCursorPos(imgui.ImVec2(34, 269))
					imgui.Text(u8'���������� ����� ���')
					imgui.SetCursorPos(imgui.ImVec2(34, 299))
					imgui.Text(u8'���������� ���������� ���������')
					
					imgui.PopFont()
					
					new_draw(343, 138)
					if skin.Slider('##������ ������', 'setting.members.size', 1, 25, 205, {470, 357}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
					if skin.Slider('##���� ������', 'setting.members.flag', 1, 25, 205, {470, 384}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
					skin.Slider('##���������� ����� ��������', 'setting.members.dist', 1, 30, 205, {470, 414}, 'setting')
					skin.Slider('##������������ ������', 'setting.members.vis', 1, 255, 205, {470, 444}, 'setting')
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 356))
					imgui.Text(u8'������ ������')
					imgui.SetCursorPos(imgui.ImVec2(34, 386))
					imgui.Text(u8'���� ������')
					imgui.SetCursorPos(imgui.ImVec2(34, 416))
					imgui.Text(u8'���������� ����� ��������')
					imgui.SetCursorPos(imgui.ImVec2(34, 446))
					imgui.Text(u8'������������ ������')
					
					new_draw(493, 47)
					imgui.SetCursorPos(imgui.ImVec2(34, 506))
					if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
						local c = imgui.ImVec4(col.title.v[1], col.title.v[2], col.title.v[3], col.title.v[4])
						local argb = imgui.ColorConvertFloat4ToARGB(c)
						setting.members.color.title = imgui.ColorConvertFloat4ToARGB(c)
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(306, 506))
					if imgui.ColorEdit4('##WorkColor', col.work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
						local c = imgui.ImVec4(col.work.v[1], col.work.v[2], col.work.v[3], col.work.v[4])
						local argb = imgui.ColorConvertFloat4ToARGB(c)
						setting.members.color.work = imgui.ColorConvertFloat4ToARGB(c)
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(569, 506))
					if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
						local c = imgui.ImVec4(col.default.v[1], col.default.v[2], col.default.v[3], col.default.v[4])
						local argb = imgui.ColorConvertFloat4ToARGB(c)
						setting.members.color.default = imgui.ColorConvertFloat4ToARGB(c)
						save('setting')
					end
					
					imgui.SetCursorPos(imgui.ImVec2(61, 508))
					imgui.Text(u8'���������')
					imgui.SetCursorPos(imgui.ImVec2(333, 508))
					imgui.Text(u8'� �����')
					imgui.SetCursorPos(imgui.ImVec2(596, 508))
					imgui.Text(u8'��� �����')
					
					
					new_draw(552, 63)
					skin.Button(u8'�������� ��������� ������', 34, 566, 633, nil, function() 
						changePosition()
					end)
					imgui.PopFont()
					imgui.Dummy(imgui.ImVec2(0, 35))
				end
				imgui.EndChild()
			elseif select_basic[6] then
				if menu_draw_up(u8'�����������', true) then select_basic[6] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'�����������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##���������� � ������ ����', setting.notice.car) then setting.notice.car = not setting.notice.car save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'���������� �������� �������� � ������ ����')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'����� ������������� ����������� � ������ ����, �� ������ ���������� �������� ��������.')
				imgui.PopFont()
				
				if not setting.notice.dep then
					new_draw(97, 68)
				else
					if setting.dep.my_tag == '' then
						new_draw(97, 116)
					else
						if setting.dep.my_tag_en == '' then
							new_draw(97, 158)
						else
							if setting.my_tag_en2 == '' then
								new_draw(97, 200)
							else
								new_draw(97, 242)
							end
						end
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 110))
				if skin.Switch(u8'##���������� � ������ ����������� � ����� ������������', setting.notice.dep) then setting.notice.dep = not setting.notice.dep save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 111))
				imgui.Text(u8'���������� � ������ ����������� � ����� ������������')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 133))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'����� � ����� ������������ ��������� � ����� �����������, �� ������ ���������� ������.')
				imgui.PopFont()
				if setting.notice.dep then
					skin.InputText(175, 168, u8'��� ����� �����������', 'setting.dep.my_tag', 128, 490, '^[a-zA-Z ]+$', 'setting')
					if setting.dep.my_tag ~= '' then
						skin.InputText(175, 210, u8'�������������� ���, ��������, �� ���������� (�������������)', 'setting.dep.my_tag_en', 128, 490, '^[a-zA-Z ]+$', 'setting')
						if setting.dep.my_tag_en ~= '' then
							skin.InputText(175, 252, u8'������ �������������� ��� (�������������)', 'setting.my_tag_en2', 128, 490, '^[a-zA-Z ]+$', 'setting')
							if setting.my_tag_en2 ~= '' then
								skin.InputText(175, 294, u8'������ �������������� ��� (�������������)', 'setting.my_tag_en3', 128, 490, '^[a-zA-Z ]+$', 'setting')
							end
						end
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 169))
					imgui.Text(u8'��� �����������')
					if setting.dep.my_tag ~= '' then
						imgui.SetCursorPos(imgui.ImVec2(34, 211))
						imgui.Text(u8'�������������� ���')
						if setting.dep.my_tag_en ~= '' then
							imgui.SetCursorPos(imgui.ImVec2(34, 253))
							imgui.Text(u8'�������������� ���')
							if setting.my_tag_en2 ~= '' then
								imgui.SetCursorPos(imgui.ImVec2(34, 295))
								imgui.Text(u8'�������������� ���')
							end
						end
					end
					imgui.PopFont()
				end
				
				imgui.EndChild()
			elseif select_basic[7] then
				if menu_draw_up(u8'������� ������', true) then select_basic[7] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'������� ������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##������� ������', setting.fast_acc.func) then setting.fast_acc.func = not setting.fast_acc.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'������� ������ � �������� (��� + E)')
				
				imgui.PopFont()
				if setting.fast_acc.func then
					local bk_size = 176
					if #setting.fast_acc.sl ~= 0 then
						local table_remove_acc = 0
						for i = 1, #setting.fast_acc.sl do
							new_draw(76 + ((i - 1) * bk_size), bk_size - 12)
							imgui.SetCursorPos(imgui.ImVec2(636, 134 + ((i - 1) * bk_size)))
							if imgui.InvisibleButton('##������� ��������'..i, imgui.ImVec2(40, 40)) then table_remove_acc = i end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(649, 148 + ((i - 1) * bk_size)))
							imgui.Text(fa.ICON_TRASH)
							imgui.PopFont()
							
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(34, 92 + ((i - 1) * bk_size)))
							imgui.Text(u8'��� ��������')
							skin.InputText(134, 90 + ((i - 1) * bk_size), u8'������� ��� ��������##'..i, 'setting.fast_acc.sl.'..i..'.text', 80, 495, nil, 'setting')
							imgui.SetCursorPos(imgui.ImVec2(34, 132 + ((i - 1) * bk_size)))
							imgui.Text(u8'�������')
							skin.InputText(134, 130 + ((i - 1) * bk_size), u8'����� ����������� �������##'..i, 'setting.fast_acc.sl.'..i..'.cmd', 16, 495, '[%a%d+-]+', 'setting')
							
							imgui.SetCursorPos(imgui.ImVec2(34,  175 + ((i - 1) * bk_size)))
							imgui.Text(u8'���������� � ������ �������� id ������')
							imgui.SetCursorPos(imgui.ImVec2(34,  205 + ((i - 1) * bk_size)))
							imgui.Text(u8'���������� ������� ��� �������������')
							imgui.SetCursorPos(imgui.ImVec2(600,  174 + ((i - 1) * bk_size)))
							if skin.Switch(u8'##���������� � ������ �������� id ������'..i, setting.fast_acc.sl[i].pass_arg) then
								setting.fast_acc.sl[i].pass_arg = not setting.fast_acc.sl[i].pass_arg
								save('setting') 
							end
							imgui.SetCursorPos(imgui.ImVec2(600,  204 + ((i - 1) * bk_size)))
							if skin.Switch(u8'##���������� ������� ��� �������������'..i, setting.fast_acc.sl[i].send_chat) then
								setting.fast_acc.sl[i].send_chat = not setting.fast_acc.sl[i].send_chat
								save('setting')
							end
							imgui.PopFont()
						end
						if table_remove_acc ~= 0 then table.remove(setting.fast_acc.sl, table_remove_acc) save('setting') end
					end
					
					imgui.PushFont(font[1])
					skin.Button(u8'�������� ��������', 250, 88 + (#setting.fast_acc.sl * bk_size), 200, 35, function()
						if #setting.cmd ~= 0 then
							local new_cell_table = {
								text = u8'�������� '..#setting.fast_acc.sl,
								cmd = setting.cmd[1][1],
								pass_arg = true,
								send_chat = true
							}
							table.insert(setting.fast_acc.sl, new_cell_table)
							save('setting')
						end
					end)
					imgui.PopFont()
				end
				imgui.Dummy(imgui.ImVec2(0, 20))
				imgui.EndChild()
			elseif select_basic[8] then
				if menu_draw_up(u8'�������������� �������', true) then select_basic[8] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'�������������� �������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##���������� �������� �����', setting.speed_door) then
					setting.speed_door = not setting.speed_door save('setting')
					if setting.speed_door then
						rkeys.registerHotKey({72}, 1, true, function() on_hot_key({72}) end)
					else
						rkeys.unRegisterHotKey({72})
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'������������ �������� ������ � ����������')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'����� � ��������� ������ ����������� ����������� �� ������� H.')
				imgui.PopFont()
				
				new_draw(97, 81)
				imgui.SetCursorPos(imgui.ImVec2(639, 110))
				if skin.Switch(u8'##��������� ����� ������������', setting.dep_off) then
					setting.dep_off = not setting.dep_off 
					save('setting')
					if setting.dep_off then
						sampRegisterChatCommand('d', function()
							sampAddChatMessage(script_tag..'{FFFFFF}�� ��������� ������� /d � ����������.', color_tag)
						end)
					else
						sampUnregisterChatCommand('d')
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 111))
				imgui.Text(u8'��������� ������� ����� ������������ (/d)')
				imgui.PopFont()
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 133))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���� �� ����� ����� �� ����������� ����������� ���������� � ����� ������������, �� ������ �����-')
				imgui.SetCursorPos(imgui.ImVec2(34, 147))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���� ������� /d. ����� ��� ������� ������ ���������� ��������.')
				imgui.PopFont()
				
				new_draw(190, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 203))
				if skin.Switch(u8'##������������ ����������', setting.show_dialog_auto) then
					setting.show_dialog_auto = not setting.show_dialog_auto save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 204))
				imgui.Text(u8'�������������� �������� ����������')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 226))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'/offer ����� ����������� �������������.')
				imgui.PopFont()
				
				if not setting.kick_afk.func then
					new_draw(270, 68)
				else
					new_draw(270, 107)
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 283))
				if skin.Switch(u8'##��� ���', setting.kick_afk.func) then
					setting.kick_afk.func = not setting.kick_afk.func save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 284))
				imgui.Text(u8'������������� ������ ��� ���������� ����� ���')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 306))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���� ������������� ������ ����, ���� �� ��������� ��������� ����� ���.')
				imgui.PopFont()
				if setting.kick_afk.func then
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 339))
					imgui.Text(u8'������� �������� � �������')
					imgui.SetCursorPos(imgui.ImVec2(340, 340))
					imgui.Text(u8'��������')
					imgui.PopFont()
					skin.InputText(230, 338, u8'��������', 'setting.kick_afk.time_kick', 4, 78, 'num')
					if skin.List({410, 335}, setting.kick_afk.mode, {u8'������ ������� ����������', u8'���� ��������� �������'}, 230, 'setting.kick_afk.mode') then
						save('setting')
					end
				end
				
				local pos_at_kick = 0
				if setting.kick_afk.func then
					pos_at_kick = 39
				end
				
				new_draw(350 + pos_at_kick, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 363 + pos_at_kick))
				if skin.Switch(u8'##����-��������', setting.anti_alarm_but) then
					setting.anti_alarm_but = not setting.anti_alarm_but
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 364 + pos_at_kick))
				imgui.Text(u8'��������� ��������� ������')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 386 + pos_at_kick))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��������� ������ � ����� �������� �� ������� ALT ���������� ��������.')
				imgui.PopFont()
				
				new_draw(430 + pos_at_kick, 77)
				imgui.SetCursorPos(imgui.ImVec2(639, 443 + pos_at_kick))
				if skin.Switch(u8'##���������� ��� ������ �� ���������', setting.display_map_distance.server) then
					setting.display_map_distance.server = not setting.display_map_distance.server
					save('setting')
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 473 + pos_at_kick))
				if skin.Switch(u8'##���������� ��� ������ �� ��������', setting.display_map_distance.user) then
					setting.display_map_distance.user = not setting.display_map_distance.user
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 444 + pos_at_kick))
				imgui.Text(u8'���������� ��� ���������� ���������� �� ��������� �����')
				imgui.SetCursorPos(imgui.ImVec2(34, 474 + pos_at_kick))
				imgui.Text(u8'���������� ��� ���������� ���������� �� ���������������� �����')
				imgui.PopFont()

			if setting.frac.org == u8'���' then
    			new_draw(519, 68)
    			imgui.SetCursorPos(imgui.ImVec2(639, 535))
    			if skin.Switch(u8'##�������������� ��������� ������', setting.auto_weapon) then
        			setting.auto_weapon = not setting.auto_weapon
        			save('setting') 
    			end
    			imgui.PushFont(font[1])
    			imgui.SetCursorPos(imgui.ImVec2(34, 536))
    			imgui.Text(u8'�������������� ��������� ���� ������')
    			imgui.PopFont()
    			imgui.SetCursorPos(imgui.ImVec2(34, 558))
    			imgui.PushFont(font[3])
    			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'�������������� ��������� ��� ������������� ������ (������/�����)')
    			imgui.PopFont()
			end


				--[[local pos_at_kick2 = 0
				if setting.stat_online_display then
					pos_at_kick2 = 39 + pos_at_kick
				end]]
				
				imgui.Dummy(imgui.ImVec2(0, 28))
				imgui.EndChild()
			elseif select_basic[9] then
				if menu_draw_up(u8'��������� �������', true) then select_basic[9] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'��������� �������', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 225)
				if buf_setting.theme[1].v then
					skin.DrawFond({64, 39}, {- 1.0,- 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				if buf_setting.theme[2].v then
					skin.DrawFond({434, 39}, {- 1.0, - 0.8}, {203, 112}, imgui.ImVec4(0.26, 0.50, 0.94, 1.00), 15, 15)
				end
				skin.DrawFond({65, 40}, {0, 0}, {200, 109}, imgui.ImVec4(1.00, 1.00, 1.00, 1.00), 15, 15)
				skin.DrawFond({65, 40}, {0, 0}, {40, 109}, imgui.ImVec4(0.91, 0.89, 0.76, 0.80), 15, 9)
				
				skin.DrawFond({70, 55}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({70, 78}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({70, 101}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({70, 125}, {0, 0}, {30, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.40), 15, 15)
				skin.DrawFond({165, 55}, {0, 0}, {40, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({115, 78}, {0, 0}, {130, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({115, 101}, {0, 0}, {70, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				skin.DrawFond({115, 125}, {0, 0}, {110, 10}, imgui.ImVec4(0.70, 0.70, 0.70, 0.40), 15, 15)
				
				skin.DrawFond({435, 40}, {0, 0}, {200, 109}, imgui.ImVec4(0.08, 0.08, 0.08, 1.00), 15, 15)
				skin.DrawFond({435, 40}, {0, 0}, {40, 109}, imgui.ImVec4(0.15, 0.13, 0.13, 0.70), 15, 9)
				
				skin.DrawFond({440, 55}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({440, 78}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({440, 101}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({440, 125}, {0, 0}, {30, 10}, imgui.ImVec4(0.30, 0.30, 0.30, 0.40), 15, 15)
				skin.DrawFond({535, 55}, {0, 0}, {40, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({485, 78}, {0, 0}, {130, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({485, 101}, {0, 0}, {70, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				skin.DrawFond({485, 125}, {0, 0}, {110, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.40), 15, 15)
				
				if not buf_setting.theme[1].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(98, 170))
				imgui.Text(u8'������� ����������')

				if buf_setting.theme[1].v then
					if skin.CheckboxOne(u8'##whitebox', 160, 200) then
						
					end
				else
					if skin.CheckboxOne(u8'##whitebox##false_func', 160, 200) then
						buf_setting.theme[1].v = true
						buf_setting.theme[2].v = false
						setting.int.theme = 'White'
						save('setting')
					end
				end
				imgui.PopStyleColor(3)
				if not buf_setting.theme[2].v then
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered,imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00))
					imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00))
				end

				imgui.SetCursorPos(imgui.ImVec2(470, 170))
				imgui.Text(u8'Ҹ���� ����������')
				if buf_setting.theme[2].v then
					if skin.CheckboxOne(u8'##blackebox', 530, 200) then
						
					end
				else
					if skin.CheckboxOne(u8'##blackbox##false_func', 530, 200) then
						buf_setting.theme[1].v = false
						buf_setting.theme[2].v = true
						setting.int.theme = 'Black'
						save('setting')
					end
				end
				imgui.PopStyleColor(3)
				imgui.PopFont()
				
				new_draw(254, 47)
				local function accent_col(num_acc, color_acc, color_acc_act)
					imgui.SetCursorPos(imgui.ImVec2(354 + (num_acc * 43), 277))
					local p = imgui.GetCursorScreenPos()
					
					imgui.SetCursorPos(imgui.ImVec2(343 + (num_acc * 43), 266))
					if imgui.InvisibleButton(u8'##������� ������'..num_acc, imgui.ImVec2(22, 22)) then
						setting.col_acc_non = color_acc
						setting.col_acc_act = color_acc_act
						setting.color_accent_num = num_acc
						save('setting')
						style_window()
					end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
					end
					if num_acc == setting.color_accent_num then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 4, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 268))
				imgui.Text(u8'�������� ������')
				accent_col(1, {0.26, 0.45, 0.94}, {0.26, 0.35, 0.94})
				accent_col(2, {0.75, 0.35, 0.87}, {0.75, 0.25, 0.87})
				accent_col(3, {1.00, 0.22, 0.37}, {1.00, 0.12, 0.37})
				accent_col(4, {1.00, 0.27, 0.23}, {1.00, 0.17, 0.23})
				accent_col(5, {1.00, 0.57, 0.04}, {1.00, 0.47, 0.04})
				accent_col(6, {0.20, 0.74, 0.29}, {0.20, 0.64, 0.29})
				accent_col(7, {0.50, 0.50, 0.52}, {0.40, 0.40, 0.42})
				imgui.PopFont()
				
				new_draw(313, 83)
				imgui.SetCursorPos(imgui.ImVec2(639, 326))
				if skin.Switch(u8'##��������� �������� �������� � �������� ����', setting.anim_main) then setting.anim_main = not setting.anim_main save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 327))
				imgui.Text(u8'��������� �������� �������� ����')
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(639, 362))
				if skin.Switch(u8'##��������� ��������� � �����������', setting.hello_mes) then setting.hello_mes = not setting.hello_mes save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 363))
				imgui.Text(u8'�� ���������� ��������� � ����������� ��� ������� �������')
				imgui.PopFont()
				
				imgui.EndChild()
			elseif select_basic[10] then
				if menu_draw_up(u8'����������', true) then select_basic[10] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'����������', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##��������������', setting.auto_update) then
					setting.auto_update = not setting.auto_update 
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'�������������� ����������')
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'������ ����� ����������� �������������, ��� ������ �������������.')
				imgui.PopFont()
				if upd_status == 0 then
					new_draw(97, 85)
					imgui.SetCursorPos(imgui.ImVec2(34, 109))
					imgui.Text(u8'���������� ���. ����������� ���������� ������ �������.')
					skin.Button(u8'��������� ������� ����������', 32, 137, 636, 27, function() update_check() end)
					
					imgui.PushFont(bold_font[3])
					imgui.SetCursorPos(imgui.ImVec2(247, 211))
					imgui.Text(u8'������� ������������')
					imgui.PopFont()
					new_draw(240, 350)
					
					imgui.SetCursorPos(imgui.ImVec2(32, 255))
					imgui.BeginChild(u8'������� ������������', imgui.ImVec2(646, 320), false)
					imgui.PushFont(font[1])

                    imgui.TextWrapped(u8'[������ 2.6]:\n\n1. ���������������� ����-����������� ���������.\n2. ��������� ��������� ������ ��� ��� � �������� �������� �� ������ � �������������.\n3. � ������������� ��������� �������� ������� Warn � ������\n4. ��������� ���������� ������ ���� �������� ��������.\n5. ��������� 3 ����� ��������� {city} � {month} � {nearest}\n6. ����� � ������� ������������� ������ ����� ��������� �� Enter.\n7. ��� ���������� � ������� ��������� �� ��� ��� ������� ������ 2, ��������� ���� /carm.\n8. ���������� ������ ������ ������.\n\n[������ 2.5]:\n\n1. ����������� �����, ������� �������� ���� �������.\n\n[������ 2.4]:\n\n1. ��������� ���� ������� ����� ����������� /members �� ������.\n2. ��������� ����� ���������: {get_ru_nick[id ������]} � {copy_nick[id ������]}.\n3. ��������� ����������� ���������� ���������.\n4. ��������� ������ �������� ���� � ����-����������� ��������� �� �� �������.\n5. ��������� ��� � ���� �������� �������, � ����� ������\n6. ��������� ����� ������� - ���\n7. ��������� ������� /sob - ������ ������������� �� ID ������\n\n[������ 2.3]:\n\n1. ����������� ��������� ��� ���������� � ��������� �������������� �������.\n2. ��������� ���, ��-�� �������� � ���������� ��������� ����������� ������.\n3. ��������� ���, ��-�� �������� ���������� ���� ������� ����� ������ ��������.\n4. ��������� ���� ������� ����� ���������� �������.\n5. ��������� ���� � ��������� ������������� ����� ������ ���. �����.\n\n[������ 2.2]:\n\n1. ���������� ������������� ��������� �� ������� ������������ ��������� �� 10.\n2. ��������� ���, ��-�� �������� ���������� ���� ��-�� ��������� �������� � ����� �����.\n3. ��������� ���, ��-�� �������� ������ ��������� ��� ���������� ������� ���������� ���� �� ����� ��.\n4. ��������� ���, ��-�� �������� ���� ������ �������� �� ������������ �������������.\n5. ��������� ���, ��-�� �������� ����� �������� ������ ��� ������ �� ���� �������� ����.\n6. ������ ��� �������� ����� � �� ���� �� ������ ����������� ��� ��������.\n7. �������� � ������������ � ���������� ������ ������������ ������.\n8. ��������� ��� � �� ����, ��-�� �������� ��� ��������� �� ������� ������������ ������������.\n\n[������ 2.1]:\n\n1. ������ ������ ������������ ����������� "�������������".\n2. � �� ���� ��������� ��������� ��������.\n3. �� ������� "����������" ������ ���� ���������� � ������������� ���������� ������.\n4. �� ������� ������������ �������� ������ ��������� ����� �������� �����.\n5. ������� ����������� ���������� ������� ������ �������� � ���� �����.\n6. ������, ��� ��������� ������ �� ���������, � ������� ���������� ������ �����������.\n7. ����� ���������� ������ ������ ����� ������ ��������� ����������.\n8. � ���������� ������� ������ ����� ��������� �������������� ��������� �� �������.\n9. ��������� CURE ���� ��������� � ��������������� ��� ������� �������.\n10. ��������� ��� ��-�� �������� ������� � �������� ���� �������� ����.\n11. ��������� ��� ��-�� �������� ���������� ������������� � ����������� ������������ ��������� �� ������������.\n12. ��������� ��� ��-�� �������� � �� ����������� �������� ��������� �������.\n13. ��������� ��� ��-�� �������� ���������� ���� ������� �� ������� � ������� ��-�� ��������� �������� �������� � �����.\n14. ��������� ��� ��-�� �������� � �������� ���� ��������� ����������� ���� �� ���� �������� ����.\n15. ��������� ��� ��-�� �������� ���������� ���� ������� ��� ������ ����� � ������� ��������.\n16. ��������� ��� ��-�� �������� ������� �������� � ���������� ������� ����� ����� �������.\n17. ��������� ��� ��-�� �������� ���������� ���� ��� ������������ ������� �� ������� ������.\n18. ��������� ��� ��-�� �������� ��� id � ������� �� ���������� ����� ���������.\n19. ��������� ��� ��-�� �������� ��������� �� ��� �� ���������� ��� ���������� �������.\n20. ��������� ��� ��-�� �������� � ��� ���������� �� ������������ ������ � ��������� �������������.\n21. ��������� ��� ��-�� �������� ��������� �� ���������� ��� ���������� ���������� �������.\n22. ��������� ��� ��-�� �������� �� ������ �� ���������� �����, ����� ������� � ��������� �������� ��� ���������� ����� � �� ����.\n23. ������ � ������� ������� ������ �� ������ ����.')
					imgui.TextWrapped(u8'20. ��������� ��� ��-�� �������� � ��� ���������� �� ������������ ������ � ��������� �������������.\n21. ��������� ��� ��-�� �������� ��������� �� ���������� ��� ���������� ���������� �������.\n22. ��������� ��� ��-�� �������� �� ������ �� ���������� �����, ����� ������� � ��������� �������� ��� ���������� ����� � �� ����.\n23. ������ � ������� ������� ������ �� ������ ����.\n\n[������ 2.0]:\n\n1. ��������� ����� ������� � ������������ ������ ������ ��������� �������.\n2. ��������� ����� ������� � �������� ���� ���� � ������� ���������� � ����.\n3. ��������� ����� ������� ��� �������� �������������� � �����.\n4. �������� ����� ��� ������� ��� �������� �������������� ������� � ��������.\n5. �� ������� � ������� ������ ����� �������� ������ ������������, ������ �������.\n6. �� ������� �� ����������� ������ ����� �������� ����������� ���������� ������� �� ������.\n7. ��������� ������� ����������� ���������� �� ����� �� ����� � ������ ��������� �������.\n8. ��������� ������� ���������� ������ ���������� � ���� �� ����� �� ��������.\n9. ������� ��������� ������� hme ��� ������� ������ ����.\n10. �� ������� � ��������� ��������� ����������� ������ �������.\n11. ������� � ���������� ��������� ������ �� ������, ������ �� � ������ � �������.\n12. ���������� ������ ��-�� ������� ������ �� ������� ��-�� ������� �������� � ���� � ����.\n13. ���������� ������� ������� ��������� ������� � ����.\n14. ��������� �������������� �� ��������: ������������, �����, ������ ��������.\n15. ���������� ������ ���� ����������, � ����� ��������� ������������ �������.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.9]:\n\n1. ��������� �������.\n2. ��������� ��� � �������� ������������ ������� � ����������.\n3. ��������� ������� �������� ��� ���������.\n4. ��������� ��� ����� ������� ��� ��������: ���������� ��������� � ������ ��� �������� ������.\n\n[������ 1.8]:\n\n1. ��������� ��������� �������.\n2. ������� ������ ����� ��������.\n3. ��������� ������� ���� ��� ���������� ����� ���.\n4. ��������� ������� ����-��������� ������.\n5. ��������� ������� �������������� ��������� ��� �������� ����������\n6. � ���� ������������� ��������� ���������� � ������� �������� � ������ � �������� �� ����.\n7. � ����������� � ������ � ����� ������������ ��������� ������ �����.\n8. � ���� ������������ ��������� ����������� ������ ��������� ������������� �����.\n9. ���������� ������� ��������������� ��� ��������� ����������.\n10. � ������� SHOW ��������� ����������� ������ �������� ������.\n11. �������� ������ �������������� � �������� � ���� �������� �������.\n12. ��������� ����������� ������������� ��������� ����� ���� ������.\n13. ��������� ��� ���������� �� ������� ����������.\n14. ������ ����� � Discord ��� ������� �������� � ������ � ��������� �������.\n\n[������ 1.7]:\n\n1. ��������� ��� ���������� ��������� � ���������� ��������\n2. ��������� ��� ����������� ���������\n3. ��������� ��������� �������\n4. �������� ���������������� ����������.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.6]:\n\n1. ��������� ������� ����������\n2. ��������� ���������� �������� �������� � ��� ������������\n3. ����� ����� ������ �������� �� ������� Enter\n4. ���������� ��������� ���������������� �����.\n\n[������ 1.5]:\n\n1. ������� � ������� ������ ����� ��������\n2. ��������� ��� � ������������ ��������� � �����\n3. ��������� �������������� ����������� � ���������.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.4]:\n\n1. ������� ������ ����� �������� ����\n2. ��������� ����� ������� - ����������� ����\n3. ������ �������� ����� ������ ���� ��� �������\n4. ��������� ��������� ����� ��������\n5. ������ ����� �������� ����� ����\n6. ������ ���� ����� ��������� �������� ESC\n7. ��������� ��� � ������� �����������\n8. ��������� ��� � ������� �������� ������ �� 1 �����\n9. ��������� ��� � ������������ ������ ��� ��������� ���������\n10. ��������� ��� � ������������ ���������\n11. ��������� ��� ���� {mynick}\n12. ���������� ��� ��������� ������ �����, ������� ��� ������ ����������')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.3]:\n\n1. ������ ������ ����������� ��� ������ � ������ � �� ������� ����������\n2. ����� ��������� ��� ����������� ������� - /osm\n3. ��� ��������� ��� ��������� ���������\n4. ������ ������������ /offer ��������� ������ ���������\n5. ���������� ������ ���� � ���������� ������ �������')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.2]:\n\n1. ��������� ���� ����� ������ �����������������\n2. ������ � ���������� ������� ����� �������� �������� ������\n3. ��������� ��� � �������������������� ������ ���������\n4. ��������� ��� � ����������� ���������� ���������\n5. ������� � ��������� ����� �������')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[������ 1.1]:\n\n1. ����������� �� �������� ������ �������� �� 35\n2. ����� ������� ��� �������� �������� ��������� ������\n3. ��������� ��� � �������� /inv\n4. ��������� ��� � ������� � ���� �������� �������')
					imgui.PopFont()
					imgui.EndChild()
					imgui.Dummy(imgui.ImVec2(0, 20))
				elseif upd_status == 1 then
					new_draw(97, 43)
					imgui.SetCursorPos(imgui.ImVec2(34, 109))
					imgui.Text(u8'�������� ������� ����������...')
				elseif upd_status == 2 then
					new_draw(97, 308)
					imgui.SetCursorPos(imgui.ImVec2(30, 110))
					imgui.Image(IMG_New_Version, imgui.ImVec2(60, 60))
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(107, 127))
					imgui.Text(u8'State Helper ' .. upd.version)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(32, 185))
					imgui.BeginChild(u8'���� ����������', imgui.ImVec2(636, 180), false)
					imgui.TextWrapped(u8(upd.text)..'\n\n'..u8(upd.info))
					imgui.EndChild()
					
					if not update_box then
						skin.Button(u8'��������', 32, 365, 636, 27, function()
							if upd.version == '3.0' then 
								imgui.OpenPopup(u8'������������� ����������')
							else
								update_download()
								update_box = true
							end
						end)
					else
						skin.Button(u8'���������� ���������...##false_non', 32, 365, 636, 27, function() end)
					end
					
					if imgui.BeginPopupModal(u8'������������� ����������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
						imgui.PushFont(font[1])
						imgui.SetCursorPos(imgui.ImVec2(8, 12))
						imgui.Text(u8'��������! ����� ���������� ��� ��������� ���������!')
						imgui.Text(u8'����� ������ ������� � ����, ��� ��������� ��������')
						imgui.Text(u8'������� ����� ������������ ����������.')
						imgui.Text(u8'��������� ������ ������ ����� �����������, ���� ��� ����������')
						imgui.Text(u8'���� ������ �������� ���, ������ �����������.')
						skin.Button(u8'����������� ���������##�����', 15, 120, 225, 30, function() 
							update_download()
							update_box = true
							imgui.CloseCurrentPopup()
						end)
						skin.Button(u8'��������##�����', 250, 120, 225, 30, function() imgui.CloseCurrentPopup() end)
						imgui.PopFont()
						imgui.Dummy(imgui.ImVec2(0, 7))
						imgui.EndPopup()
					end
				end
				imgui.PopFont()
				imgui.EndChild()
				
			elseif select_basic[11] then
				if menu_draw_up(u8'� �������', true) then select_basic[11] = false end
				
				local function new_draw(pos_draw, par_dr_y)
					imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(180, 41))
				imgui.BeginChild(u8'� �������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 40)
				imgui.PushFont(bold_font[3])
				local calc = imgui.CalcTextSize('State Helper '..scr.version)
				imgui.SetCursorPos(imgui.ImVec2(332 - (calc.x / 2), 25))
				imgui.Text('State Helper '..scr.version)
				imgui.PopFont()
				
				new_draw(69, 43)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(15, 81))
				imgui.Text(u8'� 2024 ��� ����� ��������. ����������� ���������.')
				new_draw(124, 43)
				imgui.SetCursorPos(imgui.ImVec2(15, 136))
				imgui.Text(u8'���������� ������������: 5469 9804 2297 5769 (����� �����)')
				new_draw(179, 54)
				skin.Button(u8'���������� � �������� �� ������ �������', 15, 191, 636, 30, function()
					shell32.ShellExecuteA(nil, 'open', 'https://discord.gg/jJ3X67tAth', nil, nil, 1)
				end)
				new_draw(245, 54)
				skin.Button(u8'������� ���������������� ����������', 15, 257, 636, 30, function()
					shell32.ShellExecuteA(nil, 'open', 'https://raw.githubusercontent.com/KaneScripter/StateHelper/main/����������������%20����������.txt', nil, nil, 1)
				end)
				imgui.PopFont()
				imgui.EndChild()
				
			elseif select_basic[12] then
				if menu_draw_up(u8'������', true) then select_basic[12] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'������', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
				
				if setting.frac.org:find(u8'��������') then
					new_draw(17, 68)
					imgui.SetCursorPos(imgui.ImVec2(639, 30))
					if skin.Switch(u8'##������� �������', setting.godeath.func) then
						setting.godeath.func = not setting.godeath.func
						if setting.godeath.func and setting.godeath.cmd_go then
								sampRegisterChatCommand('go', function()
									sampSendChat('/godeath '.. id_player_godeath)
								end)
						elseif not setting.godeath.func and setting.godeath.cmd_go then
							sampUnregisterChatCommand('go')
						end
						save('setting')
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 31))
					imgui.Text(u8'��������� ������� ������� /godeath')
					imgui.PopFont()
					imgui.PushFont(font[3])
					imgui.SetCursorPos(imgui.ImVec2(34, 53))
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'��� ������ ������� �������� � �������� ������� ����� /godeath')
					imgui.PopFont()
					
					if setting.godeath.func then
						local function accent_col(num_acc, color_acc, color_acc_act)
							imgui.SetCursorPos(imgui.ImVec2(483 + (num_acc * 43), 285))
							local p = imgui.GetCursorScreenPos()
							
							imgui.SetCursorPos(imgui.ImVec2(472 + (num_acc * 43), 274))
							if imgui.InvisibleButton(u8'##����� �����'..num_acc, imgui.ImVec2(22, 22)) then
								setting.color_godeath = color_acc
								setting.godeath.color = num_acc
								save('setting')
								style_window()
							end
							if imgui.IsItemActive() then
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
							else
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 11, imgui.GetColorU32(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
							end
							if num_acc == setting.godeath.color then
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 4, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
							end
						end
						new_draw(100, 137)
						
						imgui.SetCursorPos(imgui.ImVec2(639, 113))
						if skin.Switch(u8'##��������� ����� ��������', setting.godeath.cmd_go) then
							setting.godeath.cmd_go = not setting.godeath.cmd_go
							if setting.godeath.cmd_go then
								sampRegisterChatCommand('go', function()
									sampSendChat('/godeath '.. id_player_godeath)
								end)
							else
								sampUnregisterChatCommand('go')
							end
							save('setting')
						end
						imgui.SetCursorPos(imgui.ImVec2(639, 143))
						if skin.Switch(u8'##���������� ���������� �� ��� �� �������������', setting.godeath.meter) then
							setting.godeath.meter = not setting.godeath.meter
							save('setting')
						end
						imgui.SetCursorPos(imgui.ImVec2(639, 173))
						if skin.Switch(u8'##�������� ��� ��������� � ������ �����', setting.godeath.two_text) then
							setting.godeath.two_text = not setting.godeath.two_text
							save('setting')
						end
						imgui.SetCursorPos(imgui.ImVec2(639, 203))
						if skin.Switch(u8'##���������� �������� ������', setting.godeath.auto_send) then
							setting.godeath.auto_send = not setting.godeath.auto_send
							save('setting')
						end
						imgui.PushFont(font[1])
						imgui.SetCursorPos(imgui.ImVec2(34, 114))
						imgui.Text(u8'��������� ��������� ����� �������� /go')
						imgui.SetCursorPos(imgui.ImVec2(34, 144))
						imgui.Text(u8'���������� ���������� �� ��� �� ��������')
						imgui.SetCursorPos(imgui.ImVec2(34, 174))
						imgui.Text(u8'�������� ��� ��������� � ������ �����')
						imgui.SetCursorPos(imgui.ImVec2(34, 204))
						imgui.Text(u8'������������� ����������� � ����� /r � �������� ������')
						
						new_draw(252, 67)
						
						imgui.SetCursorPos(imgui.ImVec2(34, 276))
						imgui.Text(u8'���� ������')
						imgui.PopFont()
						accent_col(0, {1.00, 0.33, 0.31}, {1.00, 0.23, 0.31})
						accent_col(1, {0.75, 0.35, 0.87}, {0.75, 0.25, 0.87})
						accent_col(2, {0.26, 0.45, 0.94}, {0.26, 0.35, 0.94})
						accent_col(3, {0.20, 0.74, 0.29}, {0.20, 0.64, 0.29})
						accent_col(4, {0.50, 0.50, 0.52}, {0.40, 0.40, 0.42})
					end
				else
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(173, 176 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'��� ��� ����������')
					imgui.PopFont()
				end
				imgui.EndChild()
			end
			
		----> [2] �������
		elseif select_main_menu[2] and select_cmd == 0 then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			menu_draw_up(u8'�������')
			skin.InputText(480, 11, u8'�����', 'search.cmd', 30, 130)
			
			local matching_indices = {}
			if search.cmd ~= '' then
				if #setting.cmd ~= 0 then
					search.cmd = search.cmd:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%1')
					for i, cmd in ipairs(setting.cmd) do
						if string.find(cmd[1], u8:decode(search.cmd)) then
							table.insert(matching_indices, i)
						end
					end
				end
				imgui.PushFont(font[3])

				local ind_end = 0
				local ind_two_end = 0
				if #matching_indices ~= 0 then
					ind_end = #matching_indices % 10
					ind_two_end = #matching_indices % 100
				end
				if ind_end == 1 and ind_two_end ~= 11 then
					local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'������� '..#matching_indices..u8' ����������')
				elseif ind_end > 1 and ind_end < 5 and ind_two_end ~= 12 and ind_two_end ~= 13 and ind_two_end ~= 14 then
					local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'������� '..#matching_indices..u8' ����������')
				else
					local calc = imgui.CalcTextSize('������� '..#matching_indices..' ����������')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'������� '..#matching_indices..u8' ����������')
				end
				imgui.PopFont()
			end
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(625, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##�������� �������', imgui.ImVec2(209, 22)) then
				local comp = 1
				local num_el = {}
				if #setting.cmd ~= 0 then
					for _, element in ipairs(setting.cmd) do
						if string.match(element[1], '^cmd%d+$') then
							table.insert(num_el, tonumber(string.match(element[1], '^cmd(%d+)$')))
						end
					end
				end
				if num_el ~= 0 then
					table.sort(num_el)
					for i = 1, #num_el do
						if num_el[i] ~= comp then
							break
						else
							comp = comp + 1
						end
					end
				end
				table.insert(setting.cmd, {'cmd'..comp, '', {}, '1'})
				save('setting')
				cmd = {
					nm = 'cmd'..comp,
					desc = u8'',
					delay = 2000,
					key = {},
					arg = {},
					var = {},
					act = {},
					num_d = 1,
					tr_fl = {0, 0, 0},
					add_f = {false, 1},
					not_send_chat = false,
					rank = '1'
				}
				local f = io.open(dirml..'/StateHelper/���������/cmd'..comp..'.json', 'w')
				f:write(encodeJson(cmd))
				f:flush()
				f:close()
				select_cmd = #setting.cmd
				anim_menu_cmd = {130, os.clock(), 0.00}
				sampRegisterChatCommand('cmd'..comp, function(arg) cmd_start(arg, 'cmd'..comp) end)
				sdvig_bool = false
				sdvig_num = 0
				sdvig = 0
			end
			imgui.PopStyleVar(1)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
			imgui.SetCursorPos(imgui.ImVec2(635, 17))
			imgui.Text(fa.ICON_PLUS)
			imgui.PopFont()
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(658, 13))
			imgui.Text(u8'�������� ����� �������')
			imgui.PopStyleColor(1)
			imgui.PopFont()
			
			local speed = 710
			local target_value = sdvig_bool and 120 or 0
			local currentTime = os.clock()
			local deltaTime = currentTime - time_os_shp
			time_os_shp = currentTime

			local target_value = sdvig_bool and 120 or 0

			if sdvig < target_value then
				sdvig = math.min(sdvig + speed * deltaTime, target_value)
			elseif sdvig > target_value then
				sdvig = math.max(sdvig - speed * deltaTime, target_value)
			end
			
			if not sdvig_bool then
				if sdvig == 0 then sdvig_num = 0 end
			end
			
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'�������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.cmd == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(141, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'��� �� ����� �������')
				imgui.PopFont()
			else
				if sdvig == 0 then
					new_draw(17, -1 + (#setting.cmd * 68))
				else
					imgui.SetCursorPos(imgui.ImVec2(0, 17))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.cmd * 68)), imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 30, 15)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + -1 + (#setting.cmd * 68) - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + -1 + (#setting.cmd * 68) - 28), 28, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.cmd * 68)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 30, 15)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + -1 + (#setting.cmd * 68) - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + -1 + (#setting.cmd * 68) - 28), 28, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
					end
				end
				imgui.PushFont(font[1])
				local remove_cmd
				for i = 1, #setting.cmd do
					local allocation = false
					local color_team = imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)
					local color_team2 = imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)
					if #matching_indices ~= 0 then
						for m = 1, #matching_indices do
							if matching_indices[m] == i then
								allocation = true
								break
							end
						end
					end
					if setting.int.theme == 'White' then
						if allocation then
							color_team = imgui.ImVec4(0.83, 0.65, 0.13, 1.00)
							color_team2 = imgui.ImVec4(0.83, 0.65, 0.13, 1.00)
						end
					else
						if allocation then
							color_team = imgui.ImVec4(0.83, 0.65, 0.13, 1.00)
							color_team2 = imgui.ImVec4(0.83, 0.65, 0.13, 1.00)
						else
							color_team = imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)
							color_team2 = imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(0 - sdvig, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##������� � �������� ���������'..i, imgui.ImVec2(666, 68)) then 
						sdvig_bool = not sdvig_bool
						if sdvig_num == 0 then
							sdvig_num = i
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.cmd ~= 1 and allocation then -- ��������� ��� �������
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 30, 3)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
					elseif i == 1 and #setting.cmd == 1 and allocation then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 30, 15) 
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
					elseif i == #setting.cmd and allocation then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 30, 12)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 60)
					elseif allocation then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.83, 0.55, 0.13, 1.00)), 30, 0)
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemActive() and sdvig == 0 then
						if i == 1 and #setting.cmd ~= 1 then -- �������
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(color_team), 30, 3)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(color_team), 60)
						elseif i == 1 and #setting.cmd == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(color_team), 30, 15) 
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(color_team), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 40), 28, imgui.GetColorU32(color_team), 60)
						elseif i == #setting.cmd then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(color_team), 30, 12)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 40), 28, imgui.GetColorU32(color_team), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(color_team), 30, 0)
						end
					end
					imgui.PushFont(fa_font[5])
					if sdvig_num ~= i and sdvig == 0 then
						imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
						imgui.Text('/'..setting.cmd[i][1])
						imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
						if setting.cmd[i][2]:gsub('%s','') == '' then
							imgui.Text(u8'��� ��������')
						else
							imgui.Text(setting.cmd[i][2])
						end
						imgui.PopStyleColor(1)
					elseif sdvig_num ~= i and sdvig ~= 0 then
						imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
						imgui.Text('/'..setting.cmd[i][1])
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.10))
						if setting.cmd[i][2]:gsub('%s','') == '' then
							imgui.Text(u8'��� ��������')
						else
							imgui.Text(setting.cmd[i][2])
						end
						imgui.PopStyleColor(1)
					end
					
					if sdvig_num == i then
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.cmd ~= 1 then -- ������ ����
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 18)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == 1 and #setting.cmd == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 22) -- ������ ������� ��������
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == #setting.cmd then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 20) -- ������ ������� ������
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 0) -- ������ ������� �������
						end
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##������� �������', imgui.ImVec2(60, 68)) then
							remove_cmd = i
							sdvig_bool = false
							sdvig_num = 0
							sdvig = 0
						end
						
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							if i == 1 and #setting.cmd ~= 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 18) -- ��
							elseif i == 1 and #setting.cmd == 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 22) -- ��
							elseif i == #setting.cmd then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 20) -- ��
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 0) -- ��
							end
						end
						
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
						imgui.SetCursorPos(imgui.ImVec2(626, 38 + ( (i - 1) * 68)))
						imgui.PushFont(fa_font[5])
						imgui.Text(fa.ICON_TRASH)
						imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
						imgui.Text(fa.ICON_PENCIL)
						imgui.PopFont()
						imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.cmd ~= 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 1) -- ������� �����
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team2), 60)
						elseif i == 1 and #setting.cmd == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 9) -- ��������
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team2), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team2), 60) 
						elseif i == #setting.cmd then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 8) -- ������ �����
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team2), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 0) -- �������� �������
						end
						
						imgui.SetCursorPos(imgui.ImVec2(640 - sdvig, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						imgui.SetCursorPos(imgui.ImVec2(17 - sdvig, 31 + ( (i - 1) * 68)))
						imgui.Text('/'..setting.cmd[i][1])
						imgui.SetCursorPos(imgui.ImVec2(17 - sdvig, 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
						if setting.cmd[i][2]:gsub('%s','') == '' then
							imgui.Text(u8'��� ��������')
						else
							imgui.Text(setting.cmd[i][2])
						end
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##������� �������', imgui.ImVec2(60, 68)) then
							sdvig_bool = false
							sdvig_num = 0
							sdvig = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/���������/'..setting.cmd[i][1]..'.json') then
								local f = io.open(dirml..'/StateHelper/���������/'..setting.cmd[i][1]..'.json')
								local setm = f:read('*a')
								f:close()
								local res, set = pcall(decodeJson, setm)
								if res and type(set) == 'table' then 
									cmd = set
								end
								select_cmd = i
								anim_menu_cmd = {130, os.clock(), 0.00}
							else
								remove_cmd = i
							end
						end
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
							imgui.PushFont(fa_font[5])
							imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
							imgui.Text(fa.ICON_PENCIL)
							imgui.PopFont()
						end
					end
				end
				if remove_cmd ~= nil then
					if doesFileExist(dirml..'/StateHelper/���������/'..setting.cmd[remove_cmd][1]..'.json') then
						os.remove(dirml..'/StateHelper/���������/'..setting.cmd[remove_cmd][1]..'.json')
					end
					sampUnregisterChatCommand(setting.cmd[remove_cmd][1])
					if #setting.cmd[remove_cmd][3] ~= 0 then
						rkeys.unRegisterHotKey(setting.cmd[remove_cmd][3])
					end
					table.remove(setting.cmd, remove_cmd) 
					save('setting')
					
				end
				if #setting.cmd > 1 then
					for draw = 1, #setting.cmd - 1 do
						if sdvig == 0 then
							skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
						else
							skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.20), 0, 0)
						end
					end
				end
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 80))
			imgui.EndChild()
		elseif select_main_menu[2] and select_cmd ~= 0 then
			local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
				if sizes_if_win == nil then
					sizes_if_win = {17, 666}
				end
				imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
				local p = imgui.GetCursorScreenPos()
				if comm_tr == nil then
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
					end
				else
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 8, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 8, 15)
					end
				end
			end
			
			if menu_draw_up(u8'�������������� �������', true) then
				imgui.OpenPopup(u8'���������� �������� � ��������')
				command_err_nm = false
				command_err_cmd = false
			end
			--[[
			if skin.Button(u8'������� ��������������', 670, 10, 160, 25, function() end) then
			
			end
			]]
			if imgui.BeginPopupModal(u8'���������� �������� � ��������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'�������� � ��������', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##������� ������ ������', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(6, 3))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				
				imgui.PushFont(bold_font[4])
				if not command_err_nm and not command_err_cmd then
					imgui.SetCursorPos(imgui.ImVec2(35, 55))
					imgui.Text(u8'�������� ��������')
				elseif not command_err_cmd then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'������')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(63, 95))
					imgui.Text(u8'����� ������� ��� ����������!')
					imgui.PopFont()
				elseif command_err_cmd then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'������')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(126, 95))
					imgui.Text(u8'������� �������!')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'���������', 10, 167, 123, 25, function()
					if cmd.nm == 'sh' or cmd.nm == 'ts' then command_err_nm = true end
					for i = 1, #setting.cmd do
						if setting.cmd[i][1] == cmd.nm and i ~= select_cmd then
							command_err_nm = true
							break
						end
					end
					if cmd.nm == '' then
						command_err_cmd = true
					end
					if not command_err_nm and not command_err_cmd then
						if doesFileExist(dirml..'/StateHelper/���������/'..setting.cmd[select_cmd][1]..'.json') then
							os.remove(dirml..'/StateHelper/���������/'..setting.cmd[select_cmd][1]..'.json')
						end
						local f = io.open(dirml..'/StateHelper/���������/'..cmd.nm..'.json', 'w')
						f:write(encodeJson(cmd))
						f:flush()
						f:close()
						if setting.cmd[select_cmd][1] ~= cmd.nm then
							sampUnregisterChatCommand(setting.cmd[select_cmd][1])
							sampRegisterChatCommand(cmd.nm, function(arg) cmd_start(arg, cmd.nm) end)
						end
						if #setting.cmd[select_cmd][3] ~= 0 then
							rkeys.unRegisterHotKey(setting.cmd[select_cmd][3])
						end
						if #cmd.key ~= 0 then
							rkeys.registerHotKey(cmd.key, 3, true, function() on_hot_key(cmd.key) end)
						end
						setting.cmd[select_cmd] = {cmd.nm, cmd.desc, cmd.key, cmd.rank}
						save('setting')
						select_cmd = 0
						imgui.CloseCurrentPopup()
					end
				end)
				skin.Button(u8'�� ���������', 138, 167, 124, 25, function()
					select_cmd = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'�������', 267, 167, 123, 25, function()
					if doesFileExist(dirml..'/StateHelper/���������/'..setting.cmd[select_cmd][1]..'.json') then
						os.remove(dirml..'/StateHelper/���������/'..setting.cmd[select_cmd][1]..'.json')
					end
					sampUnregisterChatCommand(setting.cmd[select_cmd][1])
					if #setting.cmd[select_cmd][3] ~= 0 then
						rkeys.unRegisterHotKey(setting.cmd[select_cmd][3])
					end
					table.remove(setting.cmd, select_cmd)
					save('setting')
					select_cmd = 0
					imgui.CloseCurrentPopup()
				end)
				imgui.PopFont()
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			if select_cmd ~= 0 then
				local function dr_circuit_mini(y_pos_plus, icon_circ, imvec4_ic)
					local return_bool = false
					
					local pos_icon = {4, 0}
					local text_add_func = ''
					if icon_circ == fa.ICON_SHARE then
						text_add_func = u8'��������� � ���'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'�������� ������� ������� Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'������� ���������� � ��� (��� ����)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'�������� �������� ����������'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'�����������'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'������ ������ ����������� ��������'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'���� ������ ������� �������...'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'���� ���������� �����...'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������� ����������'
					end
					
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
					if imgui.InvisibleButton(u8'##�������� ������� � ���������'..POS_Y_CMD_F + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(101, POS_Y_CMD_F + y_pos_plus + 1))
						local p = imgui.GetCursorScreenPos()
						
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(105, POS_Y_CMD_F + y_pos_plus + 5))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
					
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(580, POS_Y_CMD_F + y_pos_plus + 9))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
					imgui.SetCursorPos(imgui.ImVec2(105 + pos_icon[1], POS_Y_CMD_F + y_pos_plus + 9 + pos_icon[2]))
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(140, POS_Y_CMD_F + y_pos_plus + 8))
					imgui.Text(text_add_func)
					
					return return_bool
				end
				
				if active_child_cmd then
					if pos_Y_cmd < 150 then
						pos_Y_cmd = pos_Y_cmd + 10
					else
						pos_Y_cmd = 150
					end
				else
					if pos_Y_cmd > 35 then
						pos_Y_cmd = pos_Y_cmd - 10
					else
						pos_Y_cmd = 35
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos))
				if imgui.InvisibleButton(u8'##���������� �������� �� ��������', imgui.ImVec2(702, 35)) then
					active_child_cmd = not active_child_cmd
				end
				if imgui.IsItemActive() then
					if setting.int.theme == 'White' then
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] - 0.03, col_end.fond_two[2] - 0.03, col_end.fond_two[3] - 0.03, 1.00), 15, 20)
					else
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00), 15, 20)
					end
				elseif imgui.IsItemHovered() then
					if setting.int.theme == 'White' then
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] - 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00), 15, 20)
					else
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00), 15, 20)
					end
				else
					if setting.int.theme == 'White' then
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
					else
						skin.DrawFond({162, 429 - (pos_Y_cmd - 35) + start_pos + new_pos}, {0, 0}, {702, pos_Y_cmd}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
					end
				end
				skin.DrawFond({162, 428 - (pos_Y_cmd - 35) + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(360, 434 - (pos_Y_cmd - 35) + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'�������� ���������� ��������')
				imgui.PopFont()
				imgui.PushFont(fa_font[5])
				imgui.SetCursorPos(imgui.ImVec2(650, 433 - (pos_Y_cmd - 35) + start_pos + new_pos))
				if active_child_cmd then
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_DOWN)
				else
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_UP)
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				if active_child_cmd then
					skin.DrawFond({162, 462 - (pos_Y_cmd - 35) + start_pos + new_pos}, {-0.5, 0}, {702, 1.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
					imgui.SetCursorPos(imgui.ImVec2(163, 464 - (pos_Y_cmd - 35) + start_pos + new_pos))
					imgui.BeginChild(u8'������� ��������', imgui.ImVec2(700, pos_Y_cmd - 35), false)
					local num_a = #cmd.act + 1
					if cmd.add_f[1] and #cmd.act ~= 0 then
						num_a = cmd.add_f[2] + 1
					end
					
					if dr_circuit_mini(50, fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {0, u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {0, u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					if dr_circuit_mini(90, fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {1, u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {1, u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					if dr_circuit_mini(130, fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {2, u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {2, u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					if dr_circuit_mini(170, fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {3, cmd.num_d, 2, {u8'�������� 1', u8'�������� 2'}}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'�������� 1', u8'�������� 2'}})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
						cmd.num_d = cmd.num_d + 1
						cmd.tr_fl[2] = cmd.tr_fl[2] + 1
					end
					if dr_circuit_mini(210, fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {4, u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {4, u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					local res_pos = 250
					if #cmd.var ~= 0 then
						if dr_circuit_mini(res_pos, fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00)) then
							if not cmd.add_f[1] or #cmd.act == 0 then
								cmd.act[num_a] = {5, '{var1}', u8''}
							elseif cmd.add_f[1] and #cmd.act ~= 0 then
								table.insert(cmd.act, num_a, {5, '{var1}', u8''})
								cmd.add_f[2] = cmd.add_f[2] + 1
							end
						end
						res_pos = res_pos + 40
						if dr_circuit_mini(res_pos, fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
							if not cmd.add_f[1] or #cmd.act == 0 then
								cmd.act[num_a] = {6, '{var1}', ''}
							elseif cmd.add_f[1] and #cmd.act ~= 0 then
								table.insert(cmd.act, num_a, {6, '{var1}', ''})
								cmd.add_f[2] = cmd.add_f[2] + 1
							end
							cmd.tr_fl[1] = cmd.tr_fl[1] + 1
						end
						res_pos = res_pos + 40
					end
					
					if cmd.tr_fl[1] ~= 0 then
						if dr_circuit_mini(res_pos, fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
							if not cmd.add_f[1] or #cmd.act == 0 then
								cmd.act[num_a] = {7, '{var1}'}
							elseif cmd.add_f[1] and #cmd.act ~= 0 then
								table.insert(cmd.act, num_a, {7, ''})
								cmd.add_f[2] = cmd.add_f[2] + 1
							end
						end
						res_pos = res_pos + 40
					end
					if cmd.tr_fl[2] ~= 0 then
						if dr_circuit_mini(res_pos, fa.ICON_SIGN_OUT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
							if not cmd.add_f[1] or #cmd.act == 0 then
								cmd.act[num_a] = {8, '1', '1'}
							elseif cmd.add_f[1] and #cmd.act ~= 0 then
								table.insert(cmd.act, num_a, {8, '1', '1'})
								cmd.add_f[2] = cmd.add_f[2] + 1
							end
							cmd.tr_fl[3] = cmd.tr_fl[3] + 1
						end
						res_pos = res_pos + 40
					end
					if cmd.tr_fl[2] ~= 0 and cmd.tr_fl[3] ~= 0 then
						if dr_circuit_mini(res_pos, fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
							if not cmd.add_f[1] or #cmd.act == 0 then
								cmd.act[num_a] = {9, '1', '1'}
							elseif cmd.add_f[1] and #cmd.act ~= 0 then
								table.insert(cmd.act, num_a, {9, ''})
								cmd.add_f[2] = cmd.add_f[2] + 1
							end
						end
						res_pos = res_pos + 40
				end
					imgui.EndChild()
				end
				imgui.PopFont()
				
				local speed = (anim_menu_cmd[1] - 39) * 5.8
				local currentTime = os.clock()
				local deltaTime = currentTime - anim_menu_cmd[2]
				anim_menu_cmd[2] = currentTime

				local anim_duration = math.abs(anim_menu_cmd[1] - 41) / speed
				if anim_menu_cmd[1] ~= 41 then
					local progress = deltaTime / anim_duration
					if progress >= 1 then
						anim_menu_cmd[1] = 41
					else
						anim_menu_cmd[1] = anim_menu_cmd[1] - (anim_menu_cmd[1] - 41) * progress
					end
				end

				local fade_duration = math.abs(anim_menu_cmd[3] - 1.0) / (speed * 0.0062)
				if anim_menu_cmd[3] < 1.0 then
					local progress = deltaTime / fade_duration
					if progress >= 1 then
						anim_menu_cmd[3] = 1.0
					else
						anim_menu_cmd[3] = anim_menu_cmd[3] + (1.0 - 0.05) * progress
					end
				end
		
				imgui.PushStyleVar(imgui.StyleVar.Alpha, anim_menu_cmd[3])
				imgui.SetCursorPos(imgui.ImVec2(163, anim_menu_cmd[1]))
				imgui.BeginChild(u8'�������������� ������� ������', imgui.ImVec2(700, 422 - pos_Y_cmd + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				imgui.PushFont(font[1])
				new_draw(17, 97)
				skin.InputText(114, 31, u8'���������� �������', 'cmd.nm', 15, 553, '[%a%d+-]+')
				if cmd.nm:find('%A+') then
					local characters_to_remove = {
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'
					}
					local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
					cmd.nm = string.gsub(cmd.nm, remove_pattern, '')
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 34))
				imgui.Text(u8'�������   /')
				skin.Button(u8'���������, �������� ��� �������� ������� ���������', 34, 68, 633, nil, function()
					imgui.OpenPopup(u8'������� ��������� �������')
					lockPlayerControl(true)
					current_key = {'', {}}
					edit_key = true
				end)
				
				if imgui.BeginPopupModal(u8'������� ��������� �������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##������� ������ ������ ���������', imgui.ImVec2(20, 20)) then
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(20, 20))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
						imgui.SetCursorPos(imgui.ImVec2(16, 13))
						imgui.PushFont(fa_font[2])
						imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
						imgui.PopFont()
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 40))
					imgui.BeginChild(u8'���������� ������� ���������', imgui.ImVec2(383, 217), false, imgui.WindowFlags.NoScrollbar)
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(10, 0))
					imgui.Text(u8'������� ��������� ������ ��� ���������')
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(10, 50))
					imgui.Text(u8'������� ���������:')
					imgui.SetCursorPos(imgui.ImVec2(145, 50))
					if #cmd.key == 0 then
						imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'�����������')
					else
						local all_keys = {}
						for i = 1, #cmd.key do
							table.insert(all_keys, vkeys.id_to_name(cmd.key[i]))
						end
						imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_keys, ' + '))
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 80))
					imgui.Text(u8'������������ ��� � ���������� � ���������')
					imgui.PopFont()
					imgui.PopFont()
					skin.DrawFond({0, 36}, {0, 0}, {381, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
					imgui.SetCursorPos(imgui.ImVec2(342, 79))
					if skin.Switch(u8'##��� � ���������', right_mb) then right_mb = not right_mb end
					
					if imgui.IsMouseClicked(0) then
						lua_thread.create(function()
							wait(500)
							setVirtualKeyDown(3, true)
							wait(0)
							setVirtualKeyDown(3, false)
						end)
					end
					local currently_pressed_keys = rkeys.getKeys(true)
					local pr_key_num = {}
					local pr_key_name = {}
					if #currently_pressed_keys ~= 0 then
						local stop_hot = false
						for i = 1, #currently_pressed_keys do
							local parts = {}
							for part in currently_pressed_keys[i]:gmatch('[^:]+') do
								table.insert(parts, part)
							end
							if currently_pressed_keys[i] ~= '1:Left Button' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
							and currently_pressed_keys[i] ~= '2:RBut' then
								table.insert(pr_key_num, tonumber(parts[1]))
								table.insert(pr_key_name, parts[2])
							else
								stop_hot = true
							end
						end
						if not stop_key_move and not stop_hot then
							current_key[1] = table.concat(pr_key_name, ' + ')
							current_key[2] = pr_key_num
							stop_key_move = true
							lua_thread.create(function()
								wait(250)
								stop_key_move = false
							end)
						end
					end
					if current_key[1] == nil then
						current_key[1] = 'nil'
					end
					if current_key[1] ~= u8'����� ���������� ��� ����������' then
						imgui.PushFont(bold_font[4])
						local calc = imgui.CalcTextSize(current_key[1])
						imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 116))
						if calc.x >= 385 then
							imgui.PopFont()
							imgui.PushFont(font[4])
							calc = imgui.CalcTextSize(current_key[1])
							imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 126))
						end
						imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
						imgui.PopFont()
					else
						imgui.PushFont(font[4])
						local calc = imgui.CalcTextSize(current_key[1])
						imgui.SetCursorPos(imgui.ImVec2(192 - calc.x / 2, 126))
						imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
						imgui.PopFont()
					end
					
					
					skin.Button(u8'���������', 0, 180, 185, nil, function()
						local is_hot_key_done = rkeys.isHotKeyDefined(current_key[2])
						
						if #setting.cmd[select_cmd][3] ~= 0 and #current_key[2] ~= 0 then
							local comp_key = 0
							if #setting.cmd[select_cmd][3] == #current_key[2] then
								for i = 1, #setting.cmd[select_cmd][3] do
									if setting.cmd[select_cmd][3][i] == current_key[2][i] then
										comp_key = comp_key + 1
									end
								end
							end
							if comp_key == #setting.cmd[select_cmd][3] then is_hot_key_done = false end
						end
						if is_hot_key_done then current_key = {u8'����� ���������� ��� ����������', {}} end
						if not is_hot_key_done then
							if right_mb then table.insert(current_key[2], 1, 2) end
							cmd.key = current_key[2]
							lockPlayerControl(false)
							edit_key = false
							imgui.CloseCurrentPopup()
						end
					end)
					skin.Button(u8'��������', 195, 180, 186, nil, function()
						current_key = {'', {}}
					end)
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(126, 50)
				skin.InputText(114, 140, u8'������� ��������', 'cmd.desc', 120, 553)
				imgui.SetCursorPos(imgui.ImVec2(35, 143))
				imgui.Text(u8'��������')
				
				new_draw(188, 50)
				imgui.SetCursorPos(imgui.ImVec2(35, 205))
				imgui.Text(u8'������ � �������')
				if skin.Slider('##������ � �������', 'cmd.rank', 1, 10, 205, {470, 202}, '') then
					cmd.rank = round(cmd.rank, 1)
				end
				imgui.SetCursorPos(imgui.ImVec2(396, 201))
				imgui.Text(u8'� ' ..cmd.rank.. u8' �����')
				
				new_draw(250, 84)
				skin.Button(u8'������ ��� �������� ���������', 34, 262, 633, nil, function()
					imgui.OpenPopup(u8'�������������� ����������')
				end)
				local all_arguments = ''
				if #cmd.arg ~= 0 then
					for ka = 1, #cmd.arg do
						all_arguments = all_arguments..' {arg'..ka..'}'
					end
				else
					all_arguments = u8' �����������'
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 309))
				imgui.Text(u8'������� ���������:'..all_arguments)
				
				if imgui.BeginPopupModal(u8'�������������� ����������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.BeginChild(u8'�������� ����������', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
					imgui.SetCursorPos(imgui.ImVec2(0, 0))
					if imgui.InvisibleButton(u8'##������� ������ ����������', imgui.ImVec2(20, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
						imgui.SetCursorPos(imgui.ImVec2(6, 3))
						imgui.PushFont(fa_font[2])
						imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
						imgui.PopFont()
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					
					if #cmd.arg == 0 then
						imgui.PushFont(font[4])
						imgui.SetCursorPos(imgui.ImVec2(134, 104))
						imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'��� ����������')
						imgui.PopFont()
					else
						for cm = 1, #cmd.arg do
							local pos_y_c = ( (cm - 1) * 40)
							new_draw(28 + pos_y_c, 30, {5, 390})
							
							imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
							if imgui.InvisibleButton(u8'##������� ��������'..cm, imgui.ImVec2(20, 20)) then table.remove(cmd.arg, cm) break end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(373, 36 + pos_y_c))
							imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_TRASH)
							imgui.PopFont()
							
							imgui.SetCursorPos(imgui.ImVec2(15, 34 + pos_y_c))
							if cmd.arg[cm][1] == 0 then
								imgui.Text(cm.. u8' �������� � ����� {arg'..cm..'}')
							else
								imgui.Text(cm.. u8' ��������� � ����� {arg'..cm..'}')
							end
							skin.InputText(190, 32 + pos_y_c, u8'�������� ���������##vgas'..cm, 'cmd.arg.'..cm..'.2', 64, 170)
						end
					end
					if #cmd.arg < 5 then
						skin.Button(u8'�������� �������� ��������', 0, 240, 400, 25, function() 
							table.insert(cmd.arg, {0, u8'�����'})
						end)
						skin.Button(u8'�������� ��������� ��������', 0, 270, 400, 25, function() 
							table.insert(cmd.arg, {1, u8'�����'})
						end)
					else
						skin.Button(u8'�������� �������� ��������##false_non', 0, 240, 400, 25, function() end)
						skin.Button(u8'�������� ��������� ��������##false_non', 0, 270, 400, 25, function() end)
					end
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(346, 84)
				skin.Button(u8'������ ��� �������� ����������', 34, 358, 633, nil, function()
					imgui.OpenPopup(u8'�������������� ����������')
				end)
				imgui.SetCursorPos(imgui.ImVec2(35, 405))
				imgui.Text(u8'������� ���������� ����������: '..#cmd.var)
				
				if imgui.BeginPopupModal(u8'�������������� ����������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.BeginChild(u8'�������� ����������', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
					imgui.SetCursorPos(imgui.ImVec2(0, 0))
					if imgui.InvisibleButton(u8'##������� ������ ����������', imgui.ImVec2(20, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
						imgui.SetCursorPos(imgui.ImVec2(6, 3))
						imgui.PushFont(fa_font[2])
						imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
						imgui.PopFont()
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					
					if #cmd.var == 0 then
						imgui.PushFont(font[4])
						imgui.SetCursorPos(imgui.ImVec2(134, 118))
						imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'��� ����������')
						imgui.PopFont()
					else
						for cm = 1, #cmd.var do
							local pos_y_c = ( (cm - 1) * 40)
							new_draw(28 + pos_y_c, 30, {5, 390})
							
							imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
							if imgui.InvisibleButton(u8'##������� ����������'..cm, imgui.ImVec2(20, 20)) then 
								table.remove(cmd.var, cm)
								if #cmd.var == 0 and #cmd.act ~= 0 then
									cmd.tr_fl[1] = 0
									for m = #cmd.act, 1, -1 do
										if cmd.act[m][1] == 5 or cmd.act[m][1] == 6 or cmd.act[m][1] == 7 then
											table.remove(cmd.act, m)
											if cmd.add_f[1] then
												if m <= cmd.add_f[2] then cmd.add_f[2] = cmd.add_f[2] - 1 end
											end
										end
									end
								elseif #cmd.var == 0 then
									cmd.tr_fl[1] = 0
								end
							end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(373, 36 + pos_y_c))
							imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_TRASH)
							imgui.PopFont()
							
							imgui.SetCursorPos(imgui.ImVec2(15, 34 + pos_y_c))
							imgui.Text(cm.. u8'. ��� {var'..cm..'}')
							if cmd.var[cm] ~= nil then
								skin.InputText(110, 32 + pos_y_c, u8'�������� ����������##'..cm, 'cmd.var.'..cm..'.2', 40, 250)
							end
						end
					end
					if #cmd.var < 6 then
						skin.Button(u8'�������� ����� ����������', 0, 270, 400, 25, function() 
							table.insert(cmd.var, {1, u8''})
						end)
					else
						skin.Button(u8'�������� ����� ����������##false_non', 0, 270, 400, 25, function() end)
					end
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(442, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 454))
				imgui.Text(u8'�������� ������������ ���������')
				skin.Slider('##�������� ������������ ���������', 'cmd.delay', 400, 10000, 205, {470, 453}, nil)
				imgui.SetCursorPos(imgui.ImVec2(417, 452))
				imgui.Text(round(cmd.delay / 1000, 0.1)..u8' ���.')
				
				new_draw(498, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 510))
				imgui.Text(u8'�� ���������� ��������� ��������� � ���')
				imgui.SetCursorPos(imgui.ImVec2(639, 509))
				if skin.Switch(u8'##�� ���������� ��������� � ���', setting.not_send_chat) then setting.not_send_chat = not setting.not_send_chat save('setting') end
				local POS_Y = 560
				
				local function ic_draw(icon_circ, imvec4_ic)
					local pos_icon = {4, 0}
					local text_add_func = ''
					if icon_circ == fa.ICON_SHARE then
						text_add_func = u8'��������� � ���'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'�������� ������� ������� Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'������� ���������� � ��� (��� ����)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'�������� �������� ����������'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'�����������'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'������ ������ ��������'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'���� � �������                     ������ �������'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������� �������'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'���� ����������                               �����'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������� ����������'
					end
					
					imgui.SetCursorPos(imgui.ImVec2(35, POS_Y + 10))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
					
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(35 + pos_icon[1], POS_Y + 14 + pos_icon[2]))
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(648, POS_Y + 16))
					imgui.PushFont(fa_font[1])
					imgui.Text(fa.ICON_TRASH)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(70, POS_Y + 13))
					imgui.Text(text_add_func)
					if icon_circ ~= fa.ICON_HOURGLASS and icon_circ ~= fa.ICON_SIGN_OUT and icon_circ ~= fa.ICON_STOP..'2' 
					and icon_circ ~= fa.ICON_SUPERSCRIPT and icon_circ ~= fa.ICON_STOP..'1' then
						imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 44))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)))
					end
				end
				local function sel_add_f(pos_y_SDF, i_sel)
					if cmd.add_f[1] and cmd.add_f[2] == i_sel then
						imgui.SetCursorPos(imgui.ImVec2(23, POS_Y + pos_y_SDF))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 656, p.y + 12), imgui.GetColorU32(imgui.ImVec4(0.11, 0.70, 0.07 ,1.00)))
					end
				end
				if #cmd.act ~= 0 then
					local remove_table = {}
					local del_d = 0
					for i, v in ipairs(cmd.act) do
						imgui.SetCursorPos(imgui.ImVec2(1, POS_Y))
						if i <= 99 then
							imgui.PushFont(font[3])
							imgui.Text(tostring(i))
							imgui.PopFont()
						else
							imgui.PushFont(font[6])
							imgui.Text(tostring(i))
							imgui.PopFont()
						end
						if v[1] == 0 then
							new_draw(POS_Y, 97)
							ic_draw(fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
							skin.InputText(35, POS_Y + 60, u8'�����##fj'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(97, i)
							POS_Y = POS_Y + 109
						elseif v[1] == 1 then
							new_draw(POS_Y, 45)
							ic_draw(fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 45))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(45, i)
							POS_Y = POS_Y + 57
						elseif v[1] == 2 then
							new_draw(POS_Y, 97)
							ic_draw(fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
							skin.InputText(35, POS_Y + 60, u8'�����##fe3'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(97, i)
							POS_Y = POS_Y + 109
						elseif v[1] == 3 then
							new_draw(POS_Y, 98 + (cmd.act[i][3] * 30))
							ic_draw(fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00))
							
							imgui.SetCursorPos(imgui.ImVec2(250, POS_Y + 22))
							local p = imgui.GetCursorScreenPos()
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.7, p.y + 0.5), 10, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
							
							if v[2] <= 9 then
								imgui.SetCursorPos(imgui.ImVec2(245, POS_Y + 14))
							else
								imgui.SetCursorPos(imgui.ImVec2(241, POS_Y + 14))
							end
							imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00), tostring(cmd.act[i][2]))
							
							for d = 1, v[3] do
								imgui.SetCursorPos(imgui.ImVec2(34, POS_Y + 32 + (d * 30)))
								imgui.Text(d..u8' ��������')
								skin.InputText(125, POS_Y + 30 + (d * 30), u8'��� ��������##'..i..d, 'cmd.act.'..i..'.4.'..d, 40, 500)
							end
							
							if v[3] >= 3 then
								for d = 3, v[3] do
									imgui.SetCursorPos(imgui.ImVec2(648, POS_Y + 34 + (d * 30)))
									imgui.PushFont(fa_font[1])
									imgui.Text(fa.ICON_TRASH)
									imgui.PopFont()
									imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 30 + (d * 30)))
									if imgui.InvisibleButton(u8'##������� �������� �������'..i..d, imgui.ImVec2(20, 20)) then
										table.remove(v[4], d)
										v[3] = v[3] - 1
										for h = 1, #cmd.act do
											if cmd.act[h][1] == 8 then
												if tonumber(cmd.act[h][2]) == cmd.act[i][2] then
													if tonumber(cmd.act[h][3]) >= d then
														local poike = tonumber(cmd.act[h][3])
														poike = poike - 1
														cmd.act[h][3] = tostring(poike)
													end
												end
											end
										end
									end
								end
							end
							if v[3] <= 4 then
								skin.Button(u8'��������##'..i, 34, POS_Y + 60 + (v[3] * 30), 100, 23, function()
									v[3] = v[3] + 1
									table.insert(v[4], u8'�������� '..v[3])
								end)
							else
								skin.Button(u8'��������##false_non', 34, POS_Y + 60 + (v[3] * 30), 100, 23, function() end)
							end
							
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then
								for k, m in ipairs(cmd.act) do
									if m[1] == 3 then
										if m[2] > v[2] then
											m[2] = m[2] - 1
										end
									elseif m[1] == 8 then
										if tonumber(m[2]) > v[2] then
											local pokat = tonumber(m[2])
											pokat = pokat - 1
											m[2] = tostring(pokat)
										elseif tonumber(m[2]) == v[2] then
											table.insert(remove_table, k)
											cmd.tr_fl[3] = cmd.tr_fl[3] - 1
										end
									end
								end
								table.insert(remove_table, i)
								cmd.tr_fl[2] = cmd.tr_fl[2] - 1
								del_d = del_d + 1
							end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 98 + (cmd.act[i][3] * 30)))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(98 + (cmd.act[i][3] * 30), i)
							POS_Y = POS_Y + 110 + (cmd.act[i][3] * 30)
						elseif v[1] == 4 then
							new_draw(POS_Y, 97, nil, 'comm')
							ic_draw(fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00))
							skin.InputText(35, POS_Y + 60, u8'����� �����������##'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(97, i)
							POS_Y = POS_Y + 109
						elseif v[1] == 5 then
							new_draw(POS_Y, 97)
							ic_draw(fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00))
							local var_sum = {}
							for k = 1, #cmd.var do
								var_sum[k] = '{var'..k..'}'
							end
							skin.List({36, POS_Y + 56}, cmd.act[i][2], var_sum, 185, 'cmd.act.'..i..'.2')
							skin.InputText(235, POS_Y + 60, u8'����� ��������##'..i, 'cmd.act.'..i..'.3', 256, 430)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(97, i)
							POS_Y = POS_Y + 109
						elseif v[1] == 6 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00))
							local all_var = {}
							for j = 1, #cmd.var do
								all_var[j] = '{var'..j..'}'
							end
							skin.List({190, POS_Y + 6}, v[2], all_var, 100, 'cmd.act.'..i..'.2')
							skin.InputText(345, POS_Y + 10, u8'�������� ����������##'..i, 'cmd.act.'..i..'.3', 256, 260)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i, imgui.ImVec2(20, 20)) then 
								table.insert(remove_table, i)
								cmd.tr_fl[1] = cmd.tr_fl[1] - 1
								if cmd.tr_fl[1] == 0 then
									for j = 1, #cmd.act do
										if cmd.act[j][1] == 7 then table.insert(remove_table, i) end
									end
								end
							end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						elseif v[1] == 7 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						elseif v[1] == 8 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_SIGN_OUT, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00))
							local all_dialogs = { 0, {}, {} }
							for j = 1, #cmd.act do
								if cmd.act[j][1] == 3 then
									all_dialogs[1] = all_dialogs[1] + 1
									table.insert(all_dialogs[2], tostring(all_dialogs[1]))
								end
							end
							for j = 1, #cmd.act do
								if cmd.act[j][1] == 3 then
									if cmd.act[j][2] == tonumber(cmd.act[i][2]) then
										all_dialogs[1] = 0
										for h = 1, cmd.act[j][3] do
											all_dialogs[1] = all_dialogs[1] + 1
											table.insert(all_dialogs[3], tostring(all_dialogs[1]))
										end
									end
								end
							end
							skin.List({176, POS_Y + 6}, v[2], all_dialogs[2], 60, 'cmd.act.'..i..'.2')
							skin.List({360, POS_Y + 6}, v[3], all_dialogs[3], 60, 'cmd.act.'..i..'.3')
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then
								table.insert(remove_table, i)
								cmd.tr_fl[3] = cmd.tr_fl[3] - 1
								for s = 1, #cmd.act do
									if cmd.act[s][1] == 9 then
										if tonumber(cmd.act[s][2]) == tonumber(v[2]) then
											table.insert(remove_table, s)
										end
									end
								end
							end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						elseif v[1] == 9 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##������� ��������'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##������� ����� �������'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						end
					end
					
					if #remove_table ~= 0 then
						local function reverseCompare(a_t, b_t)
							return a_t > b_t
						end
						table.sort(remove_table, reverseCompare)
						for back = 1, #remove_table do
							table.remove(cmd.act, remove_table[back])
							if cmd.add_f[1] then
								if remove_table[back] <= cmd.add_f[2] then cmd.add_f[2] = cmd.add_f[2] - 1 end
							end
						end
						remove_table = {}
					end
					cmd.num_d = cmd.num_d - del_d
				end
				
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(197, POS_Y + 13))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'�������� ���������� ��������')
				imgui.PopFont()
				imgui.PushFont(fa_font[5])
				imgui.SetCursorPos(imgui.ImVec2(487, POS_Y + 12))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_ANGLE_DOWN)
				imgui.PopFont()
				
				local function dr_circuit(y_pos_plus, icon_circ, imvec4_ic)
					local return_bool = false
					
					local pos_icon = {4, 0}
					local text_add_func = ''
					if icon_circ == fa.ICON_SHARE then
						text_add_func = u8'��������� � ���'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'�������� ������� ������� Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'������� ���������� � ��� (��� ����)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'�������� �������� ����������'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'�����������'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'������ ������ ����������� ��������'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'���� ������ ������� �������...'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'���� ���������� �����...'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'��������� ������� ����������'
					end
					
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
					if imgui.InvisibleButton(u8'##�������� ������� � ���������'..POS_Y + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(101, POS_Y + y_pos_plus + 1))
						local p = imgui.GetCursorScreenPos()
						
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 498, p.y + 32), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(105, POS_Y + y_pos_plus + 5))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec4_ic), 5, 15)
					
					imgui.PushFont(fa_font[4])
					imgui.SetCursorPos(imgui.ImVec2(580, POS_Y + y_pos_plus + 9))
					imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
					imgui.SetCursorPos(imgui.ImVec2(105 + pos_icon[1], POS_Y + y_pos_plus + 9 + pos_icon[2]))
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), icon_circ)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(140, POS_Y + y_pos_plus + 8))
					imgui.Text(text_add_func)
					
					return return_bool
				end
				
				local num_a = #cmd.act + 1
				
				if cmd.add_f[1] and #cmd.act ~= 0 then
					num_a = cmd.add_f[2] + 1
				end
				
				if dr_circuit(50, fa.ICON_SHARE, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {0, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {0, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit(90, fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {1, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {1, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit(130, fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {2, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {2, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				if dr_circuit(170, fa.ICON_LIST_OL, imgui.ImVec4(0.88, 0.18, 0.20 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {3, cmd.num_d, 2, {u8'�������� 1', u8'�������� 2'}}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'�������� 1', u8'�������� 2'}})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
					cmd.num_d = cmd.num_d + 1
					cmd.tr_fl[2] = cmd.tr_fl[2] + 1
				end
				if dr_circuit(210, fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00)) then
					if not cmd.add_f[1] or #cmd.act == 0 then
						cmd.act[num_a] = {4, u8''}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {4, u8''})
						cmd.add_f[2] = cmd.add_f[2] + 1
					end
				end
				local res_pos = 250
				if #cmd.var ~= 0 then
					if dr_circuit(res_pos, fa.ICON_PENCIL, imgui.ImVec4(0.83, 0.13, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {5, '{var1}', u8''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {5, '{var1}', u8''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
					if dr_circuit(res_pos, fa.ICON_SUPERSCRIPT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {6, '{var1}', ''}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {6, '{var1}', ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
						cmd.tr_fl[1] = cmd.tr_fl[1] + 1
					end
					res_pos = res_pos + 40
				end
				
				if cmd.tr_fl[1] ~= 0 then
					if dr_circuit(res_pos, fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {7, '{var1}'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {7, ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
				end
				if cmd.tr_fl[2] ~= 0 then
					if dr_circuit(res_pos, fa.ICON_SIGN_OUT, imgui.ImVec4(1.00, 0.21, 0.41 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {8, '1', '1'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {8, '1', '1'})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
						cmd.tr_fl[3] = cmd.tr_fl[3] + 1
					end
					res_pos = res_pos + 40
				end
				if cmd.tr_fl[2] ~= 0 and cmd.tr_fl[3] ~= 0 then
					if dr_circuit(res_pos, fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00)) then
						if not cmd.add_f[1] or #cmd.act == 0 then
							cmd.act[num_a] = {9, '1', '1'}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {9, ''})
							cmd.add_f[2] = cmd.add_f[2] + 1
						end
					end
					res_pos = res_pos + 40
				end
				
				if not cmd.add_f[1] and #cmd.act >= 2 then
					skin.Button(u8'��������� � �����', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
					skin.Button(u8'��������� � �����##false_func', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
					res_pos = res_pos + 60
				elseif cmd.add_f[1] and #cmd.act >= 2 then 
					skin.Button(u8'��������� � �����##false_func', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
					skin.Button(u8'��������� � �����', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
					res_pos = res_pos + 60
				end
				
				skin.Button(u8'���������� ��������� ����', 100, POS_Y + res_pos + 30, 495, 35, function()
					imgui.OpenPopup(u8'�������� ��������� �����')
				end)
				
				if imgui.BeginPopupModal(u8'�������� ��������� �����', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##������� ������ �����', imgui.ImVec2(20, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(20, 20))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
						imgui.SetCursorPos(imgui.ImVec2(16, 13))
						imgui.PushFont(fa_font[2])
						imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
						imgui.PopFont()
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 35))
					imgui.BeginChild(u8'�������� �����', imgui.ImVec2(600, 400), false, imgui.WindowFlags.NoScrollbar)
					
					local function tag_hint_text(numb_str, tag_text, tag_description)
						local col_text_srt_t = '{000000}'
						if setting.int.theme ~= 'White' then col_text_srt_t = '{FFFFFF}' end
						imgui.PushFont(font[4])
						imgui.SetCursorPos(imgui.ImVec2(10, 5 + ((numb_str - 1) * 30)))
						
						imgui.TextColoredRGB('{EBA031}'..tag_text..' - '..col_text_srt_t..tag_description)
						local p = imgui.GetCursorScreenPos()
						imgui.SetCursorPos(imgui.ImVec2(10, 5 + ((numb_str - 1) * 30)))
						imgui.InvisibleButton(u8'##'..tag_text..numb_str, imgui.ImVec2(750, 30))
						
						if imgui.IsItemClicked() then
							local clipboard_text = u8(tag_text)
							imgui.SetClipboardText(clipboard_text)
							sampAddChatMessage(script_tag..'{FFFFFF}����� ���������� � ����� ������: {d121b7}'..tag_text, color_tag)
						end
						
						imgui.PopFont()
					end
					
					tag_hint_text(1, '{mynick}', '������� ��� ������� �� ����������')
					tag_hint_text(2, '{myid}', '������� ��� id')
					tag_hint_text(3, '{mynickrus}', '������� ��� ������� �� �������')
					tag_hint_text(4, '{myrank}', '������� ���� ���������')
					tag_hint_text(5, '{time}', '������� ������� �����')
					tag_hint_text(6, '{day}', '������� ������� ����')
					tag_hint_text(7, '{week}', '������� ������� ������')
					tag_hint_text(8, '{month}', '������� ������� �����')
					tag_hint_text(9, '{get_ru_nick[id ������]}', '������� ��� ������ �� ��� ID �� �������')
					tag_hint_text(10, '{getplnick[id ������]}', '������� ��� ������ �� ��� ID')
					tag_hint_text(11, '{copy_nick[id ������]}', '����������� Nick_Name ������')
					tag_hint_text(12, '{city}', '������ ����� � ������� ���������')
					tag_hint_text(13, '{area}', '������ ����� � ������� ���������')
					tag_hint_text(14, '{nearest}', '�������� id ���������� ������ � ������� 60 ������')
					tag_hint_text(15, '{med7}', '������� ���� �� ����� ���. ����� �� 7 ����')
					tag_hint_text(16, '{med14}', '������� ���� �� ����� ���. ����� �� 14 ����')
					tag_hint_text(17, '{med30}', '������� ���� �� ����� ���. ����� �� 30 ����')
					tag_hint_text(18, '{med60}', '������� ���� �� ����� ���. ����� �� 60 ����')
					tag_hint_text(19, '{medup7}', '������� ���� �� ���������� ���. ����� �� 7 ����')
					tag_hint_text(20, '{medup14}', '������� ���� �� ���������� ���. ����� �� 14 ����')
					tag_hint_text(21, '{medup30}', '������� ���� �� ���������� ���. ����� �� 30 ����')
					tag_hint_text(22, '{medup60}', '������� ���� �� ���������� ���. ����� �� 60 ����')
					tag_hint_text(23, '{pricenarko}', '������� ���� �� ������ �����������������')
					tag_hint_text(24, '{pricerecept}', '������� ���� �� ������')
					tag_hint_text(25, '{pricetatu}', '������� ���� �������� ���������� � ����')
					tag_hint_text(26, '{priceant }', '������� ���� �� ����������')
					tag_hint_text(27, '{pricelec }', '������� ���� �� �������')
					tag_hint_text(28, '{priceosm }', '������� ���� �� ���. ������')
					
					tag_hint_text(29, '{priceauto1}', '������� ���� �� ���� �� 1 �����')
					tag_hint_text(30, '{priceauto2}', '������� ���� �� ���� �� 2 ������')
					tag_hint_text(31, '{priceauto3}', '������� ���� �� ���� �� 3 ������')
					tag_hint_text(32, '{pricemoto1}', '������� ���� �� ���� �� 1 �����')
					tag_hint_text(33, '{pricemoto2}', '������� ���� �� ���� �� 2 ������')
					tag_hint_text(34, '{pricemoto3}', '������� ���� �� ���� �� 3 ������')
					tag_hint_text(35, '{pricefly}', '������� ���� �� �����')
					tag_hint_text(36, '{pricefish1}', '������� ���� �� ������� �� 1 �����')
					tag_hint_text(37, '{pricefish2}', '������� ���� �� ������� �� 2 ������')
					tag_hint_text(38, '{pricefish3}', '������� ���� �� ������� �� 3 ������')
					tag_hint_text(39, '{priceswim1}', '������� ���� �� ������ ��������� �� 1 �����')
					tag_hint_text(40, '{priceswim2}', '������� ���� �� ������ ��������� �� 2 ������')
					tag_hint_text(41, '{priceswim3}', '������� ���� �� ������ ��������� �� 3 ������')
					tag_hint_text(42, '{pricegun1}', '������� ���� �� ������ �� 1 �����')
					tag_hint_text(43, '{pricegun2}', '������� ���� �� ������ �� 2 ������')
					tag_hint_text(44, '{pricegun3}', '������� ���� �� ������ �� 3 ������')
					tag_hint_text(45, '{pricehunt1}', '������� ���� �� ����� �� 1 �����')
					tag_hint_text(46, '{pricehunt2}', '������� ���� �� ����� �� 2 ������')
					tag_hint_text(47, '{pricehunt3}', '������� ���� �� ����� �� 3 ������')
					tag_hint_text(48, '{priceexc1}', '������� ���� �� �������� �� 1 �����')
					tag_hint_text(49, '{priceexc2}', '������� ���� �� �������� �� 2 ������')
					tag_hint_text(50, '{priceexc3}', '������� ���� �� �������� �� 3 ������')
					tag_hint_text(51, '{pricetaxi1}', '������� ���� �� ����� �� 1 �����')
					tag_hint_text(52, '{pricetaxi2}', '������� ���� �� ����� �� 2 ������')
					tag_hint_text(53, '{pricetaxi3}', '������� ���� �� ����� �� 3 ������')
					tag_hint_text(54, '{pricemeh1}', '������� ���� �� �������� �� 1 �����')
					tag_hint_text(55, '{pricemeh2}', '������� ���� �� �������� �� 2 ������')
					tag_hint_text(56, '{pricemeh3}', '������� ���� �� �������� �� 3 ������')
					
					tag_hint_text(57, '{sex:���,���}', '������� ����� � ������������ � ��������� �����')
					tag_hint_text(58, '{dialoglic[id ��������][id �����][id ������]}', '��������� ������� � ���������')
					tag_hint_text(59, '{target}', '������� id � ���������� ������� �� ������')
					tag_hint_text(60, '{prtsc}', '������� �������� ���� F8')
					
					imgui.EndChild()
					
					imgui.EndPopup()
				end
				--[[
				0 - ��������� � ���
				1 - �������� ������� Enter
				2 - ������� ���� � ���
				3 - ������ ������ ��������
				4 - �����������
				5 - �������� ����������
				6 - ���� ���������� �����
				7 - ��������� ������� ����������
				8 - ���� ������ ������� �������
				9 - ��������� ������
				]]
				
				imgui.Dummy(imgui.ImVec2(0, 90))
				imgui.PopFont()
				imgui.EndChild()
				imgui.PopStyleVar(1)
			end
			
		----> [3] �����
		elseif select_main_menu[3] and select_shpora == 0 then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			menu_draw_up(u8'�����')
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(639, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##�������� ���������', imgui.ImVec2(195, 22)) then
				local comp = 1
				local num_el = {}
				if #setting.shpora ~= 0 then
					for _, element in ipairs(setting.shpora) do
						if string.match(element[1], '^shpora%d+$') then
							table.insert(num_el, tonumber(string.match(element[1], '^shpora(%d+)$')))
						end
					end
				end
				if num_el ~= 0 then
					table.sort(num_el)
					for i = 1, #num_el do
						if num_el[i] ~= comp then
							break
						else
							comp = comp + 1
						end
					end
				end
				table.insert(setting.shpora, {'shpora'..comp, ''})
				save('setting')
				shpora = {
					nm = 'shpora'..comp,
					text = ''
				}
				local f = io.open(dirml..'/StateHelper/���������/shpora'..comp..'.txt', 'w')
				f:write(u8:decode(shpora.text))
				f:flush()
				f:close()
				select_shpora = #setting.shpora
				anim_menu_shpora[1] = 0
				anim_menu_shpora[3] = false
				anim_menu_shpora[4] = 0
			end
			imgui.PopStyleVar(1)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
			imgui.SetCursorPos(imgui.ImVec2(649, 17))
			imgui.Text(fa.ICON_PLUS)
			imgui.PopFont()
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(672, 13))
			imgui.Text(u8'�������� ����� �����')
			imgui.PopStyleColor(1)
			imgui.PopFont()
			
			local speed = 710
			local target_value = anim_menu_shpora[3] and 180 or 0
			local currentTime = os.clock()
			local deltaTime = currentTime - anim_menu_shpora[2]
			anim_menu_shpora[2] = currentTime

			local target_value = anim_menu_shpora[3] and 180 or 0

			if anim_menu_shpora[1] < target_value then
				anim_menu_shpora[1] = math.min(anim_menu_shpora[1] + speed * deltaTime, target_value)
			elseif anim_menu_shpora[1] > target_value then
				anim_menu_shpora[1] = math.max(anim_menu_shpora[1] - speed * deltaTime, target_value)
			end
			
			if not anim_menu_shpora[3] then
				if anim_menu_shpora[1] == 0 then anim_menu_shpora[4] = 0 end
			end
		
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'���������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.shpora == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(137, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'��� �� ����� ���������')
				imgui.PopFont()
			else
				if anim_menu_shpora[1] == 0 then
					new_draw(17, -1 + (#setting.shpora * 68))
				else
					imgui.SetCursorPos(imgui.ImVec2(0, 17))
					local p = imgui.GetCursorScreenPos()
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.shpora * 68)), imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 30, 15)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + -1 + (#setting.shpora * 68) - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + -1 + (#setting.shpora * 68) - 28), 28, imgui.GetColorU32(imgui.ImVec4(0.70, 0.70, 0.70, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + -1 + (#setting.shpora * 68)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 30, 15)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + -1 + (#setting.shpora * 68) - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + -1 + (#setting.shpora * 68) - 28), 28, imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.00)), 60)
					end
				end
				imgui.PushFont(font[1])
				local remove_shpora
				for i = 1, #setting.shpora do
					imgui.SetCursorPos(imgui.ImVec2(0 - anim_menu_shpora[1], 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##������� � �������� ���������'..i, imgui.ImVec2(666, 68)) then
						anim_menu_shpora[2] = os.clock()
						anim_menu_shpora[3] = not anim_menu_shpora[3]
						if anim_menu_shpora[4] == 0 then
							anim_menu_shpora[4] = i
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemActive() and anim_menu_shpora[1] == 0 then
						if i == 1 and #setting.shpora ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 3)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 3) -- ������� ���� � ���
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						elseif i == 1 and #setting.shpora == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 15) -- ��������
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end 
						elseif i == #setting.shpora then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 12)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 12) -- ������ ��� � ����
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 0) -- �������
							end
						end
					end
					imgui.PushFont(fa_font[5])
					if anim_menu_shpora[4] ~= i and anim_menu_shpora[1] == 0 then
						imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
						imgui.Text(setting.shpora[i][1])
						imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
						if setting.shpora[i][2]:gsub('%s', '') == '' then
							imgui.Text(u8'��� ������')
						else
							imgui.Text(setting.shpora[i][2])
						end
						imgui.PopStyleColor(1)
					elseif anim_menu_shpora[4] ~= i and anim_menu_shpora[1] ~= 0 then
						imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(17, 31 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.20))
						imgui.Text(setting.shpora[i][1])
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(17, 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.10))
						if setting.shpora[i][2]:gsub('%s', '') == '' then
							imgui.Text(u8'��� ������')
						else
							imgui.Text(setting.shpora[i][2])
						end
						imgui.PopStyleColor(1)
					end
					
					if anim_menu_shpora[4] == i then
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.shpora ~= 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 18)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == 1 and #setting.shpora == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 22)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == #setting.shpora then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 20)
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 20) -- ������ ������� ������
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 0)
						end
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##������� �������', imgui.ImVec2(60, 68)) then
							remove_shpora = i
							anim_menu_shpora[3] = false
							anim_menu_shpora[1] = 0
							anim_menu_shpora[4] = 0
						end
						
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							if i == 1 and #setting.shpora ~= 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 18)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 60)
							elseif i == 1 and #setting.shpora == 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 22) 
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 60)
							elseif i == #setting.shpora then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 20)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 0)
							end
						end
						
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.57, 0.04, 1.00)))
						imgui.SetCursorPos(imgui.ImVec2(486, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.00, 0.65, 0.77, 1.00)))
							
						imgui.SetCursorPos(imgui.ImVec2(626, 38 + ( (i - 1) * 68)))
						imgui.PushFont(fa_font[5])
						imgui.Text(fa.ICON_TRASH)
						imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
						imgui.Text(fa.ICON_PENCIL)
						imgui.SetCursorPos(imgui.ImVec2(503.5, 36.5 + ( (i - 1) * 68)))
						imgui.Text(fa.ICON_EYE)
						imgui.PopFont()
						imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.shpora ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 1)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 30, 1)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
							end
						elseif i == 1 and #setting.shpora == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 9)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 30, 9)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
							end 
						elseif i == #setting.shpora then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 8)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 30, 8)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - anim_menu_shpora[1], p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 30, 0)
							end
						end
						
						imgui.SetCursorPos(imgui.ImVec2(640 - anim_menu_shpora[1], 37 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
						imgui.Text(fa.ICON_ANGLE_RIGHT)
						imgui.PopStyleColor(1)
						imgui.PopFont()
						
						imgui.SetCursorPos(imgui.ImVec2(17 - anim_menu_shpora[1], 31 + ( (i - 1) * 68)))
						imgui.Text(setting.shpora[i][1])
						imgui.SetCursorPos(imgui.ImVec2(17 - anim_menu_shpora[1], 51 + ( (i - 1) * 68)))
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
						if setting.shpora[i][2]:gsub('%s', '') == '' then
							imgui.Text(u8'��� ������')
						else
							imgui.Text(setting.shpora[i][2])
						end
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##������� �����', imgui.ImVec2(60, 68)) then
							anim_menu_shpora[3] = false
							anim_menu_shpora[1] = 0
							anim_menu_shpora[4] = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/���������/'..setting.shpora[i][1]..'.txt') then
								local f = io.open(dirml..'/StateHelper/���������/'..setting.shpora[i][1]..'.txt')
								shpora = {
									nm = setting.shpora[i][1],
									text = u8(f:read('*a'))
								}
								f:close()
								select_shpora = i
							else
								remove_shpora = i
							end
						end
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.47, 0.04, 1.00)))
							imgui.PushFont(fa_font[5])
							imgui.SetCursorPos(imgui.ImVec2(566, 38 + ( (i - 1) * 68)))
							imgui.Text(fa.ICON_PENCIL)
							imgui.PopFont()
						end
						
						imgui.SetCursorPos(imgui.ImVec2(486, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##���������� �����', imgui.ImVec2(60, 68)) then
							anim_menu_shpora[3] = false
							anim_menu_shpora[1] = 0
							anim_menu_shpora[4] = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/���������/'..setting.shpora[i][1]..'.txt') then
								local f = io.open(dirml..'/StateHelper/���������/'..setting.shpora[i][1]..'.txt')
								shpora = {
									nm = setting.shpora[i][1],
									text = u8(f:read('*a'))
								}
								f:close()
								select_shpora = i
							else
								remove_shpora = i
							end
							text_spur = shpora.text
							win.spur_big.v = true
						end
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(486, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.00, 0.55, 0.77, 1.00)))
							imgui.PushFont(fa_font[5])
							imgui.SetCursorPos(imgui.ImVec2(503.5, 36.5 + ( (i - 1) * 68)))
							imgui.Text(fa.ICON_EYE)
							imgui.PopFont()
						end
					end
				end
				if remove_shpora ~= nil then table.remove(setting.shpora, remove_shpora) save('setting') end
				if #setting.shpora > 1 then
					for draw = 1, #setting.shpora - 1 do
						if anim_menu_shpora[1] == 0 then
							skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
						else
							skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.20), 0, 0)
						end
					end
				end
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 80))
			imgui.EndChild()
		elseif select_main_menu[3] and select_shpora ~= 0 then
			local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
				if sizes_if_win == nil then
					sizes_if_win = {17, 666}
				end
				imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
				local p = imgui.GetCursorScreenPos()
				if comm_tr == nil then
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
						if par_dr_y ~= 48 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 25), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 24.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						end
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
						if par_dr_y ~= 48 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 29), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 24, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.76), 24, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						end
					end
				else
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 30, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 30, 15)
					end
				end
			end
			
			if menu_draw_up(u8'�������������� ���������', true) then
				imgui.OpenPopup(u8'���������� �������� � ����������')
				shpora_err_nm = false
			end
			imgui.PushFont(font[1])
			skin.Button(u8'������� ��� ���������', 656, 9, 180, 26, function() 
				text_spur = shpora.text
				win.spur_big.v = true
			end)
			imgui.PopFont()
			if imgui.BeginPopupModal(u8'���������� �������� � ����������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'�������� � ����������', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##������� ������ ���������', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(6, 3))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				
				imgui.PushFont(bold_font[4])
				if not shpora_err_nm then
					imgui.SetCursorPos(imgui.ImVec2(35, 55))
					imgui.Text(u8'�������� ��������')
				else
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'������')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(86, 95))
					imgui.Text(u8'����� ��� ��� ����������')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'���������', 10, 167, 123, 25, function()
					for i = 1, #setting.shpora do
						if setting.shpora[i][1] == shpora.nm and i ~= select_shpora then
							shpora_err_nm = true
							break
						end
					end
					if not shpora_err_nm  then
						if doesFileExist(dirml..'/StateHelper/���������/'..setting.shpora[select_shpora][1]..'.txt') then
							os.remove(dirml..'/StateHelper/���������/'..setting.shpora[select_shpora][1]..'.txt')
						end
						shpora.nm = shpora.nm:gsub('[<>:\"/\\|%*%?%c]', '')
						if shpora.nm == '' then shpora.nm = u8'��� �����' end
						local f = io.open(dirml..'/StateHelper/���������/'..shpora.nm..'.txt', 'w')
						f:write(u8:decode(shpora.text))
						f:flush()
						f:close()
						local textes = ''
						local buf_text_shpora = imgui.ImBuffer(75)
						buf_text_shpora.v = u8:decode(shpora.text)
						buf_text_shpora.v = string.gsub(buf_text_shpora.v, '\n.+', '')
						textes = u8(buf_text_shpora.v)
						if shpora.text ~= '' and buf_text_shpora.v == '' then textes = u8'������ ������' end
						if textes ~= shpora.text and textes ~= u8'������ ������' then textes = textes..' ...' end
						setting.shpora[select_shpora] = {shpora.nm, textes}
						save('setting')
						select_shpora = 0
						imgui.CloseCurrentPopup()
					end
				end)
				skin.Button(u8'�� ���������', 138, 167, 124, 25, function()
					select_shpora = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'�������', 267, 167, 123, 25, function()
					if doesFileExist(dirml..'/StateHelper/���������/'..setting.shpora[select_shpora][1]..'.txt') then
						os.remove(dirml..'/StateHelper/���������/'..setting.shpora[select_shpora][1]..'.txt')
					end
					table.remove(setting.shpora, select_shpora)
					save('setting')
					select_shpora = 0
					imgui.CloseCurrentPopup()
				end)
				imgui.PopFont()
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			if select_shpora ~= 0 then
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'�������������� �����', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				imgui.PushFont(font[1])
				new_draw(17, 48)
				imgui.SetCursorPos(imgui.ImVec2(35, 32))
				imgui.Text(u8'��� �����')
				skin.InputText(125, 30, u8'������� ��� ���������', 'shpora.nm', 95, 539, nil)
				new_draw(77, 328)
				imgui.SetCursorPos(imgui.ImVec2(25, 87))
				local text_multiline = imgui.ImBuffer(512000)
				text_multiline.v = shpora.text
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
				imgui.InputTextMultiline('##���� ����� ������ �����', text_multiline, imgui.ImVec2(649, 318))
				imgui.PopStyleColor()
				if text_multiline.v == '' and not imgui.IsItemActive() then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					imgui.SetCursorPos(imgui.ImVec2(29, 88))
					imgui.Text(u8'������� ����� ����� ���������')
					imgui.PopStyleColor()
				end
				shpora.text = text_multiline.v
				imgui.PopFont()
				
				imgui.EndChild()
			end
			
		----> [4] �����������
		elseif select_main_menu[4] then
			menu_draw_up(u8'�����������')
			dep_win()
		
		----> [5] �������������
		elseif select_main_menu[5] then
			menu_draw_up(u8'���� �������������')
			win_sobes_fix()
			
		----> [6] �����������
		elseif select_main_menu[6] then
			menu_draw_up(u8'�����������')
			reminder_win_fix()
			
		----> [7] ����������
		elseif select_main_menu[7] then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
				
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
				
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				end
			end
			local function point_sum(n)
				local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
				return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
			end
			local function earnings_text(e_text_st, e_text_sum, e_p_x, e_p_y)
				local tr_ff = false
				imgui.PushFont(font[1])
				if e_text_sum ~= 0 then
					imgui.SetCursorPos(imgui.ImVec2(e_p_x,e_p_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}'.. e_text_st ..' {279643}'.. point_sum(e_text_sum) ..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}'.. e_text_st ..' {36CF5C}'.. point_sum(e_text_sum) ..'$')
					end
					tr_ff = true
				end
				imgui.PopFont()
				
				return tr_ff
			end
			local function draw_button(pos_draw, text_for_draw, num_select)
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)))
				end
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				if select_stat ~= num_select then
					if imgui.InvisibleButton(u8'##������� ������� ����������'..pos_draw[1], imgui.ImVec2(234, 25)) then select_stat = num_select end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
						end
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00)))
						end
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 234, p.y + 25), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
				end
				imgui.PushFont(font[1])
				local calc = imgui.CalcTextSize(text_for_draw)
				calc = 117 - (calc.x / 2)
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + calc, 43))
				if setting.int.theme == 'White' and num_select == select_stat then
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), text_for_draw)
				else
					imgui.Text(text_for_draw)
				end
				imgui.PopFont()
			end
			menu_draw_up(u8'����������')
			
			draw_button({162, 40}, u8'�������', 0)
			draw_button({396, 40}, u8'������', 1)
			draw_button({630, 40}, u8'��������� �����������', 2)
			
			imgui.SetCursorPos(imgui.ImVec2(180, 65))
			if select_stat == 0 then
				imgui.BeginChild(u8'���������� �������', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				if setting.frac.org:find(u8'��������') then
					local non_stat = false
					local pos_y = 0
					local psl_y = 0
					
					for i = 1, 7 do
						if setting.stat.hosp.date_week[i] ~= '' then
							local money_true = 0
							non_stat = true
							if setting.stat.hosp.payday[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.lec[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.medcard[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.apt[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.ant[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.rec[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.medcam[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.tatu[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.hosp.cure[i] ~= 0 then money_true = money_true + 1 end
							if setting.new_stat_bl.osm[i] ~= 0 then money_true = money_true + 1 end
							if setting.new_stat_bl.ticket[i] ~= 0 then money_true = money_true + 1 end
							if setting.new_stat_bl.awards[i] ~= 0 then money_true = money_true + 1 end
							
							local pp_y = 0
							if money_true ~= 0 then
								local total_day = 0
								new_draw(17 + pos_y, (91 + (money_true * 23)))
								imgui.PushFont(bold_font[3])
								imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
								imgui.Text(setting.stat.hosp.date_week[i])
								local calc = imgui.CalcTextSize(setting.stat.hosp.date_week[i])
								imgui.PopFont()
								skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
								if earnings_text('��������:', setting.stat.hosp.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.payday[i] end
								if earnings_text('�������:', setting.stat.hosp.lec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.lec[i] end
								if earnings_text('���������� ���.����:', setting.stat.hosp.medcard[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcard[i] end
								if earnings_text('������ �����������������:', setting.stat.hosp.apt[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.apt[i] end
								if earnings_text('������� ������������:', setting.stat.hosp.ant[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.ant[i] end
								if earnings_text('������� ��������:', setting.stat.hosp.rec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.rec[i] end
								if earnings_text('��������� ������������:', setting.stat.hosp.medcam[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcam[i] end
								if earnings_text('�� ������:', setting.stat.hosp.cure[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.cure[i] end
								if earnings_text('�������� ����������:', setting.stat.hosp.tatu[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.tatu[i] end
								if earnings_text('���. ������:', setting.new_stat_bl.osm[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.osm[i] end
								if earnings_text('������ �����������:', setting.new_stat_bl.ticket[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.ticket[i] end
								if earnings_text('������ �� ������:', setting.new_stat_bl.awards[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.awards[i] end
								
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
								if setting.int.theme == 'White' then
									imgui.TextColoredRGB('{000000}����� �� ����: {279643}'..point_sum(total_day)..'$')
								else
									imgui.TextColoredRGB('{FFFFFF}����� �� ����: {36CF5C}'..point_sum(total_day)..'$')
								end
								imgui.PopFont()
								pos_y = pos_y + 91 + (money_true * 23) + 12
							else
								new_draw(17 + pos_y, 84)
								imgui.PushFont(bold_font[3])
								imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
								imgui.Text(setting.stat.hosp.date_week[i])
								local calc = imgui.CalcTextSize(setting.stat.hosp.date_week[i])
								imgui.PopFont()
								skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 69 + pos_y))
								imgui.Text(u8'� ���� ���� �� ������ �� ����������')
								imgui.PopFont()
								pos_y = pos_y + 96
							end
						end
					end
					new_draw(17 + pos_y, 63)
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
					setting.stat.hosp.total_week = 0
					for i = 1, 7 do
						setting.stat.hosp.total_week = setting.stat.hosp.total_week + setting.stat.hosp.payday[i] + setting.stat.hosp.lec[i] + setting.stat.hosp.medcard[i] + setting.stat.hosp.apt[i] + setting.stat.hosp.ant[i] + setting.stat.hosp.rec[i] + setting.stat.hosp.medcam[i] + setting.stat.hosp.tatu[i] + setting.stat.hosp.cure[i] + setting.new_stat_bl.osm[i] + setting.new_stat_bl.ticket[i] + setting.new_stat_bl.awards[i]
					end
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}����� �� ������: {279643}'..point_sum(setting.stat.hosp.total_week)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}����� �� ������: {36CF5C}'..point_sum(setting.stat.hosp.total_week)..'$')
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}����� �� �� �����: {279643}'..point_sum(setting.stat.hosp.total_all)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}����� �� �� �����: {36CF5C}'..point_sum(setting.stat.hosp.total_all)..'$')
					end
					imgui.PopFont()
					skin.Button(u8'�������� ����������', 270, 98 + pos_y, 145, 30, function()
						if setting.frac.org:find(u8'��������') then
							setting.stat.hosp = {
								payday = {0, 0, 0, 0, 0, 0, 0},
								lec = {0, 0, 0, 0, 0, 0, 0},
								medcard = {0, 0, 0, 0, 0, 0, 0},
								apt = {0, 0, 0, 0, 0, 0, 0},
								vac = {0, 0, 0, 0, 0, 0, 0},
								ant = {0, 0, 0, 0, 0, 0, 0},
								rec = {0, 0, 0, 0, 0, 0, 0},
								medcam = {0, 0, 0, 0, 0, 0, 0},
								cure = {0, 0, 0, 0, 0, 0, 0},
								tatu = {0, 0, 0, 0, 0, 0, 0},
								total_week = 0,
								total_all = 0,
								date_num = {0, 0},
								date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
								date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
								date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
							}
							setting.new_stat_bl = {
								osm = {0, 0, 0, 0, 0, 0, 0},
								ticket = {0, 0, 0, 0, 0, 0, 0},
								awards = {0, 0, 0, 0, 0, 0, 0}
							}
						end
						save('setting')
					end)
					imgui.Dummy(imgui.ImVec2(0, 18))
					
				--[[elseif setting.frac.org:find(u8'����� ��������������') then
					local non_stat = false
					local pos_y = 0
					local psl_y = 0
					
					for i = 1, 7 do
						if setting.stat.school.date_week[i] ~= '' then
							local money_true = 0
							non_stat = true
							if setting.stat.school.payday[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.auto[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.moto[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.fish[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.swim[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.gun[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.hun[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.exc[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.taxi[i] ~= 0 then money_true = money_true + 1 end
							if setting.stat.school.meh[i] ~= 0 then money_true = money_true + 1 end
							
							local pp_y = 0
							if money_true ~= 0 then
								local total_day = 0
								new_draw(17 + pos_y, (91 + (money_true * 23)))
								imgui.PushFont(font[4])
								imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
								imgui.Text(setting.stat.school.date_week[i])
								local calc = imgui.CalcTextSize(setting.stat.school.date_week[i])
								imgui.PopFont()
								skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
								if earnings_text('��������:', setting.stat.school.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.payday[i] end
								if earnings_text('����:', setting.stat.school.auto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.auto[i] end
								if earnings_text('����:', setting.stat.school.moto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.moto[i] end
								if earnings_text('�������:', setting.stat.school.fish[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.fish[i] end
								if earnings_text('��������:', setting.stat.school.swim[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.swim[i] end
								if earnings_text('������:', setting.stat.school.gun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.gun[i] end
								if earnings_text('�����:', setting.stat.school.hun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.hun[i] end
								if earnings_text('��������:', setting.stat.school.exc[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.exc[i] end
								if earnings_text('�����:', setting.stat.school.taxi[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.taxi[i] end
								if earnings_text('��������:', setting.stat.school.meh[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.meh[i] end
								
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
								if setting.int.theme == 'White' then
									imgui.TextColoredRGB('{000000}����� �� ����: {279643}'..point_sum(total_day)..'$')
								else
									imgui.TextColoredRGB('{FFFFFF}����� �� ����: {36CF5C}'..point_sum(total_day)..'$')
								end
								imgui.PopFont()
								pos_y = pos_y + 91 + (money_true * 23) + 12
							else
								new_draw(17 + pos_y, 84)
								imgui.PushFont(font[4])
								imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
								imgui.Text(setting.stat.school.date_week[i])
								local calc = imgui.CalcTextSize(setting.stat.school.date_week[i])
								imgui.PopFont()
								skin.DrawFond({17, 55 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 69 + pos_y))
								imgui.Text(u8'� ���� ���� �� ������ �� ����������')
								imgui.PopFont()
								pos_y = pos_y + 96
							end
						end
					end
					new_draw(17 + pos_y, 63)
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
					setting.stat.school.total_week = 0
					for i = 1, 7 do
						setting.stat.school.total_week = setting.stat.school.payday[i] + setting.stat.school.auto[i] + setting.stat.school.moto[i] + 
						setting.stat.school.fish[i] + setting.stat.school.swim[i] + setting.stat.school.gun[i] + setting.stat.school.exc[i] + 
						setting.stat.school.taxi[i] + setting.stat.school.meh[i] + setting.stat.school.hun[i] + setting.stat.school.total_week
					end
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}����� �� ������: {279643}'..point_sum(setting.stat.school.total_week)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}����� �� ������: {36CF5C}'..point_sum(setting.stat.school.total_week)..'$')
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}����� �� �� �����: {279643}'..point_sum(setting.stat.school.total_all)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}����� �� �� �����: {36CF5C}'..point_sum(setting.stat.school.total_all)..'$')
					end
					imgui.PopFont()
					skin.Button(u8'�������� ����������', 270, 98 + pos_y, 145, 30, function()
						if setting.frac.org:find(u8'����� ��������������') then
							setting.stat.school = {
								payday = {0, 0, 0, 0, 0, 0, 0},
								auto = {0, 0, 0, 0, 0, 0, 0},
								moto = {0, 0, 0, 0, 0, 0, 0},
								fish = {0, 0, 0, 0, 0, 0, 0},
								swim = {0, 0, 0, 0, 0, 0, 0},
								gun = {0, 0, 0, 0, 0, 0, 0},
								hun = {0, 0, 0, 0, 0, 0, 0},
								exc = {0, 0, 0, 0, 0, 0, 0},
								taxi = {0, 0, 0, 0, 0, 0, 0},
								meh = {0, 0, 0, 0, 0, 0, 0},
								total_week = 0,
								total_all = 0,
								date_num = {0, 0},
								date_today = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
								date_last = {tonumber(os.date('%d')), tonumber(os.date('%m')), tonumber(os.date('%Y'))},
								date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
							}
						end
						save('setting')
					end)
					imgui.Dummy(imgui.ImVec2(0, 18))]]
				else
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(121, 176 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'��� ��� ���� ����������')
					imgui.PopFont()
				end
				
				imgui.EndChild()
			elseif select_stat == 1 then
				imgui.BeginChild(u8'���������� �������', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				local pos_y = 17
				
				for i = 1, 7 do
					imgui.PushFont(font[1])
					if setting.online_stat.date_week[i] ~= '' then
						if i == 1 then
							new_draw(pos_y, 202)
						else
							new_draw(pos_y, 127)
						end
						imgui.PushFont(bold_font[3])
						imgui.SetCursorPos(imgui.ImVec2(17, 12 + pos_y))
						imgui.Text(setting.online_stat.date_week[i])
						local calc = imgui.CalcTextSize(setting.online_stat.date_week[i])
						imgui.PopFont()
						skin.DrawFond({17, 38 + pos_y}, {0, 0}, {calc.x, 4}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
						
						imgui.SetCursorPos(imgui.ImVec2(17, 52 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}������ ������ �� ����: {279643}'.. print_time(setting.online_stat.clean[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}������ ������ �� ����: {36CF5C}'.. print_time(setting.online_stat.clean[i]))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 75 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}��� �� ����: {279643}'.. print_time(setting.online_stat.afk[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}��� �� ����: {36CF5C}'.. print_time(setting.online_stat.afk[i]))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 98 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}����� �� ����: {279643}'.. print_time(setting.online_stat.all[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}����� �� ����: {36CF5C}'.. print_time(setting.online_stat.all[i]))
						end
						
						pos_y = pos_y + 144
						
						if i == 1 then
							imgui.SetCursorPos(imgui.ImVec2(17, -17 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}������ �� ������: {279643}'.. print_time(session_clean.v))
							else
								imgui.TextColoredRGB('{FFFFFF}������ �� ������: {36CF5C}'.. print_time(session_clean.v))
							end
							imgui.SetCursorPos(imgui.ImVec2(17, 6 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}��� �� ������: {279643}'.. print_time(session_afk.v))
							else
								imgui.TextColoredRGB('{FFFFFF}��� �� ������: {36CF5C}'.. print_time(session_afk.v))
							end
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}����� �� ������: {279643}'.. print_time(session_all.v))
							else
								imgui.TextColoredRGB('{FFFFFF}����� �� ������: {36CF5C}'.. print_time(session_all.v))
							end
							pos_y = pos_y + 75
						end
					end
					
					imgui.PopFont()
				end
					
				imgui.PushFont(font[1])
				new_draw(pos_y, 64)
				setting.online_stat.total_week = setting.online_stat.clean[1] + setting.online_stat.clean[2] + setting.online_stat.clean[3] + 
				setting.online_stat.clean[4] + setting.online_stat.clean[5] + setting.online_stat.clean[6] + setting.online_stat.clean[7]
				imgui.SetCursorPos(imgui.ImVec2(17, 11 + pos_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}������ ������ �� ������: {279643}'.. print_time(setting.online_stat.total_week))
				else
					imgui.TextColoredRGB('{FFFFFF}������ ������ �� ������: {36CF5C}'.. print_time(setting.online_stat.total_week))
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 34 + pos_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}������ ������ �� �� �����: {279643}'.. print_time(setting.online_stat.total_all))
				else
					imgui.TextColoredRGB('{FFFFFF}������ ������ �� �� �����: {36CF5C}'.. print_time(setting.online_stat.total_all))
				end
				imgui.PopFont()
				pos_y = pos_y + 81
				
				skin.Button(u8'�������� ����������##�������', 270, pos_y, 145, 30, function()
					setting.online_stat = {
						clean = {0, 0, 0, 0, 0, 0, 0},
						afk = {0, 0, 0, 0, 0, 0, 0},
						all = {0, 0, 0, 0, 0, 0, 0},
						total_week = 0,
						total_all = 0,
						date_num = {0, 0},
						date_today = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
						date_last = {os.date('%d') + 0, os.date('%m') + 0, os.date('%Y') + 0},
						date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''}
					}
					save('setting')
				end)
				imgui.Dummy(imgui.ImVec2(0, 18))
				
				imgui.EndChild()
			elseif select_stat == 2 then
				imgui.BeginChild(u8'��������� �����������', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
				end
			end
				
				imgui.PushFont(bold_font[3])
				imgui.SetCursorPos(imgui.ImVec2(132, 17))
				imgui.Text(u8'��������� ����������� ���������� �������')
				imgui.PopFont()
				
				new_draw(46, 68)
				
				imgui.SetCursorPos(imgui.ImVec2(624, 59))
				if skin.Switch(u8'##���������� ������� �� ������', setting.stat_online_display) then
					setting.stat_online_display = not setting.stat_online_display
					save('setting')
					if setting.stat_online_display then
						win.stat_online.v = true
						ch_pos_on_stat()
					else
						win.stat_online.v = false
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(17, 60))
				imgui.Text(u8'���������� ������� �� ������')
				
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(17, 82))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���������� ������� ����� ������ ������������ �� ����� ������.')
				imgui.PopFont()
				
				if setting.stat_online_display then --stat_online_display_hiding
					new_draw(129, 68)
					
					imgui.SetCursorPos(imgui.ImVec2(624, 142))
					if skin.Switch(u8'##�������� ��� �������', setting.stat_online_display_hiding) then
						setting.stat_online_display_hiding = not setting.stat_online_display_hiding
						save('setting')
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(17, 143))
					imgui.Text(u8'�������� ��� ��������')
					
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(17, 165))
					imgui.PushFont(font[3])
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'�� ����� ��������� �������, ��������� ��� TAB - ���������� ����� ����������.')
					imgui.PopFont()
				
					new_draw(211, 258)
					imgui.PushFont(font[1])
					
					imgui.SetCursorPos(imgui.ImVec2(17, 225))
					imgui.Text(u8'���������� ������� �����')
					imgui.SetCursorPos(imgui.ImVec2(17, 255))
					imgui.Text(u8'���������� ������� ����')
					imgui.SetCursorPos(imgui.ImVec2(17, 285))
					imgui.Text(u8'���������� ������ ������ �� ����')
					imgui.SetCursorPos(imgui.ImVec2(17, 315))
					imgui.Text(u8'���������� ��� �� ����')
					imgui.SetCursorPos(imgui.ImVec2(17, 345))
					imgui.Text(u8'���������� ����� �� ����')
					imgui.SetCursorPos(imgui.ImVec2(17, 375))
					imgui.Text(u8'���������� ������ �� ������')
					imgui.SetCursorPos(imgui.ImVec2(17, 405))
					imgui.Text(u8'���������� ��� �� ������')
					imgui.SetCursorPos(imgui.ImVec2(17, 435))
					imgui.Text(u8'���������� ����� �� ������')
					
					imgui.SetCursorPos(imgui.ImVec2(624, 224))
					if skin.Switch(u8'##������� �����', setting.stat_on_members.time) then
						setting.stat_on_members.time = not setting.stat_on_members.time
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 254))
					if skin.Switch(u8'##������� ����', setting.stat_on_members.date) then
						setting.stat_on_members.date = not setting.stat_on_members.date
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 284))
					if skin.Switch(u8'##������ �� ����', setting.stat_on_members.clean_on_day) then
						setting.stat_on_members.clean_on_day = not setting.stat_on_members.clean_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 314))
					if skin.Switch(u8'##��� �� ����', setting.stat_on_members.afk_on_day) then
						setting.stat_on_members.afk_on_day = not setting.stat_on_members.afk_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 344))
					if skin.Switch(u8'##����� �� ����', setting.stat_on_members.all_on_day) then
						setting.stat_on_members.all_on_day = not setting.stat_on_members.all_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 374))
					if skin.Switch(u8'##������ �� ������', setting.stat_on_members.clean_on_session) then
						setting.stat_on_members.clean_on_session = not setting.stat_on_members.clean_on_session
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 404))
					if skin.Switch(u8'##��� �� ������', setting.stat_on_members.afk_on_session) then
						setting.stat_on_members.afk_on_session = not setting.stat_on_members.afk_on_session
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 434))
					if skin.Switch(u8'##����� �� ������', setting.stat_on_members.all_on_session) then
						setting.stat_on_members.all_on_session = not setting.stat_on_members.all_on_session
						save('setting')
					end
					
					new_draw(483, 60)
					skin.Button(u8'�������� ��������� ����', 17, 498, 636, 30, function() ch_pos_on_stat() end)
					--imgui.Dummy(imgui.ImVec2(0, 15))
					
					imgui.PopFont()
					
				end
				imgui.Dummy(imgui.ImVec2(0, 35))
				imgui.EndChild()
			end
			
		----> [8] ������
		elseif select_main_menu[8] then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 8, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00)), 8, 15)
				end
			end
			local function draw_button(pos_draw, text_for_draw, num_select)
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)))
				end
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				if select_music ~= num_select then
					if imgui.InvisibleButton(u8'##������� ������� ������'..pos_draw[1], imgui.ImVec2(175.5, 25)) then select_music = num_select end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.01, col_end.fond_two[2] + 0.01, col_end.fond_two[3] + 0.01, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00)))
						end
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)))
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.08, col_end.fond_two[2] + 0.08, col_end.fond_two[3] + 0.08, 1.00)))
						end
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 175.5, p.y + 25), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
				end
				imgui.PushFont(font[1])
				local calc = imgui.CalcTextSize(text_for_draw)
				calc = 87.75 - (calc.x / 2)
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + calc, 43))
				if setting.int.theme == 'White' and num_select == select_music then
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), text_for_draw)
				else
					imgui.Text(text_for_draw)
				end
				imgui.PopFont()
			end
			menu_draw_up(u8'������')
			
			draw_button({162, 40}, u8'����� � ���������', 1)
			draw_button({337.5, 40}, u8'���������', 2)
			draw_button({513, 40}, u8'����� Record', 3)
			draw_button({688.5, 40}, u8'������ �����', 4)
			
			if setting.int.theme == 'White' then
				skin.DrawFond({162, 406 + start_pos + new_pos}, {0, 0}, {702, 58}, imgui.ImVec4(col_end.fond_two[1] + 0.03, col_end.fond_two[2] + 0.03, col_end.fond_two[3] + 0.03, 1.00), 15, 20)
			else
				skin.DrawFond({162, 406 + start_pos + new_pos}, {0, 0}, {702, 58}, imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00), 15, 20)
			end
			skin.DrawFond({162, 405 + start_pos + new_pos}, {-0.5, 0}, {702, 0.6}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
			
			imgui.PushFont(fa_font[1])
			if status_track_pl == 'STOP' then
				imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_BACKWARD)
				imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_FORWARD)
				imgui.PushFont(fa_font[6])
				imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_PLAY_CIRCLE_O)
				imgui.PopFont()
			else
				if menu_play_track[1] or menu_play_track[2] then
					imgui.SetCursorPos(imgui.ImVec2(176, 427 + start_pos + new_pos))
					if imgui.InvisibleButton(u8'##����������� �����', imgui.ImVec2(18, 17)) then back_track() end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_BACKWARD)
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_BACKWARD)
					else
						imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
						imgui.Text(fa.ICON_BACKWARD)
					end
					
					imgui.SetCursorPos(imgui.ImVec2(243, 427 + start_pos + new_pos))
					if imgui.InvisibleButton(u8'##����������� �����', imgui.ImVec2(18, 17)) then next_track() end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_FORWARD)
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_FORWARD)
					else
						imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
						imgui.Text(fa.ICON_FORWARD)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(176, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_BACKWARD)
					imgui.SetCursorPos(imgui.ImVec2(245, 429 + start_pos + new_pos))
					imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,0.40), fa.ICON_FORWARD)
				end
				
				imgui.PushFont(fa_font[6])
				if status_track_pl == 'PLAY' then
					imgui.SetCursorPos(imgui.ImVec2(206, 420 + start_pos + new_pos))
					if imgui.InvisibleButton(u8'##�����', imgui.ImVec2(27, 27)) then action_song('PAUSE') end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PAUSE_CIRCLE_O)
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PAUSE_CIRCLE_O)
					else
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.Text(fa.ICON_PAUSE_CIRCLE_O)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(206, 420 + start_pos + new_pos))
					if imgui.InvisibleButton(u8'##�����������', imgui.ImVec2(27, 27)) then action_song('PLAY') end
					if imgui.IsItemActive() then
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLAY_CIRCLE_O)
					elseif imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PLAY_CIRCLE_O)
					else
						imgui.SetCursorPos(imgui.ImVec2(204, 416 + start_pos + new_pos))
						imgui.Text(fa.ICON_PLAY_CIRCLE_O)
					end
				end
				imgui.PopFont()
			end
			imgui.PopFont()
			local function thetime()
				if timetr[1] < 10 then
					trt = '0'..timetr[1]
				else
					trt = timetr[1]
				end
				if timetr[2] < 10 then
					trt2 = '0'..timetr[2]
				else
					trt2 = timetr[2]
				end
				return trt2..':'..trt
			end
			imgui.SetCursorPos(imgui.ImVec2(276, 412 + start_pos + new_pos))
			if selectis == status_image then
				imgui.Image(IMG_label, imgui.ImVec2(45, 44))
			elseif select_record == 0 and select_radio == 0 then
				imgui.Image(IMG_No_Label, imgui.ImVec2(45, 44))
			elseif select_record ~= 0 then
				imgui.Image(IMG_Record[select_record], imgui.ImVec2(45, 44))
			elseif select_radio ~= 0 then
				imgui.Image(IMG_Radio[select_radio], imgui.ImVec2(45, 44))
			end
			imgui.SetCursorPos(imgui.ImVec2(276, 412 + start_pos + new_pos))
			if setting.int.theme == 'White' then
				imgui.Image(IMG_Background_White, imgui.ImVec2(45, 44))
			else
				imgui.Image(IMG_Background, imgui.ImVec2(45, 44))
			end
			imgui.PushFont(font[1])
			if status_track_pl == 'STOP' then
				imgui.SetCursorPos(imgui.ImVec2(336, 420 + start_pos + new_pos))
				imgui.Text(u8'������ �� ���������������')
			else
				local artist_buf = imgui.ImBuffer(58)
				local name_buf = imgui.ImBuffer(58)
				local artist_end = artist
				local name_end = name_tr
				artist_buf.v = artist
				name_buf.v = name_tr
				if artist_buf.v ~= artist then artist_end = artist_buf.v..'...' end
				if name_buf.v ~= name_tr then name_end = name_buf.v..'...' end
				imgui.SetCursorPos(imgui.ImVec2(336, 411 + start_pos + new_pos))
				imgui.Text(u8(artist_end))
				imgui.SetCursorPos(imgui.ImVec2(336, 429 + start_pos + new_pos))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.70), u8(name_end))
				if select_record == 0 and select_radio == 0 then
					local calc = imgui.CalcTextSize(thetime())
					imgui.SetCursorPos(imgui.ImVec2(736 - calc.x, 433 + start_pos + new_pos))
					imgui.Text(thetime())
				end
			end
			
			imgui.PopFont()
			
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
			
			imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
			if status_track_pl ~= 'STOP' then
				if menu_play_track[1] or menu_play_track[2] then
					local size_X_line = (timetr[2] * 60 + timetr[1]) * timetri
					if size_X_line > 400 then
						size_X_line = 400
					end
					imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size_X_line, p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
				
					imgui.SetCursorPos(imgui.ImVec2(325, 445 + start_pos + new_pos))
					imgui.PushItemWidth(419)
					if imgui.SliderFloat(u8'##���������', sectime_track, 0, track_time_hc - 2, u8'') then rewind_song(sectime_track.v) end
					if imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(336 + size_X_line, 454 + start_pos + new_pos))
						local p = imgui.GetCursorScreenPos()
						if setting.int.theme == 'White' then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)), 60)
						else
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
						end
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(336, 453 + start_pos + new_pos))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)))
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(751, 453 + start_pos + new_pos))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 97, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
			imgui.SetCursorPos(imgui.ImVec2(751, 453 + start_pos + new_pos))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (volume_buf.v * 50), p.y + 3), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00)))
			imgui.SetCursorPos(imgui.ImVec2(740, 445 + start_pos + new_pos))
			imgui.PushItemWidth(119)
			if imgui.SliderFloat(u8'##���������', volume_buf, 0, 2, u8'') then 
				setting.mus.volume = volume_buf.v 
				save('setting')
				volume_song(setting.mus.volume)
			end
			volume_buf.v = setting.mus.volume
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(751 + (volume_buf.v * 48), 454 + start_pos + new_pos))
			local p = imgui.GetCursorScreenPos()
			if setting.int.theme == 'White' then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 6, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
			end
			
			imgui.PushFont(fa_font[4])
			imgui.SetCursorPos(imgui.ImVec2(748, 419 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##����������', imgui.ImVec2(20, 20)) then setting.mus.rep = not setting.mus.rep save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(751, 421 + start_pos + new_pos))
			if setting.mus.rep and not imgui.IsItemActive() then
				imgui.Text(fa.ICON_REPEAT)
			elseif not imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_REPEAT)
			elseif imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_REPEAT)
			end
			imgui.SetCursorPos(imgui.ImVec2(789, 419 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##���� ������', imgui.ImVec2(20, 20)) then setting.mus.win = not setting.mus.win save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(792, 421 + start_pos + new_pos))
			if setting.mus.win and not imgui.IsItemActive() then
				imgui.Text(fa.ICON_WINDOW_MAXIMIZE)
			elseif not imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_WINDOW_MAXIMIZE)
			elseif imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_WINDOW_MAXIMIZE)
			end
			imgui.SetCursorPos(imgui.ImVec2(832, 419 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##���������� ������', imgui.ImVec2(20, 20)) then
				action_song('STOP')
				sel_link = ''
			end
			imgui.SetCursorPos(imgui.ImVec2(835, 421 + start_pos + new_pos))
			if not imgui.IsItemActive() then
				imgui.Text(fa.ICON_STOP)
			else
				imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_STOP)
			end
			imgui.PopFont()
			
			if select_music == 1 then
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(162, 65))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 702, p.y + 36), imgui.GetColorU32(imgui.ImVec4(0.78, 0.78, 0.78, 1.00)))
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 702, p.y + 36), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30, 1.00)))
				end
				
				if skin.InputText(193, 72, u8'������� �������� ����� ��� ��� �����������', 'text_find_track', 100, 591, nil, nil, 'enterflag') then
					if text_find_track ~= '' then
						qua_page = 1
						sel_link = ''
						find_track_link(text_find_track, 1)
					end
				end
				imgui.PushFont(fa_font[4])
				imgui.SetCursorPos(imgui.ImVec2(176, 73))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), fa.ICON_SEARCH)
				imgui.PopFont()
				
				imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 0)
				skin.Button(u8'�����', 784, 65, 80, 36, function() 
					if text_find_track ~= '' then
						qua_page = 1
						sel_link = ''
						find_track_link(text_find_track, 1)
					end
				end)
				imgui.PopStyleVar(1)
				imgui.SetCursorPos(imgui.ImVec2(180, 101))
				imgui.BeginChild(u8'����� � ���������', imgui.ImVec2(682, 304 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				if tracks.link[1] ~= '������404' then
					local POS_Y_T = 17
					for i = 1, #tracks.link do
						new_draw(POS_Y_T, 36)
						imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
						if imgui.InvisibleButton(u8'##�������� ����'..i, imgui.ImVec2(634, 36)) then
							if menu_play_track[1] and selectis == i and sel_link == tracks.link[i] then
								if status_track_pl == 'PLAY' then
									action_song('PAUSE')
								elseif status_track_pl == 'PAUSE' then
									action_song('PLAY')
								end
							elseif selectis ~= i and menu_play_track[1] or not menu_play_track[1] or sel_link ~= tracks.link[i] then
								selectis = i
								sel_link = tracks.link[i]
								select_record = 0
								select_radio = 0
								menu_play_track = {true, false, false, false}
								play_song(tracks.link[selectis], false)
							end
						end
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 8, 15)
							end
						elseif imgui.IsItemHovered() then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00)), 8, 15)
							end
						else
							if menu_play_track[1] and selectis == i and sel_link == tracks.link[i] then
								imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
								local p = imgui.GetCursorScreenPos()
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.07, col_end.fond_two[2] - 0.07, col_end.fond_two[3] - 0.07, 1.00)), 8, 15)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.16, col_end.fond_two[2] + 0.16, col_end.fond_two[3] + 0.16, 1.00)), 8, 15)
								end
							end
						end
						
						imgui.PushFont(fa_font[4])
						local favorite_track = false
						local favorite_track_i = 1
						if #save_tracks.link ~= 0 then
							for k = 1, #save_tracks.link do
								if tracks.link[i] == save_tracks.link[k] then 
									favorite_track = true
									favorite_track_i = k
									break
								end
							end
						end
						imgui.SetCursorPos(imgui.ImVec2(7, POS_Y_T + 8))
						if imgui.InvisibleButton(u8'##�������� � ���������'..i, imgui.ImVec2(20, 20)) then
							if favorite_track then
								table.remove(save_tracks.link, favorite_track_i)
								table.remove(save_tracks.artist, favorite_track_i)
								table.remove(save_tracks.name, favorite_track_i)
								table.remove(save_tracks.time, favorite_track_i)
								table.remove(save_tracks.image, favorite_track_i)
								save('save_tracks')
								if selectis ~= 0 and menu_play_track[2] then
									if favorite_track_i <= selectis and selectis ~= 1 and favorite_track_i ~= selectis and #save_tracks.link ~= 0 then
										selectis = selectis - 1
										status_image = selectis
									elseif favorite_track_i == #save_tracks.link+1 and selectis == favorite_track_i and #save_tracks.link ~= 0 then
										selectis = selectis - 1
										play_song(save_tracks.link[selectis], false)
									elseif favorite_track_i == selectis and favorite_track_i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
										play_song(save_tracks.link[selectis], false)
									end
									if #save_tracks.link == 0 then
										action_song('STOP')
									end
								end
							else
								table.insert(save_tracks.link, 1, tracks.link[i])
								table.insert(save_tracks.artist, 1, tracks.artist[i])
								table.insert(save_tracks.name, 1, tracks.name[i])
								table.insert(save_tracks.time, 1, tracks.time[i])
								table.insert(save_tracks.image, 1, tracks.image[i])
								save('save_tracks')
								if selectis ~= 0 and status_track_pl ~= 'STOP' and menu_play_track[2] then
									selectis = selectis + 1
									status_image = status_image + 1
								end
							end
						end
						imgui.SetCursorPos(imgui.ImVec2(11, POS_Y_T + 10))
						if imgui.IsItemActive() then
							if not favorite_track then
								imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_PLUS)
							else
								imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_CHECK)
							end
						elseif imgui.IsItemHovered() then
							if not favorite_track then
								imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_PLUS)
							else
								imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_CHECK)
							end
						else
							if not favorite_track then
								imgui.Text(fa.ICON_PLUS)
							else
								imgui.Text(fa.ICON_CHECK)
							end
						end
						imgui.SetCursorPos(imgui.ImVec2(35, POS_Y_T + 10))
						if selectis ~= i and sel_link ~= tracks.link[i] then
							imgui.Text(fa.ICON_PLAY)
						elseif status_track_pl == 'PLAY' and menu_play_track[1] and sel_link == tracks.link[i] then
							imgui.Text(fa.ICON_PAUSE)
						elseif status_track_pl == 'PAUSE' and menu_play_track[1] and sel_link == tracks.link[i] or not menu_play_track[1] or sel_link ~= tracks.link[i] then
							imgui.Text(fa.ICON_PLAY)
						end
						imgui.PopFont()
						imgui.PushFont(font[1])
						local track_text = tracks.artist[i]..' {7f7f7f}- '..tracks.name[i]
						local buf_size_text = imgui.ImBuffer(85)
						buf_size_text.v = track_text
						if buf_size_text.v ~= track_text then buf_size_text.v = string.sub(buf_size_text.v, 1, -4) .. '...' end
						imgui.SetCursorPos(imgui.ImVec2(58, POS_Y_T + 9))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}'..buf_size_text.v)
						else
							imgui.TextColoredRGB(buf_size_text.v)
						end
						local calc = imgui.CalcTextSize(tracks.time[i])
						imgui.SetCursorPos(imgui.ImVec2(656 - calc.x, POS_Y_T + 9))
						imgui.Text(tracks.time[i])
						imgui.PopFont()
						POS_Y_T = POS_Y_T + 46
					end
					imgui.Dummy(imgui.ImVec2(0, 20))
					
					if qua_page ~= 1 then
						local imvec4_col = imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00))
						if setting.int.theme == 'White' then
							imvec4_col = imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80 ,1.00))
						end
						local pos_page = 315
						if qua_page == 3 then
							pos_page = 297
						elseif qua_page == 4 then
							pos_page = 279
						end
						for m = 1, qua_page do
							imgui.SetCursorPos(imgui.ImVec2(pos_page, POS_Y_T + 20))
							local p = imgui.GetCursorScreenPos()
							imgui.SetCursorPos(imgui.ImVec2(pos_page - 11, POS_Y_T + 9))
							if m == current_page then
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 0.5, p.y - 0.5), 11, imvec4_col, 60)
							end
							if imgui.InvisibleButton(u8'##������� � ��������'..m, imgui.ImVec2(23, 23)) then
								find_track_link(text_find_track, m)
								current_page = m
							end
							imgui.SetCursorPos(imgui.ImVec2(pos_page - 3, POS_Y_T + 11))
							imgui.PushFont(font[1])
							imgui.Text(tostring(m))
							imgui.PopFont()
							pos_page = pos_page + 36
						end
						imgui.Dummy(imgui.ImVec2(0, 13))
					end
				else
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(172, 128 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'������ �� �������')
					imgui.PopFont()
				end
				imgui.EndChild()
				imgui.PopFont()
				
			elseif select_music == 2 then
				imgui.SetCursorPos(imgui.ImVec2(180, 65))
				imgui.BeginChild(u8'���������', imgui.ImVec2(682, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local remove_table_track = nil
				if #save_tracks.link ~= 0 then
					local POS_Y_T = 17
					for i = 1, #save_tracks.link do
						new_draw(POS_Y_T, 36)
						imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
						if imgui.InvisibleButton(u8'##�������� ���������� ����'..i, imgui.ImVec2(634, 36)) then
							if menu_play_track[2] and selectis == i then
								if status_track_pl == 'PLAY' then
									action_song('PAUSE')
								elseif status_track_pl == 'PAUSE' then
									action_song('PLAY')
								end
							elseif selectis ~= i and menu_play_track[2] or not menu_play_track[2] then
								selectis = i
								select_record = 0
								select_radio = 0
								menu_play_track = {false, true, false, false}
								play_song(save_tracks.link[selectis], false)
							end
						end
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.05, col_end.fond_two[2] + 0.05, col_end.fond_two[3] + 0.05, 1.00)), 8, 15)
							end
						elseif imgui.IsItemHovered() then
							imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.04, col_end.fond_two[2] + 0.04, col_end.fond_two[3] + 0.04, 1.00)), 8, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00)), 8, 15)
							end
						else
							if menu_play_track[2] and selectis == i then
								imgui.SetCursorPos(imgui.ImVec2(0, POS_Y_T))
								local p = imgui.GetCursorScreenPos()
								if setting.int.theme == 'White' then
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.07, col_end.fond_two[2] - 0.07, col_end.fond_two[3] - 0.07, 1.00)), 8, 15)
								else
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 36), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.16, col_end.fond_two[2] + 0.16, col_end.fond_two[3] + 0.16, 1.00)), 8, 15)
								end
							end
						end
						
						imgui.PushFont(fa_font[4])
						imgui.SetCursorPos(imgui.ImVec2(7, POS_Y_T + 8))
						if imgui.InvisibleButton(u8'##������� �� ���������'..i, imgui.ImVec2(20, 20)) then
							remove_table_track = i
						end
						imgui.SetCursorPos(imgui.ImVec2(11, POS_Y_T + 10))
						if imgui.IsItemActive() then
							imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), fa.ICON_TRASH)
						elseif imgui.IsItemHovered() then
							imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_TRASH)
						else
							imgui.Text(fa.ICON_TRASH)
						end
						imgui.SetCursorPos(imgui.ImVec2(35, POS_Y_T + 10))
						if selectis ~= i then
							imgui.Text(fa.ICON_PLAY)
						elseif status_track_pl == 'PLAY' and menu_play_track[2] then
							imgui.Text(fa.ICON_PAUSE)
						elseif status_track_pl == 'PAUSE' and menu_play_track[2] or not menu_play_track[2] then
							imgui.Text(fa.ICON_PLAY)
						end
						imgui.PopFont()
						imgui.PushFont(font[1])
						local track_text = save_tracks.artist[i]..' {7f7f7f}- '..save_tracks.name[i]
						local buf_size_text = imgui.ImBuffer(85)
						buf_size_text.v = track_text
						if buf_size_text.v ~= track_text then buf_size_text.v = string.sub(buf_size_text.v, 1, -4) .. '...' end
						imgui.SetCursorPos(imgui.ImVec2(58, POS_Y_T + 9))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}'..buf_size_text.v)
						else
							imgui.TextColoredRGB(buf_size_text.v)
						end
						local calc = imgui.CalcTextSize(save_tracks.time[i])
						imgui.SetCursorPos(imgui.ImVec2(656 - calc.x, POS_Y_T + 9))
						imgui.Text(save_tracks.time[i])
						imgui.PopFont()
						POS_Y_T = POS_Y_T + 46
					end
					imgui.Dummy(imgui.ImVec2(0, 20))
				else
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(145, 146 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'��� ��������� ������')
					imgui.PopFont()
				end
				
				if remove_table_track ~= nil then
					local i = remove_table_track
					table.remove(save_tracks.link, i)
					table.remove(save_tracks.artist, i)
					table.remove(save_tracks.name, i)
					table.remove(save_tracks.time, i)
					table.remove(save_tracks.image, i)
					save('save_tracks')
					if selectis ~= 0 and menu_play_track[2] then
						if i <= selectis and selectis ~= 1 and i ~= selectis and #save_tracks.link ~= 0 then
							selectis = selectis - 1
							status_image = selectis
						elseif i == #save_tracks.link+1 and selectis == i and #save_tracks.link ~= 0 then
							selectis = selectis - 1
							play_song(save_tracks.link[selectis], false)
						elseif i == selectis and i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
							play_song(save_tracks.link[selectis], false)
						end
						if #save_tracks.link == 0 then
							action_song('STOP')
							selectis = 0
						end
					end
				end
				
				imgui.EndChild()
			elseif select_music == 3 then
				imgui.SetCursorPos(imgui.ImVec2(162, 65))
				imgui.BeginChild(u8'����� Record', imgui.ImVec2(702, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local function background_record_card(posX_R, posY_R, i_R, record_text_name)
					imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
					if imgui.InvisibleButton(u8'##�������� ������������'..i_R, imgui.ImVec2(126, 156)) then 
						selectis = 0
						select_radio = 0
						menu_play_track = {false, false, true, false}
						if select_record ~= i_R then
							select_record = i_R
							artist = 'Record'
							name_tr = record_name[i_R]
							play_song(record[i_R])
						elseif status_track_pl == 'PLAY' then
							action_song('PAUSE')
						elseif status_track_pl == 'PAUSE' then
							action_song('PLAY')
						end
					end
					if select_record ~= i_R then
						if imgui.IsItemActive() then
						
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.03, col_end.fond_two[2] - 0.03, col_end.fond_two[3] - 0.03, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00), 10, 15)
							end
						elseif imgui.IsItemHovered() then
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00), 10, 15)
							end
						else
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00), 10, 15)
							end
						end
					else
						if setting.int.theme == 'White' then
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 10, 15)
						else
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 10, 15)
						end
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(posX_R + 16, posY_R + 5))
					imgui.Image(IMG_Record[i_R], imgui.ImVec2(94, 94))
					local calc = imgui.CalcTextSize(u8(record_text_name))
					imgui.SetCursorPos(imgui.ImVec2(posX_R + (63 - calc.x / 2 ), posY_R + 114))
					imgui.Text(u8(record_text_name))
					imgui.PopFont()
				end
				
				background_record_card(12, 12 + ((start_pos + new_pos) / 2), 1, 'Record')
				background_record_card(150, 12 + ((start_pos + new_pos) / 2), 2, 'Megamix')
				background_record_card(288, 12 + ((start_pos + new_pos) / 2), 3, 'Party 24/7')
				background_record_card(426, 12 + ((start_pos + new_pos) / 2), 4, 'Phonk')
				background_record_card(564, 12 + ((start_pos + new_pos) / 2), 5, '��� FM')
				
				background_record_card(12, 176 + ((start_pos + new_pos) / 2), 6, '���� �����')
				background_record_card(150, 176 + ((start_pos + new_pos) / 2), 7, 'Dupstep')
				background_record_card(288, 176 + ((start_pos + new_pos) / 2), 8, 'Big Hits')
				background_record_card(426, 176 + ((start_pos + new_pos) / 2), 9, 'Organic')
				background_record_card(564, 176 + ((start_pos + new_pos) / 2), 10, 'Russian Hits')
				
				imgui.EndChild()
			elseif select_music == 4 then
				imgui.SetCursorPos(imgui.ImVec2(162, 65))
				imgui.BeginChild(u8'������ �����', imgui.ImVec2(702, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local function background_radio_card(posX_R, posY_R, i_R, radiost_name)
					imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
					if imgui.InvisibleButton(u8'##�������� ������ ������������'..i_R, imgui.ImVec2(126, 156)) then 
						selectis = 0
						select_record = 0
						menu_play_track = {false, false, false, true}
						if select_radio ~= i_R then
							select_radio = i_R
							artist = 'Radio'
							name_tr = u8:decode(radio_name[i_R])
							play_song(radio[i_R])
						elseif status_track_pl == 'PLAY' then
							action_song('PAUSE')
						elseif status_track_pl == 'PAUSE' then
							action_song('PLAY')
						end
					end
					if select_radio ~= i_R then
						if imgui.IsItemActive() then
						
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.03, col_end.fond_two[2] - 0.03, col_end.fond_two[3] - 0.03, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00), 10, 15)
							end
						elseif imgui.IsItemHovered() then
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.02, col_end.fond_two[2] + 0.02, col_end.fond_two[3] + 0.02, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.12, col_end.fond_two[2] + 0.12, col_end.fond_two[3] + 0.12, 1.00), 10, 15)
							end
						else
							if setting.int.theme == 'White' then
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00), 10, 15)
							else
								skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(col_end.fond_two[1] + 0.09, col_end.fond_two[2] + 0.09, col_end.fond_two[3] + 0.09, 1.00), 10, 15)
							end
						end
					else
						if setting.int.theme == 'White' then
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 10, 15)
						else
							skin.DrawFond({posX_R, posY_R}, {0, 0}, {126, 152}, imgui.ImVec4(0.99, 0.35, 0.12 ,0.90), 10, 15)
						end
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(posX_R + 17, posY_R + 6))
					imgui.Image(IMG_Radio[i_R], imgui.ImVec2(92, 92))
					local calc = imgui.CalcTextSize(u8(radiost_name))
					imgui.SetCursorPos(imgui.ImVec2(posX_R + (63 - calc.x / 2 ), posY_R + 114))
					imgui.Text(u8(radiost_name))
					imgui.PopFont()
				end
				
				background_radio_card(12, 12 + ((start_pos + new_pos) / 2), 1, '������ ����')
				background_radio_card(150, 12 + ((start_pos + new_pos) / 2), 2, 'DFM')
				background_radio_card(288, 12 + ((start_pos + new_pos) / 2), 3, '������')
				background_radio_card(426, 12 + ((start_pos + new_pos) / 2), 4, '����� ����')
				background_radio_card(564, 12 + ((start_pos + new_pos) / 2), 5, '��������')
				
				background_radio_card(12, 176 + ((start_pos + new_pos) / 2), 6, '����')
				background_radio_card(150, 176 + ((start_pos + new_pos) / 2), 7, '����')
				background_radio_card(288, 176 + ((start_pos + new_pos) / 2), 8, 'LoFi Hip-Hop')
				background_radio_card(426, 176 + ((start_pos + new_pos) / 2), 9, '��������')
				background_radio_card(564, 176 + ((start_pos + new_pos) / 2), 10, '90s Eurodance')
				
				imgui.EndChild()
			end
			
		----> [9] �� ����
		elseif select_main_menu[9] then
			menu_draw_up(u8'�� ����')
			rp_zona_win()
			
		
		----> [11] ����������
		elseif select_main_menu[11] and select_lec == 0 then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			
			menu_draw_up(u8'����������')
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(632, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##�������� ������', imgui.ImVec2(202, 22)) then
				lec_buf = {
					q = {},
					wait = 2000,
					cmd = ''
				}
				select_lec = #setting.lec + 1
			end
			imgui.PopStyleVar(1)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
			imgui.SetCursorPos(imgui.ImVec2(642, 17))
			imgui.Text(fa.ICON_PLUS)
			imgui.PopFont()
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(665, 13))
			imgui.Text(u8'�������� ����� ������')
			imgui.PopStyleColor(1)
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			
			imgui.BeginChild(u8'����������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.lec == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(154, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'��� �� ����� ������')
				imgui.PopFont()
			else
				new_draw(17, -1 + (#setting.lec * 68))
				imgui.PushFont(font[1])
				local remove_lec
				for i = 1, #setting.lec do
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##������� � �������� ������'..i, imgui.ImVec2(666, 68)) then 
						local function deepCopy(orig)
							local copy
								if type(orig) == 'table' then
								copy = {}
								for key, value in next, orig, nil do
									copy[deepCopy(key)] = deepCopy(value)
								end
								setmetatable(copy, deepCopy(getmetatable(orig)))
							else
								copy = orig
							end
							
							return copy
						end
						lec_buf = deepCopy(setting.lec[i])
						select_lec = i
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemActive() then
						if i == 1 and #setting.lec ~= 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 3)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 3)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						elseif i == 1 and #setting.lec == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 15)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 15)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end 
						elseif i == #setting.lec then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 12)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 60)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 12)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 0)
							end
						end
					end
					imgui.PushFont(fa_font[5])
					imgui.SetCursorPos(imgui.ImVec2(640, 37 + ( (i - 1) * 68)))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50))
					imgui.Text(fa.ICON_ANGLE_RIGHT)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(17, 39 + ( (i - 1) * 68)))
					imgui.Text('/'..setting.lec[i].cmd)
				end
				if remove_lec ~= nil then table.remove(setting.lec, remove_lec) save('setting') end
				if #setting.lec > 1 then
					for draw = 1, #setting.lec - 1 do
						skin.DrawFond({17, 16 + (draw * 68)}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
					end
				end
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 80))
			imgui.EndChild()
		elseif select_main_menu[11] and select_lec ~= 0 then
			local function new_draw(pos_draw, par_dr_y, sizes_if_win, comm_tr)
				if sizes_if_win == nil then
					sizes_if_win = {17, 666}
				end
				imgui.SetCursorPos(imgui.ImVec2(sizes_if_win[1], pos_draw))
				local p = imgui.GetCursorScreenPos()
				if comm_tr == nil then
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
						if par_dr_y ~= 50 and par_dr_y ~= 44 and par_dr_y ~= 53 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 29), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						elseif par_dr_y == 53 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 23.5, p.y + 26.5), 26.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 640.5, p.y + 26.5), 26.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						elseif par_dr_y == 50 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 22, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 24.76), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						elseif par_dr_y == 44 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						end
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
						if par_dr_y ~= 50 and par_dr_y ~= 44 and par_dr_y ~= 53 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 28, p.y + 29), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						elseif par_dr_y == 53 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 23.5, p.y + 26.5), 26.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 640.5, p.y + 26.5), 26.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						elseif par_dr_y == 50 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 22, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 24.76), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						elseif par_dr_y == 44 then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21.8, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 645, p.y + 22), 22, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						end
					end
				else
					if setting.int.theme == 'White' then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.50)), 30, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizes_if_win[2], p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(0.99, 1.00, 0.21, 0.30)), 30, 15)
					end
				end
			end
			
			if menu_draw_up(u8'�������������� ������', true) then
				imgui.OpenPopup(u8'���������� �������� � �������')
				lec_err_nm = false
				lec_err_fact = false
			end
			if imgui.BeginPopupModal(u8'���������� �������� � �������', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'�������� � �������', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##������� ������ ������', imgui.ImVec2(20, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(6, 3))
					imgui.PushFont(fa_font[2])
					imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
					imgui.PopFont()
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				
				imgui.PushFont(bold_font[4])
				if not lec_err_nm and not lec_err_fact then
					imgui.SetCursorPos(imgui.ImVec2(35, 55))
					imgui.Text(u8'�������� ��������')
				elseif not lec_err_fact then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'������')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(63, 95))
					imgui.Text(u8'����� ������� ��� ����������!')
					imgui.PopFont()
				elseif not lec_err_nm then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'������')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(126, 95))
					imgui.Text(u8'������� �������!')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'���������##�������', 10, 167, 123, 25, function()
					if lec_buf.cmd == 'sh' or lec_buf.cmd == 'ts' then lec_err_nm = true end
					for i = 1, #setting.cmd do
						if setting.cmd[i][1] == lec_buf.cmd then
							lec_err_nm = true
							break
						end
					end
					for i = 1, #setting.lec do
						if setting.lec[i].cmd == lec_buf.cmd and i ~= select_lec then
							lec_err_nm = true
							break
						end
					end
					if lec_buf.cmd == '' then lec_err_fact = true end
					if not lec_err_nm and not lec_err_fact then
						if setting.lec[select_lec] ~= nil then
							sampUnregisterChatCommand(setting.lec[select_lec].cmd)
							sampRegisterChatCommand(lec_buf.cmd, function(arg) lec_start(arg, lec_buf.cmd) end)
							setting.lec[select_lec] = lec_buf
						else
							sampRegisterChatCommand(lec_buf.cmd, function(arg) lec_start(arg, lec_buf.cmd) end)
							setting.lec[select_lec] = lec_buf
						end
						save('setting')
						select_lec = 0
						imgui.CloseCurrentPopup()
					end
				end)
				skin.Button(u8'�� ���������', 138, 167, 124, 25, function()
					select_lec = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'�������', 267, 167, 123, 25, function()
					if setting.lec[select_lec] ~= nil then
						table.remove(setting.lec, select_lec)
					end
					save('setting')
					select_lec = 0
					imgui.CloseCurrentPopup()
				end)
				imgui.PopFont()
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			if select_lec ~= 0 then
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'�������������� ������', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 50)
				imgui.PushFont(font[1])
				skin.InputText(114, 31, u8'���������� �������', 'lec_buf.cmd', 15, 553, '[%a%d+-]+')
				if lec_buf.cmd:find('%A+') then
					local characters_to_remove = {
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�',
						'�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'
					}
					local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
					lec_buf.cmd = string.gsub(lec_buf.cmd, remove_pattern, '')
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 34))
				imgui.Text(u8'�������   /')
				
				
				new_draw(79, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 91))
				imgui.Text(u8'�������� ������������ ���������')
				skin.Slider('##�������� ������������ ��������� ������', 'lec_buf.wait', 400, 10000, 205, {470, 90}, nil)
				imgui.SetCursorPos(imgui.ImVec2(417, 89))
				imgui.Text(round(lec_buf.wait / 1000, 0.1)..u8' ���.')
				
				new_draw(135, 53 + (#lec_buf.q * 40))
				if #lec_buf.q ~= 0 then
					local remove_table_qq
					for i = 1, #lec_buf.q do
						skin.InputText(30, 149 + ((i - 1) * 40), u8'������� ���������##'..i, 'lec_buf.q.'..i, 1024, 595)
						
						imgui.SetCursorPos(imgui.ImVec2(647, 148 + ((i - 1) * 40)))
						if imgui.InvisibleButton(u8'##������� ���������'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(651, 153 + ((i - 1) * 40)))
						imgui.Text(fa.ICON_TRASH)
						imgui.PopFont()
					end
					if remove_table_qq ~= nil then table.remove(lec_buf.q, remove_table_qq) end
				end
				skin.Button(u8'�������� ���������', 242, 149 + (#lec_buf.q * 40), 173, 25, function() table.insert(lec_buf.q, '') end)
				imgui.PopFont()
				
				imgui.Dummy(imgui.ImVec2(0, 29))
				imgui.EndChild()
			end
			
		----> [10] ������
		elseif select_main_menu[10] then
			local function new_draw(pos_draw, par_dr_y, x_dr_pos)
				if x_dr_pos == nil then x_dr_pos = 0 end
				imgui.SetCursorPos(imgui.ImVec2(0 + x_dr_pos, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)

					if par_dr_y ~= 50 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 24.8, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 50 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 24.8, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 642, p.y + 25), 25, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			
			menu_draw_up(u8'������')
			
			if #setting.tickets == 0 then
				imgui.SetCursorPos(imgui.ImVec2(180, 41))
				imgui.BeginChild(u8'������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(39, 156 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'����� �� ������ ������ ������ ������ ��������� �������, �����')
				imgui.SetCursorPos(imgui.ImVec2(55, 186 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'���������� � ��������, �������� � ���� ��� ���������� ����!')
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'��������� � ����������', 240, 223 + ((start_pos + new_pos) / 2), 185, 35, function()
					local new_ticket = {
						--team = u8'������ '..(#setting.tickets + 1),
						status = 0,
						text = {},
						bool_text = '',
						time = 0
					}
					table.insert(setting.tickets, new_ticket)
					save('setting')
				end)
				imgui.PopFont()
				imgui.EndChild()
			else
				imgui.SetCursorPos(imgui.ImVec2(180, 41))
				imgui.BeginChild(u8'������ �������', imgui.ImVec2(682, 280 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				imgui.PushFont(font[1])
				
				if #setting.tickets[1].text ~= 0 then
					local function new_draw_mes(arg_mes, text_mes, pos_draw)
						imgui.PushFont(font[1])
						
						text_mes = (add_new_lines(u8:decode(text_mes), 65)):gsub('\\n', '\n')
						local calc = imgui.CalcTextSize(u8(text_mes))
						
						if arg_mes == 1 then
							imgui.SetCursorPos(imgui.ImVec2(632 - calc.x, 20 + pos_draw))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 20, p.y + 18 + calc.y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.16, col_end.fond_two[2] - 0.16, col_end.fond_two[3] - 0.06, 1.00)), 10, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 20, p.y + 18 + calc.y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.17, col_end.fond_two[2] + 0.17, col_end.fond_two[3] + 0.17, 1.00)), 10, 15)
							end
						else
							imgui.SetCursorPos(imgui.ImVec2(10, 20 + pos_draw))
							local p = imgui.GetCursorScreenPos()
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 20, p.y + 18 + calc.y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 10, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 20, p.y + 18 + calc.y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 10, 15)
							end
						end
						
						if arg_mes == 1 then
							local calc_nick = imgui.CalcTextSize(u8(my.nick))
							imgui.SetCursorPos(imgui.ImVec2(622 - calc.x - calc_nick.x, 27 + pos_draw))
							imgui.TextColoredRGB('{7F7F7F}'.. my.nick)
							imgui.SetCursorPos(imgui.ImVec2(642 - calc.x, 27 + pos_draw))
							imgui.Text(u8(text_mes))
						else
							imgui.SetCursorPos(imgui.ImVec2(40 + calc.x, 27 + pos_draw))
							imgui.TextColoredRGB('{7F7F7F}���������')
							imgui.SetCursorPos(imgui.ImVec2(20, 27 + pos_draw))
							imgui.Text(u8(text_mes))
						end
						
						imgui.PopFont()
						
						return calc.y + 33 + pos_draw
					end
					
					local pos_mess = 0
					for i = 1, #setting.tickets[1].text do
						pos_mess = new_draw_mes(1, setting.tickets[1].text[i][1], pos_mess)
						
						if setting.tickets[1].text[i][2] ~= '' then
							pos_mess = new_draw_mes(2, setting.tickets[1].text[i][2], pos_mess)
						end
					end
					
					imgui.Dummy(imgui.ImVec2(0, 29))
				else
					imgui.SetCursorPos(imgui.ImVec2(25, 110 + ( (start_pos + new_pos) / 2 )))
					imgui.TextColoredRGB('{7F7F7F}��� ��������� � ���� ���� ���������. �����, ����� ��� � ������ ���������, �� �� ������.')
					imgui.SetCursorPos(imgui.ImVec2(45, 130 + ( (start_pos + new_pos) / 2 )))
					imgui.TextColoredRGB('{7F7F7F} ������, �������� �� ���, �� ������ �� ����������� ���������� ���� ������ ������:')
					imgui.SetCursorPos(imgui.ImVec2(163, 150 + ( (start_pos + new_pos) / 2 )))
					imgui.TextColoredRGB('{7F7F7F}������, IP-�����, ��������� ���� � ���� ��������.')
				end
				
				imgui.PopFont()
				
				if get_scroll_max_help > 0 then
					imgui.SetScrollY(imgui.GetScrollMaxY())
					get_scroll_max_help = get_scroll_max_help - 1
				end
				imgui.EndChild()
				
				new_draw(321 + start_pos + new_pos, 90, 180)
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(195, 334 + start_pos + new_pos))
				local text_multiline = imgui.ImBuffer(1500)
				text_multiline.v = setting.tickets[1].bool_text
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
				imgui.InputTextMultiline('##���� ����� ������ ���������', text_multiline, imgui.ImVec2(649, 67), imgui.InputTextFlags.EnterReturnsTrue)
				imgui.PopStyleColor()
				if text_multiline.v == '' and not imgui.IsItemActive() then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					imgui.SetCursorPos(imgui.ImVec2(203, 337 + start_pos + new_pos))
					imgui.Text(u8'������� ����� ������ ���������')
					imgui.PopStyleColor()
				end
				setting.tickets[1].bool_text = text_multiline.v
				
				if setting.tickets[1].time <= 0 then
					skin.Button(u8'���������', 190, 420 + start_pos + new_pos, 646, 35, function()
						local function remove_quotes(str)
							local len = #str
							if len >= 2 and str:sub(1, 1) == '"' and str:sub(len, len) == '"' then
								return str:sub(2, len - 1)
							else
								return str
							end
						end
						send_message_about_problem(remove_quotes(encodeJson(setting.tickets[1].bool_text)), tostring(#setting.tickets[1].text + 1))
						table.insert(setting.tickets[1].text, {remove_quotes(encodeJson(setting.tickets[1].bool_text)), ''})
						setting.tickets[1].status = 0
						setting.tickets[1].time = 60
						setting.tickets[1].bool_text = ''
						get_scroll_max_help = 2
						save('setting')
					end)
				else
					skin.Button(u8'��������� ����� ����� ����� '.. tostring(setting.tickets[1].time) .. u8' ���.##false_non', 190, 420 + start_pos + new_pos, 646, 35, function() end)
				end
				imgui.PopFont()
				
			end
			imgui.Dummy(imgui.ImVec2(0, 24))
		
		----> [12] ������� ����
		elseif select_main_menu[12] then
			
			menu_draw_up(u8'������� ����')
			history_chats()
			
		----> [13] ��������
		elseif select_main_menu[13] then
			local function new_draw(pos_draw, par_dr_y)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_draw))
				local p = imgui.GetCursorScreenPos()
				if setting.int.theme == 'White' then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.06, col_end.fond_two[2] - 0.06, col_end.fond_two[3] - 0.06, 1.00)), 60)
					end
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + par_dr_y), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 30, 15)
					
					if par_dr_y ~= 47 then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + par_dr_y - 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + par_dr_y - 28), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 21, p.y + 24), 23, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 643, p.y + 23.5), 23.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.07, col_end.fond_two[2] + 0.07, col_end.fond_two[3] + 0.07, 1.00)), 60)
					end
				end
			end
			
			menu_draw_up(u8'������� ��������')
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'������� ��������', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 68)
			imgui.SetCursorPos(imgui.ImVec2(622, 30))
			if skin.Switch(u8'##��������� ���������', setting.fast_action_save) then setting.fast_action_save = not setting.fast_action_save save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 31))
			imgui.Text(u8'��������� ��������� ��������� �������')
			imgui.PopFont()
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(17, 53))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'���� �� ������, ����� ��������� ������ ����������� - ��������� ��� �������.')
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(254, 106))
			imgui.Text(u8'�������� � �����')
			imgui.PopFont()
			
			new_draw(135, 140)
			imgui.SetCursorPos(imgui.ImVec2(622, 148))
			if skin.Switch(u8'##��������� ��������� ����� ��', setting.fast_chat[1]) then 
				setting.fast_chat[1] = not setting.fast_chat[1]
				if setting.fast_action_save then 
					save('setting')
				end
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 149))
			imgui.Text(u8'��������� ��� ��������� � ����, ����� �� �������� � ��������')
			
			imgui.SetCursorPos(imgui.ImVec2(622, 178))
			if skin.Switch(u8'##��������� �� �������� � ������� �� ������ �������', setting.fast_chat[2]) then 
				setting.fast_chat[2] = not setting.fast_chat[2]
				if setting.fast_action_save then 
					save('setting')
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(17, 179))
			imgui.Text(u8'��������� �� �������� � ������� � ���� �� ������ �������')
			
			skin.Button(u8'�������� ���', 17, 220, 633, nil, function() 
				for qua = 1, 50 do
					sampAddChatMessage('', 0xFFFFFF)
				end
			end)
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(252, 296))
			imgui.Text(u8'�������� � �����')
			imgui.PopFont()
			
			new_draw(325, 216)
			
			imgui.PushFont(font[1])
			skin.Button(u8'���������/�������� ����� ����� �������', 17, 345, 633, nil, function() 
				setting.off_nick = not setting.off_nick
				sampSendChat('/settings')
				nickname_dialog = true
				time_dialog_nickname = 0
				if setting.fast_action_save then 
					save('setting')
				end
			end)
			
			skin.Button(u8'������ ��������� �� ��������� ����� �� �����', 17, 392, 633, nil, function() 
				local my_int = getActiveInterior()
				if my_int == 0 then
					local bool_result, pos_X, pos_Y, pos_Z = getTargetServerCoordinates()
					if bool_result then
						local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
						local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
						sampAddChatMessage(script_tag..'{f7c52f}���������� �� ��� �� �����: '..removeDecimalPart(distance)..' �.', color_tag)
					else
						sampAddChatMessage(script_tag..'{f7c52f}���������� ���������� ���������, ��� ��� ����������� �����.', color_tag)
					end
				else
					sampAddChatMessage(script_tag..'{f7c52f}���������� ���������� ���������, ��� ��� �� ���������� � ���������.', color_tag)
				end
			end)
			skin.Button(u8'������ ��������� �� ����������� ����� �� �����', 17, 439, 633, nil, function() 
				local my_int = getActiveInterior()
				if my_int == 0 then
					local bool_result, pos_X, pos_Y, pos_Z = getTargetBlipCoordinates()
					if bool_result then
						local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
						local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
						sampAddChatMessage(script_tag..'{f7c52f}���������� �� ��� �� �����: '..removeDecimalPart(distance)..' �.', color_tag)
					else
						sampAddChatMessage(script_tag..'{f7c52f}���������� ���������� ���������, ��� ��� ����������� �����.', color_tag)
					end
				else
					sampAddChatMessage(script_tag..'{f7c52f}���������� ���������� ���������, ��� ��� �� ���������� � ���������.', color_tag)
				end
			end)
			skin.Button(u8'������� ���������� � ��������', 17, 486, 633, nil, function() 
				�lose_�onnect()
			end)
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(234, 562))
			imgui.Text(u8'�������� �� ��������')
			imgui.PopFont()
			
			new_draw(591, 169)
			imgui.PushFont(font[1])
			skin.Button(u8'������������� ������', 17, 611, 633, nil, function() 
				showCursor(false)
				scr:reload()
			end)
			
			skin.Button(u8'�������� ��� ��������� �������', 17, 658, 633, nil, function() 
				script_ac.reset = script_ac.reset + 1
				if script_ac.reset > 1 then
					local deletedir
					deletedir = function(dir)
						for file in lfs.dir(dir) do
							local file_path = dir..'/'..file
							if file ~= "." and file ~= ".." then
								if lfs.attributes(file_path, 'mode') == 'file' then
									os.remove(file_path)
								elseif lfs.attributes(file_path, 'mode') == 'directory' then
									deletedir(file_path)
								end
							end
						end
						lfs.rmdir(dir)
					end
					sampAddChatMessage(script_tag..'{FFFFFF}��������� ��������. ������������ �������...', color_tag)
					deletedir(dirml..'/StateHelper/')
					showCursor(false)
					scr:reload()
				end
			end)
			skin.Button(u8'������� ������', 17, 705, 633, nil, function() 
				script_ac.del = script_ac.del + 1
				if script_ac.del > 1 then
					sampAddChatMessage(script_tag..'{FFFFFF}������ �����! �� ������ ������ ������� ��� ����� �� ����� BlastHack.', color_tag)
					win.main.v = false
					showCursor(false)
					os.remove(scr.path)
					scr:reload()
				end
			end)
			imgui.PopFont()
			
			imgui.Dummy(imgui.ImVec2(0, 43))
			imgui.EndChild()
		end
	else
		imgui.PushFont(fa_font[6])
		imgui.SetCursorPos(imgui.ImVec2(301, 215 + ((start_pos + new_pos) / 2)))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), fa.ICON_LOCK)
		imgui.PopFont()
		imgui.PushFont(bold_font[4])
		imgui.SetCursorPos(imgui.ImVec2(343, 210 + ((start_pos + new_pos) / 2)))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), u8'������ ������������')
		imgui.PopFont()
	end
	imgui.End()
end

function window.music()
	imgui.SetNextWindowSize(imgui.ImVec2(328, 98), imgui.Cond.Always)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy - 60), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Musec Window', win.music.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
	skin.DrawFond({4, 4}, {0, 0}, {320, 90}, imgui.ImVec4(0.00, 0.00, 0.00, 1.00), 15, 15) --0.17, 0.17, 0.17, 1.00
	
	imgui.SetCursorPos(imgui.ImVec2(15, 14))
	if selectis == status_image then
		imgui.Image(IMG_label, imgui.ImVec2(70, 70))
	elseif select_record == 0 and select_radio == 0 then
		imgui.Image(IMG_No_Label, imgui.ImVec2(70, 70))
	elseif select_record ~= 0 then
		imgui.Image(IMG_Record[select_record], imgui.ImVec2(70, 70))
	elseif select_radio ~= 0 then
		imgui.Image(IMG_Radio[select_radio], imgui.ImVec2(70, 70))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 14))
	imgui.Image(IMG_Background_Black, imgui.ImVec2(70, 70))
	
	if status_track_pl == 'PAUSE' then
		imgui.SetCursorPos(imgui.ImVec2(15, 14))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 70, p.y + 70), imgui.GetColorU32(imgui.ImVec4(0.00, 0.00, 0.00, 0.60)))
		
		imgui.PushFont(fa_font[5])
		imgui.SetCursorPos(imgui.ImVec2(39, 36))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_PAUSE)
		imgui.PopFont()
	end
	
	imgui.SetCursorPos(imgui.ImVec2(96, 75))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 217, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.50, 0.50, 0.50, 0.40)))
	
	if not menu_play_track[3] and not menu_play_track[4] then
		local size_X_line = ((timetr[2] * 60 + timetr[1]) * timetri) * 0.5425
		if size_X_line > 217 then
			size_X_line = 217
		end
		imgui.SetCursorPos(imgui.ImVec2(96, 75))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size_X_line, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80, 1.00)))
	else
		imgui.SetCursorPos(imgui.ImVec2(96, 75))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 217, p.y + 3), imgui.GetColorU32(imgui.ImVec4(0.80, 0.80, 0.80, 1.00)))
	end
	
	imgui.PushFont(font[7])
	local artist_buf = imgui.ImBuffer(22)
	local name_buf = imgui.ImBuffer(22)
	local artist_end = artist
	local name_end = name_tr
	artist_buf.v = artist
	name_buf.v = name_tr
	if artist_buf.v ~= artist then artist_end = artist_buf.v..'...' end
	if name_buf.v ~= name_tr then name_end = name_buf.v..'...' end
	imgui.SetCursorPos(imgui.ImVec2(96, 20))
	imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), u8(artist_end))
	imgui.SetCursorPos(imgui.ImVec2(96, 42))
	imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.70), u8(name_end))
	
	imgui.PopFont()
	imgui.End()
end

function window.act_choice()
	if sampIsPlayerConnected(targ_id) then
		local actions_per_column = 5
		local total_actions = #setting.fast_acc.sl
		local column_count = math.ceil(total_actions / actions_per_column)
		local fixed_height = 350
		imgui.SetNextWindowSize(imgui.ImVec2(278 * column_count, fixed_height), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(setting.pos_act.x, setting.pos_act.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Choice Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		skin.DrawFond({4, 4}, {0, 0}, {270 * column_count, fixed_height}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
		local bool_pos_act = imgui.GetWindowPos()
		local bool_upd_pos = {x = bool_pos_act.x + 139 * column_count, y = bool_pos_act.y + (fixed_height / 2)}
		if not imgui.IsMouseDown(0) then
			if bool_upd_pos.x ~= setting.pos_act.x or bool_upd_pos.y ~= setting.pos_act.y then
				setting.pos_act = {x = bool_upd_pos.x, y = bool_upd_pos.y}
				save('setting')
			end
		end
		imgui.PushFont(font[4])
		local calc = imgui.CalcTextSize(flies_nick..' ['..flies_id..']')
		local header_width = calc.x + 18
		imgui.SetCursorPos(imgui.ImVec2((278 * column_count - header_width) / 2, 4))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + header_width, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2((278 * column_count - calc.x) / 2, 9))
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), flies_nick..' ['..flies_id..']')
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + header_width, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2((278 * column_count - calc.x) / 2, 9))
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00, 1.00), flies_nick..' ['..flies_id..']')
		end
		imgui.PopFont()
		imgui.PushFont(font[1])
		for i = 1, total_actions do
			local bool_cmd = true
			for k = 1, #setting.cmd do
				if setting.cmd[k][1] == setting.fast_acc.sl[i].cmd then
					if tonumber(setting.frac.rank) < tonumber(setting.cmd[k][4]) then
						bool_cmd = false
					end
					break
				end
			end
			local column_index = math.floor((i - 1) / actions_per_column)
			local row_index = (i - 1) % actions_per_column
			local x_pos = 9 + (column_index * 270)
			local y_pos = 60 + (row_index * 35)
			if bool_cmd then
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i, x_pos, y_pos, 260, 30, function()
					if sampIsPlayerConnected(flies_id) then
						local cmd_send_chat = '/'..setting.fast_acc.sl[i].cmd
						local arg_tr = ''
						if setting.fast_acc.sl[i].pass_arg then
							cmd_send_chat = cmd_send_chat..' '..flies_id
							arg_tr = flies_id
						end
						if setting.fast_acc.sl[i].send_chat then
							local tr_cmd = false
							for c = 1, #setting.cmd do
								if setting.cmd[c][1] == setting.fast_acc.sl[i].cmd then tr_cmd = true break end
							end
							if tr_cmd then
								cmd_start(tostring(arg_tr), setting.fast_acc.sl[i].cmd)
							else
								sampSendChat(cmd_send_chat)
							end
						else
							sampSetChatInputEnabled(true)
							sampSetChatInputText(cmd_send_chat)
						end
						win.action_choice.v = false
					end
				end)
			else
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i..'##false_non', x_pos, y_pos, 260, 30, function() end)
				imgui.PushFont(fa_font[1])
				imgui.SetCursorPos(imgui.ImVec2(x_pos + 241, y_pos + 10))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_LOCK)
				imgui.PopFont()
			end
			if row_index < actions_per_column - 1 then
				imgui.GetWindowDrawList():AddLine(
					imgui.ImVec2(x_pos, y_pos + 35),
					imgui.ImVec2(x_pos + 260, y_pos + 35),
					imgui.GetColorU32(imgui.ImVec4(0.7, 0.7, 0.7, 0.6))
				)
			end
		end
		skin.Button(u8'��������', 9, 80 + (actions_per_column * 35), 260 * column_count, 35, function()
			win.action_choice.v = false
		end)
		imgui.PopFont()

		imgui.End()
	end
end

function window.spur()
	imgui.SetNextWindowSize(imgui.ImVec2(908, 658), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Spur Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	skin.DrawFond({4, 4}, {0, 0}, {900, 650}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##������� ���� �����', imgui.ImVec2(20, 20))  then
		win.spur_big.v = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	local options_size_font = {6, 3, 1, 4, 5}
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(40, 10))
	if skin.Slider('##������ ������', 'spur_text_size', 0, 4, 130, {50, 11}) then end
	imgui.PopFont()
	
	local text_spur_table = {}
	for line in text_spur:gmatch('[^\n]*\n?') do
		table.insert(text_spur_table, line:match('^(.-)\n?$'))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 50))
	imgui.BeginChild(u8'����� ���������', imgui.ImVec2(879, 603), false)
	imgui.PushFont(font[options_size_font[round(spur_text_size, 1) + 1]])
	for i, line in ipairs(text_spur_table) do
		imgui.TextWrapped(line)
	end
	imgui.PopFont()
	imgui.EndChild()
	
	imgui.End()
end

function window.reminder()
	imgui.SetNextWindowSize(imgui.ImVec2(608, 122), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('Spur Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	skin.DrawFond({4, 4}, {0, 0}, {600, 114}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
	
	imgui.SetCursorPos(imgui.ImVec2(13, 13))
	if imgui.InvisibleButton(u8'##������� ���� �����������', imgui.ImVec2(20, 20))  then
		win.reminder.v = false
	end
	imgui.SetCursorPos(imgui.ImVec2(23, 23))
	local p = imgui.GetCursorScreenPos()
	if imgui.IsItemHovered() then
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		imgui.SetCursorPos(imgui.ImVec2(19, 16))
		imgui.PushFont(fa_font[2])
		imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00 ,0.70), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
	end
	
	imgui.PushFont(font[4])
	local calc = imgui.CalcTextSize(rem_text)
	imgui.SetCursorPos(imgui.ImVec2(304 - (calc.x / 2), 50))
	imgui.Text(rem_text)
	imgui.PopFont()
	imgui.End()
end

function window.icon()
	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(240, 700))
	imgui.Begin('Window Icon', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
	
	for i,v in pairs(fa) do
		imgui.PushFont(fa_font[1])
		if imgui.Button(fa[i]..' - '..i, imgui.ImVec2(210, 25)) then setClipboardText(i) end
		imgui.PopFont()
	end
	
	imgui.End()
end

function open_big_shpora(spur_number)
	if spur_number > #setting.shpora then
		sampAddChatMessage(script_tag..'{FFFFFF} ����� ��������� �� ����������. ����� �� '..#setting.shpora, color_tag)
		return
	elseif spur_number <= 0 then
		sampAddChatMessage(script_tag..'{FFFFFF} ������ ��������� ���������� � �������!', color_tag)
		return
	end
	
	if doesFileExist(dirml..'/StateHelper/���������/'..setting.shpora[spur_number][1]..'.txt') then
		sel_big_spur = spur_number
		local f = io.open(dirml..'/StateHelper/���������/'..setting.shpora[spur_number][1]..'.txt')
		text_spur = u8(f:read('*a'))
		f:close()			
		win.spur_big.v = true
	end
end

local notif_manag = {
	s_y = 100,
	p_x = -150
}
function window.notice()
	if notif_manag.p_x < 160 and wind_act_wait then 
		notif_manag.p_x = notif_manag.p_x + 15
	elseif not wind_act_wait and notif_manag.p_x > -150 then
		notif_manag.p_x = notif_manag.p_x - 15
	elseif not wind_act_wait and notif_manag.p_x <= -150 then
		win.notice.v = false
	end
	
	imgui.SetNextWindowPos(imgui.ImVec2(sx - notif_manag.p_x, sy - (notif_manag.s_y / 2 + 10)), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(308, notif_manag.s_y + 8))
	imgui.Begin('Window Wait Notice', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	skin.DrawFond({4, 4}, {0, 0}, {300, notif_manag.s_y}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 0.80), 15, 15)
	
	imgui.PushFont(font[4])
	if all_text_notice ~= nil then
		for i = 1, #all_text_notice do
			imgui.SetCursorPos(imgui.ImVec2(20, 23 + ((i - 1) * 27)))
			imgui.Text(all_text_notice[i])
		end
	end
	imgui.PopFont()
	
	imgui.End()
end
win.notice.v = false
wind_act_wait = false
all_text_notice = {}

function window.stat_online()
		local len_win = 21
		if setting.stat_on_members.time then len_win = len_win + 23 end
		if setting.stat_on_members.date then len_win = len_win + 26 end
		if setting.stat_on_members.clean_on_day then len_win = len_win + 23 end
		if setting.stat_on_members.afk_on_day then len_win = len_win + 23 end
		if setting.stat_on_members.all_on_day then len_win = len_win + 23 end
		if setting.stat_on_members.clean_on_session then len_win = len_win + 23 end
		if setting.stat_on_members.afk_on_session then len_win = len_win + 23 end
		if setting.stat_on_members.all_on_session then len_win = len_win + 23 end
		if setting.stat_on_members.time or setting.stat_on_members.date then
			if setting.stat_on_members.clean_on_day or setting.stat_on_members.afk_on_day or setting.stat_on_members.all_on_day
			or setting.stat_on_members.clean_on_session or setting.stat_on_members.clean_on_session or setting.stat_on_members.all_on_session then
				len_win = len_win + 6
			end
		end
		
		local function formatCustomDate()
			local weekdays = {u8'�����������', u8'�����������', u8'�������', u8'�����', u8'�������', u8'�������', u8'�������'}
			local months = {u8'������', u8'�������', u8'�����', u8'������', u8'���', u8'����', u8'����', u8'�������', u8'��������', u8'�������', u8'������', u8'�������'}

			local currentTime = os.date('*t')
			local weekday = weekdays[currentTime.wday]
			local month = months[currentTime.month]
			local day = currentTime.day

			return weekday .. ', ' .. day .. ' ' .. month
		end
		imgui.SetNextWindowPos(imgui.ImVec2(setting.pos_onstat.x, setting.pos_onstat.y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(257, len_win + 8))
		imgui.Begin('Window Stat Online', false, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBringToFrontOnFocus)
		
		skin.DrawFond({4, 4}, {0, 0}, {249, len_win}, imgui.ImVec4(0.00, 0.00, 0.00, 0.50), 15, 15)
		if imgui.IsMouseClicked(0) and change_pos_onstat then change_pos_onstat = false end
		if start_session then
			showCursor(false)
			start_session = false
		end
	
		local pos_win_elements = 17
		imgui.PushFont(font[1])
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 0.50))
		if setting.stat_on_members.time then
			local time_format = os.date('%H:%M:%S')
			local len_date = imgui.CalcTextSize(time_format)
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(120 - len_date.x / 2, pos_win_elements))
			imgui.Text(time_format)
			imgui.PopFont()
			pos_win_elements = pos_win_elements + 26
		end
		if setting.stat_on_members.date then
			local date_format = formatCustomDate()
			local len_date_format = imgui.CalcTextSize(date_format)
			imgui.SetCursorPos(imgui.ImVec2(128 - len_date_format.x / 2, pos_win_elements))
			imgui.Text(date_format)
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.date or setting.stat_on_members.time then
			if setting.stat_on_members.clean_on_day or setting.stat_on_members.afk_on_day or setting.stat_on_members.all_on_day
			or setting.stat_on_members.clean_on_session or setting.stat_on_members.clean_on_session or setting.stat_on_members.all_on_session then
				skin.DrawFond({23, pos_win_elements}, {0, 0}, {209, 2}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
				pos_win_elements = pos_win_elements + 6
			end
		end
		if setting.stat_on_members.clean_on_day then
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'������ �� ����: '.. u8(print_time(setting.online_stat.clean[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.afk_on_day then
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'��� �� ����: '.. u8(print_time(setting.online_stat.afk[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.all_on_day then
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'����� �� ����: '.. u8(print_time(setting.online_stat.all[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.clean_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'������ �� ������: '.. u8(print_time(session_clean.v)))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.afk_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'��� �� ������: '.. u8(print_time(session_afk.v)))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.all_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'����� �� ������: '.. u8(print_time(session_all.v)))
			pos_win_elements = pos_win_elements + 23
		end
		imgui.PopStyleColor(1)
		imgui.PopFont()

		imgui.End()
end

function new_notice(type_notice, text_notice)
	if type_notice == 'wait' then
		all_text_notice = text_notice
		notif_manag.s_y = 36 + (#all_text_notice * 27)
		wind_act_wait = true
		win.notice.v = true
	elseif type_notice == 'off' then
		wind_act_wait = false
	else
		all_text_notice = text_notice
		lua_thread.create(function()
			wind_act_wait = true
			win.notice.v = true
			wait(6000)
			wind_act_wait = false
		end)
	end
	showCursor(false)
end

color_w = {
	fond_one = {0.91, 0.89, 0.76, 1.00},
	fond_two = {0.96, 0.94, 0.93, 1.00},
	text = 0.00
}

color_b = {
	fond_one = {0.14, 0.14, 0.15, 1.00},
	fond_two = {0.12, 0.12, 0.12, 1.00},
	text = 1.00
}

col_end = {
	fond_one = {0.91, 0.89, 0.76, 1.00},
	fond_two = {0.96, 0.94, 0.93, 1.00},
	text = 0.00
}

if setting.int.theme == 'Black' then
	col_end = {
		fond_one = {0.14, 0.14, 0.15, 1.00},
		fond_two = {0.12, 0.12, 0.12, 1.00},
		text = 1.00
	}
end

function color_accent()
	
end

function style_window()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.WindowRounding = 15.0
	style.ChildWindowRounding = 10.0
	style.FrameRounding = 9.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ScrollbarSize = 15.0
	style.FramePadding = imgui.ImVec2(5, 3)
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarRounding = 0
	style.GrabMinSize = 18.0
	style.GrabRounding = 4.0
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	
	colors[clr.FrameBg] 			 = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- �������
	colors[clr.FrameBgHovered]       = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- �������
	colors[clr.FrameBgActive]        = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- �������
	colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.TitleBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.SliderGrabActive]     = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.Button]               = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- ������
	colors[clr.ButtonHovered]        = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- ������
	colors[clr.ButtonActive]         = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- ������
	colors[clr.Header]               = ImVec4(1.00, 1.00, 1.00, 0.65)
	colors[clr.HeaderHovered]        = ImVec4(1.00, 1.00, 1.00, 0.80)
	colors[clr.HeaderActive]         = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.Separator]            = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.SeparatorHovered]     = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.SeparatorActive]      = ImVec4(0.37, 0.37, 0.37, 0.60)
	colors[clr.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.TextSelectedBg]       = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.Text]                 = ImVec4(col_end.text, col_end.text, col_end.text, 1.00) -- �����
	colors[clr.TextDisabled]         = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.08, 0.08, 0.08, 0.00)
	colors[clr.ChildWindowBg]        = ImVec4(1.00, 1.00, 1.00, 0.00)
	if setting.int.theme == 'White' then
		colors[clr.PopupBg]          = ImVec4(0.80, 0.80, 0.80, 1.00) -- ����
	else
		colors[clr.PopupBg]          = ImVec4(0.10, 0.10, 0.10, 1.00) -- ����
	end
	colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.26, 0.59, 0.98, 0.00)
	colors[clr.MenuBarBg]            = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.00, 0.00, 0.00, 0.00) -- �������������� �����
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00) -- �������������� �����
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00) -- �������������� �����
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00) -- �������������� �����
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

--> ����������
function save(table_name)
	if table_name == 'setting' then
		local f = io.open(dirml..'/StateHelper/���������.json', 'w')
		f:write(encodeJson(setting))
		f:flush()
		f:close()
	elseif table_name == 'save_tracks' then
		local f = io.open(dirml..'/StateHelper/�����.json', 'w')
		f:write(encodeJson(save_tracks))
		f:flush()
		f:close()
	elseif table_name == 'scene' then
		local f = io.open(dirml..'/StateHelper/�����.json', 'w')
		f:write(encodeJson(scene))
		f:flush()
		f:close()
	end
end

--[[
	0 - ��������� � ���
	1 - �������� ������� Enter
	2 - ������� ���� � ���
	3 - ������ ������ ��������
	4 - �����������
	5 - �������� ����������
	6 - ���� ���������� �����
	7 - ��������� ������� ����������
	8 - ���� ������ ������� �������
	9 - ��������� ������
]]
			
function cmd_start(arg_c, command_active)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}� ��� ��� �������� ���������! ����������� {ED95A8}Page Down{FFFFFF}, ����� ���������� �.', color_tag)
		return
	end
	
	local f = io.open(dirml..'/StateHelper/���������/'..command_active..'.json')
	local setm = f:read('*a')
	f:close()
	local res, set = pcall(decodeJson, setm)
	if res and type(set) == 'table' then 
		cmds = set
	end
	
	if tonumber(setting.frac.rank) < tonumber(cmds.rank) then
		sampAddChatMessage(script_tag..'{FFFFFF}������ ������� �������� � '..cmds.rank..' �����!', color_tag)
		return
	end
	
	local args = {}
	if #cmds.arg ~= 0 then
		local function invalid_arguments()
			local tbl_ar = {}
			for ar = 1, #cmds.arg do
				table.insert(tbl_ar, '['..u8:decode(cmds.arg[ar][2])..']')
			end
			sampAddChatMessage(script_tag..'{FFFFFF}����������� {a8a8a8}/'..command_active..' '..table.concat(tbl_ar, ' '), color_tag)
		end
		
		for word in arg_c:gmatch('%S+') do
			table.insert(args, word)
		end
		
		if #args > #cmds.arg then
			local merged = table.concat(args, ' ', #cmds.arg, #args)
			args[#cmds.arg] = merged
			for z = #args, #cmds.arg + 1, -1 do
				table.remove(args, z)
			end
		end
		
		for arg_i, arg_v in ipairs(cmds.arg) do
			if arg_v[1] == 0 then
				if args[arg_i] ~= nil then
					if not args[arg_i]:find('^(%d+)$') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			elseif arg_v[1] == 1 then
				if args[arg_i] ~= nil then
					if not args[arg_i]:find('(.+)') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			end
		end
	end
	
	local not_send_chat
	if cmds.not_send_chat then
		for mess = 1, #cmds do
			if cmds.act[mess][1] == 0 then
				not_send_chat = mess
			end
		end
	end
	
	local function conv_tag(text_to_convert)
		local stop_send_chat = false
		local num_id_dial = -1
		local num_id_player = 0
		local mass_tags = {}
		for value in text_to_convert:gmatch('{(.-)}') do
		  table.insert(mass_tags, '{' .. value .. '}')
		end
		if #mass_tags == 0 then return text_to_convert end
		for value in text_to_convert:gmatch('{arg(%d+)}') do
			if text_to_convert:find('{arg(%d+)}') then
				local number = tonumber(text_to_convert:match('{arg(%d+)}'))
				if text_to_convert:find('{arg'..number..'}') and cmds.arg[number] ~= nil then
					text_to_convert = text_to_convert:gsub('{arg'..number..'}', u8(args[number]))
				end
			end
		end
		for value in text_to_convert:gmatch('{var(%d+)}') do
			if text_to_convert:find('{var(%d+)}') then
				local number = tonumber(text_to_convert:match('{var(%d+)}'))
				if text_to_convert:find('{var'..number..'}') and cmds.var[number] ~= nil then
					text_to_convert = text_to_convert:gsub('{var'..number..'}', cmds.var[number][2])
				end
			end
		end
		if text_to_convert:find('{prtsc}') then
			stop_send_chat = true
			text_to_convert = text_to_convert:gsub('{prtsc}', '')
			print_scr()
		end
		
		text_to_convert = tag_act(text_to_convert)
		
		if text_to_convert:find('{dialoglic%[(%d+)%]%[(%d+)%]%[(%d+)%]}') then
			stop_send_chat = true
			num_id_dial, num_id_term, num_id_player = string.match(text_to_convert, '{dialoglic%[(.-)%]%[(.-)%]%[(.-)%]}')
			if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 10 then
				num_give_lic = tonumber(num_id_dial)
			else
				sampAddChatMessage(script_tag..'{FF5345}[����������� ������] {FFFFFF}�������� {dialoglic} ����� �������� ��������.', color_tag)
				return ''
			end
			if tonumber(num_id_term) >= 0 and tonumber(num_id_term) <= 3 then
				num_give_lic_term = tonumber(num_id_term)
			else
				sampAddChatMessage(script_tag..'{FF5345}[����������� ������] {FFFFFF}�������� {dialoglic} ����� �������� ��������.', color_tag)
				return ''
			end
		end
		if stop_send_chat then return '/givelicense '..num_id_player end
		
		if text_to_convert:find('{dialoggov%[(%d+)%]%[(%d+)%]}') then
			stop_send_chat = true
			num_id_dial, num_id_player = string.match(text_to_convert, '{dialoggov%[(.-)%]%[(.-)%]}')
			if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 3 then
				num_give_gov = tonumber(num_id_dial)
			else
				sampAddChatMessage(script_tag..'{FF5345}[����������� ������] {FFFFFF}�������� {dialoggov} ����� �������� ��������.', color_tag)
				return ''
			end
		end
		if stop_send_chat then return '/givepass '..num_id_player end
		
		return text_to_convert
	end
	
	local function are_all_false(arr)
		for i = 1, #arr do
			if arr[i] ~= false then
				return false
			end
		end
		return true
	end
	
	local delay = cmds.delay
	local dialogs = {}
	local bool = {}
	
	thread = lua_thread.create(function()
		for i, v in ipairs(cmds.act) do
			if are_all_false(bool) then
				if v[1] == 0 then
					local message_end = ((u8:decode(conv_tag(v[2]))))
					if i ~= 1 then
						if cmds.act[i - 1][1] == 0 then
							wait(delay)
						end
					end
					if not cmds.not_send_chat then
						sampSendChat(message_end)
					elseif cmds.not_send_chat and i ~= not_send_chat then
						sampSendChat(message_end)
					elseif cmds.not_send_chat and i == not_send_chat then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(message_end)
					end
				elseif v[1] == 1 then
					wait(400)
					sampAddChatMessage(script_tag..'{FFFFFF}������� �� {23E64A}Enter{FFFFFF} ��� ����������� ��� {FF8FA2}Page Down{FFFFFF}, ����� ��������� ���������.', color_tag)
					addOneOffSound(0, 0, 0, 1058)
					new_notice('wait', {u8'Enter - ���������� ���������', u8'Page Down - ����������'})
					while true do wait(0)
						if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then new_notice('off') break end
					end
				elseif v[1] == 2 then
					local message_end = ((u8:decode(conv_tag(v[2]))))
					sampAddChatMessage(script_tag..'{FFFFFF}'..message_end, color_tag)
				elseif v[1] == 3 then
					local dr_texts = {}
					for t = 1, v[3] do
						table.insert(dr_texts, u8'Num '..t..' - '..v[4][t])
					end
					new_notice('wait', dr_texts)
					while true do wait(0)
						if not sampIsChatInputActive() and not sampIsDialogActive() then
							if isKeyJustPressed(VK_1) or isKeyJustPressed(VK_NUMPAD1) then table.insert(dialogs, {v[2], 1, false}) new_notice('off') break end
							if isKeyJustPressed(VK_2) or isKeyJustPressed(VK_NUMPAD2) then table.insert(dialogs, {v[2], 2, false}) new_notice('off') break end
							if isKeyJustPressed(VK_3) or isKeyJustPressed(VK_NUMPAD3) then table.insert(dialogs, {v[2], 3, false}) new_notice('off') break end
							if isKeyJustPressed(VK_4) or isKeyJustPressed(VK_NUMPAD4) then table.insert(dialogs, {v[2], 4, false}) new_notice('off') break end
							if isKeyJustPressed(VK_5) or isKeyJustPressed(VK_NUMPAD5) then table.insert(dialogs, {v[2], 5, false}) new_notice('off') break end
						end
					end
				elseif v[1] == 5 then
					local number = tonumber(string.match(v[2], '%d+'))
					if cmds.var[number] ~= nil then cmds.var[number][2] = v[3] end
				elseif v[1] == 6 then
					table.insert(bool, true)
					local number = tonumber(string.match(v[2], '%d+'))
					for vr = 1, #cmds.var do
						if cmds.var[vr][1] == number and u8:decode(cmds.var[vr][2]) == u8:decode(v[3]) then
						bool[#bool] = false end break
					end
				elseif v[1] == 7 then
					local number = tonumber(string.match(v[2], '%d+'))
					table.remove(bool, #bool)
				elseif v[1] == 8 then
					table.insert(bool, true)
					for m = 1, #dialogs do
						if dialogs[m][1] == tonumber(v[2]) then
							if dialogs[m][2] == tonumber(v[3]) then
								bool[#bool] = false
								break
							end
						end
					end
				elseif v[1] == 9 then
					table.remove(bool, #bool)
				end
			else
				if v[1] == 7 or v[1] == 9 then
					table.remove(bool, #bool)
				elseif v[1] == 8 or v[1] == 6 then
					table.insert(bool, true)
				end
			end
		end
		new_notice('off')
	end)
end

function tag_act(tick_tag)
	tick_tag = u8:decode(tick_tag)
	if tick_tag:find('%b{}') then
		local tabl_check = {}
		for match in tick_tag:gmatch('%b{}') do
		   table.insert(tabl_check, match:sub(2, -2))
		end
		
		for t = 1, #tabl_check do
			if tick_tag:find('{mynick}') then tick_tag = tick_tag:gsub('{mynick}', tostring(sampGetPlayerNickname(my.id):gsub('_', ' ')))
			elseif tick_tag:find('{mynickrus}') then tick_tag = tick_tag:gsub('{mynickrus}', tostring(u8:decode(setting.nick)))
			elseif tick_tag:find('{myrank}') then tick_tag = tick_tag:gsub('{myrank}', tostring(u8:decode(setting.frac.title)))
			elseif tick_tag:find('{myid}') then tick_tag = tick_tag:gsub('{myid}', tostring(my.id))
			elseif tick_tag:find('{time}') then tick_tag = tick_tag:gsub('{time}', tostring(os.date('%X')))
			elseif tick_tag:find('{day}') then tick_tag = tick_tag:gsub('{day}', tostring(tonumber(os.date('%d'))))
			elseif tick_tag:find('{week}') then tick_tag = tick_tag:gsub('{week}', tostring(week[tonumber(os.date('%w'))]))
			elseif tick_tag:find('{month}') then tick_tag = tick_tag:gsub('{month}', tostring(month[tonumber(os.date('%m'))]))
			elseif tick_tag:find('{getplnick(%[(%d+)%])}') then
				local num_id = string.match(tick_tag, '{getplnick%[(.-)%]}')
				if sampIsPlayerConnected(tonumber(num_id)) then
					tick_tag = tick_tag:gsub('{getplnick%['.. num_id ..'%]}', tostring(sampGetPlayerNickname(tonumber(num_id))):gsub('_', ' '))
				else
					tick_tag = tick_tag:gsub('{getplnick%['.. num_id ..'%]}', u8'�����������')
					sampAddChatMessage(script_tag..'{FF5345}[����������� ������] {FFFFFF}�������� {getplnick} �� ��������� ������.', color_tag)
				end
			elseif tick_tag:find('{get_ru_nick%[(%d+)%]}') then
                local num_id = string.match(tick_tag, '{get_ru_nick%[(.-)%]}')
                if sampIsPlayerConnected(tonumber(num_id)) then
                    local getnick = sampGetPlayerNickname(tonumber(num_id)):gsub('_', ' ')
                    tick_tag = tick_tag:gsub('{get_ru_nick%['.. num_id ..'%]}', RusNick(getnick))
                else
                    tick_tag = tick_tag:gsub('{get_ru_nick%['.. num_id ..'%]}', u8'�����������')
                    sampAddChatMessage(script_tag..'{FF5345}[����������� ������] {FFFFFF}�������� {get_ru_nick} �� ��������� ������.', color_tag)
                end
			elseif tick_tag:find('{copy_nick%[(%d+)%]}') then
				local num_id = string.match(tick_tag, '{copy_nick%[(.-)%]}')
				if sampIsPlayerConnected(tonumber(num_id)) then
					local nickname = sampGetPlayerNickname(tonumber(num_id))
					setClipboardText(nickname)
					tick_tag = tick_tag:gsub('{copy_nick%['.. num_id ..'%]}', '')
				else
					tick_tag = tick_tag:gsub('{copy_nick%['.. num_id ..'%]}', '')
				end
			elseif tick_tag:find('{city}') then 
				tick_tag = tick_tag:gsub('{city}', 
					({
						[0] = "��� ������",
						[1] = "���-������",
						[2] = "���-������",
						[3] = "���-��������"
					})[getCityPlayerIsIn(PLAYER_PED)] or "����������� �����"
				)
			elseif tick_tag:find('{area}') then 
				tick_tag = tick_tag:gsub('{area}', area())
			elseif tick_tag:find('{nearest}') then
				tick_tag = tick_tag:gsub('{nearest}', nearest(60))
			elseif tick_tag:find('{target}') then tick_tag = tick_tag:gsub('{target}', tostring(targ_id))
			elseif tick_tag:find('{med7}') then tick_tag = tick_tag:gsub('{med7}', tostring(setting.price.mede[1]))
			elseif tick_tag:find('{med14}') then tick_tag = tick_tag:gsub('{med14}', tostring(setting.price.mede[2]))
			elseif tick_tag:find('{med30}') then tick_tag = tick_tag:gsub('{med30}', tostring(setting.price.mede[3]))
			elseif tick_tag:find('{med60}') then tick_tag = tick_tag:gsub('{med60}', tostring(setting.price.mede[4]))
			elseif tick_tag:find('{medup7}') then tick_tag = tick_tag:gsub('{medup7}', tostring(setting.price.upmede[1]))
			elseif tick_tag:find('{medup14}') then tick_tag = tick_tag:gsub('{medup14}', tostring(setting.price.upmede[2]))
			elseif tick_tag:find('{medup30}') then tick_tag = tick_tag:gsub('{medup30}', tostring(setting.price.upmede[3]))
			elseif tick_tag:find('{medup60}') then tick_tag = tick_tag:gsub('{medup60}', tostring(setting.price.upmede[4]))
			elseif tick_tag:find('{pricenarko}') then tick_tag = tick_tag:gsub('{pricenarko}', tostring(setting.price.narko))
			elseif tick_tag:find('{pricerecept}') then tick_tag = tick_tag:gsub('{pricerecept}', tostring(setting.price.rec))
			elseif tick_tag:find('{pricetatu}') then tick_tag = tick_tag:gsub('{pricetatu}', tostring(setting.price.tatu))
			elseif tick_tag:find('{priceant}') then tick_tag = tick_tag:gsub('{priceant}', tostring(setting.price.ant))
			elseif tick_tag:find('{pricelec}') then tick_tag = tick_tag:gsub('{pricelec}', tostring(setting.price.lec))
			elseif tick_tag:find('{priceosm}') then tick_tag = tick_tag:gsub('{priceosm}', tostring(setting.priceosm))
			
			elseif tick_tag:find('{priceauto1}') then tick_tag = tick_tag:gsub('{priceauto1}', tostring(setting.price_list_cl.auto[1]))
			elseif tick_tag:find('{priceauto2}') then tick_tag = tick_tag:gsub('{priceauto2}', tostring(setting.price_list_cl.auto[2]))
			elseif tick_tag:find('{priceauto3}') then tick_tag = tick_tag:gsub('{priceauto3}', tostring(setting.price_list_cl.auto[3]))
			elseif tick_tag:find('{pricemoto1}') then tick_tag = tick_tag:gsub('{pricemoto1}', tostring(setting.price_list_cl.moto[1]))
			elseif tick_tag:find('{pricemoto2}') then tick_tag = tick_tag:gsub('{pricemoto2}', tostring(setting.price_list_cl.moto[2]))
			elseif tick_tag:find('{pricemoto3}') then tick_tag = tick_tag:gsub('{pricemoto3}', tostring(setting.price_list_cl.moto[3]))
			elseif tick_tag:find('{pricefly}') then tick_tag = tick_tag:gsub('{pricefly}', tostring(setting.price_list_cl.fly[1]))
			elseif tick_tag:find('{pricefish1}') then tick_tag = tick_tag:gsub('{pricefish1}', tostring(setting.price_list_cl.fish[1]))
			elseif tick_tag:find('{pricefish2}') then tick_tag = tick_tag:gsub('{pricefish2}', tostring(setting.price_list_cl.fish[2]))
			elseif tick_tag:find('{pricefish3}') then tick_tag = tick_tag:gsub('{pricefish3}', tostring(setting.price_list_cl.fish[3]))
			elseif tick_tag:find('{priceswim1}') then tick_tag = tick_tag:gsub('{priceswim1}', tostring(setting.price_list_cl.swim[1]))
			elseif tick_tag:find('{priceswim2}') then tick_tag = tick_tag:gsub('{priceswim2}', tostring(setting.price_list_cl.swim[2]))
			elseif tick_tag:find('{priceswim3}') then tick_tag = tick_tag:gsub('{priceswim3}', tostring(setting.price_list_cl.swim[3]))
			elseif tick_tag:find('{pricegun1}') then tick_tag = tick_tag:gsub('{pricegun1}', tostring(setting.price_list_cl.gun[1]))
			elseif tick_tag:find('{pricegun2}') then tick_tag = tick_tag:gsub('{pricegun2}', tostring(setting.price_list_cl.gun[2]))
			elseif tick_tag:find('{pricegun3}') then tick_tag = tick_tag:gsub('{pricegun3}', tostring(setting.price_list_cl.gun[3]))
			elseif tick_tag:find('{pricehunt1}') then tick_tag = tick_tag:gsub('{pricehunt1}', tostring(setting.price_list_cl.hunt[1]))
			elseif tick_tag:find('{pricehunt2}') then tick_tag = tick_tag:gsub('{pricehunt2}', tostring(setting.price_list_cl.hunt[2]))
			elseif tick_tag:find('{pricehunt3}') then tick_tag = tick_tag:gsub('{pricehunt3}', tostring(setting.price_list_cl.hunt[3]))
			elseif tick_tag:find('{priceexc1}') then tick_tag = tick_tag:gsub('{priceexc1}', tostring(setting.price_list_cl.exc[1]))
			elseif tick_tag:find('{priceexc2}') then tick_tag = tick_tag:gsub('{priceexc2}', tostring(setting.price_list_cl.exc[2]))
			elseif tick_tag:find('{priceexc3}') then tick_tag = tick_tag:gsub('{priceexc3}', tostring(setting.price_list_cl.exc[3]))
			elseif tick_tag:find('{pricetaxi1}') then tick_tag = tick_tag:gsub('{pricetaxi1}', tostring(setting.price_list_cl.taxi[1]))
			elseif tick_tag:find('{pricetaxi2}') then tick_tag = tick_tag:gsub('{pricetaxi2}', tostring(setting.price_list_cl.taxi[2]))
			elseif tick_tag:find('{pricetaxi3}') then tick_tag = tick_tag:gsub('{pricetaxi3}', tostring(setting.price_list_cl.taxi[3]))
			elseif tick_tag:find('{pricemeh1}') then tick_tag = tick_tag:gsub('{pricemeh1}', tostring(setting.price_list_cl.meh[1]))
			elseif tick_tag:find('{pricemeh2}') then tick_tag = tick_tag:gsub('{pricemeh2}', tostring(setting.price_list_cl.meh[2]))
			elseif tick_tag:find('{pricemeh3}') then tick_tag = tick_tag:gsub('{pricemeh3}', tostring(setting.price_list_cl.meh[3]))
			
			
			elseif tick_tag:find('{sex:[%w%s�-��-�]*,[%w%s�-��-�]*}') then	
				for v in tick_tag:gmatch('{sex:[%w%s�-��-�]*,[%w%s�-��-�]*}') do
					local m, w = v:match('{sex:([%w%s�-��-�]*),([%w%s�-��-�]*)}')
					if setting.sex == u8'�������' then
						tick_tag = tick_tag:gsub(v, m)
					else
						tick_tag = tick_tag:gsub(v, w)
					end
				end
			end
		end
	end
	
	return u8(tick_tag)
end

function RusNick(name)
    if name:match('%a+') then
        local replacements = {
            ['A'] = '�', ['B'] = '�', ['C'] = '�', ['D'] = '�', ['E'] = '�', 
            ['F'] = '�', ['G'] = '�', ['H'] = '�', ['I'] = '�', ['J'] = '��', 
            ['K'] = '�', ['L'] = '�', ['M'] = '�', ['N'] = '�', ['O'] = '�', 
            ['P'] = '�', ['Q'] = '�', ['R'] = '�', ['S'] = '�', ['T'] = '�', 
            ['U'] = '�', ['V'] = '�', ['W'] = '�', ['X'] = '��', ['Y'] = '�', 
            ['Z'] = '�', ['a'] = '�', ['b'] = '�', ['c'] = '�', ['d'] = '�', 
            ['e'] = '�', ['f'] = '�', ['g'] = '�', ['h'] = '�', ['i'] = '�', 
            ['j'] = '�', ['k'] = '�', ['l'] = '�', ['m'] = '�', ['n'] = '�', 
            ['o'] = '�', ['p'] = '�', ['q'] = '�', ['r'] = '�', ['s'] = '�', 
            ['t'] = '�', ['u'] = '�', ['v'] = '�', ['w'] = '�', ['x'] = 'x', 
            ['y'] = '�', ['z'] = '�', ['_'] = ' ', ['`'] = '�', ['``'] = '�'
        }
        local multi_replacements = {
            ['ph'] = '�', ['Ph'] = '�', ['Ch'] = '�', ['ch'] = '�', ['Th'] = '�', 
            ['th'] = '�', ['Sh'] = '�', ['sh'] = '�', ['ea'] = '�', ['Ae'] = '�', 
            ['ae'] = '�', ['size'] = '����', ['Jj'] = '��������', ['Whi'] = '���', 
            ['lack'] = '���', ['whi'] = '���', ['Kh'] = '�', ['kh'] = '�', 
            ['hn'] = '�', ['Hen'] = '���', ['Zh'] = '�', ['zh'] = '�', 
            ['Yu'] = '�', ['yu'] = '�', ['Yo'] = '�', ['yo'] = '�', 
            ['Cz'] = '�', ['cz'] = '�', ['ia'] = '�', ['Ya'] = '�', 
            ['ya'] = '�', ['ove'] = '��', ['ay'] = '��', ['rise'] = '����', 
            ['oo'] = '�', ['Oo'] = '�', ['Ee'] = '�', ['ee'] = '�', 
            ['Un'] = '��', ['un'] = '��', ['Ci'] = '��', ['ci'] = '��', 
            ['yse'] = '��', ['cate'] = '����', ['eow'] = '��', 
            ['rown'] = '����', ['yev'] = '���', ['Babe'] = '�����', 
            ['Jason'] = '�������', ['liy'] = '���', ['ane'] = '���', 
            ['ame'] = '���'
        }
        for k, v in pairs(multi_replacements) do
            name = name:gsub(k, v)
        end
        for k, v in pairs(replacements) do
            name = name:gsub(k, v)
        end

        return name
    end
    return name
end

function nearest(radius)
    local myPed = playerPed
    local myX, myY, myZ = getCharCoordinates(myPed)
    local nearestPlayerId = -1
    local nearestDist = radius
    
    for i = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(i) and i ~= my.id then
            local result, playerPed = sampGetCharHandleBySampPlayerId(i)
            if result then
                local x, y, z = getCharCoordinates(playerPed)
                local dist = getDistanceBetweenCoords3d(myX, myY, myZ, x, y, z)
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayerId = i
                end
            end
        end
    end
    
    if nearestPlayerId == -1 then
        sampAddChatMessage(script_tag .. '{FFFFFF}���� ������� �������!', color_tag)
        return "��� ���������"
    else
        return tostring(nearestPlayerId)
    end
end

function area()
    local x, y, z = getCharCoordinates(PLAYER_PED)
    return get_area(x, y, z)
end

function get_area(x, y, z)
    local closest_area, min_distance = nil, math.huge
    local zones = {
        {name = "���� ������", x1 = -2667.810, y1 = -302.135, z1 = -28.831, x2 = -2646.400, y2 = -262.320, z2 = 71.169},
        {name = "��������", x1 = -1315.420, y1 = -405.388, z1 = 15.406, x2 = -1264.400, y2 = -209.543, z2 = 25.406},
        {name = "������", x1 = -2395.140, y1 = -222.589, z1 = -5.3, x2 = -2354.090, y2 = -204.792, z2 = 200.000},
        {name = "�����-�����", x1 = -1632.830, y1 = -2263.440, z1 = -3.0, x2 = -1601.330, y2 = -2231.790, z2 = 200.000},
        {name = "��������� ��", x1 = 2381.680, y1 = -1494.030, z1 = -89.084, x2 = 2421.030, y2 = -1454.350, z2 = 110.916},
        {name = "�������� ����", x1 = 1236.630, y1 = 1163.410, z1 = -89.084, x2 = 1277.050, y2 = 1203.280, z2 = 110.916},
        {name = "����������� ��������", x1 = 1277.050, y1 = 1044.690, z1 = -89.084, x2 = 1315.350, y2 = 1087.630, z2 = 110.916},
        {name = "�����", x1 = 1252.330, y1 = -926.999, z1 = -89.084, x2 = 1357.000, y2 = -910.170, z2 = 110.916},
        {name = "������� �����", x1 = 1692.620, y1 = -1971.800, z1 = -20.492, x2 = 1812.620, y2 = -1932.800, z2 = 79.508},
        {name = "�������� ���� ��", x1 = 1315.350, y1 = 1044.690, z1 = -89.084, x2 = 1375.600, y2 = 1087.630, z2 = 110.916},
        {name = "���-������", x1 = 2581.730, y1 = -1454.350, z1 = -89.084, x2 = 2632.830, y2 = -1393.420, z2 = 110.916},
        {name = "������", x1 = 2437.390, y1 = 1858.100, z1 = -39.084, x2 = 2495.090, y2 = 1970.850, z2 = 60.916},
		{name = "�������� �����-���", x1 = -1132.820, y1 = -787.391, z1 = 0.000, x2 = -956.476, y2 = -768.027, z2 = 200.000},
		{name = "������� �����", x1 = 1370.850, y1 = -1170.870, z1 = -89.084, x2 = 1463.900, y2 = -1130.850, z2 = 110.916},
		{name = "��������� ���������", x1 = -1620.300, y1 = 1176.520, z1 = -4.5, x2 = -1580.010, y2 = 1274.260, z2 = 200.000},
		{name = "������� ������", x1 = 787.461, y1 = -1410.930, z1 = -34.126, x2 = 866.009, y2 = -1310.210, z2 = 65.874},
		{name = "������� ������", x1 = 2811.250, y1 = 1229.590, z1 = -39.594, x2 = 2861.250, y2 = 1407.590, z2 = 60.406},
		{name = "����������� ����������", x1 = 1582.440, y1 = 347.457, z1 = 0.000, x2 = 1664.620, y2 = 401.750, z2 = 200.000},
		{name = "���� ��������", x1 = 2759.250, y1 = 296.501, z1 = 0.000, x2 = 2774.250, y2 = 594.757, z2 = 200.000},
		{name = "������� ������-����", x1 = 1377.480, y1 = 2600.430, z1 = -21.926, x2 = 1492.450, y2 = 2687.360, z2 = 78.074},
		{name = "������� �����", x1 = 1507.510, y1 = -1385.210, z1 = 110.916, x2 = 1582.550, y2 = -1325.310, z2 = 335.916},
		{name = "����������", x1 = 2185.330, y1 = -1210.740, z1 = -89.084, x2 = 2281.450, y2 = -1154.590, z2 = 110.916},
		{name = "����������", x1 = 1318.130, y1 = -910.170, z1 = -89.084, x2 = 1357.000, y2 = -768.027, z2 = 110.916},
		{name = "���� ������", x1 = -2361.510, y1 = -417.199, z1 = 0.000, x2 = -2270.040, y2 = -355.493, z2 = 200.000},
		{name = "����������", x1 = 1996.910, y1 = -1449.670, z1 = -89.084, x2 = 2056.860, y2 = -1350.720, z2 = 110.916},
		{name = "�������� �����", x1 = 1236.630, y1 = 2142.860, z1 = -89.084, x2 = 1297.470, y2 = 2243.230, z2 = 110.916},
		{name = "����������", x1 = 2124.660, y1 = -1494.030, z1 = -89.084, x2 = 2266.210, y2 = -1449.670, z2 = 110.916},
		{name = "�������� �����", x1 = 1848.400, y1 = 2478.490, z1 = -89.084, x2 = 1938.800, y2 = 2553.490, z2 = 110.916},
		{name = "�����", x1 = 422.680, y1 = -1570.200, z1 = -89.084, x2 = 466.223, y2 = -1406.050, z2 = 110.916},
		{name = "������� ���������", x1 = -2007.830, y1 = 56.306, z1 = 0.000, x2 = -1922.000, y2 = 224.782, z2 = 100.000},
		{name = "������� �����", x1 = 1391.050, y1 = -1026.330, z1 = -89.084, x2 = 1463.900, y2 = -926.999, z2 = 110.916},
		{name = "�������� ��������", x1 = 1704.590, y1 = 2243.230, z1 = -89.084, x2 = 1777.390, y2 = 2342.830, z2 = 110.916},
		{name = "��������� �������", x1 = 1758.900, y1 = -1722.260, z1 = -89.084, x2 = 1812.620, y2 = -1577.590, z2 = 110.916},
		{name = "����������� ��������", x1 = 1375.600, y1 = 823.228, z1 = -89.084, x2 = 1457.390, y2 = 919.447, z2 = 110.916},
		{name = "��������", x1 = 1974.630, y1 = -2394.330, z1 = -39.084, x2 = 2089.000, y2 = -2256.590, z2 = 60.916},
		{name = "�����-����", x1 = -399.633, y1 = -1075.520, z1 = -1.489, x2 = -319.033, y2 = -977.516, z2 = 198.511},
		{name = "�����", x1 = 334.503, y1 = -1501.950, z1 = -89.084, x2 = 422.680, y2 = -1406.050, z2 = 110.916},
		{name = "������", x1 = 225.165, y1 = -1369.620, z1 = -89.084, x2 = 334.503, y2 = -1292.070, z2 = 110.916},
		{name = "������� �����", x1 = 1724.760, y1 = -1250.900, z1 = -89.084, x2 = 1812.620, y2 = -1150.870, z2 = 110.916},
		{name = "�����-����", x1 = 2027.400, y1 = 1703.230, z1 = -89.084, x2 = 2137.400, y2 = 1783.230, z2 = 110.916},
		{name = "������� �����", x1 = 1378.330, y1 = -1130.850, z1 = -89.084, x2 = 1463.900, y2 = -1026.330, z2 = 110.916},
		{name = "����������� ��������", x1 = 1197.390, y1 = 1044.690, z1 = -89.084, x2 = 1277.050, y2 = 1163.390, z2 = 110.916},
		{name = "��������� �����", x1 = 1073.220, y1 = -1842.270, z1 = -89.084, x2 = 1323.900, y2 = -1804.210, z2 = 110.916},
		{name = "����������", x1 = 1451.400, y1 = 347.457, z1 = -6.1, x2 = 1582.440, y2 = 420.802, z2 = 200.000},
		{name = "������ ������", x1 = -2270.040, y1 = -430.276, z1 = -1.2, x2 = -2178.690, y2 = -324.114, z2 = 200.000},
		{name = "������� ��������", x1 = 1325.600, y1 = 596.349, z1 = -89.084, x2 = 1375.600, y2 = 795.010, z2 = 110.916},
		{name = "��������", x1 = 2051.630, y1 = -2597.260, z1 = -39.084, x2 = 2152.450, y2 = -2394.330, z2 = 60.916},
		{name = "����������", x1 = 1096.470, y1 = -910.170, z1 = -89.084, x2 = 1169.130, y2 = -768.027, z2 = 110.916},
		{name = "���� ��� ������", x1 = 1457.460, y1 = 2723.230, z1 = -89.084, x2 = 1534.560, y2 = 2863.230, z2 = 110.916},
		{name = "�����", x1 = 2027.400, y1 = 1783.230, z1 = -89.084, x2 = 2162.390, y2 = 1863.230, z2 = 110.916},
		{name = "����������", x1 = 2056.860, y1 = -1210.740, z1 = -89.084, x2 = 2185.330, y2 = -1126.320, z2 = 110.916},
		{name = "����������", x1 = 952.604, y1 = -937.184, z1 = -89.084, x2 = 1096.470, y2 = -860.619, z2 = 110.916},
		{name = "������-��������", x1 = -1372.140, y1 = 2498.520, z1 = 0.000, x2 = -1277.590, y2 = 2615.350, z2 = 200.000},
		{name = "���-�������", x1 = 2126.860, y1 = -1126.320, z1 = -89.084, x2 = 2185.330, y2 = -934.489, z2 = 110.916},
		{name = "���-�������", x1 = 1994.330, y1 = -1100.820, z1 = -89.084, x2 = 2056.860, y2 = -920.815, z2 = 110.916},
		{name = "������", x1 = 647.557, y1 = -954.662, z1 = -89.084, x2 = 768.694, y2 = -860.619, z2 = 110.916},
		{name = "�������� ����", x1 = 1277.050, y1 = 1087.630, z1 = -89.084, x2 = 1375.600, y2 = 1203.280, z2 = 110.916},
		{name = "�������� �����", x1 = 1377.390, y1 = 2433.230, z1 = -89.084, x2 = 1534.560, y2 = 2507.230, z2 = 110.916},
		{name = "����������", x1 = 2201.820, y1 = -2095.000, z1 = -89.084, x2 = 2324.000, y2 = -1989.900, z2 = 110.916},
		{name = "�������� �����", x1 = 1704.590, y1 = 2342.830, z1 = -89.084, x2 = 1848.400, y2 = 2433.230, z2 = 110.916},
		{name = "�����", x1 = 1252.330, y1 = -1130.850, z1 = -89.084, x2 = 1378.330, y2 = -1026.330, z2 = 110.916},
		{name = "��������� �������", x1 = 1701.900, y1 = -1842.270, z1 = -89.084, x2 = 1812.620, y2 = -1722.260, z2 = 110.916},
		{name = "�����", x1 = -2411.220, y1 = 373.539, z1 = 0.000, x2 = -2253.540, y2 = 458.411, z2 = 200.000},
		{name = "��������", x1 = 1515.810, y1 = 1586.400, z1 = -12.500, x2 = 1729.950, y2 = 1714.560, z2 = 87.500},
		{name = "������", x1 = 225.165, y1 = -1292.070, z1 = -89.084, x2 = 466.223, y2 = -1235.070, z2 = 110.916},
		{name = "�����", x1 = 1252.330, y1 = -1026.330, z1 = -89.084, x2 = 1391.050, y2 = -926.999, z2 = 110.916},
		{name = "��������� ��", x1 = 2266.260, y1 = -1494.030, z1 = -89.084, x2 = 2381.680, y2 = -1372.040, z2 = 110.916},
		{name = "���������� �����", x1 = 2623.180, y1 = 943.235, z1 = -89.084, x2 = 2749.900, y2 = 1055.960, z2 = 110.916},
		{name = "����������", x1 = 2541.700, y1 = -1941.400, z1 = -89.084, x2 = 2703.580, y2 = -1852.870, z2 = 110.916},
		{name = "���-�������", x1 = 2056.860, y1 = -1126.320, z1 = -89.084, x2 = 2126.860, y2 = -920.815, z2 = 110.916},
		{name = "���������� �����", x1 = 2625.160, y1 = 2202.760, z1 = -89.084, x2 = 2685.160, y2 = 2442.550, z2 = 110.916},
		{name = "�����", x1 = 225.165, y1 = -1501.950, z1 = -89.084, x2 = 334.503, y2 = -1369.620, z2 = 110.916},
		{name = "���-������", x1 = -365.167, y1 = 2123.010, z1 = -3.0, x2 = -208.570, y2 = 2217.680, z2 = 200.000},
		{name = "���������� �����", x1 = 2536.430, y1 = 2442.550, z1 = -89.084, x2 = 2685.160, y2 = 2542.550, z2 = 110.916},
		{name = "�����", x1 = 334.503, y1 = -1406.050, z1 = -89.084, x2 = 466.223, y2 = -1292.070, z2 = 110.916},
		{name = "�������", x1 = 647.557, y1 = -1227.280, z1 = -89.084, x2 = 787.461, y2 = -1118.280, z2 = 110.916},
		{name = "�����", x1 = 422.680, y1 = -1684.650, z1 = -89.084, x2 = 558.099, y2 = -1570.200, z2 = 110.916},
		{name = "�������� �����", x1 = 2498.210, y1 = 2542.550, z1 = -89.084, x2 = 2685.160, y2 = 2626.550, z2 = 110.916},
		{name = "������� �����", x1 = 1724.760, y1 = -1430.870, z1 = -89.084, x2 = 1812.620, y2 = -1250.900, z2 = 110.916},
		{name = "�����", x1 = 225.165, y1 = -1684.650, z1 = -89.084, x2 = 312.803, y2 = -1501.950, z2 = 110.916},
		{name = "����������", x1 = 2056.860, y1 = -1449.670, z1 = -89.084, x2 = 2266.210, y2 = -1372.040, z2 = 110.916},
		{name = "�������-�����", x1 = 603.035, y1 = 264.312, z1 = 0.000, x2 = 761.994, y2 = 366.572, z2 = 200.000},
		{name = "�����", x1 = 1096.470, y1 = -1130.840, z1 = -89.084, x2 = 1252.330, y2 = -1026.330, z2 = 110.916},
		{name = "���� �������", x1 = -1087.930, y1 = 855.370, z1 = -89.084, x2 = -961.950, y2 = 986.281, z2 = 110.916},
		{name = "���� ������", x1 = 1046.150, y1 = -1722.260, z1 = -89.084, x2 = 1161.520, y2 = -1577.590, z2 = 110.916},
		{name = "������������ �����", x1 = 1323.900, y1 = -1722.260, z1 = -89.084, x2 = 1440.900, y2 = -1577.590, z2 = 110.916},
		{name = "����������", x1 = 1357.000, y1 = -926.999, z1 = -89.084, x2 = 1463.900, y2 = -768.027, z2 = 110.916},
		{name = "�����", x1 = 466.223, y1 = -1570.200, z1 = -89.084, x2 = 558.099, y2 = -1385.070, z2 = 110.916},
		{name = "����������", x1 = 911.802, y1 = -860.619, z1 = -89.084, x2 = 1096.470, y2 = -768.027, z2 = 110.916},
		{name = "����������", x1 = 768.694, y1 = -954.662, z1 = -89.084, x2 = 952.604, y2 = -860.619, z2 = 110.916},
		{name = "����� �����", x1 = 2377.390, y1 = 788.894, z1 = -89.084, x2 = 2537.390, y2 = 897.901, z2 = 110.916},
		{name = "�������", x1 = 1812.620, y1 = -1852.870, z1 = -89.084, x2 = 1971.660, y2 = -1742.310, z2 = 110.916},
		{name = "��������� ����", x1 = 2089.000, y1 = -2394.330, z1 = -89.084, x2 = 2201.820, y2 = -2235.840, z2 = 110.916},
		{name = "������������ �����", x1 = 1370.850, y1 = -1577.590, z1 = -89.084, x2 = 1463.900, y2 = -1384.950, z2 = 110.916},
		{name = "�������� �����", x1 = 2121.400, y1 = 2508.230, z1 = -89.084, x2 = 2237.400, y2 = 2663.170, z2 = 110.916},
		{name = "�����", x1 = 1096.470, y1 = -1026.330, z1 = -89.084, x2 = 1252.330, y2 = -910.170, z2 = 110.916},
		{name = "���� ����", x1 = 1812.620, y1 = -1449.670, z1 = -89.084, x2 = 1996.910, y2 = -1350.720, z2 = 110.916},
		{name = "�������� �����-���", x1 = -1242.980, y1 = -50.096, z1 = 0.000, x2 = -1213.910, y2 = 578.396, z2 = 200.000},
		{name = "���� ������", x1 = -222.179, y1 = 293.324, z1 = 0.000, x2 = -122.126, y2 = 476.465, z2 = 200.000},
		{name = "�����", x1 = 2106.700, y1 = 1863.230, z1 = -89.084, x2 = 2162.390, y2 = 2202.760, z2 = 110.916},
		{name = "����������", x1 = 2541.700, y1 = -2059.230, z1 = -89.084, x2 = 2703.580, y2 = -1941.400, z2 = 110.916},
		{name = "����� ������", x1 = 807.922, y1 = -1577.590, z1 = -89.084, x2 = 926.922, y2 = -1416.250, z2 = 110.916},
		{name = "��������", x1 = 1457.370, y1 = 1143.210, z1 = -89.084, x2 = 1777.400, y2 = 1203.280, z2 = 110.916},
		{name = "�������", x1 = 1812.620, y1 = -1742.310, z1 = -89.084, x2 = 1951.660, y2 = -1602.310, z2 = 110.916},
		{name = "��������� ���������", x1 = -1580.010, y1 = 1025.980, z1 = -6.1, x2 = -1499.890, y2 = 1274.260, z2 = 200.000},
		{name = "������� �����", x1 = 1370.850, y1 = -1384.950, z1 = -89.084, x2 = 1463.900, y2 = -1170.870, z2 = 110.916},
		{name = "���� ����", x1 = 1664.620, y1 = 401.750, z1 = 0.000, x2 = 1785.140, y2 = 567.203, z2 = 200.000},
		{name = "�����", x1 = 312.803, y1 = -1684.650, z1 = -89.084, x2 = 422.680, y2 = -1501.950, z2 = 110.916},
		{name = "������� �������", x1 = 1440.900, y1 = -1722.260, z1 = -89.084, x2 = 1583.500, y2 = -1577.590, z2 = 110.916},
		{name = "����������", x1 = 687.802, y1 = -860.619, z1 = -89.084, x2 = 911.802, y2 = -768.027, z2 = 110.916},
		{name = "���� ����", x1 = -2741.070, y1 = 1490.470, z1 = -6.1, x2 = -2616.400, y2 = 1659.680, z2 = 200.000},
		{name = "���-�������", x1 = 2185.330, y1 = -1154.590, z1 = -89.084, x2 = 2281.450, y2 = -934.489, z2 = 110.916},
		{name = "����������", x1 = 1169.130, y1 = -910.170, z1 = -89.084, x2 = 1318.130, y2 = -768.027, z2 = 110.916},
		{name = "�������� �����", x1 = 1938.800, y1 = 2508.230, z1 = -89.084, x2 = 2121.400, y2 = 2624.230, z2 = 110.916},
		{name = "������������ �����", x1 = 1667.960, y1 = -1577.590, z1 = -89.084, x2 = 1812.620, y2 = -1430.870, z2 = 110.916},
		{name = "�����", x1 = 72.648, y1 = -1544.170, z1 = -89.084, x2 = 225.165, y2 = -1404.970, z2 = 110.916},
		{name = "����-���������", x1 = 2536.430, y1 = 2202.760, z1 = -89.084, x2 = 2625.160, y2 = 2442.550, z2 = 110.916},
		{name = "�����", x1 = 72.648, y1 = -1684.650, z1 = -89.084, x2 = 225.165, y2 = -1544.170, z2 = 110.916},
		{name = "����������� �����", x1 = 952.663, y1 = -1310.210, z1 = -89.084, x2 = 1072.660, y2 = -1130.850, z2 = 110.916},
		{name = "���-�������", x1 = 2632.740, y1 = -1135.040, z1 = -89.084, x2 = 2747.740, y2 = -945.035, z2 = 110.916},
		{name = "����������", x1 = 861.085, y1 = -674.885, z1 = -89.084, x2 = 1156.550, y2 = -600.896, z2 = 110.916},
		{name = "�����", x1 = -2253.540, y1 = 373.539, z1 = -9.1, x2 = -1993.280, y2 = 458.411, z2 = 200.000},
		{name = "��������� ��������", x1 = 1848.400, y1 = 2342.830, z1 = -89.084, x2 = 2011.940, y2 = 2478.490, z2 = 110.916},
		{name = "������� �����", x1 = -1580.010, y1 = 744.267, z1 = -6.1, x2 = -1499.890, y2 = 1025.980, z2 = 200.000},
		{name = "��������� �����", x1 = 1046.150, y1 = -1804.210, z1 = -89.084, x2 = 1323.900, y2 = -1722.260, z2 = 110.916},
		{name = "������", x1 = 647.557, y1 = -1118.280, z1 = -89.084, x2 = 787.461, y2 = -954.662, z2 = 110.916},
		{name = "�����-�����", x1 = -2994.490, y1 = 277.411, z1 = -9.1, x2 = -2867.850, y2 = 458.411, z2 = 200.000},
		{name = "������� ���������", x1 = 964.391, y1 = 930.890, z1 = -89.084, x2 = 1166.530, y2 = 1044.690, z2 = 110.916},
		{name = "���� ����", x1 = 1812.620, y1 = -1100.820, z1 = -89.084, x2 = 1994.330, y2 = -973.380, z2 = 110.916},
		{name = "�������� ����", x1 = 1375.600, y1 = 919.447, z1 = -89.084, x2 = 1457.370, y2 = 1203.280, z2 = 110.916},
		{name = "��������-���", x1 = -405.770, y1 = 1712.860, z1 = -3.0, x2 = -276.719, y2 = 1892.750, z2 = 200.000},
		{name = "���� ������", x1 = 1161.520, y1 = -1722.260, z1 = -89.084, x2 = 1323.900, y2 = -1577.590, z2 = 110.916},
		{name = "��������� ��", x1 = 2281.450, y1 = -1372.040, z1 = -89.084, x2 = 2381.680, y2 = -1135.040, z2 = 110.916},
		{name = "������ ��������", x1 = 2137.400, y1 = 1703.230, z1 = -89.084, x2 = 2437.390, y2 = 1783.230, z2 = 110.916},
		{name = "�������", x1 = 1951.660, y1 = -1742.310, z1 = -89.084, x2 = 2124.660, y2 = -1602.310, z2 = 110.916},
		{name = "��������", x1 = 2624.400, y1 = 1383.230, z1 = -89.084, x2 = 2685.160, y2 = 1783.230, z2 = 110.916},
		{name = "�������", x1 = 2124.660, y1 = -1742.310, z1 = -89.084, x2 = 2222.560, y2 = -1494.030, z2 = 110.916},
		{name = "�����", x1 = -2533.040, y1 = 458.411, z1 = 0.000, x2 = -2329.310, y2 = 578.396, z2 = 200.000},
		{name = "������� �����", x1 = -1871.720, y1 = 1176.420, z1 = -4.5, x2 = -1620.300, y2 = 1274.260, z2 = 200.000},
		{name = "������������ �����", x1 = 1583.500, y1 = -1722.260, z1 = -89.084, x2 = 1758.900, y2 = -1577.590, z2 = 110.916},
		{name = "��������� ��", x1 = 2381.680, y1 = -1454.350, z1 = -89.084, x2 = 2462.130, y2 = -1135.040, z2 = 110.916},
		{name = "����� ������", x1 = 647.712, y1 = -1577.590, z1 = -89.084, x2 = 807.922, y2 = -1416.250, z2 = 110.916},
		{name = "������", x1 = 72.648, y1 = -1404.970, z1 = -89.084, x2 = 225.165, y2 = -1235.070, z2 = 110.916},
		{name = "�������", x1 = 647.712, y1 = -1416.250, z1 = -89.084, x2 = 787.461, y2 = -1227.280, z2 = 110.916},
		{name = "��������� ��", x1 = 2222.560, y1 = -1628.530, z1 = -89.084, x2 = 2421.030, y2 = -1494.030, z2 = 110.916},
		{name = "�����", x1 = 558.099, y1 = -1684.650, z1 = -89.084, x2 = 647.522, y2 = -1384.930, z2 = 110.916},
		{name = "��������� �������", x1 = -1709.710, y1 = -833.034, z1 = -1.5, x2 = -1446.010, y2 = -730.118, z2 = 200.000},
		{name = "�����", x1 = 466.223, y1 = -1385.070, z1 = -89.084, x2 = 647.522, y2 = -1235.070, z2 = 110.916},
		{name = "��������� ��������", x1 = 1817.390, y1 = 2202.760, z1 = -89.084, x2 = 2011.940, y2 = 2342.830, z2 = 110.916},
		{name = "������", x1 = 2162.390, y1 = 1783.230, z1 = -89.084, x2 = 2437.390, y2 = 1883.230, z2 = 110.916},
		{name = "�������", x1 = 1971.660, y1 = -1852.870, z1 = -89.084, x2 = 2222.560, y2 = -1742.310, z2 = 110.916},
		{name = "����������� ����������", x1 = 1546.650, y1 = 208.164, z1 = 0.000, x2 = 1745.830, y2 = 347.457, z2 = 200.000},
		{name = "����������", x1 = 2089.000, y1 = -2235.840, z1 = -89.084, x2 = 2201.820, y2 = -1989.900, z2 = 110.916},
		{name = "�����", x1 = 952.663, y1 = -1130.840, z1 = -89.084, x2 = 1096.470, y2 = -937.184, z2 = 110.916},
		{name = "�����-����", x1 = 1848.400, y1 = 2553.490, z1 = -89.084, x2 = 1938.800, y2 = 2863.230, z2 = 110.916},
		{name = "��������", x1 = 1400.970, y1 = -2669.260, z1 = -39.084, x2 = 2189.820, y2 = -2597.260, z2 = 60.916},
		{name = "���� ������", x1 = -1213.910, y1 = 950.022, z1 = -89.084, x2 = -1087.930, y2 = 1178.930, z2 = 110.916},
		{name = "���� ������", x1 = -1339.890, y1 = 828.129, z1 = -89.084, x2 = -1213.910, y2 = 1057.040, z2 = 110.916},
		{name = "���� �������", x1 = -1339.890, y1 = 599.218, z1 = -89.084, x2 = -1213.910, y2 = 828.129, z2 = 110.916},
		{name = "���� �������", x1 = -1213.910, y1 = 721.111, z1 = -89.084, x2 = -1087.930, y2 = 950.022, z2 = 110.916},
		{name = "���� ������", x1 = 930.221, y1 = -2006.780, z1 = -89.084, x2 = 1073.220, y2 = -1804.210, z2 = 110.916},
		{name = "������������", x1 = 1073.220, y1 = -2006.780, z1 = -89.084, x2 = 1249.620, y2 = -1842.270, z2 = 110.916},
		{name = "���� �������", x1 = 787.461, y1 = -1130.840, z1 = -89.084, x2 = 952.604, y2 = -954.662, z2 = 110.916},
		{name = "���� �������", x1 = 787.461, y1 = -1310.210, z1 = -89.084, x2 = 952.663, y2 = -1130.840, z2 = 110.916},
		{name = "������������ �����", x1 = 1463.900, y1 = -1577.590, z1 = -89.084, x2 = 1667.960, y2 = -1430.870, z2 = 110.916},
		{name = "����������� �����", x1 = 787.461, y1 = -1416.250, z1 = -89.084, x2 = 1072.660, y2 = -1310.210, z2 = 110.916},
		{name = "�������� ������", x1 = 2377.390, y1 = 596.349, z1 = -89.084, x2 = 2537.390, y2 = 788.894, z2 = 110.916},
		{name = "�������� �����", x1 = 2237.400, y1 = 2542.550, z1 = -89.084, x2 = 2498.210, y2 = 2663.170, z2 = 110.916},
		{name = "��������� ����", x1 = 2632.830, y1 = -1668.130, z1 = -89.084, x2 = 2747.740, y2 = -1393.420, z2 = 110.916},
		{name = "���� ������", x1 = 434.341, y1 = 366.572, z1 = 0.000, x2 = 603.035, y2 = 555.680, z2 = 200.000},
		{name = "����������", x1 = 2089.000, y1 = -1989.900, z1 = -89.084, x2 = 2324.000, y2 = -1852.870, z2 = 110.916},
		{name = "���������", x1 = -2274.170, y1 = 578.396, z1 = -7.6, x2 = -2078.670, y2 = 744.170, z2 = 200.000},
		{name = "��������� ������", x1 = -208.570, y1 = 2337.180, z1 = 0.000, x2 = 8.430, y2 = 2487.180, z2 = 200.000},
		{name = "��������� ����", x1 = 2324.000, y1 = -2145.100, z1 = -89.084, x2 = 2703.580, y2 = -2059.230, z2 = 110.916},
		{name = "�������� �����-���", x1 = -1132.820, y1 = -768.027, z1 = 0.000, x2 = -956.476, y2 = -578.118, z2 = 200.000},
		{name = "������ �����", x1 = 1817.390, y1 = 1703.230, z1 = -89.084, x2 = 2027.400, y2 = 1863.230, z2 = 110.916},
		{name = "�����-�����", x1 = -2994.490, y1 = -430.276, z1 = -1.2, x2 = -2831.890, y2 = -222.589, z2 = 200.000},
		{name = "������", x1 = 321.356, y1 = -860.619, z1 = -89.084, x2 = 687.802, y2 = -768.027, z2 = 110.916},
		{name = "�������� ��������", x1 = 176.581, y1 = 1305.450, z1 = -3.0, x2 = 338.658, y2 = 1520.720, z2 = 200.000},
		{name = "������", x1 = 321.356, y1 = -768.027, z1 = -89.084, x2 = 700.794, y2 = -674.885, z2 = 110.916},
		{name = "������", x1 = 2162.390, y1 = 1883.230, z1 = -89.084, x2 = 2437.390, y2 = 2012.180, z2 = 110.916},
		{name = "��������� ����", x1 = 2747.740, y1 = -1668.130, z1 = -89.084, x2 = 2959.350, y2 = -1498.620, z2 = 110.916},
		{name = "����������", x1 = 2056.860, y1 = -1372.040, z1 = -89.084, x2 = 2281.450, y2 = -1210.740, z2 = 110.916},
		{name = "������� �����", x1 = 1463.900, y1 = -1290.870, z1 = -89.084, x2 = 1724.760, y2 = -1150.870, z2 = 110.916},
		{name = "������� �����", x1 = 1463.900, y1 = -1430.870, z1 = -89.084, x2 = 1724.760, y2 = -1290.870, z2 = 110.916},
		{name = "���� ������", x1 = -1499.890, y1 = 696.442, z1 = -179.615, x2 = -1339.890, y2 = 925.353, z2 = 20.385},
		{name = "����� �����", x1 = 1457.390, y1 = 823.228, z1 = -89.084, x2 = 2377.390, y2 = 863.229, z2 = 110.916},
		{name = "��������� ��", x1 = 2421.030, y1 = -1628.530, z1 = -89.084, x2 = 2632.830, y2 = -1454.350, z2 = 110.916},
		{name = "������� ���������", x1 = 964.391, y1 = 1044.690, z1 = -89.084, x2 = 1197.390, y2 = 1203.220, z2 = 110.916},
		{name = "���-�������", x1 = 2747.740, y1 = -1120.040, z1 = -89.084, x2 = 2959.350, y2 = -945.035, z2 = 110.916},
		{name = "����������", x1 = 737.573, y1 = -768.027, z1 = -89.084, x2 = 1142.290, y2 = -674.885, z2 = 110.916},
		{name = "��������� ����", x1 = 2201.820, y1 = -2730.880, z1 = -89.084, x2 = 2324.000, y2 = -2418.330, z2 = 110.916},
		{name = "��������� ��", x1 = 2462.130, y1 = -1454.350, z1 = -89.084, x2 = 2581.730, y2 = -1135.040, z2 = 110.916},
		{name = "������", x1 = 2222.560, y1 = -1722.330, z1 = -89.084, x2 = 2632.830, y2 = -1628.530, z2 = 110.916},
		{name = "���� ������", x1 = -2831.890, y1 = -430.276, z1 = -6.1, x2 = -2646.400, y2 = -222.589, z2 = 200.000},
		{name = "����������", x1 = 1970.620, y1 = -2179.250, z1 = -89.084, x2 = 2089.000, y2 = -1852.870, z2 = 110.916},
		{name = "�������� ���������", x1 = -1982.320, y1 = 1274.260, z1 = -4.5, x2 = -1524.240, y2 = 1358.900, z2 = 200.000},
		{name = "������ ���-������", x1 = 1817.390, y1 = 1283.230, z1 = -89.084, x2 = 2027.390, y2 = 1469.230, z2 = 110.916},
		{name = "��������� ����", x1 = 2201.820, y1 = -2418.330, z1 = -89.084, x2 = 2324.000, y2 = -2095.000, z2 = 110.916},
		{name = "������", x1 = 1823.080, y1 = 596.349, z1 = -89.084, x2 = 1997.220, y2 = 823.228, z2 = 110.916},
		{name = "��������-������", x1 = -2353.170, y1 = 2275.790, z1 = 0.000, x2 = -2153.170, y2 = 2475.790, z2 = 200.000},
		{name = "�����", x1 = -2329.310, y1 = 458.411, z1 = -7.6, x2 = -1993.280, y2 = 578.396, z2 = 200.000},
		{name = "���-������", x1 = 1692.620, y1 = -2179.250, z1 = -89.084, x2 = 1812.620, y2 = -1842.270, z2 = 110.916},
		{name = "������� ��������", x1 = 1375.600, y1 = 596.349, z1 = -89.084, x2 = 1558.090, y2 = 823.228, z2 = 110.916},
		{name = "������� ������", x1 = 1817.390, y1 = 1083.230, z1 = -89.084, x2 = 2027.390, y2 = 1283.230, z2 = 110.916},
		{name = "�������� �����", x1 = 1197.390, y1 = 1163.390, z1 = -89.084, x2 = 1236.630, y2 = 2243.230, z2 = 110.916},
		{name = "���-������", x1 = 2581.730, y1 = -1393.420, z1 = -89.084, x2 = 2747.740, y2 = -1135.040, z2 = 110.916},
		{name = "������ �����", x1 = 1817.390, y1 = 1863.230, z1 = -89.084, x2 = 2106.700, y2 = 2011.830, z2 = 110.916},
		{name = "�����-����", x1 = 1938.800, y1 = 2624.230, z1 = -89.084, x2 = 2121.400, y2 = 2861.550, z2 = 110.916},
		{name = "���� ������", x1 = 851.449, y1 = -1804.210, z1 = -89.084, x2 = 1046.150, y2 = -1577.590, z2 = 110.916},
		{name = "����������� ������", x1 = -1119.010, y1 = 1178.930, z1 = -89.084, x2 = -862.025, y2 = 1351.450, z2 = 110.916},
		{name = "������-����", x1 = 2749.900, y1 = 943.235, z1 = -89.084, x2 = 2923.390, y2 = 1198.990, z2 = 110.916},
		{name = "��������� ����", x1 = 2703.580, y1 = -2302.330, z1 = -89.084, x2 = 2959.350, y2 = -2126.900, z2 = 110.916},
		{name = "����������", x1 = 2324.000, y1 = -2059.230, z1 = -89.084, x2 = 2541.700, y2 = -1852.870, z2 = 110.916},
		{name = "�����", x1 = -2411.220, y1 = 265.243, z1 = -9.1, x2 = -1993.280, y2 = 373.539, z2 = 200.000},
		{name = "������������ �����", x1 = 1323.900, y1 = -1842.270, z1 = -89.084, x2 = 1701.900, y2 = -1722.260, z2 = 110.916},
		{name = "����������", x1 = 1269.130, y1 = -768.027, z1 = -89.084, x2 = 1414.070, y2 = -452.425, z2 = 110.916},
		{name = "����� ������", x1 = 647.712, y1 = -1804.210, z1 = -89.084, x2 = 851.449, y2 = -1577.590, z2 = 110.916},
		{name = "�������-�����", x1 = -2741.070, y1 = 1268.410, z1 = -4.5, x2 = -2533.040, y2 = 1490.470, z2 = 200.000},
		{name = "������ 4 �������", x1 = 1817.390, y1 = 863.232, z1 = -89.084, x2 = 2027.390, y2 = 1083.230, z2 = 110.916},
		{name = "��������", x1 = 964.391, y1 = 1203.220, z1 = -89.084, x2 = 1197.390, y2 = 1403.220, z2 = 110.916},
		{name = "�������� �����", x1 = 1534.560, y1 = 2433.230, z1 = -89.084, x2 = 1848.400, y2 = 2583.230, z2 = 110.916},
		{name = "���� ��� ������", x1 = 1117.400, y1 = 2723.230, z1 = -89.084, x2 = 1457.460, y2 = 2863.230, z2 = 110.916},
		{name = "�������", x1 = 1812.620, y1 = -1602.310, z1 = -89.084, x2 = 2124.660, y2 = -1449.670, z2 = 110.916},
		{name = "�������� �������", x1 = 1297.470, y1 = 2142.860, z1 = -89.084, x2 = 1777.390, y2 = 2243.230, z2 = 110.916},
		{name = "������", x1 = -2270.040, y1 = -324.114, z1 = -1.2, x2 = -1794.920, y2 = -222.589, z2 = 200.000},
		{name = "����� �������", x1 = 967.383, y1 = -450.390, z1 = -3.0, x2 = 1176.780, y2 = -217.900, z2 = 200.000},
		{name = "���-���������", x1 = -926.130, y1 = 1398.730, z1 = -3.0, x2 = -719.234, y2 = 1634.690, z2 = 200.000},
		{name = "������ ������", x1 = 1817.390, y1 = 1469.230, z1 = -89.084, x2 = 2027.400, y2 = 1703.230, z2 = 110.916},
		{name = "���� ����", x1 = -2867.850, y1 = 277.411, z1 = -9.1, x2 = -2593.440, y2 = 458.411, z2 = 200.000},
		{name = "���� ������", x1 = -2646.400, y1 = -355.493, z1 = 0.000, x2 = -2270.040, y2 = -222.589, z2 = 200.000},
		{name = "�����", x1 = 2027.400, y1 = 863.229, z1 = -89.084, x2 = 2087.390, y2 = 1703.230, z2 = 110.916},
		{name = "�������", x1 = -2593.440, y1 = -222.589, z1 = -1.0, x2 = -2411.220, y2 = 54.722, z2 = 200.000},
		{name = "��������", x1 = 1852.000, y1 = -2394.330, z1 = -89.084, x2 = 2089.000, y2 = -2179.250, z2 = 110.916},
		{name = "�������-�������", x1 = 1098.310, y1 = 1726.220, z1 = -89.084, x2 = 1197.390, y2 = 2243.230, z2 = 110.916},
		{name = "�������������", x1 = -789.737, y1 = 1659.680, z1 = -89.084, x2 = -599.505, y2 = 1929.410, z2 = 110.916},
		{name = "���-������", x1 = 1812.620, y1 = -2179.250, z1 = -89.084, x2 = 1970.620, y2 = -1852.870, z2 = 110.916},
		{name = "������� �����", x1 = -1700.010, y1 = 744.267, z1 = -6.1, x2 = -1580.010, y2 = 1176.520, z2 = 200.000},
		{name = "������ ������", x1 = -2178.690, y1 = -1250.970, z1 = 0.000, x2 = -1794.920, y2 = -1115.580, z2 = 200.000},
		{name = "���-��������", x1 = -354.332, y1 = 2580.360, z1 = 2.0, x2 = -133.625, y2 = 2816.820, z2 = 200.000},
		{name = "������ ���������", x1 = -936.668, y1 = 2611.440, z1 = 2.0, x2 = -715.961, y2 = 2847.900, z2 = 200.000},
		{name = "����������� ��������", x1 = 1166.530, y1 = 795.010, z1 = -89.084, x2 = 1375.600, y2 = 1044.690, z2 = 110.916},
		{name = "������", x1 = 2222.560, y1 = -1852.870, z1 = -89.084, x2 = 2632.830, y2 = -1722.330, z2 = 110.916},
		{name = "�������� �����-���", x1 = -1213.910, y1 = -730.118, z1 = 0.000, x2 = -1132.820, y2 = -50.096, z2 = 200.000},
		{name = "��������� �������", x1 = 1817.390, y1 = 2011.830, z1 = -89.084, x2 = 2106.700, y2 = 2202.760, z2 = 110.916},
		{name = "��������� ���������", x1 = -1499.890, y1 = 578.396, z1 = -79.615, x2 = -1339.890, y2 = 1274.260, z2 = 20.385},
		{name = "������ ��������", x1 = 2087.390, y1 = 1543.230, z1 = -89.084, x2 = 2437.390, y2 = 1703.230, z2 = 110.916},
		{name = "������ �����", x1 = 2087.390, y1 = 1383.230, z1 = -89.084, x2 = 2437.390, y2 = 1543.230, z2 = 110.916},
		{name = "������", x1 = 72.648, y1 = -1235.070, z1 = -89.084, x2 = 321.356, y2 = -1008.150, z2 = 110.916},
		{name = "������", x1 = 2437.390, y1 = 1783.230, z1 = -89.084, x2 = 2685.160, y2 = 2012.180, z2 = 110.916},
		{name = "����������", x1 = 1281.130, y1 = -452.425, z1 = -89.084, x2 = 1641.130, y2 = -290.913, z2 = 110.916},
		{name = "������� �����", x1 = -1982.320, y1 = 744.170, z1 = -6.1, x2 = -1871.720, y2 = 1274.260, z2 = 200.000},
		{name = "�����-�����-�����", x1 = 2576.920, y1 = 62.158, z1 = 0.000, x2 = 2759.250, y2 = 385.503, z2 = 200.000},
		{name = "������� ����� �������", x1 = 2498.210, y1 = 2626.550, z1 = -89.084, x2 = 2749.900, y2 = 2861.550, z2 = 110.916},
		{name = "����� �����-����", x1 = 1777.390, y1 = 863.232, z1 = -89.084, x2 = 1817.390, y2 = 2342.830, z2 = 110.916},
		{name = "������� �������", x1 = -2290.190, y1 = 2548.290, z1 = -89.084, x2 = -1950.190, y2 = 2723.290, z2 = 110.916},
		{name = "��������� ����", x1 = 2324.000, y1 = -2302.330, z1 = -89.084, x2 = 2703.580, y2 = -2145.100, z2 = 110.916},
		{name = "������", x1 = 321.356, y1 = -1044.070, z1 = -89.084, x2 = 647.557, y2 = -860.619, z2 = 110.916},
		{name = "��������� ���������", x1 = 1558.090, y1 = 596.349, z1 = -89.084, x2 = 1823.080, y2 = 823.235, z2 = 110.916},
		{name = "��������� ����", x1 = 2632.830, y1 = -1852.870, z1 = -89.084, x2 = 2959.350, y2 = -1668.130, z2 = 110.916},
		{name = "�����-�����", x1 = -314.426, y1 = -753.874, z1 = -89.084, x2 = -106.339, y2 = -463.073, z2 = 110.916},
		{name = "��������", x1 = 19.607, y1 = -404.136, z1 = 3.8, x2 = 349.607, y2 = -220.137, z2 = 200.000},
		{name = "������� ������", x1 = 2749.900, y1 = 1198.990, z1 = -89.084, x2 = 2923.390, y2 = 1548.990, z2 = 110.916},
		{name = "���� ����", x1 = 1812.620, y1 = -1350.720, z1 = -89.084, x2 = 2056.860, y2 = -1100.820, z2 = 110.916},
		{name = "������� �����", x1 = -1993.280, y1 = 265.243, z1 = -9.1, x2 = -1794.920, y2 = 578.396, z2 = 200.000},
		{name = "�������� ��������", x1 = 1377.390, y1 = 2243.230, z1 = -89.084, x2 = 1704.590, y2 = 2433.230, z2 = 110.916},
		{name = "������", x1 = 321.356, y1 = -1235.070, z1 = -89.084, x2 = 647.522, y2 = -1044.070, z2 = 110.916},
		{name = "���� ����", x1 = -2741.450, y1 = 1659.680, z1 = -6.1, x2 = -2616.400, y2 = 2175.150, z2 = 200.000},
		{name = "��� Probe Inn", x1 = -90.218, y1 = 1286.850, z1 = -3.0, x2 = 153.859, y2 = 1554.120, z2 = 200.000},
		{name = "����������� �����", x1 = -187.700, y1 = -1596.760, z1 = -89.084, x2 = 17.063, y2 = -1276.600, z2 = 110.916},
		{name = "���-�������", x1 = 2281.450, y1 = -1135.040, z1 = -89.084, x2 = 2632.740, y2 = -945.035, z2 = 110.916},
		{name = "������-����-����", x1 = 2749.900, y1 = 1548.990, z1 = -89.084, x2 = 2923.390, y2 = 1937.250, z2 = 110.916},
		{name = "���������� ������", x1 = 2011.940, y1 = 2202.760, z1 = -89.084, x2 = 2237.400, y2 = 2508.230, z2 = 110.916},
		{name = "��������� ������", x1 = -208.570, y1 = 2123.010, z1 = -7.6, x2 = 114.033, y2 = 2337.180, z2 = 200.000},
		{name = "�����-�����", x1 = -2741.070, y1 = 458.411, z1 = -7.6, x2 = -2533.040, y2 = 793.411, z2 = 200.000},
		{name = "�����-����-������", x1 = 2703.580, y1 = -2126.900, z1 = -89.084, x2 = 2959.350, y2 = -1852.870, z2 = 110.916},
		{name = "����������� �����", x1 = 926.922, y1 = -1577.590, z1 = -89.084, x2 = 1370.850, y2 = -1416.250, z2 = 110.916},
		{name = "�����", x1 = -2593.440, y1 = 54.722, z1 = 0.000, x2 = -2411.220, y2 = 458.411, z2 = 200.000},
		{name = "����������� ������", x1 = 1098.390, y1 = 2243.230, z1 = -89.084, x2 = 1377.390, y2 = 2507.230, z2 = 110.916},
		{name = "��������", x1 = 2121.400, y1 = 2663.170, z1 = -89.084, x2 = 2498.210, y2 = 2861.550, z2 = 110.916},
		{name = "��������", x1 = 2437.390, y1 = 1383.230, z1 = -89.084, x2 = 2624.400, y2 = 1783.230, z2 = 110.916},
		{name = "��������", x1 = 964.391, y1 = 1403.220, z1 = -89.084, x2 = 1197.390, y2 = 1726.220, z2 = 110.916},
		{name = "������� ���", x1 = -410.020, y1 = 1403.340, z1 = -3.0, x2 = -137.969, y2 = 1681.230, z2 = 200.000},
		{name = "��������", x1 = 580.794, y1 = -674.885, z1 = -9.5, x2 = 861.085, y2 = -404.790, z2 = 200.000},
		{name = "���-��������", x1 = -1645.230, y1 = 2498.520, z1 = 0.000, x2 = -1372.140, y2 = 2777.850, z2 = 200.000},
		{name = "�������� ���������", x1 = -2533.040, y1 = 1358.900, z1 = -4.5, x2 = -1996.660, y2 = 1501.210, z2 = 200.000},
		{name = "�������� �����-���", x1 = -1499.890, y1 = -50.096, z1 = -1.0, x2 = -1242.980, y2 = 249.904, z2 = 200.000},
		{name = "�������� ������", x1 = 1916.990, y1 = -233.323, z1 = -100.000, x2 = 2131.720, y2 = 13.800, z2 = 200.000},
		{name = "����������", x1 = 1414.070, y1 = -768.027, z1 = -89.084, x2 = 1667.610, y2 = -452.425, z2 = 110.916},
		{name = "��������� ����", x1 = 2747.740, y1 = -1498.620, z1 = -89.084, x2 = 2959.350, y2 = -1120.040, z2 = 110.916},
		{name = "���-������� �����", x1 = 2450.390, y1 = 385.503, z1 = -100.000, x2 = 2759.250, y2 = 562.349, z2 = 200.000},
		{name = "�������� �����", x1 = -2030.120, y1 = -2174.890, z1 = -6.1, x2 = -1820.640, y2 = -1771.660, z2 = 200.000},
		{name = "����������� �����", x1 = 1072.660, y1 = -1416.250, z1 = -89.084, x2 = 1370.850, y2 = -1130.850, z2 = 110.916},
		{name = "�������� ������", x1 = 1997.220, y1 = 596.349, z1 = -89.084, x2 = 2377.390, y2 = 823.228, z2 = 110.916},
		{name = "�����-����", x1 = 1534.560, y1 = 2583.230, z1 = -89.084, x2 = 1848.400, y2 = 2863.230, z2 = 110.916},
		{name = "����� �����", x1 = -1794.920, y1 = -50.096, z1 = -1.04, x2 = -1499.890, y2 = 249.904, z2 = 200.000},
		{name = "����-������", x1 = -1166.970, y1 = -1856.030, z1 = 0.000, x2 = -815.624, y2 = -1602.070, z2 = 200.000},
		{name = "�������� ����", x1 = 1457.390, y1 = 863.229, z1 = -89.084, x2 = 1777.400, y2 = 1143.210, z2 = 110.916},
		{name = "�����-����", x1 = 1117.400, y1 = 2507.230, z1 = -89.084, x2 = 1534.560, y2 = 2723.230, z2 = 110.916},
		{name = "��������", x1 = 104.534, y1 = -220.137, z1 = 2.3, x2 = 349.607, y2 = 152.236, z2 = 200.000},
		{name = "��������� ������", x1 = -464.515, y1 = 2217.680, z1 = 0.000, x2 = -208.570, y2 = 2580.360, z2 = 200.000},
		{name = "������� �����", x1 = -2078.670, y1 = 578.396, z1 = -7.6, x2 = -1499.890, y2 = 744.267, z2 = 200.000},
		{name = "��������� ������", x1 = 2537.390, y1 = 676.549, z1 = -89.084, x2 = 2902.350, y2 = 943.235, z2 = 110.916},
		{name = "����� ���-������", x1 = -2616.400, y1 = 1501.210, z1 = -3.0, x2 = -1996.660, y2 = 1659.680, z2 = 200.000},
		{name = "��������", x1 = -2741.070, y1 = 793.411, z1 = -6.1, x2 = -2533.040, y2 = 1268.410, z2 = 200.000},
		{name = "������", x1 = 2087.390, y1 = 1203.230, z1 = -89.084, x2 = 2640.400, y2 = 1383.230, z2 = 110.916},
		{name = "���-��������-�����", x1 = 2162.390, y1 = 2012.180, z1 = -89.084, x2 = 2685.160, y2 = 2202.760, z2 = 110.916},
		{name = "��������-����", x1 = -2533.040, y1 = 578.396, z1 = -7.6, x2 = -2274.170, y2 = 968.369, z2 = 200.000},
		{name = "��������-������", x1 = -2533.040, y1 = 968.369, z1 = -6.1, x2 = -2274.170, y2 = 1358.900, z2 = 200.000},
		{name = "����-���������", x1 = 2237.400, y1 = 2202.760, z1 = -89.084, x2 = 2536.430, y2 = 2542.550, z2 = 110.916},
		{name = "���������� �����", x1 = 2685.160, y1 = 1055.960, z1 = -89.084, x2 = 2749.900, y2 = 2626.550, z2 = 110.916},
		{name = "���� ������", x1 = 647.712, y1 = -2173.290, z1 = -89.084, x2 = 930.221, y2 = -1804.210, z2 = 110.916},
		{name = "������ ������", x1 = -2178.690, y1 = -599.884, z1 = -1.2, x2 = -1794.920, y2 = -324.114, z2 = 200.000},
		{name = "����-����-�����", x1 = -901.129, y1 = 2221.860, z1 = 0.000, x2 = -592.090, y2 = 2571.970, z2 = 200.000},
		{name = "������� ������", x1 = -792.254, y1 = -698.555, z1 = -5.3, x2 = -452.404, y2 = -380.043, z2 = 200.000},
		{name = "�����", x1 = -1209.670, y1 = -1317.100, z1 = 114.981, x2 = -908.161, y2 = -787.391, z2 = 251.981},
		{name = "����� �������", x1 = -968.772, y1 = 1929.410, z1 = -3.0, x2 = -481.126, y2 = 2155.260, z2 = 200.000},
		{name = "�������� ���������", x1 = -1996.660, y1 = 1358.900, z1 = -4.5, x2 = -1524.240, y2 = 1592.510, z2 = 200.000},
		{name = "���������� �����", x1 = -1871.720, y1 = 744.170, z1 = -6.1, x2 = -1701.300, y2 = 1176.420, z2 = 300.000},
		{name = "������", x1 = -2411.220, y1 = -222.589, z1 = -1.14, x2 = -2173.040, y2 = 265.243, z2 = 200.000},
		{name = "����������", x1 = 1119.510, y1 = 119.526, z1 = -3.0, x2 = 1451.400, y2 = 493.323, z2 = 200.000},
		{name = "����", x1 = 2749.900, y1 = 1937.250, z1 = -89.084, x2 = 2921.620, y2 = 2669.790, z2 = 110.916},
		{name = "��������", x1 = 1249.620, y1 = -2394.330, z1 = -89.084, x2 = 1852.000, y2 = -2179.250, z2 = 110.916},
		{name = "���� �����-�����", x1 = 72.648, y1 = -2173.290, z1 = -89.084, x2 = 342.648, y2 = -1684.650, z2 = 110.916},
		{name = "����������� ����������", x1 = 1463.900, y1 = -1150.870, z1 = -89.084, x2 = 1812.620, y2 = -768.027, z2 = 110.916},
		{name = "�������-����", x1 = -2324.940, y1 = -2584.290, z1 = -6.1, x2 = -1964.220, y2 = -2212.110, z2 = 200.000},
		{name = "���������� ��������", x1 = 37.032, y1 = 2337.180, z1 = -3.0, x2 = 435.988, y2 = 2677.900, z2 = 200.000},
		{name = "�����-�������", x1 = 338.658, y1 = 1228.510, z1 = 0.000, x2 = 664.308, y2 = 1655.050, z2 = 200.000},
		{name = "������ ���-�-���", x1 = 2087.390, y1 = 943.235, z1 = -89.084, x2 = 2623.180, y2 = 1203.230, z2 = 110.916},
		{name = "�������� �������", x1 = 1236.630, y1 = 1883.110, z1 = -89.084, x2 = 1777.390, y2 = 2142.860, z2 = 110.916},
		{name = "���� �����-�����", x1 = 342.648, y1 = -2173.290, z1 = -89.084, x2 = 647.712, y2 = -1684.650, z2 = 110.916},
		{name = "������������", x1 = 1249.620, y1 = -2179.250, z1 = -89.084, x2 = 1692.620, y2 = -1842.270, z2 = 110.916},
		{name = "�������� ��� ��������", x1 = 1236.630, y1 = 1203.280, z1 = -89.084, x2 = 1457.370, y2 = 1883.110, z2 = 110.916},
		{name = "����� �����", x1 = -594.191, y1 = -1648.550, z1 = 0.000, x2 = -187.700, y2 = -1276.600, z2 = 200.000},
		{name = "������������", x1 = 930.221, y1 = -2488.420, z1 = -89.084, x2 = 1249.620, y2 = -2006.780, z2 = 110.916},
		{name = "�������� ����", x1 = 2160.220, y1 = -149.004, z1 = 0.000, x2 = 2576.920, y2 = 228.322, z2 = 200.000},
		{name = "��������� ����", x1 = 2373.770, y1 = -2697.090, z1 = -89.084, x2 = 2809.220, y2 = -2330.460, z2 = 110.916},
		{name = "�������� �����-���", x1 = -1213.910, y1 = -50.096, z1 = -4.5, x2 = -947.980, y2 = 578.396, z2 = 200.000},
		{name = "�������-�������", x1 = 883.308, y1 = 1726.220, z1 = -89.084, x2 = 1098.310, y2 = 2507.230, z2 = 110.916},
		{name = "������-�����", x1 = -2274.170, y1 = 744.170, z1 = -6.1, x2 = -1982.320, y2 = 1358.900, z2 = 200.000},
		{name = "����� �����", x1 = -1794.920, y1 = 249.904, z1 = -9.1, x2 = -1242.980, y2 = 578.396, z2 = 200.000},
		{name = "����� ��", x1 = -321.744, y1 = -2224.430, z1 = -89.084, x2 = 44.615, y2 = -1724.430, z2 = 110.916},
		{name = "������", x1 = -2173.040, y1 = -222.589, z1 = -1.0, x2 = -1794.920, y2 = 265.243, z2 = 200.000},
		{name = "���� ������", x1 = -2178.690, y1 = -2189.910, z1 = -47.917, x2 = -2030.120, y2 = -1771.660, z2 = 576.083},
		{name = "����-������", x1 = -376.233, y1 = 826.326, z1 = -3.0, x2 = 123.717, y2 = 1220.440, z2 = 200.000},
		{name = "������ ������", x1 = -2178.690, y1 = -1115.580, z1 = 0.000, x2 = -1794.920, y2 = -599.884, z2 = 200.000},
		{name = "�����-�����", x1 = -2994.490, y1 = -222.589, z1 = -1.0, x2 = -2593.440, y2 = 277.411, z2 = 200.000},
		{name = "����-����", x1 = 508.189, y1 = -139.259, z1 = 0.000, x2 = 1306.660, y2 = 119.526, z2 = 200.000},
		{name = "�������", x1 = -2741.070, y1 = 2175.150, z1 = 0.000, x2 = -2353.170, y2 = 2722.790, z2 = 200.000},
		{name = "��������", x1 = 1457.370, y1 = 1203.280, z1 = -89.084, x2 = 1777.390, y2 = 1883.110, z2 = 110.916},
		{name = "�������� ��������", x1 = -319.676, y1 = -220.137, z1 = 0.000, x2 = 104.534, y2 = 293.324, z2 = 200.000},
		{name = "���������", x1 = -2994.490, y1 = 458.411, z1 = -6.1, x2 = -2741.070, y2 = 1339.610, z2 = 200.000},
		{name = "����-���", x1 = 2285.370, y1 = -768.027, z1 = 0.000, x2 = 2770.590, y2 = -269.740, z2 = 200.000},
		{name = "������ ������", x1 = 337.244, y1 = 710.840, z1 = -115.239, x2 = 860.554, y2 = 1031.710, z2 = 203.761},
		{name = "��������", x1 = 1382.730, y1 = -2730.880, z1 = -89.084, x2 = 2201.820, y2 = -2394.330, z2 = 110.916},
		{name = "���������-����", x1 = -2994.490, y1 = -811.276, z1 = 0.000, x2 = -2178.690, y2 = -430.276, z2 = 200.000},
		{name = "����� ��", x1 = -2616.400, y1 = 1659.680, z1 = -3.0, x2 = -1996.660, y2 = 2175.150, z2 = 200.000},
		{name = "������ �������� ������", x1 = -91.586, y1 = 1655.050, z1 = -50.000, x2 = 421.234, y2 = 2123.010, z2 = 250.000},
		{name = "���� ������", x1 = -2997.470, y1 = -1115.580, z1 = -47.917, x2 = -2178.690, y2 = -971.913, z2 = 576.083},
		{name = "���� ������", x1 = -2178.690, y1 = -1771.660, z1 = -47.917, x2 = -1936.120, y2 = -1250.970, z2 = 576.083},
		{name = "�������� �����-���", x1 = -1794.920, y1 = -730.118, z1 = -3.0, x2 = -1213.910, y2 = -50.096, z2 = 200.000},
		{name = "����������", x1 = -947.980, y1 = -304.320, z1 = -1.1, x2 = -319.676, y2 = 327.071, z2 = 200.000},
		{name = "�������� �����", x1 = -1820.640, y1 = -2643.680, z1 = -8.0, x2 = -1226.780, y2 = -1771.660, z2 = 200.000},
		{name = "���-�-������", x1 = -1166.970, y1 = -2641.190, z1 = 0.000, x2 = -321.744, y2 = -1856.030, z2 = 200.000},
		{name = "���� ������", x1 = -2994.490, y1 = -2189.910, z1 = -47.917, x2 = -2178.690, y2 = -1115.580, z2 = 576.083},
		{name = "������ ������", x1 = -1213.910, y1 = 596.349, z1 = -242.990, x2 = -480.539, y2 = 1659.680, z2 = 900.000},
		{name = "����� �����", x1 = -1213.910, y1 = -2892.970, z1 = -242.990, x2 = 44.615, y2 = -768.027, z2 = 900.000},
		{name = "��������", x1 = -2997.470, y1 = -2892.970, z1 = -242.990, x2 = -1213.910, y2 = -1115.580, z2 = 900.000},
		{name = "��������� �����", x1 = -480.539, y1 = 596.349, z1 = -242.990, x2 = 869.461, y2 = 2993.870, z2 = 900.000},
		{name = "������ ������", x1 = -2997.470, y1 = 1659.680, z1 = -242.990, x2 = -480.539, y2 = 2993.870, z2 = 900.000},
		{name = "���������� ��", x1 = -2997.470, y1 = -1115.580, z1 = -242.990, x2 = -1213.910, y2 = 1659.680, z2 = 900.000},
		{name = "���������� ��", x1 = 869.461, y1 = 596.349, z1 = -242.990, x2 = 2997.060, y2 = 2993.870, z2 = 900.000},
		{name = "�������� �����", x1 = -1213.910, y1 = -768.027, z1 = -242.990, x2 = 2997.060, y2 = 596.349, z2 = 900.000},
		{name = "���������� ��", x1 = 44.615, y1 = -2892.970, z1 = -242.990, x2 = 2997.060, y2 = -768.027, z2 = 900.000}
    }

    for _, zone in ipairs(zones) do
        local center_x = (zone.x1 + zone.x2) / 2
        local center_y = (zone.y1 + zone.y2) / 2
        local center_z = (zone.z1 + zone.z2) / 2

        local distance = math.sqrt((x - center_x)^2 + (y - center_y)^2 + (z - center_z)^2)

        if distance < min_distance then
            closest_area = zone.name
            min_distance = distance
        end
    end

    return closest_area or "����������� ����"
end


function lec_start(text_arg, cmd_lec)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}� ��� ��� �������� ���������! ����������� {ED95A8}Page Down{FFFFFF}, ����� ���������� �.', color_tag)
		return
	end
	
	local select_lec_i
	for i = 1, #setting.lec do
		if setting.lec[i].cmd == cmd_lec then select_lec_i = setting.lec[i] end
	end
	
	if select_lec_i ~= nil then
		thread = lua_thread.create(function()
			for i, v in ipairs(select_lec_i.q) do
				if v ~= nil then
					local message_end = ((u8:decode(tag_act(v))))
					if i ~= 1 then
						wait(select_lec_i.wait)
						sampSendChat(message_end)
					else
						sampSendChat(message_end)
					end
				end
			end
		end)		
	end
end

function add_table_act(org_to_replace, default_act)
	local add_table
	local function create_file_json(name_file_json, desc_act, table_to_save, rank)
		local bool_true = false
		if desc_act ~= nil then
			if #setting.cmd ~= 0 then
				for i = 1, #setting.cmd do
					if setting.cmd[i][1] == name_file_json then
						bool_true = true
						break
					end
				end
			end
		end
		if not bool_true then
			local f = io.open(dirml..'/StateHelper/���������/'..name_file_json..'.json', 'w')
			f:write(encodeJson(table_to_save))
			f:flush()
			f:close()
			
			sampRegisterChatCommand(name_file_json, function(arg) cmd_start(arg, name_file_json) end)
			
			if desc_act ~= nil then
				table.insert(setting.cmd, {name_file_json, desc_act, {}, rank})
				save('setting')
			end
		end
	end
	if default_act then
		add_table = {
			arg = {},
			nm = 'z',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'�����������',
			act = {
				{0, u8'������������, ���� ����� {mynickrus}, ��� ���� ���� �����{sex:��,��}?'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('z', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{1, u8'�������'}
			},
			nm = 'exp',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'������� �� ���������',
			act = {
				{0, u8'/me ������ ��������� ���� �������{sex:��,���} �� �������� ����������'},
				{0, u8'/do ������ ������ ���������� �� ��������.'},
				{0, u8'/todo � ��������{sex:,�} ������� ��� �� ������*����������� � ������'},
				{0, u8'/me ��������� ����� ���� ������{sex:,�} ������� �����, ����� ���� ���������{sex:,�} ����������'},
				{0, u8'/expel {arg1} {arg2}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('exp', nil, add_table, '3')
		add_table = {
			arg = {},
			nm = 'za',
			var = {},
			act = {
				{0, u8'�������� �� ����.'}
			},
			desc = u8'�������� ����� "�������� �� ����"',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('za', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'show',
			var = {},
			act = {
				{3, 1, 5, {u8"�������", u8"����������� �����", u8"��������", u8"�������� ������", u8"�������������"}},
				{8, "1", "1"},
				{0, u8"/do ������� � ��������� �������."},
				{0, u8"/me ������{sex:,�} ������� �� ���������� �������"},
				{0, u8"/todo ���, ��������*��������� ������� �������� ��������"},
				{0, u8"/showpass {arg1}"},
				{9, "1", "1"},
				{8, "1", "2"},
				{0, u8"/do ����������� ����� ��������� � ��������� �������."},
				{0, u8"/me ������� ���� � ������, ������{sex:,�} ���. �����, ����� ���� �������{sex:,�} � �������� ��������"},
				{0, u8"/showmc {arg1}"},
				{9, "1", "1"},
				{8, "1", "3"},
				{0, u8"/do ����� �������� ��������� � ��������� �������."},
				{0, u8"/me ������� ���� � ������, ������{sex:,�} ��������, ����� ���� �������{sex:,�} �� �������� ��������"},
				{0, u8"/showlic {arg1}"},
				{9, "1", "1"},
				{8, "1", "4"},
				{0, u8"/do �������� ������ ��������� �� ���������� �������."},
				{0, u8"/me ������� ���� � ������, ������{sex:,�} ������, ����� ���� �������{sex:,�} � �������� ��������"},
				{0, u8"/wbook {arg1}"},
				{9, "1", "1"},
				{8, "1", "5"},
				{0, u8"/me ������{sex:,�} ���� ������������� �� ������� � ��������� ���������{sex:,�} ���"},
				{0, u8"/me ���������� ������������� �������� ��������"},
				{0, u8"/do ������������� �������� ���������� � ����� ������ � ������� ����."},
				{0, u8"/showbadge {arg1}"}
			},
			desc = u8'�������� ������ ���� ���������',
			tr_fl = {0, 1, 3},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('show', nil, add_table, '1')
		add_table = {
			arg = {},
			nm = 'cam',
			var = {},
			act = {
				{3, 1, 2, {u8'�������� ������', u8'��������� ������'}},
				{8, '1', '1'},
				{0, u8'/do ������� ��������� � ����� �������.'},
				{0, u8'/me ������� ���� � ������, ������{sex:,�} ������ �������, ����� ���� ���{sex:��,��} � ���������� \'������\''},
				{0, u8'/me ����� �� ������ ������, ���������{sex:,�} � ������ �������������'},
				{0, u8'/do ������ ��������� ������ ���������� ����� � ����.'},
				{9, '1', '1'},
				{8, '1', '2'},
				{0, u8'/do ������� ��������� � ���� � ���� ������.'},
				{0, u8'/me �����{sex:,�} �� ������ ���������� ������, ����� ���� �����{sex:,�} ������� � ������ ������'},
				{0, u8'/do ������������� ������������� ��������������.'},
				{9, '1', '1'}
			},
			desc = u8'������ ��� ���������� �������������',
			tr_fl = {0, 1, 2},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('cam', nil, add_table, '1')
		add_table = {
			arg = {},
			nm = 'mb',
			var = {},
			act = {
				{0, u8'/members'}
			},
			desc = u8'����������� ������� /members',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('mb', nil, add_table, '1')
		add_table = {
			arg = {
				{0, u8'id ����������'},
				{0, u8'����� � �������'},
				{1, u8'�������'}
			},
			nm = '+mute',
			var = {},
			act = {
				{0, u8'/do ����� ����� �� �����.'},
				{0, u8'/me ����{sex:,�} ����� � �����, ����� ���� {sex:�����,�����} � ��������� ��������� ������ �������'},
				{0, u8'/me ��������{sex:,�} ��������� ������� ������� ���������� {get_ru_nick[{arg1}]}'},
				{0, u8'/fmute {arg1} {arg2} {arg3}'},
				{0, u8'/r ���������� {get_ru_nick[{arg1}]} ���� ��������� �����. �������: {arg3}'}
			},
			desc = u8'������ ��� ���� ����������� ����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('+mute', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id ����������'}
			},
			nm = '-mute',
			var = {},
			act = {
				{0, u8'/do ����� ����� �� �����.'},
				{0, u8'/me ����{sex:,�} ����� � �����, ����� ���� {sex:�����,�����} � ��������� ��������� ������ �������'},
				{0, u8'/me ���������{sex:,�} ��������� ������� ������� ���������� {get_ru_nick[{arg1}]}'},
				{0, u8'/funmute {arg1}'},
				{0, u8'/r ���������� {get_ru_nick[{arg1}]} ����� �������� �����!'}
			},
			desc = u8'����� ��� ���� ����������� ����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('-mute', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id ����������'},
				{1, u8'�������'}
			},
			nm = '+warn',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'������ ���������� �������',
			act = {
				{0, u8'/do � ����� ������� ����� �������.'},
				{0, u8'/me ������{sex:,�} ������� �� �������, ����� ���� {sex:�����,�����} � ���� ������ �����������'},
				{0, u8'/me �������{sex:,�} ���������� � ���������� {get_ru_nick[{arg1}]}'},
				{0, u8'/fwarn {arg1} {arg2}'},
				{0, u8'/r {get_ru_nick[{arg1}]} ������� �������! �������: {arg2}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('+warn', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id ����������'}
			},
			nm = '-warn',
			var = {},
			act = {
				{0, u8'/do � ����� ������� ����� �������.'},
				{0, u8'/me ������{sex:,�} ������� �� �������, ����� ���� {sex:�����,�����} � ���� ������ �����������'},
				{0, u8'/me �������{sex:,�} ���������� � ���������� {get_ru_nick[{arg1}]}'},
				{0, u8'/unfwarn {arg1}'},
				{0, u8'/r ���������� {get_ru_nick[{arg1}]} ���� �������!'}
			},
			desc = u8'����� ������� ����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '8'
		}
		create_file_json('-warn', nil, add_table, '8')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'inv',
			var = {},
			act = {
				{0, u8'/do � ������� ��������� ����� �� ��������.'},
				{0, u8'/me ����������� �� ���������� ������, ������{sex:,�} ������ ����'},
				{0, u8'/me �������{sex:,�} ���� �� �������� � ������ �������� ��������'},
				{0, u8'/invite {arg1}'},
				{0, u8'/r ������������ ������ ���������� ����� ����������� - {get_ru_nick[{arg1}]}'}
			},
			desc = u8'������� ������ � �����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('inv', nil, add_table, '9')
		add_table = {
			arg = {
				{0, u8'id ����������'},
				{1, u8'�������'}
			},
			nm = 'uninv',
			var = {},
			act = {
				{0, u8'/do � ����� ������� ����� �������.'},
				{0, u8'/me ������{sex:,�} ������� �� �������, ����� ���� {sex:�����,�����} � ���� ������ �����������'},
				{0, u8'/me �������{sex:,�} ���������� � ���������� {get_ru_nick[{arg1}]}'},
				{0, u8'/uninvite {arg1} {arg2}'},
				{0, u8'/r ��������� {get_ru_nick[{arg1}]} ��� ������ �� �����������. �������: {arg2}'}
			},
			desc = u8'������� ����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('uninv', nil, add_table, '9')
		add_table = {
			arg = {
				{0, u8'id ����������'},
				{0, u8'����� �����'}
			},
			nm = 'rank',
			var = {},
			act = {
				{0, u8'/do � ������� ������ ��������� ������ � ������� �� ��������� � ������.'},
				{0, u8'/me ����������� �� ���������� ������ ������, ������{sex:,�} ������ ������'},
				{0, u8'/me ������ ������, ������{sex:,�} ������ ���� �� �������� � ������'},
				{0, u8'/me �������{sex:,�} ���� �� �������� �������� ��������'},
				{0, u8'/giverank {arg1} {arg2}'},
				{0, u8'/r ��������� {get_ru_nick[{arg1}]} ������� ����� ���������. �����������!'}
			},
			desc = u8'���������� ���������� ����',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '9'
		}
		create_file_json('rank', nil, add_table, '9') 
	end
	
	if org_to_replace:find(u8'��������') then
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'hl',
			var = {},
			act = {
				{0, u8'/do ����������� ����� ����� �� ����� �����.'},
				{0, u8'/me ������ �����, ������{sex:,�} ����������� ��������� � �������{sex:,�} �������� ��������'},
				{0, u8'/heal {arg1} {pricelec}'}
			},
			desc = u8'�������� ������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('hl', u8'�������� ������', add_table, '1')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'mc',
			var = {{1, '0'}, {1, '0'}, {1, '0'}},
			tr_fl = {0, 4, 14},
			desc = u8'�������� ����������� �����',
			act = {
				{0, u8'��� ���������� �������� ����� ����������� ����� ��� �������� ���������?'},
				{0, u8'��� ���������� ����������� ����� ������������, ����������, ��� �������.'},
				{0, u8'/b ��� ����� ������� /showpass {myid}'},
				{1, u8''},
				{0, u8'/me ����{sex:,�} ������� �� ��� �������� � ����������� ������{sex:,�} ���'},
				{3, 1, 2, {u8'����� ���. �����', u8'�������� ���. �����'}},
				{8, '1', '1'},
				{0, u8'��������� ���������� ����� ���. ����� ������� �� � �����.'},
				{0, u8'7 ����: {med7}$. 14 ����: {med14}$'},
				{0, u8'30 ����: {med30}$. 60 ����: {med60}$'},
				{0, u8'������� �� ����� ���� ��������� � �� ���������.'},
				{3, 2, 4, {u8'7 ����', u8'14 ����', u8'30 ����', u8'60 ����'}},
				{8, '2', '1'},
				{5, '{var1}', '{med7}'},
				{5, '{var3}', '0'},
				{9, '1', '1'},
				{8, '2', '2'},
				{5, '{var1}', '{med14}'},
				{5, '{var3}', '1'},
				{9, '1', '1'},
				{8, '2', '3'},
				{5, '{var1}', '{med30}'},
				{5, '{var3}', '2'},
				{9, '1', '1'},
				{8, '2', '4'},
				{5, '{var1}', '{med60}'},
				{5, '{var3}', '3'},
				{9, '1', '1'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'��������� ���������� ���. ����� ������� �� � �����.'},
				{0, u8'7 ����: {medup7}$. 14 ����: {medup14}$'},
				{0, u8'30 ����: {medup30}$. 60 ����: {medup60}$'},
				{0, u8'������� �� ����� ���� ��������� � �� ���������.'},
				{3, 3, 4, {u8'7 ����', u8'14 ����', u8'30 ����', u8'60 ����'}},
				{8, '3', '1'},
				{5, '{var1}', '{medup7}'},
				{5, '{var3}', '0'},
				{9, '1', '1'},
				{8, '3', '2'},
				{5, '{var1}', '{medup14}'},
				{5, '{var3}', '1'},
				{9, '1', '1'},
				{8, '3', '3'},
				{5, '{var1}', '{medup30}'},
				{5, '{var3}', '2'},
				{9, '1', '1'},
				{8, '3', '4'},
				{5, '{var1}', '{medup60}'},
				{5, '{var3}', '3'},
				{9, '1', '1'},
				{9, '1', '1'},
				{0, u8'������, ������ ����� ���� ��������, ��������� ������.'},
				{0, u8'�� ������ ������ ����� ���������� ���� ��� �����?'},
				{1, ''},
				{0, u8'��� �����-������ �������?'},
				{3, 4, 4, {u8'��������� ������', u8'����������� ����.', u8'����. ��������', u8'����������'}},
				{8, '4', '1'},
				{5, '{var2}', '3'},
				{9, '1', '1'},
				{8, '4', '2'},
				{5, '{var2}', '2'},
				{9, '1', '1'},
				{8, '4', '3'},
				{5, '{var2}', '1'},
				{9, '1', '1'},
				{8, '4', '4'},
				{5, '{var2}', '0'},
				{9, '1', '1'},
				{0, u8'/me ���� � ������ ���� �� ���. ����� ������ � ������� ����� � ���� ������'},
				{0, u8'/do ������ �������� �������� �� �����.'},
				{0, u8'/me ����� ������ � ���. ����, ����� ���� ������ ������ ������� � ����������� ����'},
				{0, u8'/do �������� ����������� ����� ��������� ���������.'},
				{0, u8'/me ������� ����������� ����� � ���� �������������'},
				{0, u8'/medcard {arg1} {var2} {var3} {var1}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 29},
			key = {},
			num_d = 5,
			rank = '3'
		}
		create_file_json('mc', u8'�������� ����������� �����', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'narko',
			var = {},
			act = {
				{0, u8'����� ������������, ��� �� ������ ���������� �� �����������������.'},
				{0, u8'��������� ������ ������ �������� {pricenarko}$'},
				{0, u8'����� ������� �����������, ���������� "�������������". �� ��������� ����� ���������� � ����������� � ������ �����.'},
				{0, u8'�� ��������? ���� ��, �� �������� �� ������� � �� ���������.'},
				{1, ''},
				{0, u8'/do �� ����� ����� ���������� �������� � ����������� �����.'},
				{0, u8'/me ���� �� ����� �������� �������������� ������, �����{sex:,�} �� �� ����'},
				{0, u8'/todo � ������ ����������� ������������*�������� ����. ������� ����� � ��������'},
				{0, u8'/me ����{sex:,�} ���� �� ��������, ����� ���� �����{sex:,�} ��� �� ������ ��������'},
				{0, u8'/me �������{sex:,�} ����������, �����, �������� ���� ������, ��������{sex:,�} ���'},
				{0, u8'/do ������� ������� �������� ������.'},
				{0, u8'/me ����{sex:,�} ���� � �������� � �������{sex:,�} ��� ������� �� �������'},
				{0, u8'/healbad {arg1}'},
				{0, u8'/todo ��� � ��! ���� � ����������� ��������� ������ ���������*������ � ���� ����� � ����������'}
			},
			desc = u8'�������� �� �����������������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('narko', u8'�������� �� �����������������', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = u8'rec',
			var = {
			{1, '0'}
			},
			act = {
				{0, u8'�� ���������� ������� � ������������ ����������.'},
				{0, u8'/n �� ����� 5 ���� � ������.'},
				{0, u8'��������� ������ ������� ���������� {pricerecept}$'},
				{0, u8'�� ��������? ���� ��, �� ����� ���������� ��� ����������?'},
				{3, 1, 5, {u8'1 ������', u8'2 �������', u8'3 �������', u8'4 �������', u8'5 ��������'}},
				{8, '1', '1'},
				{5, '{var1}', '1'},
				{9, '1', '1'},
				{8, '1', '2'},
				{5, '{var1}', '2'},
				{9, '1', '1'},
				{8, '1', '3'},
				{5, '{var1}', '3'},
				{9, '1', '1'},
				{8, '1', '4'},
				{5, '{var1}', '4'},
				{9, '1', '1'},
				{8, '1', '5'},
				{5, '{var1}', '5'},
				{9, '1', '1'},
				{0, u8'/do �� ����� ����� ������ ��� ���������� ��������.'},
				{0, u8'/me ���� ����� � �������, ��������{sex:,�} ����������� ������, ����� ���� ��������{sex:,�} ������ � ���� �����'},
				{0, u8'/do ��� ������ �������� ������� ���������.'},
				{0, u8'/todo ������� � ������ ���������� ����������!*��������� ������� �������� ��������'},
				{0, u8'/recept {arg1} {var1}'}
			},
			desc = u8'�������� ������',
			tr_fl = {0, 1, 5},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('rec', u8'�������� ������', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'osm',
			var = {},
			act = {
				{0, u8'����� ������������, ��� �� ������ ������ ����������� ������.'},
				{0, u8'������������ ���, ����������, ���� ����������� �����.'},
				{1, u8''},
				{0, u8'/me ���� ����������� ����� � ���� � ����������� � �������'},
				{0, u8'������� �����. ������� ��� ������, ����� ������� �����.'},
				{1, u8''},
				{0, u8'/medcheck {arg1} {priceosm}'},
				{0, u8'/me ����������� ����������� �������� �� ������� ������ �����������'},
				{0, u8'/todo ����������! � ��� �� �������!*���������� ����������� ������'},
				{0, u8'/do ����������� ����� ��������� � ����� ����.'},
				{0, u8'/me ������ ����� �� �������, {sex:����,������} ��������� ��������� � ����������� �����'},
				{0, u8'/me �������{sex:,�} ����������� ����� ������� � ���� ��������'},
				{0, u8'�� ���� ��. ����� ��� �������, �� �������!'}
			},
			desc = u8'�������� ����������� ������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('osm', u8'�������� ����������� ������', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'tatu',
			var = {},
			act = {
				{0, u8'������ �� ����� ����� �� ��������� ���������� � ������ ����.'},
				{0, u8'�������� ��� �������, ����������.'},
				{1, ''},
				{0, u8'/me ������{sex:,�} � ��� ������������� �������'},
				{0, u8'/do ������� ������������� � ������ ����.'},
				{0, u8'/me ������������� � ���������, ������{sex:,�} ��� ������� ���������'},
				{0, u8'��������� ��������� ���������� �������� {pricetatu}$. �� ��������?'},
				{0, u8'/n ���������� �� ���������, ������ ��� ���������.'},
				{0, u8'/b �������� ���������� � ������� ������� /showtatu'},
				{1, ''},
				{0, u8'� ������, �� ������, ����� �������� � ���� �������, ����� � �����{sex:,�} ���� ����������.'},
				{0, u8'/do � ����� ����� ���������������� ������ � ��������.'},
				{0, u8'/do ������� ��� ��������� ���� �� �������.'},
				{0, u8'/me ����{sex:,�} ������� ��� ��������� ���������� � �������'},
				{0, u8'/me �������� ��������, ������{sex:��,����} �������� ��� ����������'},
				{0, u8'/unstuff {arg1} {pricetatu}'}
			},
			desc = u8'������� ���������� � ����',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('tatu', u8'������� ���������� � ����', add_table, '7')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'ant',
			var = {},
			act = {
				{0, u8'��������� � �����{sex:,�}, ��� ����� �����������.'},
				{0, u8'��������� ������ ����������� ���������� {priceant}$. �� ��������?'},
				{0, u8'���� ��, �� ����� ���������� ��� ����������?'},
				{1, ''},
				{0, u8'/me ������ ���.�����, �������{sex:���,��} �� ����� ������������, ����� ���� �������{sex:,�} �� � ������� �� ����'},
				{0, u8'/do ����������� ��������� �� �����.'},
				{0, u8'/todo ��� �������, ������������ �� ������ �� �������!*�������� ���. �����'},
				{2, u8'������� ���������� ������������ � ���.'},
				{0, u8'/antibiotik {arg1} '}
			},
			desc = u8'�������� �����������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('ant', u8'�������� �����������', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'cur',
			var = {},
			act = {
				{0, u8'/cure {arg1}'},
				{0, u8'/me ������ ��������� ���� ������{sex:,�} ���. �����, ����� ���� ������{sex:,�} ������'},
				{0, u8'/me ��������� ��������{sex:,�} ������ �� ��� �������������, ����� ���� ������{sex:,�} �������� ����'},
				{0, u8'/do � ����� ����� �������.'},
				{0, u8'/me �����{sex:,�} �� ������, ����� ���� ���������{sex:��,���} � ��������'},
				{0, u8'/me {sex:������,�������} ���� �� ��� �������������, ����� ���� �����{sex:,�} ������ ������������� �������'},
				{0, u8'/me �����{sex:,�} ���� �� ��� �������������, ����� ���� ������{sex:,�} �������� ����'},
				{0, u8'/me ������{sex:,�} ���� �� ��� �������������, ����� ���� �����{sex:,�} ������ ������������� �������'},
				{0, u8'/todo ������ ��������� ������������*������� ������'}
			},
			desc = u8'������� �������� ���������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '2'
		}
		create_file_json('cur', u8'������� �������� ���������', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'strah',
			var = {},
			act = {
				{0, u8'����� ������������, ��� �� ������ �������� ����������� ���������.'},
				{0, u8'� ��� �� ������� �������� �� ���� �����������.'},
				{0, u8'/me ������ �� ��� ����� ������ �����, ����� ���� �������� ��� ���������'},
				{0, u8'/me �������� �����, ������� ��� �������� �������� � �������:'},
				{0, u8'��� �������� �����, ������ ����� ��� � ���� ������.'},
				{0, u8'/me ������� �������� �������� � ���������, ����������� �� �����'},
				{0, u8'/do ������������ ����� � ���� ������ �����������.'},
				{0, u8'/todo ����������! �� ���������� ������������!*���������� ����������'},
				{0, u8'/givemedinsurance {arg1}'}
			},
			desc = u8'�������� ����������� ���������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('strah', u8'�������� ����������� ���������', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'mt',
			var = {},
			act = {
				{0, u8'����� ������������, ��� �� ������ ������ ������������.'},
				{0, u8'���� � ���������� ������������� ������� ������ �� �������������!'},
				{0, u8'/do �� ����� ����� ����������� �����.'},
				{0, u8'/me ������ ����������� �������� �� ����� ��� ����������� ������� ��������'},
				{0, u8'/todo ������ ������������, ��� ����� ������� �������*������� ������'},
				{0, u8'/mticket {arg1}'}
			},
			desc = u8'�������� ������������ ��� �������� ������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('mt', u8'�������� ������������ ��� �������� ������', add_table, '4')
		add_table = {
			arg = {},
			nm = 'hme',
			var = {},
			act = {
				{0, u8'/me ������ �����, ������{sex:,�} ����������� ��������� � ����������� ��� �����{sex:,�}'},
				{0, u8'/heal {myid} 5000'}
			},
			desc = u8'�������� ������ ����',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('hme', u8'�������� ������ ����', add_table, '4')
		
		
		setting.fast_acc.sl = {
			{
				text = u8'��������',
				cmd = 'hl',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'mc',
				pass_arg = true,
				text = u8'�������� ���. �����'
			},
			{
				send_chat = true,
				cmd = 'osm',
				pass_arg = true,
				text = u8'���. ������'
			},
			{
				text = u8'�������� �� ������',
				cmd = 'narko',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ ������',
				cmd = 'rec',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� �����������',
				cmd = 'ant',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ �� ������� �����',
				cmd = 'mt',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� ���������',
				cmd = 'strah',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'cur',
				pass_arg = true,
				text = u8'������� ��� ������'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'�������������'
			},
			{
				send_chat = true,
				cmd = 'za',
				pass_arg = true,
				text = u8'�������� �� ����'
			},
			{
				text = u8'�������',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'����� ��������������') then
		--[[
		[0] -- ����
		[1] -- ����
		[2] -- ������
		[3] -- �������
		[4] -- ������
		[5] -- ������
		[6] -- �����
		[7] -- ��������
		[8] -- �����
		[9] -- ��������
		]]
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licmauto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� �������� ����������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {priceauto1}$, �� 2 ������ {priceauto2}$, �� 3 ������ {priceauto3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ����'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[0][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('licauto', u8'������� �������� �� �������� ����������', add_table, '1')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licmoto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� �������� ���������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricemoto1}$, �� 2 ������ {pricemoto2}$, �� 3 ������ {pricemoto3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ����'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[1][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '2'
		}
		create_file_json('licmoto', u8'������� �������� �� �������� ���������', add_table, '2')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licfly',
			var = {{1, '0'}},
			tr_fl = {0, 0, 0},
			desc = u8'������� �������� �� �����',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ���������� {pricefly}$. �� ��������?'},
				{1, u8''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� �����'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[2][0][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('licfly', u8'������� �������� �� �����', add_table, '7')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licfish',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� �����������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricefish1}$, �� 2 ������ {pricefish2}$, �� 3 ������ {pricefish3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� �����������'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[3][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '3'
		}
		create_file_json('licfish', u8'������� �������� �� �����������', add_table, '3')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licswim',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� ������ ���������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {priceswim1}$, �� 2 ������ {priceswim2}$, �� 3 ������ {priceswim3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ���. ���������'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[4][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('licswim', u8'������� �������� �� ������ ���������', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'licgun',
			var = {
				{1, '0'}
			},
			tr_fl = {0, 2, 8},
			desc = u8'������� �������� �� ������',
			act = {
				{0, u8'��� ���������� �������� �� ������, ��� ����� ���������, ��� �� �������.'},
				{0, u8'��������, ����������, ���� ����������� �����.'},
				{0, u8'/n /showmc {myid}'},
				{3, 1, 3, {u8'������', u8'������� ����������', u8'��� ���. �����'}},
				{8, '1', '1'},
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricegun1}$, �� 2 ������ {pricegun2}$, �� 3 ������ {pricegun3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 2, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '2', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '2', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '2', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ������'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[5][{var1}][{arg1}]}'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'��������, �� � �� ���� �������� ��� �������� �� ������ � ����� � ���������� ��������.'},
				{0, u8'�� ������ ����� ������ ���. ������������ � �������� � ��������� � ���.'},
				{9, ''},
				{8, '1', '3'},
				{0, u8'��������, �� ������ � �� ���� �������� ��� �������� �� ������.'},
				{0, u8'� ��� ����������� ����������� �����. �������� � ����� � ��������� ��������.'},
				{9, ''}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 3,
			rank = '5'
		}
		create_file_json('licgun', u8'������� �������� �� ������', add_table, '5')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'lichunt',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� �����',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricehunt1}$, �� 2 ������ {pricehunt2}$, �� 3 ������ {pricehunt3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� �����'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[6][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '5'
		}
		create_file_json('lichunt', u8'������� �������� �� �����', add_table, '5')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licdig',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� �� ��������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {priceexc1}$, �� 2 ������ {priceexc2}$, �� 3 ������ {priceexc3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ��������'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[7][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licdig', u8'������� �������� �� ��������', add_table, '6')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'lictaxi',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� ��� ������ � �����',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricetaxi1}$, �� 2 ������ {pricetaxi2}$, �� 3 ������ {pricetaxi3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� �����'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[8][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('lictaxi', u8'������� �������� ��� ������ � �����', add_table, '6')
		add_table = {
			arg = {{0, u8'id ������'}},
			nm = 'licmec',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'������� �������� ��� ������ �� ��������',
			act = {
				{0, u8'/me ������{sex:,�} �� ��� ����� ������ ����� ��� ������ ��������'},
				{0, u8'��������� �������� ������� �� � �����.'},
				{0, u8'�� 1 ����� {pricemeh1}$, �� 2 ������ {pricemeh2}$, �� 3 ������ {pricemeh3}$'},
				{0, u8'�� ����� ���� ���������?'},
				{3, 1, 3, {u8'1 �����', u8'2 ������', u8'3 ������'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me �������{sex:,�} ����� � �������, ����� ���� ����������{sex:,�} �������� �� ��������'},
				{0, u8'/todo ���, ����������� �����*���������� �������� �������� ��������'},
				{0, u8'{dialoglic[9][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licmec', u8'������� �������� �� ��������', add_table, '6')
		
		setting.fast_acc.sl = {
			{
				text = u8'�������� �� ����',
				cmd = 'licauto',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'licmoto',
				pass_arg = true,
				text = u8'�������� �� ����'
			},
			{
				text = u8'�������� �� ����',
				cmd = 'licfish',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� �� ��������',
				cmd = 'licswim',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� �� ������',
				cmd = 'licgun',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'lichunt',
				pass_arg = true,
				text = u8'�������� �� �����'
			},
			{
				send_chat = true,
				cmd = 'licdig',
				pass_arg = true,
				text = u8'�������� �� ��������'
			},
			{
				send_chat = true,
				cmd = 'lictaxi',
				pass_arg = true,
				text = u8'�������� �� �����'
			},
			{
				send_chat = true,
				cmd = 'licmec',
				pass_arg = true,
				text = u8'�������� �� ��������'
			},
			{
				send_chat = true,
				cmd = 'licfly',
				pass_arg = true,
				text = u8'�������� �� �����'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'�������������'
			},
			{
				text = u8'�������',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'�������������') then
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'pass',
			var = {},
			rank = '6',
			act = {
				{0, u8'/do ����� ��� ������ ���������� � �������� ��������� ��� ������.'},
				{0, u8'/me ������� ���� ��� ����, ����{sex:,�} �����, ����� ���� ��������{sex:,�} ��� �������� ��������'},
				{0, u8'/todo ������� ���� ����� ���� � ��������� ������� �����*���������� ���� � ������'},
				{0, u8'{dialoggov[0][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'�������� ���� �������� � ��������',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('pass', u8'�������� ���� �������� � ��������', add_table, '6')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'visa',
			var = {},
			rank = '3',
			act = {
				{0, u8'��������� ������ ���������� 500.000$. �� ��������? ���� ��, �� �� ���������.'},
				{1, ''},
				{0, u8'/do ����� ��� ���������� ���� ��������� ��� ������.'},
				{0, u8'/me ������� ���� ��� ����, ����{sex:,�} �����, ����� ���� ��������{sex:,�} ��� �������� ��������'},
				{0, u8'/todo ������� ���� ���� ������ � ��������� ������� �����*���������� ���� � ������'},
				{0, u8'{dialoggov[1][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'�������� ���� ��� �������� � Vice City',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('visa', u8'�������� ���� ��� �������� � Vice City', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'car',
			var = {},
			rank = '5',
			act = {
				{0, u8'/do ����� ��� ��������� ����������� ��������� ��� ������.'},
				{0, u8'/me ������� ���� ��� ����, ����{sex:,�} �����, ����� ���� ��������{sex:,�} ��� �������� ��������'},
				{0, u8'/todo ������� ���� ���� ������ � ��������� ������� �����*���������� ���� � ������'},
				{0, u8'{dialoggov[2][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'���������� ������ �/� � ����������',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('car', u8'���������� ������ �/� � ����������', add_table, '5')
		add_table = {
			 arg = {
				{0, u8'id ������'}
			},
			nm = 'visit',
			var = {},
			rank = '3',
			act = {
				{0, u8'/me �������{sex:,�} �� ���������� ������� ������� ��������'},
				{0, u8'/do �� ������� ��������: {mynickrus}, ������� �����.'},
				{0, u8'/showvisit {arg1}'}
			},
			desc = u8'�������� ������� ��������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('visit', u8'�������� ������� ��������', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{0, u8'����'}
			},
			nm = 'freely',
			var = {},
			rank = '3',
			act = {
				{0, u8'/do ����� � ����������� ��������� � ����� ����.'},
				{0, u8'/me ������ �����, �������{sex:,�} �� �� ����� ��� ������������ ������������'},
				{0, u8'/me ������ �� ������� �����, ��������{sex:,a} �������� � �������{sex:,a} �������� ��������'},
				{0, u8'/todo ������� ���� ���� ������ � ��������� ������� �����*��������� ���� � ������'},
				{0, u8'/free {arg1} {arg2}'}
			},
			desc = u8'���������� ������ ��������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('freely', u8'���������� ������ ��������', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'lic',
			var = {},
			rank = '9',
			act = {
				{0, u8'/do ����� ��� ������ �������� ��������� ��� ������.'},
				{0, u8'/me ������� ���� ��� ����, ����{sex:,�} �����, ����� ���� ��������{sex:,�} ��� ������ �����������'},
				{0, u8'/todo ������� ���� ���� ������ � ��������� ������� �����*��������� ����� � �����'},
				{0, u8'/givelicadvokat {arg1}'}
			},
			desc = u8'������ �������� ��������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('lic', u8'������ �������� ��������', add_table, '9')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{0, u8'id �������'}
			},
			nm = 'wed',
			var = {},
			rank = '6',
			act = {
				{0, u8'�����������, ��������� ����������� � �����!'},
				{0, u8'��������� ������� � �����!'},
				{0, u8'������� - ����� ���������� � ������������ ������� � ����� �����.'},
				{0, u8'� ����� ��� �� ������ �� ����� ���� �� ����, ������ ��������� � ������� ���������� ����, � ���������.'},
				{0, u8'�������� �����, �� ����������� ������� �� ���� ������� ���� ���� ����� ������ � ����� ������� ����� �����.'},
				{0, u8'� ������ ��������� ��������, ����������� � ����������� ����������, ��� ���� ��������������.'},
				{0, u8'����� ��� � ���� ����� � ����������� ���� ����� ���������� ������������ ��������.'},
				{0, u8'/wedding {arg1} {arg2}'},
				{1, ''},
				{0, u8'����� ��� �� ������! ������ ������������!'}
			},
			desc = u8'��������� ����',
			tr_fl = {0, 0, 0},
			delay = 3000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('wed', u8'��������� ����', add_table, '6')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{1, u8'�������'}
			},
			nm = 'uvalgos',
			var = {},
			rank = '9',
			act = {
				{0, u8'/do � ����� ������� ����� �������.'},
				{0, u8'/me ������{sex:,�} ������� �� �������, ����� ���� {sex:�����,�����} � ���� ������ �����������'},
				{0, u8'/me �������{sex:,�} ���������� � ���������� ��������������� ���������'},
				{0, u8'/demoute {arg1} {arg2}'}
			},
			desc = u8'������� ������������',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('uvalgos', u8'������� ������������', add_table, '9')
		
		setting.fast_acc.sl = {
			{
				text = u8'�������������',
				cmd = 'z',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� ����',
				cmd = 'visa',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�/� � ����������',
				cmd = 'car',
				pass_arg = true,
				send_chat = true
				
			},
			{
				text = u8'�������� �������',
				cmd = 'pass',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������� ��������',
				cmd = 'visit',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������� ��������',
				cmd = 'lic',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'�������',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'���') then
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'agenda',
			var = {},
			rank = 5,
			act = {
				{0, u8'������������, � {myrank} {mynickrus}.'},
				{0, u8'�������� ���������� ��� �������.'},
				{1, u8''},
				{0, u8'/me ����{sex:,�} �������� � ��� �������� ��������, ����������� ��� ������{sex:,�}, ����� ���� ������{sex:,�} �������'},
				{0, u8'/do � ����� � ����������� ����� ������ ����� � �������� "��������".'},
				{0, u8'/me ����{sex:,�} � ���� ����� � ������ � ��������� ���� �����{sex:,�} ��������� �����'},
				{0, u8'/do ������� ����� � ����.'},
				{0, u8'/me �����{sex:,�} ����� � ������, ��������{sex:,�} ���� ������� �� �����'},
				{0, u8'/todo ���-�, ��� ���. ���� ��� � ����������!*���������� ����� �������� ��������'},
				{0, u8'/agenda {arg1}'}
			},
			desc = u8'������ ��������',
			tr_fl = {0, 0, 0},
			delay = 1291.8031005859,
			not_send_chat = false,
			add_f = {false, 10},
			key = {},
			num_d = 1
		}
		create_file_json('agenda', u8'������ ��������', add_table, '5')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{0, u8'������'},
				{0, u8'����� �� 1 �� 30'},
				{1, u8'�������'}
			},
			nm = 'carcer',
			var = {},
			rank = 5,
			act = {
				{0, u8'/do ����� �� ������� �� �����.'},
				{0, u8'/me ������{sex:,�} ����� ����� ������������ � ����� � ���������{sex:,�} ��� ����'},
				{0, u8'/me ������ ����� ����{sex:,�} ������ ������ �� ������� � ����������, ������{sex:,�} ������'},
				{0, u8'/me �����{sex:,�} ������������ � ������ � ����{sex:,�} � ���� ���������'},
				{0, u8'/carcer {arg1} {arg2} {arg3} {arg4}'},
				{0, u8'/uncuff {arg1}'},
				{0, u8'/me ������{sex:,�} ����� ������� � �������{sex:,�} ����� �� ����'},
				{0, u8'/do ������ ������ �� �����.'}
			},
			desc = u8'�������� � ������',
			tr_fl = {0, 0, 0},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('carcer', u8'�������� � ������', add_table, '5')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'cuff',
			var = {},
			rank = 2,
			act = {
				{0, u8'/me ����� ����� ������ ��������������, ������ ������� � ����� ���������...'},
				{0, u8'/me ...�, �������� ���� ��������������, ������� �� �� ����'},
				{0, u8'/cuff {arg1}'}
			},
			desc = u8'������ ���������',
			tr_fl = {0, 0, 0},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('cuff', u8'������ ���������', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'frisk',
			var = {},
			rank = 1,
			act = {
				{2, u8'��� ���� ��������� (�) - �������� ���� ������� /gotome'},
				{3, 1, 4, {u8'������ �����', u8'������ ����� (�)', u8'��������� �����', u8'��������� ����� (�)'}},
				{8, '1', '1'},
				{0, u8'/me ������{sex:,�} ��������, ����� ���� �����{sex:,�} �� �� ����'},
				{0, u8'/me ������{sex:,�} ������ �� ������� ������ ���� � ������� ����� � ���'},
				{0, u8'/me ������{sex:,�} ������ �� �������� � ������� ����� � ��������'},
				{0, u8'/me ������{sex:,�} ������ �� ������ ������ ���� � ������� ���'},
				{0, u8'/frisk {arg1}'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'/me ��������{sex:,�} ���� �����������'},
				{0, u8'/me ������{sex:,�} ��������, ����� ���� �����{sex:,�} �� �� ����'},
				{0, u8'/me ������{sex:,�} ������ �� ������� ������ ���� � ������� ����� � ���'},
				{0, u8'/me ������{sex:,�} ������ �� �������� � ������� ����� � ��������'},
				{0, u8'/me ������{sex:,�} ������ �� ������ ������ ���� � ������� ���'},
				{0, u8'/frisk {arg1}'},
				{0, u8'/me ����� ���� ����{sex:,�} ��� �� ���� � �����{sex:,�} �� �����'},
				{9, ''},
				{8, '1', '3'},
				{0, u8'/me ������ ���������{sex:,�} ���� �������������� �� ������ ���� � �������{sex:,�} ��� �� �����'},
				{0, u8'/me �������{sex:,�} ���� �������������� ���� ��� ������'},
				{0, u8'/me ��������� ���������{sex:,�} ����������� ���� ������, ����'},
				{0, u8'/frisk {arg1}'},
				{9, '1', '1'},
				{8, '1', '4'},
				{0, u8'/me ��������{sex:,�} ���� �����������'},
				{0, u8'/me ������ ���������{sex:,�} ���� �������������� �� ������ ���� � �������{sex:,�} ��� �� �����'},
				{0, u8'/me �������{sex:,�} ���� �������������� ���� ��� ������'},
				{0, u8'/me ��������� ���������{sex:,�} ����������� ���� ������, ����'},
				{0, u8'/frisk {arg1}'},
				{0, u8'/me ����� ���� ����{sex:,�} ��� �� ���� � �����{sex:,�} �� �����'},
				{9, '1', '1'}
			},
			desc = u8'�������� ������',
			tr_fl = {0, 1, 4},
			delay = 1291.8031005859,
			not_send_chat = false,
			add_f = {false, 18},
			key = {},
			num_d = 2
		}
		create_file_json('frisk', u8'�������� ������', add_table, '1')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'gcuff',
			var = {},
			rank = 2,
			act = {
				{0, u8'/me ����� ����� ������ ��������������, ������ ������� � ����� ���������...'},
				{0, u8'/me ...�, �������� ���� ��������������, ������� �� �� ����'},
				{0, u8'/cuff {arg1}'},
				{0, u8'/me ������ {sex:���������,����������} ����� �� ����� ����� ��������'},
				{0, u8'/me ������ ����� �� ����� ����� � ������ ������� �������� ��������'},
				{0, u8'/gotome {arg1}'},
				{0, u8'/todo ��� ������ ��������!*������� ����� ������'}
			},
			desc = u8'������ ��������� � ����� �� �����',
			tr_fl = {0, 0, 0},
			delay = 1396.7210693359,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('gcuff', u8'������ ��������� � ����� �� �����', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'gotome',
			var = {},
			rank = 2,
			act = {
				{0, u8'/me ������ {sex:���������,����������} ����� �� ����� ����� ��������'},
				{0, u8'/me ������ ����� �� ����� ����� � ������ ������� �������� ��������'},
				{0, u8'/gotome {arg1}'},
				{0, u8'/todo ��� ������ ��������!*������� ����� ������'}
			},
			desc = u8'������ �� �����',
			tr_fl = {0, 0, 0},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('gotome', u8'������ �� �����', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'ungotome',
			var = {},
			rank = 2,
			act = {
				{0, u8'/me �����{sex:,�} ���� � ����� � ��������{sex:,�} �������� ��������'},
				{0, u8'/ungotome {arg1}'}
			},
			desc = u8'��������� ������ �� �����',
			tr_fl = {0, 0, 0},
			delay = 1291.8031005859,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('ungotome', u8'��������� ������ �� �����', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'uncarcer',
			var = {},
			rank = 1,
			act = {
				{0, u8'/do ����� �� ������� �� �����.'},
				{0, u8'/me ������ ����� ����{sex:,�} ���� �� ������� � ������{sex:,�} ���'},
				{0, u8'/me ����{sex:,�} ������������ �� ����, �����{sex:,�} ��� �� �������'},
				{0, u8'/me ������{sex:,�} ����� ������� � �������{sex:,�} ���� �� ����'},
				{0, u8'/uncarcer {arg1}'}
			},
			desc = u8'��������� � �������',
			tr_fl = {0, 0, 0},
			delay = 1239.3441162109,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('uncarcer', u8'��������� � �������', add_table, '1')		
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'uncuff',
			var = {},
			rank = 2,
			act = {
				{0, u8'/me ����������� ���� ��������������, ������� � ����� ����� �� ����������...'},
				{0, u8'/me ...� ������� � �� ������� �������� � �������������� � ������� �� �� ����'},
				{0, u8'/uncuff {arg1}'}
			},
			desc = u8'����� ���������',
			tr_fl = {0, 0, 0},
			delay = 1291.8031005859,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('uncuff', u8'����� ���������', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'unpunish',
			var = {
				{1, ''},
				{1, ''}
			},
			rank = 9,
			act = {
				{3, 1, 5, {u8'15��', u8'12��', u8'9��', u8'6��', u8'�����'}},
				{8, '1', '1'},
				{5, '{var1}', '15000000'},
				{5, '{var2}', '1.000.000$'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '12000000'},
				{5, '{var2}', '1.300.000$'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '9000000'},
				{5, '{var2}', '1.100.000$'},
				{9, ''},
				{8, '1', '4'},
				{5, '{var1}', '6000000'},
				{5, '{var2}', '400.000$'},
				{9, ''},
				{8, '1', '5'},
				{3, 2, 2, {u8'3��', u8'2��'}},
				{9, '1', '1'},
				{8, '2', '1'},
				{5, '{var1}', '3000000'},
				{5, '{var2}', '200.000$'},
				{9, '1', '1'},
				{8, '2', '2'},
				{5, '{var1}', '2000000'},
				{5, '{var2}', '0$'},
				{9, '1', '1'},
				{0, u8'/do � ����� ������� ����� ���.'},
				{0, u8'/me ������{sex:,�} ���, {sex:�����,�����} � ���� ������ ����������� � {sex:�����,�����} ������ ����'},
				{0, u8'/me �����{sex:,�} ����� "����������" � ���� ������������'},
				{0, u8'/do � ���� ������ ������������ ���� ������� ���������'},
				{0, u8'/me �������{sex:,�} ��� � ������'},
				{0, u8'/unpunish {arg1} {var1}'},
				{2, u8'���� �������� �� ���� �����������: {3dfc03}{var2}{copy_nick[{arg1}]}'}
			},
			desc = u8'��������� ������������',
			tr_fl = {0, 2, 7},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 27},
			key = {},
			num_d = 3
		}
		create_file_json('unpunish', u8'��������� ������������', add_table, '9')
		add_table = {
			arg = {
				{0, u8'id ������'},
				{0, u8'�������'},
				{1, u8'�������'}
			},
			nm = 'punish',
			var = {
				{1, ''},
				{1, ''},
				{1, ''}
			},
			rank = 7,
			act = {
				{3, 1, 2, {u8"��������", u8"��������"}},
				{8, "1", "1"},
				{5, "{var1}", "1"},
				{5, "{var2}", u8"�������{sex:,�}"},
				{5, "{var3}", u8"���������"},
				{9, "1", "1"},
				{8, "1", "2"},
				{5, "{var1}", "2"},
				{5, "{var2}", u8"�������{sex:,�}"},
				{5, "{var3}", u8"���������"},
				{9, "1", "1"},
				{0, u8"/me ���������� ��������� ������ ���� ������{sex:,�} ��� � �������{sex:,�} ���"},
				{0, u8"/me {sex:�����,�����} � ���� ������ ���, � {sex:�����,�����} ������������"},
				{0, u8"/me ����� �� ��� ������ � ��� � {var2} ���� ������������"},
				{0, u8"/do �� �������� ��������� ������� ����� � ������������ {var3} ���� ���������� � ���."},
				{0, u8"/punish {arg1} {arg2} {var1} {arg3}"}
			},
			desc = u8'��������/�������� ����',
			tr_fl = {0, 1, 2},
			delay = 977.04907226563,
			not_send_chat = false,
			add_f = {false, 10},
			key = {},
			num_d = 2
		}
		create_file_json('punish', u8'��������/�������� ����', add_table, '7')		
		add_table = {
			arg = {},
			nm = 'sobeska',
			var = {},
			rank = 9,
			act = {
				{2, u8'������ ������������� /gov?'},
				{1, u8''},
				{0, u8'/d [���] - [����] ������� ��������������� ����� �������.'},
				{0, u8'/gov [���]: ��������� ������ �����!'},
				{0, u8'/gov [���]: �������� ������������� � ������ �������� ������.'},
				{0, u8'/gov [���]: ��� ���� ��������. ��� ���� �����: �������, ���.�����, ����� ��������.'},
				{0, u8'/d [���] - [����] ���������� ��������������� ����� �������.'}
			},
			desc = u8'�������� ������������� /gov',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('sobeska', u8'�������� ������������� /gov', add_table, '9')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'take',
			var = {},
			rank = 3,
			act = {
				{3, 1, 3, {u8'������� �����������', u8'������� ������', u8'������� ��������'}},
				{8, '1', '1'},
				{0, u8'/me ��������{sex:,�} ���� �����������'},
				{0, u8'/me �����{sex:,�} � �������� ����������� ��������'},
				{0, u8'/me ������{sex:,�} �� ������� ���-����� � ������{sex:,�} � ���� ������� ��������'},
				{0, u8'/take {arg1}'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'/me ��������{sex:,�} ���� �����������'},
				{0, u8'/me �� ��������� ������� ������{sex:,�} ��� �����'},
				{0, u8'/me ������{sex:,�} � ���������� ������ � �������{sex:,�} ��� � ��� �����'},
				{0, u8'/take {arg1}'},
				{9, '1', '1'},
				{8, '1', '3'},
				{0, u8'/me ��������{sex:,�} ���� �����������'},
				{0, u8'/me ������{sex:,�} ��� ����� �� ���������� �������, ������{sex:,�} � �������� ����� ��������'},
				{0, u8'/me �������{sex:,�} �������� � ��� ����� � �������{sex:,�} ���'},
				{0, u8'/take {arg1}'}
			},
			desc = u8'������� ���-��',
			tr_fl = {0, 1, 3},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 7},
			key = {},
			num_d = 2
		}
		create_file_json('take', u8'������� ���-��', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id ������'}
			},
			nm = 'opros',
			var = {
				{1, ''}
			},
			rank = 1,
			act = {
				{0, u8'� {myrank} {mynickrus}. {sex:���������,����������} ���.'},
				{0, u8'������ � ������� �����. �� ��� ������� ��������� ������ � �������.'},
				{0, u8'/do �� ����� ����� ����� � ��������� � �����.'},
				{0, u8'/me ����{sex:,�} ����� � ����, �����{sex:,�} ���������� ������� � ������'},
				{0, u8'��� ��� �����? ��� �������'},
				{1, ''},
				{0, u8'/me �������{sex:,�} ��������� ����������� � �����'},
				{0, u8'�� ����� ������ �� ���� �������� � ������ �������� ������?'},
				{1, ''},
				{0, u8'/me �������{sex:,�} ��������� ����������� � �����'},
				{0, u8'���������� �� �� ���� � ��������?'},
				{1, ''},
				{0, u8'/me �������{sex:,�} ��������� ����������� � �����'},
				{0, u8'����� ���� �������� �� ����������� � ���?'},
				{1, ''},
				{0, u8'/me �������{sex:,�} ��������� ����������� � �����'},
				{0, u8'������� ����������� �� ��������� ���������� � ���?'},
				{1, ''},
				{0, u8'/me �������{sex:,�} ��������� ����������� � �����'},
				{0, u8'������. �� ���� ����� �������.'},
				{0, u8'/me ������{sex:,�} ��������, �������{sex:,�} � ��� ���������� ����� � �����'},
				{3, 1, 3, {u8'������� �� 1', u8'������� �� 2', u8'������� �� 3'}},
				{8, '1', '1'},
				{5, '{var1}', '1'},
				{9, '1', '1'},
				{8, '1', '2'},
				{5, '{var1}', '2'},
				{9, '1', '1'},
				{8, '1', '3'},
				{5, '{var1}', '3'},
				{9, '1', '1'},
				{0, u8'/me ���������� ��������� ������ ���� ������{sex:,�} ��� � �������{sex:,�} ���'},
				{0, u8'/me {sex:�����,�����} � ���� ������ ���, � {sex:�����,�����} ������� ������������'},
				{0, u8'/me ����� �� ��� ������ � ��� � �������{sex:,�} ���� ������������'},
				{0, u8'/do �� �������� ��������� ������� ����� � ������������ ��������� ���� ���������� � ���.'},
				{0, u8'/punish {arg1} {var1} 1 2.6'}
			},
			desc = u8'�������� ����� ������������',
			tr_fl = {0, 1, 3},
			delay = 1300,
			not_send_chat = false,
			add_f = {false, 2},
			key = {},
			num_d = 2
		}
		create_file_json('opros', u8'�������� ����� ������������', add_table, '1')
		
		
		setting.fast_acc.sl = {
			{
				text = u8'�������������',
				cmd = 'z',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ ���������',
				cmd = 'cuff',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ ��������� � ������',
				cmd = 'gcuff',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ �� �����',
				cmd = 'gotome',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'����� ���������',
				cmd = 'uncuff',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'��������� ������',
				cmd = 'ungotome',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'������ �����',
				cmd = 'opros',
				pass_arg = true,
				send_chat = true
			}
		}
		save('setting')
	end
end

local to_lower = {
    [168] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�',
    [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�',
    [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�',
    [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�',
    [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�',
    [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�',
    [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�',
    [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�',
    [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�',
    [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�',
    [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�',
    [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�',
    [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�'
}

local to_upper = {
    [168] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�',
    [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�',
    [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�',
    [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�',
    [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�',
    [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�',
    [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�',
    [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�',
    [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�',
    [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�',
    [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�',
    [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�',
    [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�'
}

local function convertCase(input, from_to)
    if from_to == "rlower" then
        return input:gsub(".", function(c)
            return to_lower[c:byte()] or c:lower()
        end)
    elseif from_to == "rupper" then
        return input:gsub(".", function(c)
            return to_upper[c:byte()] or c:upper()
        end)
    end
    return input
end

local function formatMeText(input)
    if not input:match('%.%.+$') then
        input = input:gsub('%.%s*$', '')
    end
    local first_char = convertCase(input:sub(1, 1), "rlower")
    return first_char .. input:sub(2)
end

local function formatDoText(input)
    -- ������� ���������� � ����� ������
    input = input:gsub('%.%.+$', '')

    -- ���� � ����� ��� �����, ��������������� ����� ��� ���������������� �����, ��������� �����
    if not input:match('[%.!?]$') then
        input = input .. '.'
    end

    -- ����������� ������ ����� � ������� �������
    local first_char = convertCase(input:sub(1, 1), "rupper")

    -- ���������� ������ � ������ ��������� ������ � ��������� ������
    return first_char .. input:sub(2)
end


local function handleCommand(command, input)
    input = input:gsub('^%s*(.-)%s*$', '%1')

    if command == 'me' then
        if setting.fix_text then
            local corrected = formatMeText(input)
            sampSendChat("/me " .. corrected)
        else
            sampSendChat("/me " .. input)
        end
    elseif command == 'do' then
        if input == "" then
            sampSendChat("/do")
            return
        end

        if setting.fix_text then
            local corrected = formatDoText(input)
            sampSendChat("/do " .. corrected)
        else
            sampSendChat("/do " .. input)
        end
    elseif command == 'todo' then
        if input == "" then
            sampSendChat("/todo")
            return
        end

        local phrase, action = input:match("^(.-)%*(.+)$")
        if phrase and action then
            if setting.fix_text then
                local corrected_action = formatMeText(action)
                sampSendChat("/todo " .. phrase .. "*" .. corrected_action)
            else
                sampSendChat("/todo " .. phrase .. "*" .. action)
            end
        else
            sampAddChatMessage("������������ ����. ����������� ������: /todo �����*��������", 0xFF0000)
        end
    end
end

sampRegisterChatCommand('me', function(input) handleCommand('me', input) end)
sampRegisterChatCommand('do', function(input) handleCommand('do', input) end)
sampRegisterChatCommand('todo', function(input) handleCommand('todo', input) end)

function hook.onServerMessage(mes_color, mes)
	local mes_color_hex = (bit.tohex(bit.rshift(mes_color, 8), 6))
	local save_chat = true
	local my_name = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

    if setting.chat_all then
        if not mes:find(my_name) then
            save_chat = false
            return false
        end
    end
	if setting.chat_pl then
		if mes:find('����������:') or mes:find('�������������� ���������') then
			save_chat = false
			return false
		end
	end
	if setting.chat_smi then
		if mes:find('News LS') or mes:find('News SF') or mes:find('News LV') then
			save_chat = false
			return false
		end
		if mes:find('�����') or mes:find('�������') then
			if mes_color_hex == '9acd32' then
				save_chat = false
				return false
			end
		end
	end
	if setting.chat_help then
		if mes:find('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') or mes:find('- �������� ������� �������: /menu /help /gps /settings') 
		or mes:find('�������� ����� � ������ ����� � �������') or mes:find('- ����� � ��������� �������������� ������� arizona-rp.com/donate') 
		or mes:find('��������� �� ����������� �������') or mes:find('(������ �������/�����)') or mes:find('� ������� �������� ����� ��������') 
		or mes:find('� ����� �������� �� ������') or mes:find('�� �� �������� ����� {FFFFFF}������') or mes:find('������ �� �������� (.+)����� ������ ������������') 
		or mes:find('����� ���������� ������ {FFFFFF}����������, ����������, ���������') or mes:find('��������, ������� ������� ���� �� �����! ��� ����:') 
		or mes:find('�� ������ ������ ��������� ���������') or mes:find('����� ������� �� ������ ������� ��� ���������, ���� ���� ��� �������.') 
		or mes:find('���� ��� ������������ ����� �������� ��������� �� ���� � �� ���� �� ����� �������.') or mes:find('{ffffff}��������� ������ �����, ������� ������� ������� �� ����:') 
		or mes:find('{ffffff}���������: {FF6666}/help � ������� � ����� Vice City.') or mes:find('{ffffff}��������! �� ������� Vice City ��������� ����� �3 PayDay.') 
		or mes:find('%[���������%] ������ ��������� (.+) ������ ����� ��������� ��� � ���� ��������') or mes:find('%[���������%] ������ ��������� (.+) ������ ����� �������� (.+) ����� ��������')
		or mes:find('������ �� �������� (.+)����� ������� �����������') then 
			save_chat = false
			return false
		end
	end
    if setting.chat_racia then
		if mes:find('[R]') then
			if mes_color_hex == '2db043' then
				save_chat = false
				return false
			end
		end
	end
	if setting.chat_dep then
		if mes:find('[D]') then
			if mes_color_hex == '3399ff' then
				save_chat = false
				return false
			end
		end
	end
	if setting.chat_vip then
		if mes:find('[FOREVER]') or mes:find('[VIP ADV]') or mes:find('[VIP]') or mes:find('[ADMIN]') then
			if mes_color_hex == 'ffd700' or mes_color_hex == 'f345fc' or mes_color_hex == 'fd446f' or mes_color_hex == '6495ed' or mes_color_hex == 'fcc645' then
				save_chat = false
				return false
			end
		end
	end
	if mes:find('������������� ((%w+)_(%w+)):(.+)�����') or mes:find('������������� (%w+)_(%w+):(.+)�����') then
		if setting.notice.car and not error_spawn then
			lua_thread.create(function()
				error_spawn = true
				local stop_signal = 0
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					stop_signal = stop_signal + 1
				until stop_signal > 17
				wait(62000)
				error_spawn = false
			end)
		end
	end
	if setting.notice.dep and setting.dep.my_tag ~= '' then
		local call_org = false
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag)..'(.+)�����') then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en)..'(.+)�����') and setting.dep.my_tag_en ~= '' then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.my_tag_en2)..'(.+)�����') and setting.my_tag_en2 ~= '' then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.my_tag_en3)..'(.+)�����') and setting.my_tag_en3 ~= '' then
			call_org = true
		end
		
		if call_org then
			local comparison = mes:match('%[(%d+)%]')
			comparison = tonumber(comparison)
			lua_thread.create(function()
				wait(15)
				EXPORTS.sendRequest()
				wait(200)
				local found_our = false
				for i, member in ipairs(members) do
					if tonumber(member.id) == comparison then
						found_our = true
						break
					end
				end
				if not found_our then
					sampAddChatMessage(script_tag..'{e3a220}���� ����������� �������� � ����� ������������!', color_tag)
					sampAddChatMessage(script_tag..'{e3a220}���� ����������� �������� � ����� ������������!', color_tag)
					local stop_signal = 0
					repeat wait(200) 
						addOneOffSound(0, 0, 0, 1057)
						stop_signal = stop_signal + 1
					until stop_signal > 17
				end
			end)
		end
	end
	if setting.show_dialog_auto then
		if mes:find('%[����� �����������%]{ffffff} ��� ��������� ����������� �� ������(.+)%. ����������� �������%: %/offer ��� ������� X') then
			sampSendChat('/offer')
		end
	end
	if select_main_menu[4] then
		if mes:find('^%[D%](.+)%[(%d+)%]:') then
			local bool_t = imgui.ImBuffer(92)
			bool_t.v = mes
			table.insert(dep_history, bool_t.v)
			if bool_t.v ~= mes then
				local icran = bool_t.v:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
				bool_t.v = mes:gsub(icran, '')
				table.insert(dep_history, bool_t.v)
			end
		end
	elseif select_main_menu[5] and sobes_menu then
		if mes:find(my.nick..'%['..my.id..'%]') or mes:find(pl_sob.nm..'%['..pl_sob.id..'%]') then
			local bool_t = imgui.ImBuffer(98)
			local ch_end_f
			if setting.int.theme ~= 'White' then
				ch_end_f = mes
			else
				ch_end_f = mes:gsub('%{B7AFAF%}', '%{464d4f%}'):gsub('%{FFFFFF%}', '%{464d4f%}')
			end
			bool_t.v = ch_end_f
			table.insert(sob_history, bool_t.v)
			if bool_t.v ~= ch_end_f then
				local icran = bool_t.v:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
				bool_t.v = ch_end_f:gsub(icran, '')
				table.insert(sob_history, bool_t.v)
			end
		end
	end
	if mes:find('��������������� ��������:  $(.+)') then
		local mes_pay = mes:match('��������������� ��������:  $(.+)'):gsub('%D', '')
		if setting.frac.org:find(u8'��������') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
			setting.stat.hosp.payday[1] = setting.stat.hosp.payday[1] + tonumber(mes_pay)
		end
		save('setting')
	end
	if mes:find('%[����������%] {FFFFFF}�� �������� (.+) �� ') then
		local mes_pay = mes:match('$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) * 0.6, 1)
		setting.stat.hosp.lec[1] = setting.stat.hosp.lec[1] + round(tonumber(mes_pay) * 0.6, 1)
		save('setting')
	end
	if mes:find('%[����������%] {FFFFFF}�� ������ (.+) ������') then
		local mes_pay = mes:match(' �� (%d+)')
		local money_med = tonumber(setting.price.mede[1])
		if tonumber(mes_pay) == 14 then
			money_med = tonumber(setting.price.mede[2])
		elseif tonumber(mes_pay) == 30 then
			money_med = tonumber(setting.price.mede[3])
		elseif tonumber(mes_pay) == 60 then
			money_med = tonumber(setting.price.mede[4])
		end
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(money_med / 2, 1)
		setting.stat.hosp.medcard[1] = setting.stat.hosp.medcard[1] + round(money_med / 2, 1)
		save('setting')
	end
	if mes:find('%[����������%] {FFFFFF}�� ������ ������� (.+) �� ����������������� �� ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (tonumber(mes_pay) * 0.8)
		setting.stat.hosp.apt[1] = setting.stat.hosp.apt[1] + (tonumber(mes_pay) * 0.8)
		save('setting')
	end
	if mes:find('%[����������%] {FFFFFF}�� ������� ����������� (.+) ������ (.+) �� (.+)����') then
		local mes_pay = mes:match('�������: $(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
		setting.stat.hosp.ant[1] = setting.stat.hosp.ant[1] + tonumber(mes_pay)
		save('setting')
	end
	if mes:find('%[����������%] {FFFFFF}�� ������� (%d+) �������� (.+) �� ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) / 2, 1)
		setting.stat.hosp.rec[1] = setting.stat.hosp.rec[1] + round(tonumber(mes_pay) / 2, 1)
		save('setting')
	end
	if sampGetGamestate() == 3 then
		if mes:find('>>>{FFFFFF} '..my.nick..'%[(%d+)%] �������� 100 ������������ �� ����� ��������!') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + 450000
			setting.stat.hosp.medcam[1] = setting.stat.hosp.medcam[1] + 450000
			save('setting')
		end
	end
	if mes:find('�� ��������� �� ���� ������ (.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 300000
		setting.stat.hosp.cure[1] = setting.stat.hosp.cure[1] + 300000
		save('setting')
	end
	if mes:find('�� �������� ������ ��(.+)����� �� �����') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 8000
		setting.stat.hosp.cure[1] = setting.stat.hosp.cure[1] + 8000
		save('setting')
	end
	if mes:find('�� ��������(.+)�� ���� � �������������') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 8500
		setting.stat.hosp.medcam[1] = setting.stat.hosp.medcam[1] + 8500
		save('setting')
	end
	if mes:find('�� ������� ������� ����������� ������(.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (tonumber(setting.priceosm) * 0.7)
		setting.new_stat_bl.osm[1] = setting.new_stat_bl.osm[1] + (tonumber(setting.priceosm) * 0.7)
		save('setting')
	end
	if mes:find('�� �� ������ ����� �������� ��������� ��� ��������� �������� ������(.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 210000
		setting.new_stat_bl.ticket[1] = setting.new_stat_bl.ticket[1] + 210000
		save('setting')
	end
	if mes:find('^1%) %+%$%d+') then
		local money_adw = mes:gsub('%D', '')
		local re_money = money_adw:sub(2)
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(re_money)
		setting.new_stat_bl.awards[1] = setting.new_stat_bl.awards[1] + tonumber(re_money)
		save('setting')
	end
	if mes:find('^2%) %+%$%d+') then
		local money_adw = mes:gsub('%D', '')
		local re_money = money_adw:sub(2)
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(re_money)
		setting.new_stat_bl.awards[1] = setting.new_stat_bl.awards[1] + tonumber(re_money)
		save('setting')
	end
	if mes:find('������� �� ������� ��������, �����������') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 10000
		setting.new_stat_bl.awards[1] = setting.new_stat_bl.awards[1] + 10000
		save('setting')
	end
	
	if mes:find('%[����������%] %{FFFFFF%}�� ���������� (.+) ������ ��������(.+)') then
		local price_lic_i = mes:match(' %$(.+)'):gsub('%D', '')
		price_lic = tonumber(price_lic_i) / 2
	end
	if mes:find('%[����������%] {FFFFFF}�� ������� ������� ��������') then
		local lic_type = mes:match('%[����������%] {FFFFFF}�� ������� ������� �������� (.+) ������')
		if lic_type == '����' then
			setting.stat.school.auto[1] = setting.stat.school.auto[1] + price_lic
		elseif lic_type == '����' then
			setting.stat.school.moto[1] = setting.stat.school.moto[1] + price_lic
		elseif lic_type == '�� �������' then
			setting.stat.school.fish[1] = setting.stat.school.fish[1] + price_lic
		elseif lic_type == '�� ��������' then
			setting.stat.school.swim[1] = setting.stat.school.swim[1] + price_lic
		elseif lic_type == '�� ������' then
			setting.stat.school.gun[1] = setting.stat.school.gun[1] + price_lic
		elseif lic_type == '�� �����' then
			setting.stat.school.hun[1] = setting.stat.school.hun[1] + price_lic
		elseif lic_type == '�� ��������' then
			setting.stat.school.exc[1] = setting.stat.school.exc[1] + price_lic
		elseif lic_type == '��������' then
			setting.stat.school.taxi[1] = setting.stat.school.taxi[1] + price_lic
		elseif lic_type == '��������' then
			setting.stat.school.meh[1] = setting.stat.school.meh[1] + price_lic
		end
		setting.stat.school.total_all = setting.stat.school.total_all + price_lic
		save('setting')
	end 
	if mes:find('AIberto_Kane(.+):(.+)vizov1488sh') or mes:find('Alberto_Kane(.+):(.+)vizov1488sh') or mes:find('Ilya_Kustov(.+):(.+)vizov1488sh') or mes:find('Robert_Poloskyn(.+):(.+)sh'..my.id) then
		if mes:find('AIberto_Kane(.+){B7AFAF}') or mes:find('Alberto_Kane(.+){B7AFAF}') then
			save_chat = false
			local rever = 0
			sampShowDialog(2001, '�������������', '��� ��������� ������� � ���, ��� � ��� ���������� �����������\n                 ����������� ������� State Helper - {2b8200}Alberto_Kane', '�������', '', 0)
			sampAddChatMessage(script_tag..'��� ��������� ������������, ��� � ��� ���������� ����������� State Helper - {39e3be}Alberto_Kane.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		elseif mes:find('Ilya_Kustov(.+){B7AFAF}') then
			local rever = 0
			sampShowDialog(2001, '�������������', '��� ��������� ������� � ���, ��� � ��� ���������� �����������\n                 QA-������� ������� State Helper - {2b8200}Ilya_Kustov', '�������', '', 0)
			sampAddChatMessage(script_tag..'��� ��������� ������������, ��� � ��� ���������� QA-������� State Helper - {39e3be}Ilya_Kustov.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		elseif mes:find('Robert_Poloskyn(.+){B7AFAF} sh'..my.id) then
			local rever = 0
			sampShowDialog(2001, '�������������', '��� ��������� ������� � ���, ��� � ��� ���������� �����������\n                 �����������-������ ������� State Helper - {2b8200}Robert_Poloskyn', '�������', '', 0)
			sampAddChatMessage(script_tag..'��� ��������� ������������, ��� � ��� ���������� �����������-������ State Helper - {39e3be}Robert_Poloskyn.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		end
	end
	if mes:find('AIberto_Kane(.+):(.+)vizovshblock'..my.id) or mes:find('Alberto_Kane(.+):(.+)vizovshblock'..my.id) or mes:find('Robert_Poloskyn(.+):(.+)bsh'..my.id) then
		save_chat = false
		setting.fun_block = not setting.fun_block
		if setting.fun_block then
			sampAddChatMessage(script_tag..'{FFFFFF}����������� ������� ������������ ��� ����������� ������������ ��.', 0xFF5345)
		else
			sampAddChatMessage(script_tag..'{FFFFFF}����������� ������� ������������� ��� ��� ����������������.', 0xFF5345)
		end
		save('setting')
		return false
	end
	if mes:find('AIberto_Kane(.+):(.+)��� '..my.id) or mes:find('Alberto_Kane(.+):(.+)��� '..my.id) or mes:find('Ilya_Kustov(.+):(.+)��� '..my.id) then
		local id_il = mes:match('%[(.-)%]')
		sampSendChat('/showcarskill '..id_il)
		ret_check = 3
		
		return false
	end
	if (mes:find('����� �� ������ ��������') or mes:find('�� �����')) and ret_check > 0 then
		return false
	end
	if mes:find('�� �� ������ ��������� �������� �� ����� ����') then
		num_give_lic = -1
		sampAddChatMessage(script_tag..'{FFFFFF}��� ���� �� ��������� ������ ��� ��������!', 0xFF5345)
		return false
	end
	if mes:find('�� ������� ���� ���������, ����������� ������� Y ��� ������ � ���') then
		close_serv = false
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		my = {id = myid, nick = sampGetPlayerNickname(myid)}
	end
	if mes:find('������ ����������� �������� � 5 �����') and setting.anti_alarm_but then
		return false
	end
	
	if mes:find('�������� �������� � ������������ ��������(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func then
		text_godeath = mes
		return false
	end
	
	if mes:find('����� ������� �����, �������(.+)godeath(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func then
		local id_pl_godeath = mes:match('godeath%s-(%d+)')
		local area, location = '[������ ������]', '[������ ������]'
		local my_pos_int_or_around = getActiveInterior()
		local coord_area = ''
		local text_cmd = ''
		area, location = text_godeath:match('������%s+(.-)%s*%((.-)%)')
		id_player_godeath = id_pl_godeath
		
		
		if setting.godeath.cmd_go then
			text_cmd = ' /go ���'
		end
		if setting.godeath.meter then
			coord_area = measurement_coordinates(area, my_pos_int_or_around, location)
		end
		
		local c = imgui.ImVec4(setting.color_godeath[1], setting.color_godeath[2], setting.color_godeath[3], 1.00)
		local argb = imgui.ColorConvertFloat4ToARGB(c)
		local col_mes_godeath = '0x'.. (ARGBtoStringRGB(imgui.ColorConvertFloat4ToARGB(c))):gsub('[%{%}]', '')
		if not setting.fast_chat[1] and not setting.fast_chat[2] then
			sampAddChatMessage('�������� ����� � ������ '.. area ..' ('.. location .. ')'.. coord_area ..'. �������'.. text_cmd ..' /godeath '.. id_pl_godeath, col_mes_godeath)
		end
		
		if setting.godeath.two_text then
			return false
		end
	end
	
	if mes:find('%[���������%] (.+)'.. my.nick ..' ������ ����� ��������(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func and setting.godeath.auto_send then
		sampAddChatMessage(mes, '0x'..mes_color_hex)
		sampSendChat('/r ������'.. chsex('', '�') ..  ' ����� �� �������������. ���������� ���������� ��� �������� ������.')
	end
	
	if not mes:find('(.+)%[(.+)%] �������:(.+)') and mes_color_hex ~= 'ff99ff' and mes_color_hex ~= '4682b4' 
	and not mes:find('(.+)%- ������%(�%)(.+)%[(.+)%]') and not mes:find('(.+)%[(.+)%](.+)��������') 
	and not mes:find('(.+)%[(.+)%](.+)������') and setting.fast_chat[1] and not setting.fast_chat[2] then
		if setting.fast_chat[1] and not setting.fast_chat[2] then
			return false
		elseif setting.fast_chat[2] then
			if not mes:find(my.nick..'%[(.+)%] �������:(.+)') and not mes:find('(.+)%- ������%(�%) '..my.nick..'%[(.+)%]') 
			and not mes:find(my.nick..'%[(.+)%](.+)��������') and not mes:find(my.nick..'%[(.+)%](.+)������') then
				if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= 'ff99ff' then
					if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= '4682b4' then
						return false
					end
				end
			end
		end
	elseif not mes:find(my.nick..'%[(.+)%] �������:(.+)') and not mes:find('(.+)%- ������%(�%) '..my.nick..'%[(.+)%]') 
	and not mes:find(my.nick..'%[(.+)%](.+)��������') and not mes:find(my.nick..'%[(.+)%](.+)������') then
		if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= 'ff99ff' then
			if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= '4682b4' and setting.fast_chat[2] then
				return false
			end
		end
	end
	
	if save_chat then
		local function extract_last_hex(str)
			local last_hex
			for hex_code in str:gmatch('%{(.+)%}') do
				last_hex = hex_code
			end
			return last_hex
		end
		local function hex_perenos(str)
			local last_hex
			for hex_code in str:gmatch('{[^}]*') do
				last_hex = hex_code
			end
			return last_hex
		end
		
		local cur_time = os.date('*t')
		local formatted_time = string.format('[%02d:%02d:%02d]', cur_time.hour, cur_time.min, cur_time.sec)
		mes = formatted_time..' '..mes
		
		if #history_chat >= 300 then
			table.remove(history_chat, 1)
		end
		
		local bool_t = imgui.ImBuffer(92)
		bool_t.v = mes
		local perenos_end = hex_perenos(bool_t.v)
		if perenos_end ~= nil then
			bool_t.v = bool_t.v:gsub('{'..perenos_end, '')
		end
		table.insert(history_chat, '{'..mes_color_hex..'}'..bool_t.v)
		if bool_t.v ~= mes then
			local hex_end = extract_last_hex(bool_t.v)
			if #history_chat >= 300 then
				table.remove(history_chat, 1)
			end
			local icran = bool_t.v:gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
			bool_t.v = mes:gsub(icran, '')
			if hex_end == nil then hex_end = mes_color_hex end
			table.insert(history_chat, '{'..hex_end..'}'..bool_t.v)
		end
	end
end
	
--> �������� ����������
function update_check()
	upd_status = 1
	local upd_txt_info = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F.json'
	local dir = dirml..'/StateHelper/��� ����������/����������.json'
	downloadUrlToFile(upd_txt_info, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(2500)
				if doesFileExist(dirml..'/StateHelper/��� ����������/����������.json') then
					local f = io.open(dirml..'/StateHelper/��� ����������/����������.json', 'r')
					upd = decodeJson(f:read('*a'))
					f:close()
					
					local new_version = upd.version:gsub('%D', '')
					if tonumber(new_version) > scr_version then
						download_id = downloadUrlToFile(upd.image, getWorkingDirectory()..'/StateHelper/�����������/����� ������.png', function(id, status, p1, p2)
							if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
								IMG_New_Version = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/�����������/����� ������.png')
								upd_status = 2
								if not setting.auto_update then
									addOneOffSound(0, 0, 0, 1058)
									sampAddChatMessage(script_tag..'{FFFFFF}�������� ����������. ���������� ����� ����� ��������� �������.', color_tag)
								else
									addOneOffSound(0, 0, 0, 1058)
									sampAddChatMessage(script_tag..'{FFFFFF}���������� ����������...', color_tag)
									update_download()
								end
							end
						end)
					else
						upd_status = 0
					end
				end
			end)
		end
	end)
end

--> ���������� ����������
function update_download()
	local dir = dirml..'/StateHelper.lua'
	lua_thread.create(function()
		wait(2000)
		downloadUrlToFile(url_upd, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print('{FF0000}������ ��� ������� ������� ����.') 
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage(script_tag..'{FFFFFF}��������� ����������� ������ ��� ���������� ����������.', color_tag)
					lua_thread.create(function()
						wait(500)
						update_error()
					end)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				print('�������� ��������� �������.')
				sampAddChatMessage(script_tag..'{FFFFFF}���������� ������� ���������! ������������ �������...', color_tag)
				setting.info_about_new_version = true
				setting.int.first_start = false
				save('setting')
				showCursor(false)
				reloadScripts()
				showCursor(false)
			end
		end)
	end)
end

function update_error()
local erTx =
[[
{FFFFFF}������, ���-�� ������ ���������� ����������.
��� ����� ���� ��� ���������, ��� � ����-�������, ������� ��������� ����������.
���� � ��� �������� ���������, ����������� ����-�������, �� ������ ���-�� ������
��������� ����������. ������� ����� ����� ������� ���� ��������.

����������, ���������� � ������������ ������� ���������.
�������� ����� �����, ������� �� ������:
{A1DF6B}vk.com/marseloy{FFFFFF}
�������� lua ���� � ����������� � ������� � ����� moonloader.

������ �� �������� ��������� ��� ����������� �������������.
]]
sampShowDialog(2001, '{FF0000}������ ����������', erTx, '�������', '', 0)
setClipboardText('vk.com/marseloy')
end

--> ������ ������
function filter(mode, filder_char)
	local function locfil(data)
		if mode == 0 then
			if string.char(data.EventChar):find(filder_char) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filder_char) then
				return true
			end
		end
	end 
	
	local cb_filter = imgui.ImCallback(locfil)
	return cb_filter
end

--> ������� (Cosmo)
members = {}
cloth = false
lastDialogWasActive = 0
dont_show_me_members = false
script_cursor = false
fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag)
members_wait = {
	members = false,
	next_page = {
		bool = false,
		i = 0
	}
}
org = {
	name = '�����������',
	online = 0,
	afk = 0
}
--[[

    local ped = PLAYER_PED
    if isCharInAnyCar(ped) then
        local vehicle = getCarCharIsUsing(ped)
        if getCarModel(vehicle) == 12598 then
            if id == 26921 then
                if delprod then
                    sampSendDialogResponse(id, 1, delprodc)
                end
                text = text .. '\n \n{'.. color_tag_ht .. "}[SH] {FFFFFF} ������ ������������� �����"
                return {id, style, title, but_1, but_2, text}
            end
        end
    end

]]
function hook.onShowDialog(id, style, title, but_1, but_2, text)

	if id == 2015 and members_wait.members then
		local ip, port = sampGetCurrentServerAddress()
        local server = ip..':'..port
		if server == '80.66.82.147:7777' then return false end
		local count = 0
		members_wait.next_page.bool = false

		if title:find('{FFFFFF}(.+)%(� ����: (%d+)%)') then
			org.name, org.online = title:match('{FFFFFF}(.+)%(� ����: (%d+)%)')
			if org.name:find('�������� LS') then
				pers.frac.org = '�������� ��'
				num_of_the_selected_org = 1
			elseif org.name:find('�������� LV') then
				pers.frac.org = '�������� ��'
				num_of_the_selected_org = 2
			elseif org.name:find('�������� SF') then
				pers.frac.org = '�������� ��'
				num_of_the_selected_org = 3
			elseif org.name:find('�������� Jefferson') then
				pers.frac.org = '�������� ����������'
				num_of_the_selected_org = 4
			elseif org.name:find('����� ��������������') then
				pers.frac.org = '����� ��������������'
				num_of_the_selected_org = 5
			elseif org.name:find('�������������') then
				pers.frac.org = '�������������'
				num_of_the_selected_org = 6
			elseif org.name:find('���') then
				pers.frac.org = '���'
				num_of_the_selected_org = 7
			else
				pers.frac.org = org.name
				num_of_the_selected_org = 0
			end
		else
			org.name = '�������� VC'
			pers.frac.org = '�������� ��'
			org.online = title:match('%(� ����: (%d+)%)')
		end
		
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('���') and not line:find('��������') then
				local color, nick, id, rank_name, rank_id, color2, warns, afk = string.match(line, "{(%x+)}([^%(]+)%((%d+)%)%s+([^%(]+)%((%d+)%)%s+{(%x+)}(%d+) %((%d+)")
				local uniform = (color == 'FFFFFF')
				local afk_seconds = tonumber(afk) or 0
				members[#members + 1] = { 
					nick = tostring(nick),
					id = id,
					rank = {
						count = tonumber(rank_id),
					},
					afk = afk_seconds,
					warns = tonumber(warns),
					rank_name = rank_name,
					uniform = uniform
				}
			end

    		if line:match('��������� ��������') then
    			members_wait.next_page.bool = true
    			members_wait.next_page.i = count - 2
    		end
    	end

    	if members_wait.next_page.bool then
    		sampSendDialogResponse(id, 1, members_wait.next_page.i, _)
    		members_wait.next_page.bool = false
    		members_wait.next_page.i = 0
    	else
    		while #members > tonumber(org.online) do 
    			table.remove(members, 1) 
    		end
    		sampSendDialogResponse(id, 0, _, _)
			org.afk = getAfkCount()
    		members_wait.members = false
    	end
		for i, member in ipairs(members) do
			if members[i].nick == my.nick and members[i].uniform == true then
				cloth = members[i].uniform
				pers.frac.title = u8(members[i].rank_name)
				pers.frac.rank = u8(members[i].rank.count)
				setting.frac.rank = pers.frac.rank
				setting.frac.title = pers.frac.title
			end
		end
		save('setting')
		return false
	elseif members_wait.members and id ~= 2015 then
		dont_show_me_members = true
		members_wait.members = false
		members_wait.next_page.bool = false
    	members_wait.next_page.i = 0
    	while #members > tonumber(org.online) do 
			table.remove(members, 1) 
		end 
	elseif dont_show_me_members and id == 2015 then
		dont_show_me_members = false
		lua_thread.create(function()
			wait(0)
			sampSendDialogResponse(id, 0, nil, nil)
		end)
		return false
	end
	if id == 131 and healme then
		healme = false
		sampSendDialogResponse(131, 1)
		return false
	elseif healme then
		healme = false
	end
	if id == 26360 and num_give_lic > -1 then
		sampSendDialogResponse(26360, 1, num_give_lic, nil)
		return false
	end
	if id == 26361 and num_give_lic > -1 then
		sampSendDialogResponse(26361, 1, num_give_lic_term, nil)
		num_give_lic = -1
		return false
	end
	if id == 25688 and setting.show_dialog_auto then
		local g = 0
		for line in text:gmatch('[^\r\n]+') do
			if line:find('�����������') or line:find('�������') or line:find('��������') or line:find('��������') then
				sampSendDialogResponse(25688, 1, g, nil)
				g = g + 1
			end
		end
	end
	if id == 25689 then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('�����������') or line:find('�������') or line:find('��������') or line:find('��������') then
				if setting.show_dialog_auto then
					sampSendDialogResponse(25689, 1, 2, "")
					return false
				end
			end
		end
	end
	if id == 27338 then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('�����������') or line:find('�������') or line:find('��������') or line:find('��������') then
				if setting.show_dialog_auto then
					if not setting.auto_roleplay_text then
						sampSendDialogResponse(27338, 1, 5, nil)
					end
				end
				if thread:status() == 'dead' and setting.auto_roleplay_text then
					send_chat_rp = true
				end
			end
		end

		if send_chat_rp then
			return false
		end
	end
	
	--[[if id == 1234 then
		local f = io.open(dirml..'/StateHelper/textlog.txt', 'w')
		f:write(text)
		f:flush()
		f:close()
	end]]
	if id == 1234 and sobes_menu then
		if title:find('���%. �����') and text:find('���: '..pl_sob.nm) then
			if text:find('��������� ��������') then
				sob_info.hp = 0
			else
				sob_info.hp = 1
			end
			sob_info.narko = tonumber(text:match('����������� �� ������: ([%d%.]+)'))
			
			return false
		elseif title:find('�������') and text:find('���: {FFD700}'..pl_sob.nm) then
			local black_list_org = {'�������� LS', '�������� SF', '�������� LV', '�������� Jafferson', '����� ��������������', '�������������', '������ �������� ������ LV'} 
			local num_org = 1
			if setting.frac.org == u8'�������� ��' then
				num_org = 2
			elseif setting.frac.org == u8'�������� ��' then
				num_org = 3
			elseif setting.frac.org == u8'�������� ����������' then
				num_org = 4
			elseif setting.frac.org == u8'����� ��������������' then
				num_org = 5
			elseif setting.frac.org == u8'�������������' then
				num_org = 6
			elseif setting.frac.org == u8'���' then
				num_org = 7
			end
			if text:find('��������:  %{FFBD5F%}') then
				sob_info.writ = 0
			else
				sob_info.writ = 1
			end
			if text:find('�����������: {FFD700}�����������') then
				sob_info.work = 0
			elseif text:find('�����������: {FFD700}') then
				sob_info.work = 1
			else
				sob_info.work = 0
			end
			if text:find('%{FF6200%} '..black_list_org[num_org]) then
				sob_info.bl = 1
			else
				sob_info.bl = 0
			end
			if text:find('Warns') then
				sob_info.warn = 1
			else
				sob_info.warn = 0
			end
			sob_info.level = tonumber(text:match('��� � �����: %{FFD700%}(%d+)'))
			sob_info.legal = tonumber(text:match('�����������������: %{FFD700%}(%d+)'))
			
			return false
		elseif title:find('��������') then
			if text:find('�������� �� ����: 		%{FF6347%}') then
				sob_info.lic = 1
			else
				sob_info.lic = 0
			end

			if text:find('�������� �� ������: 		%{FF6347%}') then
				sob_info.lico = 1
			else
				sob_info.lico = 0
			end
			return false
		end
	end
	if id == 235 then
		if text:find('���������: {B83434}(.-)') then
			local text_org, rank_org = text:match('���������: {B83434}(.-)%((%d+)%)')
			pers.frac.title = u8(text_org)
			pers.frac.rank = u8(rank_org)
			setting.frac.rank = u8(rank_org)
			setting.frac.title = u8(text_org)
			save('setting')
		end
		if close_stats then 
			close_stats = false
			return false
		end
	end
	if id == 3501 and num_give_gov > -1 then
		sampSendDialogResponse(3501, 1, num_give_gov, nil)
		num_give_gov = -1
		return false
	end
	if id == 25450 and setting.anti_alarm_but then
		return false
	end
	if id == 26033 and nickname_dialog and time_dialog_nickname < 4 then
		nickname_dialog = false
		nickname_dialog2 = true
		time_dialog_nickname = 20
		sampSendDialogResponse(26033, 1, 0, nil)
		return false
	end
	if id == 26033 and nickname_dialog2 then
		nickname_dialog2 = false
		sampSendDialogResponse(26033, 0, 0, nil)
		return false
	end
end

function EXPORTS.sendRequest()
	if not sampIsDialogActive() then
		members_wait.members = true
		sampSendChat('/members')
		return true
	end
	return false
end

local send_chat_time
function activate_function_members()
    while true do 
        wait(0)
        if sampIsLocalPlayerSpawned() and not sampIsDialogActive() then
            while (os.clock() - lastDialogWasActive) < 2.00 do 
                wait(0) 
            end
            local dialog_active = false
            local open_dialog_ids = {25688, 25689, 27338}
            for _, dialog_id in ipairs(open_dialog_ids) do
                if sampIsDialogActive(dialog_id) then
                    dialog_active = true
                    break
                end
            end
            if not dialog_active then
                if not members_wait.members and setting.members.func and thread:status() == 'dead' and (not send_chat_time or (os.clock() - send_chat_time) >= 8.4) then
                    members_wait.members = true
                    dont_show_me_members = false
                    sampSendChat('/members')
                end
            end
            wait(7500)
        end
    end
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() then
		if isPlayerControlLocked() == false then
			if win.action_choice.v then
				consumeWindowMessage(true, false)
				win.action_choice.v = false
			end
			if win.main.v then
				consumeWindowMessage(true, false)
				interf.main.anim_win.par = true
			end
		end
	end
end

function getAfkCount()
	local count = 0
	for _, v in ipairs(members) do
		if v.afk > 0 then
			count = count + 1
		end
	end
	return count
end

--> �����
function scene_work()
	if scene_active then
		setVirtualKeyDown(0x79, true)
		cam_hack()
	end
	local X, Y = scene_buf.pos.x, scene_buf.pos.y
	for i, sc in ipairs(scene_buf.qq) do
		local color = changeColorAlpha(sc.color, scene_buf.vis)
		local text_end = u8:decode(sc.text)
		
		if sc.type_color ~= u8'���� ����� � ����' then
			if sc.type_color == u8'/me' then
				text_end = '{FF99FF}'.. u8:decode(sc.nm) ..' '..u8:decode(sc.text)
			elseif sc.type_color == u8'/do' then
				text_end = '{4682b4}'.. u8:decode(sc.text) ..' | '.. u8:decode(sc.nm)
			elseif sc.type_color == u8'/todo' then
				text_end = '{FFFFFF}'..u8:decode(sc.text)..' - ������(�) '.. u8:decode(sc.nm) ..', {FF99FF}'..u8:decode(sc.act)
			elseif sc.type_color == u8'����' then
				text_end = '{FFFFFF}'.. u8:decode(sc.nm) ..' �������: '..u8:decode(sc.text)
			elseif sc.type_color == u8'�������' then
				text_end = '{73B461}[���]:{FFFFFF} '.. u8:decode(sc.nm) ..' - '.. u8:decode(sc.text)
			end
		end
		if scene_buf.invers then
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 3, true)
		else
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 4, true)
		end
		Y = Y + scene_buf.dist
	end
	if scene_active then
		if isKeyDown(0x01) or isKeyJustPressed(VK_ESCAPE) then
			setVirtualKeyDown(0x79, false)
			scene_active = false
			sampSetCursorMode(0)
			win.main.v = true
			imgui.ShowCursor = true
			displayRadar(true)
			displayHud(true)
			radarHud = 0
			angPlZ = angZ * -1.0
			lockPlayerControl(false)
			restoreCameraJumpcut()
			setCameraBehindPlayer()
		end
	end
end

function scene_edit()
	scene_edit_i = true
	setVirtualKeyDown(0x79, true)
	pos_sc = lua_thread.create(function()
		local backup = {
			['x'] = scene_buf.pos.x,
			['y'] = scene_buf.pos.y
		}
		local pos_sc_edit = true
		sampSetCursorMode(4)
		win.main.v = false
		if not sampIsChatInputActive() then
			while not sampIsChatInputActive() and pos_sc_edit do
				wait(0)
				local cX, cY = getCursorPos()
				scene_buf.pos.x = cX
				scene_buf.pos.y = cY
				if isKeyDown(0x01) then
					while isKeyDown(0x01) or isKeyDown(0x0D) do wait(0) end
					pos_sc_edit = false
				elseif isKeyJustPressed(VK_ESCAPE) then
					pos_sc_edit = false
					scene_buf.pos.x = backup['x']
					scene_buf.pos.y = backup['y']
				end
			end
		end
		sampSetCursorMode(0)
		setVirtualKeyDown(0x79, false)
		scene_edit_i = false
		win.main.v = true
		imgui.ShowCursor = true
		pos_sc_edit = false
	end)
end

function ch_pos_on_stat()
	pos_new_stat = lua_thread.create(function()
		change_pos_onstat = true
		sampSetCursorMode(4)
		win.main.v = false
		if not sampIsChatInputActive() then
			while not sampIsChatInputActive() and change_pos_onstat do
				wait(0)
				local cX, cY = getCursorPos()
				setting.pos_onstat.x = cX
				setting.pos_onstat.y = cY
				if isKeyDown(0x01) then
					while isKeyDown(0x01) do wait(0) end
					change_pos_onstat = false
				end
			end
		else
			change_pos_onstat = false
		end
		save('setting')
		sampSetCursorMode(0)
		win.main.v = true
		imgui.ShowCursor = true
		change_pos_onstat = false
	end)
end

--> ���������
function print_scr()
	lua_thread.create(function()
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> ��������� + /time
function print_scr_time()
	lua_thread.create(function()
		sampSendChat('/time')
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> �������
sampRegisterChatCommand('r', function(text_accents_r) 
	if setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and not setting.accent.func then
		sampSendChat('/r ['..u8:decode(setting.teg)..']: '..text_accents_r)
	elseif setting.teg == '' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.accent.text)..' ������]: '..text_accents_r)
	elseif setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.teg)..']['..u8:decode(setting.accent.text)..' ������]: '..text_accents_r)
	else
		sampSendChat('/r '..text_accents_r)
	end 
end)
sampRegisterChatCommand('s', function(text_accents_s) 
	if text_accents_s ~= '' and setting.accent.func and setting.accent.s and setting.accent.text ~= '' then
		sampSendChat('/s ['..u8:decode(setting.accent.text)..' ������]: '..text_accents_s)
	else
		sampSendChat('/s '..text_accents_s)
	end 
end)
sampRegisterChatCommand('f', function(text_accents_f) 
	if text_accents_f ~= '' and setting.accent.func and setting.accent.f and setting.accent.text ~= '' then
		sampSendChat('/f ['..u8:decode(setting.accent.text)..' ������]: '..text_accents_f)
	else
		sampSendChat('/f '..text_accents_f)
	end 
end)

function hook.onSendCommand(cmd)
	if cmd:find('/r ') then
		if setting.act_r ~= '' and setting.act_r ~= ' ' then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(setting.act_r))
			end)
		end
	end
	if cmd:find('/time') then
		if setting.act_time ~= '' and setting.act_time ~= ' ' then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(setting.act_time))
			end)
		end
	end
end

function hook.onSendChat(message)
    if setting.accent.func then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == ':d' or message == 'XD' or message == ':)' or message == ':(' then return {message} end
		
		if setting.accent.text ~= '' then
			return{'['..u8:decode(setting.accent.text)..' ������]: '..message}
		end
    end
end

--> ���� ���
local BuffSize = 32
local KeyboardLayoutName = ffi.new('char[?]', BuffSize)
local LocalInfo = ffi.new('char[?]', BuffSize)
local month = {'������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������'}

function getStrByState(keyState)
	if keyState == 0 then
		return '{ffeeaa}����{ffffff}'
	end
	return '{53E03D}���{ffffff}'
end

function getStrByState2(keyState)
	if keyState == 0 then
		return ''
	end
	return '{F55353}Caps{ffffff}'
end

function time_hud_func_and_distance_point()
	local text_dist_user_point = ''
	local text_dist_server_point = ''
	local my_int = getActiveInterior()
	local bool_result_server, pos_X_s, pos_Y_s, pos_Z_s = getTargetServerCoordinates()
	local distance_end_serv = -2
	local bias = 0
	
	if setting.time_hud then
		local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
		local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
		local localName = ffi.string(LocalInfo)
		local capsState = ffi.C.GetKeyState(20)
		local function lang()
			local str = string.match(localName, '([^%(]*)')
			if str:find('�������') then
				return 'Ru'
			elseif str:find('����������') then
				return 'En'
			end
		end
		local text = string.format('%s | {ffeeaa}%s{ffffff} %s', os.date('%d ')..month[tonumber(os.date('%m'))]..os.date(' - %H:%M:%S'), lang(), getStrByState2(capsState))
		bias = renderGetFontDrawTextLength(fontPD, text) + 10
		renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
	end
	
	if setting.display_map_distance.server and my_int == 0 then
		if bool_result_server then
			local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
			distance_end_serv = getDistanceBetweenCoords3d(pos_X_s, pos_Y_s, pos_Z_s, x_player, y_player, z_player)
			text_dist_server_point = tostring(removeDecimalPart(distance_end_serv)..' �. �� ����. �����')
			renderFontDrawText(font_metka, text_dist_server_point, 20 + bias, sy - 20, 0xFFFFFFFF)
		end
	end
	
	if setting.display_map_distance.user and my_int == 0 then
		local bool_result, pos_X, pos_Y, pos_Z = getTargetBlipCoordinates()
		if bool_result then
			local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
			local distance_end = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
			text_dist_user_point = tostring(removeDecimalPart(distance_end)..' �. �� ����� �����')
			local y_bias = 0
			if setting.display_map_distance.server and my_int == 0 and bool_result_server then
				y_bias = -18
			end
			if bool_result_server then
				if math.abs(distance_end_serv - distance_end) > 3 then
					renderFontDrawText(font_metka, text_dist_user_point, 20 + bias, sy - 20 + y_bias, 0xFFFFFFFF)
				end
			else
				renderFontDrawText(font_metka, text_dist_user_point, 20 + bias, sy - 20 + y_bias, 0xFFFFFFFF)
			end
		end
	end
end

--> ������ ������ �������
function round(num, step) --> ����� - ��� ����������
  return math.ceil(num / step) * step
end

function chsex(text_man, text_woman)
	if setting.sex == u8'�������' then
		return text_man
	else
		return text_woman
	end
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, '\n', '\r\n')
      str = string.gsub (str, '([^%w ])',
         function (c) return string.format ('%%%02X', string.byte(c)) end)
      str = string.gsub (str, ' ', '+')
   end
   return str
end

convert_color = function(argb)
	local col = imgui.ColorConvertU32ToFloat4(argb)
	return imgui.ImFloat4(col.z, col.y, col.x, col.w) 
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function isCursorAvailable()
	return (not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen())
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered, align, b_symbol)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local symb_len = renderGetFontDrawTextLength(font, '>')
	local hovered = false
	local result = false
    b_symbol = b_symbol == nil and false or b_symbol
    align = align or 1

    if align == 2 then
    	posX = posX - (lenght / 2)
    elseif align == 3 then
    	posX = posX - lenght
	end

    if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
        hovered = true
        if isKeyJustPressed(0x01) then
        	result = true 
        end
    end

    local anim = math.floor(math.sin(os.clock() * 10) * 3 + 5)
 	if hovered and b_symbol and (align == 2 or align == 1) then
    	renderFontDrawText(font, '>', posX - symb_len - anim, posY, 0x90FFFFFF)
    end 
    renderFontDrawText(font, text, posX, posY, hovered and color_hovered or color)
    if hovered and b_symbol and (align == 2 or align == 3) then
    	renderFontDrawText(font, '<', posX + lenght + anim, posY, 0x90FFFFFF)
    end 

    return result
end

function changePosition()
	if setting.members.func then
		pos_new_memb = lua_thread.create(function()
			local backup = {
				['x'] = setting.members.pos.x,
                ['y'] = setting.members.pos.y
			}
			local ChangePos = true
			sampSetCursorMode(4)
			win.main.v = false
			sampAddChatMessage(script_tag..'{FFFFFF}������� {FF6060}���{FFFFFF}, ����� ��������� ��� {FF6060}ESC{FFFFFF} ��� ������.', color_tag)
            if not sampIsChatInputActive() then
                while not sampIsChatInputActive() and ChangePos do
                    wait(0)
                    local cX, cY = getCursorPos()
                    setting.members.pos.x = cX
                    setting.members.pos.y = cY
                    if isKeyDown(0x01) then
                    	while isKeyDown(0x01) do wait(0) end
                        ChangePos = false
						save('setting')
                        sampAddChatMessage(script_tag..'{FFFFFF}������� ���������.', color_tag)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						setting.members.pos.x = backup['x']
						setting.members.pos.y = backup['y']
                        sampAddChatMessage(script_tag..'{FFFFFF}�� �������� ��������� �������.', color_tag)
                    end
                end
            end
            sampSetCursorMode(0)
            win.main.v = true
			imgui.ShowCursor = true
            ChangePos = false
		end)
	end
end

function render_members()
	local X, Y = setting.members.pos.x, setting.members.pos.y
	local title = string.format('%s | ������: %s%s', org.name, org.online, (setting.members.afk and (' (%s � ���)'):format(org.afk) or ''))
	local col_title = changeColorAlpha(setting.members.color.title, setting.members.vis)
	if setting.members.invers then
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.members.dist - 5, col_title, col_title, 4, false) then
			sampSendChat('/members')
		end
	else
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.members.dist - 5, col_title, col_title, 3, false) then
			sampSendChat('/members')
		end
	end
	if org.name == '���������' then
		if setting.members.invers then
			renderFontDrawClickableText(script_cursor, fontes, '�� �� �������� � �����������', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, '�� �� �������� � �����������', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	elseif #members > 0 then
		for i, member in ipairs(members) do
			if i <= tonumber(org.online) then
				local color = changeColorAlpha(setting.members.form and (member.uniform and setting.members.color.work or setting.members.color.default) or setting.members.color.default, setting.members.vis)
				local rank = setting.members.rank and string.format('[%s]', member.rank.count) or nil
				local nick = member.nick .. (setting.members.id and string.format('(%s)', member.id) or '')
				local afk = setting.members.afk and string.format(' (AFK: %s)', member.afk) or ''
				local warns = setting.members.warn and string.format(' (Warns: %s)', member.warns) or ''
				local out_string
				if setting.members.invers then
					out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 4, true)
				else
					out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 3, true)
				end
				Y = Y + setting.members.dist
			end
		end
	else
		if setting.members.invers then
			renderFontDrawClickableText(script_cursor, fontes, '�� ���� ����� �� ������', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, '�� ���� ����� �� ������', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	end
end

function on_hot_key(id_pr_key)
	local pressed_key = tostring(table.concat(id_pr_key, ' '))
	if pressed_key == '72' and setting.speed_door then
		sampSendChat('/opengate')
	end
	if thread:status() == 'dead' and not edit_key and #setting.cmd ~= 0 and not sampIsChatInputActive() and not sampIsDialogActive() then
		for k, v in pairs(setting.cmd) do
			if pressed_key == tostring(table.concat(v[3], ' ')) then
				cmd_start('', v[1])
				break
			end
		end
	end
end

function imgui.TextColoredRGB(string, max_float)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else 
				imgui.Text(u8(w))
			end
		end
	end
	render_text(string)
end

function time()
	local function get_weekday(year, month, day)
		local weekday = tonumber(os.date('%w', os.time{year = year, month = month, day = day}))
		if weekday == 0 then
			weekday = 7
		end

		return weekday
	end
	
	while true do
		wait(1000)
		if sampGetGamestate() == 3 then
			if #setting.reminder ~= 0 then
				local current_date_all = os.date('*t')
				local current_date = {
					year = tonumber(current_date_all.year),
					mon	= tonumber(current_date_all.month),
					day = tonumber(current_date_all.day),
					hour = tonumber(current_date_all.hour),
					min = tonumber(current_date_all.min),
				}
				for i = 1, #setting.reminder do
					local repeat_true = false
					local cur_day_rep = false
					for m = 1, #setting.reminder[i].repeats do
						if setting.reminder[i].repeats[m] then repeat_true = true break end
					end
					if setting.reminder[i].year == current_date.year and setting.reminder[i].mon == current_date.mon and
					setting.reminder[i].day == current_date.day and setting.reminder[i].hour == current_date.hour and
					setting.reminder[i].min == current_date.min then
						cur_day_rep = true
						if not setting.reminder[i].execution then
							win.reminder.v = true
							imgui.ShowCursor = true
							if setting.reminder[i].sound then
								lua_thread.create(function()
									local stop_signal = 0
									repeat wait(200) 
										addOneOffSound(0, 0, 0, 1057)
										stop_signal = stop_signal + 1
									until stop_signal > 17
								end)
							end
							rem_text = setting.reminder[i].nm
							setting.reminder[i].execution = true
							save('setting')
						end
					elseif setting.reminder[i].hour ~= current_date.hour and setting.reminder[i].min ~= current_date.min then
						setting.reminder[i].execution = false
						save('setting')
					end
					if not cur_day_rep and repeat_true and not setting.reminder[i].execution and setting.reminder[i].hour == current_date.hour and setting.reminder[i].min == current_date.min then
						local week_day = get_weekday(current_date.year, current_date.mon, current_date.day)
						if setting.reminder[i].repeats[week_day] then
							win.reminder.v = true
							imgui.ShowCursor = true
							if setting.reminder[i].sound then
								lua_thread.create(function()
									local stop_signal = 0
									repeat wait(200) 
										addOneOffSound(0, 0, 0, 1057)
										stop_signal = stop_signal + 1
									until stop_signal > 17
								end)
							end
							rem_text = setting.reminder[i].nm
							setting.reminder[i].execution = true
							save('setting')
						end
					end
				end
			end
			
			if not isGamePaused() then
				session_clean.v = session_clean.v + 1
				session_all.v = session_all.v + 1
			
				setting.online_stat.clean[1] = setting.online_stat.clean[1] + 1
				setting.online_stat.all[1] = setting.online_stat.all[1] + 1
				setting.online_stat.total_all = setting.online_stat.total_all + 1
			else
				session_all.v = session_all.v + 1
				session_afk.v = session_afk.v + 1
				
				setting.online_stat.all[1] = setting.online_stat.all[1] + 1
				setting.online_stat.afk[1] = setting.online_stat.afk[1] + 1
			end
		end
		
		if get_status_potok_song() == 1 and track_time_hc ~= 0 then
			local time_song = 0
			time_song = time_song_position(track_time_hc)
			time_song = round(time_song, 1)
			timetr[1] = time_song % 60
			timetr[2] = math.floor(time_song / 60)
		end
		
		if close_stats then
			sampSendChat('/stats')
		end
		
		if not isGamePaused() and not isPauseMenuActive() then
			kick_afk_buf = 0
		end
		if isGamePaused() or isPauseMenuActive() then
			if setting.kick_afk.func and setting.kick_afk.time_kick ~= '' then
				kick_afk_buf = kick_afk_buf + 1
				local bul_afk = kick_afk_buf / 60

				if bul_afk >= tonumber(setting.kick_afk.time_kick) then
					if setting.kick_afk.mode == u8'������ ������� ����������' then
						if not close_serv then
							�lose_�onnect()
							close_serv = true
							sampAddChatMessage(script_tag..'{FFFFFF}�� ���� ��������� �� ������� �� ���������� ����� ���!', 0xFF5345)
						end
					else
						os.exit()
					end
				end
			end
		end
		
		if time_dialog_nickname < 6 then
			time_dialog_nickname = time_dialog_nickname + 1
		elseif time_dialog_nickname >= 6 and time_dialog_nickname <= 10 then
			nickname_dialog = false
		end
		
		if #setting.tickets ~= 0 then
			if setting.tickets[1].time > 0 then
				setting.tickets[1].time = setting.tickets[1].time - 1
			end
		end
		
		if debug_crush_help > 0 then
			debug_crush_help = debug_crush_help - 1
		end
		
		if #setting.tickets ~= 0 and not isGamePaused() and not isPauseMenuActive() then
			if setting.tickets[1].text ~= 0 then
				if setting.tickets[1].status == 0 then
					check_ticket = check_ticket - 1
					
					if check_ticket <= 0 then
						check_ticket = 100
						asyncHttpRequest('GET', 'https://raw.githubusercontent.com/KaneScripter/q/main/'.. setting.unicum_git .. #setting.tickets[1].text ..'.txt', nil,
							function(response)
								if response.text:find('404: Not Found') then
									--print('�� �������')
								else
									token_respone = response.text
								end
							end,
							function(err)
							print(err)
						end)
					end
				end
			end
		end	
		
		if token_respone ~= '' and not isGamePaused() and not isPauseMenuActive() then
			local token_copy = token_respone
			token_respone = ''
			asyncHttpRequest('GET', ('https://gist.githubusercontent.com/KaneScripter/'.. token_copy .. '/'.. setting.unicum_id .. #setting.tickets[1].text ..'.txt'):gsub("%s", ""), nil,
				function(response)
					setClipboardText('https://gist.githubusercontent.com/KaneScripter/'.. token_copy .. '/'.. setting.unicum_id .. #setting.tickets[1].text ..'.txt')
					if response.text:find('404: Not Found') then
						--print('�� �������')
					else
						setting.tickets[1].status = 1
						setting.tickets[1].text[#setting.tickets[1].text][2] = response.text
						sampAddChatMessage(script_tag..'{FFFFFF}������ ��������� �������� �� ���� ���������!', color_tag)
						setting.notice_help = true
						save('setting')
						get_scroll_max_help = 2
					end
				end,
				function(err)
				print(err)
			end)
		end
		if send_chat_rp then
			sampAddChatMessage(script_tag..'{ffffff} ���� 7 ������ ��� ������������� (��������)', color_tag)
			send_chat_time = os.clock()
			send_chat_rp = false
		end
		if send_chat_time then
			if os.clock() - send_chat_time >= 7.3 then
				sampSendDialogResponse(27338, 1, 0, nil)
				local message = SexTag('/me ����{sex:,�} �������� � ��� �������� ��������, ����������� ��� ������{sex:,�}, ����� ���� ������{sex:,�} �������')
				sampSendChat(message)
				send_chat_time = nil
			end
		end
	end
end
local send_chat_time = nil

function SexTag(text)
    return text:gsub('{sex:([%w%s�-��-�]*),([%w%s�-��-�]*)}', function(maleForm, femaleForm)
        return setting.sex == u8'�������' and maleForm or femaleForm
    end)
end

function save_coun_onl()
	while true do 
		wait(60000)
		save('setting')
	end
end

--> ���-���
function cam_hack()
	if not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
		offMouX, offMouY = getPcMouseMovement()
		angZ = (angZ + offMouX/4.0) % 360.0
		angY = math.min(89.0, math.max(-89.0, angY + offMouY/4.0))
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)
		curZ = angZ + 180.0
		curY = angY * -1.0
		radZ = math.rad(curZ)
		radY = math.rad(curY)
		sinZ = math.sin(radZ)
		cosZ = math.cos(radZ)
		sinY = math.sin(radY)
		cosY = math.cos(radY)
		sinZ = sinZ * cosY
		cosZ = cosZ * cosY
		sinZ = sinZ * 10.0
		cosZ = cosZ * 10.0
		sinY = sinY * 10.0
		posPlX = posX + sinZ
		posPlY = posY + cosZ
		posPlZ = posZ + sinY
		angPlZ = angZ * -1.0
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_W) then
			radZ = math.rad(angZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinY = math.sin(radY)
			cosY = math.cos(radY)
			sinZ = sinZ * cosY
			cosZ = cosZ * cosY
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			sinY = sinY * speed
			posX = posX + sinZ
			posY = posY + cosZ
			posZ = posZ + sinY
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_S) then
			curZ = angZ + 180.0
			curY = angY * -1.0
			radZ = math.rad(curZ)
			radY = math.rad(curY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinY = math.sin(radY)
			cosY = math.cos(radY)
			sinZ = sinZ * cosY
			cosZ = cosZ * cosY
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			sinY = sinY * speed
			posX = posX + sinZ
			posY = posY + cosZ
			posZ = posZ + sinY
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_A) then
			curZ = angZ - 90.0
			radZ = math.rad(curZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			posX = posX + sinZ
			posY = posY + cosZ
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_D) then
			curZ = angZ + 90.0
			radZ = math.rad(curZ)
			radY = math.rad(angY)
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)
			sinZ = sinZ * speed
			cosZ = cosZ * speed
			posX = posX + sinZ
			posY = posY + cosZ
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_SHIFT) then
			posZ = posZ + speed
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_CONTROL) then
			posZ = posZ - speed
			setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
		end
		radZ, radY = math.rad(angZ), math.rad(angY)
		sinZ, cosZ = math.sin(radZ), math.cos(radZ)
		sinY, cosY = math.sin(radY), math.cos(radY)
		sinZ, cosZ, sinY = sinZ * cosY, cosZ * cosY, sinY * 1.0
		poiX, poiY, poiZ = posX + sinZ, posY + cosZ, posZ + sinY
		pointCameraAtPoint(poiX, poiY, poiZ, 2)

		if isKeyDown(VK_F10) then
			displayRadar(false)
			displayHud(false)
		else
			displayRadar(true)
			displayHud(true)
		end
	end
end

function hook.onSendAimSync()
    if camhack_active then
		return false
    end
end

function onScriptTerminate(script, quit)
	if script == thisScript() and not quit and camhack_active then
		displayRadar(true)
		displayHud(true)
		lockPlayerControl(false)
		restoreCameraJumpcut()
		setCameraBehindPlayer()
	end
end

local onday = false
function print_time(time)
	local timehighlight = 86400 - os.date('%H', 0) * 3600
	if tonumber(time) >= 86400 then onDay = true else onDay = false end
	return os.date((onDay and math.floor(time / 86400)..' �. ' or '')..('%H �. %M ���.'), time + timehighlight)
end

function removeDecimalPart(value)
	local dotPosition = string.find(value, '%.')
	if not dotPosition then
		return value
	end
	
	return string.sub(value, 1, dotPosition - 1)
end

function getTargetServerCoordinates()
	local pos_cord = {x = 0.0, y = 0.0, z = 0.0}
    local target_server = false
    for id = 0, 31 do
        local object_truct = 0xC7F168 + id * 56
		local object_truct_pos = {
			x = representIntAsFloat(readMemory(object_truct + 0, 4, false)),
			y = representIntAsFloat(readMemory(object_truct + 4, 4, false)),
			z = representIntAsFloat(readMemory(object_truct + 8, 4, false))
		}
        if object_truct_pos.x ~= 0.0 or object_truct_pos.y ~= 0.0 or object_truct_pos.z ~= 0.0 then
            pos_cord = {
				x = object_truct_pos.x,
				y = object_truct_pos.y,
				z = object_truct_pos.z
			}
            target_server = true
        end
    end
	
    return target_server, pos_cord.x, pos_cord.y, pos_cord.z
end

function �lose_�onnect()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, raknetNewBitStream())
	raknetDeleteBitStream(raknetNewBitStream())
end

function SendWebhook(URL, DATA, callback_ok, callback_error) -- ������� �������� �������
    local function asyncHttpRequest(method, url, args, resolve, reject)
        local request_thread = effil.thread(function (method, url, args)
           local requests = require 'requests'
           local result, response = pcall(requests.request, method, url, args)
           if result then
              response.json, response.xml = nil, nil
              return true, response
           else
              return false, response
           end
        end)(method, url, args)
        if not resolve then resolve = function() end end
        if not reject then reject = function() end end
        lua_thread.create(function()
            local runner = request_thread
            while true do
                local status, err = runner:status()
                if not err then
                    if status == 'completed' then
                        local result, response = runner:get()
                        if result then
                           resolve(response)
                        else
                           reject(response)
                        end
                        return
                    elseif status == 'canceled' then
                        return reject(status)
                    end
                else
                    return reject(err)
                end
                wait(0)
            end
        end)
    end
    asyncHttpRequest('POST', URL, {headers = {['content-type'] = 'application/json'}, data = u8(DATA)}, callback_ok, callback_error)
end

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function (method, url, args)
		local requests = require 'requests'
		local result, response = pcall(requests.request, method, url, args)
		if result then
			response.json, response.xml = nil, nil
			return true, response
		else
			return false, response
		end
	end)(method, url, args)

	if not resolve then resolve = function() end end
	if not reject then reject = function() end end

	lua_thread.create(function()
		local runner = request_thread
		while true do
			local status, err = runner:status()
			if not err then
				if status == 'completed' then
					local result, response = runner:get()
					if result then
						resolve(response)
					else
						reject(response)
					end
					return
				elseif status == 'canceled' then
					return reject(status)
				end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end

function send_message_about_problem(mes_text, number_ticket) 																																																																																																																																																																																																																																																																																																															--[[����������, �� ����������� � ���� �������, ������ ���������!! ������� �� ���������!!)]]	SendWebhook('https://discord.com/api/webhooks/1224707514356990024/mtsQLAPW1ZBk_Z5YM48WZKdFsP7fDj9Qa36KXxFKpNwvAulNEtXscZmtPovhOeocEJ3m', ([[{																																																																																																				
		"content": "`%s`\n\n���������� ID: `%s`\n���������� Git: `%s`\n���: `%s`\n������ �������: `%s`",
		"embeds": null,
		"attachments": []
	}]]):format(u8:decode(mes_text), setting.unicum_id..number_ticket, setting.unicum_git..number_ticket, my.nick, scr.version))
	sampAddChatMessage(script_tag..'{FFFFFF}��������� ������� ����������. �������� ������ �� ������ ���������.', color_tag)
end

function add_new_lines(text, maxLineLength)
	local result = ''
	local count = 1
	local lineLength = 0
	local wordCount = 0

	for word in text:gmatch('%S+') do
		local wordLength = #word
		wordCount = wordCount + 1
		
		if lineLength + wordLength > maxLineLength then
			result = result .. '\n'
			count = count + 1
			lineLength = 0
		end

		result = result .. word .. ' '
		lineLength = lineLength + wordLength + 1

		if wordCount == text:match('%S+') then
			result = result:sub(1, -2)
		end
	end

	return result, count
end

function measurement_coordinates(text_area, bool_int_or_around, location_city)
	local areas_and_coordinates = {
		{'Rodeo', {x = 379, y = -1449, z = 20}},
		{'Marina', {x = 771, y = -1585, z = 20}},
		{'Vinewood', {x = 799, y = -1154, z = 20}},
		{'Market', {x = 1191, y = -1406, z = 12}},
		{'Conference', {x = 1170, y = -1741, z = 20}},
		{'Verona Beach', {x = 830, y = -1860, z = 20}},
		{'Maria', {x = 415, y = -1852, z = 20}},
		{'Temple', {x = 1163, y = -1050, z = 20}},
		{'Mulholland', {x = 1177, y = -818, z = 68}},
		{'Verdant Bluffs', {x = 1221, y = -2084, z = 64}},
		{'Pershing', {x = 1477, y = -1649, z = 20}},
		{'Commerce', {x = 1603, y = -1481, z = 27}},
		{'Downtown Los', {x = 1617, y = -1265, z = 20}},
		{'Mulholland Intersection', {x = 1659, y = -947, z = 20}},
		{'International', {x = 1875, y = -2416, z = 20}},
		{'El Corona', {x = 1839, y = -1991, z = 20}},
		{'Little Mexico', {x = 1713, y = -1705, z = 20}},
		{'Idlewood', {x = 1923, y = -1571, z = 20}},
		{'Glen Park', {x = 1965, y = -1202, z = 20}},
		{'Jefferson', {x = 2205, y = -1395, z = 20}},
		{'Las Colinas', {x = 2429, y = -1059, z = 20}},
		{'Los Flores', {x = 2723, y = -1269, z = 20}},
		{'East Los', {x = 2524, y = -1533, z = 20}},
		{'Ganton', {x = 2412, y = -1729, z = 20}},
		{'Willowfield', {x = 2412, y = -1911, z = 20}},
		{'Ocean Docks', {x = 2776, y = -2530, z = 20}},
		{'Playa Del Seville', {x = 2860, y = -1945, z = 20}},
		{'East Beach', {x = 2902, y = -1420, z = 20}},
		{'Northstar Rock', {x = 2112, y = -500, z = 20}},
		{'Palomino Creek', {x = 2510, y = -115, z = 20}},
		{'Hankypanky Point', {x = 2594, y = 183, z = 20}},
		{'Frederick Bridge', {x = 2762, y = 459, z = 20}},
		{'Montgomery Intersection', {x = 1722, y = 323, z = 20}},
		{'The Mako Span', {x = 1722, y = 505, z = 20}},
		{'Montgomery', {x = 1232, y = 407, z = 20}},
		{'Fern Ridge', {x = 817, y = 101, z = 20}},
		{'Hilltop Farm', {x = 1027, y = -257, z = 20}},
		{'Hampton Barns', {x = 649, y = 290, z = 20}},
		{'Blueberry', {x = 369, y = -192, z = 20}},
		{'Dillimore', {x = 660, y = -673, z = 20}},
		{'Richman', {x = 471, y = -954, z = 20}},
		{'Blueberry Acres', {x = -186, y = 180, z = 20}},
		{'The Panopticon', {x = -658, y = -53, z = 20}},
		{'Martin Bridge',  {x = -166, y = 363, z = 20}},
		{'Fallow Bridge', {x = 491, y = 500, z = 20}},
		{'Mount Chiliad', {x = -2608, y = -1514, z = 20}},
		{'Shady Creeks', {x = -1684, y = -1864, z = 20}},
		{'Shady Cabin', {x = -1642, y = -2284, z = 20}},
		{'Angel Pine', {x = -1880, y = -2494, z = 20}},
		{'Back o Beyond',  {x = -705, y = -2286, z = 20}},
		{'Leafy Hollow', {x = -1021, y = -1649, z = 20}},
		{'Flint Range', {x = -462, y = -1502, z = 20}},
		{'Flint Intersection', {x = -98, y = -1364, z = 20}},
		{'Beacon Hill', {x = -434, y = -1084, z = 20}},
		{'Flint County', {x = -434, y = -1084, z = 20}},
		{'The Farm', {x = -1180, y = -1028, z = 20}},
		{'Fallen Tree', {x = -560, y = -441, z = 20}},
		{'Easter Bay Chemicals', {x = -980, y = -539, z = 20}},
		{'Easter Tunnel', {x = -1452, y = -795, z = 20}},
		{'Easter Bay Airport', {x = -1340, y = -221, z = 20}},
		{'Foster Valley', {x = -1868, y = -978, z = 20}},
		{'Missionary Hill', {x = -2636, y = -624, z = 85}},
		{'Avispa Country Club', {x = -2678, y = -235, z = 20}},
		{'Ocean Flats', {x = -2748, y = 44, z = 20}},
		{'Hashbury', {x = -2482, y = 30, z = 20}},
		{'Doherty', {x = -2090, y = 72, z = 34}},
		{'Garcia', {x = -2244, y = 170, z = 20}},
		{'City Hall', {x = -2692, y = 380, z = 20}},
		{'Queens', {x = -2482, y = 422, z = 20}},
		{'King', {x = -2230, y = 436, z = 20}},
		{'Santa Flora', {x = -2594, y = 590, z = 20}},
		{'China Town', {x = -2314, y = 604, z = 20}},
		{'Downtown', {x = -1870, y = 674, z = 20}},
		{'Easter Basin', {x = -1520, y = 394, z = 20}},
		{'Palisades', {x = -2794, y = 758, z = 20}},
		{'Juniper Hill', {x = -2510, y = 758, z = 20}},
		{'Financial', {x = -1922, y = 884, z = 20}},
		{'Esplanade East', {x = -1698, y = 1323, z = 20}},
		{'Esplanade North', {x = -2076, y = 1351, z = 20}},
		{'Calton Neights', {x = -2230, y = 1085, z = 20}},
		{'Paradiso', {x = -2636, y = 1043, z = 20}},
		{'Juniper Hollow', {x = -2510, y = 1197, z = 20}},
		{'Kincaid Bridge', {x = -1208, y = 791, z = 20}},
		{'Garver', {x = -1236, y = 973, z = 20}},
		{'Gant Bridge', {x = -2664, y = 1816, z = 20}},
		{'Battery Point', {x = -2804, y = 1312, z = 20}},
		{'Bayside Marina', {x = -2354, y = 2328, z = 20}},
		{'Bayside Tunnel', {x = -1906, y = 2651, z = 20}},
		{'Bayside', {x = -2634, y = 2622, z = 20}}, 
		{'El Quebrados', {x = -1430, y = 2818, z = 20}},
		{'Aldea Malvada', {x = -1206, y = 2510, z = 20}},
		{'Valle Ocultado', {x = -835, y = 2746, z = 20}},
		{'Arco del', {x = -779, y = 2340, z = 20}},
		{'Las Barrancas', {x = -681, y = 1499, z = 20}},
		{'Sherman Dam', {x = -709, y = 2031, z = 20}},
		{'Las Brujas', {x = -459, y = 2269, z = 20}},
		{'El Castillo', {x = -249, y = 2423, z = 20}},
		{'Las Payasadas', {x = -179, y = 2818, z = 20}},
		{'Verdant Meadows', {x = 170, y = 2357, z = 20}},
		{'Regular Tom', {x = -319, y = 1881, z = 20}},
		{'Big Ear', {x = -221, y = 1545, z = 20}},
		{'Probe Inn', {x = 2, y = 1349, z = 20}},
		{'Green Palms', {x = 198, y = 1531, z = 20}},
		{'Octane Springs', {x = 520, y = 1503, z = 20}},
		{'Fort Carson', {x = -11, y = 971, z = 20}},
		{'Hunter Quarry', {x = 800, y = 816, z = 20}},
		{'Rockshore East', {x = 2781, y = 746, z = 20}}, 
		{'Rockshore West', {x = 2277, y = 704, z = 20}},
		{'Last Dime Motel', {x = 1913, y = 704, z = 20}},
		{'Randolph Ind', {x = 1689, y = 732, z = 20}},
		{'Blackfield Chapel', {x = 1409, y = 760, z = 20}},
		{'Thruway South', {x = 1801, y = 844, z = 20}},
		{'Blackfield Intersection', {x = 1231, y = 930, z = 20}},
		{'Greenglass College', {x = 1091, y = 1070, z = 20}},
		{'LVA Freight', {x = 1595, y = 1028, z = 20}},
		{'Four Dragons', {x = 1917, y = 1025, z = 20}},
		{'Come%-A%-Lot', {x = 2253, y = 1053, z = 20}},
		{'Linden Side', {x = 2895, y = 1049, z = 20}},
		{'Linden Station', {x = 2804, y = 1273, z = 9}},
		{'Camel\'s Toe', {x = 2300, y = 1273, z = 20}},
		{'Thruway East', {x = 2706, y = 1469, z = 12}},
		{'Pink Swan', {x = 1936, y = 1175, z = 20}},
		{'The Strip', {x = 2048, y = 1259, z = 20}},
		{'High Roller', {x = 1908, y = 1357, z = 20}},
		{'Pirates', {x = 1922, y = 1595, z = 20}},
		{'Las Venturas Airport', {x = 1558, y = 1539, z = 20}},
		{'LVA Airport', {x = 1558, y = 1539, z = 20}},
		{'Blackfield', {x = 1109, y = 1552, z = 20}},
		{'Royale Casino', {x = 2188, y = 1515, z = 20}},
		{'Caligula', {x = 2202, y = 1655, z = 20}},
		{'Pilgrim', {x = 2524, y = 1571, z = 6}},
		{'Sobell Rail', {x = 2888, y = 1795, z = 20}},
		{'Creek', {x = 2916, y = 2249, z = 20}},
		{'Ring Master', {x = 2258, y = 1815, z = 20}},
		{'Starfish Casino', {x = 2342, y = 1955, z = 20}},
		{'Old Venturas Strip', {x = 2384, y = 2179, z = 20}},
		{'Roca Escalante', {x = 2412, y = 2319, z = 9}},
		{'The Emerald Isle', {x = 2118, y = 2361, z = 22}},
		{'Thruway North', {x = 2216, y = 2586, z = 5}},
		{'Spiny Bed', {x = 2258, y = 2740, z = 9}},
		{'Kacc', {x = 2622, y = 2754, z = 22}},
		{'Redsands East', {x = 1928, y = 2107, z = 20}},
		{'The Visage', {x = 1928, y = 1883, z = 20}},
		{'Harry Gold', {x = 1788, y = 1785, z = 20}},
		{'Redsands West', {x = 1452, y = 2093, z = 20}},
		{'Whitewood', {x = 990, y = 2163, z = 9}},
		{'Pilson Intersection', {x = 1200, y = 2415, z = 20}},
		{'Yellow Bell', {x = 1223, y = 2783, z = 20}},
		{'Prickle Pine', {x = 1573, y = 2671, z = 20}}
	}
	
	local city_and_coordinates = {
		{'Tierra Robada', {x = -1488, y = 2219, z = 20}},
		{'San Fierro', {x = -2320, y = 246, z = 20}},
		{'Whetstone', {x = -2215, y = -1854, z = 20}},
		{'Flint County', {x = -574, y = -2638, z = 20}},
		{'Los Santos', {x = 1490, y = -1531, z = 12}},
		{'Red County', {x = 865, y = -438, z = 20}},
		{'Bone County', {x = 67, y = 795, z = 20}},
		{'Las Venturas', {x = 1945, y = 1838, z = 20}}
	}
	
	local coord_area_end
	local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
	local distance_to_city = 0
	local org_all_position = {{x = 1178, y = -1323, z = 14}, {x = 1642, y = 1834, z = 11}, {x = -2667, y = 581, z = 14}, {x = 2034, y = -1406, z = 17}}
	for i = 1, #areas_and_coordinates do
		if (text_area):find(areas_and_coordinates[i][1]) then
			coord_area_end = areas_and_coordinates[i][2]
			break
		end
	end
	if text_area == '�����������' then
		for i = 1, #city_and_coordinates do
			if (location_city):find(city_and_coordinates[i][1]) then
				coord_area_end = city_and_coordinates[i][2]
				break
			end
		end
	end
	
	if coord_area_end then
		if bool_int_or_around == 0 then
			distance_to_city = getDistanceBetweenCoords3d(coord_area_end.x, coord_area_end.y, coord_area_end.z, x_player, y_player, z_player)
			
			return ' ['.. tostring(removeDecimalPart(distance_to_city)) ..' �. �� ���]'
		else
			if setting.frac.org == u8'�������� ��' then
				x_player, y_player, z_player = org_all_position[1].x, org_all_position[1].y, org_all_position[1].z
			elseif	setting.frac.org == u8'�������� ��' then
				x_player, y_player, z_player = org_all_position[2].x, org_all_position[2].y, org_all_position[2].z
			elseif	setting.frac.org == u8'�������� ��' then
				x_player, y_player, z_player = org_all_position[3].x, org_all_position[3].y, org_all_position[3].z
			elseif	setting.frac.org == u8'�������� ����������' then
				x_player, y_player, z_player = org_all_position[4].x, org_all_position[4].y, org_all_position[4].z
			end
			
			distance_to_city = getDistanceBetweenCoords3d(coord_area_end.x, coord_area_end.y, coord_area_end.z, x_player, y_player, z_player)
			
			return ' ['.. tostring(removeDecimalPart(distance_to_city)) ..' �. �� ����� ��������]'
		end
	else
		return ' [������ ��������� ����������]'
	end

	return ' [������ ��������� ����������]'
end