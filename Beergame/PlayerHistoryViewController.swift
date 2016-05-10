import UIKit
import Charts

class HistoryViewController: UIViewController, ChartViewDelegate {

    // MARK: - Model
    // Public API, then private
    var game: Game?
    var playsheetEntries: [PlaysheetEntry]?
    
    // MARK: - Outlets
    @IBOutlet weak var YourOrderIncomingDeliveryLineChartView: LineChartView!
    @IBOutlet weak var BackorderInventoryLineChartView: LineChartView!
    @IBOutlet weak var IncomingOrderYourDeliveryLineChartView: LineChartView!
    @IBOutlet weak var CostLineChartView: LineChartView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.YourOrderIncomingDeliveryLineChartView.hidden = false
            self.BackorderInventoryLineChartView.hidden = true
            self.IncomingOrderYourDeliveryLineChartView.hidden = true
            self.CostLineChartView.hidden = true
            break
        case 1:
            self.YourOrderIncomingDeliveryLineChartView.hidden = true
            self.BackorderInventoryLineChartView.hidden = false
            self.IncomingOrderYourDeliveryLineChartView.hidden = true
            self.CostLineChartView.hidden = true
            break
        case 2:
            self.YourOrderIncomingDeliveryLineChartView.hidden = true
            self.BackorderInventoryLineChartView.hidden = true
            self.IncomingOrderYourDeliveryLineChartView.hidden = false
            self.CostLineChartView.hidden = true
            break
        case 3:
            self.YourOrderIncomingDeliveryLineChartView.hidden = true
            self.BackorderInventoryLineChartView.hidden = true
            self.IncomingOrderYourDeliveryLineChartView.hidden = true
            self.CostLineChartView.hidden = false
            break
        default:
            break
        }
    }
    
    // MARK: - Controller Lifecycle
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        initializeYourOrderIncomingDeliveryLineChartView()
        initializeBackorderInventoryLineChartView()
        initializeIncomingOrderYourDeliveryLineChartView()
        initializeCostLineChartView()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        if self.game == nil {
            self.game = (super.tabBarController as! PlayTabBarController).game
        }
        
        fetchPlaysheetEntries()
    }
    
    // MARK: - Private Methods
    /**
    Formats the your order/incoming delivery chart.
    */
    private func initializeYourOrderIncomingDeliveryLineChartView() {
        
        self.YourOrderIncomingDeliveryLineChartView.delegate = self
        self.YourOrderIncomingDeliveryLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.YourOrderIncomingDeliveryLineChartView.noDataText = "No order/delivery data found"
        self.YourOrderIncomingDeliveryLineChartView.descriptionText = ""
        self.YourOrderIncomingDeliveryLineChartView.dragEnabled = false
        self.YourOrderIncomingDeliveryLineChartView.highlightPerTapEnabled = false
        self.YourOrderIncomingDeliveryLineChartView.scaleXEnabled = false
        self.YourOrderIncomingDeliveryLineChartView.scaleYEnabled = false
        self.YourOrderIncomingDeliveryLineChartView.rightAxis.enabled = false
        self.YourOrderIncomingDeliveryLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.YourOrderIncomingDeliveryLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.YourOrderIncomingDeliveryLineChartView.hidden = false
    }
    
    /**
     Formats the backorder/inventory chart.
     */
    private func initializeBackorderInventoryLineChartView() {
        
        self.BackorderInventoryLineChartView.delegate = self
        self.BackorderInventoryLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.BackorderInventoryLineChartView.noDataText = "No backorder/inventory data found"
        self.BackorderInventoryLineChartView.descriptionText = ""
        self.BackorderInventoryLineChartView.dragEnabled = false
        self.BackorderInventoryLineChartView.highlightPerTapEnabled = false
        self.BackorderInventoryLineChartView.scaleXEnabled = false
        self.BackorderInventoryLineChartView.scaleYEnabled = false
        self.BackorderInventoryLineChartView.rightAxis.enabled = false
        self.BackorderInventoryLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.BackorderInventoryLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.BackorderInventoryLineChartView.hidden = true
    }
    
    /**
     Formats the incoming order/your delivery chart.
     */
    private func initializeIncomingOrderYourDeliveryLineChartView() {
        
        self.IncomingOrderYourDeliveryLineChartView.delegate = self
        self.IncomingOrderYourDeliveryLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.IncomingOrderYourDeliveryLineChartView.noDataText = "No order/delivery data found"
        self.IncomingOrderYourDeliveryLineChartView.descriptionText = ""
        self.IncomingOrderYourDeliveryLineChartView.dragEnabled = false
        self.IncomingOrderYourDeliveryLineChartView.highlightPerTapEnabled = false
        self.IncomingOrderYourDeliveryLineChartView.scaleXEnabled = false
        self.IncomingOrderYourDeliveryLineChartView.scaleYEnabled = false
        self.IncomingOrderYourDeliveryLineChartView.rightAxis.enabled = false
        self.IncomingOrderYourDeliveryLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.IncomingOrderYourDeliveryLineChartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
        self.IncomingOrderYourDeliveryLineChartView.hidden = true
    }
    
    /**
     Formats the cost chart.
     */
    private func initializeCostLineChartView() {
        
        self.CostLineChartView.delegate = self
        self.CostLineChartView.gridBackgroundColor = UIColor.whiteColor()
        self.CostLineChartView.noDataText = "No cost data found"
        self.CostLineChartView.descriptionText = ""
        self.CostLineChartView.dragEnabled = false
        self.CostLineChartView.highlightPerTapEnabled = false
        self.CostLineChartView.scaleXEnabled = false
        self.CostLineChartView.scaleYEnabled = false
        self.CostLineChartView.rightAxis.enabled = false
        self.CostLineChartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.CostLineChartView.leftAxis.valueFormatter?.numberStyle = .CurrencyStyle
        self.CostLineChartView.hidden = true
    }
    
    /**
     Updates the history by getting the playsheet entries for the current game and user.
     Calls reloadData afterwards.
     */
    private func fetchPlaysheetEntries() {
        
        BeergameAPI.getHistoryOfUserOfGame((self.game?.gameId)!, userId: PreferencesManager.loadValueForKey("userid") as! Int) { (response) -> Void in
            
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
     Reloads the graphs with data from playsheetEntries.
     */
    private func reloadData() {
        
        var yourOrder: [Int] = [Int]()
        var incomingDelivery: [Int] = [Int]()
        var backorder: [Int] = [Int]()
        var inventory: [Int] = [Int]()
        var incomingOrder: [Int] = [Int]()
        var yourDelivery: [Int] = [Int]()
        var costs: [Double] = [Double]()

        for entry in self.playsheetEntries! {
            yourOrder.append(entry.requestedOrder)
            incomingDelivery.append(entry.incomingDelivery!)
            backorder.append(entry.backorder!)
            inventory.append(entry.inventory!)
            incomingOrder.append(entry.incomingOrder!)
            yourDelivery.append(entry.outgoingDelivery!)
            costs.append(entry.cost!)
        }
        
        guard let entryCount = self.playsheetEntries?.count else {
            return
        }

        setYourOrderIncomingDeliveryChartData(entryCount, yourOrder: yourOrder, incomingDelivery: incomingDelivery)
        setBackorderInventoryChartData(entryCount, backorder: backorder, inventory: inventory)
        setIncomingOrderYourDeliveryChartData(entryCount, incomingOrder: incomingOrder, yourDelivery: yourDelivery)
        setCostLineChartData(entryCount, costs: costs)
    }
    
    private func log(whatToLog: AnyObject) {
        debugPrint("HistoryViewController: \(whatToLog)")
    }
    
    /**
     Draws your order/incoming delivery graph.
     */
    private func setYourOrderIncomingDeliveryChartData(week: Int, yourOrder: [Int], incomingDelivery: [Int]) {
        
        // Define y-axis labels
        let tempArray = yourOrder + incomingDelivery
        let minMax = GraphHelper.getMinMaxWithoutNegatives(tempArray)
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.YourOrderIncomingDeliveryLineChartView.leftAxis.customAxisMin = minMax.0
            self.YourOrderIncomingDeliveryLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        // Path for yourOrder
        let yVals1 = GraphHelper.createYVals(week, values: yourOrder)
        let set1: LineChartDataSet = GraphHelper.createSet(yVals1, label: "Your Order")
        set1.setColor(UIColor.greenColor())
        
        // Path for incomingDelivery
        let yVals2 = GraphHelper.createYVals(week, values: incomingDelivery)
        let set2: LineChartDataSet = GraphHelper.createSet(yVals2, label: "Incoming Delivery")
        set2.setColor(UIColor.yellowColor())
        
        // Add paths
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.YourOrderIncomingDeliveryLineChartView.data = data
    }
    
    /**
     Draws backorder/inventory graph with provided data. The graph gets negative if backorders exist.
     - parameters:
        - week: Number of the current week.
        - backorder: Array of backorders per week.
        - inventory: Array of inventory per week.
     */
    private func setBackorderInventoryChartData(week: Int, backorder: [Int], inventory: [Int]) {
        
        // Getting the right values
        var values: [Int] = [Int]()
        for i in 0...(week-1) {
            
            if inventory[i]==0 && backorder[i]>0 {
                values.append(-backorder[i])
                
            } else if inventory[i]>0 && backorder[i]==0 {
                values.append(inventory[i])
                
            } else {
                values.append(0)
            }
        }
        
        // Define y-axis labels
        let minMax = GraphHelper.getMinMax([Int](values))
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.BackorderInventoryLineChartView.leftAxis.customAxisMin = minMax.0
            self.BackorderInventoryLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        // Path for backorder/inventory
        let yVals = GraphHelper.createYVals(week, values: values)
        let set = GraphHelper.createSet(yVals, label: "Backorder/Inventory")
        
        // Change color to red if backorders exist
        if values.last < 0 {
            set.setColor(UIColor.redColor())
        } else {
            set.setColor(UIColor.greenColor())
        }
        
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set)
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        
        self.BackorderInventoryLineChartView.leftAxis.startAtZeroEnabled = false
        self.BackorderInventoryLineChartView.data = data
    }
    
    /**
     Draws incoming order/your delivery graph.
     - parameters:
        - week: Number of the current week.
        - incomingOrder: Array of incoming orders per week.
        - yourDelivery: Array of outgoing deliveries per week.
     */
    private func setIncomingOrderYourDeliveryChartData(week: Int, incomingOrder: [Int], yourDelivery: [Int]) {
        
        // Define y-axis labels
        let tempArray = incomingOrder + yourDelivery
        let minMax = GraphHelper.getMinMaxWithoutNegatives([Int](tempArray))
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.IncomingOrderYourDeliveryLineChartView.leftAxis.customAxisMin = minMax.0
            self.IncomingOrderYourDeliveryLineChartView.leftAxis.customAxisMax = minMax.1
        }
        
        // Path for incomingOrder
        let yVals1 = GraphHelper.createYVals(week, values: incomingOrder)
        let set1 = GraphHelper.createSet(yVals1, label: "Incoming Order")
        set1.drawCirclesEnabled = true
        set1.setCircleColor(UIColor.yellowColor())
        set1.setColor(UIColor.yellowColor())
        set1.circleRadius = 3
        
        // Path for yourDelivery
        let yVals2 = GraphHelper.createYVals(week, values: yourDelivery)
        let set2 = GraphHelper.createSet(yVals2, label: "Your Delivery")
        set2.setColor(UIColor.greenColor())
        
        // Add paths
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        
        self.IncomingOrderYourDeliveryLineChartView.data = data
    }
    
    /**
     Draws cost graph with the data provided.
     - parameters:
        - week: Number of the current week.
        - costs: Array of costs per week.
     */
    private func setCostLineChartData(week: Int, costs: [Double]) {
        
        // Path for costs
        let yVals = GraphHelper.createYVals(week, values: costs)
        let set = GraphHelper.createSet(yVals, label: "Costs")
        set.setColor(UIColor.redColor())
        set.drawCubicEnabled = true
        
        // Add path
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set)
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        
        self.CostLineChartView.data = data
    }
}
