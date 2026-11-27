import FocusCore
import UIKit

final class URLOpener: AppOpening {
    func open(_ url: URL) async -> Bool {
        await UIApplication.shared.open(url)
    }
}
