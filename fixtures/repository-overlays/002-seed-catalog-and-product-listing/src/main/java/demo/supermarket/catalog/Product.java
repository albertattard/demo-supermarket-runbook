package demo.supermarket.catalog;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "products")
class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 1000)
    private String description;

    @Column(name = "unit_label", nullable = false)
    private String unitLabel;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(nullable = false)
    private boolean active;

    @Column(name = "image_path")
    private String imagePath;

    protected Product() {
    }

    Long getId() {
        return id;
    }

    Category getCategory() {
        return category;
    }

    String getName() {
        return name;
    }

    String getDescription() {
        return description;
    }

    String getUnitLabel() {
        return unitLabel;
    }

    BigDecimal getUnitPrice() {
        return unitPrice;
    }

    boolean isActive() {
        return active;
    }

    String getImagePath() {
        return imagePath;
    }
}
