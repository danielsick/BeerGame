import UIKit
import Charts

class StatisticsHistoryViewController: UIViewController, ChartViewDelegate {

    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            fetchPlayersAndHost()
        }
    }
    var playsheetEntries: [PlaysheetEntry]?
    var host: User?
    var users = [User]()
    
    let colorsHighAlpha: [UIColor] = [
        UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1),
        UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1),
        UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1),
        UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1),
        UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1),
        UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1),
        UIColor(red: 125/255, green: 0/255, blue: 0/255, alpha: 1),
        UIColor(red: 0/255, green: 125/255, blue: 0/255, alpha: 1),
        UIColor(red: 0/255, green: 0/255, blue: 125/255, alpha: 1),
    ]
    
    let colorsLowAlpha: [UIColor] = [
        UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.3),
        UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 0.3),
        UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.3),
        UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 0.3),
        UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 0.3),
        UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 0.3),
        UIColor(red: 125/255, green: 0/255, blue: 0/255, alpha: 0.3),
        UIColor(red: 0/255, green: 125/255, blue: 0/255, alpha: 0.3),
        UIColor(red: 0/255, green: 0/255, blue: 125/255, alpha: 0.3),
    ]
    
    var colorCount: Int = Int()
    
    // MARK: - Outlets
    @IBOutlet weak var PlayerOrdersLineChartView: LineChartView!
    @IBOutlet weak var InventoriesLineChartView: LineChartView!
    @IBOutlet weak var IncomingOrdersLineChartView: LineChartView!
    @IBOutlet weak var CostsLineChartView: LineChartView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedValueChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.PlayerOrdersLineChartView.hidden = false
            self.InventoriesLineChartView.hidden = true
            self.IncomingOrdersLineChartView.hidden = true
            self.CostsLineChartView.hidden = true
            break
        case 1:
            self.PlayerOrdersLineChartView.hidden = true
            self.InventoriesLineChartView.hidden = false
            self.IncomingOrdersLineChartView.hidden = true
            self.CostsLineChartView.hidden = true
            break
        case 2:
            self.PlayerOrdersLineChartView.hidden = true
            self.InventoriesLineChartView.hidden = true
            self.IncomingOrdersLineChartView.hidden = false
            self.CostsLineChartView.hidden = true
            break
        case 3:
            self.PlayerOrdersLineChartView.hidden = true
            self.InventoriesLineChartView.hidden = true
            self.IncomingOrdersLineChartView.hidden = true
            self.CostsLineChartView.hidden = false
            break
        default:
            break
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorCount = colorsHighAlpha.count
        
        initializePlayerOrdersLineChartView()
        initializeInventoriesLineChartView()
        initializeIncomingOrdersLineChartView()
        initializeCostsLineChartView()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        if self.game == nil {
            self.game = (super.tabBarController as! StatisticsTabBarController).game
        }
    }
    
    // MARK: - Private Methods
    /**
    Formats the orders chart.
    */
    private func initializePlayerOrdersLineChartView() {
        
        self.PlayerOrdersLineChartView.delegate = self
        self.PlayerOrdersLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.PlayerOrdersLineChartView.noDataText = "No order/delivery data found"
        self.PlayerOrdersLineChartView.descriptionText = ""
        self.PlayerOrdersLineChartView.dragEnabled = false
        self.PlayerOrdersLineChartView.highlightPerTapEnabled = false
        self.PlayerOrdersLineChartView.scaleXEnabled = false
        self.PlayerOrdersLineChartView.scaleYEnabled = false
        self.PlayerOrdersLineChartView.rightAxis.enabled = false
        self.PlayerOrdersLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.PlayerOrdersLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.PlayerOrdersLineChartView.hidden = false
    }
    
    /**
     Formats the backorder/inventory chart.
     */
    private func initializeInventoriesLineChartView() {
        
        self.InventoriesLineChartView.delegate = self
        self.InventoriesLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.InventoriesLineChartView.noDataText = "No backorder/inventory data found"
        self.InventoriesLineChartView.descriptionText = ""
        self.InventoriesLineChartView.dragEnabled = false
        self.InventoriesLineChartView.highlightPerTapEnabled = false
        self.InventoriesLineChartView.scaleXEnabled = false
        self.InventoriesLineChartView.scaleYEnabled = false
        self.InventoriesLineChartView.rightAxis.enabled = false
        self.InventoriesLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.InventoriesLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.InventoriesLineChartView.hidden = true
    }
    
    /**
     Formats the deliveries chart.
     */
    private func initializeIncomingOrdersLineChartView() {
        
        self.IncomingOrdersLineChartView.delegate = self
        self.IncomingOrdersLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.IncomingOrdersLineChartView.noDataText = "No order/delivery data found"
        self.IncomingOrdersLineChartView.descriptionText = ""
        self.IncomingOrdersLineChartView.dragEnabled = false
        self.IncomingOrdersLineChartView.highlightPerTapEnabled = false
        self.IncomingOrdersLineChartView.scaleXEnabled = false
        self.IncomingOrdersLineChartView.scaleYEnabled = false
        self.IncomingOrdersLineChartView.rightAxis.enabled = false
        self.IncomingOrdersLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.IncomingOrdersLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.IncomingOrdersLineChartView.hidden = true
    }
    
    /**
     Formats the costs chart.
     */
    private func initializeCostsLineChartView() {
        
        self.CostsLineChartView.delegate = self
        self.CostsLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.CostsLineChartView.noDataText = "No cost data found"
        self.CostsLineChartView.descriptionText = ""
        self.CostsLineChartView.dragEnabled = false
        self.CostsLineChartView.highlightPerTapEnabled = false
        self.CostsLineChartView.scaleXEnabled = false
        self.CostsLineChartView.scaleYEnabled = false
        self.CostsLineChartView.rightAxis.enabled = false
        self.CostsLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.CostsLineChartView.leftAxis.valueFormatter?.numberStyle = .CurrencyStyle
        self.CostsLineChartView.hidden = true
    }
    
    /**
     Gets players and hosts for the current game and saves them in model.
     Calls fetchPlaysheetEntries afterwards.
     */
    private func fetchPlayersAndHost() {
        let gameId = game?.gameId!
        
        BeergameAPI.getUsersOfGame(gameId!) { (response) -> Void in
            switch response.result {
            case .Success(let usersOfGame):
                // 200 OK
                if usersOfGame.count > 0 {
                    // Save users & host in model
                    self.users.removeAll()
                    for user in usersOfGame {
                        self.users.insert(user, atIndex: 0)
                    }
                    
                    self.users = self.users.reverse()
                    self.host = self.users[0]
                    
                    // Update playsheet
                    dispatch_async(dispatch_get_main_queue()) {
                        self.fetchPlaysheetEntries()
                    }
                }
            case .Failure:
                // Error handling
                let error = "Couldn't fetch players."
                self.log(error)
                return
            }
        }
    }
    
    /**
     Updates the statistics history by getting the playsheet entries for the current game.
     Calls reloadData afterwards.
     */
    private func fetchPlaysheetEntries() {
        
        BeergameAPI.getHistoryOfGame((self.game?.gameId)!) { (response) -> Void in
            
            switch response.result {
            case .Success(let playsheet):
                // 200 OK
                if playsheet.count == 0 {
                    return
                }
                
                self.playsheetEntries = [PlaysheetEntry]()
                
                for entry in playsheet {
                    self.playsheetEntries?.append(entry)
                }
                
                // Update graphs
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.reloadData()
                }
            case .Failure:
                // Error handling
                let error = "Couldn't fetch playsheet entries."
                self.log(error)
            }
        }
    }
    
    /**
     Reloads the graphs.
     */
    private func reloadData() {

        guard var weeks = self.playsheetEntries?.count else {
            return
        }
        weeks /= users.count
        
        self.setPlayerOrdersIncomingDeliveriesChartData(weeks)
        self.setBackordersInventoriesChartData(weeks)
        self.setIncomingOrdersPlayerDeliveriesChartData(weeks)
        self.setCostsLineChartData(weeks)
    }
    
    private func log(whatToLog: AnyObject) {
        debugPrint("HistoryViewController: \(whatToLog)")
    }

    /**
     Draws player orders/incoming deliveries graph.
     
     - parameters:
        - week: Number of the last week.
     */
    private func setPlayerOrdersIncomingDeliveriesChartData(week: Int) {
        
        // Define y-axis labels
        var tempArray: [Int] = [Int]()
        for entry in self.playsheetEntries! {
            
            tempArray.append(entry.requestedOrder)
            if let delivery = entry.incomingDelivery {
                tempArray.append(delivery)
            }
        }
        
        let minMax = GraphHelper.getMinMaxWithoutNegatives(tempArray)
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.PlayerOrdersLineChartView.leftAxis.customAxisMin = minMax.0
            self.PlayerOrdersLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        
        // Paths for player orders and incoming deliveries
        for var i = 0; i<users.count; i++ {
            
            let usr = users[i]
            
            var playerOrder: [Int] = [Int]()
            if usr.userId == host?.userId {
                
                for entry in self.playsheetEntries! {
                    if usr.userId == entry.user.userId {
                        playerOrder.append(entry.requestedOrder)
                    }
                }
                
            } else {
                
                var incomingDelivery: [Int] = [Int]()
                for entry in self.playsheetEntries! {
                    if usr.userId == entry.user.userId {
                        playerOrder.append(entry.requestedOrder)
                        incomingDelivery.append(entry.incomingDelivery!)
                    }
                }
                let yVals = GraphHelper.createYVals(week, values: incomingDelivery)
                let set: LineChartDataSet = GraphHelper.createSet(yVals, label: "\(usr.name) (i. Del.)")
                set.setColor(colorsLowAlpha[i % colorCount])
                dataSets.append(set)
            }
            
            let yVals = GraphHelper.createYVals(week, values: playerOrder)
            let set: LineChartDataSet = GraphHelper.createSet(yVals, label: "\(usr.name) (o. Ord.)")
            set.setColor(colorsHighAlpha[i % colorCount])
            dataSets.append(set)
        }
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.PlayerOrdersLineChartView.data = data
    }
    
    /**
     Draws backorders/inventories graph with provided data. The graph gets negative if backorders exist.
     - parameters:
        - week: Number of the last week.
     */
    private func setBackordersInventoriesChartData(week: Int) {
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        
        var tempArray: [Int] = [Int]()
        
        // Paths for backorders/inventories
        for var i = 0; i<users.count; ++i {
            
            let usr = users[i]
            
            if self.host?.userId == usr.userId {
                continue
            }
            
            // Getting the right values
            var values: [Int] = [Int]()
            for entry in self.playsheetEntries! {
                if usr.userId == entry.user.userId {
                    let backorder = entry.backorder!
                    let inventory = entry.inventory!
                    
                    if inventory==0 && backorder>0 {
                        values.append(-backorder)
                        tempArray.append(-backorder)
                        
                    } else if inventory>0 && backorder==0 {
                        values.append(inventory)
                        tempArray.append(inventory)
                        
                    } else {
                        values.append(0)
                        tempArray.append(0)
                    }
                }
            }
            let yVals = GraphHelper.createYVals(week, values: values)
            let set: LineChartDataSet = GraphHelper.createSet(yVals, label: usr.name)
            set.setColor(colorsHighAlpha[i % colorCount])
            dataSets.append(set)
        }
        
        // Define y-axis labels
        let minMax = GraphHelper.getMinMax([Int](tempArray))
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.InventoriesLineChartView.leftAxis.customAxisMin = minMax.0
            self.InventoriesLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.InventoriesLineChartView.data = data
    }
    
    /**
     Draws incoming orders/player deliveries graph.
     
     - parameters:
        - week: Number of the last week.
     */
    private func setIncomingOrdersPlayerDeliveriesChartData(week: Int) {
        
        // Define y-axis labels
        var tempArray: [Int] = [Int]()
        for entry in self.playsheetEntries! {
            
            if self.host?.userId == entry.user.userId {
                continue
            }
            tempArray.append(entry.incomingOrder!)
            tempArray.append(entry.outgoingDelivery!)
        }
        
        let minMax = GraphHelper.getMinMaxWithoutNegatives(tempArray)
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.IncomingOrdersLineChartView.leftAxis.customAxisMin = minMax.0
            self.IncomingOrdersLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        
        // Paths for incoming orders and player deliveries
        for var i = 0; i<users.count; ++i {
            
            let usr = users[i]
            
            if self.host?.userId == usr.userId {
                continue
            }
            
            var incomingOrder: [Int] = [Int]()
            var playerDelivery: [Int] = [Int]()
            for entry in self.playsheetEntries! {
                if usr.userId == entry.user.userId {
                    incomingOrder.append(entry.incomingOrder!)
                    playerDelivery.append(entry.outgoingDelivery!)
                }
            }
            let yVals1 = GraphHelper.createYVals(week, values: incomingOrder)
            let set1: LineChartDataSet = GraphHelper.createSet(yVals1, label: "\(usr.name) (i. Ord.)")
            set1.setColor(colorsHighAlpha[i % colorCount])
            dataSets.append(set1)
            
            let yVals2 = GraphHelper.createYVals(week, values: playerDelivery)
            let set2: LineChartDataSet = GraphHelper.createSet(yVals2, label: "\(usr.name) (o. Del.)")
            set2.setColor(colorsLowAlpha[i % colorCount])
            dataSets.append(set2)
        }
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.IncomingOrdersLineChartView.data = data
    }
    
    /**
     Draws costs graph with the data provided.
     
     - parameters:
        - week: Number of the last week.
     */
    private func setCostsLineChartData(week: Int) {
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        
        // Paths for costs
        for var i = 0; i<users.count; ++i {
            
            let usr = users[i]
            
            if self.host?.userId == usr.userId {
                continue
            }
            
            var cost: [Double] = [Double]()
            for entry in self.playsheetEntries! {
                if usr.userId == entry.user.userId {
                    cost.append(entry.cost!)
                }
            }
            let yVals = GraphHelper.createYVals(week, values: cost)
            let set: LineChartDataSet = GraphHelper.createSet(yVals, label: usr.name)
            set.setColor(colorsHighAlpha[i % colorCount])
            dataSets.append(set)
        }
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.CostsLineChartView.data = data
    }
}
