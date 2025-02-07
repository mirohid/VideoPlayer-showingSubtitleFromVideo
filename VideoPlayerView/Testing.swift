import SwiftUI
import AVKit
import AVFoundation

struct Testing: View {
    @State private var subtitles: [String] = []  // List of subtitles to display
    @State private var player: AVPlayer?
    @State private var currentSubtitle: String = ""  // The currently displayed subtitle
    @State private var timeObserverToken: Any?  // Add this line
    @State private var subtitleItems: [SubtitleItem] = []  // Add this line
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 300)
            } else {
                Text("Loading video...")
            }
            
            Text(currentSubtitle)  // Display the current subtitle
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding()
        }
        .onAppear {
            loadVideoAndSubtitles()
        }
        .onDisappear {
            // Remove the time observer when the view disappears
            if let timeObserverToken = timeObserverToken {
                player?.removeTimeObserver(timeObserverToken)
                self.timeObserverToken = nil
            }
        }
    }
    
    private func loadVideoAndSubtitles() {
        guard let videoURL = Bundle.main.url(forResource: "myvideo", withExtension: "mp4") else {
            print("Video not found")
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Set up subtitle output
        let legibleOutput = AVPlayerItemLegibleOutput()
        legibleOutput.suppressesPlayerRendering = true  // We'll handle the rendering
        playerItem.add(legibleOutput)
        
        // Add a delegate to capture subtitle events
        let delegate = SubtitleDelegate(subtitles: $subtitles, currentSubtitle: $currentSubtitle)
        legibleOutput.setDelegate(delegate, queue: .main)
        
        // Try to enable closed captions if available
        if let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let locales = AVMediaSelectionGroup.playableMediaSelectionOptions(from: group.options)
            if let englishOption = locales.first(where: { $0.extendedLanguageTag?.contains("en") ?? false }) {
                playerItem.select(englishOption, in: group)
                print("Selected subtitle track: \(englishOption.displayName)")
            } else if let firstOption = locales.first {
                playerItem.select(firstOption, in: group)
                print("Selected subtitle track: \(firstOption.displayName)")
            }
        }
        
        // Add time observer for continuous playback monitoring
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak player] time in
            // You can add time-based subtitle updates here if needed
        }
    }
    
    private func loadSubtitles(from asset: AVAsset, playerItem: AVPlayerItem) {
        guard let subtitleTracks = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            print("No subtitles found in the asset")
            return
        }
        
        print("Found \(subtitleTracks.options.count) subtitle tracks")
        
        for option in subtitleTracks.options {
            print("Subtitle option: \(option.displayName), locale: \(option.locale?.identifier ?? "unknown")")
            if option.mediaType == .subtitle {
                playerItem.select(option, in: subtitleTracks)
                print("Selected subtitle track: \(option.displayName)")
            }
        }
    }
    
    private func loadExternalSubtitles(from url: URL) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            subtitleItems = parseSRT(content)
            print("Successfully loaded \(subtitleItems.count) subtitle items")
            // Print first subtitle for verification
            if let first = subtitleItems.first {
                print("First subtitle: \(first.text) (starts at \(first.startTime)s)")
            }
        } catch {
            print("Error loading subtitles: \(error)")
        }
    }
    
    private func updateCurrentSubtitle(at time: Double) {
        for item in subtitleItems {
            if time >= item.startTime && time <= item.endTime {
                currentSubtitle = item.text
                return
            }
        }
        currentSubtitle = ""  // Clear subtitle if no matching time found
    }
    
    private func parseSRT(_ content: String) -> [SubtitleItem] {
        var items: [SubtitleItem] = []
        let blocks = content.components(separatedBy: "\n\n")
        
        for block in blocks {
            let lines = block.components(separatedBy: "\n")
            guard lines.count >= 3 else { continue }
            
            // Parse time line (format: 00:00:00,000 --> 00:00:00,000)
            let timeLine = lines[1]
            let timeComponents = timeLine.components(separatedBy: " --> ")
            guard timeComponents.count == 2 else { continue }
            
            let startTime = parseTime(timeComponents[0])
            let endTime = parseTime(timeComponents[1])
            
            // Combine remaining lines as subtitle text
            let text = lines[2...].joined(separator: "\n")
            
            items.append(SubtitleItem(startTime: startTime, endTime: endTime, text: text))
        }
        
        return items
    }
    
    private func parseTime(_ timeString: String) -> Double {
        let components = timeString.replacingOccurrences(of: ",", with: ".")
            .split(separator: ":")
        guard components.count == 3,
              let hours = Double(components[0]),
              let minutes = Double(components[1]),
              let seconds = Double(components[2]) else {
            return 0
        }
        
        return hours * 3600 + minutes * 60 + seconds
    }
    
    // Debugging function to list all media tracks
    private func debugSubtitleTracks(from asset: AVAsset) {
        let mediaTracks = asset.tracks
        for track in mediaTracks {
            print("Track: \(track.mediaType.rawValue), Language: \(track.languageCode ?? "Unknown")")
        }
        
        // Check for subtitle tracks
        guard let subtitleTracks = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            print("No subtitle tracks found in the asset.")
            return
        }
        
        for option in subtitleTracks.options {
            print("Subtitle track available: \(option.displayName), Language: \(option.locale?.identifier ?? "Unknown")")
        }
    }
}

// Delegate for handling subtitle output from the video player
class SubtitleDelegate: NSObject, AVPlayerItemLegibleOutputPushDelegate {
    @Binding var subtitles: [String]
    @Binding var currentSubtitle: String
    
    init(subtitles: Binding<[String]>, currentSubtitle: Binding<String>) {
        _subtitles = subtitles
        _currentSubtitle = currentSubtitle
    }

    // Delegate method for handling subtitles
    func legibleOutput(_ output: AVPlayerItemLegibleOutput, didOutputAttributedStrings strings: [NSAttributedString], forItemTime time: CMTime) {
        DispatchQueue.main.async {
            if let subtitle = strings.first?.string {
                self.currentSubtitle = subtitle
                self.subtitles.append(subtitle)
                print("Current subtitle at \(time.seconds): \(subtitle)")
            } else {
                self.currentSubtitle = ""
            }
        }
    }
    
    // Add this required method
    func legibleOutput(_ output: AVPlayerItemLegibleOutput, didOutputAttributedStrings strings: [NSAttributedString], nativeSampleBuffers: [Any], forItemTime time: CMTime) {
        legibleOutput(output, didOutputAttributedStrings: strings, forItemTime: time)
    }
}

struct Testing_Previews: PreviewProvider {
    static var previews: some View {
        Testing()
    }
}

struct SubtitleItem {
    let startTime: Double  // in seconds
    let endTime: Double    // in seconds
    let text: String
}
