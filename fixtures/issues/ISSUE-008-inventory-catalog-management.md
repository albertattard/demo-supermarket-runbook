## Goal

Implement inventory user screens for managing products and categories.

Inventory users maintain the catalog but do not manage orders, delivery postal
codes, or users.

## Scope

- Add inventory product list at `/inventory/products`.
- Support product search/filtering.
- Add product create/edit forms.
- Support archiving and unarchiving products.
- Add inventory category list at `/inventory/categories`.
- Add category create/edit forms.
- Support archiving and unarchiving categories.
- Use server-side Bean Validation for forms.
- Include optional product image path as a text field.
- Do not allow physical deletion of products or categories.
- Ensure archived products are hidden from customer catalog.
- Ensure archived products remain visible through existing order item snapshots.
- Keep order access out of inventory screens.

## Out of Scope

- Stock tracking
- Product image upload
- Delivery postal-code management
- Order management
- User management
- Bulk import/export

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- Inventory user can create and edit products.
- Inventory user can archive and unarchive products.
- Inventory user can create and edit categories.
- Inventory user can archive and unarchive categories.
- Customers do not see archived products in the catalog.
- Product/category deletion is not exposed in the UI.
- Existing orders are unaffected by later product edits.
