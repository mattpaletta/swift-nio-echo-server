//
//  Basic-Client.swift
//  basic-client
//
//  Created by Matthew on 2018-12-05.
//

import Foundation
import NIO

enum BasicClientError: Error {
    case invalidHost
    case invalidPort
}

class BasicClient {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var host: String?
    private var port: Int?
    private var bootstrap: ClientBootstrap {
        return ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([ClientOutHandler(), ClientInHandler()], first: false)
        }
    }
    
    private var channel: Channel?
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func start() throws {
        guard let host = host else {
            throw BasicClientError.invalidHost
        }
        guard let port = port else {
            throw BasicClientError.invalidPort
        }
        do {
            self.channel = try bootstrap.connect(host: host, port: port).wait()
            //            try channel.closeFuture.wait()
        } catch let error {
            throw error
        }
    }
    
    func read_when_ready() {
        self.channel?.read()
    }
    
    func write(msg: String) {
        // We will flush the buffer in the handler asynchronously.
        var buffer = self.channel!.allocator.buffer(capacity: msg.utf8.count)
        buffer.write(string: msg)
        self.channel!.write(buffer)
        
//        let _ = try self.channel!.writeAndFlush(msg)
        
//        do {
//            let _ = try self.channel!.write(msg).wait()
//        } catch let e {
//            print(e)
//            print("An error occured!")
//        }
        
//        let promise: EventLoopPromise<String> = self.channel!.eventLoop.newPromise()
//        self.channel?.writeAndFlush(msg, promise: promise)
//
//        return promise?.futureResult.then({ (_) -> EventLoopFuture<String> in
//            return self.channel?.read()
//        }).then({ (text) -> EventLoopFuture<String> in
//            return promise?.succeed(result: text)
//        })
    }
    
    func write_read(msg: String) {
        self.write(msg: msg)
        print("Waiting for read")
        self.read_when_ready()
    }
    
    func stop() {
        do {
            try self.channel?.closeFuture.wait()
            try self.group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down \(error.localizedDescription)")
            exit(0)
        }
        print("Client connection closed")
    }
}
