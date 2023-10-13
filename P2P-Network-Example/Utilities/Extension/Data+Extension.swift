//
//  Data+Extension.swift
//  P2P-Network-Example
//
//  Created by cleanmac on 11/10/23.
//

import Foundation

extension Data {
    func chunked() -> [Data] {
        let chunkSize = 65536
        let fullChunks = Int(count / chunkSize)
        let totalChunks = fullChunks + (count % 1024 != 0 ? 1 : 0)
        
        var chunks: [Data] = []
        for chunkCounter in 0..<totalChunks {
            var chunk: Data
            let chunkBase = chunkCounter * chunkSize
            var diff = chunkSize
            if chunkCounter == totalChunks - 1 {
                diff = count - chunkBase
            }
            
            let range = chunkBase..<(chunkBase + diff)
            chunk = subdata(in: range)
            chunks.append(chunk)
        }
        return chunks
    }
}
