-- LRU 缓存实现
local LRUCache = {}
LRUCache.__index = LRUCache

function LRUCache.new(capacity)
  local self = setmetatable({}, LRUCache)
  self.capacity = capacity
  self.cache = {}
  self.order = {}
  self.index = 0
  return self
end

function LRUCache:logState()
  local state = "Current state: "
  for i, key in ipairs(self.order) do
    state = state .. string.format("%s=%s", key, self.cache[key])
    if i < #self.order then
      state = state .. ", "
    end
  end
  print(state)
end

function LRUCache:initConfig()
  self.cache = {}
  self.order = {}
  self.index = 0
end

function LRUCache:goNext()
  self.index = self.index + 1
  if self.index > #self.order then
    self.index = 1
  end
  return self.order[self.index]
end

function LRUCache:goPrev()
  self.index = self.index - 1
  if self.index <= 0 then
    self.index = #self.order
  end
  return self.order[self.index]
end

function LRUCache:get(key)
  local value = self.cache[key]
  if value then
    -- 将访问的元素移到队列末尾（最近使用）
    self:remove(key)
    table.insert(self.order, key)
    return value
  end
  return nil
end

function LRUCache:setIndexFormMark(mark)
  for index, key in ipairs(self.order) do
    if mark == key then
      self.index = index
      print("找到" .. mark .. "的索引" .. index)
      break
    end
  end
end

function LRUCache:put(key, value)
  if self.cache[key] then
    -- 如果键已存在，更新值并移到队列末尾
    self.cache[key] = value
    self:remove(key)
    table.insert(self.order, key)
    if self.index ~= 1 then
      self.index = self.index - 1
    end
  else
    -- 如果缓存已满，移除最久未使用的元素
    if #self.order >= self.capacity then
      local oldest = table.remove(self.order, 1)
      self.cache[oldest] = nil
    end
    -- 添加新元素
    self.cache[key] = value
    table.insert(self.order, key)
  end
end

function LRUCache:remove(key)
  for i, v in ipairs(self.order) do
    if v == key then
      table.remove(self.order, i)
      break
    end
  end
end
return LRUCache
