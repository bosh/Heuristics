import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

	ServerSocket serverSocket = null;
	int port = 4445;

	
	public Server() {
        try {
			serverSocket = new ServerSocket(port);
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		int i = 0;
		while (i < 2) {	//waits for 2 clients to connect. Once they both disconnenct the server terminates. 
            Socket clientSocket = null;

            try {
            	//establishes client connection. Waits till a client connects
                clientSocket = serverSocket.accept();
                clientSocket.setKeepAlive(true);
                clientSocket.setTcpNoDelay(true);
                
                //start new thread, one per client
                ServerConnection sconn = new ServerConnection(clientSocket);
                Thread  clientThread = new Thread(sconn);
                clientThread.start();
                i++;
            } catch (IOException e) {
                System.out.println("could not accept connection on port " + port);
            }

        }

	}
	
	public boolean getStopProcessing() {
		return true;
	}
	
	public static void main(String[] args) {

		System.out.println("Start");
		Server s = new Server();
        System.out.println("Disconnecting");
  
	}

}
