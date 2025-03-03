package presentation;

import javax.swing.*;

public class AddOrderView {
    private JButton addOrderButton;
    private JTextField amount;
    private JTextField clientId;
    private JTextField productId;
    private JScrollPane clientScrollPane;
    private JScrollPane productScrollPane;
    private JTable clientTable;
    private JTable productTable;
    private JButton backButton;
    private JPanel addOrderPanel;
    private JButton refreshTablesButton;
    private JFrame frame;

    public AddOrderView(){
        clientScrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        productScrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        frame = new JFrame("Add Order");
        frame.setContentPane(addOrderPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(false);
    }

    public String getAmount(){return amount.getText();}

    public String getClientId(){return clientId.getText();}

    public String getProductId(){return productId.getText();}

    public void addActionListenerAddOrderButton(java.awt.event.ActionListener e){addOrderButton.addActionListener(e);}

    public void addActionListenerBackButton(java.awt.event.ActionListener e){backButton.addActionListener(e);}

    public void addActionListenerRefreshTablesButton(java.awt.event.ActionListener e){refreshTablesButton.addActionListener(e);}

    void showError(String errMessage) {
        JOptionPane.showMessageDialog(frame, errMessage);
    }

    public JTable getClientTable() {
        return clientTable;
    }

    public JTable getProductTable() {
        return productTable;
    }

    public JFrame getFrame() {
        return frame;
    }
}
