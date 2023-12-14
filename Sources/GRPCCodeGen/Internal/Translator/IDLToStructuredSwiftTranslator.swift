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
  private let typealiasTranslator = TypealiasTranslator()
  private let serverCodeTranslator = ServerCodeTranslator()

  func translate(
    codeGenerationRequest: CodeGenerationRequest,
    client: Bool,
    server: Bool
  ) throws -> StructuredSwiftRepresentation {
    let topComment = Comment.doc(codeGenerationRequest.leadingTrivia)
    let imports: [ImportDescription] = [
      ImportDescription(moduleName: "GRPCCore")
    ]
    var codeBlocks: [CodeBlock] = []
    codeBlocks.append(
      contentsOf: try self.typealiasTranslator.translate(from: codeGenerationRequest)
    )

    if server {
      codeBlocks.append(
        contentsOf: try self.serverCodeTranslator.translate(from: codeGenerationRequest)
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