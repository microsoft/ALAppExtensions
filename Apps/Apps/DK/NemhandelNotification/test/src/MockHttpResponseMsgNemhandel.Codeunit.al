codeunit 148013 "Mock HttpResponseMsg Nemhandel" implements "Http Response Msg Nemhandel"
{
    var
        BlockedByEnvGlobal: Boolean;
        StatusCodeGlobal: Integer;
        ReasonPhraseGlobal: Text;
        ResponseBodyGlobal: JsonObject;

    procedure SetBlockedByEnvironment(BlockedByEnv: Boolean)
    begin
        BlockedByEnvGlobal := BlockedByEnv;
    end;

    procedure SetError(StatusCode: Integer; ReasonPhraseValue: Text)
    begin
        StatusCodeGlobal := StatusCode;
        ReasonPhraseGlobal := ReasonPhraseValue;
    end;

    procedure SetSuccess(StatusCode: Integer; ResponseBodyText: Text)
    var
        ResponseBody: JsonObject;
    begin
        ResponseBody.ReadFrom(ResponseBodyText);
        StatusCodeGlobal := StatusCode;
        ResponseBodyGlobal := ResponseBody;
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(BlockedByEnvGlobal);
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit((StatusCodeGlobal >= 200) and (StatusCodeGlobal <= 299));
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(StatusCodeGlobal);
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(ReasonPhraseGlobal);
    end;

    procedure GetResponseBody(): JsonObject;
    begin
        exit(ResponseBodyGlobal);
    end;

    procedure GetResponseBodyAsText() Body: Text;
    begin
        ResponseBodyGlobal.WriteTo(Body);
    end;
}
