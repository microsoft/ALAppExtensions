codeunit 31452 "Persist. Confirm Response CZL"
{
    SingleInstance = true;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        Response: Boolean;

    procedure GetResponse(Question: Text; Default: Boolean): Boolean
    begin
        Response := ConfirmManagement.GetResponse(Question, Default);
        exit(Response);
    end;

    procedure GetResponseOrDefault(Question: Text; Default: Boolean): Boolean
    begin
        Response := ConfirmManagement.GetResponseOrDefault(Question, Default);
        exit(Response);
    end;

    procedure GetPersistentResponse(): Boolean
    begin
        exit(Response);
    end;

    procedure Init()
    begin
        clear(Response);
    end;
}