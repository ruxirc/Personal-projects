package businessLogic;

import businessLogic.validators.ProductPriceValidator;
import businessLogic.validators.Validator;
import dataAccess.ProductDAO;
import model.Product;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Business Logic Layer for managing operations related to products.
 */
public class ProductBLL {
    private List<Validator<Product>> validators;
    private ProductDAO productDAO;

    /**
     * Constructs a ProductBLL object and initializes validators and ProductDAO.
     */
    public ProductBLL() {
        validators = new ArrayList<>();
        validators.add(new ProductPriceValidator());

        productDAO = new ProductDAO();
    }

    /**
     * Finds a product by ID.
     *
     * @param id the ID of the product to find.
     * @return the product with the specified ID.
     * @throws NoSuchElementException if the product with the specified ID is not found.
     */
    public Product findProductById(int id) {
        Product product = productDAO.findById(id);
        if (product == null) {
            throw new NoSuchElementException("The product with id = " + id + " was not found!");
        }
        return product;
    }

    /**
     * Retrieves all products.
     *
     * @return a two-dimensional array representing all products.
     */
    public String[][] findAllProducts() {
        System.out.println(productDAO.findAll());
        return productDAO.listOfObjects(productDAO.findAll());
    }

    /**
     * Retrieves field names for products.
     *
     * @return an array of field names for products.
     */
    public String[] getFieldNames() {
        return productDAO.fieldNames();
    }

    /**
     * Inserts a new product.
     *
     * @param product the product to be inserted.
     * @return the inserted product.
     */
    public Product insertProduct(Product product) {
        productDAO.insert(product);
        return null;
    }

    /**
     * Updates an existing product.
     *
     * @param product the product to be updated.
     * @return the updated product.
     * @throws NoSuchElementException if the product cannot be updated.
     */
    public Product updateProduct(Product product) {
        Product result = productDAO.update(product);
        if (result == null)
            throw new NoSuchElementException("The product with ID:" + product.getId() + " could not be modified");
        return null;
    }

    /**
     * Deletes a product.
     *
     * @param product the product to be deleted.
     * @return the deleted product.
     * @throws NoSuchElementException if the product cannot be deleted.
     */
    public Product deleteProduct(Product product) {
        Product result = productDAO.delete(product);
        if (result == null)
            throw new NoSuchElementException("The product with ID:" + product.getId() + " could not be deleted");
        return null;
    }

    /**
     * Decrements the stock of a product by a specified amount.
     *
     * @param productId the ID of the product whose stock is to be decremented.
     * @param amount the amount by which to decrement the stock.
     * @throws IllegalArgumentException if there is insufficient stock to cover the decrement.
     * @throws NoSuchElementException if the product with the specified ID is not found.
     */
    public void decrementStock(int productId, int amount) {
        Product product = productDAO.findById(productId);
        if (product != null) {
            int newStock = product.getStock() - amount;
            if (newStock >= 0) {
                productDAO.updateField(productId, "stock", newStock);
            } else {
                throw new IllegalArgumentException("Insufficient stock for product ID: " + productId);
            }
        } else {
            throw new NoSuchElementException("Product with ID: " + productId + " not found");
        }
    }

    /**
     * Retrieves validators for products.
     *
     * @return a list of validators for products.
     */
    public List<Validator<Product>> getValidators() {
        return validators;
    }
}
