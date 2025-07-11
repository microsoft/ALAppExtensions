namespace Microsoft.Finance.VAT.Reporting;

codeunit 13619 "Elec. VAT Decl. Http Response" implements "Elec. VAT Decl. Response"
{
    Access = Internal;

    var
        Response: HttpResponseMessage;

    procedure Initialize(HttpResponse: HttpResponseMessage)
    begin
        Response := HttpResponse;
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(Response.IsBlockedByEnvironment());
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit(Response.IsSuccessStatusCode());
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(Response.HttpStatusCode());
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(Response.ReasonPhrase());
    end;

    procedure GetResponseStream() InStream: InStream;
    begin
        Response.Content.ReadAs(InStream);
    end;

    procedure GetResponseBodyAsText() Body: Text;
    begin
        if Response.Content.ReadAs(Body) then;
    end;
}
