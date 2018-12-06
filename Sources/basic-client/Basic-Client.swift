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
        let promise: EventLoopPromise<Void> = self.channel!.eventLoop.newPromise()
        let handler = DependHandler()
        
        let _ = self.channel!.pipeline.add(name: "depends", handler: handler, first: true).then { (_) -> EventLoopFuture<Void> in
            print("wrote to channel!")
            self.channel?.write(buffer, promise: promise)
            return promise.futureResult
        }.then { (v) -> EventLoopFuture<String> in
                self.channel?.read()
                return handler.get_promise().futureResult
        }.map { (str) -> (String) in
                self.channel?.pipeline.remove(name: "depends")
                print("promised: \(str)")
                return str
        }
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
