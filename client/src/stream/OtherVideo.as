package stream {

import flash.display.Sprite;
import flash.events.*;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

public class OtherVideo extends Sprite {
    private var vid:Video;

    private var nsPlayer:NetStream;

    private var nc:NetConnection;

    private var currentname:String;

    private static var _instance:OtherVideo;

    private var ready:Boolean;

    public static function getInstance():OtherVideo {
        if (_instance == null) {
            _instance = new OtherVideo(new SingletonEnforcer());
        }
        return _instance;
    }

    /**
     * constructor for singleton
     *
     * @param sE        the singletonenforcer
     */
    public function OtherVideo(sE:SingletonEnforcer) {
        ready = false;
        nc = new NetConnection();
        nc.client = this;
        nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        nc.connect("rtmp://localhost/live");
    }

    /**
     * starts to get a certain stream (name/username is always also the name stream)
     */
    public function play(name:String):void {
        if (ready) {
            currentname = name;
            nsPlayer.play(currentname);
        }
    }

    /**
     * starts starts the stream when netstatus event is dispatched
     */
    private function onNetStatus(event:NetStatusEvent):void {
        if (nc.connected) {
            nsPlayer = new NetStream(nc);
            nsPlayer.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            nsPlayer.client = new CustomClient();
            nsPlayer.play(currentname);
            vid = new Video(197, 145);
            vid.attachNetStream(nsPlayer);
            addChild(vid);
            ready = true;
        }
    }

    /**
     * useless but needs to be caught to avoid ugly errors
     */
    public function onBWDone():void {
    }

    /**
     * useless but needs to be caught to avoid ugly errors
     */
    public function onMetaData():void {
    }
}
}

class CustomClient {
    public function onMetaData(info:Object):void {
    }

    public function onCuePoint(info:Object):void {
    }
}

class SingletonEnforcer {
}
