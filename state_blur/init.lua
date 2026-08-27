local ffi = require 'ffi'
local imgui = require 'mimgui'
local M = {}

local libPath = getWorkingDirectory() .. [[\lib\state_blur\state_blur]]
local status, lib = pcall(ffi.load, libPath)

if status then
    ffi.cdef[[
        void* mimgui_blur_apply_ex(float x0, float y0, float x1, float y1, float radius,
                                    float* outX0, float* outY0, float* outX1, float* outY1,
                                    float* outU0, float* outV0, float* outU1, float* outV1);
        void mimgui_blur_invalidate();
        void MimguiBlur_AttachDevice(void* device);
        int  mimgui_blur_verify_script(const char* callerScriptPath);
        void mimgui_blur_set_update_interval(int frames);
        void mimgui_blur_force_refresh();
    ]]
end

local licensed = false
if status then
    local ok, callerPath = pcall(function() return thisScript().path end)
    if ok and callerPath then
        local vok, res = pcall(lib.mimgui_blur_verify_script, callerPath)
        licensed = vok and res == 1
    end
end

M.available = status and licensed

local outRect = status and ffi.new('float[8]') or nil
local function outPtrs()
    return outRect + 0, outRect + 1, outRect + 2, outRect + 3,
           outRect + 4, outRect + 5, outRect + 6, outRect + 7
end

local warnedUnlicensed = false

function M.setup()
    if not status then return false end

    if not licensed then
        if not warnedUnlicensed then
            warnedUnlicensed = true
            pcall(sampAddChatMessage,
                '[Blur]{FFFFFF} Извините, блюр доступен пока только для скрипта State Helper.', 0xFF3333)
        end
        return true
    end

    if _G.MIMGUI_BLUR_HOOKED then return true end
    pcall(function()
        local ptr = getD3DDevicePtr()
        if ptr and ptr ~= 0 then
            lib.MimguiBlur_AttachDevice(ffi.cast('void*', ptr))
            _G.MIMGUI_BLUR_HOOKED = true
        end
    end)
    return _G.MIMGUI_BLUR_HOOKED == true
end

function M.SetPerformanceMode(n)
    if not (M.available and status and lib.mimgui_blur_set_update_interval) then return end
    pcall(lib.mimgui_blur_set_update_interval, n)
end

local frameCounter = 0

function M.InvalidateBlurCache()
    if status and lib.mimgui_blur_force_refresh then
        pcall(lib.mimgui_blur_force_refresh)
    end
end

local function colToU32(col)
    if not col then return 0xFFFFFFFF end
    local a = math.floor((col.w or 1.0) * 255 + 0.5)
    local b = math.floor((col.z or 1.0) * 255 + 0.5)
    local g = math.floor((col.y or 1.0) * 255 + 0.5)
    local r = math.floor((col.x or 1.0) * 255 + 0.5)
    return bit.bor(bit.lshift(a, 24), bit.lshift(b, 16), bit.lshift(g, 8), r)
end

local function titleBarHeight()
    return imgui.GetFontSize() + imgui.GetStyle().FramePadding.y * 2.0
end

local function resolveInsets(opts)
    local u = opts.inset or 0
    return opts.insetLeft or u, opts.insetTop or u, opts.insetRight or u, opts.insetBottom or u
end

