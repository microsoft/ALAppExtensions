// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10530 "MTD Mgt."
{
    var
        MTDConnection: Codeunit "MTD Connection";
        RetrievePeriodsUpToDateMsg: Label 'Retrieve VAT return periods are up to date.';
        RetrieveReturnsUpToDateMsg: Label 'Retrieve submitted VAT returns are up to date.';
        RetrievePaymentsUpToDateMsg: Label 'Retrieve VAT payments are up to date.';
        RetrieveLiabilitiesUpToDateMsg: Label 'Retrieve VAT liabilities are up to date.';
        RetrievePeriodsMsg: Label 'Retrieve VAT return periods successful';
        RetrieveReturnsMsg: Label 'Retrieve submitted VAT returns successful';
        RetrievePaymentsMsg: Label 'Retrieve VAT payments successful';
        RetrieveLiabilitiesMsg: Label 'Retrieve VAT liabilities successful';
        IncludingMsg: Label 'including %1 new and %2 modified records.', Comment = '%1, %2 - records count';
        RetrievePeriodsErr: Label 'Not possible to retrieve VAT return periods.';
        RetrieveLiabilitiesErr: Label 'Not possible to retrieve VAT liabilities.';
        RetrievePaymentsErr: Label 'Not possible to retrieve VAT payments.';
        RetrieveReturnsErr: Label 'Not possible to retrieve submitted VAT returns.';
        SubmitReturnErr: Label 'Not possible to submit VAT return.';
        ReasonTxt: Label 'Reason from the HMRC server: ';
        NoSubmittedReturnsMsg: Label 'The remote endpoint has indicated that there is no submitted VAT returns for the specified period.';
        PeriodLinkErr: Label 'There is no return period linked to this VAT return.\\Use the Create From VAT Return Period action on the VAT Returns page or the Create VAT Return action on the VAT Return Periods page.';

    [EventSubscriber(ObjectType::Page, Page::"VAT Report", 'OnAfterInitPageControllers', '', true, true)]
    local procedure OnAfterInitVATReportPageControllers(VATReportHeader: Record "VAT Report Header"; var SubmitControllerStatus: Boolean; var MarkAsSubmitControllerStatus: Boolean)
    begin
        if VATReportHeader."Return Period No." = '' then
            exit;

        SubmitControllerStatus := VATReportHeader.Status = VATReportHeader.Status::Released;
        MarkAsSubmitControllerStatus := false;
    end;

    local procedure MarkSubmittedVATReturnAsAccepted(VATReturnNo: Code[20]; ResponseJson: Text)
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        with VATReportHeader do
            if Get("VAT Report Config. Code"::"VAT Return", VATReturnNo) then
                if Status = Status::Submitted then begin
                    VALIDATE(Status, Status::Accepted);
                    Modify(true);
                    ArchiveResponseMessage(VATReportHeader, ResponseJson);
                end;
    end;

    local procedure MarkAcceptedVATReturnAsClosed(VATReturnNo: Code[20])
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        with VATReportHeader do
            if Get("VAT Report Config. Code"::"VAT Return", VATReturnNo) then
                if Status = Status::Accepted then begin
                    VALIDATE(Status, Status::Closed);
                    Modify(true);
                end;
    end;

    internal procedure SubmitVATReturn(var RequestJson: Text; var ResponseJson: Text) Result: Boolean
    var
        HttpError: Text;
        ErrorMsg: Text;
        OriginalRequestJson: Text;
    begin
        OriginalRequestJson := RequestJson;
        Result := MTDConnection.InvokeRequest_SubmitVATReturn(ResponseJson, RequestJson, HttpError);

        if not Result and MTDConnection.IsError408Timeout(ResponseJson) then begin
            Result := MTDConnection.InvokeRequest_RefreshAccessToken(HttpError);
            if Result then
                Result := MTDConnection.InvokeRequest_SubmitVATReturn(ResponseJson, OriginalRequestJson, HttpError);
        end;

        if not Result then begin
            ErrorMsg := SubmitReturnErr;
            if HttpError <> '' then
                ErrorMsg += '\' + ReasonTxt + HttpError;
            LogActivity(Result, ErrorMsg);
            Commit();
            Error(ErrorMsg);
        end;
    end;

    internal procedure RetrieveVATReturns(VATReturnPeriod: Record "VAT Return Period"; var ResponseJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        HttpError: Text;
    begin
        if MTDConnection.InvokeRequest_RetrieveVATReturns(VATReturnPeriod."Period Key", ResponseJson, ShowMessage, HttpError) then
            Result := ParseVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount);
        if Result then
            MarkSubmittedVATReturnAsAccepted(VATReturnPeriod."VAT Return No.", ResponseJson);

        if not Result and ShowMessage and MTDConnection.IsError404NotFound(ResponseJson) then begin
            LogActivity(Result, NoSubmittedReturnsMsg);
            Commit();
            Message(NoSubmittedReturnsMsg)
        end else
            RetrieveRecordSummaryMessage(
                RetrieveReturnsUpToDateMsg, RetrieveReturnsMsg, RetrieveReturnsErr,
                Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    internal procedure RetrieveVATReturnPeriods(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean; OpenOAuthSetup: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        if MTDConnection.InvokeRequest_RetrieveVATReturnPeriods(StartDate, EndDate, ResponseJson, HttpError, OpenOAuthSetup) then
            Result := ParseObligations(ResponseJson, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrievePeriodsUpToDateMsg, RetrievePeriodsMsg, RetrievePeriodsErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    internal procedure RetrieveLiabilities(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        if MTDConnection.InvokeRequest_RetrieveLiabilities(StartDate, EndDate, ResponseJson, HttpError) then
            Result := ParseLiabilities(ResponseJson, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrieveLiabilitiesUpToDateMsg, RetrieveLiabilitiesMsg, RetrieveLiabilitiesErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    internal procedure RetrievePayments(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        if MTDConnection.InvokeRequest_RetrievePayments(StartDate, EndDate, ResponseJson, HttpError) then
            Result := ParsePayments(ResponseJson, StartDate, EndDate, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrievePaymentsUpToDateMsg, RetrievePaymentsMsg, RetrievePaymentsErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    local procedure ParseObligations(ResponseJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempVATReturnPeriod: Record "VAT Return Period" temporary;
        JToken: JsonToken;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        if JToken.ReadFrom(ResponseJson) then
            if JToken.SelectToken('Content.obligations', JToken) then begin
                if JToken.IsArray() then begin
                    TotalCount := JToken.AsArray().Count();
                    foreach JToken in JToken.AsArray() do
                        if ParseObligation(TempVATReturnPeriod, JToken) then
                            InsertObligation(TempVATReturnPeriod, NewCount, ModifiedCount);
                end;
                exit(true);
            end;
        exit(false);
    end;

    local procedure ParseObligation(var VATReturnPeriod: Record "VAT Return Period"; JToken: JsonToken): Boolean
    var
        RecordRef: RecordRef;
    begin
        with VATReturnPeriod do begin
            Clear(VATReturnPeriod);
            RecordRef.GetTable(VATReturnPeriod);
            ReadJsonValue(RecordRef, JToken, 'start', FieldNo("Start Date"));
            ReadJsonValue(RecordRef, JToken, 'end', FieldNo("End Date"));
            ReadJsonValue(RecordRef, JToken, 'due', FieldNo("Due Date"));
            ReadJsonValue(RecordRef, JToken, 'periodKey', FieldNo("Period Key"));
            ReadJsonValue(RecordRef, JToken, 'received', FieldNo("Received Date"));
            RecordRef.SetTable(VATReturnPeriod);
            if JToken.SelectToken('status', JToken) then
                case JToken.AsValue().AsText() of
                    'O':
                        Status := Status::Open;
                    'F':
                        Status := Status::Closed;
                end;
        end;

        exit(true);
    end;

    local procedure InsertObligation(TempVATReturnPeriod: Record "VAT Return Period" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        if not VATReturnPeriod.FindVATReturnPeriod(VATReturnPeriod, TempVATReturnPeriod."Start Date", TempVATReturnPeriod."End Date") then begin
            VATReturnPeriod := TempVATReturnPeriod;
            VATReturnPeriod.Insert(true);
            NewCount += 1;
        end else
            if VATReturnPeriod.DiffersFromVATReturnPeriod(TempVATReturnPeriod) then begin
                if (VATReturnPeriod.Status = VATReturnPeriod.Status::Open) and
                   (TempVATReturnPeriod.Status = TempVATReturnPeriod.Status::Closed)
                then
                    MarkAcceptedVATReturnAsClosed(VATReturnPeriod."VAT Return No.");
                CopyFromObligation(VATReturnPeriod, TempVATReturnPeriod);
                VATReturnPeriod.Modify();
                ModifiedCount += 1;
            end;
    end;

    local procedure CopyFromObligation(var VATReturnPeriodTo: Record "VAT Return Period"; VATReturnPeriodFrom: Record "VAT Return Period"): Boolean
    begin
        with VATReturnPeriodTo do begin
            Status := VATReturnPeriodFrom.Status;
            "Due Date" := VATReturnPeriodFrom."Due Date";
            "Period Key" := VATReturnPeriodFrom."Period Key";
            "Received Date" := VATReturnPeriodFrom."Received Date";
        end;
    end;

    local procedure ParseVATReturns(VATReturnPeriod: Record "VAT Return Period"; ResponseJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempMTDReturnDetails: Record "MTD Return Details" temporary;
        JToken: JsonToken;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        if not JToken.ReadFrom(ResponseJson) then
            exit(false);

        if not JToken.SelectToken('Content', JToken) then
            exit(false);

        TotalCount := 1;
        TempMTDReturnDetails."Start Date" := VATReturnPeriod."Start Date";
        TempMTDReturnDetails."End Date" := VATReturnPeriod."End Date";
        TempMTDReturnDetails.Finalised := true;
        if not ParseVATReturn(TempMTDReturnDetails, JToken) then
            exit(false);

        InsertVATReturn(TempMTDReturnDetails, NewCount, ModifiedCount);
        exit(true);
    end;

    local procedure ParseVATReturn(var MTDReturnDetails: Record "MTD Return Details"; JToken: JsonToken): Boolean
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(MTDReturnDetails);
        with MTDReturnDetails do begin
            if not ReadJsonValue(RecordRef, JToken, 'periodKey', FieldNo("Period Key")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'vatDueSales', FieldNo("VAT Due Sales")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'vatDueAcquisitions', FieldNo("VAT Due Acquisitions")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'totalVatDue', FieldNo("Total VAT Due")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'vatReclaimedCurrPeriod', FieldNo("VAT Reclaimed Curr Period")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'netVatDue', FieldNo("Net VAT Due")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'totalValueSalesExVAT', FieldNo("Total Value Sales Excl. VAT")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'totalValuePurchasesExVAT', FieldNo("Total Value Purchases Excl.VAT")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'totalValueGoodsSuppliedExVAT', FieldNo("Total Value Goods Suppl. ExVAT")) then
                exit(false);
            if not ReadJsonValue(RecordRef, JToken, 'totalAcquisitionsExVAT', FieldNo("Total Acquisitions Excl. VAT")) then
                exit(false);
        end;
        RecordRef.SetTable(MTDReturnDetails);
        exit(true);
    end;

    local procedure InsertVATReturn(TempMTDReturnDetails: Record "MTD Return Details" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDReturnDetails: Record "MTD Return Details";
    begin
        if not MTDReturnDetails.GET(TempMTDReturnDetails.RecordId()) then begin
            MTDReturnDetails := TempMTDReturnDetails;
            MTDReturnDetails.Insert();
            NewCount += 1;
        end else
            if MTDReturnDetails.DiffersFromReturn(TempMTDReturnDetails) then begin
                MTDReturnDetails := TempMTDReturnDetails;
                MTDReturnDetails.Modify();
                ModifiedCount += 1;
            end;
    end;

    local procedure ParseLiabilities(LiabilitiesJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempMTDLiability: Record "MTD Liability" temporary;
        JToken: JsonToken;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        if JToken.ReadFrom(LiabilitiesJson) then
            if JToken.SelectToken('Content.liabilities', JToken) then begin
                if JToken.IsArray() then begin
                    TotalCount := JToken.AsArray().Count();
                    foreach JToken in JToken.AsArray() do
                        if ParseLiability(TempMTDLiability, JToken) then
                            InsertLiability(TempMTDLiability, NewCount, ModifiedCount);
                end;
                exit(true);
            end;
        exit(false);
    end;

    local procedure ParseLiability(var MTDLiability: Record "MTD Liability"; JToken: JsonToken): Boolean
    var
        RecordRef: RecordRef;
        JToken2: JsonToken;
    begin
        with MTDLiability do begin
            if JToken.SelectToken('type', JToken2) then
                case JToken2.AsValue().AsText() of
                    'VAT Return Debit Charge':
                        Type := Type::"VAT Return Debit Charge";
                end;
            RecordRef.GetTable(MTDLiability);
            ReadJsonValue(RecordRef, JToken, 'originalAmount', FieldNo("Original Amount"));
            ReadJsonValue(RecordRef, JToken, 'outstandingAmount', FieldNo("Outstanding Amount"));
            ReadJsonValue(RecordRef, JToken, 'due', FieldNo("Due Date"));

            if JToken.SelectToken('taxPeriod', JToken) then begin
                ReadJsonValue(RecordRef, JToken, 'from', FieldNo("From Date"));
                ReadJsonValue(RecordRef, JToken, 'to', FieldNo("To Date"));
            end;
        end;
        RecordRef.SetTable(MTDLiability);
        exit(true);
    end;

    local procedure InsertLiability(TempMTDLiability: Record "MTD Liability" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDLiability: Record "MTD Liability";
    begin
        if not MTDLiability.GET(TempMTDLiability.RecordId()) then begin
            MTDLiability := TempMTDLiability;
            MTDLiability.Insert();
            NewCount += 1;
        end else
            if MTDLiability.DiffersFromLiability(TempMTDLiability) then begin
                MTDLiability := TempMTDLiability;
                MTDLiability.Modify();
                ModifiedCount += 1;
            end;
    end;

    local procedure ParsePayments(PaymentsJson: Text; StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempMTDPayment: Record "MTD Payment" temporary;
        JToken: JsonToken;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        TempMTDPayment."Entry No." := 0;
        TempMTDPayment."Start Date" := StartDate;
        TempMTDPayment."End Date" := EndDate;

        if JToken.ReadFrom(PaymentsJson) then
            if JToken.SelectToken('Content.payments', JToken) then begin
                if JToken.IsArray() then begin
                    TotalCount := JToken.AsArray().Count();
                    foreach JToken in JToken.AsArray() do
                        if ParsePayment(TempMTDPayment, JToken) then
                            InsertPayment(TempMTDPayment, NewCount, ModifiedCount);
                end;
                exit(true);
            end;
        exit(false);
    end;

    local procedure ParsePayment(var MTDPayment: Record "MTD Payment"; JToken: JsonToken): Boolean
    var
        RecordRef: RecordRef;
    begin
        with MTDPayment do begin
            "Entry No." += 1;
            "Received Date" := 0D;
            Amount := 0;
            RecordRef.GETTABLE(MTDPayment);
            ReadJsonValue(RecordRef, JToken, 'received', FieldNo("Received Date"));
            ReadJsonValue(RecordRef, JToken, 'amount', FieldNo(Amount));
        end;
        RecordRef.SetTable(MTDPayment);
        exit(true);
    end;

    local procedure InsertPayment(TempMTDPayment: Record "MTD Payment" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDPayment: Record "MTD Payment";
    begin
        if not MTDPayment.GET(TempMTDPayment.RecordId()) then begin
            MTDPayment := TempMTDPayment;
            MTDPayment.Insert();
            NewCount += 1;
        end else
            if MTDPayment.DiffersFromPayment(TempMTDPayment) then begin
                MTDPayment := TempMTDPayment;
                MTDPayment.Modify();
                ModifiedCount += 1;
            end;
    end;

    local procedure RetrieveRecordSummaryMessage(UpToDateMsg: Text; SuccessMsg: Text; ErrorMsg: Text; Result: Boolean; ShowMessage: Boolean; HttpError: Text; NewCount: Integer; ModifiedCount: Integer)
    var
        MessageString: Text;
    begin
        if Result then
            if NewCount + ModifiedCount = 0 then
                MessageString := UpToDateMsg
            else
                MessageString := StrSubstNo('%1,\%2', SuccessMsg, StrSubstNo(IncludingMsg, NewCount, ModifiedCount))
        else begin
            MessageString := ErrorMsg;
            if HttpError <> '' then
                MessageString += '\' + ReasonTxt + HttpError;
        end;

        LogActivity(Result, MessageString);
        Commit();

        if not ShowMessage then
            exit;

        if Result then
            Message(MessageString)
        else
            Error(MessageString);
    end;

    local procedure LogActivity(Result: Boolean; ActivityMessage: Text)
    var
        ActivityLog: Record "Activity Log";
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        OAuth20Setup.GET(MTDConnection.GetOAuthSetupCode());
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

    internal procedure ArchiveResponseMessage(VATReportHeader: Record "VAT Report Header"; MessageText: Text)
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        DummyGUID: Guid;
    begin
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(MessageText);
        VATReportArchive.ArchiveResponseMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob, DummyGUID);
    end;

    internal procedure CheckReturnPeriodLink(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        if not VATReturnPeriod.Get(VATReportHeader."Return Period No.") then
            Error(PeriodLinkErr);
    end;

    local procedure ReadJsonValue(RecordRef: RecordRef; JToken: JsonToken; KeyValue: Text; FieldNo: Integer) Result: Boolean
    var
        FieldRef: FieldRef;
        GuidValue: Guid;
    begin
        Result := JToken.SelectToken(KeyValue, JToken);
        if Result then begin
            FieldRef := RecordRef.Field(FieldNo);
            case FieldRef.Type() of
                FieldType::Integer:
                    FieldRef.Value(JToken.AsValue().AsInteger());
                FieldType::Decimal:
                    FieldRef.Value(JToken.AsValue().AsDecimal());
                FieldType::Date:
                    FieldRef.Value(JToken.AsValue().AsDate());
                FieldType::Time:
                    FieldRef.Value(JToken.AsValue().AsTime());
                FieldType::DateTime:
                    FieldRef.Value(JToken.AsValue().AsDateTime());
                FieldType::Boolean:
                    FieldRef.Value(JToken.AsValue().AsBoolean());
                FieldType::GUID:
                    begin
                        Result := Evaluate(GuidValue, JToken.AsValue().AsText());
                        FieldRef.Value(GuidValue);
                    end;
                FieldType::Text:
                    FieldRef.Value(CopyStr(JToken.AsValue().AsText(), 1, FieldRef.Length()));
                FieldType::Code:
                    FieldRef.Value(CopyStr(JToken.AsValue().AsCode(), 1, FieldRef.Length()));
            end;
        end;
    end;

    procedure GetVATReportSetupUpgradeTag(): Code[250];
    begin
        exit('MS-345859-GB-MTD-VATReportSetup-20200304');
    end;

    procedure GetDailyLimitUpgradeTag(): Code[250];
    begin
        exit('MS-332065-GB-MTD-DailyLimit-20200304');
    end;

    [EventSubscriber(ObjectType::Codeunit, 9999, 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetVATReportSetupUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDailyLimitUpgradeTag());
    end;
}
