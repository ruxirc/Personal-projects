package org.example.GUI;

import org.example.BusinessLogic.SimulationManager;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class UserInterface {
    private JTextField clientsNumber;
    private JTextField queueNumber;
    private JTextField minArrival;
    private JTextField maxArrival;
    private JTextField minService;
    private JTextField maxService;
    private JTextField simulationTime;
    private JLabel clientsNumberL;
    private JLabel queueNumberL;
    private JLabel minArrivalL;
    private JLabel maxArrivalL;
    private JLabel minServiceL;
    private JLabel maxServiceL;
    private JLabel simulationTimeL;
    private JLabel strategyL;
    private JRadioButton timeStrategy;
    private JRadioButton queueStrategy;

    public UserInterface() {
        clientsNumber = new JTextField();
        queueNumber = new JTextField();
        minArrival = new JTextField();
        maxArrival = new JTextField();
        minService = new JTextField();
        maxService = new JTextField();
        simulationTime = new JTextField();

        // Initialize labels
        clientsNumberL = new JLabel("Number of Clients:");
        queueNumberL = new JLabel("Number of Queues:");
        minArrivalL = new JLabel("Minimum Arrival Time:");
        maxArrivalL = new JLabel("Maximum Arrival Time:");
        minServiceL = new JLabel("Minimum Service Time:");
        maxServiceL = new JLabel("Maximum Service Time:");
        simulationTimeL = new JLabel("Simulation Time:");
        strategyL = new JLabel("Strategy:");
        timeStrategy.setText("Time Strategy");
        queueStrategy.setText("Queue Strategy ");
    }

    public void addToFrame1 () {
        JFrame frame = new JFrame("Polynomial Calculator");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(600, 400);
        frame.setResizable(true);

        JPanel panel = new JPanel(new GridLayout(0, 2));

        // Add labels and text fields
        addLabelAndTextField(panel, clientsNumberL, clientsNumber);
        addLabelAndTextField(panel, queueNumberL, queueNumber);
        addLabelAndTextField(panel, minArrivalL, minArrival);
        addLabelAndTextField(panel, maxArrivalL, maxArrival);
        addLabelAndTextField(panel, minServiceL, minService);
        addLabelAndTextField(panel, maxServiceL, maxService);
        addLabelAndTextField(panel, simulationTimeL, simulationTime);

        // Add strategy label and radio buttons
        JPanel strategyPanel = new JPanel();
        strategyPanel.setLayout(new FlowLayout(FlowLayout.LEFT));
        strategyPanel.add(strategyL);
        strategyPanel.add(timeStrategy);
        strategyPanel.add(queueStrategy);

        panel.add(strategyPanel);

        JButton startSimulationButton = new JButton("Start Simulation");
        startSimulationButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                startSimulation();
            }
        });
        panel.add(startSimulationButton);

        frame.add(panel);
        frame.setVisible(true);
    }

    private void addLabelAndTextField(JPanel panel, JLabel label, JTextField textField) {
        panel.add(label);
        panel.add(textField);
    }

    public void startSimulation(){
        int numberOfClients = Integer.parseInt(clientsNumber.getText());
        int numberOfQueues = Integer.parseInt(queueNumber.getText());
        int arrivalTimeMin = Integer.parseInt(minArrival.getText());
        int arrivalTimeMax = Integer.parseInt(maxArrival.getText());
        int serviceTimeMin = Integer.parseInt(minService.getText());
        int serviceTimeMax = Integer.parseInt(maxService.getText());
        int simulationTimeMax = Integer.parseInt(simulationTime.getText());
        boolean isTimeStrategy = timeStrategy.isSelected();
        boolean isQueueStrategy = queueStrategy.isSelected();

        // Crearea unei instanțe de SimulationManager și transmiterea informațiilor prin constructor
        SimulationManager simulationManager = new SimulationManager(
                numberOfClients,
                numberOfQueues,
                arrivalTimeMin,
                arrivalTimeMax,
                serviceTimeMin,
                serviceTimeMax,
                simulationTimeMax,
                isTimeStrategy,
                isQueueStrategy
        );

        try {
            simulationManager.startSimulation();
        }catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(null, "Invalid input! Please enter valid numbers.", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    public static void main(String[] args) {

        UserInterface ui = new UserInterface();
        ui.addToFrame1();

    }
}
