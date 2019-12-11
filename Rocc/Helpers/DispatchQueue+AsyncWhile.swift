//
//  DispatchQueue+AsyncWhile.swift
//  Rocc
//
//  Created by Simon Mitchell on 18/11/2019.
//  Copyright © 2019 Simon Mitchell. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    fileprivate class Canceller {
        
        var shouldCancel: Bool = false
        
        func cancel() {
            shouldCancel = true
        }
    }
    
    typealias AsyncWhileCompletion = (Bool) -> Void
    
    func asyncWhile(_ closure: @escaping ((@escaping AsyncWhileCompletion) -> Void), timeout: TimeInterval, done: @escaping () -> Void) {
        
        // Jump onto this queue synchronously
        async {
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let continueClosure: AsyncWhileCompletion = { [weak self] finished in
                
                guard !finished else {
                    semaphore.signal()
                    return
                }
                
                guard let this = self else { return }
                this.asyncWhileRecursive(closure, done: done, semaphore: semaphore)
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
            
            
            let _ = semaphore.wait(timeout: .now() + timeout)
                        
            // Call done either after timeout or when semaphore is signaled
            if Thread.current.isMainThread {
                DispatchQueue.main.async {
                    done()
                }
            } else {
                DispatchQueue.main.sync {
                    done()
                }
            }
        }
    }
    
    private func asyncWhileRecursive(_ closure: @escaping ((@escaping AsyncWhileCompletion) -> Void), done: @escaping () -> Void, semaphore: DispatchSemaphore) {
        
        async {
            
            let continueClosure: AsyncWhileCompletion = { [weak self] finished in
                
                guard !finished else {
                    semaphore.signal()
                    return
                }
                
                guard let this = self else { return }
                this.asyncWhileRecursive(closure, done: done, semaphore: semaphore)
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
