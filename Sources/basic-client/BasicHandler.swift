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

class ClientInHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
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
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: String) {
        print("Got message: \(data)")
        var buffer = ctx.channel.allocator.buffer(capacity: data.utf8.count)
        buffer.write(string: data)
        ctx.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            // TODO: Call delegate with message!
            print("Received: \(received)")
        }
        
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
