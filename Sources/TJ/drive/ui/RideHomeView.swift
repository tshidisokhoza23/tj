import SwiftUI
import MapKit

public struct RideHomeView: View {
    @StateObject private var viewModel = DriveViewModel()
    @EnvironmentObject private var router: NavigationRouter

    @State private var isSearchingView: Bool = false
    @State private var searchFromText: String = "Sandton City, Johannesburg"
    @State private var searchToText: String = ""
    @State private var step: Int = 0 // 0: Search, 1: Selection, 2: Tracking

    @State private var showDrawer: Bool = false
    @State private var activeSubScreen: RideSubScreen? = nil
    @State private var showScheduleSheet: Bool = false
    @State private var showSafetyCenter: Bool = false
    @State private var showDriverProfile: Bool = false
    @State private var showCancelDialog: Bool = false
    @State private var showRatingSheet: Bool = false
    @State private var selectedRating: Int = 0

    public init() {}

    enum RideSubScreen: String, Identifiable {
        case history, payment, savedPlaces, promotions, safety, support, settings
        var id: String { rawValue }
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background Map
                MapViewContainer(
                    coordinate: viewModel.pickupCoordinate,
                    destination: viewModel.selectedDestination,
                    driver: viewModel.assignedDriver,
                    nearbyDrivers: viewModel.nearbyDrivers
                )
                .ignoresSafeArea(edges: .all)

                // Top Floating Bar (Menu / Back / Safety)
                HStack {
                    Button(action: {
                        if step > 0 || isSearchingView {
                            if isSearchingView {
                                isSearchingView = false
                            } else {
                                step -= 1
                                if step == 0 { viewModel.selectDestination(nil) }
                            }
                        } else {
                            showDrawer = true
                        }
                    }) {
                        Image(systemName: (step > 0 || isSearchingView) ? "arrow.left" : "line.3.horizontal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Spacer()

                    if step == 0 && !isSearchingView {
                        Button(action: { showSafetyCenter = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "shield.fill")
                                    .foregroundColor(.blue)
                                Text("Safety")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Bottom Draggable Content Sheet
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        // Drag Indicator
                        Capsule()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 36, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 12)

                        if isSearchingView {
                            fullSearchPanel
                        } else if step == 0 {
                            compactSearchCard
                        } else if step == 1 {
                            rideSelectionPanel
                        } else if step == 2 {
                            liveTrackingPanel
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(28, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: -4)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDrawer) {
                RideDrawerSheet(
                    onSelectScreen: { screen in
                        showDrawer = false
                        activeSubScreen = screen
                    },
                    onSwitchToDriver: {
                        showDrawer = false
                        viewModel.toggleDriverMode(true)
                    }
                )
            }
            .sheet(item: $activeSubScreen) { sub in
                switch sub {
                case .history:
                    RideHistorySheet(trips: viewModel.trips)
                case .payment:
                    RidePaymentSheet(balance: viewModel.walletBalance)
                case .savedPlaces:
                    SavedPlacesSheet(destinations: viewModel.destinations) { dest in
                        activeSubScreen = nil
                        viewModel.selectDestination(dest)
                        step = 1
                    }
                case .promotions:
                    PromotionsSheet()
                case .safety:
                    SafetyCenterSheet()
                case .support:
                    SupportSheet()
                case .settings:
                    SettingsView(router: router)
                }
            }
            .sheet(isPresented: $showScheduleSheet) {
                ScheduleRideSheet { date, time in
                    showScheduleSheet = false
                }
                .presentationDetents([.height(320)])
            }
            .sheet(isPresented: $showSafetyCenter) {
                SafetyCenterSheet()
            }
            .sheet(isPresented: $showDriverProfile) {
                if let driver = viewModel.assignedDriver {
                    DriverProfileSheet(driver: driver)
                }
            }
            .sheet(isPresented: $showRatingSheet) {
                RatingSheet(
                    driverName: viewModel.assignedDriver?.name ?? "Driver",
                    onDismiss: {
                        showRatingSheet = false
                        step = 0
                        viewModel.selectDestination(nil)
                    }
                )
                .presentationDetents([.height(340)])
            }
            .alert("Cancel Ride?", isPresented: $showCancelDialog) {
                Button("Keep Ride", role: .cancel) {}
                Button("Cancel Ride", role: .destructive) {
                    viewModel.cancelRide(reason: "Rider cancelled")
                    step = 0
                }
            } message: {
                Text("Cancelling after a driver accepts keeps a R20 fee. Unused fares are fully refunded to your wallet.")
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewModel.completedTripSummary != nil },
                set: { if !$0 { viewModel.completedTripSummary = nil } }
            )) {
                if let summary = viewModel.completedTripSummary {
                    CompletedTripSummaryView(summary: summary) {
                        viewModel.completedTripSummary = nil
                        showRatingSheet = true
                    }
                }
            }
        }
    }

