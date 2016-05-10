import Foundation
import Security

class PreferencesManager {
    
    /**
     Saves value by key in NSUserDefaults.
    */
    class func saveValue(value: AnyObject?, key: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
     Loads value by key from NSUserDefaults.
    */
    class func loadValueForKey(key: String) -> AnyObject? {
        let r: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(key)
        return r
    }
    
    /**
     Deletes value by key from NSUserDefaults.
    */
    class func deleteValueForKey(key: String) -> Void {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
}