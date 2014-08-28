package view {

import flash.events.EventDispatcher;

public class User extends EventDispatcher {

    //Needs to be bindable so the List can get updates on Value-Changes:
    [Bindable]
    public var username:String;

    [Bindable]
    public var stream:String;

    [Bindable]
    //green for stream available, red for n/a
    public var color:String;

    public function User(username:String, stream:String, color:String = "0xcc0000") {
        this.username = username;
        this.stream = stream;
        this.color = color;
    }
}
}
