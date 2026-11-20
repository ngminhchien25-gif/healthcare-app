using Dapper;
using System.Data;
using WebApp.Services;
using Microsoft.Data.SqlClient;
namespace WebApp.Api.Models;
public class MemberRepository : BaseRepository
{
    public MemberRepository(IDbConnection connection) : base(connection)
    {
    }
    public int Add(Member obj)
    {
        if (string.IsNullOrEmpty(obj.MemberId))
        {
            obj.MemberId = Guid.NewGuid().ToString().Replace("-", string.Empty);
        }
        obj.Password = BCrypt.Net.BCrypt.HashPassword(obj.Password);
        return connection.Execute("AddMember", obj, commandType: CommandType.StoredProcedure);
    }
    public Member? GetMemberByEmail(string email)
    {
        string sql = "SELECT * FROM Member WHERE Email=@Email";
        return connection.QuerySingleOrDefault<Member>(sql, new{email});
    }
    public LoginResuilt Login(LoginModel obj, IConfiguration configuration)
    {
        Member? member = GetMemberByEmail(obj.Email);
        if(member !=null)
        {
            if(BCrypt.Net.BCrypt.Verify(obj.Password, member.Password))
            {
                return new LoginResuilt
                {
                    Success = true,
                    Message = "Login Success",
                    Token = Helper.GenerateToken(member, configuration)
                };
            }
            return new LoginResuilt
            {
                Success = false,
                Message = "Password invalid"
            };
        }
        return new LoginResuilt
        {
            Success = false,
            Message = "Email invalid"
        };
    }
    public int ChangePassword(string memberId, ChangePasswordModel obj)
    {
        string? hash = connection.QuerySingleOrDefault<string>(
            "SELECT Password FROM Member WHERE MemberId = @MemberId", new { memberId });
        if (hash == null) return 0;
        if (!BCrypt.Net.BCrypt.Verify(obj.OldPassword, hash)) return -1;
        string newHash = BCrypt.Net.BCrypt.HashPassword(obj.NewPassword);
        return connection.Execute(
            "UPDATE Member SET Password = @Password WHERE MemberId = @MemberId",
            new { memberId, Password = newHash });
    }
    public PagedResult<MemberSummary> GetMembers(string? keyword, int page, int pageSize)
    {
        string fromWhere = "Member";
        if (!string.IsNullOrWhiteSpace(keyword))
        {
            fromWhere += " WHERE Email LIKE @Pattern OR GivenName LIKE @Pattern OR Surname LIKE @Pattern";
        }
        return QueryPaged<MemberSummary>(
            "MemberId, GivenName, Surname, Email, Role",
            fromWhere, "Email", new { Pattern = "%" + keyword?.Trim() + "%" }, page, pageSize);
    }
    public int SetRole(string memberId, Role role)
    {
        return connection.Execute(
            "UPDATE Member SET Role = @Role WHERE MemberId = @MemberId", new { memberId, role });
    }
    public int DeleteMember(string memberId)
    {
        try
        {
            return connection.Execute("DELETE FROM Member WHERE MemberId = @MemberId", new { memberId });
        }
        catch (SqlException)
        {
            return -2;
        }
    }
}