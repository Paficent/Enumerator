--!strict

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

local Enumerator = { public = {} }
Enumerator.__metamethods = {
	__index = function(self, key)
		if self._values[key] then
			return EnumItem.new(key, self._values[key], self)
		end
		return Enumerator.public[key]
	end,
	__tostring = function(self)
		return self._type
	end,
	__type = "Enumerator",
}

function Enumerator.new<CustomEnum>(typeName: string, values: CustomEnum & { [string]: number })
	return setmetatable({
		_type = typeName,
		_values = values,
	}, Enumerator.__metamethods) :: Enumerator<CustomEnum>
end

function Enumerator.public:GetItems()
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

function Enumerator.public:GetItemByValue<CustomEnum>(value: number): EnumItem<CustomEnum>?
	for _, item in self:GetItems() do
		if item.Value == value then
			return item
		end
	end
	return nil
end

function Enumerator.public:GetItemByName<CustomEnum>(name: string): EnumItem<CustomEnum>?
	for _, item in self:GetItems() do
		if item.Name == name then
			return item
		end
	end
	return nil
end

export type Enumerator<CustomEnum> =
	typeof(setmetatable({} :: any, {}))
	& CustomEnum
	& { [string]: EnumItem<CustomEnum> }
	& typeof(Enumerator.public)

return Enumerator
