# shipmentFunctions-v2

A Wiremod Expression 2 extension for interacting with DarkRP shipments. This version enhances the original TylerB shipments extension with improved performance, new features, and robust error handling while maintaining full backward compatibility.


## Function Reference

### Core Information Functions

#### `entity:shipmentName()` / `shipmentName(string)`
Returns the display name of the shipment.
```lua
Name = Shipment:shipmentName()                    # "AK-47"
Name = shipmentName("weapon_ak47")                # "AK-47"
```

#### `entity:shipmentType()` / `shipmentType(string)`
Returns the weapon/entity class that the shipment spawns.
```lua
Class = Shipment:shipmentType()                   # "weapon_ak47"
Class = shipmentType("AK-47")                     # "weapon_ak47"
```

#### `entity:shipmentClass(string)`
Alias for `shipmentType()`.

#### `entity:shipmentModel()` / `shipmentModel(string)`
Returns the world model path of the weapon/item.
```lua
Model = Shipment:shipmentModel()                  # "models/weapons/w_rif_ak47.mdl"
```

### Quantity Functions

#### `entity:shipmentSize()` / `shipmentSize(string)`
Returns the maximum/original number of items in the shipment.
```lua
MaxItems = Shipment:shipmentSize()                # 10
```

#### `entity:shipmentAmount()`
Returns the current number of items remaining in the shipment.
```lua
Current = Shipment:shipmentAmount()               # 7
```

#### `entity:shipmentPercent()`
Returns the percentage (0-100) of items remaining.
```lua
Remaining = Shipment:shipmentPercent()            # 70
```

### Status Functions

#### `entity:isShipment()`
Returns 1 if the entity is a valid shipment, 0 otherwise.
```lua
if(Entity:isShipment()) {
    print("This is a shipment!")
}
```

#### `entity:shipmentEmpty()`
Returns 1 if the shipment has no items left.
```lua
if(Shipment:shipmentEmpty()) {
    print("Shipment is out of stock!")
}
```

#### `entity:shipmentFull()`
Returns 1 if the shipment is at maximum capacity.
```lua
if(Shipment:shipmentFull()) {
    print("Shipment is fully stocked!")
}
```

### Price Functions

#### `entity:shipmentPrice()` / `shipmentPrice(string)`
Returns the purchase price of the shipment.
```lua
Price = Shipment:shipmentPrice()                  # 5000
```

#### `entity:shipmentSeparate()` / `shipmentSeparate(string)`
Returns 1 if items can be purchased individually, 0 if bulk only.
```lua
CanBuySingle = Shipment:shipmentSeparate()        # 1
```

#### `entity:shipmentPriceSep()` / `shipmentPriceSep(string)`
Returns the price for individual items when sold separately.
```lua
SinglePrice = Shipment:shipmentPriceSep()         # 500
```

### Extended Information (New in 2025)

#### `entity:shipmentCategory()` / `shipmentCategory(string)`
Returns the category/classification of the shipment.
```lua
Category = Shipment:shipmentCategory()            # "Rifles"
```

#### `entity:shipmentOwner()`
Returns the entity that owns/placed this shipment.
```lua
Owner = Shipment:shipmentOwner()
if(Owner:isValid()) {
    print("Owner: " + Owner:name())
}
```

#### `entity:shipmentInfo()`
Returns a formatted string with comprehensive shipment information.
```lua
Info = Shipment:shipmentInfo()
# "Name: AK-47 | Type: weapon_ak47 | Price: $5000 | Count: 7/10 | Model: models/weapons/w_rif_ak47.mdl"
```

### Permission Functions

#### `entity:shipmentCanBuy(entity player)`
Returns 1 if the specified player can purchase this shipment.
```lua
if(Shipment:shipmentCanBuy(owner())) {
    print("You can buy this shipment!")
} else {
    print("Cannot buy: insufficient funds or wrong job")
}
```

### Utility Functions

#### `getAllShipments()`
Returns an array of all valid shipment entities on the map.
```lua
AllShipments = getAllShipments()
print("Found " + AllShipments:count() + " shipments")

foreach(K, V:number = AllShipments) {
    local Ent = entity(V)
    print(Ent:shipmentName())
}
```

