import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.Hashtable;

public class ServerConnection implements Runnable {

	ServerSocket serverSocket = null;
	Socket socket = null;
	private String tag="";
	private static GameState game = new GameState();
	private long elapsed_time = 0;
	private String gameapplet = "NoTippingApplet";

	
	//store all the avalaible weights in a hashtable. The key is the weight (1-10) and the value indicates if the weight is 
	//available. Once a client uses a weight, the value changes to false.
	Hashtable<String, Boolean> weights = new Hashtable<String, Boolean>();
	
	public ServerConnection(Socket socket) {		
		super();
		
		for (int i = 1; i<=10; i++) {
			weights.put(Integer.toString(i), true);
		}
		
		int[] pos_wts = new int[31];
		for (int i=0; i<=30; i++) {
			pos_wts[i] = -1;
		}
		
		pos_wts[-4+15] = 3;	//3 kilogram block at position -4. All positions are offset by 15
		
		game.setPosition_weights(pos_wts);
		game.calculate_torque();
		game.setMode("ADD");
		
		
		this.socket = socket;
		try {
			//tcp_no_delay = socket.getTcpNoDelay()?"no":"yes";
			socket.setTcpNoDelay(true);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void run() {
		processClient();
	}
	
	PrintWriter out;
	BufferedReader in;	
	
	private boolean processClient() {
		out = null;
		in  = null;
		try {
			out = new PrintWriter(socket.getOutputStream(), true);
			in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

			String inputLine;	
			inputLine = in.readLine() ;
			
			//if the client connects without a tag or a blank tag then the connection is refused. 
			if (inputLine == null) {
				System.out.println("Error:No request received");
				return false;
			} else if (inputLine.trim().length() == 0) {
				System.out.println("Error:Zero length request");
				return false;
			} 
			inputLine = inputLine.trim();
			setTag(inputLine);
			System.out.println("Connected with client " + getTag());
			out.println("Connection accpeted for " + getTag());
			
			if (!tag.equals(gameapplet)) {
				if (game.getCurrent_player() == null) {
					game.setCurrent_player(tag);
					System.out.println("Setting " + tag + " as current player");
				}
				game.getPlayers().add(tag);
			}

			interactWithClient();
		} catch (Exception e) {
			System.out.println("Error processing thread " + ", " +  e.getMessage());
			return false;
		} finally {
			try {
				if (out != null ) out.close();
				if (in  != null ) in.close();
				socket.close();
			} catch(Exception e) {}

		}
		return true;
			
	}
	

	private static String new_game_message = "";
	private static String prev_game_message = "";
	
	public void interactWithClient() {
		String inputline="";
		
		if (this.tag.equals(gameapplet)) {
			setNew_game_message("");
			for (String s:game.getPlayers()) {
				setNew_game_message(getNew_game_message() + "ADDPLAYER|" + s + "\n");			
			}
		} else {
			setNew_game_message("ADDPLAYER|" + this.getTag());
		}
		
		try {
			
			while (game.isGameInProgress()) {
				

				if (this.tag.equals(gameapplet)) {
					if (!getPrev_game_message().equals(getNew_game_message())) {
						setPrev_game_message(getNew_game_message());
						out.println(getNew_game_message());
						System.out.println(getNew_game_message());
					}
					continue;
				}
				
				if (!this.tag.equals(game.getCurrent_player()))
					continue;
				
				if (game.getPlayers().size() <  2)
					continue;
										
				String state = game.getMode() +"|" + game.getPositions() + "|in="+game.getRighttorque() + ",out="+game.getLefttorque();
				System.out.println(state);
				out.println(state);

				long start = System.nanoTime();
				inputline = in.readLine();
				long end = System.nanoTime();

				elapsed_time += end-start;
				System.out.println(tag + " time= " + (elapsed_time/1000000000) + " seconds");
				
				if (elapsed_time/1000000000 > 120) {
					out.println("TIMEOUT");
					out.println("LOSE");
					//setNew_game_message("RESULT|" + game.nextPlayer() + "|TIMEOUT");
					setNew_game_message("TIMEOUT|" + this.tag);
					game.removePlayer(this.getTag());
					game.setGameInProgress(false);
					break;
				}
				
				
				if (inputline == null)
					break;
				
				if (inputline.trim().equals(""))
					continue;
				
				
				
				System.out.println(getTag() + ": " + inputline);
				if (inputline.equals("Bye")) {
					System.out.println("Client " + getTag() + " terminated connection");
					out.println("Bye");
					game.removePlayer(this.getTag());
					setNew_game_message("REMOVEPLAYER|" + getTag() + "\n");
					game.setCurrent_player(game.nextPlayer());
					break;
				} 
				
				String[] res = inputline.split(",");
				
				if (game.getMode().equals("ADD")) {
					if (weights.containsKey(res[0])) {
						if (weights.get(res[0])) {
							int pos = Integer.parseInt(res[1]);
							if (pos >=-15 && pos<=15) {
								if (game.getPosition_weights()[pos+15] == -1) {								
									game.getPosition_weights()[pos+15] = Integer.parseInt(res[0]);								
									weights.put(res[0], false);
									game.incrementWeights_used();
									game.calculate_torque();
									setNew_game_message("ADD|" + game.getCurrent_player() + "|" + inputline);
									if (game.getRighttorque() > 0 || game.getLefttorque() > 0) { 
										System.out.println("in=" + game.getRighttorque() + " & out=" + game.getLefttorque());
										out.println("TIP");
										out.println("LOSE");
//										setNew_game_message("RESULT|" + game.nextPlayer() + "|TIP");										
//										setNew_game_message("Bye");
										game.removePlayer(this.getTag());
										game.setGameInProgress(false);
									}
									else {
										out.println("ACCEPT");
										if (game.getWeights_used() >= 20) {
											game.setMode("REMOVE");
										}

										game.setCurrent_player(game.nextPlayer());
									}
								} else {
									out.println("REJECT [Position already occupied]");
								}
							} else {
								out.println("REJECT [Invalid Position]");	
							}
						} else {
							out.println("REJECT [Weight Aready used]");
						}
							
					} else {
						out.println("REJECT [Invalid Weight]");
					}
				} else if (game.getMode().equals("REMOVE")) {
					if (weights.containsKey(res[0])) {
						int wt = Integer.parseInt(res[0]);
						int pos = Integer.parseInt(res[1]);
						if (game.getPosition_weights()[pos+15] == wt) {
							game.getPosition_weights()[pos+15] = -1;
							game.decrementWeights_used();
							game.calculate_torque();
							setNew_game_message("REMOVE|" + game.getCurrent_player() + "|" + inputline);
							if (game.getRighttorque() > 0 || game.getLefttorque() > 0) { 
								System.out.println("in=" + game.getRighttorque() + " & out=" + game.getLefttorque());
								out.println("TIP");
								out.println("LOSE");
								game.removePlayer(this.getTag());
								game.setGameInProgress(false);
							}
							else {
								out.println("ACCEPT");
								if (game.getWeights_used() < 0) {
									out.println("LAST");
									out.println("LOSE");
									game.removePlayer(this.getTag());
									game.setGameInProgress(false);
								}
								game.setCurrent_player(game.nextPlayer());
							}
						} else {
							out.println("REJECT [Weight " + wt + " not present at position " + pos + "]");
						}
					} else {
						out.println("REJECT [Invalid Weight]");
					}

					

				}
				inputline = "";
			}
			
			if (getNew_game_message().startsWith("TIMEOUT") && this.tag.equals("NoTippingApplet")) {
				out.println(new_game_message);
			}
			
			if (!game.isGameInProgress() && !this.tag.equals(game.getCurrent_player()))
				out.println("WIN");
			
			setNew_game_message("REMOVEPLAYER|" + getTag() + "\n");
			
			if (game.getPlayers().size() <= 0)
				Server.forceClose();
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
	}

	public String getTag() {
		return tag;
	}

	public void setTag(String tag) {
		this.tag = tag;
	}
	
	public synchronized String getNew_game_message () {
		return new_game_message;
	}

	public synchronized void setNew_game_message (String message) {
		new_game_message = message;
	}

	public synchronized String getPrev_game_message () {
		return prev_game_message;
	}

	public synchronized void setPrev_game_message (String message) {
		prev_game_message = message;
	}


}

