//
//  AllStationsService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol AllStationsServiceProtocol {
    func getAllStations(
        apikey: String,
        lang: String?,
        format: String?
    ) async throws -> String
}

final class AllStationsService: AllStationsServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getAllStations(
        apikey: String,
        lang: String? = nil,
        format: String? = nil
    ) async throws -> String {
        let output = try await client.getAllStations(query: .init(
            apikey: apikey,
            lang: lang,
            format: format
        ))
        switch output {
        case .ok(let ok):
            switch ok.body {
            case .html(let body):
                
                var collected = Data()
                for try await chunk in body {
                    collected.append(contentsOf: chunk)
                }
                return String(data: collected, encoding: .utf8) ?? ""
            }
        default:
            throw NSError(domain: "AllStationsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Non-200 response"])
        }
    }
}
