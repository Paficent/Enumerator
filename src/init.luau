--!strict

--[=[
    @class Enumerator
    @__index prototype

    Enumerator is a flexible and efficient module designed for managing enumerations in Luau projects. It provides a clean and structured approach to do enum management and enhance code clarity.


    [Example Usage](https://github.com/Paficent/Enumerator/blob/main/test/strict.luau)
]=]

local EnumItem = {}

export type EnumItem<CustomEnum> = typeof(setmetatable(
	{} :: {
		Name: string,
		Value: number,
		EnumType: CustomEnum,
	},
	{}
))

function EnumItem.new<EnumParent>(name: string, value: number, enumParent: EnumParent): EnumItem<EnumParent>
	return setmetatable({
		Name = name,
		Value = value,
		EnumType = enumParent,
	}, {
		__tostring = function(self: EnumItem<EnumParent>): string
			return `Enumerator.{tostring(self.EnumType)}.{self.Name}`
		end,
		__eq = function(self, other)
			if getmetatable(other).__type == "EnumItem" then
				return tostring(self) == tostring(other)
			end
			return false
		end,
		__type = "EnumItem",
	})
end

-----------------------------------------------------------------------------------------------------

local Enumerator = { prototype = {} }
Enumerator.__metamethods = {
	__index = function(self, key)
		if self._values[key] then
			return EnumItem.new(key, self._values[key], self)
		end
		return Enumerator.prototype[key]
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

    @return { EnumItem<CustomEnum> }? -- A table of all EnumItem instances in the enum.

    ```lua
    local allItems: { Enumerator.EnumItem<FruitEnum> } = Fruits:GetItems()
    for _, item in allItems do
        print(item.Name, item.Value) -- Output: "Apple 1", "Banana 2", "Cherry 3"
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
		table.insert(result, EnumItem.new(key, self._values[key], self))
	end

	return result
end

--[=[
    Retrieves an enum item by its name.

    @param name string -- The name of the enum item to retrieve.
    @return EnumItem<CustomEnum>? -- The enum item with the specified name, or nil if not found.

    ```lua
    local bananaItem: Enumerator.EnumItem<FruitEnum>? = Fruits:GetItemByValue(2)
    if bananaItem then
        print(bananaItem.Name) -- Output: "Banana"
    end
    ```
]=]
function Enumerator.prototype:GetItemByName<CustomEnum>(name: string): EnumItem<CustomEnum>?
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
    @return EnumItem<CustomEnum>? -- The enum item with the specified value, or nil if not found.

    ```lua
    local bananaItem: Enumerator.EnumItem<FruitEnum>? = Fruits:GetItemByValue(2)
    if bananaItem then
        print(bananaItem.Name) -- Output: "Banana"
    end
    ```
]=]
function Enumerator.prototype:GetItemByValue<CustomEnum>(value: number): EnumItem<CustomEnum>?
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
	& { [string]: EnumItem<CustomEnum> }
	& typeof(Enumerator.prototype)

return Enumerator
