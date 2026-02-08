//
//  DirectoryService.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//
import Foundation

struct DirectoryCity: Hashable, Sendable {
    let title: String
}

struct DirectoryStation: Hashable, Sendable {
    let title: String
    let yandexCode: String?
}

struct DirectoryAPIResponse: Decodable, Sendable {
    let countries: [DirectoryCountry]
}

struct DirectoryCountry: Decodable, Sendable {
    let title: String
    let regions: [DirectoryRegion]
}

struct DirectoryRegion: Decodable, Sendable {
    let settlements: [DirectorySettlement]
}

struct DirectorySettlement: Decodable, Sendable {
    let title: String
    let popularTitle: String?
    let shortTitle: String?
    let stations: [DirectoryAPIStation]
    
    enum CodingKeys: String, CodingKey {
        case title
        case popularTitle = "popular_title"
        case shortTitle = "short_title"
        case stations
    }
}

struct DirectoryAPIStation: Decodable, Sendable {
    let title: String
    let shortTitle: String?
    let transportType: String
    let codes: DirectoryStationCodes?
    
    enum CodingKeys: String, CodingKey {
        case title
        case shortTitle = "short_title"
        case transportType = "transport_type"
        case codes
    }
}

struct DirectoryStationCodes: Decodable, Sendable {
    let yandexCode: String?
    
    enum CodingKeys: String, CodingKey {
        case yandexCode = "yandex_code"
    }
}

final class DirectoryService {
    private let apikey: String
    private static var cachedCountries: [DirectoryCountry]?
    private static var loadingTask: Task<[DirectoryCountry], Error>?
    
    init(apikey: String) {
        self.apikey = apikey
    }
    
    func fetchAllCities() async throws -> [DirectoryCity] {
        let countries = try await loadCountries()
        var set = Set<String>()
        
        for country in countries {
            for region in country.regions {
                for settlement in region.settlements {
                    if !settlement.title.isEmpty {
                        set.insert(settlement.title)
                    }
                }
            }
        }
        
        return set.sorted().map { DirectoryCity(title: $0) }
    }
    
    func fetchStations(inCityTitle cityTitle: String) async throws -> [DirectoryStation] {
        let trimmed = cityTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }
        
        let countries = try await loadCountries()
        var result: [DirectoryStation] = []
        let target = normalize(trimmed)
        
        for country in countries {
            guard country.title.contains("Россия") || country.title.contains("Russia") else { continue }
            
            for region in country.regions {
                for settlement in region.settlements {
                    let titles = [settlement.title, settlement.popularTitle, settlement.shortTitle].compactMap { $0 }
                    let matches = titles.map { normalize($0) }.contains(target)
                    
                    guard matches else { continue }
                    
                    for station in settlement.stations {
                        guard station.transportType == "train" else { continue }

                        guard let yandexCode = station.codes?.yandexCode, !yandexCode.isEmpty else { continue }
                        
                        let rawTitle = station.shortTitle ?? station.title
                        let onlyStationName = extractStationName(fromFullTitle: rawTitle, cityTitle: cityTitle)
                        
                        guard !onlyStationName.isEmpty else { continue }

                        let hasCyrillic = onlyStationName.unicodeScalars.contains { scalar in
                            (0x0400...0x04FF).contains(scalar.value)
                        }
                        guard hasCyrillic else { continue }
                        
                        result.append(DirectoryStation(title: onlyStationName, yandexCode: yandexCode))
                    }
                }
            }
        }

        var seen = Set<String>()
        var unique: [DirectoryStation] = []
        for station in result {
            if seen.insert(station.title).inserted {
                unique.append(station)
            }
        }

        return unique.sorted { station1, station2 in
            let title1 = station1.title
            let title2 = station2.title
            
            let isLetter1 = title1.first?.isLetter ?? false
            let isLetter2 = title2.first?.isLetter ?? false
            
            if isLetter1 && !isLetter2 {
                return true
            } else if !isLetter1 && isLetter2 {
                return false
            } else {
                return title1 < title2
            }
        }
    }

    private func loadCountries() async throws -> [DirectoryCountry] {
        if let cached = Self.cachedCountries {
            return cached
        }

        if let task = Self.loadingTask {
            return try await task.value
        }

        let task = Task<[DirectoryCountry], Error> {
            let url = try makeURL()
            let (data, _) = try await URLSession.shared.data(from: url)

            let decoder = JSONDecoder()
            let response = try decoder.decode(DirectoryAPIResponse.self, from: data)
            let countries = response.countries

            Self.cachedCountries = countries
            Self.loadingTask = nil
            
            return countries
        }
        
        Self.loadingTask = task
        return try await task.value
    }
    
    private func normalize(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
    }
    
    private func makeURL() throws -> URL {
        var components = URLComponents(string: "https://api.rasp.yandex.net/v3.0/stations_list/")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU")
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }
    
    private func extractStationName(fromFullTitle title: String, cityTitle: String) -> String {
        if let commaIdx = title.firstIndex(of: ",") {
            let after = title.index(after: commaIdx)
            return String(title[after...]).trimmingCharacters(in: .whitespaces)
        }

        if let open = title.firstIndex(of: "("),
           let close = title.firstIndex(of: ")"),
           open < close {
            let inside = title.index(after: open)..<close
            return String(title[inside]).trimmingCharacters(in: .whitespaces)
        }

        let normTitle = normalize(title)
        let normCity = normalize(cityTitle)
        if normTitle.hasPrefix(normCity) {
            let trimmed = title.dropFirst(cityTitle.count).trimmingCharacters(in: .whitespaces)
            return trimmed
        }
        
        return title
    }
}
