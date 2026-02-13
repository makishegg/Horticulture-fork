-- Интеграция эффекта с системой потребления предметов

-- Хук при потреблении предмета через прямое использование
local function onConsumeItem(player, item)
    if not player or not item then return end
    
    local itemType = item:getType()
    local itemName = item:getName()
    
    -- Проверяем различные варианты названия hemp
    if itemType == "Hemp" or 
       itemName:contains("Hemp") or 
       itemName:contains("hemp") or
       itemType == "HempBud" then
        
        HempMotionBlurModule.applyEffect(player)
        
        print("HempMotionBlur: Эффект применён! Длится 2 часа.")
    end
end

-- Для совместимости с различными системами модов
Events.OnEat.Add(function(player, item, percent)
    onConsumeItem(player, item)
end)

Events.OnDrink.Add(function(player, item)
    onConsumeItem(player, item)
end)

-- Дополнительно проверяем через инвентарь
Events.OnPlayerUpdate.Add(function(player)
    -- Проверяем, есть ли в инвентаре hemp и применяем эффект при использовании
    if player and player:isAlive() then
        -- Логика может быть расширена в зависимости от системы мода
    end
end)