import Dates

function getTimeStamp()::String
    return Dates.now() |> x -> Dates.format(x, Dates.RFC1123Format)
end
