//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	private static var OK_200: Int { return 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, httpURLResponse)):

				guard httpURLResponse.statusCode == RemoteFeedLoader.OK_200, let value = try? JSONDecoder().decode(RemoteFeedItem.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				let feedImageList = value.items.map { $0.feedImageItem }
				completion(.success(feedImageList))

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct RemoteFeedItem: Decodable {
		let items: [RemoteFeedImage]
		init(items: [RemoteFeedImage]) {
			self.items = items
		}
	}

	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImageItem: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
