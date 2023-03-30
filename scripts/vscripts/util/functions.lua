-- put your fancy global functions here for you (and others) to use, i guess

-- Apparently entity indices take up the first 14 bits of an EHandle, need more testing to really verify this
function EHandleToHScript(iPawnId)
    return EntIndexToHScript(bit.band(iPawnId, 0x3FFF))
end

--Allow something like RunScriptCode "print(activator, caller)"
function RunScriptCodeWithActivator(hTarget, sCode, fDelay, hActivator, hCaller)
    local tScope = hTarget:GetOrCreatePrivateScriptScope()
    if tScope.AddActivatorCallerToScope == nil then
        tScope.AddActivatorCallerToScope = function(para)
            tScope.activator = para.activator;
            tScope.caller = para.caller;
        end
    end 
    DoEntFireByInstanceHandle(hTarget, "CallScriptFunction", "AddActivatorCallerToScope", fDelay, hActivator, hCaller)
    DoEntFireByInstanceHandle(hTarget, "RunScriptCode", sCode, fDelay, nil, nil)
    DoEntFireByInstanceHandle(hTarget, "RunScriptCode", "activator = nil; caller = nil", fDelay, nil, nil)
end

--Dump the contents of a table
function table.dump(tbl)
    for k, v in pairs(tbl) do
        print(k, v)
    end
end

-- shuffles positions of elements in an array
-- usable only for array type of tables (when keys are not strings)
function table.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- removes all instances of a given value
-- from a given table
function table.RemoveValue(tbl, value)
    for i = #tbl, 1, -1 do
        if tbl[i] == value then
            table.remove(tbl, i)
        end
    end
end