    // MARK: - Step 0: Compact Search Bar
    private var compactSearchCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { isSearchingView = true }) {
                HStack(spacing: 14) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)

                    Text("Where to?")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(18)
            }

            Text("Good day")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            RowQuickActionChips(
                onHomeClick: {
                    if let home = viewModel.destinations.first(where: { $0.type == "home" }) {
                        viewModel.selectDestination(home)
                        step = 1
                    } else {
                        isSearchingView = true
                    }
                },
                onWorkClick: {
                    if let work = viewModel.destinations.first(where: { $0.type == "work" }) {
                        viewModel.selectDestination(work)
                        step = 1
                    } else {
                        isSearchingView = true
                    }
                },
                onAddClick: { isSearchingView = true }
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - Step 0: Full Search Panel
    private var fullSearchPanel: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Plan your trip")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button(action: { isSearchingView = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    TextField("Pickup location", text: $searchFromText)
                        .font(.system(size: 15, weight: .medium))
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                HStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    TextField("Where to?", text: $searchToText)
                        .font(.system(size: 15, weight: .medium))
                        .onChange(of: searchToText) { newValue in
                            viewModel.searchPlaces(query: newValue)
                        }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.isSearchingAddress {
                        ProgressView("Searching addresses...")
                            .padding()
                    } else if !viewModel.suggestions.isEmpty {
                        ForEach(viewModel.suggestions) { suggestion in
                            DestinationRowItem(destination: suggestion) {
                                viewModel.selectDestination(suggestion)
                                isSearchingView = false
                                step = 1
                            }
                        }
                    } else {
                        Text("Recent Destinations")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)

                        ForEach(viewModel.destinations) { destination in
                            DestinationRowItem(destination: destination) {
                                viewModel.selectDestination(destination)
                                isSearchingView = false
                                step = 1
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 280)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - Step 1: Ride Selection Panel
    private var rideSelectionPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Choose a ride")
                        .font(.system(size: 22, weight: .bold))
                    if let dist = viewModel.routeDistance, let dur = viewModel.routeDuration {
                        Text("\(dist) • \(dur)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text("Personal")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Ride Option Preferences Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(viewModel.ridePreferences.keys), id: \.self) { pref in
                        let isSelected = viewModel.ridePreferences[pref] ?? false
                        Button(action: { viewModel.togglePreference(pref) }) {
                            Text(pref)
                                .font(.footnote)
                                .fontWeight(isSelected ? .bold : .medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(isSelected ? Color.blue.opacity(0.2) : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(isSelected ? .blue : .primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }

            // Ride Options List
            VStack(spacing: 10) {
                ForEach(viewModel.rideOptions) { option in
                    let isSelected = viewModel.selectedRide?.id == option.id
                    Button(action: { viewModel.selectedRide = option }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "car.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(option.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    Image(systemName: "person.fill")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("4")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Text(option.arrivalTime)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.blue)
                                Text(option.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(option.price)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(14)
                        .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }

            HStack(spacing: 12) {
                Button(action: { showScheduleSheet = true }) {
                    Image(systemName: "calendar")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .frame(width: 54, height: 54)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                }

                Button(action: {
                    viewModel.startBooking()
                    step = 2
                }) {
                    Text(viewModel.selectedRide != nil ? "Request \(viewModel.selectedRide!.title)" : "Select a ride")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - Step 2: Live Tracking Panel
    private var liveTrackingPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            ProgressView()
                .progressViewStyle(.linear)
                .tint(.blue)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 58, height: 58)
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(statusTitle(viewModel.bookingStatus))
                        .font(.system(size: 18, weight: .bold))

                    if let driver = viewModel.assignedDriver {
                        Text("\(driver.name) • \(driver.vehicleModel)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(driver.licensePlate)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Searching for nearby cars...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if viewModel.bookingStatus != .inProgress && viewModel.bookingStatus != .completed {
                    Button(action: { showCancelDialog = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
            }

            if let driver = viewModel.assignedDriver {
                HStack {
                    Spacer()
                    ActionButton(icon: "phone.fill", label: "Call") {
                        if let url = URL(string: "tel://112") { UIApplication.shared.open(url) }
                    }
                    Spacer()
                    ActionButton(icon: "video.fill", label: "Video") {}
                    Spacer()
                    ActionButton(icon: "bubble.left.fill", label: "Chat") {
                        router.navigate(to: .chatDetail(conversationId: driver.id, participantName: driver.name))
                    }
                    Spacer()
                    ActionButton(icon: "square.and.arrow.up", label: "Share") {}
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            if let pin = viewModel.safetyPin {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.blue)
                    Text("Verify with PIN: \(pin)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(14)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private func statusTitle(_ status: BookingStatus) -> String {
        switch status {
        case .searching: return "Finding your driver..."
        case .enRoute: return "Driver on the way"
        case .arrived: return "Driver has arrived"
        case .inProgress: return "Heading to destination"
        case .completed: return "Arrived at destination"
        case .none: return "Trip Cancelled"
        }
    }
}

// MARK: - Helper UI Subcomponents

struct MapViewContainer: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let destination: Destination?
    let driver: NearbyDriver?
    let nearbyDrivers: [NearbyDriver]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let pickupAnno = MKPointAnnotation()
        pickupAnno.coordinate = coordinate
        pickupAnno.title = "Pickup"
        uiView.addAnnotation(pickupAnno)

        if let dest = destination {
            let destAnno = MKPointAnnotation()
            destAnno.coordinate = CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)
            destAnno.title = dest.name
            uiView.addAnnotation(destAnno)
        }

        if let activeDriver = driver {
            let driverAnno = MKPointAnnotation()
            driverAnno.coordinate = activeDriver.coordinate
            driverAnno.title = activeDriver.name
            uiView.addAnnotation(driverAnno)
        }
    }
}

struct RowQuickActionChips: View {
    let onHomeClick: () -> Void
    let onWorkClick: () -> Void
    let onAddClick: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onHomeClick) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.blue)
                    Text("Home")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(14)
            }

            Button(action: onWorkClick) {
                HStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(.blue)
                    Text("Work")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(14)
            }

            Button(action: onAddClick) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
            }
        }
    }
}

struct DestinationRowItem: View {
    let destination: Destination
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: destination.name == "Home" ? "house.fill" : (destination.name == "Work" ? "briefcase.fill" : "mappin.and.ellipse"))
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(destination.address.isEmpty ? "Tap to select" : destination.address)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RideDrawerSheet: View {
    let onSelectScreen: (RideHomeView.RideSubScreen) -> Void
    let onSwitchToDriver: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: onSwitchToDriver) {
                        HStack {
                            Image(systemName: "car.side.fill")
                                .foregroundColor(.white)
                            Text("SWITCH TO DRIVE")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.teal)
                        .cornerRadius(12)
                    }
                }

                Section("Navigation") {
                    DrawerRow(icon: "clock.arrow.circlepath", title: "Trip history") { onSelectScreen(.history) }
                    DrawerRow(icon: "creditcard.fill", title: "Payment / Wallet") { onSelectScreen(.payment) }
                    DrawerRow(icon: "mappin.and.ellipse", title: "Saved places") { onSelectScreen(.savedPlaces) }
                    DrawerRow(icon: "tag.fill", title: "Promotions") { onSelectScreen(.promotions) }
                    DrawerRow(icon: "shield.fill", title: "Safety") { onSelectScreen(.safety) }
                    DrawerRow(icon: "questionmark.circle.fill", title: "Support") { onSelectScreen(.support) }
                    DrawerRow(icon: "gearshape.fill", title: "Settings") { onSelectScreen(.settings) }
                }
            }
            .navigationTitle("Ride Menu")
        }
    }
}

struct DrawerRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

struct RideHistorySheet: View {
    let trips: [Trip]
    var body: some View {
        NavigationStack {
            List(trips) { trip in
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.destinationAddress).font(.headline)
                    Text("From: \(trip.pickupAddress)").font(.caption).foregroundColor(.secondary)
                    HStack {
                        Text("R\(String(format: "%.2f", trip.fare))").font(.subheadline.bold())
                        Spacer()
                        Text(trip.status).font(.caption).foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Trip History")
        }
    }
}

struct RidePaymentSheet: View {
    let balance: Double
    var body: some View {
        NavigationStack {
            List {
                Section("Wallet Balance") {
                    HStack {
                        Text("Available")
                        Spacer()
                        Text("R\(String(format: "%.2f", balance))").font(.title2.bold()).foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Payment")
        }
    }
}

struct SavedPlacesSheet: View {
    let destinations: [Destination]
    let onSelect: (Destination) -> Void
    var body: some View {
        NavigationStack {
            List(destinations) { dest in
                Button(action: { onSelect(dest) }) {
                    VStack(alignment: .leading) {
                        Text(dest.name).font(.headline)
                        Text(dest.address).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Saved Places")
        }
    }
}

struct PromotionsSheet: View {
    var body: some View {
        NavigationStack {
            Text("No active promotions").foregroundColor(.secondary)
                .navigationTitle("Promotions")
        }
    }
}

struct SafetyCenterSheet: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Safety Tools") {
                    Label("Share Trip Status", systemImage: "square.and.arrow.up")
                    Label("Emergency Assistance (112)", systemImage: "phone.fill")
                    Label("Safety Support Team", systemImage: "shield.fill")
                }
            }
            .navigationTitle("Safety Center")
        }
    }
}

struct SupportSheet: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Frequently Asked Questions")
                Text("Report an Issue")
                Text("Contact Support")
            }
            .navigationTitle("Support")
        }
    }
}

