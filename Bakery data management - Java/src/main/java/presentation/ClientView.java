package presentation;

import javax.swing.*;
import java.awt.event.ActionListener;

public class ClientView extends JFrame {
    private JPanel panelClients;
    private JButton addClientButton;
    private JButton modifyClientButton;
    private JButton deleteClientButton;
    private JTable clientJTable;
    private JScrollPane scrollPane;
    private JButton backButton;
    private JPanel clientsPanel;
    private JTextField addName;
    private JTextField addEmail;
    private JTextField addAddress;
    private JTextField modName;
    private JTextField modEmail;
    private JTextField modAddress;
    private JTextField delId;
    private JTextField modAge;
    private JTable clientTable;
    private JButton showTableButton;
    private JTextField modId;
    private JTextField addAge;
    private JTextField id;
    private JFrame frame;

    public ClientView() {
        scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
        frame = new JFrame("Clients");
        frame.setContentPane(clientsPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(false);
    }

    public int getAddID() {
        return Integer.parseInt(id.getText());
    }

    public String getAddName() {
        return addName.getText();
    }

    public String getAddEmail() {
        return addEmail.getText();
    }

    public String getAddAddress() {
        return addAddress.getText();
    }

    public String getAddAge() {
        return addAge.getText();
    }

    public String getModId() {
        return modId.getText();
    }

    public String getModName() {
        return modName.getText();
    }

    public String getModEmail() {
        return modEmail.getText();
    }

    public String getModAddress() {
        return modAddress.getText();
    }

    public String getModAge() {
        return modAge.getText();
    }

    public String getDelId() {
        return delId.getText();
    }

    public void addActionListenerAddClientButton(ActionListener e) {
        addClientButton.addActionListener(e);
    }

    public void addActionListenerModifyClientButton(ActionListener e) {
        modifyClientButton.addActionListener(e);
    }

    public void addActionListenerDeleteClientButton(ActionListener e) {
        deleteClientButton.addActionListener(e);
    }

    public void addActionListenerShowTableButton(ActionListener e) {
        showTableButton.addActionListener(e);
    }

    public void addActionListenerBackButton(ActionListener e) {
        backButton.addActionListener(e);
    }

    public JFrame getFrame() {
        return frame;
    }

    void showError(String errMessage) {
        JOptionPane.showMessageDialog(this, errMessage);
    }

    public JTable getClientTable() {
        return clientTable;
    }
}

