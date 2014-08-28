package view {

import events.FailEvent;
import events.IncomingMessageEvent;
import events.StreamOnOffEvent;
import events.UserLogInOutEvent;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.Socket;
import flash.system.System;
import flash.utils.Timer;

public class SocketIO extends Sprite {
    public var socket:Socket;

    private var username:String;

    private var password:String;

    private var bmpDat:Raster;

    private var prefixTemp:String;

    /**
     * Contructor for the Socket
     *
     * @param username        Username to Login to the Java-Socket-Server
     * @param password        Password to Login to the Java-Socket-Server
     * @param bmpDat        Reference to the Bitmap-Data-Object to which the Socket-Input have to be forwarded to
     */
    public function SocketIO(username:String, password:String, bmpDat:Raster):void {
        this.bmpDat = bmpDat;
        this.username = username;
        this.password = password;
        this.prefixTemp = "";
        init();
    }

    /**
     * Initializer
     *
     * Connects the server-socket and registers all
     * the socket-related event-handlers
     */
    private function init(e:Event = null):void {

        socket = new Socket();
        socket.connect("localhost", 5010);
        socket.addEventListener(Event.CLOSE, closeHandler);
        socket.addEventListener(Event.CONNECT, connectHandler);
        socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
    }

    /**
     * Sends the first string through the socket which allways has to be
     * the login-string containing username and password
     */
    private function connectHandler(event:Event):void {

        socket.writeUTFBytes("login|" + username + "|" + password + "|\n");
        socket.flush();
        dispatchEvent(event);
    }

    /**
     * Gets called when there is more data in the socket-buffer
     * to be processed. Depending on what the string looks like the
     * string gets passed on to the peace of code. If the data is data
     * for the canvas this class uses the direct reference to the bmdDat-object.
     * Everything else gets converted into a new Event which is then being dispatched.
     */
    private function dataHandler(event:ProgressEvent):void {
        var inputstr:String = socket.readUTFBytes(socket.bytesAvailable);
        var inputstrlines:Array = inputstr.split("\n");
        for (var i:int = 0; i < inputstrlines.length; i++) {
            var line:String = inputstrlines[i] as String;
            if (prefixTemp.length > 0) //any fragments from last fetch?
            {
                //add fragment of last fetch-process to beginning of current line:
                line = prefixTemp + line;
                prefixTemp = "";
            }
            if (line.charAt(line.length - 2) == ("#")) //if string complete
            {
                var linessplit:Array = line.split("|");
                var prefix:String = linessplit[0] as String;
                if (line.charAt(0) == "|") //if pixel
                {
                    var color:String = "0x" + new String(linessplit[3]).slice(0, 6);
                    bmpDat.setPixel(linessplit[1], linessplit[2], parseInt(color, 16));
                }
                else if (line.charAt(0) == "l") //if line
                {
                    bmpDat.line(linessplit[1], linessplit[2], linessplit[3], linessplit[4], parseInt(new String(linessplit[5]).replace("#", ""), 16), true);
                }
                else if (line.charAt(0) == "c") //if circle
                {
                    bmpDat.circle(linessplit[1], linessplit[2], linessplit[3], parseInt(new String(linessplit[4]).replace("#", ""), 16), false);
                }
                else if (line.charAt(0) == "r") //if rectangle
                {
                    bmpDat.drawRect(linessplit[1], linessplit[2], linessplit[3], linessplit[4], parseInt(new String(linessplit[5]).replace("#", ""), 16));
                }
                else if (line.charAt(0) == "m") //if msg
                {
                    var date:Date = new Date();
                    dispatchEvent(new IncomingMessageEvent(IncomingMessageEvent.MSG, linessplit[1], date, String(linessplit[2]).substr(0, String(linessplit[2]).length - 2)));
                }
                else if (line.substr(0, 11) == "s|loggedin|") //if login
                {
                    var user:String = line.substr(11)
                    var userclean:Array = user.split("#");
                    dispatchEvent(new UserLogInOutEvent(UserLogInOutEvent.LOGIN, userclean[0]));
                }
                else if (line.substr(0, 12) == "s|loggedout|") //if logout
                {
                    var userlo:String = line.substr(12);
                    var usercleanlo:Array = userlo.split("#");
                    dispatchEvent(new UserLogInOutEvent(UserLogInOutEvent.LOGOUT, usercleanlo[0]));
                }
                else if (line.substr(0, 11) == "s|streamon|") //if stream on
                {
                    var userstron:String = line.substr(11);
                    var usercleanstron:Array = userstron.split("#");
                    dispatchEvent(new StreamOnOffEvent(StreamOnOffEvent.ON, usercleanstron[0]));
                }
                else if (line.substr(0, 12) == "s|streamoff|") //if stream on
                {
                    var userstroff:String = line.substr(12);
                    var usercleanstroff:Array = userstroff.split("#");
                    dispatchEvent(new StreamOnOffEvent(StreamOnOffEvent.OFF, usercleanstroff[0]));
                }
                else {
                    trace("unimplemented line: " + line);
                }
            }
            else { //if not complete define as prefix for future data
                prefixTemp = line;
            }
        }
    }

    /**
     * Is called when connection is closed. Dispatches a "FailEvent",
     * which gets handled in the "Application.mxml".
     */
    private function closeHandler(event:Event):void {
        dispatchEvent(new FailEvent(FailEvent.FAIL, "connection closed"));
    }

    /**
     * Is called when an IO-error occurs. Dispatches a "FailEvent",
     * which gets handled in the "Application.mxml".
     */
    private function ioErrorHandler(event:IOErrorEvent):void {
        dispatchEvent(new FailEvent(FailEvent.FAIL, "io error"));
    }

    /**
     * Is called when an security-error occurs. Dispatches a "FailEvent",
     * which gets handled in the "Application.mxml".
     */
    private function securityErrorHandler(event:SecurityErrorEvent):void {
        dispatchEvent(new FailEvent(FailEvent.FAIL, "security error"));
    }

    /**
     * Sends a String straight to the Socket-Server
     *
     * @param msg        the string which should be send to the socket-server
     */
    public function send(msg:String):void {
        socket.writeUTFBytes(msg);
        socket.flush();
    }
}
}
