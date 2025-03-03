package presentation;

import javax.swing.*;
import java.awt.event.ActionListener;

public class ProductView {
    private JTextField addPrice;
    private JTextField addName;
    private JTextField addStock;
    private JTextField modPrice;
    private JTextField modName;
    private JTextField modStock;
    private JTextField delPrice;
    private JButton addProductButton;
    private JButton modifyProductButton;
    private JButton deleteProductButton;
    private JTextField modId;
    private JButton backButton;
    private JPanel productPanel;
    private JTable productTable;
    private JScrollPane scrollPane;
    private JButton showTableButton;
    private JTextField id;
    private JFrame frame;

    public ProductView() {
        scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        frame = new JFrame("Products");
        frame.setContentPane(productPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(false);
    }

    public int getAddID() {
        return Integer.parseInt(id.getText());
    }

    public void setId(JTextField id) {
        this.id = id;
    }

    public String getAddPrice() {
        return addPrice.getText();
    }

    public String getAddName() {
        return addName.getText();
    }

    public String getAddStock() {
        return addStock.getText();
    }

    public String getModPrice() {
        return modPrice.getText();
    }

    public String getModName() {
        return modName.getText();
    }

    public String getModStock() {
        return modStock.getText();
    }

    public String getModId() {
        return modId.getText();
    }

    public String getDelPrice() {
        return delPrice.getText();
    }

    public void addActionListenerAddProductButton(ActionListener e) {
        addProductButton.addActionListener(e);
    }

    public void addActionListenerModifyProductButton(ActionListener e) {
        modifyProductButton.addActionListener(e);
    }

    public void addActionListenerDeleteProductButton(ActionListener e) {
        deleteProductButton.addActionListener(e);
    }

    public void addActionListenerBackButton(ActionListener e) {
        backButton.addActionListener(e);
    }

    public void addActionListenerShowTableButton(ActionListener e) {
        showTableButton.addActionListener(e);
    }

    void showError(String errMessage) {
        JOptionPane.showMessageDialog(null, errMessage);
    }

    public JFrame getFrame() {
        return frame;
    }

    public JTable getProductTable() {
        return productTable;
    }

}
