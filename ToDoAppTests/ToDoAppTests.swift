//
//  ToDoAppTests.swift
//  ToDoAppTests
//
//  Created by Артемий Андреев on 22.05.2025.
//

import XCTest
import CoreData
@testable import ToDoApp

// MARK: – URLProtocolStub
private class URLProtocolStub: URLProtocol {
    static var stub: Stub?
    struct Stub { let data: Data?; let response: HTTPURLResponse?; let error: Error? }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        if let err = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: err)
        } else {
            if let resp = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
            }
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    override func stopLoading() {}
}

// MARK: –  TaskDetailPresenter
private class MockDetailView: TaskDetailViewProtocol {
    var shownError: String?
    func showTask(title: String, taskDescription: String, isDone: Bool) {}
    func close() {}
    func showError(_ message: String) { shownError = message }
}
private class MockDetailInteractor: TaskDetailInteractorInput {
    func addTask(title: String, taskDescription: String, isDone: Bool) {}
    func updateTask(model: TaskModel) {}
    func deleteTask(id: NSManagedObjectID) {}
}
private class MockDetailDelegate: TaskDetailDelegate {
    func didAddTask(_ task: TaskModel) {}
    func didUpdate(_ task: TaskModel) {}
    func didDelete(id: NSManagedObjectID) {}
}


final class ToDoAppTests: XCTestCase {

    func testAddAndFetchCoreData() throws {
        let manager = CoreDataManager(inMemory: true)
        XCTAssertFalse(manager.isInitialDataLoaded)

        let m1 = try manager.addTask(title: "A", taskDescription: "Desc A")
        let m2 = try manager.addTask(title: "B", taskDescription: "Desc B", isDone: true)

        let all = try manager.fetchAllTasks()
        XCTAssertEqual(all.count, 2)
        XCTAssertTrue(all.contains { $0.id == m1.id })
        XCTAssertTrue(all.contains { $0.id == m2.id })
        XCTAssertTrue(manager.isInitialDataLoaded)
    }

    func testFetchTodosSuccess() async throws {
        URLProtocol.registerClass(URLProtocolStub.self)
        defer {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stub = nil
        }

        let json = """
        { "todos":[{"id":1,"todo":"Hi","completed":false,"userId":1}] }
        """.data(using: .utf8)!
        let url = URL(string: Constants.apiURL)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolStub.stub = .init(data: json, response: response, error: nil)

        let items = try await NetworkService.shared.fetchTodos()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].todo, "Hi")
    }

    func testSaveEmptyTitleShowsError() {
        let presenter = TaskDetailPresenter(mode: .new)
        let view = MockDetailView()
        let interactor = MockDetailInteractor()
        let delegate = MockDetailDelegate()

        presenter.view = view
        presenter.interactor = interactor
        presenter.delegate = delegate

        presenter.save(title: "   ", taskDescription: "x", isDone: false)
        XCTAssertEqual(view.shownError, "Название не может быть пустым")
    }
}
