using System.Data;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public abstract class BaseProvider : IDisposable
{
    IDbConnection? connection;
    IConfiguration configuration;
    public BaseProvider(IConfiguration configuration)
    {
        this.configuration = configuration;
    }
    protected IDbConnection Connection => connection ??= new SqlConnection(configuration.GetConnectionString("Healthcare"));
    public void Dispose()
    {
        if (connection != null)
        {
            System.Console.WriteLine("!!!!Disposable!!!!");
            connection.Dispose();
        }
    }
}