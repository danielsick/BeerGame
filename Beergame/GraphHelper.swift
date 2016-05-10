import Foundation
import Charts


class GraphHelper {
    
    static let numberOfNeededYAxisValues = 7
    
    /**
     Creates an array of ChartDataEntries to define the y-values of a path
     
     @param max Number of entries
     
     @param values Array of numbers for y-values
     
     @return ChartDataEntries to be used in a LineChartSet
     */
    static func createYVals(max: Int, values: [NSNumber]) -> [ChartDataEntry] {
        
        var yVals: [ChartDataEntry] = [ChartDataEntry]()

        if max != 1 {
            for var i = 0; i<max; i++ {
                yVals.append(ChartDataEntry(value: Double(values[i]), xIndex: i))
            }
        } else { // If only 1 value is provided, a graph parallel to the x-axis is drawn
            yVals.append(ChartDataEntry(value: Double(values[0]), xIndex: 0))
            yVals.append(ChartDataEntry(value: Double(values[0]), xIndex: 1))
        }
        
        return yVals
    }
    
    /**
     Creates a set for a chart from ChartDataEntries to define a path
     
     @param yVals Points of the path to be defined
     
     @param label Name of the path that is displayed at the bottom of the graph
     
     @return A set that can be used in the data of a LineChartData
     */
    static func createSet(yVals: [ChartDataEntry], label: String) -> LineChartDataSet {
        
        let set: LineChartDataSet = LineChartDataSet(yVals: yVals, label: label)
        set.axisDependency = .Left
        set.drawCircleHoleEnabled = false
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        
        return set
    }
    
    /**
     Calculates custom min and max values for y labels with min >= 0
     
     @param array All possible values for every graph in the chart
     
     @return Returns (min, max) or (-1, -1) in case no custom values are needed
     */
    static func getMinMaxWithoutNegatives(array: [Int]) -> (Double, Double) {
        
        let minMax = getMinMax(array)
        var min = minMax.0
        var max = minMax.1
        
        if min == -1 && max == -1 {
            return (-1, -1)
        }
        
        max = (min >= 0 ? max : max - min)
        min = (min >= 0 ? min : 0)
        return (min, max)
    }
    
    /**
     Calculates custom min and max values for y labels
     
     @param array All possible values for every graph in the chart
     
     @return Returns (min, max) or (-1, -1) in case no custom values are needed
     */
    static func getMinMax(array: [Int]) -> (Double, Double) {
        
        var smallestValueInArray: Int = array.first!
        var biggestValueInArray: Int = array.first!
        var min = -1.0
        var max = -1.0
        
        for x in array {
            if x<smallestValueInArray {
                smallestValueInArray = x
            } else if x>biggestValueInArray {
                biggestValueInArray = x
            }
        }
        
        let difference = biggestValueInArray - smallestValueInArray
        if difference < numberOfNeededYAxisValues {
            min = Double(smallestValueInArray - ((numberOfNeededYAxisValues-difference) / 2))
            max = Double(biggestValueInArray + ((numberOfNeededYAxisValues-difference) / 2))
        }
        
        return (min, max)
    }
    
    static func getWeeksAsStringsUntil(highestWeek: Int) -> [String] {
        var weeks: [String] = [String]()

        for i in 1...(highestWeek) {
            weeks.append(String(i))
        }
        
        if highestWeek == 1 {
            weeks.append("")
        }

        return weeks
    }
}