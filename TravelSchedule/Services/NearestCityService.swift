//
//  NearestCityService.swift
//  TravelSchedule
//
//  Created by Владислав on 21.12.2025.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias NearestCityResponse = Components.Schemas.NearestCityResponse

protocol NearestCityServiceProtocol {
    func getNearestCity(
        apikey: String,
        lat: Double,
        lng: Double,
        distance: Int?,
        lang: String?,
        format: String?
    ) async throws -> NearestCityResponse
}

final class NearestCityService: NearestCityServiceProtocol {
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    func getNearestCity(
        apikey: String,
        lat: Double,
        lng: Double,
        distance: Int? = nil,
        lang: String? = nil,
        format: String? = nil
    ) async throws -> NearestCityResponse {
        let response = try await client.getNearestCity(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            lang: lang,
            format: format
        ))
        return try response.ok.body.json
    }
}
