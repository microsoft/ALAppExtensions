codeunit 4517 "Dummy SMTP Authentication" implements "SMTP Authentication"
{
    ObsoleteReason = 'Dummy codeunit';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
    Access = Internal;

    procedure Validate(var SMTPAccount: Record "SMTP Account");
    begin
        // Do nothing
    end;

    procedure Authenticate(SmtpClient: DotNet SmtpClient; SMTPAccount: Record "SMTP Account");
    begin
        // Do nothing
    end;
}