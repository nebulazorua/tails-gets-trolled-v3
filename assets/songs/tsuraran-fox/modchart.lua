local oStep = curStep;
function stepHit(nStep)
    if(getOption"ruinMod")then
        for step = oStep, nStep do
            if(step==896 or step==1536)then
                ruin(true)
            elseif(step==1280 or step==2058)then
                ruin(false);
            end
        end
    end
    oStep=nStep;
end