import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacrosMacros)
import MacrosMacros

let testMacros: [String: Macro.Type] = [
    "DebugPrintable": DebugPrintable.self,
    "Obfuscated": Obfuscated.self
]
#endif

final class MacrosTests: XCTestCase {
    
    func testDebugPrintableMacro_Var() throws {
#if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @DebugPrintable
            var value = 0
            value = 10
            """,
            expandedSource: """
            var value = 0 {
                didSet {
                    #if DEBUG
                    print("[DebugPrintable] Variable 'value' has been changed from value '\\(oldValue)' to value '\\(value)'")
                    #endif
                }
            }
            value = 10
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testDebugPrintableMacro_Let() throws {
#if canImport(MacrosMacros)
        assertMacroExpansion(
            """
            @DebugPrintable
            let value = 0
            """,
            expandedSource: """
            let value = 0
            """,
            diagnostics: [DiagnosticSpec(
                message: "Cannot perform @DebugPrintable macros because 'let' is immutable",
                line: 1,
                column: 1
            )],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testObfuscatedMacro() throws {
#if canImport(MacrosMacros)
        assertMacroExpansion(
        """
        let value = #Obfuscated("some value")
        """,
        expandedSource: """
let value = {
    let encrypted: [UInt8] = [41, 53, 55, 63, 122, 44, 59, 54, 47, 63]
    let decrypted = encrypted.map {
        $0 ^ 90
    }
    return String(decoding: decrypted, as: UTF8.self)
}()
""",
        macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
}
