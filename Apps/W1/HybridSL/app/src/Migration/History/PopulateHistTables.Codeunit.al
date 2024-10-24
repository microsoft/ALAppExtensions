// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using MSFT.DataMigration.SL.HistoricalData;

codeunit 42025 SLPopulateHistTables
{
    Access = Internal;

    trigger OnRun()
    begin
        PopulateAllHistoryTables();
    end;

    internal procedure PopulateAllHistoryTables()
    var
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
        SLHistSOType: Record "SL Hist. SOType";
        SLAPAdjust: Record "SL APAdjust";
        SLAPDoc: Record "SL APDoc";
        SLAPTran: Record "SL APTran";
        SLARAdjust: Record "SL ARAdjust";
        SLARDoc: Record "SL ARDoc";
        SLARTran: Record "SL ARTran";
        SLBatch: Record "SL Batch";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLGLTran: Record "SL GLTran";
        SLINTran: Record "SL INTran";
        SLLotSerT: Record "SL LotSerT";
        SLPOReceipt: Record "SL POReceipt";
        SLPOTran: Record "SL POTran";
        SLPurchOrd: Record "SL PurchOrd";
        SLPurOrdDet: Record "SL PurOrdDet";
        SLSOHeader: Record "SL SOHeader";
        SLSOLine: Record "SL SOLine";
        SLSOShipHeader: Record "SL SOShipHeader";
        SLSOShipLine: Record "SL SOShipLine";
        SLSOType: Record "SL SOType";
        DateTimeVar: DateTime;
        Day: Integer;
        InitialHistYear: Integer;
        Month: Integer;
        TheTime: Time;
        HistVariant: Variant;
        SourceVariant: Variant;

    begin
        if not SLCompanyAdditionalSettings.GetMigrateHistory() then
            exit;
        DeleteAllHistoryTables();
        InitialHistYear := SLCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then begin
            Day := 01;
            Month := 01;
            TheTime := 0T;
            DateTimeVar := CreateDateTime(DMY2Date(Day, Month, InitialHistYear), TheTime);
        end;

        if SLCompanyAdditionalSettings.GetMigrateHistAPTrx() then begin
            SLAPDoc.Reset();
            SLAPAdjust.Reset();
            SLAPTran.Reset();
            SLAPDoc.SetFilter(CpnyID, '= %1', CompanyName);
            SLAPTran.SetFilter(CpnyID, '= %1', CompanyName);
            if InitialHistYear > 0 then begin
                SLAPDoc.SetFilter(DocDate, '>= %1', DateTimeVar);
                SLAPAdjust.SetFilter(AdjgDocDate, '>= %1', DateTimeVar);
                SLAPTran.SetFilter(TranDate, '>= %1', DateTimeVar);
            end;
            SourceVariant := SLAPDoc;
            HistVariant := SLHistAPDoc;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLAPTran;
            HistVariant := SLHistAPTran;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLAPAdjust;
            HistVariant := SLHistAPAdjust;
            PopulateHistoryTable(SourceVariant, HistVariant);
        end;

        if SLCompanyAdditionalSettings.GetMigrateHistARTrx() then begin
            SLARDoc.Reset();
            SLARAdjust.Reset();
            SLARTran.Reset();
            SLSOHeader.Reset();
            SLSOLine.Reset();
            SLSOShipHeader.Reset();
            SLSOShipLine.Reset();
            SLSOType.Reset();
            SLARDoc.SetFilter(CpnyID, '= %1', CompanyName);
            SLARTran.SetFilter(CpnyID, '= %1', CompanyName);
            SLSOHeader.SetFilter(CpnyID, '= %1', CompanyName);
            SLSOLine.SetFilter(CpnyID, '= %1', CompanyName);
            SLSOShipHeader.SetFilter(CpnyID, '= %1', CompanyName);
            SLSOShipLine.SetFilter(CpnyID, '= %1', CompanyName);
            SLSOType.SetFilter(CpnyID, '= %1', CompanyName);
            if InitialHistYear > 0 then begin
                SLARDoc.SetFilter(DocDate, '>= %1', DateTimeVar);
                SLARAdjust.SetFilter(AdjgDocDate, '>= %1', DateTimeVar);
                SLARTran.SetFilter(TranDate, '>= %1', DateTimeVar);
                SLSOHeader.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
                SLSOLine.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
                SLSOShipHeader.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
                SLSOShipHeader.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
            end;
            SourceVariant := SLARAdjust;
            HistVariant := SLHistARAdjust;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLARDoc;
            HistVariant := SLHistARDoc;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLARTran;
            HistVariant := SLHistARTran;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLSOHeader;
            HistVariant := SLHistSOHeader;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLSOLine;
            HistVariant := SLHistSOLine;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLSOShipHeader;
            HistVariant := SLHistSOShipHeader;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLSOShipLine;
            HistVariant := SLHistSOShipLine;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLSOType;
            HistVariant := SLHistSOType;
            PopulateHistoryTable(SourceVariant, HistVariant);
        end;

        if SLCompanyAdditionalSettings.GetMigrateHistGLTrx() then begin
            SLBatch.Reset();
            SLGLTran.Reset();
            SLBatch.SetFilter(CpnyID, '= %1', CompanyName);
            SLGLTran.SetFilter(CpnyID, '= %1', CompanyName);
            if InitialHistYear > 0 then begin
                SLBatch.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
                SLGLTran.SetFilter(TranDate, '>= %1', DateTimeVar);
            end;
            SourceVariant := SLBatch;
            HistVariant := SLHistBatch;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLGLTran;
            HistVariant := SLHistGLTran;
            PopulateHistoryTable(SourceVariant, HistVariant);
        end;

        if SLCompanyAdditionalSettings.GetMigrateHistInvTrx() then begin
            SLINTran.Reset();
            SLLotSerT.Reset();
            SLINTran.SetFilter(CpnyID, '= %1', CompanyName);
            SLLotSerT.SetFilter(CpnyID, '= %1', CompanyName);
            if InitialHistYear > 0 then begin
                SLINTran.SetFilter(TranDate, '>= %1', DateTimeVar);
                SLLotSerT.SetFilter(TranDate, '>= %1', DateTimeVar);
            end;
            SourceVariant := SLINTran;
            HistVariant := SLHistINTran;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLLotSerT;
            HistVariant := SLHistLotSerT;
            PopulateHistoryTable(SourceVariant, HistVariant);
        end;

        if SLCompanyAdditionalSettings.GetMigrateHistPurchTrx() then begin
            SLPOReceipt.Reset();
            SLPOTran.Reset();
            SLPurchOrd.Reset();
            SLPurOrdDet.Reset();
            SLPOReceipt.SetFilter(CpnyID, '= %1', CompanyName);
            SLPOTran.SetFilter(CpnyID, '= %1', CompanyName);
            SLPurchOrd.SetFilter(CpnyID, '= %1', CompanyName);
            SLPurOrdDet.SetFilter(CpnyID, '= %1', CompanyName);
            if InitialHistYear > 0 then begin
                SLPOReceipt.SetFilter(RcptDate, '>= %1', DateTimeVar);
                SLPOTran.SetFilter(RcptDate, '>= %1', DateTimeVar);
                SLPurchOrd.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
                SLPurOrdDet.SetFilter(Crtd_DateTime, '>= %1', DateTimeVar);
            end;
            SourceVariant := SLPOReceipt;
            HistVariant := SLHistPOReceipt;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLPOTran;
            HistVariant := SLHistPOTran;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLPurchOrd;
            HistVariant := SLHistPurchOrd;
            PopulateHistoryTable(SourceVariant, HistVariant);
            SourceVariant := SLPurOrdDet;
            HistVariant := SLHistPurOrdDet;
            PopulateHistoryTable(SourceVariant, HistVariant);
        end;
    end;

    internal procedure PopulateHistoryTable(var SourceRecordVariant: Variant; var TargetRecordVariant: Variant)
    var
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
        I: Integer;

    begin
        SourceRecordRef.GetTable(SourceRecordVariant);
        TargetRecordRef.GetTable(TargetRecordVariant);
        TargetRecordRef.Reset();
        I := 1;
        if SourceRecordRef.FindSet() then
            repeat
                for I := 1 to SourceRecordRef.FieldCount() do
                    if SourceRecordRef.FieldExist(i) then begin
                        SourceFieldRef := SourceRecordRef.Field(i);
                        TargetFieldRef := TargetRecordRef.Field(i);
                        TargetFieldRef.Value := SourceFieldRef.Value;
                    end;
                TargetRecordRef.Insert();
                Commit();
            until SourceRecordRef.Next() = 0;

        TargetRecordRef.SetTable(TargetRecordVariant);
    end;

    internal procedure DeleteAllHistoryTables()
    var
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
        SLHistSOType: Record "SL Hist. SOType";
    begin
        SLHistAPDoc.DeleteAll();
        SLHistAPAdjust.DeleteAll();
        SLHistAPTran.DeleteAll();
        SLHistARAdjust.DeleteAll();
        SLHistARDoc.DeleteAll();
        SLHistARTran.DeleteAll();
        SLHistBatch.DeleteAll();
        SLHistPOReceipt.DeleteAll();
        SLHistPOTran.DeleteAll();
        SLHistPurchOrd.DeleteAll();
        SLHistPurOrdDet.DeleteAll();
        SLHistINTran.DeleteAll();
        SLHistLotSerT.DeleteAll();
        SLHistGLTran.DeleteAll();
        SLHistSOHeader.DeleteAll();
        SLHistSOLine.DeleteAll();
        SLHistSOShipHeader.DeleteAll();
        SLHistSOShipLine.DeleteAll();
        SLHistSOType.DeleteAll();
    end;
}
