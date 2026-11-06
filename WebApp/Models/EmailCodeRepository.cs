using System.Data;
using System.Security.Cryptography;
using Dapper;

namespace WebApp.Api.Models;
public class EmailCodeRepository : BaseRepository
{
    const int MaxAttempts = 5;
    class CodeRow
    {
        public int EmailCodeId { get; set; }
        public string CodeHash { get; set; } = null!;
        public short Attempts { get; set; }
    }
    public EmailCodeRepository(IDbConnection connection) : base(connection) { }

    public string? CreateCode(string memberId, short purpose)
    {
        int recent = connection.ExecuteScalar<int>(
            "SELECT COUNT(*) FROM EmailCode WHERE MemberId = @memberId AND Purpose = @purpose AND CreatedAt > DATEADD(SECOND, -60, SYSDATETIME())",
            new { memberId, purpose });
        if (recent > 0) return null;
        string code = RandomNumberGenerator.GetInt32(0, 1000000).ToString("D6");
        connection.Execute(
            "UPDATE EmailCode SET UsedAt = SYSDATETIME() WHERE MemberId = @memberId AND Purpose = @purpose AND UsedAt IS NULL",
            new { memberId, purpose });
        connection.Execute(
            "INSERT INTO EmailCode (MemberId, Purpose, CodeHash, ExpiresAt) VALUES (@memberId, @purpose, @hash, DATEADD(MINUTE, 10, SYSDATETIME()))",
            new { memberId, purpose, hash = BCrypt.Net.BCrypt.HashPassword(code) });
        return code;
    }

    public int Verify(string memberId, short purpose, string code)
    {
        string sql = @"SELECT TOP 1 EmailCodeId, CodeHash, Attempts FROM EmailCode
                       WHERE MemberId = @memberId AND Purpose = @purpose AND UsedAt IS NULL AND ExpiresAt > SYSDATETIME()
                       ORDER BY EmailCodeId DESC";
        CodeRow? row = connection.QueryFirstOrDefault<CodeRow>(sql, new { memberId, purpose });
        if (row == null) return -1;
        if (row.Attempts >= MaxAttempts) return -3;
        if (!BCrypt.Net.BCrypt.Verify(code, row.CodeHash))
        {
            connection.Execute("UPDATE EmailCode SET Attempts = Attempts + 1 WHERE EmailCodeId = @id", new { id = row.EmailCodeId });
            return row.Attempts + 1 >= MaxAttempts ? -3 : -1;
        }
        connection.Execute("UPDATE EmailCode SET UsedAt = SYSDATETIME() WHERE EmailCodeId = @id", new { id = row.EmailCodeId });
        return 1;
    }

    public bool IsConfirmed(string memberId)
    {
        return connection.ExecuteScalar<bool>("SELECT EmailConfirmed FROM Member WHERE MemberId = @memberId", new { memberId });
    }
    public int ConfirmEmail(string memberId)
    {
        return connection.Execute("UPDATE Member SET EmailConfirmed = 1 WHERE MemberId = @memberId", new { memberId });
    }
    public int ResetPassword(string memberId, string newPassword)
    {
        string hash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        return connection.Execute("UPDATE Member SET Password = @hash WHERE MemberId = @memberId", new { memberId, hash });
    }
}