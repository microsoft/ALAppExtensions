namespace Microsoft.EServices;

codeunit 13659 "Http Response Msg Nemhandel" implements "Http Response Msg Nemhandel"
{
    var
        Response: HttpResponseMessage;

    procedure Initialize(HttpResponse: HttpResponseMessage)
    begin
        Response := HttpResponse;
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(Response.IsBlockedByEnvironment);
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit(Response.IsSuccessStatusCode);
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(Response.HttpStatusCode);
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(Response.ReasonPhrase);
    end;

    procedure GetResponseBody() ResponseBody: JsonObject;
    var
        ResponseBodyText: Text;
    begin
        Response.Content.ReadAs(ResponseBodyText);
        ResponseBody.ReadFrom(ResponseBodyText);
    end;

    procedure GetResponseBodyAsText() Body: Text;
    begin
        if Response.Content.ReadAs(Body) then;
    end;
}
