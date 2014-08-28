package view {

import flash.display.BitmapData;
import flash.geom.Rectangle;

public class Raster extends BitmapData {
    private var buffer:Array = new Array();

    private var r:Rectangle = new Rectangle();

    private var socket:SocketIO;

    public function Raster(width:uint, height:uint, transparent:Boolean, color:uint) {
        super(width, height, transparent, color);
    }

    /**
     * method for checking if the pixel is within its boundaries and if it needs to be sent
     * as single pixels or as a vector
     *
     * @param x        x-coord of the pixel
     * @param y        y-coord of the pixel
     * @param color    color of the pixel
     * @param asPixel    does it need to be sent as a pixel or as a vektor?
     */
    public function setPixelProxy(x:int, y:int, color:uint, asPixel:Boolean):void {
        if (x < 0) {
            x = 0;
        }
        if (x >= width) {
            x = width - 1;
        }
        if (y < 0) {
            y = 0;
        }
        if (y >= height) {
            y = height - 1;
        }
        if (x < width && x >= 0 && y < height && y >= 0 && socket != null) //if pixel within borders and socket initialized
        {
            setPixel32(x, y, color);
            if (asPixel) {
                socket.send("|" + x + "|" + y + "|" + Utils.getNumberAsHexString(color, 6) + "|\n");
            }
        }
    }

    /**
     * method for dependency injection for the socket-server
     */
    public function setSocket(socket:SocketIO):void {
        this.socket = socket;
    }

    /**
     * draw a line
     *
     * @param x0        first point x coord
     * @param y0        first point y coord
     * @param x1        second point x coord
     * @param y1        second point y coord
     * @param c            color
     */
    public function line(x0:int, y0:int, x1:int, y1:int, color:uint, justdraw:Boolean = true):void {
        //apply boundaries
        if (x0 < 0) {
            x0 = 0;
        }
        if (x0 >= width) {
            x0 = width - 1;
        }
        if (y0 < 0) {
            y0 = 0;
        }
        if (y0 >= height) {
            y0 = height - 1;
        }
        if (x1 < 0) {
            x1 = 0;
        }
        if (x1 >= width) {
            x1 = width - 1;
        }
        if (y1 < 0) {
            y1 = 0;
        }
        if (y1 >= height) {
            y1 = height - 1;
        }
        var asPixel:Boolean = true;
        if (Math.sqrt((x0 - x1) * (x0 - x1) + (y1 - y0) * (y1 - y0)) > 3.0 && !justdraw) {
            //when start and endpoint are more then 3 pix apart: dont send all the single pixel, send a line
            socket.send("l|" + x0 + "|" + y0 + "|" + x1 + "|" + y1 + "|" + Utils.getNumberAsHexString(color, 6) + "|\n");
            asPixel = false;
        }
        if (justdraw) {
            asPixel = false;
        }
        var dx:int;
        var dy:int;
        var i:int;
        var xinc:int;
        var yinc:int;
        var cumul:int;
        var x:int;
        var y:int;
        x = x0;
        y = y0;
        dx = x1 - x0;
        dy = y1 - y0;
        xinc = (dx > 0) ? 1 : -1;
        yinc = (dy > 0) ? 1 : -1;
        dx = dx < 0 ? -dx : dx;
        dy = dy < 0 ? -dy : dy;
        setPixelProxy(x, y, color, asPixel);
        //magic:
        if (dx > dy) {
            cumul = dx >> 1;
            for (i = 1; i <= dx; ++i) {
                x += xinc;
                cumul += dy;
                if (cumul >= dx) {
                    cumul -= dx;
                    y += yinc;
                }
                setPixelProxy(x, y, color, asPixel);
            }
        }
        //even more magic:
        else {
            cumul = dy >> 1;
            for (i = 1; i <= dy; ++i) {
                y += yinc;
                cumul += dx;
                if (cumul >= dy) {
                    cumul -= dy;
                    x += xinc;
                }
                setPixelProxy(x, y, color, asPixel);
            }
        }
    }

    /**
     * draw a circle
     *
     * @param px        first point x coord
     * @param py        first point y coord
     * @param r            radius
     * @param c            color
     */
    public function circle(px:int, py:int, r:int, color:uint, send:Boolean):void {
        var x:int;
        var y:int;
        var d:int;
        x = 0;
        y = r;
        d = 1 - r;
        //reflexion first point
        setPixelProxy(px + x, py + y, color, send);
        setPixelProxy(px + x, py - y, color, send);
        setPixelProxy(px - y, py + x, color, send);
        setPixelProxy(px + y, py + x, color, send);
        while (y > x) {
            if (d < 0) {
                d += (x + 3) << 1;
            }
            else {
                d += ((x - y) << 1) + 5;
                y--;
            }
            x++;
            //reflextion all the other points
            setPixelProxy(px + x, py + y, color, send);
            setPixelProxy(px - x, py + y, color, send);
            setPixelProxy(px + x, py - y, color, send);
            setPixelProxy(px - x, py - y, color, send);
            setPixelProxy(px - y, py + x, color, send);
            setPixelProxy(px - y, py - x, color, send);
            setPixelProxy(px + y, py - x, color, send);
            setPixelProxy(px + y, py + x, color, send);
        }
    }

    /**
     * draw a rectangle
     *
     * @param x0        first point x coord
     * @param y0        first point y coord
     * @param x1        second point x coord
     * @param y1        second point y coord
     * @param c            color
     */
    public function drawRect(x0:int, y0:int, x1:int, y1:int, color:uint):void {
        line(x0, y0, x0, y1, color);
        line(x0, y0, x1, y0, color);
        line(x1, y0, x1, y1, color);
        line(x0, y1, x1, y1, color);
    }
}
}
