package com.apps.iatinyfish.presentation.deals

import android.content.ActivityNotFoundException
import android.content.ContextWrapper
import android.content.Intent
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalContext
import androidx.test.platform.app.InstrumentationRegistry
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import com.apps.iatinyfish.data.model.ProductOffer
import com.apps.iatinyfish.data.repository.DealsRepository
import com.apps.iatinyfish.data.repository.PreviewDealsRepository
import com.apps.iatinyfish.data.repository.RemoteSearchException
import com.apps.iatinyfish.ui.theme.IATinyFishTheme
import org.junit.Rule
import org.junit.Test
import kotlinx.coroutines.runBlocking

class DealsAppTest {
    @get:Rule val composeRule = createComposeRule()

    @Test fun startScreenShowsSearchAndSuggestion() {
        composeRule.setContent {
            IATinyFishTheme {
                DealsApp(state = DealsUiState(), onEvent = {})
            }
        }

        composeRule.onNodeWithText("Buscar").assertIsDisplayed()
        composeRule.onNodeWithText("Nintendo Switch OLED").assertIsDisplayed()
    }

    @Test fun blankSearchShowsValidation() {
        showApp(DealsViewModel(PreviewDealsRepository))
        composeRule.onNodeWithText("Buscar").performClick()
        composeRule.onNodeWithText("Escribe un producto para iniciar la búsqueda.").assertIsDisplayed()
    }

    @Test fun remoteHomeLabelsTheWebSearchMode() {
        composeRule.setContent {
            IATinyFishTheme { DealsApp(DealsUiState(isPreviewData = false), {}) }
        }
        composeRule.onNodeWithText("BÚSQUEDA WEB DE OFERTAS").assertIsDisplayed()
    }

    @Test fun missingBrowserShowsAnExplanationInsteadOfCrashing() {
        val offer = runBlocking { PreviewDealsRepository.search("Nintendo") }.first()
            .copy(sourceUrl = "https://example.com/product")
        val noBrowser = object : ContextWrapper(InstrumentationRegistry.getInstrumentation().targetContext) {
            override fun startActivity(intent: Intent) {
                throw ActivityNotFoundException("No browser installed")
            }
        }
        composeRule.setContent {
            CompositionLocalProvider(LocalContext provides noBrowser) {
                IATinyFishTheme { DealsApp(DealsUiState(selectedOffer = offer), {}) }
            }
        }
        composeRule.onNodeWithText("Abrir fuente web").performScrollTo().performClick()
        composeRule.onNodeWithText("No hay un navegador disponible para abrir esta fuente.")
            .performScrollTo().assertIsDisplayed()
    }

    @Test fun demoSearchOpensDetailsAndReturnsToResults() {
        showApp(DealsViewModel(PreviewDealsRepository))
        composeRule.onNodeWithText("Nintendo Switch OLED").performClick()
        composeRule.onNodeWithText("3 resultados de demostración").assertIsDisplayed()
        composeRule.onNodeWithText("Pixel Store").performClick()
        composeRule.onNodeWithText("Detalle de oferta").assertIsDisplayed()
        composeRule.onNodeWithText("‹  Volver").performClick()
        composeRule.onNodeWithText("3 resultados de demostración").assertIsDisplayed()
    }

    @Test fun remoteErrorShowsTheRetryAction() {
        showApp(DealsViewModel(object : DealsRepository {
            override val isPreviewData = false
            override suspend fun search(query: String): List<ProductOffer> {
                throw RemoteSearchException("No hay conexión de prueba")
            }
        }))
        composeRule.onNodeWithText("Nintendo Switch OLED").performClick()
        composeRule.onNodeWithText("No hay conexión de prueba").assertIsDisplayed()
        composeRule.onNodeWithText("Reintentar").assertIsDisplayed()
    }

    private fun showApp(viewModel: DealsViewModel) {
        composeRule.setContent {
            val state by viewModel.state.collectAsState()
            IATinyFishTheme { DealsApp(state, viewModel::onEvent) }
        }
    }
}
