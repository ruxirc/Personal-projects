package org.example.BusinessLogic;

import org.example.GUI.SimulationWindow;
import org.example.Model.Client;
import org.example.Model.Server;

import javax.swing.*;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;

public class SimulationManager {
    private int simulationTimeMax;
    private int currentTime = 0;
    private int numberOfClients;
    private int numberOfQueues;
    private int arrivalTimeMin;
    private int arrivalTimeMax;
    private int serviceTimeMin;
    private int serviceTimeMax;
    private static boolean isTimeStrategy;
    private static boolean isQueueStrategy;

    private static final List<Server> queues = new ArrayList<>();
    private static final PriorityQueue<Client> clientQueue = new PriorityQueue<>(Comparator.comparingInt(Client::getArrivalTime));
    private static final Random random = new Random();
    private static SimulationWindow simulationWindow;
    private static FileWriter writer;
    private double averageWaitingTime;
    private double averageServiceTime;
    private int peakHour;
    private static int max = 0;

    public SimulationManager(
            int numberOfClients,
            int numberOfQueues,
            int arrivalTimeMin,
            int arrivalTimeMax,
            int serviceTimeMin,
            int serviceTimeMax,
            int simulationTimeMax,
            boolean isTimeStrategy,
            boolean isQueueStrategy

    ) {
        this.numberOfClients = numberOfClients;
        this.numberOfQueues = numberOfQueues;
        this.arrivalTimeMin = arrivalTimeMin;
        this.arrivalTimeMax = arrivalTimeMax;
        this.serviceTimeMin = serviceTimeMin;
        this.serviceTimeMax = serviceTimeMax;
        this.simulationTimeMax = simulationTimeMax;
        this.isTimeStrategy = isTimeStrategy;
        this.isQueueStrategy = isQueueStrategy;
    }

    public void startSimulation() {
        simulationWindow = new SimulationWindow(numberOfQueues);

        SwingWorker<Void, Void> worker = new SwingWorker<Void, Void>() {
            @Override
            protected Void doInBackground() throws Exception {

                for (int i = 0; i < numberOfQueues; i++) {
                    Server spot = new Server(String.valueOf(i), simulationWindow);
                    queues.add(spot);
                    spot.start();
                }

                generateRandom();
                displayRandom(clientQueue);

                while (currentTime <= simulationTimeMax) {
                    while (!clientQueue.isEmpty() && clientQueue.peek().getArrivalTime() <= currentTime) {
                        Client client = clientQueue.poll();
                        assignClientToQueue(client);
                    }
                    Thread.sleep(1000);
                    System.out.println(currentTime);
                    currentTime++;

                    //calcul peak hour
                    int sum = 0;
                    for (Server a : queues) {
                        sum += a.getQueueLength();
                    }
                    if(sum > max){
                        max = sum;
                        peakHour = currentTime;
                    }

                    // afisez in fereastra si in fisierul de log
                    simulationWindow.updateCurrentTime(currentTime);
                    writeLog(currentTime, clientQueue, queues);
                }

                //calcul averageWaitingTime si averageServiceTime
                Server s = new Server("", simulationWindow);
                averageWaitingTime = s.getAverageWaitingTime();
                averageServiceTime = s.getAverageServiceTime();
                writeLogAvg(peakHour, averageWaitingTime, averageServiceTime);

                for (Server spot : queues) {
                    spot.terminate();
                }

                for (Server spot : queues) {
                    spot.join();
                }

                //System.out.println("Simulation ended.");

                return null;
            }

            @Override
            protected void done() {
                simulationWindow.closeWindow();
                try {
                    writer.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        };

        worker.execute();
    }


    private void generateRandom() {
        for (int i = 1; i <= numberOfClients; i++) {
            int arrivalTime = random.nextInt(arrivalTimeMax - arrivalTimeMin + 1) + arrivalTimeMin;
            int serviceTime = random.nextInt(serviceTimeMax - serviceTimeMin + 1) + serviceTimeMin;
            Client c = new Client(i, arrivalTime, serviceTime);
            clientQueue.add(c);
            //simulationWindow.displayClient(c);
            //System.out.println("Generated client " + (i) + " with arrival time " + arrivalTime + " and service time " + serviceTime);
        }
    }

    private void displayRandom(PriorityQueue<Client> clientQueue){
        // coada deja memoreaza in ordinea timpului de sosire => e deja sortata daca fac cu poll
        PriorityQueue<Client> copy = new PriorityQueue<>(clientQueue);
        while(!copy.isEmpty()){
            Client client = copy.poll();
            simulationWindow.displayClient(client);
        }
    }


    private static void assignClientToQueue(Client client) {
        Server selectedLane = queues.get(0);
        //int bestScore = selectedLane.getQueueLength() + selectedLane.getTotalServiceTime();

        if(isQueueStrategy){
            int minQ = Integer.MAX_VALUE;

            for (int i = 0; i < queues.size(); i++) {
                Server a = queues.get(i);
                if(a.getQueueLength() < minQ){
                    selectedLane = a;
                    minQ = a.getQueueLength();
                }
            }
        }

        else if(isTimeStrategy){
            int minT = Integer.MAX_VALUE;
            for (int i = 0; i < queues.size(); i++) {
                Server b = queues.get(i);
                if(b.getTotalServiceTime() < minT){
                    selectedLane = b;
                    minT = b.getTotalServiceTime();
                }
            }
        }

//        for (Server lane : queues) {
//            int laneScore = lane.getQueueLength() + lane.getTotalServiceTime();
//            if (laneScore < bestScore) {
//                selectedLane = lane;
//                bestScore = laneScore;
//            }
//        }

        selectedLane.addClient(client);

        //System.out.println("Client " + client.getId() + " " + client.getArrivalTime() + " " + client.getServiceTime() + " assigned to queue " + selectedLane.getNameOfQueue());
    }

    private static void initializeLogFile(){
        try {
            writer = new FileWriter("SimulationLog.txt");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    private static void writeLog(int currentTime, PriorityQueue<Client> clientQueue, List<Server> queues) {
        if(writer == null) {
            initializeLogFile();
        }
        try {
            writer.write("Time: " + currentTime);

            writer.write("\nWaiting clients: ");
            for (Client client : clientQueue) {
                writer.write("(" + client.getId() + "," + client.getArrivalTime() + "," + client.getServiceTime() + "); ");
            }
            writer.write("\n");

            for (Server queue : queues) {
                writer.write("Queue " + queue.getNameOfQueue() + ": ");
                if (queue.getQueueLength() == 0) {
                    writer.write("closed");
                } else {
                    for (Client client : queue.getClients()) {
                        writer.write("(" + client.getId() + "," + client.getArrivalTime() + "," + client.getServiceTime() + "); ");
                    }
                }
                writer.write("\n");
            }

        }catch(Exception e) {
            e.printStackTrace();
        }
    }

    private void writeLogAvg(int peakHour, double averageWaitingTime, double averageServiceTime) {
        try {
            writer.write("Peak Hour: " + peakHour + "\n");
            writer.write("Average Waiting Time: " + averageWaitingTime + "\n");
            writer.write("Average Service Time: " + averageServiceTime + "\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}