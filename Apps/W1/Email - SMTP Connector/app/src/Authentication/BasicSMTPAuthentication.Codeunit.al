codeunit 4517 "Basic SMTP Authentication" implements "SMTP Authentication"
{
    Access = Internal;

    procedure Validate(var SMTPAccount: Record "SMTP Account");
    begin
        // do nothing
    end;

    [NonDebuggable]
    procedure Authenticate(SmtpClient: DotNet SmtpClient; SMTPAccount: Record "SMTP Account");
    var
        CancellationToken: DotNet CancellationToken;
        Password: Text;
    begin
        Password := SMTPAccount.GetPassword(SMTPAccount."Password Key");
        SmtpClient.Authenticate(SMTPAccount."User Name", Password, CancellationToken);
    end;
}