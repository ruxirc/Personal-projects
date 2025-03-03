package presentation;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class MainController {
    private MainView mainView;
    private ClientView clientsView;
    private ProductView productView;
    private OrderView orderView;
    private AddOrderView addOrderView;

    public MainController(MainView mainView, ClientView clientsView, ProductView productView, OrderView orderView, AddOrderView addOrderView){
        this.mainView = mainView;
        this.clientsView = clientsView;
        this.productView = productView;
        this.orderView = orderView;
        this.addOrderView = addOrderView;

        mainView.addActionListenerClientButton(new ActionListenerClientButton());
        mainView.addActionListenerProductButton(new ActionListenerProductButton());
        mainView.addActionListenerOrderButton(new ActionListenerOrderButton());
        mainView.addActionListenerAddOrderButton(new ActionListenerAddOrderButton());
    }

    class ActionListenerAddOrderButton implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(false);
            addOrderView.getFrame().setVisible(true);
            System.out.println("Add order button pressed");
        }
    }

    class ActionListenerOrderButton implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(false);
            orderView.getFrame().setVisible(true);
        }
    }

    class ActionListenerClientButton implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(false);
            clientsView.getFrame().setVisible(true);
        }
    }

    class ActionListenerProductButton implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(false);
            productView.getFrame().setVisible(true);
        }
    }


}
