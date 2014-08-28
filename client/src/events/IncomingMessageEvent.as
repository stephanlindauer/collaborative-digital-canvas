package events {

import flash.events.Event;


public class IncomingMessageEvent extends Event {
    public static const MSG:String = "msg";

    public var author:String;

    public var timestamp:Date;

    public var message:String;

    public function IncomingMessageEvent(type:String, author:String, timestamp:Date, message:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.author = author;
        this.timestamp = timestamp;
        this.message = message;
    }
}
}
