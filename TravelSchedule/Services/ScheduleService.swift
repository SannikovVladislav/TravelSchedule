//
//  ScheduleService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ScheduleResponse = Components.Schemas.ScheduleResponse

protocol ScheduleServiceProtocol {
    func getStationSchedule(
        apikey: String,
        station: String,
        lang: String?,
        format: String?,
        date: String?,
        transport_types: String?,
        event: String?,
        direction: String?,
        system: String?,
        result_timezone: String?
    ) async throws -> ScheduleResponse
}

final class ScheduleService: ScheduleServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getStationSchedule(
        apikey: String,
        station: String,
        lang: String? = nil,
        format: String? = nil,
        date: String? = nil,
        transport_types: String? = nil,
        event: String? = nil,
        direction: String? = nil,
        system: String? = nil,
        result_timezone: String? = nil
    ) async throws -> ScheduleResponse {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: station,
            lang: lang,
            format: format,
            date: date,
            transport_types: transport_types,
            event: event,
            direction: direction,
            system: system,
            result_timezone: result_timezone
        ))
        return try response.ok.body.json
    }
}
