using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace WebApp.Services;
public class EmailService
{
    readonly IConfiguration configuration;
    public EmailService(IConfiguration configuration)
    {
        this.configuration = configuration;
    }
    public async Task SendAsync(string to, string subject, string body)
    {
        string? host = configuration["Smtp:Host"];
        if (string.IsNullOrWhiteSpace(host))
        {
            Console.WriteLine($"[EMAIL - chưa cấu hình SMTP] Đến: {to} | {subject} | {body}");
            return;
        }
        MimeMessage message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(configuration["Smtp:From"] ?? configuration["Smtp:User"]!));
        message.To.Add(MailboxAddress.Parse(to));
        message.Subject = subject;
        message.Body = new TextPart("plain") { Text = body };
        int port = int.Parse(configuration["Smtp:Port"] ?? "587");
        bool ssl = bool.Parse(configuration["Smtp:UseSsl"] ?? "false");
        using SmtpClient client = new SmtpClient();
        await client.ConnectAsync(host, port, ssl ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTlsWhenAvailable);
        string? user = configuration["Smtp:User"];
        if (!string.IsNullOrEmpty(user))
        {
            await client.AuthenticateAsync(user, configuration["Smtp:Password"]);
        }
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}