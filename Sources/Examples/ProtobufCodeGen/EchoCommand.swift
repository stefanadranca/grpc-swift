import ArgumentParser
import struct Foundation.UUID
import GRPCCore
import GRPCInProcessTransport

@available(macOS 13.0, *)
  @main
  struct EchoCommand: AsyncParsableCommand {
    @Flag(help: "Stream input messages.")
    var streamInput: Bool = false

    @Flag(help: "Stream output messages.")
    var streamOutput: Bool = false

    @Argument(help: "Input to the RPC.")
    var input: String

    func run() async throws {
      let inProcess = InProcessTransport.makePair()

      try await withThrowingTaskGroup(of: Void.self) { group in
        // Configure and run the server.
        group.addTask {
          let server = GRPCServer(transports: [inProcess.server], services: [EchoService()])
          try await server.run()
        }

        // Configure and run the client.
        group.addTask {
          try await withThrowingTaskGroup(of: Void.self) { clientGroup in
            let client = GRPCClient(
              transport: inProcess.client
            )

            clientGroup.addTask {
              try await client.run()
            }

            let echo = Echo.Echo.Client(client: client)
            switch (self.streamInput, self.streamOutput) {
            case (false, false):
              try await self.get(echo)
            case (false, true):
              try await self.expand(echo)
            case (true, false):
              try await self.collect(echo)
            case (true, true):
              try await self.update(echo)
            }

            clientGroup.cancelAll()
          }
        }

        try await group.next()
        group.cancelAll()
      }
    }
  }

@available(macOS 13.0, *)
extension EchoCommand {
  // Unary
  func get(_ client: Echo.Echo.Client) async throws {
    let request = ClientRequest.Single(
      message: Echo.Echo.Method.Get.Input.with{$0.text = self.input},
      metadata: ["uuid": "\(UUID())"]
    )

    try await client.get(request: request) { response in
      try print(response.message)
    }
  }

  // Client streaming.
  func collect(_ client: Echo.Echo.Client) async throws {
    let request = ClientRequest.Stream(metadata: ["uuid": "\(UUID())"]) { writer in
      for part in self.input.split(separator: " ") {
        let message = Echo.Echo.Method.Collect.Input.with{ $0.text = String(part)}
        try await writer.write(message)
      }
    }

    try await client.collect(request: request) { response in
      try print(response.message)
    }
  }

  // Server streaming.
  func expand(_ client: Echo.Echo.Client) async throws {
    let request = ClientRequest.Single(
      message: Echo.Echo.Method.Expand.Input.with{$0.text = self.input},
      metadata: ["uuid": "\(UUID())"]
    )

    try await client.expand(request: request) { response in
      for try await message in response.messages {
        print(message)
      }
    }
  }

  // Bidirectional streaming.
  func update(_ client: Echo.Echo.Client) async throws {
    let request = ClientRequest.Stream(metadata: ["uuid": "\(UUID())"]) { writer in
      for part in self.input.split(separator: " ") {
        let message = Echo.Echo.Method.Update.Input.with{ $0.text = String(part) }
        try await writer.write(message)
      }
    }

    try await client.update(request: request) { response in
      for try await message in response.messages {
        print(message)
      }
    }
  }
}
