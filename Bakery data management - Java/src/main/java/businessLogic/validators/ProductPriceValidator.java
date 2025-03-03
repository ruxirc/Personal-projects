package businessLogic.validators;

import model.Product;

public class ProductPriceValidator implements Validator<Product> {
    private static final float MIN_PRICE = 0;
    private static final float MAX_PRICE = 1000;

    /**
     * Validates the price of a product.
     *
     * @param product the product to validate.
     * @throws IllegalArgumentException if the product's price is not within the valid range.
     */
    @Override
    public void validate(Product product) {
        double price = product.getPrice();

        if (price < MIN_PRICE || price > MAX_PRICE) {
            throw new IllegalArgumentException("The product price must be between " + MIN_PRICE + " and " + MAX_PRICE);
        }
    }
}