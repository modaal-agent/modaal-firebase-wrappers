// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import XCTest
@testable import ModaalFirebaseAuth
@testable import ModaalFirebaseMocks

final class FirebaseAuthCombineTests: XCTestCase {

  private var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = []
  }

  override func tearDown() {
    cancellables = nil
    super.tearDown()
  }

  // MARK: - Helpers

  private func makeAuthDataResultMock() -> FirebaseAuthDataResultProtocolMock {
    let userMock = FirebaseUserProtocolMock(metadata: FirebaseUserMetadataProtocolMock())
    userMock.uid = "test-uid"
    userMock.isAnonymous = true
    return FirebaseAuthDataResultProtocolMock(user: userMock)
  }

  // MARK: - Future: signInAnonymously

  func testSignInAnonymouslySuccess() {
    let mock = FirebaseAuthProtocolMock()
    let expectedResult = makeAuthDataResultMock()

    mock.signInAnonymouslyHandler = { completion in
      completion(.success(expectedResult))
    }

    let expectation = expectation(description: "signIn completes")
    mock.signInAnonymously()
      .sink(
        receiveCompletion: { completion in
          if case .failure = completion { XCTFail("Expected success") }
        },
        receiveValue: { result in
          XCTAssertEqual(result.user.uid, "test-uid")
          XCTAssertTrue(result.user.isAnonymous)
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.signInAnonymouslyCallCount, 1)
  }

  func testSignInAnonymouslyFailure() {
    let mock = FirebaseAuthProtocolMock()
    let expectedError = NSError(domain: "FIRAuthError", code: 17999)

    mock.signInAnonymouslyHandler = { completion in
      completion(.failure(expectedError))
    }

    let expectation = expectation(description: "signIn fails")
    mock.signInAnonymously()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 17999)
            expectation.fulfill()
          }
        },
        receiveValue: { _ in XCTFail("Expected failure") }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Future: signIn(withEmail:password:)

  func testSignInWithEmailSuccess() {
    let mock = FirebaseAuthProtocolMock()
    let expectedResult = makeAuthDataResultMock()

    mock.signInWithEmailEmailPasswordCompletionHandler = { email, password, completion in
      XCTAssertEqual(email, "user@example.com")
      XCTAssertEqual(password, "secret123")
      completion(.success(expectedResult))
    }

    let expectation = expectation(description: "email signIn completes")
    mock.signIn(withEmail: "user@example.com", password: "secret123")
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { result in
          XCTAssertEqual(result.user.uid, "test-uid")
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Future: sendPasswordReset

  func testSendPasswordResetSuccess() {
    let mock = FirebaseAuthProtocolMock()

    mock.sendPasswordResetHandler = { email, completion in
      XCTAssertEqual(email, "user@example.com")
      completion(.success(()))
    }

    let expectation = expectation(description: "reset completes")
    mock.sendPasswordReset(withEmail: "user@example.com")
      .sink(
        receiveCompletion: { completion in
          if case .failure = completion { XCTFail("Expected success") }
          expectation.fulfill()
        },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.sendPasswordResetCallCount, 1)
  }

  // MARK: - Streaming: authStateDidChangePublisher

  func testAuthStateDidChangePublisherEmitsUserChanges() {
    let mock = FirebaseAuthProtocolMock()
    let user1 = FirebaseUserProtocolMock(metadata: FirebaseUserMetadataProtocolMock())
    user1.uid = "user-1"
    let user2 = FirebaseUserProtocolMock(metadata: FirebaseUserMetadataProtocolMock())
    user2.uid = "user-2"
    let handle = NSObject()

    var capturedListener: ((FirebaseAuthProtocol, FirebaseUserProtocol?) -> Void)?

    mock.addStateDidChangeListenerHandler = { listener in
      capturedListener = listener
      return handle
    }

    var receivedUIDs: [String?] = []
    let expectation = expectation(description: "receives 3 state changes")
    expectation.expectedFulfillmentCount = 3

    mock.authStateDidChangePublisher()
      .sink { user in
        receivedUIDs.append(user?.uid)
        expectation.fulfill()
      }
      .store(in: &cancellables)

    XCTAssertNotNil(capturedListener)

    capturedListener?(mock, user1)
    capturedListener?(mock, user2)
    capturedListener?(mock, nil) // signed out

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(receivedUIDs, ["user-1", "user-2", nil])
  }

  func testAuthStateDidChangePublisherRemovesListenerOnCancel() {
    let mock = FirebaseAuthProtocolMock()
    let handle = NSObject()

    mock.addStateDidChangeListenerHandler = { _ in handle }

    var removedHandle: FirebaseAuthStateDidChangeListenerHandle?
    mock.removeStateDidChangeListenerHandler = { h in
      removedHandle = h
    }

    let cancellable = mock.authStateDidChangePublisher()
      .sink { _ in }

    XCTAssertEqual(mock.removeStateDidChangeListenerCallCount, 0)
    cancellable.cancel()
    XCTAssertEqual(mock.removeStateDidChangeListenerCallCount, 1)
    XCTAssertIdentical(removedHandle as AnyObject, handle)
  }
}
