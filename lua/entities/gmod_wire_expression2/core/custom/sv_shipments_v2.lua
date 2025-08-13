------------------------------------------------------
--    _____ _     _                            _       --
--   / ____| |   (_)                          | |      --
--  | (___ | |__  _ _ __  _ __ ___   ___ _ __ | |_ ___ --
--   \___ \| '_ \| | '_ \| '_ ` _ \ / _ \ '_ \| __/ __|--
--   ____) | | | | | |_) | | | | | |  __/ | | | |_\__ \--
--  |_____/|_| |_|_| .__/|_| |_| |_|\___|_| |_|\__|___/--
--                 | |                                 --
--                 |_|                Rewrite          --
--                        Original by TylerB           --
--                    Modernized by Liam               --
------------------------------------------------------

local EXTENSION_NAME = "Shipments E2 Extension"
local EXTENSION_VERSION = "2.0.0"
local EXTENSION_AUTHOR = "TylerB (Original), Liam (2025 Rewrite)"

-- Performance optimizations
local IsValid = IsValid
local IsEntity = IsEntity
local pairs = pairs
local ipairs = ipairs
local string_lower = string.lower
local string_format = string.format
local table_Copy = table.Copy

-- Cache for shipment lookups to improve performance
local shipment_cache = {}
local cache_time = {}

-- Get CustomShipments table safely
local function getCustomShipments()
    return CustomShipments or DarkRP and DarkRP.getShipments() or {}
end

-- Default broken shipment structure (more comprehensive)
local BROKEN_SHIPMENT = {
    amount = -1,
    price = -1,
    pricesep = -1,
    noship = false,
    entity = "invalid_shipment",
    model = "models/error.mdl",
    separate = false,
    name = "Invalid Shipment",
    -- New fields for extended functionality
    category = "Unknown",
    description = "Invalid or non-existent shipment",
    allowed = {},
    customCheck = nil,
    sortOrder = 999999
}

