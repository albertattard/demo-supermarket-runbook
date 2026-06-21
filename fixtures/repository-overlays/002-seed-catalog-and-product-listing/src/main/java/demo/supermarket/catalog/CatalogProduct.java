package demo.supermarket.catalog;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

public record CatalogProduct(
        Long id,
        String name,
        String description,
        String categoryName,
        String unitLabel,
        BigDecimal unitPrice,
        String imagePath) {

    public String displayImagePath() {
        if (imagePath == null || imagePath.isBlank()) {
            return "/images/product-placeholder.svg";
        }
        return imagePath;
    }

    public String displayUnitPrice() {
        return NumberFormat.getCurrencyInstance(Locale.GERMANY).format(unitPrice);
    }
}
