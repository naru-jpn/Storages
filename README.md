# Storages
Browse local storages of your iOS applications.

## Features

- [x] Easy browsing of files contained local storage.
- [x] Share files to other device over shared network.
- [x] Sort files or directory based on applied options.
- [x] Calculate file size.
- [x] Calculate total file size contained in any directory.
- [x] Preview image (png, jpg, webp, ktx) or text content.
- [x] Delete file with swipe.

## Installation

Support install using Swift Package Manager.

## Usage

### Browsing from Home direcotry.

Simply you only need to create `StorageBrowser` with parameter `source`. 

```swift
// Create new browser (SwiftUI view).
StorageBrowser(source: .home)
```

### Browsing from custom path.

`name` is only used as navigation title. 

```swift
StorageBrowser(source: .custom(path: CUSTOM_PATH, name: CUSTOM_NAME))
```

### Configure storategy of sorting.

`setting` contains rules of sorting and option for previewing contents.

```swift
struct Settings {
  let sortingStrategy: SortingStrategy?
  let previewSettings: FilePreview.Settings
}
// ...
StorageBrowser(source: source, setting: setting)
```

`SortingStrategy` is defined [here](https://github.com/naru-jpn/Storages/blob/main/Sources/Storages/UI/SortingStrategy.swift).

- Display directory first or not.
- Rule to sort files.
   - alphabet
   - fileSize

### Configure settings of previewing contents.

Now you can only set option to preview string contents.

Too long text takes too much time to render when using Text of SwiftUI. So default value of `maxStringPreviewLength` is `1000`.

```swift
struct Settings {
  let stringEncoding: String.Encoding
  let maxStringPreviewLength: Int
}
```

## Licenses

All source code is licensed under the [MIT License](./LICENSE).
