package server;

import java.awt.image.BufferedImage;
import java.net.*;
import java.util.*;

public class Server {

    private Hashtable<String, User> clients;
    private int port;
    private BufferedImage image;

    @SuppressWarnings("unused")
    // just initialization
    private BackEnd backend;

    /**
     * Constructor
     *
     * @param Number of the Port the Server should listen on
     */
    public Server(int port) {
        this.port = port;
        clients = new Hashtable<String, User>();
        image = new BufferedImage(600, 400, BufferedImage.TYPE_3BYTE_BGR);
        backend = new BackEnd(image);
        new PolicyServer(843).start();
    }

    /**
     * Sets up the Socket-Server thats supposed to listen for new Connections.
     * When User logs in this method starts a new User Thread for the brand new
     * Client.
     *
     * @param Name of the Client that needs added
     */
    private void startServerListener() {
        ServerSocket ss;
        try {
            ss = new ServerSocket(port);
            System.out.println("cdc-server ready...");
            while (true) {
                new User(ss.accept(), this, image).start();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Adds a Client to the USer-Hash-Table of the Server (Login)
     *
     * @param Name of the Client that needs added
     */
    public void addClient(String name, User body) {
        clients.put(name, body);
    }

    /**
     * Removes a Client from User-Hash-Table of the Server (Disconnect,
     * Logout...)
     *
     * @param Name of the Client that needs to be removed
     */
    public void removeClient(String name) {
        clients.remove(name);
    }

    /**
     * Returns a String with the names of all the currently logged in Users
     *
     * @return A String with the names of all the currently logged in Users that
     * looks like this: "users|user1|users2|user3|..."
     */
    @SuppressWarnings("rawtypes")
    public String getUsers() {
        String users;
        users = "users|";
        for (Enumeration e = clients.keys(); e.hasMoreElements(); )
            users += (String) e.nextElement() + "|";
        if (!users.equals("users|"))
            users = users.substring(0, users.length() - 1);
        return users;
    }

    /**
     * Sends a Message to all Users currently logged in, except the User sending
     * this Message.
     *
     * @param name Name of the User sending this Message
     * @param msg  Message thats supposed to be sent
     */
    @SuppressWarnings("rawtypes")
    public void broadcastEverybodyElse(String name, String msg)
            throws Exception {
        for (Enumeration e = clients.keys(); e.hasMoreElements(); ) {
            User currentUser = (User) clients.get((String) e.nextElement());
            if (!currentUser.getUserName().equals(name)) {
                currentUser.send(msg);
            }
        }
    }

    @SuppressWarnings("rawtypes")
    public User getuser(String name) throws Exception {
        for (Enumeration e = clients.keys(); e.hasMoreElements(); ) {
            User currentUser = (User) clients.get((String) e.nextElement());
            if (currentUser.getUserName().equals(name)) {
                return currentUser;
            }
        }
        return null;
    }

    /**
     * Sends a Message to all Users currently logged in
     *
     * @param msg message thats supposed to be sent
     */
    @SuppressWarnings("rawtypes")
    public void broadcastAll(String msg) throws Exception {
        for (Enumeration e = clients.keys(); e.hasMoreElements(); ) {
            ((User) clients.get((String) e.nextElement())).send(msg);
        }
    }

    /**
     * Sends a Message straight to the specified User
     *
     * @param name       name of the sending User
     * @param targetname name of the receiving User
     * @param msg        message thats supposed to be sent
     */
    public void send(String name, String targetname, String msg)
            throws Exception {
        ((User) clients.get(targetname)).send(name + ": " + msg);
    }

    /**
     * Checks if a User with a certain Name is currently logged in
     *
     * @return Boolean true if user is logged in, false if not
     */
    public boolean isClient(String name) {
        return clients.containsKey(name);
    }

    /**
     * Returns an Array of the Names as Strings of all the currently logged in
     * Users
     *
     * @return String[] containing the Names as Strings of all the currently
     * logged in Users
     */
    @SuppressWarnings("rawtypes")
    public String[] getClients() {
        String[] resultarray = new String[clients.size()];
        int i = 0;
        for (Enumeration e = clients.keys(); e.hasMoreElements(); ) {
            User currentUser = (User) clients.get((String) e.nextElement());
            resultarray[i] = currentUser.getUserName();
            i++;
        }
        return resultarray;
    }

    /**
     * Starts Server on Standard-Port 5010 if no Port-Parameter is being passed
     *
     * @param x String Array of Parameters
     */
    public static void main(String[] x) {
        if (x.length != 0) {
            new Server(Integer.parseInt(x[0])).startServerListener();
        } else {
            new Server(5010).startServerListener();
        }

    }
}
