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
\
Let's test this in practice with a few short Q&A (there may be some repetitions, but they are on purpose).
\
\
\
**Q1.** In the case illustrated in @fig:meiosis what is the probability of getting a gamete with allele `C` [for short I'll name it P(`C`)].

**A1.** Since we can only get allele `A` or `B`, but no `C` then $P(C) = \frac{0}{2} = 0$ (it is an impossible event).
\
\
\
**Q2.** In the case illustrated in @fig:meiosis what is the probability of getting a gamete with allele `A` [for short I'll name it P(`A`)].

**A2.** Since we can get only allele `A` or `B` then `A` is 1 of 2 possible events, so $\frac{1}{2} = 0.5$.

It seems that to answer this question we just had to divide the counts of the events satisfying our requirements by the counts of all events.

> **_Note:_** This is exactly the same probability (since it relies on the same reasoning) as for getting a gamete with allele `B` (1 of 2 or $\frac{1}{2} = 0.5$)

\
**Q3.** In the case illustrated in @fig:meiosis, what is the probability of getting a gamete with allele `A` or `B` [for short I'll name it P(`A` or `B`)].

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
**Q4.** In the case illustrated in @fig:meiosis, what is the probability of getting a gamete with allele `B` (for short I'll name it P(`B`)).

**A4.** I know, we already answered it in A2. But let's do something wild and use slightly different reasoning.

Getting gamete `A` or `B` are two incidents of two possible events (2 of 2). If we subtract event `A` (that we are not interested in) from both the events we get:

$P(B) = \frac{2-1}{2} = \frac{1}{2}$

It seems that to answer this question we just had to subtract the count of the events we are not interested in from the counts of the both events.

Let's see if this works with fractions (aka probabilities).

$P(B) = P(A or B) - P(A) = \frac{2}{2} - \frac{1}{2} = \frac{1}{2}$

Yep, a success indeed.
