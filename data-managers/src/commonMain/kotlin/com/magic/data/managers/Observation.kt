package com.magic.data.managers

import kotlinx.coroutines.Job

class Observation internal constructor(private val job: Job) {
    fun cancel() {
        job.cancel()
    }
}