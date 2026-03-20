-- ==========================================
-- OBFUSCATEUR LUA (Générateur)
-- ==========================================

-- Fonction interne pour encoder en Base64
local function toBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Fonction principale qui génère le code obfusqué
local function Obfuscate(inputCode)
    -- 1. Encodage de tout le code source pour cacher la logique
    local encoded = toBase64(inputCode)
    
    -- 2. Découpage en très petits morceaux pour créer le dictionnaire obfusqué
    local chunks = {}
    for i = 1, #encoded, 8 do
        local chunk = encoded:sub(i, i + 7)
        -- Ajout du "bruit" visuel similaire à ton fichier (.txt)
        table.insert(chunks, "`" .. chunk .. "=`")
    end
    
    local arrayStr = table.concat(chunks, ",")

    -- 3. Création du Wrapper de décodage (C'est ce qui sera exécuté à la fin)
    -- On recrée la structure return(function(...) trouvée dans gfhythjty.txt
    local wrapper = [[
return(function(...)
    local k={]] .. arrayStr .. [[}
    local w = ""
    for i=1, #k do
        -- Nettoyage du bruit ajouté pendant l'obfuscation
        local chunk = tostring(k[i]):gsub("=$", ""):gsub("^`", ""):gsub("`$", "")
        w = w .. chunk
    end
    
    -- Fonction de déchiffrement embarquée
    local function dec(data)
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end
    
    -- Exécution du code déchiffré
    local d = dec(w)
    local f = loadstring(d) or load(d)
    if f then
        return f(...)
    end
end)()
]]
    return wrapper
end

-- ==========================================
-- TEST DE L'OBFUSCATEUR
-- ==========================================

-- Mets ici le code que tu veux obfusquer :
local monCodeAProteger = [[
print("Salut, je suis un script totalement obfusqué !")
local a = 500
local b = 250
print("Le code secret est : " .. (a + b))
]]

-- Lancement de l'obfuscation
local resultatFinal = Obfuscate(monCodeAProteger)

-- Affiche le gros bloc de code obfusqué (incompréhensible)
print(resultatFinal)
