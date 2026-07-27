package demo.supermarket.catalog;

import module java.base;

public record CatalogView(List<CatalogCategory> categories,
                          List<CatalogProduct> products,
                          Long selectedCategoryId,
                          String search) {

    public boolean hasProducts() {
        return !products.isEmpty();
    }
}
