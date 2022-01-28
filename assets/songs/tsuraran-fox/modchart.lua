local oStep = curStep;
function newSpriteLG(x,y,bg,graphic)
    local spr = newSprite(x,y,bg);
    spr:loadGraphic(graphic);
    return spr;
end

local smonk1 = newSprite(-1500, 665, true)
smonk1:setFrames("smoke")
smonk1:setScale(0.8)
smonk1.alpha = 0;
smonk1:addAnimByPrefix("smoke","Symbol 7",11.75);
smonk1:playAnim("smoke")
smonk1.scrollFactorX = 1.025;
smonk1.scrollFactorY = 1.025;
smonk1:changeLayer('boyfriend')

local smonk2 = newSprite(712.5, 665, true)
smonk2:setFrames("smoke")
smonk2:setScale(0.8)
smonk2.alpha = 0;
smonk2:addAnimByPrefix("smoke","Symbol 7",12.15);
smonk2:playAnim("smoke")
smonk2.flipX = true;
smonk2.scrollFactorX = 1.025;
smonk2.scrollFactorY = 1.025;
smonk2:changeLayer('boyfriend')

local overlay = newSpriteLG(-650,-200,false,'spotlight');
overlay.scrollFactorX = 1;
overlay.alpha = 0;
overlay.scrollFactorY= 1;
function define(name,def)
    modMgr:define(name)
    modMgr:set(name,def)
end
local funcQueue = {}

function queueFunc(step, callback)
    table.insert(funcQueue, {step,callback})
end
 
local defaultZoom = getVar"defaultCamZoom";
define("gameCamZoom",defaultZoom)
define("spotlightAlpha",0)
define("justHowHighAreYou",0)


if(not getOption"ruinMod")then
    modMgr:queueEase(1536,1536+16,"spotlightAlpha",100,"quartOut")
    modMgr:queueEase(1536,1536+16,"gameCamZoom",defaultZoom*1.4,"quartOut")
    modMgr:queueEase(1536,1536+16,"justHowHighAreYou",35,"quartOut")

    modMgr:queueEase(1664,1664+16,"gameCamZoom",defaultZoom,"quartOut")
    modMgr:queueEase(1664,1664+16,"spotlightAlpha",0,"quartOut")
    modMgr:queueEase(1664,1664+16,"justHowHighAreYou",15,"quartOut")
    
    modMgr:queueEase(1936,1936+16,"justHowHighAreYou",0,"quartOut")

    
    queueFunc(1536,function()
        smonk1.x = smonk1.x - 600;
        smonk2.x = smonk2.x + 600;

        smonk1:tween({x = smonk1.x + 600, alpha = 1}, (stepCrochet * 32) / 1000, "quadInOut");
        smonk2:tween({x = smonk2.x - 600, alpha = 1}, (stepCrochet * 32) / 1000, "quadInOut");

        dad:tweenColor(-1, getVar("cancerColors")[1], (stepCrochet*16)/1000, "quartOut")
        bf:tweenColor(-1, getVar("cancerColors")[1], (stepCrochet*16)/1000, "quartOut")
        gf:tweenColor(-1, getVar("cancerColors")[1], (stepCrochet*16)/1000, "quartOut")
    end)
    queueFunc(1936,function()

        smonk1:tween({x = smonk1.x - 600, alpha = 0}, (stepCrochet * 32) / 1000, "quadInOut");
        smonk2:tween({x = smonk2.x + 600, alpha = 0}, (stepCrochet * 32) / 1000, "quadInOut");

        dad:tweenColor(dad:getProperty"color", -1, (stepCrochet*16)/1000, "quartOut")
        bf:tweenColor(bf:getProperty"color", -1, (stepCrochet*16)/1000, "quartOut")
        gf:tweenColor(gf:getProperty"color", -1, (stepCrochet*16)/1000, "quartOut")
    end)
end
function stepHit(nStep)
    for step = oStep, nStep do
        if(getOption"ruinMod")then
            if(step==896 or step==1536)then
                ruin(true)
            elseif(step==1280 or step==2058)then
                ruin(false);
            end
        end
    end
    for i = #funcQueue,1,-1 do
        local v = funcQueue[i]
        if(v[1]<=nStep)then
            v[2](nStep)
            table.remove(funcQueue,i)
        end
    end
    oStep=nStep;
end

function update(elapsed)
    overlay.alpha = modMgr:get("spotlightAlpha",0);

    local gameZoom = modMgr:get("gameCamZoom",0)*100

    setVar("defaultCamZoom",gameZoom)

    if(setHighness and getOption"getHigh")then
        local percent = modMgr:get("justHowHighAreYou",0)
        setHighness(percent);
    elseif(setHighness)then
        setHighness(0)
    end

end