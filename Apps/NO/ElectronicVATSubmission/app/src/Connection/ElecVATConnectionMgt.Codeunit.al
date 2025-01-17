// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Utilities;
using System.Integration;
using System.Security.AccessControl;
using System.Security.Authentication;
using System.Utilities;

codeunit 10687 "Elec. VAT Connection Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        ElecVATSetup: Record "Elec. VAT Setup";

        ElecVATLoggingMgt: Codeunit "Elec. VAT Logging Mgt.";
        ValidatingLinesProgressTxt: Label 'Validating lines\@1@@@@@@@';
        FeatureConsentErr: Label 'The electronic VAT submission feature is not enabled. To enable it, on the Electronic VAT Setup page, turn on the Enabled toggle.';
        ValidateVATReturnTxt: Label 'Validate VAT Return.';
        ValidatingVATReturnTxt: Label 'Validating VAT report...';
        GettingAltinnTokenTxt: Label 'Getting Altinn token...';
        CreatingInstanceTxt: Label 'Creating instance...';
        UploadingVATReturnSubmissionTxt: Label 'Uploading VAT return submission...';
        UploadingVATReturnTxt: Label 'Uploading VAT return...';
        CompletingDataFillingTxt: Label 'Completing data filling...';
        CompletingSubmissionTxt: Label 'Completing submission...';
        CreateInstanceTxt: Label 'Create instance';
        ExchangeTokenTxt: Label 'Exchange ID-Porten token';
        UploadVATReturnSubmissionTxt: Label 'Upload VAT return submission';
        UploadVATReturnTxt: Label 'Upload VAT return';
        CompleteDataFillingTxt: Label 'Complete data filling';
        CheckFeedbackStatusTxt: Label 'Check feedback status';
        GetFeedbackTxt: Label 'Get feedback';
        GetFeedbackDataTxt: Label 'Get feedback data';
        ValidateReturnErr: Label 'Cannot validate the VAT return.';
        ExchangeTokenErr: Label 'Cannot exchange the token with ID-porten.';
        CreateIntanceErr: Label 'Cannot create an instance.';
        UploadVATReturnSubmissionErr: Label 'Cannot upload the VAT return submission.';
        UploadVATReturnErr: Label 'Cannot upload the VAT return.';
        CompleteDataFillingErr: Label 'Not possible to complete data filling';
        GenerateIntanceUrlErr: Label 'Cannot generate the instance URL from response: %1.', Comment = '%1 = raw response';
        ParseFeedbackCheckErr: Label 'Cannot parse the feedback check from the response: %1.', Comment = '%1 = raw response';
        ParseFeedbackInstanceErr: Label 'Not possible to get feedback instance from the response: %1.', Comment = '%1 = raw response';
        InstanceUrlIncreaseMaxLengthErr: Label 'Cannot get the instance URL %1 because it has more than 250 characters.', Comment = '%1 = url';
        CheckFeedbackStatusErr: Label 'Cannot check the feedback status';
        GetFeedbackErr: Label 'Cannot get feedback.';
        GetFeedbackDataErr: Label 'Cannot get feedback data';
        ReasonTxt: Label 'Reason from the Skatteetaten server: ';
        CannotHandleResponseFromServerErr: Label 'Validation failed for the row %1: %2', Comment = '%1 = number, %2 = raw response text';
        CannotHandleResponseWithReasonFromServerErr: Label 'Validation failed for the row %1. Reason: %2. Use the Download Response Message action for more details', Comment = '%1 = number, %2 = reason text';
        PositiveValidationResultTxt: Label 'ingen avvik', Locked = true;
        EnvironmentBlocksErr: Label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 - url, e.g. https://microsoft.com';
        ConnectionErr: Label 'Could not connect to the remote service %1.', Comment = '%1 - url, e.g. https://microsoft.com';
        HttpErrorCodeAndReasonTxt: Label 'HTTP error %1 (%2)', Comment = '%1 = code, %2 = reason';
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;

    procedure SubmitVATReturn(var VATReportHeader: Record "VAT Report Header")
    var
        User: Record User;
        WebRequestHelper: Codeunit "Web Request Helper";
        ProcessDialog: Dialog;
        BaseUrl: Text;
        InstanceUrl: Text[250];
        DataID: Text;
    begin
        CheckConnection();
        ElecVATSetup.GetRecordOnce();
        ElecVATSetup.TestField("Submission Environment URL");
        ElecVATSetup.TestField("Submission App URL");
        ElecVATLoggingMgt.RemoveResponseDocAttachments(VATReportHeader);
        BaseUrl := ElecVATSetup."Submission Environment URL" + ElecVATSetup."Submission App URL";
        WebRequestHelper.IsValidUri(BaseUrl);
        If GuiAllowed() then begin
            ProcessDialog.Open('#1#######');
            ProcessDialog.Update(1, ValidatingVATReturnTxt);
        end;
        ValidateVATReportLines(VATReportHeader);
        if GuiAllowed() then
            ProcessDialog.Update(1, GettingAltinnTokenTxt);
        UpdateAltinnToken();
        if GuiAllowed() then
            ProcessDialog.Update(1, CreatingInstanceTxt);
        GetInstanceInfo(InstanceUrl, DataID, BaseUrl, VATReportHeader);
        VATReportHeader.Validate("Message Id", InstanceUrl);
        VATReportHeader.modify(true);
        Commit();
        if GuiAllowed() then
            ProcessDialog.Update(1, UploadingVATReturnSubmissionTxt);
        UploadVATReturnSubmission(VATReportHeader, InstanceUrl, DataID);
        if GuiAllowed() then
            ProcessDialog.Update(1, UploadingVATReturnTxt);
        UploadVATReturn(VATReportHeader, InstanceUrl);
        if GuiAllowed() then
            ProcessDialog.Update(1, CompletingDataFillingTxt);
        CompleteDataFilling(InstanceUrl);
        if GuiAllowed() then
            ProcessDialog.Update(1, CompletingSubmissionTxt);
        CompleteDataFilling(InstanceUrl);
        VATReportHeader.Validate(Status, VATReportHeader.Status::Submitted);
        User.SetRange("User Security ID", UserSecurityId());
        if not User.IsEmpty() then
            VATReportHeader.Validate("Submitted By", UserSecurityId());
        VATReportHeader.Validate("Submitted Date", Today());
        VATReportHeader.Modify(true);
        If GuiAllowed() then
            ProcessDialog.Close();
    end;

    procedure IsFeedbackProvided(VATReportHeader: Record "VAT Report Header") Result: Boolean
    var
        FeedbackUrl: Text;
        Response: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        CheckConnection();
        VATReportHeader.TestField("Message Id");
        UpdateAltinnToken();
        FeedbackUrl := VATReportHeader."Message Id";
        AddSlashToUrl(FeedbackUrl);
        FeedbackUrl += 'feedback/status';
        InvokeGetRequestWithAccessTokenCheck(Response, FeedbackUrl, GetJsonContentType(), '', CheckFeedbackStatusTxt, CheckFeedbackStatusErr);
        if not JObject.ReadFrom(Response) then
            error(ParseFeedbackCheckErr, Response);
        if not JObject.SelectToken('$.Content.isFeedbackProvided', JToken) then
            error(ParseFeedbackCheckErr, Response);
        if not Evaluate(Result, JToken.AsValue().AsText()) then
            error(ParseFeedbackCheckErr, Response);
        exit(Result);
    end;

