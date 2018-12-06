//
//  BasicHandler.swift
//  basic-client
//
//  Created by Matthew on 2018-12-05.
//

import Foundation
import NIO

class ClientOutHandler: ChannelOutboundHandler {
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    private var numBytes = 0
    
    // channel is connected, send a message
    func channelActive(ctx: ChannelHandlerContext) {
        print("Connected on Channel!")
    }
    
    // This will flush the out-buffer for us!
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        ctx.writeAndFlush(data, promise: promise)
    }
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

//    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
//        var buffer = unwrapOutboundIn(data)
//        let readableBytes = buffer.readableBytes
//        if let received = buffer.readString(length: readableBytes) {
//            print("Received: \(received)")
//        }
//
//        if numBytes == 0 {
//            print("nothing left to read, close the channel")
//            ctx.close(promise: nil)
//        }
//    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}

class DependHandler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    var promise: EventLoopPromise<String>?

    func get_promise() -> EventLoopPromise<String> {
        return self.promise!
    }
    
    // Store the 'read' promise here.
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        print("Storing promise")
        self.promise = ctx.eventLoop.newPromise()
        ctx.writeAndFlush(data, promise: promise)
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            // TODO: Call delegate with message!
            print("Received2: \(received)")
            self.promise?.succeed(result: received)
        }
    }
}

class ClientInHandler: ChannelInboundHandler {
    typealias InboundOut = String
    typealias InboundIn = ByteBuffer
    
    
    var promise: EventLoopPromise<String>?
    private var numBytes = 0
    
    convenience init() {
        self.init(promise: nil)
    }
    
    init(promise: EventLoopPromise<String>?) {
        self.promise = promise
    }
    
    func add_promise(promise: EventLoopPromise<String>) {
        self.promise = promise
    }
    
    // channel is connected, send a message
    func channelActive(ctx: ChannelHandlerContext) {
        print("Connected on Channel!")
    }
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            print("Received: \(received)")
        }
        
        print(ctx.channel.pipeline.debugDescription)
        
        if numBytes == 0 {
//            print("nothing left to read, close the channel")
//            ctx.close(promise: nil)
        }
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}
