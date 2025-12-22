//
//  ThreadService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse

protocol ThreadServiceProtocol {
    func getRouteStations(
        apikey: String,
        uid: String,
        from: String?,
        to: String?,
        format: String?,
        lang: String?,
        date: String?,
        show_systems: String?
    ) async throws -> ThreadStationsResponse
}

final class ThreadService: ThreadServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getRouteStations(
        apikey: String,
        uid: String,
        from: String? = nil,
        to: String? = nil,
        format: String? = nil,
        lang: String? = nil,
        date: String? = nil,
        show_systems: String? = nil
    ) async throws -> ThreadStationsResponse {
        let response = try await client.getRouteStations(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            format: format,
            lang: lang,
            date: date,
            show_systems: show_systems
        ))
        return try response.ok.body.json
    }
}
