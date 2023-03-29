-- put your fancy global functions here for you (and others) to use, i guess

-- shuffles positions of elements in an array
-- usable only for array type of tables (when keys are not strings)
function table.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end
