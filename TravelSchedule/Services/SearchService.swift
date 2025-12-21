//
//  SearchService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias Segments = Components.Schemas.Segments

protocol SearchServiceProtocol {
    func getSegments(
        apikey: String,
        from: String,
        to: String,
        format: String?,
        lang: String?,
        date: String?,
        transport_types: String?,
        offset: Int?,
        limit: Int?,
        result_timezone: String?,
        transfers: Bool?
    ) async throws -> Segments
}

final class SearchService: SearchServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getSegments(
        apikey: String,
        from: String,
        to: String,
        format: String? = nil,
        lang: String? = nil,
        date: String? = nil,
        transport_types: String? = nil,
        offset: Int? = nil,
        limit: Int? = nil,
        result_timezone: String? = nil,
        transfers: Bool? = nil
    ) async throws -> Segments {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: format,
            lang: lang,
            date: date,
            transport_types: transport_types,
            offset: offset,
            limit: limit,
            result_timezone: result_timezone,
            transfers: transfers
        ))
        return try response.ok.body.json
    }
}
