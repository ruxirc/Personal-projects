package businessLogic.validators;


import model.Order1;

public class OrderAmountValidator implements Validator<Order1>{
    /**
     * Validates the amount of a product in an order.
     *
     * @param order the order to validate.
     * @throws IllegalArgumentException if the amount of the product in the order is negative.
     */
    @Override
    public void validate(Order1 order) {
        if(order.getQuantity() < 0)
            throw new IllegalArgumentException("Invalid Product Amount");
    }
}
