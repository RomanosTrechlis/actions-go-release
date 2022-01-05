# Github actions Go release

Playing around with Github actions

```yml
on:
  push:
    # Sequence of patterns matched against refs/tags
    tags:
      - 'v*' # Push events to matching v*, i.e. v1.0, v20.15.10
  release:
    types: [created]
jobs:
  release-linux-amd64:
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: compile and release
      uses: ngs/go-release.action@v1.0.1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        UPLOAD_URL: ${{ steps.get_release.outputs.upload_url }}
        RELEASE_NAME: ${{ github.ref_name }}
        GOARCH: amd64
        GOOS: linux
        EXTRA_FILES: "LICENSE"
  release-windows-amd64:
    name: release windows/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: compile and release
      uses: ngs/go-release.action@v1.0.1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        UPLOAD_URL: ${{ steps.get_release.outputs.upload_url }}
        RELEASE_NAME: ${{ github.ref_name }}
        GOARCH: amd64
        GOOS: windows
        EXTRA_FILES: "LICENSE"
```