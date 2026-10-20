import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct DebugPrintable: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            return []
        }
        
        if variable.bindingSpecifier.trimmedDescription == "let" {
            let diagnostic = Diagnostic(
                node: Syntax(node),
                message: DebugPrintableDiagnostic(
                    message: "Cannot perform @DebugPrintable macros because 'let' is immutable"
                )
            )
            
            context.diagnose(diagnostic)
            return []
        }
        
        guard let pattern = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            return []
        }
        
        let identifier = pattern.identifier
        
        return [
            """
            didSet {
                #if DEBUG
                print("[DebugPrintable] Variable '\(raw: identifier.text)' has been changed from value '\\(oldValue)' to value '\\(\(raw: identifier.text))'")
                #endif
            }
            """
        ]
    }
}

public struct Obfuscated: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        
        guard let argument = node.arguments.first?.expression,
              let stringLiteral = argument.as(StringLiteralExprSyntax.self),
              stringLiteral.segments.count == 1,
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            throw ObfuscatedDiagnosticError.invalidArgument
        }
        
        let value = segment.content.text
        let key: UInt8 = 0x5A
        
        let encryptedBytes = value.utf8.map { $0 ^ key }
        let encryptedArray = encryptedBytes.map(String.init).joined(separator: ", ")
        
        return """
        {
            let encrypted: [UInt8] = [\(raw: encryptedArray)]
            let decrypted = encrypted.map { $0 ^ \(raw: String(key)) }
            return String(decoding: decrypted, as: UTF8.self)
        }()
        """
    }
}

enum ObfuscatedDiagnosticError: Error {
    case invalidArgument
}

struct DebugPrintableDiagnostic: DiagnosticMessage {
    let message: String
    
    var diagnosticID: MessageID {
        MessageID(
            domain: "DebugPrintable",
            id: "invalidDeclaration"
        )
    }
    
    var severity: DiagnosticSeverity {
        .error
    }
}

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DebugPrintable.self,
        Obfuscated.self
    ]
}
