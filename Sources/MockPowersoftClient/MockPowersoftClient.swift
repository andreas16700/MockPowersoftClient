import Foundation
import PowersoftKit
import SwiftLinuxNetworking

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Blank: Codable{}
struct Wrapper<T: Codable>: Codable{
	let content: T
}

public struct MockPsClient: PowersoftClientProtocol{
	static let pageCapacity = 10000
	//MARK: Items
	public func getAllItemsCount(type: PowersoftKit.eCommerceType) async -> Int? {
		return await sendRequest(path: "items/count", method: "GET", expect: Wrapper<Int>.self).map(\.content)
	}
	
	public func getItemsPage(page: Int, type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSItem]? {
		return await sendRequest(path: "items/page/\(page)", method: "GET", expect: [PSItem].self)
	}
	
	public func getAllItems(type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSItem]? {
//		return await sendRequest(path: "items/all", method: "GET", expect: [PSItem].self)
		return await getAllPaginated(resource: .items, type: PSItem.self)
	}
	//MARK: Models
	public func getAllModelItems()async ->[String: [PSItem]]?{
		return await sendRequest(path: "allModelItems", method: "GET", expect: [String: [PSItem]].self)
	}
	public func getModel(modelCode: String) async -> [PowersoftKit.PSItem]? {
		return await sendRequest(path: "modelItem/"+modelCode, method: "GET", expect: [PSItem].self)
	}
	public func getModelMetadata(modelCode: String) async -> PSListModel? {
		return await sendRequest(path: "model/"+modelCode, method: "GET", expect: PSListModel.self)
	}
	public func getAllModelsCount(type: PowersoftKit.eCommerceType) async -> Int? {
		return await sendRequest(path: "models/count", method: "GET", expect: Wrapper<Int>.self).map(\.content)
	}
	
	public func getModelsPage(page: Int, type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSListModel]? {
		return await sendRequest(path: "models/page/\(page)", method: "GET", expect: [PSListModel].self)
	}
	
	public func getAllModels(type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSListModel]? {
		return await getAllPaginated(resource: .models, type: PSListModel.self)
	}
	//MARK: Stocks
	public func getStock(for itemCode: String) async -> PowersoftKit.PSListStockStoresItem? {
		return await sendRequest(path: "stock/"+itemCode, method: "GET", expect: PSListStockStoresItem.self)
	}
	
	public func getAllStockCount(type: PowersoftKit.eCommerceType) async -> Int? {
		return await sendRequest(path: "stocks/count", method: "GET", expect: Wrapper<Int>.self).map(\.content)
	}
	
	public func getStocksPage(page: Int, type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSListStockStoresItem]? {
		return await sendRequest(path: "stocks/page/\(page)", method: "GET", expect: [PSListStockStoresItem].self)
	}
	
	public func getAllStocks(type: PowersoftKit.eCommerceType) async -> [PowersoftKit.PSListStockStoresItem]? {
		return await getAllPaginated(resource: .stocks, type: PSListStockStoresItem.self)
	}
	//MARK: General
	public func getFirstModelsAndTheirStocks(count: Int)async ->[ModelAndItsStocks]?{
		return await sendRequest(path: "firstModelItemsAndStocks/\(count)", method: "GET", expect: [ModelAndItsStocks].self)
	}
	private func getAllPaginated<T>(resource: ResourceName, type: T.Type) async -> [T]?{
		let countGetter = countGetter(forResource: resource)
		let pageGetter = pageGetter(forResource: resource, resourceType: type)
		return await getAllPaginated(resourceName: resource.rawValue, countGetter: countGetter, pageGetter: pageGetter)
	}
	
