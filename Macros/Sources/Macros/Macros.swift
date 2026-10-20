// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(accessor, names: named(didSet))
public macro DebugPrintable() = #externalMacro(
    module: "MacrosMacros",
    type: "DebugPrintable"
)

@freestanding(expression)
public macro Obfuscated(_ value: String) -> String = #externalMacro(
    module: "MacrosMacros",
    type: "Obfuscated"
)
