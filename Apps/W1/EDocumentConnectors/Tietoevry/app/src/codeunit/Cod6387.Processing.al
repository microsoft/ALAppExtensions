// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocument;
using Microsoft.Sales.Document;
using Microsoft.Sales.Peppol;
using System.Telemetry;
using System.Text;
using System.Utilities;
using Microsoft.eServices.EDocument.Service.Participant;

codeunit 6387 "Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m;

    //Send outbound document
    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EdocumentService: Record "E-Document Service";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        IsAsync := true;

        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported,
            EDocumentServiceStatus.Status::"Sending Error":
                SendEDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
        end;

        FeatureTelemetry.LogUptake('0000MSC', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    //Get status of sent document
    procedure GetDocumentResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        if not CheckIfDocumentStatusSuccessful(EDocument, HttpRequest, HttpResponse) then
            exit(false);

        exit(true);
    end;

    procedure CancelEDocument(EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Tietoevry then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        if not (EDocumentServiceStatus.Status = EDocumentServiceStatus.Status::Created) then
            Error(CancelCheckStatusErr, EDocumentServiceStatus.Status);

        EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Canceled;
        EDocumentServiceStatus.Modify();
        exit(true);
    end;

    procedure RestartEDocument(EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Tietoevry then
            exit;

        // if TietoevryConnection.HandleSendActionRequest(EDocument, HttpRequest, HttpResponse, 'Restart', false) then
        exit(true);
    end;

    // Mark document as collected
    procedure AcknowledgeEDocument(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; MessageId: Text)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
    begin
        if MessageId = '' then
            exit;

        TietoevryConnection.HandleSendFetchDocumentRequest(MessageId, LocalHttpRequest, LocalHttpResponse, false);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);
    end;

    //Get a list of messages to collect
    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ContentData: Text;
        OutStream: OutStream;
    begin
        if not TietoevryConnection.GetReceivedDocuments(HttpRequest, HttpResponse, true) then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseInstream: InStream;
        ResponseTxt: Text;
    begin
        TempBlob.CreateInStream(ResponseInstream);
        ResponseInstream.ReadText(ResponseTxt);

        exit(GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    procedure ParseReceivedDocument(InputTxt: Text; Index: Integer; var MessageId: Text): Boolean
    var
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        JsonTokenValue: JsonToken;
    begin
        if not JsonArray.ReadFrom(InputTxt) then
            exit(false);

        if Index > JsonArray.Count() then
            exit(false);

        if not JsonArray.Get(Index, JsonToken) then
            exit(false);

        JsonObject := JsonToken.AsObject();
        if not JsonObject.Get('id', JsonTokenValue) then
            exit(false);

        MessageId := JsonTokenValue.AsValue().AsText();
        exit(true);
    end;

    local procedure GetNumberOfReceivedDocuments(InputTxt: Text): Integer
    var
        JsonToken: JsonToken;
    begin
        if not JsonToken.ReadFrom(InputTxt) then
            exit(0);

        exit(JsonToken.AsArray().Count());
    end;

    local procedure SendEDocument(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage);
    var
        HttpContentResponse: HttpContent;
    begin
        TietoevryConnection.HandleSendDocumentRequest(TempBlob, EDocument, HttpRequest, HttpResponse, true);
        HttpContentResponse := HttpResponse.Content;
        SetEMessageID(EDocument."Entry No", ParseSendDocumentResponse(HttpContentResponse));
    end;

    local procedure CheckIfDocumentStatusSuccessful(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        Telemetry: Codeunit Telemetry;
        Status, ErrorDescription : Text;
        ContentData: Text;
        JToken: JsonToken;
    begin
        if not TietoevryConnection.CheckDocumentStatus(EDocument, HttpRequestMessage, HttpResponse, true) then
            exit(false);

        if IsDocumentStatusProcessed(HttpResponse, Status) then begin
            EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
            EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
            EDocumentServiceStatus.Status := "E-Document Status"::Processed;
            EDocumentServiceStatus.Modify();
            EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponse);
            exit(true);
        end;

        case Status of
            TietoevryPendingStatusLbl:
                exit(false);
            TietoevryFailedStatusLbl:
                begin
                    HttpResponse.Content.ReadAs(ContentData);
                    if not JToken.ReadFrom(ContentData) then begin
                        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ParseErr);
                        exit(false);
                    end;
                    foreach JToken in JToken.AsObject().Values() do
                        case JToken.Path() of
                            'details':
                                ErrorDescription := JToken.AsValue().AsText();
                        end;
                    EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ErrorDescription);
                    exit(false);
                end;
            else begin
                Telemetry.LogMessage('0000MSB', StrSubstNo(WrongParseStatusErr, Status), Verbosity::Error, DataClassification::SystemMetadata);
                exit(false);
            end;
        end;
    end;

    local procedure IsDocumentStatusProcessed(HttpResponse: HttpResponseMessage; var Status: Text): Boolean
    var
        HttpContentResponse: HttpContent;
        Result: Text;
        JToken: JsonToken;
    begin
        HttpContentResponse := HttpResponse.Content;
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            Error(ParseErr);

        if not JToken.ReadFrom(Result) then
            Error(ParseErr);

        foreach JToken in JToken.AsObject().Values() do
            case JToken.Path() of
                'status':
                    Status := JToken.AsValue().AsText();
            end;

        if Status = TietoevryProcessedStatusLbl then
            exit(true);

        exit(false);
    end;

    local procedure ParseSendDocumentResponse(HttpContentResponse: HttpContent): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
        Value: Text;
    begin
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit('');

        if not JsonManagement.InitializeFromString(Result) then
            exit('');

        JsonManagement.GetStringPropertyValueByName('id', Value);
        exit(Value);
    end;

    local procedure SetEMessageID(EDocEntryNo: Integer; MessageId: Text)
    var
        EDocument: Record "E-Document";
    begin
        if MessageId = '' then
            exit;

        if not EDocument.Get(EDocEntryNo) then
            exit;

        EDocument."Message Id" := CopyStr(MessageId, 1, MaxStrLen(EDocument."Message Id"));
        EDocument.Modify();
    end;

    procedure ParseJsonString(HttpContentResponse: HttpContent): Text
    var
        ResponseJObject: JsonObject;
        ResponseJson: Text;
        Result: Text;
        IsJsonResponse: Boolean;
    begin
        HttpContentResponse.ReadAs(Result);
        IsJsonResponse := ResponseJObject.ReadFrom(Result);
        if IsJsonResponse then
            ResponseJObject.WriteTo(ResponseJson)
        else
            exit('');

        if not TryInitJson(ResponseJson) then
            exit('');

        exit(Result);
    end;

    [TryFunction]
    local procedure TryInitJson(JsonTxt: Text)
    var
        JsonManagement: Codeunit "JSON Management";
    begin
        JSONManagement.InitializeObject(JsonTxt);
    end;

    local procedure SplitId(Input: Text; var SchemeId: Text; var EndpointId: Text)
    var
        Parts: List of [Text];
    begin
        Parts := Input.Split(':');
        SchemeId := Parts.Get(1);
        EndpointId := Parts.Get(2);
    end;

    internal procedure IsValidSchemeId(PeppolId: Text[50]) Result: Boolean;
    var
        ValidSchemeId: Text;
        ValidSchemeIdList: List of [Text];
        SplitSeparator: Text;
        SchemeId: Text;
    begin
        SplitSeparator := ' ';
        ValidSchemeId := ValidSchemeIdTxt;
        ValidSchemeIdList := ValidSchemeId.Split(SplitSeparator);

        foreach SchemeId in ValidSchemeIdList do
            if PeppolId.StartsWith(SchemeId) then
                exit(true);
        exit(false);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyInfoByFormat"(var SupplierEndpointID: Text; var SupplierSchemeID: Text; var SupplierName: Text; IsBISBilling: Boolean)
    var
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;

        SplitId(EDocExtConnectionSetup."Company Id", SupplierSchemeID, SupplierEndpointID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingSupplierPartyLegalEntityByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingSupplierPartyLegalEntityByFormat"(var PartyLegalEntityRegName: Text; var PartyLegalEntityCompanyID: Text; var PartyLegalEntitySchemeID: Text; var SupplierRegAddrCityName: Text; var SupplierRegAddrCountryIdCode: Text; var SupplRegAddrCountryIdListId: Text; IsBISBilling: Boolean)
    var
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;

        SplitId(EDocExtConnectionSetup."Company Id", PartyLegalEntitySchemeID, PartyLegalEntityCompanyID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingCustomerPartyInfoByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingCustomerPartyInfoByFormat"(SalesHeader: Record "Sales Header"; var CustomerEndpointID: Text; var CustomerSchemeID: Text; var CustomerPartyIdentificationID: Text; var CustomerPartyIDSchemeID: Text; var CustomerName: Text; IsBISBilling: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;
        ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.");
        SplitId(ServiceParticipant."Participant Identifier", CustomerSchemeID, CustomerEndpointID);
        SplitId(ServiceParticipant."Participant Identifier", CustomerPartyIDSchemeID, CustomerPartyIdentificationID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Management", OnAfterGetAccountingCustomerPartyLegalEntityByFormat, '', false, false)]
    local procedure "PEPPOL Management_OnAfterGetAccountingCustomerPartyLegalEntityByFormat"(SalesHeader: Record "Sales Header"; var CustPartyLegalEntityRegName: Text; var CustPartyLegalEntityCompanyID: Text; var CustPartyLegalEntityIDSchemeID: Text; IsBISBilling: Boolean)
    var
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocExtConnectionSetup: Record "Connection Setup";
    begin
        if not IsBISBilling then
            exit;
        if not EDocExtConnectionSetup.Get() then
            exit;
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Tietoevry);
        if not EDocumentService.FindFirst() then
            exit;

        ServiceParticipant.Get(EDocumentService.Code, ServiceParticipant."Participant Type"::Customer, SalesHeader."Bill-to Customer No.");
        SplitId(ServiceParticipant."Participant Identifier", CustPartyLegalEntityIDSchemeID, CustPartyLegalEntityCompanyID);
    end;

    var
        TietoevryConnection: Codeunit Connection;
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        CancelCheckStatusErr: Label 'You cannot ask for cancel with the E-Document in this current status %1. You can request for cancel when E-document status is ''Created''.', Comment = '%1 - Status';
        ParseErr: Label 'Failed to parse document from Tietoevry API';
        WrongParseStatusErr: Label 'Got unexected status from Tietoevry API: %1', Comment = '%1 - Status that we received from API', Locked = true;
        TietoevryFailedStatusLbl: Label 'FAILED', Locked = true;
        TietoevryPendingStatusLbl: Label 'PENDING', Locked = true;
        TietoevryProcessedStatusLbl: Label 'PROCESSED', Locked = true;
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
#pragma warning disable AA0240
        ValidSchemeIdTxt: Label '0002 0007 0009 0037 0060 0088 0096 0097 0106 0130 0135 0142 0147 0151 0170 0183 0184 0188 0190 0191 0192 0193 0194 0195 0196 0198 0199 0200 0201 0202 0203 0204 0205 0208 0209 0210 0211 0212 0213 0215 0216 0217 0218 0219 0220 0221 0225 0230 9901 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9957 9959 AN AQ AS AU EM', Locked = true;
#pragma warning restore AA0240        
}