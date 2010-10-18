public class Possibility {
    public int[] weights;
    public int[] positions;
    public double[] torque;

    public Possibility(int[] weights, int positions[], double[] torque) {
        this.weights = weights;
        this.positions = positions;
        this.torque = torque;
    }
}
