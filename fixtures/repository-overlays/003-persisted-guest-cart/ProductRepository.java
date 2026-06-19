package demo.supermarket.catalog;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("""
        select p
        from Product p
        join fetch p.category c
        where p.active = true
          and (:categoryId is null or c.id = :categoryId)
          and (:searchTerm is null
               or lower(p.name) like concat('%', :searchTerm, '%')
               or lower(p.description) like concat('%', :searchTerm, '%'))
        order by c.displayOrder asc, p.name asc
        """)
    List<Product> findActiveForCatalog(
        @Param("categoryId") Long categoryId,
        @Param("searchTerm") String searchTerm
    );
}
