local function require(module)
	local file = debug.getinfo(1).source
	local directory = file:sub(2,#file-12)
	-- TODO: _FILEDIRECTORY
	return getfenv().require(directory .. module)
end
local tweenObj = require("tween")
local tweens = {}

local shit = {

}

function tween(obj,properties,time,style)
    table.insert(tweens,tweenObj.new(time,obj,properties,style))
end
function numLerp(a,b,c)
    return a+(b-a)*c
end

local funcQueue = {}
local callbacks = {}

function define(name,def)
    modMgr:define(name)
    modMgr:set(name,def)
end

define("haloRadiusX",0)
define("haloRadiusZ",0)
define("haloSpeed",0)

local defaultZoom = getVar"defaultCamZoom"

define("hudCamZoom",1)
define("gameCamZoom",getVar("defaultCamZoom"))
define("noteCamZoom",1)

define("hudCamAngle",0)
define("gameCamAngle",0)
define("noteCamAngle",0)

function queueFunc(step, callback)
    table.insert(funcQueue, {step,callback})
end

local function queueFunc2(sStep, eStep, callback)
    table.insert(callbacks,{sStep,eStep,callback})
end

local function queueFuncB(sBeat, eBeat, callback)
    table.insert(callbacks,{sBeat*4,eBeat*4,callback})
end

function queueSetB(startB,...)
    modMgr:queueSet(startB*4,...)
end

function queueEaseLS(start,len,...)
    modMgr:queueEase(start,start+len,...)
end

function queueEaseB(startB,endB,...)
    modMgr:queueEase(startB*4,endB*4,...)
end

function queueEaseLB(start,len,...)
    queueEaseB(start,start+len,...)
end


modMgr:set('suddenOffset',55)
modMgr:set('hiddenOffset',-25)

local stepCrochet = stepCrochet or ((60 / bpm)*1000) / 4

function dadNoteHit(direction, noteTime, currentTime, animationName, isHold)

end

function goodNoteHit(direction, noteTime, currentTime, isHold)

end


function update(elapsed)
    for i = #tweens,1,-1 do
        if(tweens[i]:update(elapsed))then
            table.remove(tweens,i)
        end
	end

    local gameZoom = modMgr:get("gameCamZoom",0)*100

    notesCam.angle = modMgr:get("noteCamAngle",0)*100
    receptorCam.angle = modMgr:get("noteCamAngle",0)*100
    holdCam.angle = modMgr:get("noteCamAngle",0)*100
    HUDCam.angle = modMgr:get("hudCamAngle",0)*100

    notesCam.zoom = modMgr:get("noteCamZoom",0)*100
    receptorCam.zoom = modMgr:get("noteCamZoom",0)*100
    holdCam.zoom = modMgr:get("noteCamZoom",0)*100
    HUDCam.zoom = modMgr:get("hudCamZoom",0)*100
    setVar("defaultCamZoom",gameZoom)

    if(#callbacks>0)then
		for i=#callbacks,1,-1 do
			local a = callbacks[i]
			if(curDecStep > a[1] and curDecStep < a[2])then
				a[3](curDecStep)
			end
            if(curDecStep > a[2])then
                table.remove(callbacks,i)
            end
		end
	end


    
end

function everyBeat(sStep,eStep,callback)
    for step = sStep, eStep do
        if(step%4==0)then
            local beat = step/4;
            callback(step,beat)
        end
    end
end

function everySecondBeat(sStep,eStep,callback)
    for step = sStep, eStep do
        if(step%8==0)then
            local beat = step/4;
            callback(step,beat)
        end
    end
end


local introBFNotes = {
    144,
    148,
    152,
    156,
    160,

    176,
    180,
    184,
    188,
    192,

    208,
    212,
    216,
    220,
    224,

    1200,
    1204,
    1208,
    1212,
    1216,

    1232,
    1236,
    1240,
    1244,
    1248,

    1264,
    1268,
    1272,
    1276,
    1280,

    1328,
    1332,
    1336,
    1340,
    1344,

    1360,
    1364,
    1368,
    1372,
    1376,

    1392,
    1396,
    1400,
    1404,
    1408
}

if(getOption"modcharts")then
for i = 1,#introBFNotes do
    local step = introBFNotes[i]
    --local shit = i >= 6 and i <= 10 and 1 or -1;
    local shit = i%2==1 and -1 or 1;
    modMgr:queueSet(step,'transformX',25*shit)
    modMgr:queueEase(step,step+4,'transformX',0,'quartOut')
    
    --[[queueFunc(step,function()
        camshit.hudZoom = 1.1;
        camshit.noteZoom = 1.1;
        camshit.noteAngle = 5*shit;
        tween(camshit,{noteAngle=0, noteZoom=1, hudZoom=1},(stepCrochet*4) / 1000,"outQuart")
    end)]]
    modMgr:queueSet(step,"hudCamZoom",1.1)
    modMgr:queueSet(step,"noteCamZoom",1.1)
    modMgr:queueSet(step,"noteCamAngle",5*shit)

    modMgr:queueEase(step,step+4,"noteCamAngle",0,'quartOut')
    modMgr:queueEase(step,step+4,"hudCamZoom",1,'quartOut')
    modMgr:queueEase(step,step+4,"noteCamZoom",1,'quartOut')
end

function introPart(start)
    local start = start + 20;
    modMgr:queueSet(start,'confusion',360)
    modMgr:queueEase(start,start+6,'confusion',0,'quadOut')

    modMgr:queueEase(start,start+6,'reverse',100,'quadOut')

    modMgr:queueSet(start+32,'confusion',-360)
    modMgr:queueEase(start+32,start+38,'confusion',0,'quadOut')
    modMgr:queueEase(start+32,start+38,'reverse',0,'quadOut')

    modMgr:queueSet(start+64,'confusion',360,0)
    modMgr:queueEase(start+64,start+68,'confusion',0,'quadOut',0)
    modMgr:queueSet(start+64,'confusion',-360,1)
    modMgr:queueEase(start+64,start+68,'confusion',0,'quadOut',1)

    modMgr:queueEase(start+64,start+68,'opponentSwap',100,'quadOut')

    modMgr:queueSet(start+128,'confusion',360)
    modMgr:queueEase(start+128,start+134,'confusion',0,'quadOut')

    modMgr:queueEase(start+128,start+134,'reverse',100,'quadOut')

    modMgr:queueSet(start+160,'confusion',-360)
    modMgr:queueEase(start+160,start+166,'confusion',0,'quadOut')
    modMgr:queueEase(start+160,start+166,'reverse',0,'quadOut')


end

-- first intro part

introPart(144)
modMgr:queueSet(356,'confusion',-360,0)
modMgr:queueEase(356,362,'confusion',0,'quadOut',0)

modMgr:queueSet(356,'confusion',360,1)
modMgr:queueEase(356,362,'confusion',0,'quadOut',1)
modMgr:queueEase(356,362,'opponentSwap',50,'quadOut')
modMgr:queueEase(356,362,'alpha',75,'quadOut', 1)

-- cool solo part
modMgr:queueEase(528,534,'flip',-125,'quadOut', 1)
modMgr:queueEase(528,534,'invert',125,'quadOut', 1)

-- duet kinda?
modMgr:queueEase(592,596,'flip',0,'quadOut', 1)
modMgr:queueEase(592,596,'invert',0,'quadOut', 1)

local noteSize = 160 * 0.7;

modMgr:queueEase(592,596,"transform0X",-noteSize * 2,'quadOut', 1)
modMgr:queueEase(592,596,"transform0X",-noteSize,'quadOut', 0)
modMgr:queueEase(592,596,"transform1X",-noteSize ,'quadOut', 1)
modMgr:queueEase(592,596,"transform1X",0 ,'quadOut', 0)
modMgr:queueEase(592,596,"transform2X",0 ,'quadOut', 1)
modMgr:queueEase(592,596,"transform2X",noteSize ,'quadOut', 0)
modMgr:queueEase(592,596,"transform3X",noteSize ,'quadOut', 1)
modMgr:queueEase(592,596,"transform3X",noteSize*2 ,'quadOut', 0)

modMgr:queueEase(592,596,'alpha',0,'quadOut', 1)

-- cool part with the bursts

modMgr:queueEase(656,660,'opponentSwap',0,'quadOut')

modMgr:queueEase(656,660,'flip',0,'quadOut', 1)
modMgr:queueEase(656,660,'invert',0,'quadOut', 1)

modMgr:queueEase(656,660,"transform0X",0,'quadOut', 1)
modMgr:queueEase(656,660,"transform0X",0,'quadOut', 0)
modMgr:queueEase(656,660,"transform1X",0 ,'quadOut', 1)
modMgr:queueEase(656,660,"transform1X",0 ,'quadOut', 0)
modMgr:queueEase(656,660,"transform2X",0 ,'quadOut', 1)
modMgr:queueEase(656,660,"transform2X",0 ,'quadOut', 0)
modMgr:queueEase(656,660,"transform3X",0 ,'quadOut', 1)
modMgr:queueEase(656,660,"transform3X",0 ,'quadOut', 0)


local shit1 = 1;
everySecondBeat(656,912,function(step,beat)
    shit1 = shit1 * -1;
    modMgr:queueSet(step,'drunk',-50)
    modMgr:queueSet(step,'tipsy',50)
    modMgr:queueSet(step,'flip',15*shit1)
    modMgr:queueSet(step,'tipsySpeed',math.cos(step)*50)
    modMgr:queueSet(step,'drunkSpeed',math.cos(step)*35)
    modMgr:queueSet(step,'confusion',15 * shit1)
    modMgr:queueEase(step,step+4,'drunk',0,'quartInOut')
    modMgr:queueEase(step,step+4,'tipsy',0,'quartInOut')
    modMgr:queueEase(step,step+4,'flip',0,'quartInOut')
    modMgr:queueEase(step,step+2,'confusion',0,'quartInOut')
end)

-- kade wave :D

queueFunc2(912,1168,function(step)
    local beat = step/4;

    for col = 0,3 do
        local mu = 1--col%2==0 and -1 or 1;
        modMgr:set("transform" .. col .. "X",32 * math.sin((beat + col*0.25) * 0.25 * math.pi));
        modMgr:set("transform" .. col .. "Y",32 * mu * math.cos((beat + col*.25) * 0.25 * math.pi));
    end
end)

for i = 0, 3 do
    modMgr:queueEase(1168, 1170, 'transform' .. i .. 'X', 0, 'quadOut')
    modMgr:queueEase(1168, 1170, 'transform' .. i .. 'Y', 0, 'quadOut')
    modMgr:queueEase(1168, 1170, 'transform' .. i .. 'Z', 0, 'quadOut')
end

modMgr:queueEase(1172, 1175, 'flip', 100, 'quadOut')
modMgr:queueEase(1180, 1183, 'flip', 0, 'quadOut')
modMgr:queueEase(1180, 1183, 'invert', 100, 'quadOut')
modMgr:queueEase(1188, 1191, 'invert', 0, 'quadOut')

-- second intro part
introPart(1200)
modMgr:queueSet(1412,'confusion',-360,1)
modMgr:queueEase(1412,1418,'confusion',0,'quadOut',1)

modMgr:queueSet(1412,'confusion',360,0)
modMgr:queueEase(1412,1418,'confusion',0,'quadOut',0)
modMgr:queueEase(1412,1418,'opponentSwap',0,'quadOut')

modMgr:queueEase(1196, 1200, 'hidden', 85, 'quadOut')

modMgr:queueSet(1474, 'hidden', 0)

modMgr:queueEase(1612, 1616, 'sudden', 85, 'quadOut')
modMgr:queueEase(1852, 1860, 'sudden', 0, 'quadOut')

-- coolest duet part ever
modMgr:queueEase(1854,1860,'tipsy',50,'quadOut')

modMgr:queueSet(1854,'confusion',-360,0)
modMgr:queueEase(1854,1860,'confusion',0,'quadOut',0)

modMgr:queueSet(1854,'confusion',360,1)
modMgr:queueEase(1854,1860,'confusion',0,'quadOut',1)
modMgr:queueEase(1854,1860,'opponentSwap',50,'quadOut')
modMgr:queueEase(1854,1860,'alpha',85,'quadOut', 1)

modMgr:queueSet(2016,'confusion',360,0)
modMgr:queueEase(2016,2020,'confusion',0,'quadOut',0)

modMgr:queueSet(2016,'confusion',-360,1)
modMgr:queueEase(2016,2020,'confusion',0,'quadOut',1)
modMgr:queueEase(2016,2020,'opponentSwap',0,'quadOut')
modMgr:queueEase(2016,2020,'alpha',0,'quadOut', 1)

modMgr:queueEase(2016,2020,'tipsy',0,'quadOut')

-- idk
local alt = 0;
for step = 1970, 1980, 2 do
    alt = alt + 1
    modMgr:queueEase(step,step+2,"confusion0",(alt%2) *  -90,'quartOut')
    modMgr:queueEase(step,step+2,"confusion1",(alt%2) *  90,'quartOut')
    modMgr:queueEase(step,step+2,"confusion2",(alt%2) *  -90,'quartOut')
    modMgr:queueEase(step,step+2,"confusion3",(alt%2) *  90,'quartOut')
    modMgr:queueEase(step,step+2,"invert",(alt%2) * 100,'quartOut')
end


-- 2nd cool part w/ the bursts
local spinBursts = {
    {2018,0,1},
    {2029,1,1},
    {2034,0,1},
    {2050,0,1},
    {2061,1,1},

    {2064,2,1},
    {2066,3,1},

    {2082,0,1},
    {2093,1,1},
    {2098,0,1},
    {2114,0,1},
    {2125,1,1},

    {2128,2,1},
    {2130,3,1},
}


for i = 1,#spinBursts do
    local burst = spinBursts[i]
    local step = (burst[1] - 2016)
    local type = burst[2]
    local pn = burst[3]

    table.insert(spinBursts, {2144 + step, type, 0})
    table.insert(spinBursts, {656 + step, type, 1})
    table.insert(spinBursts, {784 + step, type, 0})
end

local offsets = {
    [0] = {0, 0.5, 1, 2},
    [1] = {0, 1, 1.5, 2},
    [2] = {0, 0.5, 1},
    [3] = {0, 0.5, 1},
}

local receptors = {
    [0] = {3, 2, 1, 0},
    [1] = {3, 2, 1, 0},
    [2] = {3, 2, 1},
    [3] = {2, 1, 0}
}

for i = 1,#spinBursts do
    local burst = spinBursts[i]
    local step = burst[1]
    local type = burst[2]
    local pn = burst[3]

    print(step,type,pn)
    
    local affectedOffsets = offsets[type]
    local affectedReceptors = receptors[type]

    if(step>=2016)then
        queueFunc(step,function()
            for _,v in next, {gameCam, HUDCam, notesCam, receptorCam, holdCam} do
                v:shake(.025,.1,true)
            end
        end)
    end
    for i = 1,#affectedOffsets do
        local qStep = step + affectedOffsets[i]
        modMgr:queueSet(qStep, 'confusion' .. affectedReceptors[i], 360, pn)
        modMgr:queueEase(qStep, qStep+4, "confusion" .. affectedReceptors[i],0,'quadOut',pn)

        modMgr:queueSet(qStep, 'transform' .. affectedReceptors[i]..'Z', -0.2, pn)
        modMgr:queueEase(qStep, qStep+4, "transform" .. affectedReceptors[i]..'Z',0,'quadOut',pn)

    end
end

-- end
modMgr:queueEase(2268, 2272, "opponentSwap",50,'quadOut', 1)
modMgr:queueEase(2268, 2272, "flip",50, 'quadOut', 1)

modMgr:queueEase(2272, 2308, 'haloRadiusX', 128, 'quartOut')
modMgr:queueEase(2272, 2308, 'haloRadiusZ', .1, 'quartOut')
modMgr:queueEase(2272, 2308, 'haloSpeed', 1, 'quartOut')
modMgr:queueEase(2308, 2340, 'alpha', 100, 'linear', 1)

modMgr:queueEase(2308, 2354, 'haloRadiusX', 2048, 'quadIn')
modMgr:queueEase(2308, 2354, 'haloRadiusZ', .8, 'quadIn')
modMgr:queueEase(2308, 2354, 'haloSpeed', 3, 'quadIn')

if(getOption"downScroll")then
    for col = 0, 3 do
        modMgr:queueEase(2270 + (col * .5),2280 + (col * .5), 'transform'..col..'Y', -1280, 'backIn', 0)
    end
else
    for col = 0, 3 do
        modMgr:queueEase(2270 + (col * .5),2280 + (col * .5), 'transform'..col..'Y', 1280, 'backIn', 0)
    end
end
queueFunc2(2272,2364,function(step)
    local beat = step/4;
    for col = 0,3 do
        local speed = modMgr:get("haloSpeed", 0) * 100
        local input = (col+1 + beat) * math.rad(360 / 4) 
        local radiusX = modMgr:get("haloRadiusX", 0) * 100;
        local radiusZ = modMgr:get("haloRadiusZ", 0) * 100;
        modMgr:set("transform" .. col .. "X",radiusX * math.sin(input) * speed,1)
        modMgr:set("transform" .. col .. "Z",radiusZ * math.cos(input) * speed,1)
    end
end)
end
function stepHit(step)
    for i = #funcQueue,1,-1 do
        local v = funcQueue[i]
        if(v[1]<=step)then
            v[2](step)
            table.remove(funcQueue,i)
        end
    end
end
