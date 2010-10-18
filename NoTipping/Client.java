import java.io.*;
import java.net.*;
import java.util.regex.*;
import java.util.*;

public class Client {
    public static void main(String[] args) throws Exception {
        Socket socket = null;
        PrintWriter out = null;
        BufferedReader in = null;
        String clientName = "B0$H";
        String location = "localhost";
        try {
            socket = new Socket(location, 4445);
            out = new PrintWriter(socket.getOutputStream(), true);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        } catch (UnknownHostException e) {
            System.err.println("Don't know about host: " + location + ".");
            System.exit(1);
        } catch (IOException e) {
            System.err.println("Couldn't get I/O for the connection to: " + location + ".");
            System.exit(1);
        }
        String fromServer;
        out.println(clientName);

        int weight_count = 10; //Initialize weight trackers
        boolean[] weights_self = new boolean[weight_count];
        java.util.Arrays.fill(weights_self,false);
        boolean[] weights_opp = new boolean[weight_count];
        java.util.Arrays.fill(weights_opp,false);

        while ((fromServer = in.readLine()) != null) {
            if (fromServer.equals("Bye")) { break; }
            System.out.println("Server: " + fromServer);

            String response = "";
            String[] matches = Pattern.compile("[|]").split(fromServer);
            String[] placements = Pattern.compile(" ").split(matches[1]);
            int[] counts = new int[placements.length];
            java.util.Arrays.fill(counts,0);
            int[] weights = new int[placements.length];
            int[] positions = new int[placements.length];
            
            for(int i = 0; i < placements.length; i++) { //Split server data into program usable info
                String[] placement = Pattern.compile(",").split(placements[i]);
                int weight = Integer.parseInt(placement[0].trim());
                int position = Integer.parseInt(placement[1].trim());
                counts[weight-1]++;
                if ((counts[weight-1] == 2) || ((counts[weight-1] == 1) && (weights_self[weight-1] == false))) {
                    weights_opp[weight-1] = true; //Note that opponent has used their weight
                }
                weights[i] = weight;
                positions[i] = position;
            }
            
            if (fromServer.startsWith("ADD")) {
                response = nextAddMove(weights, positions, weights_self, weights_opp); //This modifies weights_self
                out.println(response);
            } else if (fromServer.startsWith("REMOVE")) {
                response = nextRemoveMove(weights, positions);
               out.println(response);
            } else if (fromServer.startsWith("REJECT")) {
                System.out.println("Oh crap");
            } else if (fromServer.startsWith("ACCEPT")) {
            } else if (fromServer.startsWith("TIP")) {
                break;
            } else if (fromServer.startsWith("WIN")) {
                break;
            } else if (fromServer.startsWith("TIMEOUT")) {
                break;
            }
        }
        out.close();
        in.close();
        socket.close();
    }

    public static String nextAddMove(int[] weights, int[] positions, boolean[] self, boolean[] opponent) {
        double[] torques = calculate_torque(weights, positions);
        for(int i = 0; i < self.length; i++) {
            if (self[i] == false) { //If not yet placed
                boolean[] self_new = new boolean[self.length]; System.arraycopy(self, 0, self_new, 0, self.length);
                self_new[i] = true; //Simulate making this move
                int weight = i+1;
                int board_width = 31;
                int offset = 15; //To change 0-30 to be -15 to 15 and -15-15 to 0-30
                
                boolean[] available_positions = new boolean[board_width]; java.util.Arrays.fill(available_positions,false);
                for(int j = 0; j < positions.length; j++) { available_positions[positions[j] + offset] = true; }   
                
                int[] weights_new = new int[weights.length + 1]; System.arraycopy(weights, 0, weights_new, 0, weights.length);
                weights_new[weights_new.length-1] = weight; //The weight that we are looking at
                ArrayList<Possibility> possibilities = new ArrayList<Possibility>();
                
                for(int j = 0; j < available_positions.length; j++) { //Try every position
                    if (available_positions[j]) {
                        int position = j - offset;
                        int[] positions_new = new int[positions.length + 1]; System.arraycopy(positions, 0, positions_new, 0, positions.length);
                        positions_new[positions_new.length-1] = position;
                        double[] torques_new = calculate_new_torque(torques, weight, position);
                        if ((torques_new[0] > 0) || (torques_new[1] > 0)) {
                            //then it's bad
                        } else { //it's a valid move for me
                            possibilities.add(new Possibility(weights_new, positions_new, torques_new));
                        }
                    }
                }
            }
        }
        return "BAD";
    }

    public static String nextRemoveMove(int[] weights, int[] positions) {
        return "WORSE";   
    }

    public static double[] calculate_new_torque(double[] torque, int weight, int position) {
        double left_torque = torque[0];
        double right_torque = torque[1];
        double in1=0,out1=0,in3=0,out3=0;
        if (position < -3) {
            out3 += (-1) * (position-(-3)) * weight;
        } else {
            in3 += (position-(-3))* weight;
        }
        if (position < -1) {
            out1 += (-1) * (position-(-1)) * weight;
        } else {
            in1 += (position-(-1))* weight;
        }
        return new double[] {left_torque + out3 - in3, right_torque + in1 - out1}; //Tip if either > 0
    }

    public static double[] calculate_torque(int[] weights, int[] positions) {
        double left_torque=0.0,right_torque=0.0,in1=0,out1=0,in3=0,out3=0;
        in3 += 9; //From board itself
        in1 += 3; //From board itself
        for (int i=0; i<weights.length; i++) {
            int position = positions[i]-15;
            int weight = weights[i];
            if (position < -3) {
                out3 += (-1) * (position-(-3)) * weight;
            } else {
                in3 += (position-(-3))* weight;
            }
            if (position < -1) {
                out1 += (-1) * (position-(-1)) * weight;
            } else {
                in1 += (position-(-1))* weight;
            }
        }
        System.out.println("1: in = " + in1 + ", out = " + out1);
        System.out.println("3: in = " + in3 + ", out = " + out3);
        left_torque = out3 - in3;
        right_torque = in1 - out1;
        return new double[] {left_torque, right_torque}; //Tip if either > 0
    }
}
