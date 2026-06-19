package demo.supermarket.catalog;

public record CatalogSearch(Long categoryId, String query) {

    public String normalizedQuery() {
        if (query == null || query.isBlank()) {
            return null;
        }
        return query.trim().toLowerCase();
    }
}
