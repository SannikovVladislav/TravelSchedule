//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Владислав on 15.12.2025.
//
import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("С Новым годом!")
        }
        .padding()
        .onAppear {
            print("Запускаем все сервисы...")
            Task {
                do {
                    let client = Client(
                        serverURL: try Servers.Server1.url(),
                        transport: URLSessionTransport()
                    )
                    let apikey = Constants.apiKey
                    
                    // 1. Copyright Service (Копирайт Яндекс Расписаний)
                    do {
                        let copyrightService = CopyrightService(client: client)
                        let copyright = try await copyrightService.get(apikey: apikey, format: nil)
                        print("🟢 Copyright:", copyright)
                    } catch {
                        print("🔴 Copyright error:", error)
                    }
                    
                    // 2. Nearest Stations Service (Список ближайших станций)
                    do {
                        let nearestStationsService = NearestStationsService(client: client, apikey: apikey)
                        let stations = try await nearestStationsService.getNearestStations(
                            lat: 59.864177, lng: 30.319163, distance: 50
                        )
                        print("🟢 Nearest stations:", stations)
                    } catch {
                        print("🔴 Nearest stations error:", error)
                    }
                    
                    // 3. Search Service (Расписание между станциями)
                    var threadUid: String? = nil
                    var carrierCode: String? = nil
                    
                    do {
                        let searchService = SearchService(client: client)
                        let segments = try await searchService.getSegments(
                            apikey: apikey,
                            from: "c213",
                            to: "c2",
                            format: "json",
                            lang: "ru_RU"
                        )
                        print("🟢 Segments:", segments)
                        
                        if let firstSegment = segments.segments?.first {
                            threadUid = firstSegment.thread?.uid
                            carrierCode = firstSegment.thread?.carrier?.code?.description
                            print("📋 Найден uid:", threadUid ?? "nil")
                            print("📋 Найден carrier code:", carrierCode ?? "nil")
                        }
                    } catch {
                        print("🔴 Segments error:", error)
                    }
                    
                    // 4. Schedule Service (Расписание по станции)
                    do {
                        let scheduleService = ScheduleService(client: client)
                        let schedule = try await scheduleService.getStationSchedule(
                            apikey: apikey,
                            station: "s9602498",
                            lang: "ru_RU",
                            format: "json"
                        )
                        print("🟢 Schedule:", schedule)
                    } catch {
                        print("🔴 Schedule error:", error)
                    }
                    
                    // 5. Thread Service (Список станций следования)
                    if let uid = threadUid {
                        do {
                            let threadService = ThreadService(client: client)
                            let threadStations = try await threadService.getRouteStations(
                                apikey: apikey, uid: uid
                            )
                            print("🟢 Thread stations:", threadStations)
                        } catch {
                            print("🔴 Thread stations error:", error)
                        }
                    } else {
                        print("⏭️ Thread Service пропущен - не найден uid в segments")
                    }
                    
                    // 6. Nearest City Service (Ближайший город)
                    do {
                        let nearestCityService = NearestCityService(client: client)
                        let nearestCity = try await nearestCityService.getNearestCity(
                            apikey: apikey, lat: 59.864177, lng: 30.319163
                        )
                        print("🟢 Nearest city:", nearestCity)
                    } catch {
                        print("🔴 Nearest city error:", error)
                    }
                    
                    // 7. Carrier Service (Информация о перевозчике)
                    if let code = carrierCode {
                        do {
                            let carrierService = CarrierService(client: client)
                            let carrier = try await carrierService.getCarrierInfo(
                                apikey: apikey, code: code
                            )
                            print("🟢 Carrier:", carrier)
                        } catch {
                            print("🔴 Carrier error:", error)
                        }
                    } else {
                        print("⏭️ Carrier Service пропущен - не найден код перевозчика в segments")
                    }
                    
                    // 8. All Stations Service (Список всех доступных станций)
                    do {
                        let allStationsService = AllStationsService(client: client)
                        let allStations = try await allStationsService.getAllStations(apikey: apikey)
                        print("🟢 All stations:", allStations)
                    } catch {
                        print("🔴 All stations error:", error)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
