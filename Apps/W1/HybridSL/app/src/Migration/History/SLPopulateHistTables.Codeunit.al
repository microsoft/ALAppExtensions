// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration.SL.HistoricalData;

codeunit 47025 "SL Populate Hist. Tables"
{
    Access = Internal;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLHistMigrationStatusMgmt: Codeunit "SL Hist. Migration Status Mgmt";
        CommitAfterXRecordCount: Integer;
        CurrentRecordCount: Integer;
        InitialDateTime: DateTime;
        InitialHistYear: Integer;
        InitialYearDate: Date;

    internal procedure GetDefaultCommitAfterXRecordCount(): Integer
    begin
        exit(1000);
    end;

    trigger OnRun()
    var
        SLHistMigrationCurStatus: Record "SL Hist. Migration Cur. Status";
        SLHistSourceError: Record "SL Hist. Source Error";
        SLHistSourceProgress: Record "SL Hist. Source Progress";
        IsHandled: Boolean;
        OverrideCommitAfterXRecordCount: Integer;
    begin
        CommitAfterXRecordCount := GetDefaultCommitAfterXRecordCount();

        OnBeforeRunSLPopulateHistTables(IsHandled, OverrideCommitAfterXRecordCount);
        if IsHandled then
            CommitAfterXRecordCount := OverrideCommitAfterXRecordCount;

        SLHistMigrationCurStatus.EnsureInit();
        if SLHistMigrationCurStatus."Reset Data" then begin
            SLHistMigrationStatusMgmt.ResetAll();

            if not SLHistSourceProgress.IsEmpty() then
                SLHistSourceProgress.DeleteAll();

            if not SLHistSourceError.IsEmpty() then
                SLHistSourceError.DeleteAll();

            SLHistMigrationCurStatus.EnsureInit();
            SLHistMigrationCurStatus."Reset Data" := false;
            SLHistMigrationCurStatus.Modify();
        end;

        SLHistMigrationStatusMgmt.SetStatusStarted();
        PopulateHistoricalTables();
    end;

    internal procedure PopulateHistoricalTables()
    var
        Day: Integer;
        Month: Integer;
        TheTime: Time;
    begin
        if not SLCompanyAdditionalSettings.GetMigrateHistory() then
            exit;

        InitialHistYear := SLCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then begin
            Day := 01;
            Month := 01;
            TheTime := 0T;
            InitialDateTime := CreateDateTime(DMY2Date(Day, Month, InitialHistYear), TheTime);
            InitialYearDate := DMY2Date(Day, Month, InitialHistYear);
        end;

        PopulateGLDetail();
        PopulateReceivables();
        PopulatePayables();
        PopulateItems();
        PopulatePurchaseReceivables();
        SLHistMigrationStatusMgmt.SetStatusFinished();
        Commit();
    end;

    internal procedure PopulateGLDetail()
    begin
        if not SLCompanyAdditionalSettings.GetMigrateHistGLTrx() then
            exit;

        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL GL Journal Trx.", false);
        PopulateHistoricalGLSetup();
        PopulateHistoricalGLTran();
        PopulateHistoricalBatch();
        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL GL Journal Trx.", true);
    end;

    internal procedure PopulateHistoricalGLSetup()
    var
        SLGLSetup: Record "SL GLSetup";
        SLHistGLSetup: Record "SL Hist. GLSetup";
        SourceTableId: Integer;
    begin
        SourceTableId := Database::"SL GLSetup";
        SLGLSetup.SetFilter(CpnyId, '= %1', CompanyName);
        if not SLGLSetup.FindSet() then
            exit;

        Clear(SLHistGLSetup);
        SLHistGLSetup.TransferFields(SLGLSetup);
        if SLHistGLSetup.Insert() then
            ReportLastSuccess(SourceTableId, SLGLSetup.SystemRowVersion)
        else
            ReportLastError(SourceTableId, SLGLSetup.SystemRowVersion, "SL Hist. Migration Step Type"::"SL GL Journal Trx.", 'GL Setup');
        AfterProcessedNextRecord(SourceTableId, SLGLSetup.SystemRowVersion);
        AfterProcessedSection(SourceTableId, SLGLSetup.SystemRowVersion);
    end;

    internal procedure PopulateHistoricalGLTran()
    var
        SLGLTran: Record "SL GLTran Buffer";
        SLHistGLTran: Record "SL Hist. GLTran Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
        PostedTxt: Label 'P', Locked = true;
    begin
        SourceTableId := Database::"SL GLTran Buffer";
        if InitialHistYear > 0 then
            SLGLTran.SetFilter(PerPost, '>= %1', Format(InitialHistYear));
        SLGLTran.SetFilter(CpnyID, '= %1', CompanyName);
        SLGLTran.SetFilter(Posted, '= %1', PostedTxt);
        if not SLGLTran.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLGLTran.SystemRowVersion;
            Clear(SLHistGLTran);
            SLHistGLTran.TransferFields(SLGLTran);
            if SLHistGLTran.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL GL Journal Trx.", SLGLTran.Module + '-' + SLGLTran.BatNbr + '-' + Format(SLGLTran.LineNbr));
            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLGLTran.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalBatch()
    var
        SLBatch: Record "SL Batch";
        SLHistBatch: Record "SL Hist. Batch";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL Batch";
        if InitialHistYear > 0 then
            SLBatch.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);
        SLBatch.SetFilter(CpnyID, '= %1', CompanyName);
        if not SLBatch.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLBatch.SystemRowVersion;
            Clear(SLHistBatch);
            SLHistBatch.TransferFields(SLBatch);

            if SLHistBatch.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL GL Journal Trx.", SLBatch.Module + '-' + SLBatch.BatNbr);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLBatch.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulatePayables();
    begin
        If not SLCompanyAdditionalSettings.GetMigrateHistAPTrx() then
            exit;

        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Payables Trx.", false);
        PopulateHistoricalAPDoc();
        PopulateHistoricalAPTran();
        PopulateHistoricalAPAdjust();
        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Payables Trx.", true);
    end;

    internal procedure PopulateHistoricalAPDoc()
    var
        SLAPDoc: Record "SL APDoc Buffer";
        SLHistAPDoc: Record "SL Hist. APDoc Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL APDoc Buffer";
        if InitialHistYear > 0 then
            SLAPDoc.SetFilter(PerPost, '>= %1', Format(InitialHistYear));
        SLAPDoc.SetFilter(CpnyID, '= %1', CompanyName);
        if not SLAPDoc.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLAPDoc.SystemRowVersion;
            Clear(SLHistAPDoc);
            SLHistAPDoc.TransferFields(SLAPDoc);
            if SLHistAPDoc.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Payables Trx.", SLAPDoc.Acct + '-' + SLAPDoc.Sub + '-' + SLAPDoc.DocType + '-' + SLAPDoc.RefNbr + '-' + Format(SLAPDoc.RecordID));
            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLAPDoc.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalAPTran()
    var
        SLAPTran: Record "SL APTran Buffer";
        SLHistAPTran: Record "SL Hist. APTran Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL APTran Buffer";
        if InitialHistYear > 0 then
            SLAPTran.SetFilter(PerPost, '>= %1', Format(InitialHistYear));
        SLAPTran.SetFilter(CpnyID, '= %1', CompanyName);
        if not SLAPTran.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLAPTran.RecordID;
            Clear(SLHistAPTran);
            SLHistAPTran.TransferFields(SLAPTran);
            if SLHistAPTran.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Payables Trx.", SLAPTran.BatNbr + '-' + SLAPTran.Acct + '-' + SLAPTran.Sub + '-' + SLAPTran.RefNbr + '-' + Format(SLAPTran.RecordID));
            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLAPTran.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalAPAdjust()
    var
        SLAPAdjust: Record "SL APAdjust";
        SLHistAPAdjust: Record "SL Hist. APAdjust";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL APAdjust";
        if InitialHistYear > 0 then
            SLAPAdjust.SetFilter(AdjgPerPost, '>= %1', Format(InitialHistYear));
        if not SLAPAdjust.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLAPAdjust.SystemRowVersion;
            Clear(SLHistAPAdjust);
            SLHistAPAdjust.TransferFields(SLAPAdjust);
            if SLHistAPAdjust.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Payables Trx.", SLAPAdjust.AdjdRefNbr + '-' + SLAPAdjust.AdjdDocType + '-' + SLAPAdjust.AdjgRefNbr + '-' + SLAPAdjust.AdjgDocType + '-' + SLAPAdjust.VendId + '-' + SLAPAdjust.AdjgAcct + '-' + SLAPAdjust.AdjgSub);
            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLAPAdjust.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateReceivables();
    begin
        If not SLCompanyAdditionalSettings.GetMigrateHistARTrx() then
            exit;

        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Receivables Trx.", false);
        PopulateHistoricalARDoc();
        PopulateHistoricalARTran();
        PopulateHistoricalARAdjust();
        PopulateHistoricalSOHeader();
        PopulateHistoricalSOLine();
        PopulateHistoricalSOShipHeader();
        PopulateHistoricalSOShipLine();
        PopulateHistoricalSOType();
        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Receivables Trx.", true);
    end;

    internal procedure PopulateHistoricalARDoc()
    var
        SLARDoc: Record "SL ARDoc Buffer";
        SLHistARDoc: Record "SL Hist. ARDoc Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL ARDoc Buffer";
        if InitialHistYear > 0 then
            SLARDoc.SetFilter(PerPost, '>= %1', Format(InitialHistYear));
        SLARDoc.SetFilter(CpnyID, '= %1', CompanyName);
        if not SLARDoc.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLARDoc.SystemRowVersion;
            Clear(SLHistARDoc);
            SLHistARDoc.TransferFields(SLARDoc);

            if SLHistARDoc.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLARDoc.CustId + '-' + SLARDoc.DocType + '-' + SLARDoc.RefNbr + '-' + SLARDoc.BatNbr);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLARDoc.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalARTran()
    var
        SLARTran: Record "SL ARTran Buffer";
        SLHistARTran: Record "SL Hist. ARTran Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL ARTran Buffer";
        if InitialHistYear > 0 then
            SLARTran.SetFilter(TranDate, '>= %1', InitialYearDate);

        SLARTran.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLARTran.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLARTran.RecordID;
            Clear(SLHistARTran);
            SLHistARTran.TransferFields(SLARTran);

            if SLHistARTran.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLARTran.CustId + '-' + SLARTran.TranType + '-' + SLARTran.RefNbr + '-' + Format(SLARTran.LineNbr));

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLARTran.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalARAdjust()
    var
        SLARAdjust: Record "SL ARAdjust";
        SLHistARAdjust: Record "SL Hist. ARAdjust";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL ARAdjust";
        if InitialHistYear > 0 then
            SLARAdjust.SetFilter(AdjgPerPost, '>= %1', Format(InitialHistYear));
        if not SLARAdjust.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLARAdjust.RecordID;
            Clear(SLHistARAdjust);
            SLHistARAdjust.TransferFields(SLARAdjust);
            if SLHistARAdjust.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLARAdjust.AdjdRefNbr + '-' + Format(SLARAdjust.RecordID));
            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLARAdjust.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalSOHeader()
    var
        SLSOHeader: Record "SL SOHeader";
        SLHistSOHeader: Record "SL Hist. SOHeader";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL SOHeader";
        if InitialHistYear > 0 then
            SLSOHeader.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLSOHeader.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLSOHeader.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLSOHeader.SystemRowVersion;
            Clear(SLHistSOHeader);
            SLHistSOHeader.TransferFields(SLSOHeader);

            if SLHistSOHeader.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLSOHeader.CpnyID + '-' + SLSOHeader.OrdNbr);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLSOHeader.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalSOLine()
    var
        SLSOLine: Record "SL SOLine";
        SLHistSOLine: Record "SL Hist. SOLine";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL SOLine";
        if InitialHistYear > 0 then
            SLSOLine.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLSOLine.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLSOLine.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLSOLine.SystemRowVersion;
            Clear(SLHistSOLine);
            SLHistSOLine.TransferFields(SLSOLine);

            if SLHistSOLine.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLSOLine.CpnyID + '-' + SLSOLine.OrdNbr + '-' + SLSOLine.LineRef);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLSOLine.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalSOShipHeader()
    var
        SLSOShipHeader: Record "SL SOShipHeader";
        SLHistSOShipHeader: Record "SL Hist. SOShipHeader";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL SOShipHeader";
        if InitialHistYear > 0 then
            SLSOShipHeader.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLSOShipHeader.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLSOShipHeader.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLSOShipHeader.SystemRowVersion;
            Clear(SLHistSOShipHeader);
            SLHistSOShipHeader.TransferFields(SLSOShipHeader);

            if SLHistSOShipHeader.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLSOShipHeader.CpnyID + '-' + SLSOShipHeader.ShipperID);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLSOShipHeader.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalSOShipLine()
    var
        SLSOShipLine: Record "SL SOShipLine";
        SLHistSOShipLine: Record "SL Hist. SOShipLine";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL SOShipLine";
        if InitialHistYear > 0 then
            SLSOShipLine.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLSOShipLine.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLSOShipLine.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLSOShipLine.SystemRowVersion;
            Clear(SLHistSOShipLine);
            SLHistSOShipLine.TransferFields(SLSOShipLine);

            if SLHistSOShipLine.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLSOShipLine.CpnyID + '-' + SLSOShipLine.ShipperID + '-' + SLSOShipLine.LineRef);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLSOShipLine.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalSOType()
    var
        SLSOType: Record "SL SOType";
        SLHistSOType: Record "SL Hist. SOType";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
        Inactive: Integer;
    begin
        SourceTableId := Database::"SL SOType";
        Inactive := 0;
        if InitialHistYear > 0 then
            SLSOType.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLSOType.SetFilter(CpnyID, '= %1', CompanyName);
        SLSOType.SetFilter(Active, '<> %1', Inactive);

        if not SLSOType.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLSOType.SystemRowVersion;
            Clear(SLHistSOType);
            SLHistSOType.TransferFields(SLSOType);

            if SLHistSOType.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Receivables Trx.", SLSOType.CpnyID + '-' + SLSOType.SOTypeID);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLSOType.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateItems();
    begin
        If not SLCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Inventory Trx.", false);
        PopulateHistoricalINTran();
        PopulateHistoricalLotSerT();
        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Inventory Trx.", true);
    end;

    internal procedure PopulateHistoricalINTran()
    var
        SLINTran: Record "SL INTran Buffer";
        SLHistINTran: Record "SL Hist. INTran Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL INTran Buffer";
        if InitialHistYear > 0 then
            SLINTran.SetFilter(TranDate, '>= %1', InitialDateTime);

        SLINTran.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLINTran.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLINTran.RecordID;
            Clear(SLHistINTran);
            SLHistINTran.TransferFields(SLINTran);

            if SLHistINTran.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Inventory Trx.", SLINTran.InvtID + '-' + SLINTran.SiteID + '-' + SLINTran.CpnyID + '-' + Format(SLINTran.RecordID));

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLINTran.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalLotSerT()
    var
        SLLotSerT: Record "SL LotSerT Buffer";
        SLHistLotSerT: Record "SL Hist. LotSerT Archive";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL LotSerT Buffer";
        if InitialHistYear > 0 then
            SLLotSerT.SetFilter(TranDate, '>= %1', InitialDateTime);

        SLLotSerT.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLLotSerT.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLLotSerT.RecordID;
            Clear(SLHistLotSerT);
            SLHistLotSerT.TransferFields(SLLotSerT);

            if SLHistLotSerT.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Inventory Trx.", SLLotSerT.LotSerNbr + '-' + Format(SLLotSerT.RecordID));

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLLotSerT.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulatePurchaseReceivables();
    begin
        If not SLCompanyAdditionalSettings.GetMigrateHistPurchTrx() then
            exit;

        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", false);
        PopulateHistoricalPOTran();
        PopulateHistoricalPOReceipt();
        PopulateHistoricalPurOrdDet();
        PopulateHistoricalPurchOrd();
        SLHistMigrationStatusMgmt.UpdateStepStatus("SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", true);
    end;

    internal procedure PopulateHistoricalPOTran()
    var
        SLPOTran: Record "SL POTran";
        SLHistPOTran: Record "SL Hist. POTran";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL POTran";
        if InitialHistYear > 0 then
            SLPOTran.SetFilter(TranDate, '>= %1', InitialDateTime);

        SLPOTran.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLPOTran.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLPOTran.SystemRowVersion;
            Clear(SLHistPOTran);
            SLHistPOTran.TransferFields(SLPOTran);

            if SLHistPOTran.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", SLPOTran.RcptNbr + '-' + SLPOTran.LineRef);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLPOTran.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalPOReceipt()
    var
        SLPOReceipt: Record "SL POReceipt";
        SLHistPOReceipt: Record "SL Hist. POReceipt";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL POReceipt";
        if InitialHistYear > 0 then
            SLPOReceipt.SetFilter(RcptDate, '>= %1', InitialDateTime);

        SLPOReceipt.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLPOReceipt.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLPOReceipt.SystemRowVersion;
            Clear(SLHistPOReceipt);
            SLHistPOReceipt.TransferFields(SLPOReceipt);

            if SLHistPOReceipt.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", SLPOReceipt.RcptNbr);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLPOReceipt.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalPurOrdDet()
    var
        SLPurOrdDet: Record "SL PurOrdDet";
        SLHistPurOrdDet: Record "SL Hist. PurOrdDet";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL PurOrdDet";
        if InitialHistYear > 0 then
            SLPurOrdDet.SetFilter(Crtd_DateTime, '>= %1', InitialDateTime);

        SLPurOrdDet.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLPurOrdDet.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLPurOrdDet.SystemRowVersion;
            Clear(SLHistPurOrdDet);
            SLHistPurOrdDet.TransferFields(SLPurOrdDet);

            if SLHistPurOrdDet.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", SLPurOrdDet.PONbr + '-' + SLPurOrdDet.LineRef);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLPurOrdDet.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    internal procedure PopulateHistoricalPurchOrd()
    var
        SLPurchOrd: Record "SL PurchOrd";
        SLHistPurchOrd: Record "SL Hist. PurchOrd";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"SL PurchOrd";
        if InitialHistYear > 0 then
            SLPurchOrd.SetFilter(PODate, '>= %1', InitialDateTime);

        SLPurchOrd.SetFilter(CpnyID, '= %1', CompanyName);

        if not SLPurchOrd.FindSet() then
            exit;

        repeat
            LastSourceRecordId := SLPurchOrd.SystemRowVersion;
            Clear(SLHistPurchOrd);
            SLHistPurchOrd.TransferFields(SLPurchOrd);

            if SLHistPurchOrd.Insert() then
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            else
                ReportLastError(SourceTableId, LastSourceRecordId, "SL Hist. Migration Step Type"::"SL Purchase Receivables Trx.", SLPurchOrd.PONbr);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until SLPurchOrd.Next() = 0;
        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure AfterProcessedNextRecord(TableId: Integer; RecId: Integer)
    var
        SLHistSourceProgress: Record "SL Hist. Source Progress";
    begin
        CurrentRecordCount := CurrentRecordCount + 1;

        if CurrentRecordCount >= CommitAfterXRecordCount then begin
            SLHistSourceProgress.SetLastProcessedRecId(TableId, RecId);
            Commit();
            CurrentRecordCount := 0;
        end;
    end;

    local procedure AfterProcessedSection(TableId: Integer; LastRecId: Integer)
    var
        SLHistSourceProgress: Record "SL Hist. Source Progress";
    begin
        if LastRecId = 0 then
            exit;

        CurrentRecordCount := 0;
        SLHistSourceProgress.SetLastProcessedRecId(TableId, LastRecId);
        Commit();
    end;

    procedure ReportLastError(TableId: Integer; RecordId: Integer; Step: enum "SL Hist. Migration Step Type"; Reference: Text[150])
    var
        SLHistSourceError: Record "SL Hist. Source Error";
    begin
        SLHistSourceError.SetRange("Table Id", TableId);
        SLHistSourceError.SetRange("Record Id", RecordId);
        if not SLHistSourceError.IsEmpty() then
            exit;

        SLHistSourceError."Table Id" := TableId;
        SLHistSourceError."Record Id" := RecordId;
        SLHistSourceError.Step := Step;
        SLHistSourceError.Reference := Reference;
        SLHistSourceError."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(SLHistSourceError."Error Code"));
        SLHistSourceError.SetErrorMessage(GetLastErrorCallStack());
        SLHistSourceError.Insert();

        ClearLastError();
    end;

    internal procedure ReportLastSuccess(TableId: Integer; RecordId: Integer)
    var
        SLHistSourceError: Record "SL Hist. Source Error";
    begin
        if SLHistSourceError.Get(TableId, RecordId) then
            SLHistSourceError.Delete();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunSLPopulateHistTables(var IsHandled: Boolean; var OverrideCommitAfterXRecordCount: Integer)
    begin
    end;
}
