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
        ReasonTxt: Label 'Reason: ';
        NoSubmittedReturnsMsg: Label 'The remote endpoint has indicated that there is no submitted VAT returns for the specified period.';

    [EventSubscriber(ObjectType::Page, Page::"VAT Report", 'OnAfterInitPageControllers', '', true, true)]
    local procedure OnAfterInitVATReportPageControllers(VATReportHeader: Record "VAT Report Header"; var SubmitControllerStatus: Boolean; var MarkAsSubmitControllerStatus: Boolean)
    begin
        if VATReportHeader."Return Period No." = '' then
            exit;

        SubmitControllerStatus := VATReportHeader.Status = VATReportHeader.Status::Released;
        MarkAsSubmitControllerStatus := FALSE;
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

    procedure SubmitVATReturn(var RequestJson: Text; var ResponseJson: Text) Result: Boolean
    var
        HttpError: Text;
        ErrorMsg: Text;
    begin
        Result := MTDConnection.InvokeRequest_SubmitVATReturn(ResponseJson, RequestJson, HttpError);

        if not Result then begin
            ErrorMsg := SubmitReturnErr;
            if HttpError <> '' then
                ErrorMsg += '\' + ReasonTxt + HttpError;
            LogActivity(Result, ErrorMsg);
            Commit();
            Error(ErrorMsg);
        end;
    end;

    procedure RetrieveVATReturns(VATReturnPeriod: Record "VAT Return Period"; var ResponseJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        HttpError: Text;
    begin
        IF MTDConnection.InvokeRequest_RetrieveVATReturns(VATReturnPeriod."Period Key", ResponseJson, ShowMessage, HttpError) THEN
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

    procedure RetrieveVATReturnPeriods(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean; OpenOAuthSetup: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        IF MTDConnection.InvokeRequest_RetrieveVATReturnPeriods(StartDate, EndDate, ResponseJson, HttpError, OpenOAuthSetup) THEN
            Result := ParseObligations(ResponseJson, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrievePeriodsUpToDateMsg, RetrievePeriodsMsg, RetrievePeriodsErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    procedure RetrieveLiabilities(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        IF MTDConnection.InvokeRequest_RetrieveLiabilities(StartDate, EndDate, ResponseJson, HttpError) THEN
            Result := ParseLiabilities(ResponseJson, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrieveLiabilitiesUpToDateMsg, RetrieveLiabilitiesMsg, RetrieveLiabilitiesErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    procedure RetrievePayments(StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer; ShowMessage: Boolean) Result: Boolean
    var
        ResponseJson: Text;
        HttpError: Text;
    begin
        IF MTDConnection.InvokeRequest_RetrievePayments(StartDate, EndDate, ResponseJson, HttpError) THEN
            Result := ParsePayments(ResponseJson, StartDate, EndDate, TotalCount, NewCount, ModifiedCount);
        RetrieveRecordSummaryMessage(
            RetrievePaymentsUpToDateMsg, RetrievePaymentsMsg, RetrievePaymentsErr,
            Result, ShowMessage, HttpError, NewCount, ModifiedCount);
    end;

    local procedure ParseObligations(ResponseJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempVATReturnPeriod: Record "VAT Return Period" temporary;
        JSONMgt: Codeunit "JSON Management";
        i: Integer;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        IF NOT JSONMgt.InitializeFromString(ResponseJson) THEN
            EXIT(FALSE);

        IF NOT JSONMgt.SelectTokenFromRoot('Content.obligations') THEN
            EXIT(FALSE);

        TotalCount := JSONMgt.GetCount();
        FOR i := 0 TO TotalCount - 1 DO
            IF JSONMgt.SelectItemFromRoot('Content.obligations', i) THEN
                IF ParseObligation(TempVATReturnPeriod, JSONMgt.WriteObjectToString()) THEN
                    InsertObligation(TempVATReturnPeriod, NewCount, ModifiedCount);

        EXIT(TRUE);
    end;

    local procedure ParseObligation(var VATReturnPeriod: Record "VAT Return Period"; Json: Text): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        IF NOT JSONMgt.InitializeFromString(Json) THEN
            EXIT(FALSE);

        WITH VATReturnPeriod DO BEGIN
            CLEAR(VATReturnPeriod);
            RecordRef.GETTABLE(VATReturnPeriod);
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'start', FIELDNO("Start Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'end', FIELDNO("End Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'due', FIELDNO("Due Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'periodKey', FIELDNO("Period Key"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'received', FIELDNO("Received Date"));
            RecordRef.SETTABLE(VATReturnPeriod);
            case JSONMgt.GetValue('status') of
                'O':
                    Status := Status::Open;
                'F':
                    Status := Status::Closed;
            end;
        END;

        EXIT(TRUE);
    end;

    local procedure InsertObligation(TempVATReturnPeriod: Record "VAT Return Period" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        IF NOT VATReturnPeriod.FindVATReturnPeriod(VATReturnPeriod, TempVATReturnPeriod."Start Date", TempVATReturnPeriod."End Date") THEN BEGIN
            VATReturnPeriod := TempVATReturnPeriod;
            VATReturnPeriod.Insert(true);
            NewCount += 1;
        END ELSE
            IF VATReturnPeriod.DiffersFromVATReturnPeriod(TempVATReturnPeriod) THEN BEGIN
                if (VATReturnPeriod.Status = VATReturnPeriod.Status::Open) and
                   (TempVATReturnPeriod.Status = TempVATReturnPeriod.Status::Closed)
                then
                    MarkAcceptedVATReturnAsClosed(VATReturnPeriod."VAT Return No.");
                CopyFromObligation(VATReturnPeriod, TempVATReturnPeriod);
                VATReturnPeriod.Modify();
                ModifiedCount += 1;
            END;
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
        JSONMgt: Codeunit "JSON Management";
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        IF NOT JSONMgt.InitializeFromString(ResponseJson) THEN
            EXIT(FALSE);

        IF NOT JSONMgt.SelectTokenFromRoot('Content') THEN
            EXIT(FALSE);

        TotalCount := 1;
        TempMTDReturnDetails."Start Date" := VATReturnPeriod."Start Date";
        TempMTDReturnDetails."End Date" := VATReturnPeriod."End Date";
        TempMTDReturnDetails.Finalised := true;
        IF ParseVATReturn(TempMTDReturnDetails, JSONMgt.WriteObjectToString()) THEN
            InsertVATReturn(TempMTDReturnDetails, NewCount, ModifiedCount);

        EXIT(TRUE);
    end;

    local procedure ParseVATReturn(var MTDReturnDetails: Record "MTD Return Details"; Json: Text): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        IF NOT JSONMgt.InitializeFromString(Json) THEN
            EXIT(FALSE);

        RecordRef.GETTABLE(MTDReturnDetails);
        WITH MTDReturnDetails DO BEGIN
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'periodKey', FIELDNO("Period Key"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatDueSales', FIELDNO("VAT Due Sales"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatDueAcquisitions', FIELDNO("VAT Due Acquisitions"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalVatDue', FIELDNO("Total VAT Due"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatReclaimedCurrPeriod', FIELDNO("VAT Reclaimed Curr Period"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'netVatDue', FIELDNO("Net VAT Due"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValueSalesExVAT', FIELDNO("Total Value Sales Excl. VAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValuePurchasesExVAT', FIELDNO("Total Value Purchases Excl.VAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValueGoodsSuppliedExVAT', FIELDNO("Total Value Goods Suppl. ExVAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalAcquisitionsExVAT', FIELDNO("Total Acquisitions Excl. VAT"));
        END;
        RecordRef.SETTABLE(MTDReturnDetails);

        EXIT(TRUE);
    end;

    local procedure InsertVATReturn(TempMTDReturnDetails: Record "MTD Return Details" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDReturnDetails: Record "MTD Return Details";
    begin
        IF NOT MTDReturnDetails.GET(TempMTDReturnDetails.RecordId()) THEN BEGIN
            MTDReturnDetails := TempMTDReturnDetails;
            MTDReturnDetails.Insert();
            NewCount += 1;
        END ELSE
            IF MTDReturnDetails.DiffersFromReturn(TempMTDReturnDetails) THEN BEGIN
                MTDReturnDetails := TempMTDReturnDetails;
                MTDReturnDetails.Modify();
                ModifiedCount += 1;
            END;
    end;

    local procedure ParseLiabilities(LiabilitiesJson: Text; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempMTDLiability: Record "MTD Liability" temporary;
        JSONMgt: Codeunit "JSON Management";
        i: Integer;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        IF NOT JSONMgt.InitializeFromString(LiabilitiesJson) THEN
            EXIT(FALSE);

        IF NOT JSONMgt.SelectTokenFromRoot('Content.liabilities') THEN
            EXIT(FALSE);

        TotalCount := JSONMgt.GetCount();
        FOR i := 0 TO TotalCount - 1 DO
            IF JSONMgt.SelectItemFromRoot('Content.liabilities', i) THEN
                IF ParseLiability(TempMTDLiability, JSONMgt.WriteObjectToString()) THEN
                    InsertLiability(TempMTDLiability, NewCount, ModifiedCount);

        EXIT(TRUE);
    end;

    local procedure ParseLiability(var MTDLiability: Record "MTD Liability"; Json: Text): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        IF NOT JSONMgt.InitializeFromString(Json) THEN
            EXIT(FALSE);

        RecordRef.GETTABLE(MTDLiability);
        WITH MTDLiability DO BEGIN
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'taxPeriod.from', FIELDNO("From Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'taxPeriod.to', FIELDNO("To Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'type', FIELDNO(Type));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'originalAmount', FIELDNO("Original Amount"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'outstandingAmount', FIELDNO("Outstanding Amount"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'due', FIELDNO("Due Date"));
        END;
        RecordRef.SETTABLE(MTDLiability);

        EXIT(TRUE);
    end;

    local procedure InsertLiability(TempMTDLiability: Record "MTD Liability" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDLiability: Record "MTD Liability";
    begin
        IF NOT MTDLiability.GET(TempMTDLiability.RecordId()) THEN BEGIN
            MTDLiability := TempMTDLiability;
            MTDLiability.Insert();
            NewCount += 1;
        END ELSE
            IF MTDLiability.DiffersFromLiability(TempMTDLiability) THEN BEGIN
                MTDLiability := TempMTDLiability;
                MTDLiability.Modify();
                ModifiedCount += 1;
            END;
    end;

    local procedure ParsePayments(PaymentsJson: Text; StartDate: Date; EndDate: Date; var TotalCount: Integer; var NewCount: Integer; var ModifiedCount: Integer): Boolean
    var
        TempMTDPayment: Record "MTD Payment" temporary;
        JSONMgt: Codeunit "JSON Management";
        i: Integer;
    begin
        TotalCount := 0;
        NewCount := 0;
        ModifiedCount := 0;

        IF NOT JSONMgt.InitializeFromString(PaymentsJson) THEN
            EXIT(FALSE);

        IF NOT JSONMgt.SelectTokenFromRoot('Content.payments') THEN
            EXIT(FALSE);

        TotalCount := JSONMgt.GetCount();
        TempMTDPayment."Entry No." := 0;
        TempMTDPayment."Start Date" := StartDate;
        TempMTDPayment."End Date" := EndDate;
        FOR i := 0 TO TotalCount - 1 DO
            IF JSONMgt.SelectItemFromRoot('Content.payments', i) THEN
                IF ParsePayment(TempMTDPayment, JSONMgt.WriteObjectToString()) THEN
                    InsertPayment(TempMTDPayment, NewCount, ModifiedCount);

        EXIT(TRUE);
    end;

    local procedure ParsePayment(var MTDPayment: Record "MTD Payment"; Json: Text): Boolean
    var
        JSONMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        IF NOT JSONMgt.InitializeFromString(Json) THEN
            EXIT(FALSE);

        WITH MTDPayment DO BEGIN
            "Entry No." += 1;
            "Received Date" := 0D;
            Amount := 0;
            RecordRef.GETTABLE(MTDPayment);
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'received', FIELDNO("Received Date"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'amount', FIELDNO(Amount));
        END;
        RecordRef.SETTABLE(MTDPayment);

        EXIT(TRUE);
    end;

    local procedure InsertPayment(TempMTDPayment: Record "MTD Payment" temporary; var NewCount: Integer; var ModifiedCount: Integer)
    var
        MTDPayment: Record "MTD Payment";
    begin
        IF NOT MTDPayment.GET(TempMTDPayment.RecordId()) THEN BEGIN
            MTDPayment := TempMTDPayment;
            MTDPayment.Insert();
            NewCount += 1;
        END ELSE
            IF MTDPayment.DiffersFromPayment(TempMTDPayment) THEN BEGIN
                MTDPayment := TempMTDPayment;
                MTDPayment.Modify();
                ModifiedCount += 1;
            END;
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

    procedure ArchiveResponseMessage(VATReportHeader: Record "VAT Report Header"; MessageText: Text)
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        DummyGUID: Guid;
    begin
        CLEAR(TempBlob.Blob);
        TempBlob.WriteAsText(MessageText, TEXTENCODING::UTF8);
        VATReportArchive.ArchiveResponseMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob, DummyGUID);
    end;
}
