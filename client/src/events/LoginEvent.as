package events {

import flash.events.Event;

public class LoginEvent extends Event {
    public static const LOGIN:String = "login";

    public var username:String;

    public var password:String;

    public function LoginEvent(type:String, bubbles:Boolean, cancelable:Boolean, username:String, password:String) {
        super(type, bubbles, cancelable);
        this.username = username;
        this.password = password;
    }
}
}