#### `getShipmentsByCategory(string category)`
Returns an array of shipment entities matching the specified category.
```lua
Rifles = getShipmentsByCategory("Rifles")
Pistols = getShipmentsByCategory("Pistols")

foreach(K, V:number = Rifles) {
    print("Rifle: " + entity(V):shipmentName())
}
```

### Cache Management

#### `clearShipmentCache()`
Clears the internal shipment lookup cache.
```lua
clearShipmentCache()  # Force refresh of all cached data
```

#### `getShipmentCacheSize()`
Returns the current number of cached shipment lookups.
```lua
CacheSize = getShipmentCacheSize()
print("Cache contains " + CacheSize + " entries")
```

## Examples

### Basic Shipment Information Display
```lua
if(Entity:isShipment()) {
    print("=== SHIPMENT INFO ===")
    print("Name: " + Entity:shipmentName())
    print("Price: $" + Entity:shipmentPrice())
    print("Stock: " + Entity:shipmentAmount() + "/" + Entity:shipmentSize())
    print("Status: " + Entity:shipmentPercent() + "% remaining")
}
```

### Finding Affordable Shipments
```lua
AllShipments = getAllShipments()
AffordableCount = 0

foreach(K, V:number = AllShipments) {
    local Shipment = entity(V)
    if(Shipment:shipmentCanBuy(owner())) {
        print("Can buy: " + Shipment:shipmentName() + " ($" + Shipment:shipmentPrice() + ")")
        AffordableCount++
    }
}

print("You can afford " + AffordableCount + " shipments")
```

### Category-Based Analysis
```lua
Categories = array("Pistols", "Rifles", "SMGs", "Shotguns")

foreach(K, Category:string = Categories) {
    local CategoryShipments = getShipmentsByCategory(Category)
    local TotalValue = 0
    
    foreach(I, ShipmentID:number = CategoryShipments) {
        TotalValue += entity(ShipmentID):shipmentPrice()
    }
    
    print(Category + ": " + CategoryShipments:count() + " shipments, $" + TotalValue + " total value")
}
```

### Shipment Monitor System
```lua
@name Shipment Monitor
@persist CheckInterval:number

if(first()) {
    CheckInterval = 5000  # Check every 5 seconds
}

interval(CheckInterval)

AllShipments = getAllShipments()
EmptyShipments = 0
LowStockShipments = 0

foreach(K, V:number = AllShipments) {
    local Shipment = entity(V)
    local Percent = Shipment:shipmentPercent()
    
    if(Shipment:shipmentEmpty()) {
        EmptyShipments++
        print("EMPTY: " + Shipment:shipmentName())
    } elseif(Percent < 25) {
        LowStockShipments++
        print("LOW STOCK: " + Shipment:shipmentName() + " (" + Percent + "%)")
    }
}

print("Status: " + EmptyShipments + " empty, " + LowStockShipments + " low stock")
```

## Backward Compatibility

All functions from the original TylerB extension are fully supported:

- `shipmentName()`, `shipmentType()`, `shipmentClass()`
- `shipmentPrice()`, `shipmentSize()`, `shipmentAmount()`
- `shipmentModel()`, `isShipment()`
- `shipmentSeparate()`, `shipmentSeperate()` (misspelled version included)
- `shipmentPriceSep()`

Your existing E2 chips will work without any modifications!

## Troubleshooting

### Common Issues

**Q: Functions return "Invalid Shipment" or -1 values**
A: Make sure you're using the correct entity or string identifier. Verify the shipment exists in CustomShipments.

**Q: Can't find shipments with `getAllShipments()`**
A: Ensure your DarkRP shipments are properly configured and spawned. Check entity classes are supported.

### Debug Commands
```lua
# Check if entity is valid shipment
print("Is shipment: " + Entity:isShipment())

# Get comprehensive info
print(Entity:shipmentInfo())

# Check cache status
print("Cache size: " + getShipmentCacheSize())

# Clear cache if needed
clearShipmentCache()
```

## Contributing

This extension is designed to be future-proof and maintainable. If you encounter issues or have suggestions for improvements, please ensure compatibility with existing DarkRP setups.

## Credits

- **Original Extension**: [TylerB](https://github.com/TylerB260/shipmentFunctions-v1)

---

*Compatible with DarkRP 2.5.0+ and modern Wiremod installations*
