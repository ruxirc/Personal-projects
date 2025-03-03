package dataAccess;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;

import connection.ConnectionFactory;
import model.Order1;


public class OrderDAO extends AbstractDAO<Order1>{

    /**
     * Verifies if there is sufficient stock available for a given order.
     *
     * @param order1 the order object containing the product ID and quantity to be checked.
     * @return true if there is sufficient stock available, otherwise false.
     */
    public boolean checkStock(Order1 order1){
        String query = "SELECT stock FROM product WHERE product.id = " + order1.getIdProduct();

        int stock = 0;

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query);
            resultSet = statement.executeQuery();

            if(resultSet.next()){
                stock = Integer.parseInt(resultSet.getString("stock"));
            }

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING,  "DAO:Order " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }

        return stock >= order1.getQuantity();
    }
}
