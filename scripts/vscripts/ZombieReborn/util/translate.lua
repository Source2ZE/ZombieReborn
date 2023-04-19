
g_TranslateTable = {}

function tr(text)
    local language = Convars:GetStr("zr_language")
    if not language or language == "" or language == "english" then
        return text
    end

    g_TranslateTable[language] = g_TranslateTable[language] or require("ZombieReborn.language." .. language)
    -- not found?
    if not g_TranslateTable[language] then
        print(string.format("Warning : translation for language %s not found", language))
        return text
    end
    return g_TranslateTable[language][text] or text
end