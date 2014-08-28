package events {

import flash.events.Event;

public class FailEvent extends Event {
    public static const FAIL:String = "fail";

    public var kindOfFail:String = "undef";

    public function FailEvent(type:String, kindOfFail:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.kindOfFail = kindOfFail;
    }
}
}
