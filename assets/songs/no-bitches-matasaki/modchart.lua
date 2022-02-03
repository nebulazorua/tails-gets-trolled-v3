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

dad:changeCharacter("dripsonic-forced") -- cache dripsonic-forced
dad:changeCharacter("dripsonic-mad") -- cache dripsonic-mad
dad:changeCharacter('dripsonic')

local camshit = {zoom = getVar("defaultCamZoom")} -- work around for tweening camera zoom
local defaultZoom = getVar("defaultCamZoom");

local charSteps = {
    {step=844,char='dripsonic-mad'},
    {step=880,char='dripsonic'},
    {step=1152,char='dripsonic-mad'},
    {step=1408,char='dripsonic-forced'},
    {step=1664,char='dripsonic-mad'},
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

    if(step>=1664 and step<1920 and not zoomed)then
        zoomed=true;
        tween(camshit,{zoom=1.6},1.5,"inOutQuad")
    end
    if(step>=1920 and zoomed)then
        zoomed=false;
        tween(camshit,{zoom=defaultZoom},1.5,"inOutQuad")
    end
    
    for s = oStep, step do
        if(getOption"ruinMod")then
            if(s==512 or s==1408)then
                ruin(true)
            end
            if(s==768 or s==1920)then
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