/*
 * Copyright 2023, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct IDLToStructuredSwiftTranslator: Translator {
  func translate(
    codeGenerationRequest: CodeGenerationRequest,
    client: Bool,
    server: Bool
  ) throws -> StructuredSwiftRepresentation {
    try self.validateInput(codeGenerationRequest)
    let typealiasTranslator = TypealiasTranslator(client: client, server: server)
    let topComment = Comment.doc(codeGenerationRequest.leadingTrivia)
    let imports = try codeGenerationRequest.dependencies.reduce(
      into: [ImportDescription(moduleName: "GRPCCore")]
    ) { partialResult, newDependency in
      try partialResult.append(translateImport(dependency: newDependency))
    }

    var codeBlocks: [CodeBlock] = []
    codeBlocks.append(
      contentsOf: try typealiasTranslator.translate(from: codeGenerationRequest)
    )

    if server {
      let serverCodeTranslator = ServerCodeTranslator()
      codeBlocks.append(
        contentsOf: try serverCodeTranslator.translate(from: codeGenerationRequest)
      )
    }

    if client {
      let clientCodeTranslator = ClientCodeTranslator()
      codeBlocks.append(
        contentsOf: try clientCodeTranslator.translate(from: codeGenerationRequest)
      )
    }

    let fileDescription = FileDescription(
      topComment: topComment,
      imports: imports,
      codeBlocks: codeBlocks
    )
    let fileName = String(codeGenerationRequest.fileName.split(separator: ".")[0])
    let file = NamedFileDescription(name: fileName, contents: fileDescription)
    return StructuredSwiftRepresentation(file: file)
  }
}

extension IDLToStructuredSwiftTranslator {
  private func translateImport(
    dependency: CodeGenerationRequest.Dependency
  ) throws -> ImportDescription {
    var importDescription = ImportDescription(moduleName: dependency.module)
    if let item = dependency.item {
      if let matchedKind = ImportDescription.Kind(rawValue: item.kind.value.rawValue) {
        importDescription.item = ImportDescription.Item(kind: matchedKind, name: item.name)
      } else {
        throw CodeGenError(
          code: .invalidKind,
          message: "Invalid kind name for import: \(item.kind.value.rawValue)"
        )
      }
    }
    if let spi = dependency.spi {
      importDescription.spi = spi
    }

    switch dependency.preconcurrency.value {
    case .required:
      importDescription.preconcurrency = .always
    case .notRequired:
      importDescription.preconcurrency = .never
    case .requiredOnOS(let OSs):
      importDescription.preconcurrency = .onOS(OSs)
    }
    return importDescription
  }

  private func validateInput(_ codeGenerationRequest: CodeGenerationRequest) throws {
    try self.checkServiceDescriptorsAreUnique(codeGenerationRequest.services)

    let servicesByUpperCaseNamespace = Dictionary(
      grouping: codeGenerationRequest.services,
      by: { $0.namespace.generatedUpperCase }
    )
    try self.checkServiceNamesAreUnique(for: servicesByUpperCaseNamespace)

    for service in codeGenerationRequest.services {
      try self.checkMethodNamesAreUnique(in: service)
    }
  }

  // Verify service names are unique within each namespace and that services with no namespace
  // don't have the same names as any of the namespaces.
  private func checkServiceNamesAreUnique(
    for servicesByUpperCaseNamespace: [String: [CodeGenerationRequest.ServiceDescriptor]]
  ) throws {
    // Check that if there are services in an empty namespace, none have names which match other namespaces,
    // to ensure that there are no enums with the same name in the type aliases part of the generated code.
    if let noNamespaceServices = servicesByUpperCaseNamespace[""] {
      let upperCaseNamespaces = servicesByUpperCaseNamespace.keys
      for service in noNamespaceServices {
        if upperCaseNamespaces.contains(service.name.generatedUpperCase) {
          throw CodeGenError(
            code: .nonUniqueServiceName,
            message: """
              Services with no namespace must not have the same generated upper case names as the namespaces. \
              \(service.name.generatedUpperCase) is used as a generated upper case name for a service with no namespace and a namespace.
              """
          )
        }
      }
    }

    // Check that the generated upper case names for services are unique within each namespace, to ensure that
    // the service enums from each namespace enum have unique names.
    for (namespace, services) in servicesByUpperCaseNamespace {
      var upperCaseNames: Set<String> = []

      for service in services {
        if upperCaseNames.contains(service.name.generatedUpperCase) {
          let errorMessage: String
          if namespace.isEmpty {
            errorMessage = """
              Services in an empty namespace must have unique generated upper case names. \
              \(service.name.generatedUpperCase) is used as a generated upper case name for multiple services without namespaces.
              """
          } else {
            errorMessage = """
              Services within the same namespace must have unique generated upper case names. \
              \(service.name.generatedUpperCase) is used as a generated upper case name for multiple services in the \(service.namespace.base) namespace.
              """
          }
          throw CodeGenError(
            code: .nonUniqueServiceName,
            message: errorMessage
          )
        }
        upperCaseNames.insert(service.name.generatedUpperCase)
      }
    }
  }

  // Verify method names are unique within a service.
  private func checkMethodNamesAreUnique(
    in service: CodeGenerationRequest.ServiceDescriptor
  ) throws {
    // Check that the method descriptors are unique, by checking that the base names
    // of the methods of a specific service are unique.
    let baseNames = service.methods.map { $0.name.base }
    var seenBaseNames = Set<String>()

    for baseName in baseNames {
      if seenBaseNames.contains(baseName) {
        throw CodeGenError(
          code: .nonUniqueMethodName,
          message: """
            Methods of a service must have unique base names. \
            \(baseName) is used as a base name for multiple methods of the \(service.name.base) service.
            """
        )
      }
      seenBaseNames.insert(baseName)
    }

    // Check that generated upper case names for methods are unique within a service, to ensure that
    // the enums containing type aliases for each method of a service.
    let upperCaseNames = service.methods.map { $0.name.generatedUpperCase }
    var seenUpperCaseNames = Set<String>()

    for upperCaseName in upperCaseNames {
      if seenUpperCaseNames.contains(upperCaseName) {
        throw CodeGenError(
          code: .nonUniqueMethodName,
          message: """
            Methods of a service must have unique generated upper case names. \
            \(upperCaseName) is used as a generated upper case name for multiple methods of the \(service.name.base) service.
            """
        )
      }
      seenUpperCaseNames.insert(upperCaseName)
    }

    // Check that generated lower case names for methods are unique within a service, to ensure that
    // the function declarations and definitions from the same protocols and extensions have unique names.
    let lowerCaseNames = service.methods.map { $0.name.generatedLowerCase }
    var seenLowerCaseNames = Set<String>()

    for lowerCaseName in lowerCaseNames {
      if seenLowerCaseNames.contains(lowerCaseName) {
        throw CodeGenError(
          code: .nonUniqueMethodName,
          message: """
            Methods of a service must have unique lower case names. \
            \(lowerCaseName) is used as a signature name for multiple methods of the \(service.name.base) service.
            """
        )
      }
      seenLowerCaseNames.insert(lowerCaseName)
    }
  }

  private func checkServiceDescriptorsAreUnique(
    _ services: [CodeGenerationRequest.ServiceDescriptor]
  ) throws {
    let descriptors = services.map {
      ($0.namespace.base.isEmpty ? "" : "\($0.namespace.base).") + $0.name.base
    }
    if let duplicate = descriptors.hasDuplicates() {
      throw CodeGenError(
        code: .nonUniqueServiceName,
        message: """
          Services must have unique descriptors. \
          \(duplicate) is the descriptor of at least two different services.
          """
      )
    }
  }
}

extension CodeGenerationRequest.ServiceDescriptor {
  var namespacedTypealiasGeneratedName: String {
    if self.namespace.generatedUpperCase.isEmpty {
      return self.name.generatedUpperCase
    } else {
      return "\(self.namespace.generatedUpperCase).\(self.name.generatedUpperCase)"
    }
  }

  var namespacedGeneratedName: String {
    if self.namespace.generatedUpperCase.isEmpty {
      return self.name.generatedUpperCase
    } else {
      return "\(self.namespace.generatedUpperCase)_\(self.name.generatedUpperCase)"
    }
  }

  var fullyQualifiedName: String {
    if self.namespace.base.isEmpty {
      return self.name.base
    } else {
      return "\(self.namespace.base).\(self.name.base)"
    }
  }
}

extension [String] {
  func hasDuplicates() -> String? {
    var elements = Set<String>()
    for element in self {
      if elements.insert(element).inserted == false {
        return element
      }
    }
    return nil
  }
}
