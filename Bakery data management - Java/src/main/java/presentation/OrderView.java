package presentation;

import javax.swing.*;
import java.awt.event.ActionListener;

public class OrderView {
    private JTextField modOrderId;
    private JTextField modClientId;
    private JTextField modProdId;
    private JTextField modProdStock;
    private JTextField delOrderId;
    private JButton modifyButton;
    private JButton deleteButton;
    private JButton backButton;
    private JPanel ordersPanel;
    private JButton showTableButton;
    private JScrollPane scrollPane;
    private JTable ordersTable;
    private JFrame frame;

    public OrderView() {
        scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        frame = new JFrame("Orders");
        frame.setContentPane(ordersPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(false);
    }

    public String getModOrderId() {
        return modOrderId.getText();
    }

    public String getModClientId() {
        return modClientId.getText();
    }

    public String getModProdId() {
        return modProdId.getText();
    }

    public String getModProdStock() {
        return modProdStock.getText();
    }

    public String getDelOrderId() {
        return delOrderId.getText();
    }

    public void addActionListenerButtonShowTable(ActionListener e) {
        showTableButton.addActionListener(e);
    }

    public void addActionListenerButtonModify(ActionListener e) {
        modifyButton.addActionListener(e);
    }

    public void addActionListenerButtonDelete(ActionListener e) {
        deleteButton.addActionListener(e);
    }

    public void addActionListenerButtonBack(ActionListener e) {
        backButton.addActionListener(e);
    }

    void showError(String errMessage) {
        JOptionPane.showMessageDialog(this.getOrdersTable(), errMessage);
    }

    public JTable getOrdersTable() {
        return ordersTable;
    }

    public JFrame getFrame() {
        return frame;
    }
}
