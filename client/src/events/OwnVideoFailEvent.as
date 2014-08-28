package events {

import flash.events.Event;

public class OwnVideoFailEvent extends Event {
    public static const FAIL:String = "ovfail";

    public var kindOfFail:String = "undef";

    public function OwnVideoFailEvent(type:String, kindOfFail:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.kindOfFail = kindOfFail;
    }
}
}
