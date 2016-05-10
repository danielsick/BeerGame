import UIKit
import Charts

class AdminHistoryViewController: UIViewController, ChartViewDelegate {

    // MARK: - Model
    // Public API, then private
    var game: Game?
    var playsheetEntries: [PlaysheetEntry]?
    
    // MARK: - Outlets
    @IBOutlet weak var YourOrderLinechartView: LineChartView!

    // MARK: - Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeYourOrderLineChartView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.game == nil {
            self.game = (super.tabBarController as! PlayTabBarController).game
        }
        
        fetchPlayersheetEntries()
    }

    // MARK: - Private Methods
    /**
    Formats the your order chart.
    */
    private func initializeYourOrderLineChartView() {
        
        self.YourOrderLinechartView.delegate = self
        self.YourOrderLinechartView.gridBackgroundColor = UIColor.whiteColor()
        self.YourOrderLinechartView.noDataText = "No order data found"
        self.YourOrderLinechartView.descriptionText = ""
        self.YourOrderLinechartView.dragEnabled = false
        self.YourOrderLinechartView.highlightPerTapEnabled = false
        self.YourOrderLinechartView.scaleXEnabled = false
        self.YourOrderLinechartView.scaleYEnabled = false
        self.YourOrderLinechartView.rightAxis.enabled = false
        self.YourOrderLinechartView.leftAxis.valueFormatter = NSNumberFormatter()
        self.YourOrderLinechartView.leftAxis.valueFormatter?.minimumFractionDigits = 0
    }
    
    /**
     Draws your order graph.
     */
    private func setYourOrderChartData(week: Int, yourOrder: [Int]) {
        
        // Define y-axis labels
        let minMax = GraphHelper.getMinMaxWithoutNegatives(yourOrder)
        if !(minMax.0 == -1 && minMax.1 == -1) {
            self.YourOrderLinechartView.leftAxis.customAxisMax = minMax.0
            self.YourOrderLinechartView.leftAxis.customAxisMax = minMax.1
        }
        
        //Path for yourOrder
        let yVals = GraphHelper.createYVals(week, values: yourOrder)
        let set: LineChartDataSet = GraphHelper.createSet(yVals, label: "Your Order")
        set.setColor(UIColor.greenColor())
        
        //Add path
        var dataSets: [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set)
        
        let weeks = GraphHelper.getWeeksAsStringsUntil(week)
        
        let data: LineChartData = LineChartData(xVals: weeks, dataSets: dataSets)
        self.YourOrderLinechartView.data = data
    }
    
    /**
     Updates the history by getting the playsheet entries for the current game and user.
     Calls reloadData afterwards.
     */
    private func fetchPlayersheetEntries() {
        
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
     Reloads the graph with data from playsheetEntries.
     */
    private func reloadData() {
        
        var yourOrder: [Int] = [Int]()
        
        var entryCount = 0

        for entry in self.playsheetEntries! {
            entryCount++
            yourOrder.append(entry.requestedOrder)
        }
        
        setYourOrderChartData(entryCount, yourOrder: yourOrder)
    }
    
    private func log(whatToLog: AnyObject) {
        debugPrint("HistoryViewController: \(whatToLog)")
    }
}
