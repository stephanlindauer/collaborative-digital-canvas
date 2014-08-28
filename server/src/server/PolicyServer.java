package server;

import java.net.*;

public class PolicyServer extends Thread {
    protected int port;
    protected ServerSocket serverSocket;

    /**
     * Constructor
     *
     * @param port number of the port to be user
     */
    public PolicyServer(int port) {
        this.port = port;
    }

    /**
     * waits for connects and passes them on to their own thread the deals with
     * i/o
     */
    public void run() {
        try {
            serverSocket = new ServerSocket(this.port);
            while (true) {
                System.out.println("policy-server ready...");
                Socket socket = this.serverSocket.accept();
                PolicyServerConnection socketConnection = new PolicyServerConnection(
                        socket);
                socketConnection.start();
            }
        } catch (Exception e) {
        }
    }

    /**
     * safely closing the socket
     */
    protected void finalize() {
        try {
            serverSocket.close();
        } catch (Exception e) {
        }
    }
}
