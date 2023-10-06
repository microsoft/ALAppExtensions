namespace Microsoft.DataMigration.GP.HistoricalData;

codeunit 40902 "Hist. Migration Status Mgmt."
{
    local procedure GetDeleteBatchSize(): Integer
    begin
        exit(500000);
    end;

    procedure UpdateStepStatus(StepType: enum "Hist. Migration Step Type"; Completed: Boolean)
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
    begin
        HistMigrationStepStatus.SetRange(Step, StepType);
        HistMigrationStepStatus.SetRange(Completed, false);

        // Step status
        if not HistMigrationStepStatus.FindLast() then begin
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

    procedure SetStatusStarted()
    begin
        UpdateStepStatus("Hist. Migration Step Type"::Started, false);
    end;

    procedure SetStatusFinished()
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
        StartedDate: DateTime;
    begin
        // Status log
        HistMigrationStepStatus.SetRange(Step, "Hist. Migration Step Type"::Started);
        if HistMigrationStepStatus.FindLast() then begin
            StartedDate := HistMigrationStepStatus."Start Date";

            HistMigrationStepStatus.Completed := true;
            HistMigrationStepStatus."End Date" := System.CurrentDateTime();
            HistMigrationStepStatus.Modify();
        end else
            StartedDate := System.CurrentDateTime();

        Clear(HistMigrationStepStatus);
        HistMigrationStepStatus.Step := "Hist. Migration Step Type"::Finished;
        HistMigrationStepStatus."Start Date" := StartedDate;
        HistMigrationStepStatus."End Date" := System.CurrentDateTime();
        HistMigrationStepStatus.Completed := true;
        HistMigrationStepStatus.Insert();

        // Current status
        HistMigrationCurrentStatus.SetCurrentStep("Hist. Migration Step Type"::Finished);
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
        UpdateStepStatus("Hist. Migration Step Type"::"Resetting Data", false);

        if not HistPurchaseRecvLine.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Purchase Recv. Line", HistPurchaseRecvLine.FieldNo(HistPurchaseRecvLine."Primary Key"));

        if not HistPurchaseRecvHeader.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Purchase Recv. Header", HistPurchaseRecvHeader.FieldNo(HistPurchaseRecvHeader."Primary Key"));

        if not HistInventoryTrxLine.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Inventory Trx. Line", HistInventoryTrxLine.FieldNo(HistInventoryTrxLine."Primary Key"));

        if not HistInventoryTrxHeader.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Inventory Trx. Header", HistInventoryTrxHeader.FieldNo(HistInventoryTrxHeader."Primary Key"));

        if not HistPayablesDocument.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Payables Document", HistPayablesDocument.FieldNo(HistPayablesDocument."Primary Key"));

        if not HistReceivablesDocument.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Receivables Document", HistReceivablesDocument.FieldNo(HistReceivablesDocument."Primary Key"));

        if not HistSalesTrxLine.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Sales Trx. Line", HistSalesTrxLine.FieldNo(HistSalesTrxLine."Primary Key"));

        if not HistSalesTrxHeader.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Sales Trx. Header", HistSalesTrxHeader.FieldNo(HistSalesTrxHeader."Primary Key"));

        if not HistGenJournalLine.IsEmpty() then
            BatchDeleteAll(Database::"Hist. Gen. Journal Line", HistGenJournalLine.FieldNo(HistGenJournalLine."Primary Key"));

        if not HistGLAccount.IsEmpty() then
            BatchDeleteAll(Database::"Hist. G/L Account", HistGLAccount.FieldNo(HistGLAccount."Primary Key"));

        UpdateStepStatus("Hist. Migration Step Type"::"Resetting Data", true);

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
        DeleteBatchSize: integer;
        IsHandled: Boolean;
        OverrideBatchDeleteSize: Integer;
    begin
        DeleteBatchSize := GetDeleteBatchSize();

        OnBeforeBatchDeleteAll(IsHandled, OverrideBatchDeleteSize);
        if IsHandled then
            DeleteBatchSize := OverrideBatchDeleteSize;

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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBatchDeleteAll(var IsHandled: Boolean; var OverrideBatchDeleteSize: Integer)
    begin
    end;
}