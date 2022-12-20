codeunit 40902 "Hist. Migration Status Mgmt."
{
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
        if not HistMigrationCurrentStatus.Get() then begin
            HistMigrationCurrentStatus."Current Step" := StepType;
            HistMigrationCurrentStatus.Insert();
        end;

        if HistMigrationCurrentStatus."Current Step" <> StepType then begin
            HistMigrationCurrentStatus."Current Step" := StepType;
            HistMigrationCurrentStatus.Modify();
        end;
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
        HistMigrationCurrentStatus.Get();
        HistMigrationCurrentStatus."Current Step" := "Hist. Migration Step Type"::Finished;
        HistMigrationCurrentStatus.Modify();
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
        if not HistMigrationCurrentStatus.Get() then begin
            HistMigrationCurrentStatus."Current Step" := "Hist. Migration Step Type"::"Not Started";
            HistMigrationCurrentStatus.Insert();
        end;

        exit(HistMigrationCurrentStatus."Current Step");
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
        HistPurchaseRecvLine.DeleteAll();
        HistPurchaseRecvHeader.DeleteAll();
        HistInventoryTrxLine.DeleteAll();
        HistInventoryTrxHeader.DeleteAll();
        HistPayablesDocument.DeleteAll();
        HistReceivablesDocument.DeleteAll();
        HistSalesTrxLine.DeleteAll();
        HistSalesTrxHeader.DeleteAll();
        HistGenJournalLine.DeleteAll();
        HistGLAccount.DeleteAll();
        HistMigrationStepError.DeleteAll();
        HistMigrationStepStatus.DeleteAll();
        HistMigrationCurrentStatus.DeleteAll();
    end;
}