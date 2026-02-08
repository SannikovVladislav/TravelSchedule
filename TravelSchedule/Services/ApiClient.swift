//
//  ApiClient.swift
//  TravelSchedule
//
//  Created by Владислав on 07.02.2026.
//
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@MainActor
final class ApiClient {
    static let shared = ApiClient()
    
    private static let serverURL: URL = {
            guard let url = URL(string: "https://api.rasp.yandex.net") else {
                fatalError("Invalid server URL")
            }
            return url
        }()


    private let client: Client
    private let searchService: SearchService
    private let carrierService: CarrierService
    private let allStationsService: AllStationsService

    private init() {
        self.client = Client(
            serverURL: Self.serverURL,
            transport: URLSessionTransport()
        )
        self.searchService = SearchService(client: client)
        self.carrierService = CarrierService(client: client)
        self.allStationsService = AllStationsService(client: client)
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

    func fetchAllCities(apikey: String) async throws -> [DirectoryCity] {
        let directory = DirectoryService(apikey: apikey)
        return try await directory.fetchAllCities()
    }

    func fetchStations(inCityTitle cityTitle: String, apikey: String) async throws -> [DirectoryStation] {
        let directory = DirectoryService(apikey: apikey)
        return try await directory.fetchStations(inCityTitle: cityTitle)
    }

    func getAllStationsRawHTML(apikey: String, lang: String? = nil, format: String? = nil) async throws -> String {
        try await allStationsService.getAllStations(apikey: apikey, lang: lang, format: format)
    }
}



