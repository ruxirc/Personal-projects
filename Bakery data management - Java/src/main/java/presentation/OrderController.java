package presentation;

import businessLogic.OrderBLL;
import model.Order1;
import main.Main;

import javax.swing.table.DefaultTableModel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderController {
    protected static final Logger LOGGER = Logger.getLogger(Main.class.getName());
    private OrderView orderView;
    private MainView mainView;

    public OrderController(){}

    public OrderController(OrderView orderView, MainView mainView){
        this.orderView = orderView;
        this.mainView = mainView;

        orderView.addActionListenerButtonBack(new ActionListenerButtonBack());
        orderView.addActionListenerButtonDelete(new ActionListenerButtonDelete());
        orderView.addActionListenerButtonShowTable(new ActionListenerButtonShowTable());
        orderView.addActionListenerButtonModify(new ActionListenerButtonModify());
    }

    class ActionListenerButtonBack extends OrderController implements ActionListener {

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(true);
            orderView.getFrame().setVisible(false);
        }
    }

    class ActionListenerButtonShowTable extends OrderController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            OrderBLL orderBLL = new OrderBLL();

            DefaultTableModel defaultTableModel = new DefaultTableModel(orderBLL.findAllOrder(), orderBLL.getFieldNames()){
                @Override
                public boolean isCellEditable(int row, int column){
                    return false;
                }
            };
            orderView.getOrdersTable().setModel(defaultTableModel);
        }
    }

    class ActionListenerButtonModify extends OrderController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            int id = 0, id_client = 0, id_product = 0, amount = 0;

            try{
                id = Integer.parseInt(orderView.getModOrderId());
                id_client = Integer.parseInt(orderView.getModClientId());
                id_product = Integer.parseInt(orderView.getModProdId());
                amount = Integer.parseInt(orderView.getModProdStock());
            }catch (Exception exception){
                orderView.showError(exception.getMessage());
            }

            Order1 order1 = new Order1(id, id_client, id_product, amount);
            OrderBLL orderBLL = new OrderBLL();
            try{
//                orderBLL.getValidators().get(0).validate(order);
//                orderBLL.getValidators().get(1).validate(order);
//                orderBLL.getValidators().get(2).validate(order);
//                orderBLL.getValidators().get(3).validate(order);
            }catch (Exception ex){
                orderView.showError(ex.getMessage());
            }

            try{
                orderBLL.updateOrder(order1);
            } catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }
        }
    }

    class ActionListenerButtonDelete extends OrderController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            int id = Integer.parseInt(orderView.getDelOrderId());
            Order1 order1 = new Order1(id);
            OrderBLL orderBLL= new OrderBLL();

            try {
//                orderBLL.getValidators().get(0).validate(order);
            }
            catch (Exception exception){
                orderView.showError(exception.getMessage());
            }

            try{
                orderBLL.deleteOrder(order1);
            } catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }

        }
    }
}
