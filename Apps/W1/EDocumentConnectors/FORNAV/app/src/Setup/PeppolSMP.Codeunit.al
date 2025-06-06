namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument.Integration.Send;

codeunit 6425 "ForNAV Peppol SMP"
{
    Access = internal;
    procedure CallSMP(Req: Text; var Input: JsonObject; action: Text; var Error: integer; var Message: Text) Output: JsonObject;
    var
        Setup: Record "ForNAV Peppol Setup";
        SendContext: Codeunit SendContext;
        PeppolSetup: Codeunit "ForNAV Peppol Setup";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        httpRequestMessage: HttpRequestMessage;
        httpContent: HttpContent;
        StatusCode: Integer;
        InStr: InStream;
        Response: JsonObject;
        jToken: JsonToken;
        Url: Text;
        HttpHeaders: HttpHeaders;
        ServiceErrorLbl: Label 'SMP %1 service error : %2 %3', Locked = true;
    begin
        Setup.InitSetup();

        Url := PeppolSetup.GetBaseUrl('SMP');
        case Req of
            'Post':
                httpContent.WriteFrom(Format(Input));
            'Put':
                httpContent.WriteFrom(Format(Input));
        end;

        httpRequestMessage.SetRequestUri(Url);
        httpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('action', action);

        httpRequestMessage.Content := HttpContent;
        httpRequestMessage.Method(Req.ToUpper());
        SendContext.Http().SetHttpRequestMessage(httpRequestMessage);
        if PeppolSetup.Send(HttpClient, SendContext.Http()) = 401 then begin
            Error := 401;
            exit;
        end;
        HttpResponse := SendContext.Http().GetHttpResponseMessage();
        StatusCode := HttpResponse.HttpStatusCode;
        if (Error = -1) and (StatusCode = 0) then begin
            Error := StatusCode;
            exit;
        end;
        Message := HttpResponse.ReasonPhrase;

        SendContext.GetTempBlob().CreateInStream(InStr);
        SendContext.Http().GetHttpResponseMessage().Content.ReadAs(InStr);

        if Response.ReadFrom(InStr) then begin
            if (StatusCode = 200) and Response.Get('statuscode', jToken) then
                StatusCode := jToken.AsValue().AsInteger();
            if Response.Get('message', jToken) and jToken.IsValue and not jToken.AsValue().IsNull then
                Message := jToken.AsValue().AsText();
            if (StatusCode >= 300) and (Error <> -1) and (StatusCode <> Error) then begin
                if Response.Get('payload', jToken) then
                    Message += ': ' + jToken.AsValue().AsText();
                error(ServiceErrorLbl, action, StatusCode, Message);
            end else
                Error := StatusCode;
            if Response.Get('payload', jToken) then
                if jToken.IsObject then
                    Output := jToken.AsObject()
                else
                    if jToken.IsValue and not jToken.AsValue().IsNull then
                        Output.ReadFrom(jToken.AsValue().AsText());
        end else
            error(ServiceErrorLbl, action, StatusCode, Message);
    end;

    procedure CallSMP(req: Text; action: Text; var error: Integer; var message: Text) output: JsonObject;
    var
        dummy: JsonObject;
    begin
        exit(CallSMP(req, dummy, action, error, message));
    end;

    internal procedure ParticipantExists(var Setup: record "ForNAV Peppol Setup")
    var
        output: JsonObject;
        message: Text;
        result: Integer;
        LicenseLbl: Label 'You need a valid ForNAV license to use this App "%1"', Comment = '%1 = meessage', Locked = true;
        ConnectionLbl: Label 'You are not authorized to use the ForNAV Peppol network. Please authorize./Error: %1', Comment = '%1 = error', Locked = true;
        LicensePeppolAccessLbl: Label 'You need update your ForNAV license to be able to use this app, please contavt your partner', Locked = true;
        SetupInAnotherBCInstanceLbl: Label 'This peppolid is alrady published in another company or Business Central installation - you need upublish it to use it with this company', Locked = true;
    begin
        result := -1; // Any
        output := CallSMP('Get', 'participant', result, message);
        case result of
            0:
                Setup.Status := Setup.Status::"Offline";
            401:
                begin
                    Setup.Authorized := false;
                    Message(ConnectionLbl, GetLastErrorText());
                end;
            402:
                begin
                    Setup.Status := Setup.Status::"Unlicensed";
                    Message(LicenseLbl, message);
                end;
            403:
                begin
                    Setup.Status := Setup.Status::"Unlicensed";
                    Message(LicensePeppolAccessLbl);
                end;
            404:
                Setup.Status := Setup.Status::"Not published";
            200:
                Setup.Status := Setup.Status::Published;
            409:
                begin
                    Message(SetupInAnotherBCInstanceLbl);
                    Setup.Status := Setup.Status::"Published in another company or installation";
                end;
            423:
                Setup.Status := Setup.Status::"Published by ForNAV using another AAD tenant";
            451:
                Setup.Status := Setup.Status::"Published by another AP";
            428:
                Setup.Status := Setup.Status::"Waiting for approval";
            else
                Error('Unknown error %1', result);
        end;
        Setup.SetValues(output);
        Setup.Modify();
    end;

    internal procedure CreateParticipant(var Setup: record "ForNAV Peppol Setup")
    var
        PeppolSetup: Codeunit "ForNAV Peppol Setup";
        input, output : JsonObject;
        error: Integer;
        message: Text;
    begin
        // Used by Azure function - do not modify
        input.Add('Identifier', Setup.ID());
        input.Add('IncomingDocsUrl', GetUrl(ClientType::Api, Setup.CurrentCompany(), ObjectType::Page, Page::"ForNAV Incoming E-Docs Api"));
        input.Add('BusinessEntity', Setup.CreateBusinessEntity());
        input.Add('License', PeppolSetup.GetJLicense());
        error := 409;
        output := CallSMP('Post', input, 'participant', error, message);
        if error = 409 then
            error('Conflict');
        Setup.Status := Setup.Status::Published;
        Setup.Modify();
    end;

    internal procedure DeleteParticipant(var Setup: record "ForNAV Peppol Setup")
    var
        Error: Integer;
        message: Text;
    begin
        Error := 204;
        CallSMP('Delete', 'participant', Error, message);
        Setup.Status := Setup.Status::"Not published";
        Setup.Modify();
    end;
}
