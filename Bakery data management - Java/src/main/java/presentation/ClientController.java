package presentation;

import businessLogic.ClientBLL;

import model.Client;
import main.Main;

import javax.swing.table.DefaultTableModel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import java.util.logging.Level;
import java.util.logging.Logger;

public class ClientController {

    protected static final Logger LOGGER = Logger.getLogger(Main.class.getName());
    private ClientView clientView;
    private MainView mainView;

    public ClientController(){}

    public ClientController(ClientView clientView, MainView mainView){
        this.clientView = clientView;
        this.mainView = mainView;

        clientView.addActionListenerAddClientButton(new ActionListenerAddClient());
        clientView.addActionListenerModifyClientButton(new ActionListenerModifyClient());
        clientView.addActionListenerDeleteClientButton(new ActionListenerDeleteClient());
        clientView.addActionListenerShowTableButton(new ActionListenerShowTable());
        clientView.addActionListenerBackButton(new ActionListenerButtonBack());
    }

    class ActionListenerButtonBack extends ClientController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(true);
            clientView.getFrame().setVisible(false);
        }
    }

    class ActionListenerShowTable extends ClientController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            ClientBLL clientBLL = new ClientBLL();

            DefaultTableModel defaultTableModel = new DefaultTableModel(clientBLL.findAllClients(), clientBLL.getFieldNames()){
                @Override
                public boolean isCellEditable(int row, int column){
                    return false;
                }
            };
            clientView.getClientTable().setModel(defaultTableModel);
        }
    }

    class ActionListenerDeleteClient extends ClientController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            int id = 0;
            try {
                id = Integer.parseInt(clientView.getDelId());
            }catch (Exception exception){
                clientView.showError(exception.getMessage());
            }
            Client client = new Client(id);
            ClientBLL clientBLL = new ClientBLL();


            try{
                clientBLL.deleteClient(client);
            } catch (Exception ex) {
                clientView.showError(ex.getMessage());
                LOGGER.log(Level.INFO, ex.getMessage());
            }

        }
    }
    class ActionListenerModifyClient extends ClientController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {

            String name, email, address;
            int age;
            int id = 0;
            try {
                id = Integer.parseInt(clientView.getModId());
            }catch (Exception ex){
                clientView.showError(ex.getMessage());
            }
            name = clientView.getModName();
            email = clientView.getModEmail();
            address = clientView.getModAddress();
            age = Integer.parseInt(clientView.getModAge());

            Client client = new Client(id, name, address, email, age);
            ClientBLL clientBLL = new ClientBLL();
            try {
                clientBLL.getValidators().get(0).validate(client);
                clientBLL.getValidators().get(1).validate(client);
            }catch (Exception ex){
                clientView.showError(ex.getMessage());
                return;
            }
            try{
                clientBLL.updateClient(client);
            } catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }
        }
    }

    class ActionListenerAddClient extends ClientController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            String name, email, address;
            int age;
            int id= clientView.getAddID();
            name = clientView.getAddName();
            email = clientView.getAddEmail();
            address = clientView.getAddAddress();
            age = Integer.parseInt(clientView.getAddAge());

            Client client = new Client(id, name, address, email, age);
            ClientBLL clientBLL = new ClientBLL();
            try {
                clientBLL.getValidators().get(0).validate(client);
                clientBLL.getValidators().get(1).validate(client);
            }catch (Exception ex){
                clientView.showError(ex.getMessage());
                return;
            }

            try{
                clientBLL.insertClient(client);
            } catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }
        }
    }

}
