# Implementation

  Detailed implementation examples and code patterns used in the Arca app.

  ## Overview

  This guide provides specific implementation details, code examples, and
  best practices for key features in the Arca codebase.

  ## Core Data Implementation

  ### Statue Model

  The primary data model for statue information:
```swift
  @Model
  final class StatueModel {
      @Attribute(.unique) var id: UUID
      var name: String
      var culturalName: String?
      var latitude: Double
      var longitude: Double
      var category: StatueCategory
      var culturalDescription: String
      var historicalPeriod: String?
      var sculptor: String?
      var constructionYear: Int?
      var materials: [String]
      var dimensions: StatueDimensions
      var isBookmarked: Bool = false

      init(name: String, latitude: Double, longitude: Double, category:
      StatueCategory) {
          self.id = UUID()
          self.name = name
          self.latitude = latitude
          self.longitude = longitude
          self.category = category
          self.materials = []
          self.dimensions = StatueDimensions()
      }
    }
```

  ### Category Enumeration

  Defines the two main types of statues in Balinese culture:

```swift
  enum StatueCategory: String, CaseIterable, Codable {
      case ritual = "ritual"
      case monumental = "monumental"

      var displayName: String {
          switch self {
          case .ritual:
              return "Sacred Ritual"
          case .monumental:
              return "Historical Monument"
          }
      }
  }
```

  ## Location Manager Implementation

  ### Core Location Setup

  Handles GPS tracking and proximity detection:

```swift
  @Observable
  final class LocationManager: NSObject, CLLocationManagerDelegate {
      private let manager = CLLocationManager()
      private let geofenceRadius: CLLocationDistance = 50.0

  var currentLocation: CLLocation?
  var nearbyStatues: [StatueModel] = []
  var isLocationAuthorized = false

  override init() {
      super.init()
      manager.delegate = self
      manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      manager.distanceFilter = 10.0
  }

  func requestLocationPermission() {
      manager.requestWhenInUseAuthorization()
  }

  func startLocationUpdates() {
      guard isLocationAuthorized else { return }
      manager.startUpdatingLocation()
  }
  }
```

  ## Audio Tour Implementation

  ### Audio Engine Setup

  Handles background-compatible audio playback:

```swift
  @Observable
  final class AudioTourManager: NSObject, AVAudioPlayerDelegate {
      private var audioEngine = AVAudioEngine()
      private var playerNode = AVAudioPlayerNode()
      private var mixer = AVAudioMixerNode()

  var isPlaying = false
  var currentStatue: StatueModel?
  var volume: Float = 0.8

  override init() {
      super.init()
      setupAudioEngine()
      setupAudioSession()
  }

  private func setupAudioEngine() {
      audioEngine.attach(playerNode)
      audioEngine.attach(mixer)

      audioEngine.connect(playerNode, to: mixer, format: nil)
      audioEngine.connect(mixer, to: audioEngine.outputNode, format: nil)

      do {
          try audioEngine.start()
      } catch {
          print("Failed to start audio engine: \(error)")
      }
  }
  }
```

  ### Audio Session Configuration

  Enables background playback and music app compatibility:

```swift
  extension AudioTourManager {
      private func setupAudioSession() {
          do {
              try AVAudioSession.sharedInstance().setCategory(
                  .playback,
                  mode: .spokenAudio,
                  options: [.duckOthers, .allowBluetooth]
              )
              try AVAudioSession.sharedInstance().setActive(true)
          } catch {
              print("Failed to setup audio session: error)")
          }
      }

  func playNarration(for statue: StatueModel) {
      guard let audioURL = audioURL(for: statue) else { return }

      do {
          let audioFile = try AVAudioFile(forReading: audioURL)
          playerNode.scheduleFile(audioFile, at: nil) { [weak self] in
              DispatchQueue.main.async {
                  self?.isPlaying = false
                  self?.currentStatue = nil
              }
          }

          if !audioEngine.isRunning {
              try audioEngine.start()
          }

          playerNode.play()
          isPlaying = true
          currentStatue = statue

      } catch {
          print("Failed to play audio: \(error)")
      }
  }
  }
```

  ## SwiftUI Views

  ### Map View Implementation

  Main interface combining map display with statue annotations:

```swift
  struct MapView: View {
      @State private var locationManager = LocationManager()
      @State private var audioManager = AudioTourManager()
      @State private var viewModel = MapViewModel()

  var body: some View {
      NavigationStack {
          ZStack {
              Map(coordinateRegion: $viewModel.region,
                  annotationItems: viewModel.statues) { statue in
                  MapAnnotation(coordinate: CLLocationCoordinate2D(
                      latitude: statue.latitude,
                      longitude: statue.longitude
                  )) {
                      StatueMarker(
                          statue: statue,
                          isSelected: viewModel.selectedStatue == statue
                      )
                      .onTapGesture {
                          viewModel.selectStatue(statue)
                      }
                  }
              }
              .onAppear {
                  locationManager.requestLocationPermission()
                  locationManager.startLocationUpdates()
              }

              VStack {
                  Spacer()

                  if let selectedStatue = viewModel.selectedStatue {
                      StatueDetailCard(statue: selectedStatue)
                          .transition(.move(edge: .bottom))
                  }

                  HStack {
                      Spacer()
                      AudioTourButton(isActive: audioManager.isPlaying) {
                          if audioManager.isPlaying {
                              audioManager.stopTour()
                          } else {
                              audioManager.startTour()
                          }
                      }
                  }
                  .padding()
              }
          }
      }
  }
  }
```

  ### Statue Detail Card

  Displays statue information with cultural context:

```swift
  struct StatueDetailCard: View {
      let statue: StatueModel
      @State private var isBookmarked = false

  var body: some View {
      VStack(alignment: .leading, spacing: 12) {
          HStack {
              VStack(alignment: .leading) {
                  Text(statue.name)
                      .font(.headline)

                  if let culturalName = statue.culturalName {
                      Text(culturalName)
                          .font(.subheadline)
                          .foregroundStyle(.secondary)
                  }
              }

              Spacer()

              Button(action: toggleBookmark) {
                  Image(systemName: isBookmarked ? "star.fill" : "star")
                      .foregroundColor(isBookmarked ? .yellow : .gray)
              }
          }

          Text(statue.culturalDescription)
              .font(.body)
              .lineLimit(3)

          HStack {
              CategoryBadge(category: statue.category)
              Spacer()
              NavigationLink("Learn More") {
                  StatueDetailView(statue: statue)
              }
              .buttonStyle(.borderedProminent)
          }
      }
      .padding()
      .background(.regularMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .onAppear {
          isBookmarked = statue.isBookmarked
      }
  }

  private func toggleBookmark() {
      isBookmarked.toggle()
      // Update bookmark status in Core Data
      BookmarkService.shared.toggleBookmark(for: statue)
  }
  }
```

  ## Related Topics
  - <doc:TechnicalOverview> - High-level architecture overview
  - ``StatueModel`` - Core data model reference
  - ``LocationManager`` - Location services API
  - ``AudioManager`` - Audio system reference
