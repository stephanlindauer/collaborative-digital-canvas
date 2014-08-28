package server;

import java.awt.image.BufferedImage;

public class Rasterizer {

    /**
     * draw a line
     *
     * @param x0    first point x coord
     * @param y0    first point y coord
     * @param x1    second point x coord
     * @param y1    second point y coord
     * @param color color
     * @param image buffered image to draw on
     */
    public static void drawLine(int x0, int y0, int x1, int y1, int color,
                                BufferedImage image) {
        int dx;
        int dy;
        int i;
        int xinc;
        int yinc;
        int cumul;
        int x;
        int y;
        x = x0;
        y = y0;
        dx = x1 - x0;
        dy = y1 - y0;
        xinc = (dx > 0) ? 1 : -1;
        yinc = (dy > 0) ? 1 : -1;
        dx = dx < 0 ? -dx : dx;
        dy = dy < 0 ? -dy : dy;

        setRGBcheck(x, y, color, image);
        if (dx > dy) {
            cumul = dx >> 1;
            for (i = 1; i <= dx; ++i) {
                x += xinc;
                cumul += dy;
                if (cumul >= dx) {
                    cumul -= dx;
                    y += yinc;
                }
                setRGBcheck(x, y, color, image);
            }
        } else {
            cumul = dy >> 1;
            for (i = 1; i <= dy; ++i) {
                y += yinc;
                cumul += dx;
                if (cumul >= dy) {
                    cumul -= dy;
                    x += xinc;
                }
                setRGBcheck(x, y, color, image);
            }
        }
    }

    /**
     * draw a circle
     *
     * @param px    first point x coord
     * @param py    first point y coord
     * @param r     radius
     * @param c     color
     * @param image buffered image to draw on
     */
    public static void drawCircle(int px, int py, int r, int color,
                                  BufferedImage image) {

        int x;
        int y;
        int d;
        x = 0;
        y = r;
        d = 1 - r;
        setRGBcheck(px + x, py + y, color, image);
        setRGBcheck(px + x, py - y, color, image);
        setRGBcheck(px - y, py + x, color, image);
        setRGBcheck(px + y, py + x, color, image);

        while (y > x) {
            if (d < 0) {
                d += (x + 3) << 1;
            } else {
                d += ((x - y) << 1) + 5;
                y--;
            }
            x++;
            setRGBcheck(px + x, py + y, color, image);
            setRGBcheck(px - x, py + y, color, image);
            setRGBcheck(px + x, py - y, color, image);
            setRGBcheck(px - x, py - y, color, image);
            setRGBcheck(px - y, py + x, color, image);
            setRGBcheck(px - y, py - x, color, image);
            setRGBcheck(px + y, py - x, color, image);
            setRGBcheck(px + y, py + x, color, image);
        }
    }

    /**
     * draw a rectangle
     *
     * @param x0    first point x coord
     * @param y0    first point y coord
     * @param x1    second point x coord
     * @param y1    second point y coord
     * @param c     color
     * @param image buffered image to draw on
     */
    public static void drawRect(int x0, int y0, int x1, int y1, int color,
                                BufferedImage image) {
        drawLine(x0, y0, x0, y1, color, image);
        drawLine(x0, y0, x1, y0, color, image);
        drawLine(x1, y0, x1, y1, color, image);
        drawLine(x0, y1, x1, y1, color, image);
    }

    /**
     * last check if pixel is within boundaries before it gets actually drawn
     * onto the canvas
     *
     * @param x0    x coord
     * @param y0    y coord
     * @param c     color
     * @param image buffered image to draw on
     */
    public static void setRGBcheck(int x0, int y0, int color,
                                   BufferedImage image) {
        if (x0 < 0) {
            x0 = 0;
        }
        if (x0 >= image.getWidth()) {
            x0 = image.getWidth() - 1;
        }
        if (y0 < 0) {
            y0 = 0;
        }
        if (y0 >= image.getHeight()) {
            y0 = image.getHeight() - 1;
        }
        image.setRGB(x0, y0, color);
    }
}
