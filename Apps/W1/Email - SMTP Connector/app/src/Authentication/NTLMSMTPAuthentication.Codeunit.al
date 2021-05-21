codeunit 4519 "NTLM SMTP Authentication" implements "SMTP Authentication"
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
        SaslMechanismNtlm: DotNet SaslMechanismNtlm;
        Password: Text;
    begin
        Password := SMTPAccount.GetPassword(SMTPAccount."Password Key");
        SaslMechanismNtlm := SaslMechanismNtlm.SaslMechanismNtlm(SMTPAccount."User Name", Password);
        SmtpClient.Authenticate(SaslMechanismNtlm, CancellationToken);
    end;
}