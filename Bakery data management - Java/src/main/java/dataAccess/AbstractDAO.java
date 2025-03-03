package dataAccess;

import java.beans.IntrospectionException;
import java.beans.PropertyDescriptor;
import java.lang.reflect.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import connection.ConnectionFactory;

public class AbstractDAO<T> {
    protected static final Logger LOGGER = Logger.getLogger(AbstractDAO.class.getName());

    private final Class<T> type;

    @SuppressWarnings("unchecked")
    public AbstractDAO() {
        this.type = (Class<T>) ((ParameterizedType) getClass().getGenericSuperclass()).getActualTypeArguments()[0];

    }

    /**
     * Creates a SQL SELECT query string for the specified field.
     * The query will select all columns from a table that corresponds to the simple name of the class
     * represented by the `type` field, and filter the results where the specified field equals a placeholder value.
     *
     * @param field the name of the field to be used in the WHERE clause of the SQL query.
     * @return a SQL SELECT query string.
     */
    private String createSelectQuery(String field) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT ");
        sb.append(" * ");
        sb.append(" FROM ");
        sb.append(type.getSimpleName());
        sb.append(" WHERE ").append(field).append(" =?");
        return sb.toString();
    }

    /**
     * Creates a SQL SELECT query string to retrieve the last record from the specified table.
     * The query selects all columns from the table, orders the records by the `id` field in descending order,
     * and limits the result to one record.
     *
     * @param table the name of the table from which to select the last record.
     * @return SQL SELECT query string to retrieve the last record from the specified table.
     */
    private String createSelectLast(String table){
        StringBuilder result = new StringBuilder();
        result.append("SELECT * FROM ");
        result.append(table);
        result.append(" ORDER BY id DESC Limit 1");
        return result.toString();
    }

    /**
     * Creates a SQL SELECT query string to retrieve all records from the table corresponding to the simple name of the class
     * represented by the `type` field. The query selects all columns from the table.
     *
     * @return SQL SELECT query string to retrieve all records from the specified table.
     */
    private String createSelectAllQuery() {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT ");
        sb.append(" * ");
        sb.append(" FROM ");
        sb.append(type.getSimpleName());
        return sb.toString();
    }

    /**
     * Creates a SQL DELETE query string to delete records from the table corresponding to the simple name of the class
     * represented by the `type` field, where the specified field equals a placeholder value.
     *
     * @param field the name of the field to be used in the WHERE clause of the SQL query.
     * @return SQL DELETE query string to delete records from the specified table where the field equals a placeholder value.
     */
    private String createDeleteQuery(String field){
        StringBuilder result = new StringBuilder();
        result.append("DELETE FROM ");
        result.append(type.getSimpleName());
        result.append(" WHERE " + field + " =?");
        return result.toString();
    }

    /**
     * Retrieves the names of all the fields declared in the class represented by the `type` field.
     *
     * @return an array of strings containing the names of all the fields in the class.
     */
    public String[] fieldNames(){
        String[] result = new String[type.getDeclaredFields().length];
        int i = 0;
        for(Field field : type.getDeclaredFields())
            result[i++] = field.getName();
        return result;
    }

    /**
     * Retrieves all records from the corresponding database table and returns them as a list of objects of type T.
     *
     * @return a list of objects containing all records from the database table.
     */
    public List<T> findAll() {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String query = createSelectAllQuery();
        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            System.out.println(statement);
            resultSet = statement.executeQuery();
            return createObjects(resultSet);
        }
        catch ( SQLException e ) {
            LOGGER.log(Level.SEVERE, e.getMessage(), e);
        }
        finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    /**
     * Retrieves a record from the corresponding database table based on the provided ID.
     *
     * @param id the ID of the record to be retrieved.
     * @return an object of type T representing the record with the provided ID, or null if not found.
     */
    public T findById(int id) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String query = createSelectQuery("id");
        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, id);
            resultSet = statement.executeQuery();

            return createObjects(resultSet).get(0);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:findById " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    /**
     * Creates a list of objects of type T from the given ResultSet.
     *
     * @param resultSet the ResultSet containing the data to be mapped to objects.
     * @return a list of objects of type T created from the ResultSet.
     */
    private List<T> createObjects(ResultSet resultSet) {
        List<T> list = new ArrayList<T>();
        Constructor[] ctors = type.getDeclaredConstructors();
        Constructor ctor = null;
        for (int i = 0; i < ctors.length; i++) {
            ctor = ctors[i];
            if (ctor.getGenericParameterTypes().length == 0)
                break;
        }
        try {
            while (resultSet.next()) {
                ctor.setAccessible(true);
                T instance = (T)ctor.newInstance();
                for (Field field : type.getDeclaredFields()) {
                    String fieldName = field.getName();
                    Object value = resultSet.getObject(fieldName);
                    PropertyDescriptor propertyDescriptor = new PropertyDescriptor(fieldName, type);
                    Method method = propertyDescriptor.getWriteMethod();
                    method.invoke(instance, value);
                }
                list.add(instance);
            }
        } catch (InstantiationException | IntrospectionException | InvocationTargetException | IllegalAccessException |
                 SecurityException | IllegalArgumentException | SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Converts a list of objects of type T into a two-dimensional array of strings.
     * Each row in the array represents an object, and each column represents a field value of that object.
     *
     * @param t the list of objects to be converted into a two-dimensional array of strings.
     * @return a two-dimensional array of strings representing the objects and their field values.
     */
    public String[][] listOfObjects(List<T> t){
        String[][] result = new String[t.size()][50];
        int i = 0;
        int j = 0;

        for(T tmp : t){
            for(Field field : tmp.getClass().getDeclaredFields()){
                field.setAccessible(true);
                try {
                    result[i][j++] = String.valueOf(field.get(tmp));
                } catch (IllegalAccessException e) {
                    throw new RuntimeException(e);
                }
            }
            i++;
            j = 0;
        }

        return result;
    }

    /**
     * Inserts a new record into the corresponding database table using the provided object t.
     *
     * @param t the object to be inserted into the database.
     * @return the ID of the newly inserted record, or -1 if an error occurs.
     */
    public int insert(T t) {
        Connection connection = null;
        PreparedStatement statement = null;
        String query = createInsertQuery(t);
        String query2 = createSelectLast(t.getClass().getSimpleName());
        System.out.println(query);
        System.out.println(query2);
        ResultSet resultSet = null;
        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            statement.executeUpdate();
            resultSet = statement.getGeneratedKeys();
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:insert " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return -1;
    }

    /**
     * Updates an existing record in the corresponding database table with the provided object t.
     *
     * @param t the object containing the updated values to be stored in the database.
     * @return the updated object retrieved from the database, or null if an error occurs.
     */
    public T update(T t) {
        String query = createUpdateQuery(t);
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            System.out.println(query);
            statement.executeUpdate();
            statement = connection.prepareStatement(createSelectQuery("id"));
            statement.setInt(1, Integer.parseInt(query.split(" ")[1]));
            resultSet = statement.executeQuery();
            return createObjects(resultSet).get(0);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:update " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    /**
     * Deletes an existing record from the corresponding database table based on the provided object t.
     *
     * @param t the object representing the record to be deleted from the database.
     * @return the deleted object retrieved from the database, or null if an error occurs.
     */
    public T delete(T t) {
        String query = createDeleteQuery("id");
        System.out.println(query);
        int id;
        Field[] fields = type.getDeclaredFields();

        fields[0].setAccessible(true);
        try {
            id = (int) fields[0].get(t);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
        fields[0].setAccessible(false);

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement("SET FOREIGN_KEY_CHECKS=0");
            statement.executeUpdate();
            statement = connection.prepareStatement(createSelectQuery("id"));
            statement.setInt(1, id);
            resultSet = statement.executeQuery();

            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, id);
            statement.executeUpdate();

            return createObjects(resultSet).get(0);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:update " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    /**
     * Creates an SQL UPDATE query string based on the provided object t.
     *
     * @param t the object containing the updated values to be stored in the database.
     * @return an SQL UPDATE query string to update the record with the values from the provided object.
     */
    private String createUpdateQuery(T t){
        // UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; (id = t.id)
        StringBuilder finalQuery = new StringBuilder();
        finalQuery.append("UPDATE ");
        finalQuery.append(type.getSimpleName()).append(" SET ");
        Object id = null;
        boolean first = true;
        for (Field field : t.getClass().getDeclaredFields()) {
            field.setAccessible(true);
            if (field.getName().equals("id")){
                try {
                    id = field.get(t);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }
                continue;
            }
            Object value;
            try {
                if (first){
                    first = false;
                }
                else {
                    finalQuery.append(", ");
                }
                finalQuery.append(field.getName());
                finalQuery.append(" = '");
                value = field.get(t);
                finalQuery.append(value).append("'");
            } catch (IllegalArgumentException | IllegalAccessException e) {
                e.printStackTrace();
            }
        }
        finalQuery.append(" WHERE id = ").append(id);
        return finalQuery.toString();
    }

    /**
     * Updates a specific field of a record in the corresponding database table identified by the provided ID.
     *
     * @param id the ID of the record to be updated.
     * @param fieldName the name of the field to be updated.
     * @param newValue the new value to be assigned to the field.
     */
    public void updateField(int id, String fieldName, Object newValue) {
        Connection connection = null;
        PreparedStatement statement = null;
        String query = "UPDATE " + type.getSimpleName() + " SET " + fieldName + " = ? WHERE id = ?";

        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            statement.setObject(1, newValue);
            statement.setInt(2, id);
            statement.executeUpdate();

        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:updateField " + e.getMessage());
        } finally {
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
    }

    /**
     * Creates an SQL INSERT query string based on the provided object t.
     *
     * @param t the object containing the values to be inserted into the database.
     * @return an SQL INSERT query string to insert the values from the provided object into the database.
     */
    private String createInsertQuery(T t) {
        StringBuilder finalQuery = new StringBuilder();
        finalQuery.append("INSERT INTO ");
        finalQuery.append(type.getSimpleName()).append(" (");
        StringBuilder valuesQuery = new StringBuilder("VALUES(");
        boolean first = true;

        for (Field field : t.getClass().getDeclaredFields()) {
            field.setAccessible(true);
            Object value;
            try {
                if (first) {
                    first = false;
                } else {
                    valuesQuery.append(", ");
                    finalQuery.append(", ");
                }
                finalQuery.append(field.getName());
                value = field.get(t);

                if (value instanceof String) {
                    valuesQuery.append("'").append(value).append("'");
                } else if (value instanceof LocalDateTime) {
                    valuesQuery.append("'").append(Timestamp.valueOf((LocalDateTime) value)).append("'");
                } else {
                    valuesQuery.append(value);
                }
            } catch (IllegalArgumentException | IllegalAccessException e) {
                e.printStackTrace();
            }
        }

        finalQuery.append(") ").append(valuesQuery).append(")");
        return finalQuery.toString();
    }

    /**
     * Retrieves the maximum ID value from the corresponding database table.
     *
     * @return the maximum ID value from the database table, or null if no records exist or an error occurs.
     */
    public Integer getLastId() {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = ConnectionFactory.getConnection();
            String tableName = type.getSimpleName();
            String query = "SELECT MAX(id) AS max_id FROM " + tableName;
            statement = connection.prepareStatement(query);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return resultSet.getInt("max_id");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "OrderDAO:getLastId " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }

        return null;
    }


}
