# Statistics - introduction {#sec:statistics_intro}

OK, once we got some Julia basics under our belts, now it is time to get
familiar with statistics.

First of all, what is statistics anyway?

Hmm, actually I have never tried to learn the definition by heart (after all
getting such a question during an exam is slim to none). Still, if I were to
give a short (2-3 sentences) definition without looking it up I would say
something like that.

Statistics is a set of methods for drawing conclusions about big things
(populations) based on small things (samples). A statistician observes only a
small part of a bigger picture and makes generalization about what he does not
see based on what he saw. Given that he saw only a part of the picture he can
never be entirely sure of his conclusions.

OK, feel free to visit Wikipedia ([see
statistics](https://en.wikipedia.org/wiki/Statistics)) and see how I did with my
definition. The definition given there is probably more accurate and
comprehensive, but maybe mine will be easier to grasp for a beginner.

Anyway, my definition says "can never be entirely sure" so there needs to be
some way to measure the (un)certainty. This is where probability comes into the
picture. We will explore this in this chapter.

## Chapter imports {#sec:statistics_intro_imports}

Later in this chapter we are going to use the following libraries

```jl
s4 = """
import CairoMakie as Cmk
import Distributions as Dsts
import Random as Rand
"""
sc(s4)
```

If you want to follow along you should have them installed on your system. A
reminder of how to deal (install and such) with packages can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer
to use `Project.toml` and `Manifest.toml` files from the [code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch04)
to install the required packages. The instructions you will find
[here](https://pkgdocs.julialang.org/v1/environments/).

The imports will be in in the code snippet when first used, but I thought it is
a good idea to put them here, after all imports should be at the top of your
file (so here they are at top of the chapter). Moreover, that way they will be
easier to find all in one place.

If during the lecture of this chapter you find a piece of code of unknown
functionality, just go to the code snippets mentioned above and run the code
from the `*.jl` file.  Once you have done that you can always extract a small
piece of it and test it separately (modify and experiment with it if you
wish).

## Probability - definition {#sec:statistics_intro_probability_definition}

For me probability is one of the key concepts in statistics, after all any
statistical software will gladly calculate the famous p-value (a form of
probability) for you. Still, let's get back to our probability definition (see
the sub-chapter name).

As said, at the conclusion of the previous section, probability is a way to
measure certainty. It's like with the grades in school. In Poland a pupil can
score 1 to 6 (lowest to highest grade) and this tells us how well he mastered
the subject. If I score 1 then I didn't master it at all, but when I get 6 this
means that I got it all. We know from everyday life that probability takes
values from 0 to 100%, e.g.

> - Are you sure of it?
> - Absolutely, one hundred percent.

or

> - Do you think he can make it?
> - I would say it's fifty-fifty.

or even

> - What are the chances?
> - Pretty much, zero.

When something is bound to happen we assign it the probability of 100%.

When it can go either way we say fifty-fifty (50% it will happen, 50% it will
not happen).

When an event is impossible we say zero (probability of it happening is 0%).

And this is the way statisticians use it. OK, maybe not quite. A typical
textbook from statistics will say that the probability takes values from 0
to 1. It is expressed this way for a few particular reasons (some of the reasons
may be given later). Moreover, believe it or not, but it is actually compatible
with our everyday life understanding.

From primary school (see also Wikipedia's definition of
[percentage](https://en.wikipedia.org/wiki/Percentage)) I remember that 1% is
actually 1/100th of something which I can write down using proper fraction as
$\frac{1}{100}$ or a decimal as 0.01.

Therefore any probability value from 0% to 100% can be written in these three
forms. For instance:

- 0% = $\frac{0}{100}$ = 0.00 = 0
- 1% = $\frac{1}{100}$ = 0.01
- 5% = $\frac{5}{100}$ = 0.05
- 10% = $\frac{10}{100}$ = 0.10 = 0.1
- 20% = $\frac{20}{100}$ = 0.20 = 0.2
- 50% = $\frac{50}{100}$ = 0.50 = 0.5
- 100% = $\frac{100}{100}$ = 1.00 = 1

To give you a better intuitive grasp of probability written as a decimal take a
look at this simplistic graphical depiction of it

<pre>
# prob = 0.0
impossible ||||||||||||||||||||||||||||||||||||||||||||||||||| certain
           ∆
# prob = 0.2
impossible ||||||||||||||||||||||||||||||||||||||||||||||||||| certain
                     ∆
# prob = 0.5
impossible ||||||||||||||||||||||||||||||||||||||||||||||||||| certain
                                    ∆
# prob = 0.8
impossible ||||||||||||||||||||||||||||||||||||||||||||||||||| certain
                                                   ∆
# prob = 1.0
impossible ||||||||||||||||||||||||||||||||||||||||||||||||||| certain
                                                             ∆
</pre>

Anyway, when written down as a decimal (like a statistician would do it) the
probability is easier to type with a keyboard and a [software
calculator](https://en.wikipedia.org/wiki/Software_calculator). Additionally,
now we will be able to perform some simple but useful calculations with those
numbers (see the upcoming sections).

## Probability - properties {#sec:statistics_intro_probability_properties}

One of the cool and practical stuff that I learned about probability is that it
can be:

- added
- subtracted
- divided
- multiplied

How about I illustrate that with a simple example.

From biology classes I remember that the genetic material
([DNA](https://en.wikipedia.org/wiki/DNA)) of a cell is in its nucleus. It is
organized in a set of chromosomes. Chromosomes come in pairs (twin or
[homologous chromosomes](https://en.wikipedia.org/wiki/Homologous_chromosome),
we get one from each of our parents). Each chromosome contains genes (like beads
on a thread). Since we got a pair of chromosomes, then each chromosome from a
pair contains a copy of the same gene(s). The copies are exactly the same or are
a different version of a gene (we call them
[alleles](https://en.wikipedia.org/wiki/Allele)). In order to create gametes
(like egg cell and sperm cells) the cells undergo division
([meiosis](https://en.wikipedia.org/wiki/Meiosis)). During this process a cell
splits in two and each of the child cells gets one chromosome from the pair.

For instance chromosome 9 contains the genes that determine our [ABO blood group
system](https://en.wikipedia.org/wiki/ABO_blood_group_system#Genetics). A
meiosis process for a person with blood group AB would look something like this
(for simplicity I drew only twin chromosomes 9 and only genes for ABO blood
group system).

![Meiosis. Splitting of a cell of a person with blood group AB.](./images/meiosis.png){#fig:meiosis}

OK, let's see how the mathematical properties of probability named at the
beginning of this sub-chapter apply here.

But first, a warm-up (or a reminder if you will). In the previous part (see
@sec:statistics_intro_probability_definition) we said that probability may be
seen as a percentage, decimal or fraction. I think that the last one will be
particularly useful to broaden our understanding of the concept. To determine
probability of an event in the nominator (top) we insert the number of times
that event may happen, in the denominator (bottom) we place the number of all
possible events, like so:

$\frac{num\ times\ this\ event\ may\ happen}{num\ times\ any\ event\ may\ happen}$
\
\
Let's test this in practice with a few short Q&As (there may be some
repetitions, but they are on purpose).
\
\
\
**Q1.** In the case illustrated in @fig:meiosis what is the probability of
getting a gamete with allele `C` [for short I'll name it P(`C`)]?

**A1.** Since we can only get allele `A` or `B`, but no `C` then $P(C) =
\frac{0}{2} = 0$ (it is an impossible event).
\
\
\
**Q2.** In the case illustrated in @fig:meiosis what is the probability of
getting a gamete with allele `A` [for short I'll name it P(`A`)]?

**A2.** Since we can get only allele `A` or `B` then `A` is 1 of 2 possible
events, so $\frac{1}{2} = 0.5$.

It seems that to answer this question we just had to divide the counts of the
events satisfying our requirements by the counts of all events.

> **_Note:_** This is exactly the same probability (since it relies on the same
> reasoning) as for getting a gamete with allele `B` (1 of 2 or $\frac{1}{2} =
> 0.5$)

\
**Q3.** In the case illustrated in @fig:meiosis, what is the probability of
getting a gamete with allele `A` or `B` [for short I'll name it P(`A` or `B`)]?

**A3.** Since we can only get allele `A` or `B` then `A` or `B` are 2 events (1
event when `A` happens + 1 event when `B` happens) of 2 possible events, so

$P(A\ or\ B) = \frac{1+1}{2} = \frac{2}{2} = 1$.

It seems that to answer this question we just had to add the counts of the both
events.

Let's look at it from a slightly different perspective.

Do you remember that in A2 we stated that probability of getting gamete `A` is
$\frac{1}{2}$ and probability of getting gamete `B` is $\frac{1}{2}$? And do you
remember that in primary school we learned that fractions can be added one to
another? Let's see will that do us any good here.

$P(A\ or\ B) = P(A) + P(B) = \frac{1}{2} + \frac{1}{2} = \frac{2}{2} = 1$

Interesting, the answer (and calculations) are (virtually) the same despite
slightly different reasoning. So it seems that in this case probabilities can be
added.
\
\
\
**Q4.** In the case illustrated in @fig:meiosis, what is the probability of
getting a gamete with allele `B` (for short I'll name it P(`B`))?

**A4.** I know, we already answered it in A2. But let's do something wild and
use slightly different reasoning.

Getting gamete `A` or `B` are two incidents of two possible events (2 of 2). If
we subtract event `A` (that we are not interested in) from both the events we
get:

$P(B) = \frac{2-1}{2} = \frac{1}{2}$

It seems that to answer this question we just had to subtract the count of the
events we are not interested in from the counts of the both events.

Let's see if this works with fractions (aka probabilities).

$P(B) = P(A\ or\ B) - P(A) = \frac{2}{2} - \frac{1}{2} = \frac{1}{2}$

Yep, a success indeed.
\
\
\
**Q5.** Look at @fig:abAndOGametes.

![Blood groups, gametes. P - parents, PG - parents' gametes, C - children, CG - children's' gametes.](./images/abAndOGametes.png){#fig:abAndOGametes}

Here we see that a person with blood group AB got children with a person with
blood group O (ii - recessive homo-zygote). The two possible blood groups in
children are A (Ai - hetero-zygote) and B (Bi - hetero-zygote).

And now, the question. In the case illustrated in @fig:abAndOGametes, what is
the probability that a child (row C) of those parents (row P) will produce a
gamete with allele `A` (row CG)?

**A5.** One way to answer this question would be to calculate the gametes in the
last row (CG). We got 4 gametes in total (`A`, `i`, `B`, `i`) only one of which
fulfills the criteria (gamete with allele `A`). Therefore, the probability is

$P(A\ in\ CG) = \frac{1}{4} = 0.25$ and that's it.

Another way to think about this problem is the following. In order for a child
to produce a gamete with allele `A` it had to get it first from the parent. So
what we are looking for is:

1. what proportion of children got allele `A` from their parents (here, half of
   them)
2. in the children with allele `A` in their genotype, what proportion of gametes
   contains allele `A` (here, half of the gametes)

So, to get half of the half all I have to do is to multiply two proportions (aka
fractions):

$P(A\ in\ CG) = P(A\ in\ C) * P(A\ in\ gametes\ of\ C\ with\ A)$

$P(A\ in\ CG) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

So it turns out that probabilities can be multiplied (at least sometimes).

### Probability properties - summary {#sec:statistics_intro_probability_summary}

The above was my interpretation of the probability properties explained on
biological examples instead of standard fair coins tosses. Let's sum up of what
we learned. I'll do this on a coin toss examples (outcome: heads or tails), you
compare it with the examples from Q&As above.

1. Probability of an event is a proportion (or fraction) of times this event
   happens to the total amount of possible distinctive events. Example:
   $P(heads) = \frac{heads}{heads + tails} = \frac{1}{2} = 0.5$
2. Probability of an impossible event is equal to 0. Probability of certain
   event is equal to 1. So, the probability takes values between 0 (inclusive)
   and 1 (inclusive).
3. Probabilities of the mutually exclusive complementary events add up
   to 1. Example: $P(heads\ or\ tails) = P(heads) + P(tails) = \frac{1}{2} +
   \frac{1}{2} = 1$
4. Probability of two mutually exclusive complementary events occurring at the
   same time is 0 (cannot get heads and tails at one coin toss).
5. Probability of two mutually exclusive complementary events occurring one
   after another is a product of two probabilities.

   Example: probability of getting two tails in two consecutive coin tosses
   $P(tails\ and\ tails) = P(tails\ in\ 1st\ toss) * P(tails\ in\ 2nd\ toss)$

   $P(tails\ and\ tails) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

   Actually, the last is also true for two simultaneous coin tosses (imagine
   that one coin lands a few milliseconds before the other).

**Anyway, the chances are that whenever you say P(this) AND P(that) you should
use multiplication. Whereas whenever you say P(this) OR P(that) you should
probably use addition.** Of course you should always think does it make sense
before you do it (if the events are not mutually exclusive and independent then
usually it does not).

## Probability - theory and practice {#sec:statistics_prob_theor_practice}

OK, in the previous chapter (see @sec:statistics_intro_probability_properties)
we said that a person with blood group AB would produce gametes `A` and `B` with
probability 50% (p = $\frac{1}{2}$ = 0.5) each. A reference value for [sperm
count](https://en.wikipedia.org/wiki/Semen_analysis#Sperm_count) is 16'000'000
per mL or 16'000 per $\mu L$. Given that last value, we would expect 8'000 cells
(16'000 * 0.5) to contain allele `A` and 8'000 (16'000 * 0.5) cells to contain
allele `B`.

Let's put that to the test.

Wait! Hold your horses! We're not going to take biological samples. Instead we
will do a computer simulation.

```jl
s = """
import Random as Rand
Rand.seed!(321) # optional, needed for reproducibility
gametes = Rand.rand(["A", "B"], 16_000)
first(gametes, 5)
"""
sco(s)
```

First we import a package to generate random numbers (`import Random as
Rand`). Then we set seed to some arbitrary number (`Rand.seed!(321)`) in order
to reproduce the results [see the
docs](https://docs.julialang.org/en/v1/stdlib/Random/#Random.seed!). Thanks to
the above you should get the exact same result as I did (assuming you're using
the same version of Julia). Then we draw 16'000 gametes out of two available
(`gametes = Rand.rand(["A", "B"], 16_000)`) with function `rand` (drawing with
replacement) from `Random` library (imported as `Rand`). Finally, since looking
through all 16'000 gametes is tedious we display only first 5 (`first(gametes,
5)`) to have a sneak peak of the result.

Let's write a function that will calculate the number of gametes for us.

```jl
s = """
function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
		if haskey(counts, elt) #1
			counts[elt] = counts[elt] + 1 #2
		else #3
			counts[elt] = 1 #4
		end #5
    end
    return counts
end
"""
sc(s)
```

Try to figure out what happened here on your own. If you need a refresher on
dictionaries in Julia see @sec:julia_language_dictionaries or [the
docs](https://docs.julialang.org/en/v1/base/collections/#Base.Dict).

Briefly, first we initialize an empty dictionary (`counts::Dict{T,Int} =
Dict()`) with keys of some type `T` (elements of that type compose Vector
`v`). Next, for every element (`elt`) in Vector `v` we check if it is present in
the `counts` (`if haskey(counts, elt)`). If it is we add 1 to the previous count
(`counts[elt] = counts[elt] + 1`). If not (`else`) we put the key (`elt`) into
the dictionary with count `1`. In the end we return the result (`return
counts`). The `if ... else` block (lines with comments `#1`-`#5`) could be
replaced with one line (`counts[elt] = get(counts, elt, 0) + 1`), but I thought
the more verbose version would be easier to understand.

Let's test it out.

```jl
s = """
gametesCounts = getCounts(gametes)
gametesCounts
"""
sco(s)
```

Hmm, that's odd. We were suppose to get 8'000 gametes with allele `A` and 8'000
with allele `B`. What happened? Well, reality. After all ["All models are wrong,
but some are useful"](https://en.wikipedia.org/wiki/All_models_are_wrong). Our
theoretical reasoning was only approximation of the real world and as such
cannot be precise (although with greater sample sizes comes greater
precision). You can imagine that a fraction of the gametes were damaged
(e.g. due to some unspecified environmental factors) and underwent apoptosis
(aka programmed cell death). So that's how it is, deal with it.

OK, let's see what are the experimental probabilities we got from our
hmm... experiment.

```jl
s = """
function getProbs(counts::Dict{T, Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v/total for (k, v) in counts)
end
"""
sc(s)
```

First we calculate total counts no matter the gamete category
(`sum(values(counts))`). Then we use dictionary comprehensions, which are
similar to comprehensions we met before (see
@sec:julia_language_comprehensions). Briefly, for each key and value in `counts`
(`for (k,v) in counts`) we create the same key in new dictionary with new value
being the proportion of `v` in `total` (`k => v/total`).

And now the experimental probabilities.

```jl
s = """
gametesProbs = getProbs(gametesCounts)
gametesProbs
"""
sco(s)
```

One last point. While writing numerous programs I figured out it is some times
better to represent things (internally) as numbers and only in the last step
present them in a more pleasant visual form to the viewer. In our case we could
have used `0` as allele `A` and `1` as allele `B` like so.

```jl
s = """
Rand.seed!(321)
gametes = Rand.rand([0, 1], 16_000)
first(gametes, 5)
"""
sco(s)
```

Then to get the counts of the alleles I could type:

```jl
s = """
alleleBCount = sum(gametes)
alleleACount = length(gametes) - alleleBCount
(alleleACount, alleleBCount)
"""
sco(s)
```

And to get the probabilities for the alleles I could simply type:

```jl
s = """
alleleBProb = sum(gametes) / length(gametes)
alleleAProb = 1 - alleleBProb
(round(alleleAProb, digits=6), round(alleleBProb, digits=6))
"""
sco(s)
```

Go ahead. Compare the numbers with those that you got previously and explain it
to yourself why this second approach works. Once you're done click the right
arrow to explore probability distributions in the next section.

> **_Note:_** Similar functionality to `getCounts` and `getProbs` can be found
> in StatsBase.jl, see:
> [countmap](https://juliastats.org/StatsBase.jl/stable/counts/#StatsBase.countmap)
> and
> [proportionmap](https://juliastats.org/StatsBase.jl/stable/counts/#StatsBase.proportionmap).

## Probability distribution {#sec:statistics_prob_distribution}

Another important concept worth knowing is that of [probability
distribution](https://en.wikipedia.org/wiki/Probability_distribution). Let's
explore it with some, hopefully interesting, examples.

First, imagine I offer Your a bet. You roll two six-sided dice. If the sum of
the dots is 12 then I give you $125, otherwise you give me $5. Hmm, sounds like
a good bet, doesn't it? Well, let's find out. By flexing our probabilistic
muscles and using a computer simulation this should not be too hard to answer.

```jl
s = """
function getSumOf2DiceRoll()::Int
	return sum(Rand.rand(1:6, 2))
end

Rand.seed!(321)
numOfRolls = 100_000
diceRolls = [getSumOf2DiceRoll() for _ in 1:numOfRolls]
diceCounts = getCounts(diceRolls)
diceProbs = getProbs(diceCounts)
"""
sc(s)
```

Here, we rolled two 6-sided dice 100 thousand ($10^5$) times. The code
introduces no new elements. The functions: `getCounts`, `getProbs`, `Rand.seed!`
were already introduced in the previous chapter (see
@sec:statistics_prob_theor_practice). And the `for _ in` construct we met while
talking about for loops (see @sec:julia_language_for_loops).

So, let's take a closer look at the result.

```jl
s = """
(diceCounts[12], diceProbs[12])
"""
sco(s)
```

It seems that out of 100'000 rolls with two six-sided dice only
 `jl diceCounts[12]` gave us two sixes (6 + 6 = 12), so the experimental
probability is equal to `jl diceProbs[12]`. But is it worth it?
From a point of view of a single person (remember the bet is you vs. me)
a person got probability of `diceProbs[12] = ` `jl diceProbs[12]` to
win $125 and a probability of `sum([get(diceProbs, i, 0) for i in 2:11]) = `
 `jl sum([get(diceProbs, i, 0) for i in 2:11])` to lose $5.
Since all the probabilities (for 2:12) add up to 1, the last part could be
rewritten as `1 - diceProbs[12] = ` `jl 1 - diceProbs[12]`.
Using Julia I can write this in the form of an equation like so:

```jl
s = """
function getOutcomeOfBet(probWin::Float64, moneyWin::Real,
                         probLose::Float64, moneyLose::Real)::Float64
	# in mathematics first we do multiplication (*), then subtraction (-)
	return probWin * moneyWin - probLose * moneyLose
end

outcomeOf1bet = getOutcomeOfBet(diceProbs[12], 125, 1 - diceProbs[12], 5)

round(outcomeOf1bet, digits=2) # round to cents (1/100th of a dollar)
"""
sco(s)
```

In total you are expected to lose $ `jl abs(round(outcomeOf1bet, digits=2))`.

Now some people may say "Phi! What is $1.39 if I can potentially win $125 in a
few tries". It seems to me those are emotions (and perhaps greed) talking, but
let's test that too.

If 200 people make that bet (100 bet $5 on 12 and 100 bet $125 on the other
result) we would expect the following outcome:

```jl
s = """
numOfBets = 100

outcomeOf100bets = (diceProbs[12] * numOfBets * 125) -
	((1 - diceProbs[12]) * numOfBets * 5)
# or
outcomeOf100bets = ((diceProbs[12] * 125) - ((1 - diceProbs[12]) * 5)) * 100
# or simply
outcomeOf100bets = outcomeOf1bet * numOfBets

round(outcomeOf100bets, digits=2)
"""
sco(s)
```

OK. So, above we introduced a few similar ways to calculate that. The result of
the bet is `jl round(outcomeOf100bets, digits=2)`. In reality roughly 97 people
that bet $5 on two sixes (6 + 6 = 12) lost their money and only 3 of them won
$125 dollars which gives us $3*\$125 - 97*\$5= -\$110$ (the numbers are not
exact because based on probability we got `jl diceProbs[12]*100` people and not
3, and so on).

Interestingly, this is the same as if you placed that same bet with me 100
times. Ninety-seven times you would have lost $5 and only 3 times you would have
won $125 dollars. This would leave you over $110 poorer and me over $110 richer.

It seems that instead of betting on 12 (two sixes) many times you would be
better off had you started a casino or a lottery. Then you should find let's say
1'000 people daily that will take that bet (or buy $5 ticket) and get you \$
 `jl abs(round(outcomeOf1bet*1000, digits=2))` (`outcomeOf1bet * 1000`) richer
every day (well, probably less, because you would have to pay some taxes, still
this makes a pretty penny).

OK, you saw right through me and you don't want to take that bet. Hmm, but what
if I say a nice, big "I'm sorry" and offer you another bet. Again, you roll two
six-sided dice. If you get 11 or 12 I give you $90 otherwise you give me
$10. This time you know right away what to do:

```jl
s = """
pWin = sum([diceCounts[i] for i in 11:12]) / numOfRolls
# or
pWin = sum([diceProbs[i] for i in 11:12])

pLose = 1 - pWin

round(pWin * 90 - pLose * 10, digits=2)
"""
sco(s)
```

So, to estimate the probability we can either add number of occurrences of 11
and 12 and divide it by the total occurrences of all events OR, as we learned in
the previous chapter (see @sec:statistics_intro_probability_properties), we can
just add the probabilities of 11 and 12 to happen. Then we proceed with
calculating the expected outcome of the bet and find out that I wanted to trick
you again ("I'm sorry. Sorry.").

Now, using this method (that relies on probability distribution) you will be
able to look through any bet that I will offer you and choose only those that
serve you well. OK, so what is a probability distribution anyway, well it is
just the value that probability takes for any possible outcome. We can represent
it graphically by using any of [Julia's plotting
libraries](https://juliapackages.com/c/graphical-plotting).

Here, I'm going to use [Makie.jl](https://docs.makie.org/stable/) which seems to
produce pleasing to the eye plots and is simple enough (that's what I think
after I read its [Basic
Tutorial](https://docs.makie.org/stable/tutorials/basic-tutorial/)). Nota bene
also its error messages are quite informative (once you learn to read them).

```jl
s = """
import CairoMakie as Cmk

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}

    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end

xs1, ys1 = getSortedKeysVals(diceCounts)
xs2, ys2 = getSortedKeysVals(diceProbs)

fig = Cmk.Figure()
Cmk.barplot(fig[1, 1:2], xs1, ys1,
    color="red",
    axis=(; # the ';' needs to be here
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurrences",
        xticks=2:12)
)
Cmk.barplot(fig[2, 1:2], xs2, ys2,
    color="blue",
    axis=(; # the ';' needs to be here
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Probability of occurrence",
        xticks=2:12)
)
fig
"""
sc(s)
```

First, we extracted the sorted keys and values from our dictionaries
(`diceCounts` and `diceProbs`) using `getSortedKeysVals`. The only new element
here is `|>` operator. It's role is
[piping](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping)
the output of one function as input to another function.
So `keys(d) |> collect |> sort` is just another way of writing
`sort(collect(keys(d)))`. In both cases first we run `keys(d)`, then we use the
result of this function as an input to `collect` function, and finally pass its
result to `sort` function. Out of the two options, the one with `|>` seems to be
clearer to me.

Regarding the `getSortedKeysVals` it returns a tuple of sorted keys and values
(that correspond with the keys). In line `xs1, ys1 =
getSortedKeysVals(diceCounts)` we unpack then values and assign them to `xs1`
(it gets sorted keys) and `ys1` (it get values that correspond with the
keys). We do likewise for `diceProbs` in the line below.

In the next step we draw the distributions as bar plots (`Cmk.barplot`). The
code seems to be pretty self explanatory after you read [the
tutorial](https://docs.makie.org/stable/tutorials/basic-tutorial/) that I just
mentioned. Two points of notice here (in case you wanted to know more): 1) the
`axis=`, `color=`, `xlabel=`, etc. are so called [keyword
arguments](https://docs.julialang.org/en/v1/manual/functions/#Keyword-Arguments),
2) the `axis` keyword argument accepts a so called [named
tuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple). OK, let's
get back to the graph. The number of counts (number of occurrences) on Y-axis is
displayed in a scientific notation, i.e. $1.0 x 10^4$ is 10'000 (one with 4
zeros) and $1.5 = 10^4$ is 15'000.

> **_Note:_** Because of the compilation process running Julia's plots for the
> first time may be slow. If that is the case you may try some tricks
> recommended by package designers, e.g. [this one from the creators of
> Gadfly.jl](http://gadflyjl.org/stable/#Compilation).

![Rolling two 6-sided dice (counts and probabilities).](./images/rolling2diceCountsProbs.png){#fig:twoDiceCountsProbs}

OK, but why did I even bother to talk about probability distribution (except for
the great enlightenment it might have given to you)? Well, because it is
important. It turns out that in statistics one relies on many distributions. For
instance:

- We want to know if people in city A are taller than in city B. We take at
  random 10 people from each of the cities, we measure them and run a famous
  [Student's T-test](https://en.wikipedia.org/wiki/Student%27s_t-test) to find
  out. It gives us the probability that helps us answer our question. It does so
  based on a
  [t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution).

- We want to know if cigarette smokers are more likely to believe in
  ghosts. What we do is we find random groups of smokers and non-smokers and ask
  them about it (Do you believe in ghosts?). We record the results and run a
  [chi squared test](https://en.wikipedia.org/wiki/Chi-squared_test) that gives
  us the probability that helps us answer our question. It does so based on a
  [chi squared
  distribution](https://en.wikipedia.org/wiki/Chi-squared_distribution).

OK, that should be enough for now. Take some rest, and when you're ready
continue with the next chapter.

## Normal distribution {#sec:statistics_normal_distribution}

Let's start where we left. We know that a probability distribution is a
(possibly graphical) depiction of the values that probability takes for any
possible outcome.  Probabilities come in different forms and
shapes. Additionally one probability distribution can transform into another (or
at least into a distribution that resembles another distribution).

Let's look at a few examples.

![Experimental binomial and multinomial probability distributions.](./images/binomAndMultinomDistr.png){#fig:unifAndBinomDistr}

Here we got experimental distributions for tossing a standard fair coin and
rolling a six-sided dice. The code for @fig:unifAndBinomDistr can be found in
[the code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets) and it
uses the same functions that we developed in the previous chapter(s).

Those are examples of the binomial (`bi` - two, `nomen` - name, those two names
could be: heads/tails, A/B, or most general success/failure) and multinomial
(`multi` - many, `nomen` - name, here the names are `1:6`)
distributions. Moreover, both of them are examples of discrete (probability is
calculated for a few distinctive values) and uniform (values are equally likely
to be observed) distribution.

Notice that in the @fig:unifAndBinomDistr (above) rolling one six-sided dice
gives us an uniform distribution (each value is equally likely to be
observed). However in the previous chapter when tossing two six-sided dice we
got the distribution that looks like this.

![Experimental probability distribution for rolling two 6-sided dice.](./images/rolling2diceProbs.png){#fig:rolling2diceProbs}

What we got here is a [bell](https://en.wikipedia.org/wiki/Bell) shaped
distribution (c'mon use your imagination). Here the middle values are the ones
most likely to occur. It turns out that quite a few distributions may transform
into the distribution that is bell shaped (as an exercise you may want to draw a
distribution for the number of heads when tossing 10 fair coins
simultaneously). Moreover, many biological phenomena got a bell shaped
distribution, e.g. men's height or the famous [intelligence
quotient](https://en.wikipedia.org/wiki/Intelligence_quotient) (aka IQ). The
theoretical name for it is [normal
distribution](https://en.wikipedia.org/wiki/Normal_distribution). Placed on a
graph it looks like this.

![Examples of normal distribution.](./images/normDistribution.png){#fig:normDistribution}

In @fig:normDistribution the upper panel depicts standard normal distributions
($\mu = 0, \sigma = 1$, explanation in a moment), a theoretical distribution
that all statisticians and probably some mathematicians love. The bottom panel
shows a distribution that is likely closer to the adult males' height
distribution in my country. Long time ago I read that the average height for an
adult man in Poland is 172 [cm] (5.64 [feet]) and standard deviation is equal to
7 [cm] (2.75 [inch]) hence this plot.

> **_Note:_** In order to get a real height distribution in a country you should
> probably visit a web site of the country's statistics office instead relying
> on information like mine.

As you can see normal distribution is often depicted as a line plot. That is
because it is a continuous distribution (the values on x axes can take any
number from a given range). Take a look at the height. In my old [identity card
](https://en.wikipedia.org/wiki/Polish_identity_card) next to the field "Height
in cm" stands "181", but is this really my precise height? What if during a
measurement the height was 180.7 or 181.3 and in the ID there could be only
height in integers. I would have to round it, right? So based on the identity
card information my real height is probably somewhere between 180.5 and
181.49999... . Moreover, it can be any value in between (like 180.6354551...,
although in reality a measuring device does not have such a precision). So, in
the bottom panel of @fig:normDistribution I rounded theoretical values for
height (`round(height, digits=0)`) obtained from `Rand.rand(Dsts.Normal(172, 7),
10_000_000)` (`Dsts` is `Distributions` package that we will discuss soon
enough). Next, I drew bars (using `Cmk.barplot` that you know), and added a line
that goes through the middle of each bar (to make the transition to the figure
in the top panel more obvious).

As you perhaps noticed, the distribution is characterized by two parameters:

- the average (also called the mean) (in population denoted as: $\mu$, in sample
  as: $\overline{x}$)
- the standard deviation (in population denoted as: $\sigma$, in sample as: $s$,
  $sd$ or $std$)

We already know the first one from school and previous chapters (e.g. `getAvg`
from @sec:julia_language_for_loops). The last one however requires some
explanation.

Let's say that we have two students. Here are their grades.

```jl
s = """
gradesStudA = [3.0, 3.5, 5.0, 4.5, 4.0]
gradesStudB = [6.0, 5.5, 1.5, 1.0, 6.0]
"""
sc(s)
```

Imagine that we want to send one student to represent the school in a national
level competition.  Therefore we want to know who is a better student. So, let's
check their averages.

```jl
s = """
avgStudA = getAvg(gradesStudA)
avgStudB = getAvg(gradesStudB)
(avgStudA, avgStudB)
"""
sco(s)
```

Hmm, they are identical. OK, in that situation let's see who is more consistent
with their scores.

To test the spread of the scores around the mean we will subtract every single
score from the mean and take their average (average of the differences).

```jl
s = """
diffsStudA = gradesStudA .- avgStudA
diffsStudB = gradesStudB .- avgStudB
(getAvg(diffsStudA), getAvg(diffsStudB))
"""
sco(s)
```

> **_Note:_** Here we used the dot functions described in
> @sec:julia_language_dot_functions

The method is of no use since `sum(diffs)` is always equal to 0 (and hence the
average is 0). See for yourself

```jl
s = """
(
	diffsStudA,
	diffsStudB
)
"""
replace(sco(s), Regex("],") => "],\n")
```

And

```jl
s = """
(sum(diffsStudA), sum(diffsStudB))
"""
sco(s)
```

Personally in this situation I would take the average of diffs without looking
at the sign (`abs` function does that) like so.

```jl
s = """
absDiffsStudA = abs.(diffsStudA)
absDiffsStudB = abs.(diffsStudB)
(getAvg(absDiffsStudA), getAvg(absDiffsStudB))
"""
sco(s)
```

Based on this we would say that student A is more consistent in his grades so he
is probably a better student of the two. I would send student A to represent the
school during the national level competition. Student B is also good, but
choosing him is a gamble. He could shine or embarrass himself (and spot the
school's name) during the competition.

For any reason statisticians decided to get rid of the sign in a different way,
i.e. by squaring ($x^{2}$) the diffs. Afterwards they calculated the average of
it. This average is named [variance](https://en.wikipedia.org/wiki/Variance).
Next, they took square root of it ($\sqrt{variance}$) to get rid of the squaring
(get the spread of the data in the same scale as the original values, since
$\sqrt{x^2} = x$).  So, they
did more or less this

```jl
s = """
# variance
function getVar(nums::Vector{<:Real})::Real
	avg::Real = getAvg(nums)
	diffs::Vector{<:Real} = nums .- avg
	squaredDiffs::Vector{<:Real} = diffs .^ 2
	return getAvg(squaredDiffs)
end

# standard deviation
function getSd(nums::Vector{<:Real})::Real
	return sqrt(getVar(nums))
end

(getSd(gradesStudA), getSd(gradesStudB))
"""
sco(s)
```

> **_Note:_** In reality the variance and standard deviation for a sample are
> calculated with slightly different formula. This is why the numbers returned
> here may be marginally different to the ones produced by other statistical
> software. Still, the functions above are easier to understand and give a
> better feel of the general ideas.

In the end we got similar numbers, reasoning, and conclusions to the one based
on `abs` function.

Although I like my method better the `sd` and squaring/square rooting is so
deeply fixed into statistics that everyone should know it. Anyway, as you can
see the standard deviation is just an average spread of data around the
mean. The bigger value for `sd` the bigger the spread. Of course the opposite is
also true.

And now a big question.

**Why should we care about the mean ($\mu$, $\overline{x}$) or sd ($\sigma$,
$s$, $sd$, $std$) anyway?**

The answer. For practical reasons that got something to do with the so called
[three sigma
rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule).

### The three sigma rule {#sec:statistics_intro_three_sigma_rule}

[The rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule) says that:

- roughly 68% of the results in the population lie within $\pm$ 1 sd from the mean
- roughly 95% of the results in the population lie within $\pm$ 2 sd from the mean
- roughly 99% of the results in the population lie within $\pm$ 3 sd from the mean

**Example 1**

Have you ever tested your [blood](https://en.wikipedia.org/wiki/Blood) and
received the lab results that said something like

- [RBC](https://en.wikipedia.org/wiki/Complete_blood_count#Reference_ranges):
  4.45 [$10^{6}/\mu L$] (4.2 - 6.00)

The RBC stands for **r**ed **b**lood **c**ell count and the parenthesis contain
the reference values (if you are within this normal range then it is a good
sign). But where did those reference values come from? This [wikipedia's
page](https://en.wikipedia.org/wiki/Blood) gives us a clue. It reports a value
for [hematocrit](https://en.wikipedia.org/wiki/Hematocrit) (a
fraction/percentage of whole blood that is occupied by red blood cells) to be:

- 45 $\pm$ 7 (38–52%) for males
- 42 $\pm$ 5 (37–47%) for females

Look at this $\pm$ symbol. Have you seen it before? No? Then look at the three
sigma rule above.

The reference values were most likely composed in the following way. A large
number (let's say 30'000) females gave their blood for testing. Hematocrit value
was calculated for all of them. The distribution was established in a similar
way that we did it before. The average hematocrit was 42 units, the standard
deviation was 5 units. The majority of the results (roughly 68%) lie within
$\pm$ 1 sd from the mean. If so, then we got 42 - 5 = 37, and 42 + 5 = 47. And
that is how those two values were considered to be the reference values for the
population. Most likely the same is true for other reference values you see in
your lab results when you [test your
blood](https://en.wikipedia.org/wiki/Complete_blood_count) or when you perform
other medical examination.

**Example 2**

Let's say a person named Peter lives in Poland. Peter approaches the famous IQ
test in one of our universities. He read on the internet that there are
different [intelligence
scales](https://en.wikipedia.org/wiki/Intelligence_quotient#Current_tests) used
throughout the world. His score is 125. The standard deviation is 24. Is his
score high, does it indicate he is gifted (a genius level intellect)? Well, in
order to be a genius one has to be in the top 2% of the population with respect
to their IQ value. What is the location of Peter's IQ value in the population.

The score of 125 is just a bit greater than 1 standard deviation above the mean
(which in an IQ test is always 100). From @sec:statistics_prob_distribution we
know that when we add all the probabilities we get 1 (so the area under the
curve in @fig:normDistribution is equal to 1). Half of the area lies on the
left, half of it on the right (1 / 2 = 0.5). So, a person with IQ = 100 is as
intelligent or more intelligent than half the people ($\frac{1}{2}$ = 0.5 = 50%)
in the population. Roughly 68% of the results lies within 1 sd from the mean
(half of it below, half of it above). So, from IQ = 100 to IQ = 124 we got (68%
/ 2 = 34%). By adding 50% (IQ $\le$ 100) to 34% (100 $\le$ IQ $\le$ 124) we get
50% + 34% = 84%. Therefore in our case Peter (with his IQ = 125) is more
intelligent than 84% of people in the population (so top 16% of the
population). His intelligence is above the average, but it is not enough to
label him a genius.

### Distributions package {#sec:statistics_intro_distributions_package}

This is all nice and good to know, but in practice it is slow and not precise
enough. What if in the previous example the IQ was let's say 139. What is the
percentage of people more intelligent than Peter. In the past that kind of
questions were to be answered with satisfactory precision using statistical
tables at the end of a textbook. Nowadays it can be quickly answered with a
greater exactitude and speed, e.g. with the
[Distributions](https://juliastats.org/Distributions.jl/stable/) package. First
let's define a helper function that is going to tell us how many standard
deviations above or below the mean a given value is (it is called
[z-score](https://en.wikipedia.org/wiki/Standard_score))

```jl
s = """
# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
	return (value - mean)/sd
end
"""
sc(s)
```

OK, now let's give it a swing. First, something simple IQ = 76, and IQ = 124
(should equal to -1 sd, +1 sd). *Alternatively, look at the value returned by
`getZScore` as a value on the x-axis in @fig:normDistribution (top panel).*

```jl
s = """
(getZScore(100, 24, 76), getZScore(100, 24, 124))
"""
sco(s)
```

Indeed, it seems to be working as expected, and now the value from this task

```jl
s = """
zScorePeterIQ139 = getZScore(100, 24, 139)
zScorePeterIQ139
"""
sco(s)
```

It is `jl zScorePeterIQ139` sd above the mean. However, we cannot use it
directly to estimate the percentage of people above that score because due to
the shape of the distribution in @fig:normDistribution the change is not linear:
1 sd ≈ 68%, 2 sd ≈ 95%, 3 sd ≈ 99% (first it changes quickly then it slows
down). This is where the `Distributions` package comes into the picture. Under
the hood it uses 'scary' mathematical formulas for [normal
distribution](https://en.wikipedia.org/wiki/Normal_distribution) to get us what
we want. In our case we use it like this

```jl
s = """
import Distributions as Dsts

Dsts.cdf(Dsts.Normal(), zScorePeterIQ139)
"""
sco(s)
```

Here we first create a standard normal distribution with $\mu$ = 0 and $\sigma$
= 1 (`Dsts.Normal()`). Then we sum all the probabilities that are lower than or
equal to `zScorePeterIQ139` = `getZScore(100, 24, 139)` = `jl getZScore(100, 24,
139)` standard deviation above the mean with `Dsts.cdf`. We see that roughly
 `jl round(Dsts.cdf(Dsts.Normal(), getZScore(100, 24, 139)), digits=4)` ≈ 95% of
people is as intelligent or less intelligent than Peter. Therefore in this case
only ≈0.05 or ≈5% of people are more intelligent than him. Alternatively you may
say that the probability that a randomly chosen person from that population is
more intelligent than Peter is ≈0.05 or ≈5%.

> **_Note:_** `cdf` in `Dsts.cdf` stands for [cumulative distribution
> function](https://en.wikipedia.org/wiki/Cumulative_distribution_function). For
> more information on `Dsts.cdf` see [these
> docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.cdf-Tuple{UnivariateDistribution,%20Real})
> or for `Dsts.Normal` [those
> docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Normal).

The above is a classical method and it is useful to know it. Based on the
z-score you can check the appropriate percentage/probability for a given value
in a table that is usually placed at the end of a statistics textbook. Make sure
you understand it since, we are going to use this method in the upcoming chapter
on a Student's t-test (see @sec:compare_contin_data_one_samp_ttest).

Luckily, in the case of the normal distribution we don't have to calculate the
z-score. The package can do that for us, compare

```jl
s = """
# for better clarity each method is in a separate line
(
Dsts.cdf(Dsts.Normal(), getZScore(100, 24, 139)),
Dsts.cdf(Dsts.Normal(100, 24), 139)
)
"""
sco(s)
```

So, in this case you can either calculate the z-score for standard normal
distribution with $\mu$ = 0 and $\sigma = 1$ or define a normal distribution
with a given mean and sd (here `Dsts.Normal(100, 24)`) and let the `Dsts.cdf`
calculate the z-score (under the hood) and percentage (it returns it) for you.

To further consolidate our knowledge. Let's go with another example. Remember
that I'm 181 cm tall. Hmm, I wonder what percentage of men in Poland is taller
than me if $\mu = 172$ [cm] and $\sigma = 7$ [cm].

```jl
s = """
1 - Dsts.cdf(Dsts.Normal(172, 7), 181)
"""
sco(s)
```

The `Dsts.cdf` gives me left side of the curve (the area under the curve for
height $\le$ 181). So in order to get those that are higher than me I subtract
it from 1. It seems that under those assumptions roughly 10% of men in Poland
are taller than me (approx. 1 out of 10 men that I encounter is taller than
me). I could also say: "the probability that a randomly chosen man from that
population is higher than me is ≈0.1 or ≈10%. Alternatively I could have used
[Dsts.ccdf](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.ccdf-Tuple{UnivariateDistribution,%20Real})
function which under the hood does `1 - Dsts.cdf(distribution, xCutoffPoint)`.

OK, and how many men in Poland are exactly as tall as I am? In general that is
the job for `Dsts.pdf` (`pdf` stands for [probability density
function](https://en.wikipedia.org/wiki/Probability_density_function), see [the
docs for
Dsts.pdf](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.pdf-Tuple{UnivariateDistribution,%20Real})). It
works pretty well for discrete distributions (we talked about them at the
beginning of this sub-chapter). For instance theoretical probability of getting
12 while rolling two six-sided dice is

```jl
s = """
Dsts.pdf(Dsts.Binomial(2, 1/6), 2)
"""
sco(s)
```

Compare it with the empirical probability from @sec:statistics_prob_distribution
which was equal to `jl diceProbs[12]`. Here we treated it as a binomial
distribution (success: two sixes (6 + 6 = 12), failure: other result) hence
`Dsts.Binomial` with `2` (number of dice to roll) and `1/6` (probability of
getting 6 in a single roll). Then we used `Dsts.pdf` to get the probability of
getting exactly two sixes. More info on `Dsts.Binomial` can be found
[here](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Binomial)
and on `Dsts.pdf` can be found
[there](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.pdf-Tuple{UnivariateDistribution,%20Real}).

However there is a problem with using `Dsts.pdf` for continues distributions
because it can take any of the infinite values within the range. Remember, in
theory there is an infinite number of values between 180 and 181 (like 180.1111,
180.12222, etc.). So usually for practical reasons it is recommended not to
calculate a probability density function (hence `pdf`) for a continuous
distribution (1 / infinity $\approx$ 0). Still, remember that the height of 181
[cm] means that the value lies somewhere between 180.5 and
181.49999... . Moreover, we can reliably calculate the probabilities (with
`Dsts.cdf`) for $\le$ 180.5 and $\le$ 181.49999... so a good approximation would
be

```jl
s = """
heightDist = Dsts.Normal(172, 7)
# 2 digits after dot because of the assumed precision of a measuring device
Dsts.cdf(heightDist, 181.49) - Dsts.cdf(heightDist, 180.50)
"""
sco(s)
```

OK. So it seems that roughly 2.5% of adult men in Poland got 181 [cm] in the
field "Height" in their identity cards. If there are let's say 10 million adult
men in Poland then roughly `jl round(10_000_000*0.025, digits=0)` (so
 `jl trunc(Int, 10_000_000*0.025/1000)` k) people are approximately my
height". Alternatively under those assumptions the probability that a random man
from the population is as tall as I am (181 cm in the height field of his
identity card) is ≈0.025 or ≈2.5%.

If you are still confused about this method take a look at the figure below.

![Using cdf to calculate proportion of men that are between 170 and 180 [cm] tall.](./images/normDistCdfUsage.png){#fig:normDistCdfUsage}

Here for better separation I placed the height of men between 170 and 180
[cm]. The method that I used subtracts the area in blue from the area in red
(red - blue). That is exactly what I did (but for 181.49 and 180.50 [cm]) when I
typed `Dsts.cdf(heightDist, 181.49) - Dsts.cdf(heightDist, 180.50)` above.

OK, time for the last theoretical sub-chapter in this section. Whenever you're
ready click on the right arrow.

## Hypothesis testing {#sec:statistics_intro_hypothesis_testing}

OK, now we are going to discuss a concept of hypothesis testing. But first let's
go through an example from everyday life that we know or at least can
imagine. Ready?

### A game of tennis {#sec:statistics_intro_tennis}

So imagine there is a group of people and among them two amateur tennis players:
John and Peter. Everyone wants to know which one of them is a better tennis
player. Well, there is only one way to find out. Let's play some games!

As far as I'm aware a tennis match can end with a win of one player, the other
loses (there are no draws). Before the games the people set the rules. Everyone
agrees that the players will play six games. To prove their supremacy a player
must win all six games (six wins in a row are unlikely to happen by accident, I
hope we can all agree on that). The series of games ends with the result 0-6 for
Peter. According to the previously set rules he is declared the local champion.

Believe it or not but this is what statisticians do. Of course they use more
formal methodology and some mathematics, but still, this is what they do:

- before the experiment they start with two assumptions

  + initial assumption: be fair and assume that both players are equally good
    (this is called [null
    hypothesis](https://en.wikipedia.org/wiki/Null_hypothesis), $H_{0}$)
  + alternative assumption: one player is better than the other (this is called
    [alternative
    hypothesis](https://en.wikipedia.org/wiki/Alternative_hypothesis), $H_{A}$)

- before the experiment they decide on how big a sample should be (in our case six games).
- before the experiment they decide on the cutoff level, once it is reached they
  will abandon their initial assumption and chose the alternative (in our case
  when a player wins six games in a row)
- they conduct the experiment (players play six games) and record the results
- after the experiment when the result provides enough evidence (in our case six
  games won by the same player) they decide to reject $H_{0}$, and choose
  $H_{A}$. Otherwise they stick to their initial assumption (do not reject
  $H_{0}$)

And that's how it is, only that statisticians prefer to rely on probabilities
instead of absolute numbers. So in our case a statistician says:

"I assume that $H_{0}$ is true. Then I will conduct the experiment and record
then result. I will calculate the probability of such a result (or more extreme
result) happening by chance. If it is small enough, let's say 5% or less, then
the result is unlikely to have occurred by accident. Therefore I will reject my
initial assumption ($H_{0}$) and choose the alternative ($H_{A}$). Otherwise I
will stay with my initial assumption."

Let's see such a process in practice and connect it with what we already know.

### Tennis - computer simulation {#sec:statistics_intro_tennis_comp_simul}

First a computer simulation.

```jl
s = """
function getResultOf6TennisGames()
	return sum(Rand.rand(0:1, 6)) # 0 means John won, 1 means Peter won
end

Rand.seed!(321)
tennisGames = [getResultOf6TennisGames() for _ in 1:100_000]
tennisCounts = getCounts(tennisGames)
tennisProbs = getProbs(tennisCounts)
"""
sc(s)
```

Here `getResultOf6TennisGames` returns a result of 6 games (in every game each
player got the same chance to win). When John wins a game then we get 0, when
Peter we get 1. So if after running `getResultOf6TennisGames` we get, e.g. 4 we
know that Peter won 4 games and John won 2 games. We repeat the experiment
100'000 times to get a reliable estimate of the results.

OK, at the beginning of this chapter we intuitively said that a player needs to
win 6 games to become the local champion. We know that the result was 0-6 for
Peter. Let's see what is the probability that Peter won by chance six games in a
row.

```jl
s = """
tennisProbs[6]
"""
sco(s)
```

In this case the probability of Peter winning by chance six games in a row is
very small. So it seems that intuitively we set the cutoff level well. Let's see
if the statistician from the quotation above would be satisfied ("If it is small
enough, let's say 5% or less, then the result is unlikely to have occurred by
accident. Therefore I will reject my initial assumption ($H_{0}$) and choose the
alternative ($H_{A}$). Otherwise I will stay with my initial assumption.")

```jl
s = """
# sigLevel - significance level for probability
# 5% = 5/100 = 0.05
function shouldRejectH0(prob::Float64, sigLevel::Float64 = 0.05)::Bool
	@assert (0 <= prob <= 1) "prob must be in range [0-1]"
	@assert (0 <= sigLevel <= 1) "sigLevel must be in range [0-1]"
	return prob <= sigLevel
end

shouldRejectH0(tennisProbs[6])
"""
sco(s)
```

Indeed he would. He would have to reject $H_{0}$ and assume that Peter is a
better player ($H_{A}$).

### Tennis - theoretical calculations {#sec:statistics_intro_tennis_theor_calc}

OK, to be sure of our conclusions let's try the same with
[Distributions](https://juliastats.org/Distributions.jl/stable/) package we met
before (imported as `Dsts`).

Remember one of two tennis players must win a game (John or Peter). So this is a
binomial distributions we met before. We assume ($H_{0}$) both of them play
equally well so the probability of any of them winning is 0.5. Now we can
proceed like this using Dictionary comprehensions we have seen before (e.g. see
`getProbs` definition from @sec:statistics_prob_theor_practice)

```jl
s = """
tennisTheorProbs = Dict(i => Dsts.pdf(Dsts.Binomial(6, 0.5), i) for i in 0:6)
tennisTheorProbs[6]
"""
sco(s)
```

Yep, the number is pretty close to `tennisProbs[6]` we got before which is
 `jl tennisProbs[6]`. So we decide to go with $H_{A}$ and say that Peter is a
better player. Just in case I will place both distributions (experimental and
theoretical) one below the other to make the comparison easier. Behold

![Probability distribution for 6 tennis games if $H_{0}$ is true.](./images/tennisExperimTheorDists.png){#fig:tennisExperimTheorDists}

Once we warmed up we can even calculate the probability using our knowledge from
@sec:statistics_intro_probability_summary. We can do this since basically given
our null hypothesis ($H_{0}$) we compared the result of a game between John and
Peter to a coin toss (0 or 1, John or Peter, heads or tails).

The probability of Peter winning a single game is $P(Peter) = \frac{1}{2} =
0.5$. Peter won all six games. In order to get two wins, first he had to won one
game. In order to get three wins first he had to won two games, and so on. So he
had to win game 1 AND game 2 AND game 3 AND ... . Given the above, and what we
stated in @sec:statistics_intro_probability_summary, here we deal with
probabilities conjunction. Therefore we use probability multiplication like so

```jl
s = """
tennisTheorProbWin6games = 0.5 * 0.5 * 0.5 * 0.5 * 0.5 * 0.5
# or
tennisTheorProbWin6games = 0.5 ^ 6

tennisTheorProbWin6games
"""
sco(s)
```

Compare it with `tennisThorProbs[6]` calculated by `Distributions` package

```jl
s = """
(tennisTheorProbs[6], tennisTheorProbWin6games)
"""
sco(s)
```

They are the same. The difference is caused by computer representation of floats
and rounding (as a reminder see @sec:julia_float_comparisons, and
@sec:julia_language_exercise2_solution).

Anyway I just wanted to present all three methods for two reasons. First, that's
the way we checked our reasoning at math in primary school (solving with
different methods). Second, chances are that one of the explanations may be too
vague for you, if so help yourself to the other methods :)

In general, as a rule of thumb you should remember that the null hypothesis
($H_{0}$) assumes lack of differences/equality, etc. (and this is what we
assumed in this tennis example).

### One or two tails {#sec:statistics_intro_one_or_two_tails}

Hopefully, the above explanations were clear enough. There is a small nuance to
what we did. In the beginning of @sec:statistics_intro_tennis we said 'To prove
their supremacy a player must win all six games'. A player, so either John or
Peter. Still, we calculated only the probability of Peter winning the six games
(`tennisTheorProbs[6]`), Peter and not John. What we did there was calculating
[one tail probability](https://en.wikipedia.org/wiki/One-_and_two-tailed_tests)
(see the figures in the link). Now, take a look at @fig:tennisExperimTheorDists
(e.g. bottom) the middle of it is 'body' and the edges to the left and right are
tails.

This approach (one-tailed test) is rather OK in our case. However, in statistics
it is frequently recommended to calculate two-tails probability (usually this is
the default option in many statistical functions/packages). That is why at the
beginning of @sec:statistics_intro_tennis I wrote 'alternative assumption: one
player is better than the other (this is called alternative hypothesis,
$H_{A}$)'.

Calculating the two-tail probability is very simple, we can either add
`tennisTheorProbs[6] + tennisTheorProbs[0]` (remember 0 means that John won all
six games) or multiply `tennisTheorProbs[6]` by 2 (since the graph in
@fig:tennisExperimTheorDists is symmetrical).

```jl
s = """
(tennisTheorProbs[6] + tennisTheorProbs[0], tennisTheorProbs[6] * 2)
"""
sco(s)
```

Once we got it we can perform our reasoning one more time.

```jl
s = """
shouldRejectH0(tennisTheorProbs[6] + tennisTheorProbs[0])
"""
sco(s)
```

In this case the decision is the same (but that is not always the case). As I
said before in general it is recommended to choose two-tailed test over the
one-tailed. Why? Let me try to explain this with another example.

Imagine I tell you that I'm a psychic that talks with the spirits and I know a
lot of stuff that is covered to mere mortals (like the rank and suit of a
covered [playing card](https://en.wikipedia.org/wiki/Playing_card)). You say you
don't believe me and propose a simple test.

You take 10 random cards from a deck. My task is to tell you the color (red or
black). And I did, the only problem is that I was wrong every single time! If
you think that proves that your were right in the first place then try to guess
10 cards in a row wrongly yourself (if you don't have cards on you go with 10
consecutive fair coin tosses).

It turns out that guessing 10 cards wrong is just as unlikely as guessing 10 of
them right (`0.5^10` = `jl 0.5^10` or 1 per `jl 2^10` tries in each case). This
could potentially mean a few things, e.g.

- I really talk with the spirits, but in their language "red" means "black", and
  "black" means "red" (cultural fun fact: they say Bulgarians nod their heads
  when they say "no", and shake them for "yes"),
- I live in one of 1024 alternative dimensions/realities and in this reality I
  managed to guess all of them wrong, when other versions of me had mixed
  results, and that one version of me guessed all of them right,
- I am a superhero and have an x-ray vision in my eyes so I saw the cards, but I
  decided to tell them wrong to protect my secret identity,
- I cheated, and were able to see the cards beforehand, but decided to mock you,
- or some other explanation is in order, but I didn't think of it right now.

The small probability only tells us that the result is unlikely to has happened
by chance alone. Still, you should always choose your null ($H_{0}$) and
alternative ($H_{A}$) hypothesis carefully. Moreover, it is a good idea to look
at both ends of a probability distribution.

### All the errors that we make {#sec:statistics_intro_errors}

Long time ago when I was a student I visited a local chess club. I was late that
day, and only one person was without a pair, Paul. I introduced myself and we
played a few games. In chess you can either win, lose, or draw a
game. Unfortunately, I lost all six games. I was upset, I assumed I just
encountered a better player. I thought: "Too bad, but next week I will be on
time and find someone else to play with" (nobody likes loosing all the
time). Next week I came to the club, and again the only person without a pair
was Paul (just my luck). Still, despite the bad feelings I won all six games
that we played that day (what are the odds). Later on it turned out that me and
Paul are pretty well matched chess players (we played chess at a similar level).

The story demonstrates that even when there is a lot of evidence (six lost games
during the first meeting) we can still make an error by rejecting our null
hypothesis ($H_{0}$).

In fact, whenever we do statistics we turn into judges, since we can make a
mistake in two ways (see figure below).

![A judge making a verdict. FP - false positive, FN - false negative.](./images/judgeVerdict.png){#fig:judgeVerdict}

An accused is either guilty or innocent. A judge (or a jury in some countries)
sets a verdict based on the evidence.

If the accused is innocent but is sentenced anyway then it is an error, it is
usually called [**type I
error**](https://en.wikipedia.org/wiki/Type_I_and_type_II_errors) (FP - false
positive in @fig:judgeVerdict). Its probability is denoted by the first letter
of Greek alphabet, so alpha (α).

In the case of John and Peter playing tennis the type I probability was $\le$
0.05. More precisely it was `tennisTheorProbs[6]` =
 `jl tennisTheorProbWin6games` (for a one tailed test).

If the accused is guilty but is declared innocent then it is another type of
error, it is usually called **type II error** (FN - false negative in
@fig:judgeVerdict). Its probability is denoted by the second letter of Greek
alphabet, so beta (β). Beta helps us determine [the power of a
test](https://en.wikipedia.org/wiki/Power_of_a_test) (power = 1 - β), i.e. if
$H_{A}$ is really true then how likely it is that we will choose $H_{A}$ over
$H_{0}$.

So to sum up, in the judge analogy innocent is $H_{0}$ being true and guilty is
$H_{A}$ being true.

Unfortunately, most of the statistical textbooks that I've read revolve around
type I errors and alphas, whereas type II error is covered much less extensively
(hence my own knowledge of the topic is more limited).

In the tennis example above we rejected $H_{0}$, hence here we risk committing
type I error. Therefore, we didn't speak about type II error, but don't worry we
will discuss it in more detail in the upcoming exercises at the end of this
chapter (see @sec:statistics_intro_exercise5).

### Cutoff levels {#sec:statistics_intro_cutoff_levels}

OK, once we know what are the type I and type II errors it is time to discuss
their cutoff values.

Obviously, the ideal situation would be if the probabilities of both type I and
type II errors were exactly 0 (no mistakes is always the best). The only problem
is that this is not possible. In our tennis example one player won all six
games, and still some small risk of a mistake existed (`tennisTheorProbs[6] =`
 `jl tennisTheorProbWin6games`). If you ever see a statistical package reporting
p-value equal, e.g. 0.0000, then this is just rounding to 4 decimal places and
not an actual zero. So what are the acceptable cutoff levels for $\alpha$
(probability of type I error) and $\beta$ (probability of type II error).

The most popular choices for $\alpha$ cutoff values are:

- 0.05, or
- 0.01

Actually, as far as I'm aware, the first of them ($\alpha = 0.05$) was initially
proposed by [Ronald Fisher](https://en.wikipedia.org/wiki/Ronald_Fisher), a
person sometimes named the father of XX-century statistics. This value was
chosen arbitrarily and is currently frowned upon by some modern statisticians as
being to lenient. Therefore, 0.01 is proposed as a more reasonable alternative.

As regards $\beta$ its two most commonly accepted cutoff values are:

- 0.2, or
- 0.1

Actually, as far as I remember the textbooks usually do not report values for
$\beta$, but for power of the test (if $H_{A}$ is really true then how likely it
is that we will choose $H_{A}$ over $H_{0}$) to be 0.8 or 0.9. However, since as
we mentioned earlier power = 1 - $\beta$, then we can easily calculate the value
for this parameter.

OK, enough of theory, time for some practice. Whenever you're ready click the
right arrow to proceed to the exercises I prepared for you.

## Statistics intro - Exercises {#sec:statistics_intro_exercises}

So, here are some exercises that you may want to solve to get from this chapter
as much as you can (best option). Alternatively, you may read the task
descriptions and the solutions (and try to understand them).

### Exercise 1 {#sec:statistics_intro_exercise1}

Some mobile phones and cash dispensers prevent unauthorized access to the
resources by using a 4-digit PIN number.

What is the probability that a randomly typed number will be the right one?

*Hint. Calculate how many different numbers you can type. If you get stuck, try
to reduce the problem to 1- or 2-digit PIN number.*

### Exercise 2 {#sec:statistics_intro_exercise2}

A few years ago during a home party a few people bragged that they can recognize
beer blindly, just by taste, since, e.g. "the beer of brand X is great, of brand
Y is OK, but of band Z is close to piss" (hmm, how can they tell?).

We decided to put that to the test. We bought six different beer brands. One
person poured them to cups marked 1-6. The task was to taste the beer and
correctly place a label on it.

What is the probability that a person would place correctly 6 labels on 6
different beer at random.

*Hint. This task may be seen as ordering of different objects. As always you may
reduce the problem to a smaller one. For instance think how many different
orderings of 3 beer do we have.*

### Exercise 3 {#sec:statistics_intro_exercise3}

Do you still remember our tennis example from @sec:statistics_intro_tennis, I
hope so. Let's modify it a bit to solidify your understanding of the topic.

Imagine John and Peter played 6 games, but this time the result was 1-5 for
Peter. Is the difference statistically significant at the crazy cutoff level for
$\alpha$ equal to 0.15. Calculate the probability (the famous p-values) for one-
and two-tailed tests.

### Exercise 4 {#sec:statistics_intro_exercise4}

In the opening to @sec:statistics_intro_errors I told you a story from the old
times. The day when I met my friend Paul in a local chess club and lost 6 games
in a row while playing with him. So, here is a task for you. If we were both
equally good chess players at that time then what is the probability that this
happened by chance (to make it simpler do one-tailed test)?

### Exercise 5 {#sec:statistics_intro_exercise5}

Remember how in @sec:statistics_intro_errors we talked about a type II error. We
said that if we decide not to reject $H_{0}$ we risk to commit a type II error
or β. It is FN, i.e. false negative, in our judge analogy from
@sec:statistics_intro_errors (declaring a person that is really guilty to be
innocent). In statistics this is when the $H_{A}$ is true but we fail to say so
and stay with our initial hypothesis ($H_{0}$).

So here is the task.

Assume that the result of the six tennis games was 1-5 for Peter (like in
@sec:statistics_intro_exercise3). Write a computer simulation that estimates the
probability of type II error that we commit in this case by not rejecting
$H_{0}$ (if the cutoff level is 0.05). To make it easier use one-tailed
probabilities.

*Hint: assume that $H_{A}$ is true, so in reality Peter wins with John on
average with the ratio 5 to 1 (5 wins - 1 defeat).*

## Statistics intro - Solutions {#sec:statistics_intro_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:statistics_intro_exercise1_solution}

The easiest way to solve this problem is to reduce it to a simpler one.

If the PIN number were only 1-digit, then the total number of possibilities
would be equal to 10 (numbers from 0 to 9).

For a 2-digit PIN the pattern would be as follow:

<pre>
00
01
02
...
09
10
11
12
...
19
20
21
...
98
99
</pre>

So, for every number in the first location there are 10 numbers (0-9) in the
second location. Therefore in total we got numbers in the range 00-99, or to
write it mathematically 10 * 10 different numbers (numbers per pos. 1 * numbers
per pos. 2).

By extension the total number of possibilities for a 4-digit PIN is:

```jl
s = """
# (method1, method2, method3)
(10 * 10 * 10 * 10, 10^4, length(0:9999))
"""
sco(s)
```

So 10'000 numbers. Therefore the probability for a random number being the right
one is `1/10_000` = `jl 1/10_000`

Similar methodology is used to assess the strength of a password to an internet
website.

### Solution to Exercise 2 {#sec:statistics_intro_exercise2_solution}

OK, so let's reduce the problem before we solve it.

If I had only 1 beer and 1 label then there is only one way to do it. The label
in my hand goes to the beer in front of me.

For 2 labels and 2 beer it goes like this:

<pre>
a b
b a
</pre>

I place one of two labels on a first beer, and I'm left with only 1 label for
the second beer. So, 2 possibilities in total.

For 3 labels and 3 beer the possibilities are as follow:

<pre>
a b c
a c b

b a c
b c a

c a b
c b a
</pre>

So here, for the first beer I can assign any of the three labels (`a`, `b`, or
`c`). Then I move to the second beer and have only two labels left in my hand
(if the first got `a`, then the second can get only `b` or `c`). Then I move to
the last beer with the last label in my hand (if the first two were `a` and `b`
then I'm left with `c`). In total I got `3 * 2 * 1` = `jl 3 * 2 * 1`
possibilities.

It turns out this relationship holds also for bigger numbers. In mathematics it
can be calculated using [factorial](https://en.wikipedia.org/wiki/Factorial)
function that is already implemented in Julia (see [the
docs](https://docs.julialang.org/en/v1/base/math/#Base.factorial)).

Still, for practice we're gonna implement one on our own with the `foreach` we
met in @sec:julia_language_map_foreach.

```jl
s = """
function myFactorial(n::Int)::Int
	@assert n > 0 "n must be positive"
	product::Int = 1
	foreach(x -> product *= x, 1:n)
	return product
end

myFactorial(6)
"""
sco(s)
```

> **_Note:_** You may also just use Julia's
> [prod](https://docs.julialang.org/en/v1/base/collections/#Base.prod) function,
> e.g. `prod(1:6)` = `jl prod(1:6)`. Still, be aware that factorial numbers grow
> pretty fast, so for bigger numbers, e.g. `myFactorial(20)` or above you might
> want to change the definition of `myFactorial` to use `BigInt` that we met in
> @sec:julia_language_exercise5_solution.

So, the probability that a person correctly labels 6 beer at random is
`round(1/factorial(6), digits=5)` = `jl round(1/factorial(6), digits=5)`.

I guess that is the reason why out of 7 people that attempted to correctly label
6 beer the results were as follows:

- one person correctly labeled 0 beer
- five people correctly labeled 1 beer
- one person correctly labeled 2 beer

I leave the conclusions to you.

### Solution to Exercise 3 {#sec:statistics_intro_exercise3_solution}

OK, for the original tennis example (see @sec:statistics_intro_tennis) we
answered the question by using a computer simulation first
(@sec:statistics_intro_tennis_comp_simul). For a change, this time we will start
with a 'purely mathematical' calculations. Ready?

In order to get the result of 1-5 for Peter we would have to get a series of
games like this one:

<pre>
# 0 - John's victory, 1 - Peter's victory
0 1 1 1 1 1
</pre>

Probability of either John or Peter winning under $H_{0}$ (assumption that they
play equally well) is $\frac{1}{2}$ = 0.5. So here we got a conjunction of
probabilities (John won AND Peter won AND Peter won AND ...). According to what
we've learned in @sec:statistics_intro_probability_summary we should multiply
the probabilities by each other.

Therefore, the probability of the result above is `0.5 * 0.5 * 0.5 * ...` or
`0.5 ^ 6` = `jl 0.5 ^ 6`. But wait, there's more. We can get such a result (1-5
for Peter) in a few different ways, i.e.

<pre>
0 1 1 1 1 1
# or
1 0 1 1 1 1
# or
1 1 0 1 1 1
# or
1 1 1 0 1 1
# or
1 1 1 1 0 1
# or
1 1 1 1 1 0
</pre>

> **_Note:_** For a big number of games it is tedious and boring to write all
> the possibilities by hand. In this case you may use Julia's
> [binomial](https://docs.julialang.org/en/v1/base/math/#Base.binomial) funcion,
> e.g. `binomial(6, 5)` = `jl binomial(6, 5)`. This tells us how many different
> fives of six objects can we get.

As we said a moment ago, each of this series of games occurs with the
probability of `jl 0.5^6`. Since we used OR (see the coments in the code above)
then according to @sec:statistics_intro_probability_summary we can add
 `jl 0.5^6` six times to itself (or multiply it by 6). So, the probability is
 equal to:

```jl
s = """
prob1to5 = (0.5^6) * 6 # parenthesis were placed for the sake of clarity
prob1to5
"""
sco(s)
```

Of course we must remember what our imaginary statistician said in
@sec:statistics_intro_tennis: "I assume that $H_{0}$ is true. Then I will
conduct the experiment and record then result. I will calculate the probability
of such a result (or more extreme result) happening by chance."

`More extreme` than 1-5 for Peter is 0-6 for Peter, we previously (see
@sec:statistics_intro_tennis_theor_calc) calculated it to be `0.5^6` =
 `jl 0.5^6`. Finally, we can get our p-value (for one-tailed test)

```jl
s2 = """
prob1to5 = (0.5^6) * 6 # parenthesis were placed for the sake of clarity
prob0to6 = 0.5^6
probBothOneTail = prob1to5 + prob0to6

probBothOneTail
"""
sco(s2)
```

> **_Note:_** Once you get used to calculating probabilities you should use
> quick methods like those from `Distributions` package (presented below), but
> for now it is important to understand what happens here, hence those long
> calculations (of `probBothOneTail`) presented here.

Let's quickly verify it with other methods we met before (e.g. in
@sec:statistics_intro_hypothesis_testing)

```jl
s = """
# for better clarity each method is in a separate line
(
probBothOneTail,
1 - Dsts.cdf(Dsts.Binomial(6, 0.5), 4),
Dsts.pdf.(Dsts.Binomial(6, 0.5), 5:6) |> sum,
tennisProbs[5] + tennisProbs[6] # experimental probability
)
"""
sco(s)
```

Yep, they all appear the same (remember about floats rounding and the difference
between theory and practice from @sec:statistics_prob_theor_practice).

So, is it significant at the crazy cutoff level of $\alpha = 0.15$?

```jl
s = """
shouldRejectH0(probBothOneTail, 0.15)
"""
sco(s)
```

Yes, it is (we reject $H_{0}$ on favor of $H_{A}$). And now for the two-tailed
test.

```jl
s = """
# remember the probability distribution is symmetrical, so *2 is OK here
shouldRejectH0(probBothOneTail * 2, 0.15)
"""
sco(s)
```

Here we cannot reject our $H_{0}$.

Of course we all know that this was just for practice, because the acceptable
type I error cutoff level is usually 0.05 or 0.01. In this case, according to
both the one-tailed and two-tailed tests we failed to reject the $H_{0}$.

BTW, this shows how important it is to use a strict mathematical reasoning and
to adhere to our own methodology. I don't know about you but when I had been a
student I would have probably accepted the result 1-5 for Peter as an intuitive
evidence that he is a better tennis player.

We will see how to speed up the calculations in this solution in one of the
upcoming chapters (see @sec:compare_categ_data_flashback).

### Solution to Exercise 4 {#sec:statistics_intro_exercise4_solution}

OK, there maybe more than one way to solve this problem.

**Solution 4.1**

In chess, a game can end with one of three results: white win, black win or a
draw. If we assume each of those options to be equally likely for two well
matched chess players then the probability of each of the three results is `1/3`
(this is our $H_{0}$).

So, similarly to our tennis example from @sec:statistics_intro_tennis the
probability (one-tailed test) of Paul winning all six games is

```jl
s = """
# (1/3) that Paul won a single game AND six games in a row (^6)
(
round((1/3)^6, digits=5),
round(Dsts.pdf(Dsts.Binomial(6, 1/3), 6), digits=5)
)
"""
sco(s)
```

So, you might think right now 'That task was a piece of cake' and you would be
right. But wait, there's more.

**Solution 4.2**

In chess played at a top level (>= 2500 ELO) the most probable outcome is
draw. It occurs with a frequency of roughly 50% (see [this Wikipedia's
page](https://en.wikipedia.org/wiki/Draw_(chess)#Frequency_of_draws)). Based on
that we could assume that for two equally strong chess players the probability
of:

- white winning is `1/4`,
- draw is `2/4` = `1/2`,
- black winning `1/4`

So under those assumptions the probability that Paul won all six games is

```jl
s = """
# (1/4) that Paul won a single game AND six games in a row (^6)
(
round((1/4)^6, digits=5),
round(Dsts.pdf(Dsts.Binomial(6, 1/4), 6), digits=5)
)
"""
sco(s)
```

So a bit lower, than the probability we got before (which was `(1/3)^6` =
 `jl (1/3)^6 |> x -> round(x, digits=5)`).

OK, so I presented you with two possible solutions. One gave the probability of
`(1/3)^6` = `jl (1/3)^6 |> x -> round(x, digits=5)`, whereas the other `(1/4)^6`
= `jl (1/4)^6 |> x -> round(x, digits=5)`. So, which one is it, which one is the
true probability? Well, probably neither. Those are both just estimations of the
true probability and they are only as good as the assumptions that we
make. After all: ["All models are wrong, but some are
useful"](https://en.wikipedia.org/wiki/All_models_are_wrong).

If the assumptions are correct, then we can get a pretty good estimate. Both the
`Solution 4.1` and `Solution 4.2` got reasonable assumptions but they are not
necessarily true (e.g. I'm not a >= 2500 ELO chess player). Still, for practical
reasons they may be more useful than just guessing, for instance if you were
ever to bet on a result of a chess game/match (do you remember the bets from
@sec:statistics_prob_distribution?).

The reason I mentioned it is not for you to place bets on chess matches but to
point on similarities to statistical practice.

For instance, there is a method named [one-way
ANOVA](https://en.wikipedia.org/wiki/One-way_analysis_of_variance) (we will
discuss it in one of the upcoming chapters). Sometimes it requires to conduct a
so called [post-hoc
test](https://en.wikipedia.org/wiki/Post_hoc_analysis). There are quite a few of
them to choose from (see the link above) and they rely on different
assumptions. For instance one may do Fisher's LSD test or Tukey's HSD
test. Which one to choose? I think you should choose the test that is better
suited for the job (based on your knowledge and recommendations from the
experts).

Regarding the above mentioned tests. Fisher's LSD test was introduced by [Ronald
Fisher](https://en.wikipedia.org/wiki/Ronald_Fisher) (what a surprise). LSD
stands for **L**east **S**ignificant **D**ifference. Some time later [John
Tukey](https://en.wikipedia.org/wiki/John_Tukey) considered it to be too lenient
(too easily rejects $H_{0}$ and declares significant differences) and offered
his own test (operating on different assumptions) as an alternative. For that
reason it was named HSD which stands for **H**onestly **S**ignificant
**D**ifference. I heard that statisticians recommend to use the latter one
(although in practice I saw people use either of them).

### Solution to Exercise 5 {#sec:statistics_intro_exercise5_solution}

OK, so we assume that Peter is a better player than John and he consistently
wins with John. On average he wins with the ratio 5 to 1 (5:1) with his opponent
(this is our true $H_{A}$). Let's write a function that gives us the result of
the experiment if this $H_{A}$ is true.

```jl
s = """
function getResultOf1TennisGameUnderHA()::Int
	# 0 - John wins, 1 - Peter wins
	return Rand.rand([0, 1, 1, 1, 1, 1], 1)
end

function getResultOf6TennisGamesUnderHA()::Int
	return [getResultOf1TennisGameUnderHA() for _ in 1:6] |> sum
end
"""
sc(s)
```

The code is fairly simple. Let me just explain one part. Under $H_{A}$ Peter
wins 5 out of six games and John 1 out of 6, therefore we choose one number out
of `[0, 1, 1, 1, 1, 1]` (0 - John wins, 1 - Peter wins) with our `Rand.rand([0,
1, 1, 1, 1, 1], 1)`.

> **_Note:_** If the $H_{A}$ would be let's say 1:99 for Peter, then to save you
> some typing I would recommend to do something like, e.g. `return
> (Rand.rand(1:100, 1) < 100) ? 1 : 0`. It draws one random number out of 100
> numbers. If the number is 1-99 then it returns 1 (Peter wins) else it returns
> 0 (John wins). BTW. When a probability of an event is small (e.g. $\le$ 1%)
> then to get its more accurate extimate you could/should increase the number of
> computer simulations (e.g. `numOfSimul` below should be `1_000_000` instead of
> `100_000`).

Alternatively the code from the snippet above could be shortened to

```jl
s = """
# here no getResultOf1TennisGameUnderHA is needed
function getResultOf6TennisGamesUnderHA()::Int
	return Rand.rand([0, 1, 1, 1, 1, 1], 6) |> sum
end
"""
sc(s)
```

Now let's run the experiment, let's say `100_000` times, and see how many times
we will fail to reject $H_{0}$. For that we will need the following helper
functions

```jl
s = """
function play6tennisGamesGetPvalue()::Float64
	# result when HA is true
    result::Int = getResultOf6TennisGamesUnderHA()
	# probability based on which we may decide to reject H0
    oneTailPval::Float64 = Dsts.pdf.(Dsts.Binomial(6, 0.5), result:6) |> sum
    return oneTailPval
end

function didFailToRejectHO(pVal::Float64)::Bool
    return pVal > 0.05
end
"""
sc(s)
```

In `play6tennisGamesGetPvalue` we conduct an experiment and get a p-value
(probability of type 1 error). First we get the result of the experiment under
$H_{A}$, i.e we assume the true probability of Peter winning a game with John to
be `5/6` = `jl round(5/6, digits=4)`. We assign the result of those 6 games to a
variable `result`. Next we calculate the probability of obtaining such a result
by chance under $H_{0}$, i.e. probability of Peter winning is `1/2` = `jl 1/2`
as we did in @sec:statistics_intro_exercise3_solution. We return that
probability.

Previously we said that the accepted cutoff level for alpha is 0.05 (see
@sec:statistics_intro_cutoff_levels). If p-value $\le$ 0.05 we reject $H_{0}$
and choose $H_{A}$. Here for $\beta$ we need to know whether we fail to reject
$H_{0}$ hence `didFailToRejectHO` function with `pVal > 0.05`.

And now, we can go to the promised `100_000` simulations.

```jl
s = """
numOfSimul = 100_000
Rand.seed!(321)
notRejectedH0 = [
	didFailToRejectHO(play6tennisGamesGetPvalue()) for _ in 1:numOfSimul
	]
probOfType2error = sum(notRejectedH0) / length(notRejectedH0)
"""
sco(s)
```

We run our experiment `100_000` times and record whether we failed to reject
$H_{0}$. We put that to `notRejectedH0` using comprehensions (see
@sec:julia_language_comprehensions). We get a vector of `Bool`s (e.g. `[true,
false, true]`). When used with `sum` function Julia treats `true` as `1` and
`false` as `0`. We can use that to get the average of `true` (fraction of times
we failed to reject $H_{0}$). This is the probability of type II error, it is
equal to `jl probOfType2error`. We can use it to calculate the power of a test
(power = 1 - β).

```jl
s = """
function getPower(beta::Float64)::Float64
    @assert (0 <= beta <= 1) "beta must be in range [0-1]"
    return 1 - beta
end
powerOfTest = getPower(probOfType2error)

powerOfTest
"""
sco(s)
```

Finally we get our results. We can compare them with the cutoff values from
@sec:statistics_intro_cutoff_levels, e.g. $\beta \le 0.2$, $power \ge 0.8$. So
it turns out that if in reality Peter is a better tennis player than John (and
on average wins with the ratio 5:1) then we will be able to confirm that rougly
in 3 experiments out of 10 (experiment - the result of 6 games that they play
with each other). This is because the power of a test should be $\ge$ 0.8
(accepted by statisticians), but it is `jl powerOfTest` (estimated in our
computer simulation). Here we can either say that they both (John and Peter)
play equally well (we did not reject $H_{0}$) or make them play a greater number
of games with each other in order to confirm that Peter consistently wins with
John with the average ratio of 5 to 1.

If you want to see a graphical representation of the solution to exercise 5 take
a look at the figure below.

![Graphical representation of estimation process for type II error and the power of a test.](./images/tennisBetaExample.png){#fig:tennisBetaExample}

The top panels display the probability distributions for our experiment (6 games
of tennis) under $H_{0}$ (red bars) and $H_{A}$ (blue bars). Notice, that the
blue bars for 0, 1, and 2 are so small that they are barely (or not at all)
visible on the graph. The black dotted vertical line is a cutoff level for type
I error (or $\alpha$), which is 0.05. The bottom panel contains the
distributions superimposed one on the other. The probability of type II error
(or $\beta$) is the sum of the heights of the blue bar(s) to the left from the
black dotted vertical line (the cutoff level for type I error). The power of a
test is the sum of the heights of the blue bar(s) to the right from the black
dotted vertical line (the cutoff level for type I error).

Hopefully the explanations above were clear enough. Still, the presented
solution got a few flaws, i.e. we hard coded 6 into our functions
(e.g. `getResultOf1TennisGameUnderHA`, `play6tennisGamesGetPvalue`), moreover
running `100_000` simulations is probably less efficient than running purely
mathematical calculations. Let's try to add some plasticity and efficiency to
our code (plus let's check the accuracy of our computer simulation).

```jl
s = """
# to the right from that point on x-axis (>point) we reject H0 and choose HA
# n - number of trials (games)
function getXForBinomRightTailProb(n::Int, probH0::Float64,
                                   rightTailProb::Float64)::Int
    @assert (0 <= rightTailProb <= 1) "rightTailProb must be in range [0-1]"
    @assert (0 <= probH0 <= 1) "probH0 must be in range [0-1]"
    @assert (n > 0) "n must be positive"
    return Dsts.cquantile(Dsts.Binomial(n, probH0), rightTailProb)
end

# n - number of trials (games), x - number of successes (Peter's wins)
# returns probability (under HA) from far left upto (and including) x
function getBetaForBinomialHA(n::Int, x::Int, probHA::Float64)::Float64
	@assert (0 <= probHA <= 1) "probHA must be in range [0-1]"
	@assert (n > 0) "n must be positive"
	@assert (x >= 0) "x musn't be negative"
    return Dsts.cdf(Dsts.Binomial(n, probHA), x)
end
"""
sc(s)
```

> **_Note:_** The above functions should work correctly if probH0 < probHA,
> i.e. the probability distribution under $H_{0}$ is on the left and the
> probability distribution under $H_{A}$ is on the right side, i.e. the case you
> see in @fig:tennisBetaExample.

The function `getXForBinomRightTailProb` returns a value (number of Peter's
wins, number of successes, value on x-axis in @fig:tennisBetaExample) above
which we reject $H_{0}$ in favor of $H_{A}$ (if we feed it with cutoff for
$\alpha$ equal to 0.05). Take a look at @fig:tennisBetaExample, it returns the
value on x-axis to the right of which the sum of heights of the red bars is
lower than the cutoff level for alpha (type I error). It does so by wrapping
around
[Dsts.cquantile](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.cquantile-Tuple{UnivariateDistribution,%20Real})
function (that runs the necessary mathematical calculations) for us.

Once we get this cutoff point (number of successes, here number of Peter's wins)
we can feed it as an input to `getBetaForBinomialHA`. Again, take a look at
@fig:tennisBetaExample, it calculates for us the sum of the heights of the blue
bars from the far left (0 on x-axis) up-to the previously obtained cutoff point
(the height of that bar is also included). Let's see how it works in practice.

```jl
s = """
xCutoff = getXForBinomRightTailProb(6, 0.5, 0.05)
probOfType2error2 = getBetaForBinomialHA(6, xCutoff, 5/6)
powerOfTest2 = getPower(probOfType2error2)

(probOfType2error, probOfType2error2, powerOfTest, powerOfTest2)
"""
sco(s)
```

They appear to be close enough which indicates that our calculations with the
computer simulation were correct.

---

**Bonus. Sample size estimation.**

As a bonus to this exerise let's talk about sample sizes.

Notice that after solving this exercise we said that if Peter is actually a
better player than John and wins on average 5:1 with his opponent then still,
most likely we will not be able to show this with 6 tennis games (`powerOfTest2`
= `jl round(powerOfTest2, digits=5)`). So, if ten such experiments would be
conducted around the world for similar Peters and Johns then roughly only in
three of them Peter would be declared a better player after running statistical
tests. That doesn't sound right.

In order to overcome this at the onset of their experiment a statistician should
also try to determine the proper sample size. First, he starts by asking himself
a question: "how big difference will make a difference". This is an arbitrary
decision (at least a bit). Still, I think we can all agree that if Peter would
win with John on average 99:1 then this would make a practical difference
(probably John would not like to play with him, what's the point if he would be
still loosing). OK, and how about Peter wins with John on average 51:49. This
does not make a practical difference. Here they are pretty well matched and
would play with each other since it would be challenging enough for both of them
and each one could win a decent amount of games to remain satisfied. Most
likely, they would be even unaware of such a small difference.

In real life a physician could say, e.g. "I'm going to test a new drug that
should reduce the level of 'bad cholesterol'
([LDL-C](https://en.wikipedia.org/wiki/Low-density_lipoprotein)). How big
reduction would I like to detect? Hmm, I know, 30 [mg/dL] or more because it
reduces the risk of a heart attack by 50%" or "By at least 25 [mg/dL] because
the drug that is already on the market reduces it by 25 [mg/dL]" (the numbers
were made up by me, I'm not a physician).

Anyway, once a statistician gets the difference that makes a difference he tries
to estimate the sample size by making some reasonable assumptions about rest of
the parameters.

In our tennis example we could write the following function for sample size
estimation

```jl
s = """
# checks sample sizes between start and finish (inclusive, inclusive)
# assumes that probH0 is 0.5
function getSampleSizeBinomial(probHA::Float64,
	cutoffBeta::Float64=0.2,
	cutoffAlpha::Float64=0.05,
	twoTail::Bool=true,
	start::Int=6, finish::Int=40)::Int

	# other probs are asserted in the component functions that use them
	@assert (0 <= cutoffBeta <= 1) "cutoffBeta must be in range [0-1]"
	@assert (start > 0 && finish > 0) "start and finish must be positive"
	@assert (start < finish) "start must be smaller than finish"

	probH0::Float64 = 0.5
	sampleSize::Int = -99
	xCutoffForAlpha::Int = 0
	beta::Float64 = 1.0

    if probH0 >= probHA
        probHA = 1 - probHA
    end
    if twoTail
        cutoffAlpha = cutoffAlpha / 2
    end

    for n in start:finish
        xCutoffForAlpha = getXForBinomRightTailProb(n, probH0, cutoffAlpha)
        beta = getBetaForBinomialHA(n, xCutoffForAlpha, probHA)
        if beta <= cutoffBeta
            sampleSize = n
            break
        end
    end

    return sampleSize
end
"""
sc(s)
```

That is not the most efficient method, but it should do the trick.

First, we initialize a few variables that we will use later (`probH0`,
`sampleSize`, `xCutoffForAlpha`, `beta`). Then we compare `probH0` with
`probHA`. We do this since `getXForBinomRightTailProb` and
`getBetaForBinomialHA` should work correctly only when `probH0` < `probHA` (see
the note under the code snippet with the functions definitions). Therefore we
need to deal with the case when it is otherwise (`if probH0 > probHA`). We do
this by subtracting `probHA` from 1 and making it our new `probHA` (`probHA =
1 - probHA`). Because of that if we ever type, e.g. `probHA` = 1/6 = 0.166, then
the function will transform it to `probHA` = 1 - 1/6 = 5/6 = 0.833 (since in our
case the sample size required to demonstrate that Peter wins on average 1 out of
6 games, is the same as the sample size required to show that John wins on
average 5 out of 6 games).

Once we are done with that we go to another checkup. If we are interested in
two-tailed probability (`cutoffAlpha` = 0.05) then we divide the number
(`cutoffAlpha`) by two. Before 0.05 went to the right side (see the black dotted
line in @fig:tennisBetaExample), now we split it, 0.025 goes to the left side,
0.025 goes to the right side of the probability distribution. This makes sense
since before (see @sec:statistics_intro_one_or_two_tails) we multiplied
one-tailed probability by 2 to get the two-tailed probability, here we do the
opposite. We can do that because the probability distribution under $H_{0}$ (see
upper left panel in @fig:tennisBetaExample) is symmetrical.

Finally, we use the previously defined functions (`getXForBinomRightTailProb`
and `getBetaForBinomialHA`) and conduct a series of experiments for different
sample sizes (between `start` and `finish`). Once the obtained `beta` fulfills
the requirement (`beta <= cutoffBeta`) we set `sampleSize` to that value
(`sampleSize = n`) and stop subsequent search with a `break` statement (so if
`sampleSize` of 6 is OK, we will not look at larger sample sizes). If the `for`
loop terminates without satisfying our requirements then the value of `-99`
(`sampleSize` was initialized with it) is returned. This is an impossible value
for a sample size. Therefore it points out that the search failed. Let's put it
to the test.

In this exercise we said that Peter wins with John on average 5:1 ($H_{A}$, prob
= 5/6 = `jl round(5/6, digits=2)`). So what is the sample size necessary to
confirm that with the acceptable type I error ($alpha \le 0.05$) and type II
error ($\beta \le 0.2$) cutoffs.

```jl
s = """
# for one-tailed test
sampleSizeHA5to1 = getSampleSizeBinomial(5/6, 0.2, 0.05, false)
sampleSizeHA5to1
"""
sco(s)
```

OK, so in order to be able to detect such a big difference (5:1, or even bigger)
between the two tennis players they would have to play `jl sampleSizeHA5to1`
games with each other (for one-tailed test). To put it into perspective and
compare it with @fig:tennisBetaExample look at the graph below.

![Graphical representation of type II error and the power of a test for 13 tennis games between Peter and John.](./images/tennisBetaExampleN13.png){#fig:tennisBetaExampleN13}

If our function worked well then the sum of the heights of the blue bars to the
right of the black dotted line should be $\ge 0.8$ (power of the test) and to
the left should be $\le 0.2$ (type II error or $\beta$).

```jl
s = """
(
# alternative to the line below: 1 - Dsts.cdf(Dsts.Binomial(13, 5/6), 9),
Dsts.pdf.(Dsts.Binomial(13, 5/6), 10:13) |> sum,
Dsts.cdf(Dsts.Binomial(13, 5/6), 9)
)
"""
sco(s)
```

Yep, that's correct. So, under those assumptions in order to confirm that Peter
is a better tennis player he would have to win $\ge 10$ games out of 13.

And how about the two-tailed probability (we expect the number of games to be
greater).

```jl
s = """
# for two-tailed test
getSampleSizeBinomial(5/6, 0.2, 0.05)
"""
sco(s)
```

Here we need `jl getSampleSizeBinomial(5/6, 0.2, 0.05, true)` games to be
sufficiently sure we can prove Peter's supremacy.

OK. Let's give our `getSampleSizeBinomial` one more swing. How about if Peter
wins with John on average 4:2 ($H_{A}$)?

```jl
s = """
# for two-tailed test
sampleSizeHA4to2 = getSampleSizeBinomial(4/6, 0.2, 0.05)
sampleSizeHA4to2
"""
sco(s)
```

Hmm, `-99`, so it will take more than 40 games (`finish::Int = 40`). Now, we can
either stop here (since playing 40 games in a row is too time and energy
consuming so we resign) or increase the value for `finish` like so

```jl
s1 = """
# for two-tailed test
sampleSizeHA4to2 = getSampleSizeBinomial(4/6, 0.2, 0.05, true, 6, 100)
sampleSizeHA4to2
"""
sco(s1)
```

Wow, if Peter is better than John in tennis and on average wins 4:2 then it
would take `jl sampleSizeHA4to2` games to be sufficiently sure to prove it (who
would have thought).

Anyway, if you ever find yourself in need to determine sample size, $\beta$ or
the power of a test (not only for one-sided tests as we did here) then you
should probably consider using
[PowerAnalyses.jl](https://github.com/rikhuijzer/PowerAnalyses.jl) which is on
[MIT](https://en.wikipedia.org/wiki/MIT_License) license.

OK, I think you deserve some rest before moving to the next chapter so why won't
you take it now.
