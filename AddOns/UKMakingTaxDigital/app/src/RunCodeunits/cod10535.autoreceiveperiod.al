// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10535 "MTD Auto Receive Period"
{
    trigger OnRun()
    begin
        ExecuteJob();
    end;

    var
        TraceCategoryLbl: Label 'Auto update of VAT return period job.', Locked = true;
        TraceExecuteMessageLbl: Label 'A job for an auto update of VAT return period has been executed: total = %1, new = %2, modified = %3.', Locked = true;

    local procedure ExecuteJob()
    var
        MTDMgt: Codeunit "MTD Mgt.";
        StartDate: Date;
        EndDate: Date;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        // Get VAT Return periods for current workdate year
        StartDate := CalcDate('<-CY>', WorkDate());
        EndDate := CalcDate('<CY>', WorkDate());
        if MTDMgt.RetrieveVATReturnPeriods(StartDate, EndDate, TotalCount, NewCount, ModifiedCount, true, false) then
            SendTraceTag(
              '00008WO', TraceCategoryLbl, VERBOSITY::Normal,
              STRSUBSTNO(TraceExecuteMessageLbl, TotalCount, NewCount, ModifiedCount), DataClassification::SystemMetadata);

        // Get VAT Return periods for next year
        StartDate := CalcDate('<1Y>', StartDate);
        EndDate := CalcDate('<1Y>', EndDate);
        if MTDMgt.RetrieveVATReturnPeriods(StartDate, EndDate, TotalCount, NewCount, ModifiedCount, true, false) then
            SendTraceTag(
              '00008WP', TraceCategoryLbl, VERBOSITY::Normal,
              STRSUBSTNO(TraceExecuteMessageLbl, TotalCount, NewCount, ModifiedCount), DataClassification::SystemMetadata);
    end;
}
