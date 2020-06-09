//
//  Retries.swift
//  Rocc
//
//  Created by Grzegorz Świrski on 6/9/20.
//  Copyright © 2020 Simon Mitchell. All rights reserved.
//

import Foundation


typealias WorkBlockCompletion = (_ isRetriable: Bool) -> Bool
typealias WorkBlock = (_ anotherAttemptMaybeSuccessful: @escaping WorkBlockCompletion, _ attemptNumber: Int) -> Void


func retry(work: @escaping WorkBlock, attempts: Int, attempt: Int = 1) {
    let anotherAttemptMaybeSuccessful: WorkBlockCompletion = { (_ isRetriable: Bool) -> Bool in
        guard isRetriable, attempt < attempts else {
            return false
        }

        retry(work: work, attempts: attempts, attempt: attempt + 1)
        return true
    }
    work(anotherAttemptMaybeSuccessful, attempt)
}

