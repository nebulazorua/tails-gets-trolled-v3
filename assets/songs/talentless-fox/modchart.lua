local oStep = curStep;
function stepHit(nStep)
    if(getOption"ruinMod")then
        for step = oStep, nStep do
            if(step==896)then
                ruin(true)
            elseif(step==1274)then
                ruin(false);
            end
        end
    end
    oStep=nStep;
end