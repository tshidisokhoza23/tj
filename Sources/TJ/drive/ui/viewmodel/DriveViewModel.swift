import Foundation
import Combine
import CoreLocation
import SwiftUI

public enum BookingStatus: String, Codable {
    case none = "NONE"
    case searching = "SEARCHING"
    case enRoute = "EN_ROUTE"
    case arrived = "ARRIVED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
}

public struct NearbyDriver: Identifiable, Equatable {
    public let id: String
    public var coordinate: CLLocationCoordinate2D
    public var rotation: Double
    public var name: String
    public var rating: Double
    public var vehicleModel: String
    public var vehicleColor: String
    public var licensePlate: String
    public var photoUrls: [String]
    public var profilePhoto: String

    public static func == (lhs: NearbyDriver, rhs: NearbyDriver) -> Bool {
        return lhs.id == rhs.id
    }

    public init(
        id: String,
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -26.1076, longitude: 28.0567),
        rotation: Double = 0.0,
        name: String = "Mpho",
        rating: Double = 4.9,
        vehicleModel: String = "Toyota Corolla",
        vehicleColor: String = "White",
        licensePlate: String = "GP 123 456",
        photoUrls: [String] = [],
        profilePhoto: String = ""
    ) {
        self.id = id
        self.coordinate = coordinate
        self.rotation = rotation
        self.name = name
        self.rating = rating
        self.vehicleModel = vehicleModel
        self.vehicleColor = vehicleColor
        self.licensePlate = licensePlate
        self.photoUrls = photoUrls
        self.profilePhoto = profilePhoto
    }
}

public struct TripSummary: Equatable {
    public let fare: Double
    public let distance: String
    public let duration: String
    public let date: String
    public let passengerName: String
    public let paymentMethod: String
    public let platformFee: Double
    public let driverEarning: Double

    public init(
        fare: Double,
        distance: String,
        duration: String,
        date: String = "Today, 14:20",
        passengerName: String = "Passenger",
        paymentMethod: String = "Wallet",
        platformFee: Double = 0.0,
        driverEarning: Double = 0.0
    ) {
        self.fare = fare
        self.distance = distance
        self.duration = duration
        self.date = date
        self.passengerName = passengerName
        self.paymentMethod = paymentMethod
        self.platformFee = platformFee
        self.driverEarning = driverEarning
    }
}

public struct DriverStats: Equatable {
    public var totalTrips: Int = 24
    public var onlineHours: Double = 32.5
    public var acceptanceRate: Double = 98.0
    public var weeklyEarnings: Double = 1850.0

    public init(totalTrips: Int = 24, onlineHours: Double = 32.5, acceptanceRate: Double = 98.0, weeklyEarnings: Double = 1850.0) {
        self.totalTrips = totalTrips
        self.onlineHours = onlineHours
        self.acceptanceRate = acceptanceRate
        self.weeklyEarnings = weeklyEarnings
    }
}

public struct AreaPresence: Equatable {
    public var clients: Int = 12
    public var radiusKm: Double = 5.0
    public init(clients: Int = 12, radiusKm: Double = 5.0) {
        self.clients = clients
        self.radiusKm = radiusKm
    }
}

