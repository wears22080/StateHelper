script_name('StateHelper')
script_authors('Kane')
script_description('Script for employees of state organizations on the Arizona Role Playing Game')
script_version('2.1')
script_properties('work-in-pause')
beta_version = 0

local text_err_and_read = {
	[1] = [[
 Не обнаружен файл SAMPFUNCS.asi в папке игры, вследствие чего
скрипту не удалось запуститься.

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения ВКонтакте:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]],
	[2] = [[
		  Внимание! 
Не обнаружены некоторые важные файлы для работы скрипта.
В следствии чего, скрипт перестал работать.
	Список необнаруженных файлов:
		%s

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
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

--> Подключение библиотек и модулей
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
assert(res, 'Библиотека SAMP Event не найдена')
---------------------------------------------------
local res, imgui = pcall(require, 'imgui')
assert(res, 'Библиотека Imgui не найдена')
---------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, 'Библиотека faIcons не найдена')
---------------------------------------------------
local res, rkeys = pcall(require, 'rkeys')
assert(res, 'Библиотека rkeys не найдена')
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

--> Скачивание изображений
IMG_Record = {}
IMG_Radio = {}
function download_image()
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/Изображения/') then
		print('{F54A4A}Ошибка. Отсутствует папка для изображений. {82E28C}Создание папки для изображений...')
		createDirectory(getWorkingDirectory()..'/StateHelper/Изображения/')
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/No label.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/Zud78GE.png', getWorkingDirectory()..'/StateHelper/Изображения/No label.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
				local texture_im = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
				IMG_Record = {texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im}
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/fuPlVzV.png', getWorkingDirectory()..'/StateHelper/Изображения/Background.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/yi98wxe.png', getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png')
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/CHJ54FR.png', getWorkingDirectory()..'/StateHelper/Изображения/Background White.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png')
			end
		end)
	end
	
	local function download_record_label(url_label_record, name_label, i_rec)
		if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png') then
			download_id = downloadUrlToFile(url_label_record, getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					IMG_Record[i_rec] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png')
				end
			end)
		end
	end
	local function download_radio_label(url_label_radio, name_label, i_radio)
		if not doesFileExist(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png') then
			download_id = downloadUrlToFile(url_label_radio, getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					IMG_Radio[i_radio] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/'..name_label..'.png')
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
	
	download_radio_label('https://i.imgur.com/lUk9LZO.png', 'Army', 1)
	download_radio_label('https://i.imgur.com/sanZtaP.png', 'Байрактар', 2)
	download_radio_label('https://i.imgur.com/03gAXqE.png', 'Наше Радіо', 3)
	download_radio_label('https://i.imgur.com/lQX0xBv.png', 'HitFm', 4)
	download_radio_label('https://i.imgur.com/VBT9uFN.png', 'MelodiaFm', 5)
	download_radio_label('https://i.imgur.com/gz22phj.png', 'Mayak', 6)
	download_radio_label('https://i.imgur.com/aAm4wxg.png', 'Nashe', 7)
	download_radio_label('https://i.imgur.com/mCR7zbX.png', 'LoFi Hip-Hop', 8)
	download_radio_label('https://i.imgur.com/VvGBnO8.png', 'Maximum', 9)
	download_radio_label('https://i.imgur.com/NVtDlRE.png', '90s Eurodance', 10)
end
download_image()

--> Скачивание шрифтов
installation_success_font = {false, false}
secc_load_font = false
function download_font()
	local link_meduim_font = ''
	local link_bold_font = ''
	if not doesDirectoryExist(getWorkingDirectory()..'/StateHelper/Fonts/') then
		print('{F54A4A}Ошибка. Отсутствует папка для шрифтов. {82E28C}Создание папки для шрифтов...')
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

--> Файловая система
dirml = getWorkingDirectory()
dirGame = getGameDirectory()
scr = thisScript()
font = renderCreateFont('Trebuchet MS', 14, 5)
fontPD = renderCreateFont('Trebuchet MS', 12, 5)
font_metka = renderCreateFont('Trebuchet MS', 9, 5)
sx, sy = getScreenResolution()

--> Окна imgui и их зависимости
local win = {
	main = imgui.ImBool(false), --> Главное
	spur_big = imgui.ImBool(false), --> Большое окно шпоры
	icon = imgui.ImBool(false), --> Иконки
	action_choice = imgui.ImBool(false), --> Быстрое взаимодействие
	reminder = imgui.ImBool(false), --> Напоминания
	notice = imgui.ImBool(false), --> Уведомления системы
	music = imgui.ImBool(false), --> Музыкальный плеер
	stat_online = imgui.ImBool(false) --> Музыкальный плеер
}
local select_main_menu = {false, false, false, false, false, false, false, false, false, false, false, false, false} --> Для главного меню
local select_basic = {false, false, false, false, false, false, false, false, false, false, false, false} --> Для меню основное
local notice = {} --> Значения уведомлений (текст, заголовок, тип - предупреждение/уведомление/инфо)

--> Обновление и её зависимости
upd = {}
url_upd = ''
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


--> Несохраняемая информация
local pers = {
	frac = {org = 'Больница ЛС', title = '', rank = 1}
}
org_all_done = {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'ТСР'}
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

--> Главные настройки
setting = {
	int = {first_start = true, script = 'Helper', theme = 'White'},
	frac = {org = u8'Больница ЛС', title = u8'Бывалый', rank = 10},
	nick = '',
	teg = '',
	act_time = '',
	act_r = '',
	sex = u8'Мужской',
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
		auto = {'100.000', '160.000', '210.000'},
		moto = {'150.000', '200.000', '240.000'},
		fly = {'500.000', '0', '0'},
		fish = {'200.000', '250.000', '290.000'},
		swim = {'200.000', '250.000', '290.000'},
		gun = {'240.000', '330.000', '405.000'},
		hunt = {'230.000', '330.000', '390.000'},
		exc = {'230.000', '330.000', '390.000'},
		taxi = {'500.000', '750.000', '1.000.000'},
		meh = {'500.000', '750.000', '1.000.000'}
	},
	chat_pl = false,
	chat_help = false,
	chat_smi = false,
	chat_racia = false,
	chat_dep = false,
	chat_vip = false,
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
	depart = {format = u8'[ЛСМЦ] - [ЛСПД]:', my_tag = '', else_tag = '', volna = ''},
	speed_door = false,
	dep_off = false,
	anim_main = false,
	cmd = {
		{'z', u8'Приветствие', {}, '1'},
		{'exp', u8'Выгнать из помещения', {}, '3'},
		{'za', u8'Отправит фразу "Пройдёмте за мной"', {}, '1'},
		{'show', u8'Показать игроку свои документы', {}, '1'},
		{'cam', u8'Начать или прекратить видеофиксацию', {}, '1'},
		{'mb', u8'Сокращённая команда /members', {}, '1'},
		{'+mute', u8'Выдать бан чата организации сотруднику', {}, '8'},
		{'-mute', u8'Снять бан чата организации сотруднику', {}, '8'},
		{'+warn', u8'Выдать сотруднику выговор', {}, '8'},
		{'-warn', u8'Снять выговор сотруднику', {}, '8'},
		{'inv', u8'Принять игрока в организацию', {}, '9'},
		{'uninv', u8'Уволить сотрудника', {}, '9'},
		{'rank', u8'Установить сотруднику ранг', {}, '9'},
	},
	show_dialog_auto = true,
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
			nm = u8'Попросить документы', 
			q = {
			u8'Для трудоустройства необходимо предоставить следующий пакет документов:',
			u8'Паспорт, медицинскую карту и лицензии.',
			u8'/n Отыгрывая, с использованием команд /me, /do, /todo'}},
			{
			nm = u8'Рассказать о себе',
			q = {
			u8'Хорошо, расскажите немного о себе.'}},
			{
			nm = u8'Почему Вы выбрали нас',
			q = {
			u8'Хорошо, скажите, почему Вы выбрали именно нас?'}},
			{
			nm = u8'Вас убивали?',
			q = {
			u8'Хорошо, давайте проверим Вашу психику.',
			u8'Скажите, Вас когда-нибудь убивали?'}},
			{
			nm = u8'Где Вы находитесь?',
			q = {
			u8'Хорошо, скажите, где Вы сейчас находитесь?'}},
			{
			nm = u8'Название купюр',
			q = {
			u8'Отлично, скажите, как называются купюры, которыми Вы расплачиваетесь?'}},
			{
			nm = u8'Рация дискорд',
			q = {
			u8'Хорошо, скажите, имеется ли у Вас спец. рация Discord?'}}}
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
	rubber_stick = true,
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
		date_week = {os.date('%d.%m.%Y'), '', '', '', '', '', ''} --> Дата за неделю в формате [день, месяц, год]
	},
	priceosm = '200000',
	start_pos = 0,
	new_pos = 0,
	new_mus_fix = true,
	pos_act = {
		x = sx / 2,
		y = sy / 2
	},
	kick_afk = {func = false, mode = u8'Сервер закроет соединение', time_kick = '10'},
	anti_alarm_but = false,
	my_tag_en2 = '',
	my_tag_en3 = '',
	auto_roleplay_text = false,
	fun_block = false,
	blank_text_dep = {u8'На связи.', u8'На связь.', u8'Конец связи.', u8'Прошу прощения, рация упала...', u8'Вы и Ваш состав свободны для проверки?'},
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
script_tag = '[ArmyHelper] '
color_tag = 0x28bf11

--> Для РП зоны
scene = {bq = {}}
scene_buf = {}
select_scene = 0

--> Для команд
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

--> Для шпор
local select_shpora = 0
shpora = {
	nm = '',
	text = ''
}

--> Работа с датами
week = {'Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'}
month = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}

--> Для обновления
new_version = {beta = beta_version, version = scr_version}
type_version = {rel = false, beta = false}
upd_info = nil

--> Обработка шрифтов
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

--> Проверка существование папки и её создание
if not doesDirectoryExist(dirml..'/StateHelper/') then
	print('{F54A4A}Ошибка. Отсутствует папка State Helper. {82E28C}Создание папки для скрипта...')
	createDirectory(dirml..'/StateHelper/')
end

function check_existence(name_folder, description_folder) --> Создание папки, если её нет
	local status_folder = true
	if not doesDirectoryExist(dirml..'/StateHelper/'..name_folder..'/') then
		print('{F54A4A}Ошибка. Отсутствует папка '..description_folder..'. {82E28C}Создание папки '..description_folder..'...')
		createDirectory(dirml..'/StateHelper/'..name_folder..'/')
		status_folder = false
	end
	
	return status_folder
end

function apply_settings(name_file, description_file, array_arg) --> Загрузка настроек или создание файла настроек
	if doesFileExist(dirml..'/StateHelper/'..name_file) then
		print('{82E28C}Чтение файла '..description_file..'...')
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
			print('{F54A4A}Ошибка. Файл '..description_file..' повреждён. {82E28C}Создание нового файла...')
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	else
		print('{F54A4A}Ошибка. Файл '..description_file..' не найден. {82E28C}Создание нового файла...')
		if not doesFileExist(dirml..'/StateHelper/'..name_file) then
			local f = io.open(dirml..'/StateHelper/'..name_file, 'w')
			f:write(encodeJson(array_arg))
			f:flush()
			f:close()
		end
	end
	
	return array_arg
end

--> Музыка
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
record_name = {'Dance', 'Megamix', 'Party 24/7', 'Phonk', 'Гоп FM', 'Руки Вверх', 'Dubstep', 'Big Hits', 'Organic', 'Russian Hits'}
radio = {
	[1] = 'http://212.26.132.129:8000/ArmyFM.m3u',
	[2] = 'https://online.radiobayraktar.ua/RadioBayraktar',
	[3] = 'http://online.nasheradio.ua/NasheRadio',
	[4] = 'http://online.hitfm.ua/HitFM',
	[5] = 'http://www.radiomelodia.com.ua/RadioMelodia.m3u',
	[6] = 'http://icecast.vgtrk.cdnvideo.ru/mayakfm_mp3_192kbps',
	[7] = 'http://nashe1.hostingradio.ru/nashe-128.mp3',
	[8] = 'http://node-33.zeno.fm/0r0xa792kwzuv?rj-ttl=5&rj-tok=AAABfMtdjJ4AtC1pGWo1_ohFMw',
	[9] = 'https://maximum.hostingradio.ru/maximum128.mp3',
	[10] = 'http://listen1.myradio24.com:9000/5967'
}
radio_name = {u8'Армія FM', u8'Байрактар', u8'Наше Радіо', u8'HitFm', u8'MelodiaFm', u8'Маяк', u8'Наше Радио', u8'LoFi Hip-Hop', u8'Максимум', u8'90\'s Eurodance'}
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

function get_status_potok_song() --> Получить статус потока
	local status_potok
	if stream_music ~= nil then
		status_potok = bass.BASS_ChannelIsActive(stream_music)
		status_potok = tonumber(status_potok)
	else
		status_potok = 0
	end
	return status_potok
	--[[
	[0] - Ничего не воспроизводится
	[1] - Играет
	[2] - Блок
	[3] - Пауза
	--]]
end

function rewind_song(time_position) --> Перемотка трека на указанную позицию (позиция трека в секундах)
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

function time_song_position(song_length) --> Получить позицию трека в секундах
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

function find_track_link(search_text, page) --> Поиск песни в интернете
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
			for link in string.gmatch(u8:decode(response.text), 'По вашему запросу ничего не найдено') do
				tracks.link[1] = 'Ошибка404'
				tracks.artist[1] = 'Ошибка404'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://'..site_link..'/get/music/') then
					track = link:match('(.+).mp3')
					tracks.link[#tracks.link + 1] = track..'.mp3'
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				local nametrack = link:match('(.+)')
				nametrack = nametrack and nametrack:gsub('^%s+', '') or 'Неизвестно'
				tracks.name[#tracks.name + 1] = nametrack:gsub('%s+$', '')
			end

			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				local artist = link:match('(.+)')
				artist = artist and artist:gsub('^%s+', '') or "Неизвестно"
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

function get_track_length() --> Получить длину трека в секундах
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

function play_song(url_track, loop_track) --> Включить песню
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
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory()..'/StateHelper/Изображения/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	elseif menu_play_track[2] then
		if not save_tracks.image[selectis]:find('no%-cover%-150') then
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory()..'/StateHelper/Изображения/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					status_image = selectis
					IMG_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Label.png')
				end
			end)
		else
			status_image = selectis
			IMG_label = IMG_No_Label
		end
	end
end

function action_song(action_music) --> Остановить/Пауза/Продолжить
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

function volume_song(volume_music) --> Установить громкость песни
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
	
	--> Создание файлов и установка значений
	check_existence('Для обновления', 'для обновлений')
	check_existence('Отыгровки', 'для отыгровок')
	check_existence('Шпаргалки', 'для шпаргалок')
	
	setting = apply_settings('Настройки.json', 'настроек', setting)
	save_tracks = apply_settings('Треки.json', 'треков', save_tracks)
	scene = apply_settings('Сцены.json', 'сцен', scene)
	
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
			sampAddChatMessage(script_tag..'{FFFFFF}Вы отключили команду /d в настройках.', color_tag)
		end)
	end
	if setting.accent.d and not setting.dep_off then
		sampRegisterChatCommand('d', function(text_accents_d) 
			if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
				sampSendChat('/d ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_d)
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
	
	if setting.frac.org:find(u8'Больница') then
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
	elseif setting.frac.org:find(u8'Центр Лицензирования') then
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
	if setting.online_stat.date_num[1] > setting.online_stat.date_num[2] then --> Если сегодняшняя дата отличается от вчерашней
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
		sampAddChatMessage(script_tag..'{FFFFFF}Скрипт успешно обновился до версии {4EEB40}'.. tostring(scr.version) ..'{FFFFFF}. Подробнее о нововведениях во вкладке "Обновления".', color_tag)
		setting.info_about_new_version = false
		save('setting')
	elseif not setting.hello_mes then
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
		if not doesFileExist(dirml..'/StateHelper/Отыгровки/'..name_file..'.json') then
			local f = io.open(dirml..'/StateHelper/Отыгровки/'..name_file..'.json', 'w')
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
			IMG_No_Label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/No label.png')
		end
		if IMG_Background == nil then
			IMG_Background = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background.png')
		end
		if IMG_Background_White == nil then
			IMG_Background_White = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background White.png')
		end
		if IMG_Background_Black == nil then
			IMG_Background_Black = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Background Black.png')
		end
		if #IMG_Record == 0 then
			IMG_Record = {
				[1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Dance Label.png'),
				[2] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Megamix Label.png'),
				[3] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Party Label.png'),
				[4] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Phonk Label.png'),
				[5] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record GopFM Label.png'),
				[6] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Ruki Vverh Label.png'),
				[7] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Dupstep Label.png'),
				[8] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Bighits Label.png'),
				[9] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Organic Label.png'),
				[10] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Record Russianhits Label.png'),
			}
		end
		if #IMG_Radio == 0 then
			IMG_Radio = {
				[1] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Army.png'),
				[2] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/DFM.png'),
				[3] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Наше Радіо.png'),
				[4] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/HitFm.png'),
				[5] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/MelodiaFm.png'),
				[6] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Mayak.png'),
				[7] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Nashe.png'),
				[8] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/LoFi Hip-Hop.png'),
				[9] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Maximum.png'),
				[10] = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/90s Eurodance.png'),
			}
		end
	else
		sampAddChatMessage(script_tag..'{FFFFFF}Ошибка обнаружения шрифтов. Попробуйте снова через несколько секунд...', color_tag)
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
	if imgui.InvisibleButton(u8'##Закрыть окно', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
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
			text_big_main_screen(u8'Выберите оформление', first_start_anim.vis[2])
		elseif first_start_anim.text[3] then
			text_big_main_screen(u8'Уточните организацию', 1.00)
		elseif first_start_anim.text[4] then
			text_big_main_screen(u8'Ваш никнейм на русском', 1.00)
		elseif first_start_anim.text[5] then
			text_big_main_screen(u8'Пользовательское соглашение', first_start_anim.vis[2])
		elseif first_start_anim.text[6] then
			text_big_main_screen(u8'Обновления', first_start_anim.vis[2])
		end
	end
	
	local result_time = os.clock() - t_pr[1]
	if result_time > 0.12 then result_time = 0.12 end
	t_pr[1] = os.clock()
	
	if first_start_anim.text[1] then
		imgui.PushFont(bold_font[2])
		imgui.SetCursorPos(imgui.ImVec2(338, 200))
		imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, first_start_anim.vis[1]), u8'Привет')
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
				imgui.Text(u8'Светлое')
				
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
				imgui.Text(u8'Тёмное')
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
				skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
					first_start_anim.text[2] = false
					first_start_anim.text[3] = true
				end)
				skin.Button(u8'Назад##false_non', 515, 400, nil, nil, function() end)
				skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Выбранная тема оформления будет отображаться\nво всех окнах программы.\n\nТему можно будет изменить в настройках.')
				imgui.PopFont()
			end
		end
	end
	if first_start_anim.text[3] then
		local carta_org = {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'ТСР'}
		for i = 1, #carta_org do
			if num_of_the_selected_org == i then
				setting.frac.org = carta_org[i]
			end
		end
		imgui.PushFont(font[1])
		if num_of_the_selected_org == 1 then
			if skin.CheckboxOne(u8'Больница ЛС', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'Больница ЛС' end
		else
			if skin.CheckboxOne(u8'Больница ЛС##false_func', 350, 177) then num_of_the_selected_org = 1 setting.frac.org = u8'Больница ЛС' end
		end
		if num_of_the_selected_org == 2 then
			if skin.CheckboxOne(u8'Больница ЛВ', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'Больница ЛВ' end
		else
			if skin.CheckboxOne(u8'Больница ЛВ##false_func', 350, 206) then num_of_the_selected_org = 2 setting.frac.org = u8'Больница ЛВ' end
		end
		if num_of_the_selected_org == 3 then
			if skin.CheckboxOne(u8'Больница СФ', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'Больница СФ' end
		else
			if skin.CheckboxOne(u8'Больница СФ##false_func', 350, 235) then num_of_the_selected_org = 3 setting.frac.org = u8'Больница СФ' end
		end
		if num_of_the_selected_org == 4 then
			if skin.CheckboxOne(u8'Больница Джефферсон', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'Больница Джефферсон' end
		else
			if skin.CheckboxOne(u8'Больница Джефферсон##false_func', 350, 263) then num_of_the_selected_org = 4 setting.frac.org = u8'Больница Джефферсон' end
		end
		if num_of_the_selected_org == 5 then
			if skin.CheckboxOne(u8'Центр Лицензирования', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'Центр Лицензирования' end
		else
			if skin.CheckboxOne(u8'Центр Лицензирования##false_func', 350, 292) then num_of_the_selected_org = 5 setting.frac.org = u8'Центр Лицензирования' end
		end
		if num_of_the_selected_org == 6 then
			if skin.CheckboxOne(u8'ТСР', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'ТСР' end
		else
			if skin.CheckboxOne(u8'ТСР##false_func', 350, 321) then num_of_the_selected_org = 6 setting.frac.org = u8'ТСР' end
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
			first_start_anim.text[3] = false
			first_start_anim.text[4] = true
		end)
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[2] = true
			first_start_anim.text[3] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Выберите организацию, в которой Вы состоите на данный момент.\nЭто поможет настроить хелпер под Ваши задачи.')
		imgui.PopFont()
	end
	if first_start_anim.text[4] then
		imgui.PushFont(font[1])
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not setting.nick:find('%S+%s+%S+') then
			skin.Button(u8'Продолжить##false_non', 630, 400, nil, nil, function() end)
		else
			skin.Button(u8'Продолжить', 630, 400, nil, nil, function() 
				first_start_anim.text[4] = false
				first_start_anim.text[5] = true
			end)
		end
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[2] = true
			first_start_anim.text[4] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Введите в поле ввода Ваш никнейм на русском языке.\nНапример, Альберто Кейн')
		local my_nickname = sampGetPlayerNickname(my.id):gsub('_',' ')
		skin.InputText(255, 255, u8'Ваш ник '..my_nickname..u8' на русском', 'setting.nick', 74, 350, '[а-Я%s]+')
		imgui.PopFont()
	end
	
	if first_start_anim.text[5] then
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(134, 150))
		imgui.BeginChild(u8'Пользовательское соглашение', imgui.ImVec2(600, 217), false)
		imgui.PushFont(font[4])
		imgui.Text(u8'1. Основные термины и определения')
		imgui.PopFont()
		imgui.TextWrapped(u8'1.1 Правообладатель - ИТД Марсель Афанасьев: это лицо, которое обладает правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений. Термин "Правообладатель" также включает в себя разработчика, менеджера, директора, поставщика и других ответственных сторон, участвующих в создании, управлении и поставке Программы (см. определение ниже). Это объединяющий термин, включающий все заинтересованные стороны, которые имеют право предоставлять разрешения на использование Программы (см. определение ниже) и управлять правами доступа в соответствии с данным Лицензионным соглашением (данный договор между двумя сторонами: (Пользователь (см. определение ниже) и Правообладатель), далее "Соглашение").\nПравообладателем данной Программы (см. определение ниже), а также официальным обладателем авторских прав и интеллектуальной собственности, является единственное лицо. Все иные лица, причастные к созданию, разработке, поддержке и другим терминам включающих в себя определение из термина Правообладателя, за исключением правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений данного программного обеспечения (далее "ПО"), являются партнёрами (далее "Партнёр", "Партнёры") Правообладателя.\n')
		imgui.TextWrapped(u8'Термин относится к ПО, в котором находится данное Лицензионное соглашение или на одном виртуальном, облачном или удалённом носителе, учётной записи одного Пользователя всего ресурса, сайта или хранилища, на котором расположено ПО.\n\n')
		imgui.TextWrapped(u8'1.2 Программа - это ПО, принадлежащее Правообладателю, которое было приобретено и установлено на Носитель (см. определение ниже) технического устройства. Из списка выпущенных Правообладателем Программ, данный термин относится ко всем ПО, включающих в своём названии словосочетание "State Helper", написанное на английском языке в любом из возможных вариантов регистра букв.\nНаименование ПО можно найти в свойствах файла установленного с источников Правообладателя в случае, если файл не был отредактирован в последствии перемещения его на Носитель (см. определение ниже) технического устройства.\n\n')
		imgui.TextWrapped(u8'1.3 Носитель - устройство или средство, используемое для хранения и передачи данных. Это может быть физический объект, такой как жёсткий диск, USB-флешка, CD, DVD, Blu-ray диск или другие съёмные устройства хранения информации.\n\n1.4 Arizona Role Play - это проект ролевой игры (Role-Play) на платформе SA:MP (San Andreas Multiplayer), принадлежащий игровой компании Arizona Games. В этом проекте игроки могут взаимодействовать в виртуальном мире, исполняя определенные роли и выполняя задания в атмосфере, созданной на базе игры Grand Theft Auto: San Andreas с использованием мультиплеерной платформы SA:MP.\n\n1.5 Руководство пользователя - документ, который содержит инструкцию о том, как правильно использовать Программу, предоставленную Правообладателем.\n\n1.6 Пользователь - человек, установивший или использующий Программу, предоставленную Правообладателем.\n\n1.7 Блокировка программы - это техническая или программная мера, которая преднамеренно ограничивает доступ Пользователя к определенным функциям, данным или ресурсам Программы.\n\n1.8 Интернет - информационно-телекоммуникационная сеть, т. е. технологическая система, предназначенная для передачи по линиям связи информации, доступ к которой осуществляется с использованием средств вычислительной техники.\n\n1.9 Установка - процесс размещения Программы на компьютере или устройстве, чтобы она стала доступной и готовой к использованию. Во время установки происходит копирование файлов Программы на жёсткий диск или другое физическое хранилище, кроме тех, доступ к которым требует наличия Интернета.\n\n')
		imgui.TextWrapped(u8'1.10 Игра - конкретный вид развлекательной деятельности, не связанный с непосредственными задачами жизнеобеспечения, выполняющий функции заполнения досуга человека.\n\n1.11 Версия программы - присвоенный номер Программы, позволяющий определить новизну ПО, т. е. дату его выхода, а также различия относительно предыдущих версий Программы.\nВерсия программы отображена в самой Программе под соответствующим названием включающая в своём словосочетании слово "Версия".\n\n1.12 Закрытое тестирование - процесс исследования, испытания ПО, имеющий своей целью проверку соответствия между реальным поведением программы и её ожидаемым поведением на конечном наборе тестов, выбранных определённым образом.\nПроцесс осуществляется без учёта возможности публикации такого ПО в общий доступ, дающий возможность любому Пользователю осуществить установку ПО.\nТермин применяется к Программе, имеющей в своём программном коде заданную условную переменную "Beta" не соответствующей второму числу текущей Версии программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'2. Лицензия')
		imgui.PopFont()
		imgui.TextWrapped(u8'2.1 Правообладатель предоставляет Вам неисключительную лицензию на использование Программы для упрощения процесса Игры на проекте Arizona Role Play, описанных в Руководстве пользователя, при условии, в котором Вами соблюдены все необходимые требования, описанные в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\nВ случае использования Программы для тестирования функциональности, Правообладатель предоставляет Вам неисключительную лицензию на тестирование программы при условии соблюдения Вами всех необходимых требований, описанных в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\n\n')
		imgui.TextWrapped(u8'2.2 При соблюдении определённых условий Вы можете создать копию программы типа "Закрытое тестирование" с единственной целью архивирования и замены правомерно установленного экземпляра в случае его утери, уничтожения или непригодности. Тем не менее, использование такой копии для иных целей запрещено, и владение ею должно прекратиться, если обладание правомерным экземпляром программы прекращается.\n\n')
		imgui.TextWrapped(u8'2.3 После установки программы Вам, по возможности, предоставляется право получать от Правообладателя или его Партнёров:\n- новые версии ПО по мере их выхода (через Интернет)\n- техническую поддержку (через Интернет)\n- доступ к информационным и вспомогательным ресурсам Правообладателя.\nДанные возможности не могут быть гарантированы Правообладателем и в праве перестать быть доступными любому Пользователю Программы в любой момент времени без объяснения причин.\n\n')
		imgui.TextWrapped(u8'2.4 В случае установки Программы типа "Закрытое тестирование" через Интернет, Вы имеете право использовать такую копию Программы исключительно на одном техническом устройстве или Ностеле. Количество созданных копий Программы на одном устройстве неограниченно. Запрещается создавать, распространять, передавать копию такой Программы через облачные хранилища, где доступ к ней могут получить другие лица, кроме Вас. Запрещается копировать такую Программу на носитель, физический доступ к которому у Вас отсутствует. Запрещено устанавливать такую копию Программу на любой носитель с источников, не включённых в перечень, описанный в данном Соглашении.\n\n')
		imgui.TextWrapped(u8'2.5 Программа считается установленной с момента её размещения на Носитель Пользователя, независимо от того, запущена она впоследствии Пользователем или нет.\n\n')
		
		imgui.PushFont(font[4])
		imgui.Text(u8'3. Обновления')
		imgui.PopFont()
		imgui.TextWrapped(u8'После установки программы на Носитель, Правообладатель предоставляет возможность Пользователям выбирать способ обновления Программы. Если Пользователь сам решит использовать автоматическое обновление, поставив соответствующую галочку в самой Программе, тогда обновления будут проводиться без дополнительного разрешения или согласия с его стороны.\n\nВ противном случае, если Пользователь не выбрал автоматическое обновление, процесс установки обновления будет требовать подтверждения Пользователя в самой Программе. Пользователю будет предоставлена возможность ознакомиться с деталями обновления и дать согласие на его установку перед началом процесса.\n\n')
		imgui.TextWrapped(u8'Независимо от выбранного способа обновления, каждое обновление будет регулироваться настоящим Соглашением, а содержание, функции и возможности обновленной Программы определяются исключительно Правообладателем. Эти обновления могут включать как добавление, так и удаление функций Программы, а также полную замену Программы. При этом Вам может быть ограничено использование Программы или устройства (включая определенные функции) до тех пор, пока обновление не будет полностью установлено или активировано.\n\nПравообладатель может прекратить предоставление поддержки Программы, пока Вы не установите все доступные обновления. Необходимость и периодичность предоставления обновлений определяется Правообладателем по его усмотрению, и Правообладатель не обязан предоставлять Вам обновления. Также Правообладатель может прекратить предоставление обновлений для версий Программы, отличных от наиболее новой версии, или для обновлений, которые не поддерживают использование Программы с различными версиями операционных систем или другим ПО.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'4. Права собственности')
		imgui.PopFont()
		imgui.TextWrapped(u8'4.1 Программа и её программный код являются интеллектуальной собственностью Правообладателя и защищены применимым авторским правом, а также международными договорами и законодательством Российской Федерации. Если Вы являетесь Пользователем, установившим Программу на законных основаниях, то Вы имеете право просматривать открытый программный код Программы. Предоставляя свои комментарии и предложения, касающиеся Программы, Вы предоставляете Правообладателю разрешение на их использование при разработке своих настоящих или будущих продуктов или услуг. При этом, Вы соглашаетесь, что такое использование не потребует выплаты компенсации и дополнительного разрешения от Вас на хранение или использование Ваших материалов.\n\n')
		imgui.TextWrapped(u8'4.2 Помимо указанных в настоящем Соглашении, владение Программой и её использование не предоставляют Вам какие-либо права на Программу или программный код, включая авторские права, патенты, торговые знаки и другие права интеллектуальной собственности. Все такие права полностью принадлежат Правообладателю Программы.\n\n')
		imgui.TextWrapped(u8'4.3 Вы не имеете права копировать или использовать Программу или её программный код, за исключением случаев, описанных в разделе 2 настоящего Соглашения.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'5. Конфиденциальность')
		imgui.PopFont()
		imgui.TextWrapped(u8'Вы даете Правообладателю и партнёрам Правообладателя согласие на использование Ваших данных в соответствии с политикой конфиденциальности. Вы осознаете, что Ваши данные будут использоваться для различных целей, таких как обработка событий использования Программы, улучшения Программы, предоставления Вам информации об установленной Программе и предложение Вам других Программ.\n\nВы также подтверждаете, что Правообладатель может передавать Ваши данные партнёрам Правообладателя, таким как поставщики платформы электронной коммерции, обработчики платежей, поставщики поддержки, услуг и Программ от имени Правообладателя, а также поставщики, предоставляющие Правообладателю или партнёрам Правообладателя аналитические данные о покупках и сбоях в работе Программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'6. Прекращение действия')
		imgui.PopFont()
		imgui.TextWrapped(u8'6.1 Если Вы нарушите любое из обязательств, установленных в данном соглашении, включая обязательства, определённые в разделах 2 или 5, настоящее Соглашение автоматически прекратится и Вы лишитесь права на получение обновлений Программы. При возникновении нарушения, которое причинило ущерб Правообладателю, Правообладатель имеет право обратиться к законным средствам защиты, предусмотренным законодательством. Отказ от ответственности и ограничения, установленные для Правообладателя в данном соглашении, будут действовать и после его прекращения.\n\n')
		imgui.TextWrapped(u8'6.2 Правообладатель имеет право уведомить Вас и прекратить действие данного Соглашения относительно конкретной Программы или всех Программ в любое удобное время. После фактического прекращения действия Соглашения Вы теряете право на использование Программы.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'7. Основные положения ответственности сторон')
		imgui.PopFont()
		imgui.TextWrapped(u8'7.1 Правообладатель не несёт никакой ответственности в следующих случаях:\n\n7.1.1 Программа не работает должным образом в связи с нестабильным подключением интернета, устаревшими или неработоспособными техническими характеристиками устройства или Носителя, на которое установлена Программа, недостающим дополнительным ПО, которое обеспечивает необходимую работу Программы, либо из-за пользовательского редактирования программного кода Программы.\n\n7.1.2 Нарушение одного и более пунктов данного Соглашения, после установки Программы.\n\n')
		imgui.TextWrapped(u8'7.1.3 Утеря одной или нескольких копий Программы после её установки.\n\n7.1.4 Потеря трудоспособности Пользователя по любой причине, вследствие чего Пользователь не имеет более физической возможности использовать Программу.\n\n7.1.5 Пользователь согласился использовать Программу, прочитав Лицензионное соглашение, но в последствии, по собственной инициативе, решил отказаться от использования Программы.\n\n7.1.6 Пользователь не получает обновления Программы.\n\n7.1.7 Пользователь не имеет свободного места для установки Программы на Носитель.\n\n7.1.8 Пользователь не имеет возможности установить Программу в связи с отсутствием или нестабильным подключением Интернета.\n\n7.1.9 Пользователь не имеет возможности установить Программу в связи с ограничениями в стране или регионе, в котором он находится.\n\n7.1.10 Пользователь не имеет возможности установить Программу в связи с ПО, через которое он пытается совершить установку.\n\n')
		imgui.TextWrapped(u8'7.1.11 Пользователя не удовлетворили ожидания процесса работы Программы или его функциональные возможности.\n\n7.1.12 Пользователь погиб, либо получил физическую или моральную травму в результате пользования Программой.\n\n7.2 Пользователь несёт полную ответственность перед Правообладателем за соблюдение условий Соглашения.\n\n7.3 Программа предоставляется на международных условиях «как есть» (as is). Правообладатель не гарантирует безошибочную и бесперебойную работы Программы, её отдельных компонентов, функциональности, каким-либо целям и ожиданиям Пользователя, а также не предоставляет никаких иных гарантий, прямо не указанных в Соглашении.\n\n7.4 Правообладатель вправе изменить условия настоящего Соглашения в любой момент времени без предварительного уведомления Пользователя об этом.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'8. Общие положения')
		imgui.PopFont()
		imgui.TextWrapped(u8'8.1 Уведомления. В произвольное время Поставщик может направить Вам уведомление по электронной почте, через всплывающее окно, диалоговое окно или другие средства, даже если в некоторых случаях Вы можете не получить уведомление до тех пор, пока не запустите Программу. Такое уведомление считается доставленным с момента, когда Правообладатель сделал его доступным через Программу, независимо от фактического времени получения.\n\n8.2 Вопросы по данному Соглашению. Если у Вас возникнут вопросы относительно данного Соглашения или потребуется получить дополнительную информацию от Правообладателя, обратитесь по указанному ниже адресу электронной почты: morte4569@vk.com.\n\n')
		imgui.TextWrapped(u8'8.3 Импедимент выполнения обязательств. В случае каких-либо сбоев или снижения производительности, полностью или частично обусловленных непредвиденными ситуациями в предоставлении коммунальных услуг (включая электроэнергию), проблемами с подключением к интернету, недоступностью телекоммуникационных или информационно-технологических услуг, неисправностями телекоммуникационного или ИТ-оборудования, забастовками и другими подобными акциями, террористическими актами, DDoS-атаками и другими атаками и нарушениями ИТ-характера, стихийными бедствиями или обстоятельствами, которые находятся вне контроля Правообладателя, включая наводнения, саботаж, пожары, войны, спец. военные операции, нападения, теракты и прочие обстоятельства непреодолимой силы, а также любыми другими причинами, которые не поддаются существенному влиянию со стороны Правообладателя, Правообладатель освобождается от ответственности за такие события.\n\n')
		imgui.TextWrapped(u8'8.4 Передача прав и обязательств. Вам не разрешается передавать Ваши права или обязательства, установленные настоящим Соглашением, без предварительного письменного согласия Правообладателя. Своей стороной, Правообладатель вправе передать настоящее Соглашение в любой момент по своему усмотрению, без необходимости получения Вашего предварительного согласия в письменной форме.\n\n8.5 Подключение к Интернету. Для работы Программы необходимо обеспечить активное и стабильное подключение к Интернету. За обеспечение постоянного активного и стабильного Интернет-соединения отвечает лично Пользователь.\n\n')
		imgui.PushFont(font[4])
		imgui.Text(u8'9. Ответственности сторон при использовании Программы')
		imgui.PopFont()
		imgui.TextWrapped(u8'9.1 Программа обладает функцией обновления, осуществляемой путём загрузки файлов на тот же носитель, на котором установлена Программа.\n\n9.2 При установке и запуске Программы, Пользователь выражает своё согласие на получение неограниченного количества необходимых файлов для работы Программы с расширениями исполняемых файлов в форматах jpg, png, ttf, json, lua и txt в любой момент времени в процессе работы программы, а также на обработку файлов любого размера, не превышающего 8589934592 бит.\n\n9.3 Пользователь соглашается с тем, что Программа имеет право на неограниченное количество перезаписей и чтений установленных файлов в процессе её работы, без предварительного уведомления Пользователя Программы об этом.\n\n9.4 Пользователь принимает факт и соглашается с тем, что в любой момент времени по любой причине Программа или её файлы могут быть безвозвратно уничтожены в связи с сбоями Программы.\n\n')
		imgui.TextWrapped(u8'9.5 Правообладатель не несёт ответственности в случае сбоя операционной системы Пользователя (далее "ОС"), который может привести к временной или постоянной невозможности пользования ОС, а также к возможному уничтожению ОС с Носителя Пользователя в ходе выполнения Программы.\n\n9.6 Правообладатель не несёт ответственности за ошибки, допущенные Пользователем при использовании Программы, которые могут вызвать проблемы в ходе Игры, а также могут привести к ограничениям в использовании Игры, включая блокировку игрового аккаунта.\n\n9.7 Правообладатель осознаёт ответственность за намеренную кражу, попытку кражи, распространение, неправомерное использование личных данных пользователя с его технического Носителя. Правообладатель принимает на себя ответственность, при условии установки программы от официального лица в виде Правообладателя Программы, что Правообладатель понесёт ответственность согласно 273 ст. Уголовного Кодекса Российской Федерации (страна проживания Правообладателя) в случае распространения вредоносных программ на техническое устройство или технический Носитель Пользователя.\n')
		imgui.TextWrapped(u8'Правообладатель гарантирует отсутствие вредоносных файлов, вредоносных программ и модификаций в Программе и использующих ею файлов.\n\n9.8 Правообладатель вправе отправлять Пользователю уведомления любого типа, любого содержания, любой длительности отображения, в любой момент времени, в любом количестве и без предварительного информирования Пользователя об этом событии в самой Программе.\n\n9.9 Правообладатель наделил Программу возможностью в процессе её работы безвозвратно уничтожать, изменять содержимое или название файлов любого расширения, которые принадлежат Правообладателю или были созданы самой Программой в ходе её работы. Пользователь соглашается с этим решением.')
		imgui.EndChild()
		
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		skin.Button(u8'Принять', 630, 400, nil, nil, function()
			first_start_anim.text[5] = false
			first_start_anim.text[6] = true
		end)
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[4] = true
			first_start_anim.text[5] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Приняв пользовательское соглашение, Вы соглашаетесь\nс политикой данной программы.')
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
			imgui.Text(u8'Всё отлично! У Вас последняя версия скрипта.')
		else
			imgui.Text(u8'Имеется обновление до версии '..new_version.version)
		end
		skin.DrawFond({134, 385}, {0, 0}, {600, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
		if not type_version.rel then
			skin.Button(u8'Завершить', 630, 400, nil, nil, function()
				first_start_anim.text[6] = false
				setting.int.first_start = false
				setting.info_about_new_version = false
				add_table_act(setting.frac.org, true)
				save('setting')
				create_act(1)
			end)
		else
			if not off_butoon_end then
				skin.Button(u8'Обновить', 630, 400, nil, nil, function()
					setting.int.first_start = false
					setting.info_about_new_version = false
					add_table_act(setting.frac.org, true)
					save('setting')
					update_download()
					off_butoon_end = true
				end)
			else
				skin.Button(u8'Обновить##false_non', 630, 400, nil, nil, function() end)
			end
		end
		skin.Button(u8'Назад', 515, 400, nil, nil, function()
			first_start_anim.text[5] = true
			first_start_anim.text[6] = false
		end)
		skin.EmphText(u8'Узнать подробнее', 140, 410, u8'Обновления нужны для устранения ошибок работы скрипта.\nДля корректной работы необходимо обновлять скрипт.')
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
	imgui.BeginChild(u8'РП зона', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	
	if select_scene == 0 then
		if not setting.rp_zone then
			imgui.PushFont(font[4])
			imgui.SetCursorPos(imgui.ImVec2(93, 155 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'Здесь Вы можете создать Role Play SS для Вашего отчёта')
			imgui.SetCursorPos(imgui.ImVec2(168, 185 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'прямо в игре без сторонних программ!')
			imgui.PopFont()
			imgui.PushFont(font[1])
			skin.Button(u8'Начать', 270, 225 + ((start_pos + new_pos) / 2), 125, 35, function()
				setting.rp_zone = true
				save('setting')
			end)
			imgui.PopFont()
		else
			if #scene.bq == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(258, 159 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет сцен')
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Добавить сцену', 270, 212 + ((start_pos + new_pos) / 2), 125, 35, function()
					local new_scene = {
						nm = u8'Сцена '..(#scene + 1),
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
					font_sc = renderCreateFont('Times New Roman', scene_buf.size, scene_buf.flag)
					select_scene = #scene.bq
					edit_sc = true
				end)
				imgui.PopFont()
			else
				new_draw(17, -1 + (#scene.bq * 68))
				imgui.PushFont(font[1])
				for i = 1, #scene.bq do
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Перейти в редактор сцены'..i, imgui.ImVec2(666, 68)) then 
						POS_Y = 380
						col_sc = {}
						if scene.bq[i].qq ~= 0 then
							for m = 1, #scene.bq[i].qq do
								table.insert(col_sc, convert_color(scene.bq[i].qq[m].color))
							end
						end
						scene_buf = scene.bq[i]
						font_sc = renderCreateFont('Times New Roman', scene_buf.size, scene_buf.flag)
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
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 3) -- вверха лев прав
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
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 15) -- одиночный
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
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 12) -- низы лев прав
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 638, p.y + 39), 28, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 0) -- квадрат
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
				skin.Button(u8'Добавить сцену', 270, 34 + (#scene.bq * 68), 125, 35, function()
					local new_scene = {
						nm = u8'Сцена '..(#scene + 1),
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
		skin.Button(u8'Сохранить сцену', 15, 29, 202, 30, function() 
			scene.bq[select_scene] = scene_buf
			save('scene')
			select_scene = 0
			edit_sc = false
		end)
		skin.Button(u8'Удалить сцену', 232, 29, 202, 30, function()
			table.remove(scene.bq, select_scene)
			save('scene')
			select_scene = 0
			edit_sc = false
		end)
		skin.Button(u8'Включить сцену', 449, 29, 202, 30, function()
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
		imgui.SetCursorPos(imgui.ImVec2(15, 73))
		imgui.Text(u8'Предосмотр')
		imgui.SetCursorPos(imgui.ImVec2(620, 72))
		if skin.Switch(u8'##Предосмотр', preview_sc) then preview_sc = not preview_sc end
		
		new_draw(113, 50)
		skin.InputText(15, 127, u8'Задайте имя сцены', 'scene_buf.nm', 80, 636)
		
		new_draw(175, 213)
		if skin.Slider('##Размер шрифта', 'scene_buf.size', 1, 30, 205, {455, 186}, '') then font_sc = renderCreateFont('Times New Roman', scene_buf.size, scene_buf.flag) end
		if skin.Slider('##Флаг шрифта', 'scene_buf.flag', 1, 30, 205, {455, 217}, '') then font_sc = renderCreateFont('Times New Roman', scene_buf.size, scene_buf.flag) end
		skin.Slider('##Расстояние между строками', 'scene_buf.dist', 1, 40, 205, {455, 247})
		skin.Slider('##Прозрачность текста', 'scene_buf.vis', 1, 255, 205, {455, 277})
		imgui.SetCursorPos(imgui.ImVec2(620, 309))
		if skin.Switch(u8'##Инверсировать текст', scene_buf.invers) then scene_buf.invers = not scene_buf.invers end
		imgui.SetCursorPos(imgui.ImVec2(15, 188))
		imgui.Text(u8'Размер шрифта')
		imgui.SetCursorPos(imgui.ImVec2(15, 219))
		imgui.Text(u8'Флаг шрифта')
		imgui.SetCursorPos(imgui.ImVec2(15, 249))
		imgui.Text(u8'Расстояние между строками')
		imgui.SetCursorPos(imgui.ImVec2(15, 279))
		imgui.Text(u8'Прозрачность текста')
		imgui.SetCursorPos(imgui.ImVec2(15, 310))
		imgui.Text(u8'Инверсировать текст')
		skin.Button(u8'Изменить положение текста', 15, 346, 636, 30, function() scene_edit() end)
		
		local pos_X_sc = 470
		imgui.PushFont(bold_font[4])
		imgui.SetCursorPos(imgui.ImVec2(243, pos_X_sc - 58))
		imgui.Text(u8'Отыгровки')
		imgui.PopFont()
		new_draw(pos_X_sc - 12, 58 + (#scene_buf.qq * 95))
		skin.Button(u8'Добавить отыгровку', 238, pos_X_sc + (#scene_buf.qq * 95), 202, 30, function() 
			table.insert(scene_buf.qq, {
				text = '',
				act = '',
				type_color = u8'Свой текст и цвет',
				nm = sampGetPlayerNickname(my.id),
				color = 0xFFFFFFFF
			})
			table.insert(col_sc, convert_color(scene_buf.qq[#scene_buf.qq].color))
		end)
		
		local remove_table_qq = nil
		for i = 1, #scene_buf.qq do
			local pos_Y_scene = pos_X_sc + ((i - 1) * 95)
			if scene_buf.qq[i].type_color ~= u8'/todo' then
				skin.InputText(15, pos_Y_scene, u8'Текст отыгровки##'..i, 'scene_buf.qq.'..i..'.text', 300, 595)
			else
				skin.InputText(15, pos_Y_scene, u8'Текст речи##'..i, 'scene_buf.qq.'..i..'.text', 300, 290)
				skin.InputText(320, pos_Y_scene, u8'Текст отыгровки##'..i, 'scene_buf.qq.'..i..'.act', 300, 290)
			end
			local scroll_bool = false
			if skin.List({15, pos_Y_scene + 35}, scene_buf.qq[i].type_color, {u8'Свой текст и цвет', u8'/me', u8'/do', u8'/todo', u8'Речь', u8'Телефон'}, 200, 'scene_buf.qq.'..i..'.type_color', '') then
			end
			if scene_buf.qq[i].type_color == u8'Свой текст и цвет' then
				imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
				imgui.Text(u8'Цвет')
				imgui.SetCursorPos(imgui.ImVec2(270, pos_Y_scene + 40))
				if imgui.ColorEdit4('##Color'..i, col_sc[i], imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
					local c = imgui.ImVec4(col_sc[i].v[1], col_sc[i].v[2], col_sc[i].v[3], col_sc[i].v[4])
					local argb = imgui.ColorConvertFloat4ToARGB(c)
					scene_buf.qq[i].color = imgui.ColorConvertFloat4ToARGB(c)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230, pos_Y_scene + 41))
				imgui.Text(u8'Имя персонажа')
				skin.InputText(340, pos_Y_scene + 39, u8'Имя персонажа##'..i, 'scene_buf.qq.'..i..'.nm', 150, 270)
			end
			imgui.SetCursorPos(imgui.ImVec2(632, pos_Y_scene - 1))
			if imgui.InvisibleButton(u8'##Удалить'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
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
		if imgui.InvisibleButton(u8'##Новое напоминание', imgui.ImVec2(175, 25)) then
			reminder_buf = {
				nm = u8'Напоминание '..(#setting.reminder + 1),
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
		imgui.TextColored(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00), u8'Напоминание')
		imgui.PopFont()
		imgui.PushFont(fa_font[1])
		imgui.SetCursorPos(imgui.ImVec2(183, 441 + start_pos + new_pos))
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
		imgui.Text(fa.ICON_PLUS)
		imgui.PopStyleColor(1)
		imgui.PopFont()
	else
		imgui.PushFont(font[1])
		local mont = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}
		local hr = tostring(reminder_buf.hour)
		local mn = tostring(reminder_buf.min)
		if reminder_buf.hour <= 9 then
			hr = '0'..hr
		end
		if reminder_buf.min <= 9 then
			mn = '0'..mn
		end
		local calc = imgui.CalcTextSize(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' г. в '..hr..':'..mn)
		imgui.SetCursorPos(imgui.ImVec2(512 - calc.x / 2, 437 + start_pos + new_pos))
		imgui.Text(reminder_buf.day..' '..u8(mont[reminder_buf.mon])..' '..reminder_buf.year..u8' г. в '..hr..':'..mn)
		imgui.PopFont()
		skin.Button(u8'Сохранить', 179, 433 + start_pos + new_pos, 180, 26, function() 
			reminder_edit = false
			table.insert(setting.reminder, 1, reminder_buf)
			save('setting')
			reminder_buf = {}
		end)
		skin.Button(u8'Удалить', 666, 433 + start_pos + new_pos, 180, 26, function()
			reminder_edit = false
			reminder_buf = {}
		end)
	end

	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'Напоминания', imgui.ImVec2(682, 387 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	if not reminder_edit then
		if #setting.reminder == 0 then
			imgui.PushFont(bold_font[4])
			imgui.SetCursorPos(imgui.ImVec2(185, 170 + ((start_pos + new_pos) / 2)))
			imgui.Text(u8'Нет напоминаний')
			imgui.PopFont()
		else
			for i = 1, #setting.reminder do
				local pos_y = 17 + ((i - 1) * 107)
				imgui.SetCursorPos(imgui.ImVec2(0, pos_y))
				if imgui.InvisibleButton(u8'##Удаление напоминания'..i, imgui.ImVec2(666, 95)) then imgui.OpenPopup(u8'Удаление напоминания') remove_reminder = i end
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
					imgui.Text(u8'Без содержания')
				else
					imgui.Text(setting.reminder[i].nm)
				end
				skin.DrawFond({17, pos_y + 43}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40))
				local week_dot = {u8'ПН, ', u8'ВТ, ', u8'СР, ', u8'ЧТ, ', u8'ПТ, ', u8'СБ, ', u8'ВС, '}
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
					repeat_text = u8'Без повторений'
				end
				local calc = imgui.CalcTextSize(repeat_text)
				imgui.SetCursorPos(imgui.ImVec2(649 - calc.x, pos_y + 12))
				imgui.Text(repeat_text)
				skin.DrawFond({17, pos_y + 57}, {0, 0}, {4, 25}, imgui.ImVec4(1.00, 0.58, 0.02 ,1.00))
				local mont = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}
				local hr = tostring(setting.reminder[i].hour)
				local mn = tostring(setting.reminder[i].min)
				if setting.reminder[i].hour <= 9 then
					hr = '0'..hr
				end
				if setting.reminder[i].min <= 9 then
					mn = '0'..mn
				end
				imgui.SetCursorPos(imgui.ImVec2(31, pos_y + 62))
				imgui.Text(setting.reminder[i].day..' '..u8(mont[setting.reminder[i].mon])..' '..setting.reminder[i].year..u8' г. в '..hr..':'..mn)
				imgui.PopFont()
			end
			imgui.Dummy(imgui.ImVec2(0, 28))
			if imgui.BeginPopupModal(u8'Удаление напоминания', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(15, 12))
				imgui.Text(u8'Вы уверены, что хотите удалить напоминание?  ')
				skin.Button(u8'Удалить##напоминание', 15, 40, 145, 30, function() table.remove(setting.reminder, remove_reminder) save('setting') imgui.CloseCurrentPopup() end)
				skin.Button(u8'Оставить##напоминание', 170, 40, 145, 30, function() imgui.CloseCurrentPopup() end)
				imgui.PopFont()
				imgui.Dummy(imgui.ImVec2(0, 7))
				imgui.EndPopup()
			end
		end
	else
		new_draw(17, 44)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 29))
		imgui.Text(u8'Текст напоминания')
		skin.InputText(150, 28, u8'Введите текст##df', 'reminder_buf.nm', 100, 500)
		
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
		imgui.Text(u8'ПН\n\nВТ\n\nСР\n\nЧТ\n\nПТ\n\nСБ\n\nВС')
		for i = 1, 7 do
			imgui.SetCursorPos(imgui.ImVec2(500, 82 + ((i - 1) * 30)))
			if skin.Switch(u8'##Повторение неделями'..i, reminder_buf.repeats[i]) then reminder_buf.repeats[i] = not reminder_buf.repeats[i] end
		end
		imgui.SetCursorPos(imgui.ImVec2(488, 314))
		imgui.Text(u8'Звук')
		imgui.SetCursorPos(imgui.ImVec2(488.5, 335))
		if skin.Switch(u8'##Звуковой сигнал', reminder_buf.sound) then reminder_buf.sound = not reminder_buf.sound end
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
		if imgui.VSliderFloat(u8'##Часы слайдера', imgui.ImVec2(18, 220), rem_fl_h, 0, 22, '') then reminder_buf.hour = round(rem_fl_h.v, 1) end
		imgui.SetCursorPos(imgui.ImVec2(630, 133))
		if imgui.VSliderFloat(u8'##Минуты слайдера', imgui.ImVec2(18, 220), rem_fl_m, 0, 58, '') then reminder_buf.min = round(rem_fl_m.v, 1) end
		
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
		
		local month = {u8'Январь', u8'Февраль', u8'Март', u8'Апрель', u8'Май', u8'Июнь', u8'Июль', u8'Август', u8'Сентябрь', u8'Октябрь', u8'Ноябрь', u8'Декабрь'}
		imgui.SetCursorPos(imgui.ImVec2(15, 89))
		imgui.PushFont(font[4])
		imgui.Text(month[tonumber(reminder_buf.mon)]..' '..reminder_buf.year..u8' г.')
		imgui.PopFont()
		skin.DrawFond({15, 124}, {0, 0}, {420, 1.0}, imgui.ImVec4(0.50, 0.50, 0.50, 0.30), 15, 2)
		imgui.SetCursorPos(imgui.ImVec2(373, 88))
		if imgui.InvisibleButton('##Смах влево', imgui.ImVec2(25, 25)) then
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
		if imgui.InvisibleButton('##Смах вправо', imgui.ImVec2(25, 25)) then
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
		
		local week_name = {u8'ПН', u8'ВТ', u8'СР', u8'ЧТ', u8'ПТ', u8'СБ', u8'ВС'}
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
			if imgui.InvisibleButton(u8'##Номер дня'..i, imgui.ImVec2(24, 24)) then reminder_buf.day = i end
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
	imgui.BeginChild(u8'Меню собеседования', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	if not sobes_menu then
		new_draw(17, 43)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 29))
		imgui.Text(u8'Введите id игрока')
		skin.InputText(144, 27, u8'Укажите id игрока', 'id_sobes', 4, 150, 'num')
		if setting.sob.level ~= '' and setting.sob.legal ~= '' and setting.sob.narko ~= '' and id_sobes ~= '' then
			skin.Button(u8'Начать собеседование', 310, 24, 170, 28, function()
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
						writ = -1
					}
					sobes_menu = true
					pl_sob.id = tonumber(id_sobes)
					pl_sob.nm = sampGetPlayerNickname(id_sobes)
				end
			end)
		elseif id_sobes ~= '' then
			skin.Button(u8'Начать собеседование##false_non', 310, 24, 170, 28, function() end)
			imgui.SetCursorPos(imgui.ImVec2(490, 29))
			imgui.TextColoredRGB('{cf2727}Заполните все поля ниже!')
		else
			skin.Button(u8'Начать собеседование##false_non', 310, 24, 170, 28, function() end)
			imgui.SetCursorPos(imgui.ImVec2(490, 29))
			imgui.TextColoredRGB('{cf2727}Укажите id игрока!')
		end
		imgui.PopFont()
		
		imgui.PushFont(bold_font[3])
		imgui.SetCursorPos(imgui.ImVec2(198, 75))
		imgui.Text(u8'Настройки меню собеседования')
		imgui.PopFont()
		
		new_draw(103, 103)
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(15, 115))
		imgui.Text(u8'Минимальный уровень игрока для вступления')
		imgui.SetCursorPos(imgui.ImVec2(15, 145))
		imgui.Text(u8'Минимальное значение законопослушности игрока для вступления')
		imgui.SetCursorPos(imgui.ImVec2(15, 175))
		imgui.Text(u8'Допустимое количество наркозависимости игрока для вступления')
		
		skin.InputText(531, 113, u8'Значение##1', 'setting.sob.level', 3, 120, 'num', 'setting')
		skin.InputText(531, 143, u8'Значение##2', 'setting.sob.legal', 4, 120, 'num', 'setting')
		skin.InputText(531, 173, u8'Значение##3', 'setting.sob.narko', 4, 120, 'num', 'setting')
		imgui.PopFont()
		
		imgui.PushFont(bold_font[3])
		imgui.SetCursorPos(imgui.ImVec2(251, 221))
		imgui.Text(u8'Перечень вопросов')
		imgui.PopFont()
		
		local POS_QY = 249
		imgui.PushFont(font[1])
		if #setting.sob.qq ~= 0 then
			local tabl_rem = 0
			for i = 1, #setting.sob.qq do
				new_draw(POS_QY, 106 + (#setting.sob.qq[i].q * 35))
				imgui.SetCursorPos(imgui.ImVec2(15, POS_QY + 12))
				imgui.Text(u8'Имя вопроса')
				skin.InputText(110, POS_QY + 11, u8'Задайте имя вопроса##sel'..i, 'setting.sob.qq.'..i..'.nm', 50, 541, nil, 'setting')
				if #setting.sob.qq[i].q ~= 0 then
					local tabl_rem_2 = 0
					for m = 1, #setting.sob.qq[i].q do
						skin.InputText(15, POS_QY + 55 + ((m - 1) * 35), u8'Напишите Ваше сообщение, которое отправится в чат##sel'..i..m, 'setting.sob.qq.'..i..'.q.'..m, 512, 608, nil, 'setting')
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
					skin.Button(u8'Добавить ответ##false_non', 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() end)
				else
					skin.Button(u8'Добавить ответ##sel'..i, 15, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() 
						table.insert(setting.sob.qq[i].q, '')
						save('setting')
					end)
				end
				skin.Button(u8'Удалить вопрос##fas'..i, 180, POS_QY + 55 + (#setting.sob.qq[i].q * 35), 150, 33, function() tabl_rem = i end)
				POS_QY = POS_QY + 118 + (#setting.sob.qq[i].q * 35)
			end
			if tabl_rem ~= 0 then table.remove(setting.sob.qq, tabl_rem) save('setting') end
		end
		POS_QY = POS_QY + 2
		if #setting.sob.qq >= 26 then
			skin.Button(u8'Создать новый вопрос##false_non', 208, POS_QY, 250, 33, function() end)
		else
			skin.Button(u8'Создать новый вопрос', 208, POS_QY, 250, 33, function()
				table.insert(setting.sob.qq, {
					nm = u8'Вопрос '..(#setting.sob.qq + 1),
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
		imgui.PopFont()
		skin.DrawFond({17, 52}, {0, 0}, {632, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({225, 60}, {0, 0}, {1, 65}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		skin.DrawFond({445, 60}, {0, 0}, {1, 65}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
		
		imgui.PushFont(font[1])
		imgui.SetCursorPos(imgui.ImVec2(17, 62))
		imgui.Text(u8'Лет в штате:')
		imgui.SetCursorPos(imgui.ImVec2(17, 84))
		imgui.Text(u8'Законопослушн:')
		imgui.SetCursorPos(imgui.ImVec2(17, 106))
		imgui.Text(u8'Работает:')
		imgui.SetCursorPos(imgui.ImVec2(240, 62))
		imgui.Text(u8'Наркозавис:')
		imgui.SetCursorPos(imgui.ImVec2(240, 84))
		imgui.Text(u8'Здоровье:')
		imgui.SetCursorPos(imgui.ImVec2(240, 106))
		imgui.Text(u8'Чёрный список:')
		imgui.SetCursorPos(imgui.ImVec2(460, 68))
		imgui.Text(u8'Лиц. на авто:')
		imgui.SetCursorPos(imgui.ImVec2(460, 97))
		imgui.Text(u8'Повестка:')
		
		imgui.SetCursorPos(imgui.ImVec2(104, 62))
		if sob_info.level == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.level >= tonumber(setting.sob.level) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.level)..' из '..setting.sob.level)
		elseif sob_info.level < tonumber(setting.sob.level) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.level)..' из '..setting.sob.level)
		end
		imgui.SetCursorPos(imgui.ImVec2(135, 84))
		if sob_info.legal == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.legal >= tonumber(setting.sob.legal) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.legal)..' из '..setting.sob.legal)
		elseif sob_info.legal < tonumber(setting.sob.legal) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.legal)..' из '..setting.sob.legal)
		end
		imgui.SetCursorPos(imgui.ImVec2(86, 106))
		if sob_info.work == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.work == 0 then
			imgui.TextColoredRGB('{00A115}Безработный')
		elseif sob_info.work == 1 then
			imgui.TextColoredRGB('{CF0000}Сост. во фракции')
		end
		imgui.SetCursorPos(imgui.ImVec2(332, 62))
		if sob_info.narko == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.narko <= tonumber(setting.sob.narko) then
			imgui.TextColoredRGB('{00A115}'..tostring(sob_info.narko)..' из '..setting.sob.narko)
		elseif sob_info.narko > tonumber(setting.sob.narko) then
			imgui.TextColoredRGB('{CF0000}'..tostring(sob_info.narko)..' из '..setting.sob.narko)
		end
		imgui.SetCursorPos(imgui.ImVec2(311, 84))
		if sob_info.hp == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.hp == 0 then
			imgui.TextColoredRGB('{00A115}Псих. здоров')
		elseif sob_info.hp == 1 then
			imgui.TextColoredRGB('{CF0000}Есть отклонения')
		end
		imgui.SetCursorPos(imgui.ImVec2(348, 106))
		if sob_info.bl == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.bl == 0 then
			imgui.TextColoredRGB('{00A115}Не состоит')
		elseif sob_info.bl == 1 then
			imgui.TextColoredRGB('{CF0000}Состоит в ЧС')
		end
		imgui.SetCursorPos(imgui.ImVec2(551, 68))
		if sob_info.lic == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.lic == 0 then
			imgui.TextColoredRGB('{00A115}Имеется')
		elseif sob_info.lic == 1 then
			imgui.TextColoredRGB('{CF0000}Отсутствует')
		end
		imgui.SetCursorPos(imgui.ImVec2(531, 97))
		if sob_info.writ == -1 then
			imgui.TextColoredRGB('{CF0000}Неизвестно')
		elseif sob_info.writ == 0 then
			imgui.TextColoredRGB('{00A115}Отсутствует')
		elseif sob_info.writ == 1 then
			imgui.TextColoredRGB('{CF0000}Имеется')
		end
		imgui.PopFont()
		
		imgui.PushFont(font[4])
		imgui.SetCursorPos(imgui.ImVec2(270, 145))
		imgui.Text(u8'Локальный чат')
		imgui.PopFont()
		new_draw(172, 190)
		
		imgui.PushFont(font[1])
		if #setting.sob.qq ~= 0 then
			skin.Button(u8'Задать вопрос', 0, 373, 219, 32, function() imgui.OpenPopup(u8'Задать вопрос') end)
		else
			skin.Button(u8'Задать вопрос##false_non', 0, 373, 219, 32, function() end)
		end
		skin.Button(u8'Определить годность', 224, 373, 218, 32, function() imgui.OpenPopup(u8'Определение годности') end)
		skin.Button(u8'Прекратить собеседование', 447, 373, 219, 32, function()
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
				writ = -1
			}
		end)
		
		if imgui.BeginPopupModal(u8'Задать вопрос', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окошко определения годности', imgui.ImVec2(20, 20)) then
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
			imgui.BeginChild(u8'Задать вопрос', imgui.ImVec2(300, 15 + (#setting.sob.qq * 35)), false, imgui.WindowFlags.NoScrollbar)
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
		
		if imgui.BeginPopupModal(u8'Определение годности', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окошко определения годности', imgui.ImVec2(20, 20)) then
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
			imgui.BeginChild(u8'Определение годности', imgui.ImVec2(300, 460), false, imgui.WindowFlags.NoScrollbar)
			imgui.PushFont(font[1])
			skin.Button(u8'Принять игрока', 15, 0, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Отлично, Вы приняты к нам на работу!')
						wait(2100)
						sampSendChat('Сейчас я выдам Вам ключи от шкафчика с формой и другими вещами.')
						wait(2100)
						sampSendChat('/do В кармане находятся ключи от шкафчиков.')
						wait(2100)
						sampSendChat('/me потянувшись во внутренний карман, достал'.. chsex('', 'а') ..' оттуда ключ')
						wait(2100)
						sampSendChat('/me передал'.. chsex('', 'а') ..' ключ от шкафчика с формой человеку напротив')
						wait(2100)
						sampSendChat('/invite '..pl_sob.id)
						wait(2100)
						sampSendChat('/r Приветствуем нового сотрудника нашей организации - '.. pl_sob.nm:gsub('_', ' ') ..'.')
					end)
				end
			end)
			skin.Button(u8'Опечатка в паспорте (нонРП ник)', 15, 60, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. У Вас опечатка в паспорте.')
						wait(2100)
						sampSendChat('/n нонРП ник. С таким ником, к сожалению, нельзя в организацию.')
					end)
				end
			end)
			skin.Button(u8'Мало лет проживания', 15, 95, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. Ваш возраст проживания в штате слишком мал.')
						wait(2100)
						sampSendChat('Минимальный возраст проживания в годах должен быть не менее, чем '..setting.sob.level)
					end)
				end
			end)
			skin.Button(u8'Проблемы с законом', 15, 130, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. У Вас проблемы с законом.')
						wait(2100)
						sampSendChat('/n Требуется минимум '..setting.sob.legal..' законопослушности.')
					end)
				end
			end)
			skin.Button(u8'Уже состоит во фракции', 15, 165, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите.')
						wait(2100)
						sampSendChat('На данный момент Вы уже работаете в другой организации.')
						wait(2100)
						sampSendChat('Если хотите к нам, то для начала Вам необходимо уволиться оттуда.')
					end)
				end
			end)
			skin.Button(u8'Имеет наркозависимость', 15, 200, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. У Вас имеется наркозависимость.')
						wait(2100)
						sampSendChat('Вы можете вылечиться от наркозависимости, попросив об этом врача больницы.')
					end)
				end
			end)
			skin.Button(u8'Проблемы с псих. здоровьем', 15, 235, 270, 28, function()
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. У Вас проблемы с псих. здоровьем.')
					end)
				end
			end)
			skin.Button(u8'Состоит в чёрном списке', 15, 270, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но Вы нам не подходите. Вы состоите в чёрном списке организации.')
					end)
				end
			end)
			skin.Button(u8'Нет паспорта', 15, 305, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Для трудоустройства необходимо предоставить паспорт.')
						wait(2100)
						sampSendChat('Получить его можно в мерии г. Лос-Сантос.')
						wait(2100)
						sampSendChat('Без него, к сожалению, продолжить мы не сможем. Приходите после его получения.')
					end)
				end
			end)
			skin.Button(u8'Нет мед. карты', 15, 340, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Для трудоустройства необходима мед. карта с пометкой "Полностью здоров".')
						wait(2100)
						sampSendChat('Получить её можно в нашей больнице.')
						wait(2100)
						sampSendChat('Без неё, к сожалению, продолжить мы не сможем.')
					end)
				end
			end)
			skin.Button(u8'Нет лицензий', 15, 375, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Для трудоустройства необходима лицензия на управление автомобилем.')
						wait(2100)
						sampSendChat('Получить её можно в Центре Лицензирования.')
						wait(2100)
						sampSendChat('Без неё, к сожалению, продолжить мы не сможем. Приходите после её получения.')
					end)
				end
			end)
			skin.Button(u8'Повестка', 15, 410, 270, 28, function() 
				imgui.CloseCurrentPopup()
				sobes_menu = false
				if thread:status() == 'dead' then
					thread = lua_thread.create(function()
						sampSendChat('Извините, но я смогу Вас трудоустроить, так как у Вас на руках имеется повестка.')
						wait(2100)
						sampSendChat('Для трудоустройства необходимо иметь военный билет, либо не иметь повестки.')
						wait(2100)
						sampSendChat('Приходите после получения военного билета.')
					end)
				end
			end)
			
			imgui.PopFont()
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		imgui.SetCursorPos(imgui.ImVec2(0, 172))
		imgui.BeginChild(u8'Локальный чат собеседования', imgui.ImVec2(667, 141), false)
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
		
		skin.InputText(10, 329, u8'Текст сообщения', 'inp_text_sob', 512, 555)
		if inp_text_sob ~= '' then
			skin.Button(u8'Отправить', 575, 326, 81, 28, function()
				sampSendChat(u8:decode(inp_text_sob))
				inp_text_sob = ''
			end)
		else
			skin.Button(u8'Отправить##false_non', 575, 326, 81, 28, function() end)
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
	skin.InputText(670, 11, u8'Поиск', 'search.chat', 100, 170) -- ICON_ANGLE_LEFT
	
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
			local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадение')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'Найдено '..#matching_indices..u8' совпадение')
		elseif ind_end > 1 and ind_end < 5 and ind_two_end ~= 12 and ind_two_end ~= 13 and ind_two_end ~= 14 then
			local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадения')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'Найдено '..#matching_indices..u8' совпадения')
		else
			local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадений')
			imgui.SetCursorPos(imgui.ImVec2(575 - calc.x, 14))
			imgui.Text(u8'Найдено '..#matching_indices..u8' совпадений')
		end
			imgui.PopFont()
	end
	
	imgui.SetCursorPos(imgui.ImVec2(180, 41))
	imgui.BeginChild(u8'История чата', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	
	
	if #history_chat > 0 then
		new_draw(17, 24 + (23 * #history_chat))
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(226, 49 + (#history_chat * 23)))
		imgui.TextColoredRGB('{808080}Показаны последние 300 сообщений.')
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
		imgui.Text(u8'Нет ни одного сообщения')
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
	imgui.BeginChild(u8'Департамент', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
	new_draw(17, 44)
	imgui.PushFont(font[1])
	imgui.SetCursorPos(imgui.ImVec2(15, 29))
	imgui.Text(u8'Формат обращения')
	
	new_draw(73, 44)
	
	local text_blank = ''
	if dep_num_text > 0 then
		text_blank = setting.blank_text_dep[dep_num_text]
	end
	
	if skin.List({350, 24}, setting.depart.format, {u8'[ЛСМЦ] - [ЛСПД]:', u8'к ЛСПД,', u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:', u8'[Больница ЛС] з.к. [ФБР]:'}, 300, 'setting.depart.format') then 
		save('setting')
		if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
		elseif setting.depart.format == u8'к ЛСПД,' then
			dep_num_text = 0
			inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
		elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
		elseif setting.depart.format == u8'[Больница ЛС] з.к. [ФБР]:' then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' з.к. ['..setting.depart.else_tag..']: '
		end
	end
	
	if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'Ваш тег')
		imgui.SetCursorPos(imgui.ImVec2(310, 85))
		imgui.Text(u8'Тег к обращаемому')
		local dans = {setting.depart.my_tag, setting.depart.else_tag}
		skin.InputText(79, 84, u8'Ваш тег', 'setting.depart.my_tag', 40, 170, nil, 'setting')
		skin.InputText(450, 84, u8'Тег к обращаемому', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
		end
	elseif setting.depart.format == u8'к ЛСПД,' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'Тег к обращаемому')
		local dans = setting.depart.else_tag
		skin.InputText(155, 84, u8'Тег к обращаемому', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
		end
	elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'Ваш тег')
		imgui.SetCursorPos(imgui.ImVec2(214, 85))
		imgui.Text(u8'Волна')
		imgui.SetCursorPos(imgui.ImVec2(403, 85))
		imgui.Text(u8'Тег к обращаемому')
		local dans = {setting.depart.my_tag, setting.depart.volna, setting.depart.else_tag}
		skin.InputText(73, 84, u8'Ваш тег', 'setting.depart.my_tag', 40, 111, nil, 'setting')
		skin.InputText(261, 84, u8'Волна', 'setting.depart.volna', 40, 111, nil, 'setting')
		skin.InputText(538, 84, u8'Обращаемому', 'setting.depart.else_tag', 40, 111, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.volna or dans[3] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
		end
	elseif setting.depart.format == u8'[Больница ЛС] з.к. [ФБР]:' then
		imgui.SetCursorPos(imgui.ImVec2(15, 85))
		imgui.Text(u8'Ваш тег')
		imgui.SetCursorPos(imgui.ImVec2(310, 85))
		imgui.Text(u8'Тег к обращаемому')
		local dans = {setting.depart.my_tag, setting.depart.else_tag}
		skin.InputText(79, 84, u8'Ваш тег', 'setting.depart.my_tag', 40, 170, nil, 'setting')
		skin.InputText(450, 84, u8'Тег к обращаемому', 'setting.depart.else_tag', 40, 200, nil, 'setting')
		if dans[1] ~= setting.depart.my_tag or dans[2] ~= setting.depart.else_tag then
			dep_num_text = 0
			inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' з.к. ['..setting.depart.else_tag..']: '
		end
	end
	imgui.PopFont()
	imgui.PushFont(bold_font[3])
	imgui.SetCursorPos(imgui.ImVec2(270, 130))
	imgui.Text(u8'Локальный чат')
	imgui.PopFont()
	new_draw(157, 248)
	
	imgui.SetCursorPos(imgui.ImVec2(0, 157))
	imgui.BeginChild(u8'Департамент', imgui.ImVec2(667, 199), false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
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
	if dep_num_text ~= 0 then
		imgui.Text(tostring(dep_num_text))
	else
		imgui.Text('-')
	end
	imgui.PopFont()
	imgui.SetCursorPos(imgui.ImVec2(8, 373))
	if imgui.InvisibleButton(u8'##Назад депа', imgui.ImVec2(20, 20)) then
		if dep_num_text > 0 then dep_num_text = dep_num_text - 1 done_active_dep = false end
	end
	imgui.SetCursorPos(imgui.ImVec2(45, 373))
	if imgui.InvisibleButton(u8'##Вперёд депа', imgui.ImVec2(20, 20)) then
		if dep_num_text < 5 then dep_num_text = dep_num_text + 1 done_active_dep = false end
	end
	
	if dep_num_text == 0 then
		skin.InputText(70, 372, u8'Текст сообщения', 'inp_text_dep', 512, 495)
	elseif not done_active_dep then
		skin.InputText(70, 372, u8'Заготовленный текст сообщения', 'setting.blank_text_dep.'..tostring(dep_num_text), 512, 495, nil, 'setting')
	end
	if dep_num_text == 0 or done_active_dep then
		if inp_text_dep ~= '' then
			skin.Button(u8'Отправить', 575, 369, 81, 28, function()
				dep_num_text = 0
				sampSendChat(u8:decode(inp_text_dep))
				if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
				elseif setting.depart.format == u8'к ЛСПД,' then
					inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
				elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
				elseif setting.depart.format == u8'[Больница ЛС] з.к. [ФБР]:' then
					inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' з.к. ['..setting.depart.else_tag..']: '
				end
			end)
		else
			skin.Button(u8'Отправить##false_non', 575, 369, 81, 28, function() end)
		end
	elseif dep_num_text > 0 and not done_active_dep then
		skin.Button(u8'Добавить', 575, 369, 81, 28, function()
			done_active_dep = true
			if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'к ЛСПД,' then
				inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '..setting.blank_text_dep[dep_num_text]
			elseif setting.depart.format == u8'[Больница ЛС] з.к. [ФБР]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..']'..u8' з.к. ['..setting.depart.else_tag..']: '
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
	--> Левое меню
	if not interf.main.collapse then
		skin.DrawFond({4, 4}, {0, 0}, {pos_el.r_menu, 460 + start_pos + new_pos}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 42, 9)
	else
		skin.DrawFond({4, 4}, {0, 0}, {100, 50}, imgui.ImVec4(col_end.fond_one[1], col_end.fond_one[2], col_end.fond_one[3], 1.00), 42, 15)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 456 + start_pos + new_pos))
	if imgui.InvisibleButton(u8'##Границы', imgui.ImVec2(pos_el.r_menu, 12)) then end
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
	
	--> Кнопки закрыть и свернуть
	imgui.SetCursorPos(imgui.ImVec2(18, 16))
	if imgui.InvisibleButton(u8'##Закрыть окно', imgui.ImVec2(20, 20)) or interf.main.anim_win.par  then
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
	if imgui.InvisibleButton(u8'##Свернуть окно', imgui.ImVec2(20, 20)) then
		
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
	if imgui.InvisibleButton(u8'##История чата', imgui.ImVec2(20, 20)) then
		
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

		if button_menu(u8'Главное', {17, 48}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_COG, {30, 55}, select_main_menu[1], {0.5, -0.5}, 0.0) then 
			transition(1)
		end
		if button_menu(u8'Команды', {17, 82}, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_TERMINAL, {29, 88}, select_main_menu[2], nil, -0.5) then 
			sdvig_bool = false
			sdvig_num = 0
			sdvig = 0
			transition(2)
		end
		if button_menu(u8'Шпоры', {17, 116}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BOOK, {29, 123}, select_main_menu[3], nil, -1) then 
			transition(3)
			anim_menu_shpora[1] = 0
			anim_menu_shpora[3] = false
			anim_menu_shpora[4] = 0
		end
		if button_menu(u8'Департамент', {17, 150}, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_SIGNAL, {29, 156}, select_main_menu[4], {0.5, -0.5}, -0.5) then
			if setting.depart.format == u8'[ЛСМЦ] - [ЛСПД]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.else_tag..']: '
			elseif setting.depart.format == u8'к ЛСПД,' then
				inp_text_dep = '/d '..u8'к'..' '..setting.depart.else_tag..', '
			elseif setting.depart.format == u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:' then
				inp_text_dep = '/d ['..setting.depart.my_tag..'] - ['..setting.depart.volna..'] - ['..setting.depart.else_tag..']: '
			end
			transition(4)
		end
		if button_menu(u8'Собес', {17, 184}, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_USER_PLUS, {28, 190}, select_main_menu[5], {0.5, -0.5}, -0.5) then 
			transition(5)
		end
		if button_menu(u8'Напоминания', {17, 218}, imgui.ImVec4(0.97, 0.27, 0.19 ,1.00), fa.ICON_BELL, {29, 225}, select_main_menu[6], {0.5, -0.5}) then 
			transition(6)
		end
		if button_menu(u8'Статистика', {17, 252}, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_AREA_CHART, {28, 259}, select_main_menu[7], {0.5, -0.5}, -0.5) then 
			transition(7)
		end
		if button_menu(u8'Музыка', {17, 286}, imgui.ImVec4(1.00, 0.14, 0.33 ,1.00), fa.ICON_MUSIC, {29, 293}, select_main_menu[8], {-0.5, 0}, -0.5) then 
			transition(8)
			win.music.v = true
		end
		if button_menu(u8'РП зона', {17, 320}, imgui.ImVec4(0.15, 0.77, 0.38 ,1.00), fa.ICON_OBJECT_GROUP, {28, 327}, select_main_menu[9], nil, -0.5) then 
			transition(9)
		end
		if button_menu(u8'Лекционная', {17, 354}, imgui.ImVec4(0.75, 0.30, 1.00, 1.00), fa.ICON_MICROPHONE, {31, 361}, select_main_menu[11], nil, -1) then
			transition(11)
		end
		if button_menu(u8'Действия', {17, 388}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_CODEPEN, {28, 395}, select_main_menu[13], nil, -1) then
			transition(13)
		end
		if button_menu(u8'Помощь', {17, 422}, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_BULLHORN, {28, 429}, select_main_menu[10], nil, -1) then
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
									--print('Не найдено')
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
		----> [0] Нулевое окно
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
			
		----> [1] Главное
		if select_main_menu[1] and all_false_sel_basic then
			menu_draw_up(u8'Главное')
			
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'Главное', imgui.ImVec2(683, 423 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
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
			if drawn_button(17, 3, u8'Личная информация') then select_basic = {true, false, false, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(19, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_LOCK, {26, 28}, {-0.3, 0})
			
			if drawn_button(57, 0, u8'Настройки чата') then select_basic = {false, true, false, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(60, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00), fa.ICON_BARS, {24, 68}, {0.5, -0.5})
			
			if drawn_button(97, 0, u8'Ценовая политика') then select_basic = {false, false, true, false, false, false, false, false, false, false, false, false} end
			drawn_icon_b(100, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00), fa.ICON_USD, {26, 108})
			
			if drawn_button(177, 12, u8'Вызовы') then select_basic = {false, false, false, false, false, false, false, false, false, false, false, true} end
			drawn_icon_b(180, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00), fa.ICON_AMBULANCE, {24, 188})
			
			if drawn_button(137, 0, u8'Быстрый доступ') then select_basic = {false, false, false, false, false, false, true, false, false, false, false, false} end
			drawn_icon_b(140, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00), fa.ICON_LINK, {24, 148})
			
			skin.DrawFond({51, 57}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 97}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 137}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 177}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			if drawn_button(235, 3, u8'Мемберс') then select_basic = {false, false, false, false, true, false, false, false, false, false, false, false} end
			drawn_icon_b(237, imgui.ImVec4(0.0, 0.47, 0.99 ,1.00), fa.ICON_USER_CIRCLE_O, {24, 245}, {-0.4, 0.7})
			
			if drawn_button(275, 0, u8'Уведомления') then select_basic = {false, false, false, false, false, true, false, false, false, false, false, false} end
			drawn_icon_b(278, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00), fa.ICON_PAPER_PLANE, {23, 286})
			
			if drawn_button(355, 12, u8'Дополнительные функции') then select_basic = {false, false, false, false, false, false, false, true, false, false, false, false} end
			drawn_icon_b(358, imgui.ImVec4(0.22, 0.82, 0.55, 1.00), fa.ICON_TOGGLE_ON, {22, 366})
			
			if drawn_button(315, 0, u8'Акцент', 1) then select_basic = {false, false, false, true, false, false, false, false, false, false, false, false} end
			drawn_icon_b(318, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00), fa.ICON_COMMENTING, {24, 326})
			
			skin.DrawFond({51, 275}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 315}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			skin.DrawFond({51, 355}, {0, 0}, {596, 1}, imgui.ImVec4(0.50, 0.50, 0.50, 0.40), 0, 0)
			
			if drawn_button(413, 3, u8'Настройки скрипта', 1) then select_basic = {false, false, false, false, false, false, false, false, true, false, false, false} end
			drawn_icon_b(417, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_SLIDERS, {25, 425}, {0, 0.5})
			
			if drawn_button(493, 12, u8'О скрипте', 1) then select_basic = {false, false, false, false, false, false, false, false, false, false, true, false} end
			drawn_icon_b(496, imgui.ImVec4(0.60, 0.60, 0.60, 1.00), fa.ICON_CODE,  {25, 504})
			
			if drawn_button(453, 0, u8'Обновление', 1) then select_basic = {false, false, false, false, false, false, false, false, false, true, false, false} end
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
				if menu_draw_up(u8'Личная информация', true) then select_basic[1] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Личная информация', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 75)
				skin.InputText(33, 36, u8'Ваш ник на русском языке',' setting.nick', 74, 633, '[а-Я%s]+', 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 65))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Ваш ник на русском языке будет полезен для использования в различных отыгровках.')
				imgui.PopFont()
				
				new_draw(110, 91)
				imgui.SetCursorPos(imgui.ImVec2(34, 156))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'От выбранной организации, в которой Вы состоите, зависит доступность различ-')
				imgui.SetCursorPos(imgui.ImVec2(34, 170))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'ных функций и команд. Скрипт поддерживает только организации из списка.')
				imgui.PopFont()
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 127))
				imgui.Text(u8'Организация')
				imgui.PopFont()
				if skin.List({480, 121}, setting.frac.org, {u8'Больница ЛС', u8'Больница ЛВ', u8'Больница СФ', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'ТСР'}, 185, 'setting.frac.org') then 
					add_table_act(setting.frac.org, false)
					save('setting')
					create_act(1)
				end
				
				new_draw(219, 73)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 236))
				imgui.Text(u8'Должность')
				local calc = imgui.CalcTextSize(setting.frac.title)
				imgui.SetCursorPos(imgui.ImVec2(660 - calc.x, 236))
				imgui.Text(setting.frac.title)
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 261))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Определено автоматически.')
				imgui.PopFont()
				
				new_draw(310, 73)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 327))
				imgui.Text(u8'Пол')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 352))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Необходимо для отыгровок.')
				imgui.PopFont()
				if skin.List({480, 321}, setting.sex, {u8'Мужской', u8'Женский'}, 185, 'setting.sex') then save('setting') end
				
				new_draw(401, 75)
				skin.InputText(33, 420, u8'Тег в рацию организации','setting.teg', 74, 633, '[а-Я%s]+', 'setting')
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 449))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'О необходимости использования тега, уточните у лидера организации.')
				imgui.PopFont()
				
				imgui.Dummy(imgui.ImVec2(0, 27))
				imgui.EndChild()
			elseif select_basic[2] then
				if menu_draw_up(u8'Настройки чата', true) then select_basic[2] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Настройки чата', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 202)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Объявления от игроков', setting.chat_pl) then setting.chat_pl = not setting.chat_pl save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 60))
				if skin.Switch(u8'##репортажи новости СМИ', setting.chat_smi) then setting.chat_smi = not setting.chat_smi save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 90))
				if skin.Switch(u8'##частые подсказки сервера', setting.chat_help) then setting.chat_help = not setting.chat_help save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 120))
				if skin.Switch(u8'##рация организации', setting.chat_racia) then setting.chat_racia = not setting.chat_racia save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 150))
				if skin.Switch(u8'##рация департамента', setting.chat_dep) then setting.chat_dep = not setting.chat_dep save('setting') end
				imgui.SetCursorPos(imgui.ImVec2(639, 180))
				if skin.Switch(u8'##вип чат', setting.chat_vip) then setting.chat_vip = not setting.chat_vip save('setting') end
				
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Скрыть объявления от игроков в СМИ')
				imgui.SetCursorPos(imgui.ImVec2(34, 61))
				imgui.Text(u8'Скрыть репортажи и новости от СМИ')
				imgui.SetCursorPos(imgui.ImVec2(34, 91))
				imgui.Text(u8'Скрыть частые подсказки сервера')
				imgui.SetCursorPos(imgui.ImVec2(34, 120))
				imgui.Text(u8'Скрыть рацию организации /r и /rb')
				imgui.SetCursorPos(imgui.ImVec2(34, 150))
				imgui.Text(u8'Скрыть рацию департамента /d')
				imgui.SetCursorPos(imgui.ImVec2(34, 180))
				imgui.Text(u8'Скрыть VIP чат')
				imgui.PopFont()
				
				
				new_draw(229, 60) -- 1 - положение окна 2 - размер окна
				imgui.SetCursorPos(imgui.ImVec2(639, 248)) -- положение автивации
				if skin.Switch(u8'##Дата и время снизу', setting.time_hud) then setting.time_hud = not setting.time_hud save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 248)) -- 1 - сдвиг текста лево/право 2 - верх/низ
				imgui.Text(u8'Отображать дату и время под миникартой')
				imgui.PopFont()
				
				new_draw(299, 143)
				skin.InputText(33, 334, u8'Текст отыгровки времени /time', 'setting.act_time', 128, 633, nil, 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 310)) -- текст де нада
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Отыгровка после ввода /time. Оставьте пустым, если не нужно.')
				imgui.PopFont()
				skin.InputText(33, 395, u8'Текст отыгровки рации /r', 'setting.act_r', 128, 633, nil, 'setting')
				imgui.SetCursorPos(imgui.ImVec2(34, 371))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Отыгровка после ввода /r. Оставьте пустым, если не нужно.')
				imgui.PopFont()
				
				new_draw(452, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 465))
				if skin.Switch(u8'##Автоскрин /time', setting.ts) then setting.ts = not setting.ts save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 465))
				imgui.Text(u8'/time + скриншот экрана командой /ts')
				imgui.PopFont()
				
				new_draw(509, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 523))
				if skin.Switch(u8'##Отыгровка палки резиновой', setting.rubber_stick) then setting.rubber_stick = not setting.rubber_stick save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 523))
				imgui.Text(u8'Отыгровка дубинки')
				imgui.PopFont()

				new_draw(566, 67)
				imgui.SetCursorPos(imgui.ImVec2(639, 583))
				if skin.Switch(u8'##Автоотыгровка принятия документов', setting.auto_roleplay_text) then setting.auto_roleplay_text = not setting.auto_roleplay_text save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 584))
				imgui.Text(u8'Автоматическая отыгровка принятия документов')
				imgui.PopFont()
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 604))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Вы станете принимать документы с отыгровкой, которая будет запускаться автоматически.')
				imgui.PopFont()

				new_draw(643, 60) -- 1 - положение окна 2 - размер окна
				imgui.SetCursorPos(imgui.ImVec2(639, 662)) -- положение автивации
				if skin.Switch(u8'##исправление отыкровок', setting.fix_text) then setting.fix_text = not setting.fix_text save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 662)) -- 1 - сдвиг текста лево/право 2 - верх/низ
				imgui.Text(u8'Автоматично исправлять отыгровки в чате в правильном формате')
				imgui.PopFont()
				
				imgui.Dummy(imgui.ImVec2(0, 27))
				imgui.EndChild()
			elseif select_basic[3] then
				if menu_draw_up(u8'Ценовая политика', true) then select_basic[3] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Ценовая политика', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				if setting.frac.org == u8'Центр Лицензирования' then
					new_draw(17, 518)
					
					imgui.PushFont(bold_font[1])
					imgui.SetCursorPos(imgui.ImVec2(230, 33))
					imgui.Text(u8'1 месяц')
					imgui.SetCursorPos(imgui.ImVec2(384, 33))
					imgui.Text(u8'2 месяца')
					imgui.SetCursorPos(imgui.ImVec2(544, 33))
					imgui.Text(u8'3 месяца')
					
					imgui.SetCursorPos(imgui.ImVec2(40, 77))
					imgui.Text(u8'Авто')
					imgui.SetCursorPos(imgui.ImVec2(40, 122))
					imgui.Text(u8'Мото')
					imgui.SetCursorPos(imgui.ImVec2(40, 167))
					imgui.Text(u8'Полёты')
					imgui.SetCursorPos(imgui.ImVec2(363, 167))
					imgui.Text(u8'Недоступно')
					imgui.SetCursorPos(imgui.ImVec2(523, 167))
					imgui.Text(u8'Недоступно')
					imgui.SetCursorPos(imgui.ImVec2(40, 212))
					imgui.Text(u8'Рыбалка')
					imgui.SetCursorPos(imgui.ImVec2(40, 257))
					imgui.Text(u8'Водное т/с')
					imgui.SetCursorPos(imgui.ImVec2(40, 302))
					imgui.Text(u8'Оружие')
					imgui.SetCursorPos(imgui.ImVec2(40, 347))
					imgui.Text(u8'Охота')
					imgui.SetCursorPos(imgui.ImVec2(40, 392))
					imgui.Text(u8'Раскопки')
					imgui.SetCursorPos(imgui.ImVec2(40, 437))
					imgui.Text(u8'Такси')
					imgui.SetCursorPos(imgui.ImVec2(40, 482))
					imgui.Text(u8'Механик')
					imgui.PopFont()
					
					imgui.PushFont(font[1])
					skin.InputText(203, 80, u8'Авто 1 мес.', 'setting.price_list_cl.auto.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 80, u8'Авто 2 мес.', 'setting.price_list_cl.auto.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 80, u8'Авто 3 мес.', 'setting.price_list_cl.auto.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 125, u8'Мото 1 мес.', 'setting.price_list_cl.moto.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 125, u8'Мото 2 мес.', 'setting.price_list_cl.moto.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 125, u8'Мото 3 мес.', 'setting.price_list_cl.moto.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 170, u8'Полёты 1 мес.', 'setting.price_list_cl.fly.1', 10, 130, 'num', 'setting')
					skin.InputText(203, 215, u8'Рыбалка 1 мес.', 'setting.price_list_cl.fish.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 215, u8'Рыбалка 2 мес.', 'setting.price_list_cl.fish.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 215, u8'Рыбалка 3 мес.', 'setting.price_list_cl.fish.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 260, u8'Водное 1 мес.', 'setting.price_list_cl.swim.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 260, u8'Водное 2 мес.', 'setting.price_list_cl.swim.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 260, u8'Водное 3 мес.', 'setting.price_list_cl.swim.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 305, u8'Оружие 1 мес.', 'setting.price_list_cl.gun.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 305, u8'Оружие 2 мес.', 'setting.price_list_cl.gun.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 305, u8'Оружие 3 мес.', 'setting.price_list_cl.gun.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 350, u8'Охота 1 мес.', 'setting.price_list_cl.hunt.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 350, u8'Охота 2 мес.', 'setting.price_list_cl.hunt.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 350, u8'Охота 3 мес.', 'setting.price_list_cl.hunt.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 395, u8'Раскопки 1 мес.', 'setting.price_list_cl.exc.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 395, u8'Раскопки 2 мес.', 'setting.price_list_cl.exc.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 395, u8'Раскопки 3 мес.', 'setting.price_list_cl.exc.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 440, u8'Такси 1 мес.', 'setting.price_list_cl.taxi.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 440, u8'Такси 2 мес.', 'setting.price_list_cl.taxi.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 440, u8'Такси 3 мес.', 'setting.price_list_cl.taxi.3', 10, 130, 'num', 'setting')
					skin.InputText(203, 485, u8'Механик 1 мес.', 'setting.price_list_cl.meh.1', 10, 130, 'num', 'setting')
					skin.InputText(363, 485, u8'Механик 2 мес.', 'setting.price_list_cl.meh.2', 10, 130, 'num', 'setting')
					skin.InputText(523, 485, u8'Механик 3 мес.', 'setting.price_list_cl.meh.3', 10, 130, 'num', 'setting')
					imgui.PopFont()
					
					imgui.Dummy(imgui.ImVec2(0, 61))
				elseif setting.frac.org == u8'ТСР' then
					imgui.PushFont(bold_font[4])
					imgui.SetCursorPos(imgui.ImVec2(92, 187 + ((start_pos + new_pos) / 2)))
					imgui.Text(u8'Для Вас нет ценовой политики')
					imgui.PopFont()
				else
					if setting.price.lec == '' then
						setting.price.lec = '0'
					elseif setting.price.rec == '' then
						setting.price.rec = '0'
					elseif setting.price.tatu == '' then
						setting.price.tatu = '0'
					elseif setting.price.ant == '' then
						setting.price.ant = '0'
					elseif setting.price.narko == '' then
						setting.price.narko = '0'
					elseif setting.priceosm == '' then
						setting.priceosm = '0'
					elseif setting.price.mede[1] == '' then
						setting.price.mede[1] = '0'
					elseif setting.price.mede[2] == '' then
						setting.price.mede[2] = '0'
					elseif setting.price.mede[3] == '' then
						setting.price.mede[3] = '0'
					elseif setting.price.mede[4] == '' then
						setting.price.mede[4] = '0'
					elseif setting.price.upmede[1] == '' then
						setting.price.upmede[1] = '0'
					elseif setting.price.upmede[2] == '' then
						setting.price.upmede[2] = '0'
					elseif setting.price.upmede[3] == '' then
						setting.price.upmede[3] = '0'
					elseif setting.price.upmede[4] == '' then
						setting.price.upmede[4] = '0'
					end
				
					new_draw(17, 140)
					imgui.PushFont(font[1])
					skin.InputText(105, 36, u8'Лечение', 'setting.price.lec', 10, 200, 'num', 'setting')
					skin.InputText(105, 76, u8'Рецепт', 'setting.price.rec', 10, 200, 'num', 'setting')
					skin.InputText(105, 116, u8'Татуировка', 'setting.price.tatu', 10, 200, 'num', 'setting')
					skin.InputText(465, 36, u8'Антибиотик', 'setting.price.ant', 10, 200, 'num', 'setting')
					skin.InputText(465, 76, u8'Наркозависимость', 'setting.price.narko', 10, 200, 'num', 'setting')
					skin.InputText(465, 116, u8'Медицинский осмотр', 'setting.priceosm', 10, 200, 'num', 'setting')
					
					new_draw(169, 182)
					skin.InputText(163, 188, u8'Мед. карта 7 дней', 'setting.price.mede.1', 10, 140, 'num', 'setting')
					skin.InputText(163, 228, u8'Мед. карта 14 дней', 'setting.price.mede.2', 10, 140, 'num', 'setting')
					skin.InputText(163, 268, u8'Мед. карта 30 дней', 'setting.price.mede.3', 10, 140, 'num', 'setting')
					skin.InputText(163, 308, u8'Мед. карта 60 дней', 'setting.price.mede.4', 10, 140, 'num', 'setting')
					skin.InputText(524, 188, u8'Новая 7 дней', 'setting.price.upmede.1', 10, 140, 'num', 'setting')
					skin.InputText(524, 228, u8'Новая 14 дней', 'setting.price.upmede.2', 10, 140, 'num', 'setting')
					skin.InputText(524, 268, u8'Новая 30 дней', 'setting.price.upmede.3', 10, 140, 'num', 'setting')
					skin.InputText(524, 308, u8'Новая 60 дней', 'setting.price.upmede.4', 10, 140, 'num', 'setting')
					
					imgui.SetCursorPos(imgui.ImVec2(34, 37))
					imgui.Text(u8'Лечение')
					imgui.SetCursorPos(imgui.ImVec2(34, 77))
					imgui.Text(u8'Рецепт')
					imgui.SetCursorPos(imgui.ImVec2(34, 117))
					imgui.Text(u8'Тату')
					imgui.SetCursorPos(imgui.ImVec2(370, 37))
					imgui.Text(u8'Антибиотик')
					imgui.SetCursorPos(imgui.ImVec2(370, 77))
					imgui.Text(u8'Наркозав.')
					imgui.SetCursorPos(imgui.ImVec2(370, 117))
					imgui.Text(u8'Мед. осмотр')
					imgui.SetCursorPos(imgui.ImVec2(34, 189))
					imgui.Text(u8'Мед. карта 7 дней')
					imgui.SetCursorPos(imgui.ImVec2(34, 229))
					imgui.Text(u8'Мед. карта 14 дней')
					imgui.SetCursorPos(imgui.ImVec2(34, 269))
					imgui.Text(u8'Мед. карта 30 дней')
					imgui.SetCursorPos(imgui.ImVec2(34, 309))
					imgui.Text(u8'Мед. карта 60 дней')
					imgui.SetCursorPos(imgui.ImVec2(353, 189))
					imgui.Text(u8'Мед. карта новая 7 дней')
					imgui.SetCursorPos(imgui.ImVec2(353, 229))
					imgui.Text(u8'Мед. карта новая 14 дней')
					imgui.SetCursorPos(imgui.ImVec2(353, 269))
					imgui.Text(u8'Мед. карта новая 30 дней')
					imgui.SetCursorPos(imgui.ImVec2(353, 309))
					imgui.Text(u8'Мед. карта новая 60 дней')
					imgui.PopFont()
				end

				imgui.EndChild()
			elseif select_basic[4] then
				if menu_draw_up(u8'Акцент', true) then select_basic[4] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Акцент', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Использовать акцент', setting.accent.func) then setting.accent.func = not setting.accent.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Использовать акцент')
				imgui.PopFont()
				
				if setting.accent.func then
					new_draw(76, 76)
					skin.InputText(33, 95, u8'Введите Ваш собственный акцент', 'setting.accent.text', 128, 633, '[а-Я%s]+', 'setting')
					imgui.SetCursorPos(imgui.ImVec2(34, 124))
					imgui.PushFont(font[3])
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Начните с заглавной буквы. Слово "акцент" писать не нужно. Например, "Британский".')
					imgui.PopFont()
					
					new_draw(164, 137)
					imgui.SetCursorPos(imgui.ImVec2(639, 177))
					if skin.Switch(u8'##Акцент в рацию', setting.accent.r) then setting.accent.r = not setting.accent.r save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 207))
					if skin.Switch(u8'##Акцент при крике', setting.accent.s) then setting.accent.s = not setting.accent.s save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 237))
					if skin.Switch(u8'##Акцент в рацию депа', setting.accent.d) then 
						setting.accent.d = not setting.accent.d 
						save('setting')
						if setting.accent.d and not setting.dep_off then
							sampRegisterChatCommand('d', function(text_accents_d) 
								if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
									sampSendChat('/d ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_d)
								else
									sampSendChat('/d '..text_accents_d)
								end 
							end)
						elseif not setting.accent.d and not setting.dep_off then
							sampUnregisterChatCommand('d')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(639, 267))
					if skin.Switch(u8'##Акцент в рацию банды', setting.accent.f) then setting.accent.f = not setting.accent.f save('setting') end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 178))
					imgui.Text(u8'Акцент в рацию организации (/r)')
					imgui.SetCursorPos(imgui.ImVec2(34, 208))
					imgui.Text(u8'Акцент во время крика (/s)')
					imgui.SetCursorPos(imgui.ImVec2(34, 238))
					imgui.Text(u8'Акцент в рацию департамента (/d)')
					imgui.SetCursorPos(imgui.ImVec2(34, 268))
					imgui.Text(u8'Акцент в чат банды/мафии (/f)')
					
					imgui.PopFont()
				end
				imgui.EndChild()
			elseif select_basic[5] then
				if menu_draw_up(u8'Мемберс', true) then select_basic[5] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Мемберс', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Мемберс на экране', setting.members.func) then setting.members.func = not setting.members.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Мемберс организации на Вашем экране')
				imgui.PopFont()
				
				if setting.members.func then
					new_draw(76, 77)
					imgui.SetCursorPos(imgui.ImVec2(639, 89))
					if skin.Switch(u8'##Скрывать при диалоге', setting.members.dialog) then setting.members.dialog = not setting.members.dialog save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 119))
					if skin.Switch(u8'##Инверсировать текст', setting.members.invers) then setting.members.invers = not setting.members.invers save('setting') end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 90))
					imgui.Text(u8'Скрывать текст, если открыт диалог')
					imgui.SetCursorPos(imgui.ImVec2(34, 120))
					imgui.Text(u8'Инверсировать текст')
					
					new_draw(165, 166)
					imgui.SetCursorPos(imgui.ImVec2(639, 178))
					if skin.Switch(u8'##Выделять цветом в форме', setting.members.form) then setting.members.form = not setting.members.form save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 208))
					if skin.Switch(u8'##Отображать id', setting.members.id) then setting.members.id = not setting.members.id save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 238))
					if skin.Switch(u8'##Отображать ранг', setting.members.rank) then setting.members.rank = not setting.members.rank save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 268))
					if skin.Switch(u8'##Отображать afk', setting.members.afk) then setting.members.afk = not setting.members.afk save('setting') end
					imgui.SetCursorPos(imgui.ImVec2(639, 298))
					if skin.Switch(u8'##Отображать выговоры', setting.members.warn) then setting.members.warn = not setting.members.warn save('setting') end
					
					imgui.SetCursorPos(imgui.ImVec2(34, 179))
					imgui.Text(u8'Выделять цветом тех, кто в форме')
					imgui.SetCursorPos(imgui.ImVec2(34, 209))
					imgui.Text(u8'Отображать id игроков')
					imgui.SetCursorPos(imgui.ImVec2(34, 239))
					imgui.Text(u8'Отображать ранг игроков')
					imgui.SetCursorPos(imgui.ImVec2(34, 269))
					imgui.Text(u8'Отображать время АФК')
					imgui.SetCursorPos(imgui.ImVec2(34, 299))
					imgui.Text(u8'Отображать количество выговоров')
					
					imgui.PopFont()
					
					new_draw(343, 138)
					if skin.Slider('##Размер шрифта', 'setting.members.size', 1, 25, 205, {470, 357}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
					if skin.Slider('##Флаг шрифта', 'setting.members.flag', 1, 25, 205, {470, 384}, 'setting') then fontes = renderCreateFont('Trebuchet MS', setting.members.size, setting.members.flag) save('setting') end
					skin.Slider('##Расстояние между строками', 'setting.members.dist', 1, 30, 205, {470, 414}, 'setting')
					skin.Slider('##Прозрачность текста', 'setting.members.vis', 1, 255, 205, {470, 444}, 'setting')
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 356))
					imgui.Text(u8'Размер шрифта')
					imgui.SetCursorPos(imgui.ImVec2(34, 386))
					imgui.Text(u8'Флаг шрифта')
					imgui.SetCursorPos(imgui.ImVec2(34, 416))
					imgui.Text(u8'Расстояние между строками')
					imgui.SetCursorPos(imgui.ImVec2(34, 446))
					imgui.Text(u8'Прозрачность текста')
					
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
					imgui.Text(u8'Заголовок')
					imgui.SetCursorPos(imgui.ImVec2(333, 508))
					imgui.Text(u8'В форме')
					imgui.SetCursorPos(imgui.ImVec2(596, 508))
					imgui.Text(u8'Без формы')
					
					
					new_draw(552, 63)
					skin.Button(u8'Изменить положение текста', 34, 566, 633, nil, function() 
						changePosition()
					end)
					imgui.PopFont()
					imgui.Dummy(imgui.ImVec2(0, 35))
				end
				imgui.EndChild()
			elseif select_basic[6] then
				if menu_draw_up(u8'Уведомления', true) then select_basic[6] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Уведомления', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Уведомлять о спавне авто', setting.notice.car) then setting.notice.car = not setting.notice.car save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Уведомлять звуковым сигналом о спавне авто')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Когда администрация предупредит о спавне авто, Вы будете уведомлены звуковым сигналом.')
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
				if skin.Switch(u8'##Уведомлять о вызове организации в рации департамента', setting.notice.dep) then setting.notice.dep = not setting.notice.dep save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 111))
				imgui.Text(u8'Уведомлять о вызове организации в рации департамента')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 133))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Когда в рации департамента обратятся к Вашей организации, Вы будете уведомлены звуком.')
				imgui.PopFont()
				if setting.notice.dep then
					skin.InputText(175, 168, u8'Тег Вашей организации', 'setting.dep.my_tag', 128, 490, '^[a-zA-Z ]+$', 'setting')
					if setting.dep.my_tag ~= '' then
						skin.InputText(175, 210, u8'Дополнительный тег, например, на английском (необязательно)', 'setting.dep.my_tag_en', 128, 490, '^[a-zA-Z ]+$', 'setting')
						if setting.dep.my_tag_en ~= '' then
							skin.InputText(175, 252, u8'Второй дополнительный тег (необязательно)', 'setting.my_tag_en2', 128, 490, '^[a-zA-Z ]+$', 'setting')
							if setting.my_tag_en2 ~= '' then
								skin.InputText(175, 294, u8'Третий дополнительный тег (необязательно)', 'setting.my_tag_en3', 128, 490, '^[a-zA-Z ]+$', 'setting')
							end
						end
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 169))
					imgui.Text(u8'Тег организации')
					if setting.dep.my_tag ~= '' then
						imgui.SetCursorPos(imgui.ImVec2(34, 211))
						imgui.Text(u8'Дополнительный тег')
						if setting.dep.my_tag_en ~= '' then
							imgui.SetCursorPos(imgui.ImVec2(34, 253))
							imgui.Text(u8'Дополнительный тег')
							if setting.my_tag_en2 ~= '' then
								imgui.SetCursorPos(imgui.ImVec2(34, 295))
								imgui.Text(u8'Дополнительный тег')
							end
						end
					end
					imgui.PopFont()
				end
				
				imgui.EndChild()
			elseif select_basic[7] then
				if menu_draw_up(u8'Быстрый доступ', true) then select_basic[7] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Быстрый доступ', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 47)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Быстрый доступ', setting.fast_acc.func) then setting.fast_acc.func = not setting.fast_acc.func save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Быстрый доступ с игроками (ПКМ + E)')
				
				imgui.PopFont()
				if setting.fast_acc.func then
					local bk_size = 176
					if #setting.fast_acc.sl ~= 0 then
						local table_remove_acc = 0
						for i = 1, #setting.fast_acc.sl do
							new_draw(76 + ((i - 1) * bk_size), bk_size - 12)
							imgui.SetCursorPos(imgui.ImVec2(636, 134 + ((i - 1) * bk_size)))
							if imgui.InvisibleButton('##Удалить действие'..i, imgui.ImVec2(40, 40)) then table_remove_acc = i end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(649, 148 + ((i - 1) * bk_size)))
							imgui.Text(fa.ICON_TRASH)
							imgui.PopFont()
							
							imgui.PushFont(font[1])
							imgui.SetCursorPos(imgui.ImVec2(34, 92 + ((i - 1) * bk_size)))
							imgui.Text(u8'Имя действия')
							skin.InputText(134, 90 + ((i - 1) * bk_size), u8'Задайте имя действия##'..i, 'setting.fast_acc.sl.'..i..'.text', 80, 495, nil, 'setting')
							imgui.SetCursorPos(imgui.ImVec2(34, 132 + ((i - 1) * bk_size)))
							imgui.Text(u8'Команда')
							skin.InputText(134, 130 + ((i - 1) * bk_size), u8'Введи исполняемую команду##'..i, 'setting.fast_acc.sl.'..i..'.cmd', 16, 495, '[%a%d+-]+', 'setting')
							
							imgui.SetCursorPos(imgui.ImVec2(34,  175 + ((i - 1) * bk_size)))
							imgui.Text(u8'Передавать в первый аргумент id игрока')
							imgui.SetCursorPos(imgui.ImVec2(34,  205 + ((i - 1) * bk_size)))
							imgui.Text(u8'Отправлять команду без подтверждения')
							imgui.SetCursorPos(imgui.ImVec2(600,  174 + ((i - 1) * bk_size)))
							if skin.Switch(u8'##Передавать в первый аргумент id игрока'..i, setting.fast_acc.sl[i].pass_arg) then
								setting.fast_acc.sl[i].pass_arg = not setting.fast_acc.sl[i].pass_arg
								save('setting') 
							end
							imgui.SetCursorPos(imgui.ImVec2(600,  204 + ((i - 1) * bk_size)))
							if skin.Switch(u8'##Отправлять команду без подтверждения'..i, setting.fast_acc.sl[i].send_chat) then
								setting.fast_acc.sl[i].send_chat = not setting.fast_acc.sl[i].send_chat
								save('setting')
							end
							imgui.PopFont()
						end
						if table_remove_acc ~= 0 then table.remove(setting.fast_acc.sl, table_remove_acc) save('setting') end
					end
					
					imgui.PushFont(font[1])
					skin.Button(u8'Добавить действие', 250, 88 + (#setting.fast_acc.sl * bk_size), 200, 35, function()
						if setting.cmd ~= 0 then
							local new_cell_table = {
								text = u8'Действие '..#setting.fast_acc.sl,
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
				if menu_draw_up(u8'Дополнительные функции', true) then select_basic[8] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Дополнительные функции', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Скоростное открытие двери', setting.speed_door) then
					setting.speed_door = not setting.speed_door save('setting')
					if setting.speed_door then
						rkeys.registerHotKey({72}, 1, true, function() on_hot_key({72}) end)
					else
						rkeys.unRegisterHotKey({72})
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Моментальное открытие дверей и шлагбаумов')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Двери и шлагбаумы станут открываться моментально на клавишу H.')
				imgui.PopFont()
				
				new_draw(97, 81)
				imgui.SetCursorPos(imgui.ImVec2(639, 110))
				if skin.Switch(u8'##Отключить рацию департамента', setting.dep_off) then
					setting.dep_off = not setting.dep_off 
					save('setting')
					if setting.dep_off then
						sampRegisterChatCommand('d', function()
							sampAddChatMessage(script_tag..'{FFFFFF}Вы отключили команду /d в настройках.', color_tag)
						end)
					else
						sampUnregisterChatCommand('d')
					end
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 111))
				imgui.Text(u8'Отключить команду рации департамента (/d)')
				imgui.PopFont()
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(34, 133))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Если Вы очень часто по случайности отправляете информацию в рацию департамента, то можете отклю-')
				imgui.SetCursorPos(imgui.ImVec2(34, 147))
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'чить команду /d. Тогда эта команда просто перестанет работать.')
				imgui.PopFont()
				
				new_draw(190, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 203))
				if skin.Switch(u8'##Автопринятие документов', setting.show_dialog_auto) then
					setting.show_dialog_auto = not setting.show_dialog_auto save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 204))
				imgui.Text(u8'Автоматическое принятие документов')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 226))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'/offer будет приниматься автоматически.')
				imgui.PopFont()
				
				if not setting.kick_afk.func then
					new_draw(270, 68)
				else
					new_draw(270, 107)
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 283))
				if skin.Switch(u8'##Кик афк', setting.kick_afk.func) then
					setting.kick_afk.func = not setting.kick_afk.func save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 284))
				imgui.Text(u8'Автоматически кикать при привышении нормы АФК')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 306))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Игра автоматически примет меры, если Вы привысите указанную норму АФК.')
				imgui.PopFont()
				if setting.kick_afk.func then
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(34, 339))
					imgui.Text(u8'Введите значение в минутах')
					imgui.SetCursorPos(imgui.ImVec2(340, 340))
					imgui.Text(u8'Действие')
					imgui.PopFont()
					skin.InputText(230, 338, u8'Значение', 'setting.kick_afk.time_kick', 4, 78, 'num')
					if skin.List({410, 335}, setting.kick_afk.mode, {u8'Сервер закроет соединение', u8'Игра полностью вылетет'}, 230, 'setting.kick_afk.mode') then
						save('setting')
					end
				end
				
				local pos_at_kick = 0
				if setting.kick_afk.func then
					pos_at_kick = 39
				end
				
				new_draw(350 + pos_at_kick, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 363 + pos_at_kick))
				if skin.Switch(u8'##Анти-тревожка', setting.anti_alarm_but) then
					setting.anti_alarm_but = not setting.anti_alarm_but
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 364 + pos_at_kick))
				imgui.Text(u8'Отключить тревожную кнопку')
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(34, 386 + pos_at_kick))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Тревожная кнопка в холле больницы на клавишу ALT перестанет работать.')
				imgui.PopFont()
				
				new_draw(430 + pos_at_kick, 77)
				imgui.SetCursorPos(imgui.ImVec2(639, 443 + pos_at_kick))
				if skin.Switch(u8'##Расстояние над картой до серверной', setting.display_map_distance.server) then
					setting.display_map_distance.server = not setting.display_map_distance.server
					save('setting')
				end
				imgui.SetCursorPos(imgui.ImVec2(639, 473 + pos_at_kick))
				if skin.Switch(u8'##Расстояние над картой до юзерской', setting.display_map_distance.user) then
					setting.display_map_distance.user = not setting.display_map_distance.user
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 444 + pos_at_kick))
				imgui.Text(u8'Отображать над миникартой расстояние до серверной метки')
				imgui.SetCursorPos(imgui.ImVec2(34, 474 + pos_at_kick))
				imgui.Text(u8'Отображать над миникартой расстояние до пользовательской метки')
				imgui.PopFont()
				
				--[[local pos_at_kick2 = 0
				if setting.stat_online_display then
					pos_at_kick2 = 39 + pos_at_kick
				end]]
				
				imgui.Dummy(imgui.ImVec2(0, 28))
				imgui.EndChild()
			elseif select_basic[9] then
				if menu_draw_up(u8'Настройки скрипта', true) then select_basic[9] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Настройки скрипта', imgui.ImVec2(699, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
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
				imgui.Text(u8'Светлое оформление')

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
				imgui.Text(u8'Тёмное оформление')
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
					if imgui.InvisibleButton(u8'##Выбрать акцент'..num_acc, imgui.ImVec2(22, 22)) then
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
				imgui.Text(u8'Цветовой акцент')
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
				if skin.Switch(u8'##Отключить анимацию открытия и закрытия окна', setting.anim_main) then setting.anim_main = not setting.anim_main save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 327))
				imgui.Text(u8'Отключить анимацию движения окон')
				imgui.PopFont()
				
				imgui.SetCursorPos(imgui.ImVec2(639, 362))
				if skin.Switch(u8'##Отключить сообщение о приветствии', setting.hello_mes) then setting.hello_mes = not setting.hello_mes save('setting') end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 363))
				imgui.Text(u8'Не показывать сообщение о приветствии при запуске скрипта')
				imgui.PopFont()
				
				imgui.EndChild()
			elseif select_basic[10] then
				if menu_draw_up(u8'Обновление', true) then select_basic[10] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Обновление', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				new_draw(17, 68)
				imgui.SetCursorPos(imgui.ImVec2(639, 30))
				if skin.Switch(u8'##Автообновление', setting.auto_update) then
					setting.auto_update = not setting.auto_update 
					save('setting')
				end
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(34, 31))
				imgui.Text(u8'Автоматическое обновление')
				imgui.SetCursorPos(imgui.ImVec2(34, 53))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Скрипт будет обновляться автоматически, без Вашего подтверждения.')
				imgui.PopFont()
				if upd_status == 0 then
					new_draw(97, 85)
					imgui.SetCursorPos(imgui.ImVec2(34, 109))
					imgui.Text(u8'Обновлений нет. Установлена актуальная версия скрипта.')
					skin.Button(u8'Проверить наличие обновления', 32, 137, 636, 27, function() update_check() end)
					
					imgui.PushFont(bold_font[3])
					imgui.SetCursorPos(imgui.ImVec2(247, 211))
					imgui.Text(u8'История нововведений')
					imgui.PopFont()
					new_draw(240, 350)
					
					imgui.SetCursorPos(imgui.ImVec2(32, 255))
					imgui.BeginChild(u8'История нововведений', imgui.ImVec2(646, 320), false)
					imgui.PushFont(font[1])
					imgui.TextWrapped(u8'[Версия 2.1]:\n\n1. Теперь скрипт поддерживает организацию "ТСР".\n2. В РП зону добавлена отыгровка телефона.\n3. Во вкладке "Обновление" теперь есть информация о нововведениях предыдущих версий.\n4. Во вкладке Департамента добавлен формат обращения через закрытый канал.\n5. Функция определения расстояния вызовов теперь работает в разы лучше.\n6. Теперь, при получении ответа от поддержки, у вкладки появляется значок уведомления.\n7. После обновления скрипт теперь будет писать результат обновления.\n8. В настройках скрипта теперь можно отключить приветственное сообщение от скрипта.\n9. Отыгровка CURE была укорочена и актуализирована под правила проекта.\n10. Исправлен баг из-за которого вкладка с вызовами была доступна всем.\n11. Исправлен баг из-за которого включённой автоотыгровке и отключённом автопринятии документы не отображались.\n12. Исправлен баг из-за которого у ЦЛ добавлялись вдобавок отыгровки медиков.\n13. Исправлен баг из-за которого происходил краш скрипта во вкладке с музыкой из-за некоторых названий артистов и песен.\n14. Исправлен баг из-за которого у женского пола отыгровка приветствия была от лица мужского пола.\n15. Исправлен баг из-за которого происходил краш скрипта при пустых полях в ценовой политике.\n16. Исправлен баг из-за которого команды выговора и увольнения стирали текст после пробела.\n17. Исправлен баг из-за которого происходил краш при многократном нажатии на вкладку помощи.\n18. Исправлен баг из-за которого Ваш id в скрипте не обновлялся после реконекта.\n19. Исправлен баг из-за которого репортажи от СМИ не скрывались при включённой функции.\n')
					imgui.TextWrapped(u8'20. Исправлен баг из-за которого в лог статистики не прибавлялись премии у некоторых пользователей.\n21. Исправлен баг из-за которого инвентарь не реагировал при включённой статистики онлайна.\n22. Исправлен баг из-за которого на экране не скрывались время, стата онлайна и текстдрав анимации при включённой сцене в РП зоне.\n23. Доступ к команде лечения изменён на первый ранг.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 2.0]:\n\n1. Добавлена новая вкладка с возможностью задать вопрос поддержке скрипта.\n2. Добавлена новая вкладка с историей чата игры и поиском информации в чате.\n3. Добавлена новая вкладка для быстрого взаимодействия с игрой.\n4. Добавлен новый ряд функций для удобного взаимодействия медикам с вызовами.\n5. Во вкладке с музыкой теперь можно включить другие радиостанции, помимо Рекорда.\n6. Во вкладке со статистикой теперь можно добавить отображение статистики онлайна на экране.\n7. Добавлена функция отображения расстояния до метки на карте в режиме реального времени.\n8. Добавлена функция отключения лишней информации в чате во время РП процесса.\n9. Медикам добавлена команда hme для лечения самого себя.\n10. Во вкладку с командами добавлена возможность поиска команды.\n11. Медикам в статистику добавлены осмотр на пилота, выдача ВУ и премии с квестов.\n12. Исправлена ошибка из-за которой скрипт не работал из-за русских символов в пути к игре.\n13. Доработана система скрытия подсказок сервера в чате.\n14. Добавлены взаимодействия со скриптом: перезагрузка, сброс, полное удаление.\n15. Исправлены мелкие баги интерфейса, а также совершена перестановка вкладок.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.9]:\n\n1. Доработка дизайна.\n2. Исправлен баг с неверным отображением вызовов в статистике.\n3. Добавлена ценовая политика для Автошколы.\n4. Добавлены две новые команды для Больницы: оформление страховки и осмотр для военного билета.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.8]:\n\n1. Небольшие изменения дизайна.\n2. Вкладка музыки вновь работает.\n3. Добавлена функция кика при превышении нормы АФК.\n4. Добавлена функция анти-тревожной кнопки.\n5. Добавлена функция автоматической отыгровки при принятии документов\n6. В меню собеседования добавлена информация о наличии повестки у игрока и лицензии на авто.\n7. В уведомлении о вызове в рации департамента добавлено больше тегов.\n8. В меню Департамента добавлена возможность быстро вставлять заготовленный текст.\n9. Статистика прибыли актуализирована под последние обновления.\n10. В команду SHOW добавлена возможность показа трудовой книжки.\n11. Изменена кнопка взаимодействия с игроками в меню быстрого доступа.\n12. Добавлена возможность просматривать шпаргалку через меню выбора.\n13. Исправлен баг интерфейса во вкладке Статистика.\n14. Создан канал в Discord для решения вопросов и помощи в улучшении скрипта.')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.7]:\n\n1. Исправлен баг сохранения изменений в настройках мемберса\n2. Исправлен баг определения должности\n3. Небольшие изменения дизайна\n4. Изменено пользовательское соглашение')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.6]:\n\n1. Отыгровка инвайта переделана\n2. Увеличено количество вводимых символов в тег департамента\n3. Поиск песен теперь работает на клавишу Enter\n4. Исправлены несколько малозначительных багов')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.5]:\n\n1. Вкладка с музыкой теперь вновь работает\n2. Исправлен баг с определением должности и ранга\n3. Несколько незначительных исправлений и доработок')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.4]:\n\n1. Платная версия стала доступна всем\n2. Добавлена новая фракция - Центральный Банк\n3. Теперь командам можно задать ранг для доступа\n4. Добавлено несколько новых анимаций\n5. Теперь можно изменять длину окна\n6. Теперь окна можно закрывать клавишой ESC\n7. Исправлен баг с лишними отыгровками\n8. Исправлен баг с выдачей лицензии только на 1 месяц\n9. Исправлен баг с ограничением текста при просмотре шпрагалки\n10. Исправлен баг с определением должности\n11. Исправлен баг тега {mynick}\n12. Исправлены ещё несколько мелких багов, которые так сильно раздражали')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.3]:\n\n1. Теперь скрипт отслеживает Ваш онлайн и хранит её во вкладке Статистика\n2. Новая отыгровка для сотрудников Больниц - /osm\n3. Все отыгровки для Автошколы обновлены\n4. Теперь автопринятие /offer принимает только документы\n5. Исправлены мелкие баги и доработаны старые функции')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.2]:\n\n1. Исправлен краш после снятия наркозависимости\n2. Теперь в настройках скрипта можно изменить цветовой акцент\n3. Исправлен баг с неработоспособностью клавиш активации\n4. Исправлен баг с отсутствием обновления должности\n5. Вкладка с командами стала удобней')
					imgui.Dummy(imgui.ImVec2(0, 25))
					imgui.TextWrapped(u8'[Версия 1.1]:\n\n1. Ограничение по созданию команд изменено на 35\n2. Новая вкладка для быстрого создания отыгровок лекций\n3. Исправлен баг с командой /inv\n4. Исправлен баг с музыкой и меню быстрого доступа')
					imgui.PopFont()
					imgui.EndChild()
					imgui.Dummy(imgui.ImVec2(0, 20))
				elseif upd_status == 1 then
					new_draw(97, 43)
					imgui.SetCursorPos(imgui.ImVec2(34, 109))
					imgui.Text(u8'Проверка наличия обновлений...')
				elseif upd_status == 2 then
					new_draw(97, 308)
					imgui.SetCursorPos(imgui.ImVec2(30, 110))
					imgui.Image(IMG_New_Version, imgui.ImVec2(60, 60))
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(107, 127))
					imgui.Text(u8'State Helper '..upd.version)
					imgui.PopFont()
					
					imgui.SetCursorPos(imgui.ImVec2(32, 185))
					imgui.BeginChild(u8'Инфо обновления', imgui.ImVec2(636, 180), false)
					imgui.TextWrapped(u8(upd.text)..'\n\n'..u8(upd.info))
					imgui.EndChild()
					
					if not update_box then
						skin.Button(u8'Обновить', 32, 365, 636, 27, function() 
							update_download()
							update_box = true
						end)
					else
						skin.Button(u8'Обновление запрошено...##false_non', 32, 365, 636, 27, function() end)
					end
				end
				imgui.PopFont()
				imgui.EndChild()
				
			elseif select_basic[11] then
				if menu_draw_up(u8'О скрипте', true) then select_basic[11] = false end
				--imgui.SetCursorPos(imgui.ImVec2(163, 41))
				
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
				imgui.BeginChild(u8'О скрипте', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 40)
				imgui.PushFont(bold_font[3])
				local calc = imgui.CalcTextSize('State Helper '..scr.version)
				imgui.SetCursorPos(imgui.ImVec2(332 - (calc.x / 2), 25))
				imgui.Text('State Helper '..scr.version)
				imgui.PopFont()
				
				new_draw(69, 43)
				imgui.PushFont(font[1])
				imgui.SetCursorPos(imgui.ImVec2(15, 81))
				imgui.Text(u8'© 2024 Все права защищены. Копирование запрещено.')
				new_draw(124, 43)
				imgui.SetCursorPos(imgui.ImVec2(15, 136))
				imgui.Text(u8'Поддержать разработчика: 5469 9804 2297 5769 (номер карты)')
				new_draw(179, 54)
				skin.Button(u8'Обратиться с вопросом по работе скрипта', 15, 191, 636, 30, function()
					shell32.ShellExecuteA(nil, 'open', 'https://discord.gg/jJ3X67tAth', nil, nil, 1)
				end)
				new_draw(245, 54)
				skin.Button(u8'Открыть пользовательское соглашение', 15, 257, 636, 30, function()
					shell32.ShellExecuteA(nil, 'open', 'https://raw.githubusercontent.com/KaneScripter/StateHelper/main/Пользовательское%20соглашение.txt', nil, nil, 1)
				end)
				imgui.PopFont()
				imgui.EndChild()
				
			elseif select_basic[12] then
				if menu_draw_up(u8'Вызовы', true) then select_basic[12] = false end
				imgui.SetCursorPos(imgui.ImVec2(163, 41))
				imgui.BeginChild(u8'Вызовы', imgui.ImVec2(700, 422 + start_pos + new_pos), false, imgui.WindowFlags.NoScrollbar + (size_win and imgui.WindowFlags.NoMove or 0))
				
				if setting.frac.org:find(u8'Больница') then
					new_draw(17, 68)
					imgui.SetCursorPos(imgui.ImVec2(639, 30))
					if skin.Switch(u8'##Функция вызовов', setting.godeath.func) then
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
					imgui.Text(u8'Упростить систему вызовов /godeath')
					imgui.PopFont()
					imgui.PushFont(font[3])
					imgui.SetCursorPos(imgui.ImVec2(34, 53))
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Вам станет удобнее работать с вызовами игроков через /godeath')
					imgui.PopFont()
					
					if setting.godeath.func then
						local function accent_col(num_acc, color_acc, color_acc_act)
							imgui.SetCursorPos(imgui.ImVec2(483 + (num_acc * 43), 285))
							local p = imgui.GetCursorScreenPos()
							
							imgui.SetCursorPos(imgui.ImVec2(472 + (num_acc * 43), 274))
							if imgui.InvisibleButton(u8'##Выбор цвета'..num_acc, imgui.ImVec2(22, 22)) then
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
						if skin.Switch(u8'##Принимать вызов командой', setting.godeath.cmd_go) then
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
						if skin.Switch(u8'##Отображать расстояние от Вас до пострадавшего', setting.godeath.meter) then
							setting.godeath.meter = not setting.godeath.meter
							save('setting')
						end
						imgui.SetCursorPos(imgui.ImVec2(639, 173))
						if skin.Switch(u8'##Заменять два сообщения о вызове одним', setting.godeath.two_text) then
							setting.godeath.two_text = not setting.godeath.two_text
							save('setting')
						end
						imgui.SetCursorPos(imgui.ImVec2(639, 203))
						if skin.Switch(u8'##Автодоклад принятия вызова', setting.godeath.auto_send) then
							setting.godeath.auto_send = not setting.godeath.auto_send
							save('setting')
						end
						imgui.PushFont(font[1])
						imgui.SetCursorPos(imgui.ImVec2(34, 114))
						imgui.Text(u8'Принимать последний вызов командой /go')
						imgui.SetCursorPos(imgui.ImVec2(34, 144))
						imgui.Text(u8'Отображать расстояние от Вас до пациента (beta)')
						imgui.SetCursorPos(imgui.ImVec2(34, 174))
						imgui.Text(u8'Заменять два сообщения о вызове одним')
						imgui.SetCursorPos(imgui.ImVec2(34, 204))
						imgui.Text(u8'Автоматически докладывать в рацию /r о принятии вызова')
						
						new_draw(252, 67)
						
						imgui.SetCursorPos(imgui.ImVec2(34, 276))
						imgui.Text(u8'Цвет вызова')
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
					imgui.Text(u8'Для Вас недоступно')
					imgui.PopFont()
				end
				imgui.EndChild()
			end
			
		----> [2] Команды
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
			menu_draw_up(u8'Команды')
			skin.InputText(480, 11, u8'Поиск', 'search.cmd', 30, 130)
			
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
					local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадение')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'Найдено '..#matching_indices..u8' совпадение')
				elseif ind_end > 1 and ind_end < 5 and ind_two_end ~= 12 and ind_two_end ~= 13 and ind_two_end ~= 14 then
					local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадения')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'Найдено '..#matching_indices..u8' совпадения')
				else
					local calc = imgui.CalcTextSize('Найдено '..#matching_indices..' совпадений')
					imgui.SetCursorPos(imgui.ImVec2(385 - calc.x, 14))
					imgui.Text(u8'Найдено '..#matching_indices..u8' совпадений')
				end
				imgui.PopFont()
			end
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(625, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##Добавить команду', imgui.ImVec2(209, 22)) then
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
				local f = io.open(dirml..'/StateHelper/Отыгровки/cmd'..comp..'.json', 'w')
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
			imgui.Text(u8'Добавить новую команду')
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
			imgui.BeginChild(u8'Команды', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.cmd == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(141, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет ни одной команды')
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
					if imgui.InvisibleButton(u8'##Перейти в редактор отыгровки'..i, imgui.ImVec2(666, 68)) then 
						sdvig_bool = not sdvig_bool
						if sdvig_num == 0 then
							sdvig_num = i
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					local p = imgui.GetCursorScreenPos()
					if i == 1 and #setting.cmd ~= 1 and allocation then -- Поисковое без нажатия
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
						if i == 1 and #setting.cmd ~= 1 then -- Нажатие
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
							imgui.Text(u8'Без описания')
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
							imgui.Text(u8'Без описания')
						else
							imgui.Text(setting.cmd[i][2])
						end
						imgui.PopStyleColor(1)
					end
					
					if sdvig_num == i then
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						local p = imgui.GetCursorScreenPos()
						if i == 1 and #setting.cmd ~= 1 then -- правый угол
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 18)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == 1 and #setting.cmd == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 22) -- кнопка удалить одинокая
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 28), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						elseif i == #setting.cmd then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 20) -- кнопка удалить нижняя
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 0) -- кнопка удалить квадрат
						end
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##Удалить команду', imgui.ImVec2(60, 68)) then
							remove_cmd = i
							sdvig_bool = false
							sdvig_num = 0
							sdvig = 0
						end
						
						if imgui.IsItemActive() then
							imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
							local p = imgui.GetCursorScreenPos()
							if i == 1 and #setting.cmd ~= 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 18) -- хз
							elseif i == 1 and #setting.cmd == 1 then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 22) -- хз
							elseif i == #setting.cmd then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 20) -- хз
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.17, 0.23, 1.00)), 30, 0) -- хз
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
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 1) -- верхний левый
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team2), 60)
						elseif i == 1 and #setting.cmd == 1 then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 9) -- одинокий
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team2), 60)
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(color_team2), 60) 
						elseif i == #setting.cmd then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 8) -- нижний левый
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(color_team2), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666 - sdvig, p.y + 68), imgui.GetColorU32(color_team2), 30, 0) -- середина квадрат
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
							imgui.Text(u8'Без описания')
						else
							imgui.Text(setting.cmd[i][2])
						end
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##Открыть команду', imgui.ImVec2(60, 68)) then
							sdvig_bool = false
							sdvig_num = 0
							sdvig = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[i][1]..'.json') then
								local f = io.open(dirml..'/StateHelper/Отыгровки/'..setting.cmd[i][1]..'.json')
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
					if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[remove_cmd][1]..'.json') then
						os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[remove_cmd][1]..'.json')
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
			
			if menu_draw_up(u8'Редактирование команды', true) then
				imgui.OpenPopup(u8'Дальнейшие действия с командой')
				command_err_nm = false
				command_err_cmd = false
			end
			if imgui.BeginPopupModal(u8'Дальнейшие действия с командой', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'Действие с командой', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##Закрыть окошко команд', imgui.ImVec2(20, 20)) then
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
					imgui.Text(u8'Выберите действие')
				elseif not command_err_cmd then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(63, 95))
					imgui.Text(u8'Такая команда уже существует!')
					imgui.PopFont()
				elseif command_err_cmd then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(126, 95))
					imgui.Text(u8'Задайте команду!')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Сохранить', 10, 167, 123, 25, function()
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
						if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json') then
							os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json')
						end
						local f = io.open(dirml..'/StateHelper/Отыгровки/'..cmd.nm..'.json', 'w')
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
				skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
					select_cmd = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'Удалить', 267, 167, 123, 25, function()
					if doesFileExist(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json') then
						os.remove(dirml..'/StateHelper/Отыгровки/'..setting.cmd[select_cmd][1]..'.json')
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
						text_add_func = u8'Отправить в чат'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'Ожидание нажатия клавиши Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'Вывести информацию в чат (для себя)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'Изменить значение переменной'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'Комментарий'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'Диалог выбора дальнейшего действия'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'Если выбран вариант диалога...'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить диалог'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'Если переменная равна...'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить условие переменной'
					end
					
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y_CMD_F + y_pos_plus))
					if imgui.InvisibleButton(u8'##Добавить функцию в редакторе'..POS_Y_CMD_F + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
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
				if imgui.InvisibleButton(u8'##Посмотреть варианты сл действия', imgui.ImVec2(702, 35)) then
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
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Варианты следующего действия')
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
					imgui.BeginChild(u8'Функции действия', imgui.ImVec2(700, pos_Y_cmd - 35), false)
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
							cmd.act[num_a] = {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}}
						elseif cmd.add_f[1] and #cmd.act ~= 0 then
							table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}})
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
				imgui.BeginChild(u8'Редактирование команды основа', imgui.ImVec2(700, 422 - pos_Y_cmd + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				imgui.PushFont(font[1])
				new_draw(17, 97)
				skin.InputText(114, 31, u8'Установите команду', 'cmd.nm', 15, 553, '[%a%d+-]+')
				if cmd.nm:find('%A+') then
					local characters_to_remove = {
						'Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ', 'Ф', 'Ы', 'В', 'А',
						'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю',
						'Ё', 'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ф', 'ы', 'в',
						'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'
					}
					local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
					cmd.nm = string.gsub(cmd.nm, remove_pattern, '')
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 34))
				imgui.Text(u8'Команда   /')
				skin.Button(u8'Назначить, изменить или очистить клавишу активации', 34, 68, 633, nil, function()
					imgui.OpenPopup(u8'Клавиша активации команды')
					lockPlayerControl(true)
					current_key = {'', {}}
					edit_key = true
				end)
				
				if imgui.BeginPopupModal(u8'Клавиша активации команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##Закрыть окошко клавиш активации', imgui.ImVec2(20, 20)) then
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
					imgui.BeginChild(u8'Назначение клавиши активации', imgui.ImVec2(383, 217), false, imgui.WindowFlags.NoScrollbar)
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(10, 0))
					imgui.Text(u8'Нажмите сочетание клавиш для установки')
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(10, 50))
					imgui.Text(u8'Текущее сочетание:')
					imgui.SetCursorPos(imgui.ImVec2(145, 50))
					if #cmd.key == 0 then
						imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
					else
						local all_keys = {}
						for i = 1, #cmd.key do
							table.insert(all_keys, vkeys.id_to_name(cmd.key[i]))
						end
						imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_keys, ' + '))
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 80))
					imgui.Text(u8'Использовать ПКМ в комбинации с клавишами')
					imgui.PopFont()
					imgui.PopFont()
					skin.DrawFond({0, 36}, {0, 0}, {381, 1}, imgui.ImVec4(0.70, 0.70, 0.70, 1.00), 15, 15)
					imgui.SetCursorPos(imgui.ImVec2(342, 79))
					if skin.Switch(u8'##ПКМ в сочетании', right_mb) then right_mb = not right_mb end
					
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
					if current_key[1] ~= u8'Такая комбинация уже существует' then
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
					
					
					skin.Button(u8'Применить', 0, 180, 185, nil, function()
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
						if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
						if not is_hot_key_done then
							if right_mb then table.insert(current_key[2], 1, 2) end
							cmd.key = current_key[2]
							lockPlayerControl(false)
							edit_key = false
							imgui.CloseCurrentPopup()
						end
					end)
					skin.Button(u8'Очистить', 195, 180, 186, nil, function()
						current_key = {'', {}}
					end)
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(126, 50)
				skin.InputText(114, 140, u8'Введите описание', 'cmd.desc', 120, 553)
				imgui.SetCursorPos(imgui.ImVec2(35, 143))
				imgui.Text(u8'Описание')
				
				new_draw(188, 50)
				imgui.SetCursorPos(imgui.ImVec2(35, 205))
				imgui.Text(u8'Доступ к команде')
				if skin.Slider('##Доступ к команде', 'cmd.rank', 1, 10, 205, {470, 202}, '') then
					cmd.rank = round(cmd.rank, 1)
				end
				imgui.SetCursorPos(imgui.ImVec2(396, 201))
				imgui.Text(u8'с ' ..cmd.rank.. u8' ранга')
				
				new_draw(250, 84)
				skin.Button(u8'Задать или изменить аргументы', 34, 262, 633, nil, function()
					imgui.OpenPopup(u8'Редактирование аргументов')
				end)
				local all_arguments = ''
				if #cmd.arg ~= 0 then
					for ka = 1, #cmd.arg do
						all_arguments = all_arguments..' {arg'..ka..'}'
					end
				else
					all_arguments = u8' Отсутствуют'
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 309))
				imgui.Text(u8'Текущие аргументы:'..all_arguments)
				
				if imgui.BeginPopupModal(u8'Редактирование аргументов', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.BeginChild(u8'Редактор аргументов', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
					imgui.SetCursorPos(imgui.ImVec2(0, 0))
					if imgui.InvisibleButton(u8'##Закрыть окошко аргументов', imgui.ImVec2(20, 20)) then
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
						imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Нет аргументов')
						imgui.PopFont()
					else
						for cm = 1, #cmd.arg do
							local pos_y_c = ( (cm - 1) * 40)
							new_draw(28 + pos_y_c, 30, {5, 390})
							
							imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
							if imgui.InvisibleButton(u8'##Удалить аргумент'..cm, imgui.ImVec2(20, 20)) then table.remove(cmd.arg, cm) break end
							imgui.PushFont(fa_font[1])
							imgui.SetCursorPos(imgui.ImVec2(373, 36 + pos_y_c))
							imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_TRASH)
							imgui.PopFont()
							
							imgui.SetCursorPos(imgui.ImVec2(15, 34 + pos_y_c))
							if cmd.arg[cm][1] == 0 then
								imgui.Text(cm.. u8' числовой с тегом {arg'..cm..'}')
							else
								imgui.Text(cm.. u8' текстовый с тегом {arg'..cm..'}')
							end
							skin.InputText(190, 32 + pos_y_c, u8'Название аргумента##vgas'..cm, 'cmd.arg.'..cm..'.2', 64, 170)
						end
					end
					if #cmd.arg < 5 then
						skin.Button(u8'Добавить числовой аргумент', 0, 240, 400, 25, function() 
							table.insert(cmd.arg, {0, u8'Число'})
						end)
						skin.Button(u8'Добавить текстовый аргумент', 0, 270, 400, 25, function() 
							table.insert(cmd.arg, {1, u8'Текст'})
						end)
					else
						skin.Button(u8'Добавить числовой аргумент##false_non', 0, 240, 400, 25, function() end)
						skin.Button(u8'Добавить текстовый аргумент##false_non', 0, 270, 400, 25, function() end)
					end
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(346, 84)
				skin.Button(u8'Задать или изменить переменные', 34, 358, 633, nil, function()
					imgui.OpenPopup(u8'Редактирование переменных')
				end)
				imgui.SetCursorPos(imgui.ImVec2(35, 405))
				imgui.Text(u8'Текущее количество переменных: '..#cmd.var)
				
				if imgui.BeginPopupModal(u8'Редактирование переменных', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.BeginChild(u8'Редактор переменных', imgui.ImVec2(400, 300), false, imgui.WindowFlags.NoScrollbar)
					imgui.SetCursorPos(imgui.ImVec2(0, 0))
					if imgui.InvisibleButton(u8'##Закрыть окошко переменных', imgui.ImVec2(20, 20)) then
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
						imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Нет переменных')
						imgui.PopFont()
					else
						for cm = 1, #cmd.var do
							local pos_y_c = ( (cm - 1) * 40)
							new_draw(28 + pos_y_c, 30, {5, 390})
							
							imgui.SetCursorPos(imgui.ImVec2(370, 32 + pos_y_c))
							if imgui.InvisibleButton(u8'##Удалить переменную'..cm, imgui.ImVec2(20, 20)) then 
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
							imgui.Text(cm.. u8'. Тег {var'..cm..'}')
							if cmd.var[cm] ~= nil then
								skin.InputText(110, 32 + pos_y_c, u8'Значение переменной##'..cm, 'cmd.var.'..cm..'.2', 40, 250)
							end
						end
					end
					if #cmd.var < 6 then
						skin.Button(u8'Добавить новую переменную', 0, 270, 400, 25, function() 
							table.insert(cmd.var, {1, u8''})
						end)
					else
						skin.Button(u8'Добавить новую переменную##false_non', 0, 270, 400, 25, function() end)
					end
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				new_draw(442, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 454))
				imgui.Text(u8'Задержка проигрывания отыгровки')
				skin.Slider('##Задержка проигрывания отыгровки', 'cmd.delay', 400, 10000, 205, {470, 453}, nil)
				imgui.SetCursorPos(imgui.ImVec2(417, 452))
				imgui.Text(round(cmd.delay / 1000, 0.1)..u8' сек.')
				
				new_draw(498, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 510))
				imgui.Text(u8'Не отправлять последнее сообщение в чат')
				imgui.SetCursorPos(imgui.ImVec2(639, 509))
				if skin.Switch(u8'##Не отправлять сообщение в чат', setting.not_send_chat) then setting.not_send_chat = not setting.not_send_chat save('setting') end
				local POS_Y = 560
				
				local function ic_draw(icon_circ, imvec4_ic)
					local pos_icon = {4, 0}
					local text_add_func = ''
					if icon_circ == fa.ICON_SHARE then
						text_add_func = u8'Отправить в чат'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'Ожидание нажатия клавиши Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'Вывести информацию в чат (для себя)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'Изменить значение переменной'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'Комментарий'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'Диалог выбора действия'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'Если в диалоге                     выбран вариант'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить вариант диалога'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'Если переменная                               равна'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить условие переменной'
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
							skin.InputText(35, POS_Y + 60, u8'Текст##fj'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(97, i)
							POS_Y = POS_Y + 109
						elseif v[1] == 1 then
							new_draw(POS_Y, 45)
							ic_draw(fa.ICON_HOURGLASS, imgui.ImVec4(0.13, 0.83, 0.24 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 45))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(45, i)
							POS_Y = POS_Y + 57
						elseif v[1] == 2 then
							new_draw(POS_Y, 97)
							ic_draw(fa.ICON_LIST, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
							skin.InputText(35, POS_Y + 60, u8'Текст##fe3'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
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
								imgui.Text(d..u8' Действие')
								skin.InputText(125, POS_Y + 30 + (d * 30), u8'Имя действия##'..i..d, 'cmd.act.'..i..'.4.'..d, 40, 500)
							end
							
							if v[3] >= 3 then
								for d = 3, v[3] do
									imgui.SetCursorPos(imgui.ImVec2(648, POS_Y + 34 + (d * 30)))
									imgui.PushFont(fa_font[1])
									imgui.Text(fa.ICON_TRASH)
									imgui.PopFont()
									imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 30 + (d * 30)))
									if imgui.InvisibleButton(u8'##Удалить действие диалога'..i..d, imgui.ImVec2(20, 20)) then
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
								skin.Button(u8'Добавить##'..i, 34, POS_Y + 60 + (v[3] * 30), 100, 23, function()
									v[3] = v[3] + 1
									table.insert(v[4], u8'Действие '..v[3])
								end)
							else
								skin.Button(u8'Добавить##false_non', 34, POS_Y + 60 + (v[3] * 30), 100, 23, function() end)
							end
							
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then
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
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(98 + (cmd.act[i][3] * 30), i)
							POS_Y = POS_Y + 110 + (cmd.act[i][3] * 30)
						elseif v[1] == 4 then
							new_draw(POS_Y, 97, nil, 'comm')
							ic_draw(fa.ICON_ALIGN_LEFT, imgui.ImVec4(0.88, 0.81, 0.18 ,1.00))
							skin.InputText(35, POS_Y + 60, u8'Текст комментария##'..i, 'cmd.act.'..i..'.2', 256, 630)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
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
							skin.InputText(235, POS_Y + 60, u8'Новое значение##'..i, 'cmd.act.'..i..'.3', 256, 430)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 97))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
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
							skin.InputText(345, POS_Y + 10, u8'Значение переменной##'..i, 'cmd.act.'..i..'.3', 256, 260)
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then 
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
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						elseif v[1] == 7 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_STOP..'1', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i, imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
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
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then
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
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
							end
							sel_add_f(43, i)
							POS_Y = POS_Y + 55
						elseif v[1] == 9 then
							new_draw(POS_Y, 43)
							ic_draw(fa.ICON_STOP..'2', imgui.ImVec4(0.21, 0.59, 1.00 ,1.00))
							imgui.SetCursorPos(imgui.ImVec2(645, POS_Y + 12))
							if imgui.InvisibleButton(u8'##Удалить действие'..i..v[1], imgui.ImVec2(20, 20)) then table.insert(remove_table, i) end
							
							if cmd.add_f[1] then
								imgui.SetCursorPos(imgui.ImVec2(17, POS_Y + 43))
								if imgui.InvisibleButton(u8'##Выбрать место вставки'..i, imgui.ImVec2(666, 12)) then cmd.add_f[2] = i end
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
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), u8'Варианты следующего действия')
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
						text_add_func = u8'Отправить в чат'
					elseif icon_circ == fa.ICON_HOURGLASS then
						pos_icon = {6, -1}
						text_add_func = u8'Ожидание нажатия клавиши Enter'
					elseif icon_circ == fa.ICON_LIST then
						pos_icon = {4, -1}
						text_add_func = u8'Вывести информацию в чат (для себя)'
					elseif icon_circ == fa.ICON_PENCIL then
						pos_icon = {6, -1}
						text_add_func = u8'Изменить значение переменной'
					elseif icon_circ == fa.ICON_ALIGN_LEFT then
						text_add_func = u8'Комментарий'
					elseif icon_circ == fa.ICON_LIST_OL then
						pos_icon = {4, -1}
						text_add_func = u8'Диалог выбора дальнейшего действия'
					elseif icon_circ == fa.ICON_SIGN_OUT then
						pos_icon = {5, -1}
						text_add_func = u8'Если выбран вариант диалога...'
					elseif icon_circ == fa.ICON_STOP..'2' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить диалог'
					elseif icon_circ == fa.ICON_SUPERSCRIPT then
						pos_icon = {6, -1}
						text_add_func = u8'Если переменная равна...'
					elseif icon_circ == fa.ICON_STOP..'1' then
						pos_icon = {6, -1}
						text_add_func = u8'Завершить условие переменной'
					end
					
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 500, p.y + 34), imgui.GetColorU32(imgui.ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00)), 8, 15)
					imgui.SetCursorPos(imgui.ImVec2(100, POS_Y + y_pos_plus))
					if imgui.InvisibleButton(u8'##Добавить функцию в редакторе'..POS_Y + y_pos_plus..icon_circ, imgui.ImVec2(500, 34)) then return_bool = true end
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
						cmd.act[num_a] = {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}}
					elseif cmd.add_f[1] and #cmd.act ~= 0 then
						table.insert(cmd.act, num_a, {3, cmd.num_d, 2, {u8'Действие 1', u8'Действие 2'}})
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
					skin.Button(u8'Добавлять в конец', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
					skin.Button(u8'Добавлять в место##false_func', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
					res_pos = res_pos + 60
				elseif cmd.add_f[1] and #cmd.act >= 2 then 
					skin.Button(u8'Добавлять в конец##false_func', 100, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = false end)
					skin.Button(u8'Добавлять в место', 352, POS_Y + res_pos + 30, 245, 25, function() cmd.add_f[1] = true cmd.add_f[2] = #cmd.act end)
					res_pos = res_pos + 60
				end
				
				skin.Button(u8'Посмотреть доступные теги', 100, POS_Y + res_pos + 30, 495, 35, function()
					imgui.OpenPopup(u8'Просмотр доступных тегов')
				end)
				
				if imgui.BeginPopupModal(u8'Просмотр доступных тегов', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##Закрыть окошко тегов', imgui.ImVec2(20, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(20, 20))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.32, 0.38, 1.00)), 60)
						imgui.SetCursorPos(imgui.ImVec2(16, 13))
						imgui.PushFont(fa_font[2])
						imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00, 0.70), fa.ICON_TIMES)
						imgui.PopFont()
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32(imgui.ImVec4(0.98, 0.42, 0.38, 1.00)), 60)
					end
					imgui.SetCursorPos(imgui.ImVec2(10, 35))
					imgui.BeginChild(u8'Просмотр тегов', imgui.ImVec2(750, 400), false, imgui.WindowFlags.NoScrollbar)
					
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
							sampAddChatMessage(script_tag..'{FFFFFF}Текст скопирован в буфер обмена: {d121b7}'..tag_text, color_tag)
						end
						
						imgui.PopFont()
					end
					
					tag_hint_text(1, '{mynick}', 'Выведет Ваш никнейм на английском')
					tag_hint_text(2, '{myid}', 'Выведет Ваш id')
					tag_hint_text(3, '{mynickrus}', 'Выведет Ваш никнейм на русском')
					tag_hint_text(4, '{myrank}', 'Выведет Вашу должность')
					tag_hint_text(5, '{time}', 'Выведет текущее время')
					tag_hint_text(6, '{day}', 'Выведет текущий день')
					tag_hint_text(7, '{week}', 'Выведет текущую неделю')
					tag_hint_text(8, '{month}', 'Выведет текущий месяц')
					tag_hint_text(9, '{getplnick[id игрока]}', 'Выведет ник игрока по его ID')
					tag_hint_text(10, '{get_ru_nick[id игрока]}', 'Выведет ник игрока по его ID на кириллице')
					tag_hint_text(11, '{get_city}', 'Выведет назву города')
					tag_hint_text(12, '{get_square}', 'Выведет текущего квадрата')
					tag_hint_text(13, '{get_area}', 'Получить текущий район')
					tag_hint_text(14, '{get_storecar_model}', 'Получить модель ближайшего к вам авто с водителем')
					tag_hint_text(15, '{get_veh_color}', 'Получить цвет ближайшего к вам авто с водителем')
					tag_hint_text(16, '{get_veh_status[id игрока]}', 'Получить статус игрока (В автомобиле) или (пешком)')
					tag_hint_text(17, '{sex}', 'Добавкит букву "а" при женском поле')
					tag_hint_text(18, '{nearest}', 'Получить id ближайшего игрока в радиусе 60 метров')
					tag_hint_text(19, '{copy_nick[id игрока]}', 'Скопировать Nick_Name игрока')
					tag_hint_text(20, '{med7}', 'Выведет цену на новую мед. карту на 7 дней')
					tag_hint_text(21, '{med14}', 'Выведет цену на новую мед. карту на 14 дней')
					tag_hint_text(22, '{med30}', 'Выведет цену на новую мед. карту на 30 дней')
					tag_hint_text(23, '{med60}', 'Выведет цену на новую мед. карту на 60 дней')
					tag_hint_text(24, '{medup7}', 'Выведет цену на обновлённую мед. карту на 7 дней')
					tag_hint_text(25, '{medup14}', 'Выведет цену на обновлённую мед. карту на 14 дней')
					tag_hint_text(26, '{medup30}', 'Выведет цену на обновлённую мед. карту на 30 дней')
					tag_hint_text(27, '{medup60}', 'Выведет цену на обновлённую мед. карту на 60 дней')
					tag_hint_text(28, '{pricenarko}', 'Выведет цену на снятие наркозависимости')
					tag_hint_text(29, '{pricerecept}', 'Выведет цену на рецепт')
					tag_hint_text(30, '{pricetatu}', 'Выведет цену удаление татуировки с тела')
					tag_hint_text(31, '{priceant }', 'Выведет цену на антибиотик')
					tag_hint_text(32, '{pricelec }', 'Выведет цену на лечение')
					tag_hint_text(33, '{priceosm }', 'Выведет цену на мед. осмотр')

					
					tag_hint_text(34, '{priceauto1}', 'Выведет цену на авто за 1 месяц')
					tag_hint_text(35, '{priceauto2}', 'Выведет цену на авто за 2 месяца')
					tag_hint_text(36, '{priceauto3}', 'Выведет цену на авто за 3 месяца')
					tag_hint_text(37, '{pricemoto1}', 'Выведет цену на мото за 1 месяц')
					tag_hint_text(38, '{pricemoto2}', 'Выведет цену на мото за 2 месяца')
					tag_hint_text(39, '{pricemoto3}', 'Выведет цену на мото за 3 месяца')
					tag_hint_text(40, '{pricefly}', 'Выведет цену на полёты')
					tag_hint_text(41, '{pricefish1}', 'Выведет цену на рыбалку за 1 месяц')
					tag_hint_text(42, '{pricefish2}', 'Выведет цену на рыбалку за 2 месяца')
					tag_hint_text(43, '{pricefish3}', 'Выведет цену на рыбалку за 3 месяца')
					tag_hint_text(44, '{priceswim1}', 'Выведет цену на водный транспорт за 1 месяц')
					tag_hint_text(45, '{priceswim2}', 'Выведет цену на водный транспорт за 2 месяца')
					tag_hint_text(46, '{priceswim3}', 'Выведет цену на водный транспорт за 3 месяца')
					tag_hint_text(47, '{pricegun1}', 'Выведет цену на оружие за 1 месяц')
					tag_hint_text(48, '{pricegun2}', 'Выведет цену на оружие за 2 месяца')
					tag_hint_text(49, '{pricegun3}', 'Выведет цену на оружие за 3 месяца')
					tag_hint_text(50, '{pricehunt1}', 'Выведет цену на охоту за 1 месяц')
					tag_hint_text(51, '{pricehunt2}', 'Выведет цену на охоту за 2 месяца')
					tag_hint_text(52, '{pricehunt3}', 'Выведет цену на охоту за 3 месяца')
					tag_hint_text(53, '{priceexc1}', 'Выведет цену на раскопки за 1 месяц')
					tag_hint_text(54, '{priceexc2}', 'Выведет цену на раскопки за 2 месяца')
					tag_hint_text(55, '{priceexc3}', 'Выведет цену на раскопки за 3 месяца')
					tag_hint_text(56, '{pricetaxi1}', 'Выведет цену на такси за 1 месяц')
					tag_hint_text(57, '{pricetaxi2}', 'Выведет цену на такси за 2 месяца')
					tag_hint_text(58, '{pricetaxi3}', 'Выведет цену на такси за 3 месяца')
					tag_hint_text(59, '{pricemeh1}', 'Выведет цену на механика за 1 месяц')
					tag_hint_text(60, '{pricemeh2}', 'Выведет цену на механика за 2 месяца')
					tag_hint_text(61, '{pricemeh3}', 'Выведет цену на механика за 3 месяца')
					
					tag_hint_text(62, '{sex:муж,жен}', 'Добавит текст в соответствии с выбранным полом')
					tag_hint_text(63, '{dialoglic[id лицензии][id срока][id игрока]}', 'Автовыбор диалога с лицензией')
					tag_hint_text(64, '{target}', 'Выведет id с последнего прицела на игрока')
					tag_hint_text(65, '{prtsc}', 'Сделает скриншот игры F8')
					
					
					imgui.EndChild()
					
					imgui.EndPopup()
				end
				--[[
				0 - Отправить в чат
				1 - Ожидание нажатия Enter
				2 - Вывести инфо в чат
				3 - Диалог выбора действия
				4 - Комментарий
				5 - Изменить переменную
				6 - Если переменная равна
				7 - Завершить условие переменной
				8 - Если выбран вариант диалога
				9 - Завершить диалог
				]]
				
				imgui.Dummy(imgui.ImVec2(0, 90))
				imgui.PopFont()
				imgui.EndChild()
				imgui.PopStyleVar(1)
			end
			
		----> [3] Шпоры
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
			menu_draw_up(u8'Шпоры')
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(639, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##Добавить шпаргалку', imgui.ImVec2(195, 22)) then
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
				local f = io.open(dirml..'/StateHelper/Шпаргалки/shpora'..comp..'.txt', 'w')
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
			imgui.Text(u8'Добавить новую шпору')
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
			imgui.BeginChild(u8'Шпаргалка', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.shpora == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(137, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет ни одной шпаргалки')
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
					if imgui.InvisibleButton(u8'##Перейти в редактор шпаргалки'..i, imgui.ImVec2(666, 68)) then
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
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 3) -- верхняя прав и лев
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 29), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						elseif i == 1 and #setting.shpora == 1 then
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 15)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 15) -- одинокая
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
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 12) -- нижняя лев и прав
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 29, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
								imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 637.5, p.y + 39), 28.5, imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 60)
							end
						else
							if setting.int.theme == 'White' then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] - 0.11, col_end.fond_two[2] - 0.11, col_end.fond_two[3] - 0.11, 1.00)), 30, 0)
							else
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 666, p.y + 68), imgui.GetColorU32(imgui.ImVec4(col_end.fond_two[1] + 0.06, col_end.fond_two[2] + 0.06, col_end.fond_two[3] + 0.06, 1.00)), 30, 0) -- квадрат
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
							imgui.Text(u8'Без текста')
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
							imgui.Text(u8'Без текста')
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
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 20) -- кнопка удалить нижняя
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + 32, p.y + 40), 28, imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 60)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 68), imgui.GetColorU32(imgui.ImVec4(1.00, 0.27, 0.23, 1.00)), 30, 0)
						end
						imgui.SetCursorPos(imgui.ImVec2(606, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##Удалить команду', imgui.ImVec2(60, 68)) then
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
							imgui.Text(u8'Без текста')
						else
							imgui.Text(setting.shpora[i][2])
						end
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(546, 17 + ( (i - 1) * 68)))
						if imgui.InvisibleButton(u8'##Открыть шпору', imgui.ImVec2(60, 68)) then
							anim_menu_shpora[3] = false
							anim_menu_shpora[1] = 0
							anim_menu_shpora[4] = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt') then
								local f = io.open(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt')
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
						if imgui.InvisibleButton(u8'##Посмотреть шпору', imgui.ImVec2(60, 68)) then
							anim_menu_shpora[3] = false
							anim_menu_shpora[1] = 0
							anim_menu_shpora[4] = 0
							
							POS_Y = 380
							if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt') then
								local f = io.open(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[i][1]..'.txt')
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
			
			if menu_draw_up(u8'Редактирование шпаргалки', true) then
				imgui.OpenPopup(u8'Дальнейшие действия с шпаргалкой')
				shpora_err_nm = false
			end
			imgui.PushFont(font[1])
			skin.Button(u8'Открыть для просмотра', 656, 9, 180, 26, function() 
				text_spur = shpora.text
				win.spur_big.v = true
			end)
			imgui.PopFont()
			if imgui.BeginPopupModal(u8'Дальнейшие действия с шпаргалкой', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'Действие с шпаргалкой', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##Закрыть окошко шпаргалки', imgui.ImVec2(20, 20)) then
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
					imgui.Text(u8'Выберите действие')
				else
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(86, 95))
					imgui.Text(u8'Такое имя уже существует')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Сохранить', 10, 167, 123, 25, function()
					for i = 1, #setting.shpora do
						if setting.shpora[i][1] == shpora.nm and i ~= select_shpora then
							shpora_err_nm = true
							break
						end
					end
					if not shpora_err_nm  then
						if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt') then
							os.remove(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt')
						end
						local f = io.open(dirml..'/StateHelper/Шпаргалки/'..shpora.nm..'.txt', 'w')
						f:write(u8:decode(shpora.text))
						f:flush()
						f:close()
						local textes = ''
						local buf_text_shpora = imgui.ImBuffer(75)
						buf_text_shpora.v = u8:decode(shpora.text)
						buf_text_shpora.v = string.gsub(buf_text_shpora.v, '\n.+', '')
						textes = u8(buf_text_shpora.v)
						if shpora.text ~= '' and buf_text_shpora.v == '' then textes = u8'Пустая строка' end
						if textes ~= shpora.text and textes ~= u8'Пустая строка' then textes = textes..' ...' end
						setting.shpora[select_shpora] = {shpora.nm, textes}
						save('setting')
						select_shpora = 0
						imgui.CloseCurrentPopup()
					end
				end)
				skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
					select_shpora = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'Удалить', 267, 167, 123, 25, function()
					if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt') then
						os.remove(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[select_shpora][1]..'.txt')
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
				imgui.BeginChild(u8'Редактирование шпоры', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				imgui.PushFont(font[1])
				new_draw(17, 48)
				imgui.SetCursorPos(imgui.ImVec2(35, 32))
				imgui.Text(u8'Имя шпоры')
				skin.InputText(125, 30, u8'Задайте имя шпаргалки', 'shpora.nm', 95, 539, nil)
				new_draw(77, 328)
				imgui.SetCursorPos(imgui.ImVec2(25, 87))
				local text_multiline = imgui.ImBuffer(512000)
				text_multiline.v = shpora.text
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
				imgui.InputTextMultiline('##Окно ввода текста шпоры', text_multiline, imgui.ImVec2(649, 318))
				imgui.PopStyleColor()
				if text_multiline.v == '' and not imgui.IsItemActive() then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					imgui.SetCursorPos(imgui.ImVec2(29, 88))
					imgui.Text(u8'Вводите текст Вашей шпаргалки')
					imgui.PopStyleColor()
				end
				shpora.text = text_multiline.v
				imgui.PopFont()
				
				imgui.EndChild()
			end
			
		----> [4] Департамент
		elseif select_main_menu[4] then
			menu_draw_up(u8'Департамент')
			dep_win()
		
		----> [5] Собеседование
		elseif select_main_menu[5] then
			menu_draw_up(u8'Меню собеседования')
			win_sobes_fix()
			
		----> [6] Напоминания
		elseif select_main_menu[6] then
			menu_draw_up(u8'Напоминания')
			reminder_win_fix()
			
		----> [7] Статистика
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
					if imgui.InvisibleButton(u8'##Сменить вкладку статистики'..pos_draw[1], imgui.ImVec2(234, 25)) then select_stat = num_select end
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
			menu_draw_up(u8'Статистика')
			
			draw_button({162, 40}, u8'Прибыль', 0)
			draw_button({396, 40}, u8'Онлайн', 1)
			draw_button({630, 40}, u8'Настройки отображения', 2)
			
			imgui.SetCursorPos(imgui.ImVec2(180, 65))
			if select_stat == 0 then
				imgui.BeginChild(u8'Статистика прибыли', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				if setting.frac.org:find(u8'Больница') then
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
								if earnings_text('Зарплата:', setting.stat.hosp.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.payday[i] end
								if earnings_text('Лечение:', setting.stat.hosp.lec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.lec[i] end
								if earnings_text('Оформление мед.карт:', setting.stat.hosp.medcard[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcard[i] end
								if earnings_text('Снятие наркозависимости:', setting.stat.hosp.apt[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.apt[i] end
								if earnings_text('Продажа антибиотиков:', setting.stat.hosp.ant[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.ant[i] end
								if earnings_text('Продажа рецептов:', setting.stat.hosp.rec[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.rec[i] end
								if earnings_text('Перевозка медикаментов:', setting.stat.hosp.medcam[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.medcam[i] end
								if earnings_text('За вызовы:', setting.stat.hosp.cure[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.cure[i] end
								if earnings_text('Сведение татуировок:', setting.stat.hosp.tatu[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.hosp.tatu[i] end
								if earnings_text('Мед. осмотр:', setting.new_stat_bl.osm[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.osm[i] end
								if earnings_text('Осмотр повестников:', setting.new_stat_bl.ticket[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.ticket[i] end
								if earnings_text('Премии за квесты:', setting.new_stat_bl.awards[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.new_stat_bl.awards[i] end
								
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
								if setting.int.theme == 'White' then
									imgui.TextColoredRGB('{000000}Итого за день: {279643}'..point_sum(total_day)..'$')
								else
									imgui.TextColoredRGB('{FFFFFF}Итого за день: {36CF5C}'..point_sum(total_day)..'$')
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
								imgui.Text(u8'В этот день Вы ничего не заработали')
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
						imgui.TextColoredRGB('{000000}Итого за неделю: {279643}'..point_sum(setting.stat.hosp.total_week)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}Итого за неделю: {36CF5C}'..point_sum(setting.stat.hosp.total_week)..'$')
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}Итого за всё время: {279643}'..point_sum(setting.stat.hosp.total_all)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}Итого за всё время: {36CF5C}'..point_sum(setting.stat.hosp.total_all)..'$')
					end
					imgui.PopFont()
					skin.Button(u8'Сбросить статистику', 270, 98 + pos_y, 145, 30, function()
						if setting.frac.org:find(u8'Больница') then
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
					
				--[[elseif setting.frac.org:find(u8'Центр Лицензирования') then
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
								if earnings_text('Зарплата:', setting.stat.school.payday[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.payday[i] end
								if earnings_text('Авто:', setting.stat.school.auto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.auto[i] end
								if earnings_text('Мото:', setting.stat.school.moto[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.moto[i] end
								if earnings_text('Рыбалка:', setting.stat.school.fish[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.fish[i] end
								if earnings_text('Плавание:', setting.stat.school.swim[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.swim[i] end
								if earnings_text('Оружие:', setting.stat.school.gun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.gun[i] end
								if earnings_text('Охота:', setting.stat.school.hun[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.hun[i] end
								if earnings_text('Раскопки:', setting.stat.school.exc[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.exc[i] end
								if earnings_text('Такси:', setting.stat.school.taxi[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.taxi[i] end
								if earnings_text('Механика:', setting.stat.school.meh[i], 17, 69 + pos_y + pp_y) then pp_y = pp_y + 23 total_day = total_day + setting.stat.school.meh[i] end
								
								imgui.PushFont(font[1])
								imgui.SetCursorPos(imgui.ImVec2(17, 79 + pos_y + pp_y))
								if setting.int.theme == 'White' then
									imgui.TextColoredRGB('{000000}Итого за день: {279643}'..point_sum(total_day)..'$')
								else
									imgui.TextColoredRGB('{FFFFFF}Итого за день: {36CF5C}'..point_sum(total_day)..'$')
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
								imgui.Text(u8'В этот день Вы ничего не заработали')
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
						imgui.TextColoredRGB('{000000}Итого за неделю: {279643}'..point_sum(setting.stat.school.total_week)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}Итого за неделю: {36CF5C}'..point_sum(setting.stat.school.total_week)..'$')
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 49 + pos_y))
					if setting.int.theme == 'White' then
						imgui.TextColoredRGB('{000000}Итого за всё время: {279643}'..point_sum(setting.stat.school.total_all)..'$')
					else
						imgui.TextColoredRGB('{FFFFFF}Итого за всё время: {36CF5C}'..point_sum(setting.stat.school.total_all)..'$')
					end
					imgui.PopFont()
					skin.Button(u8'Сбросить статистику', 270, 98 + pos_y, 145, 30, function()
						if setting.frac.org:find(u8'Центр Лицензирования') then
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
					imgui.Text(u8'Для Вас пока недоступно')
					imgui.PopFont()
				end
				
				imgui.EndChild()
			elseif select_stat == 1 then
				imgui.BeginChild(u8'Статистика онлайна', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
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
							imgui.TextColoredRGB('{000000}Чистый онлайн за день: {279643}'.. print_time(setting.online_stat.clean[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за день: {36CF5C}'.. print_time(setting.online_stat.clean[i]))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 75 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}АФК за день: {279643}'.. print_time(setting.online_stat.afk[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}АФК за день: {36CF5C}'.. print_time(setting.online_stat.afk[i]))
						end
						imgui.SetCursorPos(imgui.ImVec2(17, 98 + pos_y))
						if setting.int.theme == 'White' then
							imgui.TextColoredRGB('{000000}Всего за день: {279643}'.. print_time(setting.online_stat.all[i]))
						else
							imgui.TextColoredRGB('{FFFFFF}Всего за день: {36CF5C}'.. print_time(setting.online_stat.all[i]))
						end
						
						pos_y = pos_y + 144
						
						if i == 1 then
							imgui.SetCursorPos(imgui.ImVec2(17, -17 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}Чистый за сессию: {279643}'.. print_time(session_clean.v))
							else
								imgui.TextColoredRGB('{FFFFFF}Чистый за сессию: {36CF5C}'.. print_time(session_clean.v))
							end
							imgui.SetCursorPos(imgui.ImVec2(17, 6 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}АФК за сессию: {279643}'.. print_time(session_afk.v))
							else
								imgui.TextColoredRGB('{FFFFFF}АФК за сессию: {36CF5C}'.. print_time(session_afk.v))
							end
							imgui.SetCursorPos(imgui.ImVec2(17, 29 + pos_y))
							if setting.int.theme == 'White' then
								imgui.TextColoredRGB('{000000}Всего за сессию: {279643}'.. print_time(session_all.v))
							else
								imgui.TextColoredRGB('{FFFFFF}Всего за сессию: {36CF5C}'.. print_time(session_all.v))
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
					imgui.TextColoredRGB('{000000}Чистый онлайн за неделю: {279643}'.. print_time(setting.online_stat.total_week))
				else
					imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за неделю: {36CF5C}'.. print_time(setting.online_stat.total_week))
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 34 + pos_y))
				if setting.int.theme == 'White' then
					imgui.TextColoredRGB('{000000}Чистый онлайн за всё время: {279643}'.. print_time(setting.online_stat.total_all))
				else
					imgui.TextColoredRGB('{FFFFFF}Чистый онлайн за всё время: {36CF5C}'.. print_time(setting.online_stat.total_all))
				end
				imgui.PopFont()
				pos_y = pos_y + 81
				
				skin.Button(u8'Сбросить статистику##онлайна', 270, pos_y, 145, 30, function()
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
				imgui.BeginChild(u8'Настройки отображения', imgui.ImVec2(682, 398 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
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
				imgui.Text(u8'Настройки отображения статистики онлайна')
				imgui.PopFont()
				
				new_draw(46, 68)
				
				imgui.SetCursorPos(imgui.ImVec2(624, 59))
				if skin.Switch(u8'##Статистика онлайна на экране', setting.stat_online_display) then
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
				imgui.Text(u8'Статистика онлайна на экране')
				
				imgui.PopFont()
				imgui.SetCursorPos(imgui.ImVec2(17, 82))
				imgui.PushFont(font[3])
				imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Статистика онлайна будет всегда отображаться на Вашем экране.')
				imgui.PopFont()
				
				if setting.stat_online_display then --stat_online_display_hiding
					new_draw(129, 68)
					
					imgui.SetCursorPos(imgui.ImVec2(624, 142))
					if skin.Switch(u8'##Скрывать при диалоге', setting.stat_online_display_hiding) then
						setting.stat_online_display_hiding = not setting.stat_online_display_hiding
						save('setting')
					end
					imgui.PushFont(font[1])
					imgui.SetCursorPos(imgui.ImVec2(17, 143))
					imgui.Text(u8'Скрывать при диалогах')
					
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(17, 165))
					imgui.PushFont(font[3])
					imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Во время открытого диалога, инвентаря или TAB - статистика будет скрываться.')
					imgui.PopFont()
				
					new_draw(211, 258)
					imgui.PushFont(font[1])
					
					imgui.SetCursorPos(imgui.ImVec2(17, 225))
					imgui.Text(u8'Отображать текущее время')
					imgui.SetCursorPos(imgui.ImVec2(17, 255))
					imgui.Text(u8'Отображать текущую дату')
					imgui.SetCursorPos(imgui.ImVec2(17, 285))
					imgui.Text(u8'Отображать чистый онлайн за день')
					imgui.SetCursorPos(imgui.ImVec2(17, 315))
					imgui.Text(u8'Отображать АФК за день')
					imgui.SetCursorPos(imgui.ImVec2(17, 345))
					imgui.Text(u8'Отображать всего за день')
					imgui.SetCursorPos(imgui.ImVec2(17, 375))
					imgui.Text(u8'Отображать чистый за сессию')
					imgui.SetCursorPos(imgui.ImVec2(17, 405))
					imgui.Text(u8'Отображать АФК за сессию')
					imgui.SetCursorPos(imgui.ImVec2(17, 435))
					imgui.Text(u8'Отображать всего за сессию')
					
					imgui.SetCursorPos(imgui.ImVec2(624, 224))
					if skin.Switch(u8'##Текущее время', setting.stat_on_members.time) then
						setting.stat_on_members.time = not setting.stat_on_members.time
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 254))
					if skin.Switch(u8'##Текущая дата', setting.stat_on_members.date) then
						setting.stat_on_members.date = not setting.stat_on_members.date
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 284))
					if skin.Switch(u8'##Чистый за день', setting.stat_on_members.clean_on_day) then
						setting.stat_on_members.clean_on_day = not setting.stat_on_members.clean_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 314))
					if skin.Switch(u8'##АФК за день', setting.stat_on_members.afk_on_day) then
						setting.stat_on_members.afk_on_day = not setting.stat_on_members.afk_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 344))
					if skin.Switch(u8'##Всего за день', setting.stat_on_members.all_on_day) then
						setting.stat_on_members.all_on_day = not setting.stat_on_members.all_on_day
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 374))
					if skin.Switch(u8'##Чистый за сессию', setting.stat_on_members.clean_on_session) then
						setting.stat_on_members.clean_on_session = not setting.stat_on_members.clean_on_session
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 404))
					if skin.Switch(u8'##АФК за сессию', setting.stat_on_members.afk_on_session) then
						setting.stat_on_members.afk_on_session = not setting.stat_on_members.afk_on_session
						save('setting')
					end
					imgui.SetCursorPos(imgui.ImVec2(624, 434))
					if skin.Switch(u8'##Всего за сессию', setting.stat_on_members.all_on_session) then
						setting.stat_on_members.all_on_session = not setting.stat_on_members.all_on_session
						save('setting')
					end
					
					new_draw(483, 60)
					skin.Button(u8'Изменить положение окна', 17, 498, 636, 30, function() ch_pos_on_stat() end)
					--imgui.Dummy(imgui.ImVec2(0, 15))
					
					imgui.PopFont()
					
				end
				imgui.Dummy(imgui.ImVec2(0, 35))
				imgui.EndChild()
			end
			
		----> [8] Музыка
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
					if imgui.InvisibleButton(u8'##Сменить вкладку музыки'..pos_draw[1], imgui.ImVec2(175.5, 25)) then select_music = num_select end
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
			menu_draw_up(u8'Музика')
			
			draw_button({162, 40}, u8'Пошук в інтернеті', 1)
			draw_button({337.5, 40}, u8'Улюблене', 2)
			draw_button({513, 40}, u8'Радіо Relax', 3)
			draw_button({688.5, 40}, u8'Інші радіо', 4)
			
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
					if imgui.InvisibleButton(u8'##Переключить назад', imgui.ImVec2(18, 17)) then back_track() end
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
					if imgui.InvisibleButton(u8'##Переключить вперёд', imgui.ImVec2(18, 17)) then next_track() end
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
					if imgui.InvisibleButton(u8'##Пауза', imgui.ImVec2(27, 27)) then action_song('PAUSE') end
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
					if imgui.InvisibleButton(u8'##Возобновить', imgui.ImVec2(27, 27)) then action_song('PLAY') end
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
				imgui.Text(u8'Нічого не грає')
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
					if imgui.SliderFloat(u8'##Перемотка', sectime_track, 0, track_time_hc - 2, u8'') then rewind_song(sectime_track.v) end
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
			if imgui.SliderFloat(u8'##Громкость', volume_buf, 0, 2, u8'') then 
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
			if imgui.InvisibleButton(u8'##Повторение', imgui.ImVec2(20, 20)) then setting.mus.rep = not setting.mus.rep save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(751, 421 + start_pos + new_pos))
			if setting.mus.rep and not imgui.IsItemActive() then
				imgui.Text(fa.ICON_REPEAT)
			elseif not imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_REPEAT)
			elseif imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_REPEAT)
			end
			imgui.SetCursorPos(imgui.ImVec2(789, 419 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##Окно плеера', imgui.ImVec2(20, 20)) then setting.mus.win = not setting.mus.win save('setting') end
			imgui.SetCursorPos(imgui.ImVec2(792, 421 + start_pos + new_pos))
			if setting.mus.win and not imgui.IsItemActive() then
				imgui.Text(fa.ICON_WINDOW_MAXIMIZE)
			elseif not imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.40), fa.ICON_WINDOW_MAXIMIZE)
			elseif imgui.IsItemActive() then
				imgui.TextColored(imgui.ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00), fa.ICON_WINDOW_MAXIMIZE)
			end
			imgui.SetCursorPos(imgui.ImVec2(832, 419 + start_pos + new_pos))
			if imgui.InvisibleButton(u8'##Остановить музыку', imgui.ImVec2(20, 20)) then
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
				
				if skin.InputText(193, 72, u8'Введите название песни или его исполнителя', 'text_find_track', 100, 591, nil, nil, 'enterflag') then
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
				skin.Button(u8'Поиск', 784, 65, 80, 36, function() 
					if text_find_track ~= '' then
						qua_page = 1
						sel_link = ''
						find_track_link(text_find_track, 1)
					end
				end)
				imgui.PopStyleVar(1)
				imgui.SetCursorPos(imgui.ImVec2(180, 101))
				imgui.BeginChild(u8'Поиск в интернете', imgui.ImVec2(682, 304 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				if tracks.link[1] ~= 'Ошибка404' then
					local POS_Y_T = 17
					for i = 1, #tracks.link do
						new_draw(POS_Y_T, 36)
						imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
						if imgui.InvisibleButton(u8'##Включить трек'..i, imgui.ImVec2(634, 36)) then
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
						if imgui.InvisibleButton(u8'##Добавить в избранные'..i, imgui.ImVec2(20, 20)) then
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
							if imgui.InvisibleButton(u8'##Перейти к странице'..m, imgui.ImVec2(23, 23)) then
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
					imgui.Text(u8'Ничего не найдено')
					imgui.PopFont()
				end
				imgui.EndChild()
				imgui.PopFont()
				
			elseif select_music == 2 then
				imgui.SetCursorPos(imgui.ImVec2(180, 65))
				imgui.BeginChild(u8'Избранные', imgui.ImVec2(682, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local remove_table_track = nil
				if #save_tracks.link ~= 0 then
					local POS_Y_T = 17
					for i = 1, #save_tracks.link do
						new_draw(POS_Y_T, 36)
						imgui.SetCursorPos(imgui.ImVec2(32, POS_Y_T))
						if imgui.InvisibleButton(u8'##Включить сохранённый трек'..i, imgui.ImVec2(634, 36)) then
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
						if imgui.InvisibleButton(u8'##Удалить из избранных'..i, imgui.ImVec2(20, 20)) then
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
					imgui.Text(u8'Нет избранных треков')
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
				imgui.BeginChild(u8'Радио Record', imgui.ImVec2(702, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local function background_record_card(posX_R, posY_R, i_R, record_text_name)
					imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
					if imgui.InvisibleButton(u8'##Включить радиостанцию'..i_R, imgui.ImVec2(126, 156)) then 
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
				background_record_card(564, 12 + ((start_pos + new_pos) / 2), 5, 'Гоп FM')
				
				background_record_card(12, 176 + ((start_pos + new_pos) / 2), 6, 'Руки Вверх')
				background_record_card(150, 176 + ((start_pos + new_pos) / 2), 7, 'Dupstep')
				background_record_card(288, 176 + ((start_pos + new_pos) / 2), 8, 'Big Hits')
				background_record_card(426, 176 + ((start_pos + new_pos) / 2), 9, 'Organic')
				background_record_card(564, 176 + ((start_pos + new_pos) / 2), 10, 'Russian Hits')
				
				imgui.EndChild()
			elseif select_music == 4 then
				imgui.SetCursorPos(imgui.ImVec2(162, 65))
				imgui.BeginChild(u8'Другие радио', imgui.ImVec2(702, 340 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				local function background_radio_card(posX_R, posY_R, i_R, radiost_name)
					imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
					if imgui.InvisibleButton(u8'##Включить другую радиостанцию'..i_R, imgui.ImVec2(126, 156)) then 
						selectis = 0
						select_record = 0
						menu_play_track = {false, false, false, true}
						if select_radio ~= i_R then
							select_radio = i_R
							artist = ''
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
				
				background_radio_card(12, 12 + ((start_pos + new_pos) / 2), 1, 'Армія FM')
				background_radio_card(150, 12 + ((start_pos + new_pos) / 2), 2, 'Байрактар')
				background_radio_card(288, 12 + ((start_pos + new_pos) / 2), 3, 'Наше Радіо')
				background_radio_card(426, 12 + ((start_pos + new_pos) / 2), 4, 'HitFm')
				background_radio_card(564, 12 + ((start_pos + new_pos) / 2), 5, 'MelodiaFm')
				
				background_radio_card(12, 176 + ((start_pos + new_pos) / 2), 6, 'Маяк')
				background_radio_card(150, 176 + ((start_pos + new_pos) / 2), 7, 'Наше')
				background_radio_card(288, 176 + ((start_pos + new_pos) / 2), 8, 'LoFi Hip-Hop')
				background_radio_card(426, 176 + ((start_pos + new_pos) / 2), 9, 'Максимум')
				background_radio_card(564, 176 + ((start_pos + new_pos) / 2), 10, '90s Eurodance')
				
				imgui.EndChild()
			end
			
		----> [9] РП зона
		elseif select_main_menu[9] then
			menu_draw_up(u8'РП зона')
			rp_zona_win()
			
		
		----> [11] Лекционная
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
			
			menu_draw_up(u8'Лекционная')
			
			imgui.PushFont(fa_font[1])
			imgui.SetCursorPos(imgui.ImVec2(632, 11))
			imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 4)
			if imgui.Button(u8'##Добавить лекцию', imgui.ImVec2(202, 22)) then
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
			imgui.Text(u8'Добавить новую лекцию')
			imgui.PopStyleColor(1)
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			
			imgui.BeginChild(u8'Лекционная', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			if #setting.lec == 0 then
				imgui.PushFont(bold_font[4])
				imgui.SetCursorPos(imgui.ImVec2(154, 187 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Нет ни одной лекции')
				imgui.PopFont()
			else
				new_draw(17, -1 + (#setting.lec * 68))
				imgui.PushFont(font[1])
				local remove_lec
				for i = 1, #setting.lec do
					imgui.SetCursorPos(imgui.ImVec2(0, 17 + ( (i - 1) * 68)))
					if imgui.InvisibleButton(u8'##Перейти в редактор лекции'..i, imgui.ImVec2(666, 68)) then 
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
			
			if menu_draw_up(u8'Редактирование лекции', true) then
				imgui.OpenPopup(u8'Дальнейшие действия с лекцией')
				lec_err_nm = false
				lec_err_fact = false
			end
			if imgui.BeginPopupModal(u8'Дальнейшие действия с лекцией', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.BeginChild(u8'Действие с лекцией', imgui.ImVec2(400, 200), false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				if imgui.InvisibleButton(u8'##Закрыть окошко лекции', imgui.ImVec2(20, 20)) then
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
					imgui.Text(u8'Выберите действие')
				elseif not lec_err_fact then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(63, 95))
					imgui.Text(u8'Такая команда уже существует!')
					imgui.PopFont()
				elseif not lec_err_nm then
					imgui.SetCursorPos(imgui.ImVec2(127, 39))
					imgui.TextColored(imgui.ImVec4(1.00, 0.33, 0.27, 1.00), u8'ОШИБКА')
					
					imgui.PushFont(font[4])
					imgui.SetCursorPos(imgui.ImVec2(126, 95))
					imgui.Text(u8'Задайте команду!')
					imgui.PopFont()
				end
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Сохранить##команду', 10, 167, 123, 25, function()
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
				skin.Button(u8'Не сохранять', 138, 167, 124, 25, function()
					select_lec = 0
					imgui.CloseCurrentPopup()
				end)
				skin.Button(u8'Удалить', 267, 167, 123, 25, function()
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
				imgui.BeginChild(u8'Редактирование лекции', imgui.ImVec2(700, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				
				new_draw(17, 50)
				imgui.PushFont(font[1])
				skin.InputText(114, 31, u8'Установите команду', 'lec_buf.cmd', 15, 553, '[%a%d+-]+')
				if lec_buf.cmd:find('%A+') then
					local characters_to_remove = {
						'Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ', 'Ф', 'Ы', 'В', 'А',
						'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю',
						'Ё', 'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ф', 'ы', 'в',
						'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю'
					}
					local remove_pattern = '[' .. table.concat(characters_to_remove, '') .. ']'
					lec_buf.cmd = string.gsub(lec_buf.cmd, remove_pattern, '')
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 34))
				imgui.Text(u8'Команда   /')
				
				
				new_draw(79, 44)
				imgui.SetCursorPos(imgui.ImVec2(35, 91))
				imgui.Text(u8'Задержка проигрывания отыгровки')
				skin.Slider('##Задержка проигрывания отыгровки лекции', 'lec_buf.wait', 400, 10000, 205, {470, 90}, nil)
				imgui.SetCursorPos(imgui.ImVec2(417, 89))
				imgui.Text(round(lec_buf.wait / 1000, 0.1)..u8' сек.')
				
				new_draw(135, 53 + (#lec_buf.q * 40))
				if #lec_buf.q ~= 0 then
					local remove_table_qq
					for i = 1, #lec_buf.q do
						skin.InputText(30, 149 + ((i - 1) * 40), u8'Введите отыгровку##'..i, 'lec_buf.q.'..i, 1024, 595)
						
						imgui.SetCursorPos(imgui.ImVec2(647, 148 + ((i - 1) * 40)))
						if imgui.InvisibleButton(u8'##Удалить отыгровку'..i, imgui.ImVec2(22, 22)) then remove_table_qq = i end
						imgui.PushFont(fa_font[1])
						imgui.SetCursorPos(imgui.ImVec2(651, 153 + ((i - 1) * 40)))
						imgui.Text(fa.ICON_TRASH)
						imgui.PopFont()
					end
					if remove_table_qq ~= nil then table.remove(lec_buf.q, remove_table_qq) end
				end
				skin.Button(u8'Добавить отыгровку', 242, 149 + (#lec_buf.q * 40), 173, 25, function() table.insert(lec_buf.q, '') end)
				imgui.PopFont()
				
				imgui.Dummy(imgui.ImVec2(0, 29))
				imgui.EndChild()
			end
			
		----> [10] Помощь
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
			
			menu_draw_up(u8'Помощь')
			
			if #setting.tickets == 0 then
				imgui.SetCursorPos(imgui.ImVec2(180, 41))
				imgui.BeginChild(u8'Помощь', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
				imgui.PushFont(font[4])
				imgui.SetCursorPos(imgui.ImVec2(39, 156 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'Здесь Вы можете задать вопрос службе поддержки скрипта, чтобы')
				imgui.SetCursorPos(imgui.ImVec2(55, 186 + ((start_pos + new_pos) / 2)))
				imgui.Text(u8'рассказать о проблеме, сообщить о баге или предложить идею!')
				imgui.PopFont()
				imgui.PushFont(font[1])
				skin.Button(u8'Связаться с поддержкой', 240, 223 + ((start_pos + new_pos) / 2), 185, 35, function()
					local new_ticket = {
						--team = u8'Вопрос '..(#setting.tickets + 1),
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
				imgui.BeginChild(u8'Диалог общения', imgui.ImVec2(682, 280 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
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
							imgui.TextColoredRGB('{7F7F7F}Поддержка')
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
					imgui.TextColoredRGB('{7F7F7F}Все сообщения в этом чате шифруются. Никто, кроме Вас и службы поддержки, их не увидит.')
					imgui.SetCursorPos(imgui.ImVec2(45, 130 + ( (start_pos + new_pos) / 2 )))
					imgui.TextColoredRGB('{7F7F7F} Однако, несмотря на это, мы крайне не рекомендуем отправлять свои личные данные:')
					imgui.SetCursorPos(imgui.ImVec2(163, 150 + ( (start_pos + new_pos) / 2 )))
					imgui.TextColoredRGB('{7F7F7F}пароли, IP-адрес, секретные коды и тому подобное.')
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
				imgui.InputTextMultiline('##Окно ввода текста сообщения', text_multiline, imgui.ImVec2(649, 67), imgui.InputTextFlags.EnterReturnsTrue)
				imgui.PopStyleColor()
				if text_multiline.v == '' and not imgui.IsItemActive() then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.60))
					imgui.SetCursorPos(imgui.ImVec2(203, 337 + start_pos + new_pos))
					imgui.Text(u8'Вводите текст Вашего сообщения')
					imgui.PopStyleColor()
				end
				setting.tickets[1].bool_text = text_multiline.v
				
				if setting.tickets[1].time <= 0 then
					skin.Button(u8'Отправить', 190, 420 + start_pos + new_pos, 646, 35, function()
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
					skin.Button(u8'Отправить снова можно через '.. tostring(setting.tickets[1].time) .. u8' сек.##false_non', 190, 420 + start_pos + new_pos, 646, 35, function() end)
				end
				imgui.PopFont()
				
			end
			imgui.Dummy(imgui.ImVec2(0, 24))
		
		----> [12] История чата
		elseif select_main_menu[12] then
			
			menu_draw_up(u8'История чата')
			history_chats()
			
		----> [13] Действия
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
			
			menu_draw_up(u8'Быстрые действия')
			imgui.SetCursorPos(imgui.ImVec2(180, 41))
			imgui.BeginChild(u8'Быстрые действия', imgui.ImVec2(682, 422 + start_pos + new_pos), false, (size_win and imgui.WindowFlags.NoMove or 0))
			
			new_draw(17, 68)
			imgui.SetCursorPos(imgui.ImVec2(622, 30))
			if skin.Switch(u8'##Сохранять настройки', setting.fast_action_save) then setting.fast_action_save = not setting.fast_action_save save('setting') end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 31))
			imgui.Text(u8'Сохранять настройки выбранных пунктов')
			imgui.PopFont()
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(17, 53))
			imgui.TextColored(imgui.ImVec4(col_end.text, col_end.text, col_end.text, 0.50), u8'Если не хотите, чтобы выбранные пункты сохранялись - отключите эту функцию.')
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(254, 106))
			imgui.Text(u8'Действия с чатом')
			imgui.PopFont()
			
			new_draw(135, 140)
			imgui.SetCursorPos(imgui.ImVec2(622, 148))
			if skin.Switch(u8'##Отключить сообщения кроме рп', setting.fast_chat[1]) then 
				setting.fast_chat[1] = not setting.fast_chat[1]
				if setting.fast_action_save then 
					save('setting')
				end
			end
			imgui.PushFont(font[1])
			imgui.SetCursorPos(imgui.ImVec2(17, 149))
			imgui.Text(u8'Отключить все сообщения в чате, кроме РП действий и диалогов')
			
			imgui.SetCursorPos(imgui.ImVec2(622, 178))
			if skin.Switch(u8'##Отключить рп действия и диалоги от других игроков', setting.fast_chat[2]) then 
				setting.fast_chat[2] = not setting.fast_chat[2]
				if setting.fast_action_save then 
					save('setting')
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(17, 179))
			imgui.Text(u8'Отключить РП действия и диалоги в чате от других игроков')
			
			skin.Button(u8'Очистить чат', 17, 220, 633, nil, function() 
				for qua = 1, 50 do
					sampAddChatMessage('', 0xFFFFFF)
				end
			end)
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(252, 296))
			imgui.Text(u8'Действия с миром')
			imgui.PopFont()
			
			new_draw(325, 216)
			
			imgui.PushFont(font[1])
			skin.Button(u8'Отключить/Включить показ ников игроков', 17, 345, 633, nil, function() 
				setting.off_nick = not setting.off_nick
				sampSendChat('/settings')
				nickname_dialog = true
				time_dialog_nickname = 0
				if setting.fast_action_save then 
					save('setting')
				end
			end)
			
			skin.Button(u8'Узнать дистанцую до серверной метки на карте', 17, 392, 633, nil, function() 
				local my_int = getActiveInterior()
				if my_int == 0 then
					local bool_result, pos_X, pos_Y, pos_Z = getTargetServerCoordinates()
					if bool_result then
						local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
						local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
						sampAddChatMessage(script_tag..'{f7c52f}Расстояние от Вас до метки: '..removeDecimalPart(distance)..' м.', color_tag)
					else
						sampAddChatMessage(script_tag..'{f7c52f}Невозможно определить дистанцию, так как отсутствует метка.', color_tag)
					end
				else
					sampAddChatMessage(script_tag..'{f7c52f}Невозможно определить дистанцию, так как Вы находитесь в интерьере.', color_tag)
				end
			end)
			skin.Button(u8'Узнать дистанцую до собственной метки на карте', 17, 439, 633, nil, function() 
				local my_int = getActiveInterior()
				if my_int == 0 then
					local bool_result, pos_X, pos_Y, pos_Z = getTargetBlipCoordinates()
					if bool_result then
						local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
						local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
						sampAddChatMessage(script_tag..'{f7c52f}Расстояние от Вас до метки: '..removeDecimalPart(distance)..' м.', color_tag)
					else
						sampAddChatMessage(script_tag..'{f7c52f}Невозможно определить дистанцию, так как отсутствует метка.', color_tag)
					end
				else
					sampAddChatMessage(script_tag..'{f7c52f}Невозможно определить дистанцию, так как Вы находитесь в интерьере.', color_tag)
				end
			end)
			skin.Button(u8'Закрыть соединение с сервером', 17, 486, 633, nil, function() 
				сlose_сonnect()
			end)
			imgui.PopFont()
			
			imgui.PushFont(bold_font[3])
			imgui.SetCursorPos(imgui.ImVec2(234, 562))
			imgui.Text(u8'Действия со скриптом')
			imgui.PopFont()
			
			new_draw(591, 169)
			imgui.PushFont(font[1])
			skin.Button(u8'Перезагрузить скрипт', 17, 611, 633, nil, function() 
				showCursor(false)
				scr:reload()
			end)
			
			skin.Button(u8'Сбросить все настройки скрипта', 17, 658, 633, nil, function() 
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
					sampAddChatMessage(script_tag..'{FFFFFF}Настройки сброшены. Перезагрузка скрипта...', color_tag)
					deletedir(dirml..'/StateHelper/')
					showCursor(false)
					scr:reload()
				end
			end)
			skin.Button(u8'Удалить скрипт', 17, 705, 633, nil, function() 
				script_ac.del = script_ac.del + 1
				if script_ac.del > 1 then
					sampAddChatMessage(script_tag..'{FFFFFF}Скрипт удалён! Вы всегда можете скачать его снова на сайте BlastHack.', color_tag)
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
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50 ,1.00), u8'Доступ заблокирован')
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
		imgui.SetNextWindowSize(imgui.ImVec2(278, 165 + ((#setting.fast_acc.sl - 1) * 35)), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(setting.pos_act.x, setting.pos_act.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Choice Window', win.action_choice.v, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		skin.DrawFond({4, 4}, {0, 0}, {270, 161 + ((#setting.fast_acc.sl - 1) * 35)}, imgui.ImVec4(col_end.fond_two[1], col_end.fond_two[2], col_end.fond_two[3], 1.00), 15, 15)
		local bool_pos_act = imgui.GetWindowPos()
		local bool_upd_pos = {x = bool_pos_act.x + 139, y = bool_pos_act.y + ((165 + ((#setting.fast_acc.sl - 1) * 35)) / 2)}
		if not imgui.IsMouseDown(0) then
			if bool_upd_pos.x ~= setting.pos_act.x or bool_upd_pos.y ~= setting.pos_act.y then
				setting.pos_act = {x = bool_upd_pos.x, y = bool_upd_pos.y}
				save('setting')
			end
		end
		
		imgui.PushFont(font[4])
		local calc = imgui.CalcTextSize(flies_nick..' ['..flies_id..']')
		imgui.SetCursorPos(imgui.ImVec2(130 - calc.x / 2, 4))
		local p = imgui.GetCursorScreenPos()
		if setting.int.theme == 'White' then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 18, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2(139 - calc.x / 2, 9))
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), flies_nick..' ['..flies_id..']')
		else
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 18, p.y + 35), imgui.GetColorU32(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 13, 12)
			imgui.SetCursorPos(imgui.ImVec2(139 - calc.x / 2, 9))
			imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00, 1.00), flies_nick..' ['..flies_id..']')
		end
		imgui.PopFont()
		
		imgui.PushFont(font[1])
		for i = 1, #setting.fast_acc.sl do
			local bool_cmd = true
			for k = 1, #setting.cmd do
				if setting.cmd[k][1] == setting.fast_acc.sl[i].cmd then
					if tonumber(setting.frac.rank) < tonumber(setting.cmd[k][4]) then
						bool_cmd = false
					end
					break
				end
			end
			
			if bool_cmd then
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i, 9, 60 + ((i - 1) * 35), 260, 30, function()
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
				skin.Button(setting.fast_acc.sl[i].text..'##ch_text'..i..'##false_non', 9, 60 + ((i - 1) * 35), 260, 30, function() end)
				imgui.PushFont(fa_font[1])
				imgui.SetCursorPos(imgui.ImVec2(250, 70 + ((i - 1) * 35)))
				imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 1.00), fa.ICON_LOCK)
				imgui.PopFont()
			end
		end
		
		skin.Button(u8'Отменить', 9, 80 + (#setting.fast_acc.sl * 35), 260, 35, function()
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
	if imgui.InvisibleButton(u8'##Закрыть окно шпоры', imgui.ImVec2(20, 20))  then
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
	if skin.Slider('##Размер текста', 'spur_text_size', 0, 4, 130, {50, 11}) then end
	imgui.PopFont()
	
	local text_spur_table = {}
	for line in text_spur:gmatch('[^\n]*\n?') do
		table.insert(text_spur_table, line:match('^(.-)\n?$'))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 50))
	imgui.BeginChild(u8'Текст шпаргалки', imgui.ImVec2(879, 603), false)
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
	if imgui.InvisibleButton(u8'##Закрыть окно напоминания', imgui.ImVec2(20, 20))  then
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
		sampAddChatMessage(script_tag..'{FFFFFF} Такой шпаргалки не существует. Всего их '..#setting.shpora, color_tag)
		return
	elseif spur_number <= 0 then
		sampAddChatMessage(script_tag..'{FFFFFF} Отсчёт шпаргалок начинается с единицы!', color_tag)
		return
	end
	
	if doesFileExist(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[spur_number][1]..'.txt') then
		sel_big_spur = spur_number
		local f = io.open(dirml..'/StateHelper/Шпаргалки/'..setting.shpora[spur_number][1]..'.txt')
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
			local weekdays = {u8'Воскресенье', u8'Понедельник', u8'Вторник', u8'Среда', u8'Четверг', u8'Пятница', u8'Суббота'}
			local months = {u8'січня', u8'лютого', u8'березня', u8'квітня', u8'травня', u8'червня', u8'липня', u8'серпня', u8'вересня', u8'жовтня' , u8'листопада', u8'грудня'}

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
			imgui.Text(u8'Чистый за день: '.. u8(print_time(setting.online_stat.clean[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.afk_on_day then
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'АФК за день: '.. u8(print_time(setting.online_stat.afk[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.all_on_day then
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'Всего за день: '.. u8(print_time(setting.online_stat.all[1])))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.clean_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'Чистый за сессию: '.. u8(print_time(session_clean.v)))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.afk_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'АФК за сессию: '.. u8(print_time(session_afk.v)))
			pos_win_elements = pos_win_elements + 23
		end
		if setting.stat_on_members.all_on_session then 
			imgui.SetCursorPos(imgui.ImVec2(22, pos_win_elements))
			imgui.Text(u8'Всего за сессию: '.. u8(print_time(session_all.v)))
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
	
	colors[clr.FrameBg] 			 = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Чекбокс
	colors[clr.FrameBgHovered]       = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Чекбокс
	colors[clr.FrameBgActive]        = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- Чекбокс
	colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.TitleBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 0.31)
	colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.SliderGrabActive]     = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.Button]               = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Кнопка
	colors[clr.ButtonHovered]        = ImVec4(setting.col_acc_non[1], setting.col_acc_non[2], setting.col_acc_non[3], 1.00) -- Кнопка
	colors[clr.ButtonActive]         = ImVec4(setting.col_acc_act[1], setting.col_acc_act[2], setting.col_acc_act[3], 1.00) -- Кнопка
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
	colors[clr.Text]                 = ImVec4(col_end.text, col_end.text, col_end.text, 1.00) -- Текст
	colors[clr.TextDisabled]         = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.08, 0.08, 0.08, 0.00)
	colors[clr.ChildWindowBg]        = ImVec4(1.00, 1.00, 1.00, 0.00)
	if setting.int.theme == 'White' then
		colors[clr.PopupBg]          = ImVec4(0.80, 0.80, 0.80, 1.00) -- Окно
	else
		colors[clr.PopupBg]          = ImVec4(0.10, 0.10, 0.10, 1.00) -- Окно
	end
	colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.26, 0.59, 0.98, 0.00)
	colors[clr.MenuBarBg]            = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.00, 0.00, 0.00, 0.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00) -- Пролистывающая дрянь
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00) -- Пролистывающая дрянь
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

--> Сохранение
function save(table_name)
	if table_name == 'setting' then
		local f = io.open(dirml..'/StateHelper/Настройки.json', 'w')
		f:write(encodeJson(setting))
		f:flush()
		f:close()
	elseif table_name == 'save_tracks' then
		local f = io.open(dirml..'/StateHelper/Треки.json', 'w')
		f:write(encodeJson(save_tracks))
		f:flush()
		f:close()
	elseif table_name == 'scene' then
		local f = io.open(dirml..'/StateHelper/Сцены.json', 'w')
		f:write(encodeJson(scene))
		f:flush()
		f:close()
	end
end

--[[
	0 - Отправить в чат
	1 - Ожидание нажатия Enter
	2 - Вывести инфо в чат
	3 - Диалог выбора действия
	4 - Комментарий
	5 - Изменить переменную
	6 - Если переменная равна
	7 - Завершить условие переменной
	8 - Если выбран вариант диалога
	9 - Завершить диалог
]]
			
function cmd_start(arg_c, command_active)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}Page Down{FFFFFF}, чтобы остановить её.', color_tag)
		return
	end
	
	local f = io.open(dirml..'/StateHelper/Отыгровки/'..command_active..'.json')
	local setm = f:read('*a')
	f:close()
	local res, set = pcall(decodeJson, setm)
	if res and type(set) == 'table' then 
		cmds = set
	end
	
	if tonumber(setting.frac.rank) < tonumber(cmds.rank) then
		sampAddChatMessage(script_tag..'{FFFFFF}Данная команда доступна с '..cmds.rank..' ранга!', color_tag)
		return
	end
	
	local args = {}
	if #cmds.arg ~= 0 then
		local function invalid_arguments()
			local tbl_ar = {}
			for ar = 1, #cmds.arg do
				table.insert(tbl_ar, '['..u8:decode(cmds.arg[ar][2])..']')
			end
			sampAddChatMessage(script_tag..'{FFFFFF}Используйте {a8a8a8}/'..command_active..' '..table.concat(tbl_ar, ' '), color_tag)
			show_cef_notify('error', script_tag, "Проверьте правильность команды", 5000)
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
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', color_tag)
				return ''
			end
			if tonumber(num_id_term) >= 0 and tonumber(num_id_term) <= 3 then
				num_give_lic_term = tonumber(num_id_term)
			else
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', color_tag)
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
				sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoggov} имеет неверное значение.', color_tag)
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
					sampAddChatMessage(script_tag..'{FFFFFF}Нажмите на {23E64A}End{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить отыгровку.', color_tag)
					addOneOffSound(0, 0, 0, 1058)
					new_notice('wait', {u8'End - продолжить отыгровку', u8'Page Down - остановить'})
					while true do wait(0)
						if isKeyJustPressed(VK_END) and not sampIsChatInputActive() and not sampIsDialogActive() then new_notice('off') break end
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

function get_city()
    local city = {
        [0] = "Вне города",
        [1] = "Лос Сантос",
        [2] = "Сан Фиерро",
        [3] = "Лас Вентурас"
    }
    return city[getCityPlayerIsIn(PLAYER_PED)]
end

function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * -1 + 3000) / 250)
    Y = KV[Y]
    if Y ~= nil then
        local KVX = (Y.."-"..X)
        return KVX
    else
        return X
    end
end

function get_square()
    return kvadrat()
end

function calculateZoneRu(x, y, z)
    local streets = {
        {"Клуб Ависпа", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
        {"Аэропорт", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
        {"Клуб Ависпа", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
        {"Аэропорт", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
        {"Гарсия", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
        {"Шейди-Кэбин", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
        {"Восточный ЛС", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
        {"Грузовое депо", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
        {"Пересечение Блэкфилд", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
        {"Клуб Ависпа", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
        {"Темпл", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
        {"Станция Юнити", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
        {"Грузовое депо ЛВ", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
        {"Лос-Флорес", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
        {"Казино", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
        {"Химзавод Истер-Бэй", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
        {"Деловой район", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
        {"Восточная Эспаланда", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
        {"Станция Маркет", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
        {"Станция Линден", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
        {"Пересечение Монтгомери", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
        {"Мост Фредерик", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
        {"Станция Йеллоу-Белл", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
        {"Деловой район", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
        {"Джефферсон", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
        {"Малхолланд", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
        {"Клуб Ависпа", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
        {"Джефферсон", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
        {"Западаное шоссе", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
        {"Джефферсон", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
        {"Северное шоссе", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
        {"Родео", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
        {"Станция Крэнберри", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
        {"Деловой район", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
        {"Западный Рэдсэндс", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
        {"Маленькая Мексика", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
        {"Пересечение Блэкфилд", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
        {"Аэропорт", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
        {"Бекон-Хилл", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
        {"Родео", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
        {"Ричман", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
        {"Деловой район", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
        {"Стрип-клуб", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
        {"Деловой район", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
        {"Пересечение Блэкфилд", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
        {"Конференц Центр", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
        {"Монтгомери", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
        {"Долина Фостер", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
        {"Часовня Блэкфилд", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
        {"Аэропорт", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
        {"Малхолланд", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
        {"Поле для гольфа", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
        {"Стрип", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
        {"Джефферсон", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
        {"Малхолланд", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
        {"Альдеа-Мальвада", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
        {"Лас-Колинас", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
        {"Лас-Колинас", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
        {"Ричман", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
        {"Грузовое депо", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
        {"Северное шоссе", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
        {"Уиллоуфилд", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
        {"Северное шоссе", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
        {"Темпл", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
        {"Маленькая Мексика", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
        {"Квинс", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
        {"Аэропорт", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
        {"Ричман", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
        {"Темпл", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
        {"Восточный ЛС", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
        {"Воссточное шоссе", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
        {"Уиллоуфилд", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
        {"Лас-Колинас", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
        {"Воссточное шоссе", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
        {"Родео", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
        {"Лас-Брухас", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
        {"Воссточное шоссе", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
        {"Родео", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
        {"Вайнвуд", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
        {"Родео", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
        {"Северное шоссе", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
        {"Деловой район", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
        {"Родео", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
        {"Джефферсон", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
        {"Хэмптон-Барнс", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
        {"Темпл", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
        {"Мост Кинкейд", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
        {"Пляж Верона", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
        {"Коммерческий район", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
        {"Малхолланд", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
        {"Родео", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
        {"Малхолланд", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
        {"Малхолланд", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
        {"Южное шоссе", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
        {"Айдлвуд", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
        {"Океанские доки", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
        {"Коммерческий район", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
        {"Северное шоссе", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
        {"Темпл", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
        {"Глен Парк", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
        {"Аэропорт Истер-Бэй", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
        {"Мост Мартин", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
        {"Стрип", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
        {"Уиллоуфилд", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
        {"Канал Марина", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
        {"Аэропорт", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
        {"Айдлвуд", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
        {"Восточная Эспаланда", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
        {"Деловой район", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
        {"Мост Мако", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
        {"Родео", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
        {"Площадь Першинг", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
        {"Малхолланд", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
        {"Мост Гант", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
        {"Лас-Колинас", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
        {"Малхолланд", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
        {"Северное шоссе", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
        {"Коммерческий район", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
        {"Родео", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
        {"Рока-Эскаланте", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
        {"Родео", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
        {"Центральный Рынок", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
        {"Лас-Колинас", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
        {"Малхолланд", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
        {"Кингс", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
        {"Восточный Рэдсэндс", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
        {"Деловой район", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
        {"Конференц Центр", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
        {"Ричман", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
        {"Оушен-Флэтс", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
        {"Колледж Грингласс", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
        {"Глен Парк", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
        {"Грузовое депо", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
        {"Регьюлар-Том", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
        {"Пляж Верона", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
        {"Восточный ЛС", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
        {"Дворец Калигулы", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
        {"Айдлвуд", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
        {"Пилигрим", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
        {"Айдлвуд", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
        {"Квинс", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
        {"Деловой район", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
        {"Коммерческий район", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
        {"Восточный ЛС", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
        {"Канал Марина", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
        {"Ричман", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
        {"Вайнвуд", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
        {"Восточный ЛС", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
        {"Родео", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
        {"Истерский Тоннель", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
        {"Родео", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
        {"Восточный Рэдсэндс", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
        {"Казино", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
        {"Айдлвуд", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
        {"Пересечение Монтгомери", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
        {"Уиллоуфилд", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
        {"Темпл", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
        {"Прикл-Пайн", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
        {"Аэропорт", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
        {"Мост Гарвер", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
        {"Мост Гарвер", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
        {"Мост Кинкейд", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
        {"Мост Кинкейд", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
        {"Пляж Верона", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
        {"Обсерватория", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
        {"Гора Вайнвуд", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
        {"Гора Вайнвуд", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
        {"Коммерческий район", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
        {"Центральный Рынок", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
        {"Западный Рокшор", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
        {"Северное шоссе", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
        {"Восточный пляж", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
        {"Мост Фаллоу", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
        {"Уиллоуфилд", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
        {"Чайнатаун", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
        {"Скалистый массив", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
        {"Океанские доки", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
        {"Химзавод Истер-Бэй", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
        {"Казино Визаж", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
        {"Оушен-Флэтс", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
        {"Ричман", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
        {"Нефтяной комплекс", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
        {"Ричман", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
        {"Казино", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
        {"Восточный пляж", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
        {"Джефферсон", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
        {"Деловой район", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
        {"Деловой район", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
        {"Мост Гарвер", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
        {"Южное шоссе", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
        {"Восточный ЛС", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
        {"Колледж Грингласс", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
        {"Лас-Колинас", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
        {"Малхолланд", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
        {"Океанские доки", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
        {"Восточный ЛС", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
        {"Гантон", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
        {"Клуб Ависпа", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
        {"Уиллоуфилд", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
        {"Северная Эспланада", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
        {"Казино Хай-Роллер", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
        {"Океанские доки", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
        {"Мотель", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
        {"Бэйсайнд-Марина", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
        {"Кингс", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
        {"Эль-Корона", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
        {"Часовня Блэкфилд", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
        {"Розовый лебедь", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
        {"Западное шоссе", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
        {"Лос-Флорес", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
        {"Казино Визаж", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
        {"Прикл-Пайн", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
        {"Пляж Верона", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
        {"Пересечение Робада", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
        {"Линден-Сайд", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
        {"Океанские доки", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
        {"Уиллоуфилд", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
        {"Кингс", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
        {"Коммерческий район", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
        {"Малхолланд", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
        {"Канал Марина", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
        {"Бэттери-Пойнт", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
        {"Казино 4 Дракона", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
        {"Блэкфилд", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
        {"Северное шоссе", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
        {"Поле для гольфа", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
        {"Айдлвуд", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
        {"Западный Рэдсэндс", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
        {"Доэрти", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
        {"Ферма Хиллтоп", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
        {"Лас-Барранкас", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
        {"Казино Пираты", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
        {"Сити Холл", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
        {"Клуб Ависпа", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
        {"Стрип", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
        {"Хашбери", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
        {"Аэропорт", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
        {"Уайтвуд-Истейтс", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
        {"Водохранилище", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
        {"Эль-Корона", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
        {"Деловой район", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
        {"Долина Фостер", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
        {"Лас-Паясадас", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
        {"Долина Окультадо", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
        {"Пересечение Блэкфилд", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
        {"Гантон", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
        {"Аэропорт Истер-Бэй", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
        {"Восточный Рэдсэндс", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
        {"Восточная Эспаланда", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
        {"Дворец Калигулы", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
        {"Казино Рояль", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
        {"Ричман", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
        {"Казино", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
        {"Малхолланд", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
        {"Деловой район", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
        {"Ханки-Панки-Пойнт", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
        {"Военный склад топлива", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
        {"Шоссе Гарри-Голд", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
        {"Тоннель Бэйсайд", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
        {"Океанские доки", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
        {"Ричман", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
        {"Промсклад Рэндольфа", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
        {"Восточный пляж", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
        {"Флинт-Уотер", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
        {"Блуберри", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
        {"Станция Линден", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
        {"Глен Парк", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
        {"Деловой район", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
        {"Западный Рэдсэндс", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
        {"Ричман", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
        {"Мост Гант", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
        {"Бар Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
        {"Пересечение Флинт", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
        {"Лас-Колинас", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
        {"Собелл-Рейл-Ярдс", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
        {"Изумрудный остров", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
        {"Скалистый массив", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
        {"Санта-Флора", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
        {"Плайя-дель-Севиль", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
        {"Центральный Рынок", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
        {"Квинс", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
        {"Пересечение Пилсон", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
        {"Спинибед", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
        {"Пилигрим", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
        {"Блэкфилд", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
        {"Большое ухо", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
        {"Диллимор", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
        {"Эль-Кебрадос", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
        {"Северная Эспланада", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
        {"Аэропорт Истер-Бэй", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
        {"Рыбацкая лагуна", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
        {"Малхолланд", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
        {"Восточный пляж", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
        {"Сан-Андреас Саунд", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
        {"Тенистые ручьи", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
        {"Центральный Рынок", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
        {"Западный Рокшор", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
        {"Прикл-Пайн", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
        {"Бухта Пасхи", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
        {"Лифи-Холлоу", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
        {"Грузовое депо", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
        {"Прикл-Пайн", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
        {"Блуберри", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
        {"Скалистый массив", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
        {"Деловой район", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
        {"Восточный Рокшор", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
        {"Залив Сан-Фиерро", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
        {"Парадизо", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
        {"Казино", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
        {"Олд-Вентурас-Стрип", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
        {"Джанипер-Хилл", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
        {"Джанипер-Холлоу", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
        {"Рока-Эскаланте", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
        {"Воссточное шоссе", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
        {"Пляж Верона", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
        {"Долина Фостер", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
        {"Арко-дель-Оэсте", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
        {"Упавшее дерево", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
        {"Ферма", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
        {"Дамба Шермана", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
        {"Северная Эспланада", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
        {"Финансовый район", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
        {"Гарсия", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
        {"Монтгомери", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
        {"Крик", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
        {"Аэропорт", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
        {"Пляж Санта-Мария", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
        {"Пересечение Малхолланд", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
        {"Эйнджел-Пайн", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
        {"Заброшеный Аэропорт", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
        {"Октан-Спрингс", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
        {"Казино Кам-э-Лот", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
        {"Западный Рэдсэндс", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
        {"Пляж Санта-Мария", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
        {"Обсерватория", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
        {"Аэропорт Лас Вентурас", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
        {"Округ Флинт", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
        {"Обсерватория", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
        {"Паломино Крик", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
        {"Океанские доки", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
        {"Аэропорт Истер-Бэй", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
        {"Уайтвуд-Истейтс", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
        {"Калтон-Хайтс", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
        {"Бухта Пасхи", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
        {"Залив ЛС", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
        {"Доэрти", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
        {"Гора Чилиад", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
        {"Форт-Карсон", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
        {"Долина Фостер", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
        {"Оушен-Флэтс", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
        {"Ферн-Ридж", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
        {"Бэйсайд", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
        {"Аэропорт", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
        {"Поместье Блуберри", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
        {"Пэлисейдс", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
        {"Норт-Рок", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
        {"Карьер Хантер", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
        {"Аэропорт", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
        {"Миссионер-Хилл", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
        {"Залив СФ", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
        {"Тюрьма Строгого Режима", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
        {"Гора Чилиад", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
        {"Гора Чилиад", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
        {"Аэропорт Истер-Бэй", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
        {"Паноптикум", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
        {"Тенистые ручьи", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
        {"Бэк-о-Бейонд", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
        {"Гора Чилиад", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
        {"Тьерра Робада", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
        {"Округ Флинт", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
        {"Уэтстоун", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
        {"Пустынный округ", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
        {"Тьерра Робада", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
        {"Окружность СФ", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
        {"Окружность ЛВ", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
        {"Туманный округ", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
        {"Окружность ЛС", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}
    }
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return 'Неизвестно'
end

function get_area()
    local x, y, z = getCharCoordinates(PLAYER_PED)
    return calculateZoneRu(x, y, z)
end

local vehicle_data = {
    {name = "Landstalker", model_id = 400, server_id = 400},
    {name = "Bravura", model_id = 401, server_id = 401},
    {name = "Buffalo", model_id = 402, server_id = 402},
    {name = "Linerunner", model_id = 403, server_id = 403},
    {name = "Pereniel", model_id = 404, server_id = 404},
	{name = "Sentinel", model_id = 405, server_id = 405},
    {name = "Dumper", model_id = 406, server_id = 406},
    {name = "Firetruck", model_id = 407, server_id = 407},
    {name = "Trashmaster", model_id = 408, server_id = 408},
    {name = "Stretch", model_id = 409, server_id = 409},
    {name = "Manana", model_id = 410, server_id = 410},
    {name = "Infernus", model_id = 411, server_id = 411},
    {name = "Voodoo", model_id = 412, server_id = 412},
    {name = "Pony", model_id = 413, server_id = 413},
    {name = "Mule", model_id = 414, server_id = 414},
    {name = "Cheetah", model_id = 415, server_id = 415},
    {name = "Ambulance", model_id = 416, server_id = 416},
    {name = "Leviathan", model_id = 417, server_id = 417},
    {name = "Moonbeam", model_id = 418, server_id = 418},
    {name = "Esperanto", model_id = 419, server_id = 419},
    {name = "Taxi", model_id = 420, server_id = 420},
    {name = "Washington", model_id = 421, server_id = 421},
    {name = "Bobcat", model_id = 422, server_id = 422},
    {name = "Mr Whoopee", model_id = 423, server_id = 423},
    {name = "BF Injection", model_id = 424, server_id = 424},
    {name = "Hunter", model_id = 425, server_id = 425},
    {name = "Premier", model_id = 426, server_id = 426},
    {name = "Enforcer", model_id = 427, server_id = 427},
    {name = "Securicar", model_id = 428, server_id = 428},
    {name = "Banshee", model_id = 429, server_id = 429},
    {name = "Predator", model_id = 430, server_id = 430},
    {name = "Bus", model_id = 431, server_id = 431},
    {name = "Rhino", model_id = 432, server_id = 432},
    {name = "Barracks", model_id = 433, server_id = 433},
    {name = "Hotknife", model_id = 434, server_id = 434},
    {name = "Trailer", model_id = 435, server_id = 435},
    {name = "Previon", model_id = 436, server_id = 436},
    {name = "Coach", model_id = 437, server_id = 437},
    {name = "Cabbie", model_id = 438, server_id = 438},
    {name = "Stallion", model_id = 439, server_id = 439},
    {name = "Rumpo", model_id = 440, server_id = 440},
    {name = "RC Bandit", model_id = 441, server_id = 441},
	{name = "Romero", model_id = 442, server_id = 442},
    {name = "Packer", model_id = 443, server_id = 443},
    {name = "Monster", model_id = 444, server_id = 444},
    {name = "Admiral", model_id = 445, server_id = 445},
    {name = "Squalo", model_id = 446, server_id = 446},
    {name = "Seasparrow", model_id = 447, server_id = 447},
    {name = "Pizzaboy", model_id = 448, server_id = 448},
    {name = "Tram", model_id = 449, server_id = 449},
    {name = "Trailer", model_id = 450, server_id = 450},
    {name = "Turismo", model_id = 451, server_id = 451},
    {name = "Speeder", model_id = 452, server_id = 452},
    {name = "Reefer", model_id = 453, server_id = 453},
    {name = "Tropic", model_id = 454, server_id = 454},
    {name = "Flatbed", model_id = 455, server_id = 455},
    {name = "Yankee", model_id = 456, server_id = 456},
    {name = "Caddy", model_id = 457, server_id = 457},
    {name = "Solair", model_id = 458, server_id = 458},
    {name = "Berkley's", model_id = 459, server_id = 459},
    {name = "Skimmer", model_id = 460, server_id = 460},
    {name = "PCJ-600", model_id = 461, server_id = 461},
    {name = "Faggio", model_id = 462, server_id = 462},
    {name = "Freeway", model_id = 463, server_id = 463},
    {name = "RC Baron", model_id = 464, server_id = 464},
    {name = "RC Raider", model_id = 465, server_id = 465},
    {name = "Glendale", model_id = 466, server_id = 466},
    {name = "Oceanic", model_id = 467, server_id = 467},
    {name = "Sanchez", model_id = 468, server_id = 468},
    {name = "Sparrow", model_id = 469, server_id = 469},
    {name = "Patriot", model_id = 470, server_id = 470},
    {name = "Quad", model_id = 471, server_id = 471},
    {name = "Coastguard", model_id = 472, server_id = 472},
    {name = "Dinghy", model_id = 473, server_id = 473},
    {name = "Hermes", model_id = 474, server_id = 474},
    {name = "Sabre", model_id = 475, server_id = 475},
    {name = "Rustler", model_id = 476, server_id = 476},
    {name = "ZR-350", model_id = 477, server_id = 477},
    {name = "Walton", model_id = 478, server_id = 478},
    {name = "Regina", model_id = 479, server_id = 479},
    {name = "Comet", model_id = 480, server_id = 480},
    {name = "BMX", model_id = 481, server_id = 481},
    {name = "Burrito", model_id = 482, server_id = 482},
    {name = "Camper", model_id = 483, server_id = 483},
    {name = "Marquis", model_id = 484, server_id = 484},
    {name = "Baggage", model_id = 485, server_id = 485},
    {name = "Dozer", model_id = 486, server_id = 486},
    {name = "Maverick", model_id = 487, server_id = 487},
    {name = "News", model_id = 488, server_id = 488},
    {name = "Rancher", model_id = 489, server_id = 489},
    {name = "FBI Rancher", model_id = 490, server_id = 490},
    {name = "Virgo", model_id = 491, server_id = 491},
    {name = "Greenwood", model_id = 492, server_id = 492},
    {name = "Jetmax", model_id = 493, server_id = 493},
    {name = "Hotring", model_id = 494, server_id = 494},
    {name = "Sandking", model_id = 495, server_id = 495},
    {name = "Blista", model_id = 496, server_id = 496},
    {name = "Police Maverick", model_id = 497, server_id = 497},
    {name = "Boxville", model_id = 498, server_id = 498},
    {name = "Benson", model_id = 499, server_id = 499},
    {name = "Mesa", model_id = 500, server_id = 500},
	{name = "RC Goblin", model_id = 501, server_id = 501},
    {name = "Hotring", model_id = 502, server_id = 502},
    {name = "Hotring", model_id = 503, server_id = 503},
    {name = "Bloodring", model_id = 504, server_id = 504},
    {name = "Rancher", model_id = 505, server_id = 505},
    {name = "Super GT", model_id = 506, server_id = 506},
    {name = "Elegant", model_id = 507, server_id = 507},
    {name = "Journey", model_id = 508, server_id = 508},
    {name = "Bike", model_id = 509, server_id = 509},
    {name = "Mountain", model_id = 510, server_id = 510},
    {name = "Beagle", model_id = 511, server_id = 511},
    {name = "Cropdust", model_id = 512, server_id = 512},
    {name = "Stunt", model_id = 513, server_id = 513},
    {name = "Tanker", model_id = 514, server_id = 514},
    {name = "RoadTrain", model_id = 515, server_id = 515},
    {name = "Nebula", model_id = 516, server_id = 516},
    {name = "Majestic", model_id = 517, server_id = 517},
    {name = "Buccaneer", model_id = 518, server_id = 518},
    {name = "Shamal", model_id = 519, server_id = 519},
    {name = "Hydra", model_id = 520, server_id = 520},
    {name = "FCR-900", model_id = 521, server_id = 521},
    {name = "NRG-500", model_id = 522, server_id = 522},
    {name = "HPV1000", model_id = 523, server_id = 523},
    {name = "Cement", model_id = 524, server_id = 524},
    {name = "Tow", model_id = 525, server_id = 525},
    {name = "Fortune", model_id = 526, server_id = 526},
    {name = "Cadrona", model_id = 527, server_id = 527},
    {name = "FBI Truck", model_id = 528, server_id = 528},
    {name = "Willard", model_id = 529, server_id = 529},
    {name = "Forklift", model_id = 530, server_id = 530},
    {name = "Tractor", model_id = 531, server_id = 531},
    {name = "Combine", model_id = 532, server_id = 532},
    {name = "Feltzer", model_id = 533, server_id = 533},
    {name = "Remington", model_id = 534, server_id = 534},
    {name = "Slamvan", model_id = 535, server_id = 535},
    {name = "Blade", model_id = 536, server_id = 536},
    {name = "Freight", model_id = 537, server_id = 537},
    {name = "Streak", model_id = 538, server_id = 538},
    {name = "Vortex", model_id = 539, server_id = 539},
    {name = "Vincent", model_id = 540, server_id = 540},
    {name = "Bullet", model_id = 541, server_id = 541},
    {name = "Clover", model_id = 542, server_id = 542},
    {name = "Sadler", model_id = 543, server_id = 543},
    {name = "Firetruck", model_id = 544, server_id = 544},
    {name = "Hustler", model_id = 545, server_id = 545},
    {name = "Intruder", model_id = 546, server_id = 546},
    {name = "Primo", model_id = 547, server_id = 547},
    {name = "Cargobob", model_id = 548, server_id = 548},
    {name = "Tampa", model_id = 549, server_id = 549},
    {name = "Sunrise", model_id = 550, server_id = 550},
    {name = "Merit", model_id = 551, server_id = 551},
    {name = "Utility", model_id = 552, server_id = 552},
    {name = "Nevada", model_id = 553, server_id = 553},
    {name = "Yosemite", model_id = 554, server_id = 554},
    {name = "Windsor", model_id = 555, server_id = 555},
    {name = "Monster", model_id = 556, server_id = 556},
    {name = "Monster", model_id = 557, server_id = 557},
    {name = "Uranus", model_id = 558, server_id = 558},
    {name = "Jester", model_id = 559, server_id = 559},
    {name = "Sultan", model_id = 560, server_id = 560},
    {name = "Stratum", model_id = 561, server_id = 561},
    {name = "Elegy", model_id = 562, server_id = 562},
    {name = "Raindance", model_id = 563, server_id = 563},
    {name = "RC Tiger", model_id = 564, server_id = 564},
    {name = "Flash", model_id = 565, server_id = 565},
    {name = "Tahoma", model_id = 566, server_id = 566},
    {name = "Savanna", model_id = 567, server_id = 567},
    {name = "Bandito", model_id = 568, server_id = 568},
    {name = "Freight", model_id = 569, server_id = 569},
    {name = "Trailer", model_id = 570, server_id = 570},
    {name = "Kart", model_id = 571, server_id = 571},
    {name = "Mower", model_id = 572, server_id = 572},
	{name = "Duneride", model_id = 573, server_id = 573},
    {name = "Sweeper", model_id = 574, server_id = 574},
    {name = "Broadway", model_id = 575, server_id = 575},
    {name = "Tornado", model_id = 576, server_id = 576},
    {name = "AT-400", model_id = 577, server_id = 577},
    {name = "DFT-30", model_id = 578, server_id = 578},
    {name = "Huntley", model_id = 579, server_id = 579},
    {name = "Stafford", model_id = 580, server_id = 580},
    {name = "BF-400", model_id = 581, server_id = 581},
    {name = "Newsvan", model_id = 582, server_id = 582},
    {name = "Tug", model_id = 583, server_id = 583},
    {name = "Trailer", model_id = 584, server_id = 584},
    {name = "Emperor", model_id = 585, server_id = 585},
    {name = "Wayfarer", model_id = 586, server_id = 586},
    {name = "Euros", model_id = 587, server_id = 587},
    {name = "Hotdog", model_id = 588, server_id = 588},
    {name = "Club", model_id = 589, server_id = 589},
    {name = "Trailer", model_id = 590, server_id = 590},
    {name = "Trailer", model_id = 591, server_id = 591},
    {name = "Andromada", model_id = 592, server_id = 592},
    {name = "Dodo", model_id = 593, server_id = 593},
    {name = "RC Cam", model_id = 594, server_id = 594},
    {name = "Launch", model_id = 595, server_id = 595},
    {name = "Police LS", model_id = 596, server_id = 596},
    {name = "Police SF", model_id = 597, server_id = 597},
    {name = "Police LV", model_id = 598, server_id = 598},
    {name = "Police Rancher", model_id = 599, server_id = 599},
    {name = "Picador", model_id = 600, server_id = 600},
    {name = "S.W.A.T.", model_id = 601, server_id = 601},
    {name = "Alpha", model_id = 602, server_id = 602},
    {name = "Phoenix", model_id = 603, server_id = 603},
    {name = "Glendale", model_id = 604, server_id = 604},
    {name = "Sadler", model_id = 605, server_id = 605},
    {name = "Luggage", model_id = 606, server_id = 606},
    {name = "Luggage", model_id = 607, server_id = 607},
    {name = "Stair", model_id = 608, server_id = 608},
    {name = "Boxville", model_id = 609, server_id = 609},
    {name = "Farm", model_id = 610, server_id = 610},
    {name = "Utility", model_id = 611, server_id = 611},
    {model_id = 612, name = "Mercedes GT63", server_id = 612},
    {model_id = 613, name = "Mercedes G63AMG", server_id = 613},
    {model_id = 614, name = "Audi RS6", server_id = 614},
    {model_id = 662, name = "BMW X5m", server_id = 615},
    {model_id = 663, name = "Chevrolet Corvette C8 Stingray", server_id = 616},
    {model_id = 665, name = "Chevrolet Cruze", server_id = 617},
    {model_id = 666, name = "Lexus LX570", server_id = 618},
    {model_id = 667, name = "Porsche 911", server_id = 619},
    {model_id = 668, name = "Porsche Cayenne S", server_id = 620},
    {model_id = 699, name = "Bentley", server_id = 621},
    {model_id = 793, name = "BMW M8", server_id = 622},
    {model_id = 794, name = "Mercedes E63", server_id = 623},
    {model_id = 909, name = "Mercedes S63 AMG", server_id = 624},
    {model_id = 965, name = "Volkswagen Touareg", server_id = 625},
    {model_id = 1194, name = "Lamborghini Urus", server_id = 626},
    {model_id = 1195, name = "Audi Q8", server_id = 627},
    {model_id = 1196, name = "Dodge Challenger SRT", server_id = 628},
    {model_id = 1197, name = "Acura NSX", server_id = 629},
    {model_id = 1198, name = "Volvo V60", server_id = 630},
    {model_id = 1199, name = "Range Rover Evoque", server_id = 631},
    {model_id = 1200, name = "Honda Civic Type-R", server_id = 632},
    {model_id = 1201, name = "Lexus Sport-S", server_id = 633},
    {model_id = 1202, name = "Ford Mustang GT", server_id = 634},
    {model_id = 1203, name = "Volvo XC90", server_id = 635},
    {model_id = 1204, name = "Jaguar F-pace", server_id = 636},
    {model_id = 1205, name = "Kia Optima", server_id = 637},
    {model_id = 3155, name = "BMW Z4 40i", server_id = 638},
    {model_id = 3156, name = "Mercedes-Benz S600 W140", server_id = 639},
    {model_id = 3157, name = "BMW X5 E53", server_id = 640},
    {model_id = 3158, name = "Nissan Skyline R34", server_id = 641},
    {model_id = 3194, name = "Ducati Diavel", server_id = 642},
    {model_id = 3195, name = "Ducati Panigale", server_id = 643},
    {model_id = 3196, name = "Ducati Ducnaked", server_id = 644},
    {model_id = 3197, name = "Kawasaki Ninja ZX-10RR", server_id = 645},
    {model_id = 3198, name = "Western", server_id = 646},
    {model_id = 3199, name = "Rolls-Royce Cullinan", server_id = 647},
    {model_id = 3200, name = "Volkswagen Beetle", server_id = 648},
    {model_id = 3201, name = "Bugatti Divo Sport", server_id = 649},
    {model_id = 3202, name = "Bugatti Chiron", server_id = 650},
    {model_id = 3203, name = "Fiat 500", server_id = 651},
    {model_id = 3204, name = "Mercedes-Benz GLS 2020", server_id = 652},
    {model_id = 3205, name = "Mercedes-AMG G65 AMG", server_id = 653},
    {model_id = 3206, name = "Lamborghini Aventador SVJ", server_id = 654},
    {model_id = 3207, name = "Range Rover SVA", server_id = 655},
    {model_id = 3208, name = "BMW 530i E39", server_id = 656},
    {model_id = 3209, name = "Mercedes-Benz S600 W220", server_id = 657},
    {model_id = 3210, name = "Tesla Model X", server_id = 658},
    {model_id = 3211, name = "Nissan LEAF", server_id = 659},
    {model_id = 3212, name = "Nissan Silvia S15", server_id = 660},
    {model_id = 3213, name = "Subaru Forester XT", server_id = 661},
    {model_id = 3215, name = "Subaru Legacy 1989", server_id = 662},
    {model_id = 3216, name = "Hyundai Sonata", server_id = 663},
    {model_id = 3217, name = "BMW 750i E38", server_id = 664},
    {model_id = 3218, name = "Mercedes-Benz E 55 AMG", server_id = 665},
    {model_id = 3219, name = "Mercedes-Benz E500", server_id = 666},
    {model_id = 3220, name = "Jackson Storm", server_id = 667},
    {model_id = 3222, name = "Lightning McQueen", server_id = 668},
    {model_id = 3223, name = "Sir Tow Mater", server_id = 669},
    {model_id = 3224, name = "Buckingham", server_id = 670},
	{model_id = 3232, name = "Infiniti FX 50", server_id = 671},
    {model_id = 3233, name = "Lexus RX 450H", server_id = 672},
    {model_id = 3234, name = "Kia Sportage", server_id = 673},
    {model_id = 3235, name = "Volkswagen Golf R", server_id = 674},
    {model_id = 3236, name = "Audi R8", server_id = 675},
    {model_id = 3237, name = "Toyota Camry XV40", server_id = 676},
    {model_id = 3238, name = "Toyota Camry XV70", server_id = 677},
    {model_id = 3239, name = "BMW M5 E60", server_id = 678},
    {model_id = 3240, name = "BMW M5 F90", server_id = 679},
    {model_id = 3245, name = "Mercedes Maybach S 650", server_id = 680},
    {model_id = 3247, name = "Mercedes-Benz AMG GT", server_id = 681},
    {model_id = 3248, name = "Porsche Panamera Turbo", server_id = 682},
    {model_id = 3251, name = "Volkswagen Passat", server_id = 683},
    {model_id = 3254, name = "Chevrolet Corvette C3 Stingray", server_id = 684},
    {model_id = 3266, name = "Dodge Ram", server_id = 685},
    {model_id = 3348, name = "Ford Mustang Shelby GT500", server_id = 686},
    {model_id = 3974, name = "Aston Martin DB5", server_id = 687},
    {model_id = 4542, name = "BMW M3 GTR", server_id = 688},
    {model_id = 4543, name = "Chevrolet Camaro", server_id = 689},
    {model_id = 4544, name = "Mazda RX7 Veilside FD", server_id = 690},
    {model_id = 4545, name = "Mazda RX8", server_id = 691},
    {model_id = 4546, name = "Mitsubishi Eclipse", server_id = 692},
    {model_id = 4547, name = "Ford Mustang 289", server_id = 693},
    {model_id = 4548, name = "Nissan 350Z", server_id = 694},
    {model_id = 4774, name = "BMW 760li", server_id = 695},
    {model_id = 4775, name = "Aston Martin One-77", server_id = 696},
    {model_id = 4776, name = "Bentley Bacalar", server_id = 697},
    {model_id = 4777, name = "Bentley Bentayga", server_id = 698},
    {model_id = 4778, name = "BMW M4 G82", server_id = 699},
    {model_id = 4779, name = "BMW i8", server_id = 700},
    {model_id = 4780, name = "Genesis G90", server_id = 701},
    {model_id = 4781, name = "Honda Integra Type-R", server_id = 702},
    {model_id = 4782, name = "BMW M3 G20", server_id = 703},
    {model_id = 4783, name = "Mercedes-Benz S500 4Matic", server_id = 704},
    {model_id = 4784, name = "Ford Raptor F150", server_id = 705},
    {model_id = 4785, name = "Ferrari J50", server_id = 706},
    {model_id = 4786, name = "Mercedes-Benz SLR McLaren", server_id = 707},
    {model_id = 4787, name = "Subaru BRZ", server_id = 708},
    {model_id = 4788, name = "Lada Vesta SW Cross", server_id = 709},
    {model_id = 4789, name = "Porsche Taycan", server_id = 710},
    {model_id = 4790, name = "Ferrari Enzo", server_id = 711},
    {model_id = 4791, name = "UAZ Patriot", server_id = 712},
    {model_id = 4792, name = "Volga", server_id = 713},
    {model_id = 4793, name = "Mercedes-Benz X Class", server_id = 714},
    {model_id = 4794, name = "Jaguar XF", server_id = 715},
    {model_id = 4795, name = "RC Shutle", server_id = 716},
    {model_id = 4796, name = "Dodge Grand Caravan", server_id = 717},
    {model_id = 4797, name = "Dodge Charger", server_id = 718},
    {model_id = 4798, name = "Ford Explorer", server_id = 719},
    {model_id = 4799, name = "Ford F150", server_id = 720},
    {model_id = 4800, name = "Deltaplane", server_id = 721},
    {model_id = 4801, name = "Sea Shark", server_id = 722},
    {model_id = 4802, name = "Lamborghini Aventador LP700", server_id = 723},
    {model_id = 4803, name = "Ferrari FF", server_id = 724},
    {model_id = 6604, name = "Audi A6", server_id = 725},
    {model_id = 6605, name = "Audi Q7", server_id = 726},
    {model_id = 6606, name = "BMW M6 2020", server_id = 727},
    {model_id = 6607, name = "BMW M6 1990", server_id = 728},
    {model_id = 6608, name = "Mercedes CLA 45 AMG", server_id = 729},
    {model_id = 6609, name = "Mercedes CLS 63 AMG", server_id = 730},
    {model_id = 6610, name = "Haval H6 2.0 GDIT", server_id = 731},
    {model_id = 6611, name = "Toyota Land Cruiser VXR V8 4", server_id = 732},
    {model_id = 6612, name = "Lincoln Continental", server_id = 733},
    {model_id = 6613, name = "Porsche Macan Turno", server_id = 734},
    {model_id = 6614, name = "Daewoo Matiz", server_id = 735},
    {model_id = 6615, name = "Mercedes-AMG G63 6x6", server_id = 736},
    {model_id = 6616, name = "Mercedes E-63 AMG", server_id = 737},
    {model_id = 6617, name = "Monster Mutt", server_id = 738},
    {model_id = 6618, name = "Monster Indonesia", server_id = 739},
    {model_id = 6619, name = "Monster El Toro", server_id = 740},
    {model_id = 6620, name = "Monster Grave Digger", server_id = 741},
    {model_id = 6621, name = "Toyota Land Cruiser Prado", server_id = 742},
    {model_id = 6622, name = "Toyota RAV4", server_id = 743},
    {model_id = 6623, name = "Toyota Supra A90", server_id = 744},
    {model_id = 6624, name = "UAZ", server_id = 745},
    {model_id = 6625, name = "Volvo XC90 2012", server_id = 746},
    {model_id = 12713, name = "Mercedes-Benz GLE 63", server_id = 747},
    {model_id = 12714, name = "Renault Laguna", server_id = 748},
    {model_id = 12715, name = "Mercedes-Benz CLS 53", server_id = 749},
    {model_id = 12716, name = "Audi RS5", server_id = 750},
    {model_id = 12717, name = "Cadillac Escalade 2020", server_id = 751},
    {model_id = 12718, name = "Cyber Truck", server_id = 752},
    {model_id = 12719, name = "Tesla Model S", server_id = 753},
    {model_id = 12720, name = "Ford GT", server_id = 754},
	{model_id = 12721, name = "Dodge Viper", server_id = 755},
    {model_id = 12722, name = "Volkswagen Polo", server_id = 756},
    {model_id = 12723, name = "Mitsubishi Lancer Old", server_id = 757},
    {model_id = 12724, name = "Audi TT RS", server_id = 758},
    {model_id = 12725, name = "Mercedes-Benz Actros", server_id = 759},
    {model_id = 12726, name = "Audi S4", server_id = 760},
    {model_id = 12727, name = "BMW 4-Series", server_id = 761},
    {model_id = 12728, name = "Cadillac Escalade 2007", server_id = 762},
    {model_id = 12729, name = "Toyota Chaser", server_id = 763},
    {model_id = 12730, name = "Dacia 1300", server_id = 764},
    {model_id = 12731, name = "Mitsubishi Lancer", server_id = 765},
    {model_id = 12732, name = "Impala 64", server_id = 766},
    {model_id = 12733, name = "Impala 67", server_id = 767},
    {model_id = 12734, name = "Coca-Cola Truck", server_id = 768},
    {model_id = 12735, name = "Coca-Cola Trailer", server_id = 769},
    {model_id = 12736, name = "McLaren MP4", server_id = 770},
    {model_id = 12737, name = "Ford Mustang Mach 1", server_id = 771},
    {model_id = 12738, name = "Rolls-Royce Phantom", server_id = 772},
    {model_id = 12739, name = "Pickup truck", server_id = 773},
    {model_id = 12740, name = "Volvo Truck", server_id = 774},
    {model_id = 12741, name = "Subaru WRX", server_id = 775},
    {model_id = 12742, name = "Sherp", server_id = 776},
    {model_id = 12743, name = "Christmas sleigh", server_id = 777},
    {model_id = 14119, name = "Audi A6", server_id = 778},
    {model_id = 14120, name = "Toyota Camry", server_id = 779},
    {model_id = 14121, name = "Kia Sportage", server_id = 780},
    {model_id = 14122, name = "Tesla Model X", server_id = 781},
    {model_id = 14123, name = "Toyota RAV4", server_id = 782},
    {model_id = 14124, name = "Nissan GTR 2017", server_id = 783},
    {model_id = 14767, name = "Mercedes-AMG Project One R50", server_id = 784},
    {model_id = 14768, name = "Aston Martin Valkyrie", server_id = 785},
    {model_id = 14769, name = "Chevrolet Aveo", server_id = 786},
    {model_id = 14857, name = "BUGATTI Bolide", server_id = 787},
    {model_id = 14884, name = "Yacota K5", server_id = 788},
    {model_id = 14899, name = "Renault DUSTER", server_id = 789},
    {model_id = 14904, name = "Ferrari Monza SP2", server_id = 790},
    {model_id = 14905, name = "Mercedes-AMG G63", server_id = 791},
    {model_id = 14906, name = "Hotwheels", server_id = 792},
    {model_id = 14907, name = "Hummer HX", server_id = 793},
    {model_id = 14908, name = "Ferrari F70", server_id = 794},
    {model_id = 14909, name = "BMW M5 CS", server_id = 795},
    {model_id = 14910, name = "LADA Priora", server_id = 796},
    {model_id = 14911, name = "Quadra Turbo-R V-Tech", server_id = 797},
    {model_id = 14912, name = "Mercedes-Benz GLE-Class 2019", server_id = 798},
    {model_id = 14913, name = "Mercedes-Benz VISION AVTR", server_id = 799},
    {model_id = 14914, name = "Specialized Stumpjumper", server_id = 800},
    {model_id = 14915, name = "Santa Cruz Tallboy", server_id = 801},
    {model_id = 14916, name = "Spooky Metalhead", server_id = 802},
    {model_id = 14917, name = "Turner Burner", server_id = 803},
    {model_id = 14918, name = "Holding Bus Company", server_id = 804},
    {model_id = 14919, name = "Los-Santos Inter Bus C.", server_id = 805},
    {model_id = 15085, name = "Dodge Charger", server_id = 806},
    {model_id = 15098, name = "BMW M1", server_id = 807},
    {model_id = 15099, name = "Lamborghini Countach", server_id = 808},
    {model_id = 15100, name = "Nagasaki", server_id = 809},
    {model_id = 15101, name = "Koenigsegg Gemera", server_id = 810},
    {model_id = 15102, name = "KIA K7", server_id = 811},
    {model_id = 15103, name = "Lampadati Toro", server_id = 812},
    {model_id = 15104, name = "Lexus LX600", server_id = 813},
    {model_id = 15105, name = "Nissan Qashqai", server_id = 814},
    {model_id = 15106, name = "Predator", server_id = 815},
    {model_id = 15107, name = "Volkswagen Scirocco", server_id = 816},
    {model_id = 15108, name = "Longfin", server_id = 817},
    {model_id = 15109, name = "Toyota GR", server_id = 818},
    {model_id = 15110, name = "Wellcraft", server_id = 819},
    {model_id = 15111, name = "Yacht", server_id = 820},
    {model_id = 15112, name = "Boates", server_id = 821},
    {model_id = 15113, name = "Mercedes-AMG A-45", server_id = 822},
	{name = "Toyota AE86", model_id = 15114, server_id = 823},
    {name = "Land Rover Defender", model_id = 15115, server_id = 824},
    {name = "Ford Mustang Mach", model_id = 15116, server_id = 825},
    {name = "Mazda 6", model_id = 15117, server_id = 826},
    {name = "Audi R8 Spyder", model_id = 15118, server_id = 827},
    {name = "Hyundai Santa Fe", model_id = 15119, server_id = 828},
    {name = "Range Rover Velar", model_id = 15295, server_id = 829},
    {name = "Mercedes-Benz 1620", model_id = 15326, server_id = 830},
    {name = "Mercedes-Benz 1113", model_id = 15327, server_id = 831},
    {name = "Volkswagen Constellation", model_id = 15328, server_id = 832},
    {name = "Luxor Deluxe", model_id = 15329, server_id = 833},
    {name = "Nimbus", model_id = 15330, server_id = 834},
    {name = "Vestra", model_id = 15331, server_id = 835},
    {name = "Mercedes-Benz Arocs 4163", model_id = 15332, server_id = 836},
    {name = "Iveco Stralis", model_id = 15333, server_id = 837},
    {name = "MAN TGS", model_id = 15334, server_id = 838},
    {name = "Volvo 460", model_id = 15335, server_id = 839},
    {name = "VC - Ambulance", model_id = 15416, server_id = 840},
    {name = "VC - Banshee", model_id = 15417, server_id = 841},
    {name = "VC - Benson", model_id = 15418, server_id = 842},
    {name = "VC - Bloodring", model_id = 15419, server_id = 843},
    {name = "VC - Bus", model_id = 15420, server_id = 844},
    {name = "VC - Cabbie", model_id = 15421, server_id = 845},
    {name = "VC - Police Car", model_id = 15422, server_id = 846},
    {name = "VC - Deluxo", model_id = 15423, server_id = 847},
    {name = "VC - FBI Rancher", model_id = 15424, server_id = 848},
    {name = "VC - Flatbed", model_id = 15425, server_id = 849},
    {name = "VC - Idaho", model_id = 15426, server_id = 850},
    {name = "VC - Infernus", model_id = 15427, server_id = 851},
    {name = "VC - Love Fist", model_id = 15428, server_id = 852},
    {name = "VC - Patriot", model_id = 15429, server_id = 853},
    {name = "VC - Pizzaboy", model_id = 15430, server_id = 854},
    {name = "VC - Securica", model_id = 15431, server_id = 855},
    {name = "VC - Sentinel", model_id = 15432, server_id = 856},
    {name = "VC - Stinger", model_id = 15433, server_id = 857},
    {name = "VC - Stretch", model_id = 15434, server_id = 858},
    {name = "VC - Taxi", model_id = 15435, server_id = 859},
    {name = "VC - Trashmaster", model_id = 15436, server_id = 860},
    {name = "VC - Angel", model_id = 15485, server_id = 861},
    {name = "VC - BF Injection", model_id = 15486, server_id = 862},
    {name = "VC - Blista", model_id = 15487, server_id = 863},
    {name = "VC - Burrito", model_id = 15488, server_id = 864},
    {name = "VC - FBI Car", model_id = 15489, server_id = 865},
    {name = "VC - Hotring B", model_id = 15490, server_id = 866},
    {name = "VC - Sabre Turbo", model_id = 15491, server_id = 867},
    {name = "VC - Sanchez", model_id = 15492, server_id = 868},
    {name = "Tesla S - ambulance", model_id = 15493, server_id = 869},
    {name = "Tesla X - ambulance", model_id = 15494, server_id = 870},
    {name = "BMW IX", model_id = 15495, server_id = 871},
    {name = "Mercedes-Benz EQC 400", model_id = 15496, server_id = 872},
    {name = "Audi e-tron", model_id = 15497, server_id = 873},
    {name = "Jaguar I-PACE", model_id = 15498, server_id = 874},
    {name = "Tesla S - police", model_id = 15499, server_id = 875},
    {name = "Tesla X - police", model_id = 15500, server_id = 876},
    {name = "Renault Twizy", model_id = 15501, server_id = 877},
    {name = "Polestar 2", model_id = 15502, server_id = 878},
    {name = "Arctics Trailer", model_id = 15720, server_id = 879},
    {name = "Mersedes-Benz GLE 63S", model_id = 15721, server_id = 880},
    {name = "Tesla Model 3", model_id = 15722, server_id = 881},
    {name = "Lamborghini Murcielago", model_id = 15723, server_id = 882},
    {name = "Xoomer Petrol", model_id = 15724, server_id = 883},
    {name = "Delorean", model_id = 15725, server_id = 884},
    {name = "Mercedes-Benz Gl63", model_id = 15626, server_id = 885},
    {name = "BMW 7", model_id = 15627, server_id = 886},
    {name = "MB v250", model_id = 15628, server_id = 887},
	{model_id = 15629, name = "Mercedes-Benz C63", server_id = 888},
    {model_id = 15630, name = "MB C63s Coupe", server_id = 889},
    {model_id = 15631, name = "Audi RS7", server_id = 890},
    {model_id = 15746, name = "BMW X7", server_id = 891},
    {model_id = 15747, name = "BMW X6", server_id = 892},
    {model_id = 15748, name = "Jeep Gladiator", server_id = 893},
    {model_id = 15749, name = "BMW M8 Gran Coupe", server_id = 894},
    {model_id = 15750, name = "Volkswagen Touareg", server_id = 895},
    {model_id = 15751, name = "Range Rover 2022", server_id = 896},
    {model_id = 15752, name = "Mercedes-Benz S 63", server_id = 897},
    {model_id = 15858, name = "Mercedes-Benz C63S", server_id = 898},
    {model_id = 15859, name = "BMW M5 F10", server_id = 899},
    {model_id = 15860, name = "BMW M3 E30", server_id = 900},
    {model_id = 15861, name = "Volkswagen Transporter", server_id = 901},
    {model_id = 15862, name = "Mercedes-Benz Vito", server_id = 902},
    {model_id = 15863, name = "Opel Vivaro", server_id = 903},
    {model_id = 15882, name = "Skate", server_id = 904},
    {model_id = 15883, name = "Surfboard", server_id = 905},
    {model_id = 15902, name = "Audi 80 Universal", server_id = 906},
    {model_id = 15903, name = "Mercedes C63 Coupe", server_id = 907},
    {model_id = 15904, name = "BMW E34", server_id = 908},
    {model_id = 15905, name = "Mercedes-Benz E63 w211", server_id = 909},
    {model_id = 15906, name = "BMW X5 F85", server_id = 910},
    {model_id = 15907, name = "Lamborghini Gallardo", server_id = 911},
    {model_id = 15908, name = "Mercedes-Benz GLE63 2016", server_id = 912},
    {model_id = 15909, name = "BMW 850i", server_id = 913},
    {model_id = 15910, name = "Audi RS6 Quattro", server_id = 914},
    {model_id = 15960, name = "Mercedes GT63 Brabus", server_id = 915},
    {model_id = 15961, name = "Mercedes-Benz GLE Brabus", server_id = 916},
    {model_id = 15962, name = "McLaren 720S", server_id = 917},
    {model_id = 15963, name = "Dodge RAM 3500", server_id = 918},
    {model_id = 15964, name = "AT-99 Scorpion", server_id = 919},
    {model_id = 15965, name = "MOP", server_id = 920},
    {model_id = 16793, name = "Batmobile", server_id = 921},
    {model_id = 16794, name = "Zombiemobile", server_id = 922},
    {model_id = 16795, name = "Devil", server_id = 923},
    {model_id = 16796, name = "Police Apocalypse", server_id = 924},
    {model_id = 16797, name = "Chum Bucket", server_id = 925},
    {model_id = 16798, name = "Hellway", server_id = 926},
    {model_id = 16892, name = "Brabus Adventure", server_id = 927},
    {model_id = 16893, name = "Brabus 850", server_id = 928},
    {model_id = 16894, name = "Mansory Stallone", server_id = 929},
    {model_id = 16895, name = "Bentley Bentayga Mansory", server_id = 930},
    {model_id = 16896, name = "Brabus 700", server_id = 931},
    {model_id = 16897, name = "Mercedes-AMG G63: Mansory", server_id = 932},
    {model_id = 16898, name = "Brabus GLS 2020", server_id = 933},
    {model_id = 16899, name = "Rolls-Royce Cullinan Mansory", server_id = 934},
    {model_id = 16900, name = "Lamborghini Urus Mansory", server_id = 935},
    {model_id = 16903, name = "Bobcat [New Year]", server_id = 936},
    {model_id = 16904, name = "Hotknife [New Year]", server_id = 937},
    {model_id = 16920, name = "Snowboard", server_id = 938},
    {model_id = 16951, name = "Chevrolet Corvette ZO6", server_id = 939},
    {model_id = 16952, name = "Porsche Carrera", server_id = 940},
    {model_id = 16953, name = "Scramjet", server_id = 941},
    {model_id = 16954, name = "Dodge Charger SRT", server_id = 942},
    {model_id = 16955, name = "Ferrari F40", server_id = 943},
    {model_id = 16956, name = "Canis", server_id = 944},
    {model_id = 16957, name = "Chevrolet Tahoe", server_id = 945},
    {model_id = 16958, name = "Tampa GT310", server_id = 946},
    {model_id = 16959, name = "Toyota Tundra", server_id = 947},
    {model_id = 16994, name = "Scooter 1", server_id = 948},
    {model_id = 16995, name = "Scooter 2", server_id = 949},
    {model_id = 16996, name = "Scooter 3", server_id = 950},
    {model_id = 18164, name = "Cheetah [V]", server_id = 951},
    {model_id = 18165, name = "Huntley S [V]", server_id = 952},
    {model_id = 18166, name = "Obey [V]", server_id = 953},
    {model_id = 18167, name = "Infernus Pegassi [V]", server_id = 954},
    {model_id = 18152, name = "BMW I7", server_id = 955},
    {model_id = 18153, name = "Cobra", server_id = 956},
    {model_id = 18154, name = "Ford Fusion", server_id = 957},
	{model_id = 18155, name = "Toyota Mark II", server_id = 958},
    {model_id = 18156, name = "Daewoo Nexia", server_id = 959},
    {model_id = 18157, name = "Volkswagen Passat B", server_id = 960},
    {model_id = 18158, name = "Infiniti QX80", server_id = 961},
    {model_id = 18159, name = "Mercedes-Benz SL 65 AMG", server_id = 962},
    {model_id = 18160, name = "Nissan Titan", server_id = 963},
    {model_id = 18161, name = "Ford Victoria", server_id = 964},
    {model_id = 16800, name = "Renault Arcana", server_id = 965},
    {model_id = 16879, name = "Daewoo Lanos", server_id = 966},
    {model_id = 16964, name = "Lada Kalina", server_id = 967},
    {model_id = 16969, name = "Lada 112", server_id = 968},
    {model_id = 16970, name = "??? ?-20", server_id = 969},
    {model_id = 16971, name = "Lada 4x4 Urban", server_id = 970},
    {model_id = 16972, name = "Lada 4x4", server_id = 971},
    {model_id = 15438, name = "UAZ Hunter", server_id = 972},
    {model_id = 15439, name = "Banshee 900R", server_id = 973},
    {model_id = 15442, name = "Schlagen GT", server_id = 974},
    {model_id = 15443, name = "Jeep Grand Cherokee", server_id = 975},
    {model_id = 15444, name = "Patriot Mil-Spec", server_id = 976},
    {model_id = 15445, name = "Hennessey Velociraptor 6x6", server_id = 977},
    {model_id = 15446, name = "Zentorno", server_id = 978},
    {model_id = 6710, name = "Mitsubishi ASX", server_id = 979},
    {model_id = 6711, name = "BMW E34 Alpina", server_id = 980},
    {model_id = 6712, name = "BMW X5 E70", server_id = 981},
    {model_id = 6713, name = "Honda Accord", server_id = 982},
    {model_id = 6714, name = "Lamborghini Huracan 2022", server_id = 983},
    {model_id = 6715, name = "Toyota Land Cruiser 100", server_id = 984},
    {model_id = 6716, name = "Daewoo Lanox 6x6", server_id = 985},
    {model_id = 6717, name = "Mercedes-Benz s600 w221", server_id = 986},
    {model_id = 6718, name = "Nissan Silvia S14", server_id = 987},
    {model_id = 6741, name = "Mitsubishi Outlander 2008", server_id = 988},
    {model_id = 6742, name = "Phantom", server_id = 989},
    {model_id = 6743, name = "Nissan Silvia S13", server_id = 990},
    {model_id = 6744, name = "Toyota Supra A80", server_id = 991},
    {model_id = 6745, name = "Tank 300 Wey", server_id = 992},
    {model_id = 6746, name = "Bentley Ultratank", server_id = 993},
    {model_id = 14131, name = "Pagani Codalunga", server_id = 994},
    {model_id = 14132, name = "Mercedes-Benz Big Foot", server_id = 995},
    {model_id = 14133, name = "BMW Big Foot", server_id = 996},
    {model_id = 6650, name = "Audi R8 Bigfoot", server_id = 997},
    {model_id = 14134, name = "Mercedes-Benz Coach", server_id = 998},
    {model_id = 14135, name = "Mercedes-Benz Transpen", server_id = 999},
    {model_id = 14137, name = "Mercedes-Benz Tourismo", server_id = 1000},
    {model_id = 14138, name = "Volvo FH 12", server_id = 1001},
    {model_id = 14139, name = "Mack Anthem", server_id = 1002},
    {model_id = 14140, name = "Tesla Semi", server_id = 1003},
    {model_id = 14141, name = "Western Star", server_id = 1004},
    {model_id = 14142, name = "Business Jet", server_id = 1005},
    {model_id = 14143, name = "Learjet 60", server_id = 1006},
    {model_id = 14145, name = "Spaceflight", server_id = 1007},
    {model_id = 14193, name = "Audi R8 Darius", server_id = 1008},
    {model_id = 14194, name = "Dodge Charger Angie", server_id = 1009},
    {model_id = 14195, name = "Ford Mustang Razor", server_id = 1010},
    {model_id = 14355, name = "RC Mavic", server_id = 1011},
    {model_id = 6673, name = "Bugatti Veyron", server_id = 1012},
    {model_id = 6674, name = "Lamborghini Centenario", server_id = 1013},
    {model_id = 6675, name = "Ford Bonco", server_id = 1014},
    {model_id = 6676, name = "Jeep Rubicon", server_id = 1015},
    {model_id = 6677, name = "Mitsubishi Pajero 3", server_id = 1016},
    {model_id = 6678, name = "BMW M3 G80", server_id = 1017},
    {model_id = 6679, name = "BMW X3 E83", server_id = 1018},
    {model_id = 6680, name = "Rolls-Royce Ghost", server_id = 1019},
    {model_id = 6681, name = "Avtoros Shaman", server_id = 1020},
    {model_id = 6682, name = "Lamborghini Countach", server_id = 1021},
    {model_id = 6683, name = "Mercedes-AMG GT R", server_id = 1022},
    {model_id = 6684, name = "Hummer H2", server_id = 1023},
    {model_id = 6685, name = "Mitsubishi Evo 8", server_id = 1024},
    {model_id = 6686, name = "Mercedes-AMG GT Black", server_id = 1025},
    {model_id = 6687, name = "Mercedes-Benz CLS55", server_id = 1026},
    {model_id = 6693, name = "JMC", server_id = 1027},
    {model_id = 15605, name = "Madcar", server_id = 1028},
    {model_id = 15618, name = "Peterblit Track 'Advance'", server_id = 1029},
    {model_id = 15619, name = "Porsche 911 Turbo S", server_id = 1030},
    {model_id = 15620, name = "Madtrain", server_id = 1031},
    {model_id = 15621, name = "Volvo 460 'Diamond'", server_id = 1032},
    {model_id = 15635, name = "Chevrolet C10 C1", server_id = 1033},
    {model_id = 15653, name = "Chevrolet C10", server_id = 1034},
    {model_id = 15669, name = "??? 21", server_id = 1035},
    {model_id = 15708, name = "Corvette C1", server_id = 1036},
    {model_id = 15710, name = "Corvette C1 (Barbie)", server_id = 1037},
    {model_id = 15711, name = "Datsun 280z", server_id = 1038},
	{model_id = 15713, name = "GMC Savanna", server_id = 1039},
    {model_id = 15733, name = "Honda NSX 1990", server_id = 1040},
    {model_id = 15734, name = "Mystery", server_id = 1041},
    {model_id = 15742, name = "Nissan 240z", server_id = 1042},
    {model_id = 15743, name = "SkullBike", server_id = 1043},
    {model_id = 15870, name = "??? 2109", server_id = 1044},
    {model_id = 15874, name = "Dunbar Track", server_id = 1045},
    {model_id = 15934, name = "?????", server_id = 1046},
    {model_id = 15935, name = "Optimus Prime Track", server_id = 1047},
    {model_id = 15937, name = "Twisted Metal", server_id = 1048},
    {model_id = 15942, name = "Hell Hot Rod", server_id = 1049},
    {model_id = 15943, name = "Hulk Hot Rod", server_id = 1050},
    {model_id = 16909, name = "Ford Explorer 20", server_id = 1051},
    {model_id = 12622, name = "Aston Martin DBS", server_id = 1052},
    {model_id = 12623, name = "Bentley Flying Spur", server_id = 1053},
    {model_id = 12624, name = "Snowmobile Buran", server_id = 1054},
    {model_id = 12625, name = "Volkswagen Golf GTI", server_id = 1055},
    {model_id = 12626, name = "Alfa Romeo Giulia", server_id = 1056},
    {model_id = 12627, name = "Hyndai Ioniq", server_id = 1057},
    {model_id = 12628, name = "BMW M2", server_id = 1058},
    {model_id = 12630, name = "Snowmobile Mizu", server_id = 1059},
    {model_id = 12631, name = "Snowmobile Retro", server_id = 1060},
    {model_id = 12633, name = "Wrangler 24", server_id = 1061},
    {model_id = 12598, name = "Chevrolet Silverado", server_id = 1062},
    {model_id = 12599, name = "Lamborghini Veneno Roadster", server_id = 1063},
    {model_id = 12600, name = "Lincoln Navigator", server_id = 1064},
    {model_id = 12602, name = "Pagani Huayra", server_id = 1065},
    {model_id = 12603, name = "Rolls Royce Boat Tail", server_id = 1066},
    {model_id = 12604, name = "Volkswagen Arteon", server_id = 1067},
    {model_id = 12605, name = "????-??????", server_id = 1068},
    {model_id = 12606, name = "???? ??????", server_id = 1069},
    {model_id = 12607, name = "???? ?????", server_id = 1070},
    {model_id = 12611, name = "Ferrari F250 GTO", server_id = 1071},
    {model_id = 12616, name = "Skoda Kodiaq", server_id = 1072},
    {model_id = 12614, name = "Prius PHV", server_id = 1073},
    {model_id = 12615, name = "Space Cruiser", server_id = 1074},
    {model_id = 6830, name = "Mack Anthem Packer", server_id = 1075},
    {model_id = 6835, name = "Apollo Intensa Emozione", server_id = 1076},
    {model_id = 6842, name = "BMW XM Off-road", server_id = 1077},
    {model_id = 6848, name = "BMW XM", server_id = 1078},
    {model_id = 6860, name = "Porsche 992 Off-Road", server_id = 1079},
    {model_id = 7408, name = "Tanarg 912", server_id = 1080},
    {model_id = 7976, name = "Aerostar 700", server_id = 1081},
    {model_id = 11860, name = "Mini Cooper Countryman", server_id = 1082},
    {model_id = 11866, name = "Dodge Charger Daytona", server_id = 1083},
    {model_id = 15449, name = "Volkswagen Amarok v6", server_id = 1084},
    {model_id = 15451, name = "BMW M4 F82", server_id = 1085},
    {model_id = 15452, name = "BMW NINE", server_id = 1086},
    {model_id = 15453, name = "Porsche Cayenne Turbo GT 2022", server_id = 1087},
    {model_id = 15454, name = "KIA EV9", server_id = 1088},
    {model_id = 15455, name = "Flying Brick", server_id = 1089},
    {model_id = 15456, name = "LiXiang L9", server_id = 1090},
    {model_id = 15457, name = "Lotus Emira", server_id = 1091},
    {model_id = 15553, name = "Lotus Esprit V8", server_id = 1092},
    {model_id = 15555, name = "Naran Hyper Coupe", server_id = 1093},
    {model_id = 15556, name = "Nissan Silvia 15", server_id = 1094},
    {model_id = 15558, name = "Mazda Rx-7FD-3S", server_id = 1095},
    {model_id = 15559, name = "Nissan Skyline BNR32", server_id = 1096},
    {model_id = 15561, name = "Vanda Electrics Dendrobium", server_id = 1097},
    {model_id = 15562, name = "Whiplash Fortnite", server_id = 1098},
    {model_id = 15563, name = "Batlle Bus Fortnite", server_id = 1099},
    {model_id = 15566, name = "Porsche 939 RSR Concept", server_id = 1100},
    {model_id = 15568, name = "Porsche 911 GT3RS 2024", server_id = 1101},
    {model_id = 14221, name = "Rezvani Vengeance", server_id = 1102},
    {model_id = 14242, name = "Peterbilt 359", server_id = 1103},
    {model_id = 14244, name = "Nissan 240Z S30", server_id = 1104},
    {model_id = 14245, name = "Bugatti Centodieci", server_id = 1105},
    {model_id = 14246, name = "Cadillac Escalade 2023", server_id = 1106},
    {model_id = 14247, name = "Ferrari Purosangue", server_id = 1107},
    {model_id = 14248, name = "Lamborghini Huracan LP 610 4", server_id = 1108},
    {model_id = 14249, name = "Lamborghini Huracan Sterrato Off-Road", server_id = 1109},
    {model_id = 14250, name = "Lamborghini Urus Off-Road", server_id = 1110},
    {model_id = 14251, name = "Ferrari SF90 Off-Road", server_id = 1111},
    {model_id = 14252, name = "Plymouth GTX Custom", server_id = 1112},
    {model_id = 14253, name = "Shelby Cobra 427 Custom", server_id = 1113},
    {model_id = 14254, name = "Mitsubishi Eclipse 1995", server_id = 1114},
    {model_id = 14255, name = "Cadillac Escalade Larte Design", server_id = 1115},
	{model_id = 15730, name = "Hummer H1 Military", server_id = 1117},
	{model_id = 15731, name = "1967 Chevrolet Impala Autogun", server_id = 1118},
	{model_id = 16861, name = "QuinJet", server_id = 1119},
	{model_id = 16862, name = "ВАЗ 2107", server_id = 1120},
	{model_id = 16863, name = "Clover Bomj Gang", server_id = 1121},
	{model_id = 16864, name = "Ford Crown Victoria Police", server_id = 1122},
	{model_id = 16865, name = "Diavel Sixteen", server_id = 1123},
	{model_id = 16866, name = "Mercedes e53 AMG 2025", server_id = 1124},
	{model_id = 16867, name = "Nissan R35 HB edition", server_id = 1125},
	{model_id = 16868, name = "Mitsubishi Evo 6 HB edition", server_id = 1126},
	{model_id = 16869, name = "F1 Bolide 23", server_id = 1127},
	{model_id = 16870, name = "Kawasaki NInja xr1000", server_id = 1128},
	{model_id = 16872, name = "Nissan Silvia s15 HB edition", server_id = 1129},
	{model_id = 16873, name = "Honda NSX 1990 HB edition", server_id = 1130},
	{model_id = 16874, name = "Toyota Land Cruiser 200 FBI", server_id = 1131},
    {name = "Skate Transparent", model_id = 14281, server_id = 1116}
}

function getVehicleNameByModelId(model_id)
    for _, vehicle in ipairs(vehicle_data) do
        if vehicle.model_id == model_id then
            return vehicle.name
        end
    end
    return "Unknown Model"
end

function get_storecar_model()
    local closest_car = nil
    local closest_distance = 175
    local my_pos = {getCharCoordinates(PLAYER_PED)}
    local my_car
    if isCharInAnyCar(PLAYER_PED) then
        my_car = storeCarCharIsInNoSave(PLAYER_PED)
    end
    for _, vehicle in ipairs(getAllVehicles()) do
        if doesCharExist(getDriverOfCar(vehicle)) and vehicle ~= my_car then
            local vehicle_pos = {getCarCoordinates(vehicle)}
            local distance = getDistanceBetweenCoords3d(my_pos[1], my_pos[2], my_pos[3], vehicle_pos[1], vehicle_pos[2], vehicle_pos[3])
            if distance < closest_distance and vehicle ~= my_car then
                closest_distance = distance
                closest_car = vehicle
            end
        end
    end
    if closest_car then
        local model_id = getCarModel(closest_car)
        local model_name = getVehicleNameByModelId(model_id)
        return "" .. model_name
    else
		sampAddChatMessage(script_tag..'{FFFFFF}Не удалось получить модель ближайшего транспорта!', color_tag)
        return ''
    end
end

function get_veh_status(player_id)
    if not sampIsPlayerConnected(player_id) then
        return "Неизвестно"
    end

    local _, ped = sampGetCharHandleBySampPlayerId(player_id)
    if isCharInAnyCar(ped) then
        return "В автомобиле"
    else
        return "Пешком"
    end
end

function get_sex_suffix()
    if setting.sex == u8'Мужской' then
        return ""
    else
        return "а"
    end
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
        sampAddChatMessage(script_tag .. '{FFFFFF}Нету игроков поблизу!', color_tag)
        return "Вне видимости"
    else
        return tostring(nearestPlayerId)
    end
end

function setClipboardText(text)
    require("ffi")
    ffi.cdef[[
        void* GlobalAlloc(int flags, size_t size);
        void* GlobalLock(void* hMem);
        int GlobalUnlock(void* hMem);
        void* memcpy(void* dest, const void* src, size_t n);
        int OpenClipboard(void* hwnd);
        int EmptyClipboard();
        void* SetClipboardData(unsigned int uFormat, void* hMem);
        int CloseClipboard();
        void* GetClipboardData(unsigned int uFormat);
        int IsClipboardFormatAvailable(unsigned int format);
    ]]
    local CF_TEXT = 1
    local GMEM_MOVEABLE = 0x0002
    if ffi.C.OpenClipboard(nil) == 0 then return end
    ffi.C.EmptyClipboard()
    local size = #text + 1
    local hMem = ffi.C.GlobalAlloc(GMEM_MOVEABLE, size)
    local ptr = ffi.C.GlobalLock(hMem)
    ffi.copy(ptr, text)
    ffi.C.GlobalUnlock(hMem)
    ffi.C.SetClipboardData(CF_TEXT, hMem)
    ffi.C.CloseClipboard()
end

local colorNames = {
	[0] = "Черного", -- hex цвета
	[1] = "Белого", -- И так ясно :)
	[2] = "Бирюзового", -- 2a77a1
	[3] = "Бордового", -- 840510
	[4] = "Тёмно-зелёного", -- 253739
	[5] = "Красно-пурпурного", -- 87446f
	[6] = "Золотисто-жёлтого", -- d78d10
	[7] = "Синего", -- 4c75b7
	[8] = "Светло-серого", -- bebece
	[9] = "Серо-зелёного", -- 5e7072
	[10] = "Тёмно-синего", -- 46597a
	[11] = "Серо-синего", -- 646a78
	[12] = "Голубино-синего", -- 5d7e8d
	[13] = "Графитово-серого", -- 58595b
	[14] = "Очень светло-серого", -- d5dad6
	[15] = "Светло-серого", -- 9ca1a5
	[16] = "Тёмно-зелёного", -- 335f3e
	[17] = "Насыщенного красно-коричневого", -- 740e1b
	[18] = "Тёмно-розового", -- 7b092a
	[19] = "Серо-коричневого", -- a09d94
	[20] = "Тёмно-синего", -- 3b4e78
	[21] = "Светло-бурдового", -- 722e3d
	[22] = "Бордово-красного", -- 691e3c
	[23] = "Серого", -- 96918d
	[24] = "Графитового", -- 515459
	[25] = "Тёмно-серого", -- 3f3e44
	[26] = "Светло-серого", -- a5a9a8
	[27] = "Тускло-серого", -- 645c5a
	[28] = "Тёмно-синего", -- 3d4b68
	[29] = "Светло-серого", -- 969591
	[30] = "Черно-красного", -- 422021
	[31] = "Тёмно-красного", -- 5f262c
	[32] = "Светло-серого с голубым оттенком", -- 8494ab
	[33] = "Серой белки", -- 767c7c
	[34] = "Тускло-серого", -- 646464
	[35] = "Серо-коричневого", -- 5a5752
	[36] = "Серо-синего", -- 252527
	[37] = "Черно-зелёного", -- 2e3a36
	[38] = "Серого", -- 93a396
	[39] = "Серо-синего", -- 6d7b88
	[40] = "Красновато-черного", -- 231918
	[41] = "Серо-коричневого", -- 6d6660
	[42] = "Коричнево-красного", -- 7c1c2a
	[43] = "Тёмно-бордового", -- 600a15
	[44] = "Тёмно-зелёного", -- 193826
	[45] = "Тёмно-бордового", -- 5d1b1f
	[46] = "Серо-бежевого", -- 9d9872
	[47] = "Зеленовато-серого", -- 7a7561
	[48] = "Кварцевого", -- 989586
	[49] = "Серо-голубого", -- acb0b1
	[50] = "Серебристо-серого", -- 848887
	[51] = "Тёмно-зелёного", -- 305045
	[52] = "Серо-синего", -- 4d6168
	[53] = "Очень тёмного синего", -- 162248
	[54] = "Тёмно-синего", -- 282f4b
	[55] = "Тёмно-коричневого", -- 7d6356
	[56] = "Серо-голубого", -- 9da4ac
	[57] = "Светло-коричневого", -- 9c8d70
	[58] = "Тёмно-красного", -- 6e1823
	[59] = "Отдаленно-синего", -- 4e6881
	[60] = "Светло-серого", -- 9e9d9b
	[61] = "Тёмно-коричневого", -- 927345
	[62] = "Тёмно-красного", -- 651c27
	[63] = "Серебристо-серого", -- 949ea0
	[64] = "Светло-серого", -- a5a7a6
	[65] = "Оливкового", -- 8f8c47
	[66] = "Тёмного серо-красно-коричневого", -- 34191e
	[67] = "Аспидно-серого", -- 6a798c
	[68] = "Оливково-серого", -- aaad8e
	[69] = "Кварцевого", -- ab998f
	[70] = "Тёмно-красного", -- 851f2d
	[71] = "Светло аспидно-серого", -- 708197
	[72] = "Серовато-зеленого", -- 575852
	[73] = "Оливково-зелёного", -- 99a790
	[74] = "Тёмно-бордового", -- 601a24
	[75] = "Очень тёмного синего", -- 22222e
	[76] = "Светло-оливкового", -- a4a095
	[77] = "Светло-коричневого", -- ab9d83
	[78] = "Тёмно-розового", -- 78222b
	[79] = "Тёмно-синего", -- 0e306d
	[80] = "Тёмно-розового", -- 722a3e
	[81] = "Средне-серого", -- 7d7161
	[82] = "Тёмно-красного", -- 741c28
	[83] = "Зелено-синего", -- 1f2e33
	[84] = "Тёмно-коричневого", -- 4e322f
	[85] = "Тёмно-розового", -- 7c1b44
	[86] = "Тёмно-зелёного", -- 2e5b20
	[87] = "Тёмно-синего", -- 395a83
	[88] = "Винно-красного", -- 682634
	[89] = "Светло-оливкового", -- a7a28f
	[90] = "Светло-серого", -- b0b4b3
	[91] = "Пурпурно-синего", -- 364155
	[92] = "Тёмно-серого", -- 6d6d6f
	[93] = "Синего", -- 0f6a89
	[94] = "Тёмно-синего", -- 204b6b
	[95] = "Тёмно-синего", -- 2a3e57
	[96] = "Светло-серого", -- 9b9f9e
	[97] = "Аспидно-серого", -- 6d8496
	[98] = "Тёмно-серого", -- 4e5d60
	[99] = "Бледно серо-коричневого", -- ae9a7f
	[100] = "Брилиантово-синего", -- 406c8f
	[101] = "Кобальто-синего", -- 1f253b
	[102] = "Светло-коричневого", -- ab9176
	[103] = "Синего", -- 124572
	[104] = "Светло-коричневого", -- 96816c
	[105] = "Серовато-синего", -- 64686b
	[106] = "Синего", -- 115083
	[107] = "Кварцевого", -- a29a85
	[108] = "Брилиантово-синего", -- 385694
	[109] = "Серовато-синего", -- 535762
	[110] = "Светло оливково-серого", -- 7f6856
	[111] = "Серовато-голубого", -- 8b929a
	[112] = "Синевато-серого", -- 596f87
	[113] = "Тёмно-коричневого", -- 473531
	[114] = "Серовато-зелёного", -- 456250
	[115] = "Тёмно-красного", -- 730a28
	[116] = "Тёмно-синего", -- 223458
	[117] = "Тёмно-бордового", -- 640e1b
	[118] = "Светло-голубого", -- a3adc6
	[119] = "Красновато-коричневого", -- 6a5854
	[120] = "Кварцевого", -- 9c8b81
	[121] = "Тёмно-бордового", -- 620b1c
	[122] = "Тёмно-серого", -- 5c5d5f
	[123] = "Тёмно-коричневого", -- 624428
	[124] = "Тёмно-красного", -- 731827
	[125] = "Тёмно-синего", -- 1c376e
	[126] = "Розового", -- ec6bae
	[127] = "Чёрного", -- 000000
	[128] = "Зелёного", -- 22984c
	[129] = "Очень тёмного бордового", -- 1e0500
	[130] = "Синего", -- 13547e
	[131] = "Тёмно-коричневого", -- 40280e
	[132] = "Тёмно-красного", -- 551f1d
	[133] = "Чёрного с лёгким оттенком зелёного", -- 020902
	[134] = "Тёмно-синего", -- 222258
	[135] = "Ярко-синего", -- 2f89ae
	[136] = "Аметистового", -- 8a4fbd
	[137] = "Травяного зелёного", -- 36973a
	[138] = "Светло серого", -- b7b7b7
	[139] = "Насыщеного пурпурно-синего", -- 474c8e
	[140] = "Светло-серого", -- 84878c
	[141] = "Тёмно-серого", -- 817867
	[142] = "Оливкового", -- 817b27
	[143] = "Тёмно-серого с фиолетовым оттенком", -- 69506e
	[144] = "Тёмно-фиолетового", -- 583d70
	[145] = "Светло-зелёного", -- 88bb70
	[146] = "Розовато-коричневого", -- 824f7a
	[147] = "Тёмно-фиолетового", -- 6e2769
	[148] = "Тёмного серо-оливково-зелёного", -- 1c1e13
	[149] = "Очень тёмно-коричневого", -- 22110a
	[150] = "Оливково-черного", -- 1f2519
	[151] = "Тёмно-зелёного", -- 2c4530
	[152] = "Тёмно-синего", -- 1e4c99
	[153] = "Тёмно-зелёного", -- 2d5f42
	[154] = "Ярко-зелёного", -- 1f9848
	[155] = "Ярко-синего", -- 179ba0
	[156] = "Светло-серого", -- 999975
	[157] = "Тёмно-серого с голубым оттенком", -- 7a859b
	[158] = "Тёмно-красного", -- 992e1c
	[159] = "Тёмно-коричневого", -- 2d1e09
	[160] = "Тёмно-зелёного", -- 122507
	[161] = "Тёмно-зорового", -- 993e4d
	[162] = "Тёмно-синего", -- 1e4c99
	[163] = "Бирюзового", -- 198182
	[164] = "Очень тёмно-серого", -- 1a2a2a
	[165] = "Тёмно-бирюзового", -- 15616f
	[166] = "Тёмно-синего", -- 1b6686
	[167] = "Фиолетового", -- 6c419a
	[168] = "Тёмно-коричневого", -- 461a0d
	[169] = "Светло-фиолетового", -- 787497
	[170] = "Светло-фиолетового", -- 766d9a
	[171] = "Тёмно-фиолетового", -- 553a81
	[172] = "Очень тёмно-коричневого", -- 242100
	[173] = "Тёмно-коричневого", -- 401b12
	[174] = "Тёмно-коричневого", -- 45220c
	[175] = "Тёмно-красного", -- 9a201d
	[176] = "Фиолетового", -- 8d4c8e
	[177] = "Тёмно-фиолетового", -- 7f5b7f
	[178] = "Тёмно-розового", -- 7b3f7f
	[179] = "Тёмно-фиолетового", -- 3c1738
	[180] = "Тёмно-коричневого", -- 723518
	[181] = "Тёмно-красного", -- 781819
	[182] = "Тёмно-оранжевого", -- 84341b
	[183] = "Тёмно-оранжевого", -- 8e2f1b
	[184] = "Тёмно-розового", -- 7e3f54
	[185] = "Пурпурно-синего", -- 7b6d7c
	[186] = "Чёрного с лёгким зелёным оттенком", -- 020c03
	[187] = "Очень тёмно-зелёного", -- 072406
	[188] = "Тёмно-зеленого", -- 163112
	[189] = "Тёмно-зеленого", -- 182f1d
	[190] = "Тёмно-фиолетового", -- 642b4e
	[191] = "Тёмно-зелёного", -- 368452
	[192] = "Светло-серого", -- 999691
	[193] = "Тёмно-серого с голубым оттенком", -- 828c95
	[194] = "Оливкового", -- 989a1f
	[195] = "Оливкового", -- 80984a
	[196] = "Тёмно-зелёного с голубым оттенком", -- 819393
	[197] = "Тёмно-зелёного", -- 788126
	[198] = "Тёмно-синего", -- 2c3d99
	[199] = "Тёмно-зелёного", -- 3b3a0a
	[200] = "Оливково-коричневого", -- 8a794e
	[201] = "Тёмно-синего", -- 0d2146
	[202] = "Очень тёмно-зелёного", -- 16371c
	[203] = "Очень тёмно-синего", -- 15273b
	[204] = "Тёмно-горубого", -- 385773
	[205] = "Очень темно-синего", -- 06081f
	[206] = "Чёрного с синим оттенком", -- 081327
	[207] = "Тёмно-синего", -- 1e394c
	[208] = "Тёмно-синего", -- 2c508c
	[209] = "Тёмно-синего", -- 154269
	[210] = "Тёмно-синего", -- 103150
	[211] = "Тёмно-синего", -- 241663
	[212] = "Тёмно-коричневого", -- 692115
	[213] = "Светло-серого", -- 8c8c94
	[214] = "Оливково-зелёного", -- 526013
	[215] = "Чёрного", -- 090f03
	[216] = "Оранжево-коричневого", -- 8d573b
	[217] = "Тёмно-голубого", -- 53888e
	[218] = "Оранжево-коричневого", -- 985c52
	[219] = "Тёмно-оранжевого", -- 99581e
	[220] = "Тёмно-розового", -- 993a62
	[221] = "Светло-зелёного", -- 99904f
	[222] = "Тёмно-оранжевого", -- 9a311e
	[223] = "Тёмно-синего", -- 0c1842
	[224] = "Тёмно-коричневого", -- 521f1e
	[225] = "Тёмно-оливкового", -- 42420c
	[226] = "Тёмно-зелёного", -- 4d991d
	[227] = "Тёмно-зелёного", -- 082a1c
	[228] = "Тёмно-жёлтого", -- 95821c
	[229] = "Зелёного", -- 197f19
	[230] = "Бурого", -- 3c141f
	[231] = "Тёмно-коричневого", -- 745117
	[232] = "Фиолетового", -- 893f8e
	[233] = "Фиолетового", -- 893f8e
	[234] = "Тёмно-зелёного", -- 0c370a
	[235] = "Тёмно-зелёного", -- 28450d
	[236] = "Тёмно-зелёного", -- 28450d
	[237] = "Тёмно-фиолетового", -- 784472
	[238] = "Зелено-коричневого", -- 8a6539
	[239] = "Коричнево-красного", -- 732518
	[240] = "Блестящего зеленовато-синего", -- 319491
	[241] = "Нежно-оливкового", -- 57941d
	[242] = "Бордово-фиолетового", -- 58163c
	[243] = "Ярко-зелёного", -- 1a8b31
	[244] = "Тёмно-коричневого", -- 38160c
	[245] = "Тёмно-зелёного", -- 051804
	[246] = "Тёмно-синего", -- 355d8e
	[247] = "Фиолетово-синего", -- 2f405c
	[248] = "Темного пурпурно-красного", -- 571a29
	[249] = "Очень темного красного", -- 4e0e28
	[250] = "Кварцево-зелёного", -- 706d68
	[251] = "Сланцево-серого", -- 3b3e43
	[252] = "Серого синего", -- 2e2d33
	[253] = "Пыльно-серого", -- 7c7e7d
	[254] = "Тёмно-серого", -- 4a4542
	[255] = "Тёмно-синего", -- 28344e
}

function get_veh_color()
    local closest_car = nil
    local closest_distance = 175
    local my_pos = {getCharCoordinates(PLAYER_PED)}
    local my_car
    if isCharInAnyCar(PLAYER_PED) then
        my_car = storeCarCharIsInNoSave(PLAYER_PED)
    end
    for _, vehicle in ipairs(getAllVehicles()) do
        if doesCharExist(getDriverOfCar(vehicle)) and vehicle ~= my_car then
            local vehicle_pos = {getCarCoordinates(vehicle)}
            local distance = getDistanceBetweenCoords3d(my_pos[1], my_pos[2], my_pos[3], vehicle_pos[1], vehicle_pos[2], vehicle_pos[3])
            if distance < closest_distance and vehicle ~= my_car then
                closest_distance = distance
                closest_car = vehicle
            end
        end
    end
    if closest_car then
        local clr1, clr2 = getCarColours(closest_car)
        local color1Name = colorNames[clr1] or ("Неизвестный цвет (" .. clr1 .. ")")
        return color1Name
    else
        sampAddChatMessage(script_tag..'{FFFFFF}Не удалось получить цвет ближайшего транспорта!', color_tag)
        return ''
    end
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
                    tick_tag = tick_tag:gsub('{getplnick%['.. num_id ..'%]}', u8'неизвестный')
                    sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {getplnick} не обнаружил игрока.', color_tag)
                end
            elseif tick_tag:find('{get_ru_nick%[(%d+)%]}') then
                local num_id = string.match(tick_tag, '{get_ru_nick%[(.-)%]}')
                if sampIsPlayerConnected(tonumber(num_id)) then
                    local latin_nick = sampGetPlayerNickname(tonumber(num_id)):gsub('_', ' ')
                    tick_tag = tick_tag:gsub('{get_ru_nick%['.. num_id ..'%]}', TranslateNick(latin_nick))
                else
                    tick_tag = tick_tag:gsub('{get_ru_nick%['.. num_id ..'%]}', u8'неизвестный')
                    sampAddChatMessage(script_tag..'{FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {get_ru_nick} не обнаружил игрока.', color_tag)
                end
            elseif tick_tag:find('{target}') then tick_tag = tick_tag:gsub('{target}', tostring(targ_id))
			elseif tick_tag:find('{get_city}') then tick_tag = tick_tag:gsub('{get_city}', get_city())
			elseif tick_tag:find('{get_square}') then tick_tag = tick_tag:gsub('{get_square}', get_square())
			elseif tick_tag:find('{get_area}') then tick_tag = tick_tag:gsub('{get_area}', get_area())
			elseif tick_tag:find('{get_storecar_model}') then tick_tag = tick_tag:gsub('{get_storecar_model}', get_storecar_model())
				            elseif tick_tag:find('{get_veh_status%[(%d+)%]}') then
                local num_id = string.match(tick_tag, '{get_veh_status%[(.-)%]}')
                tick_tag = tick_tag:gsub('{get_veh_status%['.. num_id ..'%]}', get_veh_status(tonumber(num_id)))
		elseif tick_tag:find('{sex}') then tick_tag = tick_tag:gsub('{sex}', get_sex_suffix())
		elseif tick_tag:find('{nearest}') then
			tick_tag = tick_tag:gsub('{nearest}', nearest(60))
		elseif tick_tag:find('{copy_nick%[(%d+)%]}') then
			local num_id = string.match(tick_tag, '{copy_nick%[(.-)%]}')
			if sampIsPlayerConnected(tonumber(num_id)) then
				local nickname = sampGetPlayerNickname(tonumber(num_id))
				setClipboardText(nickname)
				tick_tag = tick_tag:gsub('{copy_nick%['.. num_id ..'%]}', '')
			else
				tick_tag = tick_tag:gsub('{copy_nick%['.. num_id ..'%]}', '')
			end
		elseif tick_tag:find('{get_veh_color}') then tick_tag = tick_tag:gsub('{get_veh_color}', get_veh_color())
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
			
			
			elseif tick_tag:find('{sex:[%w%sа-яА-Я]*,[%w%sа-яА-Я]*}') then	
				for v in tick_tag:gmatch('{sex:[%w%sа-яА-Я]*,[%w%sа-яА-Я]*}') do
					local m, w = v:match('{sex:([%w%sа-яА-Я]*),([%w%sа-яА-Я]*)}')
					if setting.sex == u8'Мужской' then
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

function lec_start(text_arg, cmd_lec)
	if thread:status() ~= 'dead' then
		sampAddChatMessage(script_tag..'{FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}Page Down{FFFFFF}, чтобы остановить её.', color_tag)
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
			local f = io.open(dirml..'/StateHelper/Отыгровки/'..name_file_json..'.json', 'w')
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
			desc = u8'Приветствие',
			act = {
				{0, u8'Здравствуйте, меня зовут {mynickrus}, чем могу быть полез{sex:ен,на}?'}
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
				{0, u8'id игрока'},
				{1, u8'Причина'}
			},
			nm = 'exp',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'Выгнать из помещения',
			act = {
				{0, u8'/me резким движением руки ухватил{sex:ся,ась} за воротник нарушителя'},
				{0, u8'/do Крепко держит нарушителя за воротник.'},
				{0, u8'/todo Я вынужден{sex:,а} вывести вас из здания*направляясь к выходу'},
				{0, u8'/me движением левой руки открыл{sex:,а} входную дверь, после чего вытолкнул{sex:,а} нарушителя'},
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
				{0, u8'Пройдёмте за мной.'}
			},
			desc = u8'Отправит фразу "Пройдёмте за мной"',
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
				{0, u8'id игрока'}
			},
			nm = 'show',
			var = {},
			act = {
				{3, 1, 4, {u8'Паспорт', u8'Медицинская карта', u8'Лицензии', u8'Трудовая книжка'}},
				{8, '1', '1'},
				{0, u8'/do Паспорт гражданина находится в заднем кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} паспорт, после чего передал{sex:,а} его человеку напротив'},
				{0, u8'/showpass {arg1}'},
				{9, '1', '1'},
				{8, '1', '2'},
				{0, u8'/do Медицинская карта находится в нагрудном кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} мед. карту, после чего передал{sex:,а} её человеку напротив'},
				{0, u8'/showmc {arg1}'},
				{9, '1', '1'},
				{8, '1', '3'},
				{0, u8'/do Пакет лицензий находится в нагрудном кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} лицензии, после чего передал{sex:,а} их человеку напротив'},
				{0, u8'/showlic {arg1}'},
				{9, '1', '1'},
				{8, '1', '4'},
				{0, u8'/do Трудовая книжка находится во внутреннем кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} книжку, после чего передал{sex:,а} её человеку напротив'},
				{0, u8'/wbook {arg1}'},
				{9, '1', '1'}
			},
			desc = u8'Показать игроку свои документы',
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
				{3, 1, 2, {u8'Включить камеру', u8'Отключить камеру'}},
				{8, '1', '1'},
				{0, u8'/do Телефон находится в левом кармане.'},
				{0, u8'/me засунув руку в карман, достал{sex:,а} оттуда телефон, после чего заш{sex:ел,ла} в приложение \'Камера\''},
				{0, u8'/me нажав на кнопку записи, приступил{sex:,а} к съёмке происходящего'},
				{0, u8'/do Камера смартфона начала записывать видео и звук.'},
				{9, '1', '1'},
				{8, '1', '2'},
				{0, u8'/do Телефон находится в руке и ведёт запись.'},
				{0, u8'/me нажал{sex:,а} на кнопку отключения записи, после чего убрал{sex:,а} телефон в задний карман'},
				{0, u8'/do Видеофиксация происходящего приостановлена.'},
				{9, '1', '1'}
			},
			desc = u8'Начать или прекратить видеофиксацию',
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
			desc = u8'Сокращённая команда /members',
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
				{0, u8'id сотрудника'},
				{0, u8'Время в минутах'},
				{1, u8'Причина'}
			},
			nm = '+mute',
			var = {},
			act = {
				{0, u8'/do Рация весит на поясе.'},
				{0, u8'/me снял{sex:,а} рацию с пояса, после чего {sex:зашел,зашла} в настройки локальных частот вещания'},
				{0, u8'/me заглушил{sex:,а} локальную частоту вещания сотруднику {getplnick[{arg1}]}'},
				{0, u8'/fmute {arg1} {arg2} {arg3}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} была отключена рация. Причина: {arg3}'}
			},
			desc = u8'Выдать бан чата организации сотруднику',
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
				{0, u8'id сотрудника'}
			},
			nm = '-mute',
			var = {},
			act = {
				{0, u8'/do Рация весит на поясе.'},
				{0, u8'/me снял{sex:,а} рацию с пояса, после чего {sex:зашел,зашла} в настройки локальных частот вещания'},
				{0, u8'/me освободил{sex:,а} локальную частоту вещания сотруднику {getplnick[{arg1}]}'},
				{0, u8'/funmute {arg1}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} снова включена рация!'}
			},
			desc = u8'Снять бан чата организации сотруднику',
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
				{0, u8'id сотрудника'},
				{1, u8'Причина'}
			},
			nm = '+warn',
			var = {},
			tr_fl = {0, 0, 0},
			desc = u8'Выдать сотруднику выговор',
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/fwarn {arg1} {arg2}'},
				{0, u8'/r {getplnick[{arg1}]} получил строгий выговор! Причина: {arg2}'}
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
				{0, u8'id сотрудника'}
			},
			nm = '-warn',
			var = {},
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/unfwarn {arg1}'},
				{0, u8'/r Сотруднику {getplnick[{arg1}]} снят строгий выговор!'}
			},
			desc = u8'Снять выговор сотруднику',
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
				{0, u8'id игрока'}
			},
			nm = 'inv',
			var = {},
			act = {
				{0, u8'/do В кармане находятся ключи от шкафчика.'},
				{0, u8'/me потянувшись во внутренний карман, достал{sex:,а} оттуда ключ'},
				{0, u8'/me передал{sex:,а} ключ от шкафчика с формой человеку напротив'},
				{0, u8'/invite {arg1}'},
				{0, u8'/r Приветствуем нового сотрудника нашей организации - {getplnick[{arg1}]}'}
			},
			desc = u8'Принять игрока в организацию',
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
				{0, u8'id сотрудника'},
				{1, u8'Причина'}
			},
			nm = 'uninv',
			var = {},
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике {getplnick[{arg1}]}'},
				{0, u8'/uninvite {arg1} {arg2}'},
				{0, u8'/r Сотрудник {getplnick[{arg1}]} был уволен из организации. Причина: {arg2}'}
			},
			desc = u8'Уволить сотрудника',
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
				{0, u8'id сотрудника'},
				{0, u8'Номер ранга'}
			},
			nm = 'rank',
			var = {},
			act = {
				{0, u8'/do В кармане халата находится футляр с ключами от шкафчиков с формой.'},
				{0, u8'/me потянувшись во внутренний карман халата, достал{sex:,а} оттуда футляр'},
				{0, u8'/me открыв футляр, достал{sex:,а} оттуда ключ от шкафчика с формой'},
				{0, u8'/me передал{sex:,а} ключ от шкафчика человеку напротив'},
				{0, u8'/giverank {arg1} {arg2}'},
				{0, u8'/r Сотрудник {getplnick[{arg1}]} получил новую должность. Поздравляем!'}
			},
			desc = u8'Установить сотруднику ранг',
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
	
	if org_to_replace:find(u8'Больница') then
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'hl',
			var = {},
			act = {
				{0, u8'/do Медицинская сумка весит на левом плече.'},
				{0, u8'/me открыв сумку, достал{sex:,а} необходимое лекарство и передал{sex:,а} человеку напротив'},
				{0, u8'/heal {arg1} {pricelec}'}
			},
			desc = u8'Вылечить игрока',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('hl', u8'Вылечить игрока', add_table, '1')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'mc',
			var = {{1, '0'}, {1, '0'}, {1, '0'}},
			tr_fl = {0, 4, 14},
			desc = u8'Оформить медицинскую карту',
			act = {
				{0, u8'Вам необходимо получить новую медицинскую карту или обновить имеющуюся?'},
				{0, u8'Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт.'},
				{0, u8'/b Для этого введите /showpass {myid}'},
				{1, u8''},
				{0, u8'/me взял{sex:,а} паспорт из рук пациента и внимательно изучил{sex:,а} его'},
				{3, 1, 2, {u8'Новая мед. карта', u8'Обновить мед. карту'}},
				{8, '1', '1'},
				{0, u8'Стоимость оформления новой мед. карты зависит от её срока.'},
				{0, u8'7 дней: {med7}$. 14 дней: {med14}$'},
				{0, u8'30 дней: {med30}$. 60 дней: {med60}$'},
				{0, u8'Скажите на какой срок оформлять и мы продолжим.'},
				{3, 2, 4, {u8'7 дней', u8'14 дней', u8'30 дней', u8'60 дней'}},
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
				{0, u8'Стоимость обновления мед. карты зависит от её срока.'},
				{0, u8'7 дней: {medup7}$. 14 дней: {medup14}$'},
				{0, u8'30 дней: {medup30}$. 60 дней: {medup60}$'},
				{0, u8'Скажите на какой срок оформлять и мы продолжим.'},
				{3, 3, 4, {u8'7 дней', u8'14 дней', u8'30 дней', u8'60 дней'}},
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
				{0, u8'Хорошо, сейчас задам пару вопросов, отвечайте честно.'},
				{0, u8'Вы можете видеть имена проходящих мимо Вас людей?'},
				{1, ''},
				{0, u8'Вас когда-нибудь убивали?'},
				{3, 4, 4, {u8'Полностью здоров', u8'Наблюдаются откл.', u8'Псих. нездоров', u8'Неопределён'}},
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
				{0, u8'/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка'},
				{0, u8'/do Печать больницы нанесена на бланк.'},
				{0, u8'/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату'},
				{0, u8'/do Страница медицинской карты полностью заполнена.'},
				{0, u8'/me передаёт медицинскую карту в руки обратившемуся'},
				{0, u8'/medcard {arg1} {var2} {var3} {var1}'}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 29},
			key = {},
			num_d = 5,
			rank = '3'
		}
		create_file_json('mc', u8'Оформить медицинскую карту', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'narko',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили излечиться от наркозависимости.'},
				{0, u8'Стоимость одного сеанса составит {pricenarko}$'},
				{0, u8'Метод лечения современный, называется "Нейроочищение". Он полностью сотрёт информацию о наркотиках с Вашего мозга.'},
				{0, u8'Вы согласны? Если да, то ложитесь на кушетку и мы приступим.'},
				{1, ''},
				{0, u8'/do На столе лежат стерильные перчатки и медицинская маска.'},
				{0, u8'/me взяв со стола средства индивидуальной защиты, надел{sex:,а} их на себя'},
				{0, u8'/todo А теперь максимально расслабьтесь*подвигая спец. аппарат ближе к пациенту'},
				{0, u8'/me взял{sex:,а} шлем от аппарата, после чего надел{sex:,а} его на голову пациента'},
				{0, u8'/me включил{sex:,а} устройство, затем, подождав пять секунд, выключил{sex:,а} его'},
				{0, u8'/do Аппарат успешно завершил работу.'},
				{0, u8'/me снял{sex:,а} шлем с пациента и повесил{sex:,а} его обратно на аппарат'},
				{0, u8'/healbad {arg1}'},
				{0, u8'/todo Вот и всё! Тяга к запрещённым веществам должна исчезнуть*снимая с себя маску с перчатками'}
			},
			desc = u8'Вылечить от наркозависимости',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('narko', u8'Вылечить от наркозависимости', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = u8'rec',
			var = {
			{1, '0'}
			},
			act = {
				{0, u8'Мы выписываем рецепты в ограниченном количестве.'},
				{0, u8'/n Не более 5 штук в минуту.'},
				{0, u8'Стоимость одного рецепта составляет {pricerecept}$'},
				{0, u8'Вы согласны? Если да, то какое количество Вам необходимо?'},
				{3, 1, 5, {u8'1 рецепт', u8'2 рецепта', u8'3 рецепта', u8'4 рецепта', u8'5 рецептов'}},
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
				{0, u8'/do На столе лежат бланки для оформления рецептов.'},
				{0, u8'/me взяв ручку с печатью, заполнил{sex:,а} необходимые бланки, после чего поставил{sex:,а} печати в углу листа'},
				{0, u8'/do Все бланки рецептов успешно заполнены.'},
				{0, u8'/todo Держите и строго соблюдайте инструкцию!*передавая рецепты человеку напротив'},
				{0, u8'/recept {arg1} {var1}'}
			},
			desc = u8'Выписать рецепт',
			tr_fl = {0, 1, 5},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('rec', u8'Выписать рецепт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'osm',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили пройти медицинский осмотр.'},
				{0, u8'Предоставьте мне, пожалуйста, Вашу медицинскую карту.'},
				{1, u8''},
				{0, u8'/me берёт медицинскую карту в руки и внимательно её изучает'},
				{0, u8'Давайте начнём. Снимите всю одежду, кроме нижнего белья.'},
				{1, u8''},
				{0, u8'/medcheck {arg1} {priceosm}'},
				{0, u8'/me внимательно осматривает пациента на наличие кожных заболеваний'},
				{0, u8'/todo Поздравляю! У Вас всё отлично!*заканчивая медицинский осмотр'},
				{0, u8'/do Медицинская карта находится в левой руке.'},
				{0, u8'/me достав ручку из кармана, {sex:внес,внесла} несколько изменений в медицинскую карту'},
				{0, u8'/me передал{sex:,а} медицинскую карту обратно в руки пациенту'},
				{0, u8'На этом всё. Всего Вам доброго, не болейте!'}
			},
			desc = u8'Провести медицинский осмотр',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('osm', u8'Провести медицинский осмотр', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'tatu',
			var = {},
			act = {
				{0, u8'Сейчас мы начнём сеанс по выведению татуировки с Вашего тела.'},
				{0, u8'Покажите Ваш паспорт, пожалуйста.'},
				{1, ''},
				{0, u8'/me принял{sex:,а} с рук обратившегося паспорт'},
				{0, u8'/do Паспорт обратившегося в правой руке.'},
				{0, u8'/me ознакомившись с паспортом, вернул{sex:,а} его обратно владельцу'},
				{0, u8'Стоимость выведения татуировки составит {pricetatu}$. Вы согласны?'},
				{0, u8'/n Оплачивать не требуется, сервер сам предложит.'},
				{0, u8'/b Покажите татуировки с помощью команды /showtatu'},
				{1, ''},
				{0, u8'Я смотрю, Вы готовы, тогда снимайте с себя рубашку, чтобы я вывел{sex:,а} Вашу татуировку.'},
				{0, u8'/do У стены стоит инструментальный столик с подносом.'},
				{0, u8'/do Аппарат для выведения тату на подносе.'},
				{0, u8'/me взял{sex:,а} аппарат для выведения татуировки с подноса'},
				{0, u8'/me осмотрев пациента, принял{sex:ся,лась} выводить его татуировку'},
				{0, u8'/unstuff {arg1} {pricetatu}'}
			},
			desc = u8'Вывести татуировку с тела',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('tatu', u8'Вывести татуировку с тела', add_table, '7')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'ant',
			var = {},
			act = {
				{0, u8'Насколько я понял{sex:,а}, Вам нужны антибиотики.'},
				{0, u8'Стоимость одного антибиотика составляет {priceant}$. Вы согласны?'},
				{0, u8'Если да, то какое количество Вам необходимо?'},
				{1, ''},
				{0, u8'/me открыв мед.сумку, схватил{sex:ась,ся} за пачку антибиотиков, после чего вытянул{sex:,а} их и положил на стол'},
				{0, u8'/do Антибиотики находятся на столе.'},
				{0, u8'/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку'},
				{2, u8'Введите количество антибиотиков в чат.'},
				{0, u8'/antibiotik {arg1} '}
			},
			desc = u8'Выписать антибиотики',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '4'
		}
		create_file_json('ant', u8'Выписать антибиотики', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'cur',
			var = {},
			act = {
				{0, u8'/cure {arg1}'},
				{0, u8'/me легким движением руки открыл{sex:,а} мед. сумку, после чего достал{sex:,а} платок'},
				{0, u8'/me аккуратно приложил{sex:,а} платок ко рту пострадавшего, после чего сделал{sex:,а} глубокий вдох'},
				{0, u8'/do В лёгких много воздуха.'},
				{0, u8'/me встал{sex:,а} на колени, после чего прислонил{sex:ся,ась} к пациенту'},
				{0, u8'/me {sex:подвел,подвела} губы ко рту пострадавшего, после чего начал{sex:,а} делать искусственное дыхание'},
				{0, u8'/me отвел{sex:,а} губы от рта пострадавшего, после чего сделал{sex:,а} глубокий вдох'},
				{0, u8'/me подвел{sex:,а} губы ко рту пострадавшего, после чего начал{sex:,а} делать искусственное дыхание'},
				{0, u8'/todo Сейчас аккуратно поднимайтесь*помогая встать'}
			},
			desc = u8'Поднять человека присмерти',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '2'
		}
		create_file_json('cur', u8'Поднять человека присмерти', add_table, '2')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'strah',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили оформить медицинскую страховку.'},
				{0, u8'С ней Вы сможете лечиться за счёт государства.'},
				{0, u8'/me достаёт из под стола пустой бланк, после чего начинает его заполнять'},
				{0, u8'/me заполнив бланк, передаёт его человеку напротив и говорит:'},
				{0, u8'Это бумажная копия, сейчас впишу Вас в базу данных.'},
				{0, u8'/me вбивает человека напротив в компьютер, находящийся на столе'},
				{0, u8'/do Обратившийся внесён в базу данных страхования.'},
				{0, u8'/todo Поздравляю! Вы официально застрахованы!*заканчивая оформление'},
				{0, u8'/givemedinsurance {arg1}'}
			},
			desc = u8'Оформить медицинскую страховку',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('strah', u8'Оформить медицинскую страховку', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'mt',
			var = {},
			act = {
				{0, u8'Очень замечательно, что Вы решили пройти обследование.'},
				{0, u8'Ведь с некоторыми заболеваниями служить крайне не рекомендуется!'},
				{0, u8'/do На плече висит медицинская сумка.'},
				{0, u8'/me достаёт необходимые средства из сумки для дальнейшего осмотра пациента'},
				{0, u8'/todo Сейчас расслабьтесь, это займёт немного времени*начиная осмотр'},
				{0, u8'/mticket {arg1}'}
			},
			desc = u8'Провести обследование для военного билета',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '3'
		}
		create_file_json('mt', u8'Провести обследование для военного билета', add_table, '4')
		add_table = {
			arg = {},
			nm = 'hme',
			var = {},
			act = {
				{0, u8'/me открыв сумку, достал{sex:,а} необходимое лекарство и моментально его выпил{sex:,а}'},
				{0, u8'/heal {myid} 5000'}
			},
			desc = u8'Вылечить самого себя',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '1'
		}
		create_file_json('hme', u8'Вылечить самого себя', add_table, '4')
		
		
		setting.fast_acc.sl = {
			{
				text = u8'Вылечить',
				cmd = 'hl',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'mc',
				pass_arg = true,
				text = u8'Оформить мед. карту'
			},
			{
				send_chat = true,
				cmd = 'osm',
				pass_arg = true,
				text = u8'Мед. осмотр'
			},
			{
				text = u8'Излечить от нарко',
				cmd = 'narko',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Выдать рецепт',
				cmd = 'rec',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Выписать антибиотики',
				cmd = 'ant',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Осмотр на военный билет',
				cmd = 'mt',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Оформить страховку',
				cmd = 'strah',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'cur',
				pass_arg = true,
				text = u8'Поднять при смерти'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'Поздароваться'
			},
			{
				send_chat = true,
				cmd = 'za',
				pass_arg = true,
				text = u8'Пройдёмте за мной'
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'Центр Лицензирования') then
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmauto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на вождение автомобиля',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {priceauto1}$, на 2 месяца {priceauto2}$, на 3 месяца {priceauto3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на авто'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[0][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '1'
		}
		create_file_json('licauto', u8'Продать лицензию на вождение автомобиля', add_table, '1')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmoto',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на вождение мотоцикла',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricemoto1}$, на 2 месяца {pricemoto2}$, на 3 месяца {pricemoto3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на мото'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[1][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '2'
		}
		create_file_json('licmoto', u8'Продать лицензию на вождение мотоцикла', add_table, '2')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licfly',
			var = {{1, '0'}},
			tr_fl = {0, 0, 0},
			desc = u8'Продать лицензию на полёты',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии составляет {pricefly}$. Вы согласны?'},
				{1, u8''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на полёты'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[2][0][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1,
			rank = '7'
		}
		create_file_json('licfly', u8'Продать лицензию на полёты', add_table, '7')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licfish',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на рыболовство',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricefish1}$, на 2 месяца {pricefish2}$, на 3 месяца {pricefish3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на рыболовство'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[3][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '3'
		}
		create_file_json('licfish', u8'Продать лицензию на рыболовство', add_table, '3')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licswim',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на водный транспорт',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {priceswim1}$, на 2 месяца {priceswim2}$, на 3 месяца {priceswim3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на вод. транспорт'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[4][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '4'
		}
		create_file_json('licswim', u8'Продать лицензию на водный транспорт', add_table, '4')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'licgun',
			var = {
				{1, '0'}
			},
			tr_fl = {0, 2, 8},
			desc = u8'Продать лицензию на оружие',
			act = {
				{0, u8'Для оформления лицензии на оружие, мне нужно убедиться, что Вы здоровы.'},
				{0, u8'Покажите, пожалуйста, Вашу медицинскую карту.'},
				{0, u8'/n /showmc {myid}'},
				{3, 1, 3, {u8'Здоров', u8'Имеются отклонения', u8'Нет мед. карты'}},
				{8, '1', '1'},
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricegun1}$, на 2 месяца {pricegun2}$, на 3 месяца {pricegun3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 2, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '2', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '2', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '2', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на оружие'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[5][{var1}][{arg1}]}'},
				{9, ''},
				{8, '1', '2'},
				{0, u8'Извините, но я не могу оформить Вам лицензию на оружие в связи с состоянием здоровья.'},
				{0, u8'Вы можете снова пройти мед. обследование в больнице и вернуться к нам.'},
				{9, ''},
				{8, '1', '3'},
				{0, u8'Извините, но сейчас я не могу оформить Вам лицензию на оружие.'},
				{0, u8'У Вас отсутствует медицинская карта. Оформить её можно в ближайшей больнице.'},
				{9, ''}
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 3,
			rank = '5'
		}
		create_file_json('licgun', u8'Продать лицензию на оружие', add_table, '5')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'lichunt',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на охоту',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricehunt1}$, на 2 месяца {pricehunt2}$, на 3 месяца {pricehunt3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на охоту'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[6][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '5'
		}
		create_file_json('lichunt', u8'Продать лицензию на охоту', add_table, '5')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licdig',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию на раскопки',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {priceexc1}$, на 2 месяца {priceexc2}$, на 3 месяца {priceexc3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на раскопки'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[7][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licdig', u8'Продать лицензию на раскопки', add_table, '6')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'lictaxi',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию для работы в такси',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricetaxi1}$, на 2 месяца {pricetaxi2}$, на 3 месяца {pricetaxi3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на такси'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[8][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('lictaxi', u8'Продать лицензию для работы в такси', add_table, '6')
		add_table = {
			arg = {{0, u8'id игрока'}},
			nm = 'licmec',
			var = {{1, '0'}},
			tr_fl = {0, 1, 3},
			desc = u8'Продать лицензию для работы на механика',
			act = {
				{0, u8'/me достал{sex:,а} из под стола пустой бланк для выдачи лицензии'},
				{0, u8'Стоимость лицензии зависит от её срока.'},
				{0, u8'На 1 месяц {pricemeh1}$, на 2 месяца {pricemeh2}$, на 3 месяца {pricemeh3}$'},
				{0, u8'На какой срок оформляем?'},
				{3, 1, 3, {u8'1 месяц', u8'2 месяца', u8'3 месяца'}},
				{8, '1', '1'},
				{5, '{var1}', '0'},
				{9, ''},
				{8, '1', '2'},
				{5, '{var1}', '1'},
				{9, ''},
				{8, '1', '3'},
				{5, '{var1}', '2'},
				{9, ''},
				{0, u8'/me засунул{sex:,а} бланк в принтер, после чего распечатал{sex:,а} лицензию на механика'},
				{0, u8'/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив'},
				{0, u8'{dialoglic[9][{var1}][{arg1}]}'},
			},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 2,
			rank = '6'
		}
		create_file_json('licmec', u8'Продать лицензию на механика', add_table, '6')
		
		setting.fast_acc.sl = {
			{
				text = u8'Лицензия на авто',
				cmd = 'licauto',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'licmoto',
				pass_arg = true,
				text = u8'Лицензия на мото'
			},
			{
				text = u8'Лицензия на рыбу',
				cmd = 'licfish',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Лицензия на плавание',
				cmd = 'licswim',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Лицензия на оружие',
				cmd = 'licgun',
				pass_arg = true,
				send_chat = true
			},
			{
				send_chat = true,
				cmd = 'lichunt',
				pass_arg = true,
				text = u8'Лицензия на охоту'
			},
			{
				send_chat = true,
				cmd = 'licdig',
				pass_arg = true,
				text = u8'Лицензия на раскопки'
			},
			{
				send_chat = true,
				cmd = 'lictaxi',
				pass_arg = true,
				text = u8'Лицензия на такси'
			},
			{
				send_chat = true,
				cmd = 'licmec',
				pass_arg = true,
				text = u8'Лицензия на механика'
			},
			{
				send_chat = true,
				cmd = 'licfly',
				pass_arg = true,
				text = u8'Лицензия на полёты'
			},
			{
				send_chat = true,
				cmd = 'z',
				pass_arg = true,
				text = u8'Поздароваться'
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	elseif org_to_replace:find(u8'ТСР') then
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'pass',
			var = {},
			rank = '6',
			act = {
				{0, u8'/do Бланк для замены информации в паспорте находится под столом.'},
				{0, u8'/me засунув руку под стол, взял{sex:,а} бланк, после чего протянул{sex:,а} его человеку напротив'},
				{0, u8'/todo Впишите сюда новую дату и поставьте подпись снизу*протягивая лист с ручкой'},
				{0, u8'{dialoggov[0][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'Изменить дату рождения в паспорте',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('pass', u8'Изменить дату рождения в паспорте', add_table, '6')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'visa',
			var = {},
			rank = '3',
			act = {
				{0, u8'Стоимость услуги составляет 500.000$. Вы согласны? Если да, то мы продолжим.'},
				{1, ''},
				{0, u8'/do Бланк для оформления визы находится под столом.'},
				{0, u8'/me засунув руку под стол, взял{sex:,а} бланк, после чего протянул{sex:,а} его человеку напротив'},
				{0, u8'/todo Впишите сюда ваши данные и поставьте подпись снизу*протягивая лист с ручкой'},
				{0, u8'{dialoggov[1][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'Оформить визу для перелётов в Vice City',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('visa', u8'Оформить визу для перелётов в Vice City', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'car',
			var = {},
			rank = '5',
			act = {
				{0, u8'/do Бланк для получения сертификата находится под столом.'},
				{0, u8'/me засунув руку под стол, взял{sex:,а} бланк, после чего протянул{sex:,а} его человеку напротив'},
				{0, u8'/todo Впишите сюда ваши данные и поставьте подпись снизу*протягивая лист с ручкой'},
				{0, u8'{dialoggov[2][{arg1}]}'}
			},
			tr_fl = {0, 0, 0},
			desc = u8'Превратить личное т/с в сертификат',
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('car', u8'Превратить личное т/с в сертификат', add_table, '5')
		add_table = {
			 arg = {
				{0, u8'id игрока'}
			},
			nm = 'visit',
			var = {},
			rank = '3',
			act = {
				{0, u8'/me вытащил{sex:,а} из нагрудного кармана визитку адвоката'},
				{0, u8'/do На визитке написано: {mynickrus}, адвокат штата.'},
				{0, u8'/showvisit {arg1}'}
			},
			desc = u8'Показать визитку адвоката',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('visit', u8'Показать визитку адвоката', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'},
				{0, u8'Цена'}
			},
			nm = 'freely',
			var = {},
			rank = '3',
			act = {
				{0, u8'/do Папка с документами находится в левой руке.'},
				{0, u8'/me открыв папку, вытащил{sex:,а} из неё бланк для освобождения заключённого'},
				{0, u8'/me достав из кармана ручку, заполнил{sex:,a} документ и передал{sex:,a} человеку напротив'},
				{0, u8'/todo Впишите сюда свои данные и поставьте подпись снизу*передавая лист с ручкой'},
				{0, u8'/free {arg1} {arg2}'}
			},
			desc = u8'Предложить услуги адвоката',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('freely', u8'Предложить услуги адвоката', add_table, '3')
		add_table = {
			arg = {
				{0, u8'id игрока'}
			},
			nm = 'lic',
			var = {},
			rank = '9',
			act = {
				{0, u8'/do Бланк для выдачи лицензии находится под столом.'},
				{0, u8'/me засунув руку под стол, взял{sex:,а} бланк, после чего заполнил{sex:,а} его нужной информацией'},
				{0, u8'/todo Впишите сюда Ваши данные и поставьте подпись снизу*передавая бланк и ручку'},
				{0, u8'/givelicadvokat {arg1}'}
			},
			desc = u8'Выдать лицензию адвоката',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('lic', u8'Выдать лицензию адвоката', add_table, '9')
		add_table = {
			arg = {
				{0, u8'id жениха'},
				{0, u8'id невесты'}
			},
			nm = 'wed',
			var = {},
			rank = '6',
			act = {
				{0, u8'Приветствую, уважаемые новобрачные и гости!'},
				{0, u8'Уважаемые невеста и жених!'},
				{0, u8'Сегодня - самое прекрасное и незабываемое событие в вашей жизни.'},
				{0, u8'С этого дня вы пойдёте по жизни рука об руку, вместе переживая и радость счастливых дней, и огорчения.'},
				{0, u8'Создавая семью, вы добровольно приняли на себя великий долг друг перед другом и перед будущим ваших детей.'},
				{0, u8'С вашего взаимного согласия, выраженного в присутствии свидетелей, ваш брак регистрируется.'},
				{0, u8'Прошу вас в знак любви и преданности друг другу обменяться обручальными кольцами.'},
				{0, u8'/wedding {arg1} {arg2}'},
				{1, ''},
				{0, u8'Совет вам да любовь! Можете поцеловаться!'}
			},
			desc = u8'Заключить брак',
			tr_fl = {0, 0, 0},
			delay = 3000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('wed', u8'Заключить брак', add_table, '6')
		add_table = {
			arg = {
				{0, u8'id игрока'},
				{1, u8'Причина'}
			},
			nm = 'uvalgos',
			var = {},
			rank = '9',
			act = {
				{0, u8'/do В левом кармане лежит телефон.'},
				{0, u8'/me достал{sex:,а} телефон из кармана, после чего {sex:зашел,зашла} в базу данных организации'},
				{0, u8'/me изменил{sex:,а} информацию о сотруднике государственной структуры'},
				{0, u8'/demoute {arg1} {arg2}'}
			},
			desc = u8'Уволить госслужащего',
			tr_fl = {0, 0, 0},
			delay = 2000,
			not_send_chat = false,
			add_f = {false, 1},
			key = {},
			num_d = 1
		}
		create_file_json('uvalgos', u8'Уволить госслужащего', add_table, '9')
		
		setting.fast_acc.sl = {
			{
				text = u8'Поздароваться',
				cmd = 'z',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Оформить визу',
				cmd = 'visa',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'т/с в сертификат',
				cmd = 'car',
				pass_arg = true,
				send_chat = true
				
			},
			{
				text = u8'Поменять паспорт',
				cmd = 'pass',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Визитка адвоката',
				cmd = 'visit',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Лицензию адвоката',
				cmd = 'lic',
				pass_arg = true,
				send_chat = true
			},
			{
				text = u8'Выгнать',
				cmd = 'exp',
				pass_arg = true,
				send_chat = false
			}
		}
		save('setting')
	end
end


local to_lower = {
    [168] = 'ё', [192] = 'а', [193] = 'б', [194] = 'в', [195] = 'г',
    [196] = 'д', [197] = 'е', [198] = 'ж', [199] = 'з', [200] = 'и',
    [201] = 'й', [202] = 'к', [203] = 'л', [204] = 'м', [205] = 'н',
    [206] = 'о', [207] = 'п', [208] = 'р', [209] = 'с', [210] = 'т',
    [211] = 'у', [212] = 'ф', [213] = 'х', [214] = 'ц', [215] = 'ч',
    [216] = 'ш', [217] = 'щ', [218] = 'ъ', [219] = 'ы', [220] = 'ь',
    [221] = 'э', [222] = 'ю', [223] = 'я', [224] = 'а', [225] = 'б',
    [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж',
    [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л',
    [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р',
    [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х',
    [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ',
    [251] = 'ы', [252] = 'ь', [253] = 'ё', [254] = 'Э', [255] = 'Ю'
}

local to_upper = {
    [168] = 'Ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г',
    [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И',
    [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н',
    [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т',
    [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч',
    [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь',
    [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'А', [225] = 'Б',
    [226] = 'В', [227] = 'Г', [228] = 'Д', [229] = 'Е', [230] = 'Ж',
    [231] = 'З', [232] = 'И', [233] = 'Й', [234] = 'К', [235] = 'Л',
    [236] = 'М', [237] = 'Н', [238] = 'О', [239] = 'П', [240] = 'Р',
    [241] = 'С', [242] = 'Т', [243] = 'У', [244] = 'Ф', [245] = 'Х',
    [246] = 'Ц', [247] = 'Ч', [248] = 'Ш', [249] = 'Щ', [250] = 'Ъ',
    [251] = 'Ы', [252] = 'Ь', [253] = 'Ё', [254] = 'Э', [255] = 'Ю'
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
    input = input:gsub('%.%.+$', '')
    if not input:match('%.$') then
        input = input .. '.'
    end
    local first_char = convertCase(input:sub(1, 1), "rupper")
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
            sampAddChatMessage("Некорректный ввод. Используйте формат: /todo Фраза*Действие", 0xFF0000)
        end
    end
end

sampRegisterChatCommand('me', function(input) handleCommand('me', input) end)
sampRegisterChatCommand('do', function(input) handleCommand('do', input) end)
sampRegisterChatCommand('todo', function(input) handleCommand('todo', input) end)


function hook.onServerMessage(mes_color, mes)
	local mes_color_hex = (bit.tohex(bit.rshift(mes_color, 8), 6))
	local save_chat = true
	
	if setting.chat_pl then
		if mes:find('Объявление:') or mes:find('Отредактировал сотрудник') then
			save_chat = false
			return false
		end
	end
	if setting.chat_smi then
		if mes:find('News LS') or mes:find('News SF') or mes:find('News LV') then
			save_chat = false
			return false
		end
		if mes:find('Гость') or mes:find('Репортёр') then
			if mes_color_hex == '9acd32' then
				save_chat = false
				return false
			end
		end
	end
	if setting.chat_help then
		if mes:find('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') or mes:find('- Основные команды сервера: /menu /help /gps /settings') 
		or mes:find('Пригласи друга и получи бонус в размере') or mes:find('- Донат и получение дополнительных средств arizona-rp.com/donate') 
		or mes:find('Подробнее об обновлениях сервера') or mes:find('(Личный кабинет/Донат)') or mes:find('С помощью телефона можно заказать') 
		or mes:find('В нашем магазине ты можешь') or mes:find('их на желаемый тобой {FFFFFF}бизнес') or mes:find('Игроки со статусом (.+)имеют больше возможностей') 
		or mes:find('можно приобрести редкие {FFFFFF}автомобили, аксессуары, воздушные') or mes:find('предметы, которые выделят тебя из толпы! Наш сайт:') 
		or mes:find('Вы можете купить складское помещение') or mes:find('Таким образом вы можете сберечь своё имущество, даже если вас забанят.') 
		or mes:find('Этот тип недвижимости будет навсегда закреплен за вами и за него не нужно платить.') or mes:find('{ffffff}Уважаемые жители штата, открыта продажа билетов на рейс:') 
		or mes:find('{ffffff}Подробнее: {FF6666}/help — Перелёты в город Vice City.') or mes:find('{ffffff}Внимание! На сервере Vice City действует акция Х3 PayDay.') 
		or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут бесплатно раз в день получать') or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут получать (.+) Ларца Олигарха')
		or mes:find('Игроки со статусом (.+)имеют большие возможности') then 
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
		if mes:find('[FOREVER]') or mes:find('[VIP ADV]') or mes:find('[VIP]') then
			if mes_color_hex == 'ffd700' or mes_color_hex == 'f345fc' or mes_color_hex == 'fd446f' or mes_color_hex == '6495ED' then
				save_chat = false
				return false
			end
		end
	end
	
	if mes:find('Администратор ((%w+)_(%w+)):(.+)спавн') or mes:find('Администратор (%w+)_(%w+):(.+)Спавн') then
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
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag)..'(.+)связь') then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en)..'(.+)связь') and setting.dep.my_tag_en ~= '' then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.my_tag_en2)..'(.+)связь') and setting.my_tag_en2 ~= '' then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.my_tag_en3)..'(.+)связь') and setting.my_tag_en3 ~= '' then
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
					sampAddChatMessage(script_tag..'{e3a220}Вашу организацию вызывают в рации департамента!', color_tag)
					sampAddChatMessage(script_tag..'{e3a220}Вашу организацию вызывают в рации департамента!', color_tag)
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
		if mes:find('%[Новое предложение%]{ffffff} Вам поступило предложение от игрока(.+)%. Используйте команду%: %/offer или клавишу X') then
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
	if mes:find('Организационная зарплата: $(%d+)') then
		local mes_pay = mes:match('Организационная зарплата: $(.+)'):gsub('%D', '')
		if setting.frac.org:find(u8'Больница') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
			setting.stat.hosp.payday[1] = setting.stat.hosp.payday[1] + tonumber(mes_pay)
		end
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы вылечили (.+) за ') then
		local mes_pay = mes:match('$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) * 0.6, 1)
		setting.stat.hosp.lec[1] = setting.stat.hosp.lec[1] + round(tonumber(mes_pay) * 0.6, 1)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы выдали (.+) сроком') then
		local mes_pay = mes:match(' на (%d+)')
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
	if mes:find('%[Информация%] {FFFFFF}Вы начали лечение (.+) от наркозависимости за ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (tonumber(mes_pay) * 0.8)
		setting.stat.hosp.apt[1] = setting.stat.hosp.apt[1] + (tonumber(mes_pay) * 0.8)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы продали антибиотики (.+) игроку (.+) за (.+)ваша') then
		local mes_pay = mes:match('прибыль: $(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(mes_pay)
		setting.stat.hosp.ant[1] = setting.stat.hosp.ant[1] + tonumber(mes_pay)
		save('setting')
	end
	if mes:find('%[Информация%] {FFFFFF}Вы продали (%d+) рецептов (.+) за ') then
		local mes_pay = mes:match('%$(.+)'):gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + round(tonumber(mes_pay) / 2, 1)
		setting.stat.hosp.rec[1] = setting.stat.hosp.rec[1] + round(tonumber(mes_pay) / 2, 1)
		save('setting')
	end
	if sampGetGamestate() == 3 then
		if mes:find('>>>{FFFFFF} '..my.nick..'%[(%d+)%] доставил 100 медикаментов на склад больницы!') then
			setting.stat.hosp.total_all = setting.stat.hosp.total_all + 450000
			setting.stat.hosp.medcam[1] = setting.stat.hosp.medcam[1] + 450000
			save('setting')
		end
	end
	if mes:find('Вы поставили на ноги игрока (.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 300000
		setting.stat.hosp.cure[1] = setting.stat.hosp.cure[1] + 300000
		save('setting')
	end
	if mes:find('Вы получили премию за(.+)ботам на улице') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 8000
		setting.stat.hosp.cure[1] = setting.stat.hosp.cure[1] + 8000
		save('setting')
	end
	if mes:find('Вы получили(.+)за ящик с медикаментами') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + 8500
		setting.stat.hosp.medcam[1] = setting.stat.hosp.medcam[1] + 8500
		save('setting')
	end
	if mes:find('Вы успешно провели медицинский осмотр(.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (setting.priceosm * 0.7)
		setting.new_stat_bl.osm[1] = setting.new_stat_bl.osm[1] + (setting.priceosm * 0.7)
		save('setting')
	end
	if mes:find('Вы не смогли найти законные основания для получения военного билета(.+)') then
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + (setting.priceosm * 0.7)
		setting.new_stat_bl.ticket[1] = setting.new_stat_bl.ticket[1] + 210000
		save('setting')
	end
	if mes:find('^1%) %+%$%d+$') then
		local money_adw = mes:gsub('1%) %+%$', '')
		money_adw = money_adw:gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(money_adw)
		setting.new_stat_bl.awards[1] = setting.new_stat_bl.awards[1] + tonumber(money_adw)
		save('setting')
	end
	if mes:find('^2%) %+%$%d+$') then
		local money_adw = mes:gsub('2%) %+%$', '')
		money_adw = money_adw:gsub('%D', '')
		setting.stat.hosp.total_all = setting.stat.hosp.total_all + tonumber(money_adw)
		setting.new_stat_bl.awards[1] = setting.new_stat_bl.awards[1] + tonumber(money_adw)
		save('setting')
	end
	
	if mes:find('%[Информация%] %{FFFFFF%}Вы предложили (.+) купить лицензию(.+)') then
		local price_lic_i = mes:match(' за %$(%d+)')
		price_lic = tonumber(price_lic_i) / 2
	end
	if mes:find('%[Информация%] {FFFFFF}Вы успешно продали лицензию') then
		local lic_type = mes:match('%[Информация%] {FFFFFF}Вы успешно продали лицензию (.+) игроку')
		if lic_type == 'авто' then
			setting.stat.school.auto[1] = setting.stat.school.auto[1] + price_lic
		elseif lic_type == 'мото' then
			setting.stat.school.moto[1] = setting.stat.school.moto[1] + price_lic
		elseif lic_type == 'на рыбалку' then
			setting.stat.school.fish[1] = setting.stat.school.fish[1] + price_lic
		elseif lic_type == 'на плавание' then
			setting.stat.school.swim[1] = setting.stat.school.swim[1] + price_lic
		elseif lic_type == 'на оружие' then
			setting.stat.school.gun[1] = setting.stat.school.gun[1] + price_lic
		elseif lic_type == 'на охоту' then
			setting.stat.school.hun[1] = setting.stat.school.hun[1] + price_lic
		elseif lic_type == 'на раскопки' then
			setting.stat.school.exc[1] = setting.stat.school.exc[1] + price_lic
		elseif lic_type == 'таксиста' then
			setting.stat.school.taxi[1] = setting.stat.school.taxi[1] + price_lic
		elseif lic_type == 'механика' then
			setting.stat.school.meh[1] = setting.stat.school.meh[1] + price_lic
		end
		setting.stat.school.total_all = setting.stat.school.total_all + price_lic
		save('setting')
	end
	if mes:find('AIberto_Kane(.+):(.+)vizov1488sh') or mes:find('Alberto_Kane(.+):(.+)vizov1488sh') or mes:find('Ilya_Kustov(.+):(.+)vizov1488sh') then
		if mes:find('AIberto_Kane(.+){B7AFAF}') or mes:find('Alberto_Kane(.+){B7AFAF}') then
			save_chat = false
			local rever = 0
			sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 разработчик скрипта State Helper - {2b8200}Alberto_Kane', 'Закрыть', '', 0)
			sampAddChatMessage(script_tag..'Это сообщение подтверждает, что к Вам обращается разработчик State Helper - {39e3be}Alberto_Kane.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		elseif mes:find('Ilya_Kustov(.+){B7AFAF}') then
			local rever = 0
			sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 QA-инженер скрипта State Helper - {2b8200}Ilya_Kustov', 'Закрыть', '', 0)
			sampAddChatMessage(script_tag..'Это сообщение подтверждает, что к Вам обращается QA-инженер State Helper - {39e3be}Ilya_Kustov.', 0xFF5345)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					rever = rever + 1
					until rever > 10
			end)
			return false
		end
	end
	if mes:find('AIberto_Kane(.+):(.+)vizovshblock'..my.id) or mes:find('Alberto_Kane(.+):(.+)vizovshblock'..my.id) then
		save_chat = false
		setting.fun_block = not setting.fun_block
		if setting.fun_block then
			sampAddChatMessage(script_tag..'{FFFFFF}Разработчик скрипта заблокировал Вам возможность пользоваться им.', 0xFF5345)
		else
			sampAddChatMessage(script_tag..'{FFFFFF}Разработчик скрипта разблокировал Вам его функциональность.', 0xFF5345)
		end
		save('setting')
		return false
	end
	if mes:find('Вы не можете продавать лицензии на такой срок') then
		num_give_lic = -1
		sampAddChatMessage(script_tag..'{FFFFFF}Ваш ранг не позволяет выдать эту лицензию!', 0xFF5345)
		return false
	end
	if mes:find('На сервере есть инвентарь, используйте клавишу Y для работы с ним') then
		close_serv = false
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		my = {id = myid, nick = sampGetPlayerNickname(myid)}
	end
	if mes:find('Данная возможность доступна с 5 ранга') and setting.anti_alarm_but then
		return false
	end
	
	if mes:find('Очевидец сообщает о пострадавшем человеке(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func then
		text_godeath = mes
		return false
	end
	
	if mes:find('Чтобы принять вызов, введите(.+)godeath(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func then
		local id_pl_godeath = mes:match('godeath%s-(%d+)')
		local area, location = '[ОШИБКА ЧТЕНИЯ]', '[ОШИБКА ЧТЕНИЯ]'
		local my_pos_int_or_around = getActiveInterior()
		local coord_area = ''
		local text_cmd = ''
		area, location = text_godeath:match('районе%s+(.-)%s*%((.-)%)')
		id_player_godeath = id_pl_godeath
		
		
		if setting.godeath.cmd_go then
			text_cmd = ' /go или'
		end
		if setting.godeath.meter then
			coord_area = measurement_coordinates(area, my_pos_int_or_around, location)
		end
		
		local c = imgui.ImVec4(setting.color_godeath[1], setting.color_godeath[2], setting.color_godeath[3], 1.00)
		local argb = imgui.ColorConvertFloat4ToARGB(c)
		local col_mes_godeath = '0x'.. (ARGBtoStringRGB(imgui.ColorConvertFloat4ToARGB(c))):gsub('[%{%}]', '')
		sampAddChatMessage('Поступил вызов в районе '.. area ..' ('.. location .. ')'.. coord_area ..'. Введите'.. text_cmd ..' /godeath '.. id_pl_godeath, col_mes_godeath)
	
		if setting.godeath.two_text then
			return false
		end
	end
	
	if mes:find('%[Диспетчер%] (.+)'.. my.nick ..' принял вызов пациента(.+)') and mes_color_hex == 'ff5350' and setting.godeath.func and setting.godeath.auto_send then
		sampAddChatMessage(mes, '0x'..mes_color_hex)
		sampSendChat('/r Принял вызов от пострадавшего. Немедленно выдвигаюсь для оказания помощи.')
	end
	
	if not mes:find('(.+)%[(.+)%] говорит:(.+)') and mes_color_hex ~= 'ff99ff' and mes_color_hex ~= '4682b4' 
	and not mes:find('(.+)%- сказал%(а%)(.+)%[(.+)%]') and not mes:find('(.+)%[(.+)%](.+)Неудачно') 
	and not mes:find('(.+)%[(.+)%](.+)Удачно') and setting.fast_chat[1] and not setting.fast_chat[2] then
		if setting.fast_chat[1] and not setting.fast_chat[2] then
			return false
		elseif setting.fast_chat[2] then
			if not mes:find(my.nick..'%[(.+)%] говорит:(.+)') and not mes:find('(.+)%- сказал%(а%) '..my.nick..'%[(.+)%]') 
			and not mes:find(my.nick..'%[(.+)%](.+)Неудачно') and not mes:find(my.nick..'%[(.+)%](.+)Удачно') then
				if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= 'ff99ff' then
					if not mes:find(my.nick..'%[(.+)%]') and mes_color_hex ~= '4682b4' then
						return false
					end
				end
			end
		end
	elseif not mes:find(my.nick..'%[(.+)%] говорит:(.+)') and not mes:find('(.+)%- сказал%(а%) '..my.nick..'%[(.+)%]') 
	and not mes:find(my.nick..'%[(.+)%](.+)Неудачно') and not mes:find(my.nick..'%[(.+)%](.+)Удачно') then
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
	
--> Проверка обновлений
function update_check()
	upd_status = 1
	local upd_txt_info = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F.json'
	local dir = dirml..'/StateHelper/Для обновления/Информация.json'
	downloadUrlToFile(upd_txt_info, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(2500)
				if doesFileExist(dirml..'/StateHelper/Для обновления/Информация.json') then
					local f = io.open(dirml..'/StateHelper/Для обновления/Информация.json', 'r')
					upd = decodeJson(f:read('*a'))
					f:close()
					
					local new_version = upd.version:gsub('%D', '')
					if tonumber(new_version) > scr_version then
						download_id = downloadUrlToFile(upd.image, getWorkingDirectory()..'/StateHelper/Изображения/Новая версия.png', function(id, status, p1, p2)
							if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
								IMG_New_Version = imgui.CreateTextureFromFile(getWorkingDirectory()..'/StateHelper/Изображения/Новая версия.png')
								upd_status = 2
								if not setting.auto_update then
									addOneOffSound(0, 0, 0, 1058)
								else
									addOneOffSound(0, 0, 0, 1058)
									sampAddChatMessage(script_tag..'{FFFFFF}Скачивание обновления...', color_tag)
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

--> Скачивание обновления
function update_download()
	local dir = dirml..'/StateHelper.lua'
	lua_thread.create(function()
		wait(2000)
		downloadUrlToFile(url_upd, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print('{FF0000}Ошибка при попытке скачать файл.') 
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage(script_tag..'{FFFFFF}Произошла неизвестная ошибка при скачивании обновления.', color_tag)
					lua_thread.create(function()
						wait(500)
						update_error()
					end)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				print('Загрузка завершена успешно.')
				sampAddChatMessage(script_tag..'{FFFFFF}Скачивание успешно завершено! Перезагрузка скрипта...', color_tag)
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
{FFFFFF}Похоже, что-то мешает скачиванию обновлению.
Это может быть как антивирус, так и анти-стиллер, который блокирует скачивание.
Если у Вас отключен антивирус, отсутствует анти-стиллер, то видимо что-то другое
блокирует скачивание. Поэтому нужно будет скачать файл отдельно.

Пожалуйста, обратитесь к разработчику скрипта ВКонтакте.
Страницу можно найти, перейдя по ссылке:
{A1DF6B}vk.com/marseloy{FFFFFF}
Скачайте lua файл и переместите с заменой в папку moonloader.

Ссылка на страницу ВКонтакте уже скопирована автоматически.
]]
sampShowDialog(2001, '{FF0000}Ошибка обновления', erTx, 'Закрыть', '', 0)
setClipboardText('vk.com/marseloy')
end

--> Фильтр текста
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

--> Мемберс (Cosmo)
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
	name = 'Организация',
	online = 0,
	afk = 0
}

function hook.onShowDialog(id, style, title, but_1, but_2, text)
	if id == 2015 and members_wait.members then
		local ip, port = sampGetCurrentServerAddress()
        local server = ip..':'..port
		if server == '80.66.82.147:7777' then return false end
		local count = 0
		members_wait.next_page.bool = false

		if title:find('{FFFFFF}(.+)%(В сети: (%d+)%)') then
			org.name, org.online = title:match('{FFFFFF}(.+)%(В сети: (%d+)%)')
			if org.name:find('Больница LS') then
				pers.frac.org = 'Больница ЛС'
				num_of_the_selected_org = 1
			elseif org.name:find('Больница LV') then
				pers.frac.org = 'Больница ЛВ'
				num_of_the_selected_org = 2
			elseif org.name:find('Больница SF') then
				pers.frac.org = 'Больница СФ'
				num_of_the_selected_org = 3
			elseif org.name:find('Больница Jefferson') then
				pers.frac.org = 'Больница Джефферсон'
				num_of_the_selected_org = 4
			elseif org.name:find('Центр лицензирования') then
				pers.frac.org = 'Центр Лицензирования'
				num_of_the_selected_org = 5
			elseif org.name:find('ТСР') then
				pers.frac.org = 'ТСР'
				num_of_the_selected_org = 6
			else
				pers.frac.org = org.name
				num_of_the_selected_org = 0
			end
		else
			org.name = 'Больница VC'
			pers.frac.org = 'Больница ВС'
			org.online = title:match('%(В сети: (%d+)%)')
		end
		
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Ник') and not line:find('страница') then
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

    		if line:match('Следующая страница') then
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
		lua_thread.create(function(); wait(0)
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
	if id == 26365 and num_give_lic > -1 then
		sampSendDialogResponse(26365, 1, num_give_lic, nil)
		return false
	end
	if id == 26366 and num_give_lic > -1 then
		sampSendDialogResponse(26366, 1, num_give_lic_term, nil)
		num_give_lic = -1
		return false
	end
	if id == 25686 and setting.show_dialog_auto then
		local g = 0
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') or line:find('трудовой') then
				sampSendDialogResponse(25686, 1, g, nil)
				g = g + 1
			end
		end
	end
	if id == 27338 then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') or line:find('трудовой') then
				if setting.show_dialog_auto then
					sampSendDialogResponse(27338, 1, 5, nil)
				end
				if thread:status() == 'dead' and setting.auto_roleplay_text then
					send_chat_rp = true
				end
			end
		end
		
		if send_chat_rp then
			return false -- Делает диалог невидимым, если send_chat_rp равно true
		end
	end
	
	
	
	--[[if id == 1234 then
		local f = io.open(dirml..'/StateHelper/textlog.txt', 'w')
		f:write(text)
		f:flush()
		f:close()
	end]]
	if id == 1234 and sobes_menu then
		if title:find('Мед%. карта') and text:find('Имя: '..pl_sob.nm) then
			if text:find('Полностью здоровый') then
				sob_info.hp = 0
			else
				sob_info.hp = 1
			end
			sob_info.narko = tonumber(text:match('Зависимость от укропа: ([%d%.]+)'))
			
			return false
		elseif title:find('Паспорт') and text:find('Имя: {FFD700}'..pl_sob.nm) then
			local black_list_org = {'Больница LS', 'Больница SF', 'Больница LV', 'Больница Jafferson', 'Центр лицензирования', 'ТСР'} 
			local num_org = 1
			if setting.frac.org == u8'Больница СФ' then
				num_org = 2
			elseif setting.frac.org == u8'Больница ЛВ' then
				num_org = 3
			elseif setting.frac.org == u8'Больница Джефферсон' then
				num_org = 4
			elseif setting.frac.org == u8'Центр Лицензирования' then
				num_org = 5
			elseif setting.frac.org == u8'ТСР' then
				num_org = 6
			end
			if text:find('Повестка:  %{FFBD5F%}') then
				sob_info.writ = 0
			else
				sob_info.writ = 1
			end
			if text:find('%{FF6200%} '..black_list_org[num_org]) then
				sob_info.bl = 1
			else
				sob_info.bl = 0
			end
			sob_info.level = tonumber(text:match('Лет в штате: %{FFD700%}(%d+)'))
			sob_info.legal = tonumber(text:match('Законопослушность: %{FFD700%}(%d+)'))
			
			return false
		elseif title:find('Лицензии') then
			if text:find('Лицензия на авто: 		%{FF6347%}') then
				sob_info.lic = 1
			else
				sob_info.lic = 0
			end
			
			return false
		end
	end
	if id == 235 then
		if text:find('Должность: {B83434}(.-)') then
			local text_org, rank_org = text:match('Должность: {B83434}(.-)%((%d+)%)')
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
			if not members_wait.members and setting.members.func and thread:status() == 'dead' and not sampIsDialogActive() and (not send_chat_time or (os.clock() - send_chat_time) >= 8.4) then
				members_wait.members = true
				dont_show_me_members = false
				sampSendChat('/members')
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

--> Сцена
function scene_work()
	if scene_active then
		setVirtualKeyDown(0x79, true)
		cam_hack()
	end
	local X, Y = scene_buf.pos.x, scene_buf.pos.y
	for i, sc in ipairs(scene_buf.qq) do
		local color = changeColorAlpha(sc.color, scene_buf.vis)
		local text_end = u8:decode(sc.text)
		
		if sc.type_color ~= u8'Свой текст и цвет' then
			if sc.type_color == u8'/me' then
				text_end = '{FF99FF}'..sc.nm..' '..u8:decode(sc.text)
			elseif sc.type_color == u8'/do' then
				text_end = '{4682b4}'..u8:decode(sc.text)..' | '..sc.nm
			elseif sc.type_color == u8'/todo' then
				text_end = '{FFFFFF}'..u8:decode(sc.text)..' - сказал(а) '..sc.nm..', {FF99FF}'..u8:decode(sc.act)
			elseif sc.type_color == u8'Речь' then
				text_end = '{FFFFFF}'..sc.nm..' говорит: '..u8:decode(sc.text)
			elseif sc.type_color == u8'Телефон' then
				text_end = '{73B461}[Тел]:{FFFFFF} '..sc.nm..' - '..u8:decode(sc.text)
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

--> Автоскрин
function print_scr()
	lua_thread.create(function()
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> Автоскрин + /time
function print_scr_time()
	lua_thread.create(function()
		sampSendChat('/time')
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

--> Акценты
sampRegisterChatCommand('r', function(text_accents_r) 
	if setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and not setting.accent.func then
		sampSendChat('/r ['..u8:decode(setting.teg)..']: '..text_accents_r)
	elseif setting.teg == '' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_r)
	elseif setting.teg ~= '' and setting.teg ~= ' ' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r ['..u8:decode(setting.teg)..']['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_r)
	else
		sampSendChat('/r '..text_accents_r)
	end 
end)
sampRegisterChatCommand('s', function(text_accents_s) 
	if text_accents_s ~= '' and setting.accent.func and setting.accent.s and setting.accent.text ~= '' then
		sampSendChat('/s ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_s)
	else
		sampSendChat('/s '..text_accents_s)
	end 
end)
sampRegisterChatCommand('f', function(text_accents_f) 
	if text_accents_f ~= '' and setting.accent.func and setting.accent.f and setting.accent.text ~= '' then
		sampSendChat('/f ['..u8:decode(setting.accent.text)..' акцент]: '..text_accents_f)
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
			return{'['..u8:decode(setting.accent.text)..' акцент]: '..message}
		end
    end
end

--> Тайм худ
local BuffSize = 32
local KeyboardLayoutName = ffi.new('char[?]', BuffSize)
local LocalInfo = ffi.new('char[?]', BuffSize)
local month = {'Січня', 'Лютого', 'Березня', 'Квітня', 'Мая', 'Червня', 'Липня', 'Серпня', 'Вересня', 'Жовтня', 'Листопада', 'Грудня'}

function getStrByState(keyState)
	if keyState == 0 then
		return '{ffeeaa}Выкл{ffffff}'
	end
	return '{53E03D}Вкл{ffffff}'
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
			if str:find('Русский') then
				return 'Ru'
			elseif str:find('Английский') then
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
			text_dist_server_point = tostring(removeDecimalPart(distance_end_serv)..' м. до серв. метки')
			renderFontDrawText(font_metka, text_dist_server_point, 20 + bias, sy - 20, 0xFFFFFFFF)
		end
	end
	
	if setting.display_map_distance.user and my_int == 0 then
		local bool_result, pos_X, pos_Y, pos_Z = getTargetBlipCoordinates()
		if bool_result then
			local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
			local distance_end = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
			text_dist_user_point = tostring(removeDecimalPart(distance_end)..' м. до вашей метки')
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

--> Прочие важные функции
function round(num, step) --> Число - шаг округления
  return math.ceil(num / step) * step
end

function chsex(text_man, text_woman)
	if setting.sex == u8'Мужской' then
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
			sampAddChatMessage(script_tag..'{FFFFFF}Нажмите {FF6060}ЛКМ{FFFFFF}, чтобы применить или {FF6060}ESC{FFFFFF} для отмены.', color_tag)
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
                        sampAddChatMessage(script_tag..'{FFFFFF}Позиция сохранена.', color_tag)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						setting.members.pos.x = backup['x']
						setting.members.pos.y = backup['y']
                        sampAddChatMessage(script_tag..'{FFFFFF}Вы отменили изменение позиции.', color_tag)
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
	local title = string.format('%s | Онлайн: %s%s', org.name, org.online, (setting.members.afk and (' (%s в АФК)'):format(org.afk) or ''))
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
	if org.name == 'Гражданин' then
		if setting.members.invers then
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
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
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
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
			else imgui.Text(u8(w)) end
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
					if setting.kick_afk.mode == u8'Сервер закроет соединение' then
						if not close_serv then
							сlose_сonnect()
							close_serv = true
							sampAddChatMessage(script_tag..'{FFFFFF}Вы были отключены от сервера за превышение нормы АФК!', 0xFF5345)
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
									--print('Не найдено')
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
						--print('Не найдено')
					else
						setting.tickets[1].status = 1
						setting.tickets[1].text[#setting.tickets[1].text][2] = response.text
						sampAddChatMessage(script_tag..'{FFFFFF}Служба поддержки ответила на Ваше сообщение!', color_tag)
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
			sampAddChatMessage(script_tag..'{ffffff} Ждем 7 секунд для подтверждения (системно)', color_tag)
			send_chat_time = os.clock()
			send_chat_rp = false
		end
		if send_chat_time then
			if os.clock() - send_chat_time >= 7.3 then
				sampSendDialogResponse(27338, 1, 0, nil)
				local message = SexTag('/me взял{sex:,а} документ с рук человека напротив, внимательно его изучил{sex:,а}, после чего вернул{sex:,а} обратно')
				sampSendChat(message)
				send_chat_time = nil
			end
		end
	end
end
local send_chat_time = nil

function SexTag(text)
    return text:gsub('{sex:([%w%sа-яА-Я]*),([%w%sа-яА-Я]*)}', function(maleForm, femaleForm)
        return setting.sex == u8'Мужской' and maleForm or femaleForm
    end)
end

function save_coun_onl()
	while true do 
		wait(60000)
		save('setting')
	end
end

--> Кам-Хак
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
	return os.date((onDay and math.floor(time / 86400)..' д. ' or '')..('%H ч. %M мин.'), time + timehighlight)
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

function сlose_сonnect()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, raknetNewBitStream())
	raknetDeleteBitStream(raknetNewBitStream())
end

function SendWebhook(URL, DATA, callback_ok, callback_error) -- Функция отправки запроса
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

function send_message_about_problem(mes_text, number_ticket) 																																																																																																																																																																																																																																																																																																															--[[Пожалуйста, не используйте в злых умыслах, будьте человеком!! Спасибо за понимание!!)]]	SendWebhook('https://discord.com/api/webhooks/1224707514356990024/mtsQLAPW1ZBk_Z5YM48WZKdFsP7fDj9Qa36KXxFKpNwvAulNEtXscZmtPovhOeocEJ3m', ([[{																																																																																																				
		"content": "`%s`\n\nУникальный ID: `%s`\nУникальный Git: `%s`\nНик: `%s`\nВерсия скрипта: `%s`",
		"embeds": null,
		"attachments": []
	}]]):format(u8:decode(mes_text), setting.unicum_id..number_ticket, setting.unicum_git..number_ticket, my.nick, scr.version))
	sampAddChatMessage(script_tag..'{FFFFFF}Сообщение успешно отправлено. Ожидайте ответа от службы поддержки.', color_tag)
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
		{'Mulholland International', {x = 1659, y = -947, z = 20}},
		{'International Airport', {x = 1875, y = -2416, z = 20}},
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
	if text_area == 'неизвестном' then
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
			
			return ' ['.. tostring(removeDecimalPart(distance_to_city)) ..' м. от Вас]'
		else
			if setting.frac.org == u8'Больница ЛС' then
				x_player, y_player, z_player = org_all_position[1].x, org_all_position[1].y, org_all_position[1].z
			elseif	setting.frac.org == u8'Больница ЛВ' then
				x_player, y_player, z_player = org_all_position[2].x, org_all_position[2].y, org_all_position[2].z
			elseif	setting.frac.org == u8'Больница СФ' then
				x_player, y_player, z_player = org_all_position[3].x, org_all_position[3].y, org_all_position[3].z
			elseif	setting.frac.org == u8'Больница Джефферсон' then
				x_player, y_player, z_player = org_all_position[4].x, org_all_position[4].y, org_all_position[4].z
			end
			
			distance_to_city = getDistanceBetweenCoords3d(coord_area_end.x, coord_area_end.y, coord_area_end.z, x_player, y_player, z_player)
			
			return ' ['.. tostring(removeDecimalPart(distance_to_city)) ..' м. от Вашей больницы]'
		end
	else
		return ' [Ошибка получения расстояния]'
	end

	return ' [Ошибка получения расстояния]'
end

function TranslateNick(name)
    if name:match('%a+') then
        local replacements = {
            ['A'] = 'А', ['B'] = 'Б', ['C'] = 'К', ['D'] = 'Д', ['E'] = 'Е', 
            ['F'] = 'Ф', ['G'] = 'Г', ['H'] = 'Х', ['I'] = 'И', ['J'] = 'Дж', 
            ['K'] = 'К', ['L'] = 'Л', ['M'] = 'М', ['N'] = 'Н', ['O'] = 'О', 
            ['P'] = 'П', ['Q'] = 'К', ['R'] = 'Р', ['S'] = 'С', ['T'] = 'Т', 
            ['U'] = 'А', ['V'] = 'В', ['W'] = 'В', ['X'] = 'Кс', ['Y'] = 'Й', 
            ['Z'] = 'З', ['a'] = 'а', ['b'] = 'б', ['c'] = 'к', ['d'] = 'д', 
            ['e'] = 'е', ['f'] = 'ф', ['g'] = 'г', ['h'] = 'х', ['i'] = 'и', 
            ['j'] = 'ж', ['k'] = 'к', ['l'] = 'л', ['m'] = 'м', ['n'] = 'н', 
            ['o'] = 'о', ['p'] = 'п', ['q'] = 'к', ['r'] = 'р', ['s'] = 'с', 
            ['t'] = 'т', ['u'] = 'у', ['v'] = 'в', ['w'] = 'в', ['x'] = 'x', 
            ['y'] = 'и', ['z'] = 'з', ['_'] = ' ', ['`'] = 'ь', ['``'] = 'ъ'
        }
        local multi_replacements = {
            ['ph'] = 'ф', ['Ph'] = 'Ф', ['Ch'] = 'Ч', ['ch'] = 'ч', ['Th'] = 'Т', 
            ['th'] = 'т', ['Sh'] = 'Ш', ['sh'] = 'ш', ['ea'] = 'и', ['Ae'] = 'Э', 
            ['ae'] = 'э', ['size'] = 'сайз', ['Jj'] = 'Джейджей', ['Whi'] = 'Вай', 
            ['lack'] = 'лэк', ['whi'] = 'вай', ['Kh'] = 'Х', ['kh'] = 'х', 
            ['hn'] = 'н', ['Hen'] = 'Ген', ['Zh'] = 'Ж', ['zh'] = 'ж', 
            ['Yu'] = 'Ю', ['yu'] = 'ю', ['Yo'] = 'Ё', ['yo'] = 'ё', 
            ['Cz'] = 'Ц', ['cz'] = 'ц', ['ia'] = 'я', ['Ya'] = 'Я', 
            ['ya'] = 'я', ['ove'] = 'ав', ['ay'] = 'эй', ['rise'] = 'райз', 
            ['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', 
            ['Un'] = 'Ан', ['un'] = 'ан', ['Ci'] = 'Ци', ['ci'] = 'ци', 
            ['yse'] = 'уз', ['cate'] = 'кейт', ['eow'] = 'яу', 
            ['rown'] = 'раун', ['yev'] = 'уев', ['Babe'] = 'Бэйби', 
            ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', 
            ['ame'] = 'ейм'
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


function show_cef_notify(type, title, text, time)
    --[[
    1) type - тип уведомления ('info' / 'error' / 'success' / 'halloween' / '')
    2) title - текст заголовка/названия уведомления (указывайте текст)
    3) text - текст содержимого уведомления (указывайте текст)
    4) time - время отображения уведомления в миллисекундах (указывайте любое число).
    ]]
    local str = ('window.executeEvent(\'event.notify.initialize\', \'["%s", "%s", "%s", "%s"]\');'):format(type, title, text, time)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt32(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end

function play_error_sound()
    if not isMonetLoader() and sampIsLocalPlayerSpawned() then
        addOneOffSound(getCharCoordinates(PLAYER_PED), 1149)
    end
    show_cef_notify('error', script_tag, "Произошла ошибка!", 1500)
end

function code(code)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt32(bs, string.len(code))
    raknetBitStreamWriteString(bs, code)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end