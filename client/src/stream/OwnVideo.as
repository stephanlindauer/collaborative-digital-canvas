package stream {

import events.OwnVideoFailEvent;
import events.OwnVideoWinEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.*;
import flash.media.Camera;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.sampler.NewObjectSample;
import flash.text.TextField;

public class OwnVideo extends Sprite {
    public var cam:Camera;

    public var video:Video;

    public var label:TextField;

    public var camFPS:Number = 25;

    public var nc:NetConnection = new NetConnection();

    public var ns:NetStream;

    private var info:Object;

    private var username:String;

    private var vid:Video;

    public function OwnVideo(name:String) {
        this.username = name;
        cam = Camera.getCamera();
        if (cam == null) {
            dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "no webcam detected"));
        }
        else {
            nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, netSecurityError);
            nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
            nc.client = this;
            nc.connect("rtmp://localhost/live");
            vid = new Video(197, 145);
            cam.setKeyFrameInterval(60);
            vid.attachCamera(cam);
            addChild(vid);
        }
    }

    private function goStream():void {
        ns = new NetStream(nc);
        ns.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        ns.attachCamera(cam);
        ns.publish(username, "live");
    }

    /**
     * handling everything that might go wrrong or right with the stream
     */
    private function netStatus(event:NetStatusEvent):void {
        info = event.info;
        switch (info.code) {
            case "NetConnection.Connect.Success":
                goStream();
                break;
            case "NetStream.Publish.BadName":
                dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "stream-adress in use"));
                cleanup();
                break;
            case "NetConnection.Connect.Failed":
                dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "connect failed"));
                cleanup();
                break;
            case "NetConnection.Connect.Rejected":
                dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "connection rejected"));
                cleanup();
                break;
            case "NetConnection.Connect.Closed":
                dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "connection closed"));
                cleanup();
                break;
            case "NetStream.Play.Start":
                break;
            case "NetStream.Publish.Start":
                dispatchEvent(new OwnVideoWinEvent(OwnVideoWinEvent.WIN, "jihaa!"));
                break;
            case "NetStream.Unpublish.Success":
                break;
            default:
                dispatchEvent(new OwnVideoFailEvent(OwnVideoFailEvent.FAIL, "unknown error"));
                cleanup();
        }
    }

    /**
     * resetting the object if something goes wrong
     */
    public function cleanup():void {
        try {
            ns.close();
            removeChild(vid);
        }
        catch (e:Error) {
        }
    }

    /**
     * useless but needs to be caught to avoid ugly errors
     */
    private function netSecurityError(event:SecurityErrorEvent):void {
    }

    /**
     * useless but needs to be caught to avoid ugly errors
     */
    private function onAsyncError(event:AsyncErrorEvent):void {
    }

    /**
     * useless but needs to be caught to avoid ugly errors
     */
    public function onBWDone():void {
    }
}
}
