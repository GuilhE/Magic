package com.magic.app.android

import android.app.Application
import com.magic.app.android.presentation.MagicViewModel
import com.magic.core.di.DependencyInjection
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

class MagicApp : Application() {

    override fun onCreate() {
        super.onCreate()
        DependencyInjection.initKoin {
            modules(
                module {
                    viewModel { MagicViewModel() }
                }
            )
            androidLogger()
            androidContext(this@MagicApp)
        }
    }
}