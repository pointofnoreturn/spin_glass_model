public class SpinGlass extends EdgeWeightedDigraph {
    private int S;
    private int[][] spins;
    private double J;
    private double entailment;
    private double T;
    private int steps;
    
    /**
     * Initializes an empty spinglass with <tt>V</tt> vertices, interaction energy J,
     * S spins, and 0 edges.
     * param V the number of vertices
     * @throws java.lang.IllegalArgumentException if <tt>V</tt> < 0
     */
    public SpinGlass(int V, double J, double entailment, double T, int S) {
        super(V);
        this.S = S;
        spins = new int[V][S];
        this.J = J;
        this.entailment = entailment;
        this.T = T;
        this.steps = 0;
    }

    /**  
     * Initializes a spinglass from an input stream.
     * The format is the number of vertices <em>V</em>,
     * followed by the number of spins <em>S</em>,
     * followed by values of spins (1 or 0) for each vertex, one vertex at a time
     * followed by the number of edges <em>E</em>,
     * followed by <em>E</em> pairs of vertices, with each entry separated by whitespace.
     * @param in the input stream
     * @throws java.lang.IndexOutOfBoundsException if the endpoints of any edge are not in prescribed range
     * @throws java.lang.IllegalArgumentException if the number of vertices or edges is negative
     */
    public SpinGlass(In in) {
        this(in.readInt(),in.readDouble(),in.readDouble(),in.readDouble(),in.readInt());
        for (int i = 0; i < V(); i++) {
            for (int j = 0; j < S; j++) {
                spins[i][j] = in.readInt();
            }
        }
        int E = in.readInt();
        if (E < 0) throw new IllegalArgumentException("Number of edges must be nonnegative");
        for (int i = 0; i < E; i++) {
            int v = in.readInt();
            int w = in.readInt();
            double weight = in.readDouble();
            addEdge(new DirectedEdge(v, w, weight));
        }
    }

    /**
     * Initializes a new spinglass that is a deep copy of <tt>G</tt>.
     * @param G the graph to copy
     */
    public SpinGlass(SpinGlass G) {
        this(G.V(),G.J(),G.entailment(),G.T(),G.S());
        for (int i = 0; i < G.V(); i++) {
            for (int j = 0; j < G.S(); j++) {
                spins[i][j]=G.spins[i][j];
            }
        }
        for (int v = 0; v < G.V(); v++) {
            // reverse so that adjacency list is in same order as original
            Stack<DirectedEdge> reverse = new Stack<DirectedEdge>();
            for (DirectedEdge e : G.adj(v)) {
                reverse.push(e);
            }
            for (DirectedEdge e : reverse) {
                ((Bag<DirectedEdge>)adj(v)).add(e);
            }
        }
    }
    
    public int S() {
        return S;
    }
    
    public double J() {
        return J;
    }
    
    public double entailment() {
        return entailment;
    }
    
    public double T() {
        return T;
    }
    
    public int steps() {
        return steps;
    }
    
    public int spin(int v, int s) {
        return spins[v][s];
    }
    
    public double avgSpin(int s) {
        int sum = 0;
        for(int v = 0; v < V(); v++) {
            sum += spins[v][s];
        }
        return 1.*sum/V();
    }
    
    public void setJ(double intEnergy) {
        J=intEnergy;
    }
    
    public void setT(double temp) {
        T=temp;
    }
    
    public void setEntailment(double entail) {
        entailment=entail;
    }
    
    public void reset() {
        steps=0;
    }

    public void setSpins(int[][] s)
    {
        for(int i=0; i<V(); i++) {
            for(int j=0; j<S; j++) {
                spins[i][j]=s[i][j];
            }
        }
    }
    
    // In a spin-glass model,
    // edges should be stored with their "to" vertex,
    // not their "from" vertex because the interaction
    // affects the "to" vertex, not the "from" vertex.
    
    public void addEdge(DirectedEdge e) {
        int v = e.from();
        int w = e.to();
        double weight = e.weight();
        DirectedEdge r = new DirectedEdge(w,v,weight);
        super.addEdge(r);
    }

    public double energyE(DirectedEdge e, int s) {
        int v = e.from();
        int w = e.to();
        if (spins[v][s]==spins[w][s]) return -1*e.weight()*J;
        return 0;
    }
    
    public double hamiltonianE() {
        double hamiltonianE = 0.;
        for (int v = 0; v < V(); v++) {
            for (int s = 0; s < S(); s++) {
                for (DirectedEdge e: adj(v)) {
                    hamiltonianE+=0.5*energyE(e,s);
                }
            }
        }
        return hamiltonianE;
    }
    
    public double energyV(int v) {
        int x=1;
        if (spins[v][0]==1) x=0;
        int y=Math.abs(spins[v][1]);
        if (x==y) return entailment;
        return 0;
    }
    
    public double hamiltonianV() {
        double hamiltonianV = 0;
        for (int v = 0; v < V(); v++) {
            hamiltonianV+=energyV(v);
        }
        return hamiltonianV;
    }
    
    public double hamiltonian() {
        return hamiltonianE()+hamiltonianV();
    }
    
    public double localEnergy(int v, int s) {
        double currentLocal = 0.;
        for (DirectedEdge e: adj(v)) {
            currentLocal+=energyE(e,s);
        }
        currentLocal+=energyV(v);
        spins[v][s]=(spins[v][s]+2)%3-1;
        double altLocal1 = 0.;
        for (DirectedEdge e: adj(v)) {
            altLocal1+=energyE(e,s);
        }
        altLocal1+=energyV(v);
        spins[v][s]=(spins[v][s]+2)%3-1;
        double altLocal2 = 0.;
        for (DirectedEdge e: adj(v)) {
            altLocal2+=energyE(e,s);
        }
        altLocal2+=energyV(v);
        spins[v][s]=(spins[v][s]+2)%3-1;
        return Math.min(altLocal1,altLocal2)-currentLocal;
    }
    
    public double flipProbability(int v, int s) {
        double energy = localEnergy(v,s);
        return Math.exp(-energy/T);
    }
    
    public void timeStep() {
        int s = (int) (Math.random()*S());
        int v = (int) (Math.random()*V());
        if (Math.random()<flipProbability(v,s))
        {
            if (s == 0) spins[v][s]=-1*spins[v][s];
            else {
                if (spins[v][s]==0) {
                    if (Math.random()<.5) spins[v][s]=-1;
                    else spins[v][s]=1;
                }
                else {
                    if (Math.random()<.5) spins[v][s]=-1*spins[v][s];
                    else spins[v][s]=0;
                }
            }
        }
        this.steps++;
    }
    
    /**
     * Returns a string representation of the spinglass.
     */
    public String toString() {
        StringBuilder s = new StringBuilder();
        String NEWLINE = System.getProperty("line.separator");
        s.append("We have "+ V() + " vertices, " + E() + " edges," + NEWLINE);
        s.append(S + " spin variables, interaction energy " + J + NEWLINE);
        s.append("entailment energy " + entailment + ", and temperature " + T + "." + NEWLINE);
        s.append("After " + steps + " step(s), we have" + NEWLINE);
        for (int v = 0; v < V(); v++) {
            s.append(v + ":");
            for (int j = 0; j < S; j++) {
                if(spins[v][j]==1) s.append(" +");
                else if(spins[v][j]==-1) s.append(" -");
                else s.append(" 0");
            }
            s.append(", edges from:");
            for (DirectedEdge e : adj(v)) {
                s.append(" " + e.to() + " (w/ weight " + e.weight()+")");
            }
            s.append(NEWLINE);
        }
        s.append("and hamiltonian "+hamiltonian());
        return s.toString();
    }

    /**
     * Unit tests the <tt>SpinGlass</tt> data type.
     */
    public static void main(String[] args) {
        In in = new In(args[0]);
        Out out = new Out(args[0].substring(0,args[0].length()-4)+"data.txt");
        SpinGlass G = new SpinGlass(in);
        out.println("number_of_steps avg_p1 avg_p2");
        for (int i = 0; i < 1000; i++) {
            for (int step = 0; step < 1000; step++)
                G.timeStep();
            out.println(G.steps()+" "+G.avgSpin(0)+" "+G.avgSpin(1));
        }
        StdOut.println(G);
    }
}
