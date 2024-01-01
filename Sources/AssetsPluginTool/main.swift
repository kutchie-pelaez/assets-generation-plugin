import Foundation

enum ItemType {
    case folder
    case asset
}

let arguments = ProcessInfo.processInfo.arguments

guard arguments.count > 2 else {
    print("Expected input and output in arguments")
    exit(1)
}

var output = ""
let inputPath = arguments[1]
let outputPath = arguments[2]
let fileManager = FileManager.default
let rootItems = try fileManager.contentsOfDirectory(atPath: inputPath)
let rootEnumName = inputPath
    .split(separator: "/")
    .last?
    .split(separator: ".")
    .first

guard let rootEnumName else {
    print("Failed to access root enum name")
    exit(1)
}

output.append(Primitives.header)
output.append(Primitives.newLines(2))

func writeContentOfDirectory(
    with enumName: some StringProtocol,
    items: [String],
    parentChain: [String] = [],
    indentation: Int = 1
) throws {
    func chain(for item: String, separator: String) -> String {
        (parentChain + [item]).joined(separator: separator)
    }

    func itemPath(for item: String) -> String {
        inputPath + "/" + chain(for: item, separator: "/")
    }

    func itemType(for item: String) -> ItemType {
        item.hasSuffix("imageset") ? .asset : .folder
    }

    let items = items
        .filter { item in
            let itemURL = URL(fileURLWithPath: itemPath(for: item))

            return (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        }
        .sorted { first, second in
            first.compare(
                second,
                options: [.caseInsensitive, .numeric]
            ) == .orderedAscending
        }
    var previousItem: ItemType?

    output.append(Primitives.tabs(indentation - 1))
    output.append(Primitives.enumDeclaration(enumName))
    output.append(Primitives.newLine)

    for item in items {
        switch itemType(for: item) {
        case .asset:
            guard let assetName = item
                .split(separator: "/")
                .last?
                .split(separator: ".")
                .first
            else {
                continue
            }

            output.append(Primitives.tabs(indentation))
            output.append(
                Primitives.image(
                    name: assetName,
                    path: chain(for: String(assetName), separator: ".")
                )
            )
            output.append(Primitives.newLine)

            previousItem = .asset

        case .folder:
            let items = try fileManager.contentsOfDirectory(atPath: itemPath(for: item))

            if previousItem == .asset {
                output.append(Primitives.newLine)
            }

            try writeContentOfDirectory(
                with: item,
                items: items,
                parentChain: parentChain + [item],
                indentation: indentation + 1
            )

            previousItem = .folder
        }
    }

    if
        let lastItem = items.last,
        itemType(for: lastItem) == .folder
    {
        output.removeLast()
    }
    output.append(Primitives.tabs(indentation - 1))
    output.append(Primitives.closingCurlyBrace)
    output.append(Primitives.newLine)
    if enumName != rootEnumName {
        output.append(Primitives.newLine)
    }
}

try writeContentOfDirectory(with: rootEnumName, items: rootItems)
fileManager.createFile(atPath: outputPath, contents: output.data(using: .utf8))
