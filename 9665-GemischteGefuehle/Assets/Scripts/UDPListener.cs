using System;
using System.Net;
using System.Net.Sockets;
using System.Text;


public class UDPListener
{
    private UdpClient listener;
    private int port;
    private System.Threading.Thread thread;
    private IPEndPoint groupEP;
    private object scriptFn;
    public string encoding = "ascii";
    public Action<string,int> callback = null;

    public bool Start(int port, Action<string, int> _callback)
    {
        // Create UDP client on port address
        this.port = port;
        listener = new UdpClient(port);
        groupEP = new IPEndPoint(IPAddress.Any, port);

        scriptFn = _callback;
        callback = _callback;

        // Start background thread
        thread = new System.Threading.Thread(_ThreadRun);
        thread.Priority = System.Threading.ThreadPriority.Normal;
        thread.Start();

        return true;
    }

    protected void _ThreadRun()
    {
        string data = "";
        byte[] bytes;

        while (true)
        {
            bytes = listener.Receive(ref groupEP);
            if (encoding == "ascii") 
                data = Encoding.ASCII.GetString(bytes, 0, bytes.Length);
            else if(encoding == "utf8")
                data = Encoding.UTF8.GetString(bytes, 0, bytes.Length);

            if(callback != null)
                callback(data, port);
        }

    }

    public void SetEncoding(string code)
    {
        encoding = code;
    }

    public void Close()
    {
        if (thread != null && thread.IsAlive)
            thread.Abort();

        if (listener != null)
            listener.Close();

        listener = null;
    }
}
