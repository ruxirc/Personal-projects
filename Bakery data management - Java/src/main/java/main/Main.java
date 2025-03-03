package main;

import presentation.*;


public class Main {

    public static void main(String[] args){
        ClientView clientView = new ClientView();
        ProductView productView = new ProductView();
        MainView mainView = new MainView();
        OrderView orderView = new OrderView();
        AddOrderView addOrderView = new AddOrderView();
        MainController controllerMain = new MainController(mainView, clientView, productView, orderView, addOrderView);
        ClientController clientController = new ClientController(clientView, mainView);
        ProductController productController = new ProductController(productView, mainView);
        OrderController orderController = new OrderController(orderView, mainView);
        AddOrderController addOrderController = new AddOrderController(addOrderView, mainView);
    }

}
