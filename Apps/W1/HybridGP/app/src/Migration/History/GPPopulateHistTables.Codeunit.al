namespace Microsoft.DataMigration.GP;

using Microsoft.CRM.Outlook;
using Microsoft.DataMigration.GP.HistoricalData;

codeunit 40900 "GP Populate Hist. Tables"
{
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HistMigrationStatusMgmt: Codeunit "Hist. Migration Status Mgmt.";
        CommitAfterXRecordCount: Integer;
        CurrentRecordCount: Integer;

    local procedure GetDefaultCommitAfterXRecordCount(): Integer
    begin
        exit(1000);
    end;

    trigger OnRun()
    var
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
        GPHistSourceProgress: Record "GP Hist. Source Progress";
        GPHistSourceError: Record "GP Hist. Source Error";
        IsHandled: Boolean;
        OverrideCommitAfterXRecordCount: Integer;
    begin
        CommitAfterXRecordCount := GetDefaultCommitAfterXRecordCount();

        OnBeforeRunGPPopulateHistTables(IsHandled, OverrideCommitAfterXRecordCount);
        if IsHandled then
            CommitAfterXRecordCount := OverrideCommitAfterXRecordCount;

        HistMigrationCurrentStatus.EnsureInit();
        if HistMigrationCurrentStatus."Reset Data" then begin
            HistMigrationStatusMgmt.ResetAll();

            if not GPHistSourceProgress.IsEmpty() then
                GPHistSourceProgress.DeleteAll();

            if not GPHistSourceError.IsEmpty() then
                GPHistSourceError.DeleteAll();

            HistMigrationCurrentStatus.EnsureInit();
            HistMigrationCurrentStatus."Reset Data" := false;
            HistMigrationCurrentStatus.Modify();
        end;

        HistMigrationStatusMgmt.SetStatusStarted();
        PopulateHistoricalTables();
    end;

    local procedure GPPayrollSeriesId(): Integer
    begin
        exit(6);
    end;

    internal procedure PopulateHistoricalTables()
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistory() then
            exit;

        PopulateGLDetail();
        PopulateReceivables();
        PopulatePayablesDocuments();
        PopulateInventoryTransactions();
        PopulateAssemblyItemTransactions();
        PopulatePurchaseRecvTransactions();

        HistMigrationStatusMgmt.SetStatusFinished();
        Commit();
    end;

    local procedure PopulateGLDetail()
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistGLTrx() then
            exit;

        // GP G/L Accounts       
        PopulateHistGLAccounts();

        // GP G/L Journal Trx.
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP GL Journal Trx.", false);
        PopulateOpenYearPostedTransactions();
        PopulateHistoricalYearPostedTransactions();
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP GL Journal Trx.", true);
    end;

    local procedure PopulateHistGLAccounts()
    var
        GPGL00105: Record "GP GL00105";
        GPGL00100: Record "GP GL00100";
        HistGLAccount: Record "Hist. G/L Account";
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"GP GL00105";
        GPGL00105.SetLoadFields(DEX_ROW_ID, ACTINDX, ACTNUMST);
        GPGL00105.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPGL00105.SetCurrentKey(DEX_ROW_ID);
        GPGL00105.SetAscending(DEX_ROW_ID, true);

        if not GPGL00105.FindSet() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP GL Accounts", false);

        repeat
            LastSourceRecordId := GPGL00105.DEX_ROW_ID;

            Clear(HistGLAccount);
            if GPGL00100.Get(GPGL00105.ACTINDX) then begin

#pragma warning disable AA0139
                HistGLAccount."No." := GPGL00105.ACTNUMST.TrimEnd();
#pragma warning restore AA0139
                HistGLAccount.Name := GPGL00100.ACTDESCR;

                if HistGLAccount.Insert() then
                    ReportLastSuccess(SourceTableId, LastSourceRecordId)
                else
                    ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP GL Accounts", GPGL00105.ACTNUMST);

                AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
            end;
        until GPGL00105.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP GL Accounts", true);
    end;

    local procedure PopulateOpenYearPostedTransactions()
    var
        GPGL20000: Record "GP GL20000";
        GPGL00105: Record "GP GL00105";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        InitialHistYear: Integer;
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"GP GL20000";
        GPGL20000.SetLoadFields(DEX_ROW_ID, OPENYEAR, ACTINDX, SERIES, SOURCDOC, JRNENTRY, SEQNUMBR, TRXSORCE, TRXDATE, CURNCYID, DEBITAMT, ORDBTAMT, CRDTAMNT, ORCRDAMT, SOURCDOC, REFRENCE, DSCRIPTN, ORTRXSRC, USWHPSTD, User_Defined_Text01, User_Defined_Text02, ORDOCNUM, ORMSTRID, ORMSTRNM);
        GPGL20000.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPGL20000.SetCurrentKey(DEX_ROW_ID);
        GPGL20000.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPGL20000.SetFilter(OPENYEAR, '>=%1', InitialHistYear);

        if not GPGL20000.FindSet() then
            exit;

        repeat
            if GPGL00105.Get(GPGL20000.ACTINDX) then begin
                LastSourceRecordId := GPGL20000.DEX_ROW_ID;
                Clear(HistGenJournalLine);

#pragma warning disable AA0139
                HistGenJournalLine."Source Type" := ConvertSeriesToSourceType(GPGL20000.SERIES, GPGL20000.SOURCDOC.TrimEnd());
#pragma warning restore AA0139

                HistGenJournalLine."Journal Entry No." := Format(GPGL20000.JRNENTRY);
                HistGenJournalLine."Account No." := CopyStr(Format(GPGL00105.ACTNUMST), 1, MaxStrLen(HistGenJournalLine."Account No."));
                HistGenJournalLine."Sequence No." := GPGL20000.SEQNUMBR;
                HistGenJournalLine."Audit Code" := GPGL20000.TRXSORCE;
                HistGenJournalLine.Closed := false;
                HistGenJournalLine.Year := GPGL20000.OPENYEAR;
                HistGenJournalLine."Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL20000.TRXDATE));
                HistGenJournalLine."Currency Code" := CopyStr(GPGL20000.CURNCYID, 1, MaxStrLen(HistGenJournalLine."Currency Code"));
                HistGenJournalLine."Debit Amount" := GPGL20000.DEBITAMT;
                HistGenJournalLine."Orig. Debit Amount" := GPGL20000.ORDBTAMT;
                HistGenJournalLine."Credit Amount" := GPGL20000.CRDTAMNT;
                HistGenJournalLine."Orig. Credit Amount" := GPGL20000.ORCRDAMT;
                HistGenJournalLine."Document Type" := GPGL20000.SOURCDOC;
                HistGenJournalLine."Reference Desc." := GPGL20000.REFRENCE;
                HistGenJournalLine."Description" := GPGL20000.DSCRIPTN;
                HistGenJournalLine."Orig. Trx. Source No." := GPGL20000.ORTRXSRC;
                HistGenJournalLine."User" := GPGL20000.USWHPSTD;
                HistGenJournalLine."Custom1" := GPGL20000.User_Defined_Text01;
                HistGenJournalLine."Custom2" := GPGL20000.User_Defined_Text02;

                if GPGL20000.SERIES <> GPPayrollSeriesId() then begin
#pragma warning disable AA0139
                    HistGenJournalLine."Orig. Document No." := GPGL20000.ORDOCNUM.TrimEnd();
#pragma warning restore AA0139
                    HistGenJournalLine."Source No." := GPGL20000.ORMSTRID;
                    HistGenJournalLine."Source Name" := CopyStr(GPGL20000.ORMSTRNM, 1, MaxStrLen(HistGenJournalLine."Source Name"));
                end;

                if HistGenJournalLine.Insert() then begin
                    ReportLastSuccess(SourceTableId, LastSourceRecordId);
                    PopulateGLOpenYearItemTransaction(GPGL20000)
                end else
                    ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP GL Journal Trx.", GPGL20000.TRXSORCE);

                AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
            end;
        until GPGL20000.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulateHistoricalYearPostedTransactions()
    var
        GPGL30000: Record "GP GL30000";
        GPGL00105: Record "GP GL00105";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        InitialHistYear: Integer;
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"GP GL30000";
        GPGL30000.SetLoadFields(DEX_ROW_ID, HSTYEAR, ACTINDX, SERIES, SOURCDOC, JRNENTRY, SEQNUMBR, TRXSORCE, TRXDATE, CURNCYID, DEBITAMT, ORDBTAMT, CRDTAMNT, ORCRDAMT, SOURCDOC, REFRENCE, DSCRIPTN, ORTRXSRC, USWHPSTD, User_Defined_Text01, User_Defined_Text02, ORDOCNUM, ORMSTRID, ORMSTRNM);
        GPGL30000.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPGL30000.SetCurrentKey(DEX_ROW_ID);
        GPGL30000.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPGL30000.SetFilter(HSTYEAR, '>=%1', InitialHistYear);

        if not GPGL30000.FindSet() then
            exit;

        repeat
            if GPGL00105.Get(GPGL30000.ACTINDX) then begin
                LastSourceRecordId := GPGL30000.DEX_ROW_ID;
                Clear(HistGenJournalLine);

#pragma warning disable AA0139
                HistGenJournalLine."Source Type" := ConvertSeriesToSourceType(GPGL30000.SERIES, GPGL30000.SOURCDOC.TrimEnd());
#pragma warning restore AA0139

                HistGenJournalLine."Journal Entry No." := Format(GPGL30000.JRNENTRY);
                HistGenJournalLine."Account No." := CopyStr(Format(GPGL00105.ACTNUMST), 1, MaxStrLen(HistGenJournalLine."Account No."));
                HistGenJournalLine."Sequence No." := GPGL30000.SEQNUMBR;
                HistGenJournalLine."Audit Code" := GPGL30000.TRXSORCE;
                HistGenJournalLine.Closed := true;
                HistGenJournalLine.Year := GPGL30000.HSTYEAR;
                HistGenJournalLine."Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL30000.TRXDATE));
                HistGenJournalLine."Currency Code" := CopyStr(GPGL30000.CURNCYID, 1, MaxStrLen(HistGenJournalLine."Currency Code"));
                HistGenJournalLine."Debit Amount" := GPGL30000.DEBITAMT;
                HistGenJournalLine."Orig. Debit Amount" := GPGL30000.ORDBTAMT;
                HistGenJournalLine."Credit Amount" := GPGL30000.CRDTAMNT;
                HistGenJournalLine."Orig. Credit Amount" := GPGL30000.ORCRDAMT;
                HistGenJournalLine."Document Type" := GPGL30000.SOURCDOC;
                HistGenJournalLine."Reference Desc." := GPGL30000.REFRENCE;
                HistGenJournalLine."Description" := GPGL30000.DSCRIPTN;
                HistGenJournalLine."Orig. Trx. Source No." := GPGL30000.ORTRXSRC;
                HistGenJournalLine."User" := GPGL30000.USWHPSTD;
                HistGenJournalLine."Custom1" := GPGL30000.User_Defined_Text01;
                HistGenJournalLine."Custom2" := GPGL30000.User_Defined_Text02;

                if GPGL30000.SERIES <> GPPayrollSeriesId() then begin
#pragma warning disable AA0139
                    HistGenJournalLine."Orig. Document No." := GPGL30000.ORDOCNUM.TrimEnd();
#pragma warning restore AA0139
                    HistGenJournalLine."Source No." := GPGL30000.ORMSTRID;
                    HistGenJournalLine."Source Name" := CopyStr(GPGL30000.ORMSTRNM, 1, MaxStrLen(HistGenJournalLine."Source Name"));
                end;

                if HistGenJournalLine.Insert() then begin
                    ReportLastSuccess(SourceTableId, LastSourceRecordId);
                    PopulateGLHistoricalYearItemTransaction(GPGL30000)
                end else
                    ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP GL Journal Trx.", GPGL30000.TRXSORCE);

                AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
            end;
        until GPGL30000.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulateReceivables()
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistARTrx() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Receivables Trx.", false);
        PopulateSalesTransactions();
        PopulateRecvDocuments();
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Receivables Trx.", true);
    end;

    local procedure PopulateSalesTransactions()
    var
        GPSOPTrxHist: Record GPSOPTrxHist;
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        InitialHistYear: Integer;
        DocumentNo: Code[35];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::GPSOPTrxHist;
        GPSOPTrxHist.SetLoadFields(DEX_ROW_ID, DOCDATE, SOPNUMBE, CUSTNMBR, SOPTYPE, SOPSTATUS, CURNCYID, SUBTOTAL, TAXAMNT, TRDISAMT, FRTAMNT, MISCAMNT, PYMTRCVD, DISTKNAM, DOCAMNT, DUEDATE, ACTLSHIP, CUSTNAME, SHIPMTHD, PRSTADCD, ShipToName, ADDRESS1, ADDRESS2, CITY, STATE, ZIPCODE, COUNTRY, CNTCPRSN, SLPRSNID, SALSTERR, CSTPONBR, ORIGNUMB, TRXSORCE);
        GPSOPTrxHist.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPSOPTrxHist.SetCurrentKey(DEX_ROW_ID);
        GPSOPTrxHist.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPSOPTrxHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPSOPTrxHist.FindSet() then
            exit;

        repeat
            LastSourceRecordId := GPSOPTrxHist.DEX_ROW_ID;
            Clear(HistSalesTrxHeader);

#pragma warning disable AA0139
            DocumentNo := GPSOPTrxHist.SOPNUMBE.TrimEnd();
            HistSalesTrxHeader."Customer No." := GPSOPTrxHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistSalesTrxHeader."No." := DocumentNo;
            HistSalesTrxHeader."Sales Trx. Type" := ConvertGPSOPTypeToHistSalesTrxType(GPSOPTrxHist.SOPTYPE);
            HistSalesTrxHeader."Sales Trx. Status" := ConvertSOPStatusToSalesTrxStatus(GPSOPTrxHist.SOPSTATUS);
            HistSalesTrxHeader."Currency Code" := CopyStr(GPSOPTrxHist.CURNCYID, 1, MaxStrLen(HistSalesTrxHeader."Currency Code"));
            HistSalesTrxHeader."Sub Total" := GPSOPTrxHist.SUBTOTAL;
            HistSalesTrxHeader."Tax Amount" := GPSOPTrxHist.TAXAMNT;
            HistSalesTrxHeader."Trade Disc. Amount" := GPSOPTrxHist.TRDISAMT;
            HistSalesTrxHeader."Freight Amount" := GPSOPTrxHist.FRTAMNT;
            HistSalesTrxHeader."Misc. Amount" := GPSOPTrxHist.MISCAMNT;
            HistSalesTrxHeader."Payment Recv. Amount" := GPSOPTrxHist.PYMTRCVD;
            HistSalesTrxHeader."Disc. Taken Amount" := GPSOPTrxHist.DISTKNAM;
            HistSalesTrxHeader."Total" := GPSOPTrxHist.DOCAMNT;
            HistSalesTrxHeader."Document Date" := GPSOPTrxHist.DOCDATE;
            HistSalesTrxHeader."Due Date" := GPSOPTrxHist.DUEDATE;
            HistSalesTrxHeader."Actual Ship Date" := GPSOPTrxHist.ACTLSHIP;
            HistSalesTrxHeader."Customer Name" := GPSOPTrxHist.CUSTNAME;
            HistSalesTrxHeader."Ship Method" := GPSOPTrxHist.SHIPMTHD;
            HistSalesTrxHeader."Ship-to Code" := GPSOPTrxHist.PRSTADCD;
            HistSalesTrxHeader."Ship-to Name" := GPSOPTrxHist.ShipToName;
            HistSalesTrxHeader."Ship-to Address" := GPSOPTrxHist.ADDRESS1;
            HistSalesTrxHeader."Ship-to Address 2" := CopyStr(GPSOPTrxHist.ADDRESS2, 1, MaxStrLen(HistSalesTrxHeader."Ship-to Address 2"));
            HistSalesTrxHeader."Ship-to City" := GPSOPTrxHist.CITY;
            HistSalesTrxHeader."Ship-to State" := GPSOPTrxHist.STATE;
            HistSalesTrxHeader."Ship-to Zipcode" := GPSOPTrxHist.ZIPCODE;
            HistSalesTrxHeader."Ship-to Country" := CopyStr(GPSOPTrxHist.COUNTRY, 1, MaxStrLen(HistSalesTrxHeader."Ship-to Country"));
            HistSalesTrxHeader."Contact Person Name" := GPSOPTrxHist.CNTCPRSN;
            HistSalesTrxHeader."Salesperson No." := GPSOPTrxHist.SLPRSNID;
            HistSalesTrxHeader."Sales Territory" := GPSOPTrxHist.SALSTERR;
            HistSalesTrxHeader."Customer Purchase No." := GPSOPTrxHist.CSTPONBR;
            HistSalesTrxHeader."Original No." := GPSOPTrxHist.ORIGNUMB;
            HistSalesTrxHeader."Audit Code" := GPSOPTrxHist.TRXSORCE;

            if HistSalesTrxHeader.Insert() then begin
                ReportLastSuccess(SourceTableId, LastSourceRecordId);
                PopulateSalesTransactionLines(GPSOPTrxHist, DocumentNo);
                PopulateSOPItemTransaction(GPSOPTrxHist)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Receivables Trx.", GPSOPTrxHist.SOPNUMBE);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPSOPTrxHist.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulateSalesTransactionLines(var GPSOPTrxHist: Record GPSOPTrxHist; DocumentNo: Code[35])
    var
        GPSOPTrxAmountsHist: Record GPSOPTrxAmountsHist;
        HistSalesTrxLine: Record "Hist. Sales Trx. Line";
    begin
        GPSOPTrxAmountsHist.SetLoadFields(DEX_ROW_ID, SOPTYPE, SOPNUMBE, LNITMSEQ, CMPNTSEQ, ITEMNMBR, ITEMDESC, UOFM, UNITCOST, UNITPRCE, QUANTITY, EXTDCOST, XTNDPRCE, TAXAMNT, LOCNCODE, ShipToName);
        GPSOPTrxAmountsHist.SetRange(SOPTYPE, GPSOPTrxHist.SOPTYPE);
        GPSOPTrxAmountsHist.SetRange(SOPNUMBE, GPSOPTrxHist.SOPNUMBE);
        if not GPSOPTrxAmountsHist.FindSet() then
            exit;

        repeat
            Clear(HistSalesTrxLine);
            HistSalesTrxLine."Sales Header No." := DocumentNo;
            HistSalesTrxLine."Sales Trx. Type" := ConvertGPSOPTypeToHistSalesTrxType(GPSOPTrxAmountsHist.SOPTYPE);
            HistSalesTrxLine."Line Item Sequence No." := GPSOPTrxAmountsHist.LNITMSEQ;
            HistSalesTrxLine."Component Sequence" := GPSOPTrxAmountsHist.CMPNTSEQ;
            HistSalesTrxLine."Item No." := GPSOPTrxAmountsHist.ITEMNMBR;
            HistSalesTrxLine."Item Description" := CopyStr(GPSOPTrxAmountsHist.ITEMDESC, 1, MaxStrLen(HistSalesTrxLine."Item Description"));
            HistSalesTrxLine."Unit of Measure" := GPSOPTrxAmountsHist.UOFM;
            HistSalesTrxLine."Unit Cost" := GPSOPTrxAmountsHist.UNITCOST;
            HistSalesTrxLine."Unit Price" := GPSOPTrxAmountsHist.UNITPRCE;
            HistSalesTrxLine.Quantity := GPSOPTrxAmountsHist.QUANTITY;
            HistSalesTrxLine."Ext. Cost" := GPSOPTrxAmountsHist.EXTDCOST;
            HistSalesTrxLine."Ext. Price" := GPSOPTrxAmountsHist.XTNDPRCE;
            HistSalesTrxLine."Tax Amount" := GPSOPTrxAmountsHist.TAXAMNT;
            HistSalesTrxLine."Location Code" := GPSOPTrxAmountsHist.LOCNCODE;
            HistSalesTrxLine."Ship-to Name" := CopyStr(GPSOPTrxAmountsHist.ShipToName, 1, MaxStrLen(HistSalesTrxLine."Ship-to Name"));

            if not HistSalesTrxLine.Insert() then
                ReportLastError(Database::GPSOPTrxAmountsHist, GPSOPTrxAmountsHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Receivables Trx.", GPSOPTrxHist.SOPNUMBE);

            AfterProcessedNextChildRecord();
        until GPSOPTrxAmountsHist.Next() = 0;
    end;

    local procedure PopulateRecvDocuments()
    begin
        PopulateRecvOpenDocuments();
        PopulateRecvHistoricalDocuments();
    end;

    local procedure PopulateRecvOpenDocuments()
    var
        GPRM20101: Record "GP RM20101";
        HistReceivablesDocument: Record "Hist. Receivables Document";
        GPRM00101: Record "GP RM00101";
        CustomerName: Text[100];
        InitialHistYear: Integer;
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"GP RM20101";
        GPRM20101.SetLoadFields(DEX_ROW_ID, DOCDATE, CUSTNMBR, DOCNUMBR, RMDTYPAL, BACHNUMB, BCHSOURC, TRXSORCE, TRXDSCRN, DUEDATE, POSTDATE, PSTUSRID, CURNCYID, ORTRXAMT, CURTRXAM, SLSAMNT, COSTAMNT, FRTAMNT, MISCAMNT, TAXAMNT, DISTKNAM, CSPORNBR, SLPRSNID, SLSTERCD, SHIPMTHD, SHIPMTHD, CASHAMNT, COMDLRAM, DINVPDOF, PYMTRMID, WROFAMNT);
        GPRM20101.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPRM20101.SetCurrentKey(DEX_ROW_ID);
        GPRM20101.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPRM20101.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPRM20101.FindSet() then
            exit;

        repeat
            LastSourceRecordId := GPRM20101.DEX_ROW_ID;
            Clear(HistReceivablesDocument);

            if GPRM00101.Get(GPRM20101.CUSTNMBR) then
                CustomerName := GPRM00101.CUSTNAME;

#pragma warning disable AA0139
            HistReceivablesDocument."Document No." := GPRM20101.DOCNUMBR.TrimEnd();
            HistReceivablesDocument."Customer No." := GPRM20101.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistReceivablesDocument."Customer Name" := CustomerName;
            HistReceivablesDocument."Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM20101.RMDTYPAL);
            HistReceivablesDocument."Batch No." := GPRM20101.BACHNUMB;
            HistReceivablesDocument."Batch Source" := GPRM20101.BCHSOURC;
            HistReceivablesDocument."Audit Code" := GPRM20101.TRXSORCE;
            HistReceivablesDocument."Trx. Description" := GPRM20101.TRXDSCRN;
            HistReceivablesDocument."Document Date" := GPRM20101.DOCDATE;
            HistReceivablesDocument."Due Date" := GPRM20101.DUEDATE;
            HistReceivablesDocument."Post Date" := GPRM20101.POSTDATE;
            HistReceivablesDocument."User" := GPRM20101.PSTUSRID;
            HistReceivablesDocument."Currency Code" := CopyStr(GPRM20101.CURNCYID, 1, MaxStrLen(HistReceivablesDocument."Currency Code"));
            HistReceivablesDocument."Orig. Trx. Amount" := GPRM20101.ORTRXAMT;
            HistReceivablesDocument."Current Trx. Amount" := GPRM20101.CURTRXAM;
            HistReceivablesDocument."Sales Amount" := GPRM20101.SLSAMNT;
            HistReceivablesDocument."Cost Amount" := GPRM20101.COSTAMNT;
            HistReceivablesDocument."Freight Amount" := GPRM20101.FRTAMNT;
            HistReceivablesDocument."Misc. Amount" := GPRM20101.MISCAMNT;
            HistReceivablesDocument."Tax Amount" := GPRM20101.TAXAMNT;
            HistReceivablesDocument."Disc. Taken Amount" := GPRM20101.DISTKNAM;
            HistReceivablesDocument."Customer Purchase No." := GPRM20101.CSPORNBR;
            HistReceivablesDocument."Salesperson No." := GPRM20101.SLPRSNID;
            HistReceivablesDocument."Sales Territory" := GPRM20101.SLSTERCD;
            HistReceivablesDocument."Ship Method" := GPRM20101.SHIPMTHD;
            HistReceivablesDocument."Cash Amount" := GPRM20101.CASHAMNT;
            HistReceivablesDocument."Commission Dollar Amount" := GPRM20101.COMDLRAM;
            HistReceivablesDocument."Invoice Paid Off Date" := GPRM20101.DINVPDOF;
            HistReceivablesDocument."Payment Terms ID" := GPRM20101.PYMTRMID;
            HistReceivablesDocument."Write Off Amount" := GPRM20101.WROFAMNT;

            if HistReceivablesDocument.Insert() then begin
                PopulateRecvApply(HistReceivablesDocument."Customer No.", CustomerName, HistReceivablesDocument."Document No.", GPRM20101.RMDTYPAL);
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Receivables Trx.", GPRM20101.DOCNUMBR);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPRM20101.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulateRecvHistoricalDocuments()
    var
        GPRMHist: Record GPRMHist;
        HistReceivablesDocument: Record "Hist. Receivables Document";
        GPRM00101: Record "GP RM00101";
        CustomerName: Text[100];
        InitialHistYear: Integer;
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::GPRMHist;
        GPRMHist.SetLoadFields(DEX_ROW_ID, DOCDATE, CUSTNMBR, DOCNUMBR, RMDTYPAL, BACHNUMB, BCHSOURC, TRXSORCE, TRXDSCRN, DUEDATE, POSTDATE, PSTUSRID, CURNCYID, ORTRXAMT, CURTRXAM, SLSAMNT, COSTAMNT, FRTAMNT, MISCAMNT, TAXAMNT, DISTKNAM, CSPORNBR, SLPRSNID, SLSTERCD, SHIPMTHD, SHIPMTHD, CASHAMNT, COMDLRAM, DINVPDOF, PYMTRMID, WROFAMNT);
        GPRMHist.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPRMHist.SetCurrentKey(DEX_ROW_ID);
        GPRMHist.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPRMHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPRMHist.FindSet() then
            exit;

        repeat
            LastSourceRecordId := GPRMHist.DEX_ROW_ID;
            Clear(HistReceivablesDocument);

            if GPRM00101.Get(GPRMHist.CUSTNMBR) then
                CustomerName := GPRM00101.CUSTNAME;

#pragma warning disable AA0139
            HistReceivablesDocument."Document No." := GPRMHist.DOCNUMBR.TrimEnd();
            HistReceivablesDocument."Customer No." := GPRMHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistReceivablesDocument."Customer Name" := CustomerName;
            HistReceivablesDocument."Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRMHist.RMDTYPAL);
            HistReceivablesDocument."Batch No." := GPRMHist.BACHNUMB;
            HistReceivablesDocument."Batch Source" := GPRMHist.BCHSOURC;
            HistReceivablesDocument."Audit Code" := GPRMHist.TRXSORCE;
            HistReceivablesDocument."Trx. Description" := GPRMHist.TRXDSCRN;
            HistReceivablesDocument."Document Date" := GPRMHist.DOCDATE;
            HistReceivablesDocument."Due Date" := GPRMHist.DUEDATE;
            HistReceivablesDocument."Post Date" := GPRMHist.POSTDATE;
            HistReceivablesDocument."User" := GPRMHist.PSTUSRID;
            HistReceivablesDocument."Currency Code" := CopyStr(GPRMHist.CURNCYID, 1, MaxStrLen(HistReceivablesDocument."Currency Code"));
            HistReceivablesDocument."Orig. Trx. Amount" := GPRMHist.ORTRXAMT;
            HistReceivablesDocument."Current Trx. Amount" := GPRMHist.CURTRXAM;
            HistReceivablesDocument."Sales Amount" := GPRMHist.SLSAMNT;
            HistReceivablesDocument."Cost Amount" := GPRMHist.COSTAMNT;
            HistReceivablesDocument."Freight Amount" := GPRMHist.FRTAMNT;
            HistReceivablesDocument."Misc. Amount" := GPRMHist.MISCAMNT;
            HistReceivablesDocument."Tax Amount" := GPRMHist.TAXAMNT;
            HistReceivablesDocument."Disc. Taken Amount" := GPRMHist.DISTKNAM;
            HistReceivablesDocument."Customer Purchase No." := GPRMHist.CSPORNBR;
            HistReceivablesDocument."Salesperson No." := GPRMHist.SLPRSNID;
            HistReceivablesDocument."Sales Territory" := GPRMHist.SLSTERCD;
            HistReceivablesDocument."Ship Method" := GPRMHist.SHIPMTHD;
            HistReceivablesDocument."Cash Amount" := GPRMHist.CASHAMNT;
            HistReceivablesDocument."Commission Dollar Amount" := GPRMHist.COMDLRAM;
            HistReceivablesDocument."Invoice Paid Off Date" := GPRMHist.DINVPDOF;
            HistReceivablesDocument."Payment Terms ID" := GPRMHist.PYMTRMID;
            HistReceivablesDocument."Write Off Amount" := GPRMHist.WROFAMNT;

            if HistReceivablesDocument.Insert() then begin
                PopulateRecvApply(HistReceivablesDocument."Customer No.", CustomerName, HistReceivablesDocument."Document No.", GPRMHist.RMDTYPAL);
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Receivables Trx.", GPRMHist.DOCNUMBR);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPRMHist.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulateRecvApply(CustomerNo: Code[35]; CustomerName: Text[100]; DocumentNo: Code[35]; GPDocumentTypeId: Integer)
    begin
        PopulateRecvOpenApply(CustomerNo, CustomerName, DocumentNo, GPDocumentTypeId);
        PopulateRecvHistApply(CustomerNo, CustomerName, DocumentNo, GPDocumentTypeId);
    end;

    local procedure PopulateRecvOpenApply(CustomerNo: Code[35]; CustomerName: Text[100]; DocumentNo: Code[35]; GPDocumentTypeId: Integer)
    var
        GPRM20201: Record "GP RM20201";
        GPRM30201: Record "GP RM30201";
        HistReceivablesApply: Record "Hist. Receivables Apply";
    begin
        GPRM20201.SetLoadFields(DEX_ROW_ID, ActualApplyToAmount, ActualDiscAvailTaken, ActualDiscTakenAmount, ActualWriteOffAmount, APFRDCDT, APFRDCNM, APFRDCTY, APFRMAPLYAMT, APFRMDENRATE, APFRMDISCAVAIL, APFRMDISCTAKEN, APFRMEXRATE, APFRMWROFAMT, ApplyFromGLPostDate, ApplyToGLPostDate, APPTOAMT, APTODCDT, APTODCNM, APTODCTY, APTODENRATE, APTOEXRATE, APYFRMRNDAMT, APYTORNDAMT, APYTORNDDISC, CPRCSTNM, CURNCYID, CUSTNMBR, DATE1, DISAVTKN, DISTKNAM, FROMCURR, GLPOSTDT, GSTDSAMT, OAPYFRMRNDAMT, OAPYTORNDAMT, OAPYTORNDDISC, ORAPTOAM, ORDATKN, ORDISTKN, ORWROFAM, PPSAMDED, RLGANLOS, Settled_Gain_CreditCurrT, Settled_Gain_DebitCurrTr, Settled_Gain_DebitDiscAv, Settled_Loss_CreditCurrT, Settled_Loss_DebitCurrTr, Settled_Loss_DebitDiscAv, TRXSORCE, WROFAMNT);
        GPRM20201.SetRange(CUSTNMBR, CustomerNo);
        GPRM20201.SetRange(APTODCTY, GPDocumentTypeId);
        GPRM20201.SetRange(APTODCNM, DocumentNo);

        if not GPRM20201.FindSet() then
            exit;

        repeat
            GPRM30201.SetLoadFields(DEX_ROW_ID);
            if not GPRM30201.Get(GPRM20201.APFRDCTY, GPRM20201.APFRDCNM, GPRM20201.APTODCTY, GPRM20201.APTODCNM) then begin
                Clear(HistReceivablesApply);

                HistReceivablesApply."Customer No." := GPRM20201.CUSTNMBR;
                HistReceivablesApply."Customer Name" := CustomerName;
                HistReceivablesApply."Corporate Customer No." := CopyStr(GPRM20201.CPRCSTNM.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Corporate Customer No."));
                HistReceivablesApply."Date" := DT2Date(GPRM20201.DATE1);
                HistReceivablesApply."GL Posting Date" := DT2Date(GPRM20201.GLPOSTDT);
                HistReceivablesApply."Apply To Document No." := GPRM20201.APTODCNM;
                HistReceivablesApply."Apply To Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM20201.APTODCTY);
                HistReceivablesApply."Apply To Document Date" := DT2Date(GPRM20201.APTODCDT);
                HistReceivablesApply."Apply To GL Posting Date" := DT2Date(GPRM20201.ApplyToGLPostDate);
                HistReceivablesApply."Currency Code" := CopyStr(GPRM20201.CURNCYID.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Currency Code"));
                HistReceivablesApply."Apply To Amount" := GPRM20201.APPTOAMT;
                HistReceivablesApply."Discount Taken Amount" := GPRM20201.DISTKNAM;
                HistReceivablesApply."Discount Available Taken" := GPRM20201.DISAVTKN;
                HistReceivablesApply."Write Off Amount" := GPRM20201.WROFAMNT;
                HistReceivablesApply."Orig. Apply To Amount" := GPRM20201.ORAPTOAM;
                HistReceivablesApply."Orig. Disc. Taken Amount" := GPRM20201.ORDISTKN;
                HistReceivablesApply."Orig. Disc. Available Taken" := GPRM20201.ORDATKN;
                HistReceivablesApply."Orig. Write Off Amount" := GPRM20201.ORWROFAM;
                HistReceivablesApply."Apply To Exchange Rate" := GPRM20201.APTOEXRATE;
                HistReceivablesApply."Apply To Denom. Exch. Rate" := GPRM20201.APTODENRATE;
                HistReceivablesApply."Apply From Document No." := GPRM20201.APFRDCNM;
                HistReceivablesApply."Apply From Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM20201.APFRDCTY);
                HistReceivablesApply."Apply From Document Date" := DT2Date(GPRM20201.APFRDCDT);
                HistReceivablesApply."Apply From GL Posting Date" := DT2Date(GPRM20201.ApplyFromGLPostDate);
                HistReceivablesApply."Apply From Currency Code" := CopyStr(GPRM20201.FROMCURR.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Apply From Currency Code"));
                HistReceivablesApply."Apply From Apply Amount" := GPRM20201.APFRMAPLYAMT;
                HistReceivablesApply."Apply From Disc. Taken Amount" := GPRM20201.APFRMDISCTAKEN;
                HistReceivablesApply."Apply From Disc. Avail. Taken" := GPRM20201.APFRMDISCAVAIL;
                HistReceivablesApply."Apply From Write Off Amount" := GPRM20201.APFRMWROFAMT;
                HistReceivablesApply."Actual Apply To Amount" := GPRM20201.ActualApplyToAmount;
                HistReceivablesApply."Actual Disc. Taken Amount" := GPRM20201.ActualDiscTakenAmount;
                HistReceivablesApply."Actual Disc. Avail. Taken" := GPRM20201.ActualDiscAvailTaken;
                HistReceivablesApply."Actual Write Off Amount" := GPRM20201.ActualWriteOffAmount;
                HistReceivablesApply."Apply From Exchange Rate" := GPRM20201.APFRMEXRATE;
                HistReceivablesApply."Apply From Denom. Exch. Rate" := GPRM20201.APFRMDENRATE;
                HistReceivablesApply."Apply From Round Amount" := GPRM20201.APYFRMRNDAMT;
                HistReceivablesApply."Apply To Round Amount" := GPRM20201.APYTORNDAMT;
                HistReceivablesApply."Apply To Round Discount" := GPRM20201.APYTORNDDISC;
                HistReceivablesApply."Orig. Apply From Round Amount" := GPRM20201.OAPYFRMRNDAMT;
                HistReceivablesApply."Orig. Apply To Round Amount" := GPRM20201.OAPYTORNDAMT;
                HistReceivablesApply."Orig. Apply To Round Discount" := GPRM20201.OAPYTORNDDISC;
                HistReceivablesApply."GST Discount Amount" := GPRM20201.GSTDSAMT;
                HistReceivablesApply."PPS Amount Deducted" := GPRM20201.PPSAMDED;
                HistReceivablesApply."Realized Gain-Loss Amount" := GPRM20201.RLGANLOS;
                HistReceivablesApply."Settled Gain CreditCurrTrx" := GPRM20201.Settled_Gain_CreditCurrT;
                HistReceivablesApply."Settled Loss CreditCurrTrx" := GPRM20201.Settled_Loss_CreditCurrT;
                HistReceivablesApply."Settled Gain DebitCurrTrx" := GPRM20201.Settled_Gain_DebitCurrTr;
                HistReceivablesApply."Settled Loss DebitCurrTrx" := GPRM20201.Settled_Loss_DebitCurrTr;
                HistReceivablesApply."Settled Gain DebitDiscAvail" := GPRM20201.Settled_Gain_DebitDiscAv;
                HistReceivablesApply."Settled Loss DebitDiscAvail" := GPRM20201.Settled_Loss_DebitDiscAv;
                HistReceivablesApply."Audit Code" := GPRM20201.TRXSORCE;

                if not HistReceivablesApply.Insert() then
                    ReportLastError(Database::"GP RM20201", GPRM20201.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Receivables Trx.", DocumentNo);

                AfterProcessedNextChildRecord();
            end;
        until GPRM20201.Next() = 0;
    end;

    local procedure PopulateRecvHistApply(CustomerNo: Code[35]; CustomerName: Text[100]; DocumentNo: Code[35]; GPDocumentTypeId: Integer)
    var
        GPRM30201: Record "GP RM30201";
        HistReceivablesApply: Record "Hist. Receivables Apply";
    begin
        GPRM30201.SetLoadFields(DEX_ROW_ID, ActualApplyToAmount, ActualDiscAvailTaken, ActualDiscTakenAmount, ActualWriteOffAmount, APFRDCDT, APFRDCNM, APFRDCTY, APFRMAPLYAMT, APFRMDENRATE, APFRMDISCAVAIL, APFRMDISCTAKEN, APFRMEXRATE, APFRMWROFAMT, ApplyFromGLPostDate, ApplyToGLPostDate, APPTOAMT, APTODCDT, APTODCNM, APTODCTY, APTODENRATE, APTOEXRATE, APYFRMRNDAMT, APYTORNDAMT, APYTORNDDISC, CPRCSTNM, CURNCYID, CUSTNMBR, DATE1, DISAVTKN, DISTKNAM, FROMCURR, GLPOSTDT, GSTDSAMT, OAPYFRMRNDAMT, OAPYTORNDAMT, OAPYTORNDDISC, ORAPTOAM, ORDATKN, ORDISTKN, ORWROFAM, PPSAMDED, RLGANLOS, Settled_Gain_CreditCurrT, Settled_Gain_DebitCurrTr, Settled_Gain_DebitDiscAv, Settled_Loss_CreditCurrT, Settled_Loss_DebitCurrTr, Settled_Loss_DebitDiscAv, TRXSORCE, WROFAMNT);
        GPRM30201.SetRange(CUSTNMBR, CustomerNo);
        GPRM30201.SetRange(APTODCTY, GPDocumentTypeId);
        GPRM30201.SetRange(APTODCNM, DocumentNo);

        if not GPRM30201.FindSet() then
            exit;

        repeat
            Clear(HistReceivablesApply);

            HistReceivablesApply."Customer No." := GPRM30201.CUSTNMBR;
            HistReceivablesApply."Customer Name" := CustomerName;
            HistReceivablesApply."Corporate Customer No." := CopyStr(GPRM30201.CPRCSTNM.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Corporate Customer No."));
            HistReceivablesApply."Date" := DT2Date(GPRM30201.DATE1);
            HistReceivablesApply."GL Posting Date" := DT2Date(GPRM30201.GLPOSTDT);
            HistReceivablesApply."Apply To Document No." := GPRM30201.APTODCNM;
            HistReceivablesApply."Apply To Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM30201.APTODCTY);
            HistReceivablesApply."Apply To Document Date" := DT2Date(GPRM30201.APTODCDT);
            HistReceivablesApply."Apply To GL Posting Date" := DT2Date(GPRM30201.ApplyToGLPostDate);
            HistReceivablesApply."Currency Code" := CopyStr(GPRM30201.CURNCYID.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Currency Code"));
            HistReceivablesApply."Apply To Amount" := GPRM30201.APPTOAMT;
            HistReceivablesApply."Discount Taken Amount" := GPRM30201.DISTKNAM;
            HistReceivablesApply."Discount Available Taken" := GPRM30201.DISAVTKN;
            HistReceivablesApply."Write Off Amount" := GPRM30201.WROFAMNT;
            HistReceivablesApply."Orig. Apply To Amount" := GPRM30201.ORAPTOAM;
            HistReceivablesApply."Orig. Disc. Taken Amount" := GPRM30201.ORDISTKN;
            HistReceivablesApply."Orig. Disc. Available Taken" := GPRM30201.ORDATKN;
            HistReceivablesApply."Orig. Write Off Amount" := GPRM30201.ORWROFAM;
            HistReceivablesApply."Apply To Exchange Rate" := GPRM30201.APTOEXRATE;
            HistReceivablesApply."Apply To Denom. Exch. Rate" := GPRM30201.APTODENRATE;
            HistReceivablesApply."Apply From Document No." := GPRM30201.APFRDCNM;
            HistReceivablesApply."Apply From Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM30201.APFRDCTY);
            HistReceivablesApply."Apply From Document Date" := DT2Date(GPRM30201.APFRDCDT);
            HistReceivablesApply."Apply From GL Posting Date" := DT2Date(GPRM30201.ApplyFromGLPostDate);
            HistReceivablesApply."Apply From Currency Code" := CopyStr(GPRM30201.FROMCURR.TrimEnd(), 1, MaxStrLen(HistReceivablesApply."Apply From Currency Code"));
            HistReceivablesApply."Apply From Apply Amount" := GPRM30201.APFRMAPLYAMT;
            HistReceivablesApply."Apply From Disc. Taken Amount" := GPRM30201.APFRMDISCTAKEN;
            HistReceivablesApply."Apply From Disc. Avail. Taken" := GPRM30201.APFRMDISCAVAIL;
            HistReceivablesApply."Apply From Write Off Amount" := GPRM30201.APFRMWROFAMT;
            HistReceivablesApply."Actual Apply To Amount" := GPRM30201.ActualApplyToAmount;
            HistReceivablesApply."Actual Disc. Taken Amount" := GPRM30201.ActualDiscTakenAmount;
            HistReceivablesApply."Actual Disc. Avail. Taken" := GPRM30201.ActualDiscAvailTaken;
            HistReceivablesApply."Actual Write Off Amount" := GPRM30201.ActualWriteOffAmount;
            HistReceivablesApply."Apply From Exchange Rate" := GPRM30201.APFRMEXRATE;
            HistReceivablesApply."Apply From Denom. Exch. Rate" := GPRM30201.APFRMDENRATE;
            HistReceivablesApply."Apply From Round Amount" := GPRM30201.APYFRMRNDAMT;
            HistReceivablesApply."Apply To Round Amount" := GPRM30201.APYTORNDAMT;
            HistReceivablesApply."Apply To Round Discount" := GPRM30201.APYTORNDDISC;
            HistReceivablesApply."Orig. Apply From Round Amount" := GPRM30201.OAPYFRMRNDAMT;
            HistReceivablesApply."Orig. Apply To Round Amount" := GPRM30201.OAPYTORNDAMT;
            HistReceivablesApply."Orig. Apply To Round Discount" := GPRM30201.OAPYTORNDDISC;
            HistReceivablesApply."GST Discount Amount" := GPRM30201.GSTDSAMT;
            HistReceivablesApply."PPS Amount Deducted" := GPRM30201.PPSAMDED;
            HistReceivablesApply."Realized Gain-Loss Amount" := GPRM30201.RLGANLOS;
            HistReceivablesApply."Settled Gain CreditCurrTrx" := GPRM30201.Settled_Gain_CreditCurrT;
            HistReceivablesApply."Settled Loss CreditCurrTrx" := GPRM30201.Settled_Loss_CreditCurrT;
            HistReceivablesApply."Settled Gain DebitCurrTrx" := GPRM30201.Settled_Gain_DebitCurrTr;
            HistReceivablesApply."Settled Loss DebitCurrTrx" := GPRM30201.Settled_Loss_DebitCurrTr;
            HistReceivablesApply."Settled Gain DebitDiscAvail" := GPRM30201.Settled_Gain_DebitDiscAv;
            HistReceivablesApply."Settled Loss DebitDiscAvail" := GPRM30201.Settled_Loss_DebitDiscAv;
            HistReceivablesApply."Audit Code" := GPRM30201.TRXSORCE;

            if not HistReceivablesApply.Insert() then
                ReportLastError(Database::"GP RM30201", GPRM30201.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Receivables Trx.", DocumentNo);

            AfterProcessedNextChildRecord();
        until GPRM30201.Next() = 0;
    end;

    local procedure PopulatePayablesDocuments()
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistAPTrx() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Payables Trx.", false);
        PopulatePayablesOpenDocuments();
        PopulatePayablesHistoricalDocuments();
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Payables Trx.", true);
    end;

    local procedure PopulatePayablesOpenDocuments()
    var
        GPPM20000: Record "GP PM20000";
        GPPM00200: Record "GP PM00200";
        HistPayablesDocument: Record "Hist. Payables Document";
        InitialHistYear: Integer;
        VendorName: Text[65];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::"GP PM20000";
        GPPM20000.SetLoadFields(DEX_ROW_ID, DOCDATE, VENDORID, DOCTYPE, DOCNUMBR, VCHRNMBR, DOCAMNT, CURNCYID, CURTRXAM, DISTKNAM, BCHSOURC, BACHNUMB, DUEDATE, PORDNMBR, TRXSORCE, TRXDSCRN, POSTEDDT, PTDUSRID, MSCCHAMT, FRTAMNT, TAXAMNT, TTLPYMTS, VOIDED, DINVPDOF, SHIPMTHD, TEN99AMNT, WROFAMNT, TRDISAMT, PYMTRMID, TEN99TYPE, TEN99BOXNUMBER, PONUMBER);
        GPPM20000.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPPM20000.SetCurrentKey(DEX_ROW_ID);
        GPPM20000.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPM20000.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPM20000.FindSet() then
            exit;

        repeat
            LastSourceRecordId := GPPM20000.DEX_ROW_ID;
            Clear(HistPayablesDocument);

            if GPPM00200.Get(GPPM20000.VENDORID) then
                VendorName := GPPM00200.VENDNAME;

#pragma warning disable AA0139
            HistPayablesDocument."Document No." := GPPM20000.DOCNUMBR.TrimEnd();
            HistPayablesDocument."Voucher No." := GPPM20000.VCHRNMBR.TrimEnd();
            HistPayablesDocument."Vendor No." := GPPM20000.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPayablesDocument."Vendor Name" := VendorName;
            HistPayablesDocument."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM20000.DOCTYPE);
            HistPayablesDocument."Document Date" := GPPM20000.DOCDATE;
            HistPayablesDocument."Document Amount" := GPPM20000.DOCAMNT;
            HistPayablesDocument."Currency Code" := CopyStr(GPPM20000.CURNCYID, 1, MaxStrLen(HistPayablesDocument."Currency Code"));
            HistPayablesDocument."Current Trx. Amount" := GPPM20000.CURTRXAM;
            HistPayablesDocument."Disc. Taken Amount" := GPPM20000.DISTKNAM;
            HistPayablesDocument."Batch Source" := GPPM20000.BCHSOURC;
            HistPayablesDocument."Batch No." := GPPM20000.BACHNUMB;
            HistPayablesDocument."Due Date" := GPPM20000.DUEDATE;
            HistPayablesDocument."Purchase No." := GPPM20000.PORDNMBR;
            HistPayablesDocument."Audit Code" := GPPM20000.TRXSORCE;
            HistPayablesDocument."Trx. Description" := GPPM20000.TRXDSCRN;
            HistPayablesDocument."Post Date" := DT2Date(GPPM20000.POSTEDDT);
            HistPayablesDocument."User" := GPPM20000.PTDUSRID;
            HistPayablesDocument."Misc. Amount" := GPPM20000.MSCCHAMT;
            HistPayablesDocument."Freight Amount" := GPPM20000.FRTAMNT;
            HistPayablesDocument."Tax Amount" := GPPM20000.TAXAMNT;
            HistPayablesDocument."Total Payments" := GPPM20000.TTLPYMTS;
            HistPayablesDocument."Voided" := GPPM20000.VOIDED;
            HistPayablesDocument."Invoice Paid Off Date" := DT2Date(GPPM20000.DINVPDOF);
            HistPayablesDocument."Ship Method" := GPPM20000.SHIPMTHD;
            HistPayablesDocument."1099 Amount" := GPPM20000.TEN99AMNT;
            HistPayablesDocument."Write Off Amount" := GPPM20000.WROFAMNT;
            HistPayablesDocument."Trade Discount Amount" := GPPM20000.TRDISAMT;
            HistPayablesDocument."Payment Terms ID" := GPPM20000.PYMTRMID;
            HistPayablesDocument."1099 Type" := Get1099TypeText(GPPM20000.TEN99TYPE);
            HistPayablesDocument."1099 Box Number" := Format(GPPM20000.TEN99BOXNUMBER);
            HistPayablesDocument."PO Number" := GPPM20000.PONUMBER;

            if HistPayablesDocument.Insert() then begin
                PopulatePayablesApply(HistPayablesDocument."Vendor No.", VendorName, HistPayablesDocument."Voucher No.", GPPM20000.DOCTYPE);
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Payables Trx.", GPPM20000.DOCNUMBR);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPPM20000.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulatePayablesHistoricalDocuments()
    var
        GPPMHist: Record GPPMHist;
        GPPM00200: Record "GP PM00200";
        HistPayablesDocument: Record "Hist. Payables Document";
        InitialHistYear: Integer;
        VendorName: Text[65];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        SourceTableId := Database::GPPMHist;
        GPPMHist.SetLoadFields(DEX_ROW_ID, DOCDATE, VENDORID, DOCTYPE, DOCNUMBR, VCHRNMBR, DOCAMNT, CURNCYID, CURTRXAM, DISTKNAM, BCHSOURC, BACHNUMB, DUEDATE, PORDNMBR, TRXSORCE, TRXDSCRN, POSTEDDT, PTDUSRID, MSCCHAMT, FRTAMNT, TAXAMNT, TTLPYMTS, VOIDED, DINVPDOF, SHIPMTHD, TEN99AMNT, WROFAMNT, TRDISAMT, PYMTRMID, TEN99TYPE, TEN99BOXNUMBER, PONUMBER);
        GPPMHist.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPPMHist.SetCurrentKey(DEX_ROW_ID);
        GPPMHist.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPMHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPMHist.FindSet() then
            exit;

        repeat
            LastSourceRecordId := GPPMHist.DEX_ROW_ID;
            Clear(HistPayablesDocument);

            if GPPM00200.Get(GPPMHist.VENDORID) then
                VendorName := GPPM00200.VENDNAME;

#pragma warning disable AA0139
            HistPayablesDocument."Document No." := GPPMHist.DOCNUMBR.TrimEnd();
            HistPayablesDocument."Voucher No." := GPPMHist.VCHRNMBR.TrimEnd();
            HistPayablesDocument."Vendor No." := GPPMHist.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPayablesDocument."Vendor Name" := VendorName;
            HistPayablesDocument."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPMHist.DOCTYPE);
            HistPayablesDocument."Document Date" := GPPMHist.DOCDATE;
            HistPayablesDocument."Document Amount" := GPPMHist.DOCAMNT;
            HistPayablesDocument."Currency Code" := CopyStr(GPPMHist.CURNCYID, 1, MaxStrLen(HistPayablesDocument."Currency Code"));
            HistPayablesDocument."Current Trx. Amount" := GPPMHist.CURTRXAM;
            HistPayablesDocument."Disc. Taken Amount" := GPPMHist.DISTKNAM;
            HistPayablesDocument."Batch Source" := GPPMHist.BCHSOURC;
            HistPayablesDocument."Batch No." := GPPMHist.BACHNUMB;
            HistPayablesDocument."Due Date" := GPPMHist.DUEDATE;
            HistPayablesDocument."Purchase No." := GPPMHist.PORDNMBR;
            HistPayablesDocument."Audit Code" := GPPMHist.TRXSORCE;
            HistPayablesDocument."Trx. Description" := GPPMHist.TRXDSCRN;
            HistPayablesDocument."Post Date" := GPPMHist.POSTEDDT;
            HistPayablesDocument."User" := GPPMHist.PTDUSRID;
            HistPayablesDocument."Misc. Amount" := GPPMHist.MSCCHAMT;
            HistPayablesDocument."Freight Amount" := GPPMHist.FRTAMNT;
            HistPayablesDocument."Tax Amount" := GPPMHist.TAXAMNT;
            HistPayablesDocument."Total Payments" := GPPMHist.TTLPYMTS;
            HistPayablesDocument."Voided" := GPPMHist.VOIDED;
            HistPayablesDocument."Invoice Paid Off Date" := GPPMHist.DINVPDOF;
            HistPayablesDocument."Ship Method" := GPPMHist.SHIPMTHD;
            HistPayablesDocument."1099 Amount" := GPPMHist.TEN99AMNT;
            HistPayablesDocument."Write Off Amount" := GPPMHist.WROFAMNT;
            HistPayablesDocument."Trade Discount Amount" := GPPMHist.TRDISAMT;
            HistPayablesDocument."Payment Terms ID" := GPPMHist.PYMTRMID;
            HistPayablesDocument."1099 Type" := Get1099TypeText(GPPMHist.TEN99TYPE);
            HistPayablesDocument."1099 Box Number" := Format(GPPMHist.TEN99BOXNUMBER);
            HistPayablesDocument."PO Number" := GPPMHist.PONUMBER;

            if HistPayablesDocument.Insert() then begin
                PopulatePayablesApply(HistPayablesDocument."Vendor No.", VendorName, HistPayablesDocument."Voucher No.", GPPMHist.DOCTYPE);
                ReportLastSuccess(SourceTableId, LastSourceRecordId)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Payables Trx.", GPPMHist.DOCNUMBR);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPPMHist.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
    end;

    local procedure PopulatePayablesApply(VendorNo: Code[35]; VendorName: Text[65]; VoucherNo: Code[35]; GPDocumentTypeId: Integer)
    begin
        PopulatePayablesOpenApply(VendorNo, VendorName, VoucherNo, GPDocumentTypeId);
        PopulatePayablesHistApply(VendorNo, VendorName, VoucherNo, GPDocumentTypeId);
    end;

    local procedure PopulatePayablesOpenApply(VendorNo: Code[35]; VendorName: Text[65]; VoucherNo: Code[35]; GPDocumentTypeId: Integer)
    var
        GPPM10200: Record "GP PM10200";
        GPPM30300: Record "GP PM30300";
        HistPayablesApply: Record "Hist. Payables Apply";
    begin
        GPPM10200.SetLoadFields(DEX_ROW_ID, ActualApplyToAmount, ActualDiscAvailTaken, ActualDiscTakenAmount, ActualWriteOffAmount, APFRDCNM, APFRMAPLYAMT, APFRMDENRATE, APFRMDISCAVAIL, APFRMDISCTAKEN, APFRMEXRATE, APFRMWROFAMT, APPLDAMT, ApplyFromGLPostDate, ApplyToGLPostDate, APTODCDT, APTODCNM, APTODCTY, APTVCHNM, Credit1099Amount, CURNCYID, DISTKNAM, DOCTYPE, FROMCURR, GSTDSAMT, ORAPPAMT, ORDATKN, ORDISTKN, ORWROFAM, PPSAMDED, TEN99AMNT, VCHRNMBR, VENDORID, WROFAMNT);
        GPPM10200.SetRange(VENDORID, VendorNo);
        GPPM10200.SetRange(DOCTYPE, GPDocumentTypeId);
        GPPM10200.SetRange(VCHRNMBR, VoucherNo);
        GPPM10200.SetRange(POSTED, true);

        if not GPPM10200.FindSet() then
            exit;

        repeat
            GPPM30300.SetLoadFields(DEX_ROW_ID);
            if not GPPM30300.Get(GPPM10200.APTVCHNM, GPPM10200.APTODCTY, GPPM10200.VCHRNMBR, GPPM10200.DOCTYPE) then begin
                Clear(HistPayablesApply);

                HistPayablesApply."Vendor No." := GPPM10200.VENDORID;
                HistPayablesApply."Vendor Name" := VendorName;
                HistPayablesApply."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM10200.DOCTYPE);
#pragma warning disable AA0139
                HistPayablesApply."Apply To Voucher No." := GPPM10200.APTVCHNM.TrimEnd();
                HistPayablesApply."Apply To Document No." := GPPM10200.APTODCNM.TrimEnd();
                HistPayablesApply."Voucher No." := GPPM10200.VCHRNMBR.TrimEnd();
#pragma warning restore AA0139
                HistPayablesApply."Apply To Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM10200.APTODCTY);
                HistPayablesApply."Apply To Document Date" := DT2Date(GPPM10200.APTODCDT);
                HistPayablesApply."Document Amount" := GPPM10200.APPLDAMT;
                HistPayablesApply."Currency Code" := CopyStr(GPPM10200.CURNCYID.TrimEnd(), 1, MaxStrLen(HistPayablesApply."Currency Code"));
                HistPayablesApply."Disc. Taken Amount" := GPPM10200.DISTKNAM;
                HistPayablesApply."Write Off Amount" := GPPM10200.WROFAMNT;
                HistPayablesApply."Orig. Applied Amount" := GPPM10200.ORAPPAMT;
                HistPayablesApply."Orig. Discount Taken Amount" := GPPM10200.ORDISTKN;
                HistPayablesApply."Orig. Discount Available Taken" := GPPM10200.ORDATKN;
                HistPayablesApply."Orig. Write Off Amount" := GPPM10200.ORWROFAM;
                HistPayablesApply."Apply To Post Date" := DT2Date(GPPM10200.ApplyToGLPostDate);
                HistPayablesApply."Apply From Document No." := GPPM10200.APFRDCNM;
                HistPayablesApply."Apply From GL Posting Date" := DT2Date(GPPM10200.ApplyFromGLPostDate);
                HistPayablesApply."Apply From Currency Code" := CopyStr(GPPM10200.FROMCURR.TrimEnd(), 1, MaxStrLen(HistPayablesApply."Apply From Currency Code"));
                HistPayablesApply."Apply From Apply Amount" := GPPM10200.APFRMAPLYAMT;
                HistPayablesApply."Apply From Disc. Taken Amount" := GPPM10200.APFRMDISCTAKEN;
                HistPayablesApply."Apply From Disc. Avail. Taken" := GPPM10200.APFRMDISCAVAIL;
                HistPayablesApply."Apply From Write Off Amount" := GPPM10200.APFRMWROFAMT;
                HistPayablesApply."Actual Apply To Amount" := GPPM10200.ActualApplyToAmount;
                HistPayablesApply."Actual Discount Taken Amount" := GPPM10200.ActualDiscTakenAmount;
                HistPayablesApply."Actual Disc. Available Taken" := GPPM10200.ActualDiscAvailTaken;
                HistPayablesApply."Actual Write Off Amount" := GPPM10200.ActualWriteOffAmount;
                HistPayablesApply."Apply From Exchange Rate" := GPPM10200.APFRMEXRATE;
                HistPayablesApply."Apply From Denom. Exch. Rate" := GPPM10200.APFRMDENRATE;
                HistPayablesApply."PPS Amount Deducted" := GPPM10200.PPSAMDED;
                HistPayablesApply."GST Discount Amount" := GPPM10200.GSTDSAMT;
                HistPayablesApply."1099 Amount" := GPPM10200.TEN99AMNT;
                HistPayablesApply."Credit 1099 Amount" := GPPM10200.Credit1099Amount;

                if not HistPayablesApply.Insert() then
                    ReportLastError(Database::"GP PM10200", GPPM10200.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Payables Trx.", VoucherNo);

                AfterProcessedNextChildRecord();
            end;
        until GPPM10200.Next() = 0;
    end;

    local procedure PopulatePayablesHistApply(VendorNo: Code[35]; VendorName: Text[65]; VoucherNo: Code[35]; GPDocumentTypeId: Integer)
    var
        GPPM30300: Record "GP PM30300";
        HistPayablesApply: Record "Hist. Payables Apply";
    begin
        GPPM30300.SetLoadFields(DEX_ROW_ID, ActualApplyToAmount, ActualDiscAvailTaken, ActualDiscTakenAmount, ActualWriteOffAmount, APFRDCNM, APFRMAPLYAMT, APFRMDENRATE, APFRMDISCAVAIL, APFRMDISCTAKEN, APFRMEXRATE, APFRMWROFAMT, APPLDAMT, ApplyFromGLPostDate, ApplyToGLPostDate, APTODCDT, APTODCNM, APTODCTY, APTVCHNM, Credit1099Amount, CURNCYID, DISTKNAM, DOCTYPE, FROMCURR, GSTDSAMT, ORAPPAMT, ORDATKN, ORDISTKN, ORWROFAM, PPSAMDED, TEN99AMNT, VCHRNMBR, VENDORID, WROFAMNT);
        GPPM30300.SetRange(VENDORID, VendorNo);
        GPPM30300.SetRange(DOCTYPE, GPDocumentTypeId);
        GPPM30300.SetRange(VCHRNMBR, VoucherNo);
        GPPM30300.SetRange(POSTED, true);

        if not GPPM30300.FindSet() then
            exit;

        repeat
            Clear(HistPayablesApply);

            HistPayablesApply."Vendor No." := GPPM30300.VENDORID;
            HistPayablesApply."Vendor Name" := VendorName;
            HistPayablesApply."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM30300.DOCTYPE);
#pragma warning disable AA0139
            HistPayablesApply."Apply To Voucher No." := GPPM30300.APTVCHNM.TrimEnd();
            HistPayablesApply."Apply To Document No." := GPPM30300.APTODCNM.TrimEnd();
            HistPayablesApply."Voucher No." := GPPM30300.VCHRNMBR.TrimEnd();
#pragma warning restore AA0139
            HistPayablesApply."Currency Code" := CopyStr(GPPM30300.CURNCYID.TrimEnd(), 1, MaxStrLen(HistPayablesApply."Currency Code"));
            HistPayablesApply."Apply To Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM30300.APTODCTY);
            HistPayablesApply."Apply To Document Date" := DT2Date(GPPM30300.APTODCDT);
            HistPayablesApply."Document Amount" := GPPM30300.APPLDAMT;
            HistPayablesApply."Disc. Taken Amount" := GPPM30300.DISTKNAM;
            HistPayablesApply."Write Off Amount" := GPPM30300.WROFAMNT;
            HistPayablesApply."Orig. Applied Amount" := GPPM30300.ORAPPAMT;
            HistPayablesApply."Orig. Discount Taken Amount" := GPPM30300.ORDISTKN;
            HistPayablesApply."Orig. Discount Available Taken" := GPPM30300.ORDATKN;
            HistPayablesApply."Orig. Write Off Amount" := GPPM30300.ORWROFAM;
            HistPayablesApply."Apply To Post Date" := DT2Date(GPPM30300.ApplyToGLPostDate);
            HistPayablesApply."Apply From Document No." := GPPM30300.APFRDCNM;
            HistPayablesApply."Apply From GL Posting Date" := DT2Date(GPPM30300.ApplyFromGLPostDate);
            HistPayablesApply."Apply From Currency Code" := CopyStr(GPPM30300.FROMCURR.TrimEnd(), 1, MaxStrLen(HistPayablesApply."Apply From Currency Code"));
            HistPayablesApply."Apply From Apply Amount" := GPPM30300.APFRMAPLYAMT;
            HistPayablesApply."Apply From Disc. Taken Amount" := GPPM30300.APFRMDISCTAKEN;
            HistPayablesApply."Apply From Disc. Avail. Taken" := GPPM30300.APFRMDISCAVAIL;
            HistPayablesApply."Apply From Write Off Amount" := GPPM30300.APFRMWROFAMT;
            HistPayablesApply."Actual Apply To Amount" := GPPM30300.ActualApplyToAmount;
            HistPayablesApply."Actual Discount Taken Amount" := GPPM30300.ActualDiscTakenAmount;
            HistPayablesApply."Actual Disc. Available Taken" := GPPM30300.ActualDiscAvailTaken;
            HistPayablesApply."Actual Write Off Amount" := GPPM30300.ActualWriteOffAmount;
            HistPayablesApply."Apply From Exchange Rate" := GPPM30300.APFRMEXRATE;
            HistPayablesApply."Apply From Denom. Exch. Rate" := GPPM30300.APFRMDENRATE;
            HistPayablesApply."PPS Amount Deducted" := GPPM30300.PPSAMDED;
            HistPayablesApply."GST Discount Amount" := GPPM30300.GSTDSAMT;
            HistPayablesApply."1099 Amount" := GPPM30300.TEN99AMNT;
            HistPayablesApply."Credit 1099 Amount" := GPPM30300.Credit1099Amount;

            if not HistPayablesApply.Insert() then
                ReportLastError(Database::"GP PM30300", GPPM30300.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Payables Trx.", VoucherNo);

            AfterProcessedNextChildRecord();
        until GPPM30300.Next() = 0;
    end;

    local procedure PopulateInventoryTransactions()
    var
        GPIVTrxHist: Record GPIVTrxHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        InitialHistYear: Integer;
        DocumentNo: Code[35];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        SourceTableId := Database::GPIVTrxHist;
        GPIVTrxHist.SetLoadFields(DEX_ROW_ID, DOCDATE, TRXSORCE, IVDOCTYP, DOCDATE, BACHNUMB, BCHSOURC, GLPOSTDT, SRCRFRNCNMBR, SOURCEINDICATOR);
        GPIVTrxHist.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPIVTrxHist.SetCurrentKey(DEX_ROW_ID);
        GPIVTrxHist.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPIVTrxHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPIVTrxHist.FindSet() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Inventory Trx.", false);

        repeat
            LastSourceRecordId := GPIVTrxHist.DEX_ROW_ID;
            Clear(HistInventoryTrxHeader);

#pragma warning disable AA0139
            DocumentNo := GPIVTrxHist.DOCNUMBR.TrimEnd();
#pragma warning restore AA0139

            HistInventoryTrxHeader."Audit Code" := GPIVTrxHist.TRXSORCE;
            HistInventoryTrxHeader."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxHist.IVDOCTYP);
            HistInventoryTrxHeader."Document No." := DocumentNo;
            HistInventoryTrxHeader."Document Date" := GPIVTrxHist.DOCDATE;
            HistInventoryTrxHeader."Batch No." := GPIVTrxHist.BACHNUMB;
            HistInventoryTrxHeader."Batch Source" := GPIVTrxHist.BCHSOURC;
            HistInventoryTrxHeader."Post Date" := GPIVTrxHist.GLPOSTDT;
            HistInventoryTrxHeader."Source Reference No." := GPIVTrxHist.SRCRFRNCNMBR;
            HistInventoryTrxHeader."Source Indicator" := GetInventoryTrxSourceIndicatorText(GPIVTrxHist.SOURCEINDICATOR);

            if HistInventoryTrxHeader.Insert() then begin
                ReportLastSuccess(SourceTableId, LastSourceRecordId);
                PopulateInventoryTrxLines(GPIVTrxHist.TRXSORCE, DocumentNo)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Inventory Trx.", GPIVTrxHist.DOCNUMBR);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPIVTrxHist.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Inventory Trx.", true);
    end;

    local procedure PopulateInventoryTrxLines(AuditCode: Text[14]; DocumentNo: Code[35])
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxLine: Record "Hist. Inventory Trx. Line";
    begin
        GPIVTrxAmountsHist.SetLoadFields(DEX_ROW_ID, TRXSORCE, DOCNUMBR, ITEMNMBR, CUSTNMBR, DOCTYPE, LNSEQNBR, DOCDATE, HSTMODUL, UOFM, TRXQTY, UNITCOST, EXTDCOST, TRXLOCTN, TRNSTLOC, Reason_Code);
        GPIVTrxAmountsHist.SetRange(TRXSORCE, AuditCode);
        GPIVTrxAmountsHist.SetRange(DOCNUMBR, DocumentNo);

        if not GPIVTrxAmountsHist.FindSet() then
            exit;

        repeat
            Clear(HistInventoryTrxLine);

#pragma warning disable AA0139
            HistInventoryTrxLine."Item No." := GPIVTrxAmountsHist.ITEMNMBR.TrimEnd();
            HistInventoryTrxLine."Customer No." := GPIVTrxAmountsHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistInventoryTrxLine."Audit Code" := GPIVTrxAmountsHist.TRXSORCE;
            HistInventoryTrxLine."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);
            HistInventoryTrxLine."Document No." := DocumentNo;
            HistInventoryTrxLine."Line Item Sequence" := GPIVTrxAmountsHist.LNSEQNBR;
            HistInventoryTrxLine."Date" := GPIVTrxAmountsHist.DOCDATE;
            HistInventoryTrxLine."Source Description" := GPIVTrxAmountsHist.HSTMODUL;
            HistInventoryTrxLine."Unit of Measure" := GPIVTrxAmountsHist.UOFM;
            HistInventoryTrxLine."Quantity" := GPIVTrxAmountsHist.TRXQTY;
            HistInventoryTrxLine."Unit Cost" := GPIVTrxAmountsHist.UNITCOST;
            HistInventoryTrxLine."Ext. Cost" := GPIVTrxAmountsHist.EXTDCOST;
            HistInventoryTrxLine."Location Code" := GPIVTrxAmountsHist.TRXLOCTN;
            HistInventoryTrxLine."Transfer To Location Code" := GPIVTrxAmountsHist.TRNSTLOC;
            HistInventoryTrxLine."Reason Code" := GPIVTrxAmountsHist.Reason_Code;

            if not HistInventoryTrxLine.Insert() then
                ReportLastError(Database::GPIVTrxAmountsHist, GPIVTrxAmountsHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

            AfterProcessedNextChildRecord();
        until GPIVTrxAmountsHist.Next() = 0;
    end;

    local procedure PopulateAssemblyItemTransactions()
    var
        GPBM30200: Record "GP BM30200";
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        InitialHistYear: Integer;
        DocumentNo: Code[35];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        SourceTableId := Database::"GP BM30200";
        GPBM30200.SetLoadFields(DEX_ROW_ID, TRXDATE, TRX_ID, TRXSORCE, BACHNUMB, BCHSOURC, PSTGDATE, REFRENCE);
        GPBM30200.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPBM30200.SetCurrentKey(DEX_ROW_ID);
        GPBM30200.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPBM30200.SetFilter(TRXDATE, '>=%1', System.CreateDateTime(System.DMY2Date(1, 1, InitialHistYear), 0T));

        if not GPBM30200.FindSet() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Inventory Trx.", false);

        repeat
            LastSourceRecordId := GPBM30200.DEX_ROW_ID;
            Clear(HistInventoryTrxHeader);

#pragma warning disable AA0139
            DocumentNo := GPBM30200.TRX_ID.TrimEnd();
#pragma warning restore AA0139

            HistInventoryTrxHeader."Audit Code" := GPBM30200.TRXSORCE;
            HistInventoryTrxHeader."Document Type" := "Hist. Inventory Doc. Type"::"Assembly";
            HistInventoryTrxHeader."Document No." := DocumentNo;
            HistInventoryTrxHeader."Document Date" := System.DT2Date(GPBM30200.TRXDATE);
            HistInventoryTrxHeader."Batch No." := GPBM30200.BACHNUMB;
            HistInventoryTrxHeader."Batch Source" := GPBM30200.BCHSOURC;
            HistInventoryTrxHeader."Post Date" := System.DT2Date(GPBM30200.PSTGDATE);
            HistInventoryTrxHeader."Source Reference No." := GPBM30200.REFRENCE;

            if HistInventoryTrxHeader.Insert() then begin
                ReportLastSuccess(SourceTableId, LastSourceRecordId);
                PopulateInventoryTrxLines(GPBM30200.TRXSORCE, DocumentNo)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPBM30200.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Inventory Trx.", true);
    end;

    local procedure PopulatePurchaseRecvTransactions()
    var
        GPPOPReceiptHist: Record GPPOPReceiptHist;
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
        InitialHistYear: Integer;
        ReceiptNo: Code[35];
        SourceTableId: Integer;
        LastSourceRecordId: Integer;
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistPurchTrx() then
            exit;

        SourceTableId := Database::GPPOPReceiptHist;
        GPPOPReceiptHist.SetLoadFields(DEX_ROW_ID, receiptdate, POPRCTNM, VENDORID, VENDNAME, POPTYPE, VNDDOCNM, GLPOSTDT, ACTLSHIP, BACHNUMB, SUBTOTAL, TRDISAMT, FRTAMNT, MISCAMNT, TAXAMNT, TEN99AMNT, PYMTRMID, DSCPCTAM, DSCDLRAM, DISAVAMT, DISCDATE, DUEDATE, REFRENCE, VOIDSTTS, PTDUSRID, TRXSORCE, VCHRNMBR, CURNCYID, InvoiceReceiptDate, PrepaymentAmount);
        GPPOPReceiptHist.SetFilter(DEX_ROW_ID, GetSourceTableRecIdFilter(SourceTableId));
        GPPOPReceiptHist.SetCurrentKey(DEX_ROW_ID);
        GPPOPReceiptHist.SetAscending(DEX_ROW_ID, true);

        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPOPReceiptHist.SetFilter("receiptdate", '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPOPReceiptHist.FindSet() then
            exit;

        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Purchase Receivables Trx.", false);

        repeat
            LastSourceRecordId := GPPOPReceiptHist.DEX_ROW_ID;
            Clear(HistPurchaseRecvHeader);

#pragma warning disable AA0139
            ReceiptNo := GPPOPReceiptHist.POPRCTNM.TrimEnd();
            HistPurchaseRecvHeader."Vendor No." := GPPOPReceiptHist.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPurchaseRecvHeader."Vendor Name" := GPPOPReceiptHist.VENDNAME;
            HistPurchaseRecvHeader."Receipt No." := ReceiptNo;
            HistPurchaseRecvHeader."Document Type" := ConvertGPDocTypeToHistPurchaseRecvDocType(GPPOPReceiptHist.POPTYPE);
            HistPurchaseRecvHeader."Vendor Document No." := GPPOPReceiptHist.VNDDOCNM;
            HistPurchaseRecvHeader."Receipt Date" := GPPOPReceiptHist.receiptdate;
            HistPurchaseRecvHeader."Post Date" := GPPOPReceiptHist.GLPOSTDT;
            HistPurchaseRecvHeader."Actual Ship Date" := GPPOPReceiptHist.ACTLSHIP;
            HistPurchaseRecvHeader."Batch No." := GPPOPReceiptHist.BACHNUMB;
            HistPurchaseRecvHeader."Vendor Name" := GPPOPReceiptHist.VENDNAME;
            HistPurchaseRecvHeader."Subtotal" := GPPOPReceiptHist.SUBTOTAL;
            HistPurchaseRecvHeader."Trade Discount Amount" := GPPOPReceiptHist.TRDISAMT;
            HistPurchaseRecvHeader."Freight Amount" := GPPOPReceiptHist.FRTAMNT;
            HistPurchaseRecvHeader."Misc. Amount" := GPPOPReceiptHist.MISCAMNT;
            HistPurchaseRecvHeader."Tax Amount" := GPPOPReceiptHist.TAXAMNT;
            HistPurchaseRecvHeader."1099 Amount" := GPPOPReceiptHist.TEN99AMNT;
            HistPurchaseRecvHeader."Payment Terms ID" := GPPOPReceiptHist.PYMTRMID;
            HistPurchaseRecvHeader."Discount Percent Amount" := GPPOPReceiptHist.DSCPCTAM;
            HistPurchaseRecvHeader."Discount Dollar Amount" := GPPOPReceiptHist.DSCDLRAM;
            HistPurchaseRecvHeader."Discount Available Amount" := GPPOPReceiptHist.DISAVAMT;
            HistPurchaseRecvHeader."Discount Date" := GPPOPReceiptHist.DISCDATE;
            HistPurchaseRecvHeader."Due Date" := GPPOPReceiptHist.DUEDATE;
            HistPurchaseRecvHeader."Reference" := GPPOPReceiptHist.REFRENCE;
            HistPurchaseRecvHeader."Void" := ConvertGPVoidOptionToBoolean(GPPOPReceiptHist.VOIDSTTS);
            HistPurchaseRecvHeader."User" := GPPOPReceiptHist.PTDUSRID;
            HistPurchaseRecvHeader."Audit Code" := GPPOPReceiptHist.TRXSORCE;
            HistPurchaseRecvHeader."Voucher No." := GPPOPReceiptHist.VCHRNMBR;
            HistPurchaseRecvHeader."Currency Code" := GPPOPReceiptHist.CURNCYID;
            HistPurchaseRecvHeader."Invoice Receipt Date" := GPPOPReceiptHist.InvoiceReceiptDate;
            HistPurchaseRecvHeader."Prepayment Amount" := GPPOPReceiptHist.PrepaymentAmount;

            if HistPurchaseRecvHeader.Insert() then begin
                ReportLastSuccess(SourceTableId, LastSourceRecordId);
                PopulatePurchaseRecvLines(GPPOPReceiptHist, ReceiptNo);
                PopulatePOPItemTransaction(GPPOPReceiptHist)
            end else
                ReportLastError(SourceTableId, LastSourceRecordId, "Hist. Migration Step Type"::"GP Purchase Receivables Trx.", GPPOPReceiptHist.POPRCTNM);

            AfterProcessedNextRecord(SourceTableId, LastSourceRecordId);
        until GPPOPReceiptHist.Next() = 0;

        AfterProcessedSection(SourceTableId, LastSourceRecordId);
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP Purchase Receivables Trx.", true);
    end;

    local procedure PopulatePurchaseRecvLines(var GPPOPReceiptHist: Record GPPOPReceiptHist; ReceiptNo: Code[35])
    var
        GPPOPReceiptLineHist: Record GPPOPReceiptLineHist;
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        HistPurchaseRecvLine: Record "Hist. Purchase Recv. Line";
    begin
        GPPOPReceiptLineHist.SetLoadFields(DEX_ROW_ID, POPRCTNM, PONUMBER, ITEMNMBR, RCPTLNNM, ITEMDESC, VNDITNUM, VNDITDSC, UMQTYINB, ACTLSHIP, UOFM, UNITCOST, EXTDCOST, TAXAMNT, LOCNCODE, TRXSORCE, SHIPMTHD, ORUNTCST, OREXTCST, ORDISTKN, ORTDISAM, ORFRTAMT, ORMISCAMT);
        GPPOPReceiptLineHist.SetRange(POPRCTNM, GPPOPReceiptHist.POPRCTNM);

        if not GPPOPReceiptLineHist.FindSet() then
            exit;

        repeat
            Clear(HistPurchaseRecvLine);

#pragma warning disable AA0139
            HistPurchaseRecvLine."PO Number" := GPPOPReceiptLineHist.PONUMBER.TrimEnd();
            HistPurchaseRecvLine."Item No." := GPPOPReceiptLineHist.ITEMNMBR.TrimEnd();
#pragma warning restore AA0139

            HistPurchaseRecvLine."Receipt No." := ReceiptNo;
            HistPurchaseRecvLine."Line No." := GPPOPReceiptLineHist.RCPTLNNM;
            HistPurchaseRecvLine."Item Desc." := CopyStr(GPPOPReceiptLineHist.ITEMDESC, 1, MaxStrLen(HistPurchaseRecvLine."Item Desc."));
            HistPurchaseRecvLine."Vendor Item No." := GPPOPReceiptLineHist.VNDITNUM;
            HistPurchaseRecvLine."Vendor Item Desc." := CopyStr(GPPOPReceiptLineHist.VNDITDSC, 1, MaxStrLen(HistPurchaseRecvLine."Vendor Item Desc."));
            HistPurchaseRecvLine."Base UofM Qty." := GPPOPReceiptLineHist.UMQTYINB;
            HistPurchaseRecvLine."Actual Ship Date" := GPPOPReceiptLineHist.ACTLSHIP;
            HistPurchaseRecvLine."Unit of Measure" := GPPOPReceiptLineHist.UOFM;
            HistPurchaseRecvLine."Unit Cost" := GPPOPReceiptLineHist.UNITCOST;
            HistPurchaseRecvLine."Ext. Cost" := GPPOPReceiptLineHist.EXTDCOST;
            HistPurchaseRecvLine."Tax Amount" := GPPOPReceiptLineHist.TAXAMNT;
            HistPurchaseRecvLine."Location Code" := GPPOPReceiptLineHist.LOCNCODE;
            HistPurchaseRecvLine."Audit Code" := GPPOPReceiptLineHist.TRXSORCE;
            HistPurchaseRecvLine."Ship Method" := GPPOPReceiptLineHist.SHIPMTHD;
            HistPurchaseRecvLine."Orig. Unit Cost" := GPPOPReceiptLineHist.ORUNTCST;
            HistPurchaseRecvLine."Orig. Ext. Cost" := GPPOPReceiptLineHist.OREXTCST;
            HistPurchaseRecvLine."Orig. Disc. Taken Amount" := GPPOPReceiptLineHist.ORDISTKN;
            HistPurchaseRecvLine."Orig. Trade Disc. Amount" := GPPOPReceiptLineHist.ORTDISAM;
            HistPurchaseRecvLine."Orig. Freight Amount" := GPPOPReceiptLineHist.ORFRTAMT;
            HistPurchaseRecvLine."Orig. Misc. Amount" := GPPOPReceiptLineHist.ORMISCAMT;

            GPPOPReceiptApply.SetLoadFields(POPRCTNM, RCPTLNNM, QTYSHPPD, QTYINVCD);
            GPPOPReceiptApply.SetRange(POPRCTNM, GPPOPReceiptLineHist.POPRCTNM);
            GPPOPReceiptApply.SetRange(RCPTLNNM, GPPOPReceiptLineHist.RCPTLNNM);
            if GPPOPReceiptApply.FindFirst() then begin
                HistPurchaseRecvLine."Quantity Shipped" := GPPOPReceiptApply.QTYSHPPD;
                HistPurchaseRecvLine."Quantity Invoiced" := GPPOPReceiptApply.QTYINVCD;
            end;

            if not HistPurchaseRecvLine.Insert() then
                ReportLastError(Database::GPPOPReceiptLineHist, GPPOPReceiptLineHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Purchase Receivables Trx.", ReceiptNo);

            AfterProcessedNextChildRecord();
        until GPPOPReceiptLineHist.Next() = 0;
    end;

    local procedure PopulateGLOpenYearItemTransaction(var GPGL20000: Record "GP GL20000")
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        HistInventoryDocType: enum "Hist. Inventory Doc. Type";
        DocumentNo: Code[22];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        // GL inventory transactions use the REFRENCE field as the inventory trx. line DOCNUMBR
        if StrLen(GPGL20000.REFRENCE.TrimEnd()) > MaxStrLen(DocumentNo) then
            exit;

#pragma warning disable AA0139
        DocumentNo := GPGL20000.REFRENCE.TrimEnd();
#pragma warning restore AA0139

        GPIVTrxAmountsHist.SetLoadFields(DEX_ROW_ID, TRXSORCE, DOCNUMBR, DOCTYPE);
        GPIVTrxAmountsHist.SetRange(TRXSORCE, GPGL20000.ORTRXSRC);
        GPIVTrxAmountsHist.SetRange(DOCNUMBR, DocumentNo);
        if not GPIVTrxAmountsHist.FindFirst() then
            exit;

        HistInventoryDocType := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);

        HistInventoryTrxHeader.SetRange("Document Type", HistInventoryDocType);
        HistInventoryTrxHeader.SetRange("Document No.", DocumentNo);
        if not HistInventoryTrxHeader.IsEmpty() then
            exit;

        Clear(HistInventoryTrxHeader);
        HistInventoryTrxHeader."Audit Code" := GPGL20000.TRXSORCE;
        HistInventoryTrxHeader."Document Type" := HistInventoryDocType;
        HistInventoryTrxHeader."Document No." := DocumentNo;
        HistInventoryTrxHeader."Document Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL20000.TRXDATE));
        HistInventoryTrxHeader."Post Date" := HistInventoryTrxHeader."Document Date";

        if HistInventoryTrxHeader.Insert() then
            PopulateInventoryTrxLines(GPGL20000.ORTRXSRC, DocumentNo)
        else
            ReportLastError(Database::GPIVTrxAmountsHist, GPIVTrxAmountsHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

        AfterProcessedNextChildRecord();
    end;

    local procedure PopulateGLHistoricalYearItemTransaction(var GPGL30000: Record "GP GL30000")
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        HistInventoryDocType: enum "Hist. Inventory Doc. Type";
        DocumentNo: Code[22];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        // GL inventory transactions use the REFRENCE field as the inventory trx. line DOCNUMBR
        if StrLen(GPGL30000.REFRENCE.TrimEnd()) > MaxStrLen(DocumentNo) then
            exit;

#pragma warning disable AA0139
        DocumentNo := GPGL30000.REFRENCE.TrimEnd();
#pragma warning restore AA0139

        GPIVTrxAmountsHist.SetLoadFields(DEX_ROW_ID, TRXSORCE, DOCNUMBR, DOCTYPE);
        GPIVTrxAmountsHist.SetRange(TRXSORCE, GPGL30000.ORTRXSRC);
        GPIVTrxAmountsHist.SetRange(DOCNUMBR, DocumentNo);
        if not GPIVTrxAmountsHist.FindFirst() then
            exit;

        HistInventoryDocType := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);

        HistInventoryTrxHeader.SetRange("Document Type", HistInventoryDocType);
        HistInventoryTrxHeader.SetRange("Document No.", DocumentNo);
        if not HistInventoryTrxHeader.IsEmpty() then
            exit;

        Clear(HistInventoryTrxHeader);
        HistInventoryTrxHeader."Audit Code" := GPGL30000.TRXSORCE;
        HistInventoryTrxHeader."Document Type" := HistInventoryDocType;
        HistInventoryTrxHeader."Document No." := DocumentNo;
        HistInventoryTrxHeader."Document Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL30000.TRXDATE));
        HistInventoryTrxHeader."Post Date" := HistInventoryTrxHeader."Document Date";

        if HistInventoryTrxHeader.Insert() then
            PopulateInventoryTrxLines(GPGL30000.ORTRXSRC, DocumentNo)
        else
            ReportLastError(Database::GPIVTrxAmountsHist, GPIVTrxAmountsHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

        AfterProcessedNextChildRecord();
    end;

    local procedure PopulatePOPItemTransaction(var GPPOPReceiptHist: Record GPPOPReceiptHist)
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        DocumentNo: Code[35];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        GPIVTrxAmountsHist.SetLoadFields(TRXSORCE, DOCTYPE);
        GPIVTrxAmountsHist.SetRange(TRXSORCE, GPPOPReceiptHist.TRXSORCE);

        if not GPIVTrxAmountsHist.FindFirst() then
            exit;

#pragma warning disable AA0139
        DocumentNo := GPPOPReceiptHist.POPRCTNM.TrimEnd();
#pragma warning restore AA0139

        HistInventoryTrxHeader."Audit Code" := GPPOPReceiptHist.TRXSORCE;
        HistInventoryTrxHeader."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);
        HistInventoryTrxHeader."Document No." := DocumentNo;
        HistInventoryTrxHeader."Document Date" := GPPOPReceiptHist.receiptdate;
        HistInventoryTrxHeader."Batch No." := GPPOPReceiptHist.BACHNUMB;
        HistInventoryTrxHeader."Batch Source" := GPPOPReceiptHist.BCHSOURC;
        HistInventoryTrxHeader."Post Date" := GPPOPReceiptHist.GLPOSTDT;

        if HistInventoryTrxHeader.Insert() then
            PopulateInventoryTrxLines(GPPOPReceiptHist.TRXSORCE, DocumentNo)
        else
            ReportLastError(Database::GPPOPReceiptHist, GPPOPReceiptHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

        AfterProcessedNextChildRecord();
    end;

    local procedure PopulateSOPItemTransaction(var GPSOPTrxHist: Record GPSOPTrxHist)
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        DocumentNo: Code[35];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            exit;

        GPIVTrxAmountsHist.SetLoadFields(DEX_ROW_ID, TRXSORCE, DOCTYPE);
        GPIVTrxAmountsHist.SetRange(TRXSORCE, GPSOPTrxHist.TRXSORCE);

        if not GPIVTrxAmountsHist.FindFirst() then
            exit;

#pragma warning disable AA0139
        DocumentNo := GPSOPTrxHist.SOPNUMBE.TrimEnd();
#pragma warning restore AA0139

        HistInventoryTrxHeader."Audit Code" := GPSOPTrxHist.TRXSORCE;
        HistInventoryTrxHeader."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);
        HistInventoryTrxHeader."Document No." := DocumentNo;
        HistInventoryTrxHeader."Document Date" := GPSOPTrxHist.DOCDATE;
        HistInventoryTrxHeader."Batch No." := GPSOPTrxHist.BACHNUMB;
        HistInventoryTrxHeader."Batch Source" := GPSOPTrxHist.BCHSOURC;
        HistInventoryTrxHeader."Post Date" := GPSOPTrxHist.GLPOSTDT;

        if HistInventoryTrxHeader.Insert() then
            PopulateInventoryTrxLines(GPSOPTrxHist.TRXSORCE, DocumentNo)
        else
            ReportLastError(Database::GPIVTrxAmountsHist, GPIVTrxAmountsHist.DEX_ROW_ID, "Hist. Migration Step Type"::"GP Inventory Trx.", DocumentNo);

        AfterProcessedNextChildRecord();
    end;

    local procedure ConvertSeriesToSourceType(Series: Integer; SourceDocType: Code[35]): enum "Hist. Source Type";
    var
        HistSourceType: enum "Hist. Source Type";
    begin
        HistSourceType := "Hist. Source Type"::Other;

        case Series of
            3:
                HistSourceType := "Hist. Source Type"::Receivables;
            4:
                HistSourceType := "Hist. Source Type"::Payables;
            5:
                HistSourceType := "Hist. Source Type"::Inventory;
        end;

        if HistSourceType = "Hist. Source Type"::Payables then
            if SourceDocType = 'RECVG' then
                HistSourceType := "Hist. Source Type"::"Purchase Receivables";

        exit(HistSourceType);
    end;

    local procedure ConvertGPSOPTypeToHistSalesTrxType(SOPTYPE: Integer): enum "Hist. Sales Trx. Type";
    begin
        case SOPTYPE of
            1:
                exit("Hist. Sales Trx. Type"::Quote);
            2:
                exit("Hist. Sales Trx. Type"::"Order");
            3:
                exit("Hist. Sales Trx. Type"::Invoice);
            4:
                exit("Hist. Sales Trx. Type"::"Return Order");
            5:
                exit("Hist. Sales Trx. Type"::"Back Order");
            6:
                exit("Hist. Sales Trx. Type"::"Fulfillment Order");
        end;

        exit("Hist. Sales Trx. Type"::Blank);
    end;

    local procedure ConvertSOPStatusToSalesTrxStatus(SOPSTATUS: Integer): enum "Hist. Sales Trx. Status";
    begin
        case SOPSTATUS of
            1:
                exit("Hist. Sales Trx. Status"::"New");
            2:
                exit("Hist. Sales Trx. Status"::"Ready to Print Pick Ticket");
            3:
                exit("Hist. Sales Trx. Status"::"Unconfirmed Pick");
            4:
                exit("Hist. Sales Trx. Status"::"Ready to Print Pack Slip");
            5:
                exit("Hist. Sales Trx. Status"::"Unconfirmed Pack");
            6:
                exit("Hist. Sales Trx. Status"::Shipped);
            7:
                exit("Hist. Sales Trx. Status"::"Ready to Post");
            8:
                exit("Hist. Sales Trx. Status"::"In Process");
            9:
                exit("Hist. Sales Trx. Status"::Complete)
        end;

        exit("Hist. Sales Trx. Status"::Blank);
    end;

    local procedure ConvertGPDocTypeToHistReceivablesDocType(GPDocTypeId: Integer): enum "Hist. Receivables Doc. Type";
    begin
        case GPDocTypeId of
            0:
                exit("Hist. Receivables Doc. Type"::Balance);
            1:
                exit("Hist. Receivables Doc. Type"::SaleOrInvoice);
            2:
                exit("Hist. Receivables Doc. Type"::"Scheduled Payment");
            3:
                exit("Hist. Receivables Doc. Type"::"Debit Memo");
            4:
                exit("Hist. Receivables Doc. Type"::"Finance Charge");
            5:
                exit("Hist. Receivables Doc. Type"::"Service Repair");
            6:
                exit("Hist. Receivables Doc. Type"::Warranty);
            7:
                exit("Hist. Receivables Doc. Type"::"Credit Memo");
            8:
                exit("Hist. Receivables Doc. Type"::Return);
            9:
                exit("Hist. Receivables Doc. Type"::Payment);
        end;

        exit("Hist. Receivables Doc. Type"::Blank);
    end;

    local procedure ConvertGPDocTypeToHistPayablesDocType(GPDocTypeId: Integer): enum "Hist. Payables Doc. Type";
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Payables Doc. Type"::Invoice);
            2:
                exit("Hist. Payables Doc. Type"::"Finance Charge");
            3:
                exit("Hist. Payables Doc. Type"::"Misc. Charges");
            4:
                exit("Hist. Payables Doc. Type"::Return);
            5:
                exit("Hist. Payables Doc. Type"::"Credit Memo");
            6:
                exit("Hist. Payables Doc. Type"::Payment);
        end;

        exit("Hist. Payables Doc. Type"::Blank);
    end;

    local procedure Get1099TypeText(Ten99Type: Integer): Text[50];
    begin
        case Ten99Type of
            1:
                exit('Not a 1099 Vendor');
            2:
                exit('Dividend');
            3:
                exit('Interest');
            4:
                exit('Miscellaneous');
            5:
                exit('Withholding');
        end;
    end;

    local procedure ConvertGPDocTypeToHistInventoryDocType(GPDocTypeId: Integer): enum "Hist. Inventory Doc. Type";
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Inventory Doc. Type"::"Inventory Adjustment");
            2:
                exit("Hist. Inventory Doc. Type"::Variance);
            3:
                exit("Hist. Inventory Doc. Type"::"Inventory Transfer");
            4:
                exit("Hist. Inventory Doc. Type"::"Purchase Receipt");
            5:
                exit("Hist. Inventory Doc. Type"::"Sales Returns");
            6:
                exit("Hist. Inventory Doc. Type"::"Sales Invoices");
            7:
                exit("Hist. Inventory Doc. Type"::"Assembly");
            8, 11, 12:
                exit("Hist. Inventory Doc. Type"::"Inventory Cost Adjustment");
        end;

        exit("Hist. Inventory Doc. Type"::Blank);
    end;

    local procedure GetInventoryTrxSourceIndicatorText(SourceIndicator: Integer): Text[65];
    begin
        case SourceIndicator of
            1:
                exit('(none)');
            2:
                exit('Issue');
            3:
                exit('Reverse Issue');
            4:
                exit('Finished Good Post');
            5:
                exit('Reverse Finished Good Post');
            6:
                exit('Stock Count');
            7:
                exit('Field Service - Service Call');
            8:
                exit('Field Service - Return Material Authorization');
            9:
                exit('Field Service - Return to Vendor');
            10:
                exit('Field Service - Work Order');
            11:
                exit('Project Accounting');
            12:
                exit('In-Transit Inventory Transfer');
        end;
    end;

    local procedure ConvertGPDocTypeToHistPurchaseRecvDocType(GPDocTypeId: Integer): enum "Hist. Purchase Recv. Doc. Type"
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Purchase Recv. Doc. Type"::Shipment);
            2:
                exit("Hist. Purchase Recv. Doc. Type"::Invoice);
            3:
                exit("Hist. Purchase Recv. Doc. Type"::"Shipment/Invoice");
            4:
                exit("Hist. Purchase Recv. Doc. Type"::"Return");
            5:
                exit("Hist. Purchase Recv. Doc. Type"::"Return w/Credit");
            6:
                exit("Hist. Purchase Recv. Doc. Type"::"Inventory Return");
            7:
                exit("Hist. Purchase Recv. Doc. Type"::"Inventory Return w/Credit");
            8:
                exit("Hist. Purchase Recv. Doc. Type"::"Intransit Transfer");
        end;

        exit("Hist. Purchase Recv. Doc. Type"::Blank);
    end;

    local procedure ConvertGPVoidOptionToBoolean(OptionIntValue: Integer): Boolean
    begin
        if OptionIntValue = 0 then
            exit(false);

        exit(true);
    end;

    local procedure AfterProcessedNextRecord(TableId: Integer; RecId: Integer)
    var
        GPHistSourceProgress: Record "GP Hist. Source Progress";
    begin
        CurrentRecordCount := CurrentRecordCount + 1;

        if CurrentRecordCount >= CommitAfterXRecordCount then begin
            GPHistSourceProgress.SetLastProcessedRecId(TableId, RecId);
            Commit();
            CurrentRecordCount := 0;
        end;
    end;

    local procedure AfterProcessedSection(TableId: Integer; LastRecId: Integer)
    var
        GPHistSourceProgress: Record "GP Hist. Source Progress";
    begin
        if LastRecId = 0 then
            exit;

        CurrentRecordCount := 0;
        GPHistSourceProgress.SetLastProcessedRecId(TableId, LastRecId);
        Commit();
    end;

    local procedure AfterProcessedNextChildRecord()
    begin
        CurrentRecordCount := CurrentRecordCount + 1;

        if CurrentRecordCount >= CommitAfterXRecordCount then begin
            Commit();
            CurrentRecordCount := 0;
        end;
    end;

    procedure ReportLastError(TableId: Integer; RecordId: Integer; Step: enum "Hist. Migration Step Type"; Reference: Text[150])
    var
        GPHistSourceError: Record "GP Hist. Source Error";
    begin
        GPHistSourceError.SetRange("Table Id", TableId);
        GPHistSourceError.SetRange("Record Id", RecordId);
        if not GPHistSourceError.IsEmpty() then
            exit;

        GPHistSourceError."Table Id" := TableId;
        GPHistSourceError."Record Id" := RecordId;
        GPHistSourceError.Step := Step;
        GPHistSourceError.Reference := Reference;
        GPHistSourceError."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(GPHistSourceError."Error Code"));
        GPHistSourceError.SetErrorMessage(GetLastErrorCallStack());
        GPHistSourceError.Insert();

        ClearLastError();
    end;

    procedure ReportLastSuccess(TableId: Integer; RecordId: Integer)
    var
        GPHistSourceError: Record "GP Hist. Source Error";
    begin
        if GPHistSourceError.Get(TableId, RecordId) then
            GPHistSourceError.Delete();
    end;

    local procedure GetSourceTableRecIdFilter(TableId: Integer): Text
    var
        GPHistSourceProgress: Record "GP Hist. Source Progress";
        GPHistSourceError: Record "GP Hist. Source Error";
        FilterText: Text;
    begin
        FilterText := '>' + Format(GPHistSourceProgress.GetLastProcessedRecId(TableId));

        GPHistSourceError.SetRange("Table Id", TableId);
        GPHistSourceError.SetLoadFields("Record Id");
        if GPHistSourceError.FindSet() then
            repeat
                FilterText += '|' + Format(GPHistSourceError."Record Id");
            until GPHistSourceError.Next() = 0;

        exit(FilterText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunGPPopulateHistTables(var IsHandled: Boolean; var OverrideCommitAfterXRecordCount: Integer)
    begin
    end;
}