import java.io.*;
import java.net.*;
import java.util.regex.*;

public class Client {
    public static void main(String[] args) throws Exception {
        Socket socket = null;
        PrintWriter out = null;
        BufferedReader in = null;
        String clientName = "BOSH";
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
        BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));
        String fromServer;
        String fromUser;
        out.println(clientName);

        boolean[] weights_self = new boolean[10];
        boolean[] weights_opp = new boolean[10];

        while ((fromServer = in.readLine()) != null) {
            if (fromServer.equals("Bye")) { break; }
            System.out.println("Server: " + fromServer);

            String response = "";
            String[] matches = Pattern.compile("[|]").split(fromServer);
            String[] placements = Pattern.compile(" ").split(matches[1]);
            int[] weights = new int[placements.length];
            int[] positions = new int[placements.length];
            for(int i = 0; i < placements.length; i++) {
                String[] placement = Pattern.compile(",").split(placements[i]);
                int weight = Integer.parseInt(placement[0].trim());
                int position = Integer.parseInt(placement[1].trim());
                weights[i] = weight;
                positions[i] = position;
            }
            
            if (fromServer.startsWith("ADD")) {
                // response = nextAddMove(weights, positions, weights_self, weights_opp);
                out.println(response);
            } else if (fromServer.startsWith("REMOVE")) {
                // response = nextRemoveMove(weights, positions);
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
        stdIn.close();
        socket.close();
    }
}
