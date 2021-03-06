//
//  main.swift
//  echo-server
//
//  Created by Matthew on 2018-12-05.
//

import Foundation

import NIOHTTP1


let SERVER = true
let port = 4567

// Every node binds to 0.0.0.0:3010
print("Starting Echo Server")
let server = EchoServer(host: "localhost", port: port)
do {
    // Server.start is an infinite loop
    try server.start()
} catch let error {
    print("Error: \(error.localizedDescription)")
    server.stop()
}
