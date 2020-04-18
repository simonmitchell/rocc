//
//  DispatchQueue+AsyncWhile.swift
//  Rocc
//
//  Created by Simon Mitchell on 18/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    typealias AsyncWhileCompletion = (Bool) -> Void
    
    /// Allows for asynchronous behaviour in a while-loop manner.
    /// - Parameters:
    ///   - closure: The closure in which the `while` logic should be run. The next call of this happens when the closure passed as a single variable to this is called. If true is returned via that closure then the while loop "breaks"
    ///   - timeout: A timeout time interval for the while loop as a fall back to exit it, this will not cut off execution automatically
    ///   - done: A closure which is called when the final while loop completes, either via calling the closure with `true`, or when the timeout has passed when calling the closure with `false`
    func asyncWhile(_ closure: @escaping ((@escaping AsyncWhileCompletion) -> Void), timeout: TimeInterval, done: @escaping () -> Void) {
        
        let deadline = CFAbsoluteTimeGetCurrent() + timeout
        
        // Jump onto this queue synchronously
        async {
                        
            let continueClosure: AsyncWhileCompletion = { [weak self] finished in
                
                guard !finished, CFAbsoluteTimeGetCurrent() < deadline else {
                    
                    // Call done either after timeout or when finished!
                    if Thread.current.isMainThread {
                        DispatchQueue.main.async {
                            done()
                        }
                    } else {
                        DispatchQueue.main.sync {
                            done()
                        }
                    }
                    
                    return
                }
                
                guard let this = self else { return }
                this.asyncWhileRecursive(closure, deadline: deadline,  done: done)
            }
                        
            if Thread.current.isMainThread {
                DispatchQueue.main.async {
                    closure(continueClosure)
                }
            } else {
                DispatchQueue.main.sync {
                    closure(continueClosure)
                }
            }
        }
    }
    
    private func asyncWhileRecursive(_ closure: @escaping ((@escaping AsyncWhileCompletion) -> Void), deadline: TimeInterval, done: @escaping () -> Void) {
        
        async {
            
            let continueClosure: AsyncWhileCompletion = { [weak self] finished in
                
                guard !finished, CFAbsoluteTimeGetCurrent() < deadline else {
                    
                    // Call done either after timeout or when finished!
                    if Thread.current.isMainThread {
                        DispatchQueue.main.async {
                            done()
                        }
                    } else {
                        DispatchQueue.main.sync {
                            done()
                        }
                    }
                    
                    return
                }
                
                guard let this = self else { return }
                this.asyncWhileRecursive(closure, deadline: deadline, done: done)
            }
                        
            if Thread.current.isMainThread {
                DispatchQueue.main.async {
                    closure(continueClosure)
                }
            } else {
                DispatchQueue.main.sync {
                    closure(continueClosure)
                }
            }
        }
    }
}