struct ScheduleRideSheet: View {
    let onSchedule: (String, String) -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Schedule a Ride").font(.title2.bold()).padding(.top)
            Text("Select date & time for pickup").font(.subheadline).foregroundColor(.secondary)
            Button("Confirm Schedule") { onSchedule("Tomorrow", "10:00 AM") }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
            Spacer()
        }
    }
}

struct DriverProfileSheet: View {
    let driver: NearbyDriver
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
                .padding(.top)
            Text(driver.name).font(.title2.bold())
            Text("★ \(String(format: "%.1f", driver.rating)) • \(driver.vehicleModel)")
                .foregroundColor(.secondary)
            Text(driver.licensePlate).font(.headline)
            Spacer()
        }
    }
}

struct RatingSheet: View {
    let driverName: String
    let onDismiss: () -> Void
    @State private var rating: Int = 5

    var body: some View {
        VStack(spacing: 20) {
            Text("How was your trip with \(driverName)?")
                .font(.title3.bold())
                .padding(.top)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: { rating = star }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                    }
                }
            }

            Button("Submit Rating") { onDismiss() }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)

            Spacer()
        }
    }
}

struct CompletedTripSummaryView: View {
    let summary: TripSummary
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)
                .padding(.top, 40)

            Text("Trip Completed")
                .font(.title.bold())

            VStack(spacing: 12) {
                HStack {
                    Text("Total Fare")
                    Spacer()
                    Text("R\(String(format: "%.2f", summary.fare))").bold()
                }
                HStack {
                    Text("Distance")
                    Spacer()
                    Text(summary.distance)
                }
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(summary.duration)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            Button("Done", action: onDone)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
