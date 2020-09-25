// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10537 "MTD Connection"
{
    trigger OnRun()
    begin

    end;

    var
        OAuthNotConfiguredErr: Label 'OAuth setup is not enabled for HMRC Making Tax Digital.';
        OpenSetupMsg: Label 'Open service connections to setup.';
        OpenSetupQst: Label 'Do you want to open the setup?';
        SubmitVATReturnTxt: Label 'Submit VAT Return.', Locked = true;
        RetrieveVATReturnTxt: Label 'Retrieve VAT Return.', Locked = true;
        RetrieveVATReturnPeriodsTxt: Label 'Retrieve VAT Return Periods.', Locked = true;
        RetrieveVATLiabilitiesTxt: Label 'Retrieve VAT Liabilities.', Locked = true;
        RetrieveVATPaymentsTxt: Label 'Retrieve VAT Payments.', Locked = true;
        Error_VRN_INVALID_Txt: Label 'The provided VRN is invalid.', Locked = true;
        Error_INVALID_DATE_FROM_Txt: Label 'Invalid date from.', Locked = true;
        Error_INVALID_DATE_TO_Txt: Label 'Invalid date to.', Locked = true;
        Error_INVALID_DATE_RANGE_Txt: Label 'Invalid date range.', Locked = true;
        Error_INVALID_STATUS_Txt: Label 'Invalid status.', Locked = true;
        Error_PERIOD_KEY_INVALID_Txt: Label 'Invalid period key.', Locked = true;
        Error_INVALID_REQUEST_Txt: Label 'Invalid request.', Locked = true;
        Error_VAT_TOTAL_VALUE_Txt: Label 'TotalVatDue should be equal to the sum of vatDueSales and vatDueAcquisitions.', Locked = true;
        Error_VAT_NET_VALUE_Txt: Label 'NetVatDue should be the difference between the largest and the smallest values among totalVatDue and vatReclaimedCurrPeriod.', Locked = true;
        Error_INVALID_NUMERIC_VALUE_Txt: Label 'Please provide a numeric field.', Locked = true;
        Error_DATE_RANGE_TOO_LARGE_Txt: Label 'The date of the requested return cannot be more than four years from the current date.', Locked = true;
        Error_NOT_FINALISED_Txt: Label 'User has not declared VAT return as final.', Locked = true;
        Error_DUPLICATE_SUBMISSION_Txt: Label 'User has has already submitted a VAT return for the given period.', Locked = true;
        Error_CLIENT_OR_AGENT_NOT_AUTHORISED_Txt: Label 'The client and/or agent is not authorised.', Locked = true;
        Error_NOT_FOUND_Txt: Label 'The remote endpoint has indicated that no associated data is found.', Locked = true;
        Error_TOO_MANY_REQ_Txt: Label 'The HMRC service is busy. Try again later.', Locked = true;
        // fault model labels
        UKMakingTaxDigitalTok: Label 'UKMakingTaxDigitalTelemetryCategoryTok', Locked = true;
        InvokeReqMsg: Label 'invoke request: %1', Locked = true;
        InvokeReqSuccessMsg: Label 'https request successfully executed', Locked = true;
        RefreshAccessTokenMsg: Label 'refreshing access token', Locked = true;
        NoHttpStatusErr: Label 'No http status from the https response', Locked = true;
        NoJsonResponseErr: Label 'Could not parse http response as json object', Locked = true;
        NoContentMessageErr: Label 'No content.message in the json response', Locked = true;
        EmptyJsonErrMsgErr: Label 'Missing error description in json response', Locked = true;
        NoContentStatusCodeErr: Label 'No Content.statusCode in json response', Locked = true;
        EmptyStatusCodeErr: Label 'Empty status code in json response', Locked = true;
        CannotParseResponseErr: Label 'Cannot parse the http error response', Locked = true;

    internal procedure InvokeRequest_SubmitVATReturn(var ResponseJson: Text; var RequestJson: Text; var HttpError: Text): Boolean
    begin
        CheckOAuthConfigured(false);
        Session.LogMessage('0000CC0', StrSubstNo(InvokeReqMsg, 'submit VAT return'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(InvokeRequest('POST', SubmitVATReturnPath(), ResponseJson, RequestJson, HttpError, SubmitVATReturnTxt));
    end;

    internal procedure InvokeRequest_RetrieveVATReturns(PeriodKey: Code[10]; var ResponseJson: Text; ShowMessage: Boolean; var HttpError: Text): Boolean
    var
        RequestJson: Text;
    begin
        CheckOAuthConfigured(ShowMessage);
        Session.LogMessage('0000CC0', StrSubstNo(InvokeReqMsg, 'retrieve VAT return'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(InvokeRequest('GET', RetrieveVATReturnPath(PeriodKey), ResponseJson, RequestJson, HttpError, RetrieveVATReturnTxt));
    end;

    internal procedure InvokeRequest_RetrieveVATReturnPeriods(StartDate: Date; EndDate: Date; var ResponseJson: Text; var HttpError: Text; OpenOAuthSetup: Boolean): Boolean
    var
        RequestJson: Text;
    begin
        CheckOAuthConfigured(OpenOAuthSetup);
        Session.LogMessage('0000CC0', StrSubstNo(InvokeReqMsg, 'retrieve VAT return periods'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(InvokeRequest('GET', RetrieveObligationsPath(StartDate, EndDate), ResponseJson, RequestJson, HttpError, RetrieveVATReturnPeriodsTxt));
    end;

    internal procedure InvokeRequest_RetrieveLiabilities(StartDate: Date; EndDate: Date; var ResponseJson: Text; var HttpError: Text): Boolean
    var
        RequestJson: Text;
    begin
        CheckOAuthConfigured(true);
        Session.LogMessage('0000CC0', StrSubstNo(InvokeReqMsg, 'retrieve liabilities'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(InvokeRequest('GET', RetrieveLiabilitiesPath(StartDate, EndDate), ResponseJson, RequestJson, HttpError, RetrieveVATLiabilitiesTxt));
    end;

    internal procedure InvokeRequest_RetrievePayments(StartDate: Date; EndDate: Date; var ResponseJson: Text; var HttpError: Text): Boolean
    var
        RequestJson: Text;
    begin
        CheckOAuthConfigured(true);
        Session.LogMessage('0000CC0', StrSubstNo(InvokeReqMsg, 'retrieve payments'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(InvokeRequest('GET', RetrievePaymentsPath(StartDate, EndDate), ResponseJson, RequestJson, HttpError, RetrieveVATPaymentsTxt));
    end;

    internal procedure InvokeRequest_RefreshAccessToken(var HttpError: Text): Boolean;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        CheckOAuthConfigured(false);
        OAuth20Setup.GET(GetOAuthSetupCode());
        Session.LogMessage('0000CCE', RefreshAccessTokenMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(OAuth20Setup.RefreshAccessToken(HttpError));
    end;

    local procedure CheckOAuthConfigured(OpenSetup: Boolean)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
        OAuth20SetupCode: code[20];
    begin
        if IsOAuthConfigured() then
            exit;

        if not OpenSetup then
            Error(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupMsg));

        if Confirm(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst)) then begin
            OAuth20SetupCode := GetOAuthSetupCode();
            if not OAuth20Setup.GET(OAuth20SetupCode) then begin
                MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, OAuth20SetupCode);
                Commit();
            end;
            Page.RunModal(Page::"OAuth 2.0 Setup", OAuth20Setup);
            if IsOAuthConfigured() then
                exit;
        end;

        Error('');
    end;

    local procedure IsOAuthConfigured(): Boolean
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        if OAuth20Setup.Get(GetOAuthSetupCode()) then
            exit(OAuth20Setup.Status = OAuth20Setup.Status::Enabled);
    end;

    internal procedure GetOAuthSetupCode(): Code[20]
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        with VATReportSetup do begin
            Get();
            exit(GetMTDOAuthSetupCode());
        end;
    end;

    local procedure InvokeRequest(Method: Text; RequestPath: Text; var ResponseJson: Text; var RequestJson: Text; var HttpError: Text; ActivityLogContext: Text) Result: Boolean
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        VATReportSetup: Record "VAT Report Setup";
        JObject: JsonObject;
        JObject2: JsonObject;
        HttpLogError: Text;
    begin
        OAuth20Setup.GET(GetOAuthSetupCode());
        VATReportSetup.Get();

        if (VATReportSetup."MTD OAuth Setup Option" = VATReportSetup."MTD OAuth Setup Option"::Sandbox) and
           (VATReportSetup."MTD Gov Test Scenario" <> '')
        then
            JObject2.Add('Gov-Test-Scenario', VATReportSetup."MTD Gov Test Scenario");
        JObject.Add('Header', JObject2);
        JObject.Add('Accept', 'application/vnd.hmrc.1.0+json');
        JObject.Add('URLRequestPath', RequestPath);
        JObject.Add('Method', Method);
        if RequestJson <> '' then
            if JObject2.ReadFrom(RequestJson) then begin
                JObject.Add('Content-Type', 'application/json');
                JObject.Add('Content', JObject2);
            end;

        JObject.WriteTo(RequestJson);

        Result := OAuth20Setup.InvokeRequest(RequestJson, ResponseJson, HttpError, true);

        if not Result then
            TryParseHMRCErrors(HttpError, HttpLogError, ResponseJson);

        LogActivity(OAuth20Setup, ActivityLogContext, HttpLogError);

        Commit();

        if Result then
            Session.LogMessage('0000CC5', InvokeReqSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
    end;

    local procedure LogActivity(OAuth20Setup: Record "OAuth 2.0 Setup"; ActivityLogContext: Text; HttpError: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        with ActivityLog do
            if Get(OAuth20Setup."Activity Log ID") then begin
                if Description <> '' then
                    Description += ' ';
                Description := CopyStr(Description + ActivityLogContext, 1, MaxStrLen(Description));
                if HttpError <> '' then
                    "Activity Message" := CopyStr(HttpError, 1, MaxStrLen("Activity Message"));
                Modify();
            end;
    end;

    internal procedure IsError404NotFound(ResponseJson: Text): Boolean
    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        StatusCode: Integer;
        StatusReason: Text;
        StatusDetails: Text;
    begin
        if OAuth20Mgt.GetHttpStatusFromJsonResponse(ResponseJson, StatusCode, StatusReason, StatusDetails) then
            exit(StatusCode = 404);
    end;

    internal procedure IsError408Timeout(ResponseJson: Text): Boolean;
    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        StatusCode: Integer;
        StatusReason: Text;
        StatusDetails: Text;
    begin
        if OAuth20Mgt.GetHttpStatusFromJsonResponse(ResponseJson, StatusCode, StatusReason, StatusDetails) then
            exit(StatusCode = 408);
    end;

    /*
    TryParseHMRCErrors()
    Try to read Response Json from HMRC and replace generic error (400,401, ..) with meaningfull HMRC error description
    API doc: https://developer.service.hmrc.gov.uk/api-documentation/docs/api/service/vat-api/1.0
    Possible templates:
    1
    "Content": {
        "statusCode": 400,
        "message": "INVALID_DATE_RANGE"
    }

    2
    "Content": {
        "code": "INVALID_REQUEST",
        "message": "Invalid request",
        "errors": [
            {
            "code": "INVALID_MONETARY_AMOUNT",
            "message": "amount should be a monetary value (to 2 decimal places), between 0 and 99,999,999,999.99",
            "path": "/netVatDue"
            }
        ]
    },
    */
    local procedure TryParseHMRCErrors(var HttpError: Text; var HttpLogError: Text; ResponseJson: Text): Boolean
    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        JObject: JsonObject;
        JToken: JsonToken;
        JToken2: JsonToken;
        StatusCode: Integer;
        StatusReason: Text;
        StatusDetails: Text;
        JsonErrorMessage: Text;
        HMRCErrorMessage: Text;
    begin
        HttpLogError := HttpError;

        if not OAuth20Mgt.GetHttpStatusFromJsonResponse(ResponseJson, StatusCode, StatusReason, StatusDetails) then begin
            Session.LogMessage('0000CC6', NoHttpStatusErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;

        if not JObject.ReadFrom(ResponseJson) then begin
            Session.LogMessage('0000CC7', NoJsonResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;

        if not JObject.SelectToken('Content.message', JToken) then begin
            Session.LogMessage('0000CC8', NoContentMessageErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;

        JsonErrorMessage := JToken.AsValue().AsText();
        if JsonErrorMessage = '' then begin
            Session.LogMessage('0000CC9', EmptyJsonErrMsgErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;

        // {"code", "message",  "errors":[{"code", "message", "path"},...]}
        if JObject.SelectToken('Content.code', JToken) then
            if JToken.AsValue().AsText() <> '' then begin
                HttpError := JsonErrorMessage;
                if JObject.SelectToken('Content.errors', JToken) then
                    if JToken.IsArray() then
                        foreach JToken in JToken.AsArray() do begin
                            if JToken.SelectToken('message', JToken2) then
                                if JToken2.AsValue().AsText() <> '' then
                                    HttpError += '\' + JToken2.AsValue().AsText();
                            if JToken.SelectToken('path', JToken2) then
                                if JToken2.AsValue().AsText() <> '' then
                                    HttpError += StrSubstNo(' (path %1)', JToken2.AsValue().AsText());
                        end;
                HttpLogError := StrSubstNo('HTTP error %1 (%2). %3', StatusCode, StatusReason, HttpError);
                if (StatusCode = 429) then
                    HttpError := Error_TOO_MANY_REQ_Txt;

                Session.LogMessage('0000CCA', HttpError, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
                exit(true);
            end;

        if not JObject.SelectToken('Content.statusCode', JToken) then begin
            Session.LogMessage('0000CCB', NoContentStatusCodeErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;
        if JToken.AsValue().AsText() = '' then begin
            Session.LogMessage('0000CCC', EmptyStatusCodeErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(false);
        end;

        case StatusCode of
            400:
                case JsonErrorMessage of
                    'VRN_INVALID':
                        HMRCErrorMessage := Error_VRN_INVALID_Txt;
                    'INVALID_DATE_FROM', 'DATE_FROM_INVALID':
                        HMRCErrorMessage := Error_INVALID_DATE_FROM_Txt;
                    'INVALID_DATE_TO', 'DATE_TO_INVALID':
                        HMRCErrorMessage := Error_INVALID_DATE_TO_Txt;
                    'INVALID_DATE_RANGE', 'DATE_RANGE_INVALID':
                        HMRCErrorMessage := Error_INVALID_DATE_RANGE_Txt;
                    'INVALID_STATUS':
                        HMRCErrorMessage := Error_INVALID_STATUS_Txt;
                    'PERIOD_KEY_INVALID':
                        HMRCErrorMessage := Error_PERIOD_KEY_INVALID_Txt;
                    'INVALID_REQUEST':
                        HMRCErrorMessage := Error_INVALID_REQUEST_Txt;
                    'VAT_TOTAL_VALUE':
                        HMRCErrorMessage := Error_VAT_TOTAL_VALUE_Txt;
                    'VAT_NET_VALUE':
                        HMRCErrorMessage := Error_VAT_NET_VALUE_Txt;
                    'INVALID_NUMERIC_VALUE':
                        HMRCErrorMessage := Error_INVALID_NUMERIC_VALUE_Txt;
                end;
            403:
                case JsonErrorMessage of
                    'DATE_RANGE_TOO_LARGE':
                        HMRCErrorMessage := Error_DATE_RANGE_TOO_LARGE_Txt;
                    'NOT_FINALISED':
                        HMRCErrorMessage := Error_NOT_FINALISED_Txt;
                    'DUPLICATE_SUBMISSION':
                        HMRCErrorMessage := Error_DUPLICATE_SUBMISSION_Txt;
                    'CLIENT_OR_AGENT_NOT_AUTHORISED':
                        HMRCErrorMessage := Error_CLIENT_OR_AGENT_NOT_AUTHORISED_Txt;
                end;
            404:
                case JsonErrorMessage of
                    'NOT_FOUND':
                        HMRCErrorMessage := Error_NOT_FOUND_Txt;
                end;
        end;

        if HMRCErrorMessage <> '' then begin
            HttpError := HMRCErrorMessage;
            HttpLogError := StrSubstNo('HTTP error %1 (%2). %3', StatusCode, StatusReason, HttpError);
            Session.LogMessage('0000CCD', HttpLogError, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
            exit(true);
        end;

        Session.LogMessage('0000CCF', CannotParseResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UKMakingTaxDigitalTok);
        exit(false);
    end;

    local procedure SubmitVATReturnPath(): Text
    begin
        exit(STRSUBSTNO('/organisations/vat/%1/returns', GetVATRegNo()));
    end;

    local procedure RetrieveVATReturnPath(PeriodNo: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(STRSUBSTNO('/organisations/vat/%1/returns/%2', GetVATRegNo(), TypeHelper.UrlEncode(PeriodNo)));
    end;

    local procedure RetrieveObligationsPath(FromDate: Date; ToDate: Date): Text
    begin
        exit(STRSUBSTNO('/organisations/vat/%1/obligations?from=%2&to=%3', GetVATRegNo(), FormatValue(FromDate), FormatValue(ToDate)));
    end;

    local procedure RetrieveLiabilitiesPath(FromDate: Date; ToDate: Date): Text
    begin
        exit(STRSUBSTNO('/organisations/vat/%1/liabilities?from=%2&to=%3', GetVATRegNo(), FormatValue(FromDate), FormatValue(ToDate)));
    end;

    local procedure RetrievePaymentsPath(FromDate: Date; ToDate: Date): Text
    begin
        exit(STRSUBSTNO('/organisations/vat/%1/payments?from=%2&to=%3', GetVATRegNo(), FormatValue(FromDate), FormatValue(ToDate)));
    end;

    local procedure FormatValue(Value: Variant): Text
    begin
        exit(Format(Value, 0, 9));
    end;

    local procedure GetVATRegNo(): Text[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
        exit(CompanyInformation."VAT Registration No.");
    end;
}
