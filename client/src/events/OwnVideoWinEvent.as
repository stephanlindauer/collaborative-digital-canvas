package events {

import flash.events.Event;

public class OwnVideoWinEvent extends Event {
    public static const WIN:String = "ovwin";

    public var kindOfFail:String = "undef";

    public function OwnVideoWinEvent(type:String, kindOfFail:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.kindOfFail = kindOfFail;
    }
}
}
