codeunit 40902 "Hist. Migration Status Mgmt."
{
    var
        DeleteBatchSize: integer;

    trigger OnRun()
    begin
        DeleteBatchSize := 500000;
    end;

    procedure PrepareHistoryMigration()
    var
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
    begin
        if HistMigrationCurrentStatus.GetDeleteAllOnNextRun() then
            ResetAll();
    end;

    procedure UpdateStepStatus(StepType: enum "Hist. Migration Step Type"; Completed: Boolean)
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
    begin
        HistMigrationStepStatus.SetRange(Step, StepType);

        // Step status
        if not HistMigrationStepStatus.FindFirst() then begin
            HistMigrationStepStatus.Step := StepType;
            HistMigrationStepStatus."Start Date" := System.CurrentDateTime();
            HistMigrationStepStatus.Insert();
        end;

        if Completed then begin
            HistMigrationStepStatus."End Date" := System.CurrentDateTime();
            HistMigrationStepStatus.Completed := true;
            HistMigrationStepStatus.Modify();
        end;

        // Current status
        if HistMigrationCurrentStatus.GetCurrentStep() <> StepType then
            HistMigrationCurrentStatus.SetCurrentStep(StepType);
    end;

    procedure SetStatusFinished()
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
        StartedDate: DateTime;
    begin
        // Step status
        if HistMigrationStepStatus.FindFirst() then
            StartedDate := HistMigrationStepStatus."Start Date";

        Clear(HistMigrationStepStatus);
        HistMigrationStepStatus.Step := "Hist. Migration Step Type"::Finished;
        HistMigrationStepStatus."Start Date" := StartedDate;
        HistMigrationStepStatus."End Date" := System.CurrentDateTime();
        HistMigrationStepStatus.Completed := true;
        HistMigrationStepStatus.Insert();

        // Current status
        HistMigrationCurrentStatus.SetCurrentStep("Hist. Migration Step Type"::Finished);
    end;

    procedure ReportLastError(Step: enum "Hist. Migration Step Type"; Reference: Text[150]; ShouldClearLastError: Boolean)
    var
        HistMigrationStepError: Record "Hist. Migration Step Error";
    begin
        HistMigrationStepError.Step := Step;
        HistMigrationStepError.Reference := Reference;
        HistMigrationStepError."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(HistMigrationStepError."Error Code"));
        HistMigrationStepError."Error Date" := System.CurrentDateTime();
        HistMigrationStepError.SetErrorMessage(GetLastErrorCallStack());
        HistMigrationStepError.Insert();

        if ShouldClearLastError then
            ClearLastError();
    end;

    procedure HasNotRanStep(Step: enum "Hist. Migration Step Type"): Boolean
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
    begin
        HistMigrationStepStatus.SetRange("Step", Step);
        exit(HistMigrationStepStatus.IsEmpty());
    end;

    procedure GetCurrentStatus(): enum "Hist. Migration Step Type";
    var
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
    begin
        exit(HistMigrationCurrentStatus.GetCurrentStep());
    end;

    procedure ResetAll()
    var
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationStepError: Record "Hist. Migration Step Error";
        HistGLAccount: Record "Hist. G/L Account";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        HistSalesTrxLine: Record "Hist. Sales Trx. Line";
        HistReceivablesDocument: Record "Hist. Receivables Document";
        HistPayablesDocument: Record "Hist. Payables Document";
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        HistInventoryTrxLine: Record "Hist. Inventory Trx. Line";
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
        HistPurchaseRecvLine: Record "Hist. Purchase Recv. Line";
    begin
        BatchDeleteAll(Database::"Hist. Purchase Recv. Line", HistPurchaseRecvLine.FieldNo(HistPurchaseRecvLine."Primary Key"));
        BatchDeleteAll(Database::"Hist. Purchase Recv. Header", HistPurchaseRecvHeader.FieldNo(HistPurchaseRecvHeader."Primary Key"));
        BatchDeleteAll(Database::"Hist. Inventory Trx. Line", HistInventoryTrxLine.FieldNo(HistInventoryTrxLine."Primary Key"));
        BatchDeleteAll(Database::"Hist. Inventory Trx. Header", HistInventoryTrxHeader.FieldNo(HistInventoryTrxHeader."Primary Key"));
        BatchDeleteAll(Database::"Hist. Payables Document", HistPayablesDocument.FieldNo(HistPayablesDocument."Primary Key"));
        BatchDeleteAll(Database::"Hist. Receivables Document", HistReceivablesDocument.FieldNo(HistReceivablesDocument."Primary Key"));
        BatchDeleteAll(Database::"Hist. Sales Trx. Line", HistSalesTrxLine.FieldNo(HistSalesTrxLine."Primary Key"));
        BatchDeleteAll(Database::"Hist. Sales Trx. Header", HistSalesTrxHeader.FieldNo(HistSalesTrxHeader."Primary Key"));
        BatchDeleteAll(Database::"Hist. Gen. Journal Line", HistGenJournalLine.FieldNo(HistGenJournalLine."Primary Key"));
        BatchDeleteAll(Database::"Hist. G/L Account", HistGLAccount.FieldNo(HistGLAccount."Primary Key"));
        BatchDeleteAll(Database::"Hist. Migration Step Error", HistMigrationStepError.FieldNo(HistMigrationStepError."Primary Key"));

        HistMigrationStepStatus.DeleteAll();
        HistMigrationCurrentStatus.DeleteAll();
        HistMigrationCurrentStatus.EnsureInit();
    end;

    local procedure BatchDeleteAll(TableId: Integer; KeyFieldId: Integer)
    var
        TableRecordRef: RecordRef;
        EntryNoFieldRef: FieldRef;
        RangeStart: Integer;
        RangeEnd: Integer;
        StartingRecordCount: Integer;
    begin
        TableRecordRef.Open(TableId);
        StartingRecordCount := TableRecordRef.Count();
        EntryNoFieldRef := TableRecordRef.Field(KeyFieldId);

        RangeStart := 1;
        RangeEnd := DeleteBatchSize;
        while RangeStart < StartingRecordCount do begin
            EntryNoFieldRef.SetRange(RangeStart, RangeEnd);
            TableRecordRef.DeleteAll();
            Commit();

            RangeStart := RangeStart + DeleteBatchSize;
            RangeEnd := RangeEnd + DeleteBatchSize;
        end;
    end;
}