import Foundation
import Combine

public class LiveValue<T> where T: Comparable {
    private var publisher: CurrentValueSubject<T, Never>
    private var oldValue: T
    
    public var rawValue: T {
        willSet {
            guard newValue != oldValue else { return }
            
            // only publish new values
            publisher.send(newValue)
            oldValue = newValue
        }
    }
    
    public init(_ value: T) {
        rawValue = value
        oldValue = value
        publisher = CurrentValueSubject(value)
    }
        
    public var valueChangedPublisher: AnyPublisher<T, Never> {
        publisher
            .debounce(for: 0.35, scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
