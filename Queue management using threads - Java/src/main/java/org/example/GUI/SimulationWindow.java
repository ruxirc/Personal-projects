package org.example.GUI;

import org.example.Model.Client;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;

public class SimulationWindow extends JFrame {
    private JPanel queuesPanel;
    private JLabel[] queueNameLabels;
    private JLabel[] queueStatusLabel;
    private JLabel currentTimeLabel;
    private JPanel topRightPanel;
    private JTextArea clientDisplayArea;

    public SimulationWindow(int numberOfQueues) {
        setTitle("Simulation Window");
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setSize(800, 600);

        // Panel pentru afișarea clienților
        topRightPanel = new JPanel(new BorderLayout());
        JLabel clientLabel = new JLabel("Clients:");
        clientDisplayArea = new JTextArea(10, 15);
        clientDisplayArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(clientDisplayArea);
        topRightPanel.add(clientLabel, BorderLayout.NORTH);
        topRightPanel.add(scrollPane, BorderLayout.CENTER);

        // Eticheta pentru timpul curent
        currentTimeLabel = new JLabel("Current Time: 0");

        // Crearea panelului pentru etichetele cozilor
        queuesPanel = new JPanel(new GridLayout(numberOfQueues, 2));
        queueNameLabels = new JLabel[numberOfQueues];
        queueStatusLabel = new JLabel[numberOfQueues];

        for (int i = 0; i < numberOfQueues; i++) {
            JPanel queuePanel = new JPanel(); // Create a new panel for each queue
            queuePanel.setLayout(new GridLayout(1, 2)); // Use GridLayout with one row and two columns

            queueNameLabels[i] = new JLabel("Queue " + (i + 1) + ":");
            queueStatusLabel[i] = new JLabel("Empty");

            queuePanel.add(queueNameLabels[i]);
            queuePanel.add(queueStatusLabel[i]);

            queuesPanel.add(queuePanel); // Add each queue panel to the main queuesPanel
        }

        // Adăugarea componentelor în conținutul ferestrei
        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(currentTimeLabel, BorderLayout.NORTH);
        getContentPane().add(queuesPanel, BorderLayout.CENTER);
        getContentPane().add(topRightPanel, BorderLayout.EAST);

        setVisible(true);
    }

    public void updateCurrentTime(int currentTime) {
        currentTimeLabel.setText("Current Time: " + currentTime);
    }

    public void updateQueueLabel(int queueIndex, String status) {
        queueStatusLabel[queueIndex].setText(status);
    }

    public void displayClient(Client client) {
        clientDisplayArea.append("Client " + client.getId() + " (" + client.getArrivalTime() + ", " + client.getServiceTime() + ")\n");
    }

    public void closeWindow() {
        setVisible(false);
        dispose();
    }
}
