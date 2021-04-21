codeunit 2428 "XS Communicate With Xero"
{
    procedure CommunicateWithXero(var Parameters: Record "XS REST Web Service Parameters"; var SyncChange: Record "Sync Change"; NAVEntityID: Integer; XeroID: Text; SyncChangeDirection: Option Incoming,Outgoing; ChangeType: Option Create,Update,Delete," "; ModifiedSince: DateTime; UseModifiedSince: Boolean; EntityDataJsonTxt: Text; var JsonEntities: JsonArray; ListOfAdditionalParametersForReports: List of [Text]) IsSuccessStatusCode: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeCommunicateWithXero(EntityDataJsonTxt, JsonEntities, Handled);

        IsSuccessStatusCode := DoCommunicateWithXero(Parameters, SyncChange, NAVEntityID, XeroID, SyncChangeDirection, ChangeType, ModifiedSince, UseModifiedSince, EntityDataJsonTxt, JsonEntities, Handled);

        OnAfterCommunicateWithXero(IsSuccessStatusCode, JsonEntities);
    end;

    procedure QueryXeroCurrencies(var Parameters: Record "XS REST Web Service Parameters"; var ResponseArrayOut: JsonArray) IsSuccessStatusCode: Boolean
    var
        SyncSetup: Record "Sync Setup";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        Handled: Boolean;
    begin
        OnBeforeQueryXeroCurrencies(Handled, ResponseArrayOut);

        if Handled then
            exit(true);

        SyncSetup.InitAPIParameters(Parameters);
        Parameters.URL := CopyStr(XeroSyncManagement.GetXeroUrlForCurrencies(), 1, 250);
        Parameters.RestMethod := Parameters.RestMethod::get;

        IsSuccessStatusCode := CallRESTWebService(Parameters);

        if Parameters.HasResponseContent() then
            ProcessResponseContent(Parameters, XeroSyncManagement.GetJsonTagForCurrencies(), ResponseArrayOut, IsSuccessStatusCode);
    end;

    procedure QueryXeroAccounts(var Parameters: Record "XS REST Web Service Parameters"; var ResponseArrayOut: JsonArray) IsSuccessStatusCode: Boolean
    var
        SyncSetup: Record "Sync Setup";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        Handled: Boolean;
    begin
        OnBeforeQueryXeroAccounts(Handled, ResponseArrayOut);

        if Handled then
            exit(true);

        SyncSetup.InitAPIParameters(Parameters);
        Parameters.URL := CopyStr(XeroSyncManagement.GetXeroUrlForAccounts(), 1, 250);
        Parameters.RestMethod := Parameters.RestMethod::get;

        IsSuccessStatusCode := CallRESTWebService(Parameters);

        if Parameters.HasResponseContent() then
            ProcessResponseContent(Parameters, XeroSyncManagement.GetJsonTagForAccounts(), ResponseArrayOut, IsSuccessStatusCode);
    end;

    procedure ParseJsonForValidationErrors(Response: JsonArray) ValidationError: Text
    var
        Token: JsonToken;
    begin
        foreach Token in Response do
            ValidationError += ParseJsonForValidationErrorsFromInnerToken(Token);
    end;

    local procedure ParseJsonForValidationErrorsFromInnerToken(Token: JsonToken) ValidationError: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        Object: JsonObject;
    begin
        if not Token.IsObject() then
            exit;

        Object := Token.AsObject();
        JsonObjectHelper.SetJsonObject(Object);
        Token := JsonObjectHelper.GetJsonToken('Elements');

        if not Token.IsArray() then
            exit;

        Token.AsArray().Get(0, Token);

        if not Token.IsObject() then
            exit;

        Object := Token.AsObject();
        JsonObjectHelper.SetJsonObject(Object);
        Token := JsonObjectHelper.GetJsonToken('ValidationErrors');

        if not Token.IsArray() then
            exit;

        Token.AsArray().Get(0, Token);

        if not Token.IsObject() then
            exit;

        Token.AsObject().Get('Message', Token);
        ValidationError := Format(Token);
    end;

    local procedure DoCommunicateWithXero(var Parameters: Record "XS REST Web Service Parameters"; var SyncChange: Record "Sync Change"; NAVEntityID: Integer; XeroID: Text; SyncChangeDirection: Option Incoming,Outgoing,Bidirectional; ChangeType: Option Create,Update,Delete," "; ModifiedSince: DateTime; UseModifiedSince: Boolean; EntityDataJsonTxt: Text; var JsonEntities: JsonArray; var Handled: Boolean) IsSuccessStatusCode: Boolean
    var
        SyncSetup: Record "Sync Setup";
        EntityToSync: Text;
    begin
        if Handled then
            exit;

        SyncSetup.InitAPIParameters(Parameters);

        SetURL(Parameters, NAVEntityID, XeroID);

        EntityToSync := GetEntityToSync(NAVEntityID);

        SetRESTMethod(Parameters, SyncChangeDirection, ChangeType, NAVEntityID);

        if (SyncChangeDirection = SyncChangeDirection::Incoming) and UseModifiedSince then
            SetIfModifiedSince(Parameters, ModifiedSince);
        if SyncChangeDirection <> SyncChangeDirection::Incoming then
            SetRequestContent(Parameters, EntityDataJsonTxt);

        IsSuccessStatusCode := CallRESTWebService(Parameters);

        IsSuccessStatusCode := ProcessStatusCode(Parameters, SyncChange, IsSuccessStatusCode, NAVEntityID, SyncChangeDirection);

        if Parameters.HasResponseContent() then
            ProcessResponseContent(Parameters, EntityToSync, JsonEntities, IsSuccessStatusCode);
    end;

    local procedure SetURL(var Parameters: Record "XS REST Web Service Parameters"; NAVEntityID: Integer; XeroID: Text)
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case NAVEntityID of
            Database::Item:
                Parameters.URL := XeroSyncManagement.GetXeroUrlForItem() + XeroId;
            Database::Customer:
                Parameters.URL := XeroSyncManagement.GetXeroUrlForCustomer() + XeroId;
            Database::"Sales Invoice Header":
                Parameters.URL := XeroSyncManagement.GetXeroUrlForInvoices() + XeroID;
        end;
    end;

    local procedure GetEntityToSync(NAVEntityID: Integer) EntityToSync: Text
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case NAVEntityID of
            Database::Item:
                EntityToSync := XeroSyncManagement.GetJsonTagForItems();
            Database::Customer:
                EntityToSync := XeroSyncManagement.GetJsonTagForCustomers();
            Database::"Sales Invoice Header":
                EntityToSync := XeroSyncManagement.GetJsonTagForInvoices();
        end;
    end;

    local procedure SetRESTMethod(var Parameters: Record "XS REST Web Service Parameters"; SyncChangeDirection: Option Incoming,Outgoing,Bidirectional; ChangeType: Option Create,Update,Delete," "; NAVEntityID: Integer)
    begin
        case SyncChangeDirection of
            SyncChangeDirection::Incoming:
                Parameters.RestMethod := Parameters.RestMethod::get;
            SyncChangeDirection::Outgoing,
            SyncChangeDirection::Bidirectional:
                case ChangeType of
                    ChangeType::Delete:
                        case NAVEntityID of
                            Database::Item:
                                Parameters.RestMethod := Parameters.RestMethod::delete;
                            Database::Customer:
                                Parameters.RestMethod := Parameters.RestMethod::post;
                        end;
                    ChangeType::Create:
                        Parameters.RestMethod := Parameters.RestMethod::put;
                    else
                        Parameters.RestMethod := Parameters.RestMethod::post;
                end;
        end;
    end;

    local procedure SetIfModifiedSince(var Parameters: Record "XS REST Web Service Parameters"; ModifiedSince: DateTime)
    begin
        Parameters.IfModifiedSince := ModifiedSince;
    end;

    local procedure SetRequestContent(var Parameters: Record "XS REST Web Service Parameters"; EntityDataJsonTxt: Text)
    var
        HttpRequestContent: HttpContent;
    begin
        HttpRequestContent.WriteFrom(EntityDataJsonTxt);
        Parameters.SetRequestContent(HttpRequestContent);
    end;

    local procedure CallRESTWebService(var Parameters: Record "XS REST Web Service Parameters") ReturnValue: Boolean
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
    begin
        Parameters.InitializeRequestMessage(RequestMessage);

        Client.Send(RequestMessage, ResponseMessage);

        Headers := ResponseMessage.Headers();
        Parameters.SetResponseHeaders(Headers);

        Content := ResponseMessage.Content();
        Parameters.SetResponseContent(Content);

        Parameters.HttpStatusCode := ResponseMessage.HttpStatusCode();
        Parameters.SetResponseReasonPhrase(ResponseMessage.ReasonPhrase());

        ReturnValue := ResponseMessage.IsSuccessStatusCode();
    end;

    local procedure ProcessStatusCode(var Parameters: Record "XS REST Web Service Parameters"; var SyncChange: Record "Sync Change"; IsSuccessStatusCode: Boolean; NAVEntityID: Integer; SyncChangeDirection: Option Incoming,Outgoing): Boolean
    var
        SynchronizeItemsFailedErr: Label 'Could not synchronize Items with Xero.\Return Error: %1\%2 - Direction: %3';
        SynchronizeCustomersFailedErr: Label 'Could not synchronize Customers with Xero.\Return Error: %1\%2 - Direction: %3';
        SynchronizeInvoicesFailedErr: Label 'Could not synchronize Invoices with Xero.\Return Error: %1\%2 - Direction: %3';
    begin
        //if nothing was modified since late date, the code 304 will be returned
        if (Parameters.HttpStatusCode = 304) then
            exit(true);

        //if server has sucessfully fulfiled the request and there is no additional payload in response body
        if (Parameters.HttpStatusCode = 204) then
            exit(true);

        if not IsSuccessStatusCode then
            case NAVEntityID of
                Database::Item:
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(SynchronizeItemsFailedErr, Parameters.HttpStatusCode, Parameters.ResponseReasonPhrase(), SyncChangeDirection));
                Database::Customer:
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(SynchronizeCustomersFailedErr, Parameters.HttpStatusCode, Parameters.ResponseReasonPhrase(), SyncChangeDirection));
                Database::"Sales Invoice Header":
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(SynchronizeInvoicesFailedErr, Parameters.HttpStatusCode, Parameters.ResponseReasonPhrase(), SyncChangeDirection));
            end;

        exit(IsSuccessStatusCode);
    end;

    local procedure ProcessResponseContent(var Parameters: Record "XS REST Web Service Parameters"; EntityToSync: Text; var JsonEntities: JsonArray; IsSucceffulRequestCode: Boolean)
    var
        HttpResponseText: Text;
        JsonResponse: JsonObject;
        JsonEntityToken: JsonToken;
        Content: HttpContent;
    begin
        Parameters.ResponseContent(Content);
        Content.ReadAs(HttpResponseText);
        if JsonResponse.ReadFrom(HttpResponseText) then
            if not IsSucceffulRequestCode then
                JsonEntities.Add(JsonResponse)
            else
                if JsonResponse.Get(EntityToSync, JsonEntityToken) then
                    if JsonEntityToken.IsArray() then
                        JsonEntities := JsonEntityToken.AsArray();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommunicateWithXero(var EntityDataJsonTxt: Text; var JsonEntities: JsonArray; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCommunicateWithXero(var IsSuccessStatusCode: Boolean; var JsonEntities: JsonArray);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeQueryXeroCurrencies(var Handled: Boolean; var ResponseArrayOut: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeQueryXeroAccounts(var Handled: Boolean; var ResponseArrayOut: JsonArray)
    begin
    end;
}