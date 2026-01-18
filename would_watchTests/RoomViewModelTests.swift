//
//  RoomViewModelTests.swift
//  would_watchTests
//
//  Created by Claude on 19/01/2026.
//

import XCTest
@testable import would_watch

@MainActor
final class RoomViewModelTests: XCTestCase {
    var viewModel: RoomViewModel!
    var mockRoomService: MockRoomService!

    override func setUp() {
        super.setUp()
        mockRoomService = MockRoomService()
        viewModel = RoomViewModel(roomService: mockRoomService)
    }

    override func tearDown() {
        viewModel = nil
        mockRoomService = nil
        super.tearDown()
    }

    // MARK: - Load Rooms Tests

    func testLoadRoomsSuccess() async {
        // Given
        let expectedRooms = [
            Room(id: "room-1", name: "Room 1", hostId: "host-1", status: .active, createdAt: nil, participants: nil),
            Room(id: "room-2", name: "Room 2", hostId: "host-2", status: .active, createdAt: nil, participants: nil)
        ]
        mockRoomService.mockRooms = expectedRooms

        // When
        await viewModel.loadRooms()

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
        XCTAssertEqual(viewModel.rooms.count, 2, "Should load 2 rooms")
        XCTAssertEqual(viewModel.rooms[0].id, "room-1")
        XCTAssertEqual(viewModel.rooms[1].id, "room-2")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }

    func testLoadRoomsFailure() async {
        // Given
        mockRoomService.shouldFail = true
        mockRoomService.mockError = NetworkError.unauthorized

        // When
        await viewModel.loadRooms()

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after error")
        XCTAssertTrue(viewModel.rooms.isEmpty, "Rooms should be empty on failure")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
    }

    func testLoadRoomsUpdatesLoadingState() async {
        // Given
        mockRoomService.mockRooms = []

        // When/Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false before load")

        let loadTask = Task {
            await viewModel.loadRooms()
        }

        // Give a moment for state to update
        try? await Task.sleep(nanoseconds: 10_000_000)

        await loadTask.value

        XCTAssertFalse(viewModel.isLoading, "Loading should be false after load")
    }

    func testLoadRoomsClearsErrorMessage() async {
        // Given
        viewModel.errorMessage = "Previous error"
        mockRoomService.mockRooms = []

        // When
        await viewModel.loadRooms()

        // Then
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared on success")
    }

    // MARK: - Create Room Tests

    func testCreateRoomSuccess() async {
        // Given
        let roomName = "New Test Room"
        let participants = ["user-1", "user-2"]
        let expectedRoom = Room(
            id: "new-room",
            name: roomName,
            hostId: "host-1",
            status: .active,
            createdAt: nil,
            participants: participants
        )
        mockRoomService.mockCreatedRoom = expectedRoom

        // When
        let success = await viewModel.createRoom(name: roomName, participants: participants)

        // Then
        XCTAssertTrue(success, "Create room should return true on success")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
        XCTAssertEqual(viewModel.rooms.count, 1, "New room should be added to rooms list")
        XCTAssertEqual(viewModel.rooms[0].id, "new-room")
        XCTAssertEqual(viewModel.rooms[0].name, roomName)
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }

    func testCreateRoomFailsWithEmptyName() async {
        // Given
        let emptyName = ""
        let participants = ["user-1"]

        // When
        let success = await viewModel.createRoom(name: emptyName, participants: participants)

        // Then
        XCTAssertFalse(success, "Create room should return false with empty name")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertTrue(viewModel.errorMessage?.contains("empty") ?? false, "Error should mention empty name")
        XCTAssertEqual(mockRoomService.createRoomCallCount, 0, "Service should not be called with empty name")
    }

    func testCreateRoomFailureWithNetworkError() async {
        // Given
        let roomName = "New Room"
        let participants: [String] = []
        mockRoomService.shouldFail = true
        mockRoomService.mockError = NetworkError.connectionError(NSError(domain: "Test", code: -1))

        // When
        let success = await viewModel.createRoom(name: roomName, participants: participants)

        // Then
        XCTAssertFalse(success, "Create room should return false on network error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        XCTAssertTrue(viewModel.rooms.isEmpty, "No room should be added on failure")
    }

    func testCreateRoomAddsToBeginningOfList() async {
        // Given
        viewModel.rooms = [
            Room(id: "existing-1", name: "Existing 1", hostId: "host", status: .active, createdAt: nil, participants: nil)
        ]

        let newRoom = Room(id: "new-room", name: "New Room", hostId: "host", status: .active, createdAt: nil, participants: nil)
        mockRoomService.mockCreatedRoom = newRoom

        // When
        let success = await viewModel.createRoom(name: "New Room", participants: [])

        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.rooms.count, 2)
        XCTAssertEqual(viewModel.rooms[0].id, "new-room", "New room should be at the beginning")
        XCTAssertEqual(viewModel.rooms[1].id, "existing-1", "Existing room should move to second position")
    }

    // MARK: - Join Room Tests

    func testJoinRoomSuccess() async {
        // Given
        let roomId = "room-123"
        let joinedRoom = Room(id: roomId, name: "Joined Room", hostId: "host", status: .active, createdAt: nil, participants: nil)
        mockRoomService.mockJoinedRoom = joinedRoom
        mockRoomService.mockRooms = [joinedRoom]

        // When
        await viewModel.joinRoom(roomId)

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
        XCTAssertEqual(mockRoomService.joinRoomCallCount, 1, "Join room should be called once")
        XCTAssertEqual(mockRoomService.getRoomsCallCount, 1, "Rooms should be reloaded after join")
    }

    func testJoinRoomFailure() async {
        // Given
        let roomId = "room-123"
        mockRoomService.shouldFail = true
        mockRoomService.mockError = NetworkError.serverError(statusCode: 404, message: "Room not found")

        // When
        await viewModel.joinRoom(roomId)

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
    }

