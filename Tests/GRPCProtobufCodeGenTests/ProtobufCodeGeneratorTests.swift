/*
 * Copyright 2024, gRPC Authors All rights reserved.
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

import GRPCCodeGen
import GRPCProtobufCodeGen
import SwiftProtobuf
import SwiftProtobufPluginLibrary
import XCTest

final class ProtobufCodeGeneratorTests: XCTestCase {
  func testProtobufCodeGenerator() throws {
    try testCodeGeneration(
      indentation: 4,
      visibility: .internal,
      client: true,
      server: false,
      expectedCode: """
        // Copyright 2015 gRPC authors.
        //
        // Licensed under the Apache License, Version 2.0 (the "License");
        // you may not use this file except in compliance with the License.
        // You may obtain a copy of the License at
        //
        //     http://www.apache.org/licenses/LICENSE-2.0
        //
        // Unless required by applicable law or agreed to in writing, software
        // distributed under the License is distributed on an "AS IS" BASIS,
        // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        // See the License for the specific language governing permissions and
        // limitations under the License.

        // DO NOT EDIT.
        // swift-format-ignore-file
        //
        // Generated by the gRPC Swift generator plugin for the protocol buffer compiler.
        // Source: helloworld.proto
        //
        // For information on using the generated types, please see the documentation:
        //   https://github.com/grpc/grpc-swift

        import GRPCCore
        import GRPCProtobuf
        import DifferentModule
        import ExtraModule

        internal enum Hello_World_Greeter {
            internal enum Method {
                internal enum SayHello {
                    internal typealias Input = Hello_World_HelloRequest
                    internal typealias Output = Hello_World_HelloReply
                    internal static let descriptor = MethodDescriptor(
                        service: "hello.world.Greeter",
                        method: "SayHello"
                    )
                }
                internal static let descriptors: [MethodDescriptor] = [
                    SayHello.descriptor
                ]
            }
            @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
            internal typealias ClientProtocol = Hello_World_GreeterClientProtocol
            @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
            internal typealias Client = Hello_World_GreeterClient
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        internal protocol Hello_World_GreeterClientProtocol: Sendable {
            /// Sends a greeting.
            func sayHello<R>(
                request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
                serializer: some MessageSerializer<Hello_World_Greeter.Method.SayHello.Input>,
                deserializer: some MessageDeserializer<Hello_World_Greeter.Method.SayHello.Output>,
                _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
            ) async throws -> R where R: Sendable
        }

        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.ClientProtocol {
            internal func sayHello<R>(
                request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
                _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
            ) async throws -> R where R: Sendable {
                try await self.sayHello(
                    request: request,
                    serializer: ProtobufSerializer<Hello_World_Greeter.Method.SayHello.Input>(),
                    deserializer: ProtobufDeserializer<Hello_World_Greeter.Method.SayHello.Output>(),
                    body
                )
            }
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        internal struct Hello_World_GreeterClient: Hello_World_Greeter.ClientProtocol {
            private let client: GRPCCore.GRPCClient
            
            internal init(client: GRPCCore.GRPCClient) {
                self.client = client
            }
            
            /// Sends a greeting.
            internal func sayHello<R>(
                request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
                serializer: some MessageSerializer<Hello_World_Greeter.Method.SayHello.Input>,
                deserializer: some MessageDeserializer<Hello_World_Greeter.Method.SayHello.Output>,
                _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
            ) async throws -> R where R: Sendable {
                try await self.client.unary(
                    request: request,
                    descriptor: Hello_World_Greeter.Method.SayHello.descriptor,
                    serializer: serializer,
                    deserializer: deserializer,
                    handler: body
                )
            }
        }
        """
    )

    try testCodeGeneration(
      indentation: 2,
      visibility: .public,
      client: false,
      server: true,
      expectedCode: """
        // Copyright 2015 gRPC authors.
        //
        // Licensed under the Apache License, Version 2.0 (the "License");
        // you may not use this file except in compliance with the License.
        // You may obtain a copy of the License at
        //
        //     http://www.apache.org/licenses/LICENSE-2.0
        //
        // Unless required by applicable law or agreed to in writing, software
        // distributed under the License is distributed on an "AS IS" BASIS,
        // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        // See the License for the specific language governing permissions and
        // limitations under the License.

        // DO NOT EDIT.
        // swift-format-ignore-file
        //
        // Generated by the gRPC Swift generator plugin for the protocol buffer compiler.
        // Source: helloworld.proto
        //
        // For information on using the generated types, please see the documentation:
        //   https://github.com/grpc/grpc-swift

        import GRPCCore
        import GRPCProtobuf
        import DifferentModule
        import ExtraModule

        public enum Hello_World_Greeter {
          public enum Method {
            public enum SayHello {
              public typealias Input = Hello_World_HelloRequest
              public typealias Output = Hello_World_HelloReply
              public static let descriptor = MethodDescriptor(
                service: "hello.world.Greeter",
                method: "SayHello"
              )
            }
            public static let descriptors: [MethodDescriptor] = [
              SayHello.descriptor
            ]
          }
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          public typealias StreamingServiceProtocol = Hello_World_GreeterStreamingServiceProtocol
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          public typealias ServiceProtocol = Hello_World_GreeterServiceProtocol
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        public protocol Hello_World_GreeterStreamingServiceProtocol: GRPCCore.RegistrableRPCService {
          /// Sends a greeting.
          func sayHello(request: ServerRequest.Stream<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Stream<Hello_World_Greeter.Method.SayHello.Output>
        }

        /// Conformance to `GRPCCore.RegistrableRPCService`.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.StreamingServiceProtocol {
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          public func registerMethods(with router: inout GRPCCore.RPCRouter) {
            router.registerHandler(
              forMethod: Hello_World_Greeter.Method.SayHello.descriptor,
              deserializer: ProtobufDeserializer<Hello_World_Greeter.Method.SayHello.Input>(),
              serializer: ProtobufSerializer<Hello_World_Greeter.Method.SayHello.Output>(),
              handler: { request in
                try await self.sayHello(request: request)
              }
            )
          }
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        public protocol Hello_World_GreeterServiceProtocol: Hello_World_Greeter.StreamingServiceProtocol {
          /// Sends a greeting.
          func sayHello(request: ServerRequest.Single<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Single<Hello_World_Greeter.Method.SayHello.Output>
        }

        /// Partial conformance to `Hello_World_GreeterStreamingServiceProtocol`.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.ServiceProtocol {
          public func sayHello(request: ServerRequest.Stream<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Stream<Hello_World_Greeter.Method.SayHello.Output> {
            let response = try await self.sayHello(request: ServerRequest.Single(stream: request))
            return ServerResponse.Stream(single: response)
          }
        }
        """
    )
    try testCodeGeneration(
      indentation: 2,
      visibility: .package,
      client: true,
      server: true,
      expectedCode: """
        // Copyright 2015 gRPC authors.
        //
        // Licensed under the Apache License, Version 2.0 (the "License");
        // you may not use this file except in compliance with the License.
        // You may obtain a copy of the License at
        //
        //     http://www.apache.org/licenses/LICENSE-2.0
        //
        // Unless required by applicable law or agreed to in writing, software
        // distributed under the License is distributed on an "AS IS" BASIS,
        // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        // See the License for the specific language governing permissions and
        // limitations under the License.

        // DO NOT EDIT.
        // swift-format-ignore-file
        //
        // Generated by the gRPC Swift generator plugin for the protocol buffer compiler.
        // Source: helloworld.proto
        //
        // For information on using the generated types, please see the documentation:
        //   https://github.com/grpc/grpc-swift

        import GRPCCore
        import GRPCProtobuf
        import DifferentModule
        import ExtraModule

        package enum Hello_World_Greeter {
          package enum Method {
            package enum SayHello {
              package typealias Input = Hello_World_HelloRequest
              package typealias Output = Hello_World_HelloReply
              package static let descriptor = MethodDescriptor(
                service: "hello.world.Greeter",
                method: "SayHello"
              )
            }
            package static let descriptors: [MethodDescriptor] = [
              SayHello.descriptor
            ]
          }
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          package typealias StreamingServiceProtocol = Hello_World_GreeterStreamingServiceProtocol
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          package typealias ServiceProtocol = Hello_World_GreeterServiceProtocol
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          package typealias ClientProtocol = Hello_World_GreeterClientProtocol
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          package typealias Client = Hello_World_GreeterClient
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        package protocol Hello_World_GreeterStreamingServiceProtocol: GRPCCore.RegistrableRPCService {
          /// Sends a greeting.
          func sayHello(request: ServerRequest.Stream<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Stream<Hello_World_Greeter.Method.SayHello.Output>
        }

        /// Conformance to `GRPCCore.RegistrableRPCService`.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.StreamingServiceProtocol {
          @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
          package func registerMethods(with router: inout GRPCCore.RPCRouter) {
            router.registerHandler(
              forMethod: Hello_World_Greeter.Method.SayHello.descriptor,
              deserializer: ProtobufDeserializer<Hello_World_Greeter.Method.SayHello.Input>(),
              serializer: ProtobufSerializer<Hello_World_Greeter.Method.SayHello.Output>(),
              handler: { request in
                try await self.sayHello(request: request)
              }
            )
          }
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        package protocol Hello_World_GreeterServiceProtocol: Hello_World_Greeter.StreamingServiceProtocol {
          /// Sends a greeting.
          func sayHello(request: ServerRequest.Single<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Single<Hello_World_Greeter.Method.SayHello.Output>
        }

        /// Partial conformance to `Hello_World_GreeterStreamingServiceProtocol`.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.ServiceProtocol {
          package func sayHello(request: ServerRequest.Stream<Hello_World_Greeter.Method.SayHello.Input>) async throws -> ServerResponse.Stream<Hello_World_Greeter.Method.SayHello.Output> {
            let response = try await self.sayHello(request: ServerRequest.Single(stream: request))
            return ServerResponse.Stream(single: response)
          }
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        package protocol Hello_World_GreeterClientProtocol: Sendable {
          /// Sends a greeting.
          func sayHello<R>(
            request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
            serializer: some MessageSerializer<Hello_World_Greeter.Method.SayHello.Input>,
            deserializer: some MessageDeserializer<Hello_World_Greeter.Method.SayHello.Output>,
            _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
          ) async throws -> R where R: Sendable
        }

        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        extension Hello_World_Greeter.ClientProtocol {
          package func sayHello<R>(
            request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
            _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
          ) async throws -> R where R: Sendable {
            try await self.sayHello(
              request: request,
              serializer: ProtobufSerializer<Hello_World_Greeter.Method.SayHello.Input>(),
              deserializer: ProtobufDeserializer<Hello_World_Greeter.Method.SayHello.Output>(),
              body
            )
          }
        }

        /// The greeting service definition.
        @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
        package struct Hello_World_GreeterClient: Hello_World_Greeter.ClientProtocol {
          private let client: GRPCCore.GRPCClient
          
          package init(client: GRPCCore.GRPCClient) {
            self.client = client
          }
          
          /// Sends a greeting.
          package func sayHello<R>(
            request: ClientRequest.Single<Hello_World_Greeter.Method.SayHello.Input>,
            serializer: some MessageSerializer<Hello_World_Greeter.Method.SayHello.Input>,
            deserializer: some MessageDeserializer<Hello_World_Greeter.Method.SayHello.Output>,
            _ body: @Sendable @escaping (ClientResponse.Single<Hello_World_Greeter.Method.SayHello.Output>) async throws -> R
          ) async throws -> R where R: Sendable {
            try await self.client.unary(
              request: request,
              descriptor: Hello_World_Greeter.Method.SayHello.descriptor,
              serializer: serializer,
              deserializer: deserializer,
              handler: body
            )
          }
        }
        """
    )
  }

  func testCodeGeneration(
    indentation: Int,
    visibility: SourceGenerator.Configuration.AccessLevel,
    client: Bool,
    server: Bool,
    expectedCode: String
  ) throws {
    let configs = SourceGenerator.Configuration(
      accessLevel: visibility,
      client: client,
      server: server,
      indentation: indentation
    )
    let descriptorSet = DescriptorSet(
      protos: [
        Google_Protobuf_FileDescriptorProto(name: "same-module.proto", package: "same-package"),
        Google_Protobuf_FileDescriptorProto(
          name: "different-module.proto",
          package: "different-package"
        ),
        Google_Protobuf_FileDescriptorProto.helloWorld,
      ])
    guard let fileDescriptor = descriptorSet.fileDescriptor(named: "helloworld.proto") else {
      return XCTFail(
        """
        Could not find the file descriptor of "helloworld.proto".
        """
      )
    }

    let moduleMappings = SwiftProtobuf_GenSwift_ModuleMappings.with {
      $0.mapping = [
        SwiftProtobuf_GenSwift_ModuleMappings.Entry.with {
          $0.protoFilePath = ["different-module.proto"]
          $0.moduleName = "DifferentModule"
        }
      ]
    }
    let generator = ProtobufCodeGenerator(configuration: configs)
    try XCTAssertEqualWithDiff(
      try generator.generateCode(
        from: fileDescriptor,
        protoFileModuleMappings: ProtoFileToModuleMappings(moduleMappingsProto: moduleMappings),
        extraModuleImports: ["ExtraModule"]
      ),
      expectedCode
    )
  }
}

private func diff(expected: String, actual: String) throws -> String {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [
    "bash", "-c",
    "diff -U5 --label=expected <(echo '\(expected)') --label=actual <(echo '\(actual)')",
  ]
  let pipe = Pipe()
  process.standardOutput = pipe
  try process.run()
  process.waitUntilExit()
  let pipeData = try XCTUnwrap(
    pipe.fileHandleForReading.readToEnd(),
    """
    No output from command:
    \(process.executableURL!.path) \(process.arguments!.joined(separator: " "))
    """
  )
  return String(decoding: pipeData, as: UTF8.self)
}

internal func XCTAssertEqualWithDiff(
  _ actual: String,
  _ expected: String,
  file: StaticString = #filePath,
  line: UInt = #line
) throws {
  if actual == expected { return }
  XCTFail(
    """
    XCTAssertEqualWithDiff failed (click for diff)
    \(try diff(expected: expected, actual: actual))
    """,
    file: file,
    line: line
  )
}

#endif  // os(macOS) || os(Linux)
