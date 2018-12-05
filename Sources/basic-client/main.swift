//
//  main.swift
//  basic-client
//
//  Created by Matthew on 2018-12-05.
//

import Foundation

func startup() -> (to: String, port: Int) {
    let middle_port = 4569
    let end_port = 4567
    
    print("Hello, This is Echo Server Client")
//    print("Would you like to connect to Echo Middle?[y/n]")
//    let x = readLine()
//    if x?.lowercased() == "y" || x?.lowercased() == "yes" {
//        return (to: "localhost", port: middle_port)
//    } else {
        return (to: "localhost", port: end_port)
//    }
}

func process_echos(client: BasicClient) {
    let stop_word = "exit"
    print("Ready for requests. To exit, type: \(stop_word)")
    
    var next = readLine()
    while next?.lowercased() != stop_word.lowercased() {
        guard let msg = next else { next = readLine(); continue }
        client.write_read(msg: msg)
        next = readLine()
    }
    print("Shutting Down.")
    client.stop()
}

let (to, port) = startup()

let client = BasicClient(host: to, port: port)
do {
    try client.start()
    process_echos(client: client)
} catch let error {
    print("Error: \(error.localizedDescription)")
    client.stop()
}