#pragma warning disable AS0078
    procedure IsVATReportAccepted(var VATReportHeader: Record "VAT Report Header") Accepted: Boolean
#pragma warning restore AS0078
    var
        TempBlob: Codeunit "Temp Blob";
        FeedbackUrl: Text;
        Response: Text;
        JObject: JsonObject;
        JToken: JsonToken;
        ContentJToken: JsonToken;
        DataTypeJToken: JsonToken;
        DataJToken: JsonToken;
        DataUrl: Text;
        DataType: Text;
        ContentOutStream: OutStream;
    begin
        CheckConnection();
        VATReportHeader.TestField("Message Id");
        ElecVATLoggingMgt.RemoveResponseDocAttachments(VATReportHeader);
        FeedbackUrl := VATReportHeader."Message Id";
        AddSlashToUrl(FeedbackUrl);
        FeedbackUrl += 'feedback';
        InvokeGetRequestWithAccessTokenCheck(Response, FeedbackUrl, GetJsonContentType(), '', GetFeedbackTxt, GetFeedbackErr);
        if not JObject.ReadFrom(Response) then
            error(ParseFeedbackInstanceErr, Response);
        if not JObject.SelectToken('$.Content.status.substatus.label', JToken) then
            error(ParseFeedbackInstanceErr, Response);
        Accepted := JToken.AsValue().AsText() = 'Mottatt';
        SaveResponseToVATArchive(VATReportHeader, Response);

        if not JObject.SelectToken('$.Content.data', JToken) then
            error(ParseFeedbackInstanceErr, Response);
        Accepted := true;
        foreach DataJToken in JToken.AsArray() do begin
            JObject := DataJToken.AsObject();
            if not JObject.SelectToken('dataType', DataTypeJToken) then
                error(ParseFeedbackInstanceErr, Response);
            DataType := DataTypeJToken.AsValue().AsText();
            if DataType in ['valideringsresultat', 'betalingsinformasjon', 'kvittering'] then begin
                if not JObject.SelectToken('$.selfLinks.apps', JToken) then
                    error(ParseFeedbackInstanceErr, Response);
                DataUrl := JToken.AsValue().AsText();
                if DataType = 'kvittering' then begin
                    InvokeGetRequestBinaryFile(TempBlob, Response, DataUrl, GetFeedbackDataTxt, GetFeedbackDataErr);
                    if not JObject.ReadFrom(Response) then
                        error(ParseFeedbackInstanceErr, Response);
                    ElecVATLoggingMgt.AttachPDFResponseToVATRepHeader(TempBlob, VATReportHeader, DataType);
                end else begin
                    InvokeGetRequestWithAccessTokenCheck(Response, DataUrl, GetTextXmlContentType(), '', GetFeedbackDataTxt, GetFeedbackDataErr);
                    if not JObject.ReadFrom(Response) then
                        error(ParseFeedbackInstanceErr, Response);
                    if not JObject.SelectToken('ContentText', ContentJToken) then
                        error(ParseFeedbackInstanceErr, Response);
                    TempBlob.CreateOutStream(ContentOutStream, TextEncoding::UTF8);
                    ContentOutStream.WriteText(ContentJToken.AsValue().AsText());
                    ElecVATLoggingMgt.AttachXmlResponseToVATRepHeader(TempBlob, VATReportHeader, DataType);
                    VATReportHeader.Validate(KID, GetKidNumberFromXMLResponse(ContentJToken.AsValue().AsText()));
                    VATReportHeader.Modify(true);
                end;
                if not JObject.SelectToken('Status.reason', JToken) then
                    error(ParseFeedbackInstanceErr, Response);
                Accepted := Accepted and (JToken.AsValue().AsText() = 'OK');
                if Accepted and (DataType = 'valideringsresultat') then
                    Accepted := ParseValidationResponse(Response, '', VATReportHeader, false);
            end;
        end;
        exit(Accepted);
    end;

    local procedure GetKidNumberFromXMLResponse(XmlResponse: Text): Text
    var
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
    begin
        ElecVATXMLHelper.LoadXmlFromText(XmlResponse);
        exit(ElecVATXMLHelper.GetFirstNodeValueByXPath('//*[name()=''betalingsinformasjon'']/*[name()=''kundeidentifikasjonsnummer'']'));
    end;

    local procedure SaveResponseToVATArchive(VATReportHeader: Record "VAT Report Header"; Response: Text)
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        ResposeOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(ResposeOutStream, TextEncoding::UTF8);
        ResposeOutStream.WriteText(Response);
        VATReportArchive.ArchiveResponseMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob);
    end;

    procedure GetUploadVATReturnRequestPart(): Text
    begin
        exit('data?datatype=mvamelding');
    end;

    local procedure ValidateVATReportLines(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        StatusDialog: Dialog;
        TotalLines: Integer;
        LinesHandled: Integer;
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.FindSet();
        If GuiAllowed() then begin
            StatusDialog.Open(ValidatingLinesProgressTxt);
            TotalLines := VATStatementReportLine.Count();
            LinesHandled := 0;
        end;
        repeat
            If GuiAllowed() then begin
                LinesHandled += 1;
                StatusDialog.Update(1, Round(LinesHandled / TotalLines * 10000, 1));
            end;
            ValidateVATReportLine(VATReportHeader, VATStatementReportLine);
        until VATStatementReportLine.Next() = 0;
        If GuiAllowed() then
            StatusDialog.Close();
    end;

    local procedure ValidateVATReportLine(VATReportHeader: Record "VAT Report Header"; VATStatementReportLine: Record "VAT Statement Report Line")
    var
        TempVATStatementReportLine: Record "VAT Statement Report Line" temporary;
        ElecVATCreateContent: Codeunit "Elec. VAT Create Content";
        Request: Text;
        Response: Text;
    begin
        CheckConnection();
        ElecVATSetup.TestField("Validate VAT Return Url");
        ElecVATLoggingMgt.LogValidationRun();
        TempVATStatementReportLine := VATStatementReportLine;
        TempVATStatementReportLine.Insert();
        Request := ElecVATCreateContent.CreateVATReportLinesNodeContent(TempVATStatementReportLine);
        ElecVATLoggingMgt.AttachXmlSubmissionTextToVATRepHeader(Request, VATReportHeader, 'mvakode-' + VATStatementReportLine."Box No.");
        Commit();
        InvokePostRequestWithAccessTokenCheck(Response, ElecVATSetup."Validate VAT Return Url", GetXmlContentType(), Request, ValidateVATReturnTxt, ValidateReturnErr);
        ParseValidationResponse(Response, VATStatementReportLine."Box No.", VATReportHeader, true);
    end;

    local procedure GetInstanceInfo(var InstanceUrl: Text[250]; var DataID: Text; BaseUrl: Text; VATReportHeader: Record "VAT Report Header")
    var
        ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
        InstanceOwnerJObject: JsonObject;
        OrganizationNumberJObject: JsonObject;
        RequestJson: Text;
        ApplicationUrl: Text;
        Response: Text;
    begin
        OrganizationNumberJObject.Add('organisationNumber', ElecVATDataMgt.GetDigitVATRegNo());
        InstanceOwnerJObject.Add('instanceOwner', OrganizationNumberJObject.AsToken());
        InstanceOwnerJObject.WriteTo(RequestJson);
        ApplicationUrl := BaseUrl;
        AddSlashToUrl(ApplicationUrl);
        ApplicationUrl += 'instances/';
        ElecVATLoggingMgt.AttachXmlSubmissionTextToVATRepHeader(RequestJson, VATReportHeader, CreateInstanceTxt);
        Commit();
        InvokeJsonPostRequestWithAccessTokenCheck(Response, ApplicationUrl, RequestJson, CreateInstanceTxt, CreateIntanceErr);
        GetInstanceInfoFromResponse(InstanceUrl, DataID, ApplicationUrl, Response);
    end;

    local procedure ParseValidationResponse(ResponseJson: Text; BoxNo: Text; VATReportHeader: Record "VAT Report Header"; AddToAttachment: Boolean): Boolean
    var
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
        JToken: JsonToken;
        ValidationResult: Text;
        FailureReason: Text;
        ErrorMessage: Text;
    begin
        ErrorMessage := StrSubstNo(CannotHandleResponseFromServerErr, BoxNo, ResponseJson);
        if not JToken.ReadFrom(ResponseJson) then
            Error(ErrorMessage);
        if not JToken.SelectToken('ContentText', JToken) then
            Error(ErrorMessage);
        ElecVATXMLHelper.LoadXmlFromText(JToken.AsValue().AsText());
        ValidationResult := ElecVATXMLHelper.GetFirstNodeValueByXPath('//*[name()=''valideringsresultat'']/*[name()=''avvikVedMeldingslevering'']');
        if ValidationResult = PositiveValidationResultTxt then
            exit(true);
        FailureReason :=
            ElecVATXMLHelper.GetFirstNodeValueByXPath('//*[name()=''valideringsresultat'']/*[name()=''avvik'']/*[name()=''avviksinformasjon'']/*[name()=''begrunnelse'']');
        if FailureReason = '' then begin
            if BoxNo = '' then
                exit(false);
            Error(ErrorMessage);
        end;
        if BoxNo = '' then
            exit(false);
        if AddToAttachment then begin
            ElecVATLoggingMgt.AttachXmlResponseTextToVATRepHeader(ResponseJson, VATReportHeader, 'valideringsresultat');
            Commit();
        end;
        Error(CannotHandleResponseWithReasonFromServerErr, BoxNo, FailureReason);
    end;

    local procedure GetInstanceInfoFromResponse(var InstanceUrl: Text[250]; var DataID: Text; ApplicationUrl: Text; ResponseJson: Text)
    var
        JObject: JsonObject;
        PartyIDJToken: JsonToken;
        InstanceGuidJToken: JsonToken;
        DataGuidJToken: JsonToken;
        PartyID: Text;
        InstanceGuid: Text;
        FullInstanceUrl: Text;
    begin
        if not JObject.ReadFrom(ResponseJson) then
            error(GenerateIntanceUrlErr, ResponseJson);
        if not JObject.SelectToken('$.Content.instanceOwner.partyId', PartyIDJToken) then
            error(GenerateIntanceUrlErr, ResponseJson);
        PartyID := PartyIDJToken.AsValue().AsText();
        if not JObject.SelectToken('$.Content.data[*].id', DataGuidJToken) then
            error(GenerateIntanceUrlErr, ResponseJson);
        DataID := DataGuidJToken.AsValue().AsText();
        if not JObject.SelectToken('$.Content.data[*].instanceGuid', InstanceGuidJToken) then
            error(GenerateIntanceUrlErr, ResponseJson);
        InstanceGuid := InstanceGuidJToken.AsValue().AsText();
        FullInstanceUrl := ApplicationUrl + PartyID + '/' + InstanceGuid;
        if StrLen(FullInstanceUrl) > MaxStrLen(InstanceUrl) then
            Error(InstanceUrlIncreaseMaxLengthErr, FullInstanceUrl);
        InstanceUrl := CopyStr(FullInstanceUrl, 1, MaxStrLen(InstanceUrl));
    end;

    local procedure UploadVATReturnSubmission(VATReportHeader: Record "VAT Report Header"; InstanceUrl: Text; DataID: Text)
    var
        ElecVATCreateContent: Codeunit "Elec. VAT Create Content";
        VATReturnSubmissionUrl: Text;
        Request: Text;
        Response: Text;
    begin
        VATReturnSubmissionUrl := InstanceUrl;
        AddSlashToUrl(VATReturnSubmissionUrl);
        VATReturnSubmissionUrl += 'data/' + DataID;
        Request := ElecVATCreateContent.CreateVATReturnSubmissionContent(VATReportHeader);
        ElecVATLoggingMgt.AttachXmlSubmissionTextToVATRepHeader(Request, VATReportHeader, 'konvolutt');
        Commit();
        InvokePutRequestWithAccessTokenCheck(
            Response, VATReturnSubmissionUrl, GetXmlContentType(), Request, UploadVATReturnSubmissionTxt, UploadVATReturnSubmissionErr);
    end;

    local procedure UploadVATReturn(VATReportHeader: Record "VAT Report Header"; InstanceUrl: Text)
    var
        VATReportArchive: Record "VAT Report Archive";
        MessageInStream: InStream;
        UploadVATReturnUrl: Text;
        Request: Text;
        Response: Text;
    begin
        UploadVATReturnUrl := InstanceUrl;
        AddSlashToUrl(UploadVATReturnUrl);
        UploadVATReturnUrl += GetUploadVATReturnRequestPart();
        VATReportArchive.Get(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.");
        VATReportArchive.CalcFields("Submission Message BLOB");
        VATReportArchive."Submission Message BLOB".CreateInStream(MessageInStream, TextEncoding::UTF8);
        MessageInStream.Read(Request);
        InvokePostRequestWithAccessTokenCheck(Response, UploadVATReturnUrl, GetTextXmlContentType(), Request, UploadVATReturnTxt, UploadVATReturnErr);
    end;

    local procedure CompleteDataFilling(InstanceUrl: Text)
    var
        CompleteDataFillingUrl: Text;
        Response: Text;
    begin
        CompleteDataFillingUrl := InstanceUrl;
        AddSlashToUrl(CompleteDataFillingUrl);
        CompleteDataFillingUrl += 'process/next';
        InvokePutRequestWithAccessTokenCheck(
            Response, CompleteDataFillingUrl, GetJsonContentType(), '', CompleteDataFillingTxt, CompleteDataFillingErr);
    end;

    [NonDebuggable]
    internal procedure UpdateAltinnToken()
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        JToken: JsonToken;
        Response: Text;
    begin
        CheckConnection();
        ElecVATSetup.TestField("Exchange ID-Porten Token Url");
        InvokeGetRequestWithAccessTokenCheck(Response, ElecVATSetup."Exchange ID-Porten Token Url", '', '', ExchangeTokenTxt, ExchangeTokenErr);
        if Response = '' then
            error(ExchangeTokenErr);
        if not JToken.ReadFrom(Response) then
            Error(ExchangeTokenErr);
        if not JToken.SelectToken('ContentText', JToken) then
            Error(ExchangeTokenErr);
        ElecVATOAuthMgt.SaveAltinnToken(JToken.AsValue().AsText());
    end;

    local procedure InvokePostRequestWithAccessTokenCheck(var Response: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text; ErrorMessageText: Text)
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        HttpError: Text;
        Result: Boolean;
    begin
        Result := ElecVATOAuthMgt.InvokePostRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        if not Result and ElecVATOAuthMgt.IsError408Timeout(Response) then begin
            Result := ElecVATOAuthMgt.RefreshAccessToken(HttpError);
            if Result then
                Result := ElecVATOAuthMgt.InvokePostRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        end;
        HandleNegativeResult(Result, HttpError, ErrorMessageText);
    end;

    local procedure InvokeJsonPostRequestWithAccessTokenCheck(var Response: Text; RequestPath: Text; Request: Text; ActivityLogContext: Text; ErrorMessageText: Text)
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        HttpError: Text;
        Result: Boolean;
    begin
        Result := ElecVATOAuthMgt.InvokePostRequestJsonContentType(Response, HttpError, RequestPath, Request, ActivityLogContext);
        if not Result and ElecVATOAuthMgt.IsError408Timeout(Response) then begin
            Result := ElecVATOAuthMgt.RefreshAccessToken(HttpError);
            if Result then
                Result := ElecVATOAuthMgt.InvokePostRequestJsonContentType(Response, HttpError, RequestPath, Request, ActivityLogContext);
        end;
        HandleNegativeResult(Result, HttpError, ErrorMessageText);
    end;

    local procedure InvokeGetRequestWithAccessTokenCheck(var Response: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text; ErrorMessageText: Text)
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        HttpError: Text;
        Result: Boolean;
    begin
        Result := ElecVATOAuthMgt.InvokeGetRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        if not Result and ElecVATOAuthMgt.IsError408Timeout(Response) then begin
            Result := ElecVATOAuthMgt.RefreshAccessToken(HttpError);
            if Result then
                Result := ElecVATOAuthMgt.InvokeGetRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        end;
        HandleNegativeResult(Result, HttpError, ErrorMessageText);
    end;

    local procedure InvokePutRequestWithAccessTokenCheck(var Response: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text; ErrorMessageText: Text)
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        HttpError: Text;
        Result: Boolean;
    begin
        Result := ElecVATOAuthMgt.InvokePutRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        if not Result and ElecVATOAuthMgt.IsError408Timeout(Response) then begin
            Result := ElecVATOAuthMgt.RefreshAccessToken(HttpError);
            if Result then
                Result := ElecVATOAuthMgt.InvokePutRequest(Response, HttpError, RequestPath, ContentType, Request, ActivityLogContext);
        end;
        HandleNegativeResult(Result, HttpError, ErrorMessageText);
    end;

    [NonDebuggable]
    local procedure InvokeGetRequestBinaryFile(var TempBlob: Codeunit "Temp Blob"; var ResponseJson: Text; RequestPath: Text; ActivityLogContext: Text; ErrorMessageText: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ActivityLog: Record "Activity Log";
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
        HttpClientVar: HttpClient;
        HttpRequestMessageVar: HttpRequestMessage;
        HttpResponseMessageVar: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ErrorMessage: Text;
        HttpError: Text;
        Bearer: SecretText;
        LogStatus: Option;
        Result: Boolean;
    begin
        HttpClientVar.Clear();
        HttpClientVar.Timeout(60000);
        HttpRequestMessageVar.GetHeaders(RequestHeaders);
        RequestHeaders.Clear();
        ElecVATOAuthMgt.GetOAuthSetup(OAuth20Setup);
        IsolatedStorage.Get(OAuth20Setup."Altinn Token", OAuth20Setup.GetTokenDataScope(), Bearer);
        RequestHeaders.Add('Authorization', SecretStrSubstNo(BearerTxt, Bearer));
        HttpRequestMessageVar.Method('GET');
        HttpRequestMessageVar.SetRequestUri(RequestPath);
        if not HttpClientVar.Send(HttpRequestMessageVar, HttpResponseMessageVar) then
            if HttpResponseMessageVar.IsBlockedByEnvironment() then
                ErrorMessage := StrSubstNo(EnvironmentBlocksErr, HttpRequestMessageVar.GetRequestUri())
            else
                ErrorMessage := StrSubstNo(ConnectionErr, HttpRequestMessageVar.GetRequestUri());
        if ErrorMessage <> '' then
            Error(ErrorMessage);
        Result := ProcessHttpBinaryResponseMessage(HttpResponseMessageVar, TempBlob, ResponseJson, HttpError);
        If Result then
            LogStatus := ActivityLog.Status::Success
        else
            LogStatus := ActivityLog.Status::Failed;
        ActivityLog.LogActivity(OAuth20Setup.RecordId(), LogStatus, CopyStr(ActivityLogContext, 1, MaxStrLen(ActivityLog.Context)), RequestPath, ActivityLogContext);
        HandleNegativeResult(Result, HttpError, ErrorMessageText);
    end;

    local procedure ProcessHttpBinaryResponseMessage(var HttpResponseMessageVar: HttpResponseMessage; var TempBlob: Codeunit "Temp Blob"; var ResponseJson: Text; var HttpError: Text) Result: Boolean
    var
        ContentTempBlob: Codeunit "Temp Blob";
        ResponseJObject: JsonObject;
        ContentInStream: InStream;
        ContentOutStream: OutStream;
        StatusCode: Integer;
        StatusReason: Text;
    begin
        Result := HttpResponseMessageVar.IsSuccessStatusCode();
        StatusCode := HttpResponseMessageVar.HttpStatusCode();
        StatusReason := HttpResponseMessageVar.ReasonPhrase();

        Clear(TempBlob);
        if not Result then
            HttpError := StrSubstNo(HttpErrorCodeAndReasonTxt, StatusCode, StatusReason)
        else begin
            ContentTempBlob.CreateInStream(ContentInStream);
            Result := HttpResponseMessageVar.Content().ReadAs(ContentInStream);
            if Result then begin
                TempBlob.CreateOutStream(ContentOutStream);
                CopyStream(ContentOutStream, ContentInStream);
            end;
        end;
        SetHttpStatus(ResponseJObject, StatusCode, StatusReason);
        ResponseJObject.WriteTo(ResponseJson);
    end;

    local procedure SetHttpStatus(var JObject: JsonObject; StatusCode: Integer; StatusReason: Text)
    var
        JObject2: JsonObject;
    begin
        JObject2.Add('code', StatusCode);
        JObject2.Add('reason', StatusReason);
        JObject.Add('Status', JObject2);
    end;

    local procedure HandleNegativeResult(Result: Boolean; HttpError: Text; ErrorMessageText: Text)
    var
        ErrorMsg: Text;
    begin
        if Result then
            exit;

        ErrorMsg := ErrorMessageText;
        if HttpError <> '' then
            ErrorMsg += '\' + ReasonTxt + HttpError;
        LogResultActivity(Result, ErrorMsg);
        Commit();
        Error(ErrorMsg);
    end;

    local procedure AddSlashToUrl(var UrlToUpdate: Text)
    begin
        If CopyStr(UrlToUpdate, StrLen(UrlToUpdate), 1) <> '/' then
            UrlToUpdate += '/';
    end;

    local procedure CheckConnection()
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
    begin
        CheckElecVATEnabled();
        ElecVATOAuthMgt.CheckOAuthConfigured(true);
    end;

    local procedure CheckElecVATEnabled()
    begin
        ElecVATSetup.GetRecordOnce();
        if not ElecVATSetup.Enabled then
            Error(FeatureConsentErr);
    end;

    local procedure LogResultActivity(Result: Boolean; ActivityMessage: Text)
    var
        ActivityLog: Record "Activity Log";
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
    begin
        ElecVATOAuthMgt.GetOAuthSetup(OAuth20Setup);
        with ActivityLog do
            if Get(OAuth20Setup."Activity Log ID") then begin
                if Result then
                    Status := Status::Success
                else
                    Status := Status::Failed;

                if (ActivityMessage <> '') and ("Activity Message" = '') then
                    "Activity Message" := CopyStr(ActivityMessage, 1, MaxStrLen("Activity Message"));
                Modify();
            end;
    end;

    local procedure GetXmlContentType(): Text
    begin
        exit('application/xml');
    end;

    local procedure GetTextXmlContentType(): Text
    begin
        exit('text/xml');
    end;

    local procedure GetJsonContentType(): Text
    begin
        exit('application/json');
    end;
}
