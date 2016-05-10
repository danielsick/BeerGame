import UIKit

class StatisticsTabBarController: UITabBarController {

    // MARK: - Model
    // Public API, then private
    var game: Game? {
        didSet {
            self.title = game?.name
        }
    }
}
