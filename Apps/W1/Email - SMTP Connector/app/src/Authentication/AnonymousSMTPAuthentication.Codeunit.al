codeunit 4518 "Anonymous SMTP Authentication" implements "SMTP Authentication"
{
    Access = Internal;

    procedure Validate(var SMTPAccount: Record "SMTP Account");
    begin
        SMTPAccount."User Name" := '';
        SMTPAccount.SetPassword('');
    end;

    procedure Authenticate(SmtpClient: DotNet SmtpClient; SMTPAccount: Record "SMTP Account");
    begin
        // do nothing
    end;
}