import java.io.*;
import java.net.*;
import java.util.regex.*;
import java.util.*;

public class Client {
    public static void main(String[] args) throws Exception {
        Socket socket = null;
        PrintWriter out = null;
        BufferedReader in = null;
        String clientName = "b0$h";
        String location = "localhost";
        try {
            socket = new Socket(location, 44444);
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
            //Server data parsing
            if (fromServer.startsWith("ADD") || fromServer.startsWith("REMOVE")) {
                String response = "";
                String[] matches = Pattern.compile("[|]").split(fromServer);
                String[] placements = Pattern.compile(" ").split(matches[1]);
                int[] counts = new int[weight_count]; java.util.Arrays.fill(counts,0);
                int[] weights = new int[placements.length];
                int[] positions = new int[placements.length];
                
                for(int i = 0; i < placements.length; i++) { //Pairs parsing
                    String[] placement = Pattern.compile(",").split(placements[i]);
                    int weight = Integer.parseInt(placement[0].trim());
                    int position = Integer.parseInt(placement[1].trim());
                    if (weight == 3 && position == -4) {
                        //Skip adding it to the counter
                    } else {
                        int weight_index = weight-1;
                        counts[weight_index]++;
                        if ((counts[weight_index] == 2) || ((counts[weight_index] == 1) && (weights_self[weight_index] == false))) {
                            weights_opp[weight_index] = true; //Note that opponent has used their weight
                        }
                    }
                    weights[i] = weight;
                    positions[i] = position;
                }
                if (fromServer.startsWith("ADD")) {
                    response = nextAddMove(weights, positions, weights_self, weights_opp); //This modifies weights_self
                } else if (fromServer.startsWith("REMOVE")) {
                    response = nextRemoveMove(weights, positions);
                }
                System.out.println(response);
                if (response != "FORFEIT") { out.println(response); }
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
        ArrayList<Possibility> possibilities = new ArrayList<Possibility>();
        //Possibility generation
        for(int i = 0; i < self.length; i++) {
            if (self[i] == false) { //If not yet placed
                boolean[] self_new = new boolean[self.length]; System.arraycopy(self, 0, self_new, 0, self.length);
                self_new[i] = true; //Simulate making this move
                int board_width = 31;
                int offset = 15; //To change 0-30 to be -15 to 15 and -15-15 to 0-30
                boolean[] available_positions = new boolean[board_width]; java.util.Arrays.fill(available_positions,true);
                for(int j = 0; j < positions.length; j++) { available_positions[positions[j] + offset] = false; }   
                for(int j = 0; j < available_positions.length; j++) { //Try every position
                    if (available_positions[j]) {
                        int weight = i+1;
                            int[] weights_new = new int[weights.length + 1]; System.arraycopy(weights, 0, weights_new, 0, weights.length);
                            weights_new[weights_new.length-1] = weight; //The weight that we are looking at
                        int position = j - offset;
                            int[] positions_new = new int[positions.length + 1]; System.arraycopy(positions, 0, positions_new, 0, positions.length);
                            positions_new[positions_new.length-1] = position;
                        double[] torques_new = calculate_new_add_torque(torques, weight, position);
                        if ((torques_new[0] > 0) || (torques_new[1] > 0)) {
                            // System.out.println("BAD TIMES " + torques_new[0] + "  " + torques_new[1] + " " + weight + " " + position);
                            //Bad times
                        } else { //it's a valid move for me
                            // System.out.println("FINE " + torques_new[0] + "  " + torques_new[1] + " " + weight + " " + position);
                            possibilities.add(new Possibility(weights_new, positions_new, torques_new, weight, position));
                        }
                    }
                }
            }
        }
        //Narrow down choices
            //........... errr

        //Picking best choice from possibilities
        if (possibilities.size() == 0) {
            System.out.println("no options :(");
            return "FORFEIT";
        }
        Possibility choice = possibilities.get(0);
        for(int i = 1; i < possibilities.size(); i++) {
            if (possibilities.get(i).weight > choice.weight) {
                choice = possibilities.get(i);
            } else if (possibilities.get(i).weight > choice.weight && Math.random() < .3) {
                choice = possibilities.get(i);
            }
        }
        self[choice.weight-1] = true;
        return choice.to_message();
    }

    public static String nextRemoveMove(int[] weights, int[] positions) {
        double[] torques = calculate_torque(weights, positions);
        ArrayList<Possibility> possibilities = new ArrayList<Possibility>();
        for(int i = 0; i < weights.length; i++) {
            int weight = weights[i];
            int position = positions[i];

            int[] weights_new = new int[weights.length - 1];
            int[] positions_new = new int[positions.length - 1];
            for(int j = 0; j < weights.length; j++) {
                if (j < i) {
                    weights_new[j] = weights[j];
                    positions_new[j] = positions[j];
                } else if (j > i) {
                    weights_new[j-1] = weights[j];
                    positions_new[j-1] = positions[j];
                }
            }
            double[] torques_new = calculate_new_remove_torque(torques, weight, position);
            if ((torques_new[0] > 0) || (torques_new[1] > 0)) {
                // System.out.println("BAD TIMES " + torques_new[0] + "  " + torques_new[1] + " " + weight + " " + position);
                //Bad times
            } else { //it's a valid move for me
                // System.out.println("FINE " + torques_new[0] + "  " + torques_new[1] + " " + weight + " " + position);
                possibilities.add(new Possibility(weights_new, positions_new, torques_new, weight, position));
            }
        }
        
        //Picking best choice from possibilities
        if (possibilities.size() == 0) {
            System.out.println("no options :(");
            return "FORFEIT";
        }
        Possibility choice = possibilities.get(0);
        for(int i = 1; i < possibilities.size(); i++) {
            if (possibilities.get(i).weight > choice.weight) {
                choice = possibilities.get(i);
            } else if (possibilities.get(i).weight > choice.weight && Math.random() < .3) {
                choice = possibilities.get(i);
            }
        }
        return choice.to_message();
    }

    public static double[] calculate_new_remove_torque(double[] torque, int weight, int position) {
        double left_torque = torque[0];
        double right_torque = torque[1];
        double in1=0,out1=0,in3=0,out3=0;
        if (position < -3) {
            out3 -= (-1) * (position-(-3)) * weight;
        } else {
            in3 -= (position-(-3))* weight;
        }
        if (position < -1) {
            out1 -= (-1) * (position-(-1)) * weight;
        } else {
            in1 -= (position-(-1))* weight;
        }
        return new double[] {left_torque + out3 - in3, right_torque + in1 - out1}; //Tip if either > 0
    }

    public static double[] calculate_new_add_torque(double[] torque, int weight, int position) {
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
            int position = positions[i];
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
        System.out.println("1: in = " + in1 + ", out = " + out1 + " | 3: in = " + in3 + ", out = " + out3);
        left_torque = out3 - in3;
        right_torque = in1 - out1;
        return new double[] {left_torque, right_torque}; //Tip if either > 0
    }
}
