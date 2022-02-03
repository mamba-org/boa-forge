# boa-forge recipes

These recipes can be used with `boa`, the build tool to create conda-packages (based on `mamba`).
The experimental recipe spec is slightly different from the conda-build recipe spec. We also have added support for "features", which can be used to enable- and disable features.
The recipes in this repository are ported from conda-forge (see [LICENSE](LICENSE)), which is interesting for a source-distribution ([blog post](https://wolfv.github.io/posts/2020/09/20/boa-and-conda-source-distributions.html))

The aim is to get the necessary packages in here to be able to boostrap micromamba, and to experiment with the experimental recipe spec and features.

When you have `boa` from the `features` branch, you can build e.g. the libarchive recipe with features enabled or disabled (using conda-forge as channel for the requirements):

- Build libarchive in a standard configuration
  `boa build libarchive"`

- Build a static library without support for bzip2 & zstd
  `boa build libarchive --features "[~bzip2, ~zstd, static]"`