	actor SStorage{
		static let shared:SStorage = .init()
		var s: [Int] = .init()
		var r: [Int] = .init()
		func addI(_ i: Int, rec: Bool = false){
			if rec{
				r.append(i)
			}else{
				s.append(i)
			}
		}
		nonisolated func add(_ i: Int, rec: Bool = false){
			Task{
				await addI(i, rec: rec)
			}
		}
		static func add(_ i: Int, rec: Bool = false){
			Self.shared.add(i, rec: rec)
		}
		static func p(){
			Task{
				let allArray = await Self.shared.s.sorted()
				let recArray = await Self.shared.r.sorted()
				let all = allArray.map{"\($0)"}.joined(separator: ",")
				let missing = allArray.filter{!recArray.contains($0)}.map{"\($0)"}.joined(separator: ",")
				print("Requested pages: ",all)
				print("Missing pages: \(missing)")
			}
		}
	}
	public func getAllPaginated<T>(resourceName: String, countGetter: () async -> Int?, pageGetter: @escaping (Int) async -> [T]?) async -> [T]? {
		guard let count = await countGetter() else {print("Nil count for resource \(resourceName)!"); return nil}
		var pages = count / pageCapacity
		if (count % pageCapacity != 0){pages+=1}
		let batchCount = 10
		let batches = pages/batchCount
		let extraPages = pages % batchCount
		print("For \(count) \(resourceName) will request \(pages) pages in \(batches) batches of \(batchCount) each + \(extraPages)")
//		let gr = DispatchGroup()
//		let q = DispatchQueue(label: "l", qos: .userInitiated, attributes: .concurrent)
		///
		///
		///
		///1					2				3		...		10
		///i=0
		///i*10+1	     		i*10+2			i*10+3			i*10+10
		
		///11					12				13		...		20
		///i=1
		///i*10+1	     		i*10+2			i*10+3			i*10+10
		
		///91					92				93		...		100
		///i=9
		///i*10+1	     		i*10+2			i*10+3			i*10+10
//		let stuff = await withTaskGroup(of: [T]?.self, returning: Optional<[T]>.self){taskGroup in
//			for i in 0..<batches{
//				for j in 1...batchCount{
//					let pageNum = i*batchCount+j
//
//					taskGroup.addTask{
//						print("Requesting page \(pageNum)")
//						SStorage.add(pageNum)
//						let p = await pageGetter(pageNum)
//						SStorage.add(pageNum, rec: true)
//						print("Received page \(pageNum)")
//						return p
//					}
//				}
////				print("Wating for batches of i=\(i) to complete")
////				await taskGroup.waitForAll()
//			}
//			if extraPages>0{
//				let firstPage = pages-extraPages+1
//				let lastPage = pages
//				for pNum in firstPage...lastPage{
//					taskGroup.addTask{
//						SStorage.add(pNum)
//						print("Requesting page \(pNum)")
//						let p = await pageGetter(pNum)
//						SStorage.add(pNum, rec: true)
//						return p
//					}
//				}
//			}
//			var r = [T]()
//			var added = 0, total = 0
//
//			for await s in taskGroup{
//				guard let unwrapped = s else {
//					print("Error retrieving page of all \(resourceName)!")
//					r = .init();return r
//				}
//				added+=1
//				total+=unwrapped.count
//				print("Result added another page and have \(total) items so far")
//				r.append(contentsOf: unwrapped)
//			}
//
//			print("Result added \(added) pages and \(total) items")
//			SStorage.p()
//			return r
//		}
		//MARK: Standard attempt
		
//		var stuff: [T] = .init()
//		for i in 0..<batches{
//			print("Requesting batch \(i)")
//			let inputs = Array(1...batchCount).map{i*batchCount+$0}
//			let batchc = await requestAll(inputs: inputs, getter: pageGetter)
//			let batch = await withTaskGroup(of: [T]?.self, returning: [T]?.self){taskGroup in
//				for j in 1...batchCount{
//					let pageNum = i*batchCount+j
//					taskGroup.addTask{
//						let page = await pageGetter(pageNum)
//						return page
//					}
//				}
//				return await taskGroup.reduce(into: Optional<[T]>.init(.init())){
//					guard $0 != nil, let some = $1 else {$0=nil;return}
//					$0!.append(contentsOf: some)
//				}
//			}
//			guard let batch else {return nil}
//			print("Received batch \(i)")
//			stuff.append(contentsOf: batch)
//		}
//		if extraPages>0{
//			print("Requesting extra pages")
//			let firstPage = pages-extraPages+1
//			let lastPage = pages
//			for pNum in firstPage...lastPage{
//				guard let page = await pageGetter(pNum) else {return nil}
//				stuff.append(contentsOf: page)
//			}
//		}
		//MARK: Best attempt
		let stuff = await withTaskGroup(of: [T]?.self, returning: [T]?.self){taskGroup in
			for i in 1...pages{
				taskGroup.addTask{
					await pageGetter(i)
				}
			}
			var arr: [T] = .init()
			arr.reserveCapacity(count)
			return await taskGroup.reduce(into: arr){
				$0.append(contentsOf: $1!)
			}
		}
		//MARK: Naive attempt
//		var stuff: [T] = .init()
//		for i in 1...pages{
//
//			print("Requesting page \(i)")
//			guard let page = await pageGetter(i) else{
//				print("Error retrieving page \(i) of all \(resourceName)!")
//				return nil
//			}
//			stuff.append(contentsOf: page)
//		}
		
		//MARK: Latest attempt
//		let batchGetter: ([Int])async->[T]? = {inputs in
//			return await requestAll(inputs: inputs, getter: pageGetter)
//		}
//		var batchInputs = Array(0..<batches).map{i in
//			let inputs = Array(1...batchCount).map{i*batchCount+$0}
//			return inputs
//		}
//		if extraPages>0{
//			let firstPage = pages-extraPages+1
//			let lastPage = pages
//			let extraInputs = Array(firstPage...lastPage)
//			batchInputs.append(extraInputs)
//		}
//		let stuff = await requestAll(inputs: batchInputs, getter: batchGetter)
		
		return stuff
	}
	enum ResourceName: String{
		case models = "models"
		case items = "items"
		case stocks = "stocks"
	}
	private func pageGetter<T>(forResource resource: ResourceName, resourceType: T.Type)->(Int)async ->[T]?{
		func removingParam<T,P>(of closure: @escaping (Int,P)async->T, withValue value: P)->(Int)async->T{
			let f = {number in
				return await closure(number, value)
			}
			return f
		}
		var closure: (Int, eCommerceType)async->[T]? = {_,_  in return nil}
		switch resource{
		case .models:
			closure = getModelsPage as! (Int, eCommerceType)async->[T]?
		case .items:
			closure = getItemsPage as! (Int, eCommerceType)async->[T]?
		case .stocks:
			closure = getStocksPage as! (Int, eCommerceType)async->[T]?
//		default:
//			fatalError()
		}
		return removingParam(of: closure, withValue: .eCommerceOnly)
	}
	private func countGetter(forResource resource: ResourceName)->()async ->Int?{
		func removingParam<T,P>(of closure: @escaping (P)async->T, withValue value: P)->()async->T{
			let f = {
				return await closure(value)
			}
			return f
		}
		var closure: (eCommerceType)async->Int? = {_ in return 0}
		switch resource{
		case .models:
			closure = getAllModelsCount
		case .items:
			closure = getAllItemsCount
		case .stocks:
			closure = getAllStockCount
//		default:
//			fatalError()
		}
		return removingParam(of: closure, withValue: .eCommerceOnly)
	}
	
