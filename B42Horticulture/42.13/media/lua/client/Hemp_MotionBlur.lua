-- Мод B42 Horticulture - Hemp Motion Blur Effect
-- Эффект очень сильного motion-blur на 2 игровых часа после употребления hemp

require "ISUI/ISPanel"

-- === КОНСТАНТЫ ===
local HEMP_DURATION_GAME_HOURS = 2
local HEMP_DURATION_MS = HEMP_DURATION_GAME_HOURS * 60 * 1000 -- 2 часа в миллисекундах
local MOTION_BLUR_INTENSITY = 0.85 -- Очень сильный blur (0.0 - 1.0)
local BLUR_FRAME_SAMPLES = 12 -- Количество кадров для blur эффекта

-- === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ===
local activeHempEffects = {}

-- === ОСНОВНОЙ КЛАСС ЭФФЕКТА ===
local HempMotionBlurEffect = {}

function HempMotionBlurEffect:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.isActive = false
    o.startTime = 0
    o.duration = HEMP_DURATION_MS
    o.intensity = MOTION_BLUR_INTENSITY
    o.frameBuffer = {} -- Буфер предыдущих кадров для blur
    return o
end

function HempMotionBlurEffect:activate()
    self.startTime = getGameTime():getTimeInMillis()
    self.isActive = true
end

function HempMotionBlurEffect:update()
    if not self.isActive then return end
    
    local currentTime = getGameTime():getTimeInMillis()
    local elapsedTime = currentTime - self.startTime
    
    if elapsedTime >= self.duration then
        self:deactivate()
    end
end

function HempMotionBlurEffect:deactivate()
    self.isActive = false
    self.frameBuffer = {}
end

function HempMotionBlurEffect:getProgress()
    if not self.isActive then return 0 end
    
    local currentTime = getGameTime():getTimeInMillis()
    local elapsedTime = currentTime - self.startTime
    return math.min(elapsedTime / self.duration, 1.0)
end

function HempMotionBlurEffect:getRemainingTime()
    if not self.isActive then return 0 end
    
    local currentTime = getGameTime():getTimeInMillis()
    local elapsedTime = currentTime - self.startTime
    local remaining = self.duration - elapsedTime
    
    return math.max(remaining, 0)
end

-- === ЭКРАН ЭФФЕКТА ===
local MotionBlurScreenPanel = ISPanel:derive("MotionBlurScreenPanel")

function MotionBlurScreenPanel:new(x, y, width, height, player, effect)
    local o = ISPanel.new(self, x, y, width, height)
    o.player = player
    o.effect = effect
    o.backgroundColor = {0, 0, 0, 0}
    o.screenTexture = nil
    return o
end

function MotionBlurScreenPanel:render()
    ISPanel.render(self)
    
    if not self.effect or not self.effect.isActive then
        return
    end
    
    -- Получаем интенсивность эффекта
    local intensity = self.effect.intensity
    local progress = self.effect:getProgress()
    
    -- Волнообразная интенсивность для более органичного motion blur
    local wave = math.sin(progress * 2 * 3.14159) * 0.3 + 0.7
    local finalIntensity = intensity * wave
    
    -- Рисуем полупрозрачный overlay для усиления эффекта размытия
    self:drawRect(0, 0, self.width, self.height, finalIntensity * 0.15, 0.1, 0.15, 0.8)
end

function MotionBlurScreenPanel:update()
    ISPanel.update(self)
    
    if self.effect then
        self.effect:update()
        
        -- Если эффект закончился, удаляем панель
        if not self.effect.isActive then
            self:removeFromUIManager()
        end
    end
end

-- === ПРИМЕНЕНИЕ ЭФФЕКТА К ПЕРСОНАЖУ ===
local function applyHempMotionBlurEffect(player)
    if not player then return end
    
    -- Проверяем, не активен ли уже эффект
    if activeHempEffects[player:getCharacterIndex()] and 
       activeHempEffects[player:getCharacterIndex()].isActive then
        return
    end
    
    -- Создаём новый эффект
    local effect = HempMotionBlurEffect:new()
    effect:activate()
    
    -- Сохраняем эффект
    activeHempEffects[player:getCharacterIndex()] = effect
    player:setVariable("B42_HempMotionBlur", effect)
    
    -- Показываем визуальный эффект на экране
    if player == getPlayer() then
        showMotionBlurPanel(player, effect)
    end
end

-- === ВИЗУАЛИЗАЦИЯ НА ЭКРАНЕ ===
function showMotionBlurPanel(player, effect)
    if player ~= getPlayer() then return end
    
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    
    local panel = MotionBlurScreenPanel:new(0, 0, screenWidth, screenHeight, player, effect)
    panel:setAnchorLeft(true)
    panel:setAnchorRight(true)
    panel:setAnchorTop(true)
    panel:setAnchorBottom(true)
    
    getPlayer():getHud():addChild(panel)
end

-- === ХУКИ СОБЫТИЙ ===

-- Событие при употреблении пищи/предмета
local function onItemConsumed(itemType, player)
    -- Проверяем, является ли это hemp
    if itemType == "Hemp" or itemType == "HempBud" or 
       (itemType and itemType:contains("hemp")) then
        applyHempMotionBlurEffect(player)
    end
end

-- Обновление эффектов каждый тик
local function onPlayerUpdate(player)
    if not player then return end
    
    local effect = player:getVariable("B42_HempMotionBlur")
    if effect then
        effect:update()
        
        -- Если эффект активен и это основной игрок, показываем время оставшегося эффекта
        if effect.isActive and player == getPlayer() then
            local remainingTime = effect:getRemainingTime()
            -- Можно добавить вывод в HUD здесь
        end
    end
end

-- Регистрируем события
Events.OnPlayerUpdate.Add(onPlayerUpdate)

-- События для различных типов потребления
Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldObjects, test)
    -- Обработка потребления через контекстное меню
end)

-- === ЭКСПОРТИРУЕМ ФУНКЦИИ ===
HempMotionBlurModule = {
    applyEffect = applyHempMotionBlurEffect,
    HempMotionBlurEffect = HempMotionBlurEffect
}