// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

codeunit 47002 "SL Populate Account History"
{
    Access = Internal;
    trigger OnRun()
    begin
        FillSLGLAcctBalbyPeriodWrkTbl();
        PopulateSLAccountTransactionsTbl();
    end;

    internal procedure FillSLGLAcctBalbyPeriodWrkTbl()
    var
        SLGLAcctBalbyPeriodWrkTbl: Record SLGLAcctBalByPeriod;
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLGLSetup: Record "SL GLSetup";
        AccountQuery: Query "SL AcctHist Acitve Accounts";
        InitialYear: Integer;
        SLLedgerID: Text[10];
        SLYtdNetIncAcct: Text[10];
    begin
        if SLGLSetup.FindFirst() then begin
            SLLedgerID := CopyStr(SLGLSetup.LedgerID.Trim(), 1, MaxStrLen(SLLedgerID));
            SLYtdNetIncAcct := CopyStr(SLGLSetup.YtdNetIncAcct.Trim(), 1, MaxStrLen(SLYtdNetIncAcct));
        end;

        if SLGLAcctBalbyPeriodWrkTbl.FindFirst() then
            SLGLAcctBalbyPeriodWrkTbl.DeleteAll();

        AccountQuery.SetRange(CpnyID, CompanyName().Trim());
        AccountQuery.SetRange(LedgerID, SLLedgerID);
        AccountQuery.SetFilter(Active, '=%1', 1);
        AccountQuery.SetFilter(Acct, '<> %1', SLYtdNetIncAcct);

        InitialYear := SLCompanyAdditionalSettings.GetInitialYear();
        if InitialYear > 0 then
            AccountQuery.SetFilter(FiscYr, '>= %1', Format(InitialYear));

        if not AccountQuery.Open() then
            exit;

        while AccountQuery.Read() do begin
            if AccountQuery.PtdBal00 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 1;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal00 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal00 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal00;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal00 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal00 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal00;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal01 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 2;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal01 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal01 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal01;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal01 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal01 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal01;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal02 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 3;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal02 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal02 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal02;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal02 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal02 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal02;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal03 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 4;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal03 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal03 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal03;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal03 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal03 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal03;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal04 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 5;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal04 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal04 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal04;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal04 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal04 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal04;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal05 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 6;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal05 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal05 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal05;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal05 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal05 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal05;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal06 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 7;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal06 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal06 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal06;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal06 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal06 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal06;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal07 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 8;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal07 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal07 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal07;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal07 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal07 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal07;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal08 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 9;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal08 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal08 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal08;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal08 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal08 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal08;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal09 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 10;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal09 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal09 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal09;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal09 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal09 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal09;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal10 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 11;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal10 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal10 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal10;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal10 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal10 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal10;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal11 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 12;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal11 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal11 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal11;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal11 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal11 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal11;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
            if AccountQuery.PtdBal12 <> 0 then begin
                SLGLAcctBalbyPeriodWrkTbl.ACCT := AccountQuery.Acct;
                SLGLAcctBalbyPeriodWrkTbl.SUB := AccountQuery.Sub;
                SLGLAcctBalbyPeriodWrkTbl.FISCYR := AccountQuery.FiscYr;
                SLGLAcctBalbyPeriodWrkTbl.PERIODID := 13;
                case (AccountQuery.AcctType.Substring(2, 1)) of
                    'A', 'E':
                        if AccountQuery.PtdBal12 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal12 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal12;
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                        end;
                    'L', 'I':
                        if AccountQuery.PtdBal12 < 0 then begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := 0;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := AccountQuery.PtdBal12 * -1;
                        end else begin
                            SLGLAcctBalbyPeriodWrkTbl.CREDITAMT := AccountQuery.PtdBal12;
                            SLGLAcctBalbyPeriodWrkTbl.DEBITAMT := 0;
                        end;
                end;
                if SLGLAcctBalbyPeriodWrkTbl.CREDITAMT <> 0 then
                    SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT
                else
                    if SLGLAcctBalbyPeriodWrkTbl.DEBITAMT <> 0 then
                        SLGLAcctBalbyPeriodWrkTbl.PERBAL := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;

                SLGLAcctBalbyPeriodWrkTbl.Insert();
                Commit();
            end;
        end;
    end;

    internal procedure PopulateSLAccountTransactionsTbl()
    var
        SLGLAcctBalbyPeriodWrkTbl: Record SLGLAcctBalByPeriod;
        SLAccountTransactionsTbl: Record "SL AccountTransactions";
        NbrOfSegments: Integer;
    begin
        NbrOfSegments := 0;
        NbrOfSegments := GetNumberOfSegments();

        if SLAccountTransactionsTbl.FindFirst() then
            SLAccountTransactionsTbl.DeleteAll();

        if SLGLAcctBalbyPeriodWrkTbl.FindSet() then
            repeat
                case NbrOfSegments of
                    1:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := '';
                            SLAccountTransactionsTbl.SubSegment_3 := '';
                            SLAccountTransactionsTbl.SubSegment_4 := '';
                            SLAccountTransactionsTbl.SubSegment_5 := '';
                            SLAccountTransactionsTbl.SubSegment_6 := '';
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    2:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := '';
                            SLAccountTransactionsTbl.SubSegment_4 := '';
                            SLAccountTransactionsTbl.SubSegment_5 := '';
                            SLAccountTransactionsTbl.SubSegment_6 := '';
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    3:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := '';
                            SLAccountTransactionsTbl.SubSegment_5 := '';
                            SLAccountTransactionsTbl.SubSegment_6 := '';
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    4:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 4);
                            SLAccountTransactionsTbl.SubSegment_5 := '';
                            SLAccountTransactionsTbl.SubSegment_6 := '';
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    5:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 4);
                            SLAccountTransactionsTbl.SubSegment_5 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 5);
                            SLAccountTransactionsTbl.SubSegment_6 := '';
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    6:
                        begin
                            SLAccountTransactionsTbl.SetCurrentKey(Id);
                            if SLAccountTransactionsTbl.FindLast() then
                                SLAccountTransactionsTbl.Id := SLAccountTransactionsTbl.Id + 1
                            else
                                SLAccountTransactionsTbl.Id := 1;
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 4);
                            SLAccountTransactionsTbl.SubSegment_5 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 5);
                            SLAccountTransactionsTbl.SubSegment_6 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 6);
                            SLAccountTransactionsTbl.SubSegment_7 := '';
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;

                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    7:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 4);
                            SLAccountTransactionsTbl.SubSegment_5 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 5);
                            SLAccountTransactionsTbl.SubSegment_6 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 6);
                            SLAccountTransactionsTbl.SubSegment_7 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 7);
                            SLAccountTransactionsTbl.SubSegment_8 := '';
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                    8:
                        begin
                            SLAccountTransactionsTbl.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 1);
                            SLAccountTransactionsTbl.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 2);
                            SLAccountTransactionsTbl.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 3);
                            SLAccountTransactionsTbl.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 4);
                            SLAccountTransactionsTbl.SubSegment_5 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 5);
                            SLAccountTransactionsTbl.SubSegment_6 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 6);
                            SLAccountTransactionsTbl.SubSegment_7 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 7);
                            SLAccountTransactionsTbl.SubSegment_8 := GetSubAcctSegmentText(SLGLAcctBalbyPeriodWrkTbl.SUB, 7);
                            SLAccountTransactionsTbl.Balance := SLGLAcctBalbyPeriodWrkTbl.PERBAL;
                            SLAccountTransactionsTbl.DebitAmount := SLGLAcctBalbyPeriodWrkTbl.DEBITAMT;
                            SLAccountTransactionsTbl.CreditAmount := SLGLAcctBalbyPeriodWrkTbl.CREDITAMT;
                            SLAccountTransactionsTbl.Sub := SLGLAcctBalbyPeriodWrkTbl.SUB;
                            SLAccountTransactionsTbl.PERIODID := SLGLAcctBalbyPeriodWrkTbl.PERIODID;
                            SLAccountTransactionsTbl.AcctNum := SLGLAcctBalbyPeriodWrkTbl.ACCT;
                            SLAccountTransactionsTbl.Year := SLGLAcctBalbyPeriodWrkTbl.FISCYR;
                            SLAccountTransactionsTbl.Insert();
                            Commit();
                        end;
                end;
            until SLGLAcctBalbyPeriodWrkTbl.Next() = 0;
    end;

    internal procedure GetNumberOfSegments(): Integer
    var
        SLFlexDef: Record "SL FlexDef";
        NbrSegments: Integer;
    begin
        NbrSegments := 0;
        SLFlexDef.SetRange(FieldClassName, 'SUBACCOUNT');
        if SLFlexDef.FindFirst() then begin
            SegLen1 := SLFlexDef.SegLength00;
            SegLen2 := SLFlexDef.SegLength01;
            SegLen3 := SLFlexDef.SegLength02;
            SegLen4 := SLFlexDef.SegLength03;
            SegLen5 := SLFlexDef.SegLength04;
            SegLen6 := SLFlexDef.SegLength05;
            SegLen7 := SLFlexDef.SegLength06;
            SegLen8 := SLFlexDef.SegLength07;
            NbrSegments := SLFlexDef.NumberSegments;
        end;
        exit(NbrSegments);
    end;

    internal procedure GetSubAcctSegmentText(Subaccount: Text[24]; SegmentNo: Integer): Text[24]
    var
        SubaccountSegmentText: Text;
    begin
        case SegmentNo of
            1:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1, SegLen1);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            2:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1, SegLen2);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            3:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2, SegLen3);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            4:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3, SegLen4);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            5:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4, SegLen5);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            6:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5, SegLen6);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            7:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5 + SegLen6, SegLen7);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
            8:
                begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5 + SegLen6 + SegLen7, SegLen8);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end;
        end;
    end;

    var
        SegLen1: Integer;
        SegLen2: Integer;
        SegLen3: Integer;
        SegLen4: Integer;
        SegLen5: Integer;
        SegLen6: Integer;
        SegLen7: Integer;
        SegLen8: Integer;
}
