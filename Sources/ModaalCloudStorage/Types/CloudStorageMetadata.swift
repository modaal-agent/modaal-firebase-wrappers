// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public struct CloudStorageMetadata {
  public var contentType: String?
  public var cacheControl: String?
  public var customMetadata: [String: String]?
  public let size: Int64
  public let name: String?
  public let path: String?
  public let timeCreated: Date?
  public let updated: Date?
  public let md5Hash: String?

  /// Create metadata for upload requests (settable properties only).
  public init(contentType: String? = nil, cacheControl: String? = nil, customMetadata: [String: String]? = nil) {
    self.contentType = contentType
    self.cacheControl = cacheControl
    self.customMetadata = customMetadata
    self.size = 0
    self.name = nil
    self.path = nil
    self.timeCreated = nil
    self.updated = nil
    self.md5Hash = nil
  }

  /// Internal memberwise init for wrapping server responses.
  init(contentType: String?, cacheControl: String?, customMetadata: [String: String]?,
       size: Int64, name: String?, path: String?, timeCreated: Date?, updated: Date?, md5Hash: String?) {
    self.contentType = contentType
    self.cacheControl = cacheControl
    self.customMetadata = customMetadata
    self.size = size
    self.name = name
    self.path = path
    self.timeCreated = timeCreated
    self.updated = updated
    self.md5Hash = md5Hash
  }
}
