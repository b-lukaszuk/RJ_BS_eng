import HypothesisTests as Htests
import RCall as RC

RC.R"
beerVolumes <- c(504, 477, 484, 476, 519, 481, 453, 485, 487, 501)
t.test(beerVolumes, mu=500)
"

beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]
Htests.OneSampleTTest(beerVolumes, 500)

