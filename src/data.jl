import Dates
import Printf

function getTimeStamp()::String
    return Dates.now() |> x -> Dates.format(x, Dates.RFC1123Format)
end

function getFloatStr(num::Float64, formatStr::String = "%.4f")::String
    return Printf.format(Printf.Format(formatStr), num)
end
