function movingAverageFactory(period)
    local t = {}
    function sum(a, ...)
        if a then
            return a + sum(...)
        else
            return 0
        end
    end
    function average(n)
        if #t == period then
            table.remove(t, 1)
        end
        t[#t + 1] = n
        return sum(unpack(t)) / #t
    end
    return average
end