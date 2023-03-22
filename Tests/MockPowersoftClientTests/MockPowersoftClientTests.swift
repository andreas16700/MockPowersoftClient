import XCTest
import PowersoftKit
@testable import MockPowersoftClient
let url = URL(string: "http://127.0.0.1:8081")!
final class MockPowersoftClientTests: XCTestCase {
	static let client: MockPsClient = .init(baseURL: url)
	static let modelCount = 50_000
	override func setUp() async throws {
		let done = await Self.client.generateModels(modelCount: Self.modelCount)
		XCTAssertTrue(done)
	}
	
	override func tearDown() async throws {
		let done = await Self.client.reset()
		XCTAssertTrue(done)
	}
	
	
	
	
	func testModelMethods()async throws{
		let counter = Self.client.getAllModelsCount
		let singler = Self.client.getModelMetadata
		let aller = Self.client.getAllModels
		try await testAllResourceMethods(countGetter: counter, singleGetter: singler, allGetter: aller, idPath: \.modelCode365)
	}
	func testStockMethods()async throws{
		let counter = Self.client.getAllStockCount
		let singler = Self.client.getStock
		let aller = Self.client.getAllStocks
		try await testAllResourceMethods(countGetter: counter, singleGetter: singler, allGetter: aller, idPath: \.itemCode365)
	}
	func testItemMethods()async throws{
		let counter = Self.client.getAllItemsCount
		let singler = Self.client.getItem
		let aller = Self.client.getAllItems
		try await testAllResourceMethods(countGetter: counter, singleGetter: singler, allGetter: aller, idPath: \.itemCode365)
	}
	func testAllResourceMethods<T: Equatable>(countGetter: (eCommerceType)async->Int?, singleGetter: (String)async->T?, allGetter: (eCommerceType)async->[T]?, idPath: KeyPath<T,String>)async throws{
		let count = try await XCTUnwrapAsync(await countGetter(.all))
		let all = try await XCTUnwrapAsync(await allGetter(.all))
		XCTAssertEqual(count, all.count)
		let randomItems = try Array(1...5).map{_ in try XCTUnwrap(all.randomElement())}
		for item in randomItems {
			let retrieved = try await XCTUnwrapAsync(await singleGetter(item[keyPath: idPath]))
			XCTAssertEqual(retrieved, item)
		}
	}
	enum Resource: String{
		case items, models,stocks
	}
//	func testGetAll()async throws{
//		let all = try await XCTUnwrapAsync(await Self.client.getAllModelItems())
//		let modelsCount = all.keys.count
//		print("Received \(modelsCount) models")
//		XCTAssertEqual(modelsCount, Self.modelCount)
//	}
//	
//	func testGetItem()async throws{
//		let all = try await XCTUnwrapAsync(await Self.client.getAllModelItems())
//		let randomItem = try XCTUnwrap(all.randomElement()?.value.randomElement())
//		let retrieved = try await XCTUnwrapAsync(await Self.client.getItem(itemCode:randomItem.itemCode365))
//		XCTAssertEqual(retrieved, randomItem)
//	}
//	func testGetAllItemsCount()async throws{
//		let itemsCount = try await XCTUnwrapAsync(await Self.client.getAllItemsCount(type: .eCommerceOnly))
//		XCTAssertTrue(itemsCount >= Self.modelCount)
//		print("has \(itemsCount) total items")
//	}
	
}
public func XCTUnwrapAsync<T>(_ expression: @autoclosure () async throws -> T?, _ message: @autoclosure () -> String = "")async throws->T{
	let expr = try await expression()
	let msg = message()
	return try XCTUnwrap(expr, msg)
}