local function drawBlurRect(dl, x0, y0, x1, y1, radius, rounding, tint, forceUpdate)
    if not (M.available and status) then return false end
    if x1 - x0 <= 2 or y1 - y0 <= 2 then return false end

    local o0, o1, o2, o3, o4, o5, o6, o7 = outPtrs()
    local ok, texPtr = pcall(lib.mimgui_blur_apply_ex, x0, y0, x1, y1, radius,
                              o0, o1, o2, o3, o4, o5, o6, o7)
    if not (ok and texPtr ~= nil and texPtr ~= ffi.NULL) then return false end

    local cx0, cy0, cx1, cy1 = outRect[0], outRect[1], outRect[2], outRect[3]
    local cu0, cv0, cu1, cv1 = outRect[4], outRect[5], outRect[6], outRect[7]
    if cx1 - cx0 <= 2 or cy1 - cy0 <= 2 then return false end

    rounding = rounding or 0
    dl:AddImageRounded(
        ffi.cast('void*', texPtr),
        imgui.ImVec2(cx0, cy0), imgui.ImVec2(cx1, cy1),
        imgui.ImVec2(cu0, cv0), imgui.ImVec2(cu1, cv1),
        0xFFFFFFFF, rounding, imgui.DrawCornerFlags.All
    )
    if tint then
        dl:AddRectFilled(
            imgui.ImVec2(cx0, cy0), imgui.ImVec2(cx1, cy1),
            colToU32(tint), rounding, imgui.DrawCornerFlags.All
        )
    end
    return true, cx0, cy0, cx1, cy1, cu0, cv0, cu1, cv1
end

function M.Begin(name, p_open, flags, opts)
    opts = opts or {}
    local rounding = opts.rounding
    if rounding == nil then rounding = imgui.GetStyle().WindowRounding end
    local blurTitleBar = opts.blurTitleBar
    if blurTitleBar == nil then blurTitleBar = true end
    local mode = opts.mode or 0
    local forceUpdate = opts.forceUpdate or false

    imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, rounding)
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))

    local pushedColors = 1
    if mode == 0 and blurTitleBar then
        imgui.PushStyleColor(imgui.Col.TitleBg, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.TitleBgCollapsed, imgui.ImVec4(0, 0, 0, 0))
        pushedColors = pushedColors + 3
    end

    local visible = imgui.Begin(name, p_open, flags or imgui.WindowFlags.None)

    if visible and M.available and status then
        local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
        local radius = opts.radius or 12.0

        if mode == 0 then
            local l, t, r, b = resolveInsets(opts)
            local x0 = pos.x + l
            local y0 = blurTitleBar and (pos.y + t) or (pos.y + titleBarHeight() + t)
            local x1 = pos.x + size.x - r
            local y1 = pos.y + size.y - b

            drawBlurRect(imgui.GetBackgroundDrawList(), x0, y0, x1, y1, radius, rounding, opts.tint, forceUpdate)
        else
            local io = imgui.GetIO()
            local scrW, scrH = io.DisplaySize.x, io.DisplaySize.y
            local o0, o1, o2, o3, o4, o5, o6, o7 = outPtrs()
            local ok, texPtr = pcall(lib.mimgui_blur_apply_ex, 0, 0, scrW, scrH, radius,
                                      o0, o1, o2, o3, o4, o5, o6, o7)

            if ok and texPtr ~= nil and texPtr ~= ffi.NULL then
                local cx0, cy0, cx1, cy1 = outRect[0], outRect[1], outRect[2], outRect[3]
                local cu0, cv0, cu1, cv1 = outRect[4], outRect[5], outRect[6], outRect[7]
                local texW, texH = cx1 - cx0, cy1 - cy0
                local uSpan, vSpan = cu1 - cu0, cv1 - cv0
                local bg = imgui.GetBackgroundDrawList()
                local tex = ffi.cast('void*', texPtr)
                local col = opts.tint and colToU32(opts.tint) or nil

                if texW > 2 and texH > 2 then
                    local function DrawPart(px1, py1, px2, py2)
                        if px1 >= px2 or py1 >= py2 then return end
                        local uv_min = imgui.ImVec2(
                            cu0 + ((px1 - cx0) / texW) * uSpan,
                            cv0 + ((py1 - cy0) / texH) * vSpan)
                        local uv_max = imgui.ImVec2(
                            cu0 + ((px2 - cx0) / texW) * uSpan,
                            cv0 + ((py2 - cy0) / texH) * vSpan)
                        bg:AddImage(tex, imgui.ImVec2(px1, py1), imgui.ImVec2(px2, py2), uv_min, uv_max, 0xFFFFFFFF)
                        if col then bg:AddRectFilled(imgui.ImVec2(px1, py1), imgui.ImVec2(px2, py2), col) end
                    end

                    DrawPart(0, 0, scrW, pos.y)
                    DrawPart(0, pos.y + size.y, scrW, scrH)
                    DrawPart(0, pos.y, pos.x, pos.y + size.y)
                    DrawPart(pos.x + size.x, pos.y, scrW, pos.y + size.y)
                    local r = rounding or 0
                    if r > 0.5 then
                        r = math.min(r, size.x * 0.5, size.y * 0.5)
                        local steps = math.max(3, math.min(10, math.ceil(r / 2)))

                        local function DrawCorner(anchorX, anchorY, centerX, centerY, sx, sy)
                            for i = 0, steps - 1 do
                                local y0 = anchorY + sy * r * (i / steps)
                                local y1 = anchorY + sy * r * ((i + 1) / steps)
                                local yTop, yBot = math.min(y0, y1), math.max(y0, y1)
                                local yMid = (yTop + yBot) * 0.5
                                local dy = centerY - yMid
                                local dxSq = r * r - dy * dy
                                local dx = (dxSq > 0) and math.sqrt(dxSq) or 0
                                local edgeX = centerX - sx * dx
                                if sx > 0 then
                                    DrawPart(anchorX, yTop, edgeX, yBot)
                                else
                                    DrawPart(edgeX, yTop, anchorX, yBot)
                                end
                            end
                        end

                        DrawCorner(pos.x, pos.y, pos.x + r, pos.y + r, 1, 1) -- top-left
                        DrawCorner(pos.x + size.x, pos.y, pos.x + size.x - r, pos.y + r, -1, 1) -- top-right
                        DrawCorner(pos.x, pos.y + size.y, pos.x + r, pos.y + size.y - r, 1, -1) -- bottom-left
                        DrawCorner(pos.x + size.x, pos.y + size.y, pos.x + size.x - r, pos.y + size.y - r, -1, -1) -- bottom-right
                    end
                end
            end
        end
    end

    imgui.PopStyleColor(pushedColors)
    imgui.PopStyleVar(1)
    return visible
