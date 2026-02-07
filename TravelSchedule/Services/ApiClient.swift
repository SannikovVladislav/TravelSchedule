//
//  ApiClient.swift
//  TravelSchedule
//
//  Created by Владислав on 07.02.2026.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@globalActor
actor ApiClient {
    static let shared = ApiClient()

    private let client: Client
    private let searchService: SearchService
    private let carrierService: CarrierService
    private let allStationsService: AllStationsService

    private init() {
        let client = Client(
            serverURL: URL(string: "https://api.rasp.yandex.net")!,
            transport: URLSessionTransport()
        )
        self.client = client
        self.searchService = SearchService(client: client)
        self.carrierService = CarrierService(client: client)
        self.allStationsService = AllStationsService(client: client)
    }

    // MARK: - Search
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
        try await searchService.getSegments(
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
        )
    }

    // MARK: - Carrier
    func getCarrierInfo(
        apikey: String,
        code: String,
        system: String? = nil,
        lang: String? = nil,
        format: String? = nil
    ) async throws -> CarrierResponse {
        try await carrierService.getCarrierInfo(
            apikey: apikey,
            code: code,
            system: system,
            lang: lang,
            format: format
        )
    }

    // MARK: - Directory (stations list endpoints)
    func fetchAllCities(apikey: String) async throws -> [DirectoryCity] {
        let directory = DirectoryService(apikey: apikey)
        return try await directory.fetchAllCities()
    }

    func fetchStations(inCityTitle cityTitle: String, apikey: String) async throws -> [DirectoryStation] {
        let directory = DirectoryService(apikey: apikey)
        return try await directory.fetchStations(inCityTitle: cityTitle)
    }

    // MARK: - Raw all stations (HTML)
    func getAllStationsRawHTML(apikey: String, lang: String? = nil, format: String? = nil) async throws -> String {
        try await allStationsService.getAllStations(apikey: apikey, lang: lang, format: format)
    }
}



