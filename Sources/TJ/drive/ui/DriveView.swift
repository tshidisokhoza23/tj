import SwiftUI
import MapKit

public struct DriveView: View {
    @StateObject private var viewModel = DriveViewModel()
    @EnvironmentObject private var router: NavigationRouter

    @State private var currentTab: Int = 0 // 0: Map, 1: Stats
    @State private var showDrawer: Bool = false
    @State private var showVehicleSheet: Bool = false
    @State private var showDocUploadSheet: Bool = false
    @State private var pinInput: String = ""
    @State private var activeSubScreen: DriverSubScreen? = nil

    enum DriverSubScreen: String, Identifiable {
        case history, earnings, payout, documents, vehicle, safety, support, settings
        var id: String { rawValue }
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Custom Driver Top Bar
                    topBarHeader

                    if !viewModel.isDriverApproved {
                        unapprovedReviewView
                    } else if currentTab == 0 {
                        mapDashboardView
                    } else {
                        statsDashboardView
                    }
                }

                // Global Incoming Ride Request Overlay
                if viewModel.isDriverOnline && viewModel.incomingRideRequest != nil {
                    incomingRequestOverlay
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDrawer) {
                DriverDrawerSheet(
                    isDriverApproved: viewModel.isDriverApproved,
                    onSelectScreen: { sub in
                        showDrawer = false
                        activeSubScreen = sub
                    },
                    onSwitchToRide: {
                        showDrawer = false
                        viewModel.toggleDriverMode(false)
                    }
                )
            }
            .sheet(item: $activeSubScreen) { sub in
                switch sub {
                case .history:
                    RideHistorySheet(trips: viewModel.trips)
                case .earnings, .payout:
                    DriverEarningsSheet(earnings: viewModel.driverEarnings, balance: viewModel.walletBalance)
                case .documents:
                    DriverDocumentsSheet(documents: viewModel.driverDocuments)
                case .vehicle:
                    VehicleProfileSheet(info: viewModel.vehicleInfo) { updated in
                        viewModel.updateVehicleInfo(updated)
                    }
                case .safety:
                    SafetyCenterSheet()
                case .support:
                    SupportSheet()
                case .settings:
                    SettingsView(router: router)
                }
            }
            .sheet(isPresented: $showVehicleSheet) {
                VehicleProfileSheet(info: viewModel.vehicleInfo) { updated in
                    viewModel.updateVehicleInfo(updated)
                    showVehicleSheet = false
                }
            }
            .sheet(isPresented: $showDocUploadSheet) {
                DocumentUploadSheet {
                    showDocUploadSheet = false
                }
            }
        }
    }

    // MARK: - Driver Top Bar Header
    private var topBarHeader: some View {
        HStack {
            Button(action: { showDrawer = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("TJ Drive")
                    .font(.system(size: 18, weight: .bold))
                Text(viewModel.isDriverOnline ? "Receiving requests" : "Currently offline")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(viewModel.isDriverOnline ? .green : .secondary)
            }

            Spacer()

            if viewModel.isDriverApproved {
                Toggle("", isOn: Binding(
                    get: { viewModel.isDriverOnline },
                    set: { viewModel.setDriverOnlineStatus($0) }
                ))
                .labelsHidden()
                .tint(.green)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }

    // MARK: - Unapproved Account Review View
    private var unapprovedReviewView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                    .padding(.top, 30)

                Text("Account Under Review")
                    .font(.title2.bold())

                Text("Tap a document to upload a clear photo. TJ reviews it before you can go online.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    ForEach(viewModel.driverDocuments) { doc in
                        DriverDocRowItem(doc: doc) {
                            showDocUploadSheet = true
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: { showVehicleSheet = true }) {
                    HStack {
                        Image(systemName: "car.fill")
                        Text("Add Vehicle Details")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Map Dashboard View (currentTab == 0)
    private var mapDashboardView: some View {
        ZStack(alignment: .bottom) {
            MapViewContainer(
                coordinate: viewModel.pickupCoordinate,
                destination: viewModel.selectedDestination,
                driver: viewModel.assignedDriver,
                nearbyDrivers: viewModel.nearbyDrivers
            )
            .ignoresSafeArea(edges: .all)

            // Top Floating Demand Banner
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.areaPresence.clients) potential clients within 5 km")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("People with the app open nearby")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 4)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()
            }

            // Offline Overlay / Bottom Trip Control Bar
            if !viewModel.isDriverOnline {
                VStack(spacing: 16) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)

                    Text("You are offline")
                        .font(.title2.bold())

                    Text("Go online to receive rides. TJ keeps 20% of each fare.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("GO ONLINE") {
                        viewModel.setDriverOnlineStatus(true)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
                }
                .padding(24)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(24)
                .shadow(radius: 12)
                .padding(20)
            } else if viewModel.bookingStatus == .enRoute || viewModel.bookingStatus == .arrived || viewModel.bookingStatus == .inProgress {
                activeTripControlBar
            }

            // Bottom Navigation Bar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { currentTab = 0 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 20))
                            Text("Map").font(.caption.bold())
                        }
                        .foregroundColor(currentTab == 0 ? .blue : .secondary)
                    }
                    Spacer()
                    Button(action: { currentTab = 1 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                            Text("Stats").font(.caption.bold())
                        }
                        .foregroundColor(currentTab == 1 ? .blue : .secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 4)
            }
        }
    }

    // MARK: - Active Trip Driver Control Bar
    private var activeTripControlBar: some View {
        VStack(spacing: 14) {
            Text(tripStatusText(viewModel.bookingStatus))
                .font(.system(size: 16, weight: .bold))

            if viewModel.bookingStatus == .enRoute {
                Button("I HAVE ARRIVED") {
                    viewModel.markArrived()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(14)
            } else if viewModel.bookingStatus == .arrived {
                HStack {
                    TextField("Enter 4-Digit Passenger PIN", text: $pinInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button("Verify") {
                        if viewModel.verifySafetyPin(pinInput) {
                            pinInput = ""
                        }
                    }
                    .fontWeight(.bold)
                }
            } else if viewModel.bookingStatus == .inProgress {
                Button("COMPLETE TRIP") {
                    viewModel.completeTrip()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(14)
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 8)
        .padding(20)
    }

    private func tripStatusText(_ status: BookingStatus) -> String {
        switch status {
        case .enRoute: return "Head to pickup location"
        case .arrived: return "Ask passenger for 4-digit PIN"
        case .inProgress: return "Driving to destination..."
        default: return ""
        }
    }

    // MARK: - Stats Dashboard View (currentTab == 1)
    private var statsDashboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Vehicle Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Vehicle Profile").font(.headline.bold())
                        Spacer()
                        Button("Edit") { showVehicleSheet = true }
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                    }
                    Text("\(viewModel.vehicleInfo.make) \(viewModel.vehicleInfo.model) (\(viewModel.vehicleInfo.year))")
                        .font(.subheadline)
                    Text(viewModel.vehicleInfo.plateNumber)
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)

                // Performance Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    StatTile(title: "Total Trips", value: "\(viewModel.driverStats.totalTrips)", icon: "car.fill")
                    StatTile(title: "Rating", value: "4.9 ★", icon: "star.fill")
                    StatTile(title: "Acceptance", value: "\(Int(viewModel.driverStats.acceptanceRate))%", icon: "checkmark.circle.fill")
                    StatTile(title: "Online Hours", value: "\(String(format: "%.1f", viewModel.driverStats.onlineHours))h", icon: "clock.fill")
                }

                // Earnings Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Earnings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("R\(String(format: "%.2f", viewModel.driverEarnings))")
                            .font(.title.bold())
                            .foregroundColor(.blue)
                        Spacer()
                        Text("Pays Mondays 06:00")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)

                // Documents List
                VStack(alignment: .leading, spacing: 10) {
                    Text("My Documents").font(.headline.bold())
                    ForEach(viewModel.driverDocuments) { doc in
                        DriverDocRowItem(doc: doc) { showDocUploadSheet = true }
                    }
                }

                Spacer(minLength: 80)
            }
            .padding()
        }
    }

    // MARK: - Incoming Ride Request Card Overlay
    private var incomingRequestOverlay: some View {
        VStack {
            Spacer()
            if let req = viewModel.incomingRideRequest {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("New Ride Request").font(.caption.bold()).foregroundColor(.blue)
                            Text(req.passengerName).font(.title2.bold())
                        }
                        Spacer()
                        Text("★ 4.9").font(.headline.bold()).foregroundColor(.orange)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label(req.pickupAddress, systemImage: "circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Label(req.destinationAddress, systemImage: "square.fill")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text(req.distance).foregroundColor(.secondary)
                        Spacer()
                        Text("R\(String(format: "%.2f", req.fare))").font(.title.bold())
                    }

                    HStack(spacing: 14) {
                        Button("Decline") {
                            viewModel.declineRideRequest()
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)

                        Button("Accept") {
                            viewModel.acceptRideRequest()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(14)
                    }
                }
                .padding(24)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(24)
                .shadow(radius: 16)
                .padding(20)
            }
        }
    }
}

