local function require(module)
	local file = debug.getinfo(1).source
	local directory = file:sub(2,#file-12)
	-- TODO: _FILEDIRECTORY
	return getfenv().require(directory .. module)
end
local tweenObj = require("tween")
local tweens = {}

function tween(obj,properties,time,style)
    table.insert(tweens,tweenObj.new(time,obj,properties,style))
end
function numLerp(a,b,c)
    return a+(b-a)*c
end


local camshit = {zoom = getVar("defaultCamZoom")} -- work around for tweening camera zoom
local defaultZoom = getVar("defaultCamZoom");

local charSteps = {
    {step=1719,char='shadow-crazy'},
}
local zoomed=false;

local oldFocus = getVar"focus";

local oStep = curStep;
dad:changeCharacter("shadow-crazy") -- cache shadow-crazy
dad:changeCharacter('shadow')

function stepHit(step)
    if(not getOption"noChars")then
        local setChar='';
        for i = 1, #charSteps do
            local v= charSteps[i]
            local step = v.step;
            local char = v.char;
            if(curStep<step)then
                break;
            end
            setChar=char;
        end

        if(dad.curCharacter~=setChar and setChar~='')then
            dad:changeCharacter(setChar)
        end
        
        if(step==1719 and dad.curCharacter == 'shadow-crazy')then
            setVar("focus","dad")
            dad:playAnim("die")
        end

        if(step==1728)then
            setVar("focus", oldFocus)
        end

        if(step==2730)then
            setVar("focus",getVar"turn")
        end
    end

    if(step>=1719 and step<1984 and not zoomed and oldFocus ~= 'center')then
        zoomed=true;
        tween(camshit,{zoom=1.6},1.5,"inOutQuad")
    end
    if(step>=1984 and zoomed and oldFocus ~= 'center')then
        zoomed=false;
        tween(camshit,{zoom=defaultZoom*.85},1.5,"inOutQuad")
    end
    if(step==1989)then
        bf.disabledDance=true;
        bf:playAnim("fuckingdies")
    end
    if(step>=1984 and step<2016 and getVar"focus"~='bf')then
        setVar("focus","bf")
    end
    if(step>=2024 and getVar"focus"~='center')then
        setVar("focus","center")
    end
    for s = oStep, step do
        if(getOption"ruinMod")then
            if(s==448 or s==1215 or s==1728)then
                ruin(true)
            end
            if(s==704 or s==1472 or s==1984)then
                ruin(false)
            end
        end
    end
    oStep=step;
end

function update(elapsed)
    for i = #tweens,1,-1 do
        if(tweens[i]:update(elapsed))then
            table.remove(tweens,i)
        end
	end
    setVar("defaultCamZoom",camshit.zoom)
end