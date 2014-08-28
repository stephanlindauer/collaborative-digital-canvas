package server;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.Date;
import javax.imageio.ImageIO;
import javax.swing.*;

@SuppressWarnings("serial")
public class BackEnd extends JFrame {

    @SuppressWarnings("unused")
    private BufferedImage image;
    private ViewComponent viewComponent;

    /**
     * Constructor
     *
     * @param image the buffered image displayed in the backend-window
     */
    public BackEnd(final BufferedImage image) {
        super("canvas view");
        this.image = image;
        // sets white as the standard color for the whole picture
        for (int i = 0; i < image.getWidth(); i++) {
            for (int j = 0; j < image.getHeight(); j++) {
                image.setRGB(i, j, 0xffffff);
            }
        }

        viewComponent = new ViewComponent(image);
        add(viewComponent);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(700, 500);
        viewComponent.paintComponent(image.createGraphics());
        setVisible(true);

        // timer-handler responsible for updating the picture-frame
        ActionListener taskPerformer = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                viewComponent.repaint();
            }
        };
        new Timer(1000, taskPerformer).start();

        // timer-handler responsible for saving the image on disk
        ActionListener imageSaver = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent evt) {
                try {
                    File f = new File(new Date().toString().replace(" ", "")
                            .replace(":", "").concat(".bmp"));
                    ImageIO.write(image, "BMP", f);
                } catch (Exception e) {
                    System.out.println("catch");
                }
            }
        };
        new Timer(60000, imageSaver).start();

    }

    // the component containing the image
    class ViewComponent extends JComponent {
        BufferedImage image;

        public ViewComponent(BufferedImage image) {
            this.image = image;
        }

        @Override
        protected void paintComponent(Graphics g) {
            if (image != null)
                g.drawImage(image, 0, 0, this);
        }
    }
}