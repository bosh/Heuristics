import java.io.*;
import java.net.*;
import java.util.regex.*;

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
                counts[weight]++;
                if ((counts[weight] == 2) || ((counts[weight] == 1) && (weights_self[weight] == false))) {
                    weights_opp[weight] = true; //Note that opponent has used their weight
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
        return "BAD";
    }

    public static String nextRemoveMove(int[] weights, int[] positions) {
        return "WORSE";   
    }

    public double[] calculate_torque(int[] weights, int[] positions) {        
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
