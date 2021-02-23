local m = {}

function m.test()
  local s = 20

  local sa = 30

  print(s,sa)

  local s = {'aa','bb','ccc'}

  for k,s in ipairs(s) do
    print(s)


    print(k)
  end
end

return m
