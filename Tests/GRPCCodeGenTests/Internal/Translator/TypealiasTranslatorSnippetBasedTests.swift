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

#if os(macOS) || os(Linux)  // swift-format doesn't like canImport(Foundation.Process)

import XCTest

@testable import GRPCCodeGen

final class TypealiasTranslatorSnippetBasedTests: XCTestCase {
  typealias MethodDescriptor = GRPCCodeGen.CodeGenerationRequest.ServiceDescriptor.MethodDescriptor
  typealias ServiceDescriptor = GRPCCodeGen.CodeGenerationRequest.ServiceDescriptor
  typealias Name = GRPCCodeGen.CodeGenerationRequest.Name

  func testTypealiasTranslator() throws {
    let method = MethodDescriptor(
      documentation: "Documentation for MethodA",
      name: Name(base: "MethodA", generatedUpperCase: "MethodA", generatedLowerCase: "methodA"),
      isInputStreaming: false,
      isOutputStreaming: false,
      inputType: "NamespaceA_ServiceARequest",
      outputType: "NamespaceA_ServiceAResponse"
    )
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: [method]
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public enum MethodA {
                      public typealias Input = NamespaceA_ServiceARequest
                      public typealias Output = NamespaceA_ServiceAResponse
                      public static let descriptor = MethodDescriptor(
                          service: "namespaceA.ServiceA",
                          method: "MethodA"
                      )
                  }
                  public static let descriptors: [MethodDescriptor] = [
                      MethodA.descriptor
                  ]
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_ServiceAStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_ServiceAServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_ServiceAClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_ServiceAClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorNoMethodsServiceClientAndServer() throws {
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_ServiceAStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_ServiceAServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_ServiceAClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_ServiceAClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorServer() throws {
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_ServiceAStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_ServiceAServiceProtocol
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: false,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorClient() throws {
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_ServiceAClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_ServiceAClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: false,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorNoClientNoServer() throws {
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: false,
      server: false,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorEmptyNamespace() throws {
    let method = MethodDescriptor(
      documentation: "Documentation for MethodA",
      name: Name(base: "MethodA", generatedUpperCase: "MethodA", generatedLowerCase: "methodA"),
      isInputStreaming: false,
      isOutputStreaming: false,
      inputType: "ServiceARequest",
      outputType: "ServiceAResponse"
    )
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(base: "", generatedUpperCase: "", generatedLowerCase: ""),
      methods: [method]
    )
    let expectedSwift =
      """
      public enum ServiceA {
          public enum Method {
              public enum MethodA {
                  public typealias Input = ServiceARequest
                  public typealias Output = ServiceAResponse
                  public static let descriptor = MethodDescriptor(
                      service: "ServiceA",
                      method: "MethodA"
                  )
              }
              public static let descriptors: [MethodDescriptor] = [
                  MethodA.descriptor
              ]
          }
          @available(macOS 13.0, *)
          public typealias StreamingServiceProtocol = ServiceAStreamingServiceProtocol
          @available(macOS 13.0, *)
          public typealias ServiceProtocol = ServiceAServiceProtocol
          @available(macOS 13.0, *)
          public typealias ClientProtocol = ServiceAClientProtocol
          @available(macOS 13.0, *)
          public typealias Client = ServiceAClient
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorCheckMethodsOrder() throws {
    let methodA = MethodDescriptor(
      documentation: "Documentation for MethodA",
      name: Name(base: "MethodA", generatedUpperCase: "MethodA", generatedLowerCase: "methodA"),
      isInputStreaming: false,
      isOutputStreaming: false,
      inputType: "NamespaceA_ServiceARequest",
      outputType: "NamespaceA_ServiceAResponse"
    )
    let methodB = MethodDescriptor(
      documentation: "Documentation for MethodB",
      name: Name(base: "MethodB", generatedUpperCase: "MethodB", generatedLowerCase: "methodB"),
      isInputStreaming: false,
      isOutputStreaming: false,
      inputType: "NamespaceA_ServiceARequest",
      outputType: "NamespaceA_ServiceAResponse"
    )
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: [methodA, methodB]
    )
    let expectedSwift =
      """
      public enum NamespaceA {
          public enum ServiceA {
              public enum Method {
                  public enum MethodA {
                      public typealias Input = NamespaceA_ServiceARequest
                      public typealias Output = NamespaceA_ServiceAResponse
                      public static let descriptor = MethodDescriptor(
                          service: "namespaceA.ServiceA",
                          method: "MethodA"
                      )
                  }
                  public enum MethodB {
                      public typealias Input = NamespaceA_ServiceARequest
                      public typealias Output = NamespaceA_ServiceAResponse
                      public static let descriptor = MethodDescriptor(
                          service: "namespaceA.ServiceA",
                          method: "MethodB"
                      )
                  }
                  public static let descriptors: [MethodDescriptor] = [
                      MethodA.descriptor,
                      MethodB.descriptor
                  ]
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_ServiceAStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_ServiceAServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_ServiceAClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_ServiceAClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorNoMethodsService() throws {
    let service = ServiceDescriptor(
      documentation: "Documentation for ServiceA",
      name: Name(base: "ServiceA", generatedUpperCase: "ServiceA", generatedLowerCase: "serviceA"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )
    let expectedSwift =
      """
      package enum NamespaceA {
          package enum ServiceA {
              package enum Method {
                  package static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              package typealias StreamingServiceProtocol = NamespaceA_ServiceAStreamingServiceProtocol
              @available(macOS 13.0, *)
              package typealias ServiceProtocol = NamespaceA_ServiceAServiceProtocol
              @available(macOS 13.0, *)
              package typealias ClientProtocol = NamespaceA_ServiceAClientProtocol
              @available(macOS 13.0, *)
              package typealias Client = NamespaceA_ServiceAClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [service]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .package
    )
  }

  func testTypealiasTranslatorServiceAlphabeticalOrder() throws {
    let serviceB = ServiceDescriptor(
      documentation: "Documentation for BService",
      name: Name(base: "BService", generatedUpperCase: "Bservice", generatedLowerCase: "bservice"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )

    let serviceA = ServiceDescriptor(
      documentation: "Documentation for AService",
      name: Name(base: "AService", generatedUpperCase: "Aservice", generatedLowerCase: "aservice"),
      namespace: Name(
        base: "namespaceA",
        generatedUpperCase: "NamespaceA",
        generatedLowerCase: "namespaceA"
      ),
      methods: []
    )

    let expectedSwift =
      """
      public enum NamespaceA {
          public enum Aservice {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_AserviceStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_AserviceServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_AserviceClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_AserviceClient
          }
          public enum Bservice {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = NamespaceA_BserviceStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = NamespaceA_BserviceServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = NamespaceA_BserviceClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = NamespaceA_BserviceClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [serviceB, serviceA]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }

  func testTypealiasTranslatorServiceAlphabeticalOrderNoNamespace() throws {
    let serviceB = ServiceDescriptor(
      documentation: "Documentation for BService",
      name: Name(base: "BService", generatedUpperCase: "BService", generatedLowerCase: "bservice"),
      namespace: Name(base: "", generatedUpperCase: "", generatedLowerCase: ""),
      methods: []
    )

    let serviceA = ServiceDescriptor(
      documentation: "Documentation for AService",
      name: Name(base: "AService", generatedUpperCase: "AService", generatedLowerCase: "aservice"),
      namespace: Name(base: "", generatedUpperCase: "", generatedLowerCase: ""),
      methods: []
    )

    let expectedSwift =
      """
      package enum AService {
          package enum Method {
              package static let descriptors: [MethodDescriptor] = []
          }
          @available(macOS 13.0, *)
          package typealias StreamingServiceProtocol = AServiceStreamingServiceProtocol
          @available(macOS 13.0, *)
          package typealias ServiceProtocol = AServiceServiceProtocol
          @available(macOS 13.0, *)
          package typealias ClientProtocol = AServiceClientProtocol
          @available(macOS 13.0, *)
          package typealias Client = AServiceClient
      }
      package enum BService {
          package enum Method {
              package static let descriptors: [MethodDescriptor] = []
          }
          @available(macOS 13.0, *)
          package typealias StreamingServiceProtocol = BServiceStreamingServiceProtocol
          @available(macOS 13.0, *)
          package typealias ServiceProtocol = BServiceServiceProtocol
          @available(macOS 13.0, *)
          package typealias ClientProtocol = BServiceClientProtocol
          @available(macOS 13.0, *)
          package typealias Client = BServiceClient
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [serviceB, serviceA]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .package
    )
  }

  func testTypealiasTranslatorNamespaceAlphabeticalOrder() throws {
    let serviceB = ServiceDescriptor(
      documentation: "Documentation for BService",
      name: Name(base: "BService", generatedUpperCase: "BService", generatedLowerCase: "bservice"),
      namespace: Name(
        base: "bnamespace",
        generatedUpperCase: "Bnamespace",
        generatedLowerCase: "bnamespace"
      ),
      methods: []
    )

    let serviceA = ServiceDescriptor(
      documentation: "Documentation for AService",
      name: Name(base: "AService", generatedUpperCase: "AService", generatedLowerCase: "aservice"),
      namespace: Name(
        base: "anamespace",
        generatedUpperCase: "Anamespace",
        generatedLowerCase: "anamespace"
      ),
      methods: []
    )

    let expectedSwift =
      """
      internal enum Anamespace {
          internal enum AService {
              internal enum Method {
                  internal static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              internal typealias StreamingServiceProtocol = Anamespace_AServiceStreamingServiceProtocol
              @available(macOS 13.0, *)
              internal typealias ServiceProtocol = Anamespace_AServiceServiceProtocol
              @available(macOS 13.0, *)
              internal typealias ClientProtocol = Anamespace_AServiceClientProtocol
              @available(macOS 13.0, *)
              internal typealias Client = Anamespace_AServiceClient
          }
      }
      internal enum Bnamespace {
          internal enum BService {
              internal enum Method {
                  internal static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              internal typealias StreamingServiceProtocol = Bnamespace_BServiceStreamingServiceProtocol
              @available(macOS 13.0, *)
              internal typealias ServiceProtocol = Bnamespace_BServiceServiceProtocol
              @available(macOS 13.0, *)
              internal typealias ClientProtocol = Bnamespace_BServiceClientProtocol
              @available(macOS 13.0, *)
              internal typealias Client = Bnamespace_BServiceClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [serviceB, serviceA]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .internal
    )
  }

  func testTypealiasTranslatorNamespaceNoNamespaceOrder() throws {
    let serviceA = ServiceDescriptor(
      documentation: "Documentation for AService",
      name: Name(base: "AService", generatedUpperCase: "AService", generatedLowerCase: "aService"),
      namespace: Name(
        base: "anamespace",
        generatedUpperCase: "Anamespace",
        generatedLowerCase: "anamespace"
      ),
      methods: []
    )
    let serviceB = ServiceDescriptor(
      documentation: "Documentation for BService",
      name: Name(base: "BService", generatedUpperCase: "BService", generatedLowerCase: "bService"),
      namespace: Name(base: "", generatedUpperCase: "", generatedLowerCase: ""),
      methods: []
    )
    let expectedSwift =
      """
      public enum BService {
          public enum Method {
              public static let descriptors: [MethodDescriptor] = []
          }
          @available(macOS 13.0, *)
          public typealias StreamingServiceProtocol = BServiceStreamingServiceProtocol
          @available(macOS 13.0, *)
          public typealias ServiceProtocol = BServiceServiceProtocol
          @available(macOS 13.0, *)
          public typealias ClientProtocol = BServiceClientProtocol
          @available(macOS 13.0, *)
          public typealias Client = BServiceClient
      }
      public enum Anamespace {
          public enum AService {
              public enum Method {
                  public static let descriptors: [MethodDescriptor] = []
              }
              @available(macOS 13.0, *)
              public typealias StreamingServiceProtocol = Anamespace_AServiceStreamingServiceProtocol
              @available(macOS 13.0, *)
              public typealias ServiceProtocol = Anamespace_AServiceServiceProtocol
              @available(macOS 13.0, *)
              public typealias ClientProtocol = Anamespace_AServiceClientProtocol
              @available(macOS 13.0, *)
              public typealias Client = Anamespace_AServiceClient
          }
      }
      """

    try self.assertTypealiasTranslation(
      codeGenerationRequest: makeCodeGenerationRequest(services: [serviceA, serviceB]),
      expectedSwift: expectedSwift,
      client: true,
      server: true,
      accessLevel: .public
    )
  }
}

extension TypealiasTranslatorSnippetBasedTests {
  private func assertTypealiasTranslation(
    codeGenerationRequest: CodeGenerationRequest,
    expectedSwift: String,
    client: Bool,
    server: Bool,
    accessLevel: SourceGenerator.Configuration.AccessLevel
  ) throws {
    let translator = TypealiasTranslator(client: client, server: server, accessLevel: accessLevel)
    let codeBlocks = try translator.translate(from: codeGenerationRequest)
    let renderer = TextBasedRenderer.default
    renderer.renderCodeBlocks(codeBlocks)
    let contents = renderer.renderedContents()
    try XCTAssertEqualWithDiff(contents, expectedSwift)
  }
}

#endif  // os(macOS) || os(Linux)
