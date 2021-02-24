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


  if '22' > '233' then
    print('test')

  end

  while true do
    for i=1,100,1 do
      if i > 10 then


        print('ss')


        print('ssdd')

        if i > 4 then
          print('sass')

          if i > 2 then

            if i > 1 then

              print('ddd')

              if i > 0 then

                print('sccc')

                if i > 11 then

                  print('ddd')

                  if i > 4 then

                    print('sss')

                    if i > 1 then

                      if i > 24 then

                        print('ss')



                      end

                    end

                  end

                end

              end

            end

            print('sss')
          end

        end

      end

    end
  end
end

return m
