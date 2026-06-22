package demo.supermarket.e2e;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import demo.supermarket.e2e.harness.E2eHarness;

@Tag("e2e")
class HomePageTest {

    private static E2eHarness harness;

    @BeforeAll
    static void startHarnesses() {
        harness = E2eHarness.start();
    }

    @AfterAll
    static void stopHarnesses() {
        if (harness != null) {
            harness.close();
        }
    }

    @Test
    void opensTheInitialHomePage() {
        harness.homePage(homePage -> homePage
                .openCatalog()
                .shouldShowApplicationName()
                .shouldShowSeededCatalogProduct());
    }

    @Test
    void filtersCatalogBySearchAndCategory() {
        harness.homePage(homePage -> homePage
                .openCatalog()
                .search("tomatoes")
                .shouldPreserveSearch("tomatoes")
                .shouldShowProduct("Cherry Tomatoes")
                .shouldShowProduct("Italian Chopped Tomatoes")
                .shouldNotShowProduct("Baby Spinach")
                .selectCategory("Pantry")
                .search("tomatoes")
                .shouldPreserveSearch("tomatoes")
                .shouldShowProduct("Italian Chopped Tomatoes")
                .shouldNotShowProduct("Cherry Tomatoes"));
    }

    @Test
    void managesPersistedGuestCartFromCatalog() {
        harness.homePage(homePage -> {
            homePage.openCatalog()
                    .addProductToCart("Sourdough Country Loaf")
                    .shouldBeOnCartScopedCatalogUrl()
                    .shouldShowApplicationName()
                    .shouldShowCatalogQuantity("Sourdough Country Loaf", "1")
                    .increaseProductQuantity("Sourdough Country Loaf")
                    .shouldShowCatalogQuantity("Sourdough Country Loaf", "2")
                    .decreaseProductQuantity("Sourdough Country Loaf")
                    .shouldShowCatalogQuantity("Sourdough Country Loaf", "1")
                    .addProductToCart("Butter Croissants")
                    .shouldBeOnCartScopedCatalogUrl()
                    .shouldShowCatalogQuantity("Butter Croissants", "1")
                    .openCurrentCart()
                    .shouldBeOnOpaqueCartUrl()
                    .shouldShowCartLine("Butter Croissants")
                    .shouldShowQuantity("Butter Croissants", "1")
                    .shouldShowCartLine("Sourdough Country Loaf")
                    .shouldShowQuantity("Sourdough Country Loaf", "1")
                    .shouldShowCartSubtotal("8,15");

            final String cartPath = homePage.currentPath();

            homePage.openPath(cartPath)
                    .shouldShowCartLine("Sourdough Country Loaf")
                    .updateQuantity("Sourdough Country Loaf", "3")
                    .shouldShowQuantity("Sourdough Country Loaf", "3")
                    .shouldShowQuantity("Butter Croissants", "1")
                    .shouldShowCartSubtotal("16,05")
                    .removeLine("Butter Croissants")
                    .shouldShowCartLine("Sourdough Country Loaf")
                    .shouldNotShowCartLine("Butter Croissants")
                    .shouldShowCartSubtotal("11,85")
                    .removeLine("Sourdough Country Loaf")
                    .shouldShowEmptyCart()
                    .openPath("/cart/not-a-real-token")
                    .shouldShowCartNotFound();
        });
    }
}
