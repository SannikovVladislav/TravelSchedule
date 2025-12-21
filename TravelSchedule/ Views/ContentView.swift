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
            Text("Hello, world!")
        }
        .padding()
        .onAppear() {
            testFetchStations()
            // Функция для тестового вызова API
            func testFetchStations() {
                // Создаём Task для выполнения асинхронного кода
                Task {
                    do {
                        // 1. Создаём экземпляр сгенерированного клиента
                        let client = Client(
                            // Используем URL сервера, также сгенерированный из openapi.yaml (если он там определён)
                            serverURL: try Servers.Server1.url(),
                            // Указываем, какой транспорт использовать для отправки запросов
                            transport: URLSessionTransport()
                        )
                        
                        // 2. Создаём экземпляр нашего сервиса, передавая ему клиент и API-ключ
                        let service = NearestStationsService(
                            client: client,
                            apikey: "807f69ba-ef96-4c8f-86ad-706710327dee" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
                        )
                        
                        // 3. Вызываем метод сервиса
                        print("Fetching stations...")
                        let stations = try await service.getNearestStations(
                            lat: 59.864177, // Пример координат
                            lng: 30.319163, // Пример координат
                            distance: 50    // Пример дистанции
                        )
                        
                        // 4. Если всё успешно, печатаем результат в консоль
                        print("Successfully fetched stations: \(stations)")
                    } catch {
                        // 5. Если произошла ошибка на любом из этапов (создание клиента, вызов сервиса, обработка ответа),
                        //    она будет поймана здесь, и мы выведем её в консоль
                        print("Error fetching stations: \(error)")
                        // В реальном приложении здесь должна быть логика обработки ошибок (показ алерта и т. д.)
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
