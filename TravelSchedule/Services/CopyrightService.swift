//
//  CopyrightService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CopyrightInfo = Components.Schemas.CopyrightInfo

protocol CopyrightServiceProtocol {
    func get(apikey: String, format: String?) async throws -> CopyrightInfo
}

final class CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func get(apikey: String, format: String? = nil) async throws -> CopyrightInfo {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey,
            format: format
        ))
        return try response.ok.body.json
    }
}
