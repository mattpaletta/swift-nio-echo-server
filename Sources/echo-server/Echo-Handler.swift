//
//  Echo-Handler.swift
//  echo-server
//
//  Created by Matthew on 2018-12-05.
//

import Foundation
import NIO

class EchoHandler: ChannelInboundHandler, ChannelOutboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    
    func channelActive(ctx: ChannelHandlerContext) {
        print("Got Channel!")
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var buffer = unwrapInboundIn(data)
        let readableBytes = buffer.readableBytes
        if let received = buffer.readString(length: readableBytes) {
            print(received)
        }
        
        ctx.write(data, promise: nil)
    }
    
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        print("Flushing!")
        ctx.writeAndFlush(data, promise: promise)
    }
    
    func channelReadComplete(ctx: ChannelHandlerContext) {
        print("Flushing Read-Complete!")
        ctx.flush()
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        ctx.close(promise: nil)
    }
}
