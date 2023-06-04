# Statistics - introduction {#sec:statistics_intro}

OK, once we got some Julia basics under our belts its time to get familiar with statistics.

First of all, what is statistics anyway?

Hmm, actually I never tried to learn the definition by heart (after all getting such a question during an exam is slim to none). Still, if I were to give a short (2-3 sentences) definition without looking it up I would say something like that.

Statistics is a set of methods for drawing conclusions about big things (populations) based on small things (samples). A statistician observes only a small part of a bigger picture and makes generalization about what he does not see based on what he saw. Given that he saw only a part of the picture he can never be entirely sure of his conclusions.

OK, feel free to visit Wikipedia ([see statistics](https://en.wikipedia.org/wiki/Statistics)) and see how it did with my definition. The definition given there is probably more accurate and comprehensive, but maybe mine will be easier to grasp for a beginner.

Anyway, my definition says "can never be entirely sure" so there needs to be some form of measurement for the uncertainty.
This is where probability comes into the picture, which we will explore in the next section.

## Probability - definition {#sec:statistics_intro_probability_definition}

For me probability is one of the key concepts in statistics, after all any statistical software will gladly calculate the famous p-value (a form of probability) for you.
Still, let's get back to our probability definition.

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
It is expressed this way for a few particular reasons (some of the reasons will be given later). Moreover, believe it or not, but it is actually compatible with our everyday life understanding.

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
It is organized in a set of chromosomes. Chromosomes come in pairs ([homologous chromosomes](https://en.wikipedia.org/wiki/Homologous_chromosome) one from each parent). Each chromosome contains genes (like beads on a thread). Since we got a pair of chromosomes, then each chromosome from a pair contains a copy of the same gene(s). The copies are exactly the same or are a different version of a gene (we call them [alleles](https://en.wikipedia.org/wiki/Allele)). In order to create gametes (like egg cell and sperm cells) the cells undergo division ([meiosis](https://en.wikipedia.org/wiki/Meiosis)). During this process a cell splits in two and each of the cells got one chromosome from the pair. For instance on chromosome 9 are located genes determining our [ABO blood group system](https://en.wikipedia.org/wiki/ABO_blood_group_system#Genetics). A meiosis process for a person with blood group AB would look something like this (for simplicity I drew only twin chromosomes 9 and only genes for ABO blood group system).

![Meiosis. Splitting of a cell of a person with blood group AB.](./images/meiosis.svg){#fig:meiosis}

OK, let's see how the mathematical properties of probability named at the beginning of this sub-chapter apply here.

**Q1.** What is the probability of a gamete having allele `A` (division example)?

**A1.** That's easy. Based on a picture above I know that a gamete must have either allele `A` or `B` (both are equally likely). In fact, I'm certain of it. From previous sub-chapter (see @sec:statistics_intro_probability_definition) I know that certain event means 100% or $\frac{100}{100}$ or just 1. Now all I have to do is to divide the probability that it will have some allele (which is equal to 1) by the total number of possibilities (which is 2). In the end I got $\frac{1}{2}$ = 0.5.

**Q2.** What is the probability of a gamete having allele `A` or `B` (addition example)?

**A2.** That's easy. A gamete can get either allele `A` or `B`. I'm certain of it (so, the probability is 1).

Alternatively I can look at the picture above (bottom row) and can write this as $\frac{times\ A\ in\ gamete + times\ B\ in\ gamete}{total\ num \ of\ gametes}$ = $\frac{1 + 1}{2}$ = $\frac{2}{2}$ = 1.

Interestingly, this is the same as writing:

$probability\ of\ gamete\ with\ A + probability\ of\ gamete\ with\ B$ = $\frac{1}{2}$ + $\frac{1}{2}$ = 0.5 + 0.5 = 1

All three (slightly different) methods gave me the same results (when that had happened during my math classes I always took it for a good omen).
