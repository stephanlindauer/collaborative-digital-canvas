package server;

import java.io.*;
import java.net.*;

public class PolicyServerConnection extends Thread {
    protected Socket socket;
    protected BufferedReader sin;
    protected PrintWriter sout;

    /**
     * Constructor
     *
     * @param socket Socket for input output
     */
    public PolicyServerConnection(Socket socket) {
        this.socket = socket;
    }

    /**
     * get the reader and writer from the socket
     */
    public void run() {
        try {
            sin = new BufferedReader(new InputStreamReader(
                    socket.getInputStream()));
            sout = new PrintWriter(socket.getOutputStream(), true);
            readPolicyRequest();
        } catch (Exception e) {
        }
    }

    /**
     * reads and checks the request and then sends out the policy xml-data
     */
    protected void readPolicyRequest() {
        try {
            String request = read();
            if (request.equals("<policy-file-request/>")) {
                writePolicy();
            }
        } catch (Exception e) {
        }
        finalize();
    }

    /**
     * sends the policy xml-data
     */
    protected void writePolicy() {
        try {
            sout.write("<?xml version=\"1.0\"?>" + "<cross-domain-policy>"
                    + "<allow-access-from domain=\"*\" to-ports=\"*\" />"
                    + "</cross-domain-policy>" + "\u0000");
            sout.close();
        } catch (Exception e) {
        }
    }

    /**
     * read data from the buffer till zero byte is reached or input extends more
     * than 200 chars
     *
     * @return the request string
     */
    protected String read() {
        StringBuffer buffer = new StringBuffer();
        int codePoint;
        boolean zeroByteRead = false;
        try {
            do {
                codePoint = sin.read();
                if (codePoint == 0) {
                    zeroByteRead = true;
                } else if (Character.isValidCodePoint(codePoint)) {
                    buffer.appendCodePoint(codePoint);
                }
            } while (!zeroByteRead && buffer.length() < 200);
        } catch (Exception e) {
        }
        return buffer.toString();
    }

    /**
     * safely closing everything
     */
    protected void finalize() {
        try {
            sin.close();
            sout.close();
            socket.close();
        } catch (Exception e) {

        }
    }
}
