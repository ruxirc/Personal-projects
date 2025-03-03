    package org.example.Model;

    import org.example.GUI.SimulationWindow;

    import java.util.LinkedList;
    import java.util.Queue;
    import java.util.concurrent.locks.Condition;
    import java.util.concurrent.locks.Lock;
    import java.util.concurrent.locks.ReentrantLock;

    public class Server extends Thread {
        private final Queue<Client> clients = new LinkedList<>();
        private final String nameOfQueue;
        private volatile boolean running = true;
        private final Lock lock = new ReentrantLock();
        private final Condition notEmpty = lock.newCondition();
        private static int totalServiceTime = 0;
        private static int totalWaitingTime = 0;
        private static int numberOfClients = 0;
        private int currentTime = 0;
        private SimulationWindow simulationWindow;


        public Server(String name, SimulationWindow simulationWindow) {
            this.nameOfQueue = name;
            this.simulationWindow = simulationWindow;
        }

        public int getQueueLength() {
            lock.lock();
            try {
                return clients.size();
            } finally {
                lock.unlock();
            }
        }

        @Override
        public void run() {
            try {
                while (running) {
                    Client client = null;
                    lock.lock();
                    try {
                        while (clients.isEmpty() && running) {
                            notEmpty.await(); // equivalent to wait()
                        }
                        if (running) {
                            client = clients.poll();
                        }
                    } finally {
                        lock.unlock();
                    }
                    if (client != null) {
                        simulationWindow.updateQueueLabel(Integer.parseInt(nameOfQueue), "Client nr. " + client.getId() + " (" + client.getArrivalTime() + ", " + client.getServiceTime() + ")");
                        Thread.sleep(client.getServiceTime() * 1000L);
                        currentTime++;
                        simulationWindow.updateQueueLabel(Integer.parseInt(nameOfQueue), "Empty");
                    }
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        public void terminate() {
            running = false;
            lock.lock();
            try {
                notEmpty.signalAll(); // wake up all waiting threads
            } finally {
                lock.unlock();
            }
        }

        public int getTotalServiceTime() {
            lock.lock();
            try {
                return totalServiceTime;
            } finally {
                lock.unlock();
            }
        }

        public double getAverageWaitingTime(){
            return (double) totalWaitingTime / numberOfClients;
        }
        public double getAverageServiceTime(){
            return (double) totalServiceTime / numberOfClients;
        }

        public void addClient(Client client) {
            lock.lock();
            try {
                clients.add(client);
                totalServiceTime += client.getServiceTime();
                totalWaitingTime += (client.getArrivalTime() - currentTime);
                numberOfClients++;
                notEmpty.signal(); // equivalent to notify
            } finally {
                lock.unlock();
            }
        }

        public String getNameOfQueue() {
            return nameOfQueue;
        }

        public Queue<Client> getClients() {
            return new LinkedList<>(clients);
        }

    }
