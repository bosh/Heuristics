import java.lang.*;
import java.awt.*;
import java.awt.event.*;

public class HelpFrame extends Frame
	implements ActionListener {
	
	public HelpFrame() {
		System.out.println("HelpFrame()");

		setLayout(new BorderLayout());
		
		text_area = new TextArea(help, 30, 70, TextArea.SCROLLBARS_VERTICAL_ONLY);
		text_area.setEditable(false);
		add(text_area, "Center");

		Button b = new Button("Thanks");
		b.addActionListener(this);
		add(b, "South");

		addWindowListener(new WindowCloser());
		
		setTitle("No Tipping Help");
		pack();
		
		// setVisible(true);
	}

	public void actionPerformed(ActionEvent e) {
		setVisible(false);
	}

	private TextArea text_area;

	private final String help = new String(

"  This help screen assumes you are familiar with " +
"the rules of the no-tipping game.  It describes the " +
"user interface of this Java applet.\n\n" +
"  The two players are assigned colors -- blue and red.  " +
"Red moves first.  The weights in the sky have yet to " +
"be placed on the bar.  The numbers below each fulcrum " +
"indicate how close the lever is to tipping over at that " +
"edge, in terms of the torque.  Don't forget the bar has " +
"weight 3, considered to be located at position zero.  " +
"The bar will not tip if either torque is equal to zero; " +
"one of the torques must actually exceed its capacity.  " +
"Specifically, the left torque must become strictly " +
"positive, or the right torque strictly negative for " +
"tipping to occur.\n\n" +
"  Moves can be made in two ways.  The player may click and " +
"drag the desired weight or use the text area at the top of " +
"the playing field.  During the adding phase, drag weights " +
"from the sky or type <weight>,<position> in the text area " +
"and hit RETURN to move the weight.  Here <weight> is the " +
"integer indicated how heavy the weight is, and <position> " +
"is an integer between -15 and 15 indicating the destination " +
"position on the lever.  During the removing phase, the " +
"player may click and drag the desired weight into the grass " +
"(the throw-away area), or type <position> in the text area " +
"to indicate which weight should be discarded.\n\n" +
"  As soon as the lever tips, the game is over and the winner " +
"declared.\n\n" +
"  Additionally the hostname:port can also be entered in the textbox " +
"and on hitting connect, the applet connects to a server which has 2 clients as players. "+
"The server sends signals which are used to move the weights on the board and play the game. "
);

}

/*
class WindowCloser extends WindowAdapter {
	public void windowClosing(WindowEvent e) {
		System.out.println("windowClosing(WindowEvent)");
		e.getWindow().dispose();
	}
}
*/



