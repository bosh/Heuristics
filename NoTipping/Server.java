import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

	ServerSocket serverSocket = null;
	static int port = 4445;	//default

	
	public Server(int port) {
        try {
			serverSocket = new ServerSocket(port);
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		System.out.println("Accepting connections on port " + port);
		int i = 0;
		while (i <= 2) {	//waits for 2 clients to connect. Once they both disconnenct the server terminates. 
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
	
	public Server() {
		this(port);
	}
	
	public boolean getStopProcessing() {
		return true;
	}
	
	public static void main(String[] args) {

		System.out.println("Start");
		try {
			if (args.length > 0) {
				port = Integer.parseInt(args[0]);
			}	
		} catch (Exception e) {
			System.out.println("Invalid port");
		} finally {
			Server s = new Server();
		}
      //  System.out.println("Disconnecting");
  
	}
	
	public static void forceClose() {
		System.exit(-1);
	}
	

}

