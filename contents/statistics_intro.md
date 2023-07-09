# Statistics - introduction {#sec:statistics_intro}

OK, once we got some Julia basics under our belts, now it is time to get familiar with statistics.

First of all, what is statistics anyway?

Hmm, actually I have never tried to learn the definition by heart (after all getting such a question during an exam is slim to none). Still, if I were to give a short (2-3 sentences) definition without looking it up I would say something like that.

Statistics is a set of methods for drawing conclusions about big things (populations) based on small things (samples). A statistician observes only a small part of a bigger picture and makes generalization about what he does not see based on what he saw. Given that he saw only a part of the picture he can never be entirely sure of his conclusions.

OK, feel free to visit Wikipedia ([see statistics](https://en.wikipedia.org/wiki/Statistics)) and see how I did with my definition. The definition given there is probably more accurate and comprehensive, but maybe mine will be easier to grasp for a beginner.

Anyway, my definition says "can never be entirely sure" so there needs to be some way to measure the (un)certainty.
This is where probability comes into the picture. We will explore this in the next section.

## Probability - definition {#sec:statistics_intro_probability_definition}

For me probability is one of the key concepts in statistics, after all any statistical software will gladly calculate the famous p-value (a form of probability) for you.
Still, let's get back to our probability definition (see the sub-chapter name).

As said, at the conclusion of the previous section, probability is a way to measure certainty.
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
It is organized in a set of chromosomes. Chromosomes come in pairs (twin or [homologous chromosomes](https://en.wikipedia.org/wiki/Homologous_chromosome), we get one from each of our parents). Each chromosome contains genes (like beads on a thread). Since we got a pair of chromosomes, then each chromosome from a pair contains a copy of the same gene(s). The copies are exactly the same or are a different version of a gene (we call them [alleles](https://en.wikipedia.org/wiki/Allele)). In order to create gametes (like egg cell and sperm cells) the cells undergo division ([meiosis](https://en.wikipedia.org/wiki/Meiosis)). During this process a cell splits in two and each of the child cells gets one chromosome from the pair.

For instance chromosome 9 contains the genes that determine our [ABO blood group system](https://en.wikipedia.org/wiki/ABO_blood_group_system#Genetics). A meiosis process for a person with blood group AB would look something like this (for simplicity I drew only twin chromosomes 9 and only genes for ABO blood group system).

![Meiosis. Splitting of a cell of a person with blood group AB.](./images/meiosis.png){#fig:meiosis}

OK, let's see how the mathematical properties of probability named at the beginning of this sub-chapter apply here.

But first, a warm-up (or a reminder if you will). In the previous part (see @sec:statistics_intro_probability_definition) we said that probability may be seen as a percentage, decimal or fraction.
I think that the last one will be particularly useful to broaden our understanding of the concept. To determine probability of an event in the nominator (top) we insert the number of times that event may happen, in the denominator (bottom) we place the number of all possible events, like so:

$\frac{times\ this\ event\ may\ happen}{times\ any\ event\ may\ happen}$
\
\
Let's test this in practice with a few short Q&As (there may be some repetitions, but they are on purpose).
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

And now, the question. In the case illustrated in @fig:abAndOGametes, what is the probability that a child (row C) of those parents (row P) will produce a gamete with allele `A` (row CG)?

**A5.** One way to answer this question would be to calculate the gametes in the last row (CG). We got 4 gametes in total (`A`, `i`, `B`, `i`) only one of which fulfills the criteria (gamete with allele `A`). Therefore, the probability is

$P(A\ in\ CG) = \frac{1}{4} = 0.25$ and that's it.

Another way to think about this problem is the following.
In order for a child to produce a gamete with allele `A` it had to get it first from the parent. So what we are looking for is:

1. what proportion of children got allele `A` from their parents (here, half of them)
2. in the children with allele `A` in their genotype, what proportion of gametes contains allele `A` (here, half of the gametes)

So, to get half of the half all I have to do is to multiply two proportions (aka fractions):

$P(A\ in\ CG) = P(A\ in\ C) * P(A\ in\ gametes\ of\ C\ with\ A)$

$P(A\ in\ CG) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

So it turns out that probabilities can be multiplied (at least sometimes).

### Probability properties - summary {#sec:statistics_intro_probability_summary}

The above was my interpretation of the probability properties explained on biological examples instead of standard fair coins tosses.
Let's sum up of what we learned. I'll do this on a coin toss examples (outcome: heads or tails), you compare it with the examples from Q&As above.

1. Probability of an event is a proportion (or fraction) of times this event happens to the total amount of possible distinctive events.
   Example: $P(heads) = \frac{heads}{heads + tails} = \frac{1}{2} = 0.5$
2. Probability of an impossible event is equal to 0. Probability of certain event is equal to 1.
3. Probabilities of the mutually exclusive complementary events add up to 1.
   Example: $P(heads\ or\ tails) = P(heads) + P(tails) = \frac{1}{2} + \frac{1}{2} = 1$
3. Probability of two mutually exclusive complementary events occurring at the same time is 0 (cannot get heads and tails at one coin toss).
   However, the probability of conjunction is a product of two probabilities.
   Example: probability of getting two tails in two consecutive coin tosses $P(tails\ and\ tails) = P(tails\ in\ 1st\ toss) * P(tails\ in\ 2nd\ toss)$

   $P(tails\ and\ tails) = \frac{1}{2} * \frac{1}{2} = \frac{1}{4} = 0.25$

   Actually, the last is also true for two simultaneous coin tosses (imagine that one coin lands a few milliseconds before the other).

## Probability - theory and practice {#sec:statistics_prob_theor_practice}

OK, in the previous chapter (see @sec:statistics_intro_probability_properties) we said that a person with blood group AB would produce gametes `A` and `B` with probability 50% (p = $\frac{1}{2}$ = 0.5) each. A reference value for [sperm count](https://en.wikipedia.org/wiki/Semen_analysis#Sperm_count) is 16'000'000 per mL or 16'000 per $\mu L$. Given that last value, we would expect 8'000 cells (16'000 * 0.5) to contain allele `A` and 8'000 (16'000 * 0.5) cells to contain allele `B`.

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

Briefly, first we initialize an empty dictionary (`counts::Dict{T,Int} = Dict()`) with keys of some type `T` (elements of that type compose Vector `v`). Next, for every element (`elt`) in Vector `v` we check if it is present in the `counts` (`if haskey(counts, elt)`). If it is we add 1 to the previous count (`counts[elt] = counts[elt] + 1`). If not (`else`) we put the key (`elt`) into the dictionary with count `1`. In the end we return the result (`return counts`). The `if ... else` block (lines with comments `#1`-`#5`) could be replaced with one line (`counts[elt] = get(counts, elt, 0) + 1`), but I thought the more verbose version would be easier to understand.

Let's test it out.

```jl
s = """
gametesCounts = getCounts(gametes)
gametesCounts
"""
sco(s)
```

Hmm, that's odd. We were suppose to get 8'000 gametes with allele `A` and 8'000 with allele `B`. What happened? Well, to quote the classic: "Reality if often disappointing" and another perhaps less known saying: "All models are wrong, but some are useful". Our theoretical reasoning was only approximation of the real world and as such cannot be precise (although with greater sample sizes comes greater precision). You can imagine that a fraction of the gametes were damaged (e.g. due to some unspecified environmental factors) and underwent apoptosis (aka programmed cell death). So that's how it is, deal with it.

OK, let's see what are the experimental probabilities we got from our hmm... experiment.

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

One last point. While writing numerous programs I figured out it is some times better to represent things (internally) as numbers and only in the last step present them in a more pleasant visual form to the viewer. In our case we could have used `0` as allele `A` and `1` as allele `B` like so.

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

Go ahead. Compare the numbers with those that you got previously and explain it to yourself why this second approach works. Once you're done click the right arrow to explore probability distributions in the next section.

## Probability distribution {#sec:statistics_prob_distribution}

Another important concept worth knowing is that of [probability distribution](https://en.wikipedia.org/wiki/Probability_distribution). Let's explore it with some, hopefully interesting, examples.

First, imagine I offer Your a bet. You roll two six-sided dice. If the sum of the dots is 12 then I give you $125, otherwise you give me $5. Hmm, sounds like a good bet, doesn't it? Well, let's find out. By flexing our probabilistic muscles and using a computer simulation this should not be too hard to answer.

```jl
s = """
function getSumOf2DiceRoll()::Int
	return sum(rnd.rand(1:6, 2))
end

rnd.seed!(321)
numOfRolls = 100_000
diceRolls = [getSumOf2DiceRoll() for _ in 1:numOfRolls]
diceCounts = getCounts(diceRolls)
diceProbs = getProbs(diceCounts)
"""
sc(s)
```

Here, we rolled two 6-sided dice 100 thousand ($10^4$) times.
The code introduces no new elements. The functions: `getCounts`, `getProbs`, `rnd.seed!` were already introduced in the previous chapter (see @sec:statistics_prob_theor_practice).
And the `for _ in` construct we met while talking about for loops (see @sec:julia_language_for_loops).

So, let's take a closer look at the result.

```jl
s = """
(diceCounts[12], diceProbs[12])
"""
sco(s)
```

It seems that out of 100'000 rolls with two six-sided dice only `jl diceCounts[12]` gave us two sixes (6 + 6 = 12), so the experimental probability is equal to `jl diceProbs[12]`. But is it worth it? From a point of view of a single person (remember the bet is you vs. me) a person got probability of `diceProbs[12] = ` `jl diceProbs[12]` to win $125 and a probability of `sum([get(diceProbs, i, 0) for i in 2:11]) = ` `jl sum([get(diceProbs, i, 0) for i in 2:11])` to lose $5. Since all the probabilities (for 2:12) add up to 1, the last part could be rewritten as `1 - diceProbs[12] = ` `jl 1 - diceProbs[12]`. Using Julia I can write this in the form of an equation like so:

```jl
s = """
function getOutcomeOfBet(probWin::Float64, moneyWin::Real,
                         probLoose::Float64, moneyLoose::Real)::Float64
	# in mathematics first we do multiplication (*), then subtraction (-)
	return probWin * moneyWin - probLoose * moneyLoose
end

outcomeOf1bet = getOutcomeOfBet(diceProbs[12], 125, 1 - diceProbs[12], 5)

round(outcomeOf1bet, digits=2) # round to cents (1/100th of a dollar)
"""
sco(s)
```

In total you are expected to lose $ `jl abs(round(outcomeOf1bet, digits=2))`.

Now some people may say "Phi! What is $1.39 if I can potentially win $125 in a few tries". It seems to me those are emotions (and perhaps greed) talking, but let's test that too.

If 200 people make that bet (100 bet $5 on 12 and 100 bet $125 on the other result) we would expect the following outcome:

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

OK. So, above we introduced a few similar ways to calculate that. The result of the bet is `jl round(outcomeOf100bets, digits=2)`. In reality roughly 97 people that bet $5 on two sixes (6 + 6 = 12) lost their money and only 3 of them won $125 dollars which gives us $3*\$125 - 97*\$5= -\$110$ (the numbers are not exact because based on probability we got `jl diceProbs[12]*100` people and not 3 and so on).

Interestingly, this is the same as if you placed that same bet with me 100 times. Ninety-seven times you would have lost $5 and only 3 times you would have won $125 dollars. This would leave you over $110 poorer and me over $110 richer.

It seems that instead of betting on 12 (two sixes) many times you would be better off had you started a casino or a lottery. Then you should find let's say 1'000 people daily that will take that bet (or buy $5 ticket) and get \$ `jl abs(round(outcomeOf1bet*1000, digits=2))` (`outcomeOf1bet * 1000` ) richer every day (well, probably less, because you would have to pay some taxes, still this makes a pretty penny).

OK, you saw right through me and you don't want to take that bet. Hmm, but what if I say a nice, big "I'm sorry" and offer you another bet. Again, you roll two six-sided dice. If you get 11 or 12 I give you $90 otherwise you give me $10. This time you know right away what to do:

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

So, to estimate the probability we can either add number of occurrences of 11 and 12 and divide it by the total occurrences of all events OR, as we learned in the previous chapter (see @sec:statistics_intro_probability_properties), we can just add the probabilities of 11 and 12 to happen. Then we proceed with with calculating the expected outcome of the bet and find out that I wanted to trick you again ("I'm sorry. Sorry.").

Now, using this method (that relies on probability distribution) you will be able to look through any bet that I will offer you and choose only those that serve you well. OK, so what is a probability distribution anyway, well it is just the value that probability takes for any possible outcome. We can represent it graphically by using any of [Julia's plotting libraries](https://juliapackages.com/c/graphical-plotting).

Here, I'm going to use [Makie.jl](https://docs.makie.org/stable/) which seems to produce pleasing to the eye plots and is simple enough (that's what I think after I read its [Basic Tutorial](https://docs.makie.org/stable/tutorials/basic-tutorial/)).

```jl
s = """
import CairoMakie as cmk

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}

    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end

xs1, ys1 = getSortedKeysVals(diceCounts)
xs2, ys2 = getSortedKeysVals(diceProbs)

fig = cmk.Figure()
cmk.barplot(fig[1, 1:2], xs1, ys1,
    color="red",
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurrences",
        xticks=2:12)
)
cmk.barplot(fig[2, 1:2], xs2, ys2,
    color="blue",
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Probability of occurrence",
        xticks=2:12)
)
fig
"""
sc(s)
```

First, we extracted the sorted keys and values from our dictionaries (`diceCounts` and `diceProbs`) using `getSortedKeysVals`. The only new element here is `|>` operator. It's role is [piping](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping) the output of one function as input to another function. So `keys(d) |> collect |> sort` is just another way of writing `sort(collect(keys(d)))`. In both cases first we run `keys(d)`, then we use the result of this function as an input to `collect` function, and finally pass its result to `sort` function. Out of the two options, the one with `|>` seems to be clearer to me.

In the next step we draw the distributions as bar plots (`cmk.barplot`). The code seems to be pretty self explanatory after you read [the tutorial](https://docs.makie.org/stable/tutorials/basic-tutorial/) that I just mentioned. The number of counts (number of occurrences) on Y-axis is displayed in a scientific notation, i.e. $1.0 x 10^4$ is 10'000 (one with 4 zeros) and $1.5 = 10^4$ is 15'000.

> **_Note:_** Because of compilation process running Julia's plots for the first time may be slow. If that is the case you may try some tricks recommended by package designers, e.g. [this one from the creators of Gadfly.jl](http://gadflyjl.org/stable/#Compilation).

![Rolling two 6-sided dice (counts and probabilities).](./images/rolling2diceCountsProbs.png){#fig:twoDiceCountsProbs}

OK, but why did I even bother to talk about probability distribution (except for the great enlightenment it might have given to you)? Well, because it is important. It turns out that in statistics one relies on many distributions. For instance:

- We want to know if people in city A are taller than in city B. We take at random 10 people from each of the cities, we measure them and run a famous [Student's T-test](https://en.wikipedia.org/wiki/Student%27s_t-test) to find out. It gives us the probability that helps us answer our question. It does so based on a [t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution).

- We want to know if cigarette smokers are more likely to believe in ghosts. What we do is we find random groups of smokers and non-smokers and ask them about it (Do you believe in ghosts?). We record the results and run a [chi squared test](https://en.wikipedia.org/wiki/Chi-squared_test) that gives us the probability that helps us answer our question. It does so based on a [chi squared distribution](https://en.wikipedia.org/wiki/Chi-squared_distribution).

OK, that should be enough for now. Take some rest, and when you're ready continue with the next chapter.

## Normal distribution {#sec:statistics_normal_distribution}

Let's start where we left. We know that a probability distribution is a (possibly graphical) depiction of the values that probability takes for any possible outcome.
Probabilities come in different forms and shapes. Additionally one probability distribution can transform into another (or at least into a distribution that resembles another distribution).

Let's look at a few examples.

![Experimental binomial and multinomial probability distributions.](./images/binomAndMultinomDistr.png){#fig:unifAndBinomDistr}

Here we got experimental distributions for tossing a standard fair coin and rolling a six-sided dice. The code for @fig:unifAndBinomDistr can be found in [the code snippets for this chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets) and it uses the same functions that we developed in the previous chapter(s).

Those are examples of the binomial (`bi` - two, `nomen` - name, those two names could be: heads/tails, A/B, or most general success/failure) and multinomial (`multi` - many, `nomen` - name, here the names are `1:6`) distributions. Moreover, both of them are examples of discrete (probability is calculated for a few distinctive values) and uniform (values are equally likely to be observed) distribution.

Notice that in the @fig:unifAndBinomDistr (above) rolling one six-sided dice gives us an uniform distribution. However in the previous chapter when tossing two six-sided dice we got the distribution that looks like this.

![Experimental probability distribution for rolling two 6-sided dice.](./images/rolling2diceProbs.png){#fig:rolling2diceProbs}

What we got here is a [bell](https://en.wikipedia.org/wiki/Bell) shaped distribution (c'mon use your imagination). It turns out that quite a few distributions may transform into the distribution that is bell shaped (as an exercise you may want to draw a distribution for the number of heads when tossing 10 fair coins simultaneously). Moreover, many biological phenomena got bell shaped distribution, e.g. men's height or the famous [intelligence quotient](https://en.wikipedia.org/wiki/Intelligence_quotient) (aka IQ). The theoretical name for it is [normal distribution](https://en.wikipedia.org/wiki/Normal_distribution). Placed on a graph it looks like this.

![Examples of normal distribution.](./images/normDistribution.png){#fig:normDistribution}

In @fig:normDistribution upper panel depicts standard normal distributions ($\mu = 0, \sigma = 1$, explanation in a moment), a theoretical distribution that all statisticians and probably some mathematicians love. The bottom panel shows a distribution that is likely closer to the males' height distribution in my country. Long time ago I read that the average height for an adult man in Poland is 172 [cm] (5.64 [feet]) and standard deviation is equal to 7 [cm] (2.75 [inch]) hence this plot.

As you can see normal distribution is often depicted as a line plot. That is because it is a continuous distribution (the values on x axes can take any number from a given range). Take a look at the height. In my old [identity card ](https://en.wikipedia.org/wiki/Polish_identity_card) next to the field "Height in cm" stands "181", but is this really my precise height? What if during a measurement the height was 180.7 or 181.3 and in the ID there could be only height in integers. I would have to round it up, right? So based on the identity card information my real height is probably somewhere between 180.5 and 181.49999... . Moreover, it can be any value in between (like 180.6354555..., although in reality a measuring device does not have such a precision). So, in the bottom panel of @fig:normDistribution I rounded theoretical values for height (`round(height, digits=0)`), drew bars (using `cmk.barplot` that you know), and added a line that goes through the middle of each bar.

As you perhaps noticed, the distribution is characterized by two parameters:

- the average (also called the mean) (in population denoted as: $\mu$, in sample as: $\overline{x}$)
- the standard deviation (in population denoted as: $\sigma$, in sample as: $s$, $sd$ or $std$)

We already know the first one from school and previous chapters (e.g. `getAvg` from @sec:julia_language_for_loops). The last one however requires some explanation.

Let's say that we have two students. Here are their grades.

```jl
s = """
gradesStudA = [3.0, 3.5, 5.0, 4.5, 4.0]
gradesStudB = [6.0, 5.5, 1.5, 1.0, 6.0]
"""
sc(s)
```

Imagine that we want to send one student to represent the school in a national level competition.
Therefore we want to know who is a better student. So, let's check their averages.

```jl
s = """
avgStudA = getAvg(gradesStudA)
avgStudB = getAvg(gradesStudB)
(avgStudA, avgStudB)
"""
sco(s)
```

Hmm, they are identical. OK, in that situation let's see who is more consistent with their scores.

To test the spread of the scores around the mean we will subtract every single score from the mean and take their average (average of the differences).

```jl
s = """
diffsStudA = gradesStudA .- avgStudA
diffsStudB = gradesStudB .- avgStudB
(getAvg(diffsStudA), getAvg(diffsStudB))
"""
sco(s)
```

> **_Note:_** Here we used the dot functions described in @sec:julia_language_dot_functions

The method is of no use since `sum(diffs)` is always equal to 0 (and hence the average is 0). See for yourself

```jl
s = """
(sum(diffsStudA), sum(diffsStudB))
"""
sco(s)
```

Personally in this situation I would take the average of diffs without looking at the sign (`abs` function does that) like so.

```jl
s = """
absDiffsStudA = abs.(diffsStudA)
absDiffsStudB = abs.(diffsStudB)
(getAvg(absDiffsStudA), getAvg(absDiffsStudB))
"""
sco(s)
```

Based on this we would say that student A is more consistent in his grades so he is probably a better student of the two. I would send student A to represent the school during the national level competition. Student B is also good, but choosing him is a gamble. He could shine or embarrass himself (and spot the school's name) during the competition.

For any reason statisticians decided to get rid of the sign in a different way, i.e. by squaring ($x^{2}$) the diffs. Afterwards they calculated the average and took square root ($\sqrt{x}$) of it to get rid of the squaring. So, they did more or less this

```jl
s = """
function getSd(nums::Vector{<:Real})::Real
	avg::Real = getAvg(nums)
	diffs::Vector{<:Real} = nums .- avg
	squaredDiffs = diffs .^ 2
	return sqrt(getAvg(squaredDiffs))
end

(getSd(gradesStudA), getSd(gradesStudB))
"""
sco(s)
```

> **_Note:_** In reality standard deviation for a sample is calculated with a slightly different formula but the one above is easier to understand.

In the end we got similar numbers, reasoning, and conclusions to the one based on `abs` function.

Unfortunately although I like my method better the `sd` and squaring/square rooting is so deeply fixed into statistics that everyone should know it.

And now a big question.

**Why should we care about the mean ($\mu$, $\overline{x}$) or sd ($\sigma$, $s$, $sd$, $std$) anyway?**

The answer. For practical reasons that got something to do with the so called [three sigma rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule).


### The three sigma rule {#sec:statistics_intro_three_sigma_rule}

[The rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule) says that:

- roughly 68% of the results in the population lie within $\pm$ 1 sd from the mean
- roughly 95% of the results in the population lie within $\pm$ 2 sd from the mean
- roughly 99% of the results in the population lie within $\pm$ 3 sd from the mean

Example 1.

Have you ever tested your [blood](https://en.wikipedia.org/wiki/Blood) and received the lab results that said something like

- [RBC](https://en.wikipedia.org/wiki/Complete_blood_count#Reference_ranges): 4.45 [$10^{12}/\mu L$] (4.2 - 6.00)

The RBC stands for **r**ed **b**lood **c**ell count and the parenthesis contain the reference values (if you are within this normal range then it is a good sign). But where did those reference values come from? This [wikipedia's page](https://en.wikipedia.org/wiki/Blood) gives us a clue. It reports a value for [hematocrit](https://en.wikipedia.org/wiki/Hematocrit) (which is in %) to be:

- 45 $\pm$ 7 (38–52%) for males
- 42 $\pm$ 5 (37–47%) for females

Look at this $\pm$ symbol. Have you seen it before? No? Then look at the three sigma rule above.

The reference values were most likely composed in the following way. A large number (let's say 30'000) females gave their blood for testing. Hematocrit value was calculated for all of them. The distribution was established in a similar way that we did before. The average hematocrit was 42 units, the standard deviation was 5 units. The majority of the results (roughly 68%) lie within $\pm$ 1 sd from the mean. If so, then we got 42 - 5 = 38, and 42 + 5 = 47. And that is how those two values were considered to be the reference values for the population. Most likely the same is true for any other reference values you see in your lab result when you [test your blood](https://en.wikipedia.org/wiki/Complete_blood_count) or when you perform other medical examination.

Example 2.

Let's say a person named Peter lives in Poland. Peter approaches the famous IQ test in one of our universities. He read on the internet that there are different [intelligence scales](https://en.wikipedia.org/wiki/Intelligence_quotient#Current_tests) used throughout the world. His score is 125. The standard deviation is 24. Is his score high, does it indicate he is gifted (a genius level intellect)? Well, in order to be a genius one has to be in the top 2% of the population with respect to their IQ value. What is the location of Peter's IQ value in the population.

The score of 125 is just a bit greater than 1 standard deviation above the mean (which in an IQ test is always 100). From @sec:statistics_prob_distribution we know that when we add all the probabilities we get 1 (so the area under the curve in @fig:normDistribution is equal to 1). Half of the area lies on the left, half of it on the right (1 / 2 = 0.5). So, a person with IQ = 100 is as intelligent or more intelligent than half the people ($\frac{1}{2}$ = 0.5 = 50%) in the population. Roughly 68% of the results lies within 1 sd from the mean (half of it below, half of it above). So, from IQ = 100 to IQ = 124 we got (68% / 2 = 34%). By adding 50% (IQ $\le$ 100) to 34% (100 $\le$ IQ $\le$ 124) we get 50% + 34% = 84%.
Therefore in our case Peter (with his IQ = 125) is more intelligent than 84% of people in the population (so top 16% of the population). His intelligence is above the average, but it is not enough to label him a genius.

### Distributions package {#sec:statistics_intro_distributions_package}

This is all nice and good to know, but in practice is slow and not precise enough. What if in the previous example the IQ was let's say 139. What is the percentage of people less intelligent than Peter. That kind of questions can be quickly answered with [Distributions](https://juliastats.org/Distributions.jl/stable/) package. For instance in the case of Peter described above we got

```jl
s = """
import Distributions as dsts

dsts.cdf(dsts.Normal(100, 24), 139)
"""
sco(s)
```

Here we first create a normal distribution with $\mu$ = 100 and $\sigma$ = 24 (`dsts.Normal(100, 24)`). Then we sum all the probabilities $\le$ 139 with `dsts.cdf` and see that in this case only ~5% of people are as intelligent or more intelligent than Peter. BTW, `cdf` stands for cumulative distribution function. For more information on `dsts.cdf` see [these docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.cdf-Tuple{UnivariateDistribution,%20Real}) or for `dsts.Normal` [those docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Normal).

To further consolidate our knowledge. Let's go with another example. Remember that I'm 181 cm tall. Hmm, I wonder what percentage of men in Poland is taller than me if $\mu = 172$ [cm] and $\sigma = 7$ [cm].

```jl
s = """
1 - dsts.cdf(dsts.Normal(172, 7), 181)
"""
sco(s)
```

The `dsts.cdf` gives me left side of the curve (height $\le$ 181). So in order to get those that are higher than me I subtract it from 1. It seems that under those assumptions roughly 10% of men in Poland are taller than me.

OK, and how many men in Poland are exactly as tall as I am? In general that is the job for
`dsts.pdf` (`pdf` stands for probablity density function, see [the docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.pdf-Tuple{UnivariateDistribution,%20Real})). It works pretty well for discrete distributions (we talked about them at the beginning of this sub-chapter). For instance theoretical probability of getting 12 while rolling two six-sided dice is

```jl
s = """
dsts.pdf(dsts.Binomial(2, 1/6), 2)
"""
sco(s)
```

Compare it with the empirical probability from @sec:statistics_prob_distribution which was equal to `jl diceProbs[12]`. Here we treated it as a binomial distribution (success: two sixes (6 + 6 = 12), failure: other result) hence `dsts.Binomial` with `2` (number of dice to roll) and `1/6` (probability of getting 6 in a single roll). Then we used `dsts.pdf` to get the probability of getting exactly two sixes. More info on `dsts.Binomial` can be found [here](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Binomial) and on `dsts.pdf` can be found [there](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.pdf-Tuple{UnivariateDistribution,%20Real}).

However there is a problem with using `dsts.pdf` for continues distributions because it can take any of the infinite values within the range. Remember, in theory there is an infinite number of values between 180 and 181 (like 180.1111, 180.12222, etc.). So usually for practical reasons it is recommended not to calculate a probability density function (hence `pdf`) for a continuous distribution (1 / infinity $\approx$ 0). Still, remember that the height of 181 [cm] means that the value lies somewhere between 180.5 and 181.49999... . Moreover, we can reliably calculate the probabilities (with `dsts.cdf`) for $\le$ 180.5 and $\le$ 181.49999... so a good approximation would be.

```jl
s = """
heightDist = dsts.Normal(172, 7)
# 2 digits after dot because of the assumed precision of a measuring device
dsts.cdf(heightDist, 181.49) - dsts.cdf(heightDist, 180.50)
"""
sco(s)
```

OK. So it seems that roughly 2.5% of adult men in Poland got 181 [cm] in the field "Height" in their identity cards. If there are let's say 10 million adult men in Poland then rougly `jl round(10_000_000*0.025, digits=0)` (so `jl trunc(Int, 10_000_000*0.025/1000)` k) people are approximately my height.

If you are still confused about this method take a look at Figure below.

![Using cdf to calculate proportion of men that are between 170 and 180 [cm] tall.](./images/normDistCdfUsage.png){#fig:normDistCdfUsage}

Here for better separation I placed the height of men between 170 and 180 [cm]. The method that I used subtracts the area in red from the area in blue. That is exactly what I did (but for 181.49 and 180.50 [cm]) when I typed `dsts.cdf(heightDist, 181.49) - dsts.cdf(heightDist, 180.50)` above.

OK, time for the last theoretical sub-chapter in this section. Whenever you're ready click on the right arrow.
