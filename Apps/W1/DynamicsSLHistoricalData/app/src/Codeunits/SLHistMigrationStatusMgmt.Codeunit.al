// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

codeunit 42800 "SL Hist. Migration Status Mgmt"
{
    local procedure GetDeleteBatchSize(): Integer
    begin
        exit(500000);
    end;

    procedure UpdateStepStatus(StepType: enum "SL Hist. Migration Step Type"; Completed: Boolean)
    var
        SLHistMigrationStepStatus: Record "SL Hist. Migration Step Status";
        SLHistMigrationCurStatus: Record "SL Hist. Migration Cur. Status";
    begin
        SLHistMigrationStepStatus.SetRange(Step, StepType);
        SLHistMigrationStepStatus.SetRange(Completed, false);

        // Step status
        if not SLHistMigrationStepStatus.FindLast() then begin
            SLHistMigrationStepStatus.Step := StepType;
            SLHistMigrationStepStatus."Start Date" := System.CurrentDateTime();
            SLHistMigrationStepStatus.Insert();
        end;

        if Completed then begin
            SLHistMigrationStepStatus."End Date" := System.CurrentDateTime();
            SLHistMigrationStepStatus.Completed := true;
            SLHistMigrationStepStatus.Modify();
        end;

        // Current status
        if SLHistMigrationCurStatus.GetCurrentStep() <> StepType then
            SLHistMigrationCurStatus.SetCurrentStep(StepType);
    end;

    procedure SetStatusStarted()
    begin
        UpdateStepStatus("SL Hist. Migration Step Type"::Started, false);
    end;

    procedure SetStatusFinished()
    var
        SLHistMigrationStepStatus: Record "SL Hist. Migration Step Status";
        SLHistMigrationCurStatus: Record "SL Hist. Migration Cur. Status";
        StartedDate: DateTime;
    begin
        // Status log
        SLHistMigrationStepStatus.SetRange(Step, "SL Hist. Migration Step Type"::Started);
        if SLHistMigrationStepStatus.FindLast() then begin
            StartedDate := SLHistMigrationStepStatus."Start Date";

            SLHistMigrationStepStatus.Completed := true;
            SLHistMigrationStepStatus."End Date" := System.CurrentDateTime();
            SLHistMigrationStepStatus.Modify();
        end else
            StartedDate := System.CurrentDateTime();

        Clear(SLHistMigrationStepStatus);
        SLHistMigrationStepStatus.Step := "SL Hist. Migration Step Type"::Finished;
        SLHistMigrationStepStatus."Start Date" := StartedDate;
        SLHistMigrationStepStatus."End Date" := System.CurrentDateTime();
        SLHistMigrationStepStatus.Completed := true;
        SLHistMigrationStepStatus.Insert();

        // Current status
        SLHistMigrationCurStatus.SetCurrentStep("SL Hist. Migration Step Type"::Finished);
    end;

    procedure GetCurrentStatus(): enum "SL Hist. Migration Step Type";
    var
        HistMigrationCurStatus: Record "SL Hist. Migration Cur. Status";
    begin
        exit(HistMigrationCurStatus.GetCurrentStep());
    end;

    procedure ResetAll()
    var
        SLHistMigrationCurStatus: Record "SL Hist. Migration Cur. Status";
        SLHistAPAdjust: Record "SL Hist. APAdjust";
        SLHistAPDoc: Record "SL Hist. APDoc";
        SLHistAPTran: Record "SL Hist. APTran";
        SLHistARAdjust: Record "SL Hist. ARAdjust";
        SLHistARDoc: Record "SL Hist. ARDoc";
        SLHistARTran: Record "SL Hist. ARTran";
        SLHistBatch: Record "SL Hist. Batch";
        SLHistGLTran: Record "SL Hist. GLTran";
        SLHistINTran: Record "SL Hist. INTran";
        SLHistLotSerT: Record "SL Hist. LotSerT";
        SLHistPOReceipt: Record "SL Hist. POReceipt";
        SLHistPOTran: Record "SL Hist. POTran";
        SLHistPurchOrd: Record "SL Hist. PurchOrd";
        SLHistPurOrdDet: Record "SL Hist. PurOrdDet";
        SLHistSOHeader: Record "SL Hist. SOHeader";
        SLHistSOLine: Record "SL Hist. SOLine";
        SLHistSOShipHeader: Record "SL Hist. SOShipHeader";
        SLHistSOShipLine: Record "SL Hist. SOShipLine";
        SLHistSOShipLot: Record "SL Hist. SOSHipLot";
        SLHistSOType: Record "SL Hist. SOType";
    begin
        UpdateStepStatus("SL Hist. Migration Step Type"::"Resetting Data", false);

        if not SLHistSOType.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. SOType", SLHistSOType.FieldNo(SLHistSOType.CpnyID));

        if not SLHistSOShipLot.IsEmpty then
            BatchDeleteAll(Database::"SL Hist. SOShipLot", SLHistSOShipLot.FieldNo(SLHistSOShipLot.CpnyID));

        if not SLHistSOShipLine.IsEmpty then
            BatchDeleteAll(Database::"SL Hist. SOShipLine", SLHistSOShipLine.FieldNo(SLHistSOShipLine.CpnyID));

        if not SLHistSOShipHeader.IsEmpty then
            BatchDeleteAll(Database::"SL Hist. SOShipHeader", SLHistSOShipHeader.FieldNo(SLHistSOShipHeader.CpnyID));

        if not SLHistSOLine.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. SOLine", SLHistSOLine.FieldNo(SLHistSOLine.CpnyID));

        if not SLHistSOHeader.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. SOHeader", SLHistSOHeader.FieldNo(SLHistSOHeader.CpnyID));

        if not SLHistPurOrdDet.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. PurOrdDet", SLHistPurOrdDet.FieldNo(SLHistPurOrdDet.CpnyID));

        if not SLHistPurchOrd.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. PurchOrd", SLHistPurchOrd.FieldNo(SLHistPurchOrd.CpnyID));

        if not SLHistPOTran.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. POTran", SLHistPOTran.FieldNo(SLHistPOTran.RcptNbr));

        if not SLHistPOReceipt.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. POReceipt", SLHistPOReceipt.FieldNo(SLHistPOReceipt.RcptNbr));

        if not SLHistLotSerT.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. LotSerT", SLHistLotSerT.FieldNo(SLHistLotSerT.LotSerNbr));

        if not SLHistINTran.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. INTran", SLHistINTran.FieldNo(SLHistINTran.InvtID));

        if not SLHistGLTran.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. GLTran", SLHistGLTran.FieldNo(SLHistGLTran.Module));

        if not SLHistBatch.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. Batch", SLHistBatch.FieldNo(SLHistBatch.Module));

        if not SLHistARTran.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. ARTran", SLHistARTran.FieldNo(SLHistARTran.CustId));

        if not SLHistARDoc.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. ARDoc", SLHistARDoc.FieldNo(SLHistARDoc.CustId));

        if not SLHistARAdjust.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. ARAdjust", SLHistARAdjust.FieldNo(SLHistARAdjust.AdjdRefNbr));

        if not SLHistAPTran.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. APTran", SLHistAPTran.FieldNo(SLHistAPTran.BatNbr));

        if not SLHistAPDoc.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. APDoc", SLHistAPDoc.FieldNo(SLHistAPDoc.Acct));

        if not SLHistAPAdjust.IsEmpty() then
            BatchDeleteAll(Database::"SL Hist. APAdjust", SLHistAPAdjust.FieldNo(SLHistAPAdjust.AdjdRefNbr));

        UpdateStepStatus("SL Hist. Migration Step Type"::"Resetting Data", true);

        SLHistMigrationCurStatus.DeleteAll();
        SLHistMigrationCurStatus.EnsureInit();
    end;

    procedure BatchDeleteAll(TableId: Integer; KeyFieldId: Integer)
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