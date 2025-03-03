package presentation;

import javax.swing.*;
import java.awt.event.ActionListener;

public class MainView {
    private JButton customerButton;
    private JButton productButton;
    private JButton orderButton;
    private JPanel mainPanel;
    private JButton addOrderButton;
    private JFrame frame;

    public MainView(){
        frame = new JFrame("Main");
        frame.setContentPane(mainPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
    }

    public void addActionListenerClientButton(ActionListener e){ customerButton.addActionListener(e);}
    public void addActionListenerProductButton(ActionListener e){productButton.addActionListener(e);}
    public void addActionListenerOrderButton(ActionListener e){orderButton.addActionListener(e);}
    public void addActionListenerAddOrderButton(ActionListener e){addOrderButton.addActionListener(e);}

    public JFrame getFrame() {
        return frame;
    }

    public void setFrame(JFrame frame) {
        this.frame = frame;
    }
}
