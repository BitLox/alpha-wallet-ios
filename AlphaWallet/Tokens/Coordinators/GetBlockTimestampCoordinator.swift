// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import BigInt
import PromiseKit
import web3swift

class GetBlockTimestampCoordinator {
    //TODO persist?
    private static var blockTimestampCache: [RPCServer: [BigUInt: Date]] = .init()

    func getBlockTimestamp(_ blockNumber: BigUInt, onServer server: RPCServer) -> Promise<Date> {
        var cacheForServer = Self.blockTimestampCache[server] ?? .init()
        if let date = cacheForServer[blockNumber] {
            return .value(date)
        }

        guard let web3 = try? getCachedWeb3(forServer: server, timeout: 6) else {
            return Promise(error: Web3Error(description: "Error creating web3 for: \(server.rpcURL) + \(server.web3Network)"))
        }

        return web3.eth.getBlockByNumberPromise(blockNumber).map {
            let result = $0.timestamp
            cacheForServer[blockNumber] = result
            Self.blockTimestampCache[server] = cacheForServer
            return result
        }
    }
}
