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

import GRPCCore
import NIOConcurrencyHelpers

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct BenchmarkClient {
  var client: GRPCClient
  var rpcNumber: Int32
  var rpcType: Grpc_Testing_RpcType
  private let rpcStats: NIOLockedValueBox<RPCStats>

  init(
    client: GRPCClient,
    rpcNumber: Int32,
    rpcType: Grpc_Testing_RpcType,
    histogramParams: Grpc_Testing_HistogramParams?
  ) {
    self.client = client
    self.rpcNumber = rpcNumber
    self.rpcType = rpcType

    var histogram: RPCStats.LatencyHistogram
    if let histogramParams = histogramParams {
      histogram = .init(
        resolution: histogramParams.resolution,
        maxBucketStart: histogramParams.maxPossible
      )
    } else {
      histogram = .init()
    }

    self.rpcStats = NIOLockedValueBox(RPCStats(latencyHistogram: histogram))
  }

  func run() async throws {
    let benchmarkClient = Grpc_Testing_BenchmarkServiceClient(client: client)
    return try await withThrowingTaskGroup(of: Void.self) { clientGroup in
      // Start the client.
      clientGroup.addTask { try await client.run() }

      // Make the requests to the server and register the latency for each one.
      try await withThrowingTaskGroup(of: Void.self) { rpcsGroup in
        for _ in 0 ..< self.rpcNumber {
          rpcsGroup.addTask {
            let (latency, errorCode) = self.makeRPC(client: benchmarkClient, rpcType: self.rpcType)
            self.rpcStats.withLockedValue {
              $0.latencyHistogram.add(value: latency)
              if errorCode != nil {
                $0.requestResultCount[Int32(errorCode!.rawValue), default: 1] += 1
              }
            }
          }
        }
        try await rpcsGroup.waitForAll()
      }

      try await clientGroup.next()
    }
  }

  // The result is the number of nanoseconds for processing the RPC.
  private func makeRPC(
    client: Grpc_Testing_BenchmarkServiceClient,
    rpcType: Grpc_Testing_RpcType
  ) -> (latency: Double, errorCode: RPCError.Code?) {
    switch rpcType {
    case .unary, .streaming, .streamingFromClient, .streamingFromServer, .streamingBothWays,
      .UNRECOGNIZED:
      let startTime = RPCStats.LatencyHistogram.grpcTimeNow()
      let endTime = RPCStats.LatencyHistogram.grpcTimeNow()
      return (
        latency: Double((endTime - startTime).value), errorCode: RPCError.Code(.unimplemented)
      )
    }
  }
}
