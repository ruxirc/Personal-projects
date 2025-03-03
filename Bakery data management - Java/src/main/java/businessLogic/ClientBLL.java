package businessLogic;

import businessLogic.validators.ClientAgeValidator;
import businessLogic.validators.EmailValidator;
import businessLogic.validators.Validator;
import dataAccess.ClientDAO;
import model.Client;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Business Logic Layer for managing operations related to clients.
 */
public class ClientBLL {

    private List<Validator<Client>> validators;
    private ClientDAO clientDAO;

    /**
     * Constructs a ClientBLL object and initializes validators and ClientDAO.
     */
    public ClientBLL() {
        validators = new ArrayList<Validator<Client>>();
        validators.add(new EmailValidator());
        validators.add(new ClientAgeValidator());

        clientDAO = new ClientDAO();
    }

    /**
     * Finds a client by ID.
     *
     * @param id the ID of the client to find.
     * @return the client with the specified ID.
     * @throws NoSuchElementException if the client with the specified ID is not found.
     */
    public Client findClientById(int id) {
        ClientDAO clientDAO = new ClientDAO();
        Client cl = clientDAO.findById(id);
        if (cl == null) {
            throw new NoSuchElementException("The client with id =" + id + " was not found!");
        }
        return cl;
    }

    /**
     * Retrieves all clients.
     *
     * @return a two-dimensional array representing all clients.
     */
    public String[][] findAllClients() {
        return clientDAO.listOfObjects(clientDAO.findAll());
    }

    /**
     * Retrieves field names for clients.
     *
     * @return an array of field names for clients.
     */
    public String[] getFieldNames(){
        return clientDAO.fieldNames();
    }

    /**
     * Inserts a new client.
     *
     * @param client the client to be inserted.
     * @return the inserted client.
     */
    public Client insertClient(Client client) {
        clientDAO.insert(client);
        return null;
    }

    /**
     * Updates an existing client.
     *
     * @param client the client to be updated.
     * @return the updated client.
     * @throws NoSuchElementException if the client cannot be updated.
     */
    public Client updateClient(Client client) {
        Client result = clientDAO.update(client);
        if(result == null)
            throw new NoSuchElementException("The Client with ID:" + client.getId() + " could not be modified");
        return null;
    }

    /**
     * Deletes a client.
     *
     * @param client the client to be deleted.
     * @return the deleted client.
     * @throws NoSuchElementException if the client cannot be deleted.
     */
    public Client deleteClient(Client client){
        Client result = clientDAO.delete(client);
        if(result == null)
            throw new NoSuchElementException("The Client with ID:" + client.getId() + " could not be deleted");
        return null;
    }

    /**
     * Retrieves validators for clients.
     *
     * @return a list of validators for clients.
     */
    public List<Validator<Client>> getValidators() {
        return validators;
    }
}
