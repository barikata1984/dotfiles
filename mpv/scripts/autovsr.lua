-- mpv 0.39.0+ / Linux / Vulkan API 用の NVIDIA VSR 切り替えスクリプト
-- デフォルトでVSRをONにするバージョン

local mp = require 'mp'

-- ## 設定項目 ##
-- VSRの品質レベルを設定します (1: 低, 2: 中, 3: 高, 4: 最高)
local vsr_quality = 4
-----------------

-- 【変更点1】VSRの初期状態を true (有効) に設定
local vsr_enabled = true

local vsr_filter_name = "@vsr_vulkan"
local vsr_filter_string = vsr_filter_name .. ":vk-vsr:quality=" .. vsr_quality

-- VSRフィルタを適用または解除する関数
local function apply_vsr()
    -- 既にフィルタが適用されている場合は一旦解除（重複適用を防ぐため）
    mp.commandv("vf", "remove", vsr_filter_name)

    -- VSRが有効な場合のみ、アップスケーリングが必要な状況でフィルタを適用
    if vsr_enabled then
        local video_w = mp.get_property_native("width")
        local video_h = mp.get_property_native("height")
        local display_w = mp.get_property_native("display-width")
        local display_h = mp.get_property_native("display-height")

        -- 映像の解像度がディスプレイの解像度より小さい場合（アップスケーリング時）のみ適用
        if video_w and display_w and video_h and display_h and (video_w < display_w or video_h < display_h) then
            mp.commandv("vf", "append", vsr_filter_string)
            mp.osd_message("VSR (vk-vsr) ON | Quality: " .. vsr_quality)
        else
            mp.osd_message("VSR (vk-vsr) ON | Upscaling not needed")
        end
    else
        mp.osd_message("VSR (vk-vsr) OFF")
    end
end

-- VSRの有効/無効を切り替える関数
local function toggle_vsr_state()
    vsr_enabled = not vsr_enabled
    apply_vsr() -- 状態を反転させた後、即座にフィルタを再適用
end

-- 【変更点2】スクリプトの初期化処理
-- 動画ファイルが読み込まれた時に、自動でVSR適用関数を呼び出す
mp.register_event("file-loaded", apply_vsr)

-- 【変更点3】プロパティの監視を常に有効にする
-- これにより、ウィンドウサイズ変更時などにもVSRの状態が正しく維持される
mp.observe_property("width", "native", apply_vsr)
mp.observe_property("height", "native", apply_vsr)
mp.observe_property("vf", "native", apply_vsr)

-- キーバインドを登録
mp.add_key_binding("ctrl+shift+u", "toggle-vsr", toggle_vsr_state)
