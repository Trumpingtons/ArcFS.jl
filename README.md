# ArcFS.jl

arc-fs: adaptive resampling with pruned trees.

Breiman's arc-fs, the AdaBoost of his random forests paper: adaptive resampling with CART trees pruned by cost complexity on a second draw, voting with weights, tested on his published test errors for 20 data sets.

Article: Breiman, L. (1998). Arcing classifiers. The Annals of Statistics 26(3), 801-849. [doi:10.1214/aos/1024691079](https://doi.org/10.1214/aos/1024691079)

## Usage

```julia
using ArcFS, CSV, Tables, Random
d = Tables.columntable(CSV.File(download("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/breastwisconsin.csv")))
X = Float64.(hcat(d.clump_thickness, d.cell_size, d.cell_shape, d.marginal_adhesion, d.epithelial_size, coalesce.(d.bare_nuclei, 1), d.bland_chromatin, d.normal_nucleoli, d.mitoses))
y = ifelse.(d.class .== "M", 2, 1)
trees, weights = arcfs(X[1:600, :], y[1:600], 50, Xoshiro(1))
mean(vote(trees, X[601:end, :], 2; weights) .!= y[601:end])  # the test error
```

## Vignette

[arc-fs: adaptive resampling with pruned trees](vignette/ArcFS.pdf)

## License

MIT (see [LICENSE](LICENSE)).

## Tests

The tests compute the published tables below from their data and check every printed value, rounded to the digits printed:

- Breiman (2001), Table 2, p. 11: one run on the given test set (`test/data/targets/large.csv`)
- Breiman (2001), Table 2, p. 11: 50 runs of 300 training and 3,000 test cases (`test/data/targets/simulated.csv`)
- Breiman (2001), Table 2, p. 11, and p. 15 (soybean): 100 runs of a 10% test set (`test/data/targets/small.csv`)

The data, downloaded from its links when the tests run or kept in `test/data/inputs`:

- `breastwisconsin`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/breastwisconsin.csv>, PollisDatasets
- `ecoli`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/ecoli.csv>, PollisDatasets
- `germancredit`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/germancredit.csv>, PollisDatasets
- `glass`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/glass.csv>, PollisDatasets
- `image`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/image.csv>, PollisDatasets
- `ionosphere`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/ionosphere.csv>, PollisDatasets
- `letters`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/letters.csv>, PollisDatasets
- `liver`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/liver.csv>, PollisDatasets
- `pima`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/pima.csv>, PollisDatasets
- `satimage`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/satimage.csv>, PollisDatasets
- `sonar`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/sonar.csv>, PollisDatasets
- `soybean`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/soybean.csv>, PollisDatasets
- `vehicle`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/vehicle.csv>, PollisDatasets
- `votes`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/votes.csv>, PollisDatasets
- `vowel`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/vowel.csv>, PollisDatasets
- `ziptest`: <https://hastie.su.domains/ElemStatLearn/datasets/zip.test.gz>, The zip-code digits, test set, from the same site
- `ziptrain`: <https://hastie.su.domains/ElemStatLearn/datasets/zip.train.gz>, The zip-code digits, training set, from the site of Hastie, Tibshirani and Friedman's The Elements of Statistical Learning

Run them with `using Pkg; Pkg.test("ArcFS")`.

Made with [Pollis](https://pollis.org).