    func testJoinRoomReloadsRoomList() async {
        // Given
        let roomId = "room-123"
        let initialRooms = [
            Room(id: "room-1", name: "Room 1", hostId: "host", status: .active, createdAt: nil, participants: nil)
        ]
        let updatedRooms = [
            Room(id: "room-1", name: "Room 1", hostId: "host", status: .active, createdAt: nil, participants: nil),
            Room(id: roomId, name: "Joined Room", hostId: "host", status: .active, createdAt: nil, participants: nil)
        ]

        mockRoomService.mockJoinedRoom = updatedRooms[1]
        mockRoomService.mockRooms = updatedRooms

        // When
        await viewModel.joinRoom(roomId)

        // Then
        XCTAssertEqual(viewModel.rooms.count, 2, "Room list should be updated after join")
        XCTAssertTrue(viewModel.rooms.contains(where: { $0.id == roomId }), "Joined room should be in the list")
    }

    // MARK: - Submit Vote Tests

    func testSubmitVoteSuccess() async {
        // Given
        let roomId = "room-123"
        let mediaId = 550
        let vote = VoteType.yes
        let expectedResponse = VoteResponse(success: true, isMatch: true)
        mockRoomService.mockVoteResponse = expectedResponse

        // When
        do {
            let response = try await viewModel.submitVote(roomId: roomId, mediaId: mediaId, vote: vote)

            // Then
            XCTAssertTrue(response.success)
            XCTAssertEqual(response.isMatch, true)
            XCTAssertEqual(mockRoomService.submitVoteCallCount, 1)
        } catch {
            XCTFail("Submit vote should not throw: \(error)")
        }
    }

    func testSubmitVoteFailure() async {
        // Given
        let roomId = "room-123"
        let mediaId = 550
        let vote = VoteType.no
        mockRoomService.shouldFail = true
        mockRoomService.mockError = NetworkError.unauthorized

        // When/Then
        do {
            _ = try await viewModel.submitVote(roomId: roomId, mediaId: mediaId, vote: vote)
            XCTFail("Submit vote should throw on error")
        } catch {
            // Expected
        }
    }

    // MARK: - Get Matches Tests

    func testGetMatchesSuccess() async {
        // Given
        let roomId = "room-123"
        let movie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker...",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 20000
        )
        let expectedMatches = [
            RoomMatch(id: 1, movie: movie, voters: ["user-1", "user-2"])
        ]
        mockRoomService.mockMatches = expectedMatches

        // When
        do {
            let matches = try await viewModel.getMatches(roomId: roomId)

            // Then
            XCTAssertEqual(matches.count, 1)
            XCTAssertEqual(matches[0].movie.id, 550)
            XCTAssertEqual(matches[0].movie.title, "Fight Club")
            XCTAssertEqual(matches[0].voters.count, 2)
        } catch {
            XCTFail("Get matches should not throw: \(error)")
        }
    }

    func testGetMatchesFailure() async {
        // Given
        let roomId = "room-123"
        mockRoomService.shouldFail = true
        mockRoomService.mockError = NetworkError.serverError(statusCode: 500, message: "Internal error")

        // When/Then
        do {
            _ = try await viewModel.getMatches(roomId: roomId)
            XCTFail("Get matches should throw on error")
        } catch {
            // Expected
        }
    }

    func testGetMatchesReturnsEmptyArray() async {
        // Given
        let roomId = "room-123"
        mockRoomService.mockMatches = []

        // When
        do {
            let matches = try await viewModel.getMatches(roomId: roomId)

            // Then
            XCTAssertTrue(matches.isEmpty, "Should return empty array when no matches")
        } catch {
            XCTFail("Get matches should not throw: \(error)")
        }
    }
}

// MARK: - Mock Room Service

class MockRoomService: RoomServiceProtocol {
    var shouldFail = false
    var mockError: Error?

    var mockRooms: [Room] = []
    var mockCreatedRoom: Room?
    var mockJoinedRoom: Room?
    var mockRoom: Room?
    var mockVoteResponse: VoteResponse?
    var mockMatches: [RoomMatch] = []

    var getRoomsCallCount = 0
    var createRoomCallCount = 0
    var joinRoomCallCount = 0
    var getRoomCallCount = 0
    var submitVoteCallCount = 0
    var getMatchesCallCount = 0

    func getRooms() async throws -> [Room] {
        getRoomsCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockRooms
    }

    func createRoom(name: String, participants: [String]) async throws -> Room {
        createRoomCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        guard let room = mockCreatedRoom else {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: -2))
        }

        return room
    }

    func joinRoom(roomId: String) async throws -> Room {
        joinRoomCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        guard let room = mockJoinedRoom else {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: -2))
        }

        return room
    }

    func getRoom(roomId: String) async throws -> Room {
        getRoomCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        guard let room = mockRoom else {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: -2))
        }

        return room
    }

    func submitVote(roomId: String, mediaId: Int, vote: VoteType) async throws -> VoteResponse {
        submitVoteCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        guard let response = mockVoteResponse else {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: -2))
        }

        return response
    }

    func getMatches(roomId: String) async throws -> [RoomMatch] {
        getMatchesCallCount += 1

        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        return mockMatches
    }

    func reset() {
        shouldFail = false
        mockError = nil
        mockRooms = []
        mockCreatedRoom = nil
        mockJoinedRoom = nil
        mockRoom = nil
        mockVoteResponse = nil
        mockMatches = []
        getRoomsCallCount = 0
        createRoomCallCount = 0
        joinRoomCallCount = 0
        getRoomCallCount = 0
        submitVoteCallCount = 0
        getMatchesCallCount = 0
    }
}
