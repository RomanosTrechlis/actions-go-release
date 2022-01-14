# Github actions Go release

Playing around with Github actions. This builds and releases a new version and uploads the created artifacts to Github.

## Github actions configuration

In order to use RomanosTrechlis/actions-go-release, follow the instructions bellow:

1. Create the **.github/workflows** directory in your root directory
2. Create a **yml** file with an appropriate name
3. Copy the following script into that file
4. Change the goos and goarch parameters in the matrix definition
5. Commit and push a new tag to your origin

```yml
on:
  push:
    # Sequence of patterns matched against refs/tags
    tags:
      - 'v*' # Push events to matching v*, i.e. v1.0, v20.15.10
release:
  types: [created]

name: Build Release
jobs:
  releases-matrix:
    name: Release Go Binary
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # build and publish in parallel: linux/386, windows/386, linux/amd64, windows/amd64
        goos: [linux, windows]
        goarch: [386, amd64]
    steps:
      - uses: actions/checkout@v2
      - uses: RomanosTrechlis/actions-go-release@v0.4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          RELEASE_NAME: ${{ github.ref_name }}
          GOOS: ${{ matrix.goos }}
          GOARCH: ${{ matrix.goarch }}
```

## TODO

+ refactor script
+ add extension on Windows executable
