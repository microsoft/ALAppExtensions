codeunit 4705 "VAT Group Submission Status"
{
    var
        BatchJsonResponseErr: Label 'Cannot update VAT report status';
        // Telemetry
        VATGroupTok: Label 'VATGroupTelemetryCategoryTok', Locked = true;
        AllStatusUpdateMsg: Label 'Updating status for all the VAT reports', Locked = true;
        AllStatusUpdateSuccMsg: Label 'Status successfully updated for all the VAT reports', Locked = true;
        SingleStatusUpdateMsg: Label 'Updating status for a single VAT report', Locked = true;
        SingleStatusUpdateSuccMsg: Label 'Status for single VAT report successfully updated', Locked = true;
        BatchEmptyResponseErr: Label 'The batch response is empty', Locked = true;
        BatchSingleRequestErrMsg: Label 'One of the requests inside the batch failed with error code %1 and message %2', Locked = true;

    trigger OnRun()
    begin
        UpdateAllVATReportStatus();
    end;

    procedure UpdateAllVATReportStatus()
    var
        VATGroupSerialization: Codeunit "VAT Group Serialization";
        VATGroupCommunication: Codeunit "VAT Group Communication";
        JsonObj: JsonObject;
        VATGroupReturnNoList: List of [Text];
        BatchPayload: Text;
        HttpResponseBodyText: Text;
    begin
        CreateVATGroupReturnNoList(VATGroupReturnNoList);
        if VATGroupReturnNoList.Count() <= 0 then
            exit;

        Session.LogMessage('0000D7F', AllStatusUpdateMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);

        BatchPayload := VATGroupSerialization.CreateBatchRequestPayload(VATGroupReturnNoList);
        VATGroupCommunication.Send('POST', '/$batch', BatchPayload, HttpResponseBodyText, true);

        JsonObj.ReadFrom(HttpResponseBodyText);
        UpdateStatusInVATReportHeader(JsonObj, VATGroupReturnNoList);

        Session.LogMessage('0000D7G', AllStatusUpdateSuccMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
    end;

    procedure UpdateSingleVATReportStatus(No: Code[20])
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportSetup: Record "VAT Report Setup";
        VATGroupCommunication: Codeunit "VAT Group Communication";
        JsonObj: JsonObject;
        QueryURL: Text;
        MemberId: Text;
        HttpResponseBodyText: Text;
    begin
        VATReportSetup.Get();

        if not VATReportHeader.Get(VATReportHeader."VAT Report Config. Code"::"VAT Return", No) then
            exit;

        if not IsVATReportValid(VATReportHeader) then
            exit;

        Session.LogMessage('0000D7H', SingleStatusUpdateMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);

        MemberId := DelChr(VATReportSetup."Group Member ID", '=', '{|}');
        QueryURL := StrSubstNo(VATGroupCommunication.GetVATGroupSubmissionStatusEndpoint(), No, MemberId);

        VATGroupCommunication.Send('GET', QueryURL, '', HttpResponseBodyText, false);

        JsonObj.ReadFrom(HttpResponseBodyText);
        UpdateSingleStatusInVATReportHeader(No, JsonObj);

        Session.LogMessage('0000D7I', SingleStatusUpdateSuccMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
    end;

    internal procedure IsVATReportValid(VATReportHeader: Record "VAT Report Header"): Boolean
    begin
        if (VATReportHeader."VAT Report Config. Code" <> VATReportHeader."VAT Report Config. Code"::"VAT Return")
            or (VATReportHeader.Status <> VATReportHeader.Status::Submitted)
            or (VATReportHeader."VAT Report Version" <> 'VATGROUP')
            or (not (VATReportHeader."VAT Group Status" in ['', 'Open', 'Released', 'Submitted', 'Pending', 'Cannot update'])) then
            exit(false);

        exit(true);
    end;

    local procedure UpdateSingleStatusInVATReportHeader(no: Code[20]; JsonObj: JsonObject)
    var
        StatusJsonToken: JsonToken;
        Status: Text;
    begin
        if JsonObj.SelectToken('$.value[0].status', StatusJsonToken) then
            Status := StatusJsonToken.AsValue().AsText()
        else
            Status := 'Pending';

        UpdateStatus(No, Status);
    end;

    local procedure CreateVATGroupReturnNoList(var VATGroupReturnNoList: List of [Text])
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code"::"VAT Return");
        VATReportHeader.SetRange(Status, VATReportHeader.Status::Submitted);
        VATReportHeader.SetRange("VAT Report Version", 'VATGROUP');
        VATReportHeader.SetFilter("VAT Group Status", '%1|%2|%3|%4|%5|%6', '', 'Open', 'Released', 'Submitted', 'Pending', 'Cannot update');

        if VATReportHeader.FindSet() then
            repeat
                VATGroupReturnNoList.Add(VATReportHeader."No.")
            until VATReportHeader.Next() = 0;
    end;

    local procedure UpdateStatusInVATReportHeader(JsonObj: JsonObject; VATGroupReturnNoList: List of [Text])
    var
        ResponsesJsonArray: JsonArray;
        ResponsesJsonArrayToken: JsonToken;
        ValueJsonToken: JsonToken;
        ElementJsonToken: JsonToken;
        ElementJsonObj: JsonObject;
        ValueJsonObj: JsonObject;
        NoJsonToken: JsonToken;
        HttpStatusCodeJsonToken: JsonToken;
        RequestIdJsonToken: JsonToken;
        StatusJsonToken: JsonToken;
        ErrMsgToken: JsonToken;
        RequestId: Integer;
        StatusCode: Integer;
        No: Text;
        Status: Text;
        ErrMsg: Text;
    begin
        if not JsonObj.Get('responses', ResponsesJsonArrayToken) then begin
            Session.LogMessage('0000DAF', BatchEmptyResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
            Error(BatchJsonResponseErr);
        end;

        ResponsesJsonArray := ResponsesJsonArrayToken.AsArray();

        foreach ElementJsonToken in ResponsesJsonArray do begin
            ElementJsonObj := ElementJsonToken.AsObject();
            ElementJsonObj.Get('status', HttpStatusCodeJsonToken);
            ElementJsonObj.Get('id', RequestIdJsonToken);
            RequestId := RequestIdJsonToken.AsValue().AsInteger();

            StatusCode := HttpStatusCodeJsonToken.AsValue().AsInteger();

            if StatusCode <> 200 then begin
                VATGroupReturnNoList.Get(RequestId, No);
                Status := 'Cannot update';

                if ElementJsonObj.SelectToken('$.body.error.code', ErrMsgToken) then
                    ErrMsg := ErrMsgToken.AsValue().AsText()
                else
                    ErrMsg := '';

                Session.LogMessage('0000D7J', StrSubstNo(BatchSingleRequestErrMsg, StatusCode, ErrMsg), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
            end else
                if ElementJsonObj.SelectToken('$.body.value[0]', ValueJsonToken) then begin
                    ValueJsonObj := ValueJsonToken.AsObject();
                    ValueJsonObj.Get('no', NoJsonToken);
                    ValueJsonObj.Get('status', StatusJsonToken);
                    No := NoJsonToken.AsValue().AsText();
                    Status := StatusJsonToken.AsValue().AsText();
                end else begin
                    VATGroupReturnNoList.Get(RequestId, No);
                    Status := 'Pending';
                end;

            UpdateStatus(No, Status);
        end;
    end;

    local procedure UpdateStatus(No: Text; Status: Text)
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader.Get(VATReportHeader."VAT Report Config. Code"::"VAT Return", No);
        VATReportHeader."VAT Group Status" := copyStr(Status, 1, MaxStrLen(VATReportHeader."VAT Group Status"));

        if Status = 'Accepted' then
            VATReportHeader.Status := VATReportHeader.Status::Accepted;
        if Status = 'Rejected' then
            VATReportHeader.Status := VATReportHeader.Status::Rejected;

        VATReportHeader.Modify();
    end;
}