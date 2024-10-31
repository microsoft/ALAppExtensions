namespace Microsoft.DataMigration.GP;

using Microsoft.CRM.Outlook;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.DataMigration;

codeunit 40125 "GP Populate Combined Tables"
{
    internal procedure PopulateAllMappedTables()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        PouplateGPFiscalPeriods();

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            PopulateGPAccount();
            PopulateGPPostingAccountsTable();

            if not GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
                PopulateGPGLTransactions();
        end;

        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then begin
            PopulateGPCustomer();

            if not GPCompanyAdditionalSettings.GetMigrateOnlyReceivablesMaster() then
                PopulateGPCustomerTransactions();
        end;

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then begin
            PopulateGPVendors();

            if not GPCompanyAdditionalSettings.GetMigrateOnlyPayablesMaster() then
                PopulateGPVendorTransactions();
        end;


        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then begin
            PopulateGPItem();

            if not GPCompanyAdditionalSettings.GetMigrateOnlyInventoryMaster() then
                PopulateGPItemTransactions();
        end;

        PopulateCodes();
        PopulateGPSegments();
        PopulateGPRMOpen();
    end;

    internal procedure PopulateGPAccount()
    var
        GPGL00100: Record "GP GL00100";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
        GPAccount: Record "GP Account";
        AccountDescription: Text;
    begin
        GPGL00100.SetFilter(ACCTTYPE, '1|2');
        // Only Posting and Unit accounts

        if not GPGL00100.FindSet() then
            exit;

        repeat
            GPSY00300.SetRange(MNSEGIND, true);
            if GPSY00300.FindFirst() then begin
                GPGL40200.SetRange(SGMNTID, GPGL00100.MNACSGMT);
                GPGL40200.SetRange(SGMTNUMB, GPSY00300.SGMTNUMB);
                if GPGL40200.FindFirst() then
                    AccountDescription := GPGL40200.DSCRIPTN.Trim();
            end;

            if AccountDescription = '' then
                AccountDescription := GPGL00100.ACTDESCR;

            Clear(GPAccount);
#pragma warning disable AA0139
            GPAccount.AcctNum := GPGL00100.MNACSGMT.Trim();
#pragma warning restore AA0139
            GPAccount.AcctIndex := GPGL00100.ACTINDX;
            GPAccount.Name := CopyStr(AccountDescription.Trim(), 1, MaxStrLen(GPAccount.Name));
            GPAccount.SearchName := GPAccount.Name;
            GPAccount.AccountCategory := GPGL00100.ACCATNUM;
            GPAccount.IncomeBalance := GPGL00100.PSTNGTYP = 1;
            GPAccount.DebitCredit := GPGL00100.TPCLBLNC;
            GPAccount.Active := GPGL00100.ACTIVE;
            GPAccount.DirectPosting := GPGL00100.ACCTENTR;
            GPAccount.AccountSubcategoryEntryNo := GPGL00100.ACCATNUM;
            GPAccount.AccountType := GPGL00100.ACCTTYPE;
            GPAccount.Insert();
        until GPGL00100.Next() = 0;
    end;

    internal procedure PouplateGPFiscalPeriods()
    var
        GPSY40100: Record "GP SY40100";
        GPSY40101: Record "GP SY40101";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        ExistingGPFiscalPeriods: Record "GP Fiscal Periods";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
    begin
        GPSY40100.SetRange(SERIES, 0);

        if not GPSY40100.FindSet() then
            exit;

        repeat
            Clear(GPFiscalPeriods);
            if GPSY40101.Get(GPSY40100.YEAR1) then begin
                GPFiscalPeriods.PERIODID := GPSY40100.PERIODID;
                GPFiscalPeriods.YEAR1 := GPSY40100.YEAR1;
                GPFiscalPeriods.PERIODDT := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPSY40100.PERIODDT));
                GPFiscalPeriods.PERDENDT := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPSY40100.PERDENDT));

                if not ExistingGPFiscalPeriods.Get(GPFiscalPeriods.PERIODID, GPFiscalPeriods.YEAR1) then
                    GPFiscalPeriods.Insert();
            end;
        until GPSY40100.Next() = 0;
    end;

    internal procedure PopulateGPGLTransactions()
    var
        GPGLTransactions: Record "GP GLTransactions";
        GPSY00300: Record "GP SY00300";
        GPGL10110: Record "GP GL10110";
        GPGL10111: Record "GP GL10111";
        GPGL00100: Record "GP GL00100";
        SegmentNumber: Integer;
        SegmentCount: Integer;
        CurrentSegmentCount: Integer;
        CurrentKey: Integer;
    begin
        GPSY00300.SetRange(MNSEGIND, true);
        if GPSY00300.FindFirst() then
            SegmentNumber := GPSY00300.SGMTNUMB;

        SegmentCount := GetTotalSegmentCount();
        CurrentKey := 1;
        GPGL10110.SetFilter(PERDBLNC, '<>0');
        GPGL10110.SetFilter(PERIODID, '>0');
        GPGL10110.SetCurrentKey(YEAR1, PERIODID, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);
        if GPGL10110.FindSet() then
            repeat
                Clear(GPGLTransactions);
                GPGLTransactions.MNACSGMT := SegmentNumber;
                GPGLTransactions.ACTINDX := GPGL10110.ACTINDX;
                GPGLTransactions.YEAR1 := GPGL10110.YEAR1;
                GPGLTransactions.PERIODID := GPGL10110.PERIODID;
                GPGLTransactions.ACTNUMBR_1 := GPGL10110.ACTNUMBR_1;
                GPGLTransactions.ACTNUMBR_2 := GPGL10110.ACTNUMBR_2;
                GPGLTransactions.ACTNUMBR_3 := GPGL10110.ACTNUMBR_3;
                GPGLTransactions.ACTNUMBR_4 := GPGL10110.ACTNUMBR_4;
                GPGLTransactions.ACTNUMBR_5 := GPGL10110.ACTNUMBR_5;
                GPGLTransactions.ACTNUMBR_6 := GPGL10110.ACTNUMBR_6;
                GPGLTransactions.ACTNUMBR_7 := GPGL10110.ACTNUMBR_7;
                GPGLTransactions.ACTNUMBR_8 := GPGL10110.ACTNUMBR_8;

                if SegmentCount > 0 then begin
                    CurrentSegmentCount := 1;
                    if GPGL00100.Get(GPGLTransactions.ACTINDX) then
                        if CurrentSegmentCount <= SegmentCount then
                            GPGLTransactions.ACTNUMBR_1 := GPGL00100.ACTNUMBR_1;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_2 := GPGL00100.ACTNUMBR_2;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_3 := GPGL00100.ACTNUMBR_3;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_4 := GPGL00100.ACTNUMBR_4;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_5 := GPGL00100.ACTNUMBR_5;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_6 := GPGL00100.ACTNUMBR_6;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_7 := GPGL00100.ACTNUMBR_7;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_8 := GPGL00100.ACTNUMBR_8;
                end;

                GPGLTransactions.PERDBLNC := GPGL10110.PERDBLNC;
                GPGLTransactions.DEBITAMT := GPGL10110.DEBITAMT;
                GPGLTransactions.CRDTAMNT := GPGL10110.CRDTAMNT;
                GPGLTransactions.Id := CurrentKey;
                GPGLTransactions.Insert();
                CurrentKey := CurrentKey + 1;
            until GPGL10110.Next() = 0;

        GPGL10111.SetFilter(PERDBLNC, '<>0');
        GPGL10111.SetFilter(PERIODID, '>0');
        GPGL10111.SetCurrentKey(YEAR1, PERIODID, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);
        if GPGL10111.FindSet() then
            repeat
                Clear(GPGLTransactions);
                GPGLTransactions.MNACSGMT := SegmentNumber;
                GPGLTransactions.ACTINDX := GPGL10111.ACTINDX;
                GPGLTransactions.YEAR1 := GPGL10111.YEAR1;
                GPGLTransactions.PERIODID := GPGL10111.PERIODID;
                GPGLTransactions.ACTNUMBR_1 := GPGL10111.ACTNUMBR_1;
                GPGLTransactions.ACTNUMBR_2 := GPGL10111.ACTNUMBR_2;
                GPGLTransactions.ACTNUMBR_3 := GPGL10111.ACTNUMBR_3;
                GPGLTransactions.ACTNUMBR_4 := GPGL10111.ACTNUMBR_4;
                GPGLTransactions.ACTNUMBR_5 := GPGL10111.ACTNUMBR_5;
                GPGLTransactions.ACTNUMBR_6 := GPGL10111.ACTNUMBR_6;
                GPGLTransactions.ACTNUMBR_7 := GPGL10111.ACTNUMBR_7;
                GPGLTransactions.ACTNUMBR_8 := GPGL10111.ACTNUMBR_8;

                if SegmentCount > 0 then begin
                    CurrentSegmentCount := 1;
                    if GPGL00100.Get(GPGLTransactions.ACTINDX) then
                        if CurrentSegmentCount <= SegmentCount then
                            GPGLTransactions.ACTNUMBR_1 := GPGL00100.ACTNUMBR_1;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_2 := GPGL00100.ACTNUMBR_2;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_3 := GPGL00100.ACTNUMBR_3;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_4 := GPGL00100.ACTNUMBR_4;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_5 := GPGL00100.ACTNUMBR_5;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_6 := GPGL00100.ACTNUMBR_6;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_7 := GPGL00100.ACTNUMBR_7;

                    CurrentSegmentCount += 1;
                    if CurrentSegmentCount <= SegmentCount then
                        GPGLTransactions.ACTNUMBR_8 := GPGL00100.ACTNUMBR_8;
                end;

                GPGLTransactions.PERDBLNC := GPGL10111.PERDBLNC;
                GPGLTransactions.DEBITAMT := GPGL10111.DEBITAMT;
                GPGLTransactions.CRDTAMNT := GPGL10111.CRDTAMNT;
                GPGLTransactions.Id := CurrentKey;
                GPGLTransactions.Insert();
                CurrentKey := CurrentKey + 1;
            until GPGL10111.Next() = 0;
    end;

    internal procedure GetTotalSegmentCount(): Integer
    var
        GPGL00100: Record "GP GL00100";
        CurrentCount: Integer;
    begin
        CurrentCount := 8;
        GPGL00100.SetFilter(ACTNUMBR_8, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_7, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_6, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_5, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_4, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_3, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_2, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        CurrentCount := CurrentCount - 1;
        Clear(GPGL00100);
        GPGL00100.SetFilter(ACTNUMBR_1, '<>''''');
        if not GPGL00100.IsEmpty() then
            exit(CurrentCount);

        exit(0);
    end;

    internal procedure PopulateGPCustomer()
    var
        GPCustomer: Record "GP Customer";
        GPRM00101: Record "GP RM00101";
        GPRM00103: Record "GP RM00103";
        GPSY01200: Record "GP SY01200";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPRM00101.SetRange(INACTIVE, false);
        if GPCompanyMigrationSettings.Get(CompanyName()) then
            if GPCompanyMigrationSettings."Migrate Inactive Customers" then
                GPRM00101.SetRange(INACTIVE);

        if not GPRM00101.FindSet() then
            exit;

        repeat
            Clear(GPCustomer);
#pragma warning disable AA0139
            GPCustomer.CUSTNMBR := GPRM00101.CUSTNMBR.Trim();
            GPCustomer.CUSTNAME := GPRM00101.CUSTNAME.Trim();
            GPCustomer.STMTNAME := GPRM00101.STMTNAME.Trim();
            GPCustomer.ADDRESS1 := GPRM00101.ADDRESS1.Trim();
            GPCustomer.ADDRESS2 := GPRM00101.ADDRESS2.Trim();
            GPCustomer.CITY := GPRM00101.CITY.Trim();
            GPCustomer.CNTCPRSN := GPRM00101.CNTCPRSN.Trim();
            GPCustomer.SALSTERR := GPRM00101.SALSTERR.Trim();
            GPCustomer.CRLMTAMT := GPRM00101.CRLMTAMT;
            GPCustomer.PYMTRMID := GPRM00101.PYMTRMID.Trim();
            GPCustomer.SLPRSNID := GPRM00101.SLPRSNID.Trim();
            GPCustomer.SHIPMTHD := GPRM00101.SHIPMTHD.Trim();
            GPCustomer.COUNTRY := GPRM00101.COUNTRY.Trim();
            GPCustomer.STMTCYCL := GPRM00101.STMTCYCL <> 0;
            GPCustomer.ZIPCODE := GPRM00101.ZIP.Trim();
            GPCustomer.STATE := GPRM00101.STATE.Trim();
            GPCustomer.TAXSCHID := GPRM00101.TAXSCHID.Trim();
            GPCustomer.UPSZONE := GPRM00101.UPSZONE.Trim();
            GPCustomer.TAXEXMT1 := GPRM00101.TAXEXMT1.Trim();
#pragma warning restore AA0139   

            if GPRM00101.PHONE1.Contains('E+') then
                GPCustomer.PHONE1 := '00000000000000'
            else
                GPCustomer.PHONE1 := CopyStr(GPRM00101.PHONE1.Trim(), 1, MaxStrLen(GPCustomer.PHONE1));

            if GPRM00101.FAX.Contains('E+') then
                GPCustomer.FAX := '00000000000000'
            else
                GPCustomer.FAX := CopyStr(GPRM00101.FAX.Trim(), 1, MaxStrLen(GPCustomer.FAX));

            if GPRM00103.Get(GPRM00101.CUSTNMBR) then
                GPCustomer.AMOUNT := GPRM00103.CUSTBLNC;

            if GPSY01200.Get('CUS', GPRM00101.CUSTNMBR, GPRM00101.ADRSCODE) then begin
                if ((GPSY01200.INET1 <> '') and (GPSY01200.INET1.Contains('@'))) then
                    GPCustomer.INET1 := CopyStr(GPSY01200.INET1.Trim(), 1, MaxStrLen(GPCustomer.INET1));

                if ((GPSY01200.INET2 <> '') and (GPSY01200.INET2.Contains('@'))) then
                    GPCustomer.INET2 := CopyStr(GPSY01200.INET2.Trim(), 1, MaxStrLen(GPCustomer.INET2));
            end;

            GPCustomer.Insert();
        until GPRM00101.Next() = 0;
    end;

    internal procedure PopulateGPCustomerTransactions()
    var
        GPRM20101: Record "GP RM20101";
        GPCustomerTransactions: Record "GP Customer Transactions";
        I: Integer;
    begin
        I := 1;
        GPRM20101.SetRange(RMDTYPAL, 1, 9);
        GPRM20101.SetFilter(CURTRXAM, '>=0.01');
        GPRM20101.SetRange(VOIDSTTS, 0);
        GPRM20101.SetCurrentKey(CUSTNMBR, RMDTYPAL);
        if not GPRM20101.FindSet() then
            exit;

        repeat
            Clear(GPCustomerTransactions);

            GPCustomerTransactions.Id := FORMAT(I);
            I += 1;
#pragma warning disable AA0139
            GPCustomerTransactions.CUSTNMBR := GPRM20101.CUSTNMBR.TrimEnd();
            GPCustomerTransactions.DOCNUMBR := GPRM20101.DOCNUMBR.TrimEnd();
#pragma warning restore AA0139
            GPCustomerTransactions.DOCDATE := GPRM20101.DOCDATE;
            if GPRM20101.RMDTYPAL in [1, 3, 4, 5] then
                GPCustomerTransactions.DUEDATE := GPRM20101.DUEDATE;

            GPCustomerTransactions.CURTRXAM := GPRM20101.CURTRXAM;
            GPCustomerTransactions.RMDTYPAL := GPRM20101.RMDTYPAL;

            GPCustomerTransactions.GLDocNo := CopyStr('C' + GPCustomerTransactions.Id + '00000', 1, MaxStrLen(GPCustomerTransactions.GLDocNo));

            if GPRM20101.RMDTYPAL < 6 then
                GPCustomerTransactions.TransType := 2;

            if (GPRM20101.RMDTYPAL >= 7) and (GPRM20101.RMDTYPAL <= 8) then
                GPCustomerTransactions.TransType := 3;

            if (GPRM20101.RMDTYPAL = 9) then
                GPCustomerTransactions.TransType := 1;

            GPCustomerTransactions.SLPRSNID := CopyStr(GPRM20101.SLPRSNID.Trim(), 1, MaxStrLen(GPCustomerTransactions.SLPRSNID));
            GPCustomerTransactions.PYMTRMID := CopyStr(GPRM20101.PYMTRMID.Trim(), 1, MaxStrLen(GPCustomerTransactions.PYMTRMID));
            GPCustomerTransactions.Insert();
        until GPRM20101.Next() = 0;
    end;

    internal procedure PopulateGPRMOpen()
    var
        GPRM20101: Record "GP RM20101";
        GPRMOpen: Record "GPRMOpen";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
    begin
        GPRM20101.SetRange(CURTRXAM, 0);
        if GPRM20101.FindSet() then
            repeat
                GPRMOpen.CUSTNMBR := GPRM20101.CUSTNMBR;
                GPRMOpen.CPRCSTNM := GPRM20101.CPRCSTNM;
                GPRMOpen.DOCNUMBR := GPRM20101.DOCNUMBR;
                GPRMOpen.CHEKNMBR := GPRM20101.CHEKNMBR;
                GPRMOpen.BACHNUMB := GPRM20101.BACHNUMB;
                GPRMOpen.BCHSOURC := GPRM20101.BCHSOURC;
                GPRMOpen.TRXSORCE := GPRM20101.TRXSORCE;
                GPRMOpen.RMDTYPAL := GPRM20101.RMDTYPAL;
                GPRMOpen.CSHRCTYP := GPRM20101.CSHRCTYP;
                GPRMOpen.CBKIDCRD := GPRM20101.CBKIDCRD;
                GPRMOpen.CBKIDCSH := GPRM20101.CBKIDCSH;
                GPRMOpen.CBKIDCHK := GPRM20101.CBKIDCHK;
                GPRMOpen.DUEDATE := GPRM20101.DUEDATE;
                GPRMOpen.DOCDATE := GPRM20101.DOCDATE;
                GPRMOpen.POSTDATE := GPRM20101.POSTDATE;
                GPRMOpen.PSTUSRID := GPRM20101.PSTUSRID;
                GPRMOpen.GLPOSTDT := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPRM20101.GLPOSTDT));
                GPRMOpen.LSTEDTDT := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPRM20101.LSTEDTDT));
                GPRMOpen.LSTUSRED := GPRM20101.LSTUSRED;
                GPRMOpen.ORTRXAMT := GPRM20101.ORTRXAMT;
                GPRMOpen.CURTRXAM := GPRM20101.CURTRXAM;
                GPRMOpen.SLSAMNT := GPRM20101.SLSAMNT;
                GPRMOpen.COSTAMNT := GPRM20101.COSTAMNT;
                GPRMOpen.FRTAMNT := GPRM20101.FRTAMNT;
                GPRMOpen.MISCAMNT := GPRM20101.MISCAMNT;
                GPRMOpen.TAXAMNT := GPRM20101.TAXAMNT;
                GPRMOpen.COMDLRAM := GPRM20101.COMDLRAM;
                GPRMOpen.CASHAMNT := GPRM20101.CASHAMNT;
                GPRMOpen.DISTKNAM := GPRM20101.DISTKNAM;
                GPRMOpen.DISAVAMT := GPRM20101.DISAVAMT;
                GPRMOpen.DISAVTKN := GPRM20101.DISAVTKN;
                GPRMOpen.DISCRTND := GPRM20101.DISCRTND;
                GPRMOpen.DISCDATE := GPRM20101.DISCDATE;
                GPRMOpen.DSCDLRAM := GPRM20101.DSCDLRAM;
                GPRMOpen.DSCPCTAM := GPRM20101.DSCPCTAM;
                GPRMOpen.WROFAMNT := GPRM20101.WROFAMNT;
                GPRMOpen.TRXDSCRN := GPRM20101.TRXDSCRN;
                GPRMOpen.CSPORNBR := GPRM20101.CSPORNBR;
                GPRMOpen.SLPRSNID := GPRM20101.SLPRSNID;
                GPRMOpen.SLSTERCD := GPRM20101.SLSTERCD;
                GPRMOpen.DINVPDOF := GPRM20101.DINVPDOF;
                GPRMOpen.PPSAMDED := GPRM20101.PPSAMDED;
                GPRMOpen.GSTDSAMT := GPRM20101.GSTDSAMT;
                GPRMOpen.DELETE1 := GPRM20101.DELETE1;
                GPRMOpen.AGNGBUKT := GPRM20101.AGNGBUKT;
                GPRMOpen.VOIDSTTS := GPRM20101.VOIDSTTS;
                GPRMOpen.VOIDDATE := GPRM20101.VOIDDATE;
                GPRMOpen.TAXSCHID := GPRM20101.TAXSCHID;
                GPRMOpen.CURNCYID := GPRM20101.CURNCYID;
                GPRMOpen.PYMTRMID := GPRM20101.PYMTRMID;
                GPRMOpen.SHIPMTHD := GPRM20101.SHIPMTHD;
                GPRMOpen.TRDISAMT := GPRM20101.TRDISAMT;
                GPRMOpen.SLSCHDID := GPRM20101.SLSCHDID;
                GPRMOpen.FRTSCHID := GPRM20101.FRTSCHID;
                GPRMOpen.MSCSCHID := GPRM20101.MSCSCHID;
                GPRMOpen.NOTEINDX := GPRM20101.NOTEINDX;
                GPRMOpen.Tax_Date := GPRM20101.Tax_Date;
                GPRMOpen.APLYWITH := GPRM20101.APLYWITH;
                GPRMOpen.SALEDATE := GPRM20101.SALEDATE;
                GPRMOpen.CORRCTN := GPRM20101.CORRCTN;
                GPRMOpen.SIMPLIFD := GPRM20101.SIMPLIFD;
                GPRMOpen.Electronic := GPRM20101.Electronic;
                GPRMOpen.ECTRX := GPRM20101.ECTRX;
                GPRMOpen.BKTSLSAM := GPRM20101.BKTSLSAM;
                GPRMOpen.BKTFRTAM := GPRM20101.BKTFRTAM;
                GPRMOpen.BKTMSCAM := GPRM20101.BKTMSCAM;
                GPRMOpen.BackoutTradeDisc := GPRM20101.BackoutTradeDisc;
                GPRMOpen.Factoring := GPRM20101.Factoring;
                GPRMOpen.DIRECTDEBIT := GPRM20101.DIRECTDEBIT;
                GPRMOpen.ADRSCODE := GPRM20101.ADRSCODE;
                GPRMOpen.EFTFLAG := GPRM20101.EFTFLAG;
                GPRMOpen.DEX_ROW_TS := GPRM20101.DEX_ROW_TS;
                GPRMOpen.DEX_ROW_ID := GPRM20101.DEX_ROW_ID;
                if GPRMOpen.Insert() then;
            until GPRM20101.Next() = 0;
    end;

    internal procedure PopulateGPVendors()
    var
        GPPM00200Vendor: Record "GP PM00200";
        GPPM00201VendorSum: Record "GP PM00201";
        GPSY01200NetAddresses: Record "GP SY01200";
        GPVendor: Record "GP Vendor";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPPM00200Vendor.SetFilter(VENDSTTS, '1|3');
        if GPCompanyMigrationSettings.Get(CompanyName()) then
            if GPCompanyMigrationSettings."Migrate Inactive Vendors" then
                GPPM00200Vendor.SetRange(VENDSTTS);

        if not GPPM00200Vendor.FindSet() then
            exit;

        repeat
            Clear(GPVendor);
#pragma warning disable AA0139            
            GPVendor.VENDORID := GPPM00200Vendor.VENDORID.TrimEnd();
            GPVendor.VENDNAME := GPPM00200Vendor.VENDNAME.TrimEnd();
            GPVendor.SEARCHNAME := GPPM00200Vendor.VENDNAME.TrimEnd();
            GPVendor.VNDCHKNM := GPPM00200Vendor.VNDCHKNM.TrimEnd();
            GPVendor.ADDRESS1 := GPPM00200Vendor.ADDRESS1.TrimEnd();
            GPVendor.ADDRESS2 := GPPM00200Vendor.ADDRESS2.TrimEnd();
            GPVendor.CITY := GPPM00200Vendor.CITY.TrimEnd();
            GPVendor.VNDCNTCT := GPPM00200Vendor.VNDCNTCT.TrimEnd();
            GPVendor.PYMTRMID := GPPM00200Vendor.PYMTRMID.TrimEnd();
            GPVendor.SHIPMTHD := GPPM00200Vendor.SHIPMTHD.TrimEnd();
            GPVendor.COUNTRY := GPPM00200Vendor.COUNTRY.TrimEnd();
            GPVendor.PYMNTPRI := GPPM00200Vendor.PYMNTPRI.TrimEnd();
            GPVendor.ZIPCODE := GPPM00200Vendor.ZIPCODE.TrimEnd();
            GPVendor.STATE := GPPM00200Vendor.STATE.TrimEnd();
            GPVendor.TAXSCHID := GPPM00200Vendor.TAXSCHID.TrimEnd();
            GPVendor.UPSZONE := GPPM00200Vendor.UPSZONE.TrimEnd();
            GPVendor.TXIDNMBR := GPPM00200Vendor.TXIDNMBR.TrimEnd();
#pragma warning restore AA0139    

            if GPPM00200Vendor.PHNUMBR1.Contains('E+') then
                GPVendor.PHNUMBR1 := '00000000000000'
            else
                GPVendor.PHNUMBR1 := CopyStr(GPPM00200Vendor.PHNUMBR1.Trim(), 1, MaxStrLen(GPVendor.PHNUMBR1));

            if GPPM00200Vendor.FAXNUMBR.Contains('E+') then
                GPVendor.FAXNUMBR := '00000000000000'
            else
                GPVendor.FAXNUMBR := CopyStr(GPPM00200Vendor.FAXNUMBR.Trim(), 1, MaxStrLen(GPVendor.FAXNUMBR));

            if GPPM00201VendorSum.Get(GPPM00200Vendor.VENDORID) then
                GPVendor.AMOUNT := GPPM00201VendorSum.CURRBLNC;

            if GPSY01200NetAddresses.Get('VEN', GPPM00200Vendor.VENDORID, GPPM00200Vendor.VADDCDPR) then begin
                if ((GPSY01200NetAddresses.INET1 <> '') and (GPSY01200NetAddresses.INET1.Contains('@'))) then
                    GPVendor.INET1 := CopyStr(GPSY01200NetAddresses.INET1.Trim(), 1, MaxStrLen(GPVendor.INET1));

                if ((GPSY01200NetAddresses.INET2 <> '') and (GPSY01200NetAddresses.INET2.Contains('@'))) then
                    GPVendor.INET2 := CopyStr(GPSY01200NetAddresses.INET2.Trim(), 1, MaxStrLen(GPVendor.INET2));
            end;

            GPVendor.Insert();
        until GPPM00200Vendor.Next() = 0;
    end;

    internal procedure PopulateGPVendorTransactions()
    var
        GPPM20000: Record "GP PM20000";
        GPVendorTransactions: Record "GP Vendor Transactions";
        I: Integer;
    begin
        I := 1;
        GPPM20000.SetFilter(DOCTYPE, '<=7');
        GPPM20000.SetFilter(CURTRXAM, '>=0.01');
        GPPM20000.SetRange(VOIDED, false);
        GPPM20000.SetCurrentKey(VENDORID, DOCTYPE, VCHRNMBR);

        if not GPPM20000.FindSet() then
            exit;

        repeat
            Clear(GPVendorTransactions);
            GPVendorTransactions.Id := FORMAT(I);
            I += 1;
#pragma warning disable AA0139            
            GPVendorTransactions.VENDORID := GPPM20000.VENDORID.Trim();
            GPVendorTransactions.DOCNUMBR := GPPM20000.DOCNUMBR.Trim();
            GPVendorTransactions.PYMTRMID := GPPM20000.PYMTRMID.Trim();
#pragma warning restore AA0139

            GPVendorTransactions.DOCDATE := GPPM20000.DOCDATE;
            GPVendorTransactions.DUEDATE := GPPM20000.DUEDATE;

            GPVendorTransactions.CURTRXAM := GPPM20000.CURTRXAM;
            GPVendorTransactions.DOCTYPE := GPPM20000.DOCTYPE;

            GPVendorTransactions.GLDocNo := CopyStr('V' + GPVendorTransactions.Id + '00000', 1, MaxStrLen(GPVendorTransactions.GLDocNo));

            case GPPM20000.DOCTYPE of
                6:
                    GPVendorTransactions.TransType := 1;
                1, 2, 3, 7:
                    GPVendorTransactions.TransType := 2;
                4, 5:
                    GPVendorTransactions.TransType := 3;
                else
                    GPVendorTransactions.TransType := 0;
            end;

            GPVendorTransactions.Insert();
        until GPPM20000.Next() = 0;
    end;

    local procedure ShouldAddItemToStagingTable(var GPIV00101: Record "GP IV00101"): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InActive: Boolean;
    begin
        if not GPCompanyAdditionalSettings.GetMigrateKitItems() then
            if GPIV00101.ITEMTYPE = 3 then
                exit(false);

        if GPIV00101.ITEMTYPE = 2 then
            InActive := true
        else
            InActive := GPIV00101.INACTIVE;

        if InActive then
            if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
                exit(false);

        if GPIV00101.IsDiscontinued() then
            if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                exit(false);

        exit(true);
    end;

    internal procedure PopulateGPItem()
    var
        GPItem: Record "GP Item";
        GPIV00101Inventory: Record "GP IV00101";
        GPIV00102InventoryQty: Record "GP IV00102";
        GPIV00105inventoryCurr: Record "GP IV00105";
        GPIV40201InventoryUom: Record "GP IV40201";
        DummyItem: Record Item;
        GPMC40000: Record "GP MC40000";
        FoundCurrency: Boolean;
    begin
        UpdateGLSetupUnitRoundingPrecisionIfNeeded();

        if not GPIV00101Inventory.FindSet() then
            exit;

        repeat
            Clear(GPItem);
            if ShouldAddItemToStagingTable(GPIV00101Inventory) then begin
                GPItem.No := CopyStr(GPIV00101Inventory.ITEMNMBR.TrimEnd(), 1, MaxStrLen(DummyItem."No."));
                GPItem.Description := CopyStr(GPIV00101Inventory.ITEMDESC.TrimEnd(), 1, MaxStrLen(GPItem.Description));
                GPItem.SearchDescription := CopyStr(GPIV00101Inventory.ITEMDESC.TrimEnd(), 1, MaxStrLen(GPItem.SearchDescription));
#pragma warning disable AA0139
                GPItem.ShortName := GPIV00101Inventory.ITEMNMBR.TrimEnd();
#pragma warning restore AA0139
                case GPIV00101Inventory.ITEMTYPE of
                    1, 2:
                        GPItem.ItemType := 0;
                    4, 5, 6:
                        GPItem.ItemType := 1;
                    3:
                        GPItem.ItemType := 2;
                end;

                case GPIV00101Inventory.VCTNMTHD of
                    1:
                        GPItem.CostingMethod := Format(0);
                    2:
                        GPItem.CostingMethod := Format(1);
                    3:
                        GPItem.CostingMethod := Format(3);
                    4, 5:
                        GPItem.CostingMethod := Format(4);
                    else
                        GPItem.CostingMethod := Format(0);
                end;

                GPItem.CurrentCost := GPIV00101Inventory.CURRCOST;
                GPItem.StandardCost := GPIV00101Inventory.STNDCOST;
#pragma warning disable AA0139
                GPItem.SalesUnitOfMeasure := GPIV00101Inventory.SELNGUOM.Trim();
                GPItem.PurchUnitOfMeasure := GPIV00101Inventory.PRCHSUOM.Trim();
                GPItem.SalesUnitOfMeasure := GPIV00101Inventory.SELNGUOM.Trim();
                GPItem.SalesUnitOfMeasure := GPIV00101Inventory.SELNGUOM.Trim();
#pragma warning restore AA0139
                case GPIV00101Inventory.ITMTRKOP of
                    2:
                        GPItem.ItemTrackingCode := ItemTrackingCodeSERIALLbl;
                    3:
                        GPItem.ItemTrackingCode := ItemTrackingCodeLOTLbl;
                end;

                GPItem.ShipWeight := GPIV00101Inventory.ITEMSHWT / 100;
                if GPIV00101Inventory.ITEMTYPE = 2 then
                    GPItem.InActive := true
                else
                    GPItem.InActive := GPIV00101Inventory.INACTIVE;

                GPIV40201InventoryUom.SetRange(UOMSCHDL, GPIV00101Inventory.UOMSCHDL);
                if GPIV40201InventoryUom.FindFirst() then
#pragma warning disable AA0139
                    GPItem.BaseUnitOfMeasure := GPIV40201InventoryUom.BASEUOFM.Trim();
#pragma warning restore AA0139

                GPIV00102InventoryQty.SetRange(ITEMNMBR, GPIV00101Inventory.ITEMNMBR);
                GPIV00102InventoryQty.SetRange(LOCNCODE, '');
                GPIV00102InventoryQty.SetRange(RCRDTYPE, 1);
                if GPIV00102InventoryQty.FindFirst() then
                    GPItem.QuantityOnHand := GPIV00102InventoryQty.QTYONHND;

                GPIV00105inventoryCurr.SetRange(ITEMNMBR, GPIV00101Inventory.ITEMNMBR);
                if GPIV00105inventoryCurr.FindSet() then
                    repeat
                        FoundCurrency := GPMC40000.Get(GPIV00105inventoryCurr.CURNCYID);
                    until (GPIV00105inventoryCurr.Next() = 0) or FoundCurrency;

                if FoundCurrency then
                    GPItem.UnitListPrice := GPIV00105inventoryCurr.LISTPRCE;

                GPItem.Insert();
            end;
        until GPIV00101Inventory.Next() = 0;
    end;

    local procedure UpdateGLSetupUnitRoundingPrecisionIfNeeded()
    var
        GPIV00101: Record "GP IV00101";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GPItemAggregate: Query "GP Item Aggregate";
        MaxItemPrecision: Decimal;
    begin
        GPItemAggregate.Open();
        GPItemAggregate.Read();
        MaxItemPrecision := GPIV00101.GetRoundingPrecision(GPItemAggregate.DECPLCUR);
        GPItemAggregate.Close();

        GeneralLedgerSetup.Get();
        if MaxItemPrecision < GeneralLedgerSetup."Unit-Amount Rounding Precision" then begin
            GeneralLedgerSetup."Unit-Amount Rounding Precision" := MaxItemPrecision;
            GeneralLedgerSetup.Modify();
        end;
    end;

    internal procedure PopulateGPItemTransactions()
    var
        GPPopulateItemTransactions: Query "GP Populate Item Transactions";
    begin
        GPPopulateItemTransactions.SetRange(RCPTSOLD, false);
        GPPopulateItemTransactions.SetRange(QTYTYPE, 1);
        GPPopulateItemTransactions.Open();
        while GPPopulateItemTransactions.Read() do
            InsertGPItemTransactionIfNeeded(GPPopulateItemTransactions);
    end;

    local procedure InsertGPItemTransactionIfNeeded(var GPPopulateItemTransactions: Query "GP Populate Item Transactions")
    var
        GPItemTransactions: Record "GP Item Transactions";
        GPIV00101: Record "GP IV00101";
        Item: Record Item;
    begin
        if not GPIV00101.Get(GPPopulateItemTransactions.ITEMNMBR) then
            exit;

        if not ShouldAddItemToStagingTable(GPIV00101) then
            exit;

        GPItemTransactions.Init();
        GPItemTransactions.No := CopyStr(GPPopulateItemTransactions.ITEMNMBR.Trim(), 1, MaxStrLen(Item."No."));
        GPItemTransactions.Location := CopyStr(GPPopulateItemTransactions.TRXLOCTN.Trim(), 1, MaxStrLen(GPItemTransactions.Location));
        GPItemTransactions.DateReceived := GPPopulateItemTransactions.DATERECD;
        GPItemTransactions.UnitCost := GPPopulateItemTransactions.UNITCOST;
        GPItemTransactions.ReceiptSEQNumber := GPPopulateItemTransactions.RCTSEQNM;

        // Set the quantity based on the item tracking type
        case GPPopulateItemTransactions.ITMTRKOP of
            2: // Serial
                GPItemTransactions.Quantity := 1;
            3: // Lot
                GPItemTransactions.Quantity := GPPopulateItemTransactions.QTYRECVDGPIV00300 - GPPopulateItemTransactions.QTYSOLDGPIV00300;
            else // None
                GPItemTransactions.Quantity := GPPopulateItemTransactions.QTYRECVD - GPPopulateItemTransactions.QTYSOLD;
        end;

        GPItemTransactions.CurrentCost := GPPopulateItemTransactions.CURRCOST;
        GPItemTransactions.StandardCost := GPPopulateItemTransactions.STNDCOST;

        GPItemTransactions.ReceiptNumber := CopyStr(GPPopulateItemTransactions.RCPTNMBR.Trim(), 1, MaxStrLen(GPItemTransactions.ReceiptNumber));
        GPItemTransactions.SerialNumber := CopyStr(GPPopulateItemTransactions.SERLNMBR.Trim(), 1, MaxStrLen(GPItemTransactions.SerialNumber));

        GPItemTransactions.LotNumber := CopyStr(GPPopulateItemTransactions.LOTNUMBR.Trim(), 1, MaxStrLen(GPItemTransactions.LotNumber));
        GPItemTransactions.ExpirationDate := GPPopulateItemTransactions.EXPNDATE;
        GPItemTransactions.Insert();
    end;

    internal procedure PopulateCodes()
    var
        GPCodes: Record "GP Codes";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
    begin
        if not GPGL40200.FindSet() then
            exit;

        repeat
            if GPSY00300.Get(GPGL40200.SGMTNUMB) then
                if (GPSY00300.MNSEGIND = false) then begin
                    Clear(GPCodes);
                    GPCodes.Id := CopyStr(GPSY00300.SGMTNAME.Trim(), 1, MaxStrLen(GPCodes.Id));

                    if UpperCase(GPSY00300.SGMTNAME) in ['G/L ACCOUNT', 'BUSINESS UNIT', 'ITEM', 'LOCATION', 'PERIOD'] then
                        GPCodes.Id += 's';

                    GPCodes.Name := CopyStr(GPGL40200.SGMNTID.Trim(), 1, MaxStrLen(GPCodes.Name));
                    GPCodes.Description := CopyStr(GPGL40200.DSCRIPTN.Trim(), 1, MaxStrLen(GPCodes.Description));
                    GPCodes.Insert();
                end;
        until GPGL40200.Next() = 0;
    end;

    internal procedure PopulateGPSegments()
    var
        GPSY00300: Record "GP SY00300";
        GPSegments: Record "GP Segments";
    begin
        GPSY00300.SetRange(MNSEGIND, false);
        if not GPSY00300.FindSet() then
            exit;

        repeat
            Clear(GPSegments);
            GPSegments.Id := CopyStr(UpperCase(GPSY00300.SGMTNAME.Trim()), 1, MaxStrLen(GPSegments.Id));

            if UpperCase(GPSY00300.SGMTNAME) in ['G/L ACCOUNT', 'BUSINESS UNIT', 'ITEM', 'LOCATION', 'PERIOD'] then
                GPSegments.Id += 's';

            GPSegments.Name := CopyStr(GPSY00300.SGMTNAME.Trim(), 1, MaxStrLen(GPSegments.Name));
            GPSegments.CodeCaption := CopyStr(GPSegments.Name + ' Code', 1, MaxStrLen(GPSegments.CodeCaption));
            GPSegments.FilterCaption := CopyStr(GPSegments.Name + ' Filter', 1, MaxStrLen(GPSegments.FilterCaption));
            GPSegments.SegmentNumber := GPSY00300.SGMTNUMB;
            GPSegments.Insert();
        until GPSY00300.Next() = 0;
    end;

    internal procedure PopulateGPPostingAccountsTable()
    var
        GPSY01100PostingAccounts: Record "GP SY01100";
        GPGL00100Accounts: Record "GP GL00100";
        GPPostingAccounts: Record "GP Posting Accounts";
    begin
        GPPostingAccounts.Id := 1;

        // Sales Account
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Sales');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.SalesAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.SalesAccount));
                GPPostingAccounts.SalesAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // SalesLineDiscAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Markdowns');
        GPSY01100PostingAccounts.SetRange(SERIES, 5);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.SalesLineDiscAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.SalesLineDiscAccount));
                GPPostingAccounts.SalesLineDiscAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // SalesInvDiscAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Trade Discounts');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.SalesInvDiscAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.SalesInvDiscAccount));
                GPPostingAccounts.SalesInvDiscAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // SalesPmtDiscDebitAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Term Discounts Taken');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.SalesPmtDiscDebitAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.SalesPmtDiscDebitAccount));
                GPPostingAccounts.SalesPmtDiscDebitAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Purchases');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchAccount));
                GPPostingAccounts.PurchAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchLineDiscAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Trade Discounts');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchLineDiscAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchLineDiscAccount));
                GPPostingAccounts.PurchLineDiscAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // COGSAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Cost of Goods Sold');
        GPSY01100PostingAccounts.SetRange(SERIES, 5);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.COGSAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.COGSAccount));
                GPPostingAccounts.COGSAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // InventoryAdjmtAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Inventory Control');
        GPSY01100PostingAccounts.SetRange(SERIES, 5);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.InventoryAdjmtAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.InventoryAdjmtAccount));
                GPPostingAccounts.InventoryAdjmtAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // SalesCreditMemoAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Credit Memos');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.SalesCreditMemoAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.SalesCreditMemoAccount));
                GPPostingAccounts.SalesCreditMemoAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchPmtDiscDebitAcc
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Discounts Taken');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchPmtDiscDebitAcc := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchPmtDiscDebitAcc));
                GPPostingAccounts.PurchPmtDiscDebitAccIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchPrepaymentsAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Prepayment');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchPrepaymentsAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchPrepaymentsAccount));
                GPPostingAccounts.PurchPrepaymentsAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchaseVarianceAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Purch. Price Variance');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchaseVarianceAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchaseVarianceAccount));
                GPPostingAccounts.PurchaseVarianceAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // ReceivablesAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Accounts Receivable');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.ReceivablesAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.ReceivablesAccount));
                GPPostingAccounts.ReceivablesAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // ServiceChargeAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Finance Charges');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.ServiceChargeAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.ServiceChargeAccount));
                GPPostingAccounts.ServiceChargeAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PaymentDiscDebitAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Term Discounts Taken');
        GPSY01100PostingAccounts.SetRange(SERIES, 3);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PaymentDiscDebitAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PaymentDiscDebitAccount));
                GPPostingAccounts.PaymentDiscDebitAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // Vendor Posting Group Accounts
        // PayablesAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Accounts Payable');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PayablesAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PayablesAccount));
                GPPostingAccounts.PayablesAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchServiceChargeAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Finance Charges');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchServiceChargeAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchServiceChargeAccount));
                GPPostingAccounts.PurchServiceChargeAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // PurchPmtDiscDebitAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Discounts Taken');
        GPSY01100PostingAccounts.SetRange(SERIES, 4);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.PurchPmtDiscDebitAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.PurchPmtDiscDebitAccount));
                GPPostingAccounts.PurchPmtDiscDebitAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        // Inventory Posting Group Accounts
        // InventoryAccount
        GPSY01100PostingAccounts.SetRange(PTGACDSC, 'Inventory Control');
        GPSY01100PostingAccounts.SetRange(SERIES, 5);
        if GPSY01100PostingAccounts.FindFirst() then begin
            GPGL00100Accounts.SetRange(ACTINDX, GPSY01100PostingAccounts.ACTINDX);
            if GPGL00100Accounts.FindFirst() then begin
                GPPostingAccounts.InventoryAccount := CopyStr(GPGL00100Accounts.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPPostingAccounts.InventoryAccount));
                GPPostingAccounts.InventoryAccountIdx := GPSY01100PostingAccounts.ACTINDX;
            end;
        end;

        GPPostingAccounts.Insert();
    end;

    internal procedure PopulateGPCompanySettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HybridCompany: Record "Hybrid Company";
    begin
        if not GPCompanyMigrationSettings.IsEmpty() then begin
            GPCompanyMigrationSettings.FindSet();
            repeat
                if not HybridCompany.Get(GPCompanyMigrationSettings.Name) then begin
                    if GPCompanyAdditionalSettings.Get(GPCompanyMigrationSettings.Name) then
                        GPCompanyAdditionalSettings.Delete();

                    GPCompanyMigrationSettings.Delete();
                end;
            until GPCompanyMigrationSettings.Next() = 0;
        end;

        if not HybridCompany.IsEmpty() then
            if HybridCompany.FindSet() then
                repeat
                    if not GPCompanyMigrationSettings.Get(HybridCompany.Name) then begin
                        Clear(GPCompanyMigrationSettings);
#pragma warning disable AA0139
                        // We need to throw the exception if lenght is longer
                        GPCompanyMigrationSettings.Name := HybridCompany.Name;
#pragma warning restore AA0139
                        GPCompanyMigrationSettings."Global Dimension 1" := '';
                        GPCompanyMigrationSettings."Global Dimension 2" := '';
                        GPCompanyMigrationSettings."Migrate Inactive Customers" := true;
                        GPCompanyMigrationSettings."Migrate Inactive Vendors" := true;
                        GPCompanyMigrationSettings.ProcessesAreRunning := false;
                        GPCompanyMigrationSettings.Insert();
                    end;
                until HybridCompany.Next() = 0;
    end;

    var
        ItemTrackingCodeSERIALLbl: Label 'SERIAL', Locked = true;
        ItemTrackingCodeLOTLbl: Label 'LOT', Locked = true;

}