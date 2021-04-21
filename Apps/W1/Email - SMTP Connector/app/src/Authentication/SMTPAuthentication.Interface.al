/// <summary>
/// Functions to be implemented by every SMTP authentication type
/// </summary>
interface "SMTP Authentication"
{
    /// <summary>
    /// Validate SMTP account.
    /// </summary>
    /// <param name="SMTPAccount">SMTP account to validate.</param>
    procedure Validate(var SMTPAccount: Record "SMTP Account");

    /// <summary>
    /// Authenticate the SMTP client with the SMTP account.
    /// </summary>
    /// <param name="SmtpClient">SMTP client to authenticate.</param>
    /// <param name="SMTPAccount">The account to use for authenticating the SMTP client.</param>
    procedure Authenticate(SmtpClient: DotNet SmtpClient; SMTPAccount: Record "SMTP Account");
}