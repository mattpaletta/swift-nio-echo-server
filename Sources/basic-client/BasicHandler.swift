//
//  BasicHandler.swift
//  basic-client
//
//  Created by Matthew on 2018-12-05.
//

import Foundation
import NIO

class ClientOutHandler: ChannelOutboundHandler {
    
    typealias InboundIn = ByteBuffer
    typealias OutboundIn = ByteBuffer
    private var numBytes = 0
    
    // channel is connected, send a message
    func channelActive(ctx: ChannelHandlerContext) {
        print("Connected on Channel!")
//        let message = "SwiftNIO rocks!"
//        var buffer = ctx.channel.allocator.buffer(capacity: message.utf8.count)
//        buffer.write(string: message)
//        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
    }
    
    // This will flush the out-buffer for us!
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        ctx.writeAndFlush(data, promise: promise)
    }
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapOutboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            // TODO: Call delegate with message!
            print("Received: \(received)")
        }

        if numBytes == 0 {
            print("nothing left to read, close the channel")
            ctx.close(promise: nil)
        }
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}

class DependHandler: ChannelInboundHandler {
    typealias InboundIn = NIOAny
    typealias OutboundIn = String
    
    var promise: EventLoopPromise<String>
    
    init(promise: EventLoopPromise<String>) {
        self.promise = promise
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: String) {
        print("Succeed Promise!")
        self.promise.succeed(result: data)
//        ctx.writeAndFlush(data, promise: self.promise)
    }
}

class ClientInHandler: ChannelInboundHandler {
    typealias InboundOut = String
    typealias InboundIn = ByteBuffer
//    typealias OutboundOut = ByteBuffer
    typealias OutboundIn = String
    
    
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
        //        let message = "SwiftNIO rocks!"
        //        var buffer = ctx.channel.allocator.buffer(capacity: message.utf8.count)
        //        buffer.write(string: message)
        //        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
    }
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }
    
//    func channelRead(ctx: ChannelHandlerContext, data: String) {
//        print("Got message: \(data)")
//        var buffer = ctx.channel.allocator.buffer(capacity: data.utf8.count)
//        buffer.write(string: data)
//        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
//    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            // TODO: Call delegate with message!
            print("Received: \(received)")
            
//            ctx.writeAndFlush(data, promise: nil)
            ctx.fireChannelRead(data)
            if let pr = self.promise {
                pr.succeed(result: received)
//                ctx.writeAndFlush(received, promise: self.promise)
            }
        }
        
        print(ctx.channel.pipeline.debugDescription)
        
        
//        ctx.fireChannelRead(data)
//        ctx.fireChannelReadComplete()
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
