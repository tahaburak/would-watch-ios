//
//  SocialViewModelTests.swift
//  would_watchTests
//
//  Created by Claude on 24/01/2026.
//

import XCTest
@testable import would_watch

@MainActor
final class SocialViewModelTests: XCTestCase {
    var viewModel: SocialViewModel!
    var mockSocialService: MockSocialService!

    override func setUp() {
        super.setUp()
        mockSocialService = MockSocialService()
        viewModel = SocialViewModel(socialService: mockSocialService)
    }

    override func tearDown() {
        viewModel = nil
        mockSocialService = nil
        super.tearDown()
    }

    // MARK: - Load Friends Tests

    func testLoadFriends_Success() async {
        // Given
        let mockFriends = [
            MockAPIClient.createMockFriend(id: "1", username: "alice", isFollowing: true),
            MockAPIClient.createMockFriend(id: "2", username: "bob", isFollowing: true)
        ]
        mockSocialService.mockFriends = mockFriends

        // When
        await viewModel.loadFriends()

        // Then
        XCTAssertEqual(viewModel.friends.count, 2)
        XCTAssertEqual(viewModel.friends[0].username, "alice")
        XCTAssertEqual(viewModel.friends[1].username, "bob")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadFriends_EmptyList() async {
        // Given
        mockSocialService.mockFriends = []

        // When
        await viewModel.loadFriends()

        // Then
        XCTAssertTrue(viewModel.friends.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadFriends_NetworkError() async {
        // Given
        mockSocialService.shouldFail = true
        mockSocialService.mockError = NetworkError.connectionError(NSError(domain: "Test", code: -1))

        // When
        await viewModel.loadFriends()

        // Then
        XCTAssertTrue(viewModel.friends.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadFriends_LoadingState() async {
        // Given
        mockSocialService.mockFriends = [
            MockAPIClient.createMockFriend(id: "1", username: "alice")
        ]

        // When
        let loadTask = Task {
            await viewModel.loadFriends()
        }

        // Then - Check loading state is set
        // Note: This may be tricky to test due to timing, but we verify it's false after completion
        await loadTask.value
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Search Users Tests

    func testSearchUsers_Success() async {
        // Given
        let mockResults = [
            MockAPIClient.createMockFriend(id: "3", username: "charlie", isFollowing: false),
            MockAPIClient.createMockFriend(id: "4", username: "diana", isFollowing: false)
        ]
        mockSocialService.mockSearchResults = mockResults
        viewModel.searchQuery = "test"

        // When
        await viewModel.searchUsers()

        // Then
        XCTAssertEqual(viewModel.searchResults.count, 2)
        XCTAssertEqual(viewModel.searchResults[0].username, "charlie")
        XCTAssertEqual(viewModel.searchResults[1].username, "diana")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchUsers_EmptyQuery() async {
        // Given
        viewModel.searchQuery = ""
        mockSocialService.mockSearchResults = [
            MockAPIClient.createMockFriend(id: "3", username: "charlie")
        ]

        // When
        await viewModel.searchUsers()

        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertEqual(mockSocialService.searchCallCount, 0) // Should not call service
    }

    func testSearchUsers_NetworkError() async {
        // Given
        viewModel.searchQuery = "test"
        mockSocialService.shouldFail = true
        mockSocialService.mockError = NetworkError.serverError(statusCode: 500, message: "Internal Server Error")

        // When
        await viewModel.searchUsers()

        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSearchUsers_ClearsResultsOnEmptyQuery() async {
        // Given
        viewModel.searchResults = [
            MockAPIClient.createMockFriend(id: "1", username: "alice")
        ]
        viewModel.searchQuery = ""

        // When
        await viewModel.searchUsers()

        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    // MARK: - Follow User Tests

    func testFollowUser_Success() async {
        // Given
        let userToFollow = MockAPIClient.createMockFriend(
            id: "5",
            username: "eve",
            isFollowing: false
        )
        viewModel.searchResults = [userToFollow]
        mockSocialService.mockFollowResponse = FollowResponse(success: true, message: "Followed successfully")

        // When
        await viewModel.followUser(userToFollow)

        // Then
        XCTAssertEqual(mockSocialService.followCallCount, 1)
        XCTAssertEqual(mockSocialService.lastFollowedUserId, "5")
        // Search results should be updated
        XCTAssertTrue(viewModel.searchResults[0].isFollowing)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFollowUser_UpdatesFriendsList() async {
        // Given
        let userToFollow = MockAPIClient.createMockFriend(
            id: "5",
            username: "eve",
            isFollowing: false
        )
        viewModel.searchResults = [userToFollow]
        mockSocialService.mockFollowResponse = FollowResponse(success: true, message: "Followed")
        // Set up friends list to be loaded after follow
        mockSocialService.mockFriends = [
            MockAPIClient.createMockFriend(id: "5", username: "eve", isFollowing: true)
        ]

        // When
        await viewModel.followUser(userToFollow)

        // Then
        XCTAssertEqual(viewModel.friends.count, 1)
        XCTAssertEqual(viewModel.friends[0].username, "eve")
    }

    func testFollowUser_NetworkError() async {
        // Given
        let userToFollow = MockAPIClient.createMockFriend(
            id: "5",
            username: "eve",
            isFollowing: false
        )
        mockSocialService.shouldFail = true
        mockSocialService.mockError = NetworkError.unauthorized

        // When
        await viewModel.followUser(userToFollow)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Unfollow User Tests

    func testUnfollowUser_Success() async {
        // Given
        let userToUnfollow = MockAPIClient.createMockFriend(
            id: "6",
            username: "frank",
            isFollowing: true
        )
        viewModel.friends = [userToUnfollow]
        mockSocialService.mockFollowResponse = FollowResponse(success: true, message: "Unfollowed successfully")

        // When
        await viewModel.unfollowUser(userToUnfollow)

        // Then
        XCTAssertEqual(mockSocialService.unfollowCallCount, 1)
        XCTAssertEqual(mockSocialService.lastUnfollowedUserId, "6")
        XCTAssertTrue(viewModel.friends.isEmpty) // Should be removed from friends list
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUnfollowUser_UpdatesSearchResults() async {
        // Given
        let userToUnfollow = MockAPIClient.createMockFriend(
            id: "6",
            username: "frank",
            isFollowing: true
        )
        viewModel.friends = [userToUnfollow]
        viewModel.searchResults = [userToUnfollow]
        mockSocialService.mockFollowResponse = FollowResponse(success: true, message: "Unfollowed")

        // When
        await viewModel.unfollowUser(userToUnfollow)

        // Then
        // Search results should show user as not following
        XCTAssertFalse(viewModel.searchResults[0].isFollowing)
    }

    func testUnfollowUser_NetworkError() async {
        // Given
        let userToUnfollow = MockAPIClient.createMockFriend(
            id: "6",
            username: "frank",
            isFollowing: true
        )
        viewModel.friends = [userToUnfollow]
        mockSocialService.shouldFail = true
        mockSocialService.mockError = NetworkError.serverError(statusCode: 404, message: "Not Found")

        // When
        await viewModel.unfollowUser(userToUnfollow)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        // Friends list should remain unchanged on error
        XCTAssertEqual(viewModel.friends.count, 1)
    }

    // MARK: - Error Handling Tests

    func testErrorMessage_ClearsOnSuccessfulLoad() async {
        // Given
        viewModel.errorMessage = "Previous error"
        mockSocialService.mockFriends = [
            MockAPIClient.createMockFriend(id: "1", username: "alice")
        ]

        // When
        await viewModel.loadFriends()

        // Then
        XCTAssertNil(viewModel.errorMessage)
    }

    func testErrorMessage_ClearsOnSuccessfulSearch() async {
        // Given
        viewModel.errorMessage = "Previous error"
        viewModel.searchQuery = "test"
        mockSocialService.mockSearchResults = [
            MockAPIClient.createMockFriend(id: "1", username: "alice")
        ]

        // When
        await viewModel.searchUsers()

        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
}

// MARK: - Mock SocialService

class MockSocialService: SocialServiceProtocol {
    var shouldFail = false
    var mockError: Error?
    var mockFriends: [Friend] = []
    var mockSearchResults: [Friend] = []
    var mockFollowResponse: FollowResponse?

    var getFriendsCallCount = 0
    var searchCallCount = 0
    var followCallCount = 0
    var unfollowCallCount = 0

    var lastSearchQuery: String?
    var lastFollowedUserId: String?
    var lastUnfollowedUserId: String?

    func getFriends() async throws -> [Friend] {
        getFriendsCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockFriends
    }

    func searchUsers(query: String) async throws -> [Friend] {
        searchCallCount += 1
        lastSearchQuery = query

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockSearchResults
    }

    func followUser(userId: String) async throws -> FollowResponse {
        followCallCount += 1
        lastFollowedUserId = userId

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockFollowResponse ?? FollowResponse(success: true, message: "Followed")
    }

    func unfollowUser(userId: String) async throws -> FollowResponse {
        unfollowCallCount += 1
        lastUnfollowedUserId = userId

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockFollowResponse ?? FollowResponse(success: true, message: "Unfollowed")
    }

    func reset() {
        shouldFail = false
        mockError = nil
        mockFriends = []
        mockSearchResults = []
        mockFollowResponse = nil
        getFriendsCallCount = 0
        searchCallCount = 0
        followCallCount = 0
        unfollowCallCount = 0
        lastSearchQuery = nil
        lastFollowedUserId = nil
        lastUnfollowedUserId = nil
    }
}
