###############################################################################
#                                  variables                                  #
###############################################################################
x = 4
x = 2

z::Int = 4
zz::Float64 = 4.4

a = 1 # type is not declared
a = 2.2 # can assign a value of any other type
# the "Hello" below is a string (a text in a form readable by Julia)
a = "Hello"

b::Int = 1 # type integer declared
b = 2 # value of type integer delivered

c::Int = 1 # type integer declared
c = 3.3 # broke the promise, float delivered, will produce error

x = 3
x * x # works as you intended

x = "three"
x * x # the result may be surprising

# use these variable names
studentAge = 19
bookTitle = "Dune"

# avoid those variable names
x = 19
y = "Dune"

1 == 1
2 == 1

2.0 != 1.0

# comparing float (1.0) with integer (1)
1.0 != 1

# comparing integer (2) with float (2.0)
2 == 2.0

# be careful whie comparing floats
(0.1 * 3) == 0.3
0.1 * 3
0.3

# strings
title = "I enjoy reading\n\"Title of my favorite book\"."
println(title)

# && returns true only if both values are true
# those return false:
# true && false
# false && true
# false && false
# this returns true:
true && true

# || returns true if any value is true
# those return true:
# true || false
# false || true
# true || true
# this returns false:
false || false

# ! flips the value to the opposite
# returns false: !true
# returns true
!false

###############################################################################
#                                 collections                                 #
###############################################################################
# Vectors
myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]

myMathGrades[3] # returns 3rd element
myMathGrades[end] # returns last grade
# it is equivalent to: myMathGrades[7], but I don't need to count elements

myMathGrades[2:4] # returns Vector with three grades (2nd, 3rd, and 4th)
# the slicing is [inclusive:inclusive]

myMathGrades[1] = 2.0
myMathGrades

myMathGrades[2:3] = [5.0, 5.0]
myMathGrades

# Arrays
myGrades = [3.5 3.0; 4.0 3.0; 5.0 2.0]
myGrades[[1, 3], 2] # returns second column (rows 1 and 3)
myGrades[:, 2] # returns second column (and all rows)
myGrades[1, :] # returns first row (and all columns)
myGrades[3, 2] # returns value from third row and second column

myGrades[3, 2] = 5
myGrades

# Array perils
x = 2
y = x # y contains the same value as x
y = 3 # y is assigned a new value, x is unaffected
(x, y)

xx = [2, 2]
yy = xx # yy refers to the same box of drawers as xx
yy[1] = 3 # new value 3 is put to the first drawer of the box pointed by yy
# both xx, and yy are changed, cause both point at the same box of drawers
(xx, yy)

# copy function to the rescue
xx = [2, 2]
# yy refers to a different box of drawers
# with the same (copied) numbers inside
yy = copy(xx)
yy[1] = 3 # this does not affect xx
(xx, yy)


# structs
struct Fraction
    numerator::Int
    denominator::Int
end

fr1 = Fraction(1, 2)
fr1

fr1.numerator

fr1.denominator

# built in Rational type
1//2 # equivalent to: Rational(1, 2)

###############################################################################
#                                  functions                                  #
###############################################################################
# mathematical functions

# declaring a function
function getRectangleArea(lenSideA::Real, lenSideB::Real)::Real
    return lenSideA * lenSideB
end

# using a function
getRectangleArea(3, 4)
getRectangleArea(1.5, 2)


function getSquareArea(lenSideA::Real)::Real
    return getRectangleArea(lenSideA, lenSideA)
end

getSquareArea(3)

# functions with generics
# the functions work fine for non-empty vectors

function getFirstElt(vect::Vector{Int})::Int
    return vect[1]
end

function getFirstElt(vect::Vector{Float64})::Float64
    return vect[1]
end

function getFirstElt(vect::Vector{String})::String
    return vect[1]
end

function getFirstEltVer2(vect)
    return vect[1]
end

function getFirstEltVer3(vect::Vector{T})::T where T
    return vect[1]
end

# functions operating on structs
1//3 + 2//6

