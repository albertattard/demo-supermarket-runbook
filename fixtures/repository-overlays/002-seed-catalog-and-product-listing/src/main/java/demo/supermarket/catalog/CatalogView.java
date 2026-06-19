package demo.supermarket.catalog;

import java.util.List;

public record CatalogView(
    List<Category> categories,
    List<Product> products,
    Long selectedCategoryId,
    String query
) {
}
