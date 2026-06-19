package demo.supermarket.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CatalogController {

    private final CatalogService catalogService;

    CatalogController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping({ "/", "/products" })
    String catalog(
        @RequestParam(name = "category", required = false) Long categoryId,
        @RequestParam(name = "q", required = false) String query,
        Model model
    ) {
        var catalog = catalogService.findCatalog(new CatalogSearch(categoryId, query));

        model.addAttribute("categories", catalog.categories());
        model.addAttribute("products", catalog.products());
        model.addAttribute("selectedCategoryId", catalog.selectedCategoryId());
        model.addAttribute("query", catalog.query());

        return "catalog";
    }
}
