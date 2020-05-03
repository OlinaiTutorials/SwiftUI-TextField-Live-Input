import SwiftUI
import Cocoa

public struct LoadingView: NSViewRepresentable {
    public typealias NSViewType = NSProgressIndicator
    private var visible: Bool = false
    
    public init(_ visible: Bool) {
        self.visible = visible
    }
    
    public func makeNSView(context: NSViewRepresentableContext<LoadingView>) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.maxValue = 0
        
        return indicator
    }
    
    public func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<LoadingView>) {
        nsView.isHidden = !visible
        
        if visible {
            nsView.startAnimation(self)
        } else {
            nsView.stopAnimation(self)
        }
    }
}
