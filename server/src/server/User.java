package server;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.SocketException;

class User extends Thread {

    private Socket cs; // the explicit socket to which this one user is
    // connected
    private Server server; // socketserver to which the client is connected to
    // just used as a reference to communicate
    private PrintWriter out; // output for all data being sent to the server
    private BufferedReader in; // input for all data being sent to the server
    private String name = null;
    private String password = null;
    private BufferedImage image;
    private String streamadress = "off";
    public boolean isStreaming = false;

    /**
     * Constructor
     *
     * @param cs     Socket for direct I/O
     * @param server Reference to the Server-Class administrating all the Users
     * @param image  Reference for direct graphic insertion
     */
    public User(Socket cs, Server server, final BufferedImage image) {
        this.cs = cs;
        this.server = server;
        this.image = image;
    }

    /**
     * Runs the Thread
     */
    public void run() {
        try {
            in = new BufferedReader(new InputStreamReader(cs.getInputStream()));
            out = new PrintWriter(new DataOutputStream(cs.getOutputStream()));
            String login = in.readLine();
            // reads the first line being sent which is supposed to be the
            // username + password

            if (login.startsWith("login|")) {
                int posSeperatorNamePassword = login.indexOf("|", 6); // second
                // seperator
                name = login.substring(6, posSeperatorNamePassword);// get the
                // username
                // string
                int posSeperatorPasswordEnd = login.indexOf("|",
                        posSeperatorNamePassword + 1); // third seperator
                password = login.substring(posSeperatorNamePassword + 1,
                        posSeperatorPasswordEnd); // get the password string

                if (((name.equals("strzebkowski") && password.equals("beuth"))
                        || (name.equals("admin") && password.equals("password"))
                        || (name.equals("mustermann") && password.equals("123"))
                        || (name.equals("peter") && password.equals("hallo"))
                        || (name.equals("username") && password.equals("password")))
                        && !server.isClient(name)) {
                    // for securitay :E
                    password = null;

                    // send informations about loggedin users
                    String[] currentclients = server.getClients();
                    for (int i = 0; i < currentclients.length; i++) {
                        out.println("s|loggedin|" + currentclients[i] + "#\n");
                        if (server.getuser(currentclients[i]).isStreaming) {
                            out.println("s|streamon|" + currentclients[i]
                                    + "#\n");
                        }
                    }
                    out.flush();

                    // transfer non-blank pixels
                    for (int x = 0; x < image.getWidth(); x++) {
                        for (int y = 0; y < image.getHeight(); y++) {
                            if (image.getRGB(x, y) != 0xffffffff) {
                                out.println("|"
                                        + Integer.toString(x)
                                        + "|"
                                        + Integer.toString(y)
                                        + "|"
                                        + Integer.toHexString(
                                        image.getRGB(x, y))
                                        .substring(2) + "#");

                            }
                        }
                    }

                    out.flush();
                    // finish login procedure
                    out.println("m|" + name + "|welcome to the server " + name
                            + "!#\n");
                    out.flush();
                    server.addClient(name, this);
                    System.out.println("logged in " + name);
                    server.broadcastEverybodyElse(name, "s|loggedin|" + name
                            + "#\n");

                    // start loop for I/O-handling
                    for (String buffer; (buffer = in.readLine()) != null; ) {
                        String[] inputstringar = buffer.split("\\|");

                        if (new Character(buffer.charAt(0)).equals("|"
                                .charAt(0)))// if pixel
                        {
                            image.setRGB(Integer.valueOf(inputstringar[1]),
                                    Integer.valueOf(inputstringar[2]), Integer
                                            .parseInt(inputstringar[3]
                                                    .substring(0, 6), 16));
                            server.broadcastEverybodyElse(name, buffer + "#");
                        } else if (inputstringar[0].equals("m"))// if message
                        {
                            if (inputstringar[1] != null) {
                                server.broadcastEverybodyElse(name, "m|" + name
                                        + "|" + inputstringar[1] + "#");
                            }
                        } else if (inputstringar[0].equals("sys")) {
                            // todo
                        } else if (inputstringar[0].equals("wcstron")) {
                            streamadress = inputstringar[1];
                            isStreaming = true;
                            server.broadcastAll("s|streamon|" + name + "#");

                        } else if (inputstringar[0].equals("wcstroff")) {
                            streamadress = "off";
                            isStreaming = false;
                            server.broadcastAll("s|streamoff|" + name + "#");
                        } else if (new Character(buffer.charAt(0)).equals("l"
                                .charAt(0)))// line
                        {

                            Rasterizer.drawLine(Integer
                                    .valueOf(inputstringar[1]), Integer
                                    .valueOf(inputstringar[2]), Integer
                                    .valueOf(inputstringar[3]), Integer
                                    .valueOf(inputstringar[4]), Integer
                                    .parseInt(inputstringar[5].substring(0, 6),
                                            16), image);

                            server.broadcastEverybodyElse(name, buffer + "#");
                        } else if (new Character(buffer.charAt(0)).equals("c"
                                .charAt(0)))// circle
                        {

                            Rasterizer.drawCircle(Integer
                                    .valueOf(inputstringar[1]), Integer
                                    .valueOf(inputstringar[2]), Integer
                                    .valueOf(inputstringar[3]), Integer
                                    .parseInt(inputstringar[4].substring(0, 6),
                                            16), image);

                            server.broadcastEverybodyElse(name, buffer + "#");
                        } else if (new Character(buffer.charAt(0)).equals("r"
                                .charAt(0)))// rectangle
                        {

                            Rasterizer.drawRect(Integer
                                    .valueOf(inputstringar[1]), Integer
                                    .valueOf(inputstringar[2]), Integer
                                    .valueOf(inputstringar[3]), Integer
                                    .valueOf(inputstringar[4]), Integer
                                    .parseInt(inputstringar[5].substring(0, 6),
                                            16), image);

                            server.broadcastEverybodyElse(name, buffer + "#");
                        } else {
                            System.out.println("unimplemented req:" + buffer);
                        }
                    }
                    // connection closer:
                    server.broadcastEverybodyElse(name, "s|loggedout|" + name
                            + "#\n");
                    out.flush();
                    in.close();
                    out.close();
                    server.removeClient(name);
                    System.out.println("user " + name + " loggedoff");
                } else {
                    // connection closer for login fails:
                    out.println("fuckoff!");
                    out.flush();
                    in.close();
                    out.close();

                    System.out.println("login of " + name
                            + " failed due to invalid loginstring:" + login
                            + "or allready logged in");
                    server.removeClient(name);
                }
            }
        } catch (SocketException e) {
            // Connection-Closer Socket-Exceptions
            e.printStackTrace();
            try {
                in.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
            System.out.println("user " + name
                    + " signed off exception caught in catch of user thread");
            try {
                server.broadcastEverybodyElse(name, "s|loggedout|" + name
                        + "#\n");
            } catch (Exception e1) {
                e1.printStackTrace();
            }
            out.flush();
            out.close();
            server.removeClient(name);
        } catch (Exception e) {
            // Connection-Closer for all possible Exceptions
            e.printStackTrace();
            try {
                in.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
            System.out.println("user " + name
                    + " signed off exception caught in catch of user thread");
            try {
                server.broadcastEverybodyElse(name, "s|loggedout|" + name
                        + "#\n");
            } catch (Exception e1) {
                e1.printStackTrace();
            }
            out.flush();
            out.close();
            server.removeClient(name);
        }

    }

    /**
     * Getter Username
     *
     * @return username of that specific Thread
     */
    public String getUserName() {
        return name;
    }

    /**
     * toString
     *
     * @return String with username and streaming-address
     */
    public String toString() {
        return name + "|" + streamadress;
    }

    /**
     * Send Message straight to the Server
     *
     * @param msg The message thats supposed to be sent
     */
    public void send(String msg) {
        out.println(msg);
        out.flush();
    }
}