@MainActor
public final class DriveViewModel: ObservableObject {
    @Published public var pickupCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -26.1076, longitude: 28.0567)
    @Published public var pickupAddress: String = "Sandton City, Johannesburg"
    @Published public var selectedDestination: Destination? = nil
    @Published public var additionalStops: [Destination] = []

    @Published public var destinations: [Destination] = []
    @Published public var trips: [Trip] = []
    @Published public var suggestions: [Destination] = []
    @Published public var isSearchingAddress: Bool = false

    @Published public var rideOptions: [RideOption] = []
    @Published public var selectedRide: RideOption? = nil
    @Published public var routeDistance: String? = nil
    @Published public var routeDuration: String? = nil

    @Published public var bookingStatus: BookingStatus = .none
    @Published public var assignedDriver: NearbyDriver? = nil
    @Published public var nearbyDrivers: [NearbyDriver] = [
        NearbyDriver(id: "d1", coordinate: CLLocationCoordinate2D(latitude: -26.105, longitude: 28.058), name: "Mpho", rating: 4.9, vehicleModel: "Toyota Quest", licensePlate: "TJ 88 GP"),
        NearbyDriver(id: "d2", coordinate: CLLocationCoordinate2D(latitude: -26.110, longitude: 28.052), name: "Sipho", rating: 4.8, vehicleModel: "VW Polo", licensePlate: "TJ 99 GP")
    ]
    @Published public var safetyPin: String? = nil
    @Published public var remainingTime: String? = nil
    @Published public var completedTripSummary: TripSummary? = nil

    @Published public var ridePreferences: [String: Bool] = [
        "Quiet trip": false,
        "Cool aircon": false,
        "Extra luggage": false
    ]

    // Driver Side State
    @Published public var isDriverMode: Bool = false
    @Published public var isDriverOnline: Bool = false
    @Published public var isDriverApproved: Bool = true
    @Published public var driverDocuments: [DriverDocument] = [
        DriverDocument(id: "doc1", type: "ID Document", status: "APPROVED", url: ""),
        DriverDocument(id: "doc2", type: "Driver's License", status: "APPROVED", url: ""),
        DriverDocument(id: "doc3", type: "Professional Permit (PrDP)", status: "APPROVED", url: ""),
        DriverDocument(id: "doc4", type: "Vehicle Licence Disc", status: "APPROVED", url: ""),
        DriverDocument(id: "doc5", type: "Roadworthy Certificate", status: "APPROVED", url: "")
    ]
    @Published public var vehicleInfo: VehicleInfo = VehicleInfo(make: "Toyota", model: "Corolla", year: "2023", plateNumber: "TJ 123 GP", color: "White")
    @Published public var driverStats: DriverStats = DriverStats()
    @Published public var driverEarnings: Double = 1850.0
    @Published public var walletBalance: Double = 450.0
    @Published public var areaPresence: AreaPresence = AreaPresence()
    @Published public var incomingRideRequest: RideRequest? = nil
    @Published public var actionError: String? = nil
    @Published public var activeRideId: String? = nil

    private let repo = DriveRepository.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        fetchInitialData()
    }

    public func fetchInitialData() {
        Task {
            if let dests = try? await repo.getDestinations() {
                self.destinations = dests
            }
            if let tripsList = try? await repo.getTrips() {
                self.trips = tripsList
            }
            if let options = try? await repo.getRideOptions(), !options.isEmpty {
                self.rideOptions = options
            } else {
                self.rideOptions = defaultRideCatalog()
            }
            if let docs = try? await repo.getDriverDocuments() {
                self.driverDocuments = docs
            }
            if let veh = try? await repo.getVehicleInfo() {
                self.vehicleInfo = veh
            }
        }
    }

    public func defaultRideCatalog() -> [RideOption] {
        [
            RideOption(id: "1", title: "TJ Go", price: "R85.00", arrivalTime: "3 min", description: "Standard compact rides", iconColorHex: "#4CAF50"),
            RideOption(id: "2", title: "TJ Comfort", price: "R120.00", arrivalTime: "5 min", description: "Newer cars with extra room", iconColorHex: "#2196F3"),
            RideOption(id: "3", title: "TJ Premium", price: "R180.00", arrivalTime: "7 min", description: "Top rated luxury drivers", iconColorHex: "#9C27B0"),
            RideOption(id: "4", title: "TJ XL", price: "R150.00", arrivalTime: "6 min", description: "Spacious SUVs up to 6 people", iconColorHex: "#FF9800")
        ]
    }

    public func searchPlaces(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            suggestions = []
            return
        }
        isSearchingAddress = true
        let sampleResults = [
            Destination(name: "\(query) Station", address: "\(query) Way, Johannesburg", latitude: -26.108, longitude: 28.057, type: "recent"),
            Destination(name: "\(query) Mall", address: "Main Road, Sandton", latitude: -26.102, longitude: 28.061, type: "recent"),
            Destination(name: "Rosebank Center (\(query))", address: "Oxford Rd, Rosebank", latitude: -26.145, longitude: 28.044, type: "recent")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.suggestions = sampleResults
            self.isSearchingAddress = false
        }
    }

    public func selectDestination(_ dest: Destination?) {
        self.selectedDestination = dest
        if let dest {
            self.routeDistance = "8.4 km"
            self.routeDuration = "12 min"
            self.selectedRide = rideOptions.first
            saveDestinationToHistory(dest)
        } else {
            self.routeDistance = nil
            self.routeDuration = nil
            self.selectedRide = nil
        }
    }

    public func saveDestinationToHistory(_ dest: Destination) {
        Task {
            _ = try? await repo.saveDestination(name: dest.name, address: dest.address, latitude: dest.latitude, longitude: dest.longitude, isFavorite: dest.isFavorite, type: dest.type)
        }
    }

    public func togglePreference(_ pref: String) {
        ridePreferences[pref] = !(ridePreferences[pref] ?? false)
    }

    public func startBooking() {
        guard let dest = selectedDestination else { return }
        bookingStatus = .searching
        safetyPin = String(format: "%04d", Int.random(in: 1000...9999))
        remainingTime = "Finding driver..."

        Task {
            let rideType = selectedRide?.title ?? "TJ Go"
            if let id = try? await repo.createRideRequest(
                pickup: pickupAddress,
                dest: dest.address.isEmpty ? dest.name : dest.address,
                pLat: pickupCoordinate.latitude,
                pLng: pickupCoordinate.longitude,
                dLat: dest.latitude,
                dLng: dest.longitude,
                fare: 85.0,
                distance: routeDistance ?? "8.4 km",
                type: rideType
            ) {
                self.activeRideId = id
            }

            // Simulate Driver Accepting
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if bookingStatus == .searching {
                assignedDriver = nearbyDrivers.first ?? NearbyDriver(id: "d1", name: "Mpho", rating: 4.9)
                bookingStatus = .enRoute
                remainingTime = "4 min"
            }
        }
    }

    public func toggleDriverMode(_ enabled: Bool) {
        if bookingStatus != .none && bookingStatus != .completed { return }
        isDriverMode = enabled
        if !enabled && isDriverOnline {
            setDriverOnlineStatus(false)
        }
    }

    public func setDriverOnlineStatus(_ online: Bool) {
        isDriverOnline = online
        Task {
            _ = try? await repo.updateOnlineStatus(online: online, latitude: pickupCoordinate.latitude, longitude: pickupCoordinate.longitude)
            if online {
                // Simulate incoming ride request after delay
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                if isDriverOnline && incomingRideRequest == nil {
                    incomingRideRequest = RideRequest(
                        id = UUID().uuidString,
                        passengerName = "Thabo M.",
                        pickupAddress = "Nelson Mandela Square",
                        destinationAddress = "OR Tambo Airport",
                        fare: 220.0,
                        distance = "24.5 km"
                    )
                }
            } else {
                incomingRideRequest = nil
            }
        }
    }

    public func acceptRideRequest() {
        guard let req = incomingRideRequest else { return }
        activeRideId = req.id
        bookingStatus = .enRoute
        incomingRideRequest = nil
        remainingTime = "5 min"
        Task {
            _ = try? await repo.updateRideStatus(rideId: req.id, status: "ACCEPTED")
        }
    }

    public func declineRideRequest() {
        incomingRideRequest = nil
    }

    public func markArrived() {
        bookingStatus = .arrived
        remainingTime = "Arrived"
        if let id = activeRideId {
            Task { _ = try? await repo.updateRideStatus(rideId: id, status: "ARRIVED") }
        }
    }

    public func verifySafetyPin(_ pin: String) -> Bool {
        bookingStatus = .inProgress
        remainingTime = "12 min"
        if let id = activeRideId {
            Task { _ = try? await repo.updateRideStatus(rideId: id, status: "STARTED") }
        }
        return true
    }

    public func completeTrip() {
        let fare = 120.0
        let fee = fare * 0.20
        completedTripSummary = TripSummary(
            fare: fare,
            distance: routeDistance ?? "12 km",
            duration: "15 min",
            passengerName: "Passenger",
            platformFee: fee,
            driverEarning: fare - fee
        )
        bookingStatus = .completed
        if let id = activeRideId {
            Task { _ = try? await repo.updateRideStatus(rideId: id, status: "COMPLETED") }
        }
        activeRideId = nil
    }

    public func cancelRide(reason: String = "User cancelled") {
        if let id = activeRideId {
            Task { _ = try? await repo.cancelRide(rideId: id, reason: reason, by: isDriverMode ? "driver" : "rider") }
        }
        bookingStatus = .none
        assignedDriver = nil
        activeRideId = nil
        selectedDestination = nil
        routeDistance = nil
        routeDuration = nil
    }

    public func updateVehicleInfo(_ info: VehicleInfo) {
        self.vehicleInfo = info
        Task { _ = try? await repo.updateVehicleInfo(vehicle: info) }
    }
}
