codeunit 79002 "LGS Outlook API Client Mock" implements "Email - Outlook API Client"
{
    SingleInstance = true;

    var
        Message: JsonObject;
        EmailAddress: Text[250];
        AccountName: Text[250];

    internal procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        Email := EmailAddress;
        Name := AccountName;
        exit(true);
    end;

    internal procedure SendEmail(AccessToken: Text; MessageJson: JsonObject)
    begin
        Message := MessageJson;
    end;

    procedure GetMessage(): JsonObject
    begin
        exit(Message);
    end;

    procedure SetAccountInformation(Email: Text[250]; Name: Text[250])
    begin
        EmailAddress := Email;
        AccountName := Name;
    end;
}