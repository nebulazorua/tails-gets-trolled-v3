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

dad:changeCharacter("shadow-crazy") -- cache shadow-crazy
dad:changeCharacter('shadow')

local camshit = {zoom = getVar("defaultCamZoom")} -- work around for tweening camera zoom
local defaultZoom = getVar("defaultCamZoom");

local charSteps = {
    {step=1720,char='shadow-crazy'},
}
local zoomed=false;

local oStep = curStep;
function stepHit(step)
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
        print(setChar)
        dad:changeCharacter(setChar)
    end

    if(step>=1727 and step<1984 and not zoomed)then
        zoomed=true;
        tween(camshit,{zoom=1.6},1.5,"inOutQuad")
    end
    if(step>=1984 and zoomed)then
        zoomed=false;
        tween(camshit,{zoom=defaultZoom},1.5,"inOutQuad")
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