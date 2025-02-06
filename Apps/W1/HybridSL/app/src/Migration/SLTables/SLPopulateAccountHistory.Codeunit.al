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
        FillSLGLAcctBalByPeriod();
        PopulateSLAccountTransactions();
    end;

    internal procedure FillSLGLAcctBalByPeriod()
    var
        SLGLAcctBalByPeriod: Record SLGLAcctBalByPeriod;
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLGLSetup: Record "SL GLSetup";
        AccountQuery: Query "SL AcctHist Active Accounts";
        InitialYear: Integer;
        SLLedgerID: Text[10];
        SLYtdNetIncAcct: Text[10];
    begin
        if SLGLSetup.FindFirst() then begin
            SLLedgerID := CopyStr(SLGLSetup.LedgerID.Trim(), 1, MaxStrLen(SLLedgerID));
            SLYtdNetIncAcct := CopyStr(SLGLSetup.YtdNetIncAcct.Trim(), 1, MaxStrLen(SLYtdNetIncAcct));
        end;

        if SLGLAcctBalByPeriod.FindFirst() then
            SLGLAcctBalByPeriod.DeleteAll();

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
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal00, 1);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal01, 2);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal02, 3);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal03, 4);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal04, 5);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal05, 6);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal06, 7);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal07, 8);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal08, 9);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal09, 10);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal10, 11);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal11, 12);
            ProcessAccountQueryPeriod(AccountQuery, SLGLAcctBalByPeriod, AccountQuery.PtdBal12, 13);
        end;
    end;

    internal procedure ProcessAccountQueryPeriod(AccountQuery: Query "SL AcctHist Active Accounts"; var SLGLAcctBalByPeriod: Record SLGLAcctBalByPeriod; PtdBal: Decimal; PeriodID: Integer)
    begin
        if PtdBal <> 0 then begin
            SLGLAcctBalByPeriod.ACCT := AccountQuery.Acct;
            SLGLAcctBalByPeriod.SUB := AccountQuery.Sub;
            SLGLAcctBalByPeriod.FISCYR := AccountQuery.FiscYr;
            SLGLAcctBalByPeriod.PERIODID := PeriodID;
            case (AccountQuery.AcctType.Substring(2, 1)) of
                'A', 'E':  // Asset, Expense
                    if PtdBal < 0 then begin
                        SLGLAcctBalByPeriod.DEBITAMT := 0;
                        SLGLAcctBalByPeriod.CREDITAMT := PtdBal * -1;
                        SLGLAcctBalByPeriod.PERBAL := PtdBal;
                    end else begin
                        SLGLAcctBalByPeriod.DEBITAMT := PtdBal;
                        SLGLAcctBalByPeriod.CREDITAMT := 0;
                        SLGLAcctBalByPeriod.PERBAL := PtdBal;
                    end;
                'L', 'I':  // Liability, Income
                    if PtdBal < 0 then begin
                        SLGLAcctBalByPeriod.CREDITAMT := 0;
                        SLGLAcctBalByPeriod.DEBITAMT := PtdBal * -1;
                        SLGLAcctBalByPeriod.PERBAL := PtdBal;
                    end else begin
                        SLGLAcctBalByPeriod.CREDITAMT := PtdBal;
                        SLGLAcctBalByPeriod.DEBITAMT := 0;
                        SLGLAcctBalByPeriod.PERBAL := PtdBal;
                    end;
            end;
            SLGLAcctBalByPeriod.Insert();
            Commit();
        end;
    end;

    internal procedure PopulateSLAccountTransactions()
    var
        SLGLAcctBalByPeriod: Record SLGLAcctBalByPeriod;
        SLAccountTransactions: Record "SL AccountTransactions";
        NbrOfSegments: Integer;
    begin
        NbrOfSegments := GetNumberOfSegments();

        if SLAccountTransactions.FindFirst() then
            SLAccountTransactions.DeleteAll();

        if SLGLAcctBalByPeriod.FindSet() then
            repeat
                PopulateTransaction(SLGLAcctBalByPeriod, SLAccountTransactions, NbrOfSegments);
            until SLGLAcctBalByPeriod.Next() = 0;
    end;

    internal procedure PopulateTransaction(SLGLAcctBalByPeriod: Record SLGLAcctBalByPeriod; var SLAccountTransactions: Record "SL AccountTransactions"; NbrOfSegments: Integer)
    begin
        Clear(SLAccountTransactions);
        SLAccountTransactions.SubSegment_1 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 1, NbrOfSegments);
        SLAccountTransactions.SubSegment_2 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 2, NbrOfSegments);
        SLAccountTransactions.SubSegment_3 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 3, NbrOfSegments);
        SLAccountTransactions.SubSegment_4 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 4, NbrOfSegments);
        SLAccountTransactions.SubSegment_5 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 5, NbrOfSegments);
        SLAccountTransactions.SubSegment_6 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 6, NbrOfSegments);
        SLAccountTransactions.SubSegment_7 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 7, NbrOfSegments);
        SLAccountTransactions.SubSegment_8 := GetSubAcctSegmentText(SLGLAcctBalByPeriod.SUB, 8, NbrOfSegments);
        SLAccountTransactions.Balance := SLGLAcctBalByPeriod.PERBAL;
        SLAccountTransactions.DebitAmount := SLGLAcctBalByPeriod.DEBITAMT;
        SLAccountTransactions.CreditAmount := SLGLAcctBalByPeriod.CREDITAMT;
        SLAccountTransactions.Sub := SLGLAcctBalByPeriod.SUB;
        SLAccountTransactions.PERIODID := SLGLAcctBalByPeriod.PERIODID;
        SLAccountTransactions.AcctNum := SLGLAcctBalByPeriod.ACCT;
        SLAccountTransactions.Year := SLGLAcctBalByPeriod.FISCYR;
        SLAccountTransactions.Insert();
        Commit();
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

    internal procedure GetSubAcctSegmentText(Subaccount: Text[24]; SegmentNo: Integer; NbrOfSegments: Integer): Text[24]
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
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1, SegLen2);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            3:
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2, SegLen3);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            4:
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3, SegLen4);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            5:
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4, SegLen5);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            6:
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5, SegLen6);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            7:
                if NbrOfSegments >= SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5 + SegLen6, SegLen7);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
            8:
                if NbrOfSegments = SegmentNo then begin
                    SubaccountSegmentText := CopyStr(Subaccount, 1 + SegLen1 + SegLen2 + SegLen3 + SegLen4 + SegLen5 + SegLen6 + SegLen7, SegLen8);
                    exit(Copystr(SubaccountSegmentText, 1, MaxStrLen(Subaccount)));
                end
                else
                    exit('');
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