--!strict

--[=[
    @class Enumerator
    @__index prototype

    Enumerator is a flexible and efficient module designed for managing enumerations in Luau projects.


    [Example Usage](https://github.com/Paficent/Enumerator/blob/main/test/strict.luau)
]=]

--[=[
    @type Item<CustomEnum> { {EnumType: CustomEnum, Name: string, Value: number} }
    @within Enumerator
]=]

local Item = {}

export type Item<CustomEnum> = typeof(setmetatable(
	{} :: {
		Name: string,
		Value: number,
		EnumType: CustomEnum,
	},
	{}
))

function Item.new<EnumParent>(name: string, value: number, enumParent: EnumParent): Item<EnumParent>
	return setmetatable({
		Name = name,
		Value = value,
		EnumType = enumParent,
	}, {
		__tostring = function(self: Item<EnumParent>): string
			return `Enumerator.{tostring(self.EnumType)}.{self.Name}`
		end,
		__eq = function(self, other)
			if getmetatable(other).__type == "Item" then
				return tostring(self) == tostring(other)
			end
			return false
		end,
		__type = "Item",
	})
end

-----------------------------------------------------------------------------------------------------

local Enumerator = { prototype = {} }
Enumerator.__metamethods = {
	__index = function(self, key)
		return if self._values[key] then Item.new(key, self._values[key], self) else Enumerator.prototype[key]
	end,
	__tostring = function(self)
		return self._type
	end,
	__type = "Enumerator",
}

--[=[
    Creates a new Enumerator

    @param type string --  The name of the enum type.
    @param values  CustomEnum & { [string]: number } --  A table mapping names to values for the enum items.
    @return Enumerator<CustomEnum> -- The newly created enumerator.

    ```lua
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
    ```
]=]
function Enumerator.new<CustomEnum>(type: string, values: CustomEnum & { [string]: number })
	return setmetatable({
		_type = type,
		_values = values,
	}, Enumerator.__metamethods) :: Enum<CustomEnum>
end

--[=[
    Retrieves all enum items as a table.

    @return { Item<CustomEnum> }? -- A table of all Item instances in the enum.

    ```lua
    local allItems: { Enumerator.Item<FruitEnum> } = Fruits:GetItems()
    for _, item in allItems do
        print(item.Name, item.Value) -- Apple 1, Banana 2, Cherry 3
    end
    ```
]=]
function Enumerator.prototype:GetItems()
	local items = {}
	for key, value in self._values do
		items[value + 1] = key
	end

	local result = {}
	for _, key in items do
		table.insert(result, Item.new(key, self._values[key], self))
	end

	return result
end

--[=[
    Retrieves an enum item by its name.

    @param name string -- The name of the enum item to retrieve.
    @return Item<CustomEnum>? -- The enum item with the specified name, or nil if not found.

    ```lua
    local bananaItem: Enumerator.Item<FruitEnum>? = Fruits:GetItemByValue(2)
    if bananaItem then
        print(bananaItem.Name) -- Banana
    end
    ```
]=]
function Enumerator.prototype:GetItemByName<CustomEnum>(name: string): Item<CustomEnum>?
	for _, item in self:GetItems() do
		if item.Name == name then
			return item
		end
	end
	return nil
end

--[=[
    Retrieves an enum item by its value.

    @param value number -- The value of the enum item to retrieve.
    @return Item<CustomEnum>? -- The enum item with the specified value, or nil if not found.

    ```lua
    local cherryItem: Enumerator.Item<FruitEnum> = Fruits:GetItemByName("Cherry")
    print(cherryItem.Value) -- 3
    ```
]=]
function Enumerator.prototype:GetItemByValue<CustomEnum>(value: number): Item<CustomEnum>?
	for _, item in self:GetItems() do
		if item.Value == value then
			return item
		end
	end
	return nil
end

export type Enum<CustomEnum> =
	typeof(setmetatable({} :: any, {}))
	& CustomEnum
	& { [string]: Item<CustomEnum> }
	& typeof(Enumerator.prototype)

return Enumerator
