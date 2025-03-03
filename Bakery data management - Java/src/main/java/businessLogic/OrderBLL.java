package businessLogic;

import businessLogic.validators.OrderAmountValidator;
import businessLogic.validators.Validator;
import dataAccess.BillDAO;
import dataAccess.OrderDAO;
import model.Bill;
import model.Order1;
import model.Product;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Business Logic Layer for managing operations related to orders.
 */
public class OrderBLL {
    private List<Validator<Order1>> validators;
    private OrderDAO orderDAO;
    private BillDAO billDAO;

    /**
     * Constructs an OrderBLL object and initializes validators and DAOs.
     */
    public OrderBLL() {
        validators = new ArrayList<>();
        validators.add(new OrderAmountValidator());
        this.orderDAO = new OrderDAO();
    }

    /**
     * Sets the BillDAO for the OrderBLL.
     *
     * @param billDAO the BillDAO to set.
     */
    public void setBillDAO(BillDAO billDAO) {
        this.billDAO = billDAO;
    }

    /**
     * Sets the OrderDAO for the OrderBLL.
     *
     * @param orderDAO the OrderDAO to set.
     */
    public void setOrderDAO(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    /**
     * Retrieves the field names for orders.
     *
     * @return an array of field names for orders.
     */
    public String[] getFieldNames() {
        return orderDAO.fieldNames();
    }

    /**
     * Retrieves all orders.
     *
     * @return a two-dimensional array representing all orders.
     */
    public String[][] findAllOrder() {
        return orderDAO.listOfObjects(orderDAO.findAll());
    }

    /**
     * Creates a new order.
     *
     * @param order1 the order to be created.
     * @return the created order.
     */
    public Order1 createOrder(Order1 order1) {
        orderDAO.insert(order1);
        return null;
    }

    /**
     * Updates an existing order.
     *
     * @param order1 the order to be updated.
     * @return the updated order.
     * @throws NoSuchElementException if the order cannot be updated.
     */
    public Order1 updateOrder(Order1 order1) {
        Order1 result = orderDAO.update(order1);
        if (result == null)
            throw new NoSuchElementException("The Order with ID:" + order1.getId() + " could not be modified");
        return null;
    }

    /**
     * Deletes an order.
     *
     * @param order1 the order to be deleted.
     * @return the deleted order.
     * @throws NoSuchElementException if the order cannot be deleted.
     */
    public Order1 deleteOrder(Order1 order1) {
        Order1 result = orderDAO.delete(order1);
        if (result == null)
            throw new NoSuchElementException("The Order with ID:" + order1.getId() + " could not be deleted");
        return null;
    }

    /**
     * Checks the stock for a given order.
     *
     * @param order1 the order to check stock for.
     * @return true if there is sufficient stock, false otherwise.
     */
    public boolean checkStock(Order1 order1) {
        return orderDAO.checkStock(order1);
    }

    /**
     * Generates a new order ID.
     *
     * @return the new order ID.
     */
    public int generateNewOrderId() {
        Integer lastOrderId = orderDAO.getLastId();
        if (lastOrderId == -1) {
            return 1;
        }
        return lastOrderId + 1;
    }

    /**
     * Generates a new log ID for billing.
     *
     * @return the new log ID.
     */
    public int generateNewLogId() {
        Integer lastLogId = billDAO.getLastId();
        if (lastLogId == -1) {
            return 1;
        }
        return lastLogId + 1;
    }

    /**
     * Processes an order, including stock checking, order creation, and billing.
     *
     * @param order1 the order to process.
     * @throws IllegalArgumentException if there is insufficient stock for the order.
     */
    public void processOrder(Order1 order1) {
        if (checkStock(order1)) {
            ProductBLL productBLL = new ProductBLL();
            productBLL.decrementStock(order1.getIdProduct(), order1.getQuantity());
            createOrder(order1);

            double amount = calculateOrderAmount(order1);
            int id = generateNewLogId();
            Bill bill = new Bill(id, order1.getId(), amount, LocalDateTime.now());

            billDAO.insert(bill);

            PrintWriter printWriter = null;
            try {
                printWriter = new PrintWriter("order" + order1.getId() + ".txt");
            } catch (FileNotFoundException ex) {
                throw new RuntimeException(ex);
            }

            printWriter.print(bill);
            printWriter.print(order1);

            printWriter.close();
        } else {
            throw new IllegalArgumentException("Insufficient stock for product ID: " + order1.getIdProduct());
        }
    }

    /**
     * Calculates the total amount for an order.
     *
     * @param order1 the order to calculate the amount for.
     * @return the total amount for the order.
     */
    private double calculateOrderAmount(Order1 order1) {
        ProductBLL productBLL = new ProductBLL();
        Product product = productBLL.findProductById(order1.getIdProduct());
        return product.getPrice() * order1.getQuantity();
    }

    /**
     * Retrieves the validators for orders.
     *
     * @return a list of validators for orders.
     */
    public List<Validator<Order1>> getValidators() {
        return validators;
    }
}
