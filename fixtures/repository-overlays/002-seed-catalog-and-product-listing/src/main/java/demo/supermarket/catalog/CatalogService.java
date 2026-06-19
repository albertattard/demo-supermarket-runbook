package demo.supermarket.catalog;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class CatalogService {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    CatalogService(CategoryRepository categoryRepository, ProductRepository productRepository) {
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
    }

    public CatalogView findCatalog(CatalogSearch search) {
        return new CatalogView(
            categoryRepository.findAllByOrderByDisplayOrderAscNameAsc(),
            productRepository.findActiveForCatalog(search.categoryId(), search.normalizedQuery()),
            search.categoryId(),
            search.query() == null ? "" : search.query().trim()
        );
    }
}
