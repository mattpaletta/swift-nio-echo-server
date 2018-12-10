//
//  Echo-Server.swift
//  echo-server
//
//  Created by Matthew on 2018-12-05.
//

import Foundation

import NIO

enum EchoServerError: Error {
    case invalidHost
    case invalidPort
}

class EchoServer: NetIODelegate {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var host: String?
    private var port: Int?
    private var channel: Channel?
    
    var handler = EchoHandler()
    
    private var serverBootstrap: ServerBootstrap {
        return ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.add(handler: BackPressureHandler()).then { v in
                    channel.pipeline.add(handler: self.handler)
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
        self.handler.delegate = self
    }
    
    func network(received: String) -> EventLoopFuture<String> {
        let response_promise: EventLoopPromise<String> = self.channel!.eventLoop.newPromise()
        
        self.channel?.eventLoop.execute {
            let result = self.process_response(msg: received)
            response_promise.succeed(result: result)
        }
        
        return response_promise.futureResult
    }
    
    func process_response(msg: String) -> String {
        // This could do any arbitrary processing.
        return msg.uppercased()
    }
    
    func start() throws {
        guard let host = host else {
            throw EchoServerError.invalidHost
        }
        guard let port = port else {
            throw EchoServerError.invalidPort
        }
        do {
            self.channel = try serverBootstrap.bind(host: host, port: port).wait()
            print("Listening on \(channel!.localAddress!)...")
            try self.channel?.closeFuture.wait()
        } catch let error {
            throw error
        }
    }
    
    func stop() {
        do {
            try self.group.syncShutdownGracefully()
        } catch let error {
            print("Error shutting down \(error.localizedDescription)")
            exit(0)
        }
        print("Client connection closed")
    }
}