function add(f1::Fraction, f2::Fraction)::Fraction
    newDenom::Int = f1.denominator * f2.denominator
    f1NewNom::Int = newDenom / f1.denominator * f1.numerator
    f2NewNom::Int = newDenom / f2.denominator * f2.numerator
    newNom::Int = f1NewNom + f2NewNom
    return Fraction(newNom, newDenom)
end

add(Fraction(1, 3), Fraction(2, 6))

# or using built-in Rational type
# equivalent to: Rational(1, 3) + Rational(2, 6)
1//3 + 2//6

# functions modyfying arguments
# the function works fine for non-empty vectors
function wrongReplaceFirstElt(ints::Vector{<:Int}, newElt::Int)::Vector{<:Int}
    ints[1] = newElt
    return ints
end

xx = [2, 2]
yy = wrongReplaceFirstElt(xx, 3)

# unintentionally we chaned xx defined outside a function
(xx, yy)

# the function works fine for non-empty vectors
function replaceFirstElt!(vect::Vector{T}, newElt::T) where T
    vect[1] = newElt
    return nothing
end

x = [1, 2, 3]
y = replaceFirstElt!(x, 4)
(x, y)

# built-in push! function
xx = [] # empty vector
push!(xx, 1, 2) # now xx is [1, 2]
push!(xx, 3) # now xx is [1, 2, 3]
push!(xx, 4, 5) # now xx is [1, 2, 3, 4, 5]
xx

###############################################################################
#                               decision making                               #
###############################################################################
function turnInt2string(num::Int)::String
    if num == 0
        return "zero"
    elseif num == 1
        return "one"
    elseif num == 2
        return "two"
    else
        return "three or above"
    end
end

(turnInt2string(2), turnInt2string(5)) # a tuple with results


# works fine for non-empty vectors
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
    if isSortedAsc
        return vect[1]
    else
        sortedVect::Vector{Int} = sort(vect)
        return sortedVect[1]
    end
end

x = [1, 2, 3, 4]
y = [3, 4, 1, 2]

(getMin(x, true), getMin(y, false))

function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
    return isSortedAsc ? vect[1] : sort(vect)[1]
end

x = [1, 2, 3, 4]
y = [3, 4, 1, 2]

(getMin(x, true), getMin(y, false))


###############################################################################
#                                 dictionaries                                #
###############################################################################
engPolDict::Dict{String, String} = Dict("one" => "jeden", "two" => "dwa")
engPolDict # the key order is not preserved on different computers

engPolDict["two"]
engPolDict["three"] = "trzy"

get(engPolDict, "four", "not found")

function translateEng2polVer1(engWord::String)::String
    if engWord == "one"
        return "jeden"
    elseif engWord == "two"
        return "dwa"
    elseif engWord == "three"
        return "trzy"
    elseif engWord == "four"
        return "jeden"
    else
        return "not found"
    end
end

(translateEng2polVer1("three"), translateEng2polVer1("ten"))

function translateEng2polVer2(engWord::String, someDict::Dict{String, String} = engPolDict)::String
    return get(someDict, engWord, "not found")
end

(translateEng2polVer2("three"), translateEng2polVer2("twelve"))

###############################################################################
#                                  repetition                                 #
###############################################################################
function printHoorayNtimes(n::Int)
    @assert (n > 0) "n needs to be greater than 0"
    for _ in 1:n
        println("hip hip hooray!")
    end
    return nothing
end

printHoorayNtimes(3)

myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]

function getSum(nums::Vector{<:Real})::Real
    total::Real = 0
    for i in 1:length(nums)
        total = total + nums[i]
    end
    return total
end

getSum(myMathGrades)

function getSum(nums::Vector{<:Real})::Real
    total::Real = 0
    for num in nums
        total += num
    end
    return total
end

getSum(myMathGrades)

function getAvg(nums::Vector{<:Real})::Real
    return getSum(nums) / length(nums)
end

getAvg(myMathGrades)

temperaturesCelsius = [22, 18.3, 20.1, 19.5]

function degCels2degFahr(tempCels::Real)::Real
    return tempCels * 1.8 + 32
end

degCels2degFahr(0)

function degCels2degFahr(tempCels::Real)::Real
    return tempCels * 1.8 + 32
end

degCels2degFahr(0)