	public init(
		pageItemCapacity: Int? = nil,
		baseURL: URL
	){
		self.pageCapacity=pageItemCapacity ?? Self.pageCapacity
		self.baseURL = baseURL
	}
	let baseURL: URL
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	func sendRequest(path: String, method: String)async -> Bool{
		return await sendRequest(path: path, method: method, body: Blank(), expect: Bool.self) ?? false
	}
	
	func sendRequest<T2: Decodable>(path: String, method: String, expect: T2.Type)async -> T2?{
		return await sendRequest(path: path, method: method, body: Blank(), expect: T2.self)
	}
	
	func sendRequest<T: Encodable>(path: String, method: String, body: T)async -> Bool{
		return await sendRequest(path: path, method: method, body: body, expect: Bool.self) ?? false
	}
	
	func sendRequest<T: Encodable, T2: Decodable>(path: String, method: String, body: T, expect: T2.Type)async ->T2?{
		let url = baseURL.customAppendingPath(path: path)
		var r: URLRequest = .init(url: url)
		r.httpMethod = method
		do{
			if T.self != Blank.self{
				let data = try encoder.encode(body)
				r.httpBody = data
			}
			do{
				let (respData, response) = try await URLSession.shared.asyncData(with: r)
				let urlResp = response as! HTTPURLResponse
				let wentOK = urlResp.statusCode >= 200 && urlResp.statusCode <= 299
				guard wentOK else {
					print("Error \(urlResp.statusCode) for request at \(url)")
					if T2.self == Bool.self{
						return (false as! T2)
					}
					return nil
				}
				guard expect != Bool.self else {return (true as! T2)}
				guard expect != Blank.self else {return (Blank() as! T2)}
				do{
					let decoded = try decoder.decode(expect, from: respData)
					return decoded
				}catch{
					reportError(title: "Error decoding response", error)
					return nil
				}
			}catch{
				reportError(title: "Error sending request to \(url)", error)
				return nil
			}
		}catch{
			reportError(title: "Error encoding payload", error)
			return nil
		}
		
	}
	private let pageCapacity: Int
	public func generateModels(modelCount: Int) async -> Bool{
		return await sendRequest(path: "generate/\(modelCount)", method: "GET")
	}
	public func generateModels(modelCount: Int, xSeed: UInt64, ySeed: UInt64) async -> Bool{
		return await sendRequest(path: "generate/\(modelCount)/\(xSeed)/\(ySeed)", method: "GET")
	}
//	public func getAll() async -> [String: [PSItem]]?{
//		return await sendRequest(path: "models", method: "GET", expect: [String: [PSItem]].self)
//	}
	public func getItem(itemCode: String) async -> PSItem? {
		return await sendRequest(path: "item/"+itemCode, method: "GET", expect: PSItem.self)
	}
	public func reset() async -> Bool{
		return await sendRequest(path: "reset/all", method: "GET")
	}
//	public func getAllItemsCount()async->Int?{
//		return await sendRequest(path: "items/count", method: "GET", expect: Wrapper<Int>.self).map(\.content)
//	}
//
	
}
extension Collection{
	func firstResult<T>(where producedThing: (Element)->T?)->T?{
		for item in self{
			if let thing = producedThing(item){
				return thing
			}
		}
		return nil
	}
	public func getPaginatedSlice(pageNumber: Int, pageSize: Int) async -> [Element]? {
		let itemsToSkip = (pageNumber-1)*pageSize
		let indexOffset = itemsToSkip
		let lastReachableIndex = self.count-1
		let lastWantedIndex = Swift.min(lastReachableIndex, indexOffset+pageSize-1)
		guard lastWantedIndex <= indexOffset else {return nil}
		let indicesArray = Array(self.indices)
		return indicesArray.map{self[$0]}
		
		/**
		 page 1:
		 start	end
		 item0	item99
		 itemsToSkip: 0
		 
		 page2:
		 start	end
		 item100	item199
		 itemsToSkip: 100 ([0]->[99])
		 
		 page 3:
		 start	end
		 item200	item299
		 itemsToSkip: 200([0]->[199])
		 
		 page n:
		 start			end
		 item[(n-1)*100]	item[(n-1)*100+99]
		 itemsToSkip: (n-1)*100
		 */
	}
}
extension Dictionary where Value: RangeReplaceableCollection{
	func allValuesAsOneCollection()->Value{
		let s = Value()
		return values.reduce(into: s){bigassCollection, collection in
			bigassCollection.append(contentsOf: collection)
		}
	}
}
func requestAll<T, Input>(inputs: Array<Input>, getter: @escaping (Input)async->[T]?)async->[T]?{
	return await withTaskGroup(of: [T]?.self, returning: [T]?.self){taskGroup in
		for input in inputs{
			taskGroup.addTask{await getter(input)}
		}
		return await taskGroup.reduce(into: [T]?.init([])){
			guard $0 != nil, let some = $1 else {$0=nil;return}
			$0?.append(contentsOf: some)
		}
	}
}
public extension URL{
	func customAppendingPath(path: String)->Self{
		let u: URL = .init(string: path)!
		var s = self
		for p in u.pathComponents{
			s = s.appendingPathComponent(p)
		}
		return s
	}
}
