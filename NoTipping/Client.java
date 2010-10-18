import java.io.*;
import java.net.*;

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

        while ((fromServer = in.readLine()) != null) {
            System.out.println("Server: " + fromServer);
            if (fromServer.equals("Bye"))
                break;
            if (((fromServer.startsWith("ADD")) || (fromServer.startsWith("REMOVE")))) {
                fromUser = stdIn.readLine();
                if (fromUser != null) { out.println(fromUser); }
            }
        }
        out.close();
        in.close();
        stdIn.close();
        socket.close();
    }
}
