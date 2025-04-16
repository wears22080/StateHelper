script_name('State Helper Lite')
script_authors('Kane')
script_description('Script for employees of state organizations on the Arizona Role Playing Game')
script_version('3.0')
script_properties('work-in-pause')

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
local text_error_lib = {
	[1] = [[
			  Внимание! 
	Не обнаружены некоторые важные файлы для работы скрипта.
	В следствии чего, скрипт не может работать.
	Список необнаруженных файлов:
	%s

	Для решения проблемы:
	1. Закройте игру.
	2. Сохраните копию скрипта на рабочий стол.
	3. Зайдите во вкладку "Моды" в лаунчере Аризоны.
	4. Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
	5. После завершения установки перетащите копию скрипта с рабочего стола обратно
	в папку "Moonloader" и запустите игру. Проблема исчезнет.

	Игра была свёрнута, поэтому можете продолжить играть. 
	]],

	[2] = {
		'imgui.lua',
		'samp/events.lua',
		'rkeys.lua',
		'fAwesome5.lua',
		'crc32ffi.lua',
		'bitex.lua',
		'MoonImGui.dll',
		'matrix3x3.lua',
		'encoding.lua',
		'vkeys.lua',
		'effil.lua',
		'bass.lua',
		'fAwesome6.lua',
	},
	[3] = {}
}

if not doesFileExist(getGameDirectory() .. '/SAMPFUNCS.asi') then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_error_lib[1], 'StateHelperLite', 0x00000030 + 0x00010000)
end

for i,v in ipairs(text_error_lib[2]) do
	if not doesFileExist(getWorkingDirectory() .. '/lib/' .. v) then
		table.insert(text_error_lib[3], v)
	end
end

if #text_error_lib[3] > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_error_lib[1]:format(table.concat(text_error_lib[3], '\n\t\t')), 'StateHelperLite', 0x00000030 + 0x00010000)
end
text_error_lib = nil

require 'lib.sampfuncs'
require 'lib.moonloader'
local json = require('cjson')
local mem = require 'memory'
local encoding = require 'encoding' encoding.default = 'CP1251'
local u8 = encoding.UTF8
local vkeys = require 'vkeys'
local rkeys = require 'rkeys'
local effil = require 'effil'
local bass = require 'bass'
local imgui = require 'mimgui'
local new = imgui.new
local fa = require('fAwesome6')
local lfs = require('lfs')
local dlstatus = require('moonloader').download_status

local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 6)
local hook = require 'lib.samp.events'

vkeys.key_names[vkeys.VK_RBUTTON] = u8'ПКМ'
vkeys.key_names[vkeys.VK_LBUTTON] = u8'ЛКМ'
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

--> Файловая система
local dir = getWorkingDirectory()
local sx, sy = getScreenResolution()
local scr = thisScript()
font = renderCreateFont('Trebuchet MS', 14, 5)
fontPD = renderCreateFont('Trebuchet MS', 12, 5)
font_flood = renderCreateFont('Trebuchet MS', 10, 5)
font_metka = renderCreateFont('Trebuchet MS', 9, 5)

--> Проверка существование папки и её создание
if not doesDirectoryExist(dir .. '/State Helper Lite/') then
	print('{F54A4A}Ошибка. Отсутствует папка State Helper Lite. {82E28C}Создание папки для скрипта...')
	createDirectory(dir .. '/State Helper Lite/')
end

--> Скачивание шрифтов
inst_suc_font = {false, false}
image_version_init = false
function download_font()
	local link_meduim_font = 'https://github.com/KaneScripter/ttf_font/raw/refs/heads/main/SFProText-Medium.ttf'
	local link_bold_font = 'https://github.com/KaneScripter/ttf_font/raw/refs/heads/main/SFProText-Bold.ttf'
	if not doesDirectoryExist(dir .. '/State Helper Lite/Шрифты/') then
		print('{F54A4A}Ошибка. Отсутствует папка для шрифтов. {82E28C}Создание папки для шрифтов...')
		createDirectory(dir .. '/State Helper Lite/Шрифты/')
	end
	if not doesFileExist(dir .. '/State Helper Lite/Шрифты/SF600.ttf') or not doesFileExist(dir .. '/State Helper Lite/Шрифты/SF800.ttf') then
		download_id = downloadUrlToFile(link_meduim_font, dir .. '/State Helper Lite/Шрифты/SF600.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				inst_suc_font[1] = true
			end
		end)
		download_id = downloadUrlToFile(link_bold_font, dir .. '/State Helper Lite/Шрифты/SF800.ttf', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				inst_suc_font[2] = true
			end
		end)
	else
		inst_suc_font = {true, true}
	end
end
download_font()

if not doesFileExist(dir .. '/State Helper Lite/Изображения/logo update.png') then
	download_id = downloadUrlToFile('https://i.imgur.com/gRSOicY.png', dir .. '/State Helper Lite/Изображения/logo update.png', function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			image_version_init = true
		end
	end)
else
	image_version_init = true
end
	
--> Регистрация основных функций
function create_folder(name_folder, description_folder) --> Создание папки для работы скрипта, если её нет
	local status_folder = true
	if not doesDirectoryExist(dir .. '/State Helper Lite/' .. name_folder .. '/') then
		print('{F54A4A}Ошибка. Отсутствует папка '.. description_folder .. '. {82E28C}Создание папки ' .. description_folder .. '...')
		createDirectory(dir .. '/State Helper Lite/' .. name_folder .. '/')
		status_folder = false
	end
	
	return status_folder
end

--> Окна mimgui
local win = {}
local windows = {
	main = new.bool(false),
	fast = new.bool(false),
	action = new.bool(false),
	shpora = new.bool(false),
	reminder = new.bool(false),
	player = new.bool(false),
	stat = new.bool(false)
}
function open_main()
	if inst_suc_font[1] and inst_suc_font[2] then
		windows.main[0] = not windows.main[0]
		if windows.main[0] then
			sx, sy = getScreenResolution()
			fix_bug_input_bool = true
			if setting.anim_win then
				anim_func = true
			else
				win_x = sx / 2
			end
		else
			if setting.anim_win then
				close_win_anim = true
				windows.main[0] = true
			end
		end
	else
		sampAddChatMessage('[SH]{FFFFFF} Не удалось обнаружить шрифты. Попробуйте снова через несколько секунд...', 0xFF5345)
		sampAddChatMessage('[SH]{FFFFFF} Если проблема не решилась, напишите разработчику ВК: vk.com/marseloy', 0xFF5345)
	end
end
sampRegisterChatCommand('sh', function()
	open_main()
end)

function deep_copy(orig, copies) --> Копирование массива с учётом цикличных ссылок
	copies = copies or {}
	if type(orig) == 'table' then
		if copies[orig] then
			return copies[orig]
		end
		
		local copy = {}
		copies[orig] = copy
		for key, value in next, orig, nil do
			copy[deep_copy(key, copies)] = deep_copy(value, copies)
		end
		setmetatable(copy, deep_copy(getmetatable(orig), copies))
		
		return copy
	else
		return orig
	end
end

--> Несохраняемая информация
local BuffSize = 32
local KeyboardLayoutName = ffi.new('char[?]', BuffSize)
local LocalInfo = ffi.new('char[?]', BuffSize)
local month = {'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'}
math.randomseed(os.time())

first_start = 0
anim_clock = os.clock()
anim = 0
an = {[1] = 4, [2] = 0.001, [3] = 0, [4] = 187, [5] = {0, 420, 0, 0, 0}, [6] = {0.00, 1}, [7] = {0.00, 0.00, 0.00}, [8] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00},
	[9] = {0, 0, 0, 0}, [10] = {0.00, 0}, [11] = {0, 0}, [12] = {0, 0, false}, [13] = 0, [14] = {0, 0, 0}, [15] = 0, [16] = 0, [17] = {0.00, 0.00, 0.00}, [18] = {0.00, 0.00, 0.00, 0.00, 0.00, 0.00},
	[19] = {0.00, 0.00}, [20] = {0.00, 0.00, 0.00}, [21] = {0, 0}, [22] = {0, 0, 0, 0, 0}, [23] = 0, [24] = {0, 0, 0, 0, 0}, [25] = {0, 0},
	[26] = 0, [27] = 0, [28] = 0, [29] = 0, [30] = {0, 0}}
stop_anim = {false}
tab = 'settings'
name_tab = u8'Главное'
tab_settings = 1
bool_go_stat_set = false
lspawncar = false

close_win = {main = false, fast = false}
imgui.Scroller = {
	id_bool_scroll = {}
}
id_bool_scroll = {}
table_move = ''
table_move_cmd = ''
close_stats = true
hovered_bool_not_child = false
bool_tazer = false
send_chat_rp = false
num_win_fast = 1
bool_edit_fast = false
sc_cursor_pos = {0, 0}
sc_cr_pos = {0, 0}
sc_cr_pos2 = {0, 0}
sc_cr_p_element = {0, 0, 0, 0, 0}
sc_cr_p_element2 = {0, 0, 0, 0, 0}
sdv_bool_fast = 0
bool_item_active = false
bool_item_active2 = false
fast_key = {}
act_key = {}
enter_key = {}
win_key = {}
all_keys = {{72}, {13}}
current_key = {'', {}}
key_pres = {}
fast_nick = 'Nick_Name'
fast_id = 0
TEST = 1
num_of_the_selected_org = 1
text_godeath = ''
id_player_go = '0'
my = {id = 0, nick = 'Nick_Name'}
error_spawn = false
kick_afk_buf = 0
close_serv = false
cur_cmd = ''
edit_cmd = false
all_cmd = {'sh', 'ts', 'r', 'd', 'go', 's', 'f'}
new_cmd = ''
edit_order_tabs = false
int_cmd = {
	folder = 1,
	group = {true, true, true}
}
edit_tab_cmd = false
edit_tab_shpora = false
bl_cmd = nil
main_or_json = 1
number_i_cmd = 0
type_cmd = 0
edit_name_folder = false
focus_input_bool = false
scroll_input_bool = false
edit_all_cmd = false
table_select_cmd = {}
cmd_memory = ''
error_save_cmd = 0
key_bool_cur = {}
dialog_act = {status = false, info = {}, options = {}, enter = false}
x_act_dialog = sx + 200
dep_text = ''
dep_history = {}
dep_var = 0
fix_bug_input_bool = false
shpora_bool = {}
num_shpora = 0
all_icon_shpora = {fa.HOUSE, fa.STAR, fa.USER, fa.MUSIC, fa.GIFT, fa.BOOK, fa.KEY, fa.GLOBE, fa.CODE, fa.COMPASS, fa.LAYER_GROUP, fa.USERS, fa.HEART, fa.CAR, fa.CALENDAR, fa.PLAY, fa.FLAG, fa.BRAIN, fa.ROBOT, fa.WRENCH, fa.INFO, fa.CLOCK, fa.FLOPPY_DISK, fa.CHART_SIMPLE, fa.SHOP, fa.LINK, fa.DATABASE, fa.TAGS, fa.POWER_OFF, fa.HAMMER, fa.SCROLL, fa.CLONE, fa.DICE, fa.USER_NURSE, fa.HOSPITAL, fa.WHEELCHAIR, fa.TRUCK_MEDICAL, fa.TEMPERATURE_LOW, fa.SYRINGE, fa.HEART_PULSE, fa.BOOK_MEDICAL, fa.BAN, fa.PLUS, fa.NOTES_MEDICAL, fa.IMAGE, fa.FILE, fa.TRASH, fa.INBOX, fa.FOLDER, fa.FOLDER_OPEN, fa.COMMENTS, fa.SLIDERS, fa.WIFI, fa.VOLUME_HIGH, fa.UP_DOWN_LEFT_RIGHT, fa.TERMINAL, fa.SUPERSCRIPT}
text_shpora = ''
cmd_memory_shpora = ''
id_sobes = ''
bool_sob_rp_scroll = false
run_sob = false
sob_info = {}
text_sob_chat = ''
support_text = ''
new_reminder = false
new_rem = {}
last_mouse_pos = {0, 0}
last_child_y = {0, 0}
child_clicked = {false, false}
start_child = {true, true}
del_rem = 0
text_reminder = ''
stat_ses = {
	cl = 0,
	afk = 0,
	all = 0
}
tab_music = 1
mus = {
	search = ''
}
image_no_label = nil
bool_button_active_music = false
bool_button_active_volume = false
new_scene = false
scene = {}
num_scene = 0
scene_active = false
scene_edit_pos = false
change_pos_onstat = false
camhack_active = false
off_scene = false
actions_set = {
	remove_mes = false,
	remove_rp = false
}
nickname_dialog = false
nickname_dialog2 = false
nickname_dialog3 = false
nickname_dialog4 = false
time_dialog_nickname = 20
ret_check = 0
replace_not_flood = {0, 0, 0, 0, 1}
popup_open_tags = false
anim_func = false
win_x = sx + 4000
win_y = sy / 2
close_win_anim = false
insert_tag_popup = {[1] = 0, [2] = '', [3] = false}
gun_bool = {}
gun_orig = {
	[1] = {
		i_gun = 3,
		name_gun = 'Дубинка',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} дубинку с поясного держателя',
		put_rp = u8'/me убрал{sex[][а]} дубинку на пояс'
	},
	[2] = {
		i_gun = 22,
		name_gun = 'Pistol',
		take = true,
		put = true,
		take_rp = u8'/me выхватил{sex[][а]} пистолет "Pistol", после чего снял{sex[][а]} его с предохранителя',
		put_rp = u8'/me убрал{sex[][а]} пистолет в кобуру'
	},
	[3] = {
		i_gun = 23,
		name_gun = 'Тайзер',
		take = true,
		put = true,
		take_rp = u8'/me быстро достал{sex[][а]} тайзер из кобуры',
		put_rp = u8'/me спрятал{sex[][а]} тайзер в кобуру'
	},
	[4] = {
		i_gun = 24,
		name_gun = 'Desert Eagle',
		take = true,
		put = true,
		take_rp = u8'/me извлек{sex[][ла]} "Desert Eagle" из кобуры',
		put_rp = u8'/me убрал{sex[][а]} "Desert Eagle" обратно в кобуру'
	},
	[5] = {
		i_gun = 25,
		name_gun = 'Дробовик',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} дробовик со спины',
		put_rp = u8'/me положил{sex[][а]} дробовик за спину'
	},
	[6] = {
		i_gun = 26,
		name_gun = 'Обрез',
		take = true,
		put = true,
		take_rp = u8'/me достал{sex[][а]} обрез из пальто',
		put_rp = u8'/me спрятал{sex[][а]} обрез под пальто'
	},
	[7] = {
		i_gun = 27,
		name_gun = 'Скорострельный дробовик',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} с плеча скорострельный дробовик',
		put_rp = u8'/me повесил{sex[][а]} скорострельный дробовик на плечо'
	},
	[8] = {
		i_gun = 28,
		name_gun = 'UZI',
		take = true,
		put = true,
		take_rp = u8'/me ловко вытащил{sex[][а]} UZI из сумки',
		put_rp = u8'/me убрал{sex[][а]} UZI в сумку'
	},
	[9] = {
		i_gun = 29,
		name_gun = 'MP5',
		take = true,
		put = true,
		take_rp = u8'/me эффектно собрал{sex[][а]} автомат MP5',
		put_rp = u8'/me повесил{sex[][а]} MP5 за спину'
	},
	[10] = {
		i_gun = 30,
		name_gun = 'AK-47',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} автомат "AK-47" со спины',
		put_rp = u8'/me поставил{sex[][а]} "AK-47" на предохранитель и убрал{sex[][а]} его за спину'
	},
	[11] = {
		i_gun = 31,
		name_gun = 'M4',
		take = true,
		put = true,
		take_rp = u8'/me быстро и уверенно снял{sex[][а]} "M4" с плеча',
		put_rp = u8'/me убрал{sex[][а]} "M4", повесив его на плечо'
	},
	[12] = {
		i_gun = 33,
		name_gun = 'Винтовка',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} винтовку с плеча',
		put_rp = u8'/me повесила{sex[][а]} винтовку на плечо'
	},
	[13] = {
		i_gun = 34,
		name_gun = 'Снайперская винтовка',
		take = true,
		put = true,
		take_rp = u8'/me достал{sex[][а]} снайперскую винтовку',
		put_rp = u8'/me поместил{sex[][а]} снайперскую винтовку за спину'
	},
	[14] = {
		i_gun = 71,
		name_gun = 'Desert Eagle Steel',
		take = true,
		put = true,
		take_rp = u8'/me извлек{sex[][ла]} "Desert Eagle Steel" из кобуры',
		put_rp = u8'/me убрал{sex[][а]} "Desert Eagle Steel" обратно в кобуру'
	},
	[15] = {
		i_gun = 72,
		name_gun = 'Desert Eagle Gold',
		take = true,
		put = true,
		take_rp = u8'/me извлек{sex[][ла]} "Desert Eagle Gold" из кобуры',
		put_rp = u8'/me убрал{sex[][а]} "Desert Eagle Gold" обратно в кобуру'
	},
	[16] = {
		i_gun = 73,
		name_gun = 'Glock',
		take = true,
		put = true,
		take_rp = u8'/me выхватил{sex[][а]} пистолет "Glock", после чего снял{sex[][а]} его с предохранителя',
		put_rp = u8'/me убрал{sex[][а]} пистолет "Glock" в кобуру'
	},
	[17] = {
		i_gun = 74,
		name_gun = 'Desert Eagle Flame',
		take = true,
		put = true,
		take_rp = u8'/me извлек{sex[][ла]} "Desert Eagle Flame" из кобуры',
		put_rp = u8'/me убрал{sex[][а]} "Desert Eagle Flame" обратно в кобуру'
	},
	[18] = {
		i_gun = 75,
		name_gun = 'Colt Python',
		take = true,
		put = true,
		take_rp = u8'/me выхватил{sex[][а]} пистолет "Colt Python", после чего снял{sex[][а]} его с предохранителя',
		put_rp = u8'/me убрал{sex[][а]} пистолет "Colt Python" в кобуру'
	},
	[19] = {
		i_gun = 76,
		name_gun = 'Colt Python Silver',
		take = true,
		put = true,
		take_rp = u8'/me выхватил{sex[][а]} пистолет "Colt Python Silver", после чего снял{sex[][а]} его с предохранителя',
		put_rp = u8'/me убрал{sex[][а]} пистолет "Colt Python Silver" в кобуру'
	},
	[20] = {
		i_gun = 77,
		name_gun = 'AK-47 Roses',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} автомат "AK-47 Roses" со спины',
		put_rp = u8'/me убрал{sex[][а]} автомат "AK-47 Roses" за спину'
	},
	[21] = {
		i_gun = 78,
		name_gun = 'AK-47 Gold',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} автомат "AK-47 Gold" со спины',
		put_rp = u8'/me убрал{sex[][а]} автомат "AK-47 Gold" за спину'
	},
	[22] = {
		i_gun = 79,
		name_gun = 'M249 Graffiti',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} пулемёт "M249 Graffiti" со спины',
		put_rp = u8'/me убрал{sex[][а]} пулемёт "M249 Graffiti" за спину'
	},
	[23] = {
		i_gun = 80,
		name_gun = 'Золотая Сайга',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} автомат "Золотая Сайга" со спины',
		put_rp = u8'/me убрал{sex[][а]} автомат "Золотая Сайга" за спину'
	},
	[24] = {
		i_gun = 81,
		name_gun = 'Standart',
		take = true,
		put = true,
		take_rp = u8'/me достал{sex[][а]} пистолет-пулемёт "Standart" из кобуры',
		put_rp = u8'/me убрал{sex[][а]} пистолет-пулемёт "Standart" в кобуру'
	},
	[25] = {
		i_gun = 82,
		name_gun = 'M249',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} пулемет "M249" со спины',
		put_rp = u8'/me убрал{sex[][а]} пулемет "M249" за спину'
	},
	[26] = {
		i_gun = 83,
		name_gun = 'Skorp',
		take = true,
		put = true,
		take_rp = u8'/me достал{sex[][а]} пистолет-пулемёт "Skorp" с кобуры',
		put_rp = u8'/me убрал{sex[][а]} пистолет-пулемёт "Skorp" в кобуру'
	},
	[27] = {
		i_gun = 84,
		name_gun = 'AKS-74',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} камуфляжный автомат "AKS-74" со спины',
		put_rp = u8'/me убрал{sex[][а]} камуфляжный автомат "AKS-74" за спину'
	},
	[28] = {
		i_gun = 85,
		name_gun = 'AK-47',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} камуфляжный автомат "AK-47" со спины',
		put_rp = u8'/me убрал{sex[][а]} камуфляжный автомат "AK-47" за спину'
	},
	[29] = {
		i_gun = 86,
		name_gun = 'Rebecca',
		take = true,
		put = true,
		take_rp = u8'/me снял{sex[][а]} дробовик "Rebecca" со спины',
		put_rp = u8'/me убрал{sex[][а]} дробовик "Rebecca" за спину'
	},
	[30] = {
		i_gun = 92,
		name_gun = 'McMillian TAC-50',
		take = true,
		put = true,
		take_rp = u8'/me достал{sex[][а]} снайперскую винтовку "McMillian TAC-50"',
		put_rp = u8'/me убрал{sex[][а]} снайперскую винтовку "McMillian TAC-50" за спину'
	}
}
anti_spam_gun = {-1, false, 0}
update_request = 0
up_child_sub = 0
cmd_del_i = 0
num_give_gov = -1
num_give_lic = -1
num_give_lic_term = 0
time_save = 1
timer_send = 0
wait_mb = 12
delay_act_def = 2.5
wait_book = {0, false}
script_reset = 0
return_mes_dep = ''
shp_edit_all = {false, {}}
new_version = '0'
search_for_new_version = 0
dialog_fire = {
	id = 27255,
	text = {}
}
tail_rotation_angle = 0
rotation_speed = 90
update_info = {}
raw_upd_info_url = 'https://raw.githubusercontent.com/wears22080/StateHelper/refs/heads/main/State%20Helper%20Lite/%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F%20%D0%BE%D0%B1%20%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8.json'
raw_upd_url = 'https://github.com/wears22080/StateHelper/raw/refs/heads/main/State%20Helper%20Lite/StateHelperLite.lua'
update_scr_check = 30
error_update = false
script_ac = {reset = 0, del = 0}
fire_active = false
level_fire = 1
confirm_action_dialog = false
popup_open_tags_call = false
server = ''
search_cmd = ''
developer_mode = 0
dev_mode = false
windir = os.getenv('windir')
status_sc = 0
UID_SH_SUPPORT = {}

--> Главные настройки
setting = {
	first_start = true,
	cl = 'Black',
	color_def = {0.00, 0.48, 1.00},
	color_def_num = 1,
	hi_mes = true,
	anim_win = true,
	win_key = {'', {}},
	cmd_open_win = '',
	tab = {'settings', 'cmd', 'shpora', 'dep', 'sob', 'reminder', 'stat', 'music', 'rp_zona', 'actions', 'help'},
	name_rus = '',
	sex = 1,
	org = 1,
	job_title = u8'Не определено',
	rank = 10,
	put_mes = {false, false, false, false, false, false, false, false, false, false, false, false, false, false},
	auto_cmd_doc = false,
	auto_close_doc = true,
	auto_cmd_tazer = true,
	auto_cmd_time = '',
	auto_cmd_r = '',
	teg_r = '',
	time = '',
	weather = '',
	watherlock = false,
	price = {
		{
			lec = '10000',
			narko = '100000',
			osm = '200000',
			rec = '20000',
			tatu = '100000',
			ant = '20000',
			mc = {'10000', '20000', '40000', '60000'},
			mcupd = {'20000', '40000', '60000', '80000'}
		},
		{
			auto = {'100000', '160000', '210000'},
			moto = {'150000', '200000', '240000'},
			fly = {'500000', '0', '0'},
			fish = {'200000', '250000', '290000'},
			swim = {'200000', '250000', '290000'},
			gun = {'240000', '330000', '405000'},
			hunt = {'230000', '330000', '390000'},
			exc = {'230000', '330000', '390000'},
			taxi = {'500000', '750000', '1000000'},
			meh = {'500000', '750000', '1000000'}
		}
	},
	fast = {
		func = false,
		one_win = {},
		two_win = {},
		key = {2, 69},
		key_name = u8'ПКМ + E'
	},
	mb = {
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
		vis = 70, 
		color = {title = 0xFFFF8585, default = 0xFFFFFFFF, work = 0xFFFF8C00},
		pos = {x = sx - 30, y = sy / 3}
	},
	godeath = {
		func = false,
		cmd_go = false,
		meter = true,
		two_text = false,
		auto_send = false,
		sound = false,
		color = 0,
		color_godeath = {1.00, 0.33, 0.31}
	},
	notice = {car = false, dep = false},
	dep = {my_tag = '', my_tag_en = '', my_tag_en2 = '', my_tag_en3 = ''},
	accent = {func = false, text = '', r = false, f = false, d = false, s = false},
	speed_door = false,
	show_dialog_auto = false,
	anti_alarm_but = false,
	dep_off = false,
	ts = false,
	time_hud = false,
	display_map_distance = {user = false, server = false},
	but_control = 1,
	kick_afk = {func = false, mode = 1, time_kick = '10'},
	act_key = {{34}, u8'Page Down'},
	enter_key = {{13}, u8'Enter'},
	adress_format_dep = 1,
	my_tag_dep = '',
	wave_tag_dep = '',
	alien_tag_dep = '',
	blanks_dep = {u8'На связи.', u8'На связь.', u8'Конец связи.', u8'Прошу прощения, рация упала...', u8'Вы и Ваш состав свободны для проверки?', u8'', u8'', u8'', u8'', u8''},
	shp = {},
	sob = {
		min_exp = '3',
		min_law = '35',
		min_narko = '5',
		auto_exp = true,
		auto_law = true,
		auto_narko = true,
		auto_org = true,
		auto_med = true,
		auto_blacklist = true,
		auto_ticket = true,
		auto_car = true,
		auto_gun = false,
		auto_warn = true,
		chat = true,
		close_doc = true,
		rp_q = {
			{name = u8'Попросить документы', rp = {u8'Для трудоустройства необходимо предоставить следующий пакет документов:', u8'Паспорт, медицинскую карту и лицензии.', u8'/n Отыгрывая, с использованием команд /me, /do, /todo'}},
			{name = u8'Рассказать о себе', rp = {u8'Хорошо, расскажите немного о себе.'}},
			{name = u8'Почему Вы выбрали нас', rp = {u8'Хорошо, скажите, почему Вы выбрали именно нас?'}},
			{name = u8'Вас убивали?', rp = {u8'Хорошо, давайте проверим Вашу психику.', u8'Скажите, Вас когда-нибудь убивали?'}},
			{name = u8'Где Вы находитесь?', rp = {u8'Хорошо, скажите, где Вы сейчас находитесь?'}},
			{name = u8'Название купюр', rp = {u8'Отлично, скажите, как называются купюры, которыми Вы расплачиваетесь?'}},
			{name = u8'Рация дискорд', rp = {u8'Хорошо, скажите, имеется ли у Вас спец. рация Discord?'}}
		},
		rp_fit = {
			{name = u8'Принять игрока', rp = {u8'Отлично, Вы приняты к нам на работу!', u8'/do В кармане находятся ключи от шкафчиков.', u8'/me засунув руку в карман, вытаскивает ключи и передаёт человеку напротив', u8'/givewbook {id_sob} 1000', u8'{waitwbook}', u8'/invite {id_sob}'}},
			{name = u8'НонРП ник', rp = {u8'Извините, но Вы нам не подходите. У Вас опечатка в паспорте.', u8'/n нонРП ник. С таким ником нельзя. Введи /settings --> Сменить NonRP ник.'}},
			{name = u8'Низкий левел', rp = {u8'Извините, но Вы нам не подходите. Ваш возраст проживания в штате слишком мал.', u8'Минимальный возраст проживания в годах должен быть не менее, чем {min_level_sob}'}},
			{name = u8'Проблемы с законом', rp = {u8'Извините, но Вы нам не подходите. У Вас проблемы с законом.', u8'/n Требуется минимум {min_law_sob} законопослушности.'}},
			{name = u8'Уже состоит во фракции', rp = {u8'Извините, но Вы нам не подходите.', u8'На данный момент Вы уже работаете в другой организации.', u8'Если хотите к нам, то для начала Вам необходимо уволиться оттуда.'}},
			{name = u8'Имеет наркозависимость', rp = {u8'Извините, но Вы нам не подходите. У Вас имеется зависимость от укропа.', u8'Вы можете излечиться, попросив об этом врача любой больницы.'}},
			{name = u8'Проблемы с псих. здоровьем', rp = {u8'Извините, но Вы нам не подходите. У Вас проблемы с псих. здоровьем.', u8'Попробуйте получить новую медицинскую карту в любой больнице.'}},
			{name = u8'Состоит в чёрном списке', rp = {u8'Извините, но Вы нам не подходите. Вы состоите в чёрном списке организации.'}},
			{name = u8'Нет паспорта', rp = {u8'Для трудоустройства необходимо предоставить паспорт.', u8'Получить его можно в мерии г. Лос-Сантос.', u8'Без него, к сожалению, продолжить мы не сможем. Приходите после его получения.'}},
			{name = u8'Нет мед. карты', rp = {u8'Для трудоустройства необходима мед. карта с пометкой "Полностью здоров".', u8'Получить её можно в любой больнице.', u8'Без неё, к сожалению, продолжить мы не сможем.'}},
			{name = u8'Нет лицензий', rp = {u8'Для трудоустройства необходима лицензия на управление автомобилем.', u8'Получить её можно в Центре Лицензирования', u8'Без неё, к сожалению, продолжить мы не сможем. Приходите после её получения.'}},
			{name = u8'Повестка', rp = {u8'Извините, но я смогу Вас трудоустроить, так как у Вас на руках имеется повестка.', u8'Для трудоустройства необходимо иметь военный билет, либо не иметь повестки.', u8'Приходите после получения военного билета.'}}
		}
	},
	reminder = {},
	stat = {
		cl = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		afk = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		day = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
		all = 0,
		today = os.date('%d.%m.%y'),
		date_week = {os.date('%d.%m.%y'), '', '', '', '', '', '', '', '', ''}
	},
	tracks = {},
	mini_player = true,
	scene = {},
	visible_fast = 100,
	replace_not_flood = true,
	color_nick = false,
	replace_ic = true,
	replace_s = true,
	replace_c = true,
	replace_b = true,
	auto_edit = false,
	command_tabs = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', ''},
	key_tabs = {{'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}, {'', {}}},
	gun_func = false,
	gun = deep_copy(gun_orig),
	stat_on_screen = {
		func = false,
		dialog = true,
		current_time = true,
		current_date = true,
		day = true,
		afk = true,
		all = true,
		ses_day = false,
		ses_afk = false,
		ses_all = false,
		visible = 60
	},
	position_stat = {x = sx - 160, y = sy / 2 - 50},
	first_start_fast = true,
	fire = {
		auto_send = false,
		sound = false,
		auto_cmd_fires = false,
		auto_select_fires = false
	},
	sob_id_arg = true,
	show_logs = true,
	text_fires = u8'/r Докладываю: выезжаю на пожар {level} степени возгорания.',
	button_close = 1,
	report_fire = {
		arrival = {
			func = false,
			ask = false,
			text = u8'/r Докладываю: прибыл на пожар {level} степени возгорания.'
		},
		foci = {
			func = false,
			ask = false,
			text = u8'/r Докладываю: все очаги пожара {level} степени возгорания ликвидированы.'
		},
		stretcher = {
			func = false,
			ask = false,
			text = u8'/r Докладываю: немедленно отношу пострадавшего в палатку.'
		},
		salvation = {
			func = false,
			ask = false,
			text = u8'/r Докладываю: пострадавшему в пожаре была успешно оказана помощь.'
		},
		extinguishing = {
			func = false,
			ask = false,
			text = u8'/r Докладываю: пожар {level} степени возгорания полностью устранён!'
		}
	},
	mb_tags = false,
	sob_moto_lic = false,
	time_offset = 0,
	close_button = true,
	playlist = {},
	new_mc = true,
	wrap_text_chat = {
		func = false,
		num_char = '82'
	},
	rank_members = {true, true, true, true, true, true, true, true, true, true, true}
}

--> Отладка кода: значение элементов массив с рекурсивным вызовом для вложенных таблиц
--[[local function inspectTable(tbl)
	for k, v in pairs(tbl) do
		print("Key:", k, "Value:", tostring(v), "Type:", type(v))
		if type(v) == "table" then
			inspectTable(v)
		end
	end
end

inspectTable(setting)]]

cmd = {
	[1] = {},
	[2] = {
		{'Все команды', false, {}},
		{'Избранные', false, {}},
		{'Основные', false, {}},
		{'Фракционные', false, {}},
		{'Для руководства', false, {}},
		{'Лекции', false, {}},
		{'Разное', false, {}}
	}
}

local original_os_date = os.date
os.date = function(format, time)
	local adjusted_time = (time or os.time()) + (setting.time_offset * 3600)
	return original_os_date(format, adjusted_time)
end

function save()
	if not setting.first_start then
		local f = io.open(dir .. '/State Helper Lite/Настройки.json', 'w')
		f:write(encodeJson(setting))
		f:flush()
		f:close()
	end
end

function save_cmd()
	if not setting.first_start then
		local f = io.open(dir .. '/State Helper Lite/Отыгровки.json', 'w')
		f:write(encodeJson(cmd))
		f:flush()
		f:close()
	end
end
	
function download_image()
	if not doesDirectoryExist(getWorkingDirectory() .. '/State Helper Lite/Изображения/') then
		print('{F54A4A}Ошибка. Отсутствует папка для изображений. {82E28C}Создание папки для изображений...')
		createDirectory(getWorkingDirectory() .. '/State Helper Lite/Изображения/')
	end
	if not doesFileExist(getWorkingDirectory() .. '/State Helper Lite/Изображения/No label.png') then
		download_id = downloadUrlToFile('https://i.imgur.com/6EjNtVG.png', getWorkingDirectory() .. '/State Helper Lite/Изображения/No label.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				--image_no_label = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/State Helper Lite/Изображения/No label.png')
			end
		end)
	end
	
	local function download_record_label(url_label_record, name_label, i_rec)
		if not doesFileExist(getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png') then
			download_id = downloadUrlToFile(url_label_record, getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					--image_record[i_rec] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png')
				end
			end)
		end
	end
	
	local function download_radio_label(url_label_radio, name_label, i_radio)
		if not doesFileExist(getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png') then
			download_id = downloadUrlToFile(url_label_radio, getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
					--image_radio[i_radio] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/State Helper Lite/Изображения/' .. name_label .. '.png')
				end
			end)
		end
	end
	
end
download_image()

--> Обработка шрифтов
local font = {}
local bold_font = {}
local fa_font = {}
imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	local config = imgui.ImFontConfig()
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	config.MergeMode = true
	config.PixelSnapH = true
	imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF600.ttf', 16.0, nil, glyph_ranges)
	
	font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF600.ttf', 10.0, _, glyph_ranges)
	font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF600.ttf', 13.0, _, glyph_ranges)
	font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF600.ttf', 15.0, _, glyph_ranges)
	
	bold_font[1] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF800.ttf', 17.0, _, glyph_ranges)
	bold_font[2] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF800.ttf', 65.0, _, glyph_ranges)
	bold_font[3] = imgui.GetIO().Fonts:AddFontFromFileTTF(u8(dir) .. u8'/State Helper Lite/Шрифты/SF800.ttf', 35.0, _, glyph_ranges)
	
	iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
	fa_font[1] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 8, nil, iconRanges)
	fa_font[2] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 13, nil, iconRanges)
	fa_font[3] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 15, nil, iconRanges)
	fa_font[4] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 17, nil, iconRanges)
	fa_font[5] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 21, nil, iconRanges)
	fa_font[6] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('solid'), 35, nil, iconRanges)
	
	if image_version_init then
		image_logo_update = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/State Helper Lite/Изображения/logo update.png')
	end
	if image_no_label == nil then
		image_no_label = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/State Helper Lite/Изображения/No label.png')
	end
end)

function CefDialog()
    local document_opened = false
	addEventHandler('onReceivePacket', function(id, bs)
        if id == 220 then
            raknetBitStreamIgnoreBits(bs, 8)
            if raknetBitStreamReadInt8(bs) == 17 then
                raknetBitStreamIgnoreBits(bs, 32)
                local length = raknetBitStreamReadInt16(bs)
                local encoded = raknetBitStreamReadInt8(bs)
                if length > 0 then
                    local text = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
                    local event, body = text:match("window%.executeEvent%('(.+)',%s*`%[(.+)%]`%);")

                    if run_sob then
                        if event == 'event.documents.inititalizeData' then
                            local data = json.decode(body)
                            local document_type = data['type']

                            if document_type == 1 then 		--> Паспорт
                            	if data['name'] ~= sob_info.nick then
                            		return
                            	end
                                sob_info.valid = true
                                local sex = data['sex']
                                local birthday = data['birthday']
                                local zakono = tonumber(tostring(data['zakono']):match("%d+")) or -2
                                local level = tonumber(tostring(data['level']):match("%d+")) or -2
                                local agenda = tostring(data['agenda'] or "Нет")

                                if agenda:find("Имеется", 1, true) then
                                    sob_info.ticket = 1
                                else
                                    sob_info.ticket = 2
                                end
                                sob_info.law = zakono
                                sob_info.exp = level

                                sendCef('documents.changePage|2')
                            elseif sob_info.valid then
                                if document_type == 2 then 		--> Лицензии
                                    local licenses = data['info']

                                    sob_info.car = 2
                                    sob_info.moto = 2
                                    sob_info.gun = 2

                                    for _, v in pairs(licenses) do
                                        local license = v['license']
                                        local date_text = v['date_text'] or ""
                                        local is_active = (date_text:find("Действует", 1, true) or date_text:find("Бессрочная", 1, true)) and 1 or 2

                                        if license == "car" then
                                            sob_info.car = is_active
                                        elseif license == "bike" then
                                            sob_info.moto = is_active
                                        elseif license == "gun" then
                                            sob_info.gun = is_active
                                        end
                                    end

                                    sendCef('documents.changePage|4')
                                elseif document_type == 4 then 		--> Мед.карта
                                    local zavisimost = tonumber(data['zavisimost']) or 0
                                    local state = data['state'] or ""
									 local sub_text = (data['demorgan'] and data['demorgan']['sub_text']) or ""

                                    local med_status_m = {
                                        ["Полностью здоров"] = 1,
                                        ["Псих. отклонени"] = 2,
                                        ["Псих. нездоров"] = 3,
                                        ["Не определён"] = 4
                                    }

                                    local med_status = 4
                                    local found_status = false
                                    for key, value in pairs(med_status_m) do
                                        if state:find(key, 1, true) then
                                            med_status = value
                                            found_status = true
                                            break
                                        end
                                    end
									
									if sub_text == "Обновите мед. карту" then
										sob_info.org = 2
									else
										sob_info.org = 1
									end

                                    if not found_status then
                                        med_status = 5
                                        sob_info.org = 3
                                    end

                                    sob_info.narko = zavisimost
                                    sob_info.med = med_status
                                    sendCef('documents.changePage|8')
                                elseif document_type == 8 then			--> Военный билет
                                    local have_army_ticket = tostring(data['have_army_ticket'] or 1)

                                    if have_army_ticket:find("Есть", 1, true) then
                                        sob_info.bilet = 0
                                    elseif have_army_ticket:find("Нет", 1, true) then
                                        sob_info.bilet = 1
                                    else
                                        sob_info.bilet = 1
                                    end
                                    sendCef('documents.close')
                                end

                            end
                        end
						if event == 'event.employment.updateData' then --> Трудовая книжка
							local data = json.decode(body)
							local member = data['member']
							if member == 0 then						   --> Проверка на оргу, потом поменяю :)
								sob_info.warn = 1
							else
								sob_info.warn = 0
							end
							sendCef('loadInfo')
							sendCef('selectMenuItem|4')
							sendCef('exit')
						end
                    end
					if event == 'event.documents.inititalizeData' then --> Отыгровка после закрытия паспорта
						local data = json.decode(body)
						if data['name'] ~= my.nick and data['type'] == 1 then
							document_opened = true
						end
					end
					
					if event == 'event.arizonahud.updateGeoPositionVisibility' and body == "true" then --> Отыгровка после закрытия паспорта
						if document_opened and setting.auto_close_doc then
							sampSendChat('/me осмотрел'.. sex('', 'а') .. ' документ, затем закрыл'.. sex('', 'а') .. ' его и вернул'.. sex('', 'а') .. ' человеку')
							document_opened = false
						end
					end
                end
            end
        end
    end)

function sendCef(str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetBitStreamWriteInt32(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
	end
end

function main()
	repeat wait(300) until isSampAvailable()
	
	thread = lua_thread.create(function() return end)
	pos_new_memb = lua_thread.create(function() return end)
	
	setting = apply_settings('Настройки.json', 'настроек', setting)
	cmd = apply_settings('Отыгровки.json', 'отыгровок', cmd)
	
	repeat wait(100) until sampIsLocalPlayerSpawned()
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	my = {id = myid, nick = sampGetPlayerNickname(myid)}
	
	lua_thread.create(activate_function_members)
	lua_thread.create(time)
	create_folder('Шрифты', 'шрифтов')
	if #setting.fast.key ~= 0 then
		table.insert(all_keys, setting.fast.key)
		rkeys.registerHotKey(setting.fast.key, 3, true, function() on_hot_key(setting.fast.key) end)
	end
	table.insert(all_keys, setting.act_key[1])
	table.insert(all_keys, setting.enter_key[1])
	rkeys.registerHotKey(setting.act_key[1], 3, true, function() on_hot_key(setting.act_key[1]) end)
	rkeys.registerHotKey({72}, 1, false, function() on_hot_key({72}) end)
	if #setting.win_key[2] ~= 0 then
		rkeys.registerHotKey(setting.win_key[2], 3, true, function() on_hot_key(setting.win_key[2]) end)
		table.insert(all_keys, setting.win_key[2])
	end
	CefDialog()
	local ip, port = sampGetCurrentServerAddress()
	server = ip .. ':' .. port
	
	if #cmd[1] ~= 0 then
		local bool_uid_save = false
		for i = 1, #cmd[1] do
			if cmd[1][i].UID == nil then
				cmd[1][i].UID = math.random(20, 95000000)
				bool_uid_save = true
			end
			
			for h, v in ipairs(cmd[1][i].act) do
				if v[1] == 'IF' then
					if v[5] == nil then
						v[5] = 1
					end
				end
			end
			
			if cmd[1][i].cmd ~= '' then
				sampRegisterChatCommand(cmd[1][i].cmd, function(arg) cmd_start(arg, tostring(cmd[1][i].UID) .. cmd[1][i].cmd) end)
				
				if cmd[1][i].cmd == 'licdig' then
					for u = 1, #cmd[1][i].act do
						if cmd[1][i].act[u][1] == 'DIALOG' then
							if cmd[1][i].act[u][2] == '' then
								cmd[1][i].act[u][2] = '1'
								bool_uid_save = true
							end
						end
					end
				end
				
				if server == '185.169.134.3:7777' and cmd[1][i].cmd == 'mc' and setting.new_mc then 
					setting.new_mc = false
					cmd[1][i] = mc_phoenix
					bool_uid_save = true
				elseif setting.first_start then 
					setting.new_mc = false
				end
			end
			
			if #cmd[1][i].key[2] ~= 0 then
				rkeys.registerHotKey(cmd[1][i].key[2], 3, true, function() on_hot_key(cmd[1][i].key[2]) end)
				table.insert(all_keys, cmd[1][i].key[2])
			end
		end
		if bool_uid_save then
			save_cmd()
		end
	end
	if #setting.shp ~= 0 then
		for i = 1, #setting.shp do
			sampRegisterChatCommand(setting.shp[i].cmd, function(arg) cmd_shpora_open(arg, tostring(setting.shp[i].UID) .. setting.shp[i].cmd) end)
			if #setting.shp[i].key[2] ~= 0 then
				rkeys.registerHotKey(setting.shp[i].key[2], 3, true, function() on_hot_key(setting.shp[i].key[2]) end)
				table.insert(all_keys, setting.shp[i].key[2])
			end
		end
	end
	for i = 1, #setting.key_tabs do
		if #setting.key_tabs[i][2] ~= 0 then
			rkeys.registerHotKey(setting.key_tabs[i][2], 3, true, function() on_hot_key(setting.key_tabs[i][2]) end)
			table.insert(all_keys, setting.key_tabs[i][2])
		end
	end
	
	if setting.cl == 'White' then
		change_design('White', false)
	else
		change_design('Black', false)
	end
	if setting.godeath.func and setting.godeath.cmd_go then
		sampRegisterChatCommand('go', function()
			go_medic_or_fire()
		end)
	end
	
	if setting.dep_off then
		sampRegisterChatCommand('d', function()
			sampAddChatMessage('[SH]{FFFFFF} Вы отключили команду /d в настройках.', 0xFF5345)
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
	
	if setting.cmd_open_win ~= '' then
		sampRegisterChatCommand(setting.cmd_open_win, function(arg)
			start_other_cmd(setting.cmd_open_win, arg)
		end)
	end
	
	for i = 1, #setting.command_tabs do
		if setting.command_tabs[i] ~= '' then
			sampRegisterChatCommand(setting.command_tabs[i], function(arg)
				start_other_cmd(setting.command_tabs[i], arg)
			end)
		end
	end
	
	
	col_mb = {
		title = convert_color(setting.mb.color.title),
		default = convert_color(setting.mb.color.default),
		work = convert_color(setting.mb.color.work)
	}
	fontes = renderCreateFont('Trebuchet MS', setting.mb.size, setting.mb.flag)

	if setting.mb.func then
		members_wait.members = true
		sampSendChat('/members')
	end
	update_text_dep()
	add_cmd_in_all_cmd()
	
	if setting.hi_mes then
		sampAddChatMessage(string.format('[SH]{FFFFFF} %s, для активации главного меню, отправьте в чат {a8a8a8}/sh', my.nick:gsub('_',' ')), 0xFF5345)
	end
	
	if setting.first_start then
		update_scr_check = 5
		search_for_new_version = 30
	end
	
	if setting.button_close == 2 then
		an[28] = 806
	end
	
	while true do wait(0)
		local current_time = os.clock()
		anim = current_time - anim_clock
		anim_clock = current_time
		
		if sampIsDialogActive() then
    		lastDialogWasActive = os.clock()
    	end
		
		res_targ, ped_tar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if res_targ then
			_, targ_id = sampGetPlayerIdByCharHandle(ped_tar)
		end
		
		if setting.auto_tazer then
			local num_weap = getCurrentCharWeapon(playerPed)
			if num_weap == 3 and not bool_tazer then 
				sampSendChat('/me сняв дубинку с пояса, взял' .. sex('', 'а') .. ' её в правую руку')
				bool_tazer = true
			elseif num_weap ~= 3 and bool_tazer then
				sampSendChat('/me повесил' .. sex('', 'а') .. ' дубинку на пояс')
				bool_tazer = false
			end
		end
		
		if send_chat_rp then
			if setting.auto_close_doc then
				sampSendChat("/me взял".. sex('', 'а') .. " документ с рук человека, затем начал".. sex('', 'а') .. " его осматривать")
			else
				local texts_rp_all = {
					'/me взял' .. sex('', 'а') .. ' документ с рук человека напротив, внимательно его изучил' .. sex('', 'а') .. ', после чего вернул' .. sex('', 'а') .. ' обратно',
					'/me внимательно рассмотрел' .. sex('', 'а') .. ' документ, который был передан ' .. sex('ему', 'ей') .. ' с рук человека напротив',
					'/me взял' .. sex('', 'а') .. ' документ с рук человека и осмотрел' .. sex('', 'а') .. ' его с пристальным вниманием',
					'/me взял' .. sex('', 'а') .. ' документ с рук собеседника и провел' .. sex('', 'а') .. ' по нему взглядом для ознакомления с его содержимым',
					'/me взял' .. sex('', 'а') .. ' документ и тщательно изучил' .. sex('', 'а') .. ' его, после чего вернул' .. sex('', 'а') .. ' обратно'
				}
				local random_index = math.random(1, #texts_rp_all)
				local text_rp = texts_rp_all[random_index]
				sampSendChat(text_rp)
			end
			send_chat_rp = false
		end
		
		if isKeyJustPressed(VK_Q) then
			TEST = TEST + 1
		end
		
		if not scene_active then
			if setting.mb.func and not isGamePaused() and ((setting.mb.dialog and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive()) or not setting.mb.dialog) then
				render_members()
			elseif setting.mb.func and pos_new_memb:status() ~= 'dead' then
				render_members()
			end
		end
		
		if setting.time_hud or setting.display_map_distance.user or setting.display_map_distance.server then
			if not isPauseMenuActive() and not isGamePaused() and not scene_active then
				time_hud_func_and_distance_point()
			end
		end
		
		if setting.replace_not_flood then
			if replace_not_flood[1] > 0 and not isGamePaused() then
				if replace_not_flood[1] > 3 and replace_not_flood[4] < 255 then
					replace_not_flood[4] = replace_not_flood[4] + (500 * anim)
					if replace_not_flood[4] > 255 then replace_not_flood[4] = 255 end
				elseif replace_not_flood[1] <= 3 and replace_not_flood[4] > 0 then
					replace_not_flood[4] = replace_not_flood[4] - (500 * anim)
					if replace_not_flood[4] < 0 then replace_not_flood[4] = 0 end
				end
				
				if not sampIsChatInputActive() then
					if replace_not_flood[5] == 1 then
						renderFontDrawText(font_flood, 'Не флуди!', replace_not_flood[2], replace_not_flood[3] - 7, join_argb(replace_not_flood[4], 255, 64, 64))
					else
						renderFontDrawText(font_flood, 'Не флуди! X' .. replace_not_flood[5], replace_not_flood[2], replace_not_flood[3] - 7, join_argb(replace_not_flood[4], 255, 64, 64))
					end
				end
			end
		end
		
		if not isGamePaused() and play.status ~= 'NULL' then
			control_song_when_finished()
		elseif isGamePaused() and play.status == 'PLAY' then
			if get_status_potok_song() == 1 then
				bass.BASS_ChannelPause(play.stream)
			end
		end
		
		if play.status ~= 'NULL' and setting.mini_player then
			windows.player[0] = true
		else
			windows.player[0] = false
		end
		
		if play.tab ~= 'RECORD' and play.tab ~= 'RADIO' and play.status ~= 'NULL' and get_status_potok_song() == 1 then
			play.pos_time = time_song_position(play.len_time)
		end
		
		if not isGamePaused() then
			if scene_active or scene_edit_pos or (new_scene and scene.preview) then
				scene_work()
			end
		end
		
		if setting.stat_on_screen.func then
			windows.stat[0] = true
		else
			windows.stat[0] = false
		end
		
		if setting.gun_func then
			local gun_ped = getCurrentCharWeapon(playerPed)
			
			for i = 1, #setting.gun do
				if anti_spam_gun[1] ~= -1 and anti_spam_gun[1] ~= gun_ped and anti_spam_gun[1] ~= setting.gun[i].i_gun and anti_spam_gun[3] == 0 then
					for m = 1, #setting.gun do
						if setting.gun[m].put and setting.gun[m].i_gun == anti_spam_gun[1] then
							sampSendChat(u8:decode(sex_decode(setting.gun[m].put_rp)))
							break
						end
					end
					anti_spam_gun[1] = -1
					anti_spam_gun[3] = 2
				elseif anti_spam_gun[1] == -1 and gun_ped == setting.gun[i].i_gun and anti_spam_gun[3] == 0 then
					if setting.gun[i].take then
						sampSendChat(u8:decode(sex_decode(setting.gun[i].take_rp)))
					end
					anti_spam_gun[1] = gun_ped
					anti_spam_gun[3] = 2
				end
			end
		else
			anti_spam_gun[1] = -1
		end
		
		if update_scr_check == 0 then
			update_check()
			update_scr_check = 7000
		end
		
		if developer_mode > 8 then
			developer_mode = 0
			if not dev_mode then
				sampAddChatMessage('[SH] Активирован режим отладки кода.', 0xFF5345)
				dev_mode = true
				open_main()
			else
				sampAddChatMessage('[SH] Отключён режим отладки кода.', 0xFF5345)
				dev_mode = false
			end
		end
	end
end

--> Кастомные элементы
local gui = {}
function gui.Draw(pos_draw, size_imvec2, col_draw_imvec4, radius_draw, flag_draw)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_draw_imvec4), radius_draw, flag_draw)
end

function gui.DrawBox(pos_draw, size_imvec2, col_draw_imvec4, col_draw_imvec4_emp, radius_draw, flag_draw)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_draw_imvec4), 0, flag_draw)
	
	pos_draw[1], pos_draw[2] = pos_draw[1] - 1.5, pos_draw[2] - 1.5
	size_imvec2[1], size_imvec2[2] = size_imvec2[1] + 3, size_imvec2[2] + 3
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_draw_imvec4_emp), radius_draw - 3, flag_draw, 1.5)
end

function gui.DrawEmp(pos_draw, size_imvec2, col_draw_imvec4, radius_draw, flag_draw, thickness_emp)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_draw_imvec4), radius_draw, flag_draw, thickness_emp)
end

function gui.DrawCircle(pos_draw, radius_draw, col_draw_imvec4)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), radius_draw, imgui.GetColorU32Vec4(col_draw_imvec4), 60)
end

function gui.DrawCircleEmp(pos_draw, radius_draw, col_draw_imvec4, thickness)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddCircle(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), radius_draw, imgui.GetColorU32Vec4(col_draw_imvec4), 60, thickness)
end

function gui.DrawLine(pos_draw_A, pos_draw_B, col_draw_imvec4, thickness_line)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + pos_draw_A[1], p.y + pos_draw_A[2]), imgui.ImVec2(p.x + pos_draw_B[1], p.y + pos_draw_B[2]), imgui.GetColorU32Vec4(col_draw_imvec4), (thickness_line or nil))
end

function new_draw(pos_draw_y, size_draw_y)
	gui.DrawBox({16, pos_draw_y}, {586, size_draw_y}, cl.tab, cl.line, 7, 15)
end

function gui.Text(pos_text_x, pos_text_y, text_gui, font_text_gui)
	if font_text_gui then
		imgui.PushFont(font_text_gui)
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_text_x, pos_text_y))
	imgui.Text(u8(text_gui))
	if font_text_gui then
		imgui.PopFont()
	end
end

function gui.FaText(pos_text_x, pos_text_y, fa_text_gui, font_text_gui, fa_style_color)
	if fa_style_color then
		imgui.PushStyleColor(imgui.Col.Text, fa_style_color)
	end
	if font_text_gui then
		imgui.PushFont(font_text_gui)
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_text_x, pos_text_y))
	imgui.Text(fa_text_gui)
	if font_text_gui then
		imgui.PopFont()
	end
	if fa_style_color then
		imgui.PopStyleColor(1)
	end
end

function gui.TextInfo(pos_textinfo, text_info)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.70))
	for i = 1, #text_info do
		gui.Text(pos_textinfo[1], pos_textinfo[2] + ((i - 1) * 14), text_info[i], font[2])
	end
	imgui.PopStyleColor(1)
end

function gui.TextGradient(string, speed, visible)
	local function transfusion(speed_f, visible_text, pl_rgb)
		local r = math.floor(math.sin((os.clock() + pl_rgb) * speed_f) * 127 + 128) / 255
		local g = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 2) * 127 + 128) / 255
		local b = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 4) * 127 + 128) / 255
		
		return imgui.ImVec4(r, g, b, (visible_text or 1))
	end
	
	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			for i = 1, #w do
				local char = u8(w:sub(i, i))
				local color = transfusion(speed, visible, (0.15 * i))
				imgui.TextColored(color, char)
				imgui.SameLine(nil, 0)
			end
			imgui.NewLine()
		end
	end
	
	render_text(string)
end

function gui.Button(text_button, pos_draw, size_imvec2, activity_button)
	local bool_button = false
	local col_stand_imvec4 = cl.bg
	local col_text_imvec4 = cl.text
	
	if activity_button ~= nil then
		col_stand_imvec4 = imgui.ImVec4(0.50, 0.50, 0.50, 0.50)
		if setting.cl == 'White' then
			col_text_imvec4 = imgui.ImVec4(0.98, 0.98, 0.98, 0.50)
		else
			col_text_imvec4 = imgui.ImVec4(0.60, 0.60, 0.60, 0.50)
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
	if imgui.InvisibleButton(text_button, imgui.ImVec2(size_imvec2[1], size_imvec2[2])) then
		bool_button = true
	end
	if imgui.IsItemActive() and activity_button == nil then
		col_stand_imvec4 = cl.def
		col_text_imvec4 = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
	end
	imgui.PushStyleColor(imgui.Col.Text, col_text_imvec4)
	imgui.PushFont(font[3])
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_stand_imvec4), 5, 15)
	if setting.cl == 'White' then
		imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + (pos_draw[1] - 1), p.y + (pos_draw[2] - 1)), imgui.ImVec2(p.x + (size_imvec2[1] + 2) + (pos_draw[1] - 1), p.y + (size_imvec2[2] + 2) + (pos_draw[2] - 1)), imgui.GetColorU32Vec4(imgui.ImVec4(0.88, 0.88, 0.88, 1.00)), 5, 15)
	end
	if text_button:find('##') then
		text_button = text_button:gsub('##(.+)', '')
	end
	local calc = imgui.CalcTextSize(text_button)
	imgui.SetCursorPos(imgui.ImVec2((pos_draw[1] - (calc.x / 2)) + (size_imvec2[1] / 2), (pos_draw[2] - (calc.y / 2)) + (size_imvec2[2] / 2)))
	
	imgui.Text(text_button)
	imgui.PopStyleColor(1)
	imgui.PopFont()
	
	return bool_button
end

function gui.InputText(pos_draw, size_input, arg_text, name_input, buf_size_input, text_about, filter_buf, flag_input)
	local arg_text_buf = imgui.new.char[buf_size_input](arg_text)
	local col_stand_imvec4 = cl.bg
	local ret_true = false
	flag_input = imgui.InputTextFlags.EnterReturnsTrue
	if filter_buf == nil then filter_buf = '' end
	if filter_buf:find('num') then
		if flag_input == nil then flag_input = 0 end
		flag_input = flag_input + imgui.InputTextFlags.CharsDecimal
	elseif filter_buf:find('rus') or filter_buf:find('en') or filter_buf:find('ern') or filter_buf:find('esp') then
		if flag_input == nil then flag_input = 0 end
		flag_input = flag_input + imgui.InputTextFlags.CallbackCharFilter
	end
	
	gui.Draw({pos_draw[1] - 3, pos_draw[2] - 5}, {size_input + 10, 23}, col_stand_imvec4, 0, 15)
	gui.DrawEmp({pos_draw[1] - 5, pos_draw[2] - 7}, {size_input + 14, 27}, cl.def, 3, 15, 2)

	imgui.PushFont(font[3])
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2] - 2))
	imgui.PushItemWidth(size_input)
	
	if filter_buf:find('rus') then
		ret_true = imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf), flag_input, TextCallbackRus)
	elseif filter_buf:find('en') then
		ret_true = imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf), flag_input, TextCallbackEn)
	elseif filter_buf:find('ern') then
		ret_true = imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf), flag_input, TextCallbackEnRusNum)
	elseif filter_buf:find('esp') then
		ret_true = imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf), flag_input, TextCallbackEnNum)
	else
		ret_true = imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf), flag_input)
	end
	
	if text_about ~= nil and (ffi.string(arg_text_buf) == '' and not imgui.IsItemActive()) then
		imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 3, pos_draw[2] - 2))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), text_about)
	end
	imgui.PopFont()
	
	return ffi.string(arg_text_buf), ret_true
end

function gui.InputFalse(text_input, pos_x, pos_y, size_input)
	local function truncate_text_to_fit(text, max_width)
		local truncated_text = text
		local text_size = imgui.CalcTextSize(text)
		
		if text_size.x > max_width then
			for i = 1, #text do
				local partial_text = text:sub(1, i)
				local partial_width = imgui.CalcTextSize(partial_text).x

				if partial_width > max_width then
					truncated_text = text:sub(1, i - 1)
					
					break
				end
			end
		end

		return truncated_text
	end
	
	gui.Draw({pos_x - 3, pos_y - 5}, {size_input + 10, 23}, (setting.cl == 'Black' and cl.bg) or imgui.ImVec4(0.80, 0.80, 0.80, 0.80) , 3, 15)
	imgui.SetCursorPos(imgui.ImVec2(pos_x, pos_y - 2))
	imgui.PushFont(font[3])
	local display_text = truncate_text_to_fit(text_input, size_input)
	imgui.Text(display_text)
	imgui.PopFont()
end

function gui.ListTable(pos_draw, size_imvec2, arg_table, arg_num, name_table)
	local col_stand_imvec4 = cl.bg

	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_stand_imvec4), 2, 15)
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + (pos_draw[1] - 2), p.y + (pos_draw[2] - 2)), imgui.ImVec2(p.x + (size_imvec2[1] + 4) + (pos_draw[1] - 2), p.y + (size_imvec2[2] + 4) + (pos_draw[2] - 2)), imgui.GetColorU32Vec4(cl.def), 5, 15, 2)
	
	imgui.PushFont(font[3])
	if #arg_table ~= 0 and arg_num then
		for i = 1, #arg_table do
			local mi = i - 1
			if i == arg_num then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
				local pos_y_dr = {pos_draw[1] - 1, (pos_draw[2] - 1) + (mi * 31)}
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_y_dr[1], p.y + pos_y_dr[2]), imgui.ImVec2(p.x + size_imvec2[1] + 2 + pos_y_dr[1], p.y + 31 + pos_y_dr[2]), imgui.GetColorU32Vec4(cl.def))
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 10, pos_draw[2] + 6 + (mi * 31)))
				imgui.Text(arg_table[i])
				imgui.PopStyleColor(1)
			else
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 10, pos_draw[2] + 6 + (mi * 31)))
				imgui.Text(arg_table[i])
			end
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - 1, (pos_draw[2] - 1) + (mi * 31)))
			if imgui.InvisibleButton(name_table .. i, imgui.ImVec2(size_imvec2[1] + 2, 31)) then
				arg_num = i
			end
		end
	end
	imgui.PopFont()
	
	return arg_num
end

function gui.LT_First_Start(pos_draw, size_imvec2, arg_table, arg_num, name_table)
	local col_stand_imvec4 = cl.bg

	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_draw[1], p.y + pos_draw[2]), imgui.ImVec2(p.x + size_imvec2[1] + pos_draw[1], p.y + size_imvec2[2] + pos_draw[2]), imgui.GetColorU32Vec4(col_stand_imvec4), 2, 15)
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + (pos_draw[1] - 2), p.y + (pos_draw[2] - 2)), imgui.ImVec2(p.x + (size_imvec2[1] + 4) + (pos_draw[1] - 2), p.y + (size_imvec2[2] + 4) + (pos_draw[2] - 2)), imgui.GetColorU32Vec4(cl.def), 5, 15, 2)
	
	local y_LT = 25
	imgui.PushFont(font[3])
	if #arg_table ~= 0 and arg_num then
		for i = 1, #arg_table do
			local mi = i - 1
			if i == arg_num then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
				local pos_y_dr = {pos_draw[1] - 1, (pos_draw[2] - 1) + (mi * y_LT)}
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + pos_y_dr[1], p.y + pos_y_dr[2]), imgui.ImVec2(p.x + size_imvec2[1] + 2 + pos_y_dr[1], p.y + y_LT + pos_y_dr[2]), imgui.GetColorU32Vec4(cl.def))
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 10, pos_draw[2] + 4 + (mi * y_LT)))
				imgui.Text(arg_table[i])
				imgui.PopStyleColor(1)
			else
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 10, pos_draw[2] + 4 + (mi * y_LT)))
				imgui.Text(arg_table[i])
			end
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - 1, (pos_draw[2] - 1) + (mi * y_LT)))
			if imgui.InvisibleButton(name_table .. i, imgui.ImVec2(size_imvec2[1] + 2, y_LT)) then
				arg_num = i
			end
		end
	end
	imgui.PopFont()
	
	return arg_num
end

function gui.ListTableHorizontal(pos_draw, arg_table, arg_num, name_table)
	local col_stand_imvec4 = cl.bg
	
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (#arg_table * 120), p.y + 23), imgui.GetColorU32Vec4(col_stand_imvec4), 0, 15)
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x - 2, p.y - 2), imgui.ImVec2(p.x + ((#arg_table * 120) + 4) - 2, p.y + 25), imgui.GetColorU32Vec4(cl.def), 3, 15, 2)
	
	imgui.PushFont(font[3])
	if #arg_table ~= 0 and arg_num then
		for i = 1, #arg_table do
			local mi = i - 1
			local calc = imgui.CalcTextSize(arg_table[i])
			if i == arg_num then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
				imgui.SetCursorPos(imgui.ImVec2((pos_draw[1] - 1) + (mi * 120), pos_draw[2] - 1))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 120 + 2, p.y + 25), imgui.GetColorU32Vec4(cl.def))
				imgui.SetCursorPos(imgui.ImVec2((pos_draw[1] + (60 - calc.x / 2)) + (mi * 120), pos_draw[2] + 4))
				imgui.Text(arg_table[i])
				imgui.PopStyleColor(1)
			else
				imgui.SetCursorPos(imgui.ImVec2((pos_draw[1] + (60 - calc.x / 2)) + (mi * 120), pos_draw[2] + 4))
				imgui.Text(arg_table[i])
			end
			imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + (mi * 120), pos_draw[2] - 1))
			if imgui.InvisibleButton(name_table .. i, imgui.ImVec2(120, 25)) then
				arg_num = i
			end
		end
	end
	imgui.PopFont()
	
	return arg_num
end

function gui.ListTableMove(pos_draw, arg_table, arg_num, name_table)
	local col_stand_imvec4 = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	imgui.PushFont(font[3])
	local calc = imgui.CalcTextSize(arg_table[arg_num])
	
	if table_move ~= name_table then
		imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - 5 - calc.x, pos_draw[2] - 5))
		if imgui.InvisibleButton('##ListTableMove ' .. name_table, imgui.ImVec2(calc.x + 30, 26)) then
			table_move = name_table
		end
		if imgui.IsItemActive() then
			col_stand_imvec4 = cl.def
		elseif imgui.IsItemHovered() then
			col_stand_imvec4 = cl.bg
		end
		imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - 5 - calc.x, pos_draw[2] - 5))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc.x + 30, p.y + 26), imgui.GetColorU32Vec4(col_stand_imvec4), 7, 15)
		if setting.cl == 'White' then
			imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x - 1, p.y - 1), imgui.ImVec2(p.x + calc.x + 32, p.y + 28), imgui.GetColorU32Vec4(imgui.ImVec4(0.88, 0.88, 0.88, 1.00)), 7, 15)
		end
	end
	
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - calc.x, pos_draw[2]))
	imgui.Text(arg_table[arg_num])
	
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 5, pos_draw[2]))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 14, p.y + 17), imgui.GetColorU32Vec4(imgui.ImVec4(0.50, 0.50, 0.50, 0.70)), 2, 15)
	
	imgui.PushFont(fa_font[2])
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 8, pos_draw[2] + 1))
	imgui.Text(fa.SORT_UP)
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 8, pos_draw[2] + 2))
	imgui.Text(fa.SORT_DOWN)
	imgui.PopFont()
	
	if table_move == name_table then
		local calc_very = 0
		for s = 1, #arg_table do
			local calc_bool = imgui.CalcTextSize(arg_table[s])
			if calc_bool.x > calc_very then
				calc_very = calc_bool.x
			end
		end
		calc_very = calc_very - calc.x
		
		imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - calc_very - 25 - calc.x, pos_draw[2] - 10))
		imgui.BeginChild(u8'Окно выбора листа'.. name_table, imgui.ImVec2(calc_very + calc.x + 39, 2 + (#arg_table * 27)), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
		
		imgui.SetCursorPos(imgui.ImVec2(0, 0))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc_very + calc.x + 39, p.y + 2 + (#arg_table * 27)), imgui.GetColorU32Vec4(cl.bg), 7, 15)
		
		for m = 1, #arg_table do
			local col_stand_imvec4_2 = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			imgui.SetCursorPos(imgui.ImVec2(0, 1 + (m - 1) * 27))
			if imgui.InvisibleButton('##ListTableMoveSelect ' .. name_table .. m, imgui.ImVec2(calc_very + calc.x + 39, 27)) then
				table_move = ''
				arg_num = m
			end
			if imgui.IsItemActive() then
				col_stand_imvec4_2 = cl.def
			elseif imgui.IsItemHovered() then
				col_stand_imvec4_2 = cl.bg2
			end
			imgui.SetCursorPos(imgui.ImVec2(1, 1 + (m - 1) * 27))
			local p = imgui.GetCursorScreenPos()
			local flag = {0, 0}
			if m == 1 then 
				flag = {4, 3}
			elseif m == #arg_table then
				flag = {4, 12}
			end
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc_very + calc.x + 37, p.y + 27), imgui.GetColorU32Vec4(col_stand_imvec4_2), flag[1], flag[2])
			
			imgui.SetCursorPos(imgui.ImVec2(25, 6 + ((m - 1) * 27)))
			imgui.Text(arg_table[m])
			
			if m == arg_num then
				imgui.PushFont(fa_font[2])
				imgui.SetCursorPos(imgui.ImVec2(7, 6 + ((m - 1) * 27)))
				imgui.Text(fa.CHECK)
				imgui.PopFont()
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(0, 0))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + calc_very + calc.x + 39, p.y + 2 + (#arg_table * 27)), imgui.GetColorU32Vec4(cl.def), 7, 15)
		imgui.EndChild()
		
		if imgui.IsMouseReleased(0) and not imgui.IsItemHovered() then
			table_move = ''
		end
	end
	
	imgui.PopFont()
	
	return arg_num
end

function gui.Counter(pos_draw, arg_text, arg_num, arg_min, arg_max, name_counter)
	local col_stand_imvec4 = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	imgui.PushFont(font[3])
	local calc = imgui.CalcTextSize(arg_text)
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] - 5 - calc.x, pos_draw[2]))
	imgui.Text(arg_text)
	imgui.PopFont()
	
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2] - 3))
	if imgui.InvisibleButton(u8'##1' .. name_counter, imgui.ImVec2(14, 10)) then
		if arg_num < arg_max then
			arg_num = arg_num + 1
		end
	end
	if imgui.IsItemActive() and arg_num < arg_max then
		gui.Draw({pos_draw[1], pos_draw[2] - 3}, {14, 10}, cl.def, 2, 15)
	elseif arg_num < arg_max then
		gui.Draw({pos_draw[1], pos_draw[2] - 3}, {14, 10}, imgui.ImVec4(0.50, 0.50, 0.50, 0.70), 2, 15)
	else
		gui.Draw({pos_draw[1], pos_draw[2] - 3}, {14, 10}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50), 2, 15)
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2] + 10))
	if imgui.InvisibleButton(u8'##2' .. name_counter, imgui.ImVec2(14, 10)) then
		if arg_num > arg_min then
			arg_num = arg_num - 1
		end
	end
	if imgui.IsItemActive() and arg_num > arg_min then
		gui.Draw({pos_draw[1], pos_draw[2] + 10}, {14, 10}, cl.def, 2, 15)
	elseif arg_num > arg_min then
		gui.Draw({pos_draw[1], pos_draw[2] + 10}, {14, 10}, imgui.ImVec4(0.50, 0.50, 0.50, 0.70), 2, 15)
	else
		gui.Draw({pos_draw[1], pos_draw[2] + 10}, {14, 10}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50), 2, 15)
	end
	
	imgui.PushFont(fa_font[2])
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 3, pos_draw[2] - 2))
	if arg_num >= arg_max then
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
	end
	imgui.Text(fa.SORT_UP)
	if arg_num >= arg_max then
		imgui.PopStyleColor(1)
	end
	imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 3, pos_draw[2] + 5))
	if arg_num <= arg_min then
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
	end
	imgui.Text(fa.SORT_DOWN)
	if arg_num <= arg_min then
		imgui.PopStyleColor(1)
	end
	imgui.PopFont()
	
	return arg_num
end

function gui.Switch(namebut, bool)
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
    local height = imgui.GetTextLineHeightWithSpacing() * 1.35
    local width = height * 1.20
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
	if setting.cl == 'White' then
		col_neitral =  0xFFD4CFCF
	end
    local col_static = 0xFFFFFFFF
    local col = bool and imgui.ColorConvertFloat4ToU32(cl.def) or col_neitral
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 10.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3) + 0.6, p.y + 5 + radius), radius - 0.75, col_static, 60)

    return rBool
end

function gui.SwitchFalse(bool)
	local rBool = false
	local namebut = '##button_false_no_name'
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
	local height = imgui.GetTextLineHeightWithSpacing() * 1.35
	local width = height * 1.20
	local radius = height * 0.30
	local ANIM_SPEED = 0.09
	local butPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 3, butPos.y + 3.8))
	imgui.Text(namebut:gsub('##.+', ''))
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
	local col_neitral = 0x80666666
	local col_static = 0x80999999
	if setting.cl == 'White' then
		col_neitral =  0x80666666 
		col_static = 0xCCD8D8D8
	end
	local col = bool and imgui.ColorConvertFloat4ToU32(cl.bg) or col_neitral
	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 10.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3) + 0.6, p.y + 5 + radius), radius - 0.75, col_static, 60)
end

function gui.GetCursorScroll()
	local cursor_pos = imgui.GetMousePos()
	local screen_pos = imgui.GetWindowPos()
	local scroll_pos = {x = imgui.GetScrollX(), y = imgui.GetScrollY()}
	local end_pos = {x = (cursor_pos.x - screen_pos.x) + scroll_pos.x, y = (cursor_pos.y - screen_pos.y) + scroll_pos.y}
	
	return end_pos
end

function gui.SliderBar(slider_text, slider_arg, slider_min, slider_max, slider_width, slider_pos, saving_it)
	local function convert(param)
		param = tonumber(param) * 100
		return round(param, 1)
	end
	
	local tbl_per = {}
	local arg_buf_format
	local pere_arg
	local saveinter
	local tap_slid = false
	
	arg_buf_format = imgui.new.float(slider_arg)
	if arg_buf_format[0] == 'nil' then
		arg_buf_format[0] = ''
	end
	
	local slider_width_end = (slider_width - 15) / slider_max
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1] + 5, slider_pos[2] + 9))
	local p = imgui.GetCursorScreenPos()
	local DragPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(slider_pos[1], slider_pos[2]))
	imgui.PushItemWidth(slider_width)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	imgui.SliderFloat(u8'##'..slider_text, arg_buf_format, slider_min, slider_max, u8'')
	imgui.PopStyleColor(3)
	
	local col_sl_non = imgui.ImVec4(0.60, 0.60, 0.60 ,1.00)
	local col_sl_circle = imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)
	if setting.cl == 'White' then
		col_sl_non = imgui.ImVec4(0.83, 0.81, 0.81 ,1.00)
	end
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + slider_width - 15, p.y + 5), imgui.GetColorU32Vec4(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 10, 15)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (arg_buf_format[0] * slider_width_end), p.y + 5), imgui.GetColorU32Vec4(cl.def), 10, 15)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (arg_buf_format[0] * slider_width_end), p.y + 2), 9, imgui.GetColorU32Vec4(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 60)
	imgui.SameLine()
	if not slider_text:find('##') then
		imgui.PushFont(font[1])
		imgui.Text(slider_text)
		imgui.PopFont()
	end
	
	return arg_buf_format[0]
end

function gui.SliderCircle(name_slider, cur_pos, radius, angle, color, thickness, segments, max_val, arg_znach)
	imgui.SetCursorPos(imgui.ImVec2(cur_pos[1], cur_pos[2]))
	local cur = imgui.GetCursorScreenPos()
	local dl = imgui.GetWindowDrawList()
	local up_center = 15.04
	
	radius, angle, color, thickness, segments = radius or 25, angle or 360, color or 0xFFFFFFFF, thickness or 1, segments or 16
	
	--> Фон полукруга
	dl:PathArcTo(cur + imgui.ImVec2(radius, radius), radius, up_center, up_center + math.rad(angle), segments)
	dl:PathStroke(color, false, thickness)
	dl:PathClear()
	
	--> Заполненная шкала
	local max_value = arg_znach / (max_val / 140)
	local result_road = math.rad(1.8 * (max_value))
	dl:PathArcTo(cur + imgui.ImVec2(radius, radius), radius, up_center, up_center + result_road, segments)
	dl:PathStroke(imgui.GetColorU32Vec4(imgui.ImVec4(0.30, 0.85, 0.38, 1.00)), false, thickness)
	dl:PathClear()
	
	local max_value_2 = max_val / (max_val / 140)
	local result_road_2 = math.rad(1.8 * (max_value_2 + 3))
	local knobAngle_2 = up_center + result_road_2
	local knobX_2 = cur.x + radius + radius * math.cos(knobAngle_2)
	local knobY_2 = cur.y + radius + radius * math.sin(knobAngle_2)
	if max_val == arg_znach then
		dl:AddCircleFilled({knobX_2, knobY_2}, 6, imgui.GetColorU32Vec4(imgui.ImVec4(0.30, 0.85, 0.38, 1.00)), 20)
	else
		dl:AddCircleFilled({knobX_2, knobY_2}, 6, color, 20)
	end
	
	--> Ручка шкалы
	local knobAngle = up_center + result_road
	local knobX = cur.x + radius + radius * math.cos(knobAngle)
	local knobY = cur.y + radius + radius * math.sin(knobAngle)
	dl:AddCircleFilled({knobX, knobY}, 6, imgui.GetColorU32Vec4(imgui.ImVec4(0.30, 0.85, 0.38, 1.00)), 20)
	
	local knobAngle_3 = up_center + math.rad(0)
	local knobX_3 = cur.x + radius + radius * math.cos(knobAngle_3)
	local knobY_3 = cur.y + radius + radius * math.sin(knobAngle_3)
	if result_road == math.rad(0) then
		dl:AddCircleFilled({knobX_3, knobY_3}, 6, color, 20)
	else
		dl:AddCircleFilled({knobX_3, knobY_3}, 6, imgui.GetColorU32Vec4(imgui.ImVec4(0.30, 0.85, 0.38, 1.00)), 20)
	end

	imgui.PushFont(bold_font[2])
	local calc = imgui.CalcTextSize(tostring(floor(arg_znach)))
	imgui.PopFont()
	gui.Text(-(calc.x / 2) + 70 + cur_pos[1], cur_pos[2] + 30, tostring(floor(arg_znach)), bold_font[2])
end

tracks = {}
random_tracks = {}
site_link = 'rus.hitmotop.com'
play = {
	i = 0,
	info = {},
	len_time = 0,
	pos_time = 0,
	status = 'NULL',
	stream = nil,
	volume = 0.5,
	status_image = 0,
	image_label = nil,
	tab = '',
	shuffle = false,
	repeat_track = 0
}

function find_track_link(search_text, page) --> Поиск песни в интернете
	local tracks_repsone = {
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
	
	asyncHttpRequest('GET', 'https://' .. site_link .. '/search' .. page_ssl .. '?q=' .. urlencode(mus.search), nil,
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
				tracks_repsone.link[1] = 'Ошибка404'
				tracks_repsone.artist[1] = 'Ошибка404'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://' .. site_link .. '/get/music/') then
					track = link:match('(.+).mp3')
					table.insert(tracks_repsone.link, track .. '.mp3')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				local nametrack = link:match('(.+)')
				nametrack = nametrack and nametrack:gsub('^%s*(.-)%s*$', '%1') or 'Неизвестно'
				table.insert(tracks_repsone.name, nametrack)
			end

			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				local artist = link:match('(.+)')
				artist = artist and artist:gsub('^%s*(.-)%s*$', '%1') or 'Неизвестно'
				table.insert(tracks_repsone.artist, artist)
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_fulltime"%>(.-)%</div') do
				if link:find('(.+)') then
					table.insert(tracks_repsone.time, link:match('(.+)'))
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_img" style="background%-image: url%(\'(.-)\'%)%;"%>%</div%>') do
				if link:find('(.+)') then
					table.insert(tracks_repsone.image, link:match('(.+)'))
				end
			end
			
			local track_list = {}
			local count = math.max(#tracks_repsone.link, #tracks_repsone.artist, #tracks_repsone.name, #tracks_repsone.time, #tracks_repsone.image)

			for i = 1, count do
				track_list[i] = {
					link = tracks_repsone.link[i] or '',
					artist = tracks_repsone.artist[i] or '',
					name = tracks_repsone.name[i] or '',
					time = tracks_repsone.time[i] or '',
					image = tracks_repsone.image[i] or ''
				}
			end
			
			tracks = track_list
		end,
		function(err)
		print(err)
	end)
end

function play_song(table_track, loop_track, num_i, song_tab) --> Включить песню
	if song_tab ~= 'RECORD' and song_tab ~= 'RADIO' then
		play.i = num_i
		play.info = table_track
		play.time = 0
		play.status = 'PLAY'
		play.len_time = get_track_length(play.info.time)
		play.tab = song_tab
		
		if get_status_potok_song() ~= 0 then
			bass.BASS_ChannelStop(play.stream)
		end
		
		if not loop_track then
			play.stream = bass.BASS_StreamCreateURL(play.info.link, 0, BASS_STREAM_AUTOFREE, nil, nil)
			bass.BASS_ChannelPlay(play.stream, false)
		else
			play.stream = bass.BASS_StreamCreateURL(play.info.link, 0, BASS_SAMPLE_LOOP, nil, nil)
			bass.BASS_ChannelPlay(play.stream, false)
		end
		bass.BASS_ChannelSetAttribute(play.stream, BASS_ATTRIB_VOL, play.volume)
		
		if not play.info.image:find('no%-cover%-150') then
			download_id = downloadUrlToFile(play.info.image, getWorkingDirectory() .. '/State Helper Lite/Изображения/Label.png', function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					play.status_image = play.i
					play.image_label = imgui.CreateTextureFromFile(getWorkingDirectory()..'/State Helper Lite/Изображения/Label.png')
				end
			end)
		else
			play.status_image = play.i
			play.image_label = image_no_label
		end
	else
		play.i = num_i
		play.info = {}
		play.time = 0
		play.status = 'PLAY'
		play.len_time = 0
		play.tab = song_tab
		
		if get_status_potok_song() ~= 0 then
			bass.BASS_ChannelStop(play.stream)
		end
		
		play.stream = bass.BASS_StreamCreateURL(table_track, 0, BASS_SAMPLE_LOOP, nil, nil)
		bass.BASS_ChannelPlay(play.stream, false)
		bass.BASS_ChannelSetAttribute(play.stream, BASS_ATTRIB_VOL, play.volume)
		
		play.image_label = image_no_label
	end
end

function get_status_potok_song() --> Получить статус потока
	if play.stream ~= nil then
		return tonumber(bass.BASS_ChannelIsActive(play.stream))
	else
		return 0
	end
	
	--[[
	[0] - Ничего не воспроизводится
	[1] - Играет
	[2] - Блок
	[3] - Пауза
	--]]
end

function rewind_song(time_position) --> Перемотка трека на указанную позицию (позиция трека в секундах)
	if play.status ~= 'NULL' and get_status_potok_song() ~= 0 then
		local length = bass.BASS_ChannelGetLength(play.stream, BASS_POS_BYTE)
		length = tostring(length)
		length = length:gsub('(%D+)', '')
		length = tonumber(length)
		bass.BASS_ChannelSetPosition(play.stream, ((length / play.len_time) * time_position) - 100, BASS_POS_BYTE)
	end
end

function time_song_position(song_length) --> Получить позицию трека в секундах
	local posByte = bass.BASS_ChannelGetPosition(play.stream, BASS_POS_BYTE)
	posByte = tostring(posByte)
	posByte = posByte:gsub('(%D+)', '')
	posByte = tonumber(posByte)
	local length = bass.BASS_ChannelGetLength(play.stream, BASS_POS_BYTE)
	length = tostring(length)
	length = length:gsub('(%D+)', '')
	length = tonumber(length)
	local postrack = posByte / (length / song_length)
	
	return postrack
end

function get_track_length(track_length) --> Получить длину трека в секундах
	local minutes, seconds = track_length:match('^(%d+):(%d+)$')
	
	if minutes and seconds then
		minutes = tonumber(minutes)
		seconds = tonumber(seconds)
		
		return minutes * 60 + seconds
	else
		return 999
	end
end

function set_song_status(action_music) --> Остановить/Пауза/Продолжить
	if play.stream ~= nil and get_status_potok_song() ~= 0 then
		if action_music == 'PLAY_OR_PAUSE' then
			if play.status == 'PLAY' then
				play.status = 'PAUSE'
				bass.BASS_ChannelPause(play.stream)
			elseif play.status == 'PAUSE' then
				play.status = 'PLAY'
				bass.BASS_ChannelPlay(play.stream, false)
			end
		elseif action_music == 'STOP' then
			bass.BASS_ChannelStop(play.stream)
			play = {
				i = 0,
				info = {},
				len_time = 0,
				pos_time = 0,
				status = 'NULL',
				stream = nil,
				volume = play.volume,
				status_image = 0,
				image_label = nil,
				tab = '',
				shuffle = play.shuffle,
				repeat_track = play.repeat_track
			}
			windows.player[0] = false
		elseif action_music == 'PLAY' then
			play.status = 'PAUSE'
			bass.BASS_ChannelPause(play.stream)
		end
	end
end

function volume_song(volume_music) --> Установить громкость песни
	if play.stream ~= nil and get_status_potok_song() ~= 0 then
		bass.BASS_ChannelSetAttribute(play.stream, BASS_ATTRIB_VOL, volume_music)
	end
end

function back_track() --> Переключить песню назад
	if play.tab == 'SEARCH' and #tracks > 0 then
		for i = 1, #tracks do
			if tracks[i].link == play.info.link then
				if i ~= 1 then
					play_song(tracks[i - 1], play.repeat_track == 2, i - 1, 'SEARCH')
					break
				else
					play_song(tracks[#tracks], play.repeat_track == 2, #tracks, 'SEARCH')
					break
				end
			end
		end
	elseif play.tab == 'ADD' and #setting.tracks > 0 then
		for i = 1, #setting.tracks do
			if setting.tracks[i].link == play.info.link then
				if i ~= 1 then
					play_song(setting.tracks[i - 1], play.repeat_track == 2, i - 1, 'ADD')
					break
				else
					play_song(setting.tracks[#setting.tracks], play.repeat_track == 2, #setting.tracks, 'ADD')
					break
				end
			end
		end
	end
end

function next_track(repeat_param) --> Переключить песню вперёд
	if play.tab == 'SEARCH' and #tracks > 0 then
		for i = 1, #tracks do
			if tracks[i].link == play.info.link then
				if i ~= #tracks then
					play_song(tracks[i + 1], play.repeat_track == 2, i + 1, 'SEARCH')
					break
				elseif repeat_param then
					play_song(tracks[1], play.repeat_track == 2, 1, 'SEARCH')
					break
				end
			end
		end
	elseif play.tab == 'ADD' and #setting.tracks > 0 then
		for i = 1, #setting.tracks do
			if setting.tracks[i].link == play.info.link then
				if i ~= #setting.tracks then
					play_song(setting.tracks[i + 1], play.repeat_track == 2, i + 1, 'ADD')
					break
				elseif repeat_param then
					play_song(setting.tracks[1], play.repeat_track == 2, 1, 'ADD')
					break
				end
			end
		end
	end
end

function shuffle_tracks(all_num) --> Рандомное перемешивание треков
	for i = 1, all_num do
		table.insert(random_tracks, i)
	end
	
	for i = #random_tracks, 2, -1 do
		local j = math.random(i)
		random_tracks[i], random_tracks[j] = random_tracks[j], random_tracks[i]
	end
end

function control_song_when_finished() --> Что делать с песней по её завершению
	if get_status_potok_song() == 3 and play.status == 'PLAY' then
		set_song_status('PLAY')
	elseif get_status_potok_song() == 0 and play.status == 'PLAY' then
		if play.repeat_track == 2 then
			play_song(play.info, play.repeat_track == 2, play.i, play.tab)
		else
			next_track(play.repeat_track == 1)
		end
	end
end

--> Отображение окон
img_step = {imgui.new.int(42)}
img_duration = {imgui.new.int(350)}
local hall = {}
function hall.settings()
	gui.Draw({4, 39}, {220, 369}, cl.tab, 0, 15)
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Вкладка настроек', imgui.ImVec2(222, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	local function new_tab_setting(color_tab_set, icon_tab_set, name_tab_set, num_return_tab_set, num_pos_plus_tab_set, sdvig_icon, sdvig_draw)
		if sdvig_icon == nil then sdvig_icon = {0, 0} end
		if sdvig_draw == nil then sdvig_draw = 0 end
		num_pos_plus_tab_set = num_pos_plus_tab_set + num_return_tab_set
		imgui.SetCursorPos(imgui.ImVec2(0, 66 + ((num_pos_plus_tab_set - 1) * 32)))
		if imgui.InvisibleButton(u8'##Кнопка перехода во вкладку ' .. num_return_tab_set, imgui.ImVec2(220, 29)) then
			tab_settings = num_return_tab_set
			if tab_settings == 13 then
				up_child_sub = 0
				developer_mode = developer_mode + 1
			elseif tab_settings == 6 then
				if setting.fire.auto_send then
					an[27] = 42
					ANIMATE[1] = animate(42, 42, 42, 42, an[27], an[27], 1, 4)
				else
					an[27] = 0
					ANIMATE[2] = animate(0, 0, 0, 0, an[27], an[27], 1, 4)
				end
			elseif tab_settings == 12 then
				if search_for_new_version == 0 and new_version == '0' then
					search_for_new_version = 615
					update_check()
				end
			end
		end
		if num_return_tab_set == tab_settings then
			gui.Draw({10, 66 + ((num_pos_plus_tab_set - 1) * 32)}, {200, 29}, cl.def, 4, 15)
		end
		gui.Draw({14, 70 + ((num_pos_plus_tab_set - 1) * 32)}, {21 + sdvig_draw, 20}, color_tab_set, 4, 15)
		
		imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
		imgui.PushFont(fa_font[2])
		imgui.SetCursorPos(imgui.ImVec2(18 + sdvig_icon[1], 73 + sdvig_icon[2] + ((num_pos_plus_tab_set - 1) * 32)))
		imgui.Text(icon_tab_set)
		imgui.PopFont()
		imgui.PopStyleColor(1)
		if setting.cl == 'White' and num_return_tab_set == tab_settings then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
			gui.Text(43, 73 + ((num_pos_plus_tab_set - 1) * 32), name_tab_set, font[3])
			imgui.PopStyleColor(1)
		else
			gui.Text(43, 73 + ((num_pos_plus_tab_set - 1) * 32), name_tab_set, font[3])
		end
	end
	imgui.Scroller(u8'Вкладка настроек', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	
	if setting.cl == 'White' then
		gui.DrawCircle({29, 32}, 20, cl.circ_im)
	else
		gui.DrawCircle({29, 32}, 20, cl.circ_im)
	end
	--[[
	local smi_text = 'СМИ'
	if setting.smi_name and setting.smi_name ~= '' then
		smi_text = smi_text ..' ' .. setting.smi_name
	end
	local all_org = {'Больница Лос-Сантос', 'Больница Сан-Фиерро', 'Больница Лас-Вентурас', 'Больница Джефферсон', 'Центр Лицензирования', 'Правительство', 'Армия Лос-Сантос', 'Армия Сан-Фиерро', 'Пожарный департамент', 'Тюрьма строгого режима', smi_text}
	]]
	local all_org = {'Больница Лос-Сантос', 'Больница Сан-Фиерро', 'Больница Лас-Вентурас', 'Больница Джефферсон', 'Центр Лицензирования', 'Правительство', 'Армия Лос-Сантос', 'Армия Сан-Фиерро', 'Пожарный департамент', 'Тюрьма строгого режима'}
	local num_char = #u8:decode(setting.name_rus)
	if num_char <= 19 then
		gui.Text(57, 17, u8:decode(setting.name_rus), font[3])
	elseif num_char <= 22 then
		gui.Text(57, 17, u8:decode(setting.name_rus), font[2])
	else
		local wrapped_text, newline_count = wrapText(u8:decode(setting.name_rus), 22, 22)
		gui.Text(57, 17, wrapped_text, font[2])
	end
	
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
	gui.Text(57, 33, all_org[setting.org], font[2])
	imgui.PopStyleColor(1)
	imgui.PushFont(fa_font[4])
	imgui.SetCursorPos(imgui.ImVec2(22, 23))
	imgui.Text(fa.USER)
	imgui.PopFont()
	local pos_tab_pl = 0
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.LOCK, 'Личная информация', 1, 0 + pos_tab_pl, {1, 0})
	new_tab_setting(imgui.ImVec4(0.00, 0.40, 1.00, 1.00), fa.COMMENT, 'Игровой чат', 2, 0 + pos_tab_pl)
	if setting.org <= 5 then
		new_tab_setting(imgui.ImVec4(0.30, 0.80, 0.39, 1.00), fa.COINS, 'Ценовая политика', 3, 0 + pos_tab_pl)
	else
		pos_tab_pl = pos_tab_pl - 1
	end
	new_tab_setting(imgui.ImVec4(1.00, 0.18, 0.33, 1.00), fa.RSS, 'Быстрый доступ', 4, 0 + pos_tab_pl, {1, 0})
	new_tab_setting(imgui.ImVec4(0.00, 0.40, 1.00, 1.00), fa.USER, 'Мемберс', 5, 0 + pos_tab_pl, {1, 0})
	if setting.org <= 4 then
		new_tab_setting(imgui.ImVec4(1.00, 0.18, 0.33, 1.00), fa.TRUCK_MEDICAL, 'Вызовы', 6, 0 + pos_tab_pl, {-1.5, 0})
	elseif setting.org == 9 then
		new_tab_setting(imgui.ImVec4(1.00, 0.18, 0.15, 1.00), fa.FIRE, 'Вызовы', 6, 0 + pos_tab_pl, {1, 0})
	else
		pos_tab_pl = pos_tab_pl -1
	end
	
	new_tab_setting(imgui.ImVec4(0.00, 0.40, 1.00, 1.00), fa.PAPER_PLANE, 'Уведомления', 7, 0.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(1.00, 0.18, 0.33, 1.00), fa.COMMENT_DOTS, 'Акцент', 8, 0.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.TOGGLE_ON, 'Другие функции', 9, 0.5 + pos_tab_pl, {-1, 0})
	
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.COMPACT_DISC, 'Оформление', 10, 1 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.SLIDERS, 'Параметры скрипта', 11, 1 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.70, 0.30, 1.00, 1.00), fa.DOWNLOAD, 'Обновление', 12, 1 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.CODE, 'О скрипте', 13, 1 + pos_tab_pl, {-1, 0}, 1)
	
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.HAMMER, 'Команды', 14, 1.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.BOOK, 'Шпаргалки', 15, 1.5 + pos_tab_pl, {1, 0})
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.SIGNAL, 'Департамент', 16, 1.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.USER_PLUS, 'Собеседование', 17, 1.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.BELL, 'Напоминания', 18, 1.5 + pos_tab_pl, {1, 0})
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.CHART_SIMPLE, 'Статистика', 19, 1.5 + pos_tab_pl, {1, 0})
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.MUSIC, 'Музыка', 20, 1.5 + pos_tab_pl)
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.OBJECT_UNGROUP, 'РП зона', 21, 1.5 + pos_tab_pl, {-1, 0})
	new_tab_setting(imgui.ImVec4(0.56, 0.56, 0.58, 1.00), fa.CUBE, 'Действия', 22, 1.5 + pos_tab_pl) --(0.11, 0.80, 0.62, 1.00)
	
	imgui.Dummy(imgui.ImVec2(0, 8))
	if bool_go_stat_set then
		bool_go_stat_set = false
		imgui.SetScrollY(imgui.GetScrollMaxY())
	end
	imgui.EndChild()
	hovered_bool_not_child = imgui.IsItemHovered()
	
	imgui.SetCursorPos(imgui.ImVec2(226, 39))
	--if tab_settings == 4 then size_y_child = 335 end
	imgui.BeginChild(u8'Суть вкладки главное', imgui.ImVec2(618, tab_settings == 4 and 335 or 369), false, imgui.WindowFlags.NoScrollWithMouse + (tab_settings == 13 and imgui.WindowFlags.NoScrollbar or 0))
	imgui.Scroller(u8'Суть вкладки главное', img_step[1][0], img_duration[1][0])
	
	local function cmd_amd_key_tab(i_tabs)
		local cmd_text_edit = u8'Назначить...'
		local key_text_edit = u8'Назначить...'
		local func_true_or_false_return = false
		if setting.key_tabs[i_tabs][1] ~= '' then
			key_text_edit = u8'Изменить...'
		end
		if setting.command_tabs[i_tabs] ~= '' then
			cmd_text_edit = u8'Изменить...'
		end
		new_draw(16, 71)
		gui.DrawLine({16, 51}, {602, 51}, cl.line)
		gui.Text(26, 25, 'Команда для открытия вкладки:', font[3])
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(241, 24))
		if setting.command_tabs[i_tabs] == '' then
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8'Отсутствует')
		else
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8'/' .. setting.command_tabs[i_tabs])
			func_true_or_false_return = true
		end
		imgui.PopFont()
		if gui.Button(cmd_text_edit .. u8'##команду для вкладки', {492, 21}, {100, 25}) then
			lockPlayerControl(true)
			edit_cmd = true
			cur_cmd = setting.command_tabs[i_tabs]
			new_cmd = setting.command_tabs[i_tabs]
			imgui.OpenPopup(u8'Изменить команду для открытия вкладки' .. i_tabs)
		end
		
		gui.Text(26, 61, 'Клавиша активации для открытия вкладки:', font[3])
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(312, 62))
		if setting.key_tabs[i_tabs][1] == '' then
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8'Отсутствует')
		else
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), setting.key_tabs[i_tabs][1])
		end
		imgui.PopFont()
		if gui.Button(key_text_edit .. u8'##клавишу активации для вкладки', {492, 57}, {100, 25}) then
			current_key = {'', {}}
			imgui.OpenPopup(u8'Изменить клавишу активации открытия вкладки' .. i_tabs)
			lockPlayerControl(true)
			edit_key = true
			win_key = setting.key_tabs[1][2]
		end
		
		local bool_result = key_edit(u8'Изменить клавишу активации открытия вкладки' .. i_tabs, setting.key_tabs[i_tabs])
		if bool_result[1] then
			setting.key_tabs[i_tabs] = bool_result[2]
			save()
		end
		
		if edit_cmd then
			local cmd_end = cmd_edit(u8'Изменить команду для открытия вкладки' .. i_tabs, cur_cmd)
			if cmd_end then
				if cmd_end ~= '' then
					setting.command_tabs[i_tabs] = cmd_end
					sampRegisterChatCommand(cmd_end, function(arg)
						start_other_cmd(cmd_end, arg)
					end)
				else
					setting.command_tabs[i_tabs] = ''
				end
				save()
				add_cmd_in_all_cmd()
			end
		end
		
		return func_true_or_false_return
	end
	
	if tab_settings == 1 then
		gui.Text(25, 12, 'Основное', bold_font[1])
		new_draw(37, 87)
		
		gui.Text(26, 50, 'Никнейм на русском', font[3])
		local bool_save_input = setting.name_rus
		setting.name_rus = gui.InputText({350, 52}, 231, setting.name_rus, u8'Имя на русском языке', 60, u8'Введите Ваш никнейм на русском', 'rus')
		if setting.name_rus ~= bool_save_input then
			save()
		end
		gui.DrawLine({16, 80}, {602, 80}, cl.line)
		gui.Text(26, 94, 'Пол персонажа', font[3])
		
		local bool_save_list = setting.sex
		setting.sex = gui.ListTableHorizontal({348, 91}, {u8'Мужской', u8'Женский'}, setting.sex, u8'Выбрать пол персонажа')
		if setting.sex ~= bool_save_list then
			save()
		end
		
		gui.Text(25, 143, 'Организация', bold_font[1])
		new_draw(168, 87)
		
		gui.Text(26, 181, 'Организация', font[3])
		local bool_set_org = setting.org
		--[[
		local smi_text = u8'СМИ'
		if setting.smi_name and setting.smi_name ~= '' then
    		smi_text = smi_text ..' ' .. setting.smi_name
		end
		setting.org = gui.ListTableMove({572, 181},{u8'Больница Лос-Сантос', u8'Больница Сан-Фиерро', u8'Больница Лас-Вентурас', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Правительство', u8'Армия Лос-Сантос', u8'Армия Сан-Фиерро', u8'Пожарный департамент', u8'Тюрьма строгого режима', smi_text},setting.org, 'Select Organization')
]]
		setting.org = gui.ListTableMove({572, 181}, {u8'Больница Лос-Сантос', u8'Больница Сан-Фиерро', u8'Больница Лас-Вентурас', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Правительство', u8'Армия Лос-Сантос', u8'Армия Сан-Фиерро', u8'Пожарный департамент', u8'Тюрьма строгого режима'}, setting.org, 'Select Organization')
		if setting.org ~= bool_set_org then
			if setting.org <= 4 then --> Для Больниц
				for i = 1, #cmd_defoult.hospital do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.hospital[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.hospital[i])
						sampRegisterChatCommand(cmd_defoult.hospital[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.hospital[i].UID) .. cmd_defoult.hospital[i].cmd) end)
						
						if server == '185.169.134.3:7777' then 
							for i = 1, #cmd[1] do
								if cmd[1][i].cmd == 'mc' then
									cmd[1][i] = mc_phoenix
								end
							end
						end
					end
				end
			elseif setting.org == 5 then --> Для ЦЛ
				for i = 1, #cmd_defoult.driving_school do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.driving_school[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.driving_school[i])
						sampRegisterChatCommand(cmd_defoult.driving_school[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.driving_school[i].UID) .. cmd_defoult.driving_school[i].cmd) end)
					end
				end
			elseif setting.org == 6 then --> Для Права
				for i = 1, #cmd_defoult.government do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.government[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.government[i])
						sampRegisterChatCommand(cmd_defoult.government[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.government[i].UID) .. cmd_defoult.government[i].cmd) end)
					end
				end
			elseif setting.org == 7 or setting.org == 8 then --> Для Армии
				for i = 1, #cmd_defoult.army do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.army[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.army[i])
						sampRegisterChatCommand(cmd_defoult.army[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.army[i].UID) .. cmd_defoult.army[i].cmd) end)
					end
					setting.gun_func = true
				end
			elseif setting.org == 9 then --> Для Пожарки
				for i = 1, #cmd_defoult.fire_department do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.fire_department[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.fire_department[i])
						sampRegisterChatCommand(cmd_defoult.fire_department[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.fire_department[i].UID) .. cmd_defoult.fire_department[i].cmd) end)
					end
				end
			elseif setting.org == 10 then --> Для ТСР
				for i = 1, #cmd_defoult.jail do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.jail[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.jail[i])
						sampRegisterChatCommand(cmd_defoult.jail[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.jail[i].UID) .. cmd_defoult.jail[i].cmd) end)
					end
					setting.gun_func = true
				end
			elseif setting.org == 11 then
				for i = 1, #cmd_defoult.smi do
					local command_return = false
					if #cmd[1] ~= 0 then
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == cmd_defoult.smi[i].cmd then
								command_return = true
							end
						end
					end
					if not command_return then
						table.insert(cmd[1], cmd_defoult.smi[i])
						sampRegisterChatCommand(cmd_defoult.smi[i].cmd, function(arg) 
						cmd_start(arg, tostring(cmd_defoult.smi[i].UID) .. cmd_defoult.smi[i].cmd) end)
					end
				end
			end
			add_cmd_in_all_cmd()
			save_cmd()
			save()
		end
		gui.DrawLine({16, 211}, {602, 211}, cl.line)
		
		gui.Text(26, 225, 'Должность', font[3])
		
		if setting.job_title == u8'Не определено' then
			local calc_jt = imgui.CalcTextSize(setting.job_title)
			gui.Text(587 - calc_jt.x, 225, u8:decode(setting.job_title), font[3])
		else
			local calc_jt = imgui.CalcTextSize(setting.job_title .. ' [' .. setting.rank ..']')
			gui.Text(587 - calc_jt.x, 225, u8:decode(setting.job_title .. ' [' .. setting.rank ..']'), font[3])
		end
	elseif tab_settings == 2 then
		gui.Text(25, 12, 'Получаемые сообщения', bold_font[1])
		new_draw(37, 431)
		
		for i = 0, 10 do
			gui.DrawLine({16, 72 + (i * 36)}, {602, 72 + (i * 36)}, cl.line)
		end
		
		gui.Text(26, 46, 'Скрыть частые подсказки сервера', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 42))
		if gui.Switch(u8'##Скрыть частые подсказки', setting.put_mes[1]) then
			setting.put_mes[1] = not setting.put_mes[1]
			save()
		end
		gui.Text(26, 82, 'Скрыть объявления в СМИ от игроков', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 77))
		if gui.Switch(u8'##Скрыть объявления в СМИ от игроков', setting.put_mes[2]) then
			setting.put_mes[2] = not setting.put_mes[2]
			save()
		end
		gui.Text(26, 118, 'Скрыть репортажи и новости от СМИ', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 113))
		if gui.Switch(u8'##Скрыть репортажи и новости от СМИ', setting.put_mes[3]) then
			setting.put_mes[3] = not setting.put_mes[3]
			save()
		end
		gui.Text(26, 154, 'Скрыть удачи игроков при открытии ларцов', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 149))
		if gui.Switch(u8'##Скрыть удачи игроков при открытии ларцов', setting.put_mes[4]) then
			setting.put_mes[4] = not setting.put_mes[4]
			save()
		end
		gui.Text(26, 190, 'Скрыть информацию о сборе средств в организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 185))
		if gui.Switch(u8'##Скрыть информацию о сборе средств в организации', setting.put_mes[5]) then
			setting.put_mes[5] = not setting.put_mes[5]
			save()
		end
		gui.Text(26, 226, 'Скрыть сообщения в вип чате', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 221))
		if gui.Switch(u8'##Скрыть сообщения в вип чате', setting.put_mes[6]) then
			setting.put_mes[6] = not setting.put_mes[6]
			save()
		end
		gui.Text(26, 262, 'Скрыть сообщения о лотерее', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 257))
		if gui.Switch(u8'##Скрыть сообщения о лотерее', setting.put_mes[7]) then
			setting.put_mes[7] = not setting.put_mes[7]
			save()
		end
		gui.Text(26, 298, 'Скрыть государственные новости', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 293))
		if gui.Switch(u8'##Скрыть государственные новости', setting.put_mes[8]) then
			setting.put_mes[8] = not setting.put_mes[8]
			save()
		end
		gui.Text(26, 334, 'Скрыть сообщения рации департамента', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 329))
		if gui.Switch(u8'##Скрыть сообщения рации департамента', setting.put_mes[9]) then
			setting.put_mes[9] = not setting.put_mes[9]
			save()
		end
		gui.Text(26, 370, 'Скрыть сообщения рации организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 365))
		if gui.Switch(u8'##Скрыть сообщения рации организации', setting.put_mes[10]) then
			setting.put_mes[10] = not setting.put_mes[10]
			save()
		end
		gui.Text(26, 406, 'Заменить сообщения о флуде всплывающей надписью', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 401))
		if gui.Switch(u8'##Заменить сообщение о флуде', setting.replace_not_flood) then
			setting.replace_not_flood = not setting.replace_not_flood
			save()
		end
		gui.Text(26, 442, 'Изменить цвет ника по цвету организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 437))
		if gui.Switch(u8'##Цветные ники', setting.color_nick) then
			setting.color_nick = not setting.color_nick
			save()
		end
		if setting.color_nick then
			if gui.Button(u8'Настроить', {370, 442}, {130, 20}) then
				imgui.OpenPopup(u8'Настроить цвет ника')
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
			gui.Button(u8'Настроить', {370, 442}, {130, 20}, false)
			imgui.PopStyleColor(3)
		end
		if imgui.BeginPopupModal(u8'Настроить цвет ника', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			imgui.BeginChild(u8'Настройки цветов', imgui.ImVec2(730, 164), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(710, 2))
			if imgui.InvisibleButton(u8'##Закрыть окно настроек', imgui.ImVec2(20, 20)) then
				save()
				imgui.CloseCurrentPopup()
			end
			if imgui.IsItemHovered() then
				gui.DrawCircle({721, 12}, 7, imgui.ImVec4(0.98, 0.30, 0.38, 1.00))
			else
				gui.DrawCircle({721, 12}, 7, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
			end			
			gui.Draw({16, 16}, {698, 148}, cl.tab, 7, 15)
			gui.Text(26, 26, 'Заменять цвет текста в IC сообщениях', font[3])
			imgui.SameLine(0, 10)
			if gui.Switch(u8'##Заменить IC', setting.replace_ic) then
				setting.replace_ic = not setting.replace_ic
				save()
			end
			gui.Text(26, 62, 'Заменять цвет текста в /s', font[3])
			imgui.SameLine(0, 10)
			if gui.Switch(u8'##Заменить /s', setting.replace_s) then
				setting.replace_s = not setting.replace_s
				save()
			end
			gui.Text(26, 98, 'Заменять цвет текста в /c', font[3])
			imgui.SameLine(0, 10)
			if gui.Switch(u8'##Заменить /c', setting.replace_c) then
				setting.replace_c = not setting.replace_c
				save()
			end
			gui.Text(26, 134, 'Заменять цвет текста в /b', font[3])
			imgui.SameLine(0, 10)
			if gui.Switch(u8'##Заменить /b', setting.replace_b) then
				setting.replace_b = not setting.replace_b
				save()
			end
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.EndChild()
			imgui.Dummy(imgui.ImVec2(0, 13))
			imgui.EndPopup()
		end

		gui.Text(25, 487, 'Отыгровки', bold_font[1])
		new_draw(512, 399)
		
		gui.Text(26, 521, 'Автокоррекция отыгровок /me, /do, /todo', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 516))
		if gui.Switch(u8'##Автокоррекция отыгровок', setting.auto_edit) then
			setting.auto_edit = not setting.auto_edit
			save()
		end
		gui.DrawLine({16, 547}, {602, 547}, cl.line)
		gui.Text(26, 557, 'Автоотыгровка при принятии документов', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 552))
		if gui.Switch(u8'##Автоотыгровка при принятии документов', setting.auto_cmd_doc) then
			setting.auto_cmd_doc = not setting.auto_cmd_doc
			save()
		end
		gui.TextInfo({26, 576}, {'При просмотре паспорта, лицензий, медицинской карты или трудовой книжки, будет', 'автоматически воспроизведена отыгровка взятия просматриваемого документа.'})
		gui.DrawLine({16, 615}, {602, 615}, cl.line)
		gui.Text(26, 625, 'Автоотыгровка при закрытии документов', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 621))
		if gui.Switch(u8'##Автоотыгровка при закрытии документов', setting.auto_close_doc) then
    		setting.auto_close_doc = not setting.auto_close_doc
    		save()
		end
		gui.TextInfo({26, 644}, {'При закрытии окна с документами в чате автоматически будет воспроизведена отыгровка.'})
		gui.DrawLine({16, 673}, {602, 673}, cl.line)
		gui.Text(26, 683, 'Автоотыгровка дубинки', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 679))
		if gui.Switch(u8'##Автоотыгровка дубинки', setting.auto_cmd_tazer) then
    		setting.auto_cmd_tazer = not setting.auto_cmd_tazer
    		save()
		end
		gui.DrawLine({16, 710}, {602, 710}, cl.line)
		gui.Text(26, 724, 'Автоотыгровка /time', font[3])
		local bool_set_time = setting.auto_cmd_time
		setting.auto_cmd_time = gui.InputText({190, 726}, 391, setting.auto_cmd_time, u8'Автоотыгровка time', 230, u8'Введите текст отыгровки')
		if setting.auto_cmd_time ~= bool_set_time then
    		save()
		end
		gui.TextInfo({26, 753}, {'После ввода команды /time, будет автоматически воспроизведена введённая Вами отыгровка.', 'Оставьте поле пустым, если не нужно.'})
		gui.DrawLine({16, 789}, {602, 789}, cl.line)
		gui.Text(26, 803, 'Автоотыгровка /r', font[3])
		local bool_set_r = setting.auto_cmd_r
		setting.auto_cmd_r = gui.InputText({190, 805}, 391, setting.auto_cmd_r, u8'Автоотыгровка r', 230, u8'Введите текст отыгровки')
		if setting.auto_cmd_r ~= bool_set_r then
    		save()
		end
		new_draw(884, 107)
		gui.TextInfo({26, 832}, {'После ввода команды /r, будет автоматически воспроизведена введённая Вами отыгровка.', 'Оставьте поле пустым, если не нужно.'})
		gui.Text(26, 898, 'Тег в рацию /r', font[3])
		local bool_set_teg = setting.teg_r
		setting.teg_r = gui.InputText({190, 900}, 311, setting.teg_r, u8'Тег в рацию организации', 250, u8'Введите тег для рации')
		if setting.teg_r ~= bool_set_teg then
    		save()
		end
		gui.TextInfo({26, 927}, {'О необходимости использования тега уточните у лидера Вашей организации.'})
		new_draw(964, 116)
		if setting.gun_func then
		gui.Text(26, 1014, 'Отыгровки оружия', font[3])
			if gui.Button(u8'Редактировать...', {460, 1011}, {130, 25}) then
				imgui.OpenPopup(u8'Редактировать отыгровки оружия')
				gun_bool = deep_copy(setting.gun)
			end
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
			gui.Text(26, 1014, 'Отыгровки оружия', font[3])
			imgui.PopStyleColor(1)
			gui.Button(u8'Редактировать...', {460, 1011}, {130, 25}, false)
		end

		gui.Text(26, 978, 'Использовать автоотыгровки при взаимодействии с оружием', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 974))
		if gui.Switch(u8'##Автоотыгровка взаимодействия с оружием', setting.gun_func) then
			setting.gun_func = not setting.gun_func
			save()
		end
		new_draw(1053, 127)

		gui.Text(26, 1068, 'Автоматический перенос длинного текста в игровом чате', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 1063))
		if gui.Switch(u8'##Автоматический перенос длинного текста в игровом чате', setting.wrap_text_chat.func) then
			setting.wrap_text_chat.func = not setting.wrap_text_chat.func
			save()
		end

		if setting.wrap_text_chat.func then
			gui.Text(26, 1106, 'Переносить текст после достижения', font[3])
			local bool_set_wrap = setting.wrap_text_chat.num_char
			setting.wrap_text_chat.num_char = gui.InputText({274, 1106}, 30, setting.wrap_text_chat.num_char, u8'Количество символов переносимого текста', 4, u8'Число', 'num')
			if setting.wrap_text_chat.num_char ~= bool_set_wrap then
				if setting.wrap_text_chat.num_char == '' then
					setting.wrap_text_chat.num_char = '128'
				end
				save()
			end
			gui.Text(320, 1106, 'символов', font[3])
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
			gui.Text(26, 1106, 'Переносить текст после достижения', font[3])
			gui.Text(320, 1106, 'символов', font[3])
			gui.InputFalse(setting.wrap_text_chat.num_char, 274, 1106, 30)
			imgui.PopStyleColor(1)
		end

		if imgui.BeginPopupModal(u8'Редактировать отыгровки оружия', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(0, 0))
			imgui.BeginChild(u8'Редактор отыгровок оружия', imgui.ImVec2(730, 370), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
			imgui.Scroller(u8'Редактор отыгровок оружия', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
			local pos_y = 0
			for i = 1, #gun_bool do
				gui.Text(25, 14 + pos_y, gun_bool[i].name_gun, bold_font[1])
				gui.Draw({16, 39 + pos_y}, {698, 71}, cl.tab, 7, 15)
				gui.DrawLine({16, 74 + pos_y}, {714, 74 + pos_y}, cl.line)
				gui.DrawCircleEmp({33.5, 56.5 + pos_y}, 10, cl.bg2, 2)
				imgui.SetCursorPos(imgui.ImVec2(20, 43 + pos_y))
				if imgui.InvisibleButton(u8'##Использовать отыгровку взятия оружия' .. i, imgui.ImVec2(27, 27)) then
					gun_bool[i].take = not gun_bool[i].take
				end
				if imgui.IsItemActive() then
					gui.DrawCircle({33.5, 56.5 + pos_y}, 10, cl.bg2, 2)
				end
				if gun_bool[i].take then
					gui.FaText(28, 50 + pos_y, fa.CHECK, fa_font[2])
				end
				gun_bool[i].take_rp = gui.InputText({57, 50 + pos_y}, 637, gun_bool[i].take_rp, u8'Взятие оружия' .. i, 260, u8'Введите текст взятия оружия')
				
				gui.DrawCircleEmp({33.5, 92.5 + pos_y}, 10, cl.bg2, 2)
				imgui.SetCursorPos(imgui.ImVec2(20, 79 + pos_y))
				if imgui.InvisibleButton(u8'##Использовать отыгровку убирания оружия' .. i, imgui.ImVec2(27, 27)) then
					gun_bool[i].put = not gun_bool[i].put
				end
				if imgui.IsItemActive() then
					gui.DrawCircle({33.5, 92.5 + pos_y}, 10, cl.bg2, 2)
				end
				if gun_bool[i].put then
					gui.FaText(28, 86 + pos_y, fa.CHECK, fa_font[2])
				end
				gun_bool[i].put_rp = gui.InputText({57, 86 + pos_y}, 637, gun_bool[i].put_rp, u8'Убирание оружия' .. i, 260, u8'Введите текст убирания оружия из виду')
			
				pos_y = pos_y + 115
			end
			
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.EndChild()
			
			gui.DrawLine({10, 370}, {720, 370}, cl.line)
			if gui.Button(u8'Сохранить и выйти', {10, 381}, {230, 31}) then
				setting.gun = deep_copy(gun_bool)
				save()
				imgui.CloseCurrentPopup()
			end
			if gui.Button(u8'Отменить текущие изменения', {250, 381}, {230, 31}) then
				imgui.CloseCurrentPopup()
			end
			if gui.Button(u8'Сбросить отыгровки до дефолта', {490, 381}, {230, 31}) then
				gun_bool = deep_copy(gun_orig)
			end
			imgui.Dummy(imgui.ImVec2(0, 13))
			imgui.EndPopup()
		end
		
		imgui.Dummy(imgui.ImVec2(0, 24))
	elseif tab_settings == 3 then
		if setting.org <= 4 then
			gui.Text(25, 12, 'Разное', bold_font[1])
			new_draw(37, 131)
		
			gui.Text(26, 50, 'Лечение', font[3])
			local bool_set_lec = setting.price[1].lec
			setting.price[1].lec = gui.InputText({130, 52}, 100, setting.price[1].lec, u8'Цена лечения', 20, u8'Цена', 'num')
			if setting.price[1].lec ~= bool_set_lec then save() end
			gui.DrawLine({16, 80}, {602, 80}, cl.line)
			gui.Text(26, 94, 'Наркоз-ость', font[3])
			local bool_set_narko = setting.price[1].lec
			setting.price[1].narko = gui.InputText({130, 96}, 100, setting.price[1].narko, u8'Цена нарко', 20, u8'Цена', 'num')
			if setting.price[1].narko ~= bool_set_narko then save() end
			gui.DrawLine({16, 124}, {602, 124}, cl.line)
			gui.Text(26, 138, 'Мед. осмотр', font[3])
			local bool_set_osm = setting.price[1].osm
			setting.price[1].osm = gui.InputText({130, 140}, 100, setting.price[1].osm, u8'Цена осмотра', 20, u8'Цена', 'num')
			if setting.price[1].osm ~= bool_set_osm then save() end
			gui.Text(381, 50, 'Рецепт', font[3])
			local bool_set_rec = setting.price[1].rec
			setting.price[1].rec = gui.InputText({481, 52}, 100, setting.price[1].rec, u8'Цена рецепта', 20, u8'Цена', 'num')
			if setting.price[1].rec ~= bool_set_rec then save() end
			gui.Text(381, 94, 'Тату', font[3])
			local bool_set_tatu = setting.price[1].tatu
			setting.price[1].tatu = gui.InputText({481, 96}, 100, setting.price[1].tatu, u8'Цена тату', 20, u8'Цена', 'num')
			if setting.price[1].tatu ~= bool_set_tatu then save() end
			gui.Text(381, 138, 'Антибиотик', font[3])
			local bool_set_ant = setting.price[1].ant
			setting.price[1].ant = gui.InputText({481, 140}, 100, setting.price[1].ant, u8'Цена антибиотика', 20, u8'Цена', 'num')
			if setting.price[1].ant ~= bool_set_ant then save() end
			
			gui.Text(25, 187, 'Медицинская карта', bold_font[1])
			new_draw(212, 175)
			
			gui.Text(26, 225, 'Новая на 7 дней', font[3])
			local bool_set_mc1 = setting.price[1].mc[1]
			setting.price[1].mc[1] = gui.InputText({154, 227}, 100, setting.price[1].mc[1], u8'Цена мед карты 7 дней новая', 20, u8'Цена', 'num')
			if setting.price[1].mc[1] ~= bool_set_mc1 then save() end
			gui.DrawLine({16, 255}, {602, 255}, cl.line)
			gui.Text(26, 269, 'Новая на 14 дней', font[3])
			local bool_set_mc2 = setting.price[1].mc[2]
			setting.price[1].mc[2] = gui.InputText({154, 271}, 100, setting.price[1].mc[2], u8'Цена мед карты 14 дней новая', 20, u8'Цена', 'num')
			if setting.price[1].mc[2] ~= bool_set_mc2 then save() end
			gui.DrawLine({16, 299}, {602, 299}, cl.line)
			gui.Text(26, 313, 'Новая на 30 дней', font[3])
			local bool_set_mc3 = setting.price[1].mc[3]
			setting.price[1].mc[3] = gui.InputText({154, 315}, 100, setting.price[1].mc[3], u8'Цена мед карты 30 дней новая', 20, u8'Цена', 'num')
			if setting.price[1].mc[3] ~= bool_set_mc3 then save() end
			gui.DrawLine({16, 343}, {602, 343}, cl.line)
			gui.Text(26, 357, 'Новая на 60 дней', font[3])
			local bool_set_mc4 = setting.price[1].mc[4]
			setting.price[1].mc[4] = gui.InputText({154, 359}, 100, setting.price[1].mc[4], u8'Цена мед карты 60 дней новая', 20, u8'Цена', 'num')
			if setting.price[1].mc[4] ~= bool_set_mc4 then save() end
			
			gui.Text(330, 225, 'Обновить на 7 дней', font[3])
			local bool_set_mcupd1 = setting.price[1].mcupd[1]
			setting.price[1].mcupd[1] = gui.InputText({481, 227}, 100, setting.price[1].mcupd[1], u8'Цена мед карты 7 дней обновить', 20, u8'Цена', 'num')
			if setting.price[1].mcupd[1] ~= bool_set_mcupd1 then save() end
			gui.Text(330, 269, 'Обновить на 14 дней', font[3])
			local bool_set_mcupd2 = setting.price[1].mcupd[2]
			setting.price[1].mcupd[2] = gui.InputText({481, 271}, 100, setting.price[1].mcupd[2], u8'Цена мед карты 14 дней обновить', 20, u8'Цена', 'num')
			if setting.price[1].mcupd[2] ~= bool_set_mcupd2 then save() end
			gui.Text(330, 313, 'Обновить на 30 дней', font[3])
			local bool_set_mcupd3 = setting.price[1].mcupd[3]
			setting.price[1].mcupd[3] = gui.InputText({481, 315}, 100, setting.price[1].mcupd[3], u8'Цена мед карты 30 дней обновить', 20, u8'Цена', 'num')
			if setting.price[1].mcupd[3] ~= bool_set_mcupd3 then save() end
			gui.Text(330, 357, 'Обновить на 60 дней', font[3])
			local bool_set_mcupd4 = setting.price[1].mcupd[4]
			setting.price[1].mcupd[4] = gui.InputText({481, 359}, 100, setting.price[1].mcupd[4], u8'Цена мед карты 60 дней обновить', 20, u8'Цена', 'num')
			if setting.price[1].mcupd[4] ~= bool_set_mcupd4 then save() end
			
			imgui.Dummy(imgui.ImVec2(0, 26))
		elseif setting.org == 5 then
			new_draw(16, 428)
			
			gui.DrawLine({109, 16}, {109, 444}, cl.line)
			gui.DrawLine({273, 16}, {273, 444}, cl.line)
			gui.DrawLine({437, 16}, {437, 444}, cl.line)
			gui.DrawLine({16, 44}, {602, 44}, cl.line)
			gui.DrawLine({16, 84}, {602, 84}, cl.line)
			gui.DrawLine({16, 124}, {602, 124}, cl.line)
			gui.DrawLine({16, 164}, {602, 164}, cl.line)
			gui.DrawLine({16, 204}, {602, 204}, cl.line)
			gui.DrawLine({16, 244}, {602, 244}, cl.line)
			gui.DrawLine({16, 284}, {602, 284}, cl.line)
			gui.DrawLine({16, 324}, {602, 324}, cl.line)
			gui.DrawLine({16, 364}, {602, 364}, cl.line)
			gui.DrawLine({16, 404}, {602, 404}, cl.line)
			
			gui.Text(166, 21, '1 месяц', font[3])
			gui.Text(326, 21, '2 месяца', font[3])
			gui.Text(490, 21, '3 месяца', font[3])
			
			gui.Text(26, 56, 'Авто', font[3])
			gui.Text(26, 96, 'Мото', font[3])
			gui.Text(26, 136, 'Полёты', font[3])
			gui.Text(26, 176, 'Рыбалка', font[3])
			gui.Text(26, 216, 'Водное т/c', font[3])
			gui.Text(26, 256, 'Оружие', font[3])
			gui.Text(26, 296, 'Охота', font[3])
			gui.Text(26, 336, 'Раскопки', font[3])
			gui.Text(26, 376, 'Такси', font[3])
			gui.Text(26, 416, 'Механик', font[3])
			
			local bool_set_auto1 = setting.price[2].auto[1]
			setting.price[2].auto[1] = gui.InputText({140, 58}, 99, setting.price[2].auto[1], u8'Цена авто 1', 20, u8'Цена', 'num')
			if setting.price[2].auto[1] ~= bool_set_auto1 then save() end
			local bool_set_auto1 = setting.price[2].auto[2]
			setting.price[2].auto[2] = gui.InputText({304, 58}, 99, setting.price[2].auto[2], u8'Цена авто 2', 20, u8'Цена', 'num')
			if setting.price[2].auto[2] ~= bool_set_auto1 then save() end
			local bool_set_auto1 = setting.price[2].auto[3]
			setting.price[2].auto[3] = gui.InputText({468, 58}, 99, setting.price[2].auto[3], u8'Цена авто 3', 20, u8'Цена', 'num')
			if setting.price[2].auto[3] ~= bool_set_auto1 then save() end
			
			local bool_set_moto1 = setting.price[2].moto[1]
			setting.price[2].moto[1] = gui.InputText({140, 98}, 99, setting.price[2].moto[1], u8'Цена мото 1', 20, u8'Цена', 'num')
			if setting.price[2].moto[1] ~= bool_set_moto1 then save() end
			local bool_set_moto2 = setting.price[2].moto[2]
			setting.price[2].moto[2] = gui.InputText({304, 98}, 99, setting.price[2].moto[2], u8'Цена мото 2', 20, u8'Цена', 'num')
			if setting.price[2].moto[2] ~= bool_set_moto2 then save() end
			local bool_set_moto3 = setting.price[2].moto[3]
			setting.price[2].moto[3] = gui.InputText({468, 98}, 99, setting.price[2].moto[3], u8'Цена мото 3', 20, u8'Цена', 'num')
			if setting.price[2].moto[3] ~= bool_set_moto3 then save() end
			
			local bool_set_fly1 = setting.price[2].fly[1]
			setting.price[2].fly[1] = gui.InputText({140, 138}, 99, setting.price[2].fly[1], u8'Цена полёты', 20, u8'Цена', 'num')
			if setting.price[2].fly[1] ~= bool_set_moto11 then save() end
			gui.Text(316, 136, 'Недоступно', font[3])
			gui.Text(480, 136, 'Недоступно', font[3])
			
			local bool_set_fish1 = setting.price[2].fish[1]
			setting.price[2].fish[1] = gui.InputText({140, 178}, 99, setting.price[2].fish[1], u8'Цена рыба 1', 20, u8'Цена', 'num')
			if setting.price[2].fish[1] ~= bool_set_fish1 then save() end
			local bool_set_fish2 = setting.price[2].fish[2]
			setting.price[2].fish[2] = gui.InputText({304, 178}, 99, setting.price[2].fish[2], u8'Цена рыба 2', 20, u8'Цена', 'num')
			if setting.price[2].fish[2] ~= bool_set_fish2 then save() end
			local bool_set_fish3 = setting.price[2].fish[3]
			setting.price[2].fish[3] = gui.InputText({468, 178}, 99, setting.price[2].fish[3], u8'Цена рыба 3', 20, u8'Цена', 'num')
			if setting.price[2].fish[3] ~= bool_set_fish3 then save() end
			
			local bool_set_swim1 = setting.price[2].swim[1]
			setting.price[2].swim[1] = gui.InputText({140, 218}, 99, setting.price[2].swim[1], u8'Цена плавание 1', 20, u8'Цена', 'num')
			if setting.price[2].swim[1] ~= bool_set_swim1 then save() end
			local bool_set_swim2 = setting.price[2].swim[2]
			setting.price[2].swim[2] = gui.InputText({304, 218}, 99, setting.price[2].swim[2], u8'Цена плавание 2', 20, u8'Цена', 'num')
			if setting.price[2].swim[2] ~= bool_set_swim2 then save() end
			local bool_set_swim3 = setting.price[2].swim[3]
			setting.price[2].swim[3] = gui.InputText({468, 218}, 99, setting.price[2].swim[3], u8'Цена плавание 3', 20, u8'Цена', 'num')
			if setting.price[2].swim[3] ~= bool_set_swim3 then save() end
			
			local bool_set_gun1 = setting.price[2].gun[1]
			setting.price[2].gun[1] = gui.InputText({140, 258}, 99, setting.price[2].gun[1], u8'Цена оружие 1', 20, u8'Цена', 'num')
			if setting.price[2].gun[1] ~= bool_set_gun1 then save() end
			local bool_set_gun2 = setting.price[2].gun[2]
			setting.price[2].gun[2] = gui.InputText({304, 258}, 99, setting.price[2].gun[2], u8'Цена оружие 2', 20, u8'Цена', 'num')
			if setting.price[2].gun[2] ~= bool_set_gun2 then save() end
			local bool_set_gun3 = setting.price[2].gun[3]
			setting.price[2].gun[3] = gui.InputText({468, 258}, 99, setting.price[2].gun[3], u8'Цена оружие 3', 20, u8'Цена', 'num')
			if setting.price[2].gun[3] ~= bool_set_gun3 then save() end
			
			local bool_set_hunt1 = setting.price[2].hunt[1]
			setting.price[2].hunt[1] = gui.InputText({140, 298}, 99, setting.price[2].hunt[1], u8'Цена охота 1', 20, u8'Цена', 'num')
			if setting.price[2].hunt[1] ~= bool_set_hunt1 then save() end
			local bool_set_hunt2 = setting.price[2].hunt[2]
			setting.price[2].hunt[2] = gui.InputText({304, 298}, 99, setting.price[2].hunt[2], u8'Цена охота 2', 20, u8'Цена', 'num')
			if setting.price[2].hunt[2] ~= bool_set_hunt2 then save() end
			local bool_set_hunt3 = setting.price[2].hunt[3]
			setting.price[2].hunt[3] = gui.InputText({468, 298}, 99, setting.price[2].hunt[3], u8'Цена охота 3', 20, u8'Цена', 'num')
			if setting.price[2].hunt[3] ~= bool_set_hunt3 then save() end
			
			local bool_set_exc1 = setting.price[2].exc[1]
			setting.price[2].exc[1] = gui.InputText({140, 338}, 99, setting.price[2].exc[1], u8'Цена раскопки 1', 20, u8'Цена', 'num')
			if setting.price[2].exc[1] ~= bool_set_exc1 then save() end
			local bool_set_exc2 = setting.price[2].exc[2]
			setting.price[2].exc[2] = gui.InputText({304, 338}, 99, setting.price[2].exc[2], u8'Цена раскопки 2', 20, u8'Цена', 'num')
			if setting.price[2].exc[2] ~= bool_set_exc2 then save() end
			local bool_set_exc3 = setting.price[2].exc[3]
			setting.price[2].exc[3] = gui.InputText({468, 338}, 99, setting.price[2].exc[3], u8'Цена раскопки 3', 20, u8'Цена', 'num')
			if setting.price[2].exc[3] ~= bool_set_exc3 then save() end
			
			local bool_set_taxi1 = setting.price[2].taxi[1]
			setting.price[2].taxi[1] = gui.InputText({140, 378}, 99, setting.price[2].taxi[1], u8'Цена такси 1', 20, u8'Цена', 'num')
			if setting.price[2].taxi[1] ~= bool_set_taxi1 then save() end
			local bool_set_taxi2 = setting.price[2].taxi[2]
			setting.price[2].taxi[2] = gui.InputText({304, 378}, 99, setting.price[2].taxi[2], u8'Цена такси 2', 20, u8'Цена', 'num')
			if setting.price[2].taxi[2] ~= bool_set_taxi2 then save() end
			local bool_set_taxi3 = setting.price[2].taxi[3]
			setting.price[2].taxi[3] = gui.InputText({468, 378}, 99, setting.price[2].taxi[3], u8'Цена такси 3', 20, u8'Цена', 'num')
			if setting.price[2].taxi[3] ~= bool_set_taxi3 then save() end
			
			local bool_set_meh1 = setting.price[2].meh[1]
			setting.price[2].meh[1] = gui.InputText({140, 418}, 99, setting.price[2].meh[1], u8'Цена механик 1', 20, u8'Цена', 'num')
			if setting.price[2].meh[1] ~= bool_set_meh1 then save() end
			local bool_set_meh2 = setting.price[2].meh[2]
			setting.price[2].meh[2] = gui.InputText({304, 418}, 99, setting.price[2].meh[2], u8'Цена механик 2', 20, u8'Цена', 'num')
			if setting.price[2].meh[2] ~= bool_set_meh2 then save() end
			local bool_set_meh3 = setting.price[2].meh[3]
			setting.price[2].meh[3] = gui.InputText({468, 418}, 99, setting.price[2].meh[3], u8'Цена механик 3', 20, u8'Цена', 'num')
			if setting.price[2].meh[3] ~= bool_set_meh3 then save() end
			
			imgui.Dummy(imgui.ImVec2(0, 24))
		else
			gui.Text(152, 159, 'Недоступно для Вас', bold_font[3])
		end
	elseif tab_settings == 4 then
		local size_y_fast = 37
		if setting.fast.func then size_y_fast = 79 end
		new_draw(16, size_y_fast)
		
		gui.Text(26, 26, 'Быстрое взаимодействие с игроками', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 21))
		if gui.Switch(u8'##Быстрый доступ', setting.fast.func) then
			setting.fast.func = not setting.fast.func
			if setting.first_start_fast then
				if #cmd[1] ~= 0 then
					for i = 1, #cmd[1] do
						if #setting.fast.one_win < 16 then
							table.insert(setting.fast.one_win, {name = cmd[1][i].desc, cmd = cmd[1][i].cmd, send = true, id = true})
						else
							table.insert(setting.fast.two_win, {name = cmd[1][i].desc, cmd = cmd[1][i].cmd, send = true, id = true})
						end
					end
				end
				setting.first_start_fast = false
			end
			save()
		end
		
		if setting.fast.func then
			gui.DrawLine({16, 53}, {602, 53}, cl.line)
			gui.Text(26, 66, 'Текущая активация -', font[3])
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.85, 0.38, 1.00))
			gui.Text(165, 66, u8:decode(setting.fast.key_name), font[3])
			imgui.PopStyleColor(1)
			if gui.Button(u8'Изменить клавишу активации', {373, 62}, {218, 25}) then
				current_key[2] = {2}
				current_key[1] = u8'ПКМ'
				imgui.OpenPopup(u8'Изменить клавишу активации быстрого доступа')
				lockPlayerControl(true)
				edit_key = true
				fast_key = setting.fast.key
			end
			
			if imgui.BeginPopupModal(u8'Изменить клавишу активации быстрого доступа', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окно КАБД', imgui.ImVec2(16, 16)) then
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(16, 16))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 40))
				imgui.BeginChild(u8'Назначение клавиши активации КАБД', imgui.ImVec2(390, 181), false, imgui.WindowFlags.NoScrollbar)
				
				imgui.PushFont(font[3])
				imgui.SetCursorPos(imgui.ImVec2(10, 0))
				imgui.Text(u8'Нажмите на необходимую клавишу или комбинацию')
				imgui.SetCursorPos(imgui.ImVec2(10, 25))
				imgui.Text(u8'Текущее сочетание:')
				imgui.SetCursorPos(imgui.ImVec2(145, 25))
				if #fast_key == 0 then
					imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
				else
					local all_key = {}
					for i = 1, #fast_key do
						table.insert(all_key, vkeys.id_to_name(fast_key[i]))
					end
					imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_key, ' + '))
				end
				imgui.PopFont()
				gui.DrawLine({0, 50}, {381, 50}, cl.line)
				
				if imgui.IsMouseClicked(0) then
					lua_thread.create(function()
						wait(500)
						setVirtualKeyDown(3, true)
						wait(0)
						setVirtualKeyDown(3, false)
					end)
				end
				local currently_pressed_keys = rkeys.getKeys(true)
				local pr_key_num = {2}
				local pr_key_name = {u8'ПКМ'}
				if #currently_pressed_keys ~= 0 then
					local stop_hot = false
					for i = 1, #currently_pressed_keys do
						local parts = {}
						for part in currently_pressed_keys[i]:gmatch('[^:]+') do
							table.insert(parts, part)
						end
						if currently_pressed_keys[i] ~= u8'1:ЛКМ' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
						and currently_pressed_keys[i] ~= u8'2:ПКМ' then
							table.insert(pr_key_num, tonumber(parts[1]))
							table.insert(pr_key_name, parts[2])
						else
							stop_hot = true
						end
					end
					if not stop_key_move and not stop_hot then
						if current_key == {u8'ПКМ', {2}} then end
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
					current_key[1] = u8''
				end
				if current_key[1] ~= u8'Такая комбинация уже существует' then
					imgui.PushFont(bold_font[3])
					local calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 80))
					if calc.x >= 385 then
						imgui.PopFont()
						imgui.PushFont(font[3])
						calc = imgui.CalcTextSize(current_key[1])
						imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
					end
					imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
					imgui.PopFont()
				else
					imgui.PushFont(font[3])
					local calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
					imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
					imgui.PopFont()
				end
					
					
				if gui.Button(u8'Применить', {0, 144}, {185, 29}) then
					if not compare_array_disable_order(setting.fast.key, current_key[2]) then
						local is_hot_key_done = false
						local num_hot_key_remove = 0
						
						if #all_keys ~= 0 and #current_key[2] ~= 0 then
							for i = 1, #all_keys do
								is_hot_key_done = compare_array_disable_order(all_keys[i], current_key[2])
								if is_hot_key_done then break end
							end
							for i = 1, #all_keys do
								if compare_array_disable_order(all_keys[i], setting.fast.key) then
									num_hot_key_remove = i
									break
								end
							end
						end
						if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
						if not is_hot_key_done then
							if num_hot_key_remove ~= 0 then
								table.remove(all_keys, num_hot_key_remove)
								rkeys.unRegisterHotKey(setting.fast.key)
							end
							setting.fast.key = current_key[2]
							setting.fast.key_name = current_key[1]
							table.insert(all_keys, current_key[2])
							rkeys.registerHotKey(current_key[2], 3, true, function() on_hot_key(setting.fast.key) end)
							lockPlayerControl(false)
							edit_key = false
							imgui.CloseCurrentPopup()
							save()
						end
					else
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
					end
				end
				if gui.Button(u8'Очистить', {194, 144}, {186, 29}) then
					current_key = {u8'ПКМ', {2}}
				end
					
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			if not bool_edit_fast then
				if an[5][1] == 0 then
					num_win_fast = gui.ListTableHorizontal({189, 115}, {u8'Первое окно', u8'Второе окно'}, num_win_fast, u8'Выбор номера окна в заимодействии')
				else
					gui.ListTableHorizontal({189, 115}, {u8'Первое окно', u8'Второе окно'}, num_win_fast, u8'Выбор номера окна в заимодействии')
				end
			else
				gui.Text(219, 116, 'Режим редактирования', bold_font[1])
			end
			
			local function fast_table_func(set_fast)
				local set_pil = 'one_win'
				if set_fast == 3 then
					set_pil = 'two_win'
				end
				if an[5][1] < 0 and an[5][1] >= -40 then
					gui.DrawBox({235, 337 + an[5][1] + (#setting.fast[set_pil] * 111)}, {148, 29}, cl.tab, cl.line, 7, 15)
				elseif an[5][1] < -40 then
					if an[5][1] > -165.4 then
						local s_x = 48 + (-an[5][1] * 3.25)
						local s_y = 9 - (an[5][1] / 1.9)
						local p_x = 309 - (s_x / 2)
						local p_y = 337 + (an[5][1] * 1.08) + (#setting.fast[set_pil] * 111)
						
						gui.DrawBox({p_x, p_y}, {s_x, s_y}, cl.tab, cl.line, 7, 15)
					end
				end
				
				if #setting.fast[set_pil] ~= 0 then
					local bool_num_el = 0
					for i = 1, #setting.fast[set_pil] do
						if i == #setting.fast[set_pil] then
							if setting.cl == 'White' then
								imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.10, 0.10, 0.10, an[5][3]))
							else
								imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, an[5][3]))
							end
						end
						
						local scroll_cursor_pos = gui.GetCursorScroll()
						local pos_y_f = ((i - 1) * 111)
						if bool_edit_fast then
							local tab_element_bool = false
							imgui.SetCursorPos(imgui.ImVec2(31, 158 + pos_y_f))
							if imgui.InvisibleButton(u8'##Переместить элемент ' .. set_fast .. i, imgui.ImVec2(571, 97)) then
								
							end
							if imgui.IsItemClicked() then
								sc_cursor_pos = scroll_cursor_pos
								sc_cr_p_element[1] = 0
								sc_cr_p_element[2] = i
								sc_cr_p_element[3] = i
								sc_cr_p_element[4] = i
								sc_cr_p_element[5] = pos_y_f
								
							end
							if imgui.IsItemActive() then
								tab_element_bool = true
								bool_item_active = true
								sc_cr_pos = {x = sc_cursor_pos.x - scroll_cursor_pos.x, y = sc_cursor_pos.y - scroll_cursor_pos.y}
								pos_y_f = pos_y_f - sc_cr_pos.y
								
								local pos_scroll = imgui.GetScrollY()
								if scroll_cursor_pos.y < (50 + pos_scroll) then
									imgui.SetScrollY(pos_scroll - ((100 * anim) + (-(scroll_cursor_pos.y - pos_scroll) / 30)))
								elseif scroll_cursor_pos.y > (285 + pos_scroll) then
									imgui.SetScrollY(pos_scroll + ((100 * anim) + ((scroll_cursor_pos.y - pos_scroll - 285) / 30)))
								end
								
								sc_cr_p_element[1] = pos_y_f
							elseif bool_item_active and sc_cr_p_element[2] == i then
								bool_item_active = false
								swapping(setting.fast[set_pil], i, sdv_bool_fast)
								save()
							elseif not imgui.IsItemActive() and sc_cr_p_element[2] == i then
								sc_cr_p_element[1] = 0
								sc_cr_p_element[2] = 0
								sc_cr_p_element[3] = 0
								sc_cr_p_element[4] = 0
								sc_cr_p_element[5] = 0
							else
								sc_cr_pos = {x = 0, y = 0}
							end
							
							if sc_cr_p_element[1] ~= 0 then
								local razn = sc_cr_p_element[1] - sc_cr_p_element[5]
								if sc_cr_p_element[1] ~= 0 and not tab_element_bool then
									if sc_cr_p_element[2] < i then
										if sc_cr_p_element[1] > (pos_y_f - 20) then
											bool_num_el = bool_num_el + 1
											sc_cr_p_element[3] = i
											if i == sc_cr_p_element[3] + 1 and sc_cr_p_element[1] < (pos_y_f + 222 - 20) then
												sc_cr_p_element[3] = i
												an[5][5] = 0
											end
											if i == sc_cr_p_element[3] then
												pos_y_f = pos_y_f - an[5][5]
												
											else
												pos_y_f = pos_y_f - 111
											end
											if an[5][5] < 111 then
												an[5][5] = an[5][5] + (500 * anim)
											else
												an[5][5] = 111
											end
										end
									elseif sc_cr_p_element[2] > i then
										if sc_cr_p_element[1] < (pos_y_f + 20) then
											bool_num_el = bool_num_el - 1
											if i == sc_cr_p_element[3] - 1 then
												sc_cr_p_element[3] = i
												an[5][5] = 0
											end
											if i == sc_cr_p_element[3] then
												pos_y_f = pos_y_f + an[5][5]
											else
												pos_y_f = pos_y_f + 111
											end
											if an[5][5] < 111 then
												an[5][5] = an[5][5] + (500 * anim)
											else
												an[5][5] = 111
											end
										end
									end
								end
							end
						end
						
						local vis_anim_input = 180
						if i <= 9 then
							gui.Text(5, 160 + pos_y_f, tostring(i), font[2])
						else
							gui.Text(2, 160 + pos_y_f, tostring(i), font[2])
						end
						if i == #setting.fast[set_pil] then vis_anim_input = an[5][4] end
						
						gui.DrawBox({16, 158 + pos_y_f}, {586, 97}, cl.tab, cl.line, 7, 15)
						gui.Text(26, 171 + pos_y_f, 'Имя', font[3])
						
						if bool_edit_fast then
							imgui.SetCursorPos(imgui.ImVec2(8, 150 + pos_y_f))
							if imgui.InvisibleButton(u8'##Удалить действие ' .. set_fast .. i, imgui.ImVec2(22, 22)) then
								table.remove(setting.fast[set_pil], i)
								break
							end
							imgui.PushFont(fa_font[4])
							imgui.SetCursorPos(imgui.ImVec2(10, 152 + pos_y_f))
							if imgui.IsItemActive() then
								imgui.TextColored(cl.def, fa.CIRCLE_XMARK)
							else
								imgui.Text(fa.CIRCLE_XMARK)
							end
							imgui.PopFont()
						end
						
						local bool_setfast = setting.fast[set_pil][i].name
						setting.fast[set_pil][i].name = gui.InputText({68, 173 + pos_y_f}, vis_anim_input, setting.fast[set_pil][i].name, u8'Имя действия' .. i, 300, u8'Введите имя действия')
						if bool_setfast ~= setting.fast[set_pil][i].name then save() end
						gui.Text(328, 171 + pos_y_f, 'Команда', font[3])
						local bool_setfast2 = setting.fast[set_pil][i].cmd
						setting.fast[set_pil][i].cmd = gui.InputText({401, 173 + pos_y_f}, vis_anim_input, setting.fast[set_pil][i].cmd, u8'Команда действия' .. i, 25, u8'Введите команду действия', 'en')
						if bool_setfast2 ~= setting.fast[set_pil][i].cmd then save() end
						gui.DrawLine({16, 201 + pos_y_f}, {602, 201 + pos_y_f}, cl.line)
						gui.Text(26, 206 + pos_y_f, 'Передавать в первый аргумент id игрока', font[3])
						imgui.SetCursorPos(imgui.ImVec2(561, 201 + pos_y_f))
						if gui.Switch(u8'##Передавать аргумент id игрока' .. set_fast.. i, setting.fast[set_pil][i].id) then
							setting.fast[set_pil][i].id = not setting.fast[set_pil][i].id
							save()
						end
						gui.DrawLine({16, 227 + pos_y_f}, {602, 227 + pos_y_f}, cl.line)
						gui.Text(26, 233 + pos_y_f, 'Отправлять команду без подтверждения', font[3])
						imgui.SetCursorPos(imgui.ImVec2(561, 228 + pos_y_f))
						if gui.Switch(u8'##Отправлять команду без подтверждения' .. set_fast ..i, setting.fast[set_pil][i].send) then
							setting.fast[set_pil][i].send = not setting.fast[set_pil][i].send
							save()
						end
						
						if i == #setting.fast[set_pil] then
							imgui.PopStyleColor(1)
							local cl_bool = imgui.ImVec4(0.13, 0.13, 0.13, an[5][4])
							if setting.cl == 'White' then
								local cl_bool = imgui.ImVec4(0.91, 0.89, 0.76, an[5][4])
							end
						end
					end
					sdv_bool_fast = bool_num_el
				else
					if an[5][1] == 0 then
						gui.Text(124, 218, 'Нет ни одного действия', bold_font[3])
					end
				end
				
				imgui.Dummy(imgui.ImVec2(0, 19))
				if (an[5][1] < 0 and an[5][1] > -165.2) or (an[5][1] <= -165.2 and an[5][1] > -165.3) then
					imgui.Dummy(imgui.ImVec2(0, 106))
					imgui.SetScrollY(imgui.GetScrollMaxY())
				end
			end
			
			if num_win_fast == 1 then
				fast_table_func(2)
			else
				fast_table_func(3)
			end
		end
	elseif tab_settings == 5 then
		new_draw(16, 37)
		
		gui.Text(26, 26, 'Мемберс организации на Вашем экране', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 21))
		if gui.Switch(u8'##Мембрес', setting.mb.func) then
			setting.mb.func = not setting.mb.func
			save()
		end
		
		if setting.mb.func then
			gui.Text(25, 72, 'Содержимое', bold_font[1])
			new_draw(97, 215)
			
			gui.Text(26, 106, 'Отображать id игроков', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 101))
			if gui.Switch(u8'##Отображать id игроков', setting.mb.id) then
				setting.mb.id = not setting.mb.id
				save()
			end
			gui.DrawLine({16, 132}, {602, 132}, cl.line)
			gui.Text(26, 142, 'Отображать ранг игроков', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 137))
			if gui.Switch(u8'##Отображать ранг игроков', setting.mb.rank) then
				setting.mb.rank = not setting.mb.rank
				save()
			end
			gui.DrawLine({16, 168}, {602, 168}, cl.line)
			gui.Text(26, 178, 'Отображать время АФК', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 173))
			if gui.Switch(u8'##Отображать время АФК', setting.mb.afk) then
				setting.mb.afk = not setting.mb.afk
				save()
			end
			gui.DrawLine({16, 204}, {602, 204}, cl.line)
			gui.Text(26, 214, 'Отображать количество выговоров', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 209))
			if gui.Switch(u8'##Отображать количество выговоров', setting.mb.warn) then
				setting.mb.warn = not setting.mb.warn
				save()
			end
			gui.DrawLine({16, 240}, {602, 240}, cl.line)
			gui.Text(26, 250, 'Отображать теги организации в никнеймах', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 245))
			if gui.Switch(u8'##Отображать теги в никнеймах', setting.mb_tags) then
				setting.mb_tags = not setting.mb_tags
				save()
			end
			gui.DrawLine({16, 276}, {602, 276}, cl.line)
			gui.Text(26, 286, 'Выделять цветом тех, кто в форме', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 281))
			if gui.Switch(u8'##Выделять цветом тех, кто в форме', setting.mb.form) then
				setting.mb.form = not setting.mb.form
				save()
			end
			
			gui.Text(25, 331, 'Визуальное отображение', bold_font[1])
			new_draw(356, 330)
			
			gui.Text(26, 365, 'Скрывать при открытом диалоге', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 360))
			if gui.Switch(u8'##Скрывать при открытом диалоге', setting.mb.dialog) then
				setting.mb.dialog = not setting.mb.dialog
				save()
			end
			gui.DrawLine({16, 391}, {602, 391}, cl.line)
			gui.Text(26, 401, 'Инверсировать текст', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 396))
			if gui.Switch(u8'##Инверсировать текст', setting.mb.invers) then
				setting.mb.invers = not setting.mb.invers
				save()
			end
			gui.DrawLine({16, 427}, {602, 427}, cl.line)
			gui.Text(26, 437, 'Флаг шрифта', font[3])
			local bool_set_flag = setting.mb.flag
			setting.mb.flag = gui.ListTableMove({572, 437}, {u8'Без обводки', u8'Без обводки наклонённый', u8'Без обводки жирный наклонённый', u8'С обводкой', u8'С обводкой жирный', u8'С обводкой наклонённый', u8'С обводкой жирный наклонённый', u8'Без обводки с тенью', u8'Без обводки жирный с тенью', u8'Без обводки с тенью наклонённый', u8'Без обводки с тенью жирный наклонённый', u8'С обводкой и тенью', u8'С обводкой и тенью жирный'}, setting.mb.flag, 'Select Size')
			if setting.mb.flag ~= bool_set_flag then
				fontes = renderCreateFont('Trebuchet MS', setting.mb.size, setting.mb.flag)
				save() 
			end
			gui.DrawLine({16, 463}, {602, 463}, cl.line)
			
			local mb_set = {
				vis = imgui.new.float(setting.mb.vis),
				size = imgui.new.float(setting.mb.size),
				dist = imgui.new.float(setting.mb.dist)
			}
			
			gui.SliderCircle('SliderVisibleMb',{54, 486}, 70, 257, imgui.GetColorU32Vec4(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 12, 50, 100, mb_set.vis[0])
			gui.SliderCircle('SliderVisibleMb2',{239, 486}, 70, 257, imgui.GetColorU32Vec4(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 12, 50, 50, mb_set.size[0])
			gui.SliderCircle('SliderVisibleMb3',{424, 486}, 70, 257, imgui.GetColorU32Vec4(imgui.ImVec4(0.90, 0.90, 0.90, 1.00)), 12, 50, 50, mb_set.dist[0])
			
			
			gui.Text(78, 621, 'Прозрачность', font[3])
			local bool_set_vis = mb_set.vis[0]
			mb_set.vis[0] = gui.SliderBar('##Прозрачность текста', mb_set.vis, 0, 100, 152, {51, 646})
			if mb_set.vis[0] ~= bool_set_vis then
				setting.mb.vis = floor(mb_set.vis[0])
				save()
			end
			gui.Text(286, 621, 'Размер', font[3])
			local bool_set_size = mb_set.size[0]
			mb_set.size[0] = gui.SliderBar('##Размер текста',mb_set.size, 1, 50, 152, {236, 646})
			if mb_set.size[0] ~= bool_set_size then
				setting.mb.size = floor(mb_set.size[0])
				fontes = renderCreateFont('Trebuchet MS', mb_set.size[0], setting.mb.flag)
				save()
			end
			gui.Text(400, 621, 'Расстояние между строками', font[3])
			local bool_set_dist = mb_set.dist[0]
			mb_set.dist[0] = gui.SliderBar('##Расстояние между строками текста', mb_set.dist, 0, 50, 152, {421, 646})
			if mb_set.dist[0] ~= bool_set_dist then
				setting.mb.dist = floor(mb_set.dist[0])
				save()
			end
			setting.mb.vis = mb_set.vis[0]
			setting.mb.size = mb_set.size[0]
			setting.mb.dist = mb_set.dist[0]
			
			gui.Text(25, 705, 'Цветовой стиль текста', bold_font[1])
			new_draw(730, 107)
			gui.Text(26, 739, 'Заголовок', font[3])
			gui.DrawLine({16, 765}, {602, 765}, cl.line)
			gui.Text(26, 775, 'Сотрудники в форме', font[3])
			gui.DrawLine({16, 801}, {602, 801}, cl.line)
			gui.Text(26, 811, 'Сотрудники без формы', font[3])
			imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(6.5, 6.5))
			imgui.SetCursorPos(imgui.ImVec2(564, 734))
			if imgui.ColorEdit4('##TitleColor', col_mb.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col_mb.title[0], col_mb.title[1], col_mb.title[2], col_mb.title[3])
				local argb = imgui.ColorConvertFloat4ToARGB(c)
				setting.mb.color.title = imgui.ColorConvertFloat4ToARGB(c)
				save()
			end
			imgui.SetCursorPos(imgui.ImVec2(564, 770))
			if imgui.ColorEdit4('##WorkColor', col_mb.work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col_mb.work[0], col_mb.work[1], col_mb.work[2], col_mb.work[3])
				local argb = imgui.ColorConvertFloat4ToARGB(c)
				setting.mb.color.work = imgui.ColorConvertFloat4ToARGB(c)
				save()
			end
			imgui.SetCursorPos(imgui.ImVec2(564, 806))
			if imgui.ColorEdit4('##DefColor', col_mb.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col_mb.default[0], col_mb.default[1], col_mb.default[2], col_mb.default[3])
				local argb = imgui.ColorConvertFloat4ToARGB(c)
				setting.mb.color.default = imgui.ColorConvertFloat4ToARGB(c)
				save()
			end
			imgui.PopStyleVar()
			
			new_draw(856, 70)
			--gui.DrawLine({16, 891}, {602, 891}, cl.line)
			gui.Text(26, 865, 'Отображать только сотрудников со следующими рангами:', font[3])
			for num_rank = 1, 10 do
				imgui.PushFont(bold_font[1])
				local calc_text = imgui.CalcTextSize(tostring(num_rank))
				imgui.PopFont()
				if setting.rank_members[num_rank] then
					gui.Draw({49 + ((num_rank - 1) * 55), 895}, {25, 25}, cl.def, 5, 15)
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1.00))
				else
					gui.Draw({49 + ((num_rank - 1) * 55), 895}, {25, 25}, cl.bg, 5, 15)
				end
				
				gui.Text((62 + ((num_rank - 1) * 55)) - (calc_text.x / 2), 899, num_rank, bold_font[1])
				
				if setting.rank_members[num_rank] then
					imgui.PopStyleColor(1)
				end
				imgui.SetCursorPos(imgui.ImVec2(49 + ((num_rank - 1) * 55), 895))
				if imgui.InvisibleButton(u8'##Переключить отображение ранга ' .. num_rank, imgui.ImVec2(25, 25)) then
					setting.rank_members[num_rank] = not setting.rank_members[num_rank]
				end
			end
			
			new_draw(945, 35)
			gui.Text(26, 954, 'Положение текста на экране', font[3])
			if gui.Button(u8'Изменить...', {491, 950}, {99, 25}) then
				changePosition()
			end
			
			imgui.Dummy(imgui.ImVec2(0, 21))
		end
	elseif tab_settings == 6 then
		if setting.org <= 4 then
			new_draw(16, 53)
			
			gui.Text(26, 26, 'Упростить систему вызовов /godeath', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 21))
			if gui.Switch(u8'##Упростить godeath', setting.godeath.func) then
				setting.godeath.func = not setting.godeath.func
				if setting.godeath.func and setting.godeath.cmd_go then
						sampRegisterChatCommand('go', function()
							go_medic_or_fire()
						end)
				elseif not setting.godeath.func and setting.godeath.cmd_go then
					sampUnregisterChatCommand('go')
				end
				save()
			end
			gui.TextInfo({26, 45}, {'Вам станет удобнее работать с вызовами игроков через /godeath'})
			
			if setting.godeath.func then
				local function accent_col(num_acc, color_acc, color_acc_act)
					imgui.SetCursorPos(imgui.ImVec2(407 + (num_acc * 43), 371))
					local p = imgui.GetCursorScreenPos()
					
					imgui.SetCursorPos(imgui.ImVec2(396 + (num_acc * 43), 360))
					if imgui.InvisibleButton(u8'##Выбор цвета' .. num_acc, imgui.ImVec2(22, 22)) then
						setting.color_godeath = color_acc
						setting.godeath.color = num_acc
						save()
					end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5),  12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
					end
					if num_acc == setting.godeath.color then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 4, imgui.GetColorU32Vec4(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
					end
				end
				
				gui.Text(25, 88, 'Взаимодействие', bold_font[1])
				new_draw(113, 107)
				
				gui.Text(26, 122, 'Принимать последний вызов командой /go', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 118))
				if gui.Switch(u8'##Принимать последний вызов командой /go', setting.godeath.cmd_go) then
					setting.godeath.cmd_go = not setting.godeath.cmd_go
					if setting.godeath.cmd_go then
						sampRegisterChatCommand('go', function()
							go_medic_or_fire()
						end)
					else
						sampUnregisterChatCommand('go')
					end
					save()
				end
				gui.DrawLine({16, 148}, {602, 148}, cl.line)
				gui.Text(26, 158, 'Автоматически докладывать в рацию /r о принятии вызова', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 154))
				if gui.Switch(u8'##Автоматически докладывать', setting.godeath.auto_send) then
					setting.godeath.auto_send = not setting.godeath.auto_send
					save()
				end
				gui.DrawLine({16, 184}, {602, 184}, cl.line)
				gui.Text(26, 194, 'Воспроизводить звуковой сигнал при поступлении вызова', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 189))
				if gui.Switch(u8'##Воспроизводить звуковой сигнал при поступлении вызова', setting.godeath.sound) then
					setting.godeath.sound = not setting.godeath.sound
					save()
				end
				
				gui.Text(25, 239, 'Отображение', bold_font[1])
				new_draw(264, 71)
				
				gui.Text(26, 273, 'Отображать расстояние от Вас до пациента', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 268))
				if gui.Switch(u8'##Отображать расстояние', setting.godeath.meter) then
					setting.godeath.meter = not setting.godeath.meter
					save()
				end
				gui.DrawLine({16, 299}, {602, 299}, cl.line)
				gui.Text(26, 309, 'Заменять два сообщения о вызове одним', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 304))
				if gui.Switch(u8'##Заменять два сообщения', setting.godeath.two_text) then
					setting.godeath.two_text = not setting.godeath.two_text
					save()
				end
				
				new_draw(354, 35)
				
				gui.Text(26, 363, 'Цвет текста вызова', font[3])
				accent_col(0, {1.00, 0.33, 0.31}, {1.00, 0.23, 0.31})
				accent_col(1, {0.75, 0.35, 0.87}, {0.75, 0.25, 0.87})
				accent_col(2, {0.26, 0.45, 0.94}, {0.26, 0.35, 0.94})
				accent_col(3, {0.20, 0.74, 0.29}, {0.20, 0.64, 0.29})
				accent_col(4, {0.50, 0.50, 0.52}, {0.40, 0.40, 0.42})
				
				imgui.Dummy(imgui.ImVec2(0, 18))
			end
		else
			new_draw(16, 53)
			
			gui.Text(26, 26, 'Упростить систему выездов на пожары', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 21))
			if gui.Switch(u8'##Упростить вызовы на пожары', setting.godeath.func) then
				setting.godeath.func = not setting.godeath.func
				if setting.godeath.func and setting.godeath.cmd_go then
						sampRegisterChatCommand('go', function()
							go_medic_or_fire()
						end)
				elseif not setting.godeath.func and setting.godeath.cmd_go then
					sampUnregisterChatCommand('go')
				end
				save()
			end
			gui.TextInfo({26, 45}, {'Вам станет удобнее принимать вызовы /fire'})
			
			if setting.godeath.func then
				gui.Text(25, 88, 'Взаимодействие с вызовами', bold_font[1])
				new_draw(113, 179 + an[27])
				
				gui.Text(26, 122, 'Принимать последний вызов командой /go', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 118))
				if gui.Switch(u8'##Принимать последний вызов командой /go', setting.godeath.cmd_go) then
					setting.godeath.cmd_go = not setting.godeath.cmd_go
					if setting.godeath.cmd_go then
						sampRegisterChatCommand('go', function()
							go_medic_or_fire()
						end)
					else
						sampUnregisterChatCommand('go')
					end
					save()
				end
				gui.DrawLine({16, 148}, {602, 148}, cl.line)
				gui.Text(26, 158, 'Автоматически докладывать в рацию /r о принятии вызова', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 154))
				if gui.Switch(u8'##Автоматически докладывать', setting.fire.auto_send) then
					setting.fire.auto_send = not setting.fire.auto_send
					if setting.fire.auto_send then
						ANIMATE[1] = animate(an[27], an[27], 42, 42, an[27], an[27], 1, 4)
					else
						ANIMATE[2] = animate(an[27], an[27], 0, 0, an[27], an[27], 1, 4)
					end
					save()
				end
				
				if setting.fire.auto_send then
					an[27] = ANIMATE[1]()
				else
					an[27] = ANIMATE[2]()
				end
				
				if an[27] > 0 then
					local bool_set_time = setting.text_fires
					setting.text_fires = gui.InputText({33, 194}, 548, setting.text_fires, u8'Доклад r', 230, u8'Введите текст отыгровки')
					if setting.text_fires ~= bool_set_time then
						save()
					end
					gui.Draw({16, 185 + an[27]}, {586, 30}, cl.tab)
				end
				
				gui.DrawLine({16, 184 + an[27]}, {602, 184 + an[27]}, cl.line)
				gui.Text(26, 194 + an[27], 'Воспроизводить звуковой сигнал при поступлении вызова', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 189 + an[27]))
				if gui.Switch(u8'##Воспроизводить звуковой сигнал при поступлении вызова', setting.fire.sound) then
					setting.fire.sound = not setting.fire.sound
					save()
				end
				gui.DrawLine({16, 220 + an[27]}, {602, 220 + an[27]}, cl.line)
				gui.Text(26, 230 + an[27], 'Автоматически открывать /fires после поступления вызова', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 225 + an[27]))
				if gui.Switch(u8'##Автоматически открывать /fires после поступления вызова', setting.fire.auto_cmd_fires) then
					setting.fire.auto_cmd_fires = not setting.fire.auto_cmd_fires
					save()
				end
				gui.DrawLine({16, 256 + an[27]}, {602, 256 + an[27]}, cl.line)
				gui.Text(26, 266 + an[27], 'Автоматически выбирать новейший пожар после открытия окна /fires', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 261 + an[27]))
				if gui.Switch(u8'##Автоматически выбирать новейший пожар после открытия окна /fires', setting.fire.auto_select_fires) then
					setting.fire.auto_select_fires = not setting.fire.auto_select_fires
					save()
				end
				
				gui.Text(25, 311 + an[27], 'Доклады в рабочую рацию', bold_font[1])
				
				local pos_report_plus = 0
				new_draw(336 + an[27], 107)
				gui.DrawLine({16, 371 + an[27]}, {602, 371 + an[27]}, cl.line)
				gui.DrawLine({16, 407 + an[27]}, {602, 407 + an[27]}, cl.line)
				gui.Text(26, 345 + an[27], 'Прибытие на место пожара', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 340 + an[27]))
				if gui.Switch(u8'##Прибытие на место пожара', setting.report_fire.arrival.func) then
					setting.report_fire.arrival.func = not setting.report_fire.arrival.func
					save()
				end
				if setting.report_fire.arrival.func then
					gui.Text(26, 381 + an[27], 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27]))
					if gui.Switch(u8'##Спрашивать подтверждение перед отправкой', setting.report_fire.arrival.ask) then
						setting.report_fire.arrival.ask = not setting.report_fire.arrival.ask
						save()
					end
					gui.Text(26, 417 + an[27], 'Текст доклада', font[3])
					local bool_set_time = setting.report_fire.arrival.text
					setting.report_fire.arrival.text = gui.InputText({135, 419 + an[27]}, 446, setting.report_fire.arrival.text, u8'Доклад прибытия на пожар', 230, u8'Введите текст отыгровки')
					if setting.report_fire.arrival.text ~= bool_set_time then
						save()
					end
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					gui.Text(26, 381 + an[27], 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27]))
					gui.SwitchFalse(setting.report_fire.arrival.ask)
					gui.Text(26, 417 + an[27], 'Текст доклада', font[3])
					gui.InputFalse(setting.report_fire.arrival.text, 135, 419 + an[27], 446)
					imgui.PopStyleColor(1)
				end
				
				pos_report_plus = pos_report_plus + 121
				new_draw(336 + an[27] + pos_report_plus, 107)
				gui.DrawLine({16, 371 + an[27] + pos_report_plus}, {602, 371 + an[27] + pos_report_plus}, cl.line)
				gui.DrawLine({16, 407 + an[27] + pos_report_plus}, {602, 407 + an[27] + pos_report_plus}, cl.line)
				gui.Text(26, 345 + an[27] + pos_report_plus, 'Ликвидация очагов возгарания', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 340 + an[27] + pos_report_plus))
				if gui.Switch(u8'##Ликвидация очагов возгарания', setting.report_fire.foci.func) then
					setting.report_fire.foci.func = not setting.report_fire.foci.func
					save()
				end
				if setting.report_fire.foci.func then
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					if gui.Switch(u8'##Спрашивать подтверждение перед отправкой 2', setting.report_fire.foci.ask) then
						setting.report_fire.foci.ask = not setting.report_fire.foci.ask
						save()
					end
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					local bool_set_time = setting.report_fire.foci.text
					setting.report_fire.foci.text = gui.InputText({135, 419 + an[27] + pos_report_plus}, 446, setting.report_fire.foci.text, u8'Ликвидация пожара', 230, u8'Введите текст отыгровки')
					if setting.report_fire.foci.text ~= bool_set_time then
						save()
					end
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					gui.SwitchFalse(setting.report_fire.foci.ask)
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					gui.InputFalse(setting.report_fire.foci.text, 135, 419 + an[27] + pos_report_plus, 446)
					imgui.PopStyleColor(1)
				end
				
				pos_report_plus = pos_report_plus + 121
				new_draw(336 + an[27] + pos_report_plus, 107)
				gui.DrawLine({16, 371 + an[27] + pos_report_plus}, {602, 371 + an[27] + pos_report_plus}, cl.line)
				gui.DrawLine({16, 407 + an[27] + pos_report_plus}, {602, 407 + an[27] + pos_report_plus}, cl.line)
				gui.Text(26, 345 + an[27] + pos_report_plus, 'Погрузка пострадавшего на носилки', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 340 + an[27] + pos_report_plus))
				if gui.Switch(u8'##Погрузка пострадавшего на носилки', setting.report_fire.stretcher.func) then
					setting.report_fire.stretcher.func = not setting.report_fire.stretcher.func
					save()
				end
				if setting.report_fire.stretcher.func then
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					if gui.Switch(u8'##Спрашивать подтверждение перед отправкой 3', setting.report_fire.stretcher.ask) then
						setting.report_fire.stretcher.ask = not setting.report_fire.stretcher.ask
						save()
					end
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					local bool_set_time = setting.report_fire.stretcher.text
					setting.report_fire.stretcher.text = gui.InputText({135, 419 + an[27] + pos_report_plus}, 446, setting.report_fire.stretcher.text, u8'Пстрадавший на носилки', 230, u8'Введите текст отыгровки')
					if setting.report_fire.stretcher.text ~= bool_set_time then
						save()
					end
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					gui.SwitchFalse(setting.report_fire.stretcher.ask)
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					gui.InputFalse(setting.report_fire.stretcher.text, 135, 419 + an[27] + pos_report_plus, 446)
					imgui.PopStyleColor(1)
				end
				
				pos_report_plus = pos_report_plus + 121
				new_draw(336 + an[27] + pos_report_plus, 107)
				gui.DrawLine({16, 371 + an[27] + pos_report_plus}, {602, 371 + an[27] + pos_report_plus}, cl.line)
				gui.DrawLine({16, 407 + an[27] + pos_report_plus}, {602, 407 + an[27] + pos_report_plus}, cl.line)
				gui.Text(26, 345 + an[27] + pos_report_plus, 'Спасение пострадавшего', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 340 + an[27] + pos_report_plus))
				if gui.Switch(u8'##Спасение пострадавшего', setting.report_fire.salvation.func) then
					setting.report_fire.salvation.func = not setting.report_fire.salvation.func
					save()
				end
				if setting.report_fire.salvation.func then
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					if gui.Switch(u8'##Спрашивать подтверждение перед отправкой 4', setting.report_fire.salvation.ask) then
						setting.report_fire.salvation.ask = not setting.report_fire.salvation.ask
						save()
					end
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					local bool_set_time = setting.report_fire.salvation.text
					setting.report_fire.salvation.text = gui.InputText({135, 419 + an[27] + pos_report_plus}, 446, setting.report_fire.salvation.text, u8'Спасение пострадавшего', 230, u8'Введите текст отыгровки')
					if setting.report_fire.salvation.text ~= bool_set_time then
						save()
					end
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					gui.SwitchFalse(setting.report_fire.salvation.ask)
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					gui.InputFalse(setting.report_fire.salvation.text, 135, 419 + an[27] + pos_report_plus, 446)
					imgui.PopStyleColor(1)
				end
				
				pos_report_plus = pos_report_plus + 121
				new_draw(336 + an[27] + pos_report_plus, 107)
				gui.DrawLine({16, 371 + an[27] + pos_report_plus}, {602, 371 + an[27] + pos_report_plus}, cl.line)
				gui.DrawLine({16, 407 + an[27] + pos_report_plus}, {602, 407 + an[27] + pos_report_plus}, cl.line)
				gui.Text(26, 345 + an[27] + pos_report_plus, 'Полное устранение пожара', font[3])
				imgui.SetCursorPos(imgui.ImVec2(561, 340 + an[27] + pos_report_plus))
				if gui.Switch(u8'##Полное устранение пожара', setting.report_fire.extinguishing.func) then
					setting.report_fire.extinguishing.func = not setting.report_fire.extinguishing.func
					save()
				end
				if setting.report_fire.extinguishing.func then
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					if gui.Switch(u8'##Спрашивать подтверждение перед отправкой 5', setting.report_fire.extinguishing.ask) then
						setting.report_fire.extinguishing.ask = not setting.report_fire.extinguishing.ask
						save()
					end
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					local bool_set_time = setting.report_fire.extinguishing.text
					setting.report_fire.extinguishing.text = gui.InputText({135, 419 + an[27] + pos_report_plus}, 446, setting.report_fire.extinguishing.text, u8'Устранение пожара', 230, u8'Введите текст отыгровки')
					if setting.report_fire.extinguishing.text ~= bool_set_time then
						save()
					end
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					gui.Text(26, 381 + an[27] + pos_report_plus, 'Спрашивать подтверждение перед отправкой', font[3])
					imgui.SetCursorPos(imgui.ImVec2(561, 376 + an[27] + pos_report_plus))
					gui.SwitchFalse(setting.report_fire.extinguishing.ask)
					gui.Text(26, 417 + an[27] + pos_report_plus, 'Текст доклада', font[3])
					gui.InputFalse(setting.report_fire.extinguishing.text, 135, 419 + an[27] + pos_report_plus, 446)
					imgui.PopStyleColor(1)
				end
				
				imgui.Dummy(imgui.ImVec2(0, 22))
				tags_in_call()
			end
		end
	elseif tab_settings == 7 then
		new_draw(16, 53)
		
		gui.Text(26, 26, 'Уведомлять звуковым сигналом о спавне авто', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 21))
		if gui.Switch(u8'##Уведомлять звуковым сигналом о спавне авто', setting.notice.car) then
			setting.notice.car = not setting.notice.car
			save()
		end
		gui.TextInfo({26, 45}, {'Когда администрация предупредит о спавне авто, Вы будете уведомлены звуковым сигналом.'})
		
		local size_y_dep = 53
		if setting.notice.dep then
			size_y_dep = 91
			if setting.dep.my_tag ~= '' then
				size_y_dep = 128
				if setting.dep.my_tag_en ~= '' then
					size_y_dep = 164
					if setting.dep.my_tag_en2 ~= '' then
						size_y_dep = 200
					end
				end
			end
		end
		new_draw(88, size_y_dep)
		gui.Text(26, 98, 'Уведомлять о вызове организации в рации департамента', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 93))
		if gui.Switch(u8'##Уведомлять о вызове организации', setting.notice.dep) then
			setting.notice.dep = not setting.notice.dep
			save()
		end
		gui.TextInfo({26, 117}, {'Когда в рации департамента обратятся к Вашей организации, Вы будете уведомлены звуком.'})
		
		if setting.notice.dep then
			gui.DrawLine({16, 143}, {602, 143}, cl.line)
			gui.Text(26, 153, 'Тег организации на который реагировать', font[3])
			
			local bool_save_input_tag1 = setting.dep.my_tag
			setting.dep.my_tag = gui.InputText({431, 155}, 150, setting.dep.my_tag, u8'Тег организации 1', 40, u8'Введите тег', 'ern')
			if setting.dep.my_tag ~= bool_save_input_tag1 then
				save()
			end
			
			if setting.dep.my_tag ~= '' then 
				gui.DrawLine({16, 179}, {602, 179}, cl.line)
				gui.Text(26, 189, 'Дополнительный тег (не обязательно)', font[3])
				local bool_save_input_tag2 = setting.dep.my_tag_en
				setting.dep.my_tag_en = gui.InputText({431, 191}, 150, setting.dep.my_tag_en, u8'Тег организации 2', 40, u8'Введите тег', 'ern')
				if setting.dep.my_tag_en ~= bool_save_input_tag2 then
					save()
				end
				
				if setting.dep.my_tag_en ~= '' then
					gui.DrawLine({16, 215}, {602, 215}, cl.line)
					gui.Text(26, 225, 'Второй дополнительный тег (не обязательно)', font[3])
					local bool_save_input_tag3 = setting.dep.my_tag_en2
					setting.dep.my_tag_en2 = gui.InputText({431, 227}, 150, setting.dep.my_tag_en2, u8'Тег организации 3', 40, u8'Введите тег', 'ern')
					if setting.dep.my_tag_en2 ~= bool_save_input_tag3 then
						save()
					end
					
					if setting.dep.my_tag_en2 ~= '' then
						gui.DrawLine({16, 251}, {602, 251}, cl.line)
						gui.Text(26, 261, 'Третий дополнительный тег (не обязательно)', font[3])
						local bool_save_input_tag4 = setting.dep.my_tag_en3
						setting.dep.my_tag_en3 = gui.InputText({431, 263}, 150, setting.dep.my_tag_en3, u8'Тег организации 4', 40, u8'Введите тег', 'ern')
						if setting.dep.my_tag_en3 ~= bool_save_input_tag4 then
							save()
						end
					end
				end
			end
		end
	elseif tab_settings == 8 then
		new_draw(16, 37)
		
		gui.Text(26, 26, 'Использовать акцент в разговоре', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 21))
		if gui.Switch(u8'##Акцент', setting.accent.func) then
			setting.accent.func = not setting.accent.func
			save()
		end
		
		if setting.accent.func then
			new_draw(72, 64)
			
			gui.Text(26, 82, 'Акцент персонажа', font[3])
			local bool_save_input = setting.accent.text
			setting.accent.text = gui.InputText({350, 84}, 231, setting.accent.text, u8'Акцент', 60, u8'Введите Ваш акцент', 'rus')
			if setting.accent.text ~= bool_save_input then
				save()
			end
			gui.TextInfo({26, 112}, {'Начните с заглавной буквы. Слово "акцент" писать не нужно. Например, "Британский"'})
			
			gui.Text(25, 155, 'Параметры', bold_font[1])
			new_draw(180, 143)
			gui.Text(26, 189, 'Акцент в рацию организации /r', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 184))
			if gui.Switch(u8'##Акцент в рацию организации /r', setting.accent.r) then
				setting.accent.r = not setting.accent.r
				save()
			end
			gui.DrawLine({16, 215}, {602, 215}, cl.line)
			gui.Text(26, 225, 'Акцент во время крика /s', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 220))
			if gui.Switch(u8'##Акцент во время крика /s', setting.accent.s) then
				setting.accent.s = not setting.accent.s
				save()
			end
			gui.DrawLine({16, 251}, {602, 251}, cl.line)
			gui.Text(26, 261, 'Акцент в рацию департамента /d', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 256))
			if gui.Switch(u8'##Акцент в рацию департамента /d', setting.accent.d) then
				setting.accent.d = not setting.accent.d
				save()
				if setting.accent.d and not setting.dep_off then
					sampRegisterChatCommand('d', function(text_accents_d) 
						if text_accents_d ~= '' and setting.accent.func and setting.accent.d and setting.accent.text ~= '' then
							sampSendChat('/d [' .. u8:decode(setting.accent.text) .. ' акцент]: ' .. text_accents_d)
						else
							sampSendChat('/d ' .. text_accents_d)
						end 
					end)
				elseif not setting.accent.d and not setting.dep_off then
					sampUnregisterChatCommand('d')
				end
			end
			gui.DrawLine({16, 287}, {602, 287}, cl.line)
			gui.Text(26, 297, 'Акцент в чат банды/мафии /f', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 292))
			if gui.Switch(u8'##Акцент в чат банды/мафии /f', setting.accent.f) then
				setting.accent.f = not setting.accent.f
				save()
			end
		end
	elseif tab_settings == 9 then
		new_draw(16, 405)
		
		gui.Text(26, 25, 'Моментальное открытие дверей и шлагбаумов', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 20))
		if gui.Switch(u8'##Моментальное открытие дверей и шлагбаумов', setting.speed_door) then
			setting.speed_door = not setting.speed_door
			save()
		end
		gui.TextInfo({26, 44}, {'Двери и шлагбаумы станут открываться моментально на клавишу H.'})
		gui.DrawLine({16, 69}, {602, 69}, cl.line)
		gui.Text(26, 79, 'Автоматическое принятие документов', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 74))
		if gui.Switch(u8'##Автопринятие документов', setting.show_dialog_auto) then
			setting.show_dialog_auto = not setting.show_dialog_auto
			save()
		end
		gui.TextInfo({26, 98}, {'Вам больше не нужно будет вводить /offer, чтобы посмотреть паспорт, мед. карту, лицензии', 'или трудовую книжку, которую хочет предложит посмотреть Вам игрок.'})
		gui.DrawLine({16, 137}, {602, 137}, cl.line)
		gui.Text(26, 147, 'Отключить команду рации департамента', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 142))
		if gui.Switch(u8'##Отключить рацию депа', setting.dep_off) then
			setting.dep_off = not setting.dep_off
			save()
			if setting.dep_off then
				sampRegisterChatCommand('d', function()
					sampAddChatMessage('[SH]{FFFFFF} Вы отключили команду /d в настройках.', 0xFF5345)
				end)
			else
				sampUnregisterChatCommand('d')
			end
		end
		gui.TextInfo({26, 166}, {'Если Вы очень часто по случайности отправляете информацию в рацию департамента,', 'то можете отключить команду /d. Тогда эта команда просто перестанет работать.'})
		gui.DrawLine({16, 205}, {602, 205}, cl.line)
		gui.Text(26, 215, 'Отображать под миникартой расстояние до серверной метки', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 210))
		if gui.Switch(u8'##Серверная метка', setting.display_map_distance.server) then
			setting.display_map_distance.server = not setting.display_map_distance.server
			save()
		end
		gui.DrawLine({16, 241}, {602, 241}, cl.line)
		gui.Text(26, 251, 'Отображать под миникартой расстояние до пользовательской метки', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 246))
		if gui.Switch(u8'##Пользовательская метка', setting.display_map_distance.user) then
			setting.display_map_distance.user = not setting.display_map_distance.user
			save()
		end
		gui.DrawLine({16, 277}, {602, 277}, cl.line)
		gui.Text(26, 287, 'Скриншот экрана + /time командой /ts', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 282))
		if gui.Switch(u8'##Команда ts', setting.ts) then
			setting.ts = not setting.ts
			if setting.ts then
				sampRegisterChatCommand('ts', print_scr_time)
			else
				sampUnregisterChatCommand('ts')
			end
			save()
		end
		gui.DrawLine({16, 313}, {602, 313}, cl.line)
		gui.Text(26, 323, 'Отображать дату и время под миникартой', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 318))
		if gui.Switch(u8'##Дата и время', setting.time_hud) then
			setting.time_hud = not setting.time_hud
			save()
		end
		gui.DrawLine({16, 349}, {602, 349}, cl.line)
		gui.Text(26, 359, 'Клавиша для остановки отыгровки - ' .. setting.act_key[2], font[3])
		if gui.Button(u8'Изменить...', {491, 355}, {99, 25}) then
			imgui.OpenPopup(u8'Изменить клавишу деактивации команды')
			lockPlayerControl(true)
			edit_key = true
			act_key = setting.act_key[1]
			current_key = {u8'Page Down', {34}}
		end
		gui.DrawLine({16, 385}, {602, 385}, cl.line)
		gui.Text(26, 395, 'Клавиша для продолжения отыгровки - ' .. setting.enter_key[2], font[3])
		if gui.Button(u8'Изменить...##клавишу продолжения', {491, 391}, {99, 25}) then
			imgui.OpenPopup(u8'Изменить клавишу продолжения команды')
			lockPlayerControl(true)
			edit_key = true
			enter_key = setting.enter_key[1]
			current_key = {u8'Enter', {13}}
		end
		
		new_draw(440, 53)
		gui.Text(26, 449, 'Изменить значение текущего времени', font[3])
		gui.TextInfo({26, 468}, {'Скрипт начнёт воспринимать текущее время с учётом Вашего изменения.'})
		
		local color_imVec4_button1, color_imVec4_button_text1 = cl.bg, cl.text
		if setting.time_offset >= 12 then
			color_imVec4_button1 = imgui.ImVec4(0.40, 0.40, 0.40, 0.50)
			color_imVec4_button_text1 = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
		else
			imgui.SetCursorPos(imgui.ImVec2(566, 454))
			if imgui.InvisibleButton(u8'##Прибавить значение к времени', imgui.ImVec2(26, 26)) then
				setting.time_offset = setting.time_offset + 1
				save()
			end
			
			if imgui.IsItemActive() then
				color_imVec4_button1 = cl.def
				color_imVec4_button_text1 = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
			end
		end
		gui.DrawCircle({578.5, 466.5}, 12.5, color_imVec4_button1)
		gui.FaText(572, 458, fa.PLUS, fa_font[3], color_imVec4_button_text1)
		
		local color_imVec4_button2, color_imVec4_button_text2 = cl.bg, cl.text
		if setting.time_offset <= -12 then
			color_imVec4_button2 = imgui.ImVec4(0.40, 0.40, 0.40, 0.50)
			color_imVec4_button_text2 = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
		else
			imgui.SetCursorPos(imgui.ImVec2(450, 454))
			if imgui.InvisibleButton(u8'##Убавить значение к времени', imgui.ImVec2(26, 26)) then
				setting.time_offset = setting.time_offset - 1
				save()
			end
			
			if imgui.IsItemActive() then
				color_imVec4_button2 = cl.def
				color_imVec4_button_text2 = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
			end
		end
		gui.DrawCircle({462.5, 466.5}, 12.5, color_imVec4_button2)
		gui.FaText(456, 458, fa.MINUS, fa_font[3], color_imVec4_button_text2)
		
		local format_time_text = ' час'
		if setting.time_offset >= -4 and setting.time_offset <= 4 and setting.time_offset ~= -1 and setting.time_offset ~= 1 then
			format_time_text = ' часа'
		elseif setting.time_offset ~= -1 and setting.time_offset ~= 1 then
			format_time_text = ' часов'
		end
		
		if setting.time_offset == 0 then
			gui.Text(492, 456, '0 часов', bold_font[1])
		elseif setting.time_offset > 0 then
			imgui.PushFont(bold_font[1])
			local text_format = '+' .. tostring(setting.time_offset) .. format_time_text
			local calc_size_text = imgui.CalcTextSize(u8(text_format))
			imgui.PopFont()
			gui.Text(521 - (calc_size_text.x / 2), 456, text_format, bold_font[1])
		else
			imgui.PushFont(bold_font[1])
			local text_format = tostring(setting.time_offset) .. format_time_text
			local calc_size_text = imgui.CalcTextSize(u8(text_format))
			imgui.PopFont()
			gui.Text(521 - (calc_size_text.x / 2), 456, text_format, bold_font[1])
		end
		
		
		if imgui.BeginPopupModal(u8'Изменить клавишу деактивации команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно КДК', imgui.ImVec2(16, 16)) then
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 40))
			imgui.BeginChild(u8'Назначение клавиши активации КДК', imgui.ImVec2(390, 181), false, imgui.WindowFlags.NoScrollbar)
			
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(10, 0))
			imgui.Text(u8'Нажмите на необходимую клавишу для назначения')
			imgui.SetCursorPos(imgui.ImVec2(10, 25))
			imgui.Text(u8'Текущая клавиша:')
			imgui.SetCursorPos(imgui.ImVec2(135, 25))
			if #act_key == 0 then
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
			else
				local all_key = {}
				for i = 1, #act_key do
					table.insert(all_key, vkeys.id_to_name(act_key[i]))
				end
				imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_key, ' + '))
			end
			imgui.PopFont()
			gui.DrawLine({0, 50}, {381, 50}, cl.line)
			
			if imgui.IsMouseClicked(0) then
				lua_thread.create(function()
					wait(500)
					setVirtualKeyDown(3, true)
					wait(0)
					setVirtualKeyDown(3, false)
				end)
			end
			local currently_pressed_keys = rkeys.getKeys(true)
			local pr_key_num = {34}
			local pr_key_name = {u8'Page Down'}
			if #currently_pressed_keys ~= 0 then
				local stop_hot = false
				for i = 1, #currently_pressed_keys do
					local parts = {}
					for part in currently_pressed_keys[i]:gmatch('[^:]+') do
						table.insert(parts, part)
					end
					if currently_pressed_keys[i] ~= u8'1:ЛКМ' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
					and currently_pressed_keys[i] ~= u8'2:ПКМ' then
						pr_key_num[1] = tonumber(parts[1])
						pr_key_name[1] = parts[2]
					else
						stop_hot = true
					end
				end
				if not stop_key_move and not stop_hot then
					if current_key == {u8'Page Down', {34}} then end
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
				current_key[1] = u8''
			end
			if current_key[1] ~= u8'Такая комбинация уже существует' then
				imgui.PushFont(bold_font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 80))
				if calc.x >= 385 then
					imgui.PopFont()
					imgui.PushFont(font[3])
					calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				end
				imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
				imgui.PopFont()
			else
				imgui.PushFont(font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
				imgui.PopFont()
			end
				
				
			if gui.Button(u8'Применить', {0, 144}, {185, 29}) then
				if not compare_array_disable_order(setting.act_key[1], current_key[2]) then
					local is_hot_key_done = false
					local num_hot_key_remove = 0
					
					if #all_keys ~= 0 and #current_key[2] ~= 0 then
						for i = 1, #all_keys do
							is_hot_key_done = compare_array_disable_order(all_keys[i], current_key[2])
							if is_hot_key_done then break end
						end
						for i = 1, #all_keys do
							if compare_array_disable_order(all_keys[i], setting.act_key[1]) then
								num_hot_key_remove = i
								break
							end
						end
					end
					if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
					if not is_hot_key_done then
						if num_hot_key_remove ~= 0 then
							table.remove(all_keys, num_hot_key_remove)
							rkeys.unRegisterHotKey(setting.act_key[1])
						end
						setting.act_key[1] = current_key[2]
						setting.act_key[2] = current_key[1]
						table.insert(all_keys, current_key[2])
						rkeys.registerHotKey(current_key[2], 3, true, function() on_hot_key(setting.act_key[1]) end)
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
						save()
					end
				else
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
			end
			if gui.Button(u8'Очистить', {194, 144}, {186, 29}) then
				current_key = {u8'Page Down', {34}}
			end
				
			imgui.EndChild()
			imgui.EndPopup()
		end
			
		if imgui.BeginPopupModal(u8'Изменить клавишу продолжения команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно КПК', imgui.ImVec2(16, 16)) then
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 40))
			imgui.BeginChild(u8'Назначение клавиши активации КПК', imgui.ImVec2(390, 181), false, imgui.WindowFlags.NoScrollbar)
			
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(10, 0))
			imgui.Text(u8'Нажмите на необходимую клавишу для назначения')
			imgui.SetCursorPos(imgui.ImVec2(10, 25))
			imgui.Text(u8'Текущая клавиша:')
			imgui.SetCursorPos(imgui.ImVec2(135, 25))
			if #enter_key == 0 then
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
			else
				local all_key = {}
				for i = 1, #enter_key do
					table.insert(all_key, vkeys.id_to_name(enter_key[i]))
				end
				imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_key, ' + '))
			end
			imgui.PopFont()
			gui.DrawLine({0, 50}, {381, 50}, cl.line)
			
			if imgui.IsMouseClicked(0) then
				lua_thread.create(function()
					wait(500)
					setVirtualKeyDown(3, true)
					wait(0)
					setVirtualKeyDown(3, false)
				end)
			end
			local currently_pressed_keys = rkeys.getKeys(true)
			local pr_key_num = {13}
			local pr_key_name = {u8'Enter'}
			if #currently_pressed_keys ~= 0 then
				local stop_hot = false
				for i = 1, #currently_pressed_keys do
					local parts = {}
					for part in currently_pressed_keys[i]:gmatch('[^:]+') do
						table.insert(parts, part)
					end
					if currently_pressed_keys[i] ~= u8'1:ЛКМ' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
					and currently_pressed_keys[i] ~= u8'2:ПКМ' then
						pr_key_num[1] = tonumber(parts[1])
						pr_key_name[1] = parts[2]
					else
						stop_hot = true
					end
				end
				if not stop_key_move and not stop_hot then
					if current_key == {u8'Enter', {13}} then end
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
				current_key[1] = u8''
			end
			if current_key[1] ~= u8'Такая комбинация уже существует' then
				imgui.PushFont(bold_font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 80))
				if calc.x >= 385 then
					imgui.PopFont()
					imgui.PushFont(font[3])
					calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				end
				imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
				imgui.PopFont()
			else
				imgui.PushFont(font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
				imgui.PopFont()
			end
				
				
			if gui.Button(u8'Применить', {0, 144}, {185, 29}) then
				if not compare_array_disable_order(setting.enter_key[1], current_key[2]) then
					local is_hot_key_done = false
					local num_hot_key_remove = 0
					
					if #all_keys ~= 0 and #current_key[2] ~= 0 then
						for i = 1, #all_keys do
							is_hot_key_done = compare_array_disable_order(all_keys[i], current_key[2])
							if is_hot_key_done then break end
						end
						for i = 1, #all_keys do
							if compare_array_disable_order(all_keys[i], setting.enter_key[1]) then
								num_hot_key_remove = i
								break
							end
						end
					end
					if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
					if not is_hot_key_done then
						if num_hot_key_remove ~= 0 then
							table.remove(all_keys, num_hot_key_remove)
							rkeys.unRegisterHotKey(setting.enter_key[1])
						end
						setting.enter_key[1] = current_key[2]
						setting.enter_key[2] = current_key[1]
						table.insert(all_keys, current_key[2])
						rkeys.registerHotKey(current_key[2], 3, true, function() on_hot_key(setting.enter_key[1]) end)
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
						save()
					end
				else
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
			end
			if gui.Button(u8'Очистить', {194, 144}, {186, 29}) then
				current_key = {u8'Enter', {13}}
			end
				
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		local pos_y_dopf = 0
		if setting.kick_afk.func then
			pos_y_dopf = 72
			new_draw(512, 107)
		else
			new_draw(512, 35)
		end
		gui.Text(26, 521, 'Автоматически кикать при привышении нормы АФК', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 516))
		if gui.Switch(u8'##Автокик АФК', setting.kick_afk.func) then
			setting.kick_afk.func = not setting.kick_afk.func
			save()
		end
		if setting.kick_afk.func then
			gui.DrawLine({16, 547}, {602, 547}, cl.line)
			gui.Text(26, 557, 'Введите значение в минутах', font[3])
			local bool_save_input_afk = setting.accent.text
			setting.kick_afk.time_kick = gui.InputText({417, 559}, 164, setting.kick_afk.time_kick, u8'АФК кик', 4, u8'Введите значение', 'num')
			if setting.kick_afk.time_kick ~= bool_save_input_afk then
				save()
			end
			gui.DrawLine({16, 583}, {602, 583}, cl.line)
			gui.Text(26, 593, 'Действие после привышения значения', font[3])
			local bool_set_act = setting.kick_afk.mode
			setting.kick_afk.mode = gui.ListTableMove({572, 593}, {u8'Полностью закрыть игру', u8'Закрыть соединение с сервером'}, setting.kick_afk.mode, 'Select action AFK')
			if setting.kick_afk.mode ~= bool_set_act then
				save() 
			end
			imgui.Dummy(imgui.ImVec2(0, 22))
		else
			imgui.Dummy(imgui.ImVec2(0, 25))
		end
	elseif tab_settings == 10 then
		local function accent_col(num_acc, color_acc, color_acc_act)
			imgui.SetCursorPos(imgui.ImVec2(278 + (num_acc * 43), 224))
			local p = imgui.GetCursorScreenPos()
			
			imgui.SetCursorPos(imgui.ImVec2(267 + (num_acc * 43), 214))
			if imgui.InvisibleButton(u8'##Выбор цвета' .. num_acc, imgui.ImVec2(22, 22)) then
				setting.color_def = color_acc
				setting.color_def_num = num_acc
				save()
				change_design(setting.cl, true)
			end
			if imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5),  12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
			end
			if num_acc == setting.color_def_num then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 4, imgui.GetColorU32Vec4(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
			end
		end
		new_draw(16, 226)
		local min_x = 115
		local min_y = 129
		gui.Draw({148 - min_x, 162 - min_y}, {252, 132}, imgui.ImVec4(0.98, 0.98, 0.98, 1.00), 7, 15)
		gui.Draw({448 - min_x, 162 - min_y}, {252, 132}, imgui.ImVec4(0.10, 0.10, 0.10, 1.00), 7, 15)
		
		--> Дизайн окон выбора темы
		gui.Draw({148 - min_x, 162 - min_y}, {252, 20}, imgui.ImVec4(0.91, 0.89, 0.76, 1.00), 7, 3)
		gui.Draw({448 - min_x, 162 - min_y}, {252, 20}, imgui.ImVec4(0.13, 0.13, 0.13, 1.00), 7, 3)
		gui.Draw({148 - min_x, 274 - min_y}, {252, 20}, imgui.ImVec4(0.91, 0.89, 0.76, 1.00), 7, 12)
		gui.Draw({448 - min_x, 274 - min_y}, {252, 20}, imgui.ImVec4(0.13, 0.13, 0.13, 1.00), 7, 12)
		gui.Draw({181 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
		gui.Draw({224 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
		gui.Draw({267 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
		gui.Draw({310 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
		gui.Draw({353 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
		gui.Draw({481 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
		gui.Draw({524 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
		gui.Draw({567 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
		gui.Draw({610 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
		gui.Draw({653 - min_x, 279 - min_y}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
		gui.Draw({244 - min_x, 167 - min_y}, {60, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
		gui.Draw({158 - min_x, 197 - min_y}, {200, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
		gui.Draw({158 - min_x, 222 - min_y}, {100, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
		gui.Draw({158 - min_x, 247 - min_y}, {150, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
		gui.Draw({544 - min_x, 167 - min_y}, {60, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
		gui.Draw({458 - min_x, 197 - min_y}, {200, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
		gui.Draw({458 - min_x, 222 - min_y}, {100, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
		gui.Draw({458 - min_x, 247 - min_y}, {150, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
		gui.DrawCircle({158 - min_x, 172 - min_y}, 4, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
		gui.DrawCircle({458 - min_x, 172 - min_y}, 4, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
		
		if setting.cl == 'White' then
			gui.DrawEmp({148 - min_x, 162 - min_y}, {252, 132}, cl.def, 7, 15, 3)
		else
			gui.DrawEmp({448 - min_x, 162 - min_y}, {252, 132}, cl.def, 7, 15, 3)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(148 - min_x, 162 - min_y))
		if imgui.InvisibleButton(u8'##Выбрать светлую тему', imgui.ImVec2(252, 132)) then
			if setting.cl ~= 'White' then
				change_design('White')
				save()
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(448 - min_x, 162 - min_y))
		if imgui.InvisibleButton(u8'##Выбрать тёмную тему', imgui.ImVec2(252, 132)) then
			if setting.cl ~= 'Black' then
				change_design('Black')
				save()
			end
		end
		
		gui.Text(204 - min_x, 306 - min_y, 'Светлое оформление', font[3])
		gui.Text(507 - min_x, 306 - min_y, 'Тёмное оформление', font[3])
		
		gui.DrawLine({16, 206}, {602, 206}, cl.line)
		gui.Text(26, 216, 'Цветовой акцент', font[3])
		accent_col(1, {0.26, 0.45, 0.94}, {0.26, 0.35, 0.94})
		accent_col(2, {0.75, 0.35, 0.87}, {0.75, 0.25, 0.87})
		accent_col(3, {1.00, 0.22, 0.37}, {1.00, 0.12, 0.37})
		accent_col(4, {1.00, 0.27, 0.23}, {1.00, 0.17, 0.23})
		accent_col(5, {1.00, 0.57, 0.04}, {1.00, 0.47, 0.04})
		accent_col(6, {0.20, 0.74, 0.29}, {0.20, 0.64, 0.29})
		accent_col(7, {0.50, 0.50, 0.52}, {0.40, 0.40, 0.42})
	elseif tab_settings == 11 then
		new_draw(16, 71)
		
		if setting.win_key[1] == '' then
			gui.Text(26, 25, 'Комбинация клавиш для открытия скрипта - Отсутствует', font[3])
			if gui.Button(u8'Назначить...##клавишу', {492, 21}, {99, 25}) then
				current_key = {'', {}}
				imgui.OpenPopup(u8'Изменить клавишу активации открытия скрипта')
				lockPlayerControl(true)
				edit_key = true
				win_key = setting.win_key[2]
			end
		else
			gui.Text(26, 25, 'Комбинация клавиш для открытия скрипта - ' .. setting.win_key[1], font[3])
			if gui.Button(u8'Изменить...##клавишу', {492, 21}, {99, 25}) then
				current_key = {'', {}}
				imgui.OpenPopup(u8'Изменить клавишу активации открытия скрипта')
				lockPlayerControl(true)
				edit_key = true
				win_key = setting.win_key[2]
			end
		end
		
		if imgui.BeginPopupModal(u8'Изменить клавишу активации открытия скрипта', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно КАC', imgui.ImVec2(16, 16)) then
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			imgui.SetCursorPos(imgui.ImVec2(10, 40))
			imgui.BeginChild(u8'Назначение клавиши активации КАC', imgui.ImVec2(390, 181), false, imgui.WindowFlags.NoScrollbar)
			
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(10, 0))
			imgui.Text(u8'Нажмите на необходимую клавишу или комбинацию')
			imgui.SetCursorPos(imgui.ImVec2(10, 25))
			imgui.Text(u8'Текущее сочетание:')
			imgui.SetCursorPos(imgui.ImVec2(145, 25))
			if #win_key == 0 then
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
			else
				local all_key = {}
				for i = 1, #win_key do
					table.insert(all_key, vkeys.id_to_name(win_key[i]))
				end
				imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_key, ' + '))
			end
			imgui.PopFont()
			gui.DrawLine({0, 50}, {381, 50}, cl.line)
			
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
					if currently_pressed_keys[i] ~= u8'1:ЛКМ' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
					and currently_pressed_keys[i] ~= u8'2:ПКМ' then
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
				current_key[1] = u8''
			end
			if current_key[1] ~= u8'Такая комбинация уже существует' then
				imgui.PushFont(bold_font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 80))
				if calc.x >= 385 then
					imgui.PopFont()
					imgui.PushFont(font[3])
					calc = imgui.CalcTextSize(current_key[1])
					imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				end
				imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
				imgui.PopFont()
			else
				imgui.PushFont(font[3])
				local calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
				imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
				imgui.PopFont()
			end
				
				
			if gui.Button(u8'Применить', {0, 144}, {185, 29}) then
				if not compare_array_disable_order(setting.win_key[2], current_key[2]) then
					local is_hot_key_done = false
					local num_hot_key_remove = 0
					local remove_sd = false
					
					if #current_key[2] == 0 and #setting.win_key[2] ~= 0 then
						remove_sd = true
						for i = 1, #all_keys do
							if compare_array_disable_order(all_keys[i], setting.win_key[2]) then
								num_hot_key_remove = i
								break
							end
						end
					else
						if #all_keys ~= 0 and #current_key[2] ~= 0 then
							for i = 1, #all_keys do
								is_hot_key_done = compare_array_disable_order(all_keys[i], current_key[2])
								if is_hot_key_done then break end
							end
							for i = 1, #all_keys do
								if compare_array_disable_order(all_keys[i], setting.win_key[2]) then
									num_hot_key_remove = i
									break
								end
							end
						end
					end
					if not remove_sd then
						if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
						if not is_hot_key_done then
							if num_hot_key_remove ~= 0 then
								table.remove(all_keys, num_hot_key_remove)
								rkeys.unRegisterHotKey(setting.win_key[2])
							end
							setting.win_key[2] = current_key[2]
							setting.win_key[1] = current_key[1]
							table.insert(all_keys, current_key[2])
							rkeys.registerHotKey(current_key[2], 3, true, function() on_hot_key(setting.win_key[2]) end)
							lockPlayerControl(false)
							edit_key = false
							imgui.CloseCurrentPopup()
							save()
						end
					else
						table.remove(all_keys, num_hot_key_remove)
						rkeys.unRegisterHotKey(setting.win_key[2])
						setting.win_key = {'', {}}
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
						save()
					end
				else
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
				end
			end
			if gui.Button(u8'Очистить', {194, 144}, {186, 29}) then
				current_key = {'', {}}
			end
				
			imgui.EndChild()
			imgui.EndPopup()
		end
			
		gui.DrawLine({16, 51}, {602, 51}, cl.line)
		if setting.cmd_open_win == '' then
			gui.Text(26, 61, 'Дополнительная команда для открытия скрипта - Отсутствует', font[3])
			if gui.Button(u8'Назначить...##команду', {492, 57}, {99, 25}) then
				lockPlayerControl(true)
				edit_cmd = true
				cur_cmd = setting.cmd_open_win
				new_cmd = setting.cmd_open_win
				imgui.OpenPopup(u8'Изменить команду для открытия скрипта')
			end
		else
			gui.Text(26, 61, 'Дополнительная команда для открытия скрипта - /' .. setting.cmd_open_win, font[3])
			if gui.Button(u8'Изменить...##команду', {492, 57}, {99, 25}) then
				lockPlayerControl(true)
				edit_cmd = true
				cur_cmd = setting.cmd_open_win
				new_cmd = setting.cmd_open_win
				imgui.OpenPopup(u8'Изменить команду для открытия скрипта')
			end
		end
		
		if edit_cmd then
			local cmd_end = cmd_edit(u8'Изменить команду для открытия скрипта', cur_cmd)
			if cmd_end ~= nil then
				if cmd_end ~= '' then
					setting.cmd_open_win = cmd_end
					sampRegisterChatCommand(cmd_end, function(arg)
						start_other_cmd(cmd_end, arg)
					end)
				else
					setting.cmd_open_win = ''
				end
				save()
			end
		end
		
		new_draw(106, 71)
		
		gui.Text(26, 115, 'Анимация движения окон', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 110))
		if gui.Switch(u8'##Анимация движения', setting.anim_win) then
			setting.anim_win = not setting.anim_win
			save()
		end
		gui.DrawLine({16, 141}, {602, 141}, cl.line)
		gui.Text(26, 151, 'Приветственное сообщение при запуске скрипта', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 146))
		if gui.Switch(u8'##Приветственное сообщение', setting.hi_mes) then
			setting.hi_mes = not setting.hi_mes
			save()
		end
		
		new_draw(196, 35)
		gui.Text(26, 205, 'Порядок расположения вкладок', font[3])
		if gui.Button(u8'Изменить...', {492, 201}, {99, 25}) then
			edit_order_tabs = true
		end
		
		new_draw(250, 35)
		gui.Text(26, 259, 'Отображать кнопку закрытия скрипта', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 254))
		if gui.Switch(u8'##Кнопка закрытия скрипта', setting.close_button) then
			setting.close_button = not setting.close_button
			save()
		end
		
		new_draw(304, 35)
		gui.Text(26, 313, 'Отображать лог ошибок в чате игры в случае сбоя скрипта', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 308))
		if gui.Switch(u8'##Отображать лог ошибок в чате после краша', setting.show_logs) then
			setting.show_logs = not setting.show_logs
			save()
		end
		
	elseif tab_settings == 12 then
		if new_version == '0' then
			if search_for_new_version > 600 then
				local function update_tail_rotation()
					tail_rotation_angle = (tail_rotation_angle + rotation_speed * anim) % 360
				end
				local function draw_tail(pos_upd_x, pos_upd_y)
					imgui.SetCursorPos(imgui.ImVec2(pos_upd_x, pos_upd_y))
					local p = imgui.GetCursorScreenPos()
					local circle_center_x, circle_center_y = p.x + 100, p.y + 100
					local circle_radius = 6
					local start_angle = math.rad(tail_rotation_angle)
					local end_angle = start_angle + math.rad(90)
					local draw_list = imgui.GetWindowDrawList()
					local segments = 32
					
					draw_list:AddCircle(imgui.ImVec2(circle_center_x, circle_center_y), circle_radius + 0.2, imgui.GetColorU32Vec4(imgui.ImVec4(0.40, 0.40, 0.40, 1.00)), 64, 3)
					
					for i = 0, segments do
						local t = i / segments
						local angle = start_angle + t * (end_angle - start_angle)
						local x = circle_center_x + math.cos(angle) * circle_radius
						local y = circle_center_y + math.sin(angle) * circle_radius
						if i > 0 then
							draw_list:AddLine(imgui.ImVec2(prev_x, prev_y), imgui.ImVec2(x, y), imgui.GetColorU32Vec4(cl.def), 2)
						end
						prev_x, prev_y = x, y
					end
				end

				update_tail_rotation()
				draw_tail(70, 110)
				gui.Text(185, 201, 'Проверка наличия обновления...', bold_font[1])
			
			else
				imgui.PushFont(bold_font[1])
				local calc_text_size = imgui.CalcTextSize('State Helper Lite ' .. scr.version)
				imgui.PopFont()
				gui.Text(309 - (calc_text_size.x / 2), 192, 'State Helper Lite ' .. scr.version, bold_font[1])
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
				gui.Text(252, 212, 'Версия актуальна', font[3])
				imgui.PopStyleColor(1)
			end
		else
			new_draw(72, 254)
			imgui.SetCursorPos(imgui.ImVec2(25, 81))
			imgui.Image(image_logo_update, imgui.ImVec2(47, 47))
			imgui.SetWindowFontScale(0.7)
			imgui.PushFont(bold_font[3])
			local calc_text_logo = imgui.CalcTextSize(update_info.version)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			gui.Text(48.5 - (calc_text_logo.x / 2), 92, update_info.version, bold_font[3])
			imgui.PopStyleColor(1)
			imgui.PopFont()
			imgui.SetWindowFontScale(1.0)
			gui.Text(80, 87, 'State Helper Lite ' .. update_info.version, font[3])
			gui.Text(80, 105, tostring(update_info.size) .. ' кб.', font[3])
			
			gui.DrawLine({16, 137}, {602, 137}, cl.line)
			imgui.SetCursorPos(imgui.ImVec2(16, 138))
			imgui.BeginChild(u8'Информация об обновлении', imgui.ImVec2(586, 188), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
			imgui.Scroller(u8'Информация об обновлении', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
			local text_update = u8'Обновление содержит исправление ошибок, улучшение кода, а тажке несколько\nновых функций. \n\nНововведения в этой версии:\n1. Во вкладку Команды добавлен поиск команд.\n2. Во вкладке Команды теперь можно сравнивать аргументы или переменные по \nвеличине данных.\n3. Во вкладке Команды добавлен тег для получения игрового уровня игрока.\n4. Во вкладке Команды ветки условий теперь сортируются по блокам для удобства \nчтения.\n5. Добавлена функция автопереноса текста в игровом чате, если текст превышает \nдопустимую длину символов.\n6. Для сотрудников Больниц сервера Phoenix добавлена кастомная мед. карта.\n7. В функции Мемберс на экране теперь можно отключить отображение определён-\nных рангов.\n8. Исправлен баг, из-за которого при включённой функции Мемберс на экране авто-\nпринятие документов могло не сработать.\n9. Исправлен баг, из-за которого добавление некоторых действий в определённое \nместо в Командах добавляло их в конец, а не на нужное место.\n10. Исправлен баг, из-за которого функция сброса настроек скрипта не работала.\n11. Исправлен баг, из-за которого функция Автооткрытие вызовов у Пожарного Де-\nпартамента отправляла /fires во время активного вызова.\n12. Исправлен баг, из-за которого у сотрудников Автошколы выдача лицензии могла \nне происходить автоматически из-за включённого Мемберс на экране.'
			local pos_y_line = 10
			--update_info.text = text_update
			for line, newlines in update_info.text:gmatch('([^\n]*)(\n*)') do
				if line:find(u8'Нововведения в этой версии') then
					imgui.PushFont(font[3])
					local calc_text_new = imgui.CalcTextSize(line)
					gui.Text(10, pos_y_line, u8:decode(line), bold_font[1])
					imgui.PopFont()
					pos_y_line = pos_y_line + 24
				elseif line ~= '' then
					gui.Text(10, pos_y_line, u8:decode(line), font[3])
					pos_y_line = pos_y_line + 18
				end
				if #newlines > 0 then
					pos_y_line = pos_y_line + (#newlines - 1) * 24
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 10))
			imgui.EndChild()
			if update_request >= 9 then
				gui.Button(u8'Обновление запрошено...', {16, 334}, {586, 27}, false)
			elseif update_request > 0 then
				gui.Button(u8'Произошла ошибка при попытке обновления, пытаемся восстановить...', {16, 334}, {586, 27}, false)
			else
				if gui.Button(u8'Установить', {16, 334}, {586, 27}) then
					update_request = 20
					update_download()
				end
			end
		end
	elseif tab_settings == 13 then
		imgui.PushFont(bold_font[3])
		local calc_text = imgui.CalcTextSize('State Helper Lite ' .. scr.version)
		imgui.SetCursorPos(imgui.ImVec2(309 - (calc_text.x / 2), 365))
		gui.TextGradient('State Helper Lite ' .. scr.version, 0.5, 1.00)
		local titles = {
			'',
			'',
			'',
			'Авторское право © 2023 - 2025 Марсель Афанасьев',
			'Все права сохранены.',
			'',
			'',
			'',
			'{45f731}Создано:',
			'Alberto_Kane, Phoenix {FF9500}(Автор идеи)',
			'',
			'',
			'',
			'{45f731}Программисты:',
			'Alberto_Kane, Phoenix {FF9500}(Fullstack-разработчик скрипта)',
			'Luke_Blather, Phoenix {FF9500}(Backend-разработчик API-сервера)',
			'',
			'',
			'',
			'{45f731}Остальная команда:',
			'Ilya_Kustov, Phoenix {FF9500}(QA-инженер, поддержка скрипта и обработка предложений)',
			'Emma_Simmons, Phoenix {FF9500}(QA-инженер, помощь в разработке функциональности)',
			'Oliver_Blain, Love {FF9500}(QA-инженер стадии Бета)',
			'Richard_Forbes, Surprise {FF9500}(Разработчик сайта, помощь в разработке функций)',
			'Robert_Poloskyn, Winslow {FF9500}(QA-инженер стадии Бета, помощь в разработке функций)',
			'Maestro_Hennessy, Phoenix {FF9500}(QA-инженер стадии Бета)',
			'Daniel_Heiliger, Love {FF9500}(QA-инженер стадии Бета)',
			'Samuel_Hayakawa, Phoenix {FF9500}(QA-инженер стадии Бета)',
			'Alfredo_Mason, Phoenix {FF9500}(QA-инженер стадии Бета)',
			'Danny_Bronks, Mirage {FF9500}(QA-инженер стадии Бета)',
			'Tetsuya_Midzuno, Faraway {FF9500}(QA-инженер стадии Бета)',
			'Yan_Heiliger, Love {FF9500}(QA-инженер стадии Бета)',
			'Brian_Petty, Tucson {FF9500}(QA-инженер стадии Бета)',
			'Franklin_Perry, Bumble Bee {FF9500}(QA-инженер стадии Бета)',
			'Victor_Bellucci, Tucson {FF9500}(QA-инженер стадии Бета)',
			'Sover_Covanio, Phoenix {FF9500}(QA-инженер стадии Бета)',
			'Saul_Goodmaan, Love {FF9500}(QA-инженер стадии Бета)',
			'Aaron_Grella, Mesa {FF9500}(QA-инженер стадии Бета)',
			'Virka_Vandalov, Wednesday {FF9500}(QA-инженер стадии Бета)',
			'Richard_Anderson, Phoenix {FF9500}(QA-тестировщик, помощь в ранней стадии разработки)',
			'Samuel_Kloppo, Red-Rock {FF9500}(Помощь в разработке функциональности)',
			'Kevin_Hatiko, Saint Rose {FF9500}(Вдохновение на создание скрипта)',
			'',
			'',
			'',
			'Скрипт разработан для облегчения работы сотрудников государственных структур',
			'проекта Arizona RP с дополнительной функциональностью для обычных игроков.',
			'',
			'',
			'',
			'Копировать скрипт, его реализованные функции из кода, кастомные элементы',
			'дизайна, а также присваивать себе авторство скрипта категорически запрещено',
			'и может быть протестовано.',
			'',
			'',
			'',
			'{45f731}State Helper Lite',
			'Самый быстрый путь от Вашей задумки до её реализации.'			
		}
		
		pos_titles = 410
		for i = 1, #titles do
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(16, pos_titles))
			imgui.TextColoredRGB(titles[i])
			imgui.PopFont()
			
			pos_titles = pos_titles + 20
		end
		
		
		imgui.Dummy(imgui.ImVec2(0, 380))
		local max_scroll = imgui.GetScrollMaxY()
		imgui.SetScrollY(up_child_sub)
		if up_child_sub < max_scroll then
			up_child_sub = up_child_sub + (anim * 25)
		else
			up_child_sub = 0
		end
		imgui.PopFont()
	elseif tab_settings == 14 then --> Команды
		cmd_amd_key_tab(1)
	elseif tab_settings == 15 then --> Шпаргалки
		cmd_amd_key_tab(2)
	elseif tab_settings == 16 then --> Департамент
		cmd_amd_key_tab(3)
	elseif tab_settings == 17 then --> Собеседование
		local ret = cmd_amd_key_tab(4)
		
		if ret then
			new_draw(106, 53)
			gui.Text(26, 115, 'Передавать в аргумент команды id игрока', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 110))
			if gui.Switch(u8'##Передавать в аргумент команды id игрока', setting.sob_id_arg) then
				setting.sob_id_arg = not setting.sob_id_arg
				save()
			end
			gui.TextInfo({26, 134}, {'Передав в аргумент id игрока, Вы сразу начнёте собеседование с этим игроком.'})
		end
	elseif tab_settings == 18 then --> Напоминания
		cmd_amd_key_tab(5)
	elseif tab_settings == 19 then --> Статистика
		cmd_amd_key_tab(6)
		new_draw(106, 35)
		gui.Text(26, 115, 'Отображать статистику онлайна на экране', font[3])
		imgui.SetCursorPos(imgui.ImVec2(561, 110))
		if gui.Switch(u8'##Стата онлайна на экране', setting.stat_on_screen.func) then
			setting.stat_on_screen.func = not setting.stat_on_screen.func
			save()
		end
		if setting.stat_on_screen.func then
			new_draw(160, 395)
			for ps = 0, 9 do
				gui.DrawLine({16, 195 + (ps * 36)}, {602, 195 + (ps * 36)}, cl.line)
			end
			
			gui.Text(26, 169, 'Отображать текущее время', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 164))
			if gui.Switch(u8'##Текущее время в стате онлайна на экране', setting.stat_on_screen.current_time) then
				setting.stat_on_screen.current_time = not setting.stat_on_screen.current_time
				save()
			end
			gui.Text(26, 205, 'Отображать текущую дату', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 200))
			if gui.Switch(u8'##Текущую дату в стате онлайна на экране', setting.stat_on_screen.current_date) then
				setting.stat_on_screen.current_date = not setting.stat_on_screen.current_date
				save()
			end
			gui.Text(26, 241, 'Показывать отыгранные часы за день без учёта АФК', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 236))
			if gui.Switch(u8'##Показывать отыгранные часы за день в стате онлайна на экране', setting.stat_on_screen.day) then
				setting.stat_on_screen.day = not setting.stat_on_screen.day
				save()
			end
			gui.Text(26, 277, 'Показывать нахождение в АФК за день', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 272))
			if gui.Switch(u8'##Показывать нахождение в афк за день в стате онлайна на экране', setting.stat_on_screen.afk) then
				setting.stat_on_screen.afk = not setting.stat_on_screen.afk
				save()
			end
			gui.Text(26, 313, 'Показывать общее время в игре за день', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 308))
			if gui.Switch(u8'##Показывать общее время в игре за день в стате онлайна на экране', setting.stat_on_screen.all) then
				setting.stat_on_screen.all = not setting.stat_on_screen.all
				save()
			end
			gui.Text(26, 349, 'Показывать отыгранные часы за сессию без учёта АФК', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 344))
			if gui.Switch(u8'##Показывать отыгранные часы за сессию в стате онлайна на экране', setting.stat_on_screen.ses_day) then
				setting.stat_on_screen.ses_day = not setting.stat_on_screen.ses_day
				save()
			end
			gui.Text(26, 385, 'Показывать нахождение в АФК за сессию', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 380))
			if gui.Switch(u8'##Показывать нахождение в афк за сессию в стате онлайна на экране', setting.stat_on_screen.ses_afk) then
				setting.stat_on_screen.ses_afk = not setting.stat_on_screen.ses_afk
				save()
			end
			gui.Text(26, 421, 'Показывать общее время в игре за сессию', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 416))
			if gui.Switch(u8'##Показывать общее время в игре за сессию в стате онлайна на экране', setting.stat_on_screen.ses_all) then
				setting.stat_on_screen.ses_all = not setting.stat_on_screen.ses_all
				save()
			end
			gui.Text(26, 457, 'Скрывать окно при открытых диалогах', font[3])
			imgui.SetCursorPos(imgui.ImVec2(561, 452))
			if gui.Switch(u8'##Скрывать окно при открытых диалогах в стате онлайна на экране', setting.stat_on_screen.dialog) then
				setting.stat_on_screen.dialog = not setting.stat_on_screen.dialog
				save()
			end
			gui.Text(26, 493, 'Прозрачность окна', font[3])
			local bool_visible = imgui.new.float(setting.stat_on_screen.visible)
			setting.stat_on_screen.visible = gui.SliderBar('##Прозрачность текста', bool_visible, 0, 100, 180, {415, 490})
			setting.stat_on_screen.visible = round(setting.stat_on_screen.visible, 0.1)
			gui.Text(26, 529, 'Позиция окна на экране', font[3])
			if gui.Button(u8'Изменить...', {492, 524}, {100, 27}) then
				ch_pos_on_stat()
			end
			
			imgui.Dummy(imgui.ImVec2(0, 21))
		end
	elseif tab_settings == 20 then --> Музыка
		cmd_amd_key_tab(7)
	elseif tab_settings == 21 then --> Рп зона
		cmd_amd_key_tab(8)
	elseif tab_settings == 22 then --> Действия
		cmd_amd_key_tab(9)
	end
	imgui.EndChild()
	
	if tab_settings == 4 and setting.fast.func then
		gui.DrawLine({226, 374}, {844, 374}, cl.line)
		gui.Draw({226, 375}, {618, 33}, cl.tab)
		if (not bool_edit_fast or #setting.fast.one_win == 0) or (not bool_edit_fast or #setting.fast.two_win == 0) then
			if gui.Button(u8'Добавить действие', {461, 377}, {148, 29}) then
				if an[5][4] >= 180 then
					an[5][1] = an[5][1] - 1
				end
			end
		elseif bool_edit_fast then
			if gui.Button(u8'Применить', {487, 377}, {96, 29}) then
				bool_edit_fast = false
			end
		end
		
		if (#setting.fast.one_win > 0 and num_win_fast == 1) or (#setting.fast.two_win > 0 and num_win_fast == 2) then
			imgui.SetCursorPos(imgui.ImVec2(814, 381))
			if imgui.InvisibleButton(u8'##Настройки быстрого доступа', imgui.ImVec2(22, 22)) then
				bool_edit_fast = not bool_edit_fast
			end
			imgui.PushFont(fa_font[4])
			imgui.SetCursorPos(imgui.ImVec2(816, 383))
			if imgui.IsItemActive() then
				imgui.TextColored(cl.def, fa.GEAR)
			else
				imgui.Text(fa.GEAR)
			end
			imgui.PopFont()
		else
			bool_edit_fast = false
		end
		if an[5][1] < 0 and an[5][1] > -165.2 then
			local bool_minus = 40 * anim
			an[5][1] = (an[5][1] - bool_minus) - (bool_minus * match_interpolation(0, 155, -an[5][1], 30))
		elseif an[5][1] <= -165.2 and an[5][1] > -165.3 then
			if num_win_fast == 1 then
				table.insert(setting.fast.one_win, {name = u8'Действие ' .. (#setting.fast.one_win + 1), cmd = '', send = true, id = true})
			else
				table.insert(setting.fast.two_win, {name = u8'Действие ' .. (#setting.fast.two_win + 1), cmd = '', send = true, id = true})
			end
			an[5][1] = -165.4
			an[5][3] = 0
			an[5][4] = 0
		else
			an[5][1] = 0
			an[5][2] = 420
			if an[5][3] < 1.00 then
				an[5][3] = an[5][3] + (2.9 * anim)
			else
				an[5][3] = 1.00
			end
			if an[5][4] < 180 then
				an[5][4] = an[5][4] + (1000 * anim)
				if an[5][4] > 180 then an[5][4] = 180 end
			else
				an[5][4] = 180
			end
		end
	end
	
	if edit_order_tabs then
		imgui.SetCursorPos(imgui.ImVec2(0, 34))
		imgui.BeginChild(u8'Блок для изменения расположения вкладок', imgui.ImVec2(848, 375), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)
		
		gui.Draw({4, 4}, {840, 370}, imgui.ImVec4(0.50, 0.50, 0.50, 0.90), 0, 15)
		if gui.Button(u8'Применить##настройку вкладок', {377, 315}, {94, 27}) then
			edit_order_tabs = false
			save()
		end
		gui.Text(137, 350, 'Меняйте вкладки местами, так как Вам будет удобней, после чего нажмите применить.', font[3])
		
		imgui.EndChild()
	end
	
	gui.DrawLine({224, 38}, {224, 409}, cl.tab, 2)
	gui.DrawLine({225, 38}, {225, 409}, cl.line)
end

function hall.cmd()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	if not edit_tab_cmd then
		gui.Draw({4, 39}, {221, 369}, cl.tab, 0, 15)
		gui.DrawLine({225, 39}, {225, 408}, cl.line)
		
		imgui.SetCursorPos(imgui.ImVec2(4, 39))
		imgui.BeginChild(u8'Папки команд', imgui.ImVec2(220, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
		imgui.Scroller(u8'Папки команд', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
		local ps = {3, 2, 0}
		local ps_y = 0
		
		local function TableMove(pos_draw, name_table)
			local col_stand_imvec4 = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			local return_bool = 0
			local arg_table = {u8'Запустить', u8'Редактировать', u8'Удалить'}
			local icon_table = {fa.CIRCLE_PLAY, fa.PEN_RULER, fa.TRASH}
			imgui.PushFont(font[3])
			
			if table_move_cmd == name_table then
				imgui.SetCursorPos(imgui.ImVec2(pos_draw[1], pos_draw[2]))
				imgui.BeginChild(u8'Окно выбора действия с командой' .. name_table, imgui.ImVec2(140, 83), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
				
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 140, p.y + 81), imgui.GetColorU32Vec4(cl.bg), 7, 15)
				
				for m = 1, 3 do
					local col_stand_imvec4_2 = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
					imgui.SetCursorPos(imgui.ImVec2(0, 1 + (m - 1) * 27))
					if imgui.InvisibleButton('##TableMoveSelect ' .. name_table .. m, imgui.ImVec2(140, 27)) then
						table_move_cmd = ''
						return_bool = m
					end
					if imgui.IsItemActive() then
						col_stand_imvec4_2 = cl.def
					elseif imgui.IsItemHovered() then
						col_stand_imvec4_2 = cl.bg2
					end
					imgui.SetCursorPos(imgui.ImVec2(1, 1 + (m - 1) * 27))
					local p = imgui.GetCursorScreenPos()
					local flag = {0, 0}
					if m == 1 then 
						flag = {4, 3}
					elseif m == 3 then
						flag = {4, 12}
					end
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 138, p.y + 27), imgui.GetColorU32Vec4(col_stand_imvec4_2), flag[1], flag[2])
					
					imgui.SetCursorPos(imgui.ImVec2(25, 6 + ((m - 1) * 27)))
					imgui.Text(arg_table[m])
					
					imgui.PushFont(fa_font[2])
					imgui.SetCursorPos(imgui.ImVec2(7, 6 + ((m - 1) * 27)))
					imgui.Text(icon_table[m])
					imgui.PopFont()
				end
				imgui.SetCursorPos(imgui.ImVec2(0, 0))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 140, p.y + 82), imgui.GetColorU32Vec4(cl.def), 7, 15)
				imgui.EndChild()
				
				if imgui.IsMouseReleased(0) and not imgui.IsItemHovered() then
					table_move_cmd = ''
				end
			end
			
			imgui.PopFont()
			
			return return_bool
		end
		local function folder_list_defoult(TEXT, FA, NUM, POS) --> Отрисовка стандартных папок
			POS = ((POS - 1) * 30) + ps_y
			local return_break = false
			--> Отрисовка кнопки перехода
			imgui.SetCursorPos(imgui.ImVec2(25, 15 + POS))
			if not edit_all_cmd or (edit_all_cmd and NUM <=7 ) then
				if imgui.InvisibleButton(u8'##Открыть папку' .. NUM, imgui.ImVec2(172, 24)) then
					int_cmd.folder = NUM
					edit_all_cmd = false
					an[13] = 0
					an[12][3] = false
					an[12][2] = 0
				end
				if imgui.IsItemActive() and int_cmd.folder ~= NUM and table_move_cmd == ''  then
					gui.Draw({25, 15 + POS}, {172, 24}, color_ItemActive, 5, 15)
				elseif imgui.IsItemHovered() and int_cmd.folder ~= NUM and table_move_cmd == ''  then
					gui.Draw({25, 15 + POS}, {172, 24}, color_ItemHovered, 5, 15)
				elseif int_cmd.folder == NUM then
					if setting.cl == 'White' then
						gui.Draw({25, 15 + POS}, {172, 24}, imgui.ImVec4(0.76, 0.76, 0.76, 1.00), 5, 15)
					else
						gui.Draw({25, 15 + POS}, {172, 24}, imgui.ImVec4(0.18, 0.18, 0.18, 1.00), 5, 15)
					end
				end
			end
			--> Отрисовка кнопки листа
			local vis_fa = 0.50
			imgui.SetCursorPos(imgui.ImVec2(7, 17 + POS))
			if imgui.InvisibleButton(u8'##Раскрыть лист' .. NUM, imgui.ImVec2(19, 19)) then
				cmd[2][NUM][2] = not cmd[2][NUM][2]
			end
			if imgui.IsItemHovered() then
				if an[6][2] ~= NUM then
					an[6][2] = NUM
					an[6][1] = 0
				end
				if an[6][1] < 0.50 then
					an[6][1] = an[6][1] + (anim * 1.5)
				end
				vis_fa = vis_fa + an[6][1]
			elseif an[6][2] == NUM and an[6][1] > 0 then
				an[6][1] = an[6][1] - (anim * 1.5)
				vis_fa = vis_fa + an[6][1]
			end
			
			--> Отрисовка текста и иконки
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
			imgui.PushFont(fa_font[3])
			imgui.SetCursorPos(imgui.ImVec2(31 + FA.SDVIG[1], 18 + FA.SDVIG[2] + POS))
			if not edit_all_cmd or (edit_all_cmd and NUM <= 7) then
				imgui.Text(FA.ICON_FOLDER)
			else
				imgui.SetCursorPos(imgui.ImVec2(29 + FA.SDVIG[1], 18 + FA.SDVIG[2] + POS))
				if imgui.InvisibleButton('##DEL_FOLDER' .. NUM, imgui.ImVec2(19, 19)) then
					if #cmd[1] ~= 0 then
						for j = 1, #cmd[1] do
							if cmd[1][j].folder == NUM then
								cmd[1][j].folder = 1
							elseif cmd[1][j].folder > NUM then
								cmd[1][j].folder = cmd[1][j].folder - 1
							end
						end
					end
					table.remove(cmd[2], NUM)
					return_break = true
				end
				if imgui.IsItemActive() then
					gui.FaText(31 + FA.SDVIG[1], 19 + FA.SDVIG[2] + POS, fa.CIRCLE_MINUS, fa_font[3], imgui.ImVec4(1.00, 0.09, 0.19, 1.00))
				else
					gui.FaText(31 + FA.SDVIG[1], 19 + FA.SDVIG[2] + POS, fa.CIRCLE_MINUS, fa_font[3], imgui.ImVec4(1.00, 0.23, 0.19, 1.00))
				end
			end
			if return_break then
				imgui.PopStyleColor(1)
				imgui.PopFont()
				return true 
			end
			if setting.cl == 'White' then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40 - (vis_fa / 2), 0.40 - (vis_fa / 2), 0.40 - (vis_fa / 2), vis_fa))
			else
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + (vis_fa / 2), 0.50 + (vis_fa / 2), 0.50 + (vis_fa / 2), vis_fa))
			end
			if cmd[2][NUM][2] then
				imgui.SetCursorPos(imgui.ImVec2(10, 18 + POS))
				imgui.Text(fa.ANGLE_DOWN)
			else
				imgui.SetCursorPos(imgui.ImVec2(13, 18 + POS))
				imgui.Text(fa.ANGLE_RIGHT)
			end
			imgui.PopStyleColor(2)
			imgui.PopFont()
			if (edit_name_folder and NUM == #cmd[2]) or (edit_all_cmd and NUM > 7) then
				imgui.PushFont(font[3])
				local txt_inp_buf = imgui.new.char[40](cmd[2][NUM][1])
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.30, 0.30, 0.30, 1.00))
				imgui.SetCursorPos(imgui.ImVec2(53, 20 + POS))
				imgui.PushItemWidth(140)
				imgui.InputText('##NAME_FOLDER' .. NUM, txt_inp_buf, ffi.sizeof(txt_inp_buf))
				imgui.PopStyleColor(1)
				if not focus_input_bool and not imgui.IsItemActive() and not edit_all_cmd then
					edit_name_folder = false
					save_cmd()
				end
				if cmd[2][NUM][1] == '' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
					gui.Text(53, 20 + POS, 'Имя файла', font[3])
					imgui.PopStyleColor(1)
				end
				imgui.PopItemWidth()
				cmd[2][NUM][1] = ffi.string(txt_inp_buf)
				
				if focus_input_bool and not scroll_input_bool and not edit_all_cmd then
					imgui.SetKeyboardFocusHere(-1)
					focus_input_bool = false
				end
				if scroll_input_bool and not edit_all_cmd then
					imgui.SetScrollY(imgui.GetScrollMaxY() + 20)
					scroll_input_bool = false
				end
				imgui.PopFont()
			else
				gui.Text(53, 20 + POS, TEXT, font[3])
			end
			
			if cmd[2][NUM][2] then
				POS = POS - ps_y
				local param_bool = true
				if #cmd[1] ~= 0 then
					for g = 1, #cmd[1] do
						if cmd[1][g].folder == NUM or NUM == 1 then
							imgui.SetCursorPos(imgui.ImVec2(52, 41 + POS + ps_y))
							if imgui.InvisibleButton('##SELECT_CMD' .. NUM .. g, imgui.ImVec2(155, 21)) then
								table_move_cmd = 'SEL_CMD_MOVE ' .. NUM .. g
							end
							if imgui.IsItemActive() and table_move_cmd == ''  then
								gui.Draw({52, 41 + POS + ps_y}, {155, 21}, color_ItemActive, 5, 15)
							elseif imgui.IsItemHovered() and table_move_cmd == ''  then
								gui.Draw({52, 41 + POS + ps_y}, {155, 21}, color_ItemHovered, 5, 15)
							end
							
							if setting.cl == 'White' then
								imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.25, 0.25, 0.25, 0.70))
							else
								imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.75, 0.75, 0.75, 0.50))
							end
							gui.Text(60, 43 + POS + ps_y, '/' .. u8:decode(cmd[1][g].cmd), font[3])
							imgui.PopStyleColor(1)
							local bool_tm = TableMove({52, 41 + POS + ps_y}, 'SEL_CMD_MOVE ' .. NUM .. g)
							if bool_tm == 1 then
								cmd_start('', tostring(cmd[1][g].UID) .. cmd[1][g].cmd)
							elseif bool_tm == 2 then
								edit_tab_cmd = true
								bl_cmd = cmd[1][g]
								cmd_memory = bl_cmd.cmd
								type_cmd = g
							elseif bool_tm == 3 then
								if #cmd[1][g].key[2] ~= 0 then
									rkeys.unRegisterHotKey(cmd[1][g].key[2])
									for ke = 1, #all_keys do
										if table.concat(all_keys[ke], ' ') == table.concat(cmd[1][g].key[2], ' ') then
											table.remove(all_keys, ke)
										end
									end
								end
								if cmd[1][g].cmd ~= '' then
									sampUnregisterChatCommand(cmd[1][g].cmd)
								end
								table.remove(cmd[1], g)
								save_cmd()
							end
							ps_y = ps_y + 22
							param_bool = false
						end
					end
				end
				if param_bool then
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
					end
					gui.Text(60, 43 + POS + ps_y, 'Пусто', font[3])
					imgui.PopStyleColor(1)
					ps_y = ps_y + 18
				end
			end
			
			if return_break then return true end
		end
		
		--> Реализация папок
		folder_list_defoult(
			'Все команды',
			{ICON_FOLDER = fa.GLOBE, SDVIG = {0, 0}},
			1,
			1
		)
		
		folder_list_defoult(
			'Избранные',
			{ICON_FOLDER = fa.STAR, SDVIG = {-1, -1}},
			2,
			2 + ps[3]
		)
		
		--> Лист организации
		local pos_list_org = (ps[3] * 30)
		imgui.SetCursorPos(imgui.ImVec2(10, 85 + pos_list_org + ps_y))
		if imgui.InvisibleButton(u8'##Раскрыть лист организации', imgui.ImVec2(111, 19)) then
			int_cmd.group[1] = not int_cmd.group[1]
		end
		if imgui.IsItemActive() and table_move_cmd == ''  then
			gui.Draw({10, 85 + pos_list_org + ps_y}, {111, 19}, color_ItemActive, 5, 15)
		elseif imgui.IsItemHovered() and table_move_cmd == ''  then
			gui.Draw({10, 85 + pos_list_org + ps_y}, {111, 19}, color_ItemHovered, 5, 15)
		end
		if setting.cl == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		gui.Text(13, 86 + pos_list_org + ps_y, 'Организация', font[3])
		if int_cmd.group[1] then
			gui.FaText(106, 86 + pos_list_org + ps_y, fa.ANGLE_DOWN, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		else
			gui.FaText(106, 86 + pos_list_org + ps_y, fa.ANGLE_RIGHT, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		imgui.PopStyleColor(1)
		
		if int_cmd.group[1] then
			folder_list_defoult(
				'Основные',
				{ICON_FOLDER = fa.HOUSE, SDVIG = {-1, 0}},
				3,
				4.2 + ps[3]
			)
			folder_list_defoult(
				'Фракционные',
				{ICON_FOLDER = fa.BRIEFCASE, SDVIG = {0, 1}},
				4,
				5.2 + ps[3]
			)
			folder_list_defoult(
				'Для руководства',
				{ICON_FOLDER = fa.USER_TIE, SDVIG = {0, 0}},
				5,
				6.2 + ps[3]
			)
		else
			ps[1] = 0
		end
		
		--> Лист общих
		local pos_list_o = (ps[1] * 30)
		if setting.cl == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		imgui.SetCursorPos(imgui.ImVec2(10, 121 + pos_list_o + ps_y))
		if imgui.InvisibleButton(u8'##Раскрыть лист общих', imgui.ImVec2(71, 19)) then
			int_cmd.group[2] = not int_cmd.group[2]
		end
		if imgui.IsItemActive() and table_move_cmd == ''  then
			gui.Draw({10, 121 + pos_list_o + ps_y}, {71, 19}, color_ItemActive, 5, 15)
		elseif imgui.IsItemHovered() and table_move_cmd == ''  then
			gui.Draw({10, 121 + pos_list_o + ps_y}, {71, 19}, color_ItemHovered, 5, 15)
		end
		gui.Text(13, 122 + pos_list_o + ps_y, 'Общие', font[3])
		if int_cmd.group[2] then
			gui.FaText(66, 122 + pos_list_o + ps_y, fa.ANGLE_DOWN, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		else
			gui.FaText(66, 122 + pos_list_o + ps_y, fa.ANGLE_RIGHT, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		imgui.PopStyleColor(1)
		
		if int_cmd.group[2] then
			folder_list_defoult(
				'Лекции',
				{ICON_FOLDER = fa.MICROPHONE, SDVIG = {0, 0}},
				6,
				5.4 + ps[1]
			)
			folder_list_defoult(
				'Разное',
				{ICON_FOLDER = fa.LAYER_GROUP, SDVIG = {-2, 0}},
				7,
				6.4 + ps[1]
			)
		else
			ps[2] = 0
		end
		
		--> Лист личных
		local pos_list_l = ((ps[1] * 30) + (ps[2] * 30)) + ps_y
		imgui.SetCursorPos(imgui.ImVec2(10, 157 + pos_list_l))
		if imgui.InvisibleButton(u8'##Раскрыть лист личных', imgui.ImVec2(76, 19)) then
			int_cmd.group[3] = not int_cmd.group[3]
		end
		if imgui.IsItemActive() and table_move_cmd == ''  then
			gui.Draw({10,  157 + pos_list_l}, {76, 19}, color_ItemActive, 5, 15)
		elseif imgui.IsItemHovered() and table_move_cmd == ''  then
			gui.Draw({10,  157 + pos_list_l}, {76, 19}, color_ItemHovered, 5, 15)
		end
		if setting.cl == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		gui.Text(13, 158 + pos_list_l, 'Личные', font[3])
		imgui.PopStyleColor(1)
		if int_cmd.group[3] then
			gui.FaText(71, 158 + pos_list_l, fa.ANGLE_DOWN, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		else
			gui.FaText(71, 158 + pos_list_l, fa.ANGLE_RIGHT, fa_font[3], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		if imgui.IsMouseReleased(0) then
			edit_name_folder = false
			save_cmd()
		end
		if not edit_all_cmd then
			imgui.SetCursorPos(imgui.ImVec2(88, 157 + pos_list_l))
			if imgui.InvisibleButton(u8'##Добавить новую личную папку', imgui.ImVec2(20, 19)) then
				table.insert(cmd[2], {u8'Новая папка ' .. tostring(#cmd[2] - 6), false})
				edit_name_folder = true
				focus_input_bool = true
				scroll_input_bool = true
				save_cmd()
			end
			if imgui.IsItemActive() then
				gui.DrawCircle({91 + 7, 157.5 + pos_list_l + 8.5}, 11, color_ItemActive)
			elseif imgui.IsItemHovered() then
				gui.DrawCircle({91 + 7, 157.5 + pos_list_l + 8.5}, 11, color_ItemHovered)
			end
			gui.FaText(91, 158 + pos_list_l, fa.PLUS, fa_font[3], cl.def)
		end
		
		if int_cmd.group[3] then
			if #cmd[2] == 7 then
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				end
				gui.Text(36, 184 + pos_list_l, 'Пусто', font[3])
				imgui.PopStyleColor(1)
			else
				for f = 8, #cmd[2] do
					if folder_list_defoult(
						u8:decode(cmd[2][f][1]),
						{ICON_FOLDER = fa.FOLDER, SDVIG = {-2, 0}},
						f,
						3.6 + (f - 5) + ps[1] + ps[2]
					) then break end
				end
			end
		end
		
		imgui.Dummy(imgui.ImVec2(0, 14))
		
		imgui.EndChild()
		
		imgui.SetCursorPos(imgui.ImVec2(226, 39))
		imgui.BeginChild(u8'Список команд', imgui.ImVec2(620, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
		imgui.Scroller(u8'Список команд', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
		
		local function search_for_matches(sought_after, match_text)
			local result_match = false
			
			sought_after = to_lowercase(sought_after)
			match_text = to_lowercase(match_text)
			
			sought_after = sought_after:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')
			
			if match_text:find(sought_after) then
				result_match = true
			end

			return result_match
		end
		
		local presence_of_a_team = false
		if #cmd[1] ~= 0 then
			local pos_i = 0
			for i = 1, #cmd[1] do
				if cmd[1][i].folder == int_cmd.folder or int_cmd.folder == 1 then
					if search_cmd ~= '' then
						if not search_for_matches(u8:decode(search_cmd), cmd[1][i].cmd .. ' ' .. u8:decode(cmd[1][i].desc)) then
							goto continue_at_end_of_cmd_loop
						end
					end
					
					presence_of_a_team = true
					pos_i = pos_i + 1
					local pl_y = pos_i * 55
					
					if pos_i < 10 then
						gui.Text(5, -37 + pl_y, tostring(pos_i), font[2])
					elseif pos_i >= 10 and pos_i < 100 then
						gui.Text(2, -37 + pl_y, tostring(pos_i), font[2])
					elseif pos_i >= 100 then
						gui.Text(1, -37 + pl_y, tostring(pos_i), font[1])
					end
					
					if an[12][2] ~= 0 and an[12][1] == i then
						imgui.SetCursorPos(imgui.ImVec2(556, -39 + pl_y))
						if imgui.InvisibleButton(u8'DEL_CMD '.. i, imgui.ImVec2(45, 45)) then
							cmd_del_i = i
							imgui.OpenPopup(u8'Подтверждение удаления команды2' .. i)
						end
						
						if imgui.IsItemActive() then
							gui.Draw({556, -39 + pl_y}, {45, 45}, imgui.ImVec4(1.00, 0.13, 0.19, 1.00), 6, 10)
						else
							gui.Draw({556, -39 + pl_y}, {45, 45}, imgui.ImVec4(1.00, 0.23, 0.19, 1.00), 6, 10)
						end
						imgui.SetCursorPos(imgui.ImVec2(511, -39 + pl_y))
						if imgui.InvisibleButton(u8'EDIT_CMD '.. i, imgui.ImVec2(45, 45)) then
							edit_tab_cmd = true
							bl_cmd = deepcopy(cmd[1][i])
							cmd_memory = bl_cmd.cmd
							type_cmd = i
							an[12][2] = 0
							an[12][3] = false
						end
						if imgui.IsItemActive() then
							gui.Draw({511, -39 + pl_y}, {45, 45}, imgui.ImVec4(1.00, 0.48, 0.00, 1.00), 0, 0)
						else
							gui.Draw({511, -39 + pl_y}, {45, 45}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 0, 0)
						end
						imgui.SetCursorPos(imgui.ImVec2(466, -39 + pl_y))
						if imgui.InvisibleButton(u8'START_CMD '.. i, imgui.ImVec2(45, 45)) then
							an[12][2] = 0
							an[12][3] = false
							cmd_start('', tostring(cmd[1][i].UID) .. cmd[1][i].cmd)
						end
						if imgui.IsItemActive() then
							gui.Draw({466, -39 + pl_y}, {45, 45}, imgui.ImVec4(0.19, 0.59, 0.78, 1.00), 0, 0)
						else
							gui.Draw({466, -39 + pl_y}, {45, 45}, imgui.ImVec4(0.19, 0.69, 0.78, 1.00), 0, 0)
						end
						gui.FaText(571, -26 + pl_y, fa.TRASH, fa_font[4], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.FaText(525, -25 + pl_y, fa.PEN_RULER, fa_font[4], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.FaText(480, -25 + pl_y, fa.CIRCLE_PLAY, fa_font[4], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
					end
					local del_cmd = false
					if imgui.BeginPopupModal(u8'Подтверждение удаления команды2' .. i, null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
						imgui.SetCursorPos(imgui.ImVec2(10, 10))
						if imgui.InvisibleButton(u8'##Закрыть окно удаления команды', imgui.ImVec2(16, 16)) then
							imgui.CloseCurrentPopup()
						end
						imgui.SetCursorPos(imgui.ImVec2(16, 16))
						local p = imgui.GetCursorScreenPos()
						if imgui.IsItemHovered() then
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
						else
							imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
						end
						gui.DrawLine({10, 31}, {346, 31}, cl.line)
						imgui.SetCursorPos(imgui.ImVec2(6, 40))
						imgui.BeginChild(u8'Подтверждение удаления команды ', imgui.ImVec2(261, 90), false, imgui.WindowFlags.NoScrollbar)
						
						gui.Text(25, 5, 'Вы уверены, что хотите удалить \n                     команду?', font[3])
						if gui.Button(u8'Удалить', {24, 50}, {90, 27}) then
							if #cmd[1][cmd_del_i].key[2] ~= 0 then
								rkeys.unRegisterHotKey(cmd[1][cmd_del_i].key[2])
								for ke = 1, #all_keys do
									if table.concat(all_keys[ke], ' ') == table.concat(cmd[1][cmd_del_i].key[2], ' ') then
										table.remove(all_keys, ke)
									end
								end
							end
							if cmd[1][cmd_del_i].cmd ~= '' then
								sampUnregisterChatCommand(cmd[1][cmd_del_i].cmd)
							end
							table.remove(cmd[1], cmd_del_i)
							an[12][2] = 0
							an[12][3] = false
							save_cmd()
							add_cmd_in_all_cmd()
							del_cmd = true
							imgui.CloseCurrentPopup()
						end
						if gui.Button(u8'Отмена', {141, 50}, {90, 27}) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndChild()
						imgui.EndPopup()
					end
					if del_cmd then break end
						
					local pl_x = 0
					if an[12][1] == i then
						pl_x = an[12][2]
					end
					imgui.SetCursorPos(imgui.ImVec2(16 + pl_x + an[13], -39 + pl_y))
					if imgui.InvisibleButton(u8'SEL_CMD '.. i, imgui.ImVec2(586, 45)) then
						if an[13] == 0 then
							if an[12][1] ~= i then
								an[12][3] = true
								an[12][2] = 0
							else
								an[12][3] = not an[12][3]
							end
							an[12][1] = i
						end
					end
					if not imgui.IsItemHovered() and imgui.IsMouseReleased(0) and an[12][1] == i then
						an[12][3] = false
					end
					if an[12][1] == i and an[12][3] then
						gui.Draw({16 + pl_x, -39 + pl_y}, {586, 45}, cl.tab, 5, 5)
					else
						if edit_all_cmd and #table_select_cmd ~= 0 then
							local bool_sdf = false
							for h = 1, #table_select_cmd do
								if table_select_cmd[h] == i then
									bool_sdf = true
								end
							end
							if bool_sdf then
								gui.Draw({16 + pl_x, -39 + pl_y}, {586, 45}, cl.bg, 5, 15)
							else
								gui.Draw({16 + pl_x, -39 + pl_y}, {586, 45}, cl.tab, 5, 15)
							end
						else
							gui.Draw({16 + pl_x, -39 + pl_y}, {586, 45}, cl.tab, 5, 15)
						end
					end
					if an[13] > 0 then
						imgui.SetCursorPos(imgui.ImVec2(16, -39 + pl_y))
						if imgui.InvisibleButton(u8'CHECK_CMD '.. i, imgui.ImVec2(38, 45)) then
							if #table_select_cmd ~= 0 then
								local remove_bool_comp = 0
								for h = 1, #table_select_cmd do
									if table_select_cmd[h] == i then
										remove_bool_comp = h
										break
									end
								end
								if remove_bool_comp == 0 then
									table.insert(table_select_cmd, i)
								else
									table.remove(table_select_cmd, remove_bool_comp)
								end
							else
								table.insert(table_select_cmd, i)
							end
						end
					end
					if cmd[1][i].cmd ~= '' then
						gui.Text(26 + pl_x + an[13], -33 + pl_y, '/' .. u8:decode(cmd[1][i].cmd), font[3])
					else
						gui.Text(26 + pl_x + an[13], -33 + pl_y, 'Без назначенной команды', font[3])
					end
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
					if cmd[1][i].desc ~= '' and cmd[1][i].desc ~= ' ' then
						gui.Text(26 + pl_x + an[13], -16 + pl_y, u8:decode(cmd[1][i].desc), font[2])
					else
						gui.Text(26 + pl_x + an[13], -16 + pl_y, 'Без описания', font[2])
					end
					if an[12][1] == i then
						if an[12][2] > -136 and an[12][3] then
							an[12][2] = an[12][2] - (anim * 900)
						elseif an[12][2] <= -136 and an[12][3] then
							an[12][2] = -136
						elseif an[12][2] < 0 then
							an[12][2] = an[12][2] + (anim * 900)
						elseif an[12][2] >= 0 then
							an[12][2] = 0
						end
					end
					imgui.PopStyleColor(1)
					
					if edit_all_cmd then
						gui.DrawCircleEmp({35, -17 + pl_y}, 9, cl.bg2, 2)
						if #table_select_cmd ~= 0 then
							for h = 1, #table_select_cmd do
								if table_select_cmd[h] == i then
									gui.FaText(29, -24 + pl_y, fa.CHECK, fa_font[2])
								end
							end
						end
						
						if an[13] < 30 then
							an[13] = an[13] + (anim * 200)
						else
							an[13] = 30
						end
					else
						if an[13] > 0 then
							an[13] = an[13] - (anim * 200)
						else
							an[13] = 0
						end
					end
				end
				
				::continue_at_end_of_cmd_loop::
			end
			imgui.Dummy(imgui.ImVec2(0, 20))
		end
		
		if not presence_of_a_team then
			edit_all_cmd = false
			if setting.cl == 'White' then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
			else
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
			end
			gui.Text(262, 165, 'Пусто', bold_font[3])
			imgui.PopStyleColor(1)
		end
		
		imgui.EndChild()
		hovered_bool_not_child = imgui.IsItemHovered()
	else
		imgui.SetCursorPos(imgui.ImVec2(4, 39))
		imgui.BeginChild(u8'Редактор команд', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoScrollWithMouse)
		imgui.Scroller(u8'Редактор команд', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
		
		--> Основные настройки команды
		gui.DrawBox({16, 16}, {396, 113}, cl.tab, cl.line, 7, 15)
		gui.DrawBox({428, 16}, {396, 113}, cl.tab, cl.line, 7, 15)
		
		gui.Text(26, 26, 'Команда', font[3])
		bl_cmd.cmd = gui.InputText({191, 28}, 200, bl_cmd.cmd, u8'Установка команды', 30, u8'Введите команду', 'en')
		gui.DrawLine({16, 53}, {412, 53}, cl.line)
		gui.Text(26, 64, 'Описание', font[3])
		bl_cmd.desc = gui.InputText({191, 66}, 200, bl_cmd.desc, u8'Описание команды', 150, u8'Введите описание команды')
		gui.DrawLine({16, 91}, {412, 91}, cl.line)
		if bl_cmd.key[1] == '' then
			gui.Text(26, 102, 'Клавиша активации - Отсутствует', font[3])
		else
			gui.Text(26, 102, 'Клавиша активации - ' .. bl_cmd.key[1], font[3])
		end
		
		if gui.Button(u8'Назначить...', {301, 98}, {100, 25}) then
			imgui.OpenPopup(u8'Назначить клавишу активации в редакторе команд')
			current_key = {'', {}}
			lockPlayerControl(true)
			edit_key = true
			key_bool_cur = bl_cmd.key[2]
		end
		local bool_result = key_edit(u8'Назначить клавишу активации в редакторе команд', bl_cmd.key)
		if bool_result[1] then
			bl_cmd.key = bool_result[2]
		end
		gui.Text(438, 26, 'Доступ к команде', font[3])
		bl_cmd.rank = gui.Counter({799, 26}, u8'С ' .. bl_cmd.rank .. u8' ранга', bl_cmd.rank, 1, 10, u8'Доступ ранга для команды')
		gui.DrawLine({428, 56}, {824, 56}, cl.line)
		gui.Text(438, 64, 'Папка хранения', font[3])
		local table_all_folder = {}
		for f = 1, #cmd[2] do
			if f <= 7 then
				table.insert(table_all_folder, u8(cmd[2][f][1]))
			else
				table.insert(table_all_folder, cmd[2][f][1])
			end
		end
		bl_cmd.folder = gui.ListTableMove({794, 64}, table_all_folder, bl_cmd.folder, 'Select Folder')
		gui.DrawLine({428, 91}, {824, 91}, cl.line)
		gui.Text(438, 102, 'Отправлять последнее сообщение в чат', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 98))
		if gui.Switch(u8'##Последнее сообщение в чат', bl_cmd.send_end_mes) then
			bl_cmd.send_end_mes = not bl_cmd.send_end_mes
		end
		
		gui.DrawBox({16, 145}, {808, 37}, cl.tab, cl.line, 7, 15)
		gui.Text(26, 155, 'Задержка проигрывания отыгровки', font[3])
		local bool_delay = imgui.new.float(bl_cmd.delay)
		bl_cmd.delay = gui.SliderBar('##Прозрачность текста', bool_delay, 0.5, 20, 180, {643, 152})
		bl_cmd.delay = round(bl_cmd.delay, 0.1)
		gui.Text(575, 155, tostring(bl_cmd.delay) .. ' сек.', font[3])
		
		local pixel_y_arg = #bl_cmd.arg * 72
		local pixel_y_var = #bl_cmd.var * 36
		if pixel_y_arg > pixel_y_var or pixel_y_arg == pixel_y_var then
			pxl = pixel_y_arg
		else
			pxl = pixel_y_var
		end
		gui.Text(25, 201, 'Аргументы', bold_font[1])
		gui.DrawBox({16, 226}, {396, 43 + pixel_y_arg}, cl.tab, cl.line, 7, 15)
		if #bl_cmd.arg <= 7 then
			if gui.Button(u8'Добавить аргумент', {140, 234 + pixel_y_arg}, {148, 27}) then
				table.insert(bl_cmd.arg, {name = 'arg' .. (#bl_cmd.arg + 1), desc = u8'Аргумент ' .. tostring(#bl_cmd.arg + 1), type = 1})
			end
		else
			gui.Button(u8'Добавить аргумент##неактив', {140, 234 + pixel_y_arg}, {148, 27}, false)
		end
		
		if #bl_cmd.arg ~= 0 then
			for arg = 1, #bl_cmd.arg do
				local y_arg = (arg * 72)
				gui.Text(26, 163 + y_arg, 'Имя', font[3])
				bl_cmd.arg[arg].name = gui.InputText({66, 165 + y_arg}, 110, bl_cmd.arg[arg].name, u8'Имя аргумента' .. arg, 20, u8'Имя аргумента', 'esp')
				bl_cmd.arg[arg].type = gui.ListTableMove({362, 163 + y_arg}, {u8'Тип: текстовый', u8'Тип: числовой'}, bl_cmd.arg[arg].type, 'Select Type' .. arg)
				gui.Text(26, 197 + y_arg, 'Предназначение', font[3])
				bl_cmd.arg[arg].desc = gui.InputText({149, 199 + y_arg}, 223, bl_cmd.arg[arg].desc, u8'Предназначение аргумента' .. arg, 60, u8'Текст')
				
				imgui.SetCursorPos(imgui.ImVec2(389, 180 + y_arg))
				if imgui.InvisibleButton(u8'##Удалить аргумент' .. arg, imgui.ImVec2(21, 20)) then
					table.remove(bl_cmd.arg, arg)
					break
				end
				local an_arg = 0
				if imgui.IsItemActive() then
					if an[9][3] < 0.45 then
						an[9][3] = an[9][3] + (anim * 1.3)
					end
					an[9][4] = arg
					if an[9][4] == arg then
						an_arg = an[9][3]
					end
				elseif imgui.IsItemHovered() then
					if an[9][3] < 0.45 then
						an[9][3] = an[9][3] + (anim * 1.3)
					end
					if an[9][4] == arg then
						an_arg = an[9][3]
					else
						an[9][4] = arg
						an[9][3] = 0
					end
				elseif an[9][4] == arg then
					if an[9][3] > 0 then
						an[9][3] = an[9][3] - (anim * 1.3)
					end
					an_arg = an[9][3]
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an_arg, 0.50 - an_arg, 0.50 - an_arg, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an_arg, 0.50 + an_arg, 0.50 + an_arg, 1.00))
				end
				gui.FaText(391, 181 + y_arg, fa.CIRCLE_XMARK, fa_font[4])
				imgui.PopStyleColor(1)
				
				gui.Text(5, 181 + y_arg, tostring(arg), font[2])
				gui.DrawLine({16, 225 + y_arg}, {412, 225 + y_arg}, cl.line)
			end
		end
		
		gui.Text(437, 201, 'Переменные', bold_font[1])
		gui.DrawBox({428, 226}, {396, 43 + pixel_y_var}, cl.tab, cl.line, 7, 15)
		if gui.Button(u8'Добавить переменную', {542, 234 + pixel_y_var}, {168, 27}) then
			table.insert(bl_cmd.var, {name = 'var' .. (#bl_cmd.var + 1), value = ''})
		end
		
		if #bl_cmd.var ~= 0 then
			for var = 1, #bl_cmd.var do
				local y_var = (var * 36)
				gui.Text(438, 199 + y_var, 'Имя', font[3])
				bl_cmd.var[var].name = gui.InputText({478, 201 + y_var}, 100, bl_cmd.var[var].name, u8'Имя переменной' .. var, 20, u8'Имя переменной', 'esp')
				gui.Text(614, 199 + y_var, 'Значение', font[3])
				bl_cmd.var[var].value = gui.InputText({689, 201 + y_var}, 100, bl_cmd.var[var].value, u8'Значение переменной' .. var, 200, u8'Значение')
				
				imgui.SetCursorPos(imgui.ImVec2(801, 198 + y_var))
				if imgui.InvisibleButton(u8'##Удалить переменную' .. var, imgui.ImVec2(21, 20)) then
					table.remove(bl_cmd.var, var)
					break
				end
				local an_var = 0
				if imgui.IsItemActive() then
					if an[9][1] < 0.45 then
						an[9][1] = an[9][1] + (anim * 1.3)
					end
					if an[9][2] == var then
						an_var = an[9][1]
					end
				elseif imgui.IsItemHovered() then
					if an[9][1] < 0.45 then
						an[9][1] = an[9][1] + (anim * 1.3)
					end
					if an[9][2] == var then
						an_var = an[9][1]
					else
						an[9][2] = var
						an[9][1] = 0
					end
				elseif an[9][2] == var then 
					if an[9][1] > 0 then
						an[9][1] = an[9][1] - (anim * 1.3)
					end
					an_var = an[9][1]
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an_var, 0.50 - an_var, 0.50 - an_var, 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an_var, 0.50 + an_var, 0.50 + an_var, 1.00))
				end
				gui.FaText(803, 199 + y_var, fa.CIRCLE_XMARK, fa_font[4])
				imgui.PopStyleColor(1)
				
				if var < 10 then
					gui.Text(417, 199 + y_var, tostring(var), font[2])
				else
					gui.Text(413, 199 + y_var, tostring(var), font[2])
				end
				gui.DrawLine({428, 225 + y_var}, {824, 225 + y_var}, cl.line)
			end
		end
		pxl = pxl + 14
		gui.DrawLine({16, 271 + pxl}, {824, 271 + pxl}, cl.line)
		local scroll_pos_y = imgui.GetScrollY()
		if #bl_cmd.act ~= 0 then
			local function anim_vis(i_act)
				local an_act = 0
				if imgui.IsItemActive() then
					if an[10][1] < 0.45 then
						an[10][1] = an[10][1] + (anim * 1.3)
					end
					if an[10][2] == i_act then
						an_act = an[10][1]
					end
				elseif imgui.IsItemHovered() then
					if an[10][1] < 0.45 then
						an[10][1] = an[10][1] + (anim * 1.3)
					end
					if an[10][2] == i_act then
						an_act = an[10][1]
					else
						an[10][2] = i_act
						an[10][1] = 0
					end
				elseif an[10][2] == i_act then 
					if an[10][1] > 0 then
						an[10][1] = an[10][1] - (anim * 1.3)
					end
					an_act = an[10][1]
				end
				
				return an_act
			end
			
			local if_disp = 0
			local bool_y = 0
			local num_el_if = 0
			for i = 1, #bl_cmd.act do
				if if_disp > 168 then
					if_disp = 168
				end
				local optimization
				if (scroll_pos_y - 2000) < pxl and (scroll_pos_y + 2000) > pxl then
					optimization = false
				else
					optimization = true
				end
				if not optimization then
					if i < 10 then
						gui.Text(5, 290 + pxl, tostring(i), font[2])
					elseif i >= 10 and i < 100 then
						gui.Text(2, 290 + pxl, tostring(i), font[2])
					elseif i >= 100 then
						gui.Text(1, 290 + pxl, tostring(i), font[1])
					end
				end
				
				local function remove_action(pixel_y, i_act)
					if not optimization then
						imgui.SetCursorPos(imgui.ImVec2(799, 293 + pixel_y))
						if imgui.InvisibleButton('##DEL' .. i_act, imgui.ImVec2(21, 22)) then
							return true
						end
						local anim_act = anim_vis(i_act)
						if setting.cl == 'White' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - anim_act, 0.50 - anim_act, 0.50 - anim_act, 1.00))
						else
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + anim_act, 0.50 + anim_act, 0.50 + anim_act, 1.00))
						end
						gui.FaText(801, 295 + pixel_y, fa.CIRCLE_XMARK, fa_font[4])
						imgui.PopStyleColor(1)
						
						return false
					end
				end
				
				local function add_action_other(pos_but_action, i_act)
					imgui.SetCursorPos(imgui.ImVec2(20, pos_but_action))
					if imgui.InvisibleButton('NEW_ACT' .. i_act, imgui.ImVec2(800, 16)) then
						number_i_cmd = i_act
						imgui.OpenPopup(u8'Добавление действия')
					end
					if imgui.IsItemHovered() then
						if i_act ~= an[11][1] then
							an[11][1] = i_act
							an[11][2] = 0
						end
						if i_act == an[11][1] then
							an[11][2] = an[11][2] + (anim * 5)
						end
					elseif not imgui.IsItemHovered() and i_act == an[11][1] then
						an[11][1] = 0
					end
					if imgui.IsItemActive() and i_act == an[11][1] and an[11][2] > 1.5 then
						if setting.cl == 'White' then
							gui.Draw({20, pos_but_action - 1}, {800, 14}, imgui.ImVec4(0.75, 0.75, 0.75, 1.00), 0, 15)
						else
							gui.Draw({20, pos_but_action - 1}, {800, 14}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 0, 15)
						end
						gui.Text(307, pos_but_action, 'Добавить новое действие в это место', font[3])
						gui.FaText(287, pos_but_action + 1, fa.CIRCLE_PLUS, fa_font[2], imgui.ImVec4(0.30, 0.75, 0.39, 1.00))
					elseif imgui.IsItemHovered() and i_act == an[11][1] and an[11][2] > 1.5 then
						if setting.cl == 'White' then
							gui.Draw({20, pos_but_action + 1}, {800, 14}, imgui.ImVec4(0.80, 0.80, 0.80, 1.00), 0, 15)
						else
							gui.Draw({20, pos_but_action + 1}, {800, 14}, imgui.ImVec4(0.25, 0.25, 0.25, 1.00), 0, 15)
						end
						gui.Text(307, pos_but_action, 'Добавить новое действие в это место', font[3])
						gui.FaText(287, pos_but_action + 1, fa.CIRCLE_PLUS, fa_font[2], imgui.ImVec4(0.30, 0.75, 0.39, 1.00))
					end
				end
				
				local bool_if_line = false
				
				if if_disp > 0 then
					for y = 1, (if_disp / 24) do
						if (i - 1) ~= 0 then
							if bl_cmd.act[i - 1][1] == 'IF' then
								bool_if_line = true
							end
						end
						if y ~= (if_disp / 24) and bool_if_line then
							bool_if_line = false
						end
						if num_el_if >= 7 then
							bool_if_line = false
						end
						if not bool_if_line then
							gui.DrawLine({24 + ((y - 1) * 24), 319 + bool_y}, {24 + ((y - 1) * 24), 319 + pxl}, cl.line, 2)
						elseif bl_cmd.act[i - 1][2] == 1 then
							gui.DrawLine({24 + ((y - 1) * 24), 319 + bool_y}, {24 + ((y - 1) * 24), 319 + pxl}, cl.line, 2)
						else
							gui.DrawLine({24 + ((y - 1) * 24), 319 + bool_y + 36}, {24 + ((y - 1) * 24), 319 + pxl}, cl.line, 2)
						end
					end
				end
				bool_y = pxl
				
				if bl_cmd.act[i][1] == 'SEND' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 61}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23 + 1 + if_disp, 295 + pxl, fa.SHARE, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Отправить сообщение в чат', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						if gui.Button(u8'Вставить тег...##' .. i, {701, 323 + pxl}, {112, 23}) then
							popup_open_tags = true
							insert_tag_popup[3] = true
							insert_tag_popup[1] = i
						end
						
						imgui.PushFont(font[3])
						if insert_tag_popup[1] == i and not insert_tag_popup[3] then
							if bl_cmd.act[i][2] ~= '' then
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. ' ' .. insert_tag_popup[2]
							else
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. insert_tag_popup[2]
							end
							insert_tag_popup[1] = 0
							insert_tag_popup[2] = ''
						end
						local txt_inp_buf = imgui.new.char[600](bl_cmd.act[i][2])
						imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.30, 0.30, 0.30, 0.00))
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PushItemWidth(662 - if_disp)
						imgui.InputText('##SEND_CHAT' .. i, txt_inp_buf, ffi.sizeof(txt_inp_buf))
						if bl_cmd.act[i][2] == '' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
							gui.Text(29 + if_disp, 326 + pxl, 'Текст', font[3])
							imgui.PopStyleColor(1)
						end
						imgui.PopItemWidth()
						bl_cmd.act[i][2] = ffi.string(txt_inp_buf)
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PopFont()
					end
					
					pxl = pxl + 77
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'OPEN_INPUT' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 61}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(1.00, 0.30, 0.00, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23 + if_disp, 295 + pxl, fa.KEYBOARD, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Открыть игровой чат с текстом', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						if gui.Button(u8'Вставить тег...##' .. i, {701, 323 + pxl}, {112, 23}) then
							popup_open_tags = true
							insert_tag_popup[3] = true
							insert_tag_popup[1] = i
						end
						
						imgui.PushFont(font[3])
						if insert_tag_popup[1] == i and not insert_tag_popup[3] then
							if bl_cmd.act[i][2] ~= '' then
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. ' ' .. insert_tag_popup[2]
							else
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. insert_tag_popup[2]
							end
							insert_tag_popup[1] = 0
							insert_tag_popup[2] = ''
						end
						local txt_inp_buf = imgui.new.char[600](bl_cmd.act[i][2])
						imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.30, 0.30, 0.30, 0.00))
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PushItemWidth(662 - if_disp)
						imgui.InputText('##OPEN_CHAT_TEXT' .. i, txt_inp_buf, ffi.sizeof(txt_inp_buf))
						if bl_cmd.act[i][2] == '' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
							gui.Text(29 + if_disp, 326 + pxl, 'Текст', font[3])
							imgui.PopStyleColor(1)
						end
						imgui.PopItemWidth()
						bl_cmd.act[i][2] = ffi.string(txt_inp_buf)
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PopFont()
					end
					
					pxl = pxl + 77
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'WAIT_ENTER' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 31}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.30, 0.75, 0.39, 1.00), 3, 15)
						gui.FaText(23 + 3 + if_disp, 295 + pxl, fa.HOURGLASS, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Ожидание нажатия клавиши Enter', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
					end
					
					pxl = pxl + 47
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'SEND_ME' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 61}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23  + if_disp, 295 + pxl, fa.SHARE_FROM_SQUARE, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Вывести в чат информацию для себя', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						if gui.Button(u8'Вставить тег...##' .. i, {701, 323 + pxl}, {112, 23}) then
							popup_open_tags = true
							insert_tag_popup[3] = true
							insert_tag_popup[1] = i
						end
						
						if insert_tag_popup[1] == i and not insert_tag_popup[3] then
							if bl_cmd.act[i][2] ~= '' then
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. ' ' .. insert_tag_popup[2]
							else
								bl_cmd.act[i][2] = bl_cmd.act[i][2] .. insert_tag_popup[2]
							end
							insert_tag_popup[1] = 0
							insert_tag_popup[2] = ''
						end
						
						imgui.PushFont(font[3])
						local txt_inp_buf = imgui.new.char[600](bl_cmd.act[i][2])
						imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.30, 0.30, 0.30, 0.00))
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PushItemWidth(662 - if_disp)
						imgui.InputText('##SEND_CHAT' .. i, txt_inp_buf, ffi.sizeof(txt_inp_buf))
						if bl_cmd.act[i][2] == '' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
							gui.Text(29 + if_disp, 326 + pxl, 'Текст', font[3])
							imgui.PopStyleColor(1)
						end
						imgui.PopItemWidth()
						bl_cmd.act[i][2] = ffi.string(txt_inp_buf)
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(27, 326 + pxl))
						imgui.PopFont()
					end
					
					pxl = pxl + 77
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'NEW_VAR' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 65}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.00, 0.48, 1.00, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23 + if_disp, 295 + pxl, fa.SQUARE_ROOT_VARIABLE, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Задать для переменной', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						gui.Text(26 + if_disp, 328 + pxl, 'Имя переменной', font[3])
						bl_cmd.act[i][2] = gui.InputText({154 + if_disp, 330 + pxl}, 120, bl_cmd.act[i][2], u8'Имя var' .. i, 20, u8'Имя переменной', 'esp')
						gui.Text(500, 328 + pxl, 'Значение', font[3])
						bl_cmd.act[i][3] = gui.InputText({577, 330 + pxl}, 227, bl_cmd.act[i][3], u8'Значение var' .. i, 200, u8'Значение переменной')
					end
					
					pxl = pxl + 81
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'DIALOG' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 99 + (#bl_cmd.act[i][3] * 34)}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.69, 0.32, 0.87, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23 + 1 + if_disp, 295 + pxl, fa.BARS_STAGGERED, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Диалог выбора дальнейшего действия', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						gui.Text(26 + if_disp, 328 + pxl, 'Имя диалога', font[3])
						bl_cmd.act[i][2] = gui.InputText({123 + if_disp, 330 + pxl}, 120, bl_cmd.act[i][2], u8'Имя диалога' .. i, 20, u8'Имя диалога', 'esp')
						gui.DrawLine({16 + if_disp, 353 + pxl}, {824, 353 + pxl}, cl.line)
					end
						for vr = 1, #bl_cmd.act[i][3] do
							if not optimization then
								local txt_inp_buf = imgui.new.char[60](bl_cmd.act[i][3][vr])
								imgui.SetCursorPos(imgui.ImVec2(50 + if_disp, 362 + pxl))
								imgui.PushItemWidth(763 - if_disp)
								imgui.InputText('##BOOL_DIALOG' .. i .. vr, txt_inp_buf, ffi.sizeof(txt_inp_buf))
								if bl_cmd.act[i][3][vr] == '' then
									imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
									gui.Text(52 + if_disp, 362 + pxl, 'Текст варианта', font[3])
									imgui.PopStyleColor(1)
								end
								imgui.PopItemWidth()
								bl_cmd.act[i][3][vr] = ffi.string(txt_inp_buf)
								imgui.SetCursorPos(imgui.ImVec2(24 + if_disp, 358 + pxl))
								if imgui.InvisibleButton('DEL_OPTION' .. i .. vr, imgui.ImVec2(23, 23)) then
									table.remove(bl_cmd.act[i][3], vr)
									break
								end
								if imgui.IsItemActive() then
									gui.FaText(27 + if_disp, 361 + pxl, fa.CIRCLE_MINUS, fa_font[4], imgui.ImVec4(1.00, 0.09, 0.19, 1.00))
								else
									gui.FaText(27 + if_disp, 361 + pxl, fa.CIRCLE_MINUS, fa_font[4], imgui.ImVec4(1.00, 0.23, 0.19, 1.00))
								end
								gui.DrawLine({16 + if_disp, 387 + pxl}, {824, 387 + pxl}, cl.line)
							end
							pxl = pxl + 34
						end
					if not optimization then
						if #bl_cmd.act[i][3] <= 9 then
							imgui.SetCursorPos(imgui.ImVec2(23 + if_disp, 358 + pxl))
							if imgui.InvisibleButton('NEW_OPTION' .. i, imgui.ImVec2(196, 23)) then
								table.insert(bl_cmd.act[i][3], '')
							end
							if imgui.IsItemActive() then
								if setting.cl == 'White' then
									gui.Draw({23 + if_disp, 358 + pxl}, {196, 23}, imgui.ImVec4(0.75, 0.75, 0.75, 1.00), 7, 15)
								else
									gui.Draw({23 + if_disp, 358 + pxl}, {196, 23}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 7, 15)
								end
							elseif imgui.IsItemHovered() then
								if setting.cl == 'White' then
									gui.Draw({23 + if_disp, 358 + pxl}, {196, 23}, imgui.ImVec4(0.80, 0.80, 0.80, 1.00), 7, 15)
								else
									gui.Draw({23 + if_disp, 358 + pxl}, {196, 23}, imgui.ImVec4(0.25, 0.25, 0.25, 1.00), 7, 15)
								end
							end
							gui.Text(52 + if_disp, 362 + pxl, 'Добавить новый вариант', font[3])
							gui.FaText(27 + if_disp, 361 + pxl, fa.CIRCLE_PLUS, fa_font[4], imgui.ImVec4(0.30, 0.75, 0.39, 1.00))
						else
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
							gui.Text(52 + if_disp, 362 + pxl, 'Добавить новый вариант', font[3])
							imgui.PopStyleColor(1)
							gui.FaText(27 + if_disp, 361 + pxl, fa.CIRCLE_PLUS, fa_font[4], imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
						end
					end
					
					pxl = pxl + 115
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'IF' then
					local param_plus = 0
					if bl_cmd.act[i][2] ~= 1 then
						param_plus = 36
					end
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 31 + param_plus}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.56, 0.56, 0.58, 1.00), 3, 15)
						gui.FaText(23 + 2 + if_disp, 295 + pxl, fa.ARROWS_CROSS, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Если', font[3])
						if bl_cmd.act[i][2] ~= 1 then
							gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						end
						
						if remove_action(pxl, i) then
							local remove_array = {i}
							for j = 1, #bl_cmd.act do
								if bl_cmd.act[j][1] == 'ELSE' then
									if bl_cmd.act[j][2] == bl_cmd.act[i][4] then
										table.insert(remove_array, j)
									end
								elseif bl_cmd.act[j][1] == 'END' then
									if bl_cmd.act[j][2] == bl_cmd.act[i][4] then
										table.insert(remove_array, j)
									end
								end
							end
							table.sort(remove_array, function(a, b) return a > b end)
							for _, index in ipairs(remove_array) do
								table.remove(bl_cmd.act, index)
							end
							break
						end
						
						local param_edit = bl_cmd.act[i][2]
						bl_cmd.act[i][2] = gui.ListTableMove({265 + if_disp, 295 + pxl}, {u8'Входные данные', u8'В диалоге выбран вариант', u8'Сравнение аргумента', u8'Сравнение переменной'}, bl_cmd.act[i][2], 'Select if' .. i)
						if param_edit ~= bl_cmd.act[i][2] then
							if bl_cmd.act[i][2] == 2 then
								bl_cmd.act[i][3] = {'', '1'}
							else
								bl_cmd.act[i][3] = {'', ''}
							end
						end
						
						if bl_cmd.act[i][2] == 2 then
							gui.Text(26 + if_disp, 329 + pxl, 'Имя диалога', font[3])
							bl_cmd.act[i][3][1] = gui.InputText({127 + if_disp, 331 + pxl}, 120, bl_cmd.act[i][3][1], u8'Имя диалога' .. i, 20, u8'Имя диалога', 'esp')
							gui.Text(300 + if_disp, 329 + pxl, 'Выбранный вариант', font[3])
							local param_opt = tonumber(bl_cmd.act[i][3][2])
							param_opt = gui.Counter({460 + if_disp, 329 + pxl}, tostring(param_opt), param_opt, 1, 99, u8'Выбранный вариант' .. i)
							bl_cmd.act[i][3][2] = tostring(param_opt)
						elseif bl_cmd.act[i][2] == 3 then
							gui.Text(26 + if_disp, 329 + pxl, 'Имя аргумента', font[3])
							bl_cmd.act[i][3][1] = gui.InputText({139 + if_disp, 331 + pxl}, 120, bl_cmd.act[i][3][1], u8'Имя аргумента ' .. i, 20, u8'Имя аргумента', 'esp')
							gui.Text(389 + if_disp, 329 + pxl, 'Значение', font[3])
							bl_cmd.act[i][3][2] = gui.InputText({467 + if_disp, 331 + pxl}, 336 - if_disp, bl_cmd.act[i][3][2], u8'Значение равенства arg' .. i, 500, u8'Значение')
							bl_cmd.act[i][5] = gui.ListTableMove({600 + if_disp, 295 + pxl}, {u8'Аргумент равен', u8'Аргумент больше, чем значение', u8'Аргумент больше или равняется значению', u8'Аргумент меньше значения', u8'Аргумент меньше или равняется значению', u8'Аргумент не равен значению'}, bl_cmd.act[i][5], 'Select Equality Values Arg' .. i)
						elseif bl_cmd.act[i][2] == 4 then
							gui.Text(26 + if_disp, 329 + pxl, 'Имя переменной', font[3])
							bl_cmd.act[i][3][1] = gui.InputText({151 + if_disp, 331 + pxl}, 120, bl_cmd.act[i][3][1], u8'Имя переменной ' .. i, 20, u8'Имя переменной', 'esp')
							gui.Text(389 + if_disp, 329 + pxl, 'Значение', font[3])
							bl_cmd.act[i][3][2] = gui.InputText({467 + if_disp, 331 + pxl}, 336 - if_disp, bl_cmd.act[i][3][2], u8'Значение равенства var' .. i, 500, u8'Значение')
							bl_cmd.act[i][5] = gui.ListTableMove({600 + if_disp, 295 + pxl}, {u8'Переменная равна', u8'Переменная больше, чем значение', u8'Переменная больше или равняется значению', u8'Переменная меньше значения', u8'Переменная меньше или равняется значению', u8'Переменная не равна значению'}, bl_cmd.act[i][5], 'Select Equality Values Var' .. i)
						end
					end
					pxl = pxl + 47 + param_plus
					if_disp = if_disp + 24
					num_el_if = num_el_if + 1
					
					
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'ELSE' then
					local bool_if_disp = 0
					if if_disp > 0 and num_el_if <= 7 then
						bool_if_disp = if_disp - 24
					elseif num_el_if > 7 then
						bool_if_disp = 168
					end
					if not optimization then
						gui.DrawBox({16 + bool_if_disp, 288 + pxl}, {808 - bool_if_disp, 31}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + bool_if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.56, 0.56, 0.58, 1.00), 3, 15)
						gui.FaText(23 + 2 + bool_if_disp, 295 + pxl, fa.ARROWS_CROSS, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + bool_if_disp, 295 + pxl, 'Иначе', font[3])
					end
					
					pxl = pxl + 47
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'END' then
					if if_disp > 0 and num_el_if <= 7 then
						if_disp = if_disp - 24
					end
					num_el_if = num_el_if - 1
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 31}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.56, 0.56, 0.58, 1.00), 3, 15)
						gui.FaText(23 + 2 + if_disp, 295 + pxl, fa.ARROWS_CROSS, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Конец условия', font[3])
					end
					
					pxl = pxl + 47
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'STOP' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 31}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(0.56, 0.56, 0.58, 1.00), 3, 15)
						gui.FaText(23 + 1 + if_disp, 295 + pxl, fa.HAND, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Остановить отыгровку', font[3])
						
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
					end
					
					pxl = pxl + 47
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'COMMENT' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 61}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 3, 15)
						gui.DrawLine({16 + if_disp, 319 + pxl}, {824, 319 + pxl}, cl.line)
						gui.FaText(23 + 1 + if_disp, 295 - 1 + pxl, fa.COMMENT, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Комментарий', font[3])
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
						
						imgui.PushFont(font[3])
						local txt_inp_buf = imgui.new.char[600](bl_cmd.act[i][2])
						imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.30, 0.30, 0.30, 0.00))
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PushItemWidth(786 - if_disp)
						imgui.InputText('##COMMENT' .. i, txt_inp_buf, ffi.sizeof(txt_inp_buf))
						if bl_cmd.act[i][2] == '' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
							gui.Text(29 + if_disp, 326 + pxl, 'Текст', font[3])
							imgui.PopStyleColor(1)
						end
						imgui.PopItemWidth()
						bl_cmd.act[i][2] = ffi.string(txt_inp_buf)
						imgui.PopStyleColor(1)
						imgui.SetCursorPos(imgui.ImVec2(27 + if_disp, 326 + pxl))
						imgui.PopFont()
					end
					
					pxl = pxl + 77
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				elseif bl_cmd.act[i][1] == 'DELAY' then
					if not optimization then
						gui.DrawBox({16 + if_disp, 288 + pxl}, {808 - if_disp, 31}, cl.tab, cl.line, 7, 15)
						gui.Draw({21 + if_disp, 293 + pxl}, {21, 21}, imgui.ImVec4(1.00, 0.50, 0.88, 1.00), 3, 15)
						gui.FaText(23 + 1 + if_disp, 295 + pxl, fa.CLOCK_ROTATE_LEFT, fa_font[3], imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
						gui.Text(50 + if_disp, 295 + pxl, 'Изменить задержку проигрывания отыгровки', font[3])
						local bool_new_delay = imgui.new.float(bl_cmd.act[i][2])
						bl_cmd.act[i][2] = gui.SliderBar('##Изменить задержку отыгровки ' .. i, bool_new_delay, 0.5, 20, 180, {618, 292 + pxl})
						delay_act_def = bl_cmd.act[i][2]
						bl_cmd.act[i][2] = round(bl_cmd.act[i][2], 0.1)
						gui.Text(560, 295 + pxl, tostring(bl_cmd.act[i][2]) .. ' сек.', font[3])
						
						if remove_action(pxl, i) then
							table.remove(bl_cmd.act, i)
							break
						end
					end
					
					pxl = pxl + 47
					if not optimization then
						add_action_other(272 + pxl, i)
					end
				end
			end
		end
		
		--> Варианты действий
		local function add_action(NUM_ACTION, FA, TEXT_ACTION)
			pxl = pxl + 37
			local BOOL = false
			
			imgui.SetCursorPos(imgui.ImVec2(260, 333 + pxl))
			if imgui.InvisibleButton(u8'Добавить действие в команде ' .. NUM_ACTION, imgui.ImVec2(320, 27)) then
				bl_cmd.id_element = bl_cmd.id_element + 1
				BOOL = true
			end
			if imgui.IsItemActive() then
				gui.Draw({261, 333 + pxl}, {318, 29}, cl.bg, 3, 15)
			elseif imgui.IsItemHovered() then
				gui.Draw({261, 333 + pxl}, {318, 29}, cl.bg2, 3, 15)
			end
			
			gui.DrawEmp({260, 332 + pxl}, {320, 31}, cl.line, 5, 15, 1)
			gui.Draw({265, 337 + pxl}, {21, 21}, FA.COLOR_BG, 3, 15)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
			gui.FaText(267 + FA.SDVIG[1], 339 + FA.SDVIG[2] + pxl, FA.ICON, fa_font[3])
			imgui.PopStyleColor(1)
			gui.Text(294, 339 + pxl, TEXT_ACTION, font[3])
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
			gui.FaText(560, 339 + pxl, fa.PLUS, fa_font[3])
			imgui.PopStyleColor(1)
			
			return BOOL
		end
		
		if #bl_cmd.act == 0 then
			gui.Text(304, 301 + pxl, 'Варианты первого действия', bold_font[1])
			gui.FaText(523, 302 + pxl, fa.ANGLE_DOWN, fa_font[4])
		else
			gui.Text(286, 301 + pxl, 'Варианты следующего действия', bold_font[1])
			gui.FaText(539, 302 + pxl, fa.ANGLE_DOWN, fa_font[4])
		end
		
		pxl = pxl - 35
		if add_action(1, {ICON = fa.SHARE, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {1, 0}}, 'Отправить сообщение в чат') then
			table.insert(bl_cmd.act, {
				'SEND',
				''
			})
		end
		if add_action(2, {ICON = fa.KEYBOARD, COLOR_BG = imgui.ImVec4(1.00, 0.30, 0.00, 1.00), SDVIG = {0, 0}}, 'Открыть игровой чат с текстом') then
			table.insert(bl_cmd.act, {
				'OPEN_INPUT',
				''
			})
		end
		if add_action(3, {ICON = fa.HOURGLASS, COLOR_BG = imgui.ImVec4(0.30, 0.75, 0.39, 1.00), SDVIG = {3, 0}}, 'Ожидание нажатия Enter') then
			table.insert(bl_cmd.act, {
				'WAIT_ENTER'
			})
		end
		if add_action(4, {ICON = fa.SHARE_FROM_SQUARE, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {0, 0}}, 'Вывести информацию для себя') then
			table.insert(bl_cmd.act, {
				'SEND_ME',
				''
			})
		end
		if add_action(5, {ICON = fa.SQUARE_ROOT_VARIABLE, COLOR_BG = imgui.ImVec4(0.00, 0.48, 1.00, 1.00), SDVIG = {0, 0}}, 'Задать для переменной') then
			table.insert(bl_cmd.act, {
				'NEW_VAR',
				'', --> Имя переменной
				'' --> Значение переменной
			})
		end
		if add_action(6, {ICON = fa.BARS_STAGGERED, COLOR_BG = imgui.ImVec4(0.69, 0.32, 0.87, 1.00), SDVIG = {1, 0}}, 'Диалог выбора действия') then
			table.insert(bl_cmd.act, {
				'DIALOG',
				'', --> Имя диалога
				{'', ''} --> Варианты действий
			})
		end
		if add_action(7, {ICON = fa.ARROWS_CROSS, COLOR_BG = imgui.ImVec4(0.56, 0.56, 0.58, 1.00), SDVIG = {2, 0}}, 'Если') then
			table.insert(bl_cmd.act, {
				'IF',
				1, --> Условие
				{'', ''}, --> Входные данные,
				bl_cmd.id_element,
				1
			})
			table.insert(bl_cmd.act, {
				'ELSE',
				bl_cmd.id_element
			})
			table.insert(bl_cmd.act, {
				'END',
				bl_cmd.id_element
			})
		end
		if add_action(8, {ICON = fa.CLOCK_ROTATE_LEFT, COLOR_BG = imgui.ImVec4(1.00, 0.50, 0.88, 1.00), SDVIG = {1, 0}}, 'Изменить задержку отыгровки') then
			table.insert(bl_cmd.act, {
				'DELAY',
				delay_act_def
			})
		end
		if add_action(9, {ICON = fa.HAND, COLOR_BG = imgui.ImVec4(0.56, 0.56, 0.58, 1.00), SDVIG = {1, 0}}, 'Остановить отыгровку') then
			table.insert(bl_cmd.act, {
				'STOP'
			})
		end
		if add_action(10, {ICON = fa.COMMENT, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {1, -1}}, 'Комментарий') then
			table.insert(bl_cmd.act, {
				'COMMENT',
				''
			})
		end
		
		imgui.Dummy(imgui.ImVec2(0, 17))
		new_action_popup()
		tags_in_cmd()
		imgui.EndChild()
	end
end

function hall.shpora()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Шпаргалки', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'Шпаргалки', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	
	local function accent_col(num_acc, color_acc, color_acc_act)
		imgui.SetCursorPos(imgui.ImVec2(356 + (num_acc * 44), 115))
		local p = imgui.GetCursorScreenPos()
		
		imgui.SetCursorPos(imgui.ImVec2(345 + (num_acc * 44), 105))
		if imgui.InvisibleButton(u8'##Выбор цвета' .. num_acc, imgui.ImVec2(22, 22)) then
			shpora_bool.color = num_acc
		end
		if imgui.IsItemActive() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5),  12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
		end
		if num_acc == shpora_bool.color then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 4, imgui.GetColorU32Vec4(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
		end
	end
		
	if edit_tab_shpora then
		gui.DrawBox({16, 16}, {396, 71}, cl.tab, cl.line, 7, 15)
		gui.DrawBox({428, 16}, {396, 71}, cl.tab, cl.line, 7, 15)
		gui.DrawLine({16, 51}, {412, 51}, cl.line)
		gui.DrawLine({428, 51}, {824, 51}, cl.line)
		
		gui.Text(26, 25, 'Имя шпаргалки', font[3])
		gui.Text(26, 61, 'Команда активации', font[3])
		shpora_bool.name = gui.InputText({191, 26}, 200, shpora_bool.name, u8'Название шпаргалки', 250, u8'Введите имя шпаргалки')
		shpora_bool.cmd = gui.InputText({191, 63}, 200, shpora_bool.cmd, u8'Установка команды шпоре', 30, u8'Введите команду', 'en')
		
		gui.Text(438, 61, 'Значок карточки', font[3])
		gui.FaText(565, 60, all_icon_shpora[shpora_bool.icon], fa_font[4])
		if gui.Button(u8'Выбрать...', {713, 57}, {100, 25}) then
			imgui.OpenPopup(u8'Установить значок карточки в шпорах')
		end
		
		if imgui.BeginPopupModal(u8'Установить значок карточки в шпорах', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно установки значка', imgui.ImVec2(16, 16)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			gui.DrawLine({10, 31}, {239, 31}, cl.line)
			imgui.SetCursorPos(imgui.ImVec2(6, 40))
			imgui.BeginChild(u8'Установка значка в шпорах', imgui.ImVec2(243, 340), false)
			local function auto_ordering_icon(pos_ic_y, table_ic, num_ic_n)
				local bool_proc_y = 0
				local bool_proc_x = 0
				local return_icon = 0
				for i = 1, #table_ic do
					imgui.SetCursorPos(imgui.ImVec2(5 + (bool_proc_x * 48), pos_ic_y - 4 + (45 * bool_proc_y)))
					if imgui.InvisibleButton(u8'##Выбрать значок ' .. pos_ic_y .. i, imgui.ImVec2(30, 30)) then
						return_icon = i + num_ic_n
					end
					if imgui.IsItemHovered() then
						gui.FaText(10 + (bool_proc_x * 48), pos_ic_y + (45 * bool_proc_y), table_ic[i], fa_font[4], cl.def)
					else
						gui.FaText(10 + (bool_proc_x * 48), pos_ic_y + (45 * bool_proc_y), table_ic[i], fa_font[4], imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
					end
					if i % 5 == 0 then
						bool_proc_y = bool_proc_y + 1
						bool_proc_x = 0
					else
						bool_proc_x = bool_proc_x + 1
					end
				end
				
				if return_icon ~= 0 then
					shpora_bool.icon = return_icon
					imgui.CloseCurrentPopup()
				end
			end
			gui.Text(10, 5, 'Предметы', bold_font[1])
			auto_ordering_icon(40, {fa.HOUSE, fa.STAR, fa.USER, fa.MUSIC, fa.GIFT, fa.BOOK, fa.KEY, fa.GLOBE, fa.CODE, fa.COMPASS, fa.LAYER_GROUP, fa.USERS, fa.HEART, fa.CAR, fa.CALENDAR, fa.PLAY, fa.FLAG, fa.BRAIN, fa.ROBOT, fa.WRENCH, fa.INFO, fa.CLOCK, fa.FLOPPY_DISK, fa.CHART_SIMPLE, fa.SHOP, fa.LINK, fa.DATABASE, fa.TAGS, fa.POWER_OFF, fa.HAMMER, fa.SCROLL, fa.CLONE, fa.DICE}, 0)
			gui.Text(10, 355, 'Медицина', bold_font[1])
			auto_ordering_icon(390, {fa.USER_NURSE, fa.HOSPITAL, fa.WHEELCHAIR, fa.TRUCK_MEDICAL, fa.TEMPERATURE_LOW, fa.SYRINGE, fa.HEART_PULSE, fa.BOOK_MEDICAL, fa.BAN, fa.PLUS, fa.NOTES_MEDICAL}, 33)
			gui.Text(10, 525, 'Операционная система', bold_font[1])
			auto_ordering_icon(560, {fa.IMAGE, fa.FILE, fa.TRASH, fa.INBOX, fa.FOLDER, fa.FOLDER_OPEN, fa.COMMENTS, fa.SLIDERS, fa.WIFI, fa.VOLUME_HIGH, fa.UP_DOWN_LEFT_RIGHT, fa.TERMINAL, fa.SUPERSCRIPT}, 44)
			
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		gui.DrawBox({16, 98}, {808, 35}, cl.tab, cl.line, 7, 15)
		gui.Text(26, 107, 'Цвет карточки', font[3])
		accent_col(0, {1.00, 0.62, 0.04}, {1.00, 0.52, 0.04})
		accent_col(1, {1.00, 0.26, 0.23}, {1.00, 0.16, 0.23})
		accent_col(2, {1.00, 0.82, 0.04}, {1.00, 0.72, 0.04})
		accent_col(3, {0.19, 0.80, 0.35}, {0.19, 0.70, 0.35})
		accent_col(4, {0.00, 0.80, 0.76}, {0.00, 0.70, 0.76})
		accent_col(5, {0.04, 0.49, 1.00}, {0.04, 0.39, 1.00})
		accent_col(6, {0.37, 0.35, 0.93}, {0.37, 0.25, 0.93})
		accent_col(7, {0.75, 0.33, 0.95}, {0.75, 0.23, 0.95})
		accent_col(8, {1.00, 0.20, 0.37}, {1.00, 0.10, 0.37})
		accent_col(9, {1.00, 0.55, 0.55}, {1.00, 0.45, 0.55})
		accent_col(10, {0.67, 0.55, 0.41}, {0.67, 0.45, 0.41})
		
		if shpora_bool.key[1] == '' then
			gui.Text(438, 24, 'Клавиша активации - Отсутствует', font[3])
		else
			gui.Text(438, 24, 'Клавиша активации - ' .. shpora_bool.key[1], font[3])
		end
		
		if gui.Button(u8'Назначить...', {713, 21}, {100, 25}) then
			imgui.OpenPopup(u8'Назначить клавишу активации в шпаргалках')
			current_key = {'', {}}
			lockPlayerControl(true)
			edit_key = true
			key_bool_cur = shpora_bool.key[2]
		end
		local bool_result = key_edit(u8'Назначить клавишу активации в шпаргалках', shpora_bool.key)
		if bool_result[1] then
			shpora_bool.key = bool_result[2]
		end
		
		gui.DrawBox({16, 144}, {808, 209}, cl.tab, cl.line, 7, 15)
		
		imgui.SetCursorPos(imgui.ImVec2(21, 149))
		local text_multiline = imgui.new.char[512000](shpora_bool.text)
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
		imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(5, 5))
		imgui.PushFont(font[3])
		imgui.InputTextMultiline('##Окно ввода текста шпаргалки', text_multiline, ffi.sizeof(text_multiline), imgui.ImVec2(803, 205))
		imgui.PopStyleColor()
		imgui.PopStyleVar(1)
		imgui.PopFont()
		shpora_bool.text = ffi.string(text_multiline)
		
		if ffi.string(text_multiline) == '' then
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(26, 154))
			if setting.cl == 'Black' then
				imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.50), u8'Вводите текст')
			else
				imgui.TextColored(imgui.ImVec4(0.00, 0.00, 0.00, 0.50), u8'Вводите текст')
			end
			imgui.PopFont()
		end
	else
		if #setting.shp ~= 0 then
			local bool_shp_x = 0
			local bool_shp_y = 0
			local color_shp = {{1.00, 0.62, 0.04}, {1.00, 0.26, 0.23}, {1.00, 0.82, 0.04}, {0.19, 0.80, 0.35}, {0.00, 0.80, 0.76}, {0.04, 0.49, 1.00}, {0.37, 0.35, 0.93}, {0.75, 0.33, 0.95}, {1.00, 0.20, 0.37}, {1.00, 0.55, 0.55}, {0.67, 0.55, 0.41}}
			for i = 1, #setting.shp do
				if not shp_edit_all[1] then
					local x_sp = (204 * bool_shp_x)
					local y_sp = (108 * bool_shp_y)
					gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_shp[setting.shp[i].color + 1][1], color_shp[setting.shp[i].color + 1][2], color_shp[setting.shp[i].color + 1][3], 1.00), 10, 15)
					imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
					if imgui.InvisibleButton(u8'##Открыть для просмотра шпоры ' .. i, imgui.ImVec2(156, 100)) then
						show_shpora = i
						text_shpora = setting.shp[i].text
						windows.shpora[0] = true
					end
					if imgui.IsItemActive() then
						gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_shp[setting.shp[i].color + 1][1], color_shp[setting.shp[i].color + 1][2] - 0.10, color_shp[setting.shp[i].color + 1][3], 1.00), 10, 15)
					end
					imgui.SetCursorPos(imgui.ImVec2(172 + x_sp, 56 + y_sp))
					if imgui.InvisibleButton(u8'##Открыть для просмотра шпоры 2' .. i, imgui.ImVec2(40, 60)) then
						show_shpora = i
						windows.shpora[0] = true
					end
					if imgui.IsItemActive() then
						gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_shp[setting.shp[i].color + 1][1], color_shp[setting.shp[i].color + 1][2] - 0.10, color_shp[setting.shp[i].color + 1][3], 1.00), 10, 15)
					end
					gui.FaText(26 + x_sp, 26 + y_sp, all_icon_shpora[setting.shp[i].icon], fa_font[5], imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
					imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
					
					imgui.SetCursorPos(imgui.ImVec2(189 + x_sp, 39 + y_sp))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 15, imgui.GetColorU32Vec4(imgui.ImVec4(color_shp[setting.shp[i].color + 1][1], color_shp[setting.shp[i].color + 1][2] + 0.10, color_shp[setting.shp[i].color + 1][3], 1.00)), 60)
					imgui.SetCursorPos(imgui.ImVec2(174 + x_sp, 24 + y_sp))
					if imgui.InvisibleButton(u8'##Открыть для редактирования шпоры ' .. i, imgui.ImVec2(30, 30)) then
						edit_tab_shpora = true
						shpora_bool = setting.shp[i]
						num_shpora = i
						cmd_memory_shpora = setting.shp[i].cmd
					end
					if imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 15, imgui.GetColorU32Vec4(imgui.ImVec4(color_shp[setting.shp[i].color + 1][1], color_shp[setting.shp[i].color + 1][2] + 0.20, color_shp[setting.shp[i].color + 1][3], 1.00)), 60)
					end
					gui.FaText(180 + x_sp, 28 + y_sp, fa.ELLIPSIS, fa_font[5], imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
					if setting.shp[i].name ~= '' then
						local wrapped_text, newline_count = wrapText(u8:decode(setting.shp[i].name), 21, 63)
						gui.Text(26 + x_sp, 91 + y_sp - (newline_count * 17), wrapped_text, bold_font[1])
					else
						gui.Text(26 + x_sp, 91 + y_sp, 'Без названия', bold_font[1])
					end
					imgui.PopStyleColor(1)
					imgui.Dummy(imgui.ImVec2(0, 19))
					
					if i % 4 == 0 then
						bool_shp_y = bool_shp_y + 1
						bool_shp_x = 0
					else
						bool_shp_x = bool_shp_x + 1
					end
				else
					local x_sp = (204 * bool_shp_x)
					local y_sp = (108 * bool_shp_y)
					local select_del = false
					for s = 1, #shp_edit_all[2] do
						if shp_edit_all[2][s] == i then
							select_del = true
							break
						end
					end
					
					if not select_del then
						gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(0.40, 0.40, 0.40, 1.00), 10, 15)
					else
						gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, cl.def, 10, 15)
					end
					imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
					if imgui.InvisibleButton(u8'##Выбрать шпору для удаления ' .. i, imgui.ImVec2(196, 100)) then
						if select_del then
							for s = 1, #shp_edit_all[2] do
								if shp_edit_all[2][s] == i then
									table.remove(shp_edit_all[2], s)
									break
								end
							end
						else
							table.insert(shp_edit_all[2], i)
						end
					end
					gui.FaText(26 + x_sp, 26 + y_sp, all_icon_shpora[setting.shp[i].icon], fa_font[5], imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
					imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
					if setting.shp[i].name ~= '' then
						local wrapped_text, newline_count = wrapText(u8:decode(setting.shp[i].name), 21, 63)
						gui.Text(26 + x_sp, 91 + y_sp - (newline_count * 17), wrapped_text, bold_font[1])
					else
						gui.Text(26 + x_sp, 91 + y_sp, 'Без названия', bold_font[1])
					end
					imgui.PopStyleColor(1)
					imgui.Dummy(imgui.ImVec2(0, 19))
					
					if i % 4 == 0 then
						bool_shp_y = bool_shp_y + 1
						bool_shp_x = 0
					else
						bool_shp_x = bool_shp_x + 1
					end
				end
			end
		else
			if setting.cl == 'White' then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
			else
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
			end
			gui.Text(375, 165, 'Пусто', bold_font[3])
			imgui.PopStyleColor(1)
		end
	end
	
	imgui.EndChild()
end

function hall.dep()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Департамент', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoScrollWithMouse)
	gui.DrawBox({16, 16}, {808, 75}, cl.tab, cl.line, 7, 15)
	gui.Text(26, 26, 'Формат обращения в рации департамента', font[3])
	
	gui.DrawLine({16, 53}, {824, 53}, cl.line)
	
	if setting.adress_format_dep == 1 or setting.adress_format_dep == 2 or setting.adress_format_dep == 5 then
		gui.Text(26, 64, 'Ваш тег', font[3])
		local bool_dep_my_tag = setting.my_tag_dep
		setting.my_tag_dep = gui.InputText({93, 66}, 200, setting.my_tag_dep, u8'Мой тег в рацию', 230, u8'Введите Ваш тег в рацию')
		if setting.my_tag_dep ~= bool_dep_my_tag then
			save()
			update_text_dep()
		end
		gui.Text(453, 64, 'Тег к обращаемому', font[3])
		local bool_dep_alien_tag = setting.alien_tag_dep
		setting.alien_tag_dep = gui.InputText({598, 66}, 200, setting.alien_tag_dep, u8'Тег к обращаемому', 230, u8'Введите тег к обращаемому')
		if setting.alien_tag_dep ~= bool_dep_alien_tag then
			save()
			update_text_dep()
		end
	elseif setting.adress_format_dep == 3 then
		gui.Text(26, 64, 'Тег к обращаемому', font[3])
		local bool_dep_alien_tag = setting.alien_tag_dep
		setting.alien_tag_dep = gui.InputText({171, 66}, 200, setting.alien_tag_dep, u8'Тег к обращаемому', 230, u8'Введите тег к обращаемому')
		if setting.alien_tag_dep ~= bool_dep_alien_tag then
			save()
			update_text_dep()
		end
	elseif setting.adress_format_dep == 4 then
		gui.Text(26, 64, 'Ваш тег', font[3])
		local bool_dep_my_tag = setting.my_tag_dep
		setting.my_tag_dep = gui.InputText({93, 66}, 140, setting.my_tag_dep, u8'Мой тег в рацию', 230, u8'Введите Ваш тег')
		if setting.my_tag_dep ~= bool_dep_my_tag then
			save()
			update_text_dep()
		end
		gui.Text(275, 64, 'Волна', font[3])
		local bool_dep_wave_tag	= setting.wave_tag_dep
		setting.wave_tag_dep = gui.InputText({331, 66}, 139, setting.wave_tag_dep, u8'Волна в рацию', 230, u8'Введите частоту')
		if setting.wave_tag_dep ~= bool_dep_wave_tag then
			save()
			update_text_dep()
		end
		gui.Text(513, 64, 'Тег к обращаемому', font[3])
		local bool_dep_alien_tag = setting.alien_tag_dep
		setting.alien_tag_dep = gui.InputText({658, 66}, 140, setting.alien_tag_dep, u8'Тег к обращаемому', 230, u8'Тег к обращаемому')
		if setting.alien_tag_dep ~= bool_dep_alien_tag then
			save()
			update_text_dep()
		end
	end
	
	gui.Text(363, 105, 'Локальный чат', bold_font[1])
	gui.DrawBox({16, 130}, {808, 223}, cl.tab, cl.line, 7, 15)
	gui.DrawLine({16, 311}, {824, 311}, cl.line)
	
	imgui.PushStyleColor(imgui.Col.Text, cl.def)
	imgui.PushFont(fa_font[4])
	imgui.SetCursorPos(imgui.ImVec2(26, 324))
	imgui.Text(fa.CHEVRON_LEFT)
	imgui.SetCursorPos(imgui.ImVec2(54, 324))
	imgui.Text(fa.CHEVRON_RIGHT)
	imgui.PopStyleColor(1)
	imgui.PopFont()
	if dep_var > 0 then
		if dep_var == 1 then
			gui.Text(42, 324, tostring(dep_var), bold_font[1])
		elseif dep_var ~= 10 then
			gui.Text(41, 324, tostring(dep_var), bold_font[1])
		else
			gui.Text(37, 324, tostring(dep_var), bold_font[1])
		end
		local bool_dep_blanks = setting.blanks_dep[dep_var]
		setting.blanks_dep[dep_var] = gui.InputText({81, 326}, 601, setting.blanks_dep[dep_var], u8'Текст заготовки в департаменте', 230, u8'Введите заготовленный текст')
		if setting.blanks_dep[dep_var] ~= bool_dep_blanks then
			save()
		end
		if gui.Button(u8'Добавить', {708, 319}, {100, 27}) then
			dep_text = dep_text .. setting.blanks_dep[dep_var]
			dep_var = 0
		end
	else
		gui.Text(42, 324, '-', bold_font[1])
		if return_mes_dep == '' then
			dep_text, ret_bool = gui.InputText({81, 326}, 601, dep_text, u8'Текст в департамент', 230, u8'Введите текст')
		else
			dep_text, ret_bool = gui.InputText({81, 326}, 581, dep_text, u8'Текст в департамент', 230, u8'Введите текст')
			imgui.PushFont(fa_font[4])
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
			imgui.SetCursorPos(imgui.ImVec2(682, 324))
			imgui.Text(fa.ROTATE_LEFT)
			imgui.PopFont()
			imgui.PopStyleColor(1)
			if imgui.IsItemHovered() then
				imgui.PushFont(font[3])
				imgui.SetTooltip(u8'Вставить предыдущий отправленный текст')
				imgui.PopFont()
			end
			imgui.SetCursorPos(imgui.ImVec2(679, 321))
			if imgui.InvisibleButton(u8'##вернуть прошлый текст', imgui.ImVec2(22, 23)) then
				dep_text = return_mes_dep
			end
			
		end
		if gui.Button(u8'Отправить', {708, 319}, {100, 27}) or ret_bool then
			sampSendChat(u8:decode(dep_text))
			return_mes_dep = dep_text
			update_text_dep()
		end
	end
	
	imgui.SetCursorPos(imgui.ImVec2(22, 322))
	if imgui.InvisibleButton(u8'##Вернуть предыдущий вариант заготовки', imgui.ImVec2(20, 24)) then
		if dep_var > 0 then
			dep_var = dep_var - 1
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(50, 322))
	if imgui.InvisibleButton(u8'##Следующий вариант заготовки', imgui.ImVec2(20, 24)) then
		if dep_var < 10 then
			dep_var = dep_var + 1
		end
	end
	
	imgui.SetCursorPos(imgui.ImVec2(16, 130))
	imgui.BeginChild(u8'Чат департамента', imgui.ImVec2(808, 181), false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
	imgui.SetScrollY(imgui.GetScrollMaxY())
	
	if #dep_history > 30 then
		for i = 1, #dep_history - 20 do
			table.remove(dep_history, 1)
		end
	end
	if #dep_history ~= 0 then
		start_index = math.max(#dep_history - 19, 1)
		for i = start_index, #dep_history do
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
			if setting.cl == 'Black' then
				imgui.TextColored(imgui.ImVec4(0.16, 0.65, 0.99, 1.00), u8(dep_history[i]))
			else
				imgui.TextColored(imgui.ImVec4(0.00, 0.35, 0.58, 1.00), dep_history[i])
			end
			imgui.PopFont()
		end
	end
	imgui.Dummy(imgui.ImVec2(0, 8))
	imgui.EndChild()
	
	local bool_adress_format = setting.adress_format_dep
	setting.adress_format_dep = gui.ListTableMove({789, 26}, {u8'[ЛСМЦ] - [ЛСПД]:', u8'[ЛСМЦ] to [ЛСПД]:', u8'к ЛСПД,', u8'[Больница ЛС] - [100,3] - [Полиция ЛС]:', u8'[Больница ЛС] з.к. [ФБР]:'}, setting.adress_format_dep, 'Select Adress Format Departament')
	if setting.adress_format_dep ~= bool_adress_format then
		save()
		update_text_dep()
	end
		
	imgui.EndChild()
end

function hall.sob()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Собеседование', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'Собеседование', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	
	if not edit_rp_q_sob and not edit_rp_fit_sob and not run_sob then
		gui.DrawBox({16, 16}, {808, 37}, cl.tab, cl.line, 7, 15)
		gui.Text(26, 26, 'Введите id игрока, чтобы начать собеседование', font[3])
		id_sobes, ret_bool = gui.InputText({520, 28}, 100, id_sobes, u8'id игрока собеседование', 4, u8'Введите id', 'num')
		if id_sobes ~= '' and (setting.sob.min_exp ~= '' or not setting.sob.auto_exp) and (setting.sob.min_law ~= '' or not setting.sob.auto_law)
		and (setting.sob.min_narko ~= '' or not setting.sob.auto_narko) then
			if gui.Button(u8'Начать собеседование', {643, 21}, {165, 27}) or ret_bool then
				run_sob = true
				if sampIsPlayerConnected(id_sobes) then
					sob_info = {
						exp = -1,
						law = -1,
						narko = -1,
						org = -1,
						med = -1,
						blacklist = -1,
						ticket = -1,
						bilet = -1,
						car = -1,
						moto = -1,
						gun = -1,
						warn = -1,
						bl_info = {},
						org_info = '',
						id = tonumber(id_sobes),
						nick = sampGetPlayerNickname(id_sobes),
						history = {}
					}
				end
			end
		else
			gui.Button(u8'Начать собеседование', {643, 21}, {165, 27}, false)
		end
		gui.Text(297, 67, 'Настройки меню собеседования', bold_font[1])
		gui.DrawBox({16, 92}, {808, 417}, cl.tab, cl.line, 7, 15)
		for i = 1, 10 do
			gui.DrawLine({16, 91 + (i * 38)}, {824, 91 + (i * 38)}, cl.line)
		end
		gui.Text(26, 102, 'Минимальный уровень игрока для вступления в организацию', font[3])
		local bool_save_input1 = setting.sob.min_exp
		setting.sob.min_exp = gui.InputText({673, 104}, 70, setting.sob.min_exp, u8'Мин exp игрока', 3, u8'Значение', 'num')
		if setting.name_rus ~= bool_save_input1 then save() end
		imgui.SetCursorPos(imgui.ImVec2(783, 98))
		if gui.Switch(u8'##Мин exp игрока функция', setting.sob.auto_exp) then
			setting.sob.auto_exp = not setting.sob.auto_exp
			save()
		end
		if setting.sob.min_exp == '' and setting.sob.auto_exp then
			gui.FaText(632, 100, fa.OCTAGON_EXCLAMATION, fa_font[5], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
		end
		gui.Text(26, 140, 'Минимальное значение законопослушности игрока для вступления в организацию', font[3])
		local bool_save_input2 = setting.sob.min_law
		setting.sob.min_law = gui.InputText({673, 142}, 70, setting.sob.min_law, u8'Мин law игрока', 3, u8'Значение', 'num')
		if setting.name_rus ~= bool_save_input2 then save() end
		imgui.SetCursorPos(imgui.ImVec2(783, 136))
		if gui.Switch(u8'##law игрока функция', setting.sob.auto_law) then
			setting.sob.auto_law = not setting.sob.auto_law
			save()
		end
		if setting.sob.min_law == '' and setting.sob.auto_law then
			gui.FaText(632, 138, fa.OCTAGON_EXCLAMATION, fa_font[5], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
		end
		gui.Text(26, 178, 'Допустимый уровень наркозависимости игрока для вступления в организацию', font[3])
		local bool_save_input3 = setting.sob.min_narko
		setting.sob.min_narko = gui.InputText({673, 180}, 70, setting.sob.min_narko, u8'Мин narko игрока', 3, u8'Значение', 'num')
		if setting.name_rus ~= bool_save_input3 then save() end
		imgui.SetCursorPos(imgui.ImVec2(783, 174))
		if gui.Switch(u8'##narko игрока функция', setting.sob.auto_narko) then
			setting.sob.auto_narko = not setting.sob.auto_narko
			save()
		end
		if setting.sob.min_narko == '' and setting.sob.auto_narko then
			gui.FaText(632, 176, fa.OCTAGON_EXCLAMATION, fa_font[5], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
		end
		gui.Text(26, 216, 'Автоматически проверять состоит ли игрок в организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 212))
		if gui.Switch(u8'##org игрока функция', setting.sob.auto_org) then
			setting.sob.auto_org = not setting.sob.auto_org
			save()
		end
		gui.Text(26, 254, 'Автоматически проверять состояние здоровья в мед. карте игрока', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 250))
		if gui.Switch(u8'##med игрока функция', setting.sob.auto_med) then
			setting.sob.auto_med = not setting.sob.auto_med
			save()
		end
		gui.Text(26, 292, 'Автоматически проверять состоит ли игрок в чёрном списке организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 288))
		if gui.Switch(u8'##blacklist игрока функция', setting.sob.auto_blacklist) then
			setting.sob.auto_blacklist = not setting.sob.auto_blacklist
			save()
		end
		gui.Text(26, 330, 'Автоматически проверять наличие военного билета и повестки', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 326))
		if gui.Switch(u8'##ticket игрока функция', setting.sob.auto_ticket) then
			setting.sob.auto_ticket = not setting.sob.auto_ticket
			save()
		end
		gui.Text(26, 368, 'Автоматически проверять наличие лицензии на авто', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 364))
		if gui.Switch(u8'##car игрока функция', setting.sob.auto_car) then
			setting.sob.auto_car = not setting.sob.auto_car
			save()
		end
		gui.Text(26, 406, 'Автоматически проверять наличие лицензии на мото', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 402))
		if gui.Switch(u8'##moto игрока функция', setting.sob_moto_lic) then
			setting.sob_moto_lic = not setting.sob_moto_lic
			save()
		end
		gui.Text(26, 444, 'Автоматически проверять наличие лицензии на оружие', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 440))
		if gui.Switch(u8'##gun игрока функция', setting.sob.auto_gun) then
			setting.sob.auto_gun = not setting.sob.auto_gun
			save()
		end
		gui.Text(26, 482, 'Автоматически проверять состоит ли игрок в организации', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 478))
		if gui.Switch(u8'##warn игрока функция', setting.sob.auto_warn) then
			setting.sob.auto_warn = not setting.sob.auto_warn
			save()
		end
		
		gui.Text(349, 523, 'Другие параметры', bold_font[1])
		gui.DrawBox({16, 548}, {808, 75}, cl.tab, cl.line, 7, 15)
		gui.DrawLine({16, 585}, {824, 585}, cl.line)
		gui.Text(26, 558, 'Отображать локальный чат', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 554))
		if gui.Switch(u8'##chat игрока функция', setting.sob.chat) then
			setting.sob.chat = not setting.sob.chat
			save()
		end
		gui.Text(26, 596, 'Автоматически закрывать показанные документы игрока', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 592))
		if gui.Switch(u8'##close doc игрока функция', setting.sob.close_doc) then
			setting.sob.close_doc = not setting.sob.close_doc
			save()
		end
		
		gui.Text(379, 637, 'Отыгровки', bold_font[1])
		gui.DrawBox({16, 662}, {808, 75}, cl.tab, cl.line, 7, 15)
		gui.DrawLine({16, 699}, {824, 699}, cl.line)
		gui.Text(26, 672, 'Отыгровки вопросов', font[3])
		gui.Text(26, 710, 'Отыгровки при определении годности', font[3])
		if gui.Button(u8'Настроить...##1', {693, 667}, {115, 27}) then
			edit_rp_q_sob = true
			an[19] = {0, 0}
		end
		if gui.Button(u8'Настроить...##2', {693, 705}, {115, 27}) then
			edit_rp_fit_sob = true
			an[19] = {0, 0}
		end
		
		imgui.Dummy(imgui.ImVec2(0, 22))
	elseif edit_rp_q_sob then
		gui.Text(346, 14, 'Перечень вопросов', bold_font[1])
		if #setting.sob.rp_q ~= 0 then
			local y_rp_q = 0
			for i = 1, #setting.sob.rp_q do
				gui.DrawBox({16, 39 + y_rp_q}, {808, 75 + (38 * #setting.sob.rp_q[i].rp)}, cl.tab, cl.line, 7, 15)
				gui.Text(26, 49 + y_rp_q, 'Имя вопроса', font[3])
				setting.sob.rp_q[i].name = gui.InputText({598, 51 + y_rp_q}, 200, setting.sob.rp_q[i].name, u8'Имя вопроса собес ' .. i, 100, u8'Текст')
				gui.DrawLine({16, 76 + y_rp_q}, {824, 76 + y_rp_q}, cl.line)
				
				if i <= 9 then
					gui.Text(5, 40 + y_rp_q, tostring(i), font[2])
				else
					gui.Text(2, 40 + y_rp_q, tostring(i), font[2])
				end
				
				if #setting.sob.rp_q[i].rp ~= 0 then
					for m = 1, #setting.sob.rp_q[i].rp do
						setting.sob.rp_q[i].rp[m] = gui.InputText({33, 89 + y_rp_q}, 734, setting.sob.rp_q[i].rp[m], u8'Отыгровка ' .. i .. m, 300, u8'Текст отыгровки')
						imgui.SetCursorPos(imgui.ImVec2(790, 84 + y_rp_q))
						if imgui.InvisibleButton(u8'##Удалить текст отыгровки ' .. i .. m, imgui.ImVec2(22, 23)) then
							table.remove(setting.sob.rp_q[i].rp, m)
							break
						end
						if imgui.IsItemActive() then
							gui.FaText(793, 87 + y_rp_q, fa.TRASH, fa_font[4], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
						else
							gui.FaText(793, 87 + y_rp_q, fa.TRASH, fa_font[4], cl.def)
						end
						gui.DrawLine({16, 114 + y_rp_q}, {824, 114 + y_rp_q}, cl.line)
						
						y_rp_q = y_rp_q + 38
					end
				end
				if gui.Button(u8'Добавить отыгровку##новую отыгровку' .. i, {255, 82 + y_rp_q}, {150, 27}) then
					table.insert(setting.sob.rp_q[i].rp, '')
				end
				if gui.Button(u8'Удалить вопрос##новую отыгровку' .. i, {435, 82 + y_rp_q}, {150, 27}) then
					table.remove(setting.sob.rp_q, i)
					break
				end
				
				y_rp_q = y_rp_q + 91
			end
		else
			if gui.Button(u8'Добавить вопрос##ff2s', {345, 185}, {150, 27}) then
				table.insert(setting.sob.rp_q, {name = '', rp = {''}})
			end
		end
		
		imgui.Dummy(imgui.ImVec2(0, 22))
		
		if bool_sob_rp_scroll then
			imgui.SetScrollY(imgui.GetScrollMaxY() + 200)
			bool_sob_rp_scroll = false
		end
	elseif edit_rp_fit_sob then
		gui.Text(239, 14, 'Перечень отыгровок при определении годности', bold_font[1])
		if #setting.sob.rp_fit ~= 0 then
			local y_rp_q = 0
			for i = 1, #setting.sob.rp_fit do
				gui.DrawBox({16, 39 + y_rp_q}, {808, 75 + (38 * #setting.sob.rp_fit[i].rp)}, cl.tab, cl.line, 7, 15)
				gui.Text(26, 49 + y_rp_q, 'Имя ответа', font[3])
				setting.sob.rp_fit[i].name = gui.InputText({598, 51 + y_rp_q}, 200, setting.sob.rp_fit[i].name, u8'Имя вопроса собес ' .. i, 100, u8'Текст')
				gui.DrawLine({16, 76 + y_rp_q}, {824, 76 + y_rp_q}, cl.line)
				
				if i <= 9 then
					gui.Text(5, 40 + y_rp_q, tostring(i), font[2])
				else
					gui.Text(2, 40 + y_rp_q, tostring(i), font[2])
				end
				
				if #setting.sob.rp_fit[i].rp ~= 0 then
					for m = 1, #setting.sob.rp_fit[i].rp do
						setting.sob.rp_fit[i].rp[m] = gui.InputText({33, 89 + y_rp_q}, 734, setting.sob.rp_fit[i].rp[m], u8'Отыгровка ' .. i .. m, 300, u8'Текст отыгровки')
						imgui.SetCursorPos(imgui.ImVec2(790, 84 + y_rp_q))
						if imgui.InvisibleButton(u8'##Удалить текст отыгровки ' .. i .. m, imgui.ImVec2(22, 23)) then
							table.remove(setting.sob.rp_fit[i].rp, m)
							break
						end
						if imgui.IsItemActive() then
							gui.FaText(793, 87 + y_rp_q, fa.TRASH, fa_font[4], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
						else
							gui.FaText(793, 87 + y_rp_q, fa.TRASH, fa_font[4], cl.def)
						end
						gui.DrawLine({16, 114 + y_rp_q}, {824, 114 + y_rp_q}, cl.line)
						
						y_rp_q = y_rp_q + 38
					end
				end
				if gui.Button(u8'Добавить отыгровку##новую отыгровку' .. i, {255, 82 + y_rp_q}, {150, 27}) then
					table.insert(setting.sob.rp_fit[i].rp, '')
				end
				if gui.Button(u8'Удалить ответ##новую отыгровку' .. i, {435, 82 + y_rp_q}, {150, 27}) then
					table.remove(setting.sob.rp_fit, i)
					break
				end
				
				y_rp_q = y_rp_q + 91
			end
		else
			if gui.Button(u8'Добавить ответ##ff2s', {345, 185}, {150, 27}) then
				table.insert(setting.sob.rp_fit, {name = '', rp = {''}})
			end
		end
		
		imgui.Dummy(imgui.ImVec2(0, 22))
		
		if bool_sob_rp_scroll then
			imgui.SetScrollY(imgui.GetScrollMaxY() + 200)
			bool_sob_rp_scroll = false
		end
	elseif run_sob then
		local ps_text = {{26, 56}, {296, 56}, {565, 56}, {26, 84}, {296, 84}, {565, 84}, {26, 112}, {296, 112}, {565, 112}, {26, 140}, {296, 140}, {565, 140}}
		local all_bool_cdf = {setting.sob.auto_exp, setting.sob.auto_law, setting.sob.auto_narko, setting.sob.auto_org, setting.sob.auto_med, setting.sob.auto_blacklist, setting.sob.auto_car, setting.sob_moto_lic, setting.sob.auto_gun, setting.sob.auto_warn, setting.sob.auto_ticket, setting.sob.auto_ticket}
		local all_bool_cdk = {'Уровень: ', 'Законопослушность: ', 'Наркозависимость: ', 'Мед карта: ', 'Здоровье: ', 'Чёрный список: ', 'Лиц. на авто: ', 'Лиц. на мото: ', 'Лиц. на оружие: ', 'Организация: ', 'Повестка: ', 'Военный билет: '}
		local all_param = {}
		local num_all_bool_cdf = 0
		local y_pos_all_cdf = 0
		for g = 1, 12 do
			if all_bool_cdf[g] then num_all_bool_cdf = num_all_bool_cdf + 1 end
		end
		
		if num_all_bool_cdf == 0 then
			gui.DrawBox({16, 16}, {808, 34}, cl.tab, cl.line, 7, 15)
		elseif num_all_bool_cdf <= 3 then
			gui.DrawBox({16, 16}, {808, 62}, cl.tab, cl.line, 7, 15)
			gui.DrawLine({16, 50}, {824, 50}, cl.line)
			gui.DrawLine({285, 50}, {285, 78}, cl.line)
			gui.DrawLine({554, 50}, {554, 78}, cl.line)
			y_pos_all_cdf = 28
		elseif num_all_bool_cdf <= 6 then
			gui.DrawBox({16, 16}, {808, 90}, cl.tab, cl.line, 7, 15)
			gui.DrawLine({16, 50}, {824, 50}, cl.line)
			gui.DrawLine({16, 78}, {824, 78}, cl.line)
			gui.DrawLine({285, 50}, {285, 106}, cl.line)
			gui.DrawLine({554, 50}, {554, 106}, cl.line)
			y_pos_all_cdf = 56
		elseif num_all_bool_cdf <= 9 then
			gui.DrawBox({16, 16}, {808, 118}, cl.tab, cl.line, 7, 15)
			gui.DrawLine({16, 50}, {824, 50}, cl.line)
			gui.DrawLine({16, 78}, {824, 78}, cl.line)
			gui.DrawLine({16, 106}, {824, 106}, cl.line)
			gui.DrawLine({285, 50}, {285, 134}, cl.line)
			gui.DrawLine({554, 50}, {554, 134}, cl.line)
			y_pos_all_cdf = 84
		elseif num_all_bool_cdf > 9 then
			gui.DrawBox({16, 16}, {808, 146}, cl.tab,cl.line, 7, 15)
			gui.DrawLine({16, 50}, {824, 50}, cl.line)
			gui.DrawLine({16, 78}, {824, 78}, cl.line)
			gui.DrawLine({16, 106}, {824, 106}, cl.line)
			gui.DrawLine({16, 134}, {824, 134}, cl.line)
			gui.DrawLine({285, 50}, {285, 162}, cl.line)
			gui.DrawLine({554, 50}, {554, 162}, cl.line)
			y_pos_all_cdf = 112
		end
		
		
		imgui.PushFont(bold_font[1])
		local sob_nick = imgui.CalcTextSize(sob_info.nick .. ' [' .. sob_info.id .. ']')
		imgui.PopFont()
		gui.Text(420 - sob_nick.x / 2, 23, sob_info.nick .. ' [' .. sob_info.id .. ']', bold_font[1])
		
		num_all_bool_cdf = 0
		for i = 1, 10 do
			if all_bool_cdf[i] then
				num_all_bool_cdf = num_all_bool_cdf + 1
				gui.Text(ps_text[num_all_bool_cdf][1], ps_text[num_all_bool_cdf][2], all_bool_cdk[i], font[3])
				imgui.PushFont(font[3])
				local calc_t = imgui.CalcTextSize(u8(all_bool_cdk[i]))
				local text_end_t = '{FF9500}Неизвестно'
				if all_bool_cdk[i] == 'Уровень: ' then
					if sob_info.exp == -2 then
						text_end_t = "{CF0000}Нету паспорта"
					else
						if tonumber(sob_info.exp) > -1 then
							if tonumber(sob_info.exp) >= tonumber(setting.sob.min_exp) then
								text_end_t = '{00A115}' .. tostring(sob_info.exp) .. '/' .. setting.sob.min_exp
							else
								text_end_t = '{CF0000}' .. tostring(sob_info.exp) .. '/' .. setting.sob.min_exp
							end
						end
					end
				elseif all_bool_cdk[i] == 'Законопослушность: ' then
					if sob_info.law == -2 then
						text_end_t = "{CF0000}Нету паспорта"
					else
						if tonumber(sob_info.law) > -1 then
							if tonumber(sob_info.law) >= tonumber(setting.sob.min_law) then
								text_end_t = '{00A115}' .. tostring(sob_info.law) .. '/' .. setting.sob.min_law
							else
								text_end_t = '{CF0000}' .. tostring(sob_info.law) .. '/' .. setting.sob.min_law
							end
						end
					end
				elseif all_bool_cdk[i] == 'Наркозависимость: ' then
					if tonumber(sob_info.narko) > -1 then
						if tonumber(sob_info.narko) >= tonumber(setting.sob.min_narko) then
							text_end_t = '{CF0000}' .. tostring(sob_info.narko) .. '/' .. setting.sob.min_narko
						else
							text_end_t = '{00A115}' .. tostring(sob_info.narko) .. '/' .. setting.sob.min_narko
						end
					end
				elseif all_bool_cdk[i] == 'Мед карта: ' then
					if sob_info.org > -1 then
						if sob_info.org == 1 then
							text_end_t = '{00A115}В порядке'
						elseif sob_info.org  == 2 then
							text_end_t = '{CF0000}Требуется обновить'
						elseif sob_info.org  == 3 then
							text_end_t = '{CF0000}Нету мед.карты'
						end
					end
				elseif all_bool_cdk[i] == 'Здоровье: ' then
					if sob_info.med > -1 then
						if sob_info.med == 1 then
							text_end_t = '{00A115}Полностью здоров'
						elseif sob_info.med == 2 then
							text_end_t = '{CF0000}Псих. отклонения'
						elseif sob_info.med == 3 then
							text_end_t = '{CF0000}Псих. нездоров'
						elseif sob_info.med == 4 then
							text_end_t = '{CF0000}Не определён'
						elseif sob_info.med == 5 then
							text_end_t = '{CF0000}Нету мед.карты'
						end
					end
				elseif all_bool_cdk[i] == 'Чёрный список: ' then
					if sob_info.blacklist > -1 then
						if sob_info.blacklist == 1 then
							text_end_t = '{00A115}Нигде не состоит'
						else
							text_end_t = '{CF0000}Состоит в ЧС'
						end
					end
				elseif all_bool_cdk[i] == 'Лиц. на авто: ' then
					if sob_info.car > -1 then
						if sob_info.car == 1 then
							text_end_t = '{00A115}Имеется'
						else
							text_end_t = '{CF0000}Отсутствует'
						end
					end
				elseif all_bool_cdk[i] == 'Лиц. на мото: ' then
					if sob_info.moto > -1 then
						if sob_info.moto == 1 then
							text_end_t = '{00A115}Имеется'
						else
							text_end_t = '{CF0000}Отсутствует'
						end
					end
				elseif all_bool_cdk[i] == 'Лиц. на оружие: ' then
					if sob_info.gun > -1 then
						if sob_info.gun == 1 then
							text_end_t = '{00A115}Имеется'
						else
							text_end_t = '{CF0000}Отсутствует'
						end
					end
				elseif all_bool_cdk[i] == 'Организация: ' then
					if sob_info.warn > -1 then
						if sob_info.warn == 1 then
							text_end_t = '{00A115}Отсутствует'
						else
							text_end_t = '{CF0000}Имеется'
						end
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(ps_text[num_all_bool_cdf][1] + calc_t.x + 2, ps_text[num_all_bool_cdf][2]))
				imgui.TextColoredRGB(text_end_t)
				if text_end_t:find('Состоит в ЧС') then
					local calc_bl = imgui.CalcTextSize(u8'Состоит в ЧС')
					local blacklist_all = table.concat(sob_info.bl_info, '\n')
					imgui.SetCursorPos(imgui.ImVec2(ps_text[num_all_bool_cdf][1] + calc_t.x + 2 + calc_bl.x + 8, ps_text[num_all_bool_cdf][2]))
					imgui.PushFont(fa_font[2])
					imgui.PushStyleColor(imgui.Col.Text, cl.def)
					imgui.Text(fa.CIRCLE_QUESTION)
					imgui.PopStyleColor(1)
					imgui.PopFont()
					if imgui.IsItemHovered() then
						imgui.SetTooltip(u8'Список ЧС, в котором состоит:\n\n' .. u8(blacklist_all))
					end
				end
				imgui.PopFont()
			end
		end
		
		if all_bool_cdf[11] then
			num_all_bool_cdf = num_all_bool_cdf + 1
			gui.Text(ps_text[num_all_bool_cdf][1], ps_text[num_all_bool_cdf][2], all_bool_cdk[11], font[3])
			imgui.PushFont(font[3])
			local calc_t = imgui.CalcTextSize(u8(all_bool_cdk[11]))
			local text_end_t = '{FF9500}Неизвестно'
			if sob_info.ticket > -1 then
				if sob_info.ticket == 1 then
					text_end_t = '{CF0000}Имеется'
				else
					text_end_t = '{00A115}Отсутствует'
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(ps_text[num_all_bool_cdf][1] + calc_t.x + 2, ps_text[num_all_bool_cdf][2]))
			imgui.TextColoredRGB(text_end_t)
			
			num_all_bool_cdf = num_all_bool_cdf + 1
			gui.Text(ps_text[num_all_bool_cdf][1], ps_text[num_all_bool_cdf][2], all_bool_cdk[12], font[3])
			
			calc_t = imgui.CalcTextSize(u8(all_bool_cdk[12]))
			text_end_t = '{FF9500}Неизвестно'
			if sob_info.bilet > -1 then
				if sob_info.bilet == 1 then
					text_end_t = '{CF0000}Отсутствует'
				else
					text_end_t = '{00A115}Имеется'
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(ps_text[num_all_bool_cdf][1] + calc_t.x + 2, ps_text[num_all_bool_cdf][2]))
			imgui.TextColoredRGB(text_end_t)
			
			imgui.PopFont()
		end
		
		if setting.sob.chat then
			gui.DrawBox({16, 60 + y_pos_all_cdf}, {808, 266 - y_pos_all_cdf}, cl.tab, cl.line, 7, 15)
			text_sob_chat, ret_bool = gui.InputText({27, 300}, 677, text_sob_chat, u8'Текст для чата собеседования', 350, u8'Введите текст')
			if text_sob_chat ~= '' then
				if gui.Button(u8'Отправить', {724, 293}, {90, 27}) or ret_bool then
					sampSendChat(u8:decode(text_sob_chat))
					text_sob_chat = ''
				end
			else
				gui.Button(u8'Отправить', {724, 293}, {90, 27}, false)
			end
			
			imgui.SetCursorPos(imgui.ImVec2(16, 60 + y_pos_all_cdf))
			imgui.BeginChild(u8'Чат собеседования', imgui.ImVec2(808, 232 - y_pos_all_cdf), false, imgui.WindowFlags.NoScrollWithMouse)
			imgui.SetScrollY(imgui.GetScrollMaxY())
			
			if #sob_info.history > 30 then
				for i = 1, #sob_info.history - 20 do
					table.remove(sob_info.history, 1)
				end
			end
			if #sob_info.history ~= 0 then
				start_index = math.max(#sob_info.history - 19, 1)
				for i = start_index, #sob_info.history do
					imgui.PushFont(font[3])
					imgui.SetCursorPos(imgui.ImVec2(10, 10 + ((i - 1) * 20)))
					imgui.TextColoredRGB(sob_info.history[i])
					imgui.PopFont()
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 8))
			imgui.EndChild()
		end
		
		if #setting.sob.rp_q ~= 0 then
			if gui.Button(u8'Задать вопрос', {16, 334}, {200, 27}) then
				imgui.OpenPopup(u8'Задать вопрос в хелпере')
			end
		else
			gui.Button(u8'Задать вопрос', {16, 334}, {200, 27}, false)
		end
		if #setting.sob.rp_fit ~= 0 then
			if gui.Button(u8'Определить годность', {320, 334}, {200, 27}) then
				imgui.OpenPopup(u8'Определить годность в хелпере')
			end
		else
			gui.Button(u8'Определить годность', {320, 334}, {200, 27}, false)
		end
		if gui.Button(u8'Прекратить собеседование', {624, 334}, {200, 27}) then
			run_sob = false
		end
		
		if imgui.BeginPopupModal(u8'Задать вопрос в хелпере', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно с вопросами', imgui.ImVec2(16, 16)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			gui.DrawLine({10, 31}, {296, 31}, cl.line)
			local y_size_child = 52
			if #setting.sob.rp_q < 9 and #setting.sob.rp_q > 1 then
				for i = 2, #setting.sob.rp_q do
					y_size_child = y_size_child + 35
				end
			elseif #setting.sob.rp_q == 1 then
				y_size_child = 52
			else
				y_size_child = 367
			end
			imgui.SetCursorPos(imgui.ImVec2(6, 40))
			imgui.BeginChild(u8'Задать вопрос в хелпере ', imgui.ImVec2(300, y_size_child), false)
			
			local pos_y_b = 0
			for i = 1, #setting.sob.rp_q do
				local text_name_sob = setting.sob.rp_q[i].name
				if setting.sob.rp_q[i].name == '' then
					text_name_sob = 'Без названия'
				end
				if gui.Button(text_name_sob .. '##rff4' .. i, {10, 8 + pos_y_b}, {274, 27}) then
					start_sob_cmd(setting.sob.rp_q[i].rp)
					imgui.CloseCurrentPopup()
				end
				pos_y_b = pos_y_b + 35
			end
			
			imgui.Dummy(imgui.ImVec2(0, 11))
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		if imgui.BeginPopupModal(u8'Определить годность в хелпере', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно с Определить годность', imgui.ImVec2(16, 16)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			gui.DrawLine({10, 31}, {296, 31}, cl.line)
			local y_size_child = 52
			if #setting.sob.rp_fit < 9 and #setting.sob.rp_fit > 1 then
				for i = 2, #setting.sob.rp_fit do
					y_size_child = y_size_child + 35
				end
			elseif #setting.sob.rp_fit == 1 then
				y_size_child = 52
			else
				y_size_child = 367
			end
			imgui.SetCursorPos(imgui.ImVec2(6, 40))
			imgui.BeginChild(u8'Определить годность в хелпере ', imgui.ImVec2(300, y_size_child), false)
			
			local pos_y_b = 0
			for i = 1, #setting.sob.rp_fit do
				local text_name_sob = setting.sob.rp_fit[i].name
				if setting.sob.rp_fit[i].name == '' then
					text_name_sob = 'Без названия'
				end
				if gui.Button(text_name_sob .. '##rff4' .. i, {10, 8 + pos_y_b}, {274, 27}) then
					start_sob_cmd(setting.sob.rp_fit[i].rp)
					open_main()
					run_sob = false
					
					imgui.CloseCurrentPopup()
				end
				pos_y_b = pos_y_b + 35
			end
			
			imgui.Dummy(imgui.ImVec2(0, 11))
			imgui.EndChild()
			imgui.EndPopup()
		end
		
	end
	imgui.EndChild()
end

function hall.reminder()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Напоминания', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'Напоминания', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	
	if new_reminder then
		gui.DrawBox({16, 16}, {808, 37}, cl.tab, cl.line, 7, 15)
		gui.Text(26, 26, 'Текст напоминания', font[3])
		new_rem.text = gui.InputText({169, 28}, 635, new_rem.text, u8'Текст напоминания', 400, u8'Введите текст')
		
		gui.DrawBox({16, 63}, {265, 296}, cl.tab, cl.line, 7, 15)
		gui.Text(32, 71, getMonthName(new_rem.mon) .. ' ' .. tostring(new_rem.year) .. ' г.', bold_font[1])
		gui.DrawLine({16, 99}, {281, 99}, cl.line)
		
		--local bool_date_td = get_today_date()
		local bool_week_td = getMonthInfo(new_rem.mon, new_rem.year)
		
		
		imgui.SetCursorPos(imgui.ImVec2(195, 66))
		if imgui.InvisibleButton(u8'##На месяц назад',  imgui.ImVec2(30, 30)) then
			new_rem.mon = new_rem.mon - 1
			new_rem.day = 1
			if new_rem.mon == 0 then
				new_rem.mon = 12
				new_rem.year = new_rem.year - 1
			end
		end
		if imgui.IsItemActive() then
			gui.FaText(204, 70, fa.ANGLE_LEFT, fa_font[5], imgui.ImVec4(0.83, 0.34, 0.34 ,1.00))
		else
			gui.FaText(204, 70, fa.ANGLE_LEFT, fa_font[5], imgui.ImVec4(0.83, 0.14, 0.14 ,1.00))
		end
		
		imgui.SetCursorPos(imgui.ImVec2(242, 66))
		if imgui.InvisibleButton(u8'##На месяц вперёд',  imgui.ImVec2(30, 30)) then
			new_rem.mon = new_rem.mon + 1
			new_rem.day = 1
			if new_rem.mon == 13 then
				new_rem.mon = 1
				new_rem.year = new_rem.year + 1
			end
		end
		if imgui.IsItemActive() then
			gui.FaText(252, 70, fa.ANGLE_RIGHT, fa_font[5], imgui.ImVec4(0.83, 0.34, 0.34 ,1.00))
		else
			gui.FaText(252, 70, fa.ANGLE_RIGHT, fa_font[5], imgui.ImVec4(0.83, 0.14, 0.14 ,1.00))
		end
		
		local bool_all_week = {u8'ПН', u8'ВТ', u8'СР', u8'ЧТ', u8'ПТ', u8'СБ', u8'ВС'}
		imgui.PushFont(font[3])
		for i = 1, 7 do
			imgui.PushFont(font[3])
			local week_calc = imgui.CalcTextSize(bool_all_week[i])
			imgui.PopFont()
			imgui.SetCursorPos(imgui.ImVec2(5 - (week_calc.x / 2) + (i * 36), 110))
			imgui.TextColored(imgui.ImVec4(0.30, 0.30, 0.30, 1.00), bool_all_week[i])
		end
		imgui.PopFont()
		
		
		local y_pos_pl = 4
		local week_bool = bool_week_td[1]
		for i = 1, bool_week_td[2] do
			imgui.PushFont(font[3])
			local num_calc = imgui.CalcTextSize(tostring(i))
			imgui.PopFont()
			local pos_x_num = math.floor(5 - (num_calc.x / 2) + (week_bool * 36))
			imgui.SetCursorPos(imgui.ImVec2(pos_x_num - 13 + (num_calc.x / 2), 147 - 13 + y_pos_pl))
			if imgui.InvisibleButton(u8'##Выбор числа месяца' .. i,  imgui.ImVec2(26, 26)) then
				new_rem.day = i
			end
			if imgui.IsItemHovered() then
				gui.DrawCircle({pos_x_num + (num_calc.x / 2), 147.5 + y_pos_pl}, 13.5, imgui.ImVec4(0.30, 0.30, 0.30 ,1.00))
			end
			if i == new_rem.day then
				gui.DrawCircle({pos_x_num + (num_calc.x / 2), 147.5 + y_pos_pl}, 13.5, imgui.ImVec4(0.83, 0.14, 0.14 ,1.00))
			end
			gui.Text(pos_x_num, 140 + y_pos_pl, tostring(i), font[3])
			
			if week_bool == 7 then
				y_pos_pl = y_pos_pl + 36
				week_bool = 1
			else
				week_bool = week_bool + 1
			end
		end
		
		gui.DrawBox({289, 63}, {99, 253}, cl.tab, cl.line, 7, 15)
		for i = 1, 7 do
			gui.Text(299, 42 + (i * 35), u8:decode(bool_all_week[i]), font[3])
			imgui.SetCursorPos(imgui.ImVec2(348, 37 + (i * 35)))
			if gui.Switch(u8'##Повтор week' .. i, new_rem.repeats[i]) then
				new_rem.repeats[i] = not new_rem.repeats[i]
			end
		end
		gui.DrawBox({289, 324}, {99, 35}, cl.tab, cl.line, 7, 15)
		gui.Text(299, 333, 'Звук', font[3])
		imgui.SetCursorPos(imgui.ImVec2(348, 328))
		if gui.Switch(u8'##Звуковой сигнал напоминания', new_rem.sound) then
			new_rem.sound = not new_rem.sound
		end
		
		if #tostring(new_rem.min) == 1 then
			new_rem.min = '0'..new_rem.min
		end
		if #tostring(new_rem.hour) == 1 then
			new_rem.hour = '0'..new_rem.hour
		end
		
		gui.Draw({500, 181}, {228, 60}, cl.tab, 7, 15)
		gui.Text(606, 173, ':', bold_font[2])
		gui.Text(480, 202, 'Ч', bold_font[1])
		gui.Text(737, 202, 'МИН', bold_font[1])
		
		--> ЧАСЫ
		imgui.SetCursorPos(imgui.ImVec2(520, 53))
		imgui.BeginChild(u8'Часы', imgui.ImVec2(90, 316), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)
		local mouse_pos = imgui.GetMousePos() * 2
		if start_child[1] then
			start_child[1] = false
			imgui.SetScrollY(last_child_y[1])
		end
		if imgui.IsMouseDown(0) and child_clicked[1] then
			imgui.SetScrollY(last_child_y[1] + (last_mouse_pos[1] - mouse_pos.y))
		else
			last_mouse_pos[1] = mouse_pos.y
			last_child_y[1] = imgui.GetScrollY()
			if last_child_y[1] % 60 == 0 then
				new_rem.hour = last_child_y[1] / 60
			elseif last_child_y[1] % 60 >= 30 then
				last_child_y[1] = last_child_y[1] + 1
				imgui.SetScrollY(last_child_y[1])
			else
				last_child_y[1] = last_child_y[1] - 1
				imgui.SetScrollY(last_child_y[1])
			end
		end
		
		for i = 0, 23 do
			if i <= 9 then
				i = '0' .. tostring(i)
			end
			imgui.PushFont(bold_font[2])
			calc_num = imgui.CalcTextSize(tostring(i))
			imgui.PopFont()
			gui.Text(36 - (calc_num.x / 2), 125 + (i * 60), tostring(i), bold_font[2])
		end
		
		imgui.Dummy(imgui.ImVec2(0, 125))
		if setting.cl == 'Black' then
			gui.Draw({0, imgui.GetScrollY() - 72}, {90, 200}, imgui.ImVec4(0.10, 0.10, 0.10, 0.96))
			gui.Draw({0, imgui.GetScrollY() + 188}, {90, 200}, imgui.ImVec4(0.10, 0.10, 0.10, 0.96))
		else
			gui.Draw({0, imgui.GetScrollY() - 72}, {90, 200}, imgui.ImVec4(0.93, 0.93, 0.93, 0.90))
			gui.Draw({0, imgui.GetScrollY() + 188}, {90, 200}, imgui.ImVec4(0.93, 0.93, 0.93, 0.90))
		end
		imgui.EndChild()
		if imgui.IsItemClicked() then
			child_clicked[1] = true
		end
		
		--> МИНУТЫ
		imgui.SetCursorPos(imgui.ImVec2(640, 53))
		imgui.BeginChild(u8'Минуты', imgui.ImVec2(90, 316), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar)
		local mouse_pos = imgui.GetMousePos() * 2
		if start_child[2] then
			start_child[2] = false
			imgui.SetScrollY(last_child_y[2])
		end
		if imgui.IsMouseDown(0) and child_clicked[2] then
			imgui.SetScrollY(last_child_y[2] + (last_mouse_pos[2] - mouse_pos.y))
		else
			last_mouse_pos[2] = mouse_pos.y
			last_child_y[2] = imgui.GetScrollY()
			if last_child_y[2] % 60 == 0 then
				new_rem.min = last_child_y[2] / 60
			elseif last_child_y[2] % 60 >= 30 then
				last_child_y[2] = last_child_y[2] + 1
				imgui.SetScrollY(last_child_y[2])
			else
				last_child_y[2] = last_child_y[2] - 1
				imgui.SetScrollY(last_child_y[2])
			end
		end
		
		for i = 0, 59 do
			if i <= 9 then
				i = '0' .. tostring(i)
			end
			imgui.PushFont(bold_font[2])
			calc_num = imgui.CalcTextSize(tostring(i))
			imgui.PopFont()
			gui.Text(36 - (calc_num.x / 2), 125 + (i * 60), tostring(i), bold_font[2])
		end
		
		imgui.Dummy(imgui.ImVec2(0, 125))
		if setting.cl == 'Black' then
			gui.Draw({0, imgui.GetScrollY() - 72}, {90, 200}, imgui.ImVec4(0.10, 0.10, 0.10, 0.96))
			gui.Draw({0, imgui.GetScrollY() + 188}, {90, 200}, imgui.ImVec4(0.10, 0.10, 0.10, 0.96))
		else
			gui.Draw({0, imgui.GetScrollY() - 72}, {90, 200}, imgui.ImVec4(0.93, 0.93, 0.93, 0.90))
			gui.Draw({0, imgui.GetScrollY() + 188}, {90, 200}, imgui.ImVec4(0.93, 0.93, 0.93, 0.90))
		end
		imgui.EndChild()
		if imgui.IsItemClicked() then
			child_clicked[2] = true
		end
		
		if imgui.IsMouseReleased(0) then
			child_clicked = {false, false}
		end
	else
		if #setting.reminder == 0 then
			if setting.cl == 'White' then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 1.00))
			else
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 1.00))
			end
			gui.Text(375, 165, 'Пусто', bold_font[3])
			imgui.PopStyleColor(1)
		else
			local function format_date_time(day, month, year, hour, minute)
				day = tonumber(day)
				month = tonumber(month)
				year = tonumber(year)
				hour = tonumber(hour)
				minute = tonumber(minute)
				local months = {
					'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня',
					'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
				}
				
				return string.format('%d %s %d г. в %02d:%02d', day, months[month], year, hour, minute)
			end
			
			local function get_repeats(repeats)
				local daysOfWeek = {'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'}
				local result = {}
				
				for i, isRepeat in ipairs(repeats) do
					if isRepeat then
						table.insert(result, daysOfWeek[i])
					end
				end
				
				if #result == 0 then
					return 'Без повторений'
				elseif #result == 7 then
					return 'Повтор каждый день'
				elseif #result == 5 and table.concat(result, ', ') == 'ПН, ВТ, СР, ЧТ, ПТ' then
					return 'Повтор в будние дни'
				else
					return 'Повтор в ' .. table.concat(result, ', ')
				end
			end
			
			for i = 1, #setting.reminder do
				local pos_y_pl = (i - 1) * 85
				local rep_rem = get_repeats(setting.reminder[i].repeats)
				local wrapped_text, newline_count = wrapText(u8:decode(setting.reminder[i].text), 95, 95)
				imgui.SetCursorPos(imgui.ImVec2(16, 16 + pos_y_pl))
				if imgui.InvisibleButton(u8'##Удалить напоминание' .. i, imgui.ImVec2(808, 75)) then
					imgui.OpenPopup(u8'Подтверждение удаления напоминания')
					del_rem = i
				end
				if setting.cl == 'Black' then
					if imgui.IsItemActive() then
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, imgui.ImVec4(0.12, 0.12, 0.12, 1.00), 7, 15)
					elseif imgui.IsItemHovered() then
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, imgui.ImVec4(0.15, 0.15, 0.15, 1.00), 7, 15)
					else
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, cl.tab, 7, 15)
					end
				else
					if imgui.IsItemActive() then
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, imgui.ImVec4(0.88, 0.86, 0.84, 1.00), 7, 15)
					elseif imgui.IsItemHovered() then
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, imgui.ImVec4(0.92, 0.90, 0.88, 1.00), 7, 15)
					else
						gui.Draw({16, 16 + pos_y_pl}, {808, 75}, cl.tab, 7, 15)
					end
				end
				gui.DrawLine({16, 53 + pos_y_pl}, {824, 53 + pos_y_pl}, cl.line)
				if setting.reminder[i].text ~= '' then
					gui.Text(26, 26 + pos_y_pl,wrapped_text, font[3])
				else
					gui.Text(26, 26 + pos_y_pl, 'Без названия', font[3])
				end
				gui.Draw({26, 63 + pos_y_pl}, {6, 19}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00))
				gui.Text(40, 64 + pos_y_pl, format_date_time(setting.reminder[i].day, setting.reminder[i].mon, setting.reminder[i].year, setting.reminder[i].hour, setting.reminder[i].min), font[3])
				imgui.PushFont(font[3])
				local calc_rep = imgui.CalcTextSize(u8(rep_rem))
				imgui.PopFont()
				gui.Text(814 - calc_rep.x, 64 + pos_y_pl, rep_rem, font[3])
			end
			
			if imgui.BeginPopupModal(u8'Подтверждение удаления напоминания', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPos(imgui.ImVec2(10, 10))
				if imgui.InvisibleButton(u8'##Закрыть окно удаления напоминания', imgui.ImVec2(16, 16)) then
					imgui.CloseCurrentPopup()
				end
				imgui.SetCursorPos(imgui.ImVec2(16, 16))
				local p = imgui.GetCursorScreenPos()
				if imgui.IsItemHovered() then
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
				else
					imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
				end
				gui.DrawLine({10, 31}, {346, 31}, cl.line)
				imgui.SetCursorPos(imgui.ImVec2(6, 40))
				imgui.BeginChild(u8'Подтверждение удаления напоминания ', imgui.ImVec2(261, 90), false, imgui.WindowFlags.NoScrollbar)
				
				gui.Text(25, 5, 'Вы уверены, что хотите удалить \n                 напоминание?', font[3])
				if gui.Button(u8'Удалить', {24, 50}, {90, 27}) then
					table.remove(setting.reminder, del_rem)
					imgui.CloseCurrentPopup()
					save()
				end
				if gui.Button(u8'Отмена', {141, 50}, {90, 27}) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndChild()
				imgui.EndPopup()
			end
			
			imgui.Dummy(imgui.ImVec2(0, 23))
		end
	end
	
	imgui.EndChild()
end

function hall.stat()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	
	local function format_time(seconds)
		local days = math.floor(seconds / 86400)
		local hours = math.floor((seconds % 86400) / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		local secs = seconds % 60

		if days > 0 then
			return string.format('%02d д. %02d ч. %02d мин. %02d сек.', days, hours, minutes, secs)
		else
			return string.format('%02d ч. %02d мин. %02d сек.', hours, minutes, secs)
		end
	end
	
	local function is_yesterday(date_string)
		local day, month, year = date_string:match('(%d%d)%.(%d%d)%.(%d%d)')
		
		if not (day and month and year) then
			error('Неправильный формат даты. Ожидается формат "DD.MM.YY".')
		end
		
		day, month, year = tonumber(day), tonumber(month), tonumber(year)
		
		year = year + 2000
		
		local current_time = os.time()
		local current_date = os.date("*t", current_time)
		local input_date_time = os.time({year = year, month = month, day = day, hour = 0})
		local yesterday_time = os.time({
			year = current_date.year,
			month = current_date.month,
			day = current_date.day - 1,
			hour = 0
		})
		
		return input_date_time == yesterday_time
	end
	
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Статистика онлайна', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'Статистика онлайна', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	
	gui.Draw({16, 16}, {808, 118}, cl.tab, 7, 15)
	gui.DrawLine({420, 66}, {420, 134}, cl.line)
	gui.Text(26, 26, tostring(setting.stat.date_week[1] .. ', сегодня'), bold_font[1])
	imgui.PushFont(bold_font[1])
	local calc_date = imgui.CalcTextSize(tostring(setting.stat.date_week[1]) .. u8', сегодня')
	imgui.PopFont()
	gui.Draw({24, 47}, {calc_date.x + 4, 5}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 7, 15)
	gui.Text(26, 66, 'Чистый онлайн за день:', font[3])
	gui.Text(26, 86, 'АФК за день:', font[3])
	gui.Text(26, 106, 'Всего за день:', font[3])
	gui.Text(431, 66, 'Чистый онлайн за сессию:', font[3])
	gui.Text(431, 86, 'АФК за сессию:', font[3])
	gui.Text(431, 106, 'Всего за сессию:', font[3])
	
	imgui.PushFont(font[3])
	imgui.SetCursorPos(imgui.ImVec2(186, 66))
	imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.cl[1]))
	imgui.SetCursorPos(imgui.ImVec2(116, 86))
	imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.afk[1]))
	imgui.SetCursorPos(imgui.ImVec2(125, 106))
	imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.day[1]))
	
	imgui.SetCursorPos(imgui.ImVec2(609, 66))
	imgui.TextColoredRGB('{279643}' .. format_time(stat_ses.cl))
	imgui.SetCursorPos(imgui.ImVec2(539, 86))
	imgui.TextColoredRGB('{279643}' .. format_time(stat_ses.afk))
	imgui.SetCursorPos(imgui.ImVec2(546, 106))
	imgui.TextColoredRGB('{279643}' .. format_time(stat_ses.all))
	imgui.PopFont()
	
	local y_pl = 0
	local online_week = setting.stat.cl[1]
	for i = 2, 10 do
		if setting.stat.date_week[i] ~= '' then
			local form_date = setting.stat.date_week[i]
			
			if is_yesterday(setting.stat.date_week[i]) then
				form_date = form_date .. u8', вчера'
			end
			imgui.PushFont(bold_font[1])
			local calc_dat = imgui.CalcTextSize(form_date)
			imgui.PopFont()
			gui.Draw({16, 142 + y_pl}, {808, 118}, cl.tab, 7, 15)
			gui.Draw({24, 173 + y_pl}, {calc_dat.x + 4, 5}, imgui.ImVec4(1.00, 0.58, 0.00, 1.00), 7, 15)
			gui.Text(26, 152 + y_pl, u8:decode(form_date), bold_font[1])
			gui.Text(26, 192 + y_pl, 'Чистый онлайн за день:', font[3])
			gui.Text(26, 212 + y_pl, 'АФК за день:', font[3])
			gui.Text(26, 232 + y_pl, 'Всего за день:', font[3])
			imgui.PushFont(font[3])
			imgui.SetCursorPos(imgui.ImVec2(186, 192 + y_pl))
			imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.cl[i]))
			imgui.SetCursorPos(imgui.ImVec2(116, 212 + y_pl))
			imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.afk[i]))
			imgui.SetCursorPos(imgui.ImVec2(125, 232 + y_pl))
			imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.day[i]))
			imgui.PopFont()
			
			online_week = online_week + setting.stat.cl[i]
			y_pl = y_pl + 128
		end
	end
	gui.Draw({16, 142 + y_pl}, {808, 57}, cl.tab, 7, 15)
	gui.Text(26, 152 + y_pl, 'Чистый онлайн за 10 дней:', font[3])
	gui.Text(26, 172 + y_pl, 'Чистый онлайн за всё время:', font[3])
	imgui.PushFont(font[3])
	imgui.SetCursorPos(imgui.ImVec2(205, 152 + y_pl))
	imgui.TextColoredRGB('{279643}' .. format_time(online_week))
	imgui.SetCursorPos(imgui.ImVec2(223, 172 + y_pl))
	imgui.TextColoredRGB('{279643}' .. format_time(setting.stat.all))
	imgui.PopFont()
	
	imgui.Dummy(imgui.ImVec2(0, 23))
	imgui.EndChild()
end

function hall.music()
    imgui.BeginChild(u8'Музыка', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
    imgui.SetCursorPos(imgui.ImVec2(50, 140))
    imgui.PushFont(bold_font[3])
    gui.TextGradient('Функция музыки отсутствует в State Helper Lite', 0.5)
    imgui.PopFont()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
    local text = u8'State Helper Lite - версия для лаунчера Arizona RP.\nПо правилам, мы не можем сделать данный функционал в скрипте.'
    local lines = {}
    for line in text:gmatch("[^\n]+") do table.insert(lines, line) end
    for i, line in ipairs(lines) do
        local textSize = imgui.CalcTextSize(line)
        local x = (840 - textSize.x) / 2
        local y = 185 + (i - 1) * 20
        imgui.SetCursorPos(imgui.ImVec2(x, y))
        imgui.Text(line)
    end
    imgui.PopStyleColor(1)
    imgui.EndChild()
end

local function decode64(str)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	str = string.gsub(str, '[^'..b..'=]', '')
	return (str:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end
function hall.rp_zona()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'РП зона', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'РП зона', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	if #setting.scene == 0 and not new_scene then
		if setting.cl == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
		end
		gui.Text(104, 166, 'Здесь Вы можете создать скриншот ситуацию (СС) для Вашего отчёта, без сторонних программ.', font[3])
		gui.Text(163, 186, 'Нажмите Добавить в правом верхнем углу, чтобы создать Вашу первую сцену.', font[3])
		imgui.PopStyleColor(1)
	elseif #setting.scene ~= 0 and not new_scene then
		local bool_scene_x = 0
		local bool_scene_y = 0
		local color_scene = {{1.00, 0.62, 0.04}, {1.00, 0.26, 0.23}, {1.00, 0.82, 0.04}, {0.19, 0.80, 0.35}, {0.00, 0.80, 0.76}, {0.04, 0.49, 1.00}, {0.37, 0.35, 0.93}, {0.75, 0.33, 0.95}, {1.00, 0.20, 0.37}, {1.00, 0.55, 0.55}, {0.67, 0.55, 0.41}}
		for i = 1, #setting.scene do
			local x_sp = (204 * bool_scene_x)
			local y_sp = (108 * bool_scene_y)
			gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_scene[setting.scene[i].color + 1][1], color_scene[setting.scene[i].color + 1][2], color_scene[setting.scene[i].color + 1][3], 1.00), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
			if imgui.InvisibleButton(u8'##Открыть сцену' .. i, imgui.ImVec2(156, 100)) then
				scene = setting.scene[i]
				scene_active = true
				scene_edit_pos = false
				windows.main[0] = false
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
			end
			if imgui.IsItemActive() then
				gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_scene[setting.scene[i].color + 1][1], color_scene[setting.scene[i].color + 1][2] - 0.10, color_scene[setting.scene[i].color + 1][3], 1.00), 10, 15)
			end
			imgui.SetCursorPos(imgui.ImVec2(172 + x_sp, 56 + y_sp))
			if imgui.InvisibleButton(u8'##Открыть сцену 2' .. i, imgui.ImVec2(40, 60)) then
				scene = setting.scene[i]
				scene_active = true
				scene_edit_pos = false
				windows.main[0] = false
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
			end
			if imgui.IsItemActive() then
				gui.Draw({16 + x_sp, 16 + y_sp}, {196, 100}, imgui.ImVec4(color_scene[setting.scene[i].color + 1][1], color_scene[setting.scene[i].color + 1][2] - 0.10, color_scene[setting.scene[i].color + 1][3], 1.00), 10, 15)
			end
			gui.FaText(26 + x_sp, 26 + y_sp, all_icon_shpora[setting.scene[i].icon], fa_font[5], imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			imgui.SetCursorPos(imgui.ImVec2(16 + x_sp, 16 + y_sp))
			
			imgui.SetCursorPos(imgui.ImVec2(189 + x_sp, 39 + y_sp))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 15, imgui.GetColorU32Vec4(imgui.ImVec4(color_scene[setting.scene[i].color + 1][1], color_scene[setting.scene[i].color + 1][2] + 0.10, color_scene[setting.scene[i].color + 1][3], 1.00)), 60)
			imgui.SetCursorPos(imgui.ImVec2(174 + x_sp, 24 + y_sp))
			if imgui.InvisibleButton(u8'##Открыть для редактирования сцены ' .. i, imgui.ImVec2(30, 30)) then
				new_scene = true
				scene = setting.scene[i]
				num_scene = i
				font_sc = renderCreateFont('Arial', scene.size, scene.flag)
			end
			if imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y), 15, imgui.GetColorU32Vec4(imgui.ImVec4(color_scene[setting.scene[i].color + 1][1], color_scene[setting.scene[i].color + 1][2] + 0.20, color_scene[setting.scene[i].color + 1][3], 1.00)), 60)
			end
			gui.FaText(180 + x_sp, 28 + y_sp, fa.ELLIPSIS, fa_font[5], imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			if setting.scene[i].name ~= '' then
				local wrapped_text, newline_count = wrapText(u8:decode(setting.scene[i].name), 21, 63)
				gui.Text(26 + x_sp, 91 + y_sp - (newline_count * 17), wrapped_text, bold_font[1])
			else
				gui.Text(26 + x_sp, 91 + y_sp, 'Без названия', bold_font[1])
			end
			imgui.Dummy(imgui.ImVec2(0, 19))
			
			if i % 4 == 0 then
				bool_scene_y = bool_scene_y + 1
				bool_scene_x = 0
			else
				bool_scene_x = bool_scene_x + 1
			end
		end
	elseif new_scene then
		gui.Draw({16, 16}, {808, 37}, cl.tab, 7, 15)
		gui.Text(26, 26, 'Имя сцены', font[3])
		scene.name = gui.InputText({139, 28}, 665, scene.name, u8'Имя сцены', 400, u8'Вводите текст')
		
		gui.Draw({16, 62}, {808, 37}, cl.tab, 7, 15)
		gui.Text(26, 72, 'Предосмотр сцены во время её редактирования', font[3])
		imgui.SetCursorPos(imgui.ImVec2(783, 69))
		if gui.Switch(u8'##Переключить предосмотр сцены', scene.preview) then
			scene.preview = not  scene.preview
		end
		
		gui.Draw({16, 109}, {808, 227}, cl.tab, 7, 15)
		gui.DrawLine({16, 146}, {824, 146}, cl.line)
		gui.DrawLine({16, 184}, {824, 184}, cl.line)
		gui.DrawLine({16, 222}, {824, 222}, cl.line)
		gui.DrawLine({16, 260}, {824, 260}, cl.line)
		gui.DrawLine({16, 298}, {824, 298}, cl.line)
		gui.Text(26, 119, 'Размер шрифта', font[3])
		gui.Text(26, 157, 'Расстояние между строками', font[3])
		gui.Text(26, 195, 'Прозрачность текста', font[3])
		gui.Text(26, 233, 'Флаг шрифта', font[3])
		gui.Text(26, 271, 'Инверсировать текст', font[3])
		gui.Text(26, 309, 'Положение текста на экране', font[3])
		
		local bool_set_size = imgui.new.float(scene.size)
		bool_set_size[0] = gui.SliderBar('##Размер шрифта', bool_set_size, 1, 50, 152, {671, 116})
		if bool_set_size[0] ~= scene.size then
			scene.size = floor(bool_set_size[0])
			font_sc = renderCreateFont('Arial', scene.size, scene.flag)
			save()
		end
		local bool_set_dist = imgui.new.float(scene.dist)
		bool_set_dist[0] = gui.SliderBar('##Расстояние между строками', bool_set_dist, 0, 50, 152, {671, 154})
		if bool_set_dist[0] ~= scene.dist then
			scene.dist = floor(bool_set_dist[0])
			save()
		end
		local bool_set_vis = imgui.new.float(scene.vis)
		bool_set_vis[0] = gui.SliderBar('##Прозрачность текста', bool_set_vis, 0, 100, 152, {671, 192})
		if bool_set_vis[0] ~= scene.vis then
			scene.vis = floor(bool_set_vis[0])
			save()
		end
		local bool_set_flag = scene.flag
		scene.flag = gui.ListTableMove({794, 233}, {u8'Без обводки', u8'Без обводки наклонённый', u8'Без обводки жирный наклонённый', u8'С обводкой', u8'С обводкой жирный', u8'С обводкой наклонённый', u8'С обводкой жирный наклонённый', u8'Без обводки с тенью', u8'Без обводки жирный с тенью', u8'Без обводки с тенью наклонённый', u8'Без обводки с тенью жирный наклонённый', u8'С обводкой и тенью', u8'С обводкой и тенью жирный'}, scene.flag, 'Select Size Scene')
		if scene.flag ~= bool_set_flag then
			font_sc = renderCreateFont('Arial', scene.size, scene.flag)
		end
		imgui.SetCursorPos(imgui.ImVec2(783, 267))
		if gui.Switch(u8'##Инверсировать текст', scene.invers) then
			scene.invers = not  scene.invers
		end
		if gui.Button(u8'Изменить...##положение текста', {713, 304}, {100, 27}) then
			scene_edit()
		end
		
		local function accent_col(num_acc, color_acc, color_acc_act)
			imgui.SetCursorPos(imgui.ImVec2(356 + (num_acc * 44), 364))
			local p = imgui.GetCursorScreenPos()
			
			imgui.SetCursorPos(imgui.ImVec2(345 + (num_acc * 44), 354))
			if imgui.InvisibleButton(u8'##Выбор цвета' .. num_acc, imgui.ImVec2(22, 22)) then
				scene.color = num_acc
			end
			if imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc_act[1], color_acc_act[2], color_acc_act[3] ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5),  12, imgui.GetColorU32Vec4(imgui.ImVec4(color_acc[1], color_acc[2], color_acc[3] ,1.00)), 60)
			end
			if num_acc == scene.color then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x, p.y + 0.5), 4, imgui.GetColorU32Vec4(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 60)
			end
		end
		
		gui.Draw({16, 346}, {808, 75}, cl.tab, 7, 15)
		gui.DrawLine({16, 383}, {824, 383}, cl.line)
		gui.Text(26, 356, 'Цвет карточки', font[3])
		accent_col(0, {1.00, 0.62, 0.04}, {1.00, 0.52, 0.04})
		accent_col(1, {1.00, 0.26, 0.23}, {1.00, 0.16, 0.23})
		accent_col(2, {1.00, 0.82, 0.04}, {1.00, 0.72, 0.04})
		accent_col(3, {0.19, 0.80, 0.35}, {0.19, 0.70, 0.35})
		accent_col(4, {0.00, 0.80, 0.76}, {0.00, 0.70, 0.76})
		accent_col(5, {0.04, 0.49, 1.00}, {0.04, 0.39, 1.00})
		accent_col(6, {0.37, 0.35, 0.93}, {0.37, 0.25, 0.93})
		accent_col(7, {0.75, 0.33, 0.95}, {0.75, 0.23, 0.95})
		accent_col(8, {1.00, 0.20, 0.37}, {1.00, 0.10, 0.37})
		accent_col(9, {1.00, 0.55, 0.55}, {1.00, 0.45, 0.55})
		accent_col(10, {0.67, 0.55, 0.41}, {0.67, 0.45, 0.41})
		
		gui.Text(26, 394, 'Значок карточки', font[3])
		gui.FaText(150, 394, all_icon_shpora[scene.icon], fa_font[4])
		if gui.Button(u8'Выбрать...##Иконку карточки', {713, 389}, {100, 27}) then
			imgui.OpenPopup(u8'Установить значок карточки в рп зоне')
		end
		
		if imgui.BeginPopupModal(u8'Установить значок карточки в рп зоне', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
			imgui.SetCursorPos(imgui.ImVec2(10, 10))
			if imgui.InvisibleButton(u8'##Закрыть окно установки значка', imgui.ImVec2(16, 16)) then
				imgui.CloseCurrentPopup()
			end
			imgui.SetCursorPos(imgui.ImVec2(16, 16))
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() then
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
			else
				imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
			end
			gui.DrawLine({10, 31}, {239, 31}, cl.line)
			imgui.SetCursorPos(imgui.ImVec2(6, 40))
			imgui.BeginChild(u8'Установка значка в рп зоне', imgui.ImVec2(243, 340), false)
			local function auto_ordering_icon(pos_ic_y, table_ic, num_ic_n)
				local bool_proc_y = 0
				local bool_proc_x = 0
				local return_icon = 0
				for i = 1, #table_ic do
					imgui.SetCursorPos(imgui.ImVec2(5 + (bool_proc_x * 48), pos_ic_y - 4 + (45 * bool_proc_y)))
					if imgui.InvisibleButton(u8'##Выбрать значок ' .. pos_ic_y .. i, imgui.ImVec2(30, 30)) then
						return_icon = i + num_ic_n
					end
					if imgui.IsItemHovered() then
						gui.FaText(10 + (bool_proc_x * 48), pos_ic_y + (45 * bool_proc_y), table_ic[i], fa_font[4], cl.def)
					else
						gui.FaText(10 + (bool_proc_x * 48), pos_ic_y + (45 * bool_proc_y), table_ic[i], fa_font[4], imgui.ImVec4(0.60, 0.60, 0.60, 1.00))
					end
					if i % 5 == 0 then
						bool_proc_y = bool_proc_y + 1
						bool_proc_x = 0
					else
						bool_proc_x = bool_proc_x + 1
					end
				end
				
				if return_icon ~= 0 then
					scene.icon = return_icon
					imgui.CloseCurrentPopup()
				end
			end
			gui.Text(10, 5, 'Предметы', bold_font[1])
			auto_ordering_icon(40, {fa.HOUSE, fa.STAR, fa.USER, fa.MUSIC, fa.GIFT, fa.BOOK, fa.KEY, fa.GLOBE, fa.CODE, fa.COMPASS, fa.LAYER_GROUP, fa.USERS, fa.HEART, fa.CAR, fa.CALENDAR, fa.PLAY, fa.FLAG, fa.BRAIN, fa.ROBOT, fa.WRENCH, fa.INFO, fa.CLOCK, fa.FLOPPY_DISK, fa.CHART_SIMPLE, fa.SHOP, fa.LINK, fa.DATABASE, fa.TAGS, fa.POWER_OFF, fa.HAMMER, fa.SCROLL, fa.CLONE, fa.DICE}, 0)
			gui.Text(10, 355, 'Медицина', bold_font[1])
			auto_ordering_icon(390, {fa.USER_NURSE, fa.HOSPITAL, fa.WHEELCHAIR, fa.TRUCK_MEDICAL, fa.TEMPERATURE_LOW, fa.SYRINGE, fa.HEART_PULSE, fa.BOOK_MEDICAL, fa.BAN, fa.PLUS, fa.NOTES_MEDICAL}, 33)
			gui.Text(10, 525, 'Операционная система', bold_font[1])
			auto_ordering_icon(560, {fa.IMAGE, fa.FILE, fa.TRASH, fa.INBOX, fa.FOLDER, fa.FOLDER_OPEN, fa.COMMENTS, fa.SLIDERS, fa.WIFI, fa.VOLUME_HIGH, fa.UP_DOWN_LEFT_RIGHT, fa.TERMINAL, fa.SUPERSCRIPT}, 44)
			
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.EndChild()
			imgui.EndPopup()
		end
		
		
		local pos_pl = 123
		gui.Text(379, 312 + pos_pl, 'Отыгровки', bold_font[1])
		if #scene.rp ~= 0 then
			for i = 1, #scene.rp do
				gui.Draw({16, 337 + pos_pl}, {808, 151}, cl.tab, 7, 15)
				if i <= 9 then
					gui.Text(5, 338 + pos_pl, tostring(i), font[2])
				else
					gui.Text(2, 338 + pos_pl, tostring(i), font[2])
				end
				gui.Text(26, 347 + pos_pl, 'Режим отображения', font[3])
				scene.rp[i].var = gui.ListTableMove({794, 347 + pos_pl}, {u8'Свой текст и свой цвет текста', u8'Разговорная речь', u8'/me', u8'/do', u8'/todo', u8'Телефон'}, scene.rp[i].var, 'Select Var Rp Zone' .. i)
				gui.DrawLine({16, 374 + pos_pl}, {824, 374 + pos_pl}, cl.line)
				if scene.rp[i].var ~= 5 then
					gui.Text(26, 385 + pos_pl, 'Текст отыгровки', font[3])
					scene.rp[i].text1 = gui.InputText({160, 387 + pos_pl}, 644, scene.rp[i].text1, u8'Текст отыгровки1' .. i, 400, u8'Введите текст Вашей отыгровки')
				else
					scene.rp[i].text1 = gui.InputText({32, 387 + pos_pl}, 370, scene.rp[i].text1, u8'Текст отыгровки1' .. i, 400, u8'Введите текст речи')
					scene.rp[i].text2 = gui.InputText({434, 387 + pos_pl}, 370, scene.rp[i].text2, u8'Текст отыгровки2' .. i, 400, u8'Введите текст действия')
				end
				gui.DrawLine({16, 412 + pos_pl}, {824, 412 + pos_pl}, cl.line)
				
				if scene.rp[i].var ~= 1 then
					gui.Text(26, 423 + pos_pl, 'Имя Вашего персонажа', font[3])
					scene.rp[i].nick = gui.InputText({610, 425 + pos_pl}, 194, scene.rp[i].nick, u8'Имя персонажа' .. i, 200, u8'Введите имя или никнейм')
				else
					local col_set = convert_color(scene.rp[i].color)
					gui.Text(26, 423 + pos_pl, 'Цвет отображаемого текста', font[3])
					imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(6.5, 6.5))
					imgui.SetCursorPos(imgui.ImVec2(787, 418 + pos_pl))
					if imgui.ColorEdit4('##Color Scene' .. i, col_set, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
						local c = imgui.ImVec4(col_set[0], col_set[1], col_set[2], col_set[3])
						scene.rp[i].color = imgui.ColorConvertFloat4ToARGB(c)
					end
					imgui.PopStyleVar(1)
				end
				gui.DrawLine({16, 450 + pos_pl}, {824, 450 + pos_pl}, cl.line)
				if gui.Button(u8'Удалить отыгровку##' .. i, {340, 455 + pos_pl}, {160, 27}) then
					table.remove(scene.rp, i)
					break
				end
				
				
				pos_pl = pos_pl + 161
			end
		end
		
		if gui.Button(u8'Добавить отыгровку', {340, 344 + pos_pl}, {160, 27}) then
			table.insert(scene.rp, {
				text1 = '',
				text2 = '',
				nick = sampGetPlayerNickname(my.id),
				var = 1,
				color = 0xFFFFFFFF
			})
		end
		
		imgui.Dummy(imgui.ImVec2(0, 20))
	end
	
	imgui.EndChild()
end

function hall.actions()
	local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
	local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
	if setting.cl == 'White' then
		color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
		color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
	end
	imgui.SetCursorPos(imgui.ImVec2(4, 39))
	imgui.BeginChild(u8'Действия', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
	imgui.Scroller(u8'Действия', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
	gui.Text(25, 12, 'Действия с чатом', bold_font[1])
	gui.DrawBox({16, 37}, {808, 113}, cl.tab, cl.line, 7, 15)
	gui.DrawLine({16, 74}, {824, 74}, cl.line)
	gui.DrawLine({16, 112}, {824, 112}, cl.line)
	gui.Text(26, 47, 'Скрыть все сообщения в чате, кроме РП действий и диалогов', font[3])
	imgui.SetCursorPos(imgui.ImVec2(783, 44))
	if gui.Switch(u8'##Скрыть все сообщения кроме РП действий', actions_set.remove_mes) then
		actions_set.remove_mes = not actions_set.remove_mes
	end
	gui.Text(26, 85, 'Скрыть РП действия и диалоги от других игроков', font[3])
	imgui.SetCursorPos(imgui.ImVec2(783, 82))
	if gui.Switch(u8'##Скрыть все сообщения', actions_set.remove_rp) then
		actions_set.remove_rp = not actions_set.remove_rp
	end
	if gui.Button(u8'Очистить игровой чат', {335, 118}, {170, 27}) then
		for qua = 1, 70 do
			sampAddChatMessage('', 0xFFFFFF)
		end
	end
	
	gui.Text(25, 165, 'Действия с миром', bold_font[1])
	gui.DrawBox({16, 190}, {808, 151}, cl.tab, cl.line, 7, 15)
	gui.DrawLine({16, 227}, {824, 227}, cl.line)
	gui.DrawLine({16, 265}, {824, 265}, cl.line)
	gui.DrawLine({16, 303}, {824, 303}, cl.line)
	if gui.Button(u8'Переключить показ никнеймов игроков', {220, 195}, {400, 27}) then
		sampSendChat('/settings')
		nickname_dialog = true
		time_dialog_nickname = 0
	end
	if gui.Button(u8'Узнать дистанцию до серверной метки на карте', {220, 233}, {400, 27}) then
		local my_int = getActiveInterior()
		if my_int == 0 then
			local bool_result, pos_X, pos_Y, pos_Z = getTargetServerCoordinates()
			if bool_result then
				local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
				local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
				sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Расстояние от Вас до метки: ' .. removeDecimalPart(distance) .. ' м.', 0xFF5345)
			else
				sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Невозможно определить дистанцию, так как отсутствует метка.', 0xFF5345)
			end
		else
			sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Невозможно определить дистанцию, так как Вы находитесь в интерьере.', 0xFF5345)
		end
	end
	if gui.Button(u8'Узнать дистанцию до собственной метки на карте', {220, 271}, {400, 27}) then
		local my_int = getActiveInterior()
		if my_int == 0 then
			local bool_result, pos_X, pos_Y, pos_Z = getTargetBlipCoordinates()
			if bool_result then
				local x_player, y_player, z_player = getCharCoordinates(PLAYER_PED)
				local distance = getDistanceBetweenCoords3d(pos_X, pos_Y, pos_Z, x_player, y_player, z_player)
				sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Расстояние от Вас до метки: ' .. removeDecimalPart(distance) .. ' м.', 0xFF5345)
			else
				sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Невозможно определить дистанцию, так как отсутствует метка.', 0xFF5345)
			end
		else
			sampAddChatMessage('[SH] {FFFFFF}{f7c52f}Невозможно определить дистанцию, так как Вы находитесь в интерьере.', 0xFF5345)
		end
	end
	
	if gui.Button(u8'Закрыть соединение с сервером', {220, 309}, {400, 27}) then
		close_connect()
	end
	
	gui.Text(25, 356, 'Действия с программой', bold_font[1])
	gui.DrawBox({16, 381}, {808, 113}, cl.tab, cl.line, 7, 15)
	gui.DrawLine({16, 418}, {824, 418}, cl.line)
	gui.DrawLine({16, 456}, {824, 456}, cl.line)
	if gui.Button(u8'Перезагрузить скрипт', {220, 386}, {400, 27}) then
		showCursor(false)
		scr:reload()
	end
	if gui.Button(script_ac.reset == 0 and u8'Сбросить все настройки скрипта' or u8'Нажмите снова для сброса настроек', {220, 424}, {400, 27}) then
		script_ac.reset = script_ac.reset + 1
		if script_ac.reset > 1 then
			os.remove(dir .. '/State Helper Lite/Настройки.json')
			os.remove(dir .. '/State Helper Lite/Отыгровки.json')
			
			sampAddChatMessage('[SH] {FFFFFF}Настройки сброшены. Перезагрузка скрипта...', 0xFF5345)
			showCursor(false)
			scr:reload()
		end
	end
	if gui.Button(script_ac.del == 0 and u8'Удалить скрипт с этого устройства' or u8'Нажмите снова для удаления скрипта', {220, 462}, {400, 27}) then
		script_ac.del = script_ac.del + 1
		if script_ac.del > 1 then
			sampAddChatMessage('[SH] {FFFFFF}Скрипт удалён. Настройки сохранены, Вы можете снова установить его в любое время.', 0xFF5345)
			windows.main[0] = false
			showCursor(false)
			os.remove(scr.path)
			scr:reload()
		end
	end
	
	imgui.Dummy(imgui.ImVec2(0, 21))
	imgui.EndChild()
end

function hall.help()
	imgui.BeginChild(u8'Поддержка', imgui.ImVec2(840, 369), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
    imgui.SetCursorPos(imgui.ImVec2(120, 140))
    imgui.PushFont(bold_font[3])
    gui.TextGradient('Функция отсутствует в State Helper Lite', 0.5)
    imgui.PopFont()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.40, 0.40, 0.40, 0.50))
    local text = u8'State Helper Lite - версия для лаунчера Arizona RP.\nПо правилам, мы не можем сделать данный функционал в скрипте.'
    local lines = {}
    for line in text:gmatch("[^\n]+") do table.insert(lines, line) end
    for i, line in ipairs(lines) do
        local textSize = imgui.CalcTextSize(line)
        local x = (840 - textSize.x) / 2
        local y = 185 + (i - 1) * 20
        imgui.SetCursorPos(imgui.ImVec2(x, y))
        imgui.Text(line)
    end
    imgui.PopStyleColor(1)
    imgui.EndChild()
end

function format_time(seconds)
	seconds = math.floor(seconds + 0.5)
	
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format('%02d:%02d:%02d', hours, minutes, secs)
	else
		return string.format('%02d:%02d', minutes, secs)
	end
end

function update_text_dep()
	if setting.adress_format_dep == 1 then
		dep_text = u8'/d [' .. setting.my_tag_dep .. '] - [' .. setting.alien_tag_dep .. ']: '
	elseif setting.adress_format_dep == 2 then
		dep_text = u8'/d [' .. setting.my_tag_dep .. '] to [' .. setting.alien_tag_dep .. ']: '
	elseif setting.adress_format_dep == 3 then
		dep_text = u8'/d к ' .. setting.alien_tag_dep .. ', '
	elseif setting.adress_format_dep == 4 then
		dep_text = u8'/d [' .. setting.my_tag_dep .. '] - ['.. setting.wave_tag_dep .. '] - [' .. setting.alien_tag_dep .. ']: '
	elseif setting.adress_format_dep == 5 then
		dep_text = u8'/d [' .. setting.my_tag_dep .. u8'] з.к. [' .. setting.alien_tag_dep .. ']: '
	end
end

function getMonthName(monthNumber)
	local months = {
		'Январь', 'Февраль', 'Март', 'Апрель', 
		'Май', 'Июнь', 'Июль', 'Август', 
		'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
	}
	
	if monthNumber >= 1 and monthNumber <= 12 then
		return months[monthNumber]
	else
		return '' 
	end
end

function getMonthInfo(month, year)
	if month < 1 or month > 12 then
		error("Месяц должен быть в диапазоне от 1 до 12")
	end
	local daysInMonth = {
		31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
	}
	local function isLeapYear(year)
		return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
	end
	if isLeapYear(year) then
		daysInMonth[2] = 29
	end
	local t = os.time({year = year, month = month, day = 1})
	local weekday = tonumber(os.date("%w", t))
	weekday = (weekday == 0) and 7 or weekday
	local daysString = tonumber(daysInMonth[month])

	return {weekday, daysString}
end

function get_today_date()
	local current_time = os.date("*t")

	local date_array = {
		current_time.day,
		current_time.month,
		current_time.year
	}

	return date_array
end
function new_text_block_popup()
    print(1)
    if imgui.BeginPopupModal(u8'Текстовый блок', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
        imgui.SetCursorPos(imgui.ImVec2(10, 10))
        print(2)
        if imgui.InvisibleButton(u8'##Закрыть окно текстового блока', imgui.ImVec2(16, 16)) then
            imgui.CloseCurrentPopup()
        end
        imgui.SetCursorPos(imgui.ImVec2(16, 16))
        imgui.BeginChild(u8'Текстовый блок добавление', imgui.ImVec2(346, 420), false, imgui.WindowFlags.NoScrollbar)
        if imgui.IsItemHovered() then
            imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
        else
            imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
        end
        gui.DrawLine({10, 31}, {346, 31}, cl.line)
        local text_multiline = imgui.new.char[512000]('')
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
        imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(5, 5))
        imgui.PushFont(font[3])
        imgui.InputTextMultiline('##Окно ввода текста шпаргалки', text_multiline, ffi.sizeof(text_multiline), imgui.ImVec2(803, 205))
        imgui.PopStyleColor()
        imgui.PopStyleVar(1)
        imgui.PopFont()
        imgui.EndChild()
        imgui.EndPopup()
    end
end
local text_multilineBlock = imgui.new.char[512000]('')
function new_action_popup()
	if imgui.BeginPopupModal(u8'Добавление действия', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.InvisibleButton(u8'##Закрыть окно добавления действия', imgui.ImVec2(16, 16)) then
			imgui.CloseCurrentPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 16))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
		end
		gui.DrawLine({10, 31}, {746, 31}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(6, 48))
		imgui.BeginChild(u8'Добавление действия в команду', imgui.ImVec2(746, 720), false, imgui.WindowFlags.NoScrollbar)
		local pix_y = -37
		local function add_action(NUM_ACTION, FA, TEXT_ACTION)
			pix_y = pix_y + 37
			local dopOt = 0
			local BOOL = false
			if NUM_ACTION == 11 then
			    dopOt = 300
			end
			imgui.SetCursorPos(imgui.ImVec2(11, 1 + pix_y))
			if imgui.InvisibleButton(u8'Добавить действие в команде в popup' .. NUM_ACTION, imgui.ImVec2(720, 27)) then
				bl_cmd.id_element = bl_cmd.id_element + 1
				BOOL = true
			end
			if imgui.IsItemActive() then
				gui.Draw({11, 1 + pix_y}, {718, 29}, cl.bg, 3, 15)
			elseif imgui.IsItemHovered() then
				gui.Draw({11, 1 + pix_y}, {718, 29}, cl.bg2, 3, 15)
			end
			
			gui.DrawEmp({10, 0 + pix_y}, {720, 31+dopOt}, cl.line, 5, 15, 1)
			gui.Draw({15, 5 + pix_y}, {21, 21}, FA.COLOR_BG, 3, 15)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
			gui.FaText(17 + FA.SDVIG[1], 7 + FA.SDVIG[2] + pix_y, FA.ICON, fa_font[3])
			imgui.PopStyleColor(1)
			gui.Text(44, 7 + pix_y, TEXT_ACTION, font[3])
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
			gui.FaText(710, 7 + pix_y, fa.PLUS, fa_font[3])
			imgui.PopStyleColor(1)
			if NUM_ACTION == 11 then
                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.50, 0.50, 0.50, 0.00))
                imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(15, 5))
                imgui.PushFont(font[3])
                imgui.InputTextMultiline('##Окно ввода текста шпаргалки', text_multilineBlock, ffi.sizeof(text_multilineBlock), imgui.ImVec2(718, 290))
                imgui.PopStyleColor()
                imgui.PopStyleVar(1)
                imgui.PopFont()
			end
			return BOOL
		end
		if add_action(1, {ICON = fa.SHARE, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {1, 0}}, 'Отправить сообщение в чат') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'SEND',
				''
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(2, {ICON = fa.KEYBOARD, COLOR_BG = imgui.ImVec4(1.00, 0.30, 0.00, 1.00), SDVIG = {0, 0}}, 'Открыть игровой чат с текстом') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'OPEN_INPUT',
				''
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(3, {ICON = fa.HOURGLASS, COLOR_BG = imgui.ImVec4(0.30, 0.75, 0.39, 1.00), SDVIG = {3, 0}}, 'Ожидание нажатия Enter') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'WAIT_ENTER'
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(4, {ICON = fa.SHARE_FROM_SQUARE, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {0, 0}}, 'Вывести информацию для себя') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'SEND_ME',
				''
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(5, {ICON = fa.SQUARE_ROOT_VARIABLE, COLOR_BG = imgui.ImVec4(0.00, 0.48, 1.00, 1.00), SDVIG = {0, 0}}, 'Задать для переменной') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'NEW_VAR',
				'', --> Имя переменной
				'' --> Значение переменной
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(6, {ICON = fa.BARS_STAGGERED, COLOR_BG = imgui.ImVec4(0.69, 0.32, 0.87, 1.00), SDVIG = {1, 0}}, 'Диалог выбора действия') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'DIALOG',
				'', --> Имя диалога
				{'', ''} --> Варианты действий
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(7, {ICON = fa.ARROWS_CROSS, COLOR_BG = imgui.ImVec4(0.56, 0.56, 0.58, 1.00), SDVIG = {2, 0}}, 'Если') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'IF',
				1, --> Условие
				{'', ''}, --> Входные данные,
				bl_cmd.id_element,
				1
			})
			table.insert(bl_cmd.act, number_i_cmd + 2, {
				'ELSE',
				bl_cmd.id_element
			})
			table.insert(bl_cmd.act, number_i_cmd + 3, {
				'END',
				bl_cmd.id_element
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(8, {ICON = fa.CLOCK_ROTATE_LEFT, COLOR_BG = imgui.ImVec4(1.00, 0.50, 0.88, 1.00), SDVIG = {1, 0}}, 'Изменить задержку отыгровки') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'DELAY',
				delay_act_def
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(9, {ICON = fa.HAND, COLOR_BG = imgui.ImVec4(0.56, 0.56, 0.58, 1.00), SDVIG = {1, 0}}, 'Остановить отыгровку') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'STOP'
			})
			imgui.CloseCurrentPopup()
		end
		if add_action(10, {ICON = fa.COMMENT, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {1, -1}}, 'Комментарий') then
			table.insert(bl_cmd.act, number_i_cmd + 1, {
				'COMMENT',
				''
			})
			imgui.CloseCurrentPopup()
		end
        if add_action(11, {ICON = fa.SHARE, COLOR_BG = imgui.ImVec4(1.00, 0.58, 0.00, 1.00), SDVIG = {1, 0}}, 'Открыть текстовых блок') then
            local ii = 1
            local t = ffi.string(text_multilineBlock)
            local result = {}
            for line in t:gmatch("(.-)\r?\n") do
                line = line:match("^%s*(.-)%s*$") -- Trim пробелы
                table.insert(result, line)
            end
            local lastLine = t:match(".*\r?\n(.-)$")
            if lastLine and lastLine ~= "" then
                lastLine = lastLine:match("^%s*(.-)%s*$")
                table.insert(result, lastLine)
            end
            for i, line in ipairs(result) do
                print(line)
                table.insert(bl_cmd.act, number_i_cmd + ii, {
                    'SEND',
                    line
                })
                ii = ii + 1
            end
            --table.insert(bl_cmd.act, number_i_cmd + 1, {
            --    'SEND',
            --    ''
            --})
            text_multilineBlock = imgui.new.char[512000]('')
            imgui.CloseCurrentPopup()
            --imgui.OpenPopup(u8'Текстовый блок')
        end
		imgui.EndChild()
		--new_text_block_popup()
		imgui.EndPopup()
	end
end

function tags_in_cmd()
	if popup_open_tags then
		popup_open_tags = false
		imgui.OpenPopup(u8'Теги в командах')
	end
	if imgui.BeginPopupModal(u8'Теги в командах', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.InvisibleButton(u8'##Закрыть окно тегов', imgui.ImVec2(16, 16)) then
			imgui.CloseCurrentPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 16))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
		end
		imgui.PushFont(font[2])
		imgui.SetCursorPos(imgui.ImVec2(172, 8))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8'Нажмите на тег, чтобы скопировать его')
		imgui.PopFont()
		gui.DrawLine({10, 32}, {536, 32}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(6, 33))
		imgui.BeginChild(u8'Выбор тегов в командах', imgui.ImVec2(540, 335), false)
		local all_list_tags = {
			{'{mynick}', 'Выведет Ваш никнейм на английском'},
			{'{myid}', 'Выведет Ваш id'},
			{'{mynickrus}', 'Выведет Ваш никнейм на русском'},
			{'{myrank}', 'Выведет Вашу должность'},
			{'{time}', 'Выведет текущее время'},
			{'{day}', 'Выведет текущий день'},
			{'{week}', 'Выведет текущую неделю'},
			{'{month}', 'Выведет текущий месяц'},
			{'{getplnick[id игрока]}', 'Выведет ник игрока по его ID'},
			{'{med7}', 'Выведет цену на новую мед. карту на 7 дней'},
			{'{med14}', 'Выведет цену на новую мед. карту на 14 дней'},
			{'{med30}', 'Выведет цену на новую мед. карту на 30 дней'},
			{'{med60}', 'Выведет цену на новую мед. карту на 60 дней'},
			{'{medup7}', 'Выведет цену на обновлённую мед. карту на 7 дней'},
			{'{medup14}', 'Выведет цену на обновлённую мед. карту на 14 дней'},
			{'{medup30}', 'Выведет цену на обновлённую мед. карту на 30 дней'},
			{'{medup60}', 'Выведет цену на обновлённую мед. карту на 60 дней'},
			{'{pricenarko}', 'Выведет цену на снятие укропозависимости'},
			{'{pricerecept}', 'Выведет цену на рецепт'},
			{'{pricetatu}', 'Выведет цену удаление татуировки с тела'},
			{'{priceant}', 'Выведет цену на антибиотик'},
			{'{pricelec}', 'Выведет цену на лечение'},
			{'{priceosm}', 'Выведет цену на мед. осмотр'},
			{'{priceauto1}', 'Выведет цену на авто на 1 месяц'},
			{'{priceauto2}', 'Выведет цену на авто на 2 месяца'},
			{'{priceauto3}', 'Выведет цену на авто на 3 месяца'},
			{'{pricemoto1}', 'Выведет цену на мото на 1 месяц'},
			{'{pricemoto2}', 'Выведет цену на мото на 2 месяца'},
			{'{pricemoto3}', 'Выведет цену на мото на 3 месяца'},
			{'{pricefly}', 'Выведет цену на полёты'},
			{'{pricefish1}', 'Выведет цену на рыбалку на 1 месяц'},
			{'{pricefish2}', 'Выведет цену на рыбалку на 2 месяца'},
			{'{pricefish3}', 'Выведет цену на рыбалку на 3 месяца'},
			{'{priceswim1}', 'Выведет цену на водный транспорт на 1 месяц'},
			{'{priceswim2}', 'Выведет цену на водный транспорт на 2 месяца'},
			{'{priceswim3}', 'Выведет цену на водный транспорт на 3 месяца'},
			{'{pricegun1}', 'Выведет цену на оружие на 1 месяц'},
			{'{pricegun2}', 'Выведет цену на оружие на 2 месяца'},
			{'{pricegun3}', 'Выведет цену на оружие на 3 месяца'},
			{'{pricehunt1}', 'Выведет цену на охоту на 1 месяц'},
			{'{pricehunt2}', 'Выведет цену на охоту на 2 месяца'},
			{'{pricehunt3}', 'Выведет цену на охоту на 3 месяца'},
			{'{priceexc1}', 'Выведет цену на раскопки на 1 месяц'},
			{'{priceexc2}', 'Выведет цену на раскопки на 2 месяца'},
			{'{priceexc3}', 'Выведет цену на раскопки на 3 месяца'},
			{'{pricetaxi1}', 'Выведет цену на такси на 1 месяц'},
			{'{pricetaxi2}', 'Выведет цену на такси на 2 месяца'},
			{'{pricetaxi3}', 'Выведет цену на такси на 3 месяца'},
			{'{pricemeh1}', 'Выведет цену на механика на 1 месяц'},
			{'{pricemeh2}', 'Выведет цену на механика на 2 месяца'},
			{'{pricemeh3}', 'Выведет цену на механика на 3 месяца'},
			{'{sex[муж. текст][жен. текст]}', 'Добавит текст в соответствии с выбранным полом'},
			{'{dialoglic[id лицензии][id срока][id игрока]}', 'Автовыбор диалога с лицензией'},
			{'{target}', 'Выведет id с последнего прицела на игрока'},
			{'{prtsc}', 'Сделает скриншот игры F8'},
			{'{random[мин. число][мах. число]}', 'Выведет рандомное число'},
			{'{nearplayer}', 'Получить id ближайшего игрока'},
			{'{getlevel[id игрока]}', 'Получить игровой уровень игрока'},
			{'{spcar}', 'Заспавнить транспорт организации (/lmenu)'},
			{'{PhoneApp[номер приложения]}', 'Открывает приложение в телефоне по списку (всего 36 пиложений)'}
		}
		
		if an[25][1] > 0 then
			an[25][1] = an[25][1] - (anim * 2)
		end
		local pos_y_list = 0
		imgui.PushFont(font[3])
		for i = 1, #all_list_tags do
			local calc_text = imgui.CalcTextSize(u8(all_list_tags[i][1]))
			imgui.SetCursorPos(imgui.ImVec2(10, 5 + pos_y_list))
			imgui.Text(u8(all_list_tags[i][1]))
			imgui.SetCursorPos(imgui.ImVec2(10 + calc_text.x + 7, 5 + pos_y_list))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8(all_list_tags[i][2]))
			if an[25][2] == i then
				imgui.SetCursorPos(imgui.ImVec2(10, 5 + pos_y_list))
				imgui.TextColored(imgui.ImVec4(0.20, 0.78, 0.35, an[25][1]), u8(all_list_tags[i][1]))
				imgui.SetCursorPos(imgui.ImVec2(10 + calc_text.x + 7, 5 + pos_y_list))
				imgui.TextColored(imgui.ImVec4(0.20, 0.78, 0.35, an[25][1]), u8(all_list_tags[i][2]))
			end
			imgui.SetCursorPos(imgui.ImVec2(5, pos_y_list + 2))
			if imgui.InvisibleButton(u8'##Скопировать тег для команды ' .. i, imgui.ImVec2(519, 23)) then
				if insert_tag_popup[3] then
					insert_tag_popup[2] = u8(all_list_tags[i][1])
					insert_tag_popup[3] = false
					imgui.CloseCurrentPopup()
				else
					imgui.SetClipboardText(u8(all_list_tags[i][1]))
					an[25][1] = 3
					an[25][2] = i
				end
			end
			
			pos_y_list = pos_y_list + 25
		end
		imgui.PopFont()
		
		imgui.Dummy(imgui.ImVec2(0, 10))
		imgui.EndChild()
		imgui.EndPopup()
	end
end

function tags_in_call()
	if popup_open_tags_call then
		popup_open_tags_call = false
		imgui.OpenPopup(u8'Теги в вызовах')
	end
	if imgui.BeginPopupModal(u8'Теги в вызовах', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.InvisibleButton(u8'##Закрыть окно тегов вызовов', imgui.ImVec2(16, 16)) then
			imgui.CloseCurrentPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 16))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
		end
		imgui.PushFont(font[2])
		imgui.SetCursorPos(imgui.ImVec2(172, 8))
		imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8'Нажмите на тег, чтобы скопировать его')
		imgui.PopFont()
		gui.DrawLine({10, 32}, {536, 32}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(6, 33))
		imgui.BeginChild(u8'Выбор тегов в вызовах', imgui.ImVec2(540, 335), false)
		local all_list_tags = {
			{'{level}', 'Выведет уровень выбранного пожара'},
			{'{mynick}', 'Выведет Ваш никнейм на английском'},
			{'{myid}', 'Выведет Ваш id'},
			{'{mynickrus}', 'Выведет Ваш никнейм на русском'},
			{'{myrank}', 'Выведет Вашу должность'},
			{'{sex[муж. текст][жен. текст]}', 'Добавит текст в соответствии с выбранным полом'},
		}
		
		if an[30][1] > 0 then
			an[30][1] = an[30][1] - (anim * 2)
		end
		local pos_y_list = 0
		imgui.PushFont(font[3])
		for i = 1, #all_list_tags do
			local calc_text = imgui.CalcTextSize(u8(all_list_tags[i][1]))
			imgui.SetCursorPos(imgui.ImVec2(10, 5 + pos_y_list))
			imgui.Text(u8(all_list_tags[i][1]))
			imgui.SetCursorPos(imgui.ImVec2(10 + calc_text.x + 7, 5 + pos_y_list))
			imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), u8(all_list_tags[i][2]))
			if an[30][2] == i then
				imgui.SetCursorPos(imgui.ImVec2(10, 5 + pos_y_list))
				imgui.TextColored(imgui.ImVec4(0.20, 0.78, 0.35, an[30][1]), u8(all_list_tags[i][1]))
				imgui.SetCursorPos(imgui.ImVec2(10 + calc_text.x + 7, 5 + pos_y_list))
				imgui.TextColored(imgui.ImVec4(0.20, 0.78, 0.35, an[30][1]), u8(all_list_tags[i][2]))
			end
			imgui.SetCursorPos(imgui.ImVec2(5, pos_y_list + 2))
			if imgui.InvisibleButton(u8'##Скопировать тег для команды ' .. i, imgui.ImVec2(519, 23)) then
				if insert_tag_popup[3] then
					insert_tag_popup[2] = u8(all_list_tags[i][1])
					insert_tag_popup[3] = false
					imgui.CloseCurrentPopup()
				else
					imgui.SetClipboardText(u8(all_list_tags[i][1]))
					an[30][1] = 3
					an[30][2] = i
				end
			end
			
			pos_y_list = pos_y_list + 25
		end
		imgui.PopFont()
		
		imgui.Dummy(imgui.ImVec2(0, 10))
		imgui.EndChild()
		imgui.EndPopup()
	end
end

function cmd_edit(nm_cmd_edit, cmd_cur)
	local new_cmd_return
	if imgui.BeginPopupModal(nm_cmd_edit, null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.InvisibleButton(u8'##Закрыть ' .. nm_cmd_edit, imgui.ImVec2(16, 16)) then
			lockPlayerControl(false)
			edit_cmd = false
			imgui.CloseCurrentPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 16))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
		end
		imgui.SetCursorPos(imgui.ImVec2(10, 35))
		imgui.BeginChild(u8'Назначение команды ' .. nm_cmd_edit, imgui.ImVec2(357, 171), false, imgui.WindowFlags.NoScrollbar)
		
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(10, 0))
		imgui.Text(u8'Введите необходимую команду')
		imgui.SetCursorPos(imgui.ImVec2(10, 25))
		imgui.Text(u8'Текущая команда:')
		imgui.SetCursorPos(imgui.ImVec2(135, 25))
		if cmd_cur == '' then
			imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), u8'Отсутствует')
		else
			imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22, 1.00), '/' .. cmd_cur)
		end
		gui.DrawLine({0, 50}, {381, 50}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(10, 70))
		imgui.Text('/')
		new_cmd = gui.InputText({27, 71}, 300, new_cmd, u8'Назначение команды', 60, u8'Введите команду', 'en')
		gui.DrawLine({0, 103}, {381, 103}, cl.line)
		local bool_new_cmd = false
		if #all_cmd ~= 0 then
			for i = 1, #all_cmd do
				if all_cmd[i] == new_cmd and new_cmd ~= cmd_cur then
					bool_new_cmd = true
					break
				end
			end
		end
		
		if not bool_new_cmd then
			imgui.SetCursorPos(imgui.ImVec2(67, 110))
			imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), u8'Всё хорошо! Можете применять.')
			if gui.Button(u8'Применить', {10, 132}, {158, 27}) then
				if new_cmd ~= cmd_cur then
					if #all_cmd ~= 0 then
						for m = 1, #all_cmd do
							if all_cmd[m] == cmd_cur then
								sampUnregisterChatCommand(all_cmd[m])
								table.remove(all_cmd, m)
								new_cmd_return = ''
								break
							end
						end
					end
					if new_cmd ~= '' then
						table.insert(all_cmd, new_cmd)
						new_cmd_return = new_cmd
					end
				end
				
				lockPlayerControl(false)
				edit_cmd = false
				imgui.CloseCurrentPopup()
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(69, 110))
			imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Такая команда уже существует!')
			if gui.Button(u8'Применить', {10, 132}, {158, 27}, false) then
				
			end
		end
		imgui.PopFont()
		
		if gui.Button(u8'Отменить', {179, 132}, {158, 27}) then
			lockPlayerControl(false)
			edit_cmd = false
			imgui.CloseCurrentPopup()
		end
		
		imgui.EndChild()
		imgui.EndPopup()
	end
	
	return new_cmd_return
end

function key_edit(name_popup_key, key_cur)
	if imgui.BeginPopupModal(name_popup_key, null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		if imgui.InvisibleButton(u8'##Закрыть окно' .. name_popup_key, imgui.ImVec2(16, 16)) then
			lockPlayerControl(false)
			edit_key = false
			imgui.CloseCurrentPopup()
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 16))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
		end
		imgui.SetCursorPos(imgui.ImVec2(10, 40))
		imgui.BeginChild(u8'Назначение клавиши' .. name_popup_key, imgui.ImVec2(390, 181), false, imgui.WindowFlags.NoScrollbar)
		
		imgui.PushFont(font[3])
		imgui.SetCursorPos(imgui.ImVec2(10, 0))
		imgui.Text(u8'Нажмите на необходимую клавишу или комбинацию')
		imgui.SetCursorPos(imgui.ImVec2(10, 25))
		imgui.Text(u8'Текущее сочетание:')
		imgui.SetCursorPos(imgui.ImVec2(145, 25))
		if #key_bool_cur == 0 then
			imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22 ,1.00), u8'Отсутствует')
		else
			local all_key = {}
			for i = 1, #key_bool_cur do
				table.insert(all_key, vkeys.id_to_name(key_bool_cur[i]))
			end
			imgui.TextColored(imgui.ImVec4(0.90, 0.63, 0.22 ,1.00), table.concat(all_key, ' + '))
		end
		imgui.PopFont()
		gui.DrawLine({0, 50}, {381, 50}, cl.line)
		
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
				if currently_pressed_keys[i] ~= u8'1:ЛКМ' and currently_pressed_keys[i] ~= '145:Scrol Lock' 
				and currently_pressed_keys[i] ~= u8'2:ПКМ' then
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
			current_key[1] = u8''
		end
		if current_key[1] ~= u8'Такая комбинация уже существует' then
			imgui.PushFont(bold_font[3])
			local calc = imgui.CalcTextSize(current_key[1])
			imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 80))
			if calc.x >= 385 then
				imgui.PopFont()
				imgui.PushFont(font[3])
				calc = imgui.CalcTextSize(current_key[1])
				imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
			end
			imgui.TextColored(imgui.ImVec4(0.08, 0.64, 0.11, 1.00), current_key[1])
			imgui.PopFont()
		else
			imgui.PushFont(font[3])
			local calc = imgui.CalcTextSize(current_key[1])
			imgui.SetCursorPos(imgui.ImVec2(195 - calc.x / 2, 90))
			imgui.TextColored(imgui.ImVec4(0.90, 0.22, 0.22, 1.00), current_key[1])
			imgui.PopFont()
		end
		
		if gui.Button(u8'Применить', {0, 144}, {185, 29}) then
			if not compare_array_disable_order(key_cur[2], current_key[2]) then
				local is_hot_key_done = false
				local num_hot_key_remove = 0
				local remove_sd = false
				
				if #current_key[2] == 0 and #key_cur[2] ~= 0 then
					remove_sd = true
					for i = 1, #all_keys do
						if compare_array_disable_order(all_keys[i], key_cur[2]) then
							num_hot_key_remove = i
							break
						end
					end
				else
					if #all_keys ~= 0 and #current_key[2] ~= 0 then
						for i = 1, #all_keys do
							is_hot_key_done = compare_array_disable_order(all_keys[i], current_key[2])
							if is_hot_key_done then break end
						end
						for i = 1, #all_keys do
							if compare_array_disable_order(all_keys[i], key_cur[2]) then
								num_hot_key_remove = i
								break
							end
						end
					end
				end
				if not remove_sd then
					if is_hot_key_done then current_key = {u8'Такая комбинация уже существует', {}} end
					if not is_hot_key_done then
						if num_hot_key_remove ~= 0 then
							table.remove(all_keys, num_hot_key_remove)
							rkeys.unRegisterHotKey(key_cur[2])
						end
						key_cur[2] = current_key[2]
						key_cur[1] = current_key[1]
						table.insert(all_keys, current_key[2])
						rkeys.registerHotKey(current_key[2], 3, true, function() on_hot_key(key_cur[2]) end)
						lockPlayerControl(false)
						edit_key = false
						imgui.CloseCurrentPopup()
						return {true, key_cur}
					end
				else
					table.remove(all_keys, num_hot_key_remove)
					rkeys.unRegisterHotKey(key_cur[2])
					key_cur = {'', {}}
					lockPlayerControl(false)
					edit_key = false
					imgui.CloseCurrentPopup()
					return {true, key_cur}
				end
			else
				lockPlayerControl(false)
				edit_key = false
				imgui.CloseCurrentPopup()
				return {false, key_cur}
			end
			save()
		end
		if gui.Button(u8'Очистить', {194, 144}, {186, 29}) then
			current_key = {'', {}}
		end
			
		imgui.EndChild()
		imgui.EndPopup()
	end
	
	return {false, key_cur}
end

function draw_gradient_border(time, speed_border)
	local function transfusion(speed_f, pl_rgb)
		local r = math.floor(math.sin((os.clock() + pl_rgb) * speed_f) * 127 + 128) / 255
		local g = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 2) * 127 + 128) / 255
		local b = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 4) * 127 + 128) / 255
		
		return imgui.ImVec4(r, g, b, 1.00)
	end
	local color = transfusion(speed_border, 0.15)
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + 4, p.y + 4), imgui.ImVec2(p.x + 844, p.y + 444), imgui.GetColorU32Vec4(color), 11, 15, 2)
end

function draw_gradient_image_music(speed_border, x_b, y_b, s_b_x, s_b_y, radius)
	local function transfusion(speed_f, pl_rgb, visible_text)
		local r = math.floor(math.sin((os.clock() + pl_rgb) * speed_f) * 127 + 128) / 255
		local g = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 2) * 127 + 128) / 255
		local b = math.floor(math.sin((os.clock() + pl_rgb) * speed_f + 4) * 127 + 128) / 255
		
		return imgui.ImVec4(r, g, b, (visible_text or 1))
	end
	
	imgui.SetCursorPos(imgui.ImVec2(0, 0))
	local p = imgui.GetCursorScreenPos()
	local base_x, base_y = p.x + x_b, p.y + y_b
	local width, height = s_b_x, s_b_y
	local color2 = transfusion(speed_border, 0.15, 0.4)

	for i = 1, 15 do
		local alpha = color2.w * (1 - i / 15)
		local color = transfusion(speed_border, 0.15, alpha)
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(base_x - i, base_y - i), imgui.ImVec2(base_x + width + i, base_y + height + i), imgui.GetColorU32Vec4(color), radius or 15 , 15)
	end
end

win.main = imgui.OnFrame(
	function() return windows.main[0] end,
	function(main)
		local coud = imgui.Cond.FirstUseEver
		if anim_func or close_win_anim then
			coud = imgui.Cond.Always
		end
		if anim_func then
			close_win_anim = false
			if win_x > sx / 2 then
				win_x = win_x - (anim * 4500)
				if win_x <= sx / 2 then 
					win_x = sx / 2 
					anim_func = false
				end
			end
		end
        imgui.SetNextWindowPos(imgui.ImVec2(win_x, win_y), coud, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(848, 448)) --> 848 x 448
        imgui.Begin('Main', windows.main,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoResize)
		bug_fix_input()
		
		if close_win_anim then
			main.HideCursor = true
		else
			main.HideCursor = false
		end
		--> Основной фон и полигоны
		if setting.first_start then
			local times = os.clock() * 2
			draw_gradient_border(times, 0.9)
		end
		gui.Draw({4, 4}, {840, 440}, cl.main, 12, 15)
	
		if setting.first_start then
			if first_start == 0 then
				imgui.SetCursorPos(imgui.ImVec2(317, 187))
				imgui.PushFont(bold_font[2])
				an[1] = an[1] - (anim * 0.7)
				gui.TextGradient('Привет', 0.5, an[1])
				imgui.PopFont()
				
				if an[1] < 0 then first_start = 1 end
			elseif first_start == 1 then
				imgui.SetCursorPos(imgui.ImVec2(45, 187))
				imgui.PushFont(bold_font[2])
				if an[2] >= 2 then stop_anim[1] = true end
				if not stop_anim[1] then
					an[2] = an[2] + (anim * 0.7)
				else
					an[2] = an[2] - (anim * 0.7)
				end
				
				gui.TextGradient('Давайте настроим хелпер', 0.5, an[2])
				imgui.PopFont()
				
				if an[2] < 0 then first_start = 2 end
			elseif first_start == 2 then
				imgui.SetCursorPos(imgui.ImVec2(78, an[4]))
				imgui.PushFont(bold_font[2])
				if an[3] <= 1.2 then
					an[3] = an[3] + (anim * 0.7)
				elseif an[4] > 40 then
					an[4] = an[4] - (anim * 290)
				end
				
				gui.TextGradient('Выберите организацию', 0.5, an[3])
				imgui.PopFont()
				
				if an[4] <= 40 then
					gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
					if gui.Button(u8'Продолжить', {715, 403}, {104, 30}) then
						first_start = 3
					end
					gui.Button(u8'Назад', {640, 403}, {62, 30}, false)
					--					setting.org = gui.LT_First_Start({300, 110}, {249, 273}, {u8'Больница Лос-Сантос', u8'Больница Сан-Фиерро', u8'Больница Лас-Вентурас', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Правительство', u8'Армия Лос-Сантос', u8'Армия Сан-Фиерро', u8'Пожарный департамент', u8'Тюрьма строгого режима', u8'СМИ'}, setting.org, u8'Выбрать организацию')
					setting.org = gui.LT_First_Start({300, 116}, {249, 248}, {u8'Больница Лос-Сантос', u8'Больница Сан-Фиерро', u8'Больница Лас-Вентурас', u8'Больница Джефферсон', u8'Центр Лицензирования', u8'Правительство', u8'Армия Лос-Сантос', u8'Армия Сан-Фиерро', u8'Пожарный департамент', u8'Тюрьма строгого режима'}, setting.org, u8'Выбрать организацию')
				end
			elseif first_start == 3 then
				imgui.PushFont(bold_font[2])
				imgui.SetCursorPos(imgui.ImVec2(120, an[4]))
				gui.TextGradient('Никнейм на русском', 0.5, 1.00)
				imgui.PopFont()
				gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				if not setting.name_rus:find('%S+%s+%S+') then
					gui.Button(u8'Продолжить', {715, 403}, {104, 30}, false)
				else
					if gui.Button(u8'Продолжить', {715, 403}, {104, 30}) then
						first_start = 4
					end
				end
				if gui.Button(u8'Назад', {640, 403}, {62, 30}) then
					first_start = 2
				end
				
				setting.name_rus = gui.InputText({272, 231}, 300, setting.name_rus, u8'Имя на русском', 60, u8'Введите Ваш никнейм на русском', 'rus')
			elseif first_start == 4 then
				imgui.PushFont(bold_font[2])
				imgui.SetCursorPos(imgui.ImVec2(83, an[4]))
				gui.TextGradient('Пол Вашего персонажа', 0.5, 1.00)
				imgui.PopFont()
				gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				if gui.Button(u8'Продолжить', {715, 403}, {104, 30}) then
					first_start = 5
				end
				if gui.Button(u8'Назад', {640, 403}, {62, 30}) then
					first_start = 3
				end
				
				setting.sex = gui.ListTableHorizontal({304, 229}, {u8'Мужской', u8'Женский'}, setting.sex, u8'Выбрать пол персонажа')
			elseif first_start == 5 then
				imgui.PushFont(bold_font[2])
				imgui.SetCursorPos(imgui.ImVec2(160, an[4]))
				gui.TextGradient('Тема оформления', 0.5, 1.00)
				imgui.PopFont()
				
				gui.Draw({148, 162}, {252, 132}, imgui.ImVec4(0.98, 0.98, 0.98, 1.00), 7, 15)
				gui.Draw({448, 162}, {252, 132}, imgui.ImVec4(0.10, 0.10, 0.10, 1.00), 7, 15)
				
				--> Дизайн окон выбора темы
				gui.Draw({148, 162}, {252, 20}, imgui.ImVec4(0.91, 0.89, 0.76, 1.00), 7, 3)
				gui.Draw({448, 162}, {252, 20}, imgui.ImVec4(0.13, 0.13, 0.13, 1.00), 7, 3)
				gui.Draw({148, 274}, {252, 20}, imgui.ImVec4(0.91, 0.89, 0.76, 1.00), 7, 12)
				gui.Draw({448, 274}, {252, 20}, imgui.ImVec4(0.13, 0.13, 0.13, 1.00), 7, 12)
				gui.Draw({181, 279}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
				gui.Draw({224, 279}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
				gui.Draw({267, 279}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
				gui.Draw({310, 279}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
				gui.Draw({353, 279}, {10, 10}, imgui.ImVec4(0.81, 0.79, 0.66, 1.00), 3, 15)
				gui.Draw({481, 279}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
				gui.Draw({524, 279}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
				gui.Draw({567, 279}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
				gui.Draw({610, 279}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
				gui.Draw({653, 279}, {10, 10}, imgui.ImVec4(0.20, 0.20, 0.20, 1.00), 3, 15)
				gui.Draw({244, 167}, {60, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
				gui.Draw({158, 197}, {200, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
				gui.Draw({158, 222}, {100, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
				gui.Draw({158, 247}, {150, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
				gui.Draw({544, 167}, {60, 10}, imgui.ImVec4(0.60, 0.60, 0.60, 0.30), 15, 15)
				gui.Draw({458, 197}, {200, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
				gui.Draw({458, 222}, {100, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
				gui.Draw({458, 247}, {150, 10}, imgui.ImVec4(0.40, 0.40, 0.40, 0.30), 15, 15)
				gui.DrawCircle({158, 172}, 4, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
				gui.DrawCircle({458, 172}, 4, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
				
				if setting.cl == 'White' then
					gui.DrawEmp({148, 162}, {252, 132}, cl.def, 7, 15, 3)
				else
					gui.DrawEmp({448, 162}, {252, 132}, cl.def, 7, 15, 3)
				end
				
				imgui.SetCursorPos(imgui.ImVec2(148, 162))
				if imgui.InvisibleButton(u8'##Выбрать светлую тему', imgui.ImVec2(252, 132)) then
					if setting.cl ~= 'White' then
						change_design('White')
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(448, 162))
				if imgui.InvisibleButton(u8'##Выбрать тёмную тему', imgui.ImVec2(252, 132)) then
					if setting.cl ~= 'Black' then
						change_design('Black')
					end
				end
				
				gui.Text(247, 309, 'Светлая', font[3])
				gui.Text(550, 309, 'Тёмная', font[3])
				
				gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				if gui.Button(u8'Продолжить', {715, 403}, {104, 30}) then
					first_start = 6
				end
				if gui.Button(u8'Назад', {640, 403}, {62, 30}) then
					first_start = 4
				end
			elseif first_start == 6 then
				imgui.PushFont(bold_font[2])
				imgui.SetCursorPos(imgui.ImVec2(29, an[4]))
				gui.TextGradient('Лицензионное соглашение', 0.5, 1.00)
				imgui.PopFont()
				gui.Draw({28, 114}, {792, 253}, cl.tab, 7, 15)
				imgui.SetCursorPos(imgui.ImVec2(38, 114))
				imgui.BeginChild(u8'Лицензионное соглашение', imgui.ImVec2(782, 253), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollWithMouse)
				imgui.Scroller(u8'Лицензионное соглашение', img_step[1][0], img_duration[1][0], imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
				imgui.SetCursorPosY(14)
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'1. Основные термины и определения')
				imgui.PopFont()
				imgui.PushFont(font[3])
				imgui.TextWrapped(u8'1.1 Правообладатель - ИТД Марсель Афанасьев: это лицо, которое обладает правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений. Термин "Правообладатель" также включает в себя разработчика, менеджера, директора, поставщика и других ответственных сторон, участвующих в создании, управлении и поставке Программы (см. определение ниже). Это объединяющий термин, включающий все заинтересованные стороны, которые имеют право предоставлять разрешения на использование Программы (см. определение ниже) и управлять правами доступа в соответствии с данным Лицензионным соглашением (данный договор между двумя сторонами: (Пользователь (см. определение ниже) и Правообладатель), далее "Соглашение").\nПравообладателем данной Программы (см. определение ниже), а также официальным обладателем авторских прав и интеллектуальной собственности, является единственное лицо. Все иные лица, причастные к созданию, разработке, поддержке и другим терминам включающих в себя определение из термина Правообладателя, за исключением правами собственности на интеллектуальную собственность, такую как авторские права, патенты, торговые марки и другие права, связанные с созданием и использованием интеллектуальных продуктов или изобретений данного программного обеспечения (далее "ПО"), являются партнёрами (далее "Партнёр", "Партнёры") Правообладателя.\n')
				imgui.TextWrapped(u8'Термин относится к ПО, в котором находится данное Лицензионное соглашение или на одном виртуальном, облачном или удалённом носителе, учётной записи одного Пользователя всего ресурса, сайта или хранилища, на котором расположено ПО.\n\n')
				imgui.TextWrapped(u8'1.2 Программа - это ПО, принадлежащее Правообладателю, которое было приобретено и установлено на Носитель (см. определение ниже) технического устройства. Из списка выпущенных Правообладателем Программ, данный термин относится ко всем ПО, включающих в своём названии словосочетание "State Helper Lite", написанное на английском языке в любом из возможных вариантов регистра букв.\nНаименование ПО можно найти в свойствах файла установленного с источников Правообладателя в случае, если файл не был отредактирован в последствии перемещения его на Носитель (см. определение ниже) технического устройства.\n\n')
				imgui.TextWrapped(u8'1.3 Носитель - устройство или средство, используемое для хранения и передачи данных. Это может быть физический объект, такой как жёсткий диск, USB-флешка, CD, DVD, Blu-ray диск или другие съёмные устройства хранения информации.\n\n1.4 Arizona Role Play - это проект ролевой игры (Role-Play) на платформе SA:MP (San Andreas Multiplayer), принадлежащий игровой компании Arizona Games. В этом проекте игроки могут взаимодействовать в виртуальном мире, исполняя определенные роли и выполняя задания в атмосфере, созданной на базе игры Grand Theft Auto: San Andreas с использованием мультиплеерной платформы SA:MP.\n\n1.5 Руководство пользователя - документ, который содержит инструкцию о том, как правильно использовать Программу, предоставленную Правообладателем.\n\n1.6 Пользователь - человек, установивший или использующий Программу, предоставленную Правообладателем.\n\n1.7 Блокировка программы - это техническая или программная мера, которая преднамеренно ограничивает доступ Пользователя к определенным функциям, данным или ресурсам Программы.\n\n1.8 Интернет - информационно-телекоммуникационная сеть, т. е. технологическая система, предназначенная для передачи по линиям связи информации, доступ к которой осуществляется с использованием средств вычислительной техники.\n\n1.9 Установка - процесс размещения Программы на компьютере или устройстве, чтобы она стала доступной и готовой к использованию. Во время установки происходит копирование файлов Программы на жёсткий диск или другое физическое хранилище, кроме тех, доступ к которым требует наличия Интернета.\n\n')
				imgui.TextWrapped(u8'1.10 Игра - конкретный вид развлекательной деятельности, не связанный с непосредственными задачами жизнеобеспечения, выполняющий функции заполнения досуга человека.\n\n1.11 Версия программы - присвоенный номер Программы, позволяющий определить новизну ПО, т. е. дату его выхода, а также различия относительно предыдущих версий Программы.\nВерсия программы отображена в самой Программе под соответствующим названием включающая в своём словосочетании слово "Версия".\n\n1.12 Закрытое тестирование - процесс исследования, испытания ПО, имеющий своей целью проверку соответствия между реальным поведением программы и её ожидаемым поведением на конечном наборе тестов, выбранных определённым образом.\nПроцесс осуществляется без учёта возможности публикации такого ПО в общий доступ, дающий возможность любому Пользователю осуществить установку ПО.\nТермин применяется к Программе, имеющей в своём программном коде заданную условную переменную "Beta" не соответствующей второму числу текущей Версии программы.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'2. Лицензия')
				imgui.PopFont()
				imgui.TextWrapped(u8'2.1 Правообладатель предоставляет Вам неисключительную лицензию на использование Программы для упрощения процесса Игры на проекте Arizona Role Play, описанных в Руководстве пользователя, при условии, в котором Вами соблюдены все необходимые требования, описанные в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\nВ случае использования Программы для тестирования функциональности, Правообладатель предоставляет Вам неисключительную лицензию на тестирование программы при условии соблюдения Вами всех необходимых требований, описанных в Руководстве пользователя, а также всех ограничений и условий использования Программы, указанных в настоящем Соглашении.\n\n')
				imgui.TextWrapped(u8'2.2 При соблюдении определённых условий Вы можете создать копию программы типа "Закрытое тестирование" с единственной целью архивирования и замены правомерно установленного экземпляра в случае его утери, уничтожения или непригодности. Тем не менее, использование такой копии для иных целей запрещено, и владение ею должно прекратиться, если обладание правомерным экземпляром программы прекращается.\n\n')
				imgui.TextWrapped(u8'2.3 После установки программы Вам, по возможности, предоставляется право получать от Правообладателя или его Партнёров:\n- новые версии ПО по мере их выхода (через Интернет)\n- техническую поддержку (через Интернет)\n- доступ к информационным и вспомогательным ресурсам Правообладателя.\nДанные возможности не могут быть гарантированы Правообладателем и в праве перестать быть доступными любому Пользователю Программы в любой момент времени без объяснения причин.\n\n')
				imgui.TextWrapped(u8'2.4 В случае установки Программы типа "Закрытое тестирование" через Интернет, Вы имеете право использовать такую копию Программы исключительно на одном техническом устройстве или Ностеле. Количество созданных копий Программы на одном устройстве неограниченно. Запрещается создавать, распространять, передавать копию такой Программы через облачные хранилища, где доступ к ней могут получить другие лица, кроме Вас. Запрещается копировать такую Программу на носитель, физический доступ к которому у Вас отсутствует. Запрещено устанавливать такую копию Программу на любой носитель с источников, не включённых в перечень, описанный в данном Соглашении.\n\n')
				imgui.TextWrapped(u8'2.5 Программа считается установленной с момента её размещения на Носитель Пользователя, независимо от того, запущена она впоследствии Пользователем или нет.\n\n')
				
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'3. Обновления')
				imgui.PopFont()
				imgui.TextWrapped(u8'После установки программы на Носитель, Правообладатель предоставляет возможность Пользователям выбирать способ обновления Программы. Если Пользователь сам решит использовать автоматическое обновление, поставив соответствующую галочку в самой Программе, тогда обновления будут проводиться без дополнительного разрешения или согласия с его стороны.\n\nВ противном случае, если Пользователь не выбрал автоматическое обновление, процесс установки обновления будет требовать подтверждения Пользователя в самой Программе. Пользователю будет предоставлена возможность ознакомиться с деталями обновления и дать согласие на его установку перед началом процесса.\n\n')
				imgui.TextWrapped(u8'Независимо от выбранного способа обновления, каждое обновление будет регулироваться настоящим Соглашением, а содержание, функции и возможности обновленной Программы определяются исключительно Правообладателем. Эти обновления могут включать как добавление, так и удаление функций Программы, а также полную замену Программы. При этом Вам может быть ограничено использование Программы или устройства (включая определенные функции) до тех пор, пока обновление не будет полностью установлено или активировано.\n\nПравообладатель может прекратить предоставление поддержки Программы, пока Вы не установите все доступные обновления. Необходимость и периодичность предоставления обновлений определяется Правообладателем по его усмотрению, и Правообладатель не обязан предоставлять Вам обновления. Также Правообладатель может прекратить предоставление обновлений для версий Программы, отличных от наиболее новой версии, или для обновлений, которые не поддерживают использование Программы с различными версиями операционных систем или другим ПО.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'4. Права собственности')
				imgui.PopFont()
				imgui.TextWrapped(u8'4.1 Программа и её программный код являются интеллектуальной собственностью Правообладателя и защищены применимым авторским правом, а также международными договорами и законодательством Российской Федерации. Если Вы являетесь Пользователем, установившим Программу на законных основаниях, то Вы имеете право просматривать открытый программный код Программы. Предоставляя свои комментарии и предложения, касающиеся Программы, Вы предоставляете Правообладателю разрешение на их использование при разработке своих настоящих или будущих продуктов или услуг. При этом, Вы соглашаетесь, что такое использование не потребует выплаты компенсации и дополнительного разрешения от Вас на хранение или использование Ваших материалов.\n\n')
				imgui.TextWrapped(u8'4.2 Помимо указанных в настоящем Соглашении, владение Программой и её использование не предоставляют Вам какие-либо права на Программу или программный код, включая авторские права, патенты, торговые знаки и другие права интеллектуальной собственности. Все такие права полностью принадлежат Правообладателю Программы.\n\n')
				imgui.TextWrapped(u8'4.3 Вы не имеете права копировать или использовать Программу или её программный код, за исключением случаев, описанных в разделе 2 настоящего Соглашения.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'5. Конфиденциальность')
				imgui.PopFont()
				imgui.TextWrapped(u8'Вы даете Правообладателю и партнёрам Правообладателя согласие на использование Ваших данных в соответствии с политикой конфиденциальности. Вы осознаете, что Ваши данные будут использоваться для различных целей, таких как обработка событий использования Программы, улучшения Программы, предоставления Вам информации об установленной Программе и предложение Вам других Программ.\n\nВы также подтверждаете, что Правообладатель может передавать Ваши данные партнёрам Правообладателя, таким как поставщики платформы электронной коммерции, обработчики платежей, поставщики поддержки, услуг и Программ от имени Правообладателя, а также поставщики, предоставляющие Правообладателю или партнёрам Правообладателя аналитические данные о покупках и сбоях в работе Программы.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'6. Прекращение действия')
				imgui.PopFont()
				imgui.TextWrapped(u8'6.1 Если Вы нарушите любое из обязательств, установленных в данном соглашении, включая обязательства, определённые в разделах 2 или 5, настоящее Соглашение автоматически прекратится и Вы лишитесь права на получение обновлений Программы. При возникновении нарушения, которое причинило ущерб Правообладателю, Правообладатель имеет право обратиться к законным средствам защиты, предусмотренным законодательством. Отказ от ответственности и ограничения, установленные для Правообладателя в данном соглашении, будут действовать и после его прекращения.\n\n')
				imgui.TextWrapped(u8'6.2 Правообладатель имеет право уведомить Вас и прекратить действие данного Соглашения относительно конкретной Программы или всех Программ в любое удобное время. После фактического прекращения действия Соглашения Вы теряете право на использование Программы.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'7. Основные положения ответственности сторон')
				imgui.PopFont()
				imgui.TextWrapped(u8'7.1 Правообладатель не несёт никакой ответственности в следующих случаях:\n\n7.1.1 Программа не работает должным образом в связи с нестабильным подключением интернета, устаревшими или неработоспособными техническими характеристиками устройства или Носителя, на которое установлена Программа, недостающим дополнительным ПО, которое обеспечивает необходимую работу Программы, либо из-за пользовательского редактирования программного кода Программы.\n\n7.1.2 Нарушение одного и более пунктов данного Соглашения, после установки Программы.\n\n')
				imgui.TextWrapped(u8'7.1.3 Утеря одной или нескольких копий Программы после её установки.\n\n7.1.4 Потеря трудоспособности Пользователя по любой причине, вследствие чего Пользователь не имеет более физической возможности использовать Программу.\n\n7.1.5 Пользователь согласился использовать Программу, прочитав Лицензионное соглашение, но в последствии, по собственной инициативе, решил отказаться от использования Программы.\n\n7.1.6 Пользователь не получает обновления Программы.\n\n7.1.7 Пользователь не имеет свободного места для установки Программы на Носитель.\n\n7.1.8 Пользователь не имеет возможности установить Программу в связи с отсутствием или нестабильным подключением Интернета.\n\n7.1.9 Пользователь не имеет возможности установить Программу в связи с ограничениями в стране или регионе, в котором он находится.\n\n7.1.10 Пользователь не имеет возможности установить Программу в связи с ПО, через которое он пытается совершить установку.\n\n')
				imgui.TextWrapped(u8'7.1.11 Пользователя не удовлетворили ожидания процесса работы Программы или его функциональные возможности.\n\n7.1.12 Пользователь погиб, либо получил физическую или моральную травму в результате пользования Программой.\n\n7.2 Пользователь несёт полную ответственность перед Правообладателем за соблюдение условий Соглашения.\n\n7.3 Программа предоставляется на международных условиях «как есть» (as is). Правообладатель не гарантирует безошибочную и бесперебойную работы Программы, её отдельных компонентов, функциональности, каким-либо целям и ожиданиям Пользователя, а также не предоставляет никаких иных гарантий, прямо не указанных в Соглашении.\n\n7.4 Правообладатель вправе изменить условия настоящего Соглашения в любой момент времени без предварительного уведомления Пользователя об этом.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'8. Общие положения')
				imgui.PopFont()
				imgui.TextWrapped(u8'8.1 Уведомления. В произвольное время Поставщик может направить Вам уведомление по электронной почте, через всплывающее окно, диалоговое окно или другие средства, даже если в некоторых случаях Вы можете не получить уведомление до тех пор, пока не запустите Программу. Такое уведомление считается доставленным с момента, когда Правообладатель сделал его доступным через Программу, независимо от фактического времени получения.\n\n8.2 Вопросы по данному Соглашению. Если у Вас возникнут вопросы относительно данного Соглашения или потребуется получить дополнительную информацию от Правообладателя, обратитесь по указанному ниже адресу электронной почты: morte4569@vk.com.\n\n')
				imgui.TextWrapped(u8'8.3 Импедимент выполнения обязательств. В случае каких-либо сбоев или снижения производительности, полностью или частично обусловленных непредвиденными ситуациями в предоставлении коммунальных услуг (включая электроэнергию), проблемами с подключением к интернету, недоступностью телекоммуникационных или информационно-технологических услуг, неисправностями телекоммуникационного или ИТ-оборудования, забастовками и другими подобными акциями, террористическими актами, DDoS-атаками и другими атаками и нарушениями ИТ-характера, стихийными бедствиями или обстоятельствами, которые находятся вне контроля Правообладателя, включая наводнения, саботаж, пожары, войны, спец. военные операции, нападения, теракты и прочие обстоятельства непреодолимой силы, а также любыми другими причинами, которые не поддаются существенному влиянию со стороны Правообладателя, Правообладатель освобождается от ответственности за такие события.\n\n')
				imgui.TextWrapped(u8'8.4 Передача прав и обязательств. Вам не разрешается передавать Ваши права или обязательства, установленные настоящим Соглашением, без предварительного письменного согласия Правообладателя. Своей стороной, Правообладатель вправе передать настоящее Соглашение в любой момент по своему усмотрению, без необходимости получения Вашего предварительного согласия в письменной форме.\n\n8.5 Подключение к Интернету. Для работы Программы необходимо обеспечить активное и стабильное подключение к Интернету. За обеспечение постоянного активного и стабильного Интернет-соединения отвечает лично Пользователь.\n\n')
				imgui.PushFont(bold_font[1])
				imgui.SetCursorPosX(10)
				imgui.Text(u8'9. Ответственности сторон при использовании Программы')
				imgui.PopFont()
				imgui.TextWrapped(u8'9.1 Программа обладает функцией обновления, осуществляемой путём загрузки файлов на тот же носитель, на котором установлена Программа.\n\n9.2 При установке и запуске Программы, Пользователь выражает своё согласие на получение неограниченного количества необходимых файлов для работы Программы с расширениями исполняемых файлов в форматах jpg, png, ttf, json, lua и txt в любой момент времени в процессе работы программы, а также на обработку файлов любого размера, не превышающего 8589934592 бит.\n\n9.3 Пользователь соглашается с тем, что Программа имеет право на неограниченное количество перезаписей и чтений установленных файлов в процессе её работы, без предварительного уведомления Пользователя Программы об этом.\n\n9.4 Пользователь принимает факт и соглашается с тем, что в любой момент времени по любой причине Программа или её файлы могут быть безвозвратно уничтожены в связи с сбоями Программы.\n\n')
				imgui.TextWrapped(u8'9.5 Правообладатель не несёт ответственности в случае сбоя операционной системы Пользователя (далее "ОС"), который может привести к временной или постоянной невозможности пользования ОС, а также к возможному уничтожению ОС с Носителя Пользователя в ходе выполнения Программы.\n\n9.6 Правообладатель не несёт ответственности за ошибки, допущенные Пользователем при использовании Программы, которые могут вызвать проблемы в ходе Игры, а также могут привести к ограничениям в использовании Игры, включая блокировку игрового аккаунта.\n\n9.7 Правообладатель осознаёт ответственность за намеренную кражу, попытку кражи, распространение, неправомерное использование личных данных пользователя с его технического Носителя. Правообладатель принимает на себя ответственность, при условии установки программы от официального лица в виде Правообладателя Программы, что Правообладатель понесёт ответственность согласно 273 ст. Уголовного Кодекса Российской Федерации (страна проживания Правообладателя) в случае распространения вредоносных программ на техническое устройство или технический Носитель Пользователя.\n')
				imgui.TextWrapped(u8'Правообладатель гарантирует отсутствие вредоносных файлов, вредоносных программ и модификаций в Программе и использующих ею файлов.\n\n9.8 Правообладатель вправе отправлять Пользователю уведомления любого типа, любого содержания, любой длительности отображения, в любой момент времени, в любом количестве и без предварительного информирования Пользователя об этом событии в самой Программе.\n\n9.9 Правообладатель наделил Программу возможностью в процессе её работы безвозвратно уничтожать, изменять содержимое или название файлов любого расширения, которые принадлежат Правообладателю или были созданы самой Программой в ходе её работы. Пользователь соглашается с этим решением.')
				imgui.PopFont()
				imgui.Dummy(imgui.ImVec2(0, 14))
				imgui.EndChild()
				gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				if gui.Button(u8'Принимаю', {715, 403}, {104, 30}) then
					first_start = 7
				end
				if gui.Button(u8'Назад', {640, 403}, {62, 30}) then
					first_start = 5
				end
			elseif first_start == 7 then
				imgui.PushFont(bold_font[2])
				imgui.SetCursorPos(imgui.ImVec2(247, an[4]))
				gui.TextGradient('Обновления', 0.5, 1.00)
				imgui.PopFont()
				if new_version == '0' or error_update then
					if search_for_new_version == 0 or error_update  then
						gui.Text(290, 221, 'Установлена актуальная версия скрипта.', font[3])
						gui.Text(324, 243, 'Можете завершать настройку.', font[3])
					else
						gui.Text(318, 230, 'Поиск обновлений, подождите...', font[3])
					end
				else
					if update_request == 0 then
						gui.Text(320, 221, 'Доступна новая версия скрипта.', font[3])
						gui.Text(235, 243, 'Для завершения настройки, установите новейшую версию.', font[3])
					else
						gui.Text(342, 231, 'Обновление запрошено...', font[3])
					end
				end
				
				gui.DrawLine({24, 391}, {824, 391}, imgui.ImVec4(0.50, 0.50, 0.50, 0.50))
				
				if new_version == '0' or error_update  then
					if search_for_new_version == 0 or error_update then
						if gui.Button(u8'Завершить', {715, 403}, {104, 30}) then
							first_start = 7
							setting.first_start = false
							for i = 1, #cmd_defoult.all do
								table.insert(cmd[1], cmd_defoult.all[i])
								sampRegisterChatCommand(cmd_defoult.all[i].cmd, function(arg) 
								cmd_start(arg, tostring(cmd_defoult.all[i].UID) .. cmd_defoult.all[i].cmd) end)
							end
							if setting.org <= 4 then --> Для Больниц
								for i = 1, #cmd_defoult.hospital do
									table.insert(cmd[1], cmd_defoult.hospital[i])
									sampRegisterChatCommand(cmd_defoult.hospital[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.hospital[i].UID) .. cmd_defoult.hospital[i].cmd) end)
								end
								
								if server == '185.169.134.3:7777' then 
									for i = 1, #cmd[1] do
										if cmd[1][i].cmd == 'mc' then
											cmd[1][i] = mc_phoenix
										end
									end
								end
							elseif setting.org == 5 then --> Для ЦЛ
								for i = 1, #cmd_defoult.driving_school do
									table.insert(cmd[1], cmd_defoult.driving_school[i])
									sampRegisterChatCommand(cmd_defoult.driving_school[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.driving_school[i].UID) .. cmd_defoult.driving_school[i].cmd) end)
								end
							elseif setting.org == 6 then --> Для Права
								for i = 1, #cmd_defoult.government do
									table.insert(cmd[1], cmd_defoult.government[i])
									sampRegisterChatCommand(cmd_defoult.government[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.government[i].UID) .. cmd_defoult.government[i].cmd) end)
								end
							elseif setting.org == 7 or setting.org == 8 then --> Для Армии
								for i = 1, #cmd_defoult.army do
									table.insert(cmd[1], cmd_defoult.army[i])
									sampRegisterChatCommand(cmd_defoult.army[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.army[i].UID) .. cmd_defoult.army[i].cmd) end)
								end
								setting.gun_func = true
							elseif setting.org == 9 then --> Для Пожарки
								for i = 1, #cmd_defoult.fire_department do
									table.insert(cmd[1], cmd_defoult.fire_department[i])
									sampRegisterChatCommand(cmd_defoult.fire_department[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.fire_department[i].UID) .. cmd_defoult.fire_department[i].cmd) end)
								end
							elseif setting.org == 10 then --> Для ТСР
								for i = 1, #cmd_defoult.jail do
									table.insert(cmd[1], cmd_defoult.jail[i])
									sampRegisterChatCommand(cmd_defoult.jail[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.jail[i].UID) .. cmd_defoult.jail[i].cmd) end)
								end
								setting.gun_func = true
							elseif setting.org == 11 then --> Для СМИ
								for i = 1, #cmd_defoult.smi do
									table.insert(cmd[1], cmd_defoult.smi[i])
									sampRegisterChatCommand(cmd_defoult.smi[i].cmd, function(arg) 
									cmd_start(arg, tostring(cmd_defoult.smi[i].UID) .. cmd_defoult.smi[i].cmd) end)
								end

							end
							add_cmd_in_all_cmd()
							save_cmd()
							save()
						end
					else
						gui.Button(u8'Завершить', {715, 403}, {104, 30}, false)
					end
				else
					if update_request == 0 then
						if gui.Button(u8'Обновить', {715, 403}, {104, 30}) then
							update_request = 25
							update_download()
						end
					else
						gui.Button(u8'Обновить', {715, 403}, {104, 30}, false)
					end
				end
				if gui.Button(u8'Назад', {640, 403}, {62, 30}) then
					first_start = 6
				end
			end
		end
		
		if not setting.first_start then
			if tab == 'settings' then
				hall.settings()
			elseif tab == 'cmd' then
				hall.cmd()
			elseif tab == 'shpora' then
				hall.shpora()
			elseif tab == 'dep' then
				hall.dep()
			elseif tab == 'sob' then
				hall.sob()
			elseif tab == 'reminder' then
				hall.reminder()
			elseif tab == 'stat' then
				hall.stat()
			elseif tab == 'music' then
				hall.music()
			elseif tab == 'rp_zona' then
				hall.rp_zona()
			elseif tab == 'actions' then
				hall.actions()
			elseif tab == 'help' then
				hall.help()
			end
			
			--> Отображение вкладок
			gui.Draw({4, 4}, {840, 34}, cl.tab, 12, 3)
			gui.Draw({4, 409}, {840, 35}, cl.tab, 12, 12)
			imgui.PushFont(bold_font[1])
			local calc = imgui.CalcTextSize(name_tab)
			gui.Text((424 - calc.x / 2), 11, u8:decode(name_tab))
			imgui.PopFont()
			element_order(setting.tab)
			
			local color_ItemActive = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
			local color_ItemHovered = imgui.ImVec4(0.24, 0.24, 0.24, 1.00)
			if setting.cl == 'White' then
				color_ItemActive = imgui.ImVec4(0.78, 0.78, 0.78, 1.00)
				color_ItemHovered = imgui.ImVec4(0.83, 0.83, 0.83, 1.00)
			end
			
			if tab == 'settings' and setting.org == 9 and tab_settings == 6 then
				imgui.SetCursorPos(imgui.ImVec2(802, 5))
				if imgui.InvisibleButton(u8'##Посмотреть теги вызовов', imgui.ImVec2(35, 32)) then
					popup_open_tags_call = true
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[29] < 0.45 then
						an[29] = an[29] + (anim * 1)
					end
				else
					if an[29] > 0 then
						an[29] = an[29] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[29], 0.50 - an[29], 0.50 - an[29], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[29], 0.50 + an[29], 0.50 + an[29], 1.00))
				end
				gui.FaText(811, 6, fa.TAGS, fa_font[4])
				gui.Text(805, 22, 'Теги')
				imgui.PopStyleColor(1)
			end
			
			if not edit_tab_cmd and tab == 'cmd' then
				if not edit_all_cmd then
					local function InputTextForSearchCmd(pos_draw, size_input, arg_text, name_input, buf_size_input, text_about)
						local arg_text_buf = imgui.new.char[buf_size_input](arg_text)
						local col_stand_imvec4 = cl.bg
						
						gui.Draw({pos_draw[1], pos_draw[2] - 5}, {size_input, 24}, col_stand_imvec4, 5, 15)
						imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 6, pos_draw[2] - 1))
						imgui.PushItemWidth(size_input - 6)
						
						imgui.InputText('##inp' .. name_input, arg_text_buf, ffi.sizeof(arg_text_buf))
						
						if text_about ~= nil and (ffi.string(arg_text_buf) == '' and not imgui.IsItemActive()) then
							imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 25, pos_draw[2] - 1))
							imgui.PushFont(font[3])
							imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), text_about)
							imgui.PopFont()
							
							imgui.SetCursorPos(imgui.ImVec2(pos_draw[1] + 7, pos_draw[2] - 1))
							imgui.PushFont(fa_font[2])
							imgui.TextColored(imgui.ImVec4(0.50, 0.50, 0.50, 0.50), fa.MAGNIFYING_GLASS)
							imgui.PopFont()
						end
						
						return ffi.string(arg_text_buf)
					end
					search_cmd = InputTextForSearchCmd({540, 14}, 150, search_cmd, u8'Поиск команды', 32, u8'Поиск')
					imgui.SetCursorPos(imgui.ImVec2(772, 5))
					if imgui.InvisibleButton(u8'##Создать команду', imgui.ImVec2(65, 32)) then
						edit_tab_cmd = true
						local bool_cmd_new = {
							cmd = '',
							delay = 2.5,
							key = {'', {}},
							desc = '',
							folder = int_cmd.folder,
							rank = 1,
							send_end_mes = true,
							arg = {},
							var = {},
							act = {},
							id_element = 0,
							UID = math.random(20, 95000000)
						}
						bl_cmd = bool_cmd_new
						cmd_memory = ''
						type_cmd = #cmd[1] + 1
						edit_all_cmd = false
						an[13] = 0
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[7][1] < 0.45 then
							an[7][1] = an[7][1] + (anim * 1)
						end
					else
						if an[7][1] > 0 then
							an[7][1] = an[7][1] - (anim * 1)
						end
					end
					
					imgui.SetCursorPos(imgui.ImVec2(705, 5))
					if imgui.InvisibleButton(u8'##Выбор команд', imgui.ImVec2(60, 32)) then
						edit_all_cmd = not edit_all_cmd
						table_select_cmd = {}
						an[12][2] = 0
						an[12][3] = false
					end
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[7][2] < 0.45 then
							an[7][2] = an[7][2] + (anim * 1)
						end
					else
						if an[7][2] > 0 then
							an[7][2] = an[7][2] - (anim * 1)
						end
					end
					
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[7][1], 0.50 - an[7][1], 0.50 - an[7][1], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[7][1], 0.50 + an[7][1], 0.50 + an[7][1], 1.00))
					end
					gui.FaText(797, 6, fa.PLUS, fa_font[4])
					gui.Text(777, 22, 'Добавить')
					imgui.PopStyleColor(1)
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[7][2], 0.50 - an[7][2], 0.50 - an[7][2], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[7][2], 0.50 + an[7][2], 0.50 + an[7][2], 1.00))
					end
					gui.FaText(727, 6, fa.LIST_CHECK, fa_font[4])
					gui.Text(711, 22, 'Выбрать')
					imgui.PopStyleColor(1)
				else
					imgui.SetCursorPos(imgui.ImVec2(780, 5))
					if imgui.InvisibleButton(u8'##Удалить выбранные команды', imgui.ImVec2(57, 32)) then
						edit_all_cmd = false
						table.sort(table_select_cmd, function(a, b) return a > b end)
						for _, index in ipairs(table_select_cmd) do
							if cmd[1][index].cmd ~= '' then
								sampUnregisterChatCommand(cmd[1][index].cmd)
							end
							if #cmd[1][index].key[2] ~= 0 then
								rkeys.unRegisterHotKey(cmd[1][index].key[2])
								for ke = 1, #all_keys do
									if table.concat(all_keys[ke], ' ') == table.concat(cmd[1][index].key[2], ' ') then
										table.remove(all_keys, ke)
									end
								end
							end
							table.remove(cmd[1], index)
						end
						add_cmd_in_all_cmd()
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[14][1] < 0.45 then
							an[14][1] = an[14][1] + (anim * 1)
						end
					else
						if an[14][1] > 0 then
							an[14][1] = an[14][1] - (anim * 1)
						end
					end
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[14][1], 0.50 - an[14][1], 0.50 - an[14][1], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[14][1], 0.50 + an[14][1], 0.50 + an[14][1], 1.00))
					end
					gui.FaText(801, 6, fa.TRASH, fa_font[4])
					gui.Text(784, 22, 'Удалить')
					imgui.PopStyleColor(1)
					
					imgui.SetCursorPos(imgui.ImVec2(704, 5))
					if imgui.InvisibleButton(u8'##Отменить выбор команд', imgui.ImVec2(64, 32)) then
						edit_all_cmd = false
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[14][2] < 0.45 then
							an[14][2] = an[14][2] + (anim * 1)
						end
					else
						if an[14][2] > 0 then
							an[14][2] = an[14][2] - (anim * 1)
						end
					end
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[14][2], 0.50 - an[14][2], 0.50 - an[14][2], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[14][2], 0.50 + an[14][2], 0.50 + an[14][2], 1.00))
					end
					gui.FaText(731, 6, fa.XMARK, fa_font[4])
					gui.Text(707, 22, 'Отменить')
					imgui.PopStyleColor(1)
				end
			elseif edit_tab_cmd and tab == 'cmd' then
				imgui.SetCursorPos(imgui.ImVec2(182, 5))
				if imgui.InvisibleButton(u8'##Выйти из редактора команд', imgui.ImVec2(48, 32)) then
					edit_tab_cmd = false
					edit_all_cmd = false
					an[13] = 0
					if #bl_cmd.key[2] ~= 0 and type_cmd == (#cmd[1] + 1) then
						for ke = 1, #all_keys do
							if table.concat(all_keys[ke], ' ') == table.concat(bl_cmd.key[2], ' ') then
								table.remove(all_keys, ke)
							end
						end
					end
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][1] < 0.45 then
						an[8][1] = an[8][1] + (anim * 1)
					end
				else
					if an[8][1] > 0 then
						an[8][1] = an[8][1] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(120, 5))
				if imgui.InvisibleButton(u8'##Удалить команду', imgui.ImVec2(56, 32)) then
					imgui.OpenPopup(u8'Подтверждение удаления команды')
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][2] < 0.45 then
						an[8][2] = an[8][2] + (anim * 1)
					end
				else
					if an[8][2] > 0 then
						an[8][2] = an[8][2] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить команду', imgui.ImVec2(64, 32)) then
					if bl_cmd.cmd ~= '' then
						local bool_true_cmd = 0
						for m = 1, #all_cmd do
							if all_cmd[m] == bl_cmd.cmd then
								bool_true_cmd = m
								break
							end
						end
						
						if bool_true_cmd == 0 or cmd_memory == bl_cmd.cmd then
							cmd[1][type_cmd] = bl_cmd
							edit_tab_cmd = false
							edit_all_cmd = false
							an[13] = 0
							if cmd_memory ~= '' then
								for y = 1, #all_cmd do
									if all_cmd[y] == cmd_memory then
										table.remove(all_cmd, y)
										sampUnregisterChatCommand(cmd_memory)
										save_cmd()
										break
									end
								end
							end
							table.insert(all_cmd, bl_cmd.cmd)
							sampRegisterChatCommand(bl_cmd.cmd, function(arg) cmd_start(arg, tostring(bl_cmd.UID) .. bl_cmd.cmd) end)
							save_cmd()
						else
							imgui.OpenPopup(u8'Ошибка сохранения команды')
							error_save_cmd = 1
						end
					elseif cmd_memory ~= '' then
						--imgui.OpenPopup(u8'Ошибка сохранения команды')
						--error_save_cmd = 0
						for y = 1, #all_cmd do
							if all_cmd[y] == cmd_memory then
								table.remove(all_cmd, y)
								sampUnregisterChatCommand(cmd_memory)
								save_cmd()
								break
							end
						end
						cmd[1][type_cmd] = bl_cmd
						edit_tab_cmd = false
						edit_all_cmd = false
						an[13] = 0
					else
						cmd[1][type_cmd] = bl_cmd
						edit_tab_cmd = false
						edit_all_cmd = false
						an[13] = 0
					end
					save_cmd()
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][3] < 0.45 then
						an[8][3] = an[8][3] + (anim * 1)
					end
				else
					if an[8][3] > 0 then
						an[8][3] = an[8][3] - (anim * 1)
					end
				end
				
				if imgui.BeginPopupModal(u8'Подтверждение удаления команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##Закрыть окно удаления команды', imgui.ImVec2(16, 16)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(16, 16))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					gui.DrawLine({10, 31}, {346, 31}, cl.line)
					imgui.SetCursorPos(imgui.ImVec2(6, 40))
					imgui.BeginChild(u8'Подтверждение удаления команды ', imgui.ImVec2(261, 90), false, imgui.WindowFlags.NoScrollbar)
					
					gui.Text(25, 5, 'Вы уверены, что хотите удалить \n                     команду?', font[3])
					if gui.Button(u8'Удалить', {24, 50}, {90, 27}) then
						if type_cmd ~= #cmd[1] + 1 then
							if #cmd[1][type_cmd].key[2] ~= 0 then
								rkeys.unRegisterHotKey(cmd[1][type_cmd].key[2])
								for ke = 1, #all_keys do
									if table.concat(all_keys[ke], ' ') == table.concat(cmd[1][type_cmd].key[2], ' ') then
										table.remove(all_keys, ke)
									end
								end
							end
							if #bl_cmd.key[2] ~= 0 then
								for ke = 1, #all_keys do
									if table.concat(all_keys[ke], ' ') == table.concat(bl_cmd.key[2], ' ') then
										table.remove(all_keys, ke)
									end
								end
							end
							if cmd[1][type_cmd].cmd ~= '' then
								sampUnregisterChatCommand(cmd[1][type_cmd].cmd)
							end
							table.remove(cmd[1], type_cmd)
							add_cmd_in_all_cmd()
						end
						if #bl_cmd.key[2] ~= 0 then
							for ke = 1, #all_keys do
								if table.concat(all_keys[ke], ' ') == table.concat(bl_cmd.key[2], ' ') then
									table.remove(all_keys, ke)
								end
							end
						end
						edit_tab_cmd = false
						edit_all_cmd = false
						an[13] = 0
						save_cmd()
						imgui.CloseCurrentPopup()
					end
					if gui.Button(u8'Отмена', {141, 50}, {90, 27}) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				if imgui.BeginPopupModal(u8'Ошибка сохранения команды', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##Закрыть окно ошибки сохранения команды', imgui.ImVec2(16, 16)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(16, 16))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					gui.DrawLine({10, 31}, {346, 31}, cl.line)
					imgui.SetCursorPos(imgui.ImVec2(6, 40))
					imgui.BeginChild(u8'Инфомарция об ошибке в команде', imgui.ImVec2(261, 71), false, imgui.WindowFlags.NoScrollbar)
					
					gui.FaText(110, 0, fa.OCTAGON_EXCLAMATION, fa_font[6], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
					
					imgui.PushFont(bold_font[1])
					if error_save_cmd == 0 then
						gui.Text(59, 41, 'Впишите команду')
					else
						gui.Text(9, 41, 'Такая команда уже существует')
					end
					imgui.PopFont()
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][1], 0.50 - an[8][1], 0.50 - an[8][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][1], 0.50 + an[8][1], 0.50 + an[8][1], 1.00))
				end
				gui.FaText(197, 6, fa.ARROW_RIGHT_TO_BRACKET, fa_font[4])
				gui.Text(187, 22, 'Выйти')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][2], 0.50 - an[8][2], 0.50 - an[8][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][2], 0.50 + an[8][2], 0.50 + an[8][2], 1.00))
				end
				gui.FaText(140, 6, fa.TRASH, fa_font[4])
				gui.Text(123, 22, 'Удалить')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][3], 0.50 - an[8][3], 0.50 - an[8][3], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][3], 0.50 + an[8][3], 0.50 + an[8][3], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
				
				
				imgui.SetCursorPos(imgui.ImVec2(775, 5))
				if imgui.InvisibleButton(u8'##Добавить действие', imgui.ImVec2(62, 32)) then
					number_i_cmd = #bl_cmd.act
					imgui.OpenPopup(u8'Добавление действия')
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][4] < 0.45 then
						an[8][4] = an[8][4] + (anim * 1)
					end
				else
					if an[8][4] > 0 then
						an[8][4] = an[8][4] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][4], 0.50 - an[8][4], 0.50 - an[8][4], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][4], 0.50 + an[8][4], 0.50 + an[8][4], 1.00))
				end
				gui.FaText(797, 6, fa.PLUS, fa_font[4])
				gui.Text(777, 22, 'Действие')
				imgui.PopStyleColor(1)
				
				imgui.SetCursorPos(imgui.ImVec2(730, 5))
				if imgui.InvisibleButton(u8'##Посмотреть теги', imgui.ImVec2(35, 32)) then
					popup_open_tags = true
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][6] < 0.45 then
						an[8][6] = an[8][6] + (anim * 1)
					end
				else
					if an[8][6] > 0 then
						an[8][6] = an[8][6] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][6], 0.50 - an[8][6], 0.50 - an[8][6], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][6], 0.50 + an[8][6], 0.50 + an[8][6], 1.00))
				end
				gui.FaText(739, 6, fa.TAGS, fa_font[4])
				gui.Text(733, 22, 'Теги')
				imgui.PopStyleColor(1)
				
				imgui.SetCursorPos(imgui.ImVec2(652, 5))
				if imgui.InvisibleButton(u8'##Открыть видеоурок', imgui.ImVec2(68, 32)) then
					
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[8][5] < 0.45 then
						an[8][5] = an[8][5] + (anim * 1)
					end
				else
					if an[8][5] > 0 then
						an[8][5] = an[8][5] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[8][5], 0.50 - an[8][5], 0.50 - an[8][5], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[8][5], 0.50 + an[8][5], 0.50 + an[8][5], 1.00))
				end

				imgui.PopStyleColor(1)
			end
			if not edit_tab_shpora and tab == 'shpora' then
				if not shp_edit_all[1] then
					imgui.SetCursorPos(imgui.ImVec2(772, 5))
					if imgui.InvisibleButton(u8'##Создать шпаргалку', imgui.ImVec2(65, 32)) then
						edit_tab_shpora = true
						cmd_memory_shpora = ''
						local bool_shpora_new = {
							name = '',
							icon = 11,
							color = 0,
							cmd = '',
							key = {'', {}},
							text = '',
							UID = math.random(100, 95000000)
						}
						shpora_bool = bool_shpora_new
						num_shpora = #setting.shp + 1
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[17][1] < 0.45 then
							an[17][1] = an[17][1] + (anim * 1)
						end
					else
						if an[17][1] > 0 then
							an[17][1] = an[17][1] - (anim * 1)
						end
					end
					
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[17][1], 0.50 - an[17][1], 0.50 - an[17][1], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[17][1], 0.50 + an[17][1], 0.50 + an[17][1], 1.00))
					end
					gui.FaText(797, 6, fa.PLUS, fa_font[4])
					gui.Text(777, 22, 'Добавить')
					imgui.PopStyleColor(1)
					
					if #setting.shp ~= 0 then
						imgui.SetCursorPos(imgui.ImVec2(705, 5))
						if imgui.InvisibleButton(u8'##Выбор шпаргалок', imgui.ImVec2(60, 32)) then
							shp_edit_all = {true, {}}
						end
						
						if imgui.IsItemActive() or imgui.IsItemHovered() then
							if an[17][2] < 0.45 then
								an[17][2] = an[17][2] + (anim * 1)
							end
						else
							if an[17][2] > 0 then
								an[17][2] = an[17][2] - (anim * 1)
							end
						end
						if setting.cl == 'White' then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[17][2], 0.50 - an[17][2], 0.50 - an[17][2], 1.00))
						else
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[17][2], 0.50 + an[17][2], 0.50 + an[17][2], 1.00))
						end
						gui.FaText(727, 6, fa.LIST_CHECK, fa_font[4])
						gui.Text(711, 22, 'Выбрать')
						imgui.PopStyleColor(1)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(780, 5))
					if imgui.InvisibleButton(u8'##Удалить выбранные шпаргалки', imgui.ImVec2(57, 32)) then
						table.sort(shp_edit_all[2], function(a, b) return a > b end)
						for _, index in ipairs(shp_edit_all[2]) do
							if setting.shp[index].cmd ~= '' then
								sampUnregisterChatCommand(setting.shp[index].cmd)
							end
							if #setting.shp[index].key[2] ~= 0 then
								rkeys.unRegisterHotKey(setting.shp[index].key[2])
								for ke = 1, #all_keys do
									if table.concat(all_keys[ke], ' ') == table.concat(setting.shp[index].key[2], ' ') then
										table.remove(all_keys, ke)
									end
								end
							end
							table.remove(setting.shp, index)
						end
						shp_edit_all = {false, {}}
						add_cmd_in_all_cmd()
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[17][1] < 0.45 then
							an[17][1] = an[17][1] + (anim * 1)
						end
					else
						if an[17][1] > 0 then
							an[17][1] = an[17][1] - (anim * 1)
						end
					end
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[17][1], 0.50 - an[17][1], 0.50 - an[17][1], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[17][1], 0.50 + an[17][1], 0.50 + an[17][1], 1.00))
					end
					gui.FaText(801, 6, fa.TRASH, fa_font[4])
					gui.Text(784, 22, 'Удалить')
					imgui.PopStyleColor(1)
					
					imgui.SetCursorPos(imgui.ImVec2(704, 5))
					if imgui.InvisibleButton(u8'##Отменить выбор шпаргалок', imgui.ImVec2(64, 32)) then
						shp_edit_all = {false, {}}
					end
					
					if imgui.IsItemActive() or imgui.IsItemHovered() then
						if an[17][2] < 0.45 then
							an[17][2] = an[17][2] + (anim * 1)
						end
					else
						if an[17][2] > 0 then
							an[17][2] = an[17][2] - (anim * 1)
						end
					end
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[17][2], 0.50 - an[17][2], 0.50 - an[17][2], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[17][2], 0.50 + an[17][2], 0.50 + an[17][2], 1.00))
					end
					gui.FaText(731, 6, fa.XMARK, fa_font[4])
					gui.Text(707, 22, 'Отменить')
					imgui.PopStyleColor(1)
				end
				
			elseif edit_tab_shpora and tab == 'shpora' then
				imgui.SetCursorPos(imgui.ImVec2(182, 5))
				if imgui.InvisibleButton(u8'##Выйти из редактора шпаргалки', imgui.ImVec2(48, 32)) then
					edit_tab_shpora = false
					if #shpora_bool.key[2] ~= 0 and num_shpora == (#setting.shp + 1) then
						for ke = 1, #all_keys do
							if table.concat(all_keys[ke], ' ') == table.concat(shpora_bool.key[2], ' ') then
								table.remove(all_keys, ke)
							end
						end
					end
					num_shpora = 0
				end
				if imgui.IsItemActive() then
					if an[18][1] < 0.45 then
						an[18][1] = an[18][1] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[18][1] < 0.45 then
						an[18][1] = an[18][1] + (anim * 1)
					end
				else
					if an[18][1] > 0 then
						an[18][1] = an[18][1] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(120, 5))
				if imgui.InvisibleButton(u8'##Удалить шпаргалку', imgui.ImVec2(56, 32)) then
					windows.shpora[0] = false
					edit_tab_shpora = false
					if (#setting.shp + 1) ~= num_shpora then
						if setting.shp[num_shpora].cmd ~= '' then
							sampUnregisterChatCommand(setting.shp[num_shpora].cmd)
						end
						if #setting.shp[num_shpora].key[2] ~= 0 then
							rkeys.unRegisterHotKey(setting.shp[num_shpora].key[2])
							for ke = 1, #all_keys do
								if table.concat(all_keys[ke], ' ') == table.concat(setting.shp[num_shpora].key[2], ' ') then
									table.remove(all_keys, ke)
								end
							end
						end
						table.remove(setting.shp, num_shpora)
						add_cmd_in_all_cmd()
					end
					if #shpora_bool.key[2] ~= 0 then
						for ke = 1, #all_keys do
							if table.concat(all_keys[ke], ' ') == table.concat(shpora_bool.key[2], ' ') then
								table.remove(all_keys, ke)
							end
						end
					end
					num_shpora = 0
					save()
				end
				if imgui.IsItemActive() then
					if an[18][2] < 0.45 then
						an[18][2] = an[18][2] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[18][2] < 0.45 then
						an[18][2] = an[18][2] + (anim * 1)
					end
				else
					if an[18][2] > 0 then
						an[18][2] = an[18][2] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить шпаргалку', imgui.ImVec2(64, 32)) then
					local err_save_shpora = false
					if shpora_bool.cmd ~= '' then
						for m = 1, #all_cmd do
							if all_cmd[m] == shpora_bool.cmd then
								imgui.OpenPopup(u8'Ошибка сохранения команды в шпоре')
								err_save_shpora = true
								break
							end
						end
					end
					if not err_save_shpora then
						edit_tab_shpora = false
						if (#setting.shp + 1) ~= num_shpora then
							setting.shp[num_shpora] = shpora_bool
							if shpora_bool.cmd ~= '' then
								if cmd_memory_shpora ~= shpora_bool.cmd then
									sampUnregisterChatCommand(shpora_bool.cmd)
									sampRegisterChatCommand(shpora_bool.cmd, function(arg) cmd_shpora_open(arg, tostring(shpora_bool.UID) .. shpora_bool.cmd) end)
								end
							end
						else
							table.insert(setting.shp, shpora_bool)
							if shpora_bool.cmd ~= '' then
								sampRegisterChatCommand(shpora_bool.cmd, function(arg) cmd_shpora_open(arg, tostring(shpora_bool.UID) .. shpora_bool.cmd) end)
							end
						end
						add_cmd_in_all_cmd()
					end
					save()
				end
				if imgui.IsItemActive() then
					if an[18][3] < 0.45 then
						an[18][3] = an[18][3] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[18][3] < 0.45 then
						an[18][3] = an[18][3] + (anim * 1)
					end
				else
					if an[18][3] > 0 then
						an[18][3] = an[18][3] - (anim * 1)
					end
				end
				
				if imgui.BeginPopupModal(u8'Ошибка сохранения команды в шпоре', null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
					imgui.SetCursorPos(imgui.ImVec2(10, 10))
					if imgui.InvisibleButton(u8'##Закрыть окно ошибки сохранения команды в шпоре', imgui.ImVec2(16, 16)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SetCursorPos(imgui.ImVec2(16, 16))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() then
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38 ,1.00)), 60)
					else
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38 ,1.00)), 60)
					end
					gui.DrawLine({10, 31}, {346, 31}, cl.line)
					imgui.SetCursorPos(imgui.ImVec2(6, 40))
					imgui.BeginChild(u8'Инфомарция об ошибке в команде в шпоре', imgui.ImVec2(261, 71), false, imgui.WindowFlags.NoScrollbar)
					
					gui.FaText(110, 0, fa.OCTAGON_EXCLAMATION, fa_font[6], imgui.ImVec4(1.00, 0.07, 0.00, 1.00))
					
					imgui.PushFont(bold_font[1])
					gui.Text(9, 41, 'Такая команда уже существует')
					imgui.PopFont()
					
					imgui.EndChild()
					imgui.EndPopup()
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[18][1], 0.50 - an[18][1], 0.50 - an[18][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[18][1], 0.50 + an[18][1], 0.50 + an[18][1], 1.00))
				end
				gui.FaText(197, 6, fa.ARROW_RIGHT_TO_BRACKET, fa_font[4])
				gui.Text(187, 22, 'Выйти')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[18][2], 0.50 - an[18][2], 0.50 - an[18][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[18][2], 0.50 + an[18][2], 0.50 + an[18][2], 1.00))
				end
				gui.FaText(140, 6, fa.TRASH, fa_font[4])
				gui.Text(123, 22, 'Удалить')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[18][3], 0.50 - an[18][3], 0.50 - an[18][3], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[18][3], 0.50 + an[18][3], 0.50 + an[18][3], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
				
			elseif edit_rp_q_sob and tab == 'sob' then
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[19][1], 0.50 - an[19][1], 0.50 - an[19][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[19][1], 0.50 + an[19][1], 0.50 + an[19][1], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить отыгровки вопросов', imgui.ImVec2(64, 32)) then
					edit_rp_q_sob = false
					save()
				end
				if imgui.IsItemActive() then
					if an[19][1] < 0.45 then
						an[19][1] = an[19][1] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[19][1] < 0.45 then
						an[19][1] = an[19][1] + (anim * 1)
					end
				else
					if an[19][1] > 0 then
						an[19][1] = an[19][1] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(772, 5))
					if imgui.InvisibleButton(u8'##Создать новую отыгровку вопроса', imgui.ImVec2(65, 32)) then
						table.insert(setting.sob.rp_q, {name = '', rp = {''}})
						bool_sob_rp_scroll = true
					end
					
					if imgui.IsItemActive() then
						if an[19][2] < 0.45 then
							an[19][2] = an[19][2] + (anim * 1)
						end
					elseif imgui.IsItemHovered() then
						if an[19][2] < 0.45 then
							an[19][2] = an[19][2] + (anim * 1)
						end
					else
						if an[19][2] > 0 then
							an[19][2] = an[19][2] - (anim * 1)
						end
					end
					
					if setting.cl == 'White' then
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[19][2], 0.50 - an[19][2], 0.50 - an[19][2], 1.00))
					else
						imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[19][2], 0.50 + an[19][2], 0.50 + an[19][2], 1.00))
					end
					gui.FaText(797, 6, fa.PLUS, fa_font[4])
					gui.Text(777, 22, 'Добавить')
					imgui.PopStyleColor(1)
			elseif edit_rp_fit_sob and tab == 'sob' then
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[19][1], 0.50 - an[19][1], 0.50 - an[19][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[19][1], 0.50 + an[19][1], 0.50 + an[19][1], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить отыгровки при определении годности', imgui.ImVec2(64, 32)) then
					edit_rp_fit_sob = false
					save()
				end
				if imgui.IsItemActive() then
					if an[19][1] < 0.45 then
						an[19][1] = an[19][1] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[19][1] < 0.45 then
						an[19][1] = an[19][1] + (anim * 1)
					end
				else
					if an[19][1] > 0 then
						an[19][1] = an[19][1] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(772, 5))
				if imgui.InvisibleButton(u8'##Создать новую отыгровку вопроса', imgui.ImVec2(65, 32)) then
					table.insert(setting.sob.rp_fit, {name = '', rp = {''}})
					bool_sob_rp_scroll = true
				end
				
				if imgui.IsItemActive() then
					if an[19][2] < 0.45 then
						an[19][2] = an[19][2] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[19][2] < 0.45 then
						an[19][2] = an[19][2] + (anim * 1)
					end
				else
					if an[19][2] > 0 then
						an[19][2] = an[19][2] - (anim * 1)
					end
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[19][2], 0.50 - an[19][2], 0.50 - an[19][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[19][2], 0.50 + an[19][2], 0.50 + an[19][2], 1.00))
				end
				gui.FaText(797, 6, fa.PLUS, fa_font[4])
				gui.Text(777, 22, 'Добавить')
				imgui.PopStyleColor(1)
			elseif not new_reminder and tab == 'reminder' then
				imgui.SetCursorPos(imgui.ImVec2(772, 5))
				if imgui.InvisibleButton(u8'##Добавить новое напоминание', imgui.ImVec2(65, 32)) then
					new_reminder = true
					local bool_reminder_new = {
						text = '',
						year = tonumber(os.date('%Y')),
						mon = tonumber(os.date('%m')),
						day = tonumber(os.date('%d')),
						min = tonumber(os.date('%M')),
						hour = tonumber(os.date('%H')),
						repeats = {false, false, false, false, false, false, false},
						sound = false,
						execution = false
					}
					new_rem = bool_reminder_new
					last_child_y = {tonumber(os.date('%H')) * 60, tonumber(os.date('%M')) * 60}
					start_child = {true, true}
				end
				
				if imgui.IsItemActive() then
					if an[20][1] < 0.45 then
						an[20][1] = an[20][1] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[20][1] < 0.45 then
						an[20][1] = an[20][1] + (anim * 1)
					end
				else
					if an[20][1] > 0 then
						an[20][1] = an[20][1] - (anim * 1)
					end
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[20][1], 0.50 - an[20][1], 0.50 - an[20][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[20][1], 0.50 + an[20][1], 0.50 + an[20][1], 1.00))
				end
				gui.FaText(797, 6, fa.PLUS, fa_font[4])
				gui.Text(777, 22, 'Добавить')
				imgui.PopStyleColor(1)
			elseif new_reminder and tab == 'reminder' then
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить напоминание', imgui.ImVec2(64, 32)) then
					new_reminder = false
					table.insert(setting.reminder, 1, new_rem)
					save()
				end
				if imgui.IsItemActive() then
					if an[20][2] < 0.45 then
						an[20][2] = an[20][2] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[20][2] < 0.45 then
						an[20][2] = an[20][2] + (anim * 1)
					end
				else
					if an[20][2] > 0 then
						an[20][2] = an[20][2] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[20][2], 0.50 - an[20][2], 0.50 - an[20][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[20][2], 0.50 + an[20][2], 0.50 + an[20][2], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
				
				imgui.SetCursorPos(imgui.ImVec2(120, 5))
				if imgui.InvisibleButton(u8'##Удалить напоминание', imgui.ImVec2(56, 32)) then
					new_reminder = false
				end
				if imgui.IsItemActive() then
					if an[20][3] < 0.45 then
						an[20][3] = an[20][3] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[20][3] < 0.45 then
						an[20][3] = an[20][3] + (anim * 1)
					end
				else
					if an[20][3] > 0 then
						an[20][3] = an[20][3] - (anim * 1)
					end
				end
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[20][3], 0.50 - an[20][3], 0.50 - an[20][3], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[20][3], 0.50 + an[20][3], 0.50 + an[20][3], 1.00))
				end
				gui.FaText(140, 6, fa.TRASH, fa_font[4])
				gui.Text(123, 22, 'Удалить')
				imgui.PopStyleColor(1)
			elseif tab == 'stat' then
				imgui.SetCursorPos(imgui.ImVec2(772, 5))
				if imgui.InvisibleButton(u8'##Сбросить статистику', imgui.ImVec2(65, 32)) then
					setting.stat = {
						cl = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
						afk = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
						day = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
						all = 0,
						today = os.date('%d.%m.%y'),
						date_week = {os.date('%d.%m.%y'), '', '', '', '', '', '', '', '', ''}
					}
					stat_ses = {
						cl = 0,
						afk = 0,
						all = 0
					}
				end
				
				if imgui.IsItemActive() then
					if an[21][1] < 0.45 then
						an[21][1] = an[21][1] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[21][1] < 0.45 then
						an[21][1] = an[21][1] + (anim * 1)
					end
				else
					if an[21][1] > 0 then
						an[21][1] = an[21][1] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(700, 5))
				if imgui.InvisibleButton(u8'##Перейти в настройки статистики', imgui.ImVec2(65, 32)) then
					tab = 'settings'
					name_tab = u8'Главное'
					tab_settings = 19
					bool_go_stat_set = true
				end
				if imgui.IsItemActive() then
					if an[21][2] < 0.45 then
						an[21][2] = an[21][2] + (anim * 1)
					end
				elseif imgui.IsItemHovered() then
					if an[21][2] < 0.45 then
						an[21][2] = an[21][2] + (anim * 1)
					end
				else
					if an[21][2] > 0 then
						an[21][2] = an[21][2] - (anim * 1)
					end
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[21][1], 0.50 - an[21][1], 0.50 - an[21][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[21][1], 0.50 + an[21][1], 0.50 + an[21][1], 1.00))
				end
				gui.FaText(795, 6, fa.ROTATE_RIGHT, fa_font[4])
				gui.Text(777, 22, 'Сбросить')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[21][2], 0.50 - an[21][2], 0.50 - an[21][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[21][2], 0.50 + an[21][2], 0.50 + an[21][2], 1.00))
				end
				gui.FaText(723, 6, fa.GEAR, fa_font[4])
				gui.Text(700, 22, 'Настройки')
				imgui.PopStyleColor(1)
			elseif not new_scene and tab == 'rp_zona' then
				imgui.SetCursorPos(imgui.ImVec2(772, 5))
				if imgui.InvisibleButton(u8'##Добавить новую сцену', imgui.ImVec2(65, 32)) then
					new_scene = true
					num_scene = 0
					local bool_scene_new = {
						name = '',
						icon = 32,
						color = 0,
						x = 20,
						y = 20,
						size = 13,
						flag = 5,
						dist = 21,
						vis = 100,
						invers = false,
						preview = false,
						rp = {}
					}
					scene = bool_scene_new
					font_sc = renderCreateFont('Arial', scene.size, scene.flag)
				end
				
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[24][1] < 0.45 then
						an[24][1] = an[24][1] + (anim * 1)
					end
				else
					if an[24][1] > 0 then
						an[24][1] = an[24][1] - (anim * 1)
					end
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[24][1], 0.50 - an[24][1], 0.50 - an[24][1], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[24][1], 0.50 + an[24][1], 0.50 + an[24][1], 1.00))
				end
				gui.FaText(797, 6, fa.PLUS, fa_font[4])
				gui.Text(777, 22, 'Добавить')
				imgui.PopStyleColor(1)
			elseif new_scene and tab == 'rp_zona' then
				imgui.SetCursorPos(imgui.ImVec2(238, 5))
				if imgui.InvisibleButton(u8'##Просмотр сцены', imgui.ImVec2(58, 32)) then
					scene_active = true
					scene_edit_pos = false
					windows.main[0] = false
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
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[24][5] < 0.45 then
						an[24][5] = an[24][5] + (anim * 1)
					end
				else
					if an[24][5] > 0 then
						an[24][5] = an[24][5] - (anim * 1)
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(182, 5))
				if imgui.InvisibleButton(u8'##Выйти из редактора сцены', imgui.ImVec2(48, 32)) then
					num_scene = 0
					new_scene = false
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[24][2] < 0.45 then
						an[24][2] = an[24][2] + (anim * 1)
					end
				else
					if an[24][2] > 0 then
						an[24][2] = an[24][2] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(120, 5))
				if imgui.InvisibleButton(u8'##Удалить сцену', imgui.ImVec2(56, 32)) then
					if num_scene ~= 0 then
						table.remove(setting.scene, num_scene)
					end
					num_scene = 0
					new_scene = false
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[24][3] < 0.45 then
						an[24][3] = an[24][3] + (anim * 1)
					end
				else
					if an[24][3] > 0 then
						an[24][3] = an[24][3] - (anim * 1)
					end
				end
				
				imgui.SetCursorPos(imgui.ImVec2(45, 5))
				if imgui.InvisibleButton(u8'##Сохранить сцену', imgui.ImVec2(64, 32)) then
					if num_scene == 0 then
						table.insert(setting.scene, scene)
					else
						setting.scene[num_scene] = scene
					end
					new_scene = false
					num_scene = 0
					save()
				end
				if imgui.IsItemActive() or imgui.IsItemHovered() then
					if an[24][4] < 0.45 then
						an[24][4] = an[24][4] + (anim * 1)
					end
				else
					if an[24][4] > 0 then
						an[24][4] = an[24][4] - (anim * 1)
					end
				end
				
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[24][5], 0.50 - an[24][5], 0.50 - an[24][5], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[24][5], 0.50 + an[24][5], 0.50 + an[24][5], 1.00))
				end
				gui.FaText(258, 6, fa.EYE, fa_font[4])
				gui.Text(239, 22, 'Просмотр')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[24][2], 0.50 - an[24][2], 0.50 - an[24][2], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[24][2], 0.50 + an[24][2], 0.50 + an[24][2], 1.00))
				end
				gui.FaText(197, 6, fa.ARROW_RIGHT_TO_BRACKET, fa_font[4])
				gui.Text(187, 22, 'Выйти')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[24][3], 0.50 - an[24][3], 0.50 - an[24][3], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[24][3], 0.50 + an[24][3], 0.50 + an[24][3], 1.00))
				end
				gui.FaText(140, 6, fa.TRASH, fa_font[4])
				gui.Text(123, 22, 'Удалить')
				imgui.PopStyleColor(1)
				if setting.cl == 'White' then
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 - an[24][4], 0.50 - an[24][4], 0.50 - an[24][4], 1.00))
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.50 + an[24][4], 0.50 + an[24][4], 0.50 + an[24][4], 1.00))
				end
				gui.FaText(70, 6, fa.FLOPPY_DISK, fa_font[4])
				gui.Text(47, 22, 'Сохранить')
				imgui.PopStyleColor(1)
			end
			new_action_popup()
		end
		
		--> Кнопка закрытия окна
		if setting.close_button then
			imgui.SetCursorPos(imgui.ImVec2(11, 11))
			if imgui.InvisibleButton(u8'##Закрыть главное окно', imgui.ImVec2(20, 20)) or close_win.main then
				if setting.anim_win then
					close_win_anim = true
				else
					windows.main[0] = false 
					close_win.main = false
				end
			end
		end
		
		if close_win_anim then
			local size_win = imgui.GetWindowSize()
			local p = imgui.GetWindowPos()
			win_y = p.y + size_win.y / 2
			win_x = p.x + size_win.x / 2
			anim_func = false
			if win_x < sx + 800 then
				win_x = win_x + (anim * 4500)
				if win_x >= sx + 500 then 
					win_x = sx + 500 
					close_win_anim = false
					windows.main[0] = false 
					close_win.main = false
				end
			end
		end
		
		if setting.close_button then
			if imgui.IsItemHovered() then
				gui.DrawCircle({21 + an[28], 21}, 7, imgui.ImVec4(0.98, 0.30, 0.38, 1.00))
			else
				gui.DrawCircle({21 + an[28], 21}, 7, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
			end
		end
		if not setting.first_start then
			gui.DrawLine({4, 38}, {844, 38}, cl.line)
			gui.DrawLine({4, 408}, {844, 408}, cl.line)
		end
	
        imgui.End()
	end
)
--[[
local inputField = imgui.new.char[256]()
local sx, sy = getScreenResolution()

win.smi = imgui.OnFrame(
    function()
        return dialogData ~= nil
    end,
    function(main)
        SmiEdit()
    end
)
]]
win.shpora = imgui.OnFrame(
	function() return windows.shpora[0] and not scene_active end,
	function(main)
        imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(808, 708))
        imgui.Begin('Shpora', windows.shpora,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + (size_win and imgui.WindowFlags.NoMove or 0))
		gui.Draw({4, 4}, {800, 700}, cl.main, 12, 15)
		gui.DrawLine({4, 38}, {804, 38}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(11, 11))
		if imgui.InvisibleButton(u8'##Закрыть окно шпаргалки', imgui.ImVec2(20, 20)) then
			windows.shpora[0] = false
		end
		if imgui.IsItemHovered() then
			gui.DrawCircle({21, 21}, 7, imgui.ImVec4(0.98, 0.30, 0.38, 1.00))
		else
			gui.DrawCircle({21, 21}, 7, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
		end
		
		imgui.SetCursorPos(imgui.ImVec2(15, 50))
		imgui.BeginChild(u8'Текст шпаргалки', imgui.ImVec2(778, 638), false)
		imgui.PushFont(font[3])
		for line in text_shpora:gmatch('[^\n]+') do
			imgui.TextWrapped(line)
		end
		imgui.PopFont()
		imgui.EndChild()
	
		imgui.End()
	end
)

win.reminder = imgui.OnFrame(
	function() return windows.reminder[0] and not scene_active end,
	function(main)
        imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(358, 158))
        imgui.Begin('Reminder', windows.reminder,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + (size_win and imgui.WindowFlags.NoMove or 0))
		gui.Draw({4, 4}, {350, 150}, cl.main, 12, 15)
		gui.DrawLine({4, 38}, {354, 38}, cl.line)
		imgui.SetCursorPos(imgui.ImVec2(11, 11))
		if imgui.InvisibleButton(u8'##Закрыть окно напоминания', imgui.ImVec2(20, 20)) then
			windows.reminder[0] = false
		end
		if imgui.IsItemHovered() then
			gui.DrawCircle({21, 21}, 7, imgui.ImVec4(0.98, 0.30, 0.38, 1.00))
		else
			gui.DrawCircle({21, 21}, 7, imgui.ImVec4(0.98, 0.40, 0.38, 1.00))
		end
		
		imgui.SetCursorPos(imgui.ImVec2(15, 50))
		imgui.BeginChild(u8'Текст напоминания', imgui.ImVec2(328, 100), false)
		imgui.PushFont(font[3])
		local calc_text_rem = imgui.CalcTextSize(text_reminder)
		local wrapped_text, newline_count = wrapText(u8:decode(text_reminder), 42, 210)
		local i_line = 0
		for line in wrapped_text:gmatch('[^\n]+') do
			local calc_text_rem = imgui.CalcTextSize(u8(line))
			gui.Text(164 - (calc_text_rem.x / 2), 16 + (i_line * 15), line, font[3])
			i_line = i_line + 1
		end
		imgui.PopFont()
		imgui.EndChild()
	
		imgui.End()
	end
)
	


win.mini_player = imgui.OnFrame(
	function() return windows.player[0] and not scene_active end,
	function(mini_player)
		mini_player.HideCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy - 60), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(318, 88))
        imgui.Begin('Music player', windows.mini_player,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoMove)
		gui.Draw({4, 4}, {310, 80}, imgui.ImVec4(0.02, 0.02, 0.02, 1.00), 12, 15)
		
		draw_gradient_image_music(0.9, 26, 26, 36, 36, 15)
		imgui.SetCursorPos(imgui.ImVec2(18, 18))
		local p_cursor_screen = imgui.GetCursorScreenPos()
		local s_image = imgui.ImVec2(52, 52)
		if play.status_image == play.i and play.i ~= 0 then
			imgui.GetWindowDrawList():AddImageRounded(play.image_label, p_cursor_screen, imgui.ImVec2(p_cursor_screen.x + s_image.x, p_cursor_screen.y + s_image.y), imgui.ImVec2(0, 0), imgui.ImVec2(1, 1), imgui.GetColorU32Vec4(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 12)
		else
			imgui.Image(image_no_label, imgui.ImVec2(52, 52))
		end
		
		if play.tab ~= 'RADIO' and play.tab ~= 'RECORD' then
			gui.Draw({85, 65}, {215, 4}, imgui.ImVec4(0.21, 0.21, 0.21, 1.00), 20, 15)
			gui.Draw({85, 65}, {(215 / play.len_time) * play.pos_time, 4}, cl.def, 20, 15)
		end
		
		local name_record = {'Record Dance', 'Megamix', 'Party 24/7', 'Phonk', 'Гоп FM', 'Руки Вверх', 'Dupstep', 'Big Hits', 'Organic', 'Russian Hits'}
		local name_radio = {'Европа Плюс', 'DFM', 'Шансон', 'Радио Дача', 'Дорожное', 'Маяк', 'Наше', 'LoFi Hip-Hop', 'Максимум', '90s Eurodance'}
		imgui.PushFont(font[3])
		if play.tab == 'RECORD' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			gui.Text(85, 27, name_record[play.i], font[3])
			imgui.PopStyleColor(1)
			
			imgui.SetCursorPos(imgui.ImVec2(85, 44))
			imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), u8('Record'))
			
		elseif play.tab == 'RADIO' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			gui.Text(85, 27, name_radio[play.i], font[3])
			imgui.PopStyleColor(1)
			
			imgui.SetCursorPos(imgui.ImVec2(85, 44))
			imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), u8('Radio'))
		else
			if play.status ~= 'NULL' then
				local track_name, newline_count_2 = wrapText(play.info.name, 30, 30)
				local track_artist, newline_count_2 = wrapText(play.info.artist, 28, 28)
				
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
				gui.Text(85, 19, track_name, font[3])
				imgui.PopStyleColor(1)
				
				imgui.SetCursorPos(imgui.ImVec2(85, 37))
				imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), u8(track_artist))
			end
		end
		imgui.PopFont()
		
        imgui.End()
	end
)

win.fast = imgui.OnFrame(
	function() return windows.fast[0] and not scene_active end,
	function(fast)
    	local size_win = {x = 348, y = 49 + math.max((#setting.fast.one_win * 34), (#setting.fast.two_win * 34))}
    	local visible_draw = 0
    	if #setting.fast.one_win ~= 0 and #setting.fast.two_win ~= 0 then
 			size_win.x = 691
        	visible_draw = 171
    	end

    	imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, setting.visible_fast / 100)
    	imgui.SetNextWindowPos(imgui.ImVec2(sx / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    	imgui.SetNextWindowSize(imgui.ImVec2(size_win.x, size_win.y + 20))
		imgui.Begin('Fast win 1', windows.fast, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoSavedSettings)
		local window_pos = imgui.GetCursorScreenPos()
		local mouse_pos_all_screen = imgui.GetMousePos()
		local mouse_pos = mouse_pos_all_screen.x - window_pos.x - 10 - visible_draw
		if mouse_pos <= 0 then
			mouse_pos = 0.01
		elseif mouse_pos >= 331 then
			mouse_pos = 330.99
		end
		
		imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 1.0)
		
		gui.Draw({10 + visible_draw, 16}, {331, 4}, imgui.ImVec4(0.21, 0.21, 0.21, 1.00), 20, 15)
		imgui.SetCursorPos(imgui.ImVec2(10 + visible_draw, 4))
		imgui.InvisibleButton(u8'##Управление видимостью окна', imgui.ImVec2(331, 26))
		if imgui.IsItemActive() then
			gui.Draw({10 + visible_draw, 16}, {mouse_pos, 4}, cl.def, 20, 15)
			setting.visible_fast = mouse_pos / 3.31
			bool_button_active_music = true
		else
			if bool_button_active_music then
				bool_button_active_music = false
				setting.visible_fast = mouse_pos / 3.31
				save()
				gui.Draw({10 + visible_draw, 16}, {mouse_pos, 4}, cl.def, 20, 15)
			else
				gui.Draw({10 + visible_draw, 16}, {3.31 * setting.visible_fast, 4}, cl.def, 20, 15)
			end
		end
		if imgui.IsItemHovered() then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.00, 1.00, 1.00, 1.00))
			gui.Text(118 + visible_draw, 1, 'Прозрачность окна', font[3])
			imgui.PopStyleColor(1)
		end
		imgui.PopStyleVar(1)
		
		gui.Draw({4, 24}, {size_win.x - 4, size_win.y - 4}, cl.main, 12, 15)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		if imgui.InvisibleButton(u8'##Закрыть окно БД', imgui.ImVec2(16, 16)) or close_win.fast then
			windows.fast[0] = false
			close_win.fast = false
		end
		imgui.SetCursorPos(imgui.ImVec2(16, 36))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemHovered() then
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.32, 0.38, 1.00)), 60)
		else
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x - 0.4, p.y - 0.2), 7, imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.42, 0.38, 1.00)), 60)
		end
		
		local nick_name_fast = fast_nick .. ' [' .. fast_id .. ']'
		imgui.PushFont(bold_font[1])
		local calc = imgui.CalcTextSize(nick_name_fast) 
		imgui.PopFont()
		gui.Text(-(calc.x / 2) + ((size_win.x - 8) / 2) + 4, 33, nick_name_fast, bold_font[1])
		gui.DrawLine({4, 62}, {size_win.x - 8, 62}, cl.line)
		
		local pos_x = 9
		if #setting.fast.one_win ~= 0 and #setting.fast.two_win ~= 0 then
			pos_x = 352
		end
		
		if #setting.fast.one_win ~= 0 then
			for i = 1, #setting.fast.one_win do
				local bool_cmd = true
				local name_fast = setting.fast.one_win[i].name
				if setting.fast.one_win[i].name:gsub('%s+', '') == '' then
					name_fast = u8'Без названия [' .. i .. ']'
				end
				local access = false
				for c = 1, #cmd[1] do
					if cmd[1][c].cmd == setting.fast.one_win[i].cmd then
						if cmd[1][c].rank > setting.rank then
							access = true
							break
						end
					end
				end
				local name_fast_button_1 = u8:decode(setting.fast.one_win[i].name)
				if #name_fast_button_1 > 41 then
					name_fast_button_1 = name_fast_button_1:sub(1, 41) .. '...'
				end
				name_fast_button_1 = u8(name_fast_button_1)
				if not access then
					if gui.Button(name_fast_button_1 .. '##fast' .. i, {9, 68 + ((i - 1) * 34)}, {333, 29}) then
						local tr_cmd = false
						local other_cmd = false
						local UID_cmd = 0
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == setting.fast.one_win[i].cmd then
								tr_cmd = true
								UID_cmd = cmd[1][c].UID
								break 
							end
						end
						if not tr_cmd then
							for c = 1, #setting.command_tabs do
								if setting.command_tabs[c] == setting.fast.one_win[i].cmd and setting.command_tabs[c] ~= '' then
									other_cmd = true
									break 
								end
							end
						end
						fast_id = tostring(fast_id)
						if tr_cmd then
							if setting.fast.one_win[i].send then
								if setting.fast.one_win[i].id then
									cmd_start(fast_id, tostring(UID_cmd) .. setting.fast.one_win[i].cmd)
								else
									cmd_start('', tostring(UID_cmd) .. setting.fast.one_win[i].cmd)
								end
							else
								if setting.fast.one_win[i].id then
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.one_win[i].cmd .. ' ' .. fast_id)
								else
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.one_win[i].cmd)
								end
							end
						elseif other_cmd then
							start_other_cmd(setting.fast.one_win[i].cmd, fast_id)
						else
							if setting.fast.one_win[i].send then
								if setting.fast.one_win[i].id then
									sampSendChat(setting.fast.one_win[i].cmd .. ' ' .. fast_id)
								else
									sampSendChat('/' .. setting.fast.one_win[i].cmd)
								end
								
							else
								sampSetChatInputEnabled(true)
								sampSetChatInputText('/' .. setting.fast.one_win[i].cmd)
							end
						end
						
						windows.fast[0] = false
					end
				else
					gui.Button(name_fast_button_1 .. '##fast' .. i, {9, 68 + ((i - 1) * 34)}, {333, 29}, false)
				end
			end
		end
		if #setting.fast.two_win ~= 0 then
			for i = 1, #setting.fast.two_win do
				local bool_cmd = true
				local name_fast = setting.fast.two_win[i].name
				if setting.fast.two_win[i].name:gsub('%s+', '') == '' then
					name_fast = u8'Без названия [' .. i .. ']'
				end
				local access = false
				for c = 1, #cmd[1] do
					if cmd[1][c].cmd == setting.fast.two_win[i].cmd then
						if cmd[1][c].rank > setting.rank then
							access = true
							break
						end
					end
				end
				local name_fast_button_2 = u8:decode(setting.fast.two_win[i].name)
				if #name_fast_button_2 > 41 then
					name_fast_button_2 = name_fast_button_2:sub(1, 41) .. '...'
				end
				name_fast_button_2 = u8(name_fast_button_2)
				if not access then
					if gui.Button(name_fast_button_2 .. '##fast2' .. i, {pos_x, 68 + ((i - 1) * 34)}, {333, 29}) then
						local tr_cmd = false
						local other_cmd = false
						local UID_cmd = 0
						for c = 1, #cmd[1] do
							if cmd[1][c].cmd == setting.fast.two_win[i].cmd then
								tr_cmd = true
								UID_cmd = cmd[1][c].UID
								break 
							end
						end
						if not tr_cmd then
							for c = 1, #setting.command_tabs do
								if setting.command_tabs[c] == setting.fast.two_win[i].cmd and setting.command_tabs[c] ~= '' then
									other_cmd = true
									break 
								end
							end
						end
						fast_id = tostring(fast_id)
						if tr_cmd then
							if setting.fast.two_win[i].send then
								if setting.fast.two_win[i].id then
									cmd_start(fast_id, tostring(UID_cmd) .. setting.fast.two_win[i].cmd)
								else
									cmd_start('', tostring(UID_cmd) .. setting.fast.two_win[i].cmd)
								end
							else
								if setting.fast.two_win[i].id then
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.two_win[i].cmd .. ' ' .. fast_id)
								else
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.two_win[i].cmd)
								end
							end
						elseif other_cmd then
							start_other_cmd(setting.fast.two_win[i].cmd, fast_id)
						else
							if setting.fast.two_win[i].send then
								if setting.fast.two_win[i].id then
									sampSendChat('/' .. setting.fast.two_win[i].cmd .. ' ' .. fast_id)
								else
									sampSendChat('/' .. setting.fast.two_win[i].cmd)
								end
							else
								if setting.fast.two_win[i].id then
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.two_win[i].cmd .. ' ' .. fast_id)
								else
									sampSetChatInputEnabled(true)
									sampSetChatInputText('/' .. setting.fast.two_win[i].cmd)
								end
							end
						end
						
						windows.fast[0] = false
					end
				else
					gui.Button(name_fast_button_2 .. '##fast2' .. i, {pos_x, 68 + ((i - 1) * 34)}, {333, 29}, false)
				end
			end
		end
		imgui.End()
		imgui.PopStyleVar(1)
	end
)

win.action = imgui.OnFrame(
	function() return windows.action[0] and not scene_active end,
	function(action)
		action.HideCursor = true
		local size_win = {x = 300, y = 25 + (#dialog_act.info * 24)}
		if dialog_act.enter then
			size_win = {x = 300, y = 39}
		end
		local x_pos = sx - (size_win.x / 2) - 20
		if dialog_act.status then
			if x_act_dialog > x_pos then
				x_act_dialog = x_act_dialog - (anim * 1400)
			elseif x_act_dialog <= x_pos then
				x_act_dialog = x_pos
			end
		else
			if x_act_dialog < (sx + 200) then
				x_act_dialog = x_act_dialog + (anim * 1200)
			else
				windows.action[0] = false
			end
		end
		
        imgui.SetNextWindowPos(imgui.ImVec2(x_act_dialog, sy - (size_win.y / 2) - 20), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(size_win.x, size_win.y))
        imgui.Begin('Action reminder', windows.action,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoMove)
		gui.Draw({4, 4}, {size_win.x - 4, size_win.y - 4}, imgui.ImVec4(0.10, 0.10, 0.10, 0.70), 12, 15)
		
		if dialog_act.enter then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.96, 0.96, 0.96, 1.00))
			gui.Text(20, 11, 'Нажмите ' .. setting.enter_key[2] .. ', чтобы продолжить', bold_font[1])
		else 
			if dialog_act.info ~= 0 then
				for i = 1, #dialog_act.info do
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.96, 0.96, 0.96, 1.00))
					if i ~= 10 then
						gui.Text(20, 17 + ((i - 1) * 24), 'NUM ' .. i .. ' - ' .. u8:decode(dialog_act.info[i]), bold_font[1])
					else
						gui.Text(20, 17 + ((i - 1) * 24), 'NUM 0 - ' .. u8:decode(dialog_act.info[i]), bold_font[1])
					end
				end
			end
		end
		
		imgui.End()
	end
)

win.stat = imgui.OnFrame(
	function() return windows.stat[0] and not scene_active end,
	function(stat)
		stat.HideCursor = true
		local size_y_stat = 38
		size_y_stat = size_y_stat + (setting.stat_on_screen.current_time and 21 or 0)
		size_y_stat = size_y_stat + (setting.stat_on_screen.current_date and setting.stat_on_screen.current_time and 24 or setting.stat_on_screen.current_date and 8 or 0)
		local num_stat = 0
		size_y_stat = size_y_stat + (setting.stat_on_screen.day and 7 or 0) + (setting.stat_on_screen.afk and 7 or 0) + (setting.stat_on_screen.all and 7 or 0) + (setting.stat_on_screen.ses_day and 7 or 0) + (setting.stat_on_screen.ses_afk and 7 or 0) + (setting.stat_on_screen.ses_all and 7 or 0)
		num_stat = num_stat  + (setting.stat_on_screen.day and 1 or 0) + (setting.stat_on_screen.afk and 1 or 0) + (setting.stat_on_screen.all and 1 or 0) + (setting.stat_on_screen.ses_day and 1 or 0) + (setting.stat_on_screen.ses_afk and 1 or 0) + (setting.stat_on_screen.ses_all and 1 or 0)
		if num_stat > 0 then
			size_y_stat = size_y_stat + ((num_stat - 1) * 13)
			size_y_stat = size_y_stat + (setting.stat_on_screen.current_time and 17 or setting.stat_on_screen.current_date and 17 or 0)
		end
		
		--[[if setting.stat_on_screen.current_time then
			size_y_stat = size_y_stat + 21
		end]]
		local function format_custom_date()
			local weekdays = {'Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'}
			local months = {'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'}

			local current_time = os.date('*t')
			local weekday = weekdays[current_time.wday]
			local month = months[current_time.month]
			local day = current_time.day

			return weekday .. ', ' .. day .. ' ' .. month
		end
		local function format_time(seconds)
			local days = math.floor(seconds / 86400)
			local hours = math.floor((seconds % 86400) / 3600)
			local minutes = math.floor((seconds % 3600) / 60)
			local secs = seconds % 60

			if days > 0 then
				return string.format('%02d д. %02d ч. %02d мин. %02d сек.', days, hours, minutes, secs)
			else
				return string.format('%02d ч. %02d мин. %02d сек.', hours, minutes, secs)
			end
		end
		imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, (setting.stat_on_screen.visible > 15) and setting.stat_on_screen.visible / 100 or 0.15)
        imgui.SetNextWindowPos(imgui.ImVec2(setting.position_stat.x, setting.position_stat.y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(298, size_y_stat + 8))
        imgui.Begin('Stat Online', windows.stat,  imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoMove)
		gui.Draw({4, 4}, {290, size_y_stat}, imgui.ImVec4(0.05, 0.05, 0.05, 1.00), 12, 15)
		
		if imgui.IsMouseClicked(0) and change_pos_onstat then
			change_pos_onstat = false 
		end
		
		local pos_pl_stat = 0
		if setting.stat_on_screen.current_time then
			local time_format = os.date('%H:%M:%S')
			imgui.PushFont(bold_font[3])
			local calc_time = imgui.CalcTextSize(time_format)
			gui.Text(149 - (calc_time.x / 2), 16 + pos_pl_stat, time_format, bold_font[3])
			imgui.PopFont()
			pos_pl_stat = 38
		end
		if setting.stat_on_screen.current_date then
			local time_format = format_custom_date()
			imgui.PushFont(bold_font[1])
			local calc_date = imgui.CalcTextSize(u8(time_format))
			gui.Text(149 - (calc_date.x / 2), 16 + pos_pl_stat, time_format, bold_font[1])
			imgui.PopFont()
			pos_pl_stat = pos_pl_stat + 26
		end
		if setting.stat_on_screen.day then
			gui.Text(20, 16 + pos_pl_stat, 'Чистый за день: ' .. format_time(setting.stat.cl[1]), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		if setting.stat_on_screen.afk then
			gui.Text(20, 16 + pos_pl_stat, 'АФК за день: ' .. format_time(setting.stat.afk[1]), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		if setting.stat_on_screen.all then
			gui.Text(20, 16 + pos_pl_stat, 'Всего за день: ' .. format_time(setting.stat.cl[1] + setting.stat.afk[1]), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		if setting.stat_on_screen.ses_day then
			gui.Text(20, 16 + pos_pl_stat, 'Чистый за сессию: ' .. format_time(stat_ses.cl), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		if setting.stat_on_screen.ses_afk then
			gui.Text(20, 16 + pos_pl_stat, 'АФК за сессию: ' .. format_time(stat_ses.afk), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		if setting.stat_on_screen.ses_all then
			gui.Text(20, 16 + pos_pl_stat, 'Всего за сессию: ' .. format_time(stat_ses.all), font[3])
			pos_pl_stat = pos_pl_stat + 20
		end
		
		imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 1.0)
        imgui.End()
	end
)

function theme()
    imgui.SwitchContext()
    local ImVec4 = imgui.ImVec4
    imgui.GetStyle().WindowPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().FramePadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1
    imgui.GetStyle().WindowRounding = 7 --> Скругление окна
    imgui.GetStyle().ChildRounding = 7
    imgui.GetStyle().FrameRounding = 7
    imgui.GetStyle().PopupRounding = 7
    imgui.GetStyle().ScrollbarRounding = 7
    imgui.GetStyle().GrabRounding = 7
    imgui.GetStyle().TabRounding = 7
 
    imgui.GetStyle().Colors[imgui.Col.Text]                   = cl.text
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 0.00) --> Окно
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = cl.main
    imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.00, 0.30, 0.00, 0.00) --> Обводка окна
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00) --> Обводка окна
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.00, 0.00, 0.00, 0.00) --> Инпут
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.00) --> Фон скроллбара
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.88, 0.26, 0.94, 0.00) --> Слайдер
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.96, 0.00) --> Слайдер
    imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.98, 0.26, 0.26, 0.40)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.98, 0.06, 0.06, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.98, 0.26, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.50, 0.50, 0.50, 0.50)
end

imgui.OnInitialize(function()
    theme()
end)

function change_design(design_bool, bool_theme)
	local def = imgui.ImVec4(setting.color_def[1], setting.color_def[2], setting.color_def[3], 1.00)
	local c_defolt_black = {
		main = imgui.ImVec4(0.10, 0.10, 0.10, 1.00),
		tab = imgui.ImVec4(0.13, 0.13, 0.13, 1.00),
		text = imgui.ImVec4(0.95, 0.95, 0.95, 1.00),
		bg = imgui.ImVec4(0.20, 0.20, 0.20, 1.00),
		bg2 = imgui.ImVec4(0.25, 0.25, 0.25, 1.00),
		line = imgui.ImVec4(0.18, 0.18, 0.18, 1.00),
		def = def,
		circ_im = imgui.ImVec4(0.16, 0.16, 0.16, 1.00)
	}
	local c_defolt_white = {
		main = imgui.ImVec4(0.95, 0.93, 0.92, 1.00),
		tab = imgui.ImVec4(0.90, 0.88, 0.86, 1.00),
		text = imgui.ImVec4(0.10, 0.10, 0.10, 1.00),
		bg = imgui.ImVec4(0.98, 0.98, 0.98, 1.00),
		bg2 = imgui.ImVec4(0.90, 0.90, 0.90, 1.00),
		line = imgui.ImVec4(0.77, 0.77, 0.77, 1.00),
		def = def,
		circ_im = imgui.ImVec4(0.82, 0.82, 0.82, 1.00)
	}
	if design_bool == 'White' and (bool_theme == nil or bool_theme == true) then
		local jc
		if setting.cl ~= 'White' then
			jc = {
				main = {0.10, 0.10, 0.10},
				tab = {0.13, 0.13, 0.13},
				text = {0.95, 0.95, 0.95},
				circ_im = {0.16, 0.16, 0.16}
			}
		else
			jc = {
				main = {0.93, 0.93, 0.93},
				tab = {0.88, 0.88, 0.88},
				text = {0.10, 0.10, 0.10},
				circ_im = {0.82, 0.82, 0.82}
			}
		end
		setting.cl = 'White'
		
		lua_thread.create(function()
			local stop_while = {false, false, false, false, false, false, false, false}
			while true do
				wait(0)
				local anim_bool = (anim * 4)
				
				if jc.main[1] < 0.95 then
					jc.main[1] = jc.main[1] + anim_bool
				else
					stop_while[1] = true
				end
				if jc.main[2] < 0.93 then
					jc.main[2] = jc.main[2] + anim_bool
				else
					stop_while[2] = true
				end
				if jc.main[3] < 0.92 then
					jc.main[3] = jc.main[3] + anim_bool
				else
					stop_while[3] = true
				end
				
				if jc.tab[1] < 0.90 then
					jc.tab[1] = jc.tab[1] + anim_bool
				else
					stop_while[4] = true
				end
				if jc.tab[2] < 0.88 then
					jc.tab[2] = jc.tab[2] + anim_bool
				else
					stop_while[5] = true
				end
				if jc.tab[3] < 0.86 then
					jc.tab[3] = jc.tab[3] + anim_bool
				else
					stop_while[6] = true
				end
				
				if jc.text[1] > 0.10 then
					jc.text[1] = jc.text[1] - anim_bool
					jc.text = {jc.text[1], jc.text[1], jc.text[1]}
				else
					stop_while[7] = true
				end
				
				if jc.circ_im[1] < 0.82 then
					jc.circ_im[1] = jc.circ_im[1] + anim_bool
					jc.circ_im = {jc.circ_im[1], jc.circ_im[1], jc.circ_im[1]}
				else
					stop_while[8] = true
				end
				
				cl = {
					main = imgui.ImVec4(jc.main[1], jc.main[2], jc.main[3], 1.00),
					tab = imgui.ImVec4(jc.tab[1], jc.tab[2], jc.tab[3], 1.00),
					text = imgui.ImVec4(jc.text[1], jc.text[2], jc.text[3], 1.00),
					bg = imgui.ImVec4(0.98, 0.98, 0.98, 1.00),
					bg2 = imgui.ImVec4(0.99, 0.99, 0.99, 1.00),
					line = imgui.ImVec4(0.77, 0.77, 0.77, 1.00),
					def = def,
					circ_im = imgui.ImVec4(jc.circ_im[1], jc.circ_im[2], jc.circ_im[3], 1.00)
				}
				theme()
				if (stop_while[1] and stop_while[2] and stop_while[3] and stop_while[4] and stop_while[5] 
				and stop_while[6] and stop_while[7] and stop_while[8]) or setting.cl == 'Black' then
					cl = c_defolt_white
					theme()
					
					break
				end
			end
		end)
	elseif design_bool == 'Black' and bool_theme == nil then
		setting.cl = 'Black'
		local jc = {
			main = {0.93, 0.93, 0.93},
			tab = {0.88, 0.88, 0.88},
			text = {0.10, 0.10, 0.10},
			circ_im = {0.82, 0.82, 0.82}
		}
		
		lua_thread.create(function()
			local stop_while = {false, false, false, false}
			while true do
				wait(0)
				local anim_bool = (anim * 4)
				
				if jc.main[1] > 0.10 then
					jc.main[1] = jc.main[1] - anim_bool
					jc.main = {jc.main[1], jc.main[1], jc.main[1]}
				else
					stop_while[1] = true
				end
				
				if jc.tab[1] > 0.13 then
					jc.tab[1] = jc.tab[1] - anim_bool
					jc.tab = {jc.tab[1], jc.tab[1], jc.tab[1]}
				else
					stop_while[2] = true
				end
				
				if jc.text[1] < 0.95 then
					jc.text[1] = jc.text[1] + anim_bool
					jc.text = {jc.text[1], jc.text[1], jc.text[1]}
				else
					stop_while[3] = true
				end
				
				if jc.circ_im[1] > 0.16 then
					jc.circ_im[1] = jc.circ_im[1] - anim_bool
					jc.circ_im = {jc.circ_im[1], jc.circ_im[1], jc.circ_im[1]}
				else
					stop_while[4] = true
				end
				
				cl = {
					main = imgui.ImVec4(jc.main[1], jc.main[2], jc.main[3], 1.00),
					tab = imgui.ImVec4(jc.tab[1], jc.tab[2], jc.tab[3], 1.00),
					text = imgui.ImVec4(jc.text[1], jc.text[2], jc.text[3], 1.00),
					bg = imgui.ImVec4(0.20, 0.20, 0.20, 1.00),
					bg2 = imgui.ImVec4(0.25, 0.25, 0.25, 1.00),
					line = imgui.ImVec4(0.18, 0.18, 0.18, 1.00),
					def = def,
					circ_im = imgui.ImVec4(jc.circ_im[1], jc.circ_im[2], jc.circ_im[3], 1.00)
				}
				theme()
				if (stop_while[1] and stop_while[2] and stop_while[3] and stop_while[4]) or setting.cl == 'White' then
					cl = c_defolt_black
					theme()
					
					break
				end
			end
		end)
	elseif bool_theme ~= nil then
		if design_bool == 'White' then
			cl = c_defolt_white
		else
			cl = c_defolt_black
		end
	end
	if bool_theme == nil or bool_theme == true then
		theme()
	end
end

--> Акценты
sampRegisterChatCommand('r', function(text_accents_r) 
	if setting.teg_r ~= '' and setting.teg_r ~= ' ' and text_accents_r ~= '' and not setting.accent.func then
		sampSendChat('/r [' .. u8:decode(setting.teg_r)..']: ' .. text_accents_r)
	elseif setting.teg_r == '' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r [' .. u8:decode(setting.accent.text) .. ' акцент]: ' .. text_accents_r)
	elseif setting.teg_r ~= '' and setting.teg_r ~= ' ' and text_accents_r ~= '' and setting.accent.func and setting.accent.r and setting.accent.text ~= '' then
		sampSendChat('/r [' .. u8:decode(setting.teg_r) .. '][' .. u8:decode(setting.accent.text) .. ' акцент]: ' .. text_accents_r)
	else
		sampSendChat('/r ' .. text_accents_r)
	end 
end)

sampRegisterChatCommand('s', function(text_accents_s) 
	if text_accents_s ~= '' and setting.accent.func and setting.accent.s and setting.accent.text ~= '' then
		sampSendChat('/s [' .. u8:decode(setting.accent.text)..' акцент]: ' .. text_accents_s)
	else
		sampSendChat('/s ' .. text_accents_s)
	end 
end)

sampRegisterChatCommand('f', function(text_accents_f) 
	if text_accents_f ~= '' and setting.accent.func and setting.accent.f and setting.accent.text ~= '' then
		sampSendChat('/f [' .. u8:decode(setting.accent.text)..' акцент]: ' .. text_accents_f)
	else
		sampSendChat('/f ' .. text_accents_f)
	end 
end)

--> Прочие функции
function start_other_cmd(cmd_func, arguments)
	if cmd_func == setting.cmd_open_win then
		open_main()
	else
		local tab_open = {'cmd', 'shpora', 'dep', 'sob', 'reminder', 'stat', 'music', 'rp_zona', 'actions'}
		local tab_name_open = {u8'Команды', u8'Шпаргалки', u8'Департамент', u8'Собеседование', u8'Напоминания', u8'Статистика онлайна', u8'Музыка', u8'РП зона', u8'Действия'}
		for i = 1, #setting.command_tabs do
			if setting.command_tabs[i] == cmd_func then
				tab = tab_open[i]
				name_tab = tab_name_open[i]
				if not windows.main[0] then
					open_main()
				end
				if i == 4 and arguments:find('(%d+)') and setting.sob_id_arg then
					local arg_id = arguments:match('(%d+)')
					arg_id = tonumber(arg_id)
					
					if arg_id ~= '' and (setting.sob.min_exp ~= '' or not setting.sob.auto_exp) and (setting.sob.min_law ~= '' 
					or not setting.sob.auto_law) and (setting.sob.min_narko ~= '' or not setting.sob.auto_narko) then
						run_sob = true
						if sampIsPlayerConnected(arg_id) then
							sob_info = {
								exp = -1,
								law = -1,
								narko = -1,
								org = -1,
								med = -1,
								blacklist = -1,
								ticket = -1,
								bilet = -1,
								car = -1,
								gun = -1,
								moto = -1,
								warn = -1,
								bl_info = {},
								org_info = '',
								id = tonumber(arg_id),
								nick = sampGetPlayerNickname(arg_id),
								history = {}
							}
						end
					end
				end
			end
		end
	end
end

function filter_word_rus(data)
	if data.EventChar >= 1040 and data.EventChar <= 1103 then
	
        return 0
    elseif data.EventChar == 32 then
	
        return 0
    else
        return true
    end
end

function filter_word_en(data)
	if (data.EventChar >= 97 and data.EventChar <= 122) then
	
		return 0
	else
		return true
	end
end

function filter_word_en_num(data)
	if (data.EventChar >= 65 and data.EventChar <= 90) or
		(data.EventChar >= 97 and data.EventChar <= 122) or
		(data.EventChar >= 48 and data.EventChar <= 57) then
	
		return 0
	else
		return true
	end
end

function filter_word_en_rus_num(data)
    local char_code = data.EventChar
    if (char_code >= 1040 and char_code <= 1103) or
       (char_code >= 65 and char_code <= 90) or
       (char_code >= 97 and char_code <= 122) or
       (char_code == 32) or
       (char_code >= 48 and char_code <= 57) then 
	   
        return 0
    else
        return true
    end
end
TextCallbackRus = ffi.cast('int (*)(ImGuiInputTextCallbackData* data)', filter_word_rus)
TextCallbackEn = ffi.cast('int (*)(ImGuiInputTextCallbackData* data)', filter_word_en)
TextCallbackEnNum = ffi.cast('int (*)(ImGuiInputTextCallbackData* data)', filter_word_en_num)
TextCallbackEnRusNum = ffi.cast('int (*)(ImGuiInputTextCallbackData* data)', filter_word_en_rus_num)

function add_cmd_in_all_cmd()
	all_cmd = {'ts', 'r', 'd', 'go', 's', 'f'}
	if #cmd[1] ~= 0 then
		for i = 1, #cmd[1] do
			table.insert(all_cmd, cmd[1][i].cmd)
		end
	end
	if #setting.shp ~= 0 then
		for i = 1, #setting.shp do
			if setting.shp[i].cmd ~= nil and setting.shp[i].cmd ~= '' then
				table.insert(all_cmd, setting.shp[i].cmd)
			end
		end
	end
	if setting.cmd_open_win ~= '' then
		table.insert(all_cmd, setting.cmd_open_win)
	end
	for i = 1, #setting.command_tabs do
		if setting.command_tabs[i] ~= '' then
			table.insert(all_cmd, setting.command_tabs[i])
		end
	end
end

function round(num, step) --> Число, шаг округления
  return math.ceil(num / step) * step
end

function floor(number)
    return math.floor(number)
end

function compare_array(array1, array2)
    if #array1 ~= #array2 then
        return false
    end
	
    for i, v in ipairs(array1) do
        if type(v) == 'table' then
            if not compare_array(v, array2[i]) then
                return false
            end
        elseif v ~= array2[i] then
            return false
        end
    end
    
    return true
end

function compare_array_disable_order(arr1, arr2)
	if #arr1 ~= #arr2 then
		return false
	end

	local copy_arr1 = {}
	local copy_arr2 = {}
	for i, v in ipairs(arr1) do
		copy_arr1[i] = v
	end
	for i, v in ipairs(arr2) do
		copy_arr2[i] = v
	end

	table.sort(copy_arr1)
	table.sort(copy_arr2)

	for i = 1, #copy_arr1 do
		if copy_arr1[i] ~= copy_arr2[i] then
			return false
		end
	end

	return true
end

function wrapText(inputText, maxLength, maxTotalLength)
	local result = ""
	local count = 0

	if maxTotalLength and #inputText > maxTotalLength then
		inputText = inputText:sub(1, maxTotalLength - 3) .. "..."
	end

	local pos = 1
	while pos <= #inputText do
		local endPos = math.min(pos + maxLength - 1, #inputText)
		result = result .. inputText:sub(pos, endPos)
		if endPos < #inputText then
			result = result .. "\n"
			count = count + 1
		end
		pos = endPos + 1
	end

	return result, count
end

function ch_pos_on_stat()
	pos_new_stat = lua_thread.create(function()
		change_pos_onstat = true
		sampSetCursorMode(4)
		windows.main[0] = false
		if not sampIsChatInputActive() then
			while not sampIsChatInputActive() and change_pos_onstat do
				wait(0)
				local cX, cY = getCursorPos()
				setting.position_stat.x = cX
				setting.position_stat.y = cY
				if isKeyDown(0x01) then
					while isKeyDown(0x01) do wait(0) end
					change_pos_onstat = false
				end
			end
		else
			change_pos_onstat = false
		end
		save()
		sampSetCursorMode(0)
		windows.main[0] = true
		imgui.ShowCursor = true
		change_pos_onstat = false
	end)
end

function swapping(array, index, shift)
    if not array or not index or index < 1 or index > #array then
        print('Некорректные входные данные function swapping()')
        return
    end
    if shift == 0 then
        return
    end
	
    local newIndex = (index + shift - 1) % #array + 1
    local temp = array[index]
    table.remove(array, index)
    table.insert(array, newIndex, temp)
end

function bug_fix_input()
	if fix_bug_input_bool then
		for i = 0, 511 do
			imgui.GetIO().KeysDown[i] = false
		end
		for i = 0, 4 do
			imgui.GetIO().MouseDown[i] = false
		end
		imgui.GetIO().KeyCtrl = false
		imgui.GetIO().KeyShift = false
		imgui.GetIO().KeyAlt = false
		imgui.GetIO().KeySuper = false
		
		fix_bug_input_bool = false
	end
end

function start_sob_cmd(rp_sob_z)
	local rp_sob = {}
	for i = 1, #rp_sob_z do
		table.insert(rp_sob, rp_sob_z[i])
	end
	if thread:status() ~= 'dead' then
		sampAddChatMessage('[SH] {FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить её.', 0xFF5345)
		return
	end
	
	if #rp_sob ~= 0 then
		thread = lua_thread.create(function()
			for i = 1, #rp_sob do
				if rp_sob[i]:find('%{min_level_sob%}') then
					rp_sob[i] = rp_sob[i]:gsub('%{min_level_sob%}', setting.sob.min_exp)
				end
				if rp_sob[i]:find('%{min_law_sob%}') then
					rp_sob[i] = rp_sob[i]:gsub('%{min_law_sob%}', setting.sob.min_law)
				end
				if rp_sob[i]:find('%{id_sob%}') then
					rp_sob[i] = rp_sob[i]:gsub('%{id_sob%}', sob_info.id)
				end
				if rp_sob[i]:find('%{myid%}') then
					rp_sob[i] = rp_sob[i]:gsub('%{myid%}', my.id)
				end
				if rp_sob[i]:find('%{mynickrus%}') then
					rp_sob[i] = rp_sob[i]:gsub('%{mynickrus%}', setting.name_rus)
				end
				if rp_sob[i]:find('%{waitwbook%}') then
					if wait_book[2] then
						local dec_key = {}
						for s = 1, #setting.enter_key[1] do
							table.insert(dec_key, dec_to_key(setting.enter_key[1][s]))
						end
						wait(400)
						windows.action[0] = true
						dialog_act.status = true
						dialog_act.enter = true
						sampAddChatMessage('[SH] {FFFFFF}Нажмите на {23E64A}' .. setting.enter_key[2] .. '{FFFFFF} для продолжения или {FF8FA2}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить отыгровку.', 0xFF5345)
						addOneOffSound(0, 0, 0, 1058)
						while true do wait(0)
							if not sampIsChatInputActive() and not sampIsDialogActive() then
								local bool_return = 0
								for key = 1, #dec_key do
									if isKeyDown(dec_key[key]) then
										bool_return = bool_return + 1
									end
								end
								if bool_return == #dec_key then
									dialog_act.status = false
									dialog_act.enter = false
									break
								end
							end
						end
					end
				else
					sampSendChat(u8:decode(rp_sob[i]))
					wait(2200)
				end
			end
		end)
	end
end

function on_hot_key(id_pr_key)
	local pressed_key = tostring(table.concat(id_pr_key, ' '))
	
	if not isGamePaused() and not isPauseMenuActive() and not sampIsDialogActive() and not sampIsChatInputActive() then
		if pressed_key == '72' and setting.speed_door then
			sampSendChat('/opengate')
		end
		
		if pressed_key == tostring(table.concat(setting.fast.key, ' ')) and setting.fast.func then
			if targ_id ~= -1 and targ_id ~= nil and (#setting.fast.one_win > 0 or #setting.fast.two_win > 0) then
				if sampIsPlayerConnected(targ_id) then
					fast_nick = sampGetPlayerNickname(targ_id)
					fast_id = targ_id
				else
					fast_nick = 'No_Name'
					fast_id = -1
				end
				windows.fast[0] = true
				imgui.ShowCursor = true
			elseif targ_id == -1 or targ_id == nil and (#setting.fast.one_win > 0 or #setting.fast.two_win > 0) then
				fast_nick = 'No_Name'
				fast_id = -1
				windows.fast[0] = true
				imgui.ShowCursor = true
			end
		end
		if pressed_key == tostring(table.concat(setting.win_key[2], ' ')) and not edit_key then
			windows.main[0] = not windows.main[0]
		end
		
		if pressed_key == tostring(table.concat(setting.act_key[1], ' ')) and not edit_key and thread:status() ~= 'dead'
		and not sampIsChatInputActive() and not sampIsDialogActive() and not isGamePaused() then
			thread:terminate()
			dialog_act.status = false
		end
		
		if #cmd[1] ~= 0 then
			for j = 1, #cmd[1] do
				if #cmd[1][j].key[2] ~= 0 then
					if pressed_key == tostring(table.concat(cmd[1][j].key[2], ' ')) and not edit_key then
						cmd_start('', tostring(cmd[1][j].UID) .. cmd[1][j].cmd)
					end
				end
			end
		end
		
		if #setting.shp ~= 0 then
			for j = 1, #setting.shp do
				if #setting.shp[j].key[2] ~= 0 then
					if pressed_key == tostring(table.concat(setting.shp[j].key[2], ' ')) and not edit_key then
						cmd_shpora_open('', tostring(setting.shp[j].UID) .. setting.shp[j].cmd)
					end
				end
			end
		end
		
		local tab_open = {'cmd', 'shpora', 'dep', 'sob', 'reminder', 'stat', 'music', 'rp_zona', 'actions'}
		local tab_name_open = {u8'Команды', u8'Шпаргалки', u8'Департамент', u8'Собеседование', u8'Напоминания', u8'Статистика онлайна', u8'Музыка', u8'РП зона', u8'Действия'}
		for j = 1, #setting.key_tabs do
			if #setting.key_tabs[j][2] ~= 0 then
				if pressed_key == tostring(table.concat(setting.key_tabs[j][2], ' ')) and not edit_key then
					tab = tab_open[j]
					name_tab = tab_name_open[j]
					if not windows.main[0] then
						if setting.anim_win then
							anim_func = true
							windows.main[0] = true
						else
							windows.main[0] = true
						end
					end
				end
			end
		end
	end
end

function match_interpolation(initial, highest_return, current_match, max_return) --> Математическая интерполяция
    local ratio = current_match / highest_return
    local result = max_return - (ratio * (max_return - 1))
	
    return result
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
	
	return imgui.new.float[4](col.z, col.y, col.x, col.w)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	
	return a, r, g, b
end

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	
	return join_argb(a, r, g, b)
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

anb = {
	settings = 7,
	cmd = 7,
	shpora = 7,
	dep = 7,
	sob = 7,
	reminder = 7,
	stat = 7,
	music = 7,
	rp_zona = 7,
	actions = 7,
	help = 7
}
function element_order(order)
	local all_size_x = 0
	local calc_el_x = {
		settings = 17,
		cmd = 19,
		shpora = 15,
		dep = 20,
		sob = 21,
		reminder = 15,
		stat = 15,
		music = 17,
		rp_zona = 21,
		actions = 17,
		help = 17
	}
	local name_tabs = {
		settings = u8'Главное',
		cmd = u8'Команды',
		shpora = u8'Шпаргалки',
		dep = u8'Департамент',
		sob = u8'Собеседование',
		reminder = u8'Напоминания',
		stat = u8'Статистика онлайна',
		music = u8'Музыка',
		rp_zona = u8'РП зона',
		actions = u8'Действия',
		help = u8'Поддержка'
	}
	for i = 1, #order do
		all_size_x = all_size_x + calc_el_x[order[i]]
	end
	local dist_el = (840 - all_size_x) / (#order + 1)
	local pos_el = 4
	local name_fa
	for i = 1, #order do
		if order[i] == 'settings' then
			name_fa = fa.GEAR
		elseif order[i] == 'cmd' then
			name_fa = fa.HAMMER
		elseif order[i] == 'shpora' then
			name_fa = fa.BOOK
		elseif order[i] == 'dep' then
			name_fa = fa.SIGNAL
		elseif order[i] == 'sob' then
			name_fa = fa.USER_PLUS
		elseif order[i] == 'reminder' then
			name_fa = fa.BELL
		elseif order[i] == 'stat' then
			name_fa = fa.CHART_SIMPLE
		elseif order[i] == 'music' then
			name_fa = fa.MUSIC
		elseif order[i] == 'rp_zona' then
			name_fa = fa.OBJECT_UNGROUP
		elseif order[i] == 'actions' then
			name_fa = fa.CUBE
		elseif order[i] == 'help' then
			name_fa = fa.BULLHORN
		end
		
		pos_el = pos_el + dist_el
		if i ~= 1 then
			pos_el = pos_el + calc_el_x[order[i]]
		end
		
		local scroll_cursor_pos = gui.GetCursorScroll()
		local sdvig_pos_ord = 0
		if edit_order_tabs then
			local tab_element_bool = false
			imgui.SetCursorPos(imgui.ImVec2(pos_el - 6, 414))
			if imgui.InvisibleButton(u8'##Переместить элемент ' .. i, imgui.ImVec2(29, 25)) then end
			
			if imgui.IsItemClicked() then
				sc_cursor_pos = scroll_cursor_pos
				sc_cr_p_element2[1] = 0
				sc_cr_p_element2[2] = i
				sc_cr_p_element2[3] = i
				sc_cr_p_element2[4] = i
				sc_cr_p_element2[5] = pos_el
			end
			if imgui.IsItemActive() then
				tab_element_bool = true
				bool_item_active2 = true
				sc_cr_pos = {x = sc_cursor_pos.x - scroll_cursor_pos.x, y = sc_cursor_pos.y - scroll_cursor_pos.y}
				sdvig_pos_ord = sc_cr_pos.x
			elseif sc_cr_p_element2[2] == i and bool_item_active2 then
				bool_item_active2 = false
				swapping(setting.tab, i, sc_cr_p_element2[3] - i)
				break
			end
		end
		
		if bool_item_active2 and sc_cr_p_element2[2] ~= i then
			if i > sc_cr_p_element2[2] then
				if (sc_cr_p_element2[5] - sc_cr_pos.x) > pos_el - 6 then
					sdvig_pos_ord = dist_el + calc_el_x[order[i]]
					if (sc_cr_p_element2[5] - sc_cr_pos.x) < pos_el + 58 then
						sc_cr_p_element2[3] = i
					end
				end
			elseif i < sc_cr_p_element2[2] then
				if (sc_cr_p_element2[5] - sc_cr_pos.x) < pos_el + 6 then
					sdvig_pos_ord = -(dist_el + calc_el_x[order[i]])
					if (sc_cr_p_element2[5] - sc_cr_pos.x) > pos_el - 58 then
						sc_cr_p_element2[3] = i
					end
				end
			end
		elseif i == sc_cr_p_element2[2] and bool_item_active2 and (sc_cr_p_element2[5] - sc_cr_pos.x) < pos_el + 58 and (sc_cr_p_element2[5] - sc_cr_pos.x) > pos_el - 58 then
			sc_cr_p_element2[3] = i
		end

		imgui.SetCursorPos(imgui.ImVec2(pos_el - 4 - sdvig_pos_ord, 410))
		imgui.BeginChild(u8'Вкладка'..i, imgui.ImVec2(32, 34), false, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + (edit_order_tabs and imgui.WindowFlags.NoMouseInputs or 0))
		imgui.SetCursorPos(imgui.ImVec2(0, 0))
		if imgui.InvisibleButton(u8'##Нажатие кнопки вкладки' .. i, imgui.ImVec2(30, 32)) then
			if order[i] ~= tab and not edit_order_tabs then
				tab = order[i]
				anb[order[i]] = 8
				name_tab = name_tabs[order[i]]
			end
		end
		imgui.PushFont(fa_font[4])
		if setting.cl == 'White' then
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.30, 0.30, 0.30, 1.00))
		else
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.70, 0.70, 0.70, 1.00))
		end
		if tab == order[i] then
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
		end
		imgui.SetCursorPos(imgui.ImVec2(4, anb[order[i]] - 40))
		imgui.Text(name_fa)
		if tab == order[i] then
			imgui.PopStyleColor(1)
		end
		if tab == order[i] and anb[order[i]] == 7 and not edit_order_tabs then
			imgui.PushStyleColor(imgui.Col.Text, cl.def)
		end
		
		imgui.SetCursorPos(imgui.ImVec2(4, anb[order[i]]))
		imgui.Text(name_fa)
		if tab == order[i] and anb[order[i]] == 7 and not edit_order_tabs then
			imgui.PopStyleColor(1)
		end
		imgui.PopStyleColor(1)
		imgui.PopFont()
		
		if anb[order[i]] >= 8 and anb[order[i]] <= 47 then
			anb[order[i]] = anb[order[i]] + (anim * 120)
		else
			anb[order[i]] = 7
		end
		imgui.EndChild()
	end
end

setmetatable(imgui.Scroller, {__call = function(self, id, step, duration, HoveredFlags)
	if not HoveredFlags then
		HoveredFlags = imgui.HoveredFlags.AllowWhenBlockedByActiveItem 
	end
	if (table_move ~= '' or table_move_cmd ~= '') and not hovered_bool_not_child then
		if id == u8'Суть вкладки главное' or id == u8'Папки команд' or id == u8'Шпаргалки' or id == u8'Собеседование' 
		or id == u8'Напоминания' or id == u8'Статистика онлайна' or id == u8'Музыка' or id == u8'Лист найденных треков'
		or id == u8'Лист добавленных треков' or id == u8'РП зона' or id == u8'Действия' or id == u8'Поддержка'
		or id == u8'Редактор отыгровок оружия' or id == u8'Информация об обновлении' or id == u8'Лицензионное соглашение' then 
			HoveredFlags = HoveredFlags + imgui.HoveredFlags.RootAndChildWindows
		end
	end
	if not imgui.Scroller.id_bool_scroll[id] then
		imgui.Scroller.id_bool_scroll[id] = {}
	end
	
	local current_position = imgui.GetScrollY()
	if (imgui.IsWindowHovered(HoveredFlags) and imgui.IsMouseDown(0)) then
		imgui.Scroller.id_bool_scroll[id].start_clock = nil
	end
	
	if imgui.Scroller.id_bool_scroll[id].start_clock then
		if (os.clock() - imgui.Scroller.id_bool_scroll[id].start_clock) * 1000 <= duration then		
			local progress = (os.clock() - imgui.Scroller.id_bool_scroll[id].start_clock) * 1000 / duration			
			local fading_progress = progress * (2 - progress)
			local distance = (imgui.Scroller.id_bool_scroll[id].target_position - imgui.Scroller.id_bool_scroll[id].start_position)
			local new_position = imgui.Scroller.id_bool_scroll[id].start_position + distance * fading_progress
			
			if new_position < 0 then
				new_position = 0
				imgui.Scroller.id_bool_scroll[id].start_clock = nil
				
			elseif new_position > imgui.GetScrollMaxY() then
				new_position = imgui.GetScrollMaxY()
				imgui.Scroller.id_bool_scroll[id].start_clock = nil
			end
			imgui.SetScrollY(math.floor(new_position))
		else
			imgui.Scroller.id_bool_scroll[id].start_clock = nil
			imgui.SetScrollY(imgui.Scroller.id_bool_scroll[id].target_position)
		end
	end
	
	local wheel_delta = imgui.GetIO().MouseWheel
	if wheel_delta ~= 0 and imgui.IsWindowHovered(HoveredFlags) then
		local offset = -wheel_delta * step		
		if not imgui.Scroller.id_bool_scroll[id].start_clock then
			imgui.Scroller.id_bool_scroll[id].start_clock = os.clock()
			imgui.Scroller.id_bool_scroll[id].start_position = current_position
			imgui.Scroller.id_bool_scroll[id].target_position = current_position + offset
		else
			imgui.Scroller.id_bool_scroll[id].start_clock = os.clock()
			imgui.Scroller.id_bool_scroll[id].start_position = current_position
			if imgui.Scroller.id_bool_scroll[id].start_position < imgui.Scroller.id_bool_scroll[id].target_position and offset > 0 then
				imgui.Scroller.id_bool_scroll[id].target_position = imgui.Scroller.id_bool_scroll[id].target_position + offset
			elseif imgui.Scroller.id_bool_scroll[id].start_position > imgui.Scroller.id_bool_scroll[id].target_position and offset < 0 then
				imgui.Scroller.id_bool_scroll[id].target_position = imgui.Scroller.id_bool_scroll[id].target_position + offset
			else
				imgui.Scroller.id_bool_scroll[id].target_position = current_position + offset
			end
		end
	end
end})

function sex(text_man, text_woman)
	if setting.sex == 1 then
		return text_man
	else
		return text_woman
	end
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	
	return copy
end

function auto_report_fire(text_send, bool_func_enter)
	if thread:status() ~= 'dead' then
		sampAddChatMessage('[SH] [Доклад] {FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить её.', 0xFF5345)
		
		return
	end
	
	thread = lua_thread.create(function()
		if bool_func_enter then
			local dec_key = {}
			for s = 1, #setting.enter_key[1] do
				table.insert(dec_key, dec_to_key(setting.enter_key[1][s]))
			end
			wait(300)
			sampAddChatMessage('[SH] {FFFFFF}Нажмите на {23E64A}' .. setting.enter_key[2] .. '{FFFFFF} для отправки доклада или {FF8FA2}' .. setting.act_key[2] .. '{FFFFFF}, чтобы отменить отправку.', 0xFF5345)
			addOneOffSound(0, 0, 0, 1058)
			while true do wait(0)
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					local bool_return = 0
					for key = 1, #dec_key do
						if isKeyDown(dec_key[key]) then
							bool_return = bool_return + 1
						end
					end
					if bool_return == #dec_key then
						dialog_act.status = false
						dialog_act.enter = false
						break
					end
				end
			end
		else
			wait(700)
		end
		
		local function tags_sub(text_sub)
			if text_sub:find('%{mynickrus%}') then
				text_sub = text_sub:gsub('%{mynickrus%}', setting.name_rus)
			end
			if text_sub:find('%{myid%}') then
				text_sub = text_sub:gsub('%{myid%}', tostring(my.id))
			end
			if text_sub:find('%{mynick%}') then
				text_sub = text_sub:gsub('%{mynick%}', my.nick)
			end
			if text_sub:find('%{level%}') then
				text_sub = text_sub:gsub('%{level%}', tostring(level_fire))
			end
			if text_sub:find('%{rank%}') then
				text_sub = text_sub:gsub('%{rank%}', setting.job_title)
			end
			if text_sub:find('%{myrank%}') then
				text_sub = text_sub:gsub('%{myrank%}', setting.job_title)
			end
			if text_sub:find('{sex%[(.-)%]%[(.-)%]}') then
				local gender_male, gender_fem = text_sub:match('{sex%[(.-)%]%[(.-)%]}')
				local pattern_gender = ''
				if setting.sex == 1 then
					pattern_gender = gender_male
				else
					pattern_gender = gender_fem
				end
				
				text_sub = text_sub:gsub('{sex%[(.-)%]%[(.-)%]}', pattern_gender)
			end
			
			return text_sub
		end
		
		local text_fire = u8:decode(text_send)
		sampSendChat(tags_sub(text_fire))
	end)
end

function cmd_shpora_open(argument, cmd_name)
	for i = 1, #setting.shp do
		if tostring(setting.shp[i].UID) .. setting.shp[i].cmd == cmd_name then
			windows.shpora[0] = not windows.shpora[0]
			text_shpora = setting.shp[i].text
		end
	end
end

function cmd_start(argument, cmd_name) --> Запуск команды
	if thread:status() ~= 'dead' then --> Если какая-то команда уже запущена, то эту команду не запускаем
		sampAddChatMessage('[SH] {FFFFFF}У Вас уже запущена отыгровка! Используйте {ED95A8}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить её.', 0xFF5345)
		return
	end
	
	local CMD --> Вся команда
	local ARG = {} --> Для аргументов
	for c = 1, #cmd[1] do --> Ищем какую команду нам запустить
		if tostring(cmd[1][c].UID) .. cmd[1][c].cmd == cmd_name then
			CMD = cmd[1][c]
		end
	end
	if CMD == nil then --> Если команда почему-то не найдена, то информируем пользователя и останавливаем проигровку
		sampAddChatMessage('[SH] {FFFFFF}ОШИБКА! Команда не найдена... Видимо, файл с командами уничтожен.', 0xFF5345)
		return
	end
	
	if #CMD.arg ~= 0 then --> Если команда с аргументами, то делаем проверку, вписываем аргументы и так далее
		local function invalid_arguments() --> Для случая, если аргументы не ожидаемые
			local tbl_ar = {}
			for ar = 1, #CMD.arg do
				table.insert(tbl_ar, '[' .. u8:decode(CMD.arg[ar].desc) .. ']')
			end
			sampAddChatMessage('[SH] {FFFFFF}Используйте {a8a8a8}/' .. CMD.cmd .. ' ' .. table.concat(tbl_ar, ' '), 0xFF5345)
		end
		
		if argument:gsub('%s+', '') ~= '' then
			for word in argument:gmatch('%S+') do --> Выписываем все полученные аргументы в переменную
				table.insert(ARG, word)
			end
			
			if #ARG > #CMD.arg then --> Если аргументов дали больше, чем их должно быть, то всё лишнее вписываем в последний аргумент
				local bool_args = table.concat(ARG, ' ', #CMD.arg, #ARG)
				ARG[#CMD.arg] = bool_args
				for c = #ARG, #CMD.arg + 1, -1 do
					table.remove(ARG, c)
				end
			end
		end
		
		for num, type_arg in ipairs(CMD.arg) do --> Если аргументы дали не те, какие должны быть, то сообщаем как надо и говорим до свидания
			if type_arg.type == 1 then
				if ARG[num] ~= nil then
					if not ARG[num]:find('(.+)') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			elseif type_arg.type == 2 then
				if ARG[num] ~= nil then
					if not ARG[num]:find('^(%d+)$') then invalid_arguments() return end
				else
					invalid_arguments() return
				end
			end
		end
	end
	local function escape_pattern(text_esc)
		return text_esc:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
	end
		
	local function tag_converter(text) --> Преобразовать теги в тексте, если они имеются
		local function escape_pattern(text_esc)
			return text_esc:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
		end
		
		text = u8:decode(text)
		if text:find('%b{}') then
			local week = {'Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'}
			local month = {'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'}
			local extracted_str = {}
			local stop_send_chat = false
			
			for tag in text:gmatch('%b{}') do
				table.insert(extracted_str, {tag, tag})
			end
			
			for i = 1, #extracted_str do
				local val = extracted_str[i][1]
				if val == '{mynick}' then
					extracted_str[i][2] = my.nick:gsub('_', ' ')
				elseif val == '{mynickrus}' then
					extracted_str[i][2] = u8:decode(setting.name_rus)
				elseif val == '{myid}' then
					extracted_str[i][2] = tostring(my.id)
				elseif val == '{myrank}' then
					extracted_str[i][2] = u8:decode(setting.job_title)
				elseif val == '{time}' then
					extracted_str[i][2] = tostring(os.date('%X'))
				elseif val == '{day}' then
					extracted_str[i][2] = tostring(os.date('%d'))
				elseif val == '{week}' then
					extracted_str[i][2] = week[tonumber(os.date('%w')) + 1]
				elseif val == '{month}' then
					extracted_str[i][2] = month[tonumber(os.date('%m'))]
				elseif val:find('{getplnick%[(%d+)%]}') then
					local num_id = string.match(val, '{getplnick%[(.-)%]}')
					if sampIsPlayerConnected(tonumber(num_id)) then
						extracted_str[i][2] = (sampGetPlayerNickname(tonumber(num_id))):gsub('_', ' ')
					else
						extracted_str[i][2] = 'Уважаемый'
						sampAddChatMessage('[SH] {FFFFFF}Параметр ' .. val .. ' не обнаружил игрока. Игрок не в сети, либо это Вы.', 0xFF5345)
					end
				elseif val:find('{getlevel%[(%d+)%]}') then
					local num_id = tonumber(string.match(val, '{getlevel%[(%d+)%]}'))
					if sampIsPlayerConnected(tonumber(num_id)) then
						extracted_str[i][2] = sampGetPlayerScore(tonumber(num_id))
					else
						extracted_str[i][2] = '0'
						sampAddChatMessage('[SH] {FFFFFF}Параметр ' .. val .. ' не обнаружил игрока. Игрок не в сети, либо это Вы.', 0xFF5345)
					end
				elseif val == '{med7}' then
					extracted_str[i][2] = setting.price[1].mc[1]:gsub('%D', '')
				elseif val == '{med14}' then
					extracted_str[i][2] = setting.price[1].mc[2]:gsub('%D', '')
				elseif val == '{med30}' then
					extracted_str[i][2] = setting.price[1].mc[3]:gsub('%D', '')
				elseif val == '{med60}' then
					extracted_str[i][2] = setting.price[1].mc[4]:gsub('%D', '')
				elseif val == '{medup7}' then
					extracted_str[i][2] = setting.price[1].mcupd[1]:gsub('%D', '')
				elseif val == '{medup14}' then
					extracted_str[i][2] = setting.price[1].mcupd[2]:gsub('%D', '')
				elseif val == '{medup30}' then
					extracted_str[i][2] = setting.price[1].mcupd[3]:gsub('%D', '')
				elseif val == '{medup60}' then
					extracted_str[i][2] = setting.price[1].mcupd[4]:gsub('%D', '')
				elseif val == '{pricenarko}' then
					extracted_str[i][2] = setting.price[1].narko:gsub('%D', '')
				elseif val == '{pricerecept}' then
					extracted_str[i][2] = setting.price[1].rec:gsub('%D', '')
				elseif val == '{pricetatu}' then
					extracted_str[i][2] = setting.price[1].tatu:gsub('%D', '')
				elseif val == '{priceant}' then
					extracted_str[i][2] = setting.price[1].ant:gsub('%D', '')
				elseif val == '{pricelec}' then
					extracted_str[i][2] = setting.price[1].lec:gsub('%D', '')
				elseif val == '{priceosm}' then
					extracted_str[i][2] = setting.price[1].osm:gsub('%D', '')
				elseif val =='{priceauto1}' then
					extracted_str[i][2] = setting.price[2].auto[1]
				elseif val == '{priceauto2}' then
					extracted_str[i][2] = setting.price[2].auto[2]
				elseif val == '{priceauto3}' then
					extracted_str[i][2] = setting.price[2].auto[3]
				elseif val == '{pricemoto1}' then
					extracted_str[i][2] = setting.price[2].moto[1]
				elseif val == '{pricemoto2}' then
					extracted_str[i][2] = setting.price[2].moto[2]
				elseif val == '{pricemoto3}' then
					extracted_str[i][2] = setting.price[2].moto[3]
				elseif val == '{pricefly}' then
					extracted_str[i][2] = setting.price[2].fly[1]
				elseif val == '{pricefish1}' then
					extracted_str[i][2] = setting.price[2].fish[1]
				elseif val == '{pricefish2}' then
					extracted_str[i][2] = setting.price[2].fish[2]
				elseif val == '{pricefish3}' then
					extracted_str[i][2] = setting.price[2].fish[3]
				elseif val == '{priceswim1}' then
					extracted_str[i][2] = setting.price[2].swim[1]
				elseif val == '{priceswim2}' then
					extracted_str[i][2] = setting.price[2].swim[2]
				elseif val == '{priceswim3}' then
					extracted_str[i][2] = setting.price[2].swim[3]
				elseif val == '{pricegun1}' then
					extracted_str[i][2] = setting.price[2].gun[1]
				elseif val == '{pricegun2}' then
					extracted_str[i][2] = setting.price[2].gun[2]
				elseif val == '{pricegun3}' then
					extracted_str[i][2] = setting.price[2].gun[3]
				elseif val == '{pricehunt1}' then
					extracted_str[i][2] = setting.price[2].hunt[1]
				elseif val == '{pricehunt2}' then
					extracted_str[i][2] = setting.price[2].hunt[2]
				elseif val == '{pricehunt3}' then
					extracted_str[i][2] = setting.price[2].hunt[3]
				elseif val == '{priceexc1}' then
					extracted_str[i][2] = setting.price[2].exc[1]
				elseif val == '{priceexc2}' then
					extracted_str[i][2] = setting.price[2].exc[2]
				elseif val == '{priceexc3}' then
					extracted_str[i][2] = setting.price[2].exc[3]
				elseif val == '{pricetaxi1}' then
					extracted_str[i][2] = setting.price[2].taxi[1]
				elseif val == '{pricetaxi2}' then
					extracted_str[i][2] = setting.price[2].taxi[2]
				elseif val == '{pricetaxi3}' then
					extracted_str[i][2] = setting.price[2].taxi[3]
				elseif val == '{pricemeh1}' then
					extracted_str[i][2] = setting.price[2].meh[1]
				elseif val == '{pricemeh2}' then
					extracted_str[i][2] = setting.price[2].meh[2]
				elseif val == '{pricemeh3}' then
					extracted_str[i][2] = setting.price[2].meh[3]
				elseif val == '{target}' then
					extracted_str[i][2] = targ_id or -1
				elseif val == '{prtsc}' then
				elseif val:find('{spcar}') then
					extracted_str[i][2] = ''
					lspawncar = true
					sampSendChat('/lmenu')
				elseif val:find('{PhoneApp%[(%d+)%]}') then
					extracted_str[i][2] = ''
					sampSendChat('/phone')
					local app_id = tonumber(string.match(val, '{PhoneApp%[(%d+)%]}'))
					sendCef('launchedApp|'.. app_id)
					sampSendChat('/phone')
				elseif val == '{nearplayer}' then
					local near_pl = getNearestID()
					if near_pl then
						extracted_str[i][2] = tostring(near_pl)
					else
						extracted_str[i][2] = '-1'
						sampAddChatMessage('[SH] {FFFFFF}Параметр ' .. val .. ' не обнаружил игрока. Игроков рядом нет.', 0xFF5345)
					end
				elseif val:find('{random%[(%d+)%]%[(%d+)%]}') then
					local min_number, max_number = val:match('{random%[(%d+)%]%[(%d+)%]}')
					local random_number = math.random(tonumber(min_number), tonumber(max_number))
					extracted_str[i][2] = tostring(random_number)
				elseif val:find('{sex%[(.-)%]%[(.-)%]}') then
					local gender_male, gender_fem = val:match('{sex%[(.-)%]%[(.-)%]}')
					if setting.sex == 1 then
						extracted_str[i][2] = gender_male
					else
						extracted_str[i][2] = gender_fem
					end
				elseif val == nil then
					extracted_str[i][2] = ''
				else
					extracted_str[i][2] = val
				end
			end
			
			for t = 1, #extracted_str do
				local pattern = escape_pattern(extracted_str[t][1])
				if text:find(pattern) then
					text = text:gsub(pattern, extracted_str[t][2])
				end
			end

			if text:find('{prtsc}') then
				stop_send_chat = true
				text = text:gsub('{prtsc}', '')
				print_scr()
			end
			
			if text:find('{dialoglic%[(%d+)%]%[(%d+)%]%[(%d+)%]}') then
				stop_send_chat = true
				num_id_dial, num_id_term, num_id_player = string.match(text, '{dialoglic%[(.-)%]%[(.-)%]%[(.-)%]}')
				if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 10 then
					num_give_lic = tonumber(num_id_dial)
				else
					sampAddChatMessage('[SH] {FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', 0xFF5345)
					return ''
				end
				if tonumber(num_id_term) >= 0 and tonumber(num_id_term) <= 3 then
					num_give_lic_term = tonumber(num_id_term)
				else
					sampAddChatMessage('[SH] {FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoglic} имеет неверное значение.', 0xFF5345)
					return ''
				end
			end
			if stop_send_chat then return u8'/givelicense ' .. num_id_player end
			
			if text:find('{dialoggov%[(%d+)%]%[(%d+)%]}') then
				stop_send_chat = true
				num_id_dial, num_id_player = string.match(text, '{dialoggov%[(.-)%]%[(.-)%]}')
				if tonumber(num_id_dial) > -1 and tonumber(num_id_dial) < 3 then
					num_give_gov = tonumber(num_id_dial)
				else
					sampAddChatMessage('[SH] {FF5345}[КРИТИЧЕСКАЯ ОШИБКА] {FFFFFF}Параметр {dialoggov} имеет неверное значение.', 0xFF5345)
					return ''
				end
			end
			if stop_send_chat then return u8'/givepass ' .. num_id_player end
		end
		
		return u8(text)
	end
	
	local function arg_and_var_and_tag_conv(text) --> Преобразовать аргументы, переменные и теги в тексте		
		if #CMD.var ~= 0 then --> Заменяем переменные в тексте 
			for i_var = 1, #CMD.var do
				local var_format = '{' .. CMD.var[i_var].name .. '}'
				if text:find(var_format) then
					local text_conv = tag_converter(CMD.var[i_var].value)
					text = text:gsub(escape_pattern(var_format), text_conv)
				end
			end
		end
		if #CMD.arg ~= 0 then --> Заменяем аргументы в тексте 
			for i_arg = 1, #CMD.arg do
				local arg_format = '{' .. CMD.arg[i_arg].name .. '}'
				if text:find(arg_format) then
					text = text:gsub(escape_pattern(arg_format), u8(ARG[i_arg]))
				end
			end
		end
		text = tag_converter(text)
		
		return text
	end
	
	local delay = CMD.delay * 1000
	local dialogs = {}
	local if_active = 0
	local else_active = 0
	local dec_key = {}
	for s = 1, #setting.enter_key[1] do
		table.insert(dec_key, dec_to_key(setting.enter_key[1][s]))
	end
	thread = lua_thread.create(function() --> Функция отыгровки
		for i, v in ipairs(CMD.act) do
			if if_active == 0 and else_active == 0 then
				if v[1] == 'SEND' then
					if i ~= 1 then
						if CMD.act[i - 1][1] == 'SEND' or CMD.act[i - 1][1] == 'SEND_ME' then
							wait(delay)
						else
							wait(delay)
						end
					end
					if CMD.send_end_mes or i ~= #CMD.act then
						sampSendChat(u8:decode(arg_and_var_and_tag_conv(v[2])))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText(u8:decode(arg_and_var_and_tag_conv(v[2])))
					end
				elseif v[1] == 'OPEN_INPUT' then
					sampSetChatInputEnabled(true)
					sampSetChatInputText(u8:decode(arg_and_var_and_tag_conv(v[2])))
					wait(400)
					windows.action[0] = true
					dialog_act.status = true
					dialog_act.enter = true
					sampAddChatMessage('[SH] {FFFFFF}Нажмите на {23E64A}' .. setting.enter_key[2] .. '{FFFFFF} для продолжения или {FF8FA2}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить отыгровку.', 0xFF5345)
					addOneOffSound(0, 0, 0, 1058)
					while true do wait(0)
						if not sampIsChatInputActive() and not sampIsDialogActive() then
							local bool_return = 0
							for key = 1, #dec_key do
								if isKeyDown(dec_key[key]) then
									bool_return = bool_return + 1
								end
							end
							if bool_return == #dec_key then
								dialog_act.status = false
								dialog_act.enter = false
								break
							end
						end
					end
				elseif v[1] == 'WAIT_ENTER' then
					wait(400)
					windows.action[0] = true
					dialog_act.status = true
					dialog_act.enter = true
					sampAddChatMessage('[SH] {FFFFFF}Нажмите на {23E64A}' .. setting.enter_key[2] .. '{FFFFFF} для продолжения или {FF8FA2}' .. setting.act_key[2] .. '{FFFFFF}, чтобы остановить отыгровку.', 0xFF5345)
					addOneOffSound(0, 0, 0, 1058)
					while true do wait(0)
						if not sampIsChatInputActive() and not sampIsDialogActive() then
							local bool_return = 0
							for key = 1, #dec_key do
								if isKeyDown(dec_key[key]) then
									bool_return = bool_return + 1
								end
							end
							if bool_return == #dec_key then
								dialog_act.status = false
								dialog_act.enter = false
								break
							end
						end
					end
				elseif v[1] == 'SEND_ME' then
					wait(400)
					sampAddChatMessage('[SH] {FFFFFF}' .. u8:decode(arg_and_var_and_tag_conv(v[2])), 0xFF5345)
				elseif v[1] == 'DELAY' then
					delay = v[2] * 1000
				elseif v[1] == 'NEW_VAR' then
					bool_cmd_var = false
					if #CMD.var ~= 0 then
						for var = 1, #CMD.var do
							if CMD.var[var].name == v[2] then
								CMD.var[var].value = v[3]
								bool_cmd_var = true
							end
						end
					end
					if not bool_cmd_var then
						table.insert(CMD.var, {name = v[2], value = v[3]})
					end
				elseif v[1] == 'DIALOG' then
					windows.action[0] = true
					dialog_act.status = true
					dialog_act.info = v[3]
					dialog_act.enter = false
					while true do wait(0)
						if not sampIsChatInputActive() and not sampIsDialogActive() then
							if #v[3] ~= 0 then
								local bool_VK = {VK_1, VK_2, VK_3, VK_4, VK_5, VK_6, VK_7, VK_8, VK_9, VK_0}
								local bool_NUMPAD = {VK_NUMPAD1, VK_NUMPAD2, VK_NUMPAD3, VK_NUMPAD4, VK_NUMPAD5, VK_NUMPAD6, VK_NUMPAD7, VK_NUMPAD8, VK_NUMPAD9, VK_NUMPAD10}
								local return_bool = false
								for d = 1, #v[3] do
									if isKeyJustPressed(bool_VK[d]) or isKeyJustPressed(bool_NUMPAD[d]) then
										table.insert(dialogs, {v[2], d})
										return_bool = true
										break
									end
								end
								if return_bool then
									dialog_act.status = false
									dialog_act.enter = false
									break 
								end
							end
						end
					end
				elseif v[1] == 'IF' then
					local bool_active = false
					
					if v[2] == 2 then
						if #dialogs ~= 0 then
							for dg = 1, #dialogs do
								if tostring(dialogs[dg][1]) == tostring(v[3][1]) and tostring(dialogs[dg][2]) == tostring(v[3][2]) then
									bool_active = true
								end
							end
						end
					elseif v[2] == 3 then
						if #CMD.arg ~= 0 then
							for ar = 1, #CMD.arg do
								local arg_1 = u8:decode(arg_and_var_and_tag_conv(tostring(ARG[ar])))
								local arg_2 = u8:decode(arg_and_var_and_tag_conv(tostring(v[3][2])))
								if tostring(CMD.arg[ar].name) == tostring(v[3][1]) then
									if v[5] == 1 and arg_1 == arg_2 then
										bool_active = true
									elseif v[5] == 6 and arg_1 ~= arg_2 then
										bool_active = true
									elseif v[5] > 1 then
										arg_1 = tonumber(arg_1)
										arg_2 = tonumber(arg_2)
										
										if arg_1 and arg_2 then
											if v[5] == 2 and arg_1 > arg_2 then
												bool_active = true
											elseif v[5] == 3 and arg_1 >= arg_2 then
												bool_active = true
											elseif v[5] == 4 and arg_1 < arg_2 then
												bool_active = true
											elseif v[5] == 5 and arg_1 <= arg_2 then
												bool_active = true
											end
										end
									end
								end
							end
						end
					elseif v[2] == 4 then
						if #CMD.var ~= 0 then
							for vr = 1, #CMD.var do
								local var_1 = u8:decode(arg_and_var_and_tag_conv(tostring(CMD.var[vr].value)))
								local var_2 = u8:decode(arg_and_var_and_tag_conv(tostring(v[3][2])))
								if tostring(CMD.var[vr].name) == tostring(v[3][1]) then
									if v[5] == 1 and var_1 == var_2 then
										bool_active = true
									elseif v[5] == 6 and var_1 ~= var_2 then
										bool_active = true
									elseif v[5] > 1 then
										var_1 = tonumber(var_1)
										var_2 = tonumber(var_2)
										if var_1 and var_2 then
											if v[5] == 2 and var_1 > var_2 then
												bool_active = true
											elseif v[5] == 3 and var_1 >= var_2 then
												bool_active = true
											elseif v[5] == 4 and var_1 < var_2 then
												bool_active = true
											elseif v[5] == 5 and var_1 <= var_2 then
												bool_active = true
											end
										end
									end
								end
							end
						end
					end
					
					if bool_active == false then
						if_active = 1
					end
				elseif v[1] == 'ELSE' then
					if_active = 1
				elseif v[1] == 'STOP' then
					return
				end
			else
				if v[1] == 'IF' then
					if_active = if_active + 1
				elseif v[1] == 'ELSE' then
					if if_active == 1 then 
						if_active = 0
					end
				elseif v[1] == 'END' then
					if if_active > 0 then
						if_active = if_active - 1
					end
				end
			end
		end
	end)
end

function getNearestID()
    local chars = getAllChars()
    local mx, my, mz = getCharCoordinates(PLAYER_PED)
    local nearId, dist = nil, 10000
    for i,v in ipairs(chars) do
        if doesCharExist(v) and v ~= PLAYER_PED then
            local vx, vy, vz = getCharCoordinates(v)
            local cDist = getDistanceBetweenCoords3d(mx, my, mz, vx, vy, vz)
            local r, id = sampGetPlayerIdByCharHandle(v)
            if r and cDist < dist then
                dist = cDist
                nearId = id
            end
        end
    end
    return nearId
end

function sex_decode(text_ret)
	local function escape_pattern(text_esc)
		return text_esc:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
	end
	text_ret = u8:decode(text_ret)
	local extracted_str = {}
	for tag in text_ret:gmatch('%b{}') do
		table.insert(extracted_str, {tag, tag})
	end
	
	if text_ret:find('{sex%[(.-)%]%[(.-)%]}') and #extracted_str ~= 0 then
		for i = 1, #extracted_str do
			local gender_male, gender_fem = text_ret:match('{sex%[(.-)%]%[(.-)%]}')
			if setting.sex == 1 then
				extracted_str[i][2] = gender_male
			else
				extracted_str[i][2] = gender_fem
			end
			
			for t = 1, #extracted_str do
				local pattern = escape_pattern(extracted_str[t][1])
				if text_ret:find(pattern) then
					text_ret = text_ret:gsub(pattern, extracted_str[t][2])
				end
			end
		end
	end
	
	return u8(text_ret)
end

--> Мемберс
members = {}
cloth = false
lastDialogWasActive = 0
dont_show_me_members = false
script_cursor = false
fontes = renderCreateFont('Trebuchet MS', setting.mb.size, setting.mb.flag)
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

function render_members()
	local X, Y = setting.mb.pos.x, setting.mb.pos.y
	local title = string.format('%s | Онлайн: %s%s', org.name, org.online, (setting.mb.afk and (' (%s в АФК)'):format(org.afk) or ''))
	local col_title = changeColorAlpha(setting.mb.color.title, (setting.mb.vis * 2))
	if setting.mb.invers then
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.mb.dist - 5, col_title, col_title, 4, false) then
			sampSendChat('/members')
		end
	else
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - setting.mb.dist - 5, col_title, col_title, 3, false) then
			sampSendChat('/members')
		end
	end
	if org.name == 'Гражданин' then
		local col_non = changeColorAlpha(setting.mb.color.default, (setting.mb.vis * 2))
		if setting.mb.invers then
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, col_non, col_non,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, col_non, col_non,  3, false)
		end
	elseif #members > 0 then
		for i, member in ipairs(members) do
			if i <= tonumber(org.online) then
				if setting.rank_members[tonumber(member.rank.count)] then
					local color = changeColorAlpha(setting.mb.form and (member.uniform and setting.mb.color.work or setting.mb.color.default) or setting.mb.color.default, (setting.mb.vis * 2))
					local rank = setting.mb.rank and string.format('[%s]', member.rank.count) or nil
					local nick = member.nick .. (setting.mb.id and string.format('(%s)', member.id) or '')
					local afk = setting.mb.afk and string.format(' (AFK: %s)', member.afk) or ''
					local warns = setting.mb.warn and string.format(' (W: %s)', member.warns) or ''
					local out_string
					if setting.mb.invers then
						out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
						renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 4, true)
					else
						out_string = ('%s%s%s%s'):format(rank and rank .. ' ' or '', nick, afk, warns)
						renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color, 3, true)
					end
					Y = Y + setting.mb.dist
				end
			end
		end
	else
		local col_non = changeColorAlpha(setting.mb.color.default, (setting.mb.vis * 2))
		if setting.mb.invers then
			renderFontDrawClickableText(script_cursor, fontes, 'Мемберс обновится через ' .. wait_mb .. ' сек.', X, Y, col_non, col_non,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Мемберс обновится через ' .. wait_mb .. ' сек.', X, Y, col_non, col_non,  3, false)
		end
	end
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
	if setting.mb.func then
		pos_new_memb = lua_thread.create(function()
			local backup = {
				['x'] = setting.mb.pos.x,
                ['y'] = setting.mb.pos.y
			}
			local ChangePos = true
			sampSetCursorMode(4)
			windows.main[0] = false
			sampAddChatMessage('[SH]{FFFFFF} Нажмите {FF6060}ЛКМ{FFFFFF}, чтобы применить или {FF6060}ESC{FFFFFF} для отмены.', 0xFF5345)
            if not sampIsChatInputActive() then
                while not sampIsChatInputActive() and ChangePos do
                    wait(0)
                    local cX, cY = getCursorPos()
                    setting.mb.pos.x = cX
                    setting.mb.pos.y = cY
                    if isKeyDown(0x01) then
                    	while isKeyDown(0x01) do wait(0) end
                        ChangePos = false
						save()
                        sampAddChatMessage('[SH]{FFFFFF} Позиция сохранена.', 0xFF5345)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						setting.mb.pos.x = backup['x']
						setting.mb.pos.y = backup['y']
                        sampAddChatMessage('[SH]{FFFFFF} Вы отменили изменение позиции.', 0xFF5345)
                    end
                end
            end
            sampSetCursorMode(0)
            windows.main[0] = true
			imgui.ShowCursor = true
            ChangePos = false
		end)
	end
end

function activate_function_members()
	while true do
		wait(0)
		if sampIsLocalPlayerSpawned() and not sampIsDialogActive() and timer_send == 0 and thread:status() == 'dead' then
			while (os.clock() - lastDialogWasActive) < 2.00 do wait(0) end
			if --[[ not members_wait.members and ]]setting.mb.func and thread:status() == 'dead' and not sampIsDialogActive() and wait_mb == 0 and not isGamePaused() and not isPauseMenuActive() then
				members_wait.members = true
				dont_show_me_members = false
				sampSendChat('/members')
				wait_mb = 27
			end
		else
			wait_mb = 10
		end
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

function getAfkCount()
	local count = 0
	for _, v in ipairs(members) do
		if v.afk > 0 then
			count = count + 1
		end
	end
	
	return count
end

function print_scr()
	lua_thread.create(function()
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

function print_scr_time()
	lua_thread.create(function()
		sampSendChat('/time')
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(25)
		setVirtualKeyDown(VK_F8, false)
	end)
end

function go_medic_or_fire()
	if setting.org <= 4 then
		sampSendChat('/godeath ' .. id_player_go)
	else
		sampSendChat('/fires')
	end
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

chat_arizona = {}

--> Hook
function hook.onServerMessage(color_mes, mes)
	local mes_col = (bit.tohex(bit.rshift(color_mes, 8), 6))
	
	if setting.put_mes[2] then
		if mes:find('Объявление:') or mes:find('Отредактировал сотрудник') then
			return false
		end
	end
	if mes:find('У игрока уже есть Трудовая книжка!') and run_sob then
		wait_book = {20, true}
	end
	
	if setting.put_mes[3] then
		if mes:find('News LS') or mes:find('News SF') or mes:find('News LV') then
			return false
		end
		if mes:find('Гость') or mes:find('Репортёр') then
			if mes_col == '9acd32' then
				return false
			end
		end
	end
	
	if mes:find('Вы не можете продавать лицензии на такой срок') then
		num_give_lic = -1
		sampAddChatMessage('[SH] {FFFFFF}Ваш ранг не позволяет выдать эту лицензию!', 0xFF5345)
		return false
	end
	
	if setting.put_mes[1] then
		if mes:find('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~') or mes:find('- Основные команды сервера: /menu /help /gps /settings') 
		or mes:find('Пригласи друга и получи бонус в размере') or mes:find('- Донат и получение дополнительных средств arizona-rp.com/donate') 
		or mes:find('Подробнее об обновлениях сервера') or mes:find('(Личный кабинет/Донат)') or mes:find('С помощью телефона можно заказать') 
		or mes:find('В нашем магазине ты можешь') or mes:find('их на желаемый тобой {FFFFFF}бизнес') or mes:find('Игроки со статусом (.+)имеют больше возможностей') 
		or mes:find('можно приобрести редкие {FFFFFF}автомобили, аксессуары, воздушные') or mes:find('предметы, которые выделят тебя из толпы! Наш сайт:') 
		or mes:find('Вы можете купить складское помещение') or mes:find('Таким образом вы можете сберечь своё имущество, даже если вас забанят.') 
		or mes:find('Этот тип недвижимости будет навсегда закреплен за вами и за него не нужно платить.') or mes:find('{ffffff}Уважаемые жители штата, открыта продажа билетов на рейс:') 
		or mes:find('{ffffff}Подробнее: {FF6666}/help — Перелёты в город Vice City.') or mes:find('{ffffff}Внимание! На сервере Vice City действует акция Х3 PayDay.') 
		or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут бесплатно раз в день получать') or mes:find('%[Подсказка%] Игроки владеющие (.+) домами могут получать (.+) Ларца Олигарха')
		or mes:find('Игроки со статусом (.+)имеют большие возможности') or mes:find('{9ACD32}%[Подсказка%]{FFFFFF} Негде жить?') or mes:find('{9ACD32}%[Подсказка%]{FFFFFF} Проживая в отеле')
		or mes:find('{9ACD32}%[Подсказка%]{FFFFFF} Подробнее') or mes:find('%[Информация%] Продавай и покупай автомобильные номера') 
		or mes:find('Администрация сервера в поиске новых спонсоров для проведения') or mes:find('Именно Вы можете стать тем самым спонсором, благодаря которому будет проведено') 
		or mes:find('Спонсировать серверные мероприятия можно с помощью команды') or mes:find('С уважением, Администрация сервера')
		or mes:find('На сервере Vice City действует акция') or mes:find('Центр обмена имуществ') or mes:find('Проводи безопасный обмен имуществом с другими игроками')
		or mes:find('%[Рыбалка%] Игрок (.+) занял(.+)место по количеству выловленной рыбы') or mes:find('Вы можете улучшить свои характеристики на поле битвы')
		or mes:find('Списанный бронежилет на 4 часа даст вашему персонажу') or mes:find('Найти склад можно(.+)Склад списанных бронежилетов') then 
			return false
		end
	end
	
	if mes:find(' испытал удачу при открытии ') or mes:find('%[Удача%] Игрок') or mes:find('Удача улыбнулась игроку') and setting.put_mes[4] then
		return false
	end

	if mes:find('[Сбор средств](.+)организац') and setting.put_mes[5] then
		return false
	end

	if setting.color_nick then
		if mes:find('говорит:') and mes_col == 'ffffff' and setting.replace_ic then
			local playerId = mes:match('%d+')
			if playerId then
				local playerColor = sampGetPlayerColor(playerId)
				sampAddChatMessage(mes, playerColor)
				return false
			end
		elseif mes:find('кричит:') and mes_col == 'f0e68c' and setting.replace_s then
		local playerId = mes:match('%d+')
		if playerId then
			local playerColor = sampGetPlayerColor(playerId)
			local mes = mes:gsub("кричит:", "кричит:{F0E68C}")
			sampAddChatMessage(mes, playerColor)
			return false
		end
		elseif mes:find('говорит шепотом:') and mes_col == '94b0c1' and setting.replace_c then
			local playerId = mes:match('%d+')
			if playerId then
				local playerColor = sampGetPlayerColor(playerId)
				sampAddChatMessage(mes, playerColor)
				return false
			end
		elseif mes:match('%(%(.+%[%d+%]: {B7AFAF}.+%)%)$') and mes_col == 'ffffff' and setting.replace_b then
			local nickname, id, text = mes:match('%(%(%s*(.-)%[(%d+)%]: {B7AFAF}(.-)%)%)$')
			if nickname and id and text then
				local playerId = tonumber(id)
				local playerColor = sampGetPlayerColor(playerId)
				local cleanText = text:gsub("{B7AFAF}", "")
				local formatted = string.format('{%06X}(( %s[%s]: {B7AFAF}%s{%06X}))',
					bit.band(playerColor, 0xFFFFFF), nickname, id, cleanText, bit.band(playerColor, 0xFFFFFF))
				sampAddChatMessage(formatted, playerColor)
				return false
			end
		end
	end
	
	if mes:find('Купите лотерейный билет и получите возможность выиграть') or mes:find('Купить лотерейные билеты можно в уличных киосках')
	and setting.put_mes[7] then
		return false
	end

	if mes:find('Гос%.Новости') and mes_col == '045fb4' and setting.put_mes[8] then
		return false
	end

	if setting.put_mes[6] then
		if mes:find('%[Информация%]{FFFFFF} Игрок (.+) приобрел ') or mes:find('%[VIP ADV%] {FFFFFF}') or mes:find('%[FOREVER%] {FFFFFF}')
		or mes:find('%[PREMIUM%] {FFFFFF}') or mes:find('%[VIP%] {FFFFFF}') or mes:find('%[ADMIN%] {FFFFFF}') then
			return false
		end
	end

	if mes:find('%[D%] ') and mes_col == '3399ff' and setting.put_mes[9] then
		return false
	end

	if mes:find('%[R%] ') and mes_col == '2db043' and setting.put_mes[10] then
		return false
	end
	
	if mes:find('На сервере есть инвентарь, используйте клавишу Y для работы с ним') then
		close_serv = false
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		my = {id = myid, nick = sampGetPlayerNickname(myid)}
	end
	
	if setting.show_dialog_auto then
		if mes:find('%[Новое предложение%]{ffffff} Вам поступило предложение от игрока(.+)%. Используйте команду%: %/offer или клавишу X') then
			sampSendChat('/offer')
		end
	end
	
	if setting.godeath.func then
		if mes:find('Очевидец сообщает о пострадавшем человеке(.+)') and mes_col == 'ff5350' then
			text_godeath = mes
			
			return false
		end
		
		if mes:find('%[Происшествие%](.+)В штате произошел пожар') and setting.org == 9 then
			if setting.fire.sound then
				addOneOffSound(0, 0, 0, 1057)
			end
			
			if setting.fire.auto_cmd_fires and not fire_active then
				sampSendChat('/fires')
			end
		end
		
		if setting.report_fire.arrival.func and setting.org == 9 and mes:find('Информация(.+)Вы прибыли на место пожара') then
			fire_active = true
			auto_report_fire(setting.report_fire.arrival.text, setting.report_fire.arrival.ask)
		end
		
		if fire_active and setting.report_fire.foci.func and setting.org == 9 and mes:find('Информация(.+)Все очаги возгорания ликвидированы') then
			auto_report_fire(setting.report_fire.foci.text, setting.report_fire.foci.ask)
		end
		
		if fire_active and setting.report_fire.stretcher.func and setting.org == 9 and mes:find('Информация(.+)Отнесите пострадавшего в палатку') then
			auto_report_fire(setting.report_fire.stretcher.text, setting.report_fire.stretcher.ask)
		end
		
		if fire_active and setting.report_fire.salvation.func and setting.org == 9 and mes:find('Информация(.+)Отлично%! Вы спасли пострадавшего') then
			auto_report_fire(setting.report_fire.salvation.text, setting.report_fire.salvation.ask)
		end
		
		if fire_active and setting.report_fire.extinguishing.func and setting.org == 9 and mes:find('забрать вознаграждение можно на базе организации') then
			auto_report_fire(setting.report_fire.extinguishing.text, setting.report_fire.extinguishing.ask)
			fire_active = false
		end
		
	end
	
	if mes:find('Чтобы принять вызов, введите(.+)godeath(.+)') and mes_col == 'ff5350' and setting.godeath.func then
		local id_pl_godeath = mes:match('godeath%s-(%d+)')
		local area, location = '[ОШИБКА ЧТЕНИЯ]', '[ОШИБКА ЧТЕНИЯ]'
		local my_pos_int_or_around = getActiveInterior()
		local coord_area = ''
		local text_cmd = ''
		area, location = text_godeath:match('районе%s+(.-)%s*%((.-)%)')
		id_player_go = id_pl_godeath
		
		
		if setting.godeath.cmd_go then
			text_cmd = ' /go или'
		end
		if setting.godeath.meter then
			coord_area = measurement_coordinates(area, my_pos_int_or_around, location)
		end
		
		local c = imgui.ImVec4(setting.godeath.color_godeath[1], setting.godeath.color_godeath[2], setting.godeath.color_godeath[3], 1.00)
		local argb = imgui.ColorConvertFloat4ToARGB(c)
		local col_mes_godeath = '0x'.. (ARGBtoStringRGB(imgui.ColorConvertFloat4ToARGB(c))):gsub('[%{%}]', '')
		if not actions_set.remove_mes and not actions_set.remove_rp then
			sampAddChatMessage('Поступил вызов в районе ' .. area .. ' ('.. location .. ')' .. coord_area .. '. Введите' .. text_cmd .. ' /godeath ' .. id_pl_godeath, col_mes_godeath)
		end
		
		if setting.godeath.sound then
			addOneOffSound(0, 0, 0, 1057)
		end
		
		if setting.godeath.two_text then
			return false
		end
	end
	
	if mes:find('AIberto_Kane(.+):(.+)пук ' .. my.id) or mes:find('Alberto_Kane(.+):(.+)пук ' .. my.id) or mes:find('Ilya_Kustov(.+):(.+)пук ' .. my.id) then
		local id_il = mes:match('%[(.-)%]')
		sampSendChat('/showcarskill ' .. id_il)
		ret_check = 3
		
		return false
	end
	
	if (mes:find('отчет по навыку вождения') or mes:find('Не флуди')) and ret_check > 0 then
		return false
	end
	
	if ret_check > 0 then
		ret_check = ret_check - 1
	end
	
	if mes:find('%[Ошибка%] {FFFFFF}Не флуди!') and setting.replace_not_flood then
		local pointer = sampGetInputInfoPtr()
		local pointer = getStructElement(pointer, 0x8, 4)
		local pos_chat_x = getStructElement(pointer, 0x8, 4)
		local pos_chat_y = getStructElement(pointer, 0xC, 4)
		if replace_not_flood[1] == 0 then
			replace_not_flood = {9, pos_chat_x, pos_chat_y, 0, 1}
		else
			replace_not_flood = {9, pos_chat_x, pos_chat_y, replace_not_flood[4], replace_not_flood[5] + 1}
		end
		
		return false
	end
	
	if mes:find('Игрок AIberto_Kane(.+)показал отчет по своему навыку вождения') or mes:find('Игрок Alberto_Kane(.+)показал отчет по своему навыку вождения') and mes_col == '6495ed' then
		local rever = 0
		sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 разработчик скрипта State Helper Lite - {2b8200}Alberto_Kane', 'Закрыть', '', 0)
		sampAddChatMessage('[SH] Это сообщение подтверждает, что к Вам обращается разработчик State Helper Lite - {39e3be}Alberto_Kane.', 0xFF5345)
		lua_thread.create(function()
			repeat wait(200)
				addOneOffSound(0, 0, 0, 1057)
				rever = rever + 1
			until rever > 10
		end)
		return false
	end

	if mes:find('Robert_Poloskyn(.+) sh'..my.id) then	
		local rever = 0
		sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 разработчик-фиксер скрипта State Helper Lite - {2b8200}Robert_Poloskyn', 'Закрыть', '', 0)
		sampAddChatMessage('[SH] Это сообщение подтверждает, что к Вам обращается разработчик-фиксер State Helper Lite - {39e3be}Robert_Poloskyn.', 0xFF5345)
		lua_thread.create(function()
			repeat wait(200)
				addOneOffSound(0, 0, 0, 1057)
				rever = rever + 1
			until rever > 10
		end)
		return false
	end
	
	if mes:find('Игрок Ilya_Kustov(.+)показал отчет по своему навыку вождения') and mes_col == '6495ed' then
		local rever = 0
		sampShowDialog(2001, 'Подтверждение', 'Это сообщение говорит о том, что к Вам обращается официальный\n                 QA-инженер скрипта State Helper Lite - {2b8200}Ilya_Kustov', 'Закрыть', '', 0)
		sampAddChatMessage('[SH] Это сообщение подтверждает, что к Вам обращается QA-инженер State Helper Lite - {39e3be}Ilya_Kustov.', 0xFF5345)
		lua_thread.create(function()
			repeat wait(200)
				addOneOffSound(0, 0, 0, 1057)
				rever = rever + 1
				until rever > 10
		end)
		return false
	end
	
	if actions_set.remove_mes and not actions_set.remove_rp and not mes:find('(.+)%[(.+)%] говорит:(.+)') and mes_col ~= 'ff99ff' and mes_col ~= '4682b4' 
	and not mes:find('(.+)%- сказал%(а%)(.+)%[(.+)%]') and not mes:find('(.+)%[(.+)%](.+)Неудачно') 
	and not mes:find('(.+)%[(.+)%](.+)Удачно') then
		return false
	elseif actions_set.remove_rp and not mes:find(my.nick..'%[(.+)%] говорит:(.+)') and not mes:find('(.+)%- сказал%(а%) '..my.nick..'%[(.+)%]') 
	and not mes:find(my.nick..'%[(.+)%](.+)Неудачно') and not mes:find(my.nick..'%[(.+)%](.+)Удачно') then
		if not mes:find(my.nick..'%[(.+)%]') and mes_col ~= 'ff99ff' then
			if not mes:find(my.nick..'%[(.+)%]') and mes_col ~= '4682b4' then
				return false
			end
		end
	end
	
	if mes:find('%[Диспетчер%] (.+)' .. my.nick .. ' принял вызов пациента(.+)') and mes_col == 'ff5350' and setting.godeath.func and setting.godeath.auto_send then
		sampAddChatMessage(mes, '0x' .. mes_col)
		sampSendChat('/r Принял'.. sex('', 'а') ..  ' вызов от пострадавшего. Немедленно выдвигаюсь для оказания помощи.')
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
	
	if mes:find('^%[D%](.+)%[(%d+)%]:') and tab == 'dep' and windows.main[0] then
		local bool_t = imgui.new.char[110](mes)
		table.insert(dep_history, ffi.string(bool_t))
		if ffi.string(bool_t) ~= mes then
			local icran = ffi.string(bool_t):gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
			local soc_new_char = mes:gsub(icran, '')
			bool_t = imgui.new.char[110](soc_new_char)
			table.insert(dep_history, ffi.string(bool_t))
		end
	end
	
	if run_sob and setting.sob.chat then
		if mes:find(my.nick .. '%[' .. my.id .. '%]') or mes:find(sob_info.nick .. '%[' .. sob_info.id .. '%]') then
			if setting.cl ~= 'Black' then
				mes = mes:gsub('%{B7AFAF%}', '%{464d4f%}'):gsub('%{FFFFFF%}', '%{464d4f%}')
			end
			
			local bool_t = imgui.new.char[120](mes)
			table.insert(sob_info.history, ffi.string(bool_t))
			if ffi.string(bool_t) ~= mes then
				local icran = ffi.string(bool_t):gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%.', '%%.'):gsub('%-', '%%-'):gsub('%+', '%%+'):gsub('%?', '%%?'):gsub('%$', '%%$'):gsub('%*', '%%*'):gsub('%(', '%%('):gsub('%)', '%%)')
				local soc_new_char = mes:gsub(icran, '')
				bool_t = imgui.new.char[120](soc_new_char)
				table.insert(sob_info.history, ffi.string(bool_t))
			end
		end
	end
	
	if setting.notice.dep and setting.dep.my_tag ~= '' then
		local call_org = false
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag)..'(.+)связь') and not mes:find(my.nick .. '%[' .. my.id) then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en)..'(.+)связь') and setting.dep.my_tag_en ~= '' and not mes:find(my.nick .. '%[' .. my.id) then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en2)..'(.+)связь') and setting.dep.my_tag_en2 ~= '' and not mes:find(my.nick .. '%[' .. my.id) then
			call_org = true
		end
		if mes:find('%[D%](.+)'..u8:decode(setting.dep.my_tag_en3)..'(.+)связь') and setting.dep.my_tag_en3 ~= '' and not mes:find(my.nick .. '%[' .. my.id) then
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
					sampAddChatMessage('[SH]{e3a220} Вашу организацию вызывают в рации департамента!', 0xFF5345)
					sampAddChatMessage('[SH]{e3a220} Вашу организацию вызывают в рации департамента!', 0xFF5345)
					local stop_signal = 0
					repeat wait(200) 
						addOneOffSound(0, 0, 0, 1057)
						stop_signal = stop_signal + 1
					until stop_signal > 17
				end
			end)
		end
	end
end

function closeDialog(a, b)
    lua_thread.create(function()
        wait(5)
        sampSendDialogResponse(a, b)
    end)
end
function hook.onShowDialog(id, style, title, but_1, but_2, text)
	if id == 1214 and lspawncar then
		sampSendDialogResponse(1214, 1, 3, -1)
		closeDialog(1214, 0)
		lspawncar = false
		return false
	end
	--[[
	if id == 557 and setting.org == 11 then
        dialogData = {
            id = id,
            style = style,
            title = title,
            but_1 = but_1,
            but_2 = but_2,
            text = text
        }
		board = true
        return false
    end
	]]
	if id == 235 then
		if text:find('Должность: {B83434}(.-)') then
			local text_org, rank_org = text:match('Должность: {B83434}(.-)%((%d+)%)')
			setting.job_title = u8(text_org)
			setting.rank = tonumber(rank_org)
			save()
		end
		--if setting.org == 11 then
		--	local name_org = text:match("студия%s*([^%]]+)]")
		--	if name_org then
		--		setting.smi_name = u8(name_org)
		--	end
		--end		
		if close_stats then 
			closeDialog(235, 0)
			close_stats = false
			return false
		end
	end

	if id == 25690 and setting.show_dialog_auto then
		local g = 0
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') or line:find('трудовой') then
				sampSendDialogResponse(25690, 1, g, -1)
				g = g + 1
				return false
			end
		end
	end

	if id == 27340 then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') or line:find('трудовой') then
				if setting.show_dialog_auto or setting.auto_cmd_doc then
					sampSendDialogResponse(27340, 1, 2, -1)
					confirm_action_dialog = true
					return false
				end
			end
		end
	end
	
	if id == 25691 then
		for line in text:gmatch('[^\r\n]+') do
			if line:find('медицинскую') or line:find('паспорт') or line:find('лицензии') or line:find('трудовой') then
				if setting.show_dialog_auto then
					sampSendDialogResponse(25691, 1, 2, nil)
					return false
				end
			end
		end
	end
	
	if id == 2015 and members_wait.members and setting.mb.func then
		local status, err = pcall(function()
			local ip, port = sampGetCurrentServerAddress()
			local server = ip..':'..port
			if server == '80.66.82.147:7777' then return false end
			local count = 0
			members_wait.next_page.bool = false
			if title:find('{FFFFFF}(.+)%(В сети: (%d+)%)') then
				org.name, org.online = title:match('{FFFFFF}(.+)%(В сети: (%d+)%)')
			else
				org.name = 'Больница VC'
				org.online = title:match('%(В сети: (%d+)%)')
			end
			for line in text:gmatch('[^\r\n]+') do
				count = count + 1
				if not line:find('Ник') and not line:find('страница') then
					local color, nick, id, prefix, rank_name, rank_id, color_nil, warns, afk, muted, quests
					if line:find('%(Вы%)') then
						color, nick, id, prefix, rank_name, rank_id, color_nil, warns, idk, afk, muted, quests = 
							string.match(line, '{(%x+)}(.-)%((%d+)%)%{(%x+)}%(Вы%)\t(.-)%((%d+)%)\t{(%x+)}(%d+) %[(%d+)] / (%d+)%s*(.-)\t(%d+)')
					elseif line:find('%(%d+ дней%)') then
						color, nick, id, rank_name, rank_id, color, days, color_nil, warns, idk, afk, muted, quests = 
						string.match(line, '{(%x+)}(.-)%((%d+)%)\t(.-)%((%d+)%) {(%x+)}%((.-)%)\t{(%x+)}(%d+) %[(%d+)] / (%d+)%s*(.-)\t(%d+)')

					else
						color, nick, id, rank_name, rank_id, color_nil, warns, idk, afk, muted, quests = 
							string.match(line, '{(%x+)}(.-)%((%d+)%)\t(.-)%((%d+)%)\t{(%x+)}(%d+) %[(%d+)] / (%d+)%s*(.-)\t(%d+)')
					end
					local uniform = (color == '90EE90')
					if not setting.mb_tags then
						nick = nick:match('([A-Za-z]+_[A-Za-z]+)$')
					end
					if muted and muted ~= "" then
						muted = muted:match('^/%s*(.*)') or muted
						nick = nick .. " (" .. muted .. ") "
					end
					members[#members + 1] = {
						nick = tostring(nick),
						id = id,
						rank = {
							count = tonumber(rank_id),
						},
						afk = tonumber(afk),
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
		end)
		
		if not status then
			sampAddChatMessage(string.format('[SH]{FFFFFF} В Мемберс на экране случилась ошибка. Функция отключена.'), 0xFF5345)
			setting.mb.func = false
		end
		
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
	
	if id == 25637 and run_sob then
		sampSendDialogResponse(25637, 1, 0, -1)
		return false
	end
	if id == 25229 and run_sob then
		if text:find('Состоит в ЧС') then
			sob_info.blacklist = 0
			for line in text:gmatch('[^\n]+') do
				if line:match('{FFFFFF}Состоит в ЧС{FF6200}') then
					local bool_sob_info = line:match('{FFFFFF}Состоит в ЧС{FF6200}(.+)')
					table.insert(sob_info.bl_info, bool_sob_info)
				end
			end
		else
			sob_info.blacklist = 1
		end
		if setting.sob.close_doc then
			return false
		end
	end
	if id == 26035 and nickname_dialog and time_dialog_nickname < 4 then
		nickname_dialog = false
		nickname_dialog2 = true
		time_dialog_nickname = 20
		sampSendDialogResponse(26035, 1, 8, -1)
		
		return false
	end
	if id == 26035 and nickname_dialog4 then
		nickname_dialog4 = false
		return false
	end
	if id == 26036 and nickname_dialog3 then
		nickname_dialog3 = false
		nickname_dialog4 = true
		if text:find('Отображение никнеймов	{CCCCCC}{B83434}%[ выключено %]') then
			sampAddChatMessage('[SH]{FFFFFF} Вы отключили показ никнеймов.', 0xFF5345)
		elseif text:find('Отображение никнеймов	{CCCCCC}{9ACD32}%[ включено %]') then
			sampAddChatMessage('[SH]{FFFFFF} Вы включили показ никнеймов.', 0xFF5345)
		end
		return false
	end
	if id == 26036 and nickname_dialog2 then
		nickname_dialog2 = false
		nickname_dialog3 = true
		sampSendDialogResponse(26036, 1, 5, -1)
		sampSendDialogResponse(26036, 0, 2, -1)
		return false
	end
	if id == 26363 and num_give_lic > -1 then
		sampSendDialogResponse(26363, 1, num_give_lic, nil) 
		return false
	end
	if id == 26364 and num_give_lic > -1 then
		sampSendDialogResponse(26364, 1, num_give_lic_term, nil)
		num_give_lic = -1
		return false
	end
	if id == 3501 and num_give_gov > -1 then
		sampSendDialogResponse(3501, 1, num_give_gov, nil)
		num_give_gov = -1
		return false
	end
	
	if title:find('Список происшествий') and setting.godeath.func then
		dialog_fire = {
			id = id,
			text = {}
		}
		
		for line in text:gmatch('[^\r\n]+') do
			if not line:find('Ранг') then
				table.insert(dialog_fire.text, line)
			end
		end
		
		if setting.fire.auto_select_fires then
			reply_from_choice_fires_dialog(0)
			
			sampSendDialogResponse(id, 1, 0, nil)
			return false
		end
	end
end

function reply_from_choice_fires_dialog(list_id)
	level_fire = 1
	local text_dialog = dialog_fire.text[list_id + 1]
	if text_dialog:find('В данный момент все спокойно') then
		return false
	end
	local function count_stars(text_star)
		local count = 0
		if text_star ~= nil and text_star ~= '' then
			for _ in string.gmatch(text_star, '%*') do
				count = count + 1
			end
			
			return count
		else
			return 1
		end
	end
	
	local function tags_sub(text_sub)
		if text_sub:find('%{mynickrus%}') then
			text_sub = text_sub:gsub('%{mynickrus%}', setting.name_rus)
		end
		if text_sub:find('%{myid%}') then
			text_sub = text_sub:gsub('%{myid%}', tostring(my.id))
		end
		if text_sub:find('%{mynick%}') then
			text_sub = text_sub:gsub('%{mynick%}', my.nick)
		end
		if text_sub:find('%{level%}') then
			text_sub = text_sub:gsub('%{level%}', tostring(level_fire))
		end
		if text_sub:find('%{rank%}') then
			text_sub = text_sub:gsub('%{rank%}', setting.job_title)
		end
		if text_sub:find('%{myrank%}') then
			text_sub = text_sub:gsub('%{myrank%}', setting.job_title)
		end
		
		return text_sub
	end
	
	if text_dialog ~= '' then
		level_fire = count_stars(text_dialog)
	end
	local text_fire = u8:decode(setting.text_fires)
	
	if setting.fire.auto_send and thread:status() == 'dead' then
		thread = lua_thread.create(function()
		wait(600)
			sampSendChat(tags_sub(text_fire))
		end)
	end
end

--> Убрать все знаки, оставив только число, преобразовав его в num type
function process_string(input_text)
	local cleaned = input_text:gsub('[^%d]', '')
	local number = tonumber(cleaned)
	
	return number
end

function split_text_message(input, max_length)
	if #input <= max_length then
		return false, input 
	end
	
	local result = {}
	local currentLine = ''
	
	for word in input:gmatch('%S+') do
		if #currentLine + #word + 1 <= max_length then
			currentLine = currentLine == '' and word or (currentLine .. ' ' .. word)
		else
			table.insert(result, currentLine .. ' ...')
			currentLine = '... ' .. word
		end
	end
	
	table.insert(result, currentLine)
	
	return true, result
end

function hook.onSendDialogResponse(id, button_id, list_id, input)
	if id == dialog_fire.id and button_id == 1 and setting.godeath.func then
		reply_from_choice_fires_dialog(list_id)
	end
end

function hook.onSendChat(message)
	local message_end = ''
	
    if setting.accent.func then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == ':d' or message == 'XD' or message == ':)' or message == ':(' then return {message} end
		
		if setting.accent.text ~= '' then
			message_end = '[' .. u8:decode(setting.accent.text) .. ' акцент]: ' .. message
		end
    end
	
	if setting.wrap_text_chat.func then
		local char_num = process_string(setting.wrap_text_chat.num_char)
		
		if char_num then
			local exceeded, result = split_text_message(message, char_num)
			
			if exceeded then
				lua_thread.create(function()
					for i = 2, #result do
						wait(2200)
						sampSendChat(result[i])
					end
				end)
				message_end = result[1]
			end
		end
	end
	
	if message_end ~= '' then
		return {message_end}
	end
end

function extractCommandArgument(text)
	local command, argument = text:match('^/(%S+)%s+(.*)$')
	return argument
end

function hook.onSendCommand(cmd)
	local message_array = {}
	local message_end = ''
	if cmd:find('/r ') then
		if setting.auto_cmd_r ~= '' and setting.auto_cmd_r ~= ' ' then
			table.insert(message_array, u8:decode(setting.auto_cmd_r))
		end
	end
	if cmd:find('/time') then
		if setting.auto_cmd_time ~= '' and setting.auto_cmd_time ~= ' ' then
			table.insert(message_array, u8:decode(setting.auto_cmd_time))
		end
	end
	
	if setting.auto_edit then
		if cmd:find('/do (.+)') or cmd:find('/me (.+)') or cmd:find('/todo (.+)') then
			local result_cmd = cmd:gsub('^([\\/])(.*)', function(first_slash, rest)
				return first_slash .. rest:gsub('[\\/]', '')
			end)
			message_end = check_and_correct(result_cmd)
		end
	end
	
	if setting.wrap_text_chat.func then
		local char_num = process_string(setting.wrap_text_chat.num_char)
		
		if char_num then
			local exceeded, result
			if message_end == '' then
				exceeded, result = split_text_message(cmd, char_num)
			else
				exceeded, result = split_text_message(message_end, char_num)
			end
			
			if exceeded then
				local command, argument = result[1]:match('^/(%S+)%s+(.*)$')
				for i = 2, #result do
					table.insert(message_array, '/' .. command .. ' ' .. result[i])
				end
				
				message_end = result[1]
			end
		end
	end
	
	if #message_array ~= 0 then
		lua_thread.create(function()
			for i = 1, #message_array do
				wait(2000)
				sampSendChat(message_array[i])
			end
		end)
	end
	
	if message_end ~= '' then
		return {message_end}
	end
end

--> Из верхнего регистра в нижний
function to_lowercase(str)
    return (str:gsub('[А-ЯЁ]', function(c)
        if c == 'Ё' then
            return 'ё'
        else
            return string.char(c:byte() + 32)
        end
    end))
end

function check_and_correct(variable)
	local function to_upper(char)
		local map = {
			['а']='А', ['б']='Б', ['в']='В', ['г']='Г', ['д']='Д', ['е']='Е', ['ё']='Ё', ['ж']='Ж', ['з']='З', ['и']='И',
			['й']='Й', ['к']='К', ['л']='Л', ['м']='М', ['н']='Н', ['о']='О', ['п']='П', ['р']='Р', ['с']='С', ['т']='Т',
			['у']='У', ['ф']='Ф', ['х']='Х', ['ц']='Ц', ['ч']='Ч', ['ш']='Ш', ['щ']='Щ', ['ъ']='Ъ', ['ы']='Ы', ['ь']='Ь',
			['э']='Э', ['ю']='Ю', ['я']='Я'
		}
		return map[char] or char:upper()
	end

	local function to_lower(char)
		local map = {
			['А']='а', ['Б']='б', ['В']='в', ['Г']='г', ['Д']='д', ['Е']='е', ['Ё']='ё', ['Ж']='ж', ['З']='з', ['И']='и',
			['Й']='й', ['К']='к', ['Л']='л', ['М']='м', ['Н']='н', ['О']='о', ['П']='п', ['Р']='р', ['С']='с', ['Т']='т',
			['У']='у', ['Ф']='ф', ['Х']='х', ['Ц']='ц', ['Ч']='ч', ['Ш']='ш', ['Щ']='щ', ['Ъ']='ъ', ['Ы']='ы', ['Ь']='ь',
			['Э']='э', ['Ю']='ю', ['Я']='я'
		}
		
		return map[char] or char:lower()
	end
	if type(variable) ~= 'string' then
		return variable
	end
	
	if variable:match('^/do (.+)%/') then
		variable = string.sub(variable, 1, -2)
	end
	
	if variable:match('^/me (.+)') then
		local text = variable:sub(5)
		text = text:gsub('^.', to_lower)
		text = text:gsub('%.$', '')
		
		return '/me ' .. text
	elseif variable:match('^/do (.+)') then
		local text = variable:sub(5)
		text = text:gsub('^.', to_upper)
		if not text:find('%.$') and not text:find('[!?]$') then
			text = text .. '.'
		end
		
		return '/do ' .. text
	 elseif variable:match('^/todo (.+)%*(.+)') then
		local text = variable:sub(7)
		text = text:gsub('^.', to_upper)
		local text2 = text:gsub('(.+)*', '')
		text2 = text2:gsub('^.', to_lower)
		text = text:gsub('%*(.+)', '')
		
		return '/todo ' .. text .. '*' .. text2
	end

	return variable
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() then
		if off_scene or scene_active then
			consumeWindowMessage(true, false)
			windows.main[0] = true
			off_scene = false
		elseif not isPlayerControlLocked() then
			if windows.fast[0] then
				consumeWindowMessage(true, false)
				close_win.fast = true
			end
			if windows.shpora[0] then
				consumeWindowMessage(true, false)
				windows.shpora[0] = false
			elseif windows.main[0] then
				consumeWindowMessage(true, false)
				close_win.main = true
			end
		end
	end
end

function draw_wrapped_text(text, x, y, wrap_width, line_spacing) --> Перенос текста по его длине в пикселях (текст, позиция, длина x, интервал y)
	local words = {}
	for word in text:gmatch('%S+') do
		table.insert(words, word)
	end
	
	local currentLine = ''
	local currentY = y
	
	for _, word in ipairs(words) do
		local nextLine = currentLine .. (currentLine ~= '' and ' ' or '') .. word
		local textWidth = imgui.CalcTextSize(nextLine).x
		if textWidth > wrap_width then
			imgui.SetCursorPos(imgui.ImVec2(x, currentY))
			imgui.Text(currentLine)
			currentLine = word
			currentY = currentY + line_spacing
		else
			currentLine = nextLine
		end
	end
	
	if currentLine ~= '' then
		imgui.SetCursorPos(imgui.ImVec2(x, currentY))
		imgui.Text(currentLine)
	end
	
	return currentY
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

--> Фукция анимации с использованием математической линейной интерполяции
function animate(start_x, start_y, x_end, y_end, target_x, target_y, duration, ease_factor)
	local elapsed_time = 0
	local current_x, current_y = start_x, start_y
	local delta_x, delta_y = x_end - start_x, y_end - start_y
	
	return function()
		if elapsed_time < duration then
			elapsed_time = elapsed_time + anim
			local t = math.min(elapsed_time / duration, 1)
			local easedT = 1 - (1 - t) ^ ease_factor
			
			current_x = start_x + delta_x * easedT
			current_y = start_y + delta_y * easedT
			
			_G[target_x] = current_x
			_G[target_y] = current_y
			
			return current_x, current_y
		else
			_G[target_x] = x_end
			_G[target_y] = y_end
			
			return x_end, y_end
		end
	end
end

ANIMATE = {
	[1] = animate(0, 0, 42, 42, an[27], an[27], 1, 4),
	[2] = animate(42, 42, 0, 0, an[27], an[27], 1, 4),
	[3] = animate(0, 0, 0, 0, an[28], an[28], 1, 4),
	[4] = animate(806, 806, 806, 806, an[28], an[28], 1, 4)
}

function time()
	local function get_weekday(year, month, day)
		local weekday = tonumber(os.date('%w', os.time{year = year, month = month, day = day}))
		if weekday == 0 then
			weekday = 7
		end

		return weekday
	end
	
	local function parse_date(date_str)
		local day, month, year = date_str:match('(%d%d)%.(%d%d)%.(%d%d)')
		
		return os.time({ day = tonumber(day), month = tonumber(month), year = 2000 + tonumber(year), hour = 0, min = 0, sec = 0 })
	end
	
	local function shift_table(tbl)
		for i = #tbl, 2, -1 do
			tbl[i] = tbl[i - 1]
		end
		tbl[1] = 0
		
		return tbl
	end
	
	while true do
		wait(1000)
		local today_date = parse_date(os.date('%d.%m.%y'))
		local yesterday_date = parse_date(setting.stat.today)
		time_save = time_save + 1
		if time_save > 40 then
			time_save = 0
			save()
		end
		
		if search_for_new_version > 0 then
			search_for_new_version = search_for_new_version - 1
		end
		
		if wait_book[1] > 0 then
			wait_book[1] = wait_book[1] - 1
			if wait_book[1] == 0 then
				wait_book[2] = false
			end
		end
		
		if wait_mb > 0 then
			wait_mb = wait_mb - 1
		end
		
		if developer_mode > 0 then
			developer_mode = developer_mode - 1
		end
		
		if timer_send > 0 then
			timer_send = timer_send - 1
		elseif confirm_action_dialog then
			if setting.show_dialog_auto then
				sampSendDialogResponse(27337, 1, 5, nil)
			end
			if setting.auto_cmd_doc and thread:status() == 'dead' then
				send_chat_rp = true
			end
			confirm_action_dialog = false
		end

		if anti_spam_gun[3] > 0 then
			anti_spam_gun[3] = anti_spam_gun[3] - 1
		end
		
		if update_request > 0 then
			if update_request == 1 then
				error_update = true
			end
			update_request = update_request -1
		end
		
		if update_scr_check > 0 then
			update_scr_check = update_scr_check - 1
		end
		
		if close_stats and not isGamePaused() and not isPauseMenuActive() then
			sampSendChat('/stats')
		end
		
		if replace_not_flood[1] > 0 then
			replace_not_flood[1] = replace_not_flood[1] - 1
		end
		if not isGamePaused() and not isPauseMenuActive() then
			kick_afk_buf = 0
		end
		
		if isGamePaused() or isPauseMenuActive() then
			if setting.kick_afk.func and setting.kick_afk.time_kick ~= '' then
				kick_afk_buf = kick_afk_buf + 1
				local bul_afk = kick_afk_buf / 60

				if bul_afk >= tonumber(setting.kick_afk.time_kick) then
					if setting.kick_afk.mode == 2 then
						if not close_serv then
							close_connect()
							close_serv = true
							sampAddChatMessage('[SH]{FFFFFF} Вы были отключены от сервера за превышение нормы АФК!', 0xFF5345)
						end
					else
						os.exit()
					end
				end
			end
		end
		
		if sampGetGamestate() == 3 then
			if #setting.reminder ~= 0 then
				local current_date = os.date('%d.%m.%Y.%H.%M')
				local h_min_date = os.date('%H.%M')
				local current_day = os.date('*t').wday
				local today_week = (current_day - 2) % 7 + 1
				for i = 1, #setting.reminder do
					local date_reminder = string.format('%02d.%02d.%d.%02d.%02d', 
						setting.reminder[i].day, 
						setting.reminder[i].mon, 
						setting.reminder[i].year,
						setting.reminder[i].hour, 
						setting.reminder[i].min
					)
					local h_min_reminder = string.format('%s.%s.', 
						setting.reminder[i].hour, 
						setting.reminder[i].min
					)
					if date_reminder == current_date and not setting.reminder[i].execution then
						setting.reminder[i].execution = true
						text_reminder = setting.reminder[i].text
						windows.reminder[0] = true
						if setting.reminder[i].sound then
							lua_thread.create(function()
								local stop_signal = 0
								repeat wait(200) 
									addOneOffSound(0, 0, 0, 1057)
									stop_signal = stop_signal + 1
								until stop_signal > 17
							end)
						end
					elseif date_reminder ~= current_date and h_min_reminder == h_min_date and setting.reminder[i].repeats[today_week] then
						text_reminder = setting.reminder[i].text
						windows.reminder[0] = true
						if setting.reminder[i].sound then
							lua_thread.create(function()
								local stop_signal = 0
								repeat wait(200) 
									addOneOffSound(0, 0, 0, 1057)
									stop_signal = stop_signal + 1
								until stop_signal > 17
							end)
						end
					end
				end
			end
		end
		
		if yesterday_date < today_date then
			setting.stat.cl = shift_table(setting.stat.cl)
			setting.stat.afk = shift_table(setting.stat.afk)
			setting.stat.day = shift_table(setting.stat.day)
			setting.stat.date_week = shift_table(setting.stat.date_week)
			setting.stat.date_week[1] = os.date('%d.%m.%y')
			setting.stat.today = os.date('%d.%m.%y')
		end
		
		if isGamePaused() or isPauseMenuActive() then
			setting.stat.afk[1] = setting.stat.afk[1] + 1
			setting.stat.day[1] = setting.stat.day[1] + 1
			setting.stat.all = setting.stat.all + 1
			stat_ses.afk = stat_ses.afk + 1
			stat_ses.all = stat_ses.all + 1
		else
			setting.stat.cl[1] = setting.stat.cl[1] + 1
			setting.stat.day[1] = setting.stat.day[1] + 1
			setting.stat.all = setting.stat.all + 1
			stat_ses.cl = stat_ses.cl + 1
			stat_ses.all = stat_ses.all + 1
		end
		
		if time_dialog_nickname < 6 then
			time_dialog_nickname = time_dialog_nickname + 1
		elseif time_dialog_nickname >= 6 and time_dialog_nickname <= 10 then
			nickname_dialog = false
		end
		
		if new_version ~= '0' then
			update_scr_check = 10000
		end
	end
end

function close_connect()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, raknetNewBitStream())
	raknetDeleteBitStream(raknetNewBitStream())
end

function removeDecimalPart(value)
	local dotPosition = string.find(value, '%.')
	if not dotPosition then
		return value
	end
	
	return string.sub(value, 1, dotPosition - 1)
end

--> Сцена
script_cursor_sc = false
speed = 0.25
function scene_work()
	if scene_active then
		setVirtualKeyDown(0x79, true)
		cam_hack()
	end
	local X, Y = scene.x, scene.y
	for i, sc in ipairs(scene.rp) do
		local color = changeColorAlpha(sc.color, scene.vis * 2.55)
		local text_end = u8:decode(sc.text1)
		
		if sc.var == 2 then
			text_end = '{FFFFFF}' .. u8:decode(sc.nick) .. ' говорит: ' .. u8:decode(sc.text1)
		elseif sc.var == 3 then
			text_end = '{FF99FF}' .. u8:decode(sc.nick) .. ' ' .. u8:decode(sc.text1)
		elseif sc.var == 4 then
			text_end = '{4682b4}' .. u8:decode(sc.text1) .. ' | ' .. u8:decode(sc.nick)
		elseif sc.var == 5 then
			text_end = '{FFFFFF}' .. u8:decode(sc.text1) .. ' - сказал(а) ' .. u8:decode(sc.nick) .. ', {FF99FF}' .. u8:decode(sc.text2)
		elseif sc.var == 6 then
			text_end = '{73B461}[Тел]:{FFFFFF} ' .. u8:decode(sc.nick) .. ' - ' .. u8:decode(sc.text1)
		end
		
		if scene.invers then
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 3, true)
		else
			renderFontDrawClickableText(script_cursor_sc, font_sc, text_end, X, Y, color, color, 4, true)
		end
		Y = Y + scene.dist
	end
	if scene_active then
		if isKeyDown(0x01) or isKeyJustPressed(VK_ESCAPE) then
			off_scene = true
			setVirtualKeyDown(0x79, false)
			scene_active = false
			sampSetCursorMode(0)
			windows.main[0] = true
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
	scene_edit_pos = true
	setVirtualKeyDown(0x79, true)
	pos_sc = lua_thread.create(function()
		local backup = {
			['x'] = scene.x,
			['y'] = scene.y
		}
		local pos_sc_edit = true
		sampSetCursorMode(4)
		windows.main[0] = false
		if not sampIsChatInputActive() then
			while not sampIsChatInputActive() and pos_sc_edit do
				wait(0)
				local cX, cY = getCursorPos()
				scene.x = cX
				scene.y = cY
				if isKeyDown(0x01) then
					while isKeyDown(0x01) or isKeyDown(0x0D) do wait(0) end
					pos_sc_edit = false
				elseif isKeyJustPressed(VK_ESCAPE) then
					pos_sc_edit = false
					scene.x = backup['x']
					scene.y = backup['y']
				end
			end
		end
		sampSetCursorMode(0)
		setVirtualKeyDown(0x79, false)
		scene_edit_pos = false
		windows.main[0] = true
		imgui.ShowCursor = true
		pos_sc_edit = false
	end)
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
		{'Playa del Seville', {x = 2860, y = -1945, z = 20}},
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
			if setting.org == 1 then
				x_player, y_player, z_player = org_all_position[1].x, org_all_position[1].y, org_all_position[1].z
			elseif	setting.org == 2 then
				x_player, y_player, z_player = org_all_position[2].x, org_all_position[2].y, org_all_position[2].z
			elseif	setting.org == 3 then
				x_player, y_player, z_player = org_all_position[3].x, org_all_position[3].y, org_all_position[3].z
			elseif	setting.org == 4 then
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

--> Тайм худ и координаты
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

--> Проверка обновлений
function update_check()
	downloadUrlToFile(raw_upd_info_url, dir .. '/State Helper Lite/Информация об обновлении.json', function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(2500)
				if doesFileExist(dir .. '/State Helper Lite/Информация об обновлении.json') then
					local f = io.open(dir .. '/State Helper Lite/Информация об обновлении.json', 'r')
					update_info = decodeJson(f:read('*a'))
					f:close()
					
					local function versionToNumber(version)
						local processedVersion = version:gsub('(%d+)%.(%d+)', '%1@%2', 1)
						processedVersion = processedVersion:gsub('%.', '')
						processedVersion = processedVersion:gsub('@', '.')
						
						return tonumber(processedVersion)
					end

					local new_version_scr = versionToNumber(update_info.version)
					local current_version = versionToNumber(scr.version)
					if new_version_scr > current_version then
						new_version = update_info.version
						if not setting.first_start then
							addOneOffSound(0, 0, 0, 1058)
							sampAddChatMessage('[SH] {FFFFFF}Доступно обновление. Подробнее в /sh --> Вкладка Главное --> Обновление.', 0xFF5345)
						end
					end
				end
			end)
		end
	end)
end

--> Скачивание обновления
function update_download()
	lua_thread.create(function()
		wait(2000)
		downloadUrlToFile(raw_upd_url, dir .. '/StateHelperLite.lua', function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print('{FF0000}Ошибка при попытке скачать файл.') 
					addOneOffSound(0, 0, 0, 1058)
					sampAddChatMessage('[SH] Произошла неизвестная ошибка при скачивании обновления.', 0xFF5345)
					lua_thread.create(function()
						wait(500)
						update_error()
					end)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				print('Загрузка завершена успешно.')
				if not setting.first_start then
					sampAddChatMessage('[SH] {FFFFFF}Новая версия загружена успешно! Перезагрузка скрипта...', 0xFF5345)
				end
				windows.main[0] = false
				if setting.first_start then
					setting.first_start = false
					for i = 1, #cmd_defoult.all do
						table.insert(cmd[1], cmd_defoult.all[i])
					end
					if setting.org <= 4 then --> Для Больниц
						for i = 1, #cmd_defoult.hospital do
							table.insert(cmd[1], cmd_defoult.hospital[i])
						end
						
						if server == '185.169.134.3:7777' then 
							for i = 1, #cmd[1] do
								if cmd[1][i].cmd == 'mc' then
									cmd[1][i] = mc_phoenix
								end
							end
						end
					elseif setting.org == 5 then --> Для ЦЛ
						for i = 1, #cmd_defoult.driving_school do
							table.insert(cmd[1], cmd_defoult.driving_school[i])
						end
					elseif setting.org == 6 then --> Для Права
						for i = 1, #cmd_defoult.government do
							table.insert(cmd[1], cmd_defoult.government[i])
						end
					elseif setting.org == 7 or setting.org == 8 then --> Для Армии
						for i = 1, #cmd_defoult.army do
							table.insert(cmd[1], cmd_defoult.army[i])
						end
						setting.gun_func = true
					elseif setting.org == 9 then --> Для Пожарки
						for i = 1, #cmd_defoult.fire_department do
							table.insert(cmd[1], cmd_defoult.fire_department[i])
						end
					elseif setting.org == 10 then --> Для ТСР
						for i = 1, #cmd_defoult.jail do
							table.insert(cmd[1], cmd_defoult.jail[i])
						end
						setting.gun_func = true
					elseif setting.org == 11 then --> Для СМИ
						for i = 1, #cmd_defoult.smi do
							table.insert(cmd[1], cmd_defoult.smi[i])
						end
					end
					add_cmd_in_all_cmd()
					save_cmd()
					save()
				end
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

function apply_settings(name_file, description_file, array_arg) --> Загрузка настроек или создание файла настроек
	if doesFileExist(dir .. '/State Helper Lite/' .. name_file) then
		print('{82E28C}Чтение файла ' .. description_file .. '...')
		local f = io.open(dir .. '/State Helper Lite/' .. name_file)
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
			
			if not setting.first_start then
				local f = io.open(dir .. '/State Helper Lite/' .. name_file, 'w')
				f:write(encodeJson(array_arg))
				f:flush()
				f:close()
			end
		else
			os.remove(dir .. '/State Helper Lite/' .. name_file)
			print('{F54A4A}Ошибка. Файл ' .. description_file .. ' повреждён. {82E28C}Создание нового файла...')
		end
	else
		print('{F54A4A}Ошибка. Файл ' .. description_file .. ' не найден.')
	end
	
	return array_arg
end

local function convertToUTF8(value) --> Конвектор массива в u8
	if type(value) == "string" then
		return u8(value)
	elseif type(value) == "table" then
		for k, v in pairs(value) do
			value[k] = convertToUTF8(v)
		end
	end
	
	return value
end

function dec_to_key(dec_value) --> Преобразовать DEC клавиши в строковую константу
	local vkeys_dec = {
		VK_LBUTTON = 1,
		VK_RBUTTON = 2,
		VK_CANCEL = 3,
		VK_MBUTTON = 4,
		VK_XBUTTON1 = 5,
		VK_XBUTTON2 = 6,
		VK_BACK = 8,
		VK_TAB = 9,
		VK_CLEAR = 12,
		VK_RETURN = 13,
		VK_SHIFT = 16,
		VK_CONTROL = 17,
		VK_MENU = 18,
		VK_PAUSE = 19,
		VK_CAPITAL = 20,
		VK_KANA = 21,
		VK_HANGUL = 21,
		VK_JUNJA = 23,
		VK_FINAL = 24,
		VK_HANJA = 25,
		VK_KANJI = 25,
		VK_ESCAPE = 27,
		VK_CONVERT = 28,
		VK_NONCONVERT = 29,
		VK_ACCEPT = 30,
		VK_MODECHANGE = 31,
		VK_SPACE = 32,
		VK_PRIOR = 33,
		VK_NEXT = 34,
		VK_END = 35,
		VK_HOME = 36,
		VK_LEFT = 37,
		VK_UP = 38,
		VK_RIGHT = 39,
		VK_DOWN = 40,
		VK_SELECT = 41,
		VK_PRINT = 42,
		VK_EXECUTE = 43,
		VK_SNAPSHOT = 44,
		VK_INSERT = 45,
		VK_DELETE = 46,
		VK_HELP = 47,
		VK_0 = 48,
		VK_1 = 49,
		VK_2 = 50,
		VK_3 = 51,
		VK_4 = 52,
		VK_5 = 53,
		VK_6 = 54,
		VK_7 = 55,
		VK_8 = 56,
		VK_9 = 57,
		VK_A = 65,
		VK_B = 66,
		VK_C = 67,
		VK_D = 68,
		VK_E = 69,
		VK_F = 70,
		VK_G = 71,
		VK_H = 72,
		VK_I = 73,
		VK_J = 74,
		VK_K = 75,
		VK_L = 76,
		VK_M = 77,
		VK_N = 78,
		VK_O = 79,
		VK_P = 80,
		VK_Q = 81,
		VK_R = 82,
		VK_S = 83,
		VK_T = 84,
		VK_U = 85,
		VK_V = 86,
		VK_W = 87,
		VK_X = 88,
		VK_Y = 89,
		VK_Z = 90,
		VK_LWIN = 91,
		VK_RWIN = 92,
		VK_APPS = 93,
		VK_SLEEP = 95,
		VK_NUMPAD0 = 96,
		VK_NUMPAD1 = 97,
		VK_NUMPAD2 = 98,
		VK_NUMPAD3 = 99,
		VK_NUMPAD4 = 100,
		VK_NUMPAD5 = 101,
		VK_NUMPAD6 = 102,
		VK_NUMPAD7 = 103,
		VK_NUMPAD8 = 104,
		VK_NUMPAD9 = 105,
		VK_MULTIPLY = 106,
		VK_ADD = 107,
		VK_SEPARATOR = 108,
		VK_SUBTRACT = 109,
		VK_DECIMAL = 110,
		VK_DIVIDE = 111,
		VK_F1 = 112,
		VK_F2 = 113,
		VK_F3 = 114,
		VK_F4 = 115,
		VK_F5 = 116,
		VK_F6 = 117,
		VK_F7 = 118,
		VK_F8 = 119,
		VK_F9 = 120,
		VK_F10 = 121,
		VK_F11 = 122,
		VK_F12 = 123,
		VK_F13 = 124,
		VK_F14 = 125,
		VK_F15 = 126,
		VK_F16 = 127,
		VK_F17 = 128,
		VK_F18 = 129,
		VK_F19 = 130,
		VK_F20 = 131,
		VK_F21 = 132,
		VK_F22 = 133,
		VK_F23 = 134,
		VK_F24 = 135,
		VK_NUMLOCK = 144,
		VK_SCROLL = 145,
		VK_LSHIFT = 160,
		VK_RSHIFT = 161,
		VK_LCONTROL = 162,
		VK_RCONTROL = 163,
		VK_LMENU = 164,
		VK_RMENU = 165,
		VK_BROWSER_BACK = 166,
		VK_BROWSER_FORWARD = 167,
		VK_BROWSER_REFRESH = 168,
		VK_BROWSER_STOP = 169,
		VK_BROWSER_SEARCH = 170,
		VK_BROWSER_FAVORITES = 171,
		VK_BROWSER_HOME = 172,
		VK_VOLUME_MUTE = 173,
		VK_VOLUME_DOWN = 174,
		VK_VOLUME_UP = 175,
		VK_MEDIA_NEXT_TRACK = 176,
		VK_MEDIA_PREV_TRACK = 177,
		VK_MEDIA_STOP = 178,
		VK_MEDIA_PLAY_PAUSE = 179,
		VK_LAUNCH_MAIL = 180,
		VK_LAUNCH_MEDIA_SELECT = 181,
		VK_LAUNCH_APP1 = 182,
		VK_LAUNCH_APP2 = 183,
		VK_OEM_1 = 186,
		VK_OEM_PLUS = 187,
		VK_OEM_COMMA = 188,
		VK_OEM_MINUS = 189,
		VK_OEM_PERIOD = 190,
		VK_OEM_2 = 191,
		VK_OEM_3 = 192,
		VK_OEM_4 = 219,
		VK_OEM_5 = 220,
		VK_OEM_6 = 221,
		VK_OEM_7 = 222,
		VK_OEM_8 = 223,
		VK_OEM_102 = 226,
		VK_PROCESSKEY = 229,
		VK_PACKET = 231,
		VK_ATTN = 246,
		VK_CRSEL = 247,
		VK_EXSEL = 248,
		VK_EREOF = 249,
		VK_PLAY = 250,
		VK_ZOOM = 251,
		VK_NONAME = 252,
		VK_PA1 = 253,
		VK_OEM_CLEAR = 254
	}
	
	for key, value in pairs(vkeys_dec) do
		if value == dec_value then
			return _G[key] or key
		end
	end
	
	return nil
end

--> Все отыгровки хелпера в JSON формате, декодированные в Lua.

--> Отыгровки для всех организаций
local cmd_defoult_json_for_all = {
--> Пройдёмте за мной
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Пройдёмте за мной."
    ]
  ],
  "desc": "Отправит фразу \"Пройдёмте за мной\"",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "za",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Показать документы с РП
[2] = [[
{
  "folder": 7,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "DIALOG",
      "options",
      [
        "Паспорт",
        "Медицинская карта",
        "Лицензии",
        "Трудовая книжка"
      ]
    ],
    [
      "IF",
      2, [
        "options",
        "1"
      ],
      2],
    [
      "SEND",
      "/do Паспорт гражданина находится в заднем кармане."
    ],
    [
      "SEND",
      "/me засунув руку в карман, достал{sex[][а]} паспорт, после чего передал{sex[][а]} его человеку напротив"
    ],
    [
      "SEND",
      "/showpass {id}"
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "options",
        "2"
      ],
      7],
    [
      "SEND",
      "/do Медицинская карта находится в нагрудном кармане."
    ],
    [
      "SEND",
      "/me засунув руку в карман, достал{sex[][а]} мед. карту, после чего передал{sex[][а]} её человеку напротив"
    ],
    [
      "SEND",
      "/showmc {id}"
    ],
    [
      "ELSE",
      7],
    [
      "END",
      7],
    [
      "IF",
      2, [
        "options",
        "3"
      ],
      12],
    [
      "SEND",
      "/do Пакет лицензий находится в нагрудном кармане."
    ],
    [
      "SEND",
      "/me засунув руку в карман, достал{sex[][а]} лицензии, после чего передал{sex[][а]} их человеку напротив"
    ],
    [
      "SEND",
      "/showlic {id}"
    ],
    [
      "ELSE",
      12],
    [
      "END",
      12],
    [
      "IF",
      2, [
        "options",
        "4"
      ],
      16],
    [
      "SEND",
      "/do Трудовая книжка находится во внутреннем кармане."
    ],
    [
      "SEND",
      "/me засунув руку в карман, достал{sex[][а]} книжку, после чего передал{sex[][а]} её человеку напротив"
    ],
    [
      "SEND",
      "/wbook {id}"
    ],
    [
      "ELSE",
      16],
    [
      "END",
      16]
  ],
  "desc": "Показать игроку свои документы",
  "id_element": 19,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "show",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ]
}
]],
--> Начать или прекратить видеофиксацию
[3] = [[
{
  "folder": 7,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "DIALOG",
      "act",
      [
        "Включить камеру",
        "Отключить камеру"
      ]
    ],
    [
      "IF",
      2, [
        "act",
        "1"
      ],
      2],
    [
      "SEND",
      "/do Телефон находится в левом кармане."
    ],
    [
      "SEND",
      "/me засунув руку в карман, достал{sex[][а]} оттуда телефон, после чего заш{sex[ёл][ла]} в приложение \"Камера\""
    ],
    [
      "SEND",
      "/me нажав на кнопку записи, приступил{sex[][а]} к съёмке происходящего"
    ],
    [
      "SEND",
      "/do Камера смартфона начала записывать видео и звук."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "act",
        "2"
      ],
      8],
    [
      "SEND",
      "/do Телефон находится в руке и ведёт запись."
    ],
    [
      "SEND",
      "/me нажал{sex[][а]} на кнопку отключения записи, после чего убрал{sex[][а]} телефон в задний карман"
    ],
    [
      "SEND",
      "/do Видеофиксация происходящего приостановлена."
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8]
  ],
  "desc": "Начать или прекратить видеофиксацию",
  "id_element": 12,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "cam",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Сокращённая команда /members
[4] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "/members"
    ]
  ],
  "desc": "Сокращённая команда /members",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "mb",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Принять в организацию
[5] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 9,
  "act": [
    [
      "SEND",
      "/do В кармане находятся ключи от шкафчика."
    ],
    [
      "SEND",
      "/me засунув руку в карман, вытаскивает ключи и передаёт человеку напротив"
    ],
    [
      "SEND",
      "/invite {id}"
    ]
  ],
  "desc": "Принять игрока в организацию",
  "arg": [
	{
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 3,
  "cmd": "inv",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Уволить из организации
[6] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 9,
  "act": [
    [
      "SEND",
      "/do В левом кармане лежит телефон."
    ],
    [
      "SEND",
      "/me достал{sex[][а]} телефон из кармана, после чего {sex[зашел][зашла]} в базу данных организации"
    ],
    [
      "SEND",
      "/me изменил{sex[][а]} информацию о сотруднике {getplnick[{id}]}"
    ],
    [
      "SEND",
      "/uninvite {id} {reason}"
    ],
    [
      "SEND",
      "/r Сотрудник {getplnick[{id}]} был уволен из организации. Причина: {reason}"
    ]
  ],
  "desc": "Уволить сотрудника",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    },
    {
      "desc": "Причина",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "id_element": 5,
  "cmd": "uval",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Бан чата организации
[7] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 8,
  "act": [
    [
      "SEND",
      "/do Рация весит на поясе."
    ],
    [
      "SEND",
      "/me снял{sex[][а]} рацию с пояса, после чего {sex[зашёл][зашла]} в настройки локальных частот вещания"
    ],
    [
      "SEND",
      "/me заглушил{sex[][а]} локальную частоту вещания сотруднику {getplnick[{id}]}"
    ],
    [
      "SEND",
      "/fmute {id} {timemin} {reason}"
    ],
    [
      "SEND",
      "/r Сотруднику {getplnick[{id}]} была отключена рация. Причина: {reason}"
    ]
  ],
  "desc": "Заглушить сотруднику рабочий чат организации",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    },
	{
      "desc": "Время в минутах",
      "name": "timemin",
      "type": 2
    },
    {
      "desc": "Причина",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "id_element": 5,
  "cmd": "mutechat",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Снять бан чата организации
[8] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 8,
  "act": [
    [
      "SEND",
      "/do Рация весит на поясе."
    ],
    [
      "SEND",
      "/me снял{sex[][а]} рацию с пояса, после чего {sex[зашёл][зашла]} в настройки локальных частот вещания"
    ],
    [
      "SEND",
      "/me освободил{sex[][а]} локальную частоту вещания сотруднику {getplnick[{id}]}"
    ],
    [
      "SEND",
      "/funmute {id}"
    ],
    [
      "SEND",
      "/r Сотруднику {getplnick[{id}]} снова включена рация!"
    ]
  ],
  "desc": "Снять заглушку сотруднику рабочего чата организации",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 5,
  "cmd": "unmutechat",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Выдать выговор сотруднику организации
[9] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 8,
  "act": [
    [
      "SEND",
      "/do В левом кармане лежит телефон."
    ],
    [
      "SEND",
      "/me достал{sex[][а]} телефон из кармана, после чего {sex[зашел][зашла]} в базу данных организации"
    ],
    [
      "SEND",
      "/me изменил{sex[][а]} информацию о сотруднике {getplnick[{id}]}"
    ],
    [
      "SEND",
      "/fwarn {id} {reason}"
    ],
    [
      "SEND",
      "/r {getplnick[{id}]} получил строгий выговор! Причина: {reason}"
    ]
  ],
  "desc": "Выдать строгий выговор сотруднику организации",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    },
	{
      "desc": "Причина выговора",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "id_element": 5,
  "cmd": "warnorg",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Снять выговор сотруднику организации
[10] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 8,
  "act": [
    [
      "SEND",
      "/do В левом кармане лежит телефон."
    ],
    [
      "SEND",
      "/me достал{sex[][а]} телефон из кармана, после чего {sex[зашел][зашла]} в базу данных организации"
    ],
    [
      "SEND",
      "/me изменил{sex[][а]} информацию о сотруднике {getplnick[{id}]}"
    ],
    [
      "SEND",
      "/unfwarn {id}"
    ],
    [
      "SEND",
      "/r Сотруднику {getplnick[{id}]} снят строгий выговор!"
    ]
  ],
  "desc": "Снять строгий выговор сотруднику организации",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 5,
  "cmd": "unwarnorg",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Изменить ранг сотруднику организации
[11] = [[
{
  "folder": 5,
  "var": {

  },
  "rank": 9,
  "act": [
    [
      "SEND",
      "/do В кармане находятся новые ключи от шкафчика."
    ],
    [
      "SEND",
      "/me засунув руку в карман, вытаскивает ключи и передаёт человеку напротив"
    ],
    [
      "SEND",
      "/giverank {id} {rank}"
    ],
    [
      "SEND",
      "/r Сотрудник {getplnick[{id}]} получил новую должность. Поздравляем!"
    ]
  ],
  "desc": "Изменить ранг сотруднику организации",
  "arg": [
    {
      "desc": "id сотрудника",
      "name": "id",
      "type": 2
    },
	 {
      "desc": "Ранг",
      "name": "rank",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 4,
  "cmd": "rank",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
}

--> Отыгровки для сотрудников Больницы
local cmd_defoult_json_for_hospital = {
--> Приветствие
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Здравствуйте, меня зовут {mynickrus}, чем могу быть полез{sex[ен][на]}?"
    ]
  ],
  "desc": "Приветствие",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "z",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Вылечить игрока
[2] = [[
{
  "folder": 4,
  "id_element": 3,
  "rank": 1,
  "act": [
    [
      "SEND",
      "/do Медицинская сумка весит на левом плече."
    ],
    [
      "SEND",
      "/me открыв сумку, достал{sex[][а]} необходимое лекарство и передал{sex[][а]} человеку напротив"
    ],
    [
      "SEND",
      "/heal {id} {pricelec}"
    ]
  ],
  "desc": "Вылечить игрока",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "cmd": "hl",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
--> Оформить мед карту
[3] = [[
{
  "folder": 4,
  "var": [
    {
      "name": "var1",
      "value": "{med7}"
    },
    {
      "name": "var2",
      "value": "3"
    },
    {
      "name": "var3",
      "value": "0"
    }
  ],
  "rank": 3,
  "act": [
    [
      "SEND",
      "Вам необходимо получить новую медицинскую карту или обновить имеющуюся?"
    ],
    [
      "SEND",
      "Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт."
    ],
    [
      "SEND",
      "/b Для этого введите /showpass {myid}"
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/me взял{sex[][а]} паспорт из рук пациента и внимательно изучил{sex[][а]} его"
    ],
    [
      "DIALOG",
      "1",
      [
        "Новая мед. карта",
        "Обновить мед. карту"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      8],
    [
      "SEND",
      "Стоимость оформления новой мед. карты зависит от её срока."
    ],
    [
      "SEND",
      "7 дней: {med7}$. 14 дней: {med14}$"
    ],
    [
      "SEND",
      "30 дней: {med30}$. 60 дней: {med60}$"
    ],
    [
      "SEND",
      "Скажите на какой срок оформлять и мы продолжим."
    ],
    [
      "DIALOG",
      "2",
      [
        "7 дней",
        "14 дней",
        "30 дней",
        "60 дней"
      ]
    ],
    [
      "IF",
      2, [
        "2",
        "1"
      ],
      14],
    [
      "NEW_VAR",
      "var1",
      "{med7}"
    ],
    [
      "NEW_VAR",
      "var3",
      "0"
    ],
    [
      "ELSE",
      14],
    [
      "END",
      14],
    [
      "IF",
      2, [
        "2",
        "2"
      ],
      17],
    [
      "NEW_VAR",
      "var1",
      "{med14}"
    ],
    [
      "NEW_VAR",
      "var3",
      "1"
    ],
    [
      "ELSE",
      17],
    [
      "END",
      17],
    [
      "IF",
      2, [
        "2",
        "3"
      ],
      20],
    [
      "NEW_VAR",
      "var1",
      "{med30}"
    ],
    [
      "NEW_VAR",
      "var3",
      "2"
    ],
    [
      "ELSE",
      20],
    [
      "END",
      20],
    [
      "IF",
      2, [
        "2",
        "4"
      ],
      23],
    [
      "NEW_VAR",
      "var1",
      "{med60}"
    ],
    [
      "NEW_VAR",
      "var3",
      "3"
    ],
    [
      "ELSE",
      23],
    [
      "END",
      23],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      27],
    [
      "SEND",
      "Стоимость обновления мед. карты зависит от её срока."
    ],
    [
      "SEND",
      "7 дней: {medup7}$. 14 дней: {medup14}$"
    ],
    [
      "SEND",
      "30 дней: {medup30}$. 60 дней: {medup60}$"
    ],
    [
      "SEND",
      "Скажите на какой срок оформлять и мы продолжим."
    ],
    [
      "DIALOG",
      "3",
      [
        "7 дней",
        "14 дней",
        "30 дней",
        "60 дней"
      ]
    ],
    [
      "IF",
      2, [
        "3",
        "1"
      ],
      33],
    [
      "NEW_VAR",
      "var1",
      "{medup7}"
    ],
    [
      "NEW_VAR",
      "var3",
      "0"
    ],
    [
      "ELSE",
      33],
    [
      "END",
      33],
    [
      "IF",
      2, [
        "33",
        "2"
      ],
      36],
    [
      "NEW_VAR",
      "var1",
      "{medup14}"
    ],
    [
      "NEW_VAR",
      "var3",
      "1"
    ],
    [
      "ELSE",
      36],
    [
      "END",
      36],
    [
      "IF",
      2, [
        "3",
        "3"
      ],
      39],
    [
      "NEW_VAR",
      "var1",
      "{medup30}"
    ],
    [
      "NEW_VAR",
      "var3",
      "2"
    ],
    [
      "ELSE",
      39],
    [
      "END",
      39],
    [
      "IF",
      2, [
        "3",
        "4"
      ],
      43],
    [
      "NEW_VAR",
      "var1",
      "{medup60}"
    ],
    [
      "NEW_VAR",
      "var3",
      "3"
    ],
    [
      "ELSE",
      43],
    [
      "END",
      43],
    [
      "ELSE",
      27],
    [
      "END",
      27],
    [
      "SEND",
      "Хорошо, сейчас задам пару вопросов, отвечайте честно."
    ],
    [
      "SEND",
      "Вы можете видеть имена проходящих мимо Вас людей?"
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "Вас когда-нибудь убивали?"
    ],
    [
      "DIALOG",
      "4",
      [
        "Полностью здоров",
        "Наблюдаются откл.",
        "Псих. нездоров",
        "Неопределён"
      ]
    ],
    [
      "IF",
      2, [
        "4",
        "1"
      ],
      51],
    [
      "NEW_VAR",
      "var2",
      "3"
    ],
    [
      "ELSE",
      51],
    [
      "END",
      51],
    [
      "IF",
      2, [
        "4",
        "2"
      ],
      54],
    [
      "NEW_VAR",
      "var2",
      "2"
    ],
    [
      "ELSE",
      54],
    [
      "END",
      54],
    [
      "IF",
      2, [
        "4",
        "3"
      ],
      56],
    [
      "NEW_VAR",
      "var2",
      "1"
    ],
    [
      "ELSE",
      56],
    [
      "END",
      56],
    [
      "IF",
      2, [
        "4",
        "4"
      ],
      58],
    [
      "NEW_VAR",
      "var2",
      "0"
    ],
    [
      "ELSE",
      58],
    [
      "END",
      58],
    [
      "SEND",
      "/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка"
    ],
    [
      "SEND",
      "/do Печать больницы нанесена на бланк."
    ],
    [
      "SEND",
      "/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату"
    ],
    [
      "SEND",
      "/do Страница медицинской карты полностью заполнена."
    ],
    [
      "SEND",
      "/me передаёт медицинскую карту в руки обратившемуся"
    ],
    [
      "SEND",
      "/medcard {arg1} {var2} {var3} {var1}"
    ]
  ],
  "desc": "Оформить медицинскую карту",
  "id_element": 65,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "mc",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ]
}
]],
--> Вылечить от наркозависимости
[4] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "SEND",
      "Очень замечательно, что Вы решили излечиться от укропозависимости."
    ],
    [
      "SEND",
      "Стоимость одного сеанса составит {pricenarko}$"
    ],
    [
      "SEND",
      "Метод лечения современный, называется \"Нейроочищение\". Он полностью сотрёт информацию об укропе с Вашего мозга."
    ],
    [
      "SEND",
      "Вы согласны? Если да, то ложитесь на кушетку и мы приступим."
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/do На столе лежат стерильные перчатки и медицинская маска."
    ],
    [
      "SEND",
      "/me взяв со стола средства индивидуальной защиты, надел{sex[][а]} их на себя"
    ],
    [
      "SEND",
      "/todo А теперь максимально расслабьтесь*подвигая спец. аппарат ближе к пациенту"
    ],
    [
      "SEND",
      "/me взял{sex[][а]} шлем от аппарата, после чего надел{sex[][а]} его на голову пациента"
    ],
    [
      "SEND",
      "/me включил{sex[][а]} устройство, затем, подождав пять секунд, выключил{sex[][а]} его"
    ],
    [
      "SEND",
      "/do Аппарат успешно завершил работу."
    ],
    [
      "SEND",
      "/me снял{sex[][а]} шлем с пациента и повесил{sex[][а]} его обратно на аппарат"
    ],
    [
      "SEND",
      "/healbad {id}"
    ],
    [
      "SEND",
      "/todo Вот и всё! Тяга к запрещённым веществам должна исчезнуть*снимая с себя маску с перчатками"
    ]
  ],
  "desc": "Вылечить от укропозависимости",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 14,
  "cmd": "narko",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Выписать антибиотики
[5] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "SEND",
      "Насколько я понял{sex[][а]}, Вам нужны антибиотики."
    ],
    [
      "SEND",
      "Стоимость одного антибиотика составляет {priceant}$. Вы согласны?"
    ],
    [
      "SEND",
      "Если да, то какое количество Вам необходимо?"
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/me открыв мед.сумку, схватил{sex[][а]} за пачку антибиотиков, после чего вытянул{sex[][а]} их и положил на стол"
    ],
    [
      "SEND",
      "/do Антибиотики находятся на столе. "
    ],
    [
      "SEND",
      "/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку"
    ],
    [
      "SEND",
      "Введите количество антибиотиков в чат."
    ],
    [
      "SEND",
      "/antibiotik {id} "
    ]
  ],
  "desc": "Выписать антибиотики",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 9,
  "cmd": "ant",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": false
}
]],
--> Выганть из больницы
[6] = [[
{
  "folder": 4,
  "id_element": 5,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/me резким движением руки ухватил{sex[ся][ась]} за воротник нарушителя"
    ],
    [
      "SEND",
      "/do Крепко держит нарушителя за воротник."
    ],
    [
      "SEND",
      "/todo Я вынужден{sex[][а]} вывести вас из здания*направляясь к выходу"
    ],
    [
      "SEND",
      "/me движением левой руки открыл{sex[][а]} входную дверь, после чего вытолкнул{sex[][а]} нарушителя"
    ],
    [
      "SEND",
      "/expel {id} {reason}"
    ]
  ],
  "desc": "Выгнать из больницы",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    },
    {
      "desc": "Причина",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": {

  },
  "cmd": "exp",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Поднять при смерти
[7] = [[
{
  "folder": 1,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "/cure {id}"
    ],
    [
      "SEND",
      "/me легким движением руки открыл{sex[][а]} мед. сумку, после чего достал{sex[][а]} платок"
    ],
    [
      "SEND",
      "/me аккуратно приложил{sex[][а]} платок ко рту пострадавшего, после чего сделал{sex[][а]} глубокий вдох"
    ],
    [
      "SEND",
      "/do В лёгких много воздуха."
    ],
    [
      "SEND",
      "/me встал{sex[][а]} на колени, после чего прислонил{sex[ся][ась]} к пациенту"
    ],
    [
      "SEND",
      "/me {sex[подвел][подвела]} губы ко рту пострадавшего, после чего начал{sex[][а]} делать искусственное дыхание"
    ],
    [
      "SEND",
      "/me отвел{sex[][а]} губы от рта пострадавшего, после чего сделал{sex[][а]} глубокий вдох"
    ],
    [
      "SEND",
      "/me подвел{sex[][а]} губы ко рту пострадавшего, после чего начал{sex[][а]} делать искусственное дыхание"
    ],
    [
      "SEND",
      "/todo Сейчас аккуратно поднимайтесь*помогая встать"
    ]
  ],
  "desc": "Поднять человека при смерти",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 9,
  "cmd": "cur",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Оформить мед страховку
[8] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 3,
  "act": [
    [
      "SEND",
      "Очень замечательно, что Вы решили оформить медицинскую страховку."
    ],
    [
      "SEND",
      "С ней Вы сможете лечиться за счёт государства."
    ],
    [
      "SEND",
      "/me достаёт из под стола пустой бланк, после чего начинает его заполнять"
    ],
    [
      "SEND",
      "/me заполнив бланк, передаёт его человеку напротив и говорит:"
    ],
    [
      "SEND",
      "Это бумажная копия, сейчас впишу Вас в базу данных."
    ],
    [
      "SEND",
      "/me вбивает человека напротив в компьютер, находящийся на столе"
    ],
    [
      "SEND",
      "/do Обратившийся внесён в базу данных страхования."
    ],
    [
      "SEND",
      "/todo Поздравляю! Вы официально застрахованы!*заканчивая оформление"
    ],
    [
      "SEND",
      "/givemedinsurance {id}"
    ]
  ],
  "desc": "Оформить медицинскую страховку",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 9,
  "cmd": "strah",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Провести мед обследование для военного билета
[9] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "SEND",
      "Очень замечательно, что Вы решили пройти обследование."
    ],
    [
      "SEND",
      "Ведь с некоторыми заболеваниями служить крайне не рекомендуется!"
    ],
    [
      "SEND",
      "/do На плече висит медицинская сумка."
    ],
    [
      "SEND",
      "/me достаёт необходимые средства из сумки для дальнейшего осмотра пациента"
    ],
    [
      "SEND",
      "/todo Сейчас расслабьтесь, это займёт немного времени*начиная осмотр"
    ],
    [
      "SEND",
      "/mticket {id}"
    ]
  ],
  "desc": "Провести обследование для военного билета",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 6,
  "cmd": "mt",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Провести мед обследование
[10] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "SEND",
      "Очень замечательно, что Вы решили пройти медицинский осмотр."
    ],
    [
      "SEND",
      "Предоставьте мне, пожалуйста, Вашу медицинскую карту."
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/me берёт медицинскую карту в руки и внимательно её изучает"
    ],
    [
      "SEND",
      "Давайте начнём. Снимите всю одежду, кроме нижнего белья."
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/medcheck {id} {priceosm}"
    ],
    [
      "SEND",
      "/me внимательно осматривает пациента на наличие кожных заболеваний"
    ],
    [
      "SEND",
      "/todo Поздравляю! У Вас всё отлично!*заканчивая медицинский осм"
    ],
    [
      "SEND",
      "/do Медицинская карта находится в левой руке."
    ],
    [
      "SEND",
      "/me достав ручку из кармана, {sex[внёс][внесла]} несколько изменений в медицинскую карту"
    ],
    [
      "SEND",
      "/me передал{sex[][а]} медицинскую карту обратно в руки пациенту"
    ],
    [
      "SEND",
      "На этом всё. Всего Вам доброго, не болейте!"
    ]
  ],
  "desc": "Провести медицинский осмотр",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 13,
  "cmd": "osm",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Вылечить охранника
[11] = [[
{
  "folder": 4,
  "id_element": 3,
  "rank": 1,
  "act": [
    [
      "SEND",
      "/do Медицинская сумка весит на левом плече."
    ],
    [
      "SEND",
      "/me открыв сумку, достал{sex[][а]} необходимое лекарство и передал{sex[][а]} охраннику пациента"
    ],
    [
      "SEND",
      "/healactor {id} {pricelec}"
    ]
  ],
  "desc": "Вылечить охранника игрока",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "cmd": "hlactor",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
--> Выписать рецепт
[12] = [[
{
  "folder": 4,
  "id_element": 21,
  "rank": 4,
  "act": [
    [
      "SEND",
      "Мы выписываем рецепты в ограниченном количестве."
    ],
    [
      "SEND",
      "/n Не более 5 штук в минуту."
    ],
    [
      "SEND",
      "Стоимость одного рецепта составляет {pricerecept}$"
    ],
    [
      "SEND",
      "Вы согласны? Если да, то какое количество Вам необходимо?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 рецепт",
        "2 рецепта",
        "3 рецепта",
        "4 рецепта",
        "5 рецептов"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      8],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      10],
    [
      "NEW_VAR",
      "var1",
      "3"
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      12],
    [
      "NEW_VAR",
      "var1",
      "4"
    ],
    [
      "ELSE",
      12],
    [
      "END",
      12],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      14],
    [
      "NEW_VAR",
      "var1",
      "5"
    ],
    [
      "ELSE",
      14],
    [
      "END",
      14],
    [
      "SEND",
      "/do На столе лежат бланки для оформления рецептов."
    ],
    [
      "SEND",
      "/me взяв ручку с печатью, заполнил{sex[][а]} необходимые бланки, после чего поставил{sex[][а]} печати в углу листа"
    ],
    [
      "SEND",
      "/do Все бланки рецептов успешно заполнены."
    ],
    [
      "SEND",
      "/todo Держите и строго соблюдайте инструкцию!*передавая рецепты человеку напротив"
    ],
    [
      "SEND",
      "/recept {arg1} {var1}"
    ]
  ],
  "desc": "Выписать рецепт",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "var": [
    {
      "name": "var1",
      "value": "5"
    }
  ],
  "cmd": "rec",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
 }
]],
--> Лекции для МЗ
[13] = [[
{
  "folder": 6,
  "id_element": 66,
  "rank": 1,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Правила пользов. рацией",
        "ПМП при обмороке",
        "Прав. общ. с гражданами",
        "ОПП при ожогах"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "Приветствую Вас, уважаемые коллеги!"
    ],
    [
      "SEND",
      "Сейчас я проведу лекцию, на тему \"Правила пользования рацией\""
    ],
    [
      "SEND",
      "Для того, чтобы использовать рацию грамотно, следует изучить правила."
    ],
    [
      "SEND",
      "При использовании рации, следует помнить о субординации."
    ],
    [
      "SEND",
      "Ко всем работникам следует относиться с уважением, на \"Вы\""
    ],
    [
      "SEND",
      "Также запрещено использовать нецензурную лексику."
    ],
    [
      "SEND",
      "За подобные нарушения Вы можете получить наказание."
    ],
    [
      "SEND",
      "В рацию запрещается кричать или издавать помехи."
    ],
    [
      "SEND",
      "Лекция на тему \"Правила пользования рацией\" окончена."
    ],
    [
      "SEND",
      "Всем спасибо за внимание."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      13],
    [
      "SEND",
      "Приветствую, коллеги, я прочту вам лекцию на тему \"Первая помощь при обмороке\"."
    ],
    [
      "SEND",
      "Обмороки сопровождаются кратковременной потерей сознания,.."
    ],
    [
      "SEND",
      "вызванная недостаточным снабжением мозга кровью."
    ],
    [
      "SEND",
      "Обморок могут вызвать резкая боль, эмоциональный стресс."
    ],
    [
      "SEND",
      "Бессознательному состоянию обычно предшествует резкое ухудшение самочувствия:"
    ],
    [
      "SEND",
      "нарастает слабость, появляются тошнота, головокружение, шум или звон в ушах."
    ],
    [
      "SEND",
      "Затем человек бледнеет, покрывается холодным потом..."
    ],
    [
      "SEND",
      "и внезапно теряет сознание."
    ],
    [
      "SEND",
      "Первая помощь должна быть направлена на улучшение кровоснабжения мозга..."
    ],
    [
      "SEND",
      "и обеспечение свободного дыхания."
    ],
    [
      "SEND",
      "Если пострадавший находится в душном, плохо проветренном помещении,.."
    ],
    [
      "SEND",
      "откройте окно, включите вентилятор или вынесите потерявшего сознание на воздух."
    ],
    [
      "SEND",
      "Протрите лицо и шею прохладной водой"
    ],
    [
      "SEND",
      "Похлопайте по щекам и если возможно, дайте пострадавшему понюхать ватку,.."
    ],
    [
      "SEND",
      "смоченную нашатырным спиртом."
    ],
    [
      "ELSE",
      13],
    [
      "END",
      13],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      29],
    [
      "SEND",
      "Доброго времени суток, уважаемые сотрудники Больницы!"
    ],
    [
      "SEND",
      "Сегодня я расскажу вам о правилах общения с гражданами."
    ],
    [
      "SEND",
      "Всегда ведите себя вежливо и сдержанно - это ключ к взаимопониманию."
    ],
    [
      "SEND",
      "Показывайте свою воспитанность перед пациентами, и в целом перед незнакомыми людьми."
    ],
    [
      "SEND",
      "Ни в коем случае не стоит оскорблять граждан, ругаться матом, дерзить, хамить, грубить им."
    ],
    [
      "SEND",
      "Это асоциальное поведение, оно не приветствуется в обществе и в нашей клиники."
    ],
    [
      "SEND",
      "За нарушение этих правил вы рискуете быть уволенными или получить выговор!"
    ],
    [
      "SEND",
      "В случае, если гражданин ведёт себя неадекватно по отношению к вам или другим людям,"
    ],
    [
      "SEND",
      "вы в праве вывести из больницы подобного нарушителя."
    ],
    [
      "SEND",
      "На этом у меня всё, благодарю за внимание и, надеюсь, за понимание."
    ],
    [
      "ELSE",
      29],
    [
      "END",
      29],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      40],
    [
      "SEND",
      "Сейчас я проведу для вас лекцию на тему ОПП при Ожогах."
    ],
    [
      "SEND",
      "Если вам удалсь вытащить человека из пожара с высокой степенью ожогов."
    ],
    [
      "SEND",
      "Главное дайте ему воздуха не ложите его туда куда идёт весь дым."
    ],
    [
      "SEND",
      "Нивкоем случае не снимайте с него прилипшую одежду."
    ],
    [
      "SEND",
      "И не лопайте волдыри на теле пострадавшего, как бы это небыло забавно."
    ],
    [
      "SEND",
      "Сразу же вам нужно срочно вызвать скорую помощь."
    ],
    [
      "SEND",
      "И ожидайте приезда специалистов, не пытайтесь сами помочь."
    ],
    [
      "SEND",
      "Из-за боли или надышавшись парами пострадавший будет без сознания"
    ],
    [
      "SEND",
      "А если будет в сознании не реагируйте на его просьбы помочь."
    ],
    [
      "SEND",
      "Просто будьте с ним рядом и морально поддерживайте."
    ],
    [
      "SEND",
      "На этом лекция закончена."
    ],
    [
      "ELSE",
      40],
    [
      "END",
      40],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      52],
    [
      "SEND",
      "Сейчас я проведу для вас лекцию на тему ОПП при Утоплении."
    ],
    [
      "SEND",
      "Если вы заметили что человек тонет, пострайтесь позвать сразу на помощь."
    ],
    [
      "SEND",
      "Или попытайтесь попробовать помочь ему сами."
    ],
    [
      "SEND",
      "Главное не стоит прыгать за пострадавшим в воду если сами не умеете плавать."
    ],
    [
      "SEND",
      "В противном случае спасатель рискует сам оказаться в роли утопающего."
    ],
    [
      "SEND",
      "Лучше всего подплыть к тонущему сзади и обхватить его одной рукой вокруг шеи."
    ],
    [
      "SEND",
      "Так, чтобы лицо смотрело вверх,дыхательные пути были над водой,"
    ],
    [
      "SEND",
      "Можно взяться за волосы, а затем как можно скорее вытащить его на сушу."
    ],
    [
      "SEND",
      "Основные действия будут направлены на то, чтобы согреть его и успокоить."
    ],
    [
      "SEND",
      "Если человек без сознания, нужно удалить воду из дыхательных путей."
    ],
    [
      "SEND",
      "Для этого надавливаем на корень языка, вызывая тем самым рвотный рефлекс."
    ],
    [
      "SEND",
      "Если рвотный рефлекс сохранен это означает,что пострадавший жив."
    ],
    [
      "SEND",
      "Сразу же вам нужно срочно вызвать скорую помощь."
    ],
    [
      "SEND",
      "На этом лекция закончена."
    ],
    [
      "ELSE",
      52],
    [
      "END",
      52]
  ],
  "desc": "Провести лекцию",
  "var": {

  },
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lekmz",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Вылечить себя
[14] = [[
{
  "folder": 4,
  "id_element": 3,
  "rank": 1,
  "act": [
    [
      "SEND",
      "/do Медицинская сумка весит на левом плече."
    ],
    [
      "SEND",
      "/me открыв сумку, достал{sex[][а]} необходимое лекарство и запил его водой"
    ],
    [
      "SEND",
      "/heal {myid} 10000"
    ]
  ],
  "desc": "Вылечить самого себя",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": {
  
  },
  "cmd": "hme",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
}

--> Отыгровки для сотрудников Центра Лицензирования
local cmd_defoult_json_for_driving_school = {
--> Приветствие
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Здравствуйте, меня зовут {mynickrus}, чем могу быть полез{sex[ен][на]}?"
    ]
  ],
  "desc": "Приветствие",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "z",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Лицензия на авто
[2] = [[
{
  "folder": 4,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "rank": 1,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {priceauto1}$, на 2 месяца {priceauto2}$, на 3 месяца {priceauto3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      9],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      9],
    [
      "END",
      9],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      11],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      11],
    [
      "END",
      11],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на авто"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[0][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на вождение автомобиля",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 16,
  "cmd": "licmauto",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на оружие
[3] = [[
{
  "folder": 4,
  "var": [
    {
      "name": "var1",
      "value": "2"
    }
  ],
  "rank": 5,
  "act": [
    [
      "SEND",
      "Для оформления лицензии на оружие, мне нужно убедиться, что Вы здоровы."
    ],
    [
      "SEND",
      "Покажите, пожалуйста, Вашу медицинскую карту."
    ],
    [
      "SEND",
      "/n /showmc {myid}"
    ],
    [
      "DIALOG",
      "1",
      [
        "Здоров",
        "Имеются отклонения",
        "Нет мед. карты"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      5],
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricegun1}$, на 2 месяца {pricegun2}$, на 3 месяца {pricegun3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "2",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "2",
        "1"
      ],
      11],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      11],
    [
      "END",
      11],
    [
      "IF",
      2, [
        "2",
        "2"
      ],
      13],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      13],
    [
      "END",
      13],
    [
      "IF",
      2, [
        "2",
        "3"
      ],
      15],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      15],
    [
      "END",
      15],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на оружие"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[5][{var1}][{arg1}]}"
    ],
    [
      "ELSE",
      5],
    [
      "END",
      5],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      21],
    [
      "SEND",
      "Извините, но я не могу оформить Вам лицензию на оружие в связи с состоянием здоровья."
    ],
    [
      "SEND",
      "Вы можете снова пройти мед. обследование в больнице и вернуться к нам."
    ],
    [
      "ELSE",
      21],
    [
      "END",
      21],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      26],
    [
      "SEND",
      "Извините, но сейчас я не могу оформить Вам лицензию на оружие."
    ],
    [
      "SEND",
      "У Вас отсутствует медицинская карта. Оформить её можно в ближайшей больнице."
    ],
    [
      "ELSE",
      26],
    [
      "END",
      26]
  ],
  "desc": "Продать лицензию на оружие",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 1
    }
  ],
  "delay": 2.5,
  "id_element": 29,
  "cmd": "licgun",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на полёты
[4] = [[
{
  "folder": 4,
  "id_element": 6,
  "rank": 7,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии составляет {pricefly}$. Вы согласны?"
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на полёты"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[2][0][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на полёты",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "cmd": "licfly",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на рыбу
[5] = [[
{
  "folder": 4,
  "id_element": 15,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии"
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricefish1}$, на 2 месяца {pricefish2}$, на 3 месяца {pricefish3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      7],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      7],
    [
      "END",
      7],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      9],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      9],
    [
      "END",
      9],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      11],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      11],
    [
      "END",
      11],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на рыболовство"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[3][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на рыболовство",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 1
    }
  ],
  "cmd": "licfish",
  "key": [
    "",
    {

    }
  ],
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ]
}
]],
--> Лицензия на мотоцикл
[6] = [[
{
  "folder": 4,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "rank": 2,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricemoto1}$, на 2 месяца {pricemoto2}$, на 3 месяца {pricemoto3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      8],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      10],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на мото"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[1][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на вождение мотоцикла",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 14,
  "cmd": "licmoto",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на механика
[7] = [[
{
  "folder": 4,
  "id_element": 14,
  "rank": 6,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricemeh1}$, на 2 месяца {pricemeh2}$, на 3 месяца {pricemeh3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      8],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      10],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на механика"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[9][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию для работы на механика",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "cmd": "licmec",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на такси
[8] = [[
{
  "folder": 4,
  "id_element": 15,
  "rank": 6,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricetaxi1}$, на 2 месяца {pricetaxi2}$, на 3 месяца {pricetaxi3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      9],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      9],
    [
      "END",
      9],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      11],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      11],
    [
      "END",
      11],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на такси"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[8][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию для работы в такси",
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lictaxi",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 1
    }
  ]
}
]],
--> Лицензия на плавание
[9] = [[
{
  "folder": 4,
  "id_element": 14,
  "rank": 4,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {priceswim1}$, на 2 месяца {priceswim2}$, на 3 месяца {priceswim3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      8],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      10],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на вод. транспорт"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[4][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на водный транспорт",
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "licswim",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ]
}
]],
--> Лицензия на охоту
[10] = [[
{
  "folder": 4,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "rank": 5,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии "
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {pricehunt1}$, на 2 месяца {pricehunt2}$, на 3 месяца {pricehunt3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      6],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      8],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      8],
    [
      "END",
      8],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      10],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на охоту"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[6][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на охоту",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 14,
  "cmd": "lichunt",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лицензия на раскопки
[11] = [[
{
  "folder": 4,
  "id_element": 15,
  "rank": 6,
  "act": [
    [
      "SEND",
      "/me достал{sex[][а]} из под стола пустой бланк для выдачи лицензии"
    ],
    [
      "SEND",
      "Стоимость лицензии зависит от её срока."
    ],
    [
      "SEND",
      "На 1 месяц {priceexc1}$, на 2 месяца {priceexc2}$, на 3 месяца {priceexc3}$"
    ],
    [
      "SEND",
      "На какой срок оформляем?"
    ],
    [
      "DIALOG",
      "1",
      [
        "1 месяц",
        "2 месяца",
        "3 месяца"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      7],
    [
      "NEW_VAR",
      "var1",
      "0"
    ],
    [
      "ELSE",
      7],
    [
      "END",
      7],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      9],
    [
      "NEW_VAR",
      "var1",
      "1"
    ],
    [
      "ELSE",
      9],
    [
      "END",
      9],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      11],
    [
      "NEW_VAR",
      "var1",
      "2"
    ],
    [
      "ELSE",
      11],
    [
      "END",
      11],
    [
      "SEND",
      "/me засунул{sex[][а]} бланк в принтер, после чего распечатал{sex[][а]} лицензию на раскопки"
    ],
    [
      "SEND",
      "/todo Вот, распишитесь здесь*протягивая лицензию человеку напротив"
    ],
    [
      "SEND",
      "{dialoglic[7][{var1}][{arg1}]}"
    ]
  ],
  "desc": "Продать лицензию на раскопки",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "var": [
    {
      "name": "var1",
      "value": "0"
    }
  ],
  "cmd": "licdig",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Выганть из помещения
[12] = [[
{
  "folder": 4,
  "id_element": 5,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/me резким движением руки ухватил{sex[ся][ась]} за воротник нарушителя"
    ],
    [
      "SEND",
      "/do Крепко держит нарушителя за воротник."
    ],
    [
      "SEND",
      "/todo Я вынужден{sex[][а]} вывести вас из здания*направляясь к выходу"
    ],
    [
      "SEND",
      "/me движением левой руки открыл{sex[][а]} входную дверь, после чего вытолкнул{sex[][а]} нарушителя"
    ],
    [
      "SEND",
      "/expel {id} {reason}"
    ]
  ],
  "desc": "Выгнать из помещения",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    },
    {
      "desc": "Причина",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": {

  },
  "cmd": "exp",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Прайс лист
[13] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Сейчас я представлю вам прайс-лист лицензий."
    ],
    [
      "SEND",
      "/me потянулся в карман, затем достал заламинированный лист"
    ],
    [
      "SEND",
      "/do Прайс-Лист в руке."
    ],
    [
      "SEND",
      "Водительские права 1 месяц {priceauto1}$, 2 месяца {priceauto2}$, 3 месяца {priceauto3}$"
    ],
    [
      "SEND",
      "Права на мото-транспорт 1 месяц {pricemoto1}$, 2 месяца {pricemoto2}$, 3 месяца {pricemoto3}$"
    ],
    [
      "SEND",
      "Права на водный транспорт 1 месяц {priceswim1}$, 2 месяца {priceswim2}$, 3 месяца {priceswim3}$"
    ],
    [
      "SEND",
      "Лицензия на рыбалку 1 месяц {pricefish1}$, 2 месяца {pricefish2}$, 3 месяца {pricefish3}$"
    ],
    [
      "SEND",
      "Лицензия на владение оружием 1 месяц {pricegun1}$, 2 месяца {pricegun2}$, 3 месяца {pricegun3}$"
    ],
    [
      "SEND",
      "Лицензия на охоту 1 месяц {pricehunt1}$, 2 месяца {pricehunt2}$, 3 месяца {pricehunt3}$"
    ],
    [
      "SEND",
      "Лицензия на раскопки 1 месяц {priceexc1}$, 2 месяца {priceexc2}$, 3 месяца {priceexc3}$"
    ],
    [
      "SEND",
      "Лицензия на работу в такси 1 месяц {pricetaxi1}$, 2 месяца {pricetaxi2}$, 3 месяца {pricetaxi3}$"
    ],
    [
      "SEND",
      "Лицензия на работу механика 1 месяц {pricemeh1}$, 2 месяца {pricemeh2}$, 3 месяца {pricemeh3}$"
    ],
    [
      "SEND",
      "Лицензия на воздушный транспорт 1 месяц {pricefly}$"
    ],
    [
      "SEND",
      "/todo Если у вас нет вопросов, то я приступаю к оформлению*убирая лист в карман"
    ]
  ],
  "desc": "Прайс-лист лицензий",
  "arg": {

  },
  "delay": 2.5,
  "id_element": 15,
  "cmd": "price",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лекции для ЦЛ
[14] = [[
{
  "folder": 6,
  "id_element": 77,
  "rank": 3,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Служебный транспорт",
        "Субординация",
        "ПДД",
        "Запреты в рацию",
        "Основные правила"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "Приветствую Вас на лекции об уходе за служебным транспортом."
    ],
    [
      "SEND",
      "И сегодня я расскажу, что надо делать, чтобы наш транспорт не ломался."
    ],
    [
      "SEND",
      "Каждый сотрудник, когда берет служебный автомобиль под свое использование..."
    ],
    [
      "SEND",
      "должен следить за уровнем бензина в баке."
    ],
    [
      "SEND",
      "Если бак становится пустым, он должен заправлять авто..."
    ],
    [
      "SEND",
      "Либо же сообщить об этом водителям."
    ],
    [
      "SEND",
      "Сев за руль надо быть очень аккуратным..."
    ],
    [
      "SEND",
      "Ведь в данном случае может не только..."
    ],
    [
      "SEND",
      "Сломаться транспорт, может пострадать и сам сотрудник."
    ],
    [
      "SEND",
      "При случае повреждений автомобиля, надо отвезти его в автомастерскую."
    ],
    [
      "SEND",
      "Если выполнять эти простые правила, то с автомобилем будет все хорошо."
    ],
    [
      "SEND",
      "Спасибо за прослушивание лекции."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      15],
    [
      "SEND",
      "Всех приветствую, сейчас я расскажу вам о субординации."
    ],
    [
      "SEND",
      "Субординация - дисциплина, система служебных отношений, связанных с подчинением одних руководителей..."
    ],
    [
      "SEND",
      "... вместе с их подразделениями, руководителям более высоких уровней."
    ],
    [
      "SEND",
      "Субординация предусматривает уважительные отношения между начальником и подчинённым."
    ],
    [
      "SEND",
      "Об исполнении поручения подчиненные обязаны докладывать в устной, письменной или ..."
    ],
    [
      "SEND",
      "... иной материальной форме, которая удовлетворит начальника."
    ],
    [
      "SEND",
      "Вы должны обращаться к сотрудникам только на «Вы»."
    ],
    [
      "SEND",
      "Вы должны уважать сотрудников вашей организации."
    ],
    [
      "SEND",
      "При оскорблении сотрудников вашей или чужой организации вы можете понести за это наказание."
    ],
    [
      "SEND",
      "Перечить старшим по должности категорически запрещено."
    ],
    [
      "SEND",
      "Лекция окончена, благодарю за внимание."
    ],
    [
      "ELSE",
      15],
    [
      "END",
      15],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      33],
    [
      "SEND",
      "Приветствую, уважаемые слушатели лекции о Правилах Дорожного Движения."
    ],
    [
      "SEND",
      "Сейчас я расскажу вам основные правила, которые обязан знать водитель перед..."
    ],
    [
      "SEND",
      "...и во время управления транспортным средством."
    ],
    [
      "SEND",
      "Для вождения вам необходимо иметь водительские права."
    ],
    [
      "SEND",
      "Перед использованием необходимо убедиться в исправности автомобиля."
    ],
    [
      "SEND",
      "Вы не должны находиться в алкогольном опьянении во время вождения."
    ],
    [
      "SEND",
      "Это может привести к дорожно-транспортному происшествию, в лучшем же случае..."
    ],
    [
      "SEND",
      "...вы получите штраф от офицеров полиции."
    ],
    [
      "SEND",
      "Также автомобиль должен быть застрахован на повреждения."
    ],
    [
      "SEND",
      "Оформить страховку возможно в Страховой Компании."
    ],
    [
      "SEND",
      "Если у вас плохое зрение - носите очки или линзы."
    ],
    [
      "SEND",
      "Вы обязательно должны видеть дорогу!"
    ],
    [
      "SEND",
      "Во время вождения каждый обязан соблюдать установленные правила дорожного движения."
    ],
    [
      "SEND",
      "Двигаться нужно только по правой стороне дороги."
    ],
    [
      "SEND",
      "Совершить обгон можно, только если..."
    ],
    [
      "SEND",
      "...вы едете по двухполосной дороге с прерывистой разметкой на осевой линии."
    ],
    [
      "SEND",
      "Вы должны внимательно следить за дорогой, останавливаться на светофорах и..."
    ],
    [
      "SEND",
      "...пропускать пешеходов."
    ],
    [
      "SEND",
      "Движение по обочине и тротуару строго запрещено и наказывается штрафом."
    ],
    [
      "SEND",
      "Соблюдайте эти правила! Любое нарушение может привести к несчастному случаю."
    ],
    [
      "SEND",
      "Все мы хотим вернуться домой живыми и здоровыми, поэтому будьте внимательны."
    ],
    [
      "SEND",
      "Лекция окончена, всех благодарю за уделённое внимание."
    ],
    [
      "ELSE",
      33],
    [
      "END",
      33],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      56],
    [
      "SEND",
      "Приветствую, коллеги, сейчас я расскажу вам о правилах общения по нашей рации."
    ],
    [
      "SEND",
      "Сотрудникам запрещено кричать, создавать помехи в рацию."
    ],
    [
      "SEND",
      "Сотрудникам запрещено использовать нецензурную лексику при общении по рации."
    ],
    [
      "SEND",
      "Сотрудникам не дозволено разводить конфликты, розни и споры по рации."
    ],
    [
      "SEND",
      "Сотрудникам запрещено оскорблять коллег по работе."
    ],
    [
      "SEND",
      "Сотрудникам запрещено заниматься купле-продажей по рации организации."
    ],
    [
      "SEND",
      "Сотрудникам запрещено выключать рацию и игнорировать руководство."
    ],
    [
      "SEND",
      "ация предназначена для связи с руководством и остальными коллегами по работе."
    ],
    [
      "SEND",
      "В рацию сообщаются доклады с постов."
    ],
    [
      "SEND",
      "За нарушение этих правил вы можете получить выговор или увольнение."
    ],
    [
      "SEND",
      "Лекция окончена, спасибо за внимание."
    ],
    [
      "ELSE",
      56],
    [
      "END",
      56],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      68],
    [
      "SEND",
      "Cейчас я проведу лекцию на тему 'Основные правила центра лицензирования'."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено прогуливать рабочий день."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено в рабочее время посещать мероприятия."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено в рабочее время посещать казино."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено в рабочее время посещать любые подработки."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено носить при себе огнестрельное оружие."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено курить в здании центра лицензирования."
    ],
    [
      "SEND",
      "Сотрудникам центра лицензирования запрещено употреблять алкогольные напитки в рабочее время."
    ],
    [
      "SEND",
      "На этом у меня всё, спасибо за внимание."
    ],
    [
      "ELSE",
      68],
    [
      "END",
      68]
  ],
  "desc": "Провести лекцию",
  "arg": {

  },
  "delay": 2.5,
  "var": {

  },
  "cmd": "lekcl",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]]
}

--> Отыгровки для сотрудников Правительства
local cmd_defoult_json_for_government = {
--> Приветствие
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Здравствуйте, меня зовут {mynickrus}, чем могу быть полез{sex[ен][на]}?"
    ]
  ],
  "desc": "Приветствие",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "z",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Изменить дату рождения
[2] = [[
{
  "folder": 4,
  "id_element": 4,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/do Бланк для замены информации в паспорте находится под столом."
    ],
    [
      "SEND",
      "/me засунув руку под стол, взял{sex[][а]} бланк, после чего протянул{sex[][а]} его человеку напротив"
    ],
    [
      "SEND",
      "/todo Впишите сюда новую дату и поставьте подпись снизу*протягивая лист с ручкой"
    ],
    [
      "SEND",
      "{dialoggov[0][{arg1}]}"
    ]
  ],
  "desc": "Изменить дату рождения в паспорте",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "cmd": "pass",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
--> Выдать визу для Вайс Сити
[3] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 3,
  "act": [
    [
      "SEND",
      "Стоимость услуги составляет 500.000$. Вы согласны? Если да, то мы продолжим."
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/do Бланк для оформления визы находится под столом."
    ],
    [
      "SEND",
      "/me засунув руку под стол, взял{sex[][а]} бланк, после чего протянул{sex[][а]} его человеку напротив"
    ],
    [
      "SEND",
      "/todo Впишите сюда ваши данные и поставьте подпись снизу*протягивая лист с ручкой"
    ],
    [
      "SEND",
      "{dialoggov[1][{arg1}]}"
    ]
  ],
  "desc": "Оформить визу для перелётов в Vice City",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 6,
  "cmd": "visa",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Превратить тс в сертификат
[4] = [[
{
  "folder": 4,
  "id_element": 4,
  "rank": 5,
  "act": [
    [
      "SEND",
      "/do Бланк для получения сертификата находится под столом."
    ],
    [
      "SEND",
      "/me засунув руку под стол, взял{sex[][а]} бланк, после чего протянул{sex[][а]} его человеку напротив"
    ],
    [
      "SEND",
      "/todo Впишите сюда ваши данные и поставьте подпись снизу*протягивая лист с ручкой"
    ],
    [
      "SEND",
      "{dialoggov[2][{arg1}]}"
    ]
  ],
  "desc": "Превратить личное т/с в сертификат",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "cmd": "car",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
--> Показать визитку адвоката
[5] = [[
{
  "folder": 4,
  "id_element": 3,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/me вытащил{sex[][а]} из нагрудного кармана визитку адвоката"
    ],
    [
      "SEND",
      "/do На визитке написано: {mynickrus}, адвокат штата."
    ],
    [
      "SEND",
      "/showvisit {arg1}"
    ]
  ],
  "desc": "Показать визитку адвоката",
  "send_end_mes": true,
  "delay": 2.5,
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ],
  "cmd": "visit",
  "key": [
    "",
    {

    }
  ],
  "var": {

  }
}
]],
--> Предложить услуги адвоката
[6] = [[
{
  "folder": 4,
  "id_element": 5,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/do Папка с документами находится в левой руке."
    ],
    [
      "SEND",
      "/me открыв папку, вытащил{sex[][а]} из неё бланк для освобождения заключённого"
    ],
    [
      "SEND",
      "/me достав из кармана ручку, заполнил{sex[][а]} документ и передал{sex[][а]} человеку напротив"
    ],
    [
      "SEND",
      "/todo Впишите сюда свои данные и поставьте подпись снизу*передавая лист с ручкой"
    ],
    [
      "SEND",
      "/free {arg1} {arg2}"
    ]
  ],
  "desc": "Предложить услуги адвоката",
  "var": {

  },
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "freely",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    },
    {
      "desc": "Цена",
      "name": "arg2",
      "type": 2
    }
  ]
}
]],
--> Выдать лицензию адвоката
[7] = [[
{
  "folder": 4,
  "id_element": 4,
  "rank": 9,
  "act": [
    [
      "SEND",
      "/do Бланк для выдачи лицензии находится под столом."
    ],
    [
      "SEND",
      "/me засунув руку под стол, взял{sex[][а]} бланк, после чего заполнил{sex[][а]} его нужной информацией"
    ],
    [
      "SEND",
      "/todo Впишите сюда Ваши данные и поставьте подпись снизу*передавая бланк и ручку"
    ],
    [
      "SEND",
      "/givelicadvokat {arg1}"
    ]
  ],
  "desc": "Выдать лицензию адвоката",
  "var": {

  },
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lic",
  "key": [
    "",
    {

    }
  ],
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    }
  ]
}
]],
--> Заключить брак
[8] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 6,
  "act": [
    [
      "SEND",
      "Приветствую, уважаемые новобрачные и гости!"
    ],
    [
      "SEND",
      "Уважаемые невеста и жених!"
    ],
    [
      "SEND",
      "Сегодня - самое прекрасное и незабываемое событие в вашей жизни."
    ],
    [
      "SEND",
      "С этого дня вы пойдёте по жизни рука об руку, вместе переживая и радость счастливых дней, и огорчения."
    ],
    [
      "SEND",
      "Создавая семью, вы добровольно приняли на себя великий долг друг перед другом и перед будущим ваших детей."
    ],
    [
      "SEND",
      "С вашего взаимного согласия, выраженного в присутствии свидетелей, ваш брак регистрируется."
    ],
    [
      "SEND",
      "Прошу вас в знак любви и преданности друг другу обменяться обручальными кольцами."
    ],
    [
      "SEND",
      "Прошу вас в знак любви и преданности друг другу обменяться обручальными кольцами."
    ],
    [
      "SEND",
      "/wedding {arg1} {arg2}"
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "Совет вам да любовь! Можете поцеловаться!"
    ]
  ],
  "desc": "Заключить брак",
  "arg": [
    {
      "desc": "id жениха",
      "name": "arg1",
      "type": 2
    },
    {
      "desc": "id невесты",
      "name": "arg2",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 11,
  "cmd": "wed",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Уволить госслужащего
[9] = [[
{
  "folder": 4,
  "id_element": 4,
  "rank": 9,
  "act": [
    [
      "SEND",
      "/do В левом кармане лежит телефон."
    ],
    [
      "SEND",
      "/me достал{sex[][а]} телефон из кармана, после чего {sex[зашёл][зашла]} в базу данных организации"
    ],
    [
      "SEND",
      "/me изменил{sex[][а]} информацию о сотруднике государственной структуры"
    ],
    [
      "SEND",
      "/demoute {arg1} {arg2}"
    ]
  ],
  "desc": "Уволить госслужащего",
  "arg": [
    {
      "desc": "id игрока",
      "name": "arg1",
      "type": 2
    },
    {
      "desc": "Причина увольнения",
      "name": "arg2",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": {

  },
  "cmd": "uvalgos",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Выганть из помещения
[10] = [[
{
  "folder": 4,
  "id_element": 5,
  "rank": 3,
  "act": [
    [
      "SEND",
      "/me резким движением руки ухватил{sex[ся][ась]} за воротник нарушителя"
    ],
    [
      "SEND",
      "/do Крепко держит нарушителя за воротник."
    ],
    [
      "SEND",
      "/todo Я вынужден{sex[][а]} вывести вас из здания*направляясь к выходу"
    ],
    [
      "SEND",
      "/me движением левой руки открыл{sex[][а]} входную дверь, после чего вытолкнул{sex[][а]} нарушителя"
    ],
    [
      "SEND",
      "/expel {id} {reason}"
    ]
  ],
  "desc": "Выгнать из помещения",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    },
    {
      "desc": "Причина",
      "name": "reason",
      "type": 1
    }
  ],
  "delay": 2.5,
  "var": {

  },
  "cmd": "exp",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лекции
[11] = [[
{
  "folder": 6,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Отъезд по личным делам",
        "Субординация",
        "Знание Устава",
        "О служебном Т/С",
        "О применении оружия",
        "Дресс-Код"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "Уважаемые сотрудники правительства, минуточку внимания."
    ],
    [
      "SEND",
      "Если вы хотите отлучится по личных делам, например покушать..."
    ],
    [
      "SEND",
      "или уехать в больницу, то нужно спросить разрешения у Старшего состава."
    ],
    [
      "SEND",
      "Также напоминаю, что рабочий транспорт брать в личных целях крайне запрещено."
    ],
    [
      "SEND",
      "За неподчинение старшим по должности, вы будете уволены."
    ],
    [
      "SEND",
      "Так-же за противозаконные действия подлежит выговор вплоть до увольнения."
    ],
    [
      "SEND",
      "Спасибо за внимание."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      10],
    [
      "SEND",
      "Приветствую вас на лекции о субординации."
    ],
    [
      "SEND",
      "Для начала расскажу, что такое субординация."
    ],
    [
      "SEND",
      "Субординация - правила подчинения младших по званию к старшим по званию уважение, отношение к ним."
    ],
    [
      "SEND",
      "То есть младшие сотрудники должны выполнять приказы начальства."
    ],
    [
      "SEND",
      "Кто ослушается - получит выговор, сперва устный."
    ],
    [
      "SEND",
      "Вы должны с уважением относится к начальству на \"Вы\"."
    ],
    [
      "SEND",
      "Не нарушайте правила и не нарушайте субординацию дабы не получить наказание."
    ],
    [
      "SEND",
      "Спасибо за внимание, лекция окончена."
    ],
    [
      "ELSE",
      10],
    [
      "END",
      10],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      19],
    [
      "SEND",
      "Сейчас я проведу лекцию на тему \"Знание устава\"."
    ],
    [
      "SEND",
      "Если вы хотите отлучится по личных делам, например покушать..."
    ],
    [
      "SEND",
      "В ваши обязанности входит знание устава, иначе не знание устава не освобождает от ответственности."
    ],
    [
      "SEND",
      "В случае незнания устава вы получите выговор, а затем вовсе можете вылететь с работы."
    ],
    [
      "SEND",
      "Запомните: Не знание Устава не освобождает вас от ответственности."
    ],
    [
      "ELSE",
      19],
    [
      "END",
      19],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      27],
    [
      "SEND",
      "Приветствую Вас на лекции об уходе за служебным транспортом."
    ],
    [
      "SEND",
      "И сегодня я расскажу, что надо делать, чтобы наш транспорт не ломался."
    ],
    [
      "SEND",
      "Каждый сотрудник, когда берет служебный автомобиль под свое использование..."
    ],
    [
      "SEND",
      "...должен следить за уровнем бензина в баке."
    ],
    [
      "SEND",
      "Если бак становится пустым, он должен заправлять авто, либо же сообщить об этом водителям."
    ],
    [
      "SEND",
      "Сев за руль надо быть очень аккуратным, ведь в данном случае может не только..."
    ],
    [
      "SEND",
      "...сломаться транспорт, может пострадать и сам сотрудник."
    ],
    [
      "SEND",
      "При случае повреждений автомобиля, надо отвезти его в автомастерскую."
    ],
    [
      "SEND",
      "Если выполнять эти простые правила, то с автомобилем будет все хорошо."
    ],
    [
      "SEND",
      "Спасибо за прослушивание лекции. Все свободны."
    ],
    [
      "ELSE",
      27],
    [
      "END",
      27],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      38],
    [
      "SEND",
      "Приветствую вас на лекции о применении оружия."
    ],
    [
      "SEND",
      "Сегодня я расскажу о правилах использования табельного оружия."
    ],
    [
      "SEND",
      "Начну с того, что табельное оружие - это желательная часть экипировки сотрудника охраны."
    ],
    [
      "SEND",
      "Надо запомнить, что с табельным оружием надо обращаться с огромной осторожностью."
    ],
    [
      "SEND",
      "Использовать его, если вам, вашему, коллеге или же гражданину штата угрожает опасность."
    ],
    [
      "SEND",
      "Надо стараться не использовать оружие в людных местах если даже есть крайняя нужда."
    ],
    [
      "SEND",
      "Ведь из-за это могут пострадать невинные люди."
    ],
    [
      "SEND",
      "Важно то, что правильное использование оружия может спасти кому-то жизнь."
    ],
    [
      "SEND",
      "Поэтому табельное оружие всегда должно быть исправно."
    ],
    [
      "SEND",
      "Если оружие повредилось, надо заменить его."
    ],
    [
      "SEND",
      "Надеюсь, вы все усвоили, спасибо за прослушивание лекции."
    ],
    [
      "ELSE",
      38],
    [
      "END",
      38],
    [
      "IF",
      2, [
        "1",
        "6"
      ],
      50],
    [
      "SEND",
      "Доброго времени суток, уважаемые сотрудники."
    ],
    [
      "SEND",
      "Сегодня я проведу для вас лекцию на тему \"Дресс-Код\"."
    ],
    [
      "SEND",
      "Дресс-код - это ваша рабочая форма ,требуемая уставом Правительства для ношения..."
    ],
    [
      "SEND",
      "...во время исполнения ваших служебных обязанностей. Помните, что запрещено..."
    ],
    [
      "SEND",
      "...исполнение службы не находясь в рабочей форме."
    ],
    [
      "SEND",
      "Каждый сотрудник должен опрятно выглядеть."
    ],
    [
      "SEND",
      "Если сотрудник будет носить запрещенные аксессуары, то ему будет устное предупреждение.После - выговор!"
    ],
    [
      "SEND",
      "На этом лекция окончена."
    ],
    [
      "ELSE",
      50],
    [
      "END",
      50]
  ],
  "desc": "Провести лекцию",
  "id_element": 58,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lekgov",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]]
}

--> Отыгровки для служащих в Армии
local cmd_defoult_json_for_army = {
--> Выдать повестку
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 5,
  "act": [
    [
      "SEND",
      "Здравствуйте, я {myrank} {mynickrus}."
    ],
    [
      "SEND",
      "Покажите пожалуйста Ваш паспорт."
    ],
    [
      "WAIT_ENTER"
    ],
    [
      "SEND",
      "/me взял{sex[][а]} документ с рук человека напротив, внимательно его изучил{sex[][а]}, после чего вернул{sex[][а]} обратно"
    ],
    [
      "SEND",
      "/do В папке с документами лежит пустой бланк с надписью \"Повестка\"."
    ],
    [
      "SEND",
      "/me взял{sex[][а]} в руку бланк с ручкой и движением руки начал{sex[][а]} заполнять бланк"
    ],
    [
      "SEND",
      "/do Готовый бланк в руке."
    ],
    [
      "SEND",
      "/me убрал{sex[][а]} ручку в карман, поставил{sex[][а]} свою подпись на бланк"
    ],
    [
      "SEND",
      "/todo Так-с, это вам. Ждем вас в военкомате!*протягивая бланк человеку напротив"
    ],
    [
      "SEND",
      "/agenda {id}"
    ]
  ],
  "desc": "Выдать повестку",
  "arg": [
    {
      "desc": "id игрока",
      "name": "id",
      "type": 2
    }
  ],
  "delay": 2.5,
  "id_element": 10,
  "cmd": "agenda",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]],
--> Лекции
[2] = [[
{
  "folder": 6,
  "id_element": 69,
  "rank": 4,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Субординация",
        "Построение",
        "Строевая подготовка",
        "Поведение на КПП",
        "Правила на тренировке"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "/s Здравия желаю, уважаемые бойцы!"
    ],
    [
      "SEND",
      "Сейчас я зачитаю Вам лекцию на тему \"Субординация\""
    ],
    [
      "SEND",
      "Запомните одно. Каждый военнослужащий должен..."
    ],
    [
      "SEND",
      "...выполнять и исполнять приказы старших по званию"
    ],
    [
      "SEND",
      "За невыполнение приказа, который не противоречит законам и уставу..."
    ],
    [
      "SEND",
      "Военнослужащий получает выговор."
    ],
    [
      "SEND",
      "Обращаться военнослужащие друг к другу должны следующим образом:"
    ],
    [
      "SEND",
      "Звание и Фамилия к кому обращаетесь или же уважаемый звание..."
    ],
    [
      "SEND",
      "...того, к кому обращаетесь."
    ],
    [
      "SEND",
      "Ну, а на этом лекция на тему \"Субординация\" окончена."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      13],
    [
      "SEND",
      "/s Сейчас я зачитаю вам лекцию на тему \"Построение\""
    ],
    [
      "SEND",
      "Когда объявили всеобщее построение вы обязаны бросить все свои дела и явиться в строй."
    ],
    [
      "SEND",
      "При опоздании извинится со словами \"Виноват, разрешите встать в строй”\"..."
    ],
    [
      "SEND",
      "...и встать в конец строя."
    ],
    [
      "SEND",
      "В строю запрещено: спать, разговаривать, использовать рацию"
    ],
    [
      "SEND",
      "Выражать эмоции, стрелять и покидать строй без разрешения"
    ],
    [
      "SEND",
      "Во время строя бойцы, офицеры должны выполнять все приказы, которые им отдаёт командир"
    ],
    [
      "SEND",
      "Если вы заметили нарушителя во время пребывания в строю, огонь без приказа не открывать"
    ],
    [
      "SEND",
      "Лекция на тему \"Построение\" окончена. Спасибо за внимание"
    ],
    [
      "ELSE",
      13],
    [
      "END",
      13],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      24],
    [
      "SEND",
      "/s Здравия желаю, уважаемые бойцы!"
    ],
    [
      "SEND",
      "Сейчас я вам проведу лекцию на тему \"Строевая подготовка\""
    ],
    [
      "SEND",
      "Для начала все бойцы должны построиться в ровную шеренгу"
    ],
    [
      "SEND",
      "Самая первая команда: \"Равняйсь!\""
    ],
    [
      "SEND",
      "После такой команды все, кроме первого, должны повернуть голову на направляющего"
    ],
    [
      "SEND",
      "Следующая команда: \"Смирно!\""
    ],
    [
      "SEND",
      "Вы поворачиваете голову в исходное положение и неподвижно стоите"
    ],
    [
      "SEND",
      "Команда \"Вольно!\" дает возможность задать вопросы командиру"
    ],
    [
      "SEND",
      "После этого командир на усмотрение произносит такие команды, как:"
    ],
    [
      "SEND",
      "\"Налево!\", \"Направо!\", \"Кругом!\", \"Шагом марш!\", и тому прочее"
    ],
    [
      "SEND",
      "Самое главное - это слушать приказы командира"
    ],
    [
      "SEND",
      "Лекция на тему \"Строевая подготовка\" окончена!"
    ],
    [
      "ELSE",
      24],
    [
      "END",
      24],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      38],
    [
      "SEND",
      "/s Здравия желаю, уважаемые бойцы!"
    ],
    [
      "SEND",
      "Сейчас я проведу лекцию на тему \"Поведение и общение с гражданскими на КПП\""
    ],
    [
      "SEND",
      "Сейчас я расскажу вам как вести себя на посту КПП с гражданскими"
    ],
    [
      "SEND",
      "Сначала нужно поприветствовать и спросить цель прибытия у гостя"
    ],
    [
      "SEND",
      "При этом вы должны убрать оружие, не нужно пугать или проявлять агрессию"
    ],
    [
      "SEND",
      "Выполняйте все просьбы гражданина, если они не противоречат уставу МО"
    ],
    [
      "SEND",
      "Старайтесь избежать конфликтов, если таковые могут возникнуть"
    ],
    [
      "SEND",
      "Но если все-таки гражданин начал хамить, кричать и драться, то:"
    ],
    [
      "SEND",
      "Просите гостя отъехать или отойти на 30 метров от КПП"
    ],
    [
      "SEND",
      "В случае неповиновения разрешено применить силу, досчитав до десяти"
    ],
    [
      "SEND",
      "Не нужно начинать диалог с гражданами, находящимся дальше 20 метров от КПП"
    ],
    [
      "SEND",
      "Запрещено стрелять, кричать и бить людей без причины"
    ],
    [
      "SEND",
      "За это вы можете получить выговор, или даже вас уволят"
    ],
    [
      "SEND",
      "Надеюсь все поняли главные принципы общения на КПП"
    ],
    [
      "SEND",
      "Лекция на тему \"Поведение и общение с гражданскими на КПП\" окончена!"
    ],
    [
      "ELSE",
      38],
    [
      "END",
      38],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      54],
    [
      "SEND",
      "Уважаемые военнослужащие, сейчас я проведу вам лекцию на тему..."
    ],
    [
      "SEND",
      "...\"Правила поведения на тренировке\"."
    ],
    [
      "SEND",
      "С самого начала я расскажу, что такое тренировка."
    ],
    [
      "SEND",
      "Тренировка - это осмысленная физическая деятельность, направленная на развитие..."
    ],
    [
      "SEND",
      "...силы - выносливости, ловкости, техничности и так далее."
    ],
    [
      "SEND",
      "Правила поведение на тренировке..."
    ],
    [
      "SEND",
      "Первое - слушаться старших по званию."
    ],
    [
      "SEND",
      "Второе - доставать оружие только по приказу."
    ],
    [
      "SEND",
      "Третье - не покидать место сбора. Исключение: По приказу."
    ],
    [
      "SEND",
      "Четвертое - в строю молчать, слушать, что говорят ваши коллеги ..."
    ],
    [
      "SEND",
      "...разговорами вы отвлекаете и сбиваете с мысли проводящего."
    ],
    [
      "SEND",
      "Пятое - слушаться только офицеров."
    ],
    [
      "SEND",
      "Лекция на тему \"Правила поведения на тренировке\" окончена. "
    ],
    [
      "ELSE",
      54],
    [
      "END",
      54]
  ],
  "desc": "Провести лекцию",
  "var": {

  },
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lekarmy",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]]
}

--> Отыгровки для сотрудников пожарного департмамента
local cmd_defoult_json_for_fire_department = {
--> Приветствие
[1] = [[
{
  "folder": 4,
  "var": {

  },
  "rank": 1,
  "act": [
    [
      "SEND",
      "Здравствуйте, меня зовут {mynickrus}, чем могу быть полез{sex[ен][на]}?"
    ]
  ],
  "desc": "Приветствие",
  "id_element": 1,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "z",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
[2] = [[
{
  "folder": 6,
  "id_element": 72,
  "rank": 3,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Огнетушители",
        "Сигнализация",
        "Субординация",
        "Правила рации",
        "Искуственное дыхание"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "Доброго времени суток, уважаемые коллеги."
    ],
    [
      "SEND",
      "Сейчас я проведу вам лекцию на тему \"Правила пользования огнетушителем\"."
    ],
    [
      "SEND",
      "Огнетушители бывают нескольких видов: Углекислотные, Пенные, Порошковые, Водные."
    ],
    [
      "SEND",
      "Углекислотные огнетушители применяются для тушения возгораний различных веществ и материалов."
    ],
    [
      "SEND",
      "Пенные огнетушители предназначены для тушения пожаров твёрдых, жидких горючих веществ..."
    ],
    [
      "SEND",
      "...в общественных зданиях и производственных объектах."
    ],
    [
      "SEND",
      "Порошковые огнетушители предназначены практически для всех классов пожаров."
    ],
    [
      "SEND",
      "Водные огнетушители предназначены для уменьшения распространения очага возгорания..."
    ],
    [
      "SEND",
      "...постепенно ограничивая площадь самого возгорания."
    ],
    [
      "SEND",
      "Для того, чтобы начать использование огнетушителя вам необходимо:"
    ],
    [
      "SEND",
      "Сорвать пломбу на огнетушителе, имеющуюся на запорно-пусковом устройстве."
    ],
    [
      "SEND",
      "Выдернуть чеку."
    ],
    [
      "SEND",
      "Направить насадку шланга на очаг возгорания."
    ],
    [
      "SEND",
      "Нажать рычаг на огнетушителе."
    ],
    [
      "SEND",
      "Подождать 3-5 с для приведения огнетушителя в готовность."
    ],
    [
      "SEND",
      "При выходе огнетушащего вещества потушить возгорание."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу, всем спасибо за внимание."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      20],
    [
      "SEND",
      "Доброго времени суток, уважаемые коллеги."
    ],
    [
      "SEND",
      "Сейчас я проведу вам лекцию на тему \"Охранно-Пожарная сигнализация."
    ],
    [
      "SEND",
      "ОПС - это комплексная система безопасности, призванная предотвращать нежелательные события..."
    ],
    [
      "SEND",
      "...будь то взлом, пожар или другое чрезвычайное происшествие."
    ],
    [
      "SEND",
      "Она состоит из следующих элементов."
    ],
    [
      "SEND",
      "Датчики: обнаруживают потенциальные угрозы..."
    ],
    [
      "SEND",
      "...(движение, открытие дверей, повышение температуры, частицы дыма)."
    ],
    [
      "SEND",
      "Приемно-контрольная панель: обрабатывает сигналы от датчиков, формирует сигналы тревоги..."
    ],
    [
      "SEND",
      "...управляет сиренами и другими системами безопасности."
    ],
    [
      "SEND",
      "Сирены: издают звуковой сигнал, предупреждая о чрезвычайной ситуации."
    ],
    [
      "SEND",
      " Пульт централизованного наблюдения: при подключении... "
    ],
    [
      "SEND",
      " специалистам, которые могут..."
    ],
    [
      "SEND",
      "...оперативно реагировать на ситуацию."
    ],
    [
      "SEND",
      "ОПС - это эффективный инструмент безопасности, который помогает предотвратить..."
    ],
    [
      "SEND",
      "...нежелательные события и обеспечить спокойствие и безопасность для вас и вашего имущества."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу, всем спасибо за внимание."
    ],
    [
      "ELSE",
      20],
    [
      "END",
      20],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      37],
    [
      "SEND",
      "Здравствуйте уважаемые коллеги, сегодня я вам проведу лекцию на тему субординация."
    ],
    [
      "SEND",
      "Я расскажу информативную лекцию на тему: Поведение в Строю."
    ],
    [
      "SEND",
      "Во-первых, Пожарному запрещено не появляться на построении без уважительной причины."
    ],
    [
      "SEND",
      "Во-вторых, Пожарным запрещено держать огнестрельное оружие в открытом виде."
    ],
    [
      "SEND",
      "В-третьих, Пожарным запрещено разговаривать, шептать, двигаться без какого-либо ведома"
    ],
    [
      "SEND",
      "В-четвертых, Пожарным запрещено курить, крутить головой, разговаривать по телефонному аппарату."
    ],
    [
      "SEND",
      "За вышеперечисленные манипуляции Вы получаете наказание в личное дело."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу, всем спасибо за внимание."
    ],
    [
      "ELSE",
      37],
    [
      "END",
      37],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      46],
    [
      "SEND",
      "Здравствуйте уважаемые коллеги, сегодня я вам проведу лекцию на тему..."
    ],
    [
      "SEND",
      "...правила использования рации."
    ],
    [
      "SEND",
      "Есть два вида раций: рация департамента и обычная рация."
    ],
    [
      "SEND",
      "Обычная рация нужна для связи со своими сотрудниками."
    ],
    [
      "SEND",
      "Разрешено: уведомлять о патрулировании территории, информировании..."
    ],
    [
      "SEND",
      "...сослуживцев о важной информации."
    ],
    [
      "SEND",
      "Просить о проверке проверить заявление на увольнение."
    ],
    [
      "SEND",
      "Запрещено: оскорблять своих коллег, принижать их честь и достоинство."
    ],
    [
      "SEND",
      "Повторять одну и ту же фразу более двух раз."
    ],
    [
      "SEND",
      "Обязательно соблюдение субординации, уважительное отношение к своим коллегам."
    ],
    [
      "SEND",
      "Рация департамента нужна для связи с другими государственными структурами."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу, всем спасибо за внимание."
    ],
    [
      "ELSE",
      46],
    [
      "END",
      46],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      59],
    [
      "SEND",
      "Доброго времени суток. Сейчас мы проведем лекцию на тему \"Искуственное дыхание легких\"."
    ],
    [
      "SEND",
      "Искусственное дыхание - неотложная мера при отсутствии..."
    ],
    [
      "SEND",
      "...самостоятельного дыхания и сердцебиения."
    ],
    [
      "SEND",
      "При выявление признаков у пострадавшего, у вас есть 5 минут на реамационные дейсвтвия."
    ],
    [
      "SEND",
      "Для начала Вам нужно уложить пострадавшего на жесткую плоскость."
    ],
    [
      "SEND",
      "Сложите руки крестом и толчком надавите на нижнию часть груди человека."
    ],
    [
      "SEND",
      "Для взрослого от 100 до 120 толчков."
    ],
    [
      "SEND",
      "Для детей до 10 лет до 80 толчков и обязательно одной рукой. Это важно!"
    ],
    [
      "SEND",
      "Через каждые 30 толчков Вы должно вдуть человеку воздух в легкие через рот..."
    ],
    [
      "SEND",
      "...при этом необходимо зажать нос пострадавшего и выровнять его шею в горизонтальное положение."
    ],
    [
      "SEND",
      "Переодически проверяйте пульс на сонной артерии."
    ],
    [
      "SEND",
      "Эффективность данного мероприятия служит реакция зрачков на свет, а также их сужение."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу, всем спасибо за внимание."
    ],
    [
      "ELSE",
      59],
    [
      "END",
      59]
  ],
  "desc": "Провести лекцию",
  "arg": {

  },
  "delay": 2.5,
  "var": {

  },
  "cmd": "lekfd",
  "key": [
    "",
    {

    }
  ],
  "send_end_mes": true
}
]]
}

--> Отыгровки для сотрудников ТСР
local cmd_defoult_json_for_jail = {
--> Провести лекцию для своих
[1] = [[
{
  "folder": 6,
  "var": {

  },
  "rank": 4,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Напоминание соблюдение правил",
        "Дисциплина",
        "Свидания заключенных"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      2],
    [
      "SEND",
      "/rjail Здравствуйте уважаемые заключенные нашего штата."
    ],
    [
      "SEND",
      "/rjail Хочу напомнить что не стоит нарушать порядок тюрьмы."
    ],
    [
      "SEND",
      "/rjail За нарушений порядка вы можете получить наказание."
    ],
    [
      "ELSE",
      2],
    [
      "END",
      2],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      6],
    [
      "SEND",
      "/rjail Доброго времени суток, уважаемые заключенные нашего исправительного учреждения!"
    ],
    [
      "SEND",
      "/rjail Сейчас я проведу вам небольшую лекцию. На тему Дисциплина!"
    ],
    [
      "SEND",
      "/rjail Заключённым запрещено категорически: Поднимать бунт и оскорблять кого-либо"
    ],
    [
      "SEND",
      "/rjail Также запрещена организация нападения на сотрудников тюрьмы."
    ],
    [
      "SEND",
      "/rjail И всё что несёт за собой гибель людей!"
    ],
    [
      "SEND",
      "/rjail За данные нарушения вы понесёте наказание в виде повышения срока и карцера."
    ],
    [
      "SEND",
      "/rjail Хорошего время провождения. "
    ],
    [
      "ELSE",
      6],
    [
      "END",
      6],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      14],
    [
      "SEND",
      "/rjail Доброго времени суток, уважаемые заключенные нашего исправительного учреждения!"
    ],
    [
      "SEND",
      "/rjail Каждый заключенный может попросить встречу со своими родными"
    ],
    [
      "SEND",
      "/rjail Для этого вам нужно обратиться к работнику тюрьмы..."
    ],
    [
      "SEND",
      "/rjail ...сказав ему номер человека которого вы хотите видеть"
    ],
    [
      "SEND",
      "/rjail дабы он связался с нами и пришел к вам"
    ],
    [
      "SEND",
      "/rjail На этом у меня всё, надеюсь вскоре вы встретитесь с родными"
    ],
    [
      "SEND",
      "/rjail Приятного отдыха!"
    ],
    [
      "ELSE",
      14],
    [
      "END",
      14]
  ],
  "desc": "Провести лекцию для заключённых",
  "id_element": 21,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lekzeks",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Провести лекцию для сотрудников
[2] = [[
{
  "folder": 6,
  "id_element": 52,
  "rank": 4,
  "act": [
    [
      "DIALOG",
      "1",
      [
        "Построение",
        "Субординация",
        "Правила нахождение в строю",
        "Правила действий при ЧС",
        "Основы поставок боеприпасов"
      ]
    ],
    [
      "IF",
      2, [
        "1",
        "1"
      ],
      3],
    [
      "SEND",
      "Здравия желаю, уважаемые Военнослужащие Тюрьмы Строгого Режима"
    ],
    [
      "SEND",
      "Сейчас я зачитаю вам лекцию на тему Построение"
    ],
    [
      "SEND",
      "Когда объявили всеобщее построение вы обязаны бросить все свои дела и явиться в строй"
    ],
    [
      "SEND",
      "При опоздании извинится со словами Виноват, разрешите встать в строй?” ..."
    ],
    [
      "SEND",
      "... и встать в конец строя"
    ],
    [
      "SEND",
      "В строю запрещено: спать, разговаривать, использовать рацию"
    ],
    [
      "SEND",
      "Выражать эмоции, стрелять и покидать строй без разрешения"
    ],
    [
      "SEND",
      "Лекция на тему \"Построение окончена\". Спасибо за внимание"
    ],
    [
      "ELSE",
      3],
    [
      "END",
      3],
    [
      "IF",
      2, [
        "1",
        "2"
      ],
      13],
    [
      "SEND",
      "Сейчас я проведу лекцию на тему Субординация"
    ],
    [
      "SEND",
      "Субординация - Система служебного подчинения младших старшим...."
    ],
    [
      "SEND",
      "...основанная на правилах служебной дисциплины!"
    ],
    [
      "SEND",
      "К всему ст. составу вы должны обращаться на Вы, Так точно!"
    ],
    [
      "SEND",
      "За нарушение субординации преследует выговор."
    ],
    [
      "SEND",
      "На этом наша лекция подошла к концу."
    ],
    [
      "ELSE",
      13],
    [
      "END",
      13],
    [
      "IF",
      2, [
        "1",
        "3"
      ],
      21],
    [
      "SEND",
      "Доброго времени суток, уважаемые Военнослужащие."
    ],
    [
      "SEND",
      "Я расскажу информативную лекцию на тему: Поведение в Строю."
    ],
    [
      "SEND",
      "Во-первых, Военнослужащим запрещено не появляться на построении без уважительной причины"
    ],
    [
      "SEND",
      "Во-вторых, Военнослужащим запрещено держать огнестрельное оружие в открытом виде"
    ],
    [
      "SEND",
      "В-четвертых, Военнослужащим запрещено курить, крутить головой.."
    ],
    [
      "SEND",
      "разговаривать по телефонному аппарату."
    ],
    [
      "SEND",
      "За вышеперечисленные манипуляции Вы получаете наказание в личное дело"
    ],
    [
      "SEND",
      "На этом лекция заканчивается. Спасибо за внимание!"
    ],
    [
      "ELSE",
      21],
    [
      "END",
      21],
    [
      "IF",
      2, [
        "1",
        "4"
      ],
      30],
    [
      "SEND",
      "Здравия желаю, уважаемые Военнослужащие Тюрьмы Строгого Режима"
    ],
    [
      "SEND",
      "Сегодня я вам проведу лекцию на тему \"Как правильно действовать при ЧС\""
    ],
    [
      "SEND",
      "В первую очередь, вам надо убедиться, что люди напали на базу"
    ],
    [
      "SEND",
      "Если бандиты в масках начали атаковать вас - это ЧС"
    ],
    [
      "SEND",
      "У вас должно быть в руках обязательно М4A4 и Deagle , а также иметь бронежилет на себе"
    ],
    [
      "SEND",
      "Первый отпор должны дать вы. Но если вы не справляетесь.."
    ],
    [
      "SEND",
      "...в рацию вы должны сообщить о нападении на тюрьму"
    ],
    [
      "SEND",
      "Запрещено убегать от выстрелов, обратно в казарму или на завод"
    ],
    [
      "SEND",
      "Лекция на тему \"Как правильно действовать при ЧС\" окончена"
    ],
    [
      "ELSE",
      30],
    [
      "END",
      30],
    [
      "IF",
      2, [
        "1",
        "5"
      ],
      40],
    [
      "SEND",
      "Здравия желаю, уважаемые Военнослужащие Тюрьмы Строгого Режима"
    ],
    [
      "SEND",
      "Сейчас я проведу лекцию на тему - \"Основы поставок боеприпасов\""
    ],
    [
      "SEND",
      "Водитель грузовика с боеприпасами обязан:"
    ],
    [
      "SEND",
      "Не допускать захвата грузовика противником любыми возможными средствами..."
    ],
    [
      "SEND",
      "...в том числе ценой собственной жизни"
    ],
    [
      "SEND",
      "Иметь полный боекомплект и бронежилет"
    ],
    [
      "SEND",
      "Водителю грузовика снабжения запрещено:"
    ],
    [
      "SEND",
      "Отвлекаться от ведения поставок, терять бдительность находясь за рулем грузовика"
    ],
    [
      "SEND",
      "В частности, запрещено спать при загруженном грузовике"
    ],
    [
      "SEND",
      "Обеспечивать поставки без сопровождения"
    ],
    [
      "SEND",
      "Оставлять загруженный грузовик снабжения за пределами части"
    ],
    [
      "SEND",
      "Лекция на тему \"Основы поставок боеприпасов\" окончена"
    ],
    [
      "ELSE",
      40],
    [
      "END",
      40]
  ],
  "desc": "Провести лекцию для сотрудников",
  "var": {

  },
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "lektsr",
  "key": [
    "",
    {

    }
  ],
  "arg": {

  }
}
]],
--> Выдать повестку
[3] = [[
	{
	  "folder": 4,
	  "var": {},
	  "rank": 5,
	  "act": [
		[
		  "SEND",
		  "Здравствуйте, я {myrank} {mynickrus}. Покажите ваш паспорт."
		],
		[
		  "WAIT_ENTER"
		],
		[
		  "SEND",
		  "/me взял{sex[][а]} документ, изучил{sex[][а]} и вернул{sex[][а]}"
		],
		[
		  "SEND",
		  "/do В папке лежит бланк \"Повестка\"."
		],
		[
		  "SEND",
		  "/me достает бланк, заполняет бланк и ставит свою подпись"
		],
		[
		  "SEND",
		  "/todo Вот ваша повестка. Ждем вас в военкомате!*протягивая бланк человеку"
		],
		[
		  "SEND",
		  "/agenda {arg1}"
		]
	  ],
	  "desc": "Выдать повестку",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "delay": 1.4,
	  "id_element": 7,
	  "cmd": "agenda",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Посадить заключённого в карцер
[4] = [[
	{
	  "folder": 4,
	  "id_element": 6,
	  "rank": 5,
	  "act": [
		[
		  "SEND",
		  "/me прижал{sex[][а]} заключённого к стене, раздвинул{sex[][а]} ноги"
		],
		[
		  "SEND",
		  "/me снял{sex[][а]} ключи с пояса, открыл{sex[][а]} дверь в карцере"
		],
		[
		  "SEND",
		  "/me завел{sex[][а]} заключённого, снял{sex[][а]} с него наручники"
		],
		[
		  "SEND",
		  "/carcer {arg1} {arg2} {arg3} {arg4}"
		],
		[
		  "SEND",
		  "/uncuff {arg1}"
		],
		[
		  "SEND",
		  "/me закрыл{sex[][а]} дверь, повесил{sex[][а]} ключи на пояс"
		]
	  ],
	  "desc": "Посадить заключённого в карцер",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		},
		{
		  "desc": "номер камеры 1 - 10",
		  "name": "arg2",
		  "type": 2
		},
		{
		  "desc": "1 - 30 мин",
		  "name": "arg3",
		  "type": 2
		},
		{
		  "desc": "причина",
		  "name": "arg4",
		  "type": 1
		}
	  ],
	  "delay": 1.4,
	  "var": {},
	  "cmd": "carcer",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Надеть наручники
[5] = [[
	{
	  "folder": 4,
	  "var": {},
	  "rank": 2,
	  "act": [
		[
		  "SEND",
		  "/do Наручники на поясе."
		],
		[
		  "SEND",
		  "/me снял{sex[][а]} наручники, скрестил{sex[][а]} руки подозреваемого и надел{sex[][а]} их на руки"
		],
		[
		  "SEND",
		  "/cuff {arg1}"
		]
	  ],
	  "desc": "Надеть наручники",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "delay": 1.4,
	  "id_element": 3,
	  "cmd": "cuff",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Обыскать игрока
[6] = [[
	{
	  "folder": 4,
	  "var": {},
	  "rank": 1,
	  "act": [
		[
		  "SEND",
		  "/me надевает перчатки, прохлопывает верхние части тела"
		],
		[
		  "SEND",
		  "/me проверяет карманы и область пояса, обыскивает ноги и обувь"
		],
		[
		  "SEND",
		  "/frisk {arg1}"
		]
	  ],
	  "desc": "Обыскать игрока",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "delay": 1.4,
	  "id_element": 3,
	  "cmd": "frisk",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Тащить за собой
[7] = [[
	{
	  "folder": 4,
	  "var": {},
	  "rank": 2,
	  "act": [
		[
		  "SEND",
		  "/me сильно ухватил{sex[][а]} человека за плечо, фиксируя его в неподвижном положении"
		],
		[
		  "SEND",
		  "/gotome {arg1}"
		]
	  ],
	  "desc": "Тащить за собой",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "delay": 1.4,
	  "id_element": 2,
	  "cmd": "gotome",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Перестать тащить за собой
[8] = [[
	{
	  "folder": 4,
	  "var": {},
	  "rank": 2,
	  "act": [
		[
		  "SEND",
		  "/me отпускает плечо задержанного"
		],
		[
		  "SEND",
		  "/ungotome {arg1}"
		]
	  ],
	  "desc": "Перестать тащить",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "delay": 1.4,
	  "id_element": 2,
	  "cmd": "ungotome",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Снять наручники
[9] = [[
	{
	  "folder": 4,
	  "id_element": 2,
	  "rank": 2,
	  "act": [
		[
		  "SEND",
		  "/me снимает ключи с пояса и снимает наручники с задержанного"
		],
		[
		  "SEND",
		  "/uncuff {arg1}"
		]
	  ],
	  "desc": "Снять наручники",
	  "send_end_mes": true,
	  "delay": 1.4,
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "cmd": "uncuff",
	  "key": ["", {}],
	  "var": {}
	}
	]],
--> Повысить/Понизить срок заключённому
[10] = [[
	{
	  "folder": 4,
	  "id_element": 11,
	  "rank": 7,
	  "act": [
		[
		  "DIALOG",
		  "what",
		  [
			"Понизить",
			"Повысить"
		  ]
		],
		[
		  "IF",
		  2,
		  [
			"what",
			"1"
		  ],
		  4
		],
		[
		  "NEW_VAR",
		  "var1",
		  "1"
		],
		[
		  "ELSE",
		  4
		],
		[
		  "NEW_VAR",
		  "var1",
		  "2"
		],
		[
		  "END",
		  4
		],
		[
		  "SEND",
		  "/me аккуратным движением правой руки достал{sex[][а]} КПК и включил{sex[][а]} его"
		],
		[
		  "SEND",
		  "/me заш{sex[ел][ла]} в базу данных ТСР, и наш{sex[ел][ла]} заключенного"
		],
		[
		  "SEND",
		  "/me нажав на его иконку в КПК и изменил{sex[][а]} срок заключенному"
		],
		[
		  "SEND",
		  "/do На планшете появилась зеленая галка и заключенному изменился срок пребывания в тюрьме."
		],
		[
		  "SEND",
		  "/punish {arg1} {arg2} {var1} {arg3}"
		]
	  ],
	  "desc": "Повысить/Понизить срок",
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		},
		{
		  "desc": "уровень 1 - 6",
		  "name": "arg2",
		  "type": 2
		},
		{
		  "desc": "причина",
		  "name": "arg3",
		  "type": 1
		}
	  ],
	  "delay": 1.4,
	  "var": [
		{
		  "name": "var1",
		  "value": "1"
		}
	  ],
	  "cmd": "punish",
	  "key": ["", {}],
	  "send_end_mes": true
	}
	]],
--> Выдать военный билет
[11] = [[
	{
	  "folder": 4,
	  "id_element": 6,
	  "rank": 7,
	  "act": [
		[
		  "SEND",
		  "Здравствуйте, я {myrank} {mynickrus}. Покажите ваш паспорт, пожалуйста."
		],
		[
		  "WAIT_ENTER"
		],
		[
		  "SEND",
		  "/me взял{sex[][а]} паспорт, внимательно изучил{sex[][а]} его"
		],
		[
		  "SEND",
		  "/do На столе лежат несколько документов, среди которых - бланк военного билета."
		],
		[
		  "SEND",
		  "/me заполнил{sex[][а]} бланк, поставил{sex[][а]} подпись и передал{sex[][а]} его человеку"
		],
		[
		  "SEND",
		  "/givemilitary {arg1}"
		]
	  ],
	  "desc": "Выдать военный билет человеку",
	  "send_end_mes": true,
	  "delay": 1.4,
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "cmd": "givemilitary",
	  "key": ["", {}],
	  "var": {}
	}
  ]],
--> Освободить человека из тюрьмы
[12] = [[
	{
	  "folder": 4,
	  "id_element": 6,
	  "rank": 9,
	  "act": [
		[
		  "SEND",
		  "/do В левом кармане лежит КПК."
		],
		[
		  "SEND",
		  "/me достал{sex[][а]} КПК, заш{sex[ел][ла]} в базу данных заключённых и наш{sex[ел][ла]} нужное дело"
		],
		[
		  "SEND",
		  "/me нажал{sex[][а]} пункт \"Освободить\" в деле заключенного"
		],
		[
		  "SEND",
		  "/do В базе данных заключённого были сделаны изменения."
		],
		[
		  "SEND",
		  "/unpunish {arg1} {arg2}"
		]
	  ],
	  "desc": "Выпустить человека с тюрьмы",
	  "send_end_mes": true,
	  "delay": 1.4,
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		},
		{
		  "desc": "сумма за выход: 2кк - 50кк",
		  "name": "arg2",
		  "type": 2
		}
	  ],
	  "cmd": "unpunish",
	  "key": ["", {}],
	  "var": {}
	}
  ]],
--> Просмотреть наказание заключённого
[13] = [[
	{
	  "folder": 4,
	  "id_element": 2,
	  "rank": 3,
	  "act": [
		[
		  "SEND",
		  "/me достал{sex[][а]} КПК и открыл{sex[][а]} базу и посмотрел{sex[][а]} информацию о человеке"
		],
		[
		  "SEND",
		  "/getjail {arg1}"
		]
	  ],
	  "desc": "Просмотреть наказание заключенного",
	  "send_end_mes": true,
	  "delay": 1.4,
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		}
	  ],
	  "cmd": "getjail",
	  "key": ["", {}],
	  "var": {}
	}
  ]],
--> Поменять номер карцера
[14] = [[
	{
	  "folder": 4,
	  "id_element": 9,
	  "rank": 6,
	  "act": [
		[
		  "SEND",
		  "/me снял{sex[][а]} ключи с пояса, открыл дверь карцера номер '{arg2}'"
		],
		[
		  "SEND",
		  "/me открыл{sex[][а]} карцер с заключенным, заломал{sex[][а]} ему руку и перевел{sex[][а]} в другую камеру"
		],
		[
		  "SEND",
		  "/me закрыл{sex[][а]} оба карцера, повесил{sex[][а]} ключи на пояс"
		],
		[
		  "SEND",
		  "/setcarcer {arg1} {arg2}"
		]
	  ],
	  "desc": "Поменять номер карцера",
	  "send_end_mes": true,
	  "delay": 1.4,
	  "arg": [
		{
		  "desc": "id игрока",
		  "name": "arg1",
		  "type": 2
		},
		{
		  "desc": "новый номер карцера 1 - 10",
		  "name": "arg2",
		  "type": 2
		}
	  ],
	  "cmd": "setcarcer",
	  "key": ["", {}],
	  "var": {}
	}
  ]],
--> Освободить игрока из карцера
[15] = [[
	{
	  "folder": 4,
	  "id_element": 5,
	  "rank": 1,
	  "act": [
		[
		  "SEND",
		  "/do Ключи от карцера на поясе."
		],
		[
		  "SEND",
		  "/me правой рукой взял{sex[][а]} ключ от карцера и открыл{sex[][а]} его"
		],
		[
		  "SEND",
		  "/me взял{sex[][а]} заключенного за руку, вывел{sex[][а]} его из карцера"
		  ],
      [
        "SEND",
        "/me закрыл{sex[][а]} дверь карцера и повесил{sex[][а]} ключ на пояс"
      ],
      [
        "SEND",
        "/uncarcer {arg1}"
      ]
    ],
    "desc": "Выпустить игрока из карцера",
    "send_end_mes": true,
    "delay": 1.4,
    "arg": [
      {
        "desc": "id игрока",
        "name": "arg1",
        "type": 2
      }
    ],
    "cmd": "uncarcer",
    "key": ["", {}],
    "var": {}
  }
]]
}
--> Для СМИ
local cmd_defoult_json_for_smi = {

	}
--> Мед карта для феникса
local medcard_phoenix = [[
{
  "folder": 4,
  "UID": 61764606,
  "var": [
	{
	  "name": "period",
	  "value": "1"
	},
	{
	  "name": "levelpl",
	  "value": "{getlevel[{idplayer}]}"
	},
	{
	  "name": "term",
	  "value": "0"
	},
	{
	  "name": "price",
	  "value": "1000"
	},
	{
	  "name": "price7",
	  "value": "20000"
	},
	{
	  "name": "price14",
	  "value": "35000"
	},
	{
	  "name": "price30",
	  "value": "45000"
	},
	{
	  "name": "price60",
	  "value": "65000"
	}
  ],
  "rank": 3,
  "act": [
	[
	  "SEND",
	  "Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт."
	],
	[
	  "SEND",
	  "/b Для этого введите /showpass {myid}"
	],
	[
	  "WAIT_ENTER"
	],
	[
	  "SEND",
	  "/me взял{sex[][а]} паспорт из рук пациента и внимательно изучил{sex[][а]} его"
	],
	[
	  "SEND",
	  "Хорошо, сейчас задам пару вопросов, отвечайте честно."
	],
	[
	  "SEND",
	  "Вы можете видеть имена проходящих мимо Вас людей?"
	],
	[
	  "WAIT_ENTER"
	],
	[
	  "SEND",
	  "Вас когда-нибудь убивали?"
	],
	[
	  "DIALOG",
	  "mentalstate",
	  [
		"Полностью здоров",
		"Наблюдаются откл.",
		"Псих. нездоров",
		"Неопределён"
	  ]
	],
	[
	  "IF",
	  2, [
		"mentalstate",
		"2"
	  ],
	  10, 1],
	[
	  "NEW_VAR",
	  "period",
	  "2"
	],
	[
	  "ELSE",
	  10],
	[
	  "IF",
	  2, [
		"mentalstate",
		"3"
	  ],
	  12, 1],
	[
	  "NEW_VAR",
	  "period",
	  "1"
	],
	[
	  "ELSE",
	  12],
	[
	  "IF",
	  2, [
		"mentalstate",
		"4"
	  ],
	  15, 1],
	[
	  "NEW_VAR",
	  "period",
	  "0"
	],
	[
	  "ELSE",
	  15],
	[
	  "END",
	  15],
	[
	  "END",
	  12],
	[
	  "END",
	  10],
	[
	  "IF",
	  4, [
		"levelpl",
		"6"
	  ],
	  22, 3],
	[
	  "IF",
	  4, [
		"levelpl",
		"10"
	  ],
	  23, 5],
	[
	  "SEND",
	  "Стоимость оформления мед карты зависит от его срока."
	],
	[
	  "SEND",
	  "7 дней - 20.000$. 14 дней - 35.000$. 30 дней - 45.000$. 60 дней - 65.000$."
	],
	[
	  "ELSE",
	  23],
	[
	  "IF",
	  4, [
		"levelpl",
		"15"
	  ],
	  29, 5],
	[
	  "SEND",
	  "Стоимость оформления мед карты зависит от его срока."
	],
	[
	  "SEND",
	  "7 дней - 35.000$. 14 дней - 50.000$. 30 дней - 60.000$. 60 дней - 75.000$."
	],
	[
	  "NEW_VAR",
	  "price7",
	  "35000"
	],
	[
	  "NEW_VAR",
	  "price14",
	  "50000"
	],
	[
	  "NEW_VAR",
	  "price30",
	  "60000"
	],
	[
	  "NEW_VAR",
	  "price60",
	  "75000"
	],
	[
	  "ELSE",
	  29],
	[
	  "IF",
	  4, [
		"levelpl",
		"20"
	  ],
	  31, 5],
	[
	  "SEND",
	  "Стоимость оформления мед карты зависит от его срока."
	],
	[
	  "SEND",
	  "7 дней - 50.000$. 14 дней - 60.000$. 30 дней - 85.000$. 60 дней - 100.000$."
	],
	[
	  "NEW_VAR",
	  "price7",
	  "50000"
	],
	[
	  "NEW_VAR",
	  "price14",
	  "60000"
	],
	[
	  "NEW_VAR",
	  "price30",
	  "85000"
	],
	[
	  "NEW_VAR",
	  "price60",
	  "100000"
	],
	[
	  "ELSE",
	  31],
	[
	  "SEND",
	  "Стоимость оформления мед карты зависит от его срока."
	],
	[
	  "SEND",
	  "7 дней - 140.000$. 14 дней - 160.000$. 30 дней - 180.000$. 60 дней - 200.000$."
	],
	[
	  "NEW_VAR",
	  "price7",
	  "140000"
	],
	[
	  "NEW_VAR",
	  "price14",
	  "160000"
	],
	[
	  "NEW_VAR",
	  "price30",
	  "180000"
	],
	[
	  "NEW_VAR",
	  "price60",
	  "200000"
	],
	[
	  "END",
	  31],
	[
	  "END",
	  29],
	[
	  "END",
	  23],
	[
	  "SEND",
	  "Выберите срок оформления и мы продолжим."
	],
	[
	  "ELSE",
	  22],
	[
	  "SEND",
	  "Для Вас стоимость медицинской карты составляет всего 1000$. Оформляем?"
	],
	[
	  "END",
	  22],
	[
	  "IF",
	  4, [
		"levelpl",
		"6"
	  ],
	  49, 3],
	[
	  "DIALOG",
	  "termmed",
	  [
		"7 дней",
		"14 дней",
		"30 дней",
		"60 дней"
	  ]
	],
	[
	  "IF",
	  2, [
		"termmed",
		"1"
	  ],
	  51, 1],
	[
	  "NEW_VAR",
	  "price",
	  "{price7}"
	],
	[
	  "ELSE",
	  51],
	[
	  "IF",
	  2, [
		"termmed",
		"2"
	  ],
	  53, 1],
	[
	  "NEW_VAR",
	  "price",
	  "{price14}"
	],
	[
	  "ELSE",
	  53],
	[
	  "IF",
	  2, [
		"termmed",
		"3"
	  ],
	  55, 1],
	[
	  "NEW_VAR",
	  "price",
	  "{price30}"
	],
	[
	  "ELSE",
	  55],
	[
	  "IF",
	  2, [
		"termmed",
		"4"
	  ],
	  57, 1],
	[
	  "NEW_VAR",
	  "price",
	  "{price60}"
	],
	[
	  "ELSE",
	  57],
	[
	  "END",
	  57],
	[
	  "END",
	  55],
	[
	  "END",
	  53],
	[
	  "END",
	  51],
	[
	  "ELSE",
	  49],
	[
	  "WAIT_ENTER"
	],
	[
	  "END",
	  49],
	[
	  "SEND",
	  "/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка"
	],
	[
	  "SEND",
	  "/do Печать больницы нанесена на бланк."
	],
	[
	  "SEND",
	  "/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату"
	],
	[
	  "SEND",
	  "/do Страница медицинской карты полностью заполнена."
	],
	[
	  "SEND",
	  "/me передаёт медицинскую карту в руки обратившемуся"
	],
	[
	  "SEND",
	  "/medcard {idplayer} {period} {term} {price}"
	]
  ],
  "desc": "Оформить медицинскую карту",
  "id_element": 77,
  "delay": 2.5,
  "send_end_mes": true,
  "cmd": "mc",
  "key": [
	"",
	{

	}
  ],
  "arg": [
	{
	  "desc": "id игрока",
	  "name": "idplayer",
	  "type": 2
	}
  ]
}
]]
mc_phoenix = {}

cmd_defoult = {
	all = {}, --> Для всех организаций
	hospital = {}, --> Для сотрудников Больниц
	driving_school = {}, --> Для сотрудников центра лицензирования
	government = {}, --> Для сотрудников правительства
	army = {}, --> Для служащих в армии
	fire_department = {}, --> Для сотрудников пожарного департмамента
	jail = {}, --> Для сотрудников тюрьмы
	smi = {} --> Для сотрудников СМИ
}

function add_cmd_defoult()
	--> Добавить команды для всех организаций
	for i = 1, #cmd_defoult_json_for_all do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_all[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.all, set)
			cmd_defoult.all[#cmd_defoult.all].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для Больниц
	for i = 1, #cmd_defoult_json_for_hospital do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_hospital[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.hospital, set)
			cmd_defoult.hospital[#cmd_defoult.hospital].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для Центра Лицензирования
	for i = 1, #cmd_defoult_json_for_driving_school do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_driving_school[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.driving_school, set)
			cmd_defoult.driving_school[#cmd_defoult.driving_school].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для Правительства
	for i = 1, #cmd_defoult_json_for_government do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_government[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.government, set)
			cmd_defoult.government[#cmd_defoult.government].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для Армии
	for i = 1, #cmd_defoult_json_for_army do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_army[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.army, set)
			cmd_defoult.army[#cmd_defoult.army].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для Пожарных
	for i = 1, #cmd_defoult_json_for_fire_department do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_fire_department[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.fire_department, set)
			cmd_defoult.fire_department[#cmd_defoult.fire_department].UID = math.random(20, 95000000)
		end
	end
	
	--> Добавить команды для ТСР
	for i = 1, #cmd_defoult_json_for_jail do
		local res, set = pcall(decodeJson, cmd_defoult_json_for_jail[i])
		if res and type(set) == 'table' then
			set = convertToUTF8(set)
			table.insert(cmd_defoult.jail, set)
			cmd_defoult.jail[#cmd_defoult.jail].UID = math.random(20, 95000000)
		end
	end

		--> Добавить команды для СМИ
		for i = 1, #cmd_defoult_json_for_smi do
			local res, set = pcall(decodeJson, cmd_defoult_json_for_smi[i])
			if res and type(set) == 'table' then
				set = convertToUTF8(set)
				table.insert(cmd_defoult.smi, set)
				cmd_defoult.smi[#cmd_defoult.smi].UID = math.random(20, 95000000)
			end
		end
	
	local res, set = pcall(decodeJson, medcard_phoenix)
	if res and type(set) == 'table' then
		mc_phoenix = convertToUTF8(set)
		mc_phoenix.UID = math.random(20, 95000000)
	end
end
add_cmd_defoult()
local function get_last_lines(log, n)
	local function split_text(input, length)
		local parts = {}
		while #input > length do
			local part = input:sub(1, length)
			table.insert(parts, part)
			input = input:sub(length + 1)
		end
		
		if #input > 0 then
			table.insert(parts, input)
		end
		
		return parts
	end
	
	local lines = {}
	for line in log:gmatch("[^\n]+") do
		table.insert(lines, line)
	end
	
	local start_index = #lines - n + 1
	if start_index < 1 then start_index = 1 end

	local last_lines = {}
	local num_str = 1
	for i = start_index, #lines do
		if lines[i]:find("%(error%)") then
			lines[i] = lines[i]:gsub('(.+)%(error%)', '')
			local name_script_error = lines[i]:match('^(.-)%:')
			local null_error_del, line_error = lines[i]:match('^(.+)%:(%d+)%:')
			lines[i] = lines[i]:gsub('^(.+)%:(%d+)%: ', '')
			lines[i] = '[' .. num_str .. '] [Лог краша] {FFFFFF}Ошибка в скрипте' .. name_script_error .. '[' .. scr.version .. '], строка ' .. line_error .. ': ' .. lines[i]
			
			local parts = split_text(lines[i], 120)
			for i, part in ipairs(parts) do
				if i == 1 then
					table.insert(last_lines, part)
				else
					table.insert(last_lines, '{FFFFFF}' .. part)
				end
			end
			
			num_str = num_str + 1
		elseif lines[i]:find('in function') and not lines[i]:find('>$') then
			local del_param_null, name_script_error, line_error = lines[i]:match('(.+)\\(.-)%.lua%:(%d+)%:')
			lines[i] = lines[i]:gsub('(.+)in function ', 'в функции ')
			if not line_error then
				line_error = 'nil'
			end
			if not name_script_error then
				name_script_error = 'NAME'
			end
			lines[i] = '[' .. num_str .. '] [Лог краша] {FFFFFF}Ошибка функции в скрипте ' .. name_script_error .. '[' .. scr.version .. '], строка ' .. line_error .. ': ' .. lines[i]
			
			local parts = split_text(lines[i], 120)
			for i, part in ipairs(parts) do
				if i == 1 then
					table.insert(last_lines, part)
				else
					table.insert(last_lines, '{FFFFFF}' .. part)
				end
			end
			
			num_str = num_str + 1
		end
	end

	return last_lines
end

function onScriptTerminate(script, game_quit)
	if script == thisScript() then
		local f = io.open(dir .. '/moonloader.log')
		local crash_log = f:read('*a')
		f:close()
		
		local log_array = get_last_lines(crash_log, 10)
		local clipboard = {}
		if #log_array ~= 0 then
			if setting.show_logs then
				sampAddChatMessage('[SH] Скрипт неожиданно завершил работу со следующими ошибками:', 0xFF5345)
			end
		else
			return
		end
		
		if setting.show_logs then
			for i = 1, #log_array do
				sampAddChatMessage(log_array[i], 0xFF5345)
				table.insert(clipboard, u8(log_array[i]))
			end
		end
		imgui.SetClipboardText(table.concat(clipboard, '\n'))
		local f = io.open(dir .. '/State Helper Lite/crashlog.log', 'w')
		f:write(table.concat(clipboard, '\n'))
		f:flush()
		f:close()
		
		if setting.show_logs then
			sampAddChatMessage('[SH] Лог краша сохранён в файлах скрипта, а также скопирован в буфер обмена.', 0xFF5345)
		else
			sampAddChatMessage('[SH] Скрипт неожиданно завершил работу. Лог сохранён в файлах скрипта, а также скопирован в буфер обмена.', 0xFF5345)
		end
	end
end
--[[
local inputTextCallback = ffi.cast("ImGuiInputTextCallback", function(data)
    if needSetCursorToEnd then
        data.CursorPos = #ffi.string(inputField)
        needSetCursorToEnd = false
    end
    return 0
end)


function SmiEdit()
    if not dialogData then return end
        local startIdx, endIdx = string.find(dialogText, "{33AA33}([^\n]+)")
		if imgui.IsItemHovered() then
			gui.DrawLine({arrowPosX - 5, arrowPosY - 5}, {arrowPosX + 5, arrowPosY}, imgui.ImVec4(0.98, 0.30, 0.38, 1.00), 2)
			gui.DrawLine({arrowPosX + 5, arrowPosY}, {arrowPosX - 5, arrowPosY + 5}, imgui.ImVec4(0.98, 0.30, 0.38, 1.00), 2)
			imgui.SetTooltip(u8("Скопировать в поле ввода"))
		else
			gui.DrawLine({arrowPosX - 5, arrowPosY - 5}, {arrowPosX + 5, arrowPosY}, imgui.ImVec4(0.98, 0.40, 0.38, 1.00), 2)
			gui.DrawLine({arrowPosX + 5, arrowPosY}, {arrowPosX - 5, arrowPosY + 5}, imgui.ImVec4(0.98, 0.40, 0.38, 1.00), 2)
		end

		-- А дописать не хоч?

    end
]]
