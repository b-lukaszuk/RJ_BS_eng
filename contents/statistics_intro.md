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
