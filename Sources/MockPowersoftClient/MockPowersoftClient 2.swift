////import PowersoftClient
//public actor MockPowersoftStore: PowersoftClientProtocol{
//	public init(
//		models: [String: [PSItem]],
//		pageItemCapacity: Int = 100,
//		modelsMetadata: [String: PSListModel],
//		stockByItemCode: [String: PSListStockStoresItem]
//	){
//		self.modelItemsByModelCode=models
//		self.pageCapacity=pageItemCapacity
//		self.modelsMetadataByModelCode = modelsMetadata
//		self.stockByItemCode=stockByItemCode
//	}
//	private let pageCapacity: Int
//	private var modelsMetadataByModelCode: [String: PSListModel]
//	private var modelItemsByModelCode: [String: [PSItem]]
//	private var stockByItemCode: [String: PSListStockStoresItem]
//	public func getItem(itemCode: String) async -> PSItem? {
//		return modelItemsByModelCode.values.firstResult(where: {$0.first(where: {item in
//			item.itemCode365==itemCode
//		})})
//	}
//	var allItems: [PSItem]{
//		return modelItemsByModelCode.allValuesAsOneCollection()
//	}
//	var allModelsMetadata: [PSListModel]{
//		return Array(modelsMetadataByModelCode.values)
//	}
//	public func getAllItemsCount(type: eCommerceType) async -> Int? {
//		return allItems.count
//	}
//	
//	public func getItemsPage(page: Int, type: eCommerceType) async -> [PSItem]? {
//		return await allItems.getPaginatedSlice(pageNumber: page, pageSize: pageCapacity)
//	}
//	
//	public func getAllItems(type: eCommerceType) async -> [PSItem]? {
//		return allItems
//	}
//	
//	public func getModel(modelCode: String) async -> [PSItem]? {
//		return modelItemsByModelCode[modelCode]
//	}
//	
//	public func getAllModelsCount(type: eCommerceType) async -> Int? {
//		return modelItemsByModelCode.keys.count
//	}
//	
//	public func getModelsPage(page: Int, type: eCommerceType) async -> [PSListModel]? {
//		return await allModelsMetadata.getPaginatedSlice(pageNumber: page, pageSize: pageCapacity)
//	}
//	
//	public func getAllModels(type: eCommerceType) async -> [PSListModel]? {
//		return allModelsMetadata
//	}
//	
//	public func getStock(for itemCode: String) async -> PSListStockStoresItem? {
//		return stockByItemCode[itemCode]
//	}
//	
//	public func getAllStockCount(type: eCommerceType) async -> Int? {
//		return stockByItemCode.values.count
//	}
//	
//	public func getStocksPage(page: Int, type: eCommerceType) async -> [PSListStockStoresItem]? {
//		return await stockByItemCode.values.getPaginatedSlice(pageNumber: page, pageSize: pageCapacity)
//	}
//	
//	public func getAllStocks(type: eCommerceType) async -> [PSListStockStoresItem]? {
//		return Array(stockByItemCode.values)
//	}
//	
//	
//	
//}
//extension Collection{
//	func firstResult<T>(where producedThing: (Element)->T?)->T?{
//		for item in self{
//			if let thing = producedThing(item){
//				return thing
//			}
//		}
//		return nil
//	}
//	public func getPaginatedSlice(pageNumber: Int, pageSize: Int) async -> [Element]? {
//		let itemsToSkip = (pageNumber-1)*pageSize
//		let indexOffset = itemsToSkip
//		let lastReachableIndex = self.count-1
//		let lastWantedIndex = Swift.min(lastReachableIndex, indexOffset+pageSize-1)
//		guard lastWantedIndex <= indexOffset else {return nil}
//		let indicesArray = Array(self.indices)
//		return indicesArray.map{self[$0]}
//		
//		/**
//		 page 1:
//		 start	end
//		 item0	item99
//		 itemsToSkip: 0
//		 
//		 page2:
//		 start	end
//		 item100	item199
//		 itemsToSkip: 100 ([0]->[99])
//		 
//		 page 3:
//		 start	end
//		 item200	item299
//		 itemsToSkip: 200([0]->[199])
//		 
//		 page n:
//		 start			end
//		 item[(n-1)*100]	item[(n-1)*100+99]
//		 itemsToSkip: (n-1)*100
//		 */
//	}
//}
//extension Dictionary where Value: RangeReplaceableCollection{
//	func allValuesAsOneCollection()->Value{
//		let s = Value()
//		return values.reduce(into: s){bigassCollection, collection in
//			bigassCollection.append(contentsOf: collection)
//		}
//	}
//}
