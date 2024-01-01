# assets-generation-plugin

Image symbols generation plugin similar to [Xcode 15 feature](https://developer.apple.com/documentation/xcode-release-notes/xcode-15-release-notes#Asset-Catalogs).

Currently there's no way to change access level for generated symbols - all of them will be `internal`.
This plugin recreates generation logic with `public` accessor applied to each symbol.


## Installation

### Swift Package Manager

In package's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/kutchie-pelaez/assets-generation-plugin.git", from: "1.0.0")
]
```

In target's plugins:

```swift
plugins: [
    .plugin(name: "AssetsPlugin", package: "assets-generation-plugin")
]
```

## Usage

Make sure "Provides Namespaces" is enabled for each folder:

<img width=1000 src=provides-namespace.png>


```swift
let one = Assets.one
let two = Assets.FolderOne.two
let three = Assets.FolderOne.FolderTwo.three
```

## License

AssetsPlugin is released under the MIT license. See [LICENSE](LICENSE) for details.