end

function M.End() imgui.End() end

function M.Rect(x0, y0, x1, y1, opts)
    opts = opts or {}
    local dl = (opts.background == false) and imgui.GetWindowDrawList() or imgui.GetBackgroundDrawList()
    return drawBlurRect(dl, x0, y0, x1, y1, opts.radius or 12.0, opts.rounding or 0, opts.tint, opts.forceUpdate or false)
end

function M.Behind(opts, drawFn)
    opts = opts or {}
    local dl = imgui.GetWindowDrawList()
    dl:ChannelsSplit(2)

    dl:ChannelsSetCurrent(1)
    drawFn()

    local rMin, rMax = imgui.GetItemRectMin(), imgui.GetItemRectMax()

    dl:ChannelsSetCurrent(0)
    local l, t, r, b = resolveInsets(opts)
    drawBlurRect(dl, rMin.x + l, rMin.y + t, rMax.x - r, rMax.y - b,
                 opts.radius or 10.0, opts.rounding or 0, opts.tint, opts.forceUpdate or false)

    dl:ChannelsMerge()
end

function M.BeginScreen(opts)
    if not (M.available and status) then return false end
    opts = opts or {}
    local io = imgui.GetIO()
    local sw, sh = io.DisplaySize.x, io.DisplaySize.y
    if sw <= 2 or sh <= 2 then return false end
    return drawBlurRect(imgui.GetBackgroundDrawList(), 0, 0, sw, sh,
                         opts.radius or 20.0, 0, opts.tint, opts.forceUpdate or false)
end

addEventHandler('onD3DDeviceLost', function()
    if status and lib.mimgui_blur_invalidate then
        lib.mimgui_blur_invalidate()
    end
end)

return M