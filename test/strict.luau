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

local appleItem: Enumerator.Item<FruitEnum> = Fruits.Apple
print(appleItem.Name) -- Apple
print(appleItem.Value) -- 1

-- The `GetItems` method returns a table of `EnumItem<FruitEnum>`
local allItems: { Enumerator.Item<FruitEnum> } = Fruits:GetItems()
for _, item in allItems do
	print(item.Name, item.Value) -- Apple 1, Banana 2, Cherry 3
end

-- It is expected to return an `EnumItem<FruitEnum>` or `nil`
local bananaItem: Enumerator.Item<FruitEnum>? = Fruits:GetItemByValue(2)
if bananaItem then
	print(bananaItem.Name) -- Banana
end

-- It is expected to return an `EnumItem<FruitEnum>` or `nil`
local cherryItem: Enumerator.Item<FruitEnum> = Fruits:GetItemByName("Cherry")
print(cherryItem.Value) -- 3
