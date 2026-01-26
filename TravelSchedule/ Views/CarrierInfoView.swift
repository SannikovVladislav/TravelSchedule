//
//  InfoCarrier.swift
//  TravelSchedule
//
//  Created by Владислав on 05.01.2026.
//
import SwiftUI
import OpenAPIURLSession
import Combine

struct CarrierInfoView: View {
    let carrier: CarrierInfo
    let onBack: () -> Void
    
    @State private var email: String?
    @State private var phone: String?
    @State private var detailsLoaded = false
    
    private let apikey = Constants.apiKey
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color(.whiteDayYP).frame(height: 12).ignoresSafeArea(edges: .top)
                ZStack {
                    Text("Информация о перевозчике")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(.blackDayYP))
                        .multilineTextAlignment(.center)
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(.blackDayYP))
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color(.whiteDayYP))
            ScrollView {
                VStack(spacing: 24) {
                    CarrierInfoLogoView(logoURLString: carrier.logo, title: carrier.title)
                        .frame(height: 104)
                        .padding(.horizontal, 16)
                    Text(carrier.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(.blackDayYP))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("E-mail")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.blackDayYP))
                        if let email = email, let url = URL(string: "mailto:\(email)") {
                            Link(email, destination: url)
                                .font(.system(size: 15))
                                .foregroundStyle(Color(.blueYP))
                        } else {
                            Text("—")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(.grayYP))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Телефон")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(.blackDayYP))
                        if let phone = phone {
                            let tel = phone.filter { !$0.isWhitespace }
                            if let url = URL(string: "tel:\(tel)") {
                                Link(phone, destination: url)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.blueYP))
                            } else {
                                Text(phone)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.grayYP))
                            }
                        } else {
                            Text("—")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(.grayYP))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
            }
        }
        .background(Color(.whiteDayYP))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if email == nil && (carrier.email != nil || carrier.contacts != nil) {
                let parsed = parseContacts(carrier.contacts)
                email = carrier.email ?? parsed.email
                phone = carrier.phone ?? parsed.phone
            }
        }
        .task(id: carrier.code) {
            await loadCarrierDetails()
        }
    }
    
    private func loadCarrierDetails() async {
        guard !detailsLoaded, let code = carrier.code else { return }
        detailsLoaded = true
        guard let serverURL = URL(string: "https://api.rasp.yandex.net") else {
                print("Invalid server URL")
                return
            }
            do {
                let client = Client(
                    serverURL: serverURL,
                    transport: URLSessionTransport()
                )
            let service = CarrierService(client: client)
            let response = try await service.getCarrierInfo(
                apikey: apikey,
                code: String(code),
                system: nil,
                lang: "ru_RU",
                format: "json"
            )
            if let carrier = response.carriers?.first {
                let parsed = parseContacts(carrier.contacts)
                let emailValue = carrier.email ?? parsed.email
                let phoneValue = carrier.phone ?? parsed.phone
                await MainActor.run {
                    email = emailValue
                    phone = phoneValue
                }
            }
        } catch {
        }
    }
    
    private func parseContacts(_ contacts: String?) -> (email: String?, phone: String?) {
        guard let contacts = contacts, !contacts.isEmpty else { return (nil, nil) }
        var emailFound: String?
        var phoneFound: String?
        let lines = contacts.components(separatedBy: CharacterSet.newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if emailFound == nil, let range = trimmed.range(of: "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}", options: [.regularExpression, .caseInsensitive]) {
                emailFound = String(trimmed[range])
            }
            if phoneFound == nil, let range = trimmed.range(of: "[+]?\\d[\\d ()-]{6,}\\d", options: .regularExpression) {
                phoneFound = String(trimmed[range])
            }
        }
        return (emailFound, phoneFound)
    }
}

struct CarrierInfoLogoView: View {
    let logoURLString: String?
    let title: String
    
    var body: some View {
        Group {
            if let urlString = logoURLString?.replacingOccurrences(of: "http://", with: "https://"),
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 343, height: 104)
                            .clipped()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 343, height: 104)
        .background(Color(.lightGrayYP))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var placeholderImage: some View {
        Image(.carrierIcon)
            .resizable()
            .scaledToFill()
            .frame(width: 343, height: 104)
            .clipped()
    }
}

#Preview {
    CarrierInfoView(
        carrier: CarrierInfo(title: "ОАО «РЖД»", logo: nil, code: 1, email: nil, phone: nil, url: nil, contacts: nil),
        onBack: {}
    )
}

