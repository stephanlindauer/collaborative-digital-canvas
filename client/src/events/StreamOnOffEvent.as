package events {

import flash.events.Event;

public class StreamOnOffEvent extends Event {
    public static const ON:String = "StreamOn";

    public static const OFF:String = "StreamOff";

    public var info:String = "undef";

    public function StreamOnOffEvent(type:String, info:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.info = info;
    }
}
}
