public class Possibility {
	public int position;
	public int weight;
    public int[] weights;
    public int[] positions;
    public double[] torque;

    public Possibility(int[] weights, int positions[], double[] torque, int weight, int position) {
    	this.weight = weight;
    	this.position = position;
        this.weights = weights;
        this.positions = positions;
        this.torque = torque;
    }

    public String to_message() {
        return "" + weight + "," + position;
    }
}
