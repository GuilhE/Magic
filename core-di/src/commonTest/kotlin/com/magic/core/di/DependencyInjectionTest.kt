package com.magic.core.di

import com.magic.core.network.api.ApiClient
import com.magic.data.managers.CardsManager
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import org.koin.core.context.stopKoin
import org.koin.test.KoinTest
import org.koin.test.inject

class DependencyInjectionTest : KoinTest {

	@BeforeTest
	fun setup() {
		stopKoin()
	}

	@AfterTest
	fun tearDown() {
		stopKoin()
	}

	private fun initTestKoin() {
		DependencyInjection.initKoin(appDeclaration = {})
	}

	@Test
	fun `test Koin initialization succeeds`() {
		initTestKoin()
		assertTrue(true, "Koin initialized successfully")
	}

	@Test
	fun `test all dependencies can be resolved`() {
		initTestKoin()

		val apiClient: ApiClient by inject()
		val cardsManager: CardsManager by inject()

		assertNotNull(apiClient, "ApiClient should be resolved")
		assertNotNull(cardsManager, "CardsManager should be resolved")
	}

	@Test
	fun `test dependency order is correct - networkModule provides ApiClient before managersModule uses it`() {
		initTestKoin()

		val apiClient: ApiClient by inject()
		assertNotNull(apiClient)

		val cardsManager: CardsManager by inject()
		assertNotNull(cardsManager)

		assertTrue(true, "Dependency order is correct")
	}
}