function degCels2degFahr!(tempsCels::Vector{<:Real})
    for i in eachindex(tempsCels)
        tempsCels[i] = degCels2degFahr(tempsCels[i])
    end
    return nothing
end

function degCels2degFahr(tempsCels::Vector{<:Real})::Vector{<:Real}
    result::Vector{<:Real} = zeros(length(tempsCels))
    for i in eachindex(tempsCels)
        result[i] = degCels2degFahr(tempsCels[i])
    end
    return result
end

temperaturesFahrenheit = degCels2degFahr(temperaturesCelsius)

###############################################################################
#                               built-in goodies                              #
###############################################################################
xs = [1, 2, 3]

# comprehensions
function inch2cm(inch::Real)::Real
    return inch * 2.54
end

inch2cm(1)

inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
    return [inch2cm(inch) for inch in inches]
end

inches2cms(inches)

# map and foreach

inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
    return map(inch2cm, inches)
end

inches2cms(inches)

function getSum(vect::Vector{<:Real})::Real
    total::Real = 0
    foreach(x -> total += x, vect) # side effect is to increase total
    return total
end

getSum([1, 2, 3, 4])

# dot operators/functions
inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
    return inch2cm.(inches)
end

inches2cms(inches)

###############################################################################
#                             additional libraries                            #
###############################################################################
import Statistics as Stats
Stats.mean([1, 2, 3])

###############################################################################
#                            exercises - solutions                            #
###############################################################################

# exercise 1
function getCircleArea(r::Real)::Real
    return pi * r * r
end

(getCircleArea(30/2) * 2, getCircleArea(45/2))

# or

function getCylinderVolume(r::Real, h::Real=2)::Real
    # hmm, is cylinder just many circles stacked one on another?
    return getCircleArea(r) * h
end

(getCylinderVolume(30/2) * 2, getCylinderVolume(45/2))

# exercise 2
function areApproxEqual(f1::Float64, f2::Float64)::Bool
    return round(f1, digits=16) == round(f2, digits=16)
end

areApproxEqual(0.1*3, 0.3)

# or using build-in function
isapprox(0.1*3, 0.3)
# compare with
# isapprox(0.11*3, 0.3)
# or to test if the values are not equal
# !isapprox(0.11*3, 0.3)

# exercise 3
function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : sort(vect)[end]
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))

# or
function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : sort(vect, rev=true)[1]
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))

# or
function getMaxUnsorted(unsortedVect::Vector{Int})::Int
    maxVal::Int = unsortedVect[1]
    for elt in unsortedVect[2:end]
        if maxVal < elt
            maxVal = elt
        end
    end
    return maxVal
end

function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : getMaxUnsorted(vect)
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))

# exercise 4
function printFizzBuzz()
    for i in 1:30
	if rem(i, 3) == 0 && rem(i, 5) == 0
            println("Fizz Buzz")
        elseif rem(i, 3) == 0
            println("Fizz")
        elseif rem(i, 5) == 0
            println("Buzz")
        else
            println(i)
        end
    end
    return nothing
end

printFizzBuzz()

# or
function getFizzBuzz(num::Int)::String
    return (
        rem(num, 15) == 0 ? "Fizz Buzz" :
        rem(num, 3) == 0 ? "Fizz" :
        rem(num, 5) == 0 ? "Buzz" :
        string(num)
    )
end

function printFizzBuzz()
    foreach(x -> println(getFizzBuzz(x)), 1:30)
    return nothing
end

printFizzBuzz()

# exercise 5
function getNumOfGrainsOnField64()::Int
    noOfGrains::Int = 1 # no of grains on field 1
    for _ in 2:64
        noOfGrains *= 2 # *= is update operator similar to +=
    end
    return noOfGrains
end

getNumOfGrainsOnField64()

# or corrected version
function getNumOfGrainsOnField64()::BigInt
    noOfGrains::BigInt = 1 # no of grains on field 1
    for _ in 2:64
        noOfGrains *= 2
    end
    return noOfGrains
end

getNumOfGrainsOnField64()

# exercse 6
function getInit(vect::Vector{T})::Vector{T} where T
    return vect[1:(end-1)]
end

getInit([1, 2, 3, 4])
getInit(["ab", "cd", "ef", "gh"])
getInit([3.3])
getInit([])
