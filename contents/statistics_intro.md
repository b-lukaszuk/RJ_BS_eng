# Statistics - introduction {#sec:statistics_intro}

OK, once we got some Julia basics under our belts its time to get familiar with statistics.

First of all, what is statistics anyway?

Hmm, actually I never tried to learn the definition by heart (after all getting such a question during an exam is slim to none). Still, if I were to give a short (2-3 sentences) definition without looking it up I would say something like that.

Statistics is a set of methods for drawing conclusions about big things (populations) based on small things (samples). A statistician observes only a small part of a bigger picture and makes generalization about what he does not see based on what he saw. Given that he saw only a part of the picture he can never be entirely sure of his conclusions.

OK, feel free to visit Wikipedia ([see statistics](https://en.wikipedia.org/wiki/Statistics)) and see how I did with my definition. The definition given there is probably more accurate and comprehensive, but maybe mine will be easier to grasp for a beginner.

Anyway, my definition says "can never be entirely sure" so there needs to be some way to measure the (un)certainty.
This is where probability comes into the picture. Which we will explore in the next section.

## Probability - definition {#sec:statistics_intro_probability_definition}

For me probability is one of the key concepts in statistics, after all any statistical software will gladly calculate the famous p-value (a form of probability) for you.
Still, let's get back to our probability definition (see the sub-chapter name).

As said at the conclusion of the previous section probability is a way to measure certainty.
It's like with the grades in school. In Poland a pupil can score 1 to 6 (lowest to highest grade) and this tells us how well he mastered the subject.
If I score 1 then I didn't master it at all, but when I get 6 this means that I got it all.
We know from everyday life that probability takes values from 0 to 100%, e.g.

> - Are you sure of it?
> - Absolutely, one hundred percent.

or

> - Do you think he can make it?
> - I would say it's fifty-fifty.

or even

> - What are the chances?
> - Pretty much, zero.

When something is bound to happen we assign it the probability of 100%.

When it can go either way we say fifty-fifty (50% it will happen, 50% it will not happen).

When an event is impossible we say zero (probability of it happening is 0%).

And this is the way statisticians use it. OK, maybe not quite. A typical textbook from statistics will say that the probability takes values from 0 to 1.
It is expressed this way for a few particular reasons (some of the reasons may be given later). Moreover, believe it or not, but it is actually compatible with our everyday life understanding.

From primary school (see also Wikipedia's definition of [percentage](https://en.wikipedia.org/wiki/Percentage)) I remember that 1%  is actually 1/100th of something which I can write down using proper fraction as $\frac{1}{100}$ or a decimal as 0.01.

Therefore any probability value from 0% to 100% can be written in these three forms. For instance:

- 0% = $\frac{0}{100}$ = 0.00 = 0
- 1% = $\frac{1}{100}$ = 0.01
- 5% = $\frac{5}{100}$ = 0.05
- 10% = $\frac{10}{100}$ = 0.10 = 0.1
- 20% = $\frac{20}{100}$ = 0.20 = 0.2
- 50% = $\frac{50}{100}$ = 0.50 = 0.5
- 100% = $\frac{100}{100}$ = 1.00 = 1

However, typing it as decimals (like a statistician would do it) is easier with a keyboard and a [software calculator](https://en.wikipedia.org/wiki/Software_calculator).
Additionally, now I will be able to perform some simple, but useful calculations, with those numbers.

## Probability - properties {#sec:statistics_intro_probability_properties}

One of the cool and practical stuff that I learned about probability is that it can be:

- added
- subtracted
- divided
- multiplied

How about I illustrate that with a simple example.

From biology classes I remember that the genetic material ([DNA](https://en.wikipedia.org/wiki/DNA)) of a cell is in its nucleus.
It is organized in a set of chromosomes. Chromosomes come in pairs (twin or [homologous chromosomes](https://en.wikipedia.org/wiki/Homologous_chromosome), we get one from each of our parents). Each chromosome contains genes (like beads on a thread). Since we got a pair of chromosomes, then each chromosome from a pair contains a copy of the same gene(s). The copies are exactly the same or are a different version of a gene (we call them [alleles](https://en.wikipedia.org/wiki/Allele)). In order to create gametes (like egg cell and sperm cells) the cells undergo division ([meiosis](https://en.wikipedia.org/wiki/Meiosis)). During this process a cell splits in two and each of the child cells got one chromosome from the pair.

For instance chromosome 9 contains the genes that determine our [ABO blood group system](https://en.wikipedia.org/wiki/ABO_blood_group_system#Genetics). A meiosis process for a person with blood group AB would look something like this (for simplicity I drew only twin chromosomes 9 and only genes for ABO blood group system).

![Meiosis. Splitting of a cell of a person with blood group AB.](./images/meiosis.png){#fig:meiosis}

OK, let's see how the mathematical properties of probability named at the beginning of this sub-chapter apply here.

But first, a warm-up (or a reminder if you will). In the previous part (see @sec:statistics_intro_probability_definition) we said that probability may be seen as a percentage, decimal or fraction.
I think that the last one will be particularly useful to broaden our understanding of the concept. To determine probability of an event in the nominator (top) we insert the number of times that event may happen, in the denominator (bottom) we place the number of all possible events, like so:

$\frac{times\ this\ event\ may\ happen}{times\ any\ event\ may\ happen}$
\
\
Let's test this in practice with a few short Q&A (there may be some repetitions, but they are on purpose).
\
\
\
**Q1.** In the case illustrated in @fig:meiosis what is the probability of getting a gamete with allele `C` [for short I'll name it P(`C`)]?

**A1.** Since we can only get allele `A` or `B`, but no `C` then $P(C) = \frac{0}{2} = 0$ (it is an impossible event).
\
\
\
**Q2.** In the case illustrated in @fig:meiosis what is the probability of getting a gamete with allele `A` [for short I'll name it P(`A`)]?

**A2.** Since we can get only allele `A` or `B` then `A` is 1 of 2 possible events, so $\frac{1}{2} = 0.5$.

It seems that to answer this question we just had to divide the counts of the events satisfying our requirements by the counts of all events.

> **_Note:_** This is exactly the same probability (since it relies on the same reasoning) as for getting a gamete with allele `B` (1 of 2 or $\frac{1}{2} = 0.5$)

\
**Q3.** In the case illustrated in @fig:meiosis, what is the probability of getting a gamete with allele `A` or `B` [for short I'll name it P(`A` or `B`)]?

**A3.** Since we can only get allele `A` or `B` then `A` or `B` are 2 events (1 event when `A` happens + 1 event when `B` happens) of 2 possible events, so

$P(A\ or\ B) = \frac{1+1}{2} = \frac{2}{2} = 1$.

It seems that to answer this question we just had to add the counts of the both events.

Let's look at it from a slightly different perspective.

Do you remember that in A2 we stated that probability of getting gamete `A` is $\frac{1}{2}$ and probability of getting gamete `B` is $\frac{1}{2}$? And do you remember that in primary school we learned that fractions can be added one to another? Let's see will that do us any good here.

$P(A\ or\ B) = P(A) + P(B) = \frac{1}{2} + \frac{1}{2} = \frac{2}{2} = 1$

Interesting, the answer (and calculations) are (virtually) the same despite slightly different reasoning. So it seems that in this case probabilities can be added.
\
\
\
**Q4.** In the case illustrated in @fig:meiosis, what is the probability of getting a gamete with allele `B` (for short I'll name it P(`B`))?

**A4.** I know, we already answered it in A2. But let's do something wild and use slightly different reasoning.

Getting gamete `A` or `B` are two incidents of two possible events (2 of 2). If we subtract event `A` (that we are not interested in) from both the events we get:

$P(B) = \frac{2-1}{2} = \frac{1}{2}$

It seems that to answer this question we just had to subtract the count of the events we are not interested in from the counts of the both events.

Let's see if this works with fractions (aka probabilities).

$P(B) = P(A\ or\ B) - P(A) = \frac{2}{2} - \frac{1}{2} = \frac{1}{2}$

Yep, a success indeed.
\
\
\
**Q5.** Look at @fig:abAndOGametes.

![Blood groups, gametes. P - parents, PG - parents' gametes, C - children, CG - children's' gametes](./images/abAndOGametes.png){#fig:abAndOGametes}

Here we see that a person with blood group AB got children with a person with blood group O (ii - recessive homo-zygote). The two possible blood groups in children are A (Ai - hetero-zygote) and B (Bi - hetero-zygote).

And now, the question. In the case illustrated in @fig:abAndOGametes, what is the probability that a child of those parents will produce a gamete with allele `A`?

**A5.** One way to answer this question would be to calculate the gametes (CG) in the last row. We got 4 gametes in total (`A`, `i`, `B`, `i`) only one of which fulfills the criteria (gamete with allele `A`). Therefore, the probability is

$P(A\ in\ CG) = \frac{1}{4} = 0.25$ and that's it.

Another way to think about this problem is the following.
In order for a child to produce a gamete with allele `A` it had to get it first from the parent. So what we are looking for is:

1. what proportion of children got allele `A` from their parents (here, half of them)
2. in the children with allele `A` in their genotype, what proportion of gametes contains allele `A` (here, half of the gametes)

So, to get half of the half all I have to do is to multiply two proportions (aka fractions):

$P(A\ in\ CG) = P(A\ in\ C) * P(A\ in\ gametes\ of\ C\ with\ A)$

$P(A\ in\ CG) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

So it turns out that probabilities can be multiplied.

### Probability properties - summary {#sec:statistics_intro_probability_summary}

The above was my interpretation of the probability properties explained on biological examples instead of standard fair coins tosses.
Let's sum up of what we learned. I'll do this on a coin toss examples, you compare it with the examples from Q&A above.

1. Probability of an event is a proportion (or fraction) of times this event happens to the total amount of possible distinctive events.
   Example: $P(heads) = \frac{heads}{heads + tails} = \frac{1}{2} = 0.5$
2. Probability of an impossible event is equal to 0. Probability of certain event is equal to 1.
3. Probabilities of the mutually exclusive complementary events add up to 1.
   Example: $P(heads\ or\ tails) = P(heads) + P(tails) = \frac{1}{2} + \frac{1}{2} = 1$
3. Probability of two mutually exclusive complementary events occurring at the same time is 0 (cannot get heads and tails at one coin toss).
   However, the probability of conjunction is a product of two probabilities.
   Example: probability of getting two tails in two consecutive coin tosses $P(tails\ and\ tails) = P(tails\ in\ 1st\ toss) * P(tails\ in\ 2nd\ toss)$

   $P(tails\ and\ tails) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

   Actually, the last is also true for two simultaneous coin tosses (imagine that one coin lands milliseconds before the other).

## Probability - theory and practice {#sec:statistics_prob_theor_practice}

OK, in the previous chapter (see @sec:statistics_intro_probability_properties) we said that a person with blood group AB would produce gametes `A` and `B` with probability 50% (p = $\frac{1}{2}$ = 0.5) each. A reference value for [sperm count](https://en.wikipedia.org/wiki/Semen_analysis#Sperm_count) is 16'000 per $\mu L$. If so, we would expect 8'000 cells (16'000 * 0.5) to contain allele `A` and 8'000 (16'000 * 0.5) cells to contain allele `B`.

Let's put that to the test.

Wait! Hold your horses! We're not going to take biological samples. Instead we will do a computer simulation.

```jl
s = """
import Random as rnd
rnd.seed!(321) # optional, needed for reproducibility
gametes = rnd.rand(["A", "B"], 16_000)
first(gametes, 5)
"""
sco(s)
```

First we import a package to generate random numbers (`import Random as rnd`). Then we set seed to some arbitrary number (`rnd.seed!(321)`) in order to reproduce the results [see the docs](https://docs.julialang.org/en/v1/stdlib/Random/#Random.seed!). Thanks to the above you should get the exact same result as I did (assuming you're using the same version of Julia). Then we draw 16'000 gametes out of two available (`gametes = rnd.rand(["A", "B"], 16_000)`) with function `rand` (drawing with replacement) from `Random` library (imported as `rnd`). Finally, since looking through all 16'000 gametes is tedious we display only first 5 (`first(gametes, 5)`) to have a sneak peak of the result.

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

Try to figure out what happened here on your own.
If you need a refresher on dictionaries in Julia see @sec:julia_language_dictionaries or [the docs](https://docs.julialang.org/en/v1/base/collections/#Base.Dict).

Briefly, first we initialize an empty dictionary (`counts::Dict{T,Int} = Dict()`) with keys of some type `T` (elements of that type compose Vector `v`). Next, for every element (`elt`) in Vector `v` we check if it is present in the `counts` (`if haskey(counts, elt)`). If it is we add 1 to the previous count (`counts[elt] = counts[elt] + 1`). If not (`else`) we put the key (`elt`) into the dictionary with count `1`. In the end we return the result (`return counts`). The `if ... else` block (lines with comments `#1`-`#5`) could be replaced with one line (`counts[elt] = get(counts, elt, 0) + 1`) but I thought the more verbose version would be easier to understand.

Let's test it out.

```jl
s = """
gametesCounts = getCounts(gametes)
gametesCounts
"""
sco(s)
```

Hmm, that's odd. We were suppose to get 8'000 gametes with allele `A` and 8'000 with allele `B`. What happened? Well, to quote the classic: "Reality if often disappointing" and another perhaps less known saying: "All models are wrong, but some are useful". Our theoretical reasoning was only approximation of the real world and as such cannot be precise (although with greater sample sizes comes greater precision). You can imagine that a fraction of the gametes were damaged (e.g. due to some unspecified environmental factors) and underwent apoptosis (aka programmed cell death). So that's how it is, deal with it.

OK, let's see what are the experimental probabilities we got from our experiment.

```jl
s = """
function getProbs(counts::Dict{T, Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v/total for (k, v) in counts)
end
"""
sc(s)
```

First we calculate total counts no matter the gamete category (`sum(values(counts))`).
Then we use dictionary comprehensions, which are similar to comprehensions we met before (see @sec:julia_language_comprehensions). Briefly, for each key and value in `counts` (`for (k,v) in counts`) we create the same key in new dictionary with new value being the proportion of `v` in `total` (`k => v/total`).

And now the experimental probabilities.

```jl
s = """
gametesProbs = getProbs(gametesCounts)
gametesProbs
"""
sco(s)
```

One last point. While writing numerous programs I figured out it is often more convenient to represent things (internally) as numbers and only in the last step present them in a more pleasant visual form to the viewer. In our case we could have used `0` as allele `A` and `1` as allele `B` like so.

```jl
s = """
rnd.seed!(321)
gametes = rnd.rand([0, 1], 16_000)
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

Go ahead. Compare the numbers with those that you got previously and explain it to yourself why this second approach works. Once you're done click right arrow to explore probability distributions in the next section.

## Probability distribution {#sec:statistics_prob_distribution}

Another important concept worth knowing is that of [probability distribution](https://en.wikipedia.org/wiki/Probability_distribution). Let's explore it with some, hopefully interesting example.

Imagine I offer Your a bet. You roll two six-sided dice. If the sum of the dots is 11 or 12 then I give You $90, otherwise You give me $10. Hmm, 9 to 1 sounds like a good bet, doesn't it? Well, let's find out by running a computer simulation.

```jl
s = """
function getSum2DiceRoll()::Int
	return sum(rnd.rand(1:6, 2))
end

rnd.seed!(321)
diceRolls = [getSum2DiceRoll() for _ in 1:100_000]
diceCounts = getCounts(diceRolls)

diceDotsSums = keys(diceCounts) |> collect |> sort
diceSumsCounts = [diceCounts[ds] for ds in diceDotsSums]
diceSumsProbs = [diceCounts[ds] / sum(diceSumsCounts) for ds in diceDotsSums]
"""
sc(s)
```

So, what we did was to roll two 6-sided dice 100 thousand ($10^4$) times.

The code is rather self explanatory, but just in case a small reminder:

- `1:6` is a unit range discussed in @sec:julia_vectors)
- `[getSum2DiceRoll() for _ in 1:100_000]` is a comprehension from @sec:julia_language_comprehensions
- `;` at the end instructs Julia not to display the (long) output in the console

The only new element here is `|>` operator. It's role is [piping](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping) output of one function as input to another function. So `keys(diceRollsCounts) |> collect |> sort` is just another way of writing `sort(collect(keys(diceRollsCounts)))`. In both cases first we run `keys(diceRollsCounts)`, then we use the result of this function as an input to `collect` function, and finally pass its result to `sort` function. Out of the two options, the one with `|>` seems to be clearer to me.

OK, let's see how it looks in the graph. For this purpose I'm going to use [Makie.jl](https://docs.makie.org/stable/) which seems to be pleasing to the eye and simple enough (that's what I think after I read its [Basic Tutorial](https://docs.makie.org/stable/tutorials/basic-tutorial/)).

```jl
s = """
import CairoMakie as cmk

cmk.barplot(diceDotsSums, diceSumsCounts,
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurrences",
        xticks=2:12))
"""
sc(s)
```

And here is the result of the plotting function (`cmk.barplot`). Look at the code above and at the graph below to figure out what part of the code is responsible for what part of the figure.

![Rolling two 6-sided dice (counts).](./images/rolling2diceCounts.png){#fig:twoDiceCounts}

The picture above presents all the possible outcomes of rolling two 6-sided dice (sum of dots on x-axis) together with the number of times that event occurred (counts on y-axis). The above is a distribution of how often an event occurs presented for all the possible events [min: 2 (1 and 1 in a roll), max: 12 (6 and 6 in a roll)].
