package presentation;


import businessLogic.ProductBLL;
import model.Product;
import main.Main;

import javax.swing.table.DefaultTableModel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.logging.Level;
import java.util.logging.Logger;


public class ProductController {
    protected static final Logger LOGGER = Logger.getLogger(Main.class.getName());

    private ProductView productView;
    private MainView mainView;

    public ProductController(){}

    public ProductController(ProductView productsView, MainView mainView){
        this.productView = productsView;
        this.mainView = mainView;

        productsView.addActionListenerAddProductButton(new ActionListenerAddProduct());
        productsView.addActionListenerModifyProductButton(new ActionListenerModifyProduct());
        productsView.addActionListenerDeleteProductButton(new ActionListenerDeleteProduct());
        productsView.addActionListenerShowTableButton(new ActionListenerShowTable());
        productsView.addActionListenerBackButton(new ActionListenerButtonBack());
    }

    class ActionListenerButtonBack extends ProductController implements ActionListener{

        @Override
        public void actionPerformed(ActionEvent e) {
            mainView.getFrame().setVisible(true);
            productView.getFrame().setVisible(false);
        }
    }

    class ActionListenerShowTable extends ProductController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            ProductBLL productBLL = new ProductBLL();

            DefaultTableModel defaultTableModel = new DefaultTableModel(productBLL.findAllProducts(), productBLL.getFieldNames()){
                @Override
                public boolean isCellEditable(int row, int column){
                    return false;
                }
            };
            productView.getProductTable().setModel(defaultTableModel);
        }
    }
    class ActionListenerDeleteProduct extends ProductController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            int id = 0;
            try {
                id = Integer.parseInt(productView.getDelPrice());
            }catch (Exception ex){
                productView.showError(ex.getMessage());
            }
            Product product = new Product(id);
            ProductBLL productsBLL = new ProductBLL();

            try{
                productsBLL.deleteProduct(product);
            } catch (Exception ex) {
                productView.showError(ex.getMessage());
                LOGGER.log(Level.INFO, ex.getMessage());
            }

        }
    }

    class ActionListenerModifyProduct extends ProductController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            int stock = 0, id = 0, price = 0;
            String name;
            try {
                id = Integer.parseInt(productView.getModId());
                stock = Integer.parseInt(productView.getModStock());
                price = Integer.parseInt(productView.getModPrice());
            }catch (Exception exception){
                productView.showError(exception.getMessage());
            }
            name = productView.getModName();

            Product products = new Product(id, name, price, stock);
            ProductBLL productsBLL = new ProductBLL();

            try{
                productsBLL.getValidators().get(0).validate(products);
            }catch (Exception exception){
                productView.showError(exception.getMessage());
                return;
            }

            try{
                productsBLL.updateProduct(products);
            }catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }

        }
    }

    class ActionListenerAddProduct extends ProductController implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e) {
            int id= productView.getAddID();
            int stock = 0, price = 0;
            String name;

            try {
                stock = Integer.parseInt(productView.getAddStock());
                price = Integer.parseInt(productView.getAddPrice());
            }catch (Exception exception){
                productView.showError(exception.getMessage());
                return;
            }
            name = productView.getAddName();

            Product products = new Product(id, name, price, stock);
            ProductBLL productsBLL = new ProductBLL();

            try{
                productsBLL.getValidators().get(0).validate(products);
            }catch (Exception exception){
                productView.showError(exception.getMessage());
                return;
            }

            try{
                productsBLL.insertProduct(products);

            }catch (Exception ex) {
                LOGGER.log(Level.INFO, ex.getMessage());
            }

        }
    }
}
