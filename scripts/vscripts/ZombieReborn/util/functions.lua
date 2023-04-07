-- put your fancy global functions here for you (and others) to use, i guess

-- Apparently entity indices take up the first 14 bits of an EHandle, need more testing to really verify this
function EHandleToHScript(iPawnId)
    return EntIndexToHScript(bit.band(iPawnId, 0x3FFF))
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
        local j = RandomInt(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function table.size(tbl)
    local getN = 0
    for _ in pairs(tbl) do
        getN = getN + 1
    end
    return getN
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
