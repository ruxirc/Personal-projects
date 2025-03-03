package presentation;

import java.io.*;

import businessLogic.ClientBLL;
import businessLogic.OrderBLL;
import businessLogic.ProductBLL;
import dataAccess.BillDAO;
import model.Client;
import model.Order1;
import model.Product;
import main.Main;

import javax.swing.table.DefaultTableModel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.logging.Logger;

public class AddOrderController {
    protected static final Logger LOGGER = Logger.getLogger(Main.class.getName());

    private AddOrderView addOrderView;
    private MainView mainView;

    public AddOrderController(AddOrderView addOrderView, MainView mainView){
        this.addOrderView = addOrderView;
        this.mainView =mainView;
        setTables();

        addOrderView.addActionListenerBackButton(new ActionListenerBackButton());
        addOrderView.addActionListenerAddOrderButton(new ActionListenerAddOrderButton());
        addOrderView.addActionListenerRefreshTablesButton(new ActionListenerRefreshTables());
    }

    /**
     * Add Order Button Listener
     */
    class ActionListenerAddOrderButton extends OrderController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            int amount = 0, id_client = 0, id_product = 0;
            try {
                amount = Integer.parseInt(addOrderView.getAmount());
                id_client = Integer.parseInt(addOrderView.getClientId());
                id_product = Integer.parseInt(addOrderView.getProductId());
            }catch (Exception exception){
                addOrderView.showError(exception.getMessage());
            }

            OrderBLL orderBLL = new OrderBLL();
            BillDAO billDAO = new BillDAO();
            orderBLL.setBillDAO(billDAO);
            int id = orderBLL.generateNewOrderId();

            Order1 order1 = new Order1(id, id_client, id_product, amount);

            if(orderBLL.checkStock(order1) ){

                try{
                    orderBLL.getValidators().get(0).validate(order1);
                }catch (Exception exception){
                    addOrderView.showError(exception.getMessage());
                    return;
                }

                orderBLL.createOrder(order1);
                orderBLL.processOrder(order1);

            }
            else addOrderView.showError("Insufficient stock");
            setTables();

        }
    }

    class ActionListenerBackButton extends OrderController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(true);
            addOrderView.getFrame().setVisible(false);
        }
    }

    class ActionListenerRefreshTables extends OrderController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            setTables();
        }
    }
    private void setTables(){
        ClientBLL clientBLL = new ClientBLL();

        DefaultTableModel defaultTableModelClient = new DefaultTableModel(clientBLL.findAllClients(), clientBLL.getFieldNames()){
            @Override
            public boolean isCellEditable(int row, int column){
                return false;
            }
        };
        addOrderView.getClientTable().setModel(defaultTableModelClient);

        ProductBLL productBLL = new ProductBLL();

        DefaultTableModel defaultTableModelProduct = new DefaultTableModel(productBLL.findAllProducts(), productBLL.getFieldNames()){
            @Override
            public boolean isCellEditable(int row, int column){
                return false;
            }
        };
        addOrderView.getProductTable().setModel(defaultTableModelProduct);
    }
}
