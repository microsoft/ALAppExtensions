// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using Microsoft.EServices.EDocument;
using Microsoft.EServices.EDocumentConnector.Avalara.Models;
using System.Utilities;


codeunit 6379 Processing
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m,
                  tabledata "Connection Setup" = rm;

    /// <summary>
    /// Call Avalara Shared API for list of companies
    /// </summary>
    /// <param name="AvalaraCompany">Records to contain returned compaines.</param>
    procedure GetCompanyList(var AvalaraCompany: Record Company temporary)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
    begin
        Request.Init();
        Request.Authenticate().CreateGetCompaniesRequest();
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);

        ParseCompanyList(AvalaraCompany, ResponseContent);
    end;

    /// <summary>
    /// Let user pick Avalara company for connection setup.
    /// </summary>
    procedure UpdateCompanyId(ConnectionSetup: Record "Connection Setup")
    var
        AvalaraCompanyList: Page "Company List";
    begin
        if TempAvalaraCompanies.IsEmpty() then
            GetCompanyList(TempAvalaraCompanies);

        Commit();
        AvalaraCompanyList.SetRecords(TempAvalaraCompanies);
        AvalaraCompanyList.LookupMode(true);
        if AvalaraCompanyList.RunModal() = Action::LookupOK then begin
            AvalaraCompanyList.GetRecord(TempAvalaraCompanies);
            ConnectionSetup.Get();
            ConnectionSetup."Company Id" := TempAvalaraCompanies."Company Id";
            ConnectionSetup."Company Name" := TempAvalaraCompanies."Company Name";
            ConnectionSetup.Modify();
        end
    end;

    /// <summary>
    /// Let user select Avalara Mandate for e-document service
    /// </summary>
    procedure UpdateMandate()
    var
        EDocService: Record "E-Document Service";
        EDocumentServices: Page "E-Document Services";
        MandateList: Page "Mandate List";
    begin
        Commit();
        EDocService.SetRange("Service Integration", Enum::"E-Document Integration"::Avalara);
        EDocumentServices.SetTableView(EDocService);
        EDocumentServices.LookupMode := true;
        EDocumentServices.Caption(AvalaraPickMandateMsg);
        if EDocumentServices.RunModal() <> Action::LookupOK then
            exit;

        EDocumentServices.GetRecord(EDocService);

        if TempMandates.IsEmpty() then
            GetMandates(TempMandates);

        MandateList.SetTempRecords(TempMandates);
        MandateList.LookupMode(true);
        if MandateList.RunModal() <> Action::LookupOK then
            exit;

        MandateList.GetRecord(TempMandates);
        EDocService."Avalara Mandate" := TempMandates."Country Mandate";
        EDocService.Modify();
    end;

    /// <summary>
    /// Calls Avalara API for SubmitDocument.
    /// </summary>
    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentService: Record "E-Document Service";
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        MetaData: Codeunit Metadata;
        InStream: InStream;
        RequestContent: Text;
        ResponseContent: Text;
    begin
        IsAsync := true;

        Metadata.SetWorkflowId('partner-einvoicing').SetDataFormat('ubl-invoice').SetDataFormatVersion('2.1');
        case EDocument."Document Type" of
            Enum::"E-Document Type"::"Sales Credit Memo",
            Enum::"E-Document Type"::"Service Credit Memo":
                MetaData.SetDataFormat('ubl-creditnote');
        end;

        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        SetMandateForMetaData(EDocumentService, MetaData);

        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(RequestContent);

        Request.Init();
        Request.Authenticate().CreateSubmitDocumentRequest(MetaData, RequestContent);
        HttpRequest := Request.GetRequest();
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, HttpResponse);

        EDocument.Get(EDocument."Entry No");
        EDocument."Document Id" := ParseDocumentId(ResponseContent);
        EDocument.Modify(true);
    end;

    /// <summary>
    /// Calls Avalara API for GetDocumentStatus.
    /// If request is successfull, but status is Error, then errors are logged and error is thrown to set document to Sending Error state
    /// </summary>
    /// <returns>False if status is Pending, True if status is Complete.</returns>
    procedure GetDocumentStatus(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
    begin
        EDocument.TestField("Document Id");

        Request.Init();
        Request.Authenticate().CreateGetDocumentStatusRequest(EDocument."Document Id");
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, HttpResponse);
        exit(ParseGetDocumentStatusResponse(EDocument, ResponseContent));
    end;

    /// <summary>
    /// Lookup documents for last XX days. 
    /// </summary>
    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        OutStream: OutStream;
        ArrayOfDocuments: Text;
        Response: JsonArray;
        EndDate: Date;
    begin
        EndDate := CalcDate('<-1M>', Today());
        Response := ReceiveDocumentInner(TempBlob, HttpRequest, HttpResponse, StrSubstNo(AvalaraGetDocsPathTxt, FormatDateTime(EndDate), FormatDateTime(Today())));
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Response.WriteTo(ArrayOfDocuments);
        OutStream.Write(ArrayOfDocuments);
        HttpResponse.Content.WriteFrom(ArrayOfDocuments);
    end;

    /// <summary>
    /// Recursive function to keep following next link from API.
    /// Ensures we get all documents within Start and End time that we requested.
    /// </summary>
    /// <returns>List of Json Objects with data about document that belong to selected avalara company.</returns>
    procedure ReceiveDocumentInner(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Path: Text): JsonArray
    var
        ConnectionSetup: Record "Connection Setup";
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
        ResponseJson, DocObject : JsonObject;
        NextLink: Text;
        ValueJson, ValueObject, CompanyId : JsonToken;
        Values: JsonArray;
    begin
        if Path = '' then
            exit; // Stop recursion

        Request.Init();
        Request.Authenticate().CreateReceiveDocumentsRequest(Path);
        HttpRequest := Request.GetRequest();
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, HttpResponse);

        ResponseJson.ReadFrom(ResponseContent);

        ResponseJson.Get('@nextLink', ValueJson);
        if not ValueJson.AsValue().IsNull() then
            NextLink := ValueJson.AsValue().AsText();
        if NextLink <> '' then begin
            Path := NextLink.Substring(StrLen(Request.GetBaseUrl()) + 1);
            Values := ReceiveDocumentInner(TempBlob, HttpRequest, HttpResponse, Path);
        end;

        // No more pagination.
        // Accumulate results
        ConnectionSetup.Get();
        ResponseJson.Get('value', ValueJson);
        if ValueJson.IsArray then
            foreach ValueObject in ValueJson.AsArray() do begin
                DocObject := ValueObject.AsObject();
                DocObject.Get('companyId', CompanyId);
                if ConnectionSetup."Company Id" = CompanyId.AsValue().AsText() then
                    Values.Add(DocObject);
            end;

        exit(Values);
    end;

    /// <summary>
    /// Get number of documents in batch
    /// </summary>
    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        Instream: InStream;
        ResponseContent: Text;
        ResponseJson: JsonArray;
    begin
        TempBlob.CreateInStream(Instream, TextEncoding::UTF8);
        Instream.ReadText(ResponseContent);
        ResponseJson.ReadFrom(ResponseContent);
        exit(ResponseJson.Count());
    end;

    /// <summary>
    /// Filter out received documents that are already downloaded.
    /// Needed as Avalara API does not support marking documents as fetched.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnBeforeInsertImportedEdocument', '', false, false)]
    local procedure OnBeforeInsertEdocumentCheck(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsCreated: Boolean; var IsProcessed: Boolean)
    var
        EDocument2: Record "E-Document";
        ContentData, DocumentId : Text;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Avalara then
            exit;

        HttpResponse.Content.ReadAs(ContentData);
        if not ParseReceivedDocument(ContentData, EDocument."Index In Batch", DocumentId) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;
        if DocumentId = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);

        // Decide if document exists
        EDocument2.SetRange("Document Id", DocumentId);
        IsCreated := not EDocument2.IsEmpty();
        IsProcessed := IsCreated;
    end;

    /// <summary>
    /// Get Document Id and store it E-Document.
    /// Create Request to Download XML based on Document Id, and store it in TempBlob. 
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", OnAfterInsertImportedEdocument, '', false, false)]
    local procedure OnAfterInsertEdocumentReadDocumentIdAndDownloadContent(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
        HttpResponseLocal: HttpResponseMessage;
        ContentData, DocumentId : Text;
        OutStream: OutStream;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Avalara then
            exit;

        HttpResponse.Content.ReadAs(ContentData);
        if not ParseReceivedDocument(ContentData, EDocument."Index In Batch", DocumentId) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;
        if DocumentId = '' then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;

        EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
        EDocument.Modify();

        Request.Init();
        Request.Authenticate().CreateDownloadRequest(DocumentId);
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, HttpResponseLocal);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, Request.GetRequest(), HttpResponseLocal);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseContent);
        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Imported);
    end;

    /// <summary>
    /// Takes "Avalara Mandate" and computes country code and mandate
    /// </summary>
    local procedure SetMandateForMetaData(EDocumentService: Record "E-Document Service"; var Metadata: Codeunit Metadata)
    var
        Mandate, County : Text;
    begin
        EDocumentService.TestField("Avalara Mandate");
        Mandate := EDocumentService."Avalara Mandate";
        County := Mandate.Split('-').Get(1);
        Metadata.SetCountry(County).SetMandate(Mandate);
    end;

    /// <summary>
    /// Create and send http call for mandates and parse response to mandate table
    /// </summary>
    local procedure GetMandates(var TempMandatesLocal: Record Mandate temporary)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
    begin
        Request.Init();
        Request.Authenticate().CreateGetMandates();
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);

        ParseMandates(TempMandatesLocal, ResponseContent);
    end;

    /// <summary>
    /// Parse mandates from json into table
    /// </summary>
    local procedure ParseMandates(var TempMandatesLocal: Record Mandate temporary; ResponseContent: Text)
    var
        ResponseJson: JsonObject;
        ValueJson, MandateJson, ParsintToken : JsonToken;
        Id: Integer;
        CountryMandate, CountryCode, Description : Text;
    begin
        ResponseJson.ReadFrom(ResponseContent);
        ResponseJson.Get('value', ValueJson);

        Clear(TempMandatesLocal);
        Id := 1;
        foreach MandateJson in ValueJson.AsArray() do begin

            MandateJson.AsObject().Get('countryMandate', ParsintToken);
            CountryMandate := ParsintToken.AsValue().AsText();
            MandateJson.AsObject().Get('countryCode', ParsintToken);
            CountryCode := ParsintToken.AsValue().AsText();
            MandateJson.AsObject().Get('description', ParsintToken);
            Description := ParsintToken.AsValue().AsText();

            if StrLen(CountryMandate) > MaxStrLen(TempMandatesLocal."Country Mandate") then
                Error(AvalaraCountryMandateLongerErr);

            if StrLen(CountryCode) > MaxStrLen(TempMandatesLocal."Country Code") then
                Error(AvalaraCountryMandateCodeErr);

            if StrLen(Description) > MaxStrLen(TempMandatesLocal.Description) then
                Error(AvalaraCountryMandateDescLongerErr);

            TempMandatesLocal.Init();
            TempMandatesLocal."Country Mandate" := CopyStr(CountryMandate, 1, MaxStrLen(TempMandatesLocal."Country Mandate"));
            TempMandatesLocal."Country Code" := CopyStr(CountryCode, 1, MaxStrLen(TempMandatesLocal."Country Code"));
            TempMandatesLocal.Description := CopyStr(Description, 1, MaxStrLen(TempMandatesLocal.Description));
            TempMandatesLocal.Insert(true);
            Id += 1;
        end;
    end;

    /// <summary>
    /// Parse companies from json into table
    /// </summary>
    local procedure ParseCompanyList(var AvalaraCompany: Record Company temporary; ResponseContent: Text)
    var
        ResponseJson: JsonObject;
        ValueJson, CompanyJson, ParsintToken : JsonToken;
        Id: Integer;
        CompanyId, CompanyName : Text;
    begin
        ResponseJson.ReadFrom(ResponseContent);
        ResponseJson.Get('value', ValueJson);

        Id := 1;
        foreach CompanyJson in ValueJson.AsArray() do begin
            Clear(AvalaraCompany);
            AvalaraCompany.Init();
            AvalaraCompany.Id := Id;
            CompanyJson.AsObject().Get('id', ParsintToken);
            CompanyId := ParsintToken.AsValue().AsText();
            CompanyJson.AsObject().Get('companyName', ParsintToken);
            CompanyName := ParsintToken.AsValue().AsText();

            if StrLen(CompanyId) > MaxStrLen(AvalaraCompany."Company Id") then
                Error(AvalaraCountryIdLongerErr);

            if StrLen(CompanyName) > MaxStrLen(AvalaraCompany."Company Name") then
                Error(AvaralaCountryNameLongerErr);

            AvalaraCompany."Company Id" := CopyStr(CompanyId, 1, MaxStrLen(AvalaraCompany."Company Id"));
            AvalaraCompany."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(AvalaraCompany."Company Name"));
            AvalaraCompany.Insert(true);
            Id += 1;
        end;
    end;

    /// <summary>
    /// Parse company id
    /// </summary>
    local procedure ParseDocumentId(ResponseMsg: Text): Text[50]
    var
        DocumentId: Text;
        ResponseJson: JsonObject;
        ValueJson: JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseMsg);
        ResponseJson.Get('id', ValueJson);

        DocumentId := ValueJson.AsValue().AsText();
        if StrLen(DocumentId) > 50 then
            Error(AvalaraIdLongerErr);

        exit(CopyStr(DocumentId, 1, 50));
    end;

    /// <summary>
    /// Parse Document Response. If erros log all events
    /// </summary>
    local procedure ParseGetDocumentStatusResponse(var EDocument: Record "E-Document"; ResponseMsg: Text): Boolean
    var
        ResponseJson, EventObject : JsonObject;
        ValueJson, EventToken, MessageToken : JsonToken;
        Events: JsonArray;
    begin
        ResponseJson.ReadFrom(ResponseMsg);
        ResponseJson.Get('id', ValueJson);
        if EDocument."Document Id" <> ValueJson.AsValue().AsText() then
            Error(IncorrectDocumentIdInResponseErr);

        if ResponseJson.Get('events', ValueJson) then
            Events := ValueJson.AsArray();

        ResponseJson.Get('status', ValueJson);
        case ValueJson.AsValue().AsText() of
            'Complete':
                exit(true);
            'Pending':
                exit(false);
            'Error':
                begin
                    if ResponseJson.Get('events', ValueJson) then
                        Events := ValueJson.AsArray();
                    foreach EventToken in Events do begin
                        EventObject := EventToken.AsObject();
                        EventObject.Get('message', MessageToken);
                        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, MessageToken.AsValue().AsText());
                    end;
                    EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, AvalaraProcessingDocFailedErr);
                    exit(false);
                end;
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Parse the document id from json
    /// </summary>
    local procedure ParseReceivedDocument(InputTxt: Text; Index: Integer; var DocumentId: Text): Boolean
    var
        ValueArray: JsonArray;
        DocumentJsonToken, IdToken : JsonToken;
    begin
        ValueArray.ReadFrom(InputTxt);
        if Index > ValueArray.Count then
            exit(false);

        if Index = 0 then
            Index := 1;

        ValueArray.Get(Index - 1, DocumentJsonToken);
        DocumentJsonToken.AsObject().Get('id', IdToken);
        DocumentId := IdToken.AsValue().AsText();

        exit(true);
    end;

    /// <summary>
    /// Format specific date with the current time, for Avalara API
    /// </summary>
    procedure FormatDateTime(inputDate: Date): Text
    var
        FormattedDateTime: Text;
        CurrentDateTime: DateTime;
    begin
        // Convert the input date to DateTime with the current time  
        CurrentDateTime := CreateDateTime(inputDate, Time());

        // Format the DateTime in the desired format  
        FormattedDateTime := Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');

        exit(FormattedDateTime);
    end;

    procedure GetAvalaraTok(): Text
    begin
        exit(AvalaraTok);
    end;

    var
        TempMandates: Record Mandate temporary;
        TempAvalaraCompanies: Record "Company" temporary;
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        IncorrectDocumentIdInResponseErr: Label 'Document ID returned by API does not match E-Document.';
        DocumentIdNotFoundErr: Label 'Document ID not found in response.';
        AvalaraProcessingDocFailedErr: Label 'An error has been identified in the submitted document.';
        AvalaraCountryMandateLongerErr: Label 'Avalara country mandate is longer than what is supported by framework.';
        AvalaraCountryMandateCodeErr: Label 'Avalara country code is longer than what is supported by framework.';
        AvalaraCountryMandateDescLongerErr: Label 'Avalara mandate description is longer than what is supported by framework.';
        AvalaraCountryIdLongerErr: Label 'Avalara company id is longer than what is supported by framework.';
        AvaralaCountryNameLongerErr: Label 'Avalara company name is longer than what is supported by framework.';
        AvalaraIdLongerErr: Label 'Avalara returned id longer than supported by framework.';
        AvalaraGetDocsPathTxt: Label '/einvoicing/documents?flow=in&count=true&filter=status eq Complete&startDate=%1&endDate=%2', Locked = true;
        AvalaraPickMandateMsg: Label 'Select which Avalara service you want to update mandate for.';
        AvalaraTok: Label 'E-Document - Avalara', Locked = true;
}