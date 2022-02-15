gf.visible=false;

function newSpriteLG(x,y,bg,graphic)
    local spr = newSprite(x,y,bg);
    spr:loadGraphic(graphic);
    return spr;
end

local smonk1 = newSprite(-1300, 625)
smonk1:setFrames("smoke")
smonk1:setScale(0.8)
smonk1.alpha = 0;
smonk1:addAnimByPrefix("smoke","Symbol 7",11.75);
smonk1:playAnim("smoke")
smonk1.scrollFactorX = 1;
smonk1.scrollFactorY = 1;

local smonk2 = newSprite(912.5, 625)
smonk2:setFrames("smoke")
smonk2:setScale(0.8)
smonk2.alpha = 0;
smonk2:addAnimByPrefix("smoke","Symbol 7",12.15);
smonk2:playAnim("smoke")
smonk2.flipX = true;
smonk2.scrollFactorX = 1;
smonk2.scrollFactorY = 1;

local smonk3 = newSprite(-1400, 450, true)
smonk3:setFrames("smoke")
smonk3:setScale(0.5)
smonk3.alpha = 0;
smonk3:addAnimByPrefix("smoke","Symbol 7",13.25);
smonk3:playAnim("smoke")
smonk3.scrollFactorX = 0.95;
smonk3.scrollFactorY = 0.95;


local smonk4 = newSprite(812.5, 450, true)
smonk4:setFrames("smoke")
smonk4:setScale(0.5)
smonk4.alpha = 0;
smonk4:addAnimByPrefix("smoke","Symbol 7",13.5);
smonk4:playAnim("smoke")
smonk4.flipX = true;
smonk4.scrollFactorX = 0.95;
smonk4.scrollFactorY = 0.95;

local smokeOverlay = newSpriteLG(0,0,false,'smokeoverlay');
smokeOverlay:screenCenter(XY)
smokeOverlay.scrollFactorX = 0;
smokeOverlay.scrollFactorY= 0;
smokeOverlay:setScale(2);
smokeOverlay.alpha=0;

local oStep = curStep;
function stepHit(cStep)
    for step = oStep+1, cStep do 
        if(step==1152)then
            if(getOption"ruinMod")then
                ruin(true)
            else
                smonk1.x = smonk1.x - 600;
                smonk2.x = smonk2.x + 600;
                smonk3.x = smonk3.x - 300;
                smonk4.x = smonk4.x + 300;
                
                smokeOverlay:tween({alpha = .35}, (stepCrochet * 64) / 1000, "quartInOut")

                smonk1:tween({x = smonk1.x + 600, alpha = 1}, (stepCrochet * 48) / 1000, "quadInOut");
                smonk2:tween({x = smonk2.x - 600, alpha = 1}, (stepCrochet * 48) / 1000, "quadInOut");
                smonk3:tween({x = smonk3.x + 300, alpha = 0.5}, (stepCrochet * 64) / 1000, "quadInOut");
                smonk4:tween({x = smonk4.x - 300, alpha = 0.5}, (stepCrochet * 64) / 1000, "quadInOut");
            end
        end
        
    end
    oStep = cStep;
end

modMgr:define("drunkC")
modMgr:set("drunkC",0)
modMgr:define("tipsyC")
modMgr:set("tipsyC",0)

modMgr:define("justHowHighAreYou")
modMgr:set("justHowHighAreYou",0)

modMgr:set("suddenOffset",100)

local swagWidth = 160 * .7
modMgr:set("justHowHighAreYou",25)

if(getOption'modchart')then
    modMgr:queueEase(1152,1220,"sudden",100,"quadOut")
    modMgr:queueEase(1152,1220,"suddenOffset",25,"quadOut")
    modMgr:queueEase(1152,1156,"tipsyC",25,"quadOut")
    modMgr:queueEase(1152,1156,"drunkC",25,"quadOut")
end

if(getOption"getHigh")then
    modMgr:queueEase(1152,1220,"justHowHighAreYou",100,"quadOut")
end

modMgr:set("flashR",128)
modMgr:set("flashG",128)
modMgr:set("flashB",128)

function update(elapsed)
    local time = songPosition / 1000

    for pN = 0, 1 do
        local drunkPerc = modMgr:get("drunkC",pN)
        local tipsyPerc = modMgr:get("tipsyC",pN)
        for col = 0, 3 do
            modMgr:set("transform" .. col .. "X",drunkPerc * (math.cos((time + col*0.2)) * swagWidth*0.4))
            modMgr:set("transform" .. col .. "Y",tipsyPerc * (math.cos((time*1.2 + col*1.8)) * swagWidth*0.5))
        end
    end

    if(setHighness and getOption"getHigh")then
        local percent = modMgr:get("justHowHighAreYou",0)
        setHighness(percent);
    elseif(setHighness)then
        setHighness(0)
    end

end