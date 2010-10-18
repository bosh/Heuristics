import java.util.ArrayList;

public class GameState {

	private double right_torque=0.0;
	private double left_torque=0.0;
	private int [] position_weights = new int[31];
	private String mode;
	private ArrayList<String> players = new ArrayList<String>();
	private String current_player=null;
	private boolean gameInProgress = true;
	private	int weights_used = 0;

	/*
	 * formula to calulate torque:
	 * in1 and out1 calculates torque on lever at -1
	 * in3 and out3 calculates torque on lever at -3
	 * 
	 * At -3, the tip occurs when torque on the left > torque on right or out3-in3 > 0
	 * At -1, the tip occurs when torque on the right > torque on left or in1-out1 > 0
	 * If either of the conditions hold true, the player loses the game
	 */
	public void calculate_torque() {		
		
		right_torque=0.0;
		left_torque=0.0;
		
		double in1=0,out1=0,in3=0,out3=0;
		
		//the board weights 3 kgs which is concentrated at 0, so there is some intorque at -3 and -1
		in3 += 9;
		in1 += 3;
		
		for (int i=0; i<position_weights.length; i++) {
			if (position_weights[i] == -1)
				continue;
			
			int pos = i-15;
			int wt = position_weights[i];
//			System.out.println("Calculating: " + pos + "," + wt);
			
			if (pos < -3) {
//				System.out.print("out3: " + out3 + "+" + "(-1) * (" + pos + "-(-3)) * " + wt);
				out3 += (-1) * (pos-(-3)) * wt;
//				System.out.println("=" + out3);
			} else {
//				System.out.print("in3: " + in3 + "+" + pos + "-(-3) * " + wt);
				in3 += (pos-(-3))* wt;
//				System.out.println("=" + in3);
			}
			
			
			if (pos < -1) {
//				System.out.print("out1: " + out1 + "+" + "(-1) * (" + pos + "-(-1)) * " + wt);
				out1 += (-1) * (pos-(-1)) * wt;
//				System.out.println("=" + out1);
			}
			else {
//				System.out.print("in1: " + in1 + "+"  + pos + "-(-1) * " + wt);
				in1 += (pos-(-1))* wt;
//				System.out.println("=" + in1);
			}
		}
		
		System.out.println("in1=" + in1);
		System.out.println("out1=" + out1);
		System.out.println("in3=" + in3);
		System.out.println("out3=" + out3);
		right_torque = in1 - out1;
		left_torque = out3 - in3;
	}
	
	public String getPositions() {
		String positions="";
		
		for (int i=0;i<position_weights.length;i++) {
			if (position_weights[i] == -1)
				continue;
			positions += position_weights[i] + "," + (i-15) + " ";
		}
				
		return positions.trim();
	}

	public double getRighttorque() {
		return right_torque;
	}

	public void setRighttorque(double intorque) {
		this.right_torque = intorque;
	}

	public double getLefttorque() {
		return left_torque;
	}

	public void setLefttorque(double outtorque) {
		this.left_torque = outtorque;
	}

	public int[] getPosition_weights() {
		return position_weights;
	}

	public void setPosition_weights(int[] positionWeights) {
		for (int i = 0; i<positionWeights.length;i++) {
			this.position_weights[i] = positionWeights[i];
		}
		//position_weights = positionWeights;
	}

	public String getMode() {
		return mode;
	}

	public void setMode(String mode) {
		this.mode = mode;
	}

	public ArrayList<String> getPlayers() {
		return players;
	}

	public void setPlayers(ArrayList<String> players) {
		this.players = players;
	}

	public String getCurrent_player() {
		return current_player;
	}

	public void setCurrent_player(String currentPlayer) {
		current_player = currentPlayer;
	}

	public boolean isGameInProgress() {
		return gameInProgress;
	}

	public void setGameInProgress(boolean gameInProgress) {
		this.gameInProgress = gameInProgress;
	}

	public String nextPlayer() {
		String new_player= players.get((players.indexOf(current_player)+1) % (players.size()));
		current_player = new_player;
		return new_player;
	}

	public int getWeights_used() {
		return weights_used;
	}

	public void setWeights_used(int weightsUsed) {
		weights_used = weightsUsed;
	}
	
	public void incrementWeights_used() {
		weights_used++;
	}
	
	public void decrementWeights_used() {
		weights_used--;
	}
	
	public void removePlayer(String tag) {
		this.players.remove(tag);
	}
	
	
}


