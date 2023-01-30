import Foundation

struct MusicTracksResponse: Decodable {

    private struct DecodableMusicTrack: Decodable {

        // MARK: - Type Definitions

        enum CodingKey: String, Swift.CodingKey {
            case artistName
            case trackName
            case previewUrl
        }

        // MARK: - Properties

        fileprivate let name: String
        fileprivate let artist: String
        fileprivate let previewURL: URL

        // MARK: - Init

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKey.self)
            self.name = try container.decode(String.self, forKey: .trackName)
            self.artist = try container.decode(String.self, forKey: .artistName)
            self.previewURL = try container.decode(URL.self, forKey: .previewUrl)
        }

    }

    private let results: [DecodableMusicTrack]
    private let resultCount: Int

    func getMusicTracks() -> [MusicTrack] {
        self.results.enumerated().map {
            MusicTrack(
                name: $0.element.name,
                artist: $0.element.artist,
                previewURL: $0.element.previewURL,
                index: $0.offset
            )
        }
    }
}
