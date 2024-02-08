import GRPCCore

@available(macOS 13.0, *)
struct EchoService: Echo.Echo.ServiceProtocol {
  func get(
    request: ServerRequest.Single<Echo.Echo.Method.Get.Input>
  ) async throws -> ServerResponse.Single<Echo.Echo.Method.Get.Output> {
    let message = Echo.Echo.Method.Get.Output.with{$0.text = "echo: \(request.message.text)"}
    return ServerResponse.Single(message: message, metadata: request.metadata)
  }

  func collect(
    request: ServerRequest.Stream<Echo.Echo.Method.Collect.Input>
  ) async throws -> ServerResponse.Single<Echo.Echo.Method.Collect.Output> {
    let text = try await request.messages.reduce(into: []) { $0.append($1.text) }
    let message = Echo.Echo.Method.Collect.Output.with{ $0.text = "echo: " + text.joined(separator: " ")}
    return ServerResponse.Single(message: message, metadata: request.metadata)
  }

  func expand(
    request: ServerRequest.Single<Echo.Echo.Method.Expand.Input>
  ) async throws -> ServerResponse.Stream<Echo.Echo.Method.Expand.Output> {
    return ServerResponse.Stream(metadata: request.metadata) { writer in
      for component in request.message.text.split(separator: " ") {
        let message = Echo.Echo.Method.Expand.Output.with{$0.text = "echo: \(component)"}
        try await writer.write(message)
      }
      return [:]
    }
  }

  func update(
    request: ServerRequest.Stream<Echo.Echo.Method.Update.Input>
  ) async throws -> ServerResponse.Stream<Echo.Echo.Method.Update.Output> {
    return ServerResponse.Stream(metadata: request.metadata) { writer in
      for try await message in request.messages {
        try await writer.write(Echo.Echo.Method.Update.Output.with{ $0.text = "echo: \(message.text)"})
      }
      return [:]
    }
  }
}
