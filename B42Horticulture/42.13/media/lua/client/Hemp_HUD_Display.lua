-- Отображение статуса эффекта в HUD

local HempStatusHUD = ISPanel:derive("HempStatusHUD")

function HempStatusHUD:new(x, y)
    local o = ISPanel.new(self, x, y, 200, 50)
    o.backgroundColor = {0, 0, 0, 0.5}
    o.borderColor = {1, 0.5, 0.5, 1}
    return o
end

function HempStatusHUD:render()
    ISPanel.render(self)
    
    local player = getPlayer()
    if not player then return end
    
    local effect = player:getVariable("B42_HempMotionBlur")
    if not effect or not effect.isActive then return end
    
    local remainingTime = effect:getRemainingTime()
    local hours = math.floor(remainingTime / (60 * 1000))
    local minutes = math.floor((remainingTime % (60 * 1000)) / 1000)
    
    local text = string.format("Hemp Effect: %02d:%02d", hours, minutes)
    
    self:drawText(text, 10, 15, 1, 1, 1, 1, UIFont.Small)
end

function HempStatusHUD:update()
    ISPanel.update(self)
    
    local player = getPlayer()
    if not player then return end
    
    local effect = player:getVariable("B42_HempMotionBlur")
    if not effect or not effect.isActive then
        self:removeFromUIManager()
    end
end

-- Добавляем HUD при активации эффекта
local function showHempStatusHUD()
    local hud = HempStatusHUD:new(100, 100)
    getPlayer():getHud():addChild(hud)
end