// MARK: - Driver Dashboard Subviews

struct StatTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct DriverDocRowItem: View {
    let doc: DriverDocument
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(doc.type).font(.subheadline.bold()).foregroundColor(.primary)
                    Text("Tap to upload clear photo").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text(doc.status)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(doc.status == "APPROVED" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .foregroundColor(doc.status == "APPROVED" ? .green : .orange)
                    .cornerRadius(6)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

struct DriverDrawerSheet: View {
    let isDriverApproved: Bool
    let onSelectScreen: (DriveView.DriverSubScreen) -> Void
    let onSwitchToRide: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: onSwitchToRide) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            Text("SWITCH TO RIDE")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }

                Section("Driver Menu") {
                    DrawerRow(icon: "clock.arrow.circlepath", title: "Trip history") { onSelectScreen(.history) }
                    DrawerRow(icon: "dollarsign.circle.fill", title: "Earnings") { onSelectScreen(.earnings) }
                    DrawerRow(icon: "building.columns.fill", title: "Payout methods") { onSelectScreen(.payout) }
                    DrawerRow(icon: "doc.text.fill", title: "Documents") { onSelectScreen(.documents) }
                    DrawerRow(icon: "car.fill", title: "Vehicle profile") { onSelectScreen(.vehicle) }
                    DrawerRow(icon: "shield.fill", title: "Safety") { onSelectScreen(.safety) }
                    DrawerRow(icon: "questionmark.circle.fill", title: "Support") { onSelectScreen(.support) }
                    DrawerRow(icon: "gearshape.fill", title: "Settings") { onSelectScreen(.settings) }
                }
            }
            .navigationTitle("Driver Menu")
        }
    }
}

struct VehicleProfileSheet: View {
    let info: VehicleInfo
    let onSave: (VehicleInfo) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var make: String
    @State private var model: String
    @State private var year: String
    @State private var plate: String
    @State private var color: String

    init(info: VehicleInfo, onSave: @escaping (VehicleInfo) -> Void) {
        self.info = info
        self.onSave = onSave
        _make = State(initialValue: info.make)
        _model = State(initialValue: info.model)
        _year = State(initialValue: info.year)
        _plate = State(initialValue: info.plateNumber)
        _color = State(initialValue: info.color)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Details") {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year)
                    TextField("Color", text: $color)
                    TextField("License Plate", text: $plate)
                }
            }
            .navigationTitle("Vehicle Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(VehicleInfo(make: make, model: model, year: year, plateNumber: plate, color: color))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DocumentUploadSheet: View {
    let onUpload: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Document").font(.title2.bold()).padding(.top)
            Text("Select photo from device storage").font(.subheadline).foregroundColor(.secondary)
            Button("Choose Photo") {
                onUpload()
                dismiss()
            }
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

struct DriverEarningsSheet: View {
    let earnings: Double
    let balance: Double

    var body: some View {
        NavigationStack {
            List {
                Section("Weekly Total") {
                    HStack {
                        Text("Earnings")
                        Spacer()
                        Text("R\(String(format: "%.2f", earnings))").font(.title2.bold()).foregroundColor(.blue)
                    }
                }
                Section("Wallet Balance") {
                    HStack {
                        Text("Available")
                        Spacer()
                        Text("R\(String(format: "%.2f", balance))").bold()
                    }
                }
            }
            .navigationTitle("Earnings & Wallet")
        }
    }
}

struct DriverDocumentsSheet: View {
    let documents: [DriverDocument]
    var body: some View {
        NavigationStack {
            List(documents) { doc in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(doc.type).font(.headline)
                        Spacer()
                        Text(doc.status)
                            .font(.caption.bold())
                            .foregroundColor(doc.status == "APPROVED" ? .green : (doc.status == "REJECTED" ? .red : .orange))
                    }
                    if doc.status == "REJECTED", let reason = doc.rejectionReason, !reason.isEmpty {
                        Text("Reason: \(reason)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Documents")
        }
    }
}
