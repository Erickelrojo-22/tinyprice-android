package com.apps.iatinyfish.presentation.deals

import com.apps.iatinyfish.data.model.ProductOffer
import com.apps.iatinyfish.data.repository.DealsRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SearchCancellationTest {
    @get:Rule val mainDispatcherRule = MainDispatcherRule()

    @Test fun blankSubmissionStopsAnEarlierSearchAndKeepsValidationVisible() = runTest {
        val viewModel = DealsViewModel(SlowRepository())
        viewModel.onEvent(DealsEvent.UseSuggestion("Laptop"))
        runCurrent()
        assertTrue(viewModel.state.value.isLoading)

        viewModel.onEvent(DealsEvent.QueryChanged(""))
        viewModel.onEvent(DealsEvent.SubmitSearch)

        assertFalse(viewModel.state.value.isLoading)
        advanceUntilIdle()
        assertTrue(viewModel.state.value.offers.isEmpty())
        assertNotNull(viewModel.state.value.errorMessage)
    }

    @Test fun editingQueryDoesNotDisplayResultsForThePreviousProduct() = runTest {
        val viewModel = DealsViewModel(SlowRepository())
        viewModel.onEvent(DealsEvent.UseSuggestion("Laptop"))
        runCurrent()

        viewModel.onEvent(DealsEvent.QueryChanged("Audífonos"))
        advanceUntilIdle()

        assertFalse(viewModel.state.value.isLoading)
        assertFalse(viewModel.state.value.hasSearched)
        assertTrue(viewModel.state.value.offers.isEmpty())
    }
}

private class SlowRepository : DealsRepository {
    override val isPreviewData = false
    override suspend fun search(query: String): List<ProductOffer> {
        delay(1_000)
        return listOf(ProductOffer(
            id = "old-result", store = "Example", productName = query,
            price = "Ver en fuente", shipping = "Consulta en tienda",
            delivery = "Por confirmar", rating = "—", sourceUrl = "https://example.com",
            summary = "Resultado de la consulta anterior", tags = emptyList(),
        ))
    }
}
