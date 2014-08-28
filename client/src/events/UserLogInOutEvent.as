package events {

import flash.events.Event;

public class UserLogInOutEvent extends Event {
    public static const LOGOUT:String = "LOGOUT";

    public static const LOGIN:String = "LOGIN";

    public var username:String;

    public function UserLogInOutEvent(type:String, username:String) {
        super(type, false, false);
        this.username = username;
    }
}
}