-- Validation functions
local function isValidShipmentEntity(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    return class == "spawned_shipment"
end

-- Enhanced table lookup with caching
local function getShipmentTable(identifier)
    if identifier == NULL or identifier == nil then 
        return table_Copy(BROKEN_SHIPMENT)
    end
    
    -- Check cache first
    local cache_key = tostring(identifier)
    if IsEntity(identifier) then
        cache_key = identifier:EntIndex() .. "_" .. (identifier:GetClass() or "unknown")
    end
    
    local current_time = CurTime()
    if shipment_cache[cache_key] and 
       cache_time[cache_key] then
        return shipment_cache[cache_key]
    end
    
    local shipments = getCustomShipments()
    local result = table_Copy(BROKEN_SHIPMENT)
    
    for k, v in ipairs(shipments) do
        local match = false
        
        if IsEntity(identifier) then
            local ent_class = identifier:GetClass()
            match = (v.entity == ent_class) or
                   (identifier.Getcontents and k == identifier:Getcontents()) or
                   (identifier.GetWeaponClass and v.entity == identifier:GetWeaponClass()) or
                   (identifier.GetShipmentClass and v.entity == identifier:GetShipmentClass())
        else
            local str_id = string_lower(tostring(identifier))
            match = (string_lower(v.entity) == str_id) or
                   (string_lower(v.name) == str_id) or
                   (v.cmd and string_lower(v.cmd) == str_id)
        end
        
        if match then
            result = table_Copy(v)
            -- Ensure all expected fields exist
            result.name = result.name or "Unnamed Shipment"
            result.entity = result.entity or "unknown"
            result.model = result.model or "models/error.mdl"
            result.amount = result.amount or 1
            result.price = result.price or 0
            result.separate = result.separate or false
            result.pricesep = result.pricesep or result.price
            break
        end
    end
    
    -- Cache the result
    shipment_cache[cache_key] = result
    cache_time[cache_key] = current_time
    
    return result
end

local function getShipmentCount(ent)
    if not IsValid(ent) then return -1 end
    if not isValidShipmentEntity(ent) then return -1 end
    
    -- Try multiple methods to get count
    if ent.Getcount then
        return ent:Getcount()
    elseif ent.GetCount then
        return ent:GetCount()
    elseif ent.GetShipmentCount then
        return ent:GetShipmentCount()
    elseif ent.count then
        return ent.count
    end
    
    return -1
end

local function getShipmentOwner(ent)
    if not IsValid(ent) then return nil end
    
    if ent.Getowning_ent then
        return ent:Getowning_ent()
    elseif ent.GetOwner then
        return ent:GetOwner()
    elseif ent.owner then
        return ent.owner
    end
    
    return nil
end

-- Name functions
e2function string entity:shipmentName()
    return getShipmentTable(this).name
end

e2function string shipmentName(string str)
    return getShipmentTable(str).name
end

-- Validation functions
e2function normal entity:isShipment()
    return isValidShipmentEntity(this) and 1 or 0
end

-- Type/Class functions
e2function string entity:shipmentType()
    return getShipmentTable(this).entity
end

e2function string shipmentType(string str)
    return getShipmentTable(str).entity
end

e2function string entity:shipmentClass() -- alias of shipmentType()
    return getShipmentTable(this).entity
end

e2function string shipmentClass(string str)
    return getShipmentTable(str).entity
end

-- Size functions
e2function normal entity:shipmentSize() -- size of original shipment
    return getShipmentTable(this).amount
end

e2function normal shipmentSize(string str) -- size of original shipment
    return getShipmentTable(str).amount
end

-- Amount functions
e2function normal entity:shipmentAmount() -- remaining in current shipment
    return getShipmentCount(this)
end

-- Model functions
e2function string entity:shipmentModel()
    return getShipmentTable(this).model
end

e2function string shipmentModel(string str)
    return getShipmentTable(str).model
end

-- Price functions
e2function normal entity:shipmentPrice()
    local price = getShipmentTable(this).price
    return (price and price >= 0) and price or 0
end

e2function normal shipmentPrice(string str)
    local price = getShipmentTable(str).price
    return (price and price >= 0) and price or 0
end

-- Separate functions (with corrected spelling)
e2function normal entity:shipmentSeparate()
    return getShipmentTable(this).separate and 1 or 0
end

e2function normal shipmentSeparate(string str)
    return getShipmentTable(str).separate and 1 or 0
end

-- Misspelled version for backward compatibility
e2function normal entity:shipmentSeperate()
    return getShipmentTable(this).separate and 1 or 0
end

e2function normal shipmentSeperate(string str)
    return getShipmentTable(str).separate and 1 or 0
end

-- Separate price functions
e2function normal entity:shipmentPriceSep()
    local pricesep = getShipmentTable(this).pricesep
    return (pricesep and pricesep >= 0) and pricesep or 0
end

e2function normal shipmentPriceSep(string str)
    local pricesep = getShipmentTable(str).pricesep
    return (pricesep and pricesep >= 0) and pricesep or 0
end


-- Get shipment category
e2function string entity:shipmentCategory()
    local shipment = getShipmentTable(this)
    return shipment.category or "Uncategorized"
end

e2function string shipmentCategory(string str)
    local shipment = getShipmentTable(str)
    return shipment.category or "Uncategorized"
end

-- Get shipment owner
e2function entity entity:shipmentOwner()
    return getShipmentOwner(this) or NULL
end

-- Check if player can buy shipment
e2function normal entity:shipmentCanBuy(entity ply)
    if not IsValid(ply) then return 0 end
    
    local shipment = getShipmentTable(this)
    
    -- Check if player has enough money
    if ply.getDarkRPVar then
        local money = ply:getDarkRPVar("money") or 0
        if money < (shipment.price or 0) then return 0 end
    end
    
    -- Check job restrictions
    if shipment.allowed and table.Count(shipment.allowed) > 0 then
        local job = ply:getDarkRPVar("job")
        local found = false
        for _, allowed_job in pairs(shipment.allowed) do
            if job == allowed_job then
                found = true
                break
            end
        end
        if not found then return 0 end
    end
    
    -- Custom check function
    if shipment.customCheck and isfunction(shipment.customCheck) then
        if not shipment.customCheck(ply) then return 0 end
    end
    
    return 1
end

-- Get percentage of shipment remaining
e2function normal entity:shipmentPercent()
    local current = getShipmentCount(this)
    local max = getShipmentTable(this).amount
    
    if current <= 0 or max <= 0 then return 0 end
    return math.floor((current / max) * 100)
end

-- Check if shipment is empty
e2function normal entity:shipmentEmpty()
    return (getShipmentCount(this) <= 0) and 1 or 0
end

-- Check if shipment is full
e2function normal entity:shipmentFull()
    local current = getShipmentCount(this)
    local max = getShipmentTable(this).amount
    return (current >= max) and 1 or 0
end

-- Get all shipments as array (returns array of entity indices)
e2function array getAllShipments()
    local result = {}
    local index = 1
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and isValidShipmentEntity(ent) then
            result[index] = ent:EntIndex()
            index = index + 1
        end
    end
    
    return result
end

-- Get shipments by category
e2function array getShipmentsByCategory(string category)
    local result = {}
    local index = 1
    local search_category = string_lower(category)
    
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and isValidShipmentEntity(ent) then
            local ent_category = string_lower(getShipmentTable(ent).category or "")
            if ent_category == search_category then
                result[index] = ent:EntIndex()
                index = index + 1
            end
        end
    end
    
    return result
end

-- Get shipment info as table (string representation)
e2function string entity:shipmentInfo()
    local shipment = getShipmentTable(this)
    local current = getShipmentCount(this)
    
    return string_format(
        "Name: %s | Type: %s | Price: $%d | Count: %d/%d | Model: %s",
        shipment.name,
        shipment.entity,
        shipment.price or 0,
        current,
        shipment.amount,
        shipment.model
    )
end

-- Cache management functions
e2function void clearShipmentCache()
    shipment_cache = {}
    cache_time = {}
end

e2function normal getShipmentCacheSize()
    return table.Count(shipment_cache)
end

-- Startup message
print(string_format(
    "[%s] v%s loaded successfully!",
    EXTENSION_NAME,
    EXTENSION_VERSION,
))