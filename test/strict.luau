--!strict

local Enumerator = require(game:GetService("ReplicatedStorage").Enumerator)

-- The type definition ensures that only these keys and values are allowed.
type FruitEnum = {
	Apple: number,
	Banana: number,
	Cherry: number,
}

-- Create an Enumerator instance for the `FruitEnum` type
local Fruits: Enumerator.Enum<FruitEnum> = Enumerator.new("Fruits", {
	Apple = 1,
	Banana = 2,
	Cherry = 3,
})

-- Example: Accessing an EnumItem with type safety
local appleItem: Enumerator.EnumItem<FruitEnum> = Fruits.Apple
print(appleItem.Name) -- Output: "Apple"
print(appleItem.Value) -- Output: 1

-- Example: Using methods with type safety
-- The `GetItems` method returns a table of `EnumItem<FruitEnum>`
local allFruitItems: { Enumerator.EnumItem<FruitEnum> } = Fruits:GetItems()
for _, item in allFruitItems do
	print(item.Name, item.Value) -- Output: "Apple 1", "Banana 2", "Cherry 3"
end

-- Example: Using `GetItemByValue` with type safety
-- It is expected to return an `EnumItem<FruitEnum>` or `nil`
local bananaItem: Enumerator.EnumItem<FruitEnum>? = Fruits:GetItemByValue(2)
if bananaItem then
	print(bananaItem.Name) -- Output: "Banana"
end

-- Example: Using `GetItemByName` with type safety
-- It is expected to return an `EnumItem<FruitEnum>` or `nil`
local cherryItem: Enumerator.EnumItem<FruitEnum> = Fruits:GetItemByName("Cherry")
print(cherryItem.Value) -- Output: 3
