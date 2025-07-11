// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Check;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Automation;
using System.Utilities;

report 18935 "Check Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdlc/Check.rdl';
    Caption = 'Check';
    Permissions = TableData "Bank Account" = m;

    dataset
    {
        dataitem(VoidGenJnlLine; "Gen. Journal Line")
        {
            DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            RequestFilterFields = "Journal Template Name", "Journal Batch Name", "Posting Date";


            trigger OnAfterGetRecord()
            var
                GenJnlLine4: Record "Gen. Journal Line";
            begin
                GenJnlLine4.Reset();
                GenJnlLine4.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                GenJnlLine4.SetRange("Journal Template Name", "Journal Template Name");
                GenJnlLine4.SetRange("Journal Batch Name", "Journal Batch Name");
                GenJnlLine4.SetRange("Posting Date", "Posting Date");
                GenJnlLine4.SetRange("Document No.", "Document No.");
                GenJnlLine4.SetRange("Account Type", GenJnlLine4."Account Type"::"Bank Account");
                if not GenJnlLine4.IsEmpty then
                    CheckManagement.VoidCheck(VoidGenJnlLine);
            end;

            trigger OnPreDataItem()
            begin
                if CurrReport.PREVIEW then
                    Error(NotPreviewLbl);

                if UseCheckNo = '' then
                    Error(LastCheckLbl);

                if TestPrint then
                    CurrReport.Break();

                if not PrintChecks then
                    CurrReport.Break();

                if (GetFilter("Line No.") <> '') or (GetFilter("Document No.") <> '') then
                    Error(
                      FilterLbl, FieldCaption("Line No."), FieldCaption("Document No."));
                SetRange("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                SetRange("Check Printed", true);
            end;
        }
        dataitem(GenJnlLine; "Gen. Journal Line")
        {
            DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");

            column(JnlTemplateName_GenJnlLine; "Journal Template Name")
            {
            }
            column(JnlBatchName_GenJnlLine; "Journal Batch Name")
            {
            }
            column(LineNo_GenJnlLine; "Line No.")
            {
            }
            dataitem(CheckPages; Integer)
            {
                DataItemTableView = sorting(Number);

                column(CheckToAddr1; CheckToAddr[1])
                {
                }
                column(CheckDateText1; CheckDateText)
                {
                }
                column(CheckNoText1; CheckNoText)
                {
                }
                column(FirstPage; FirstPage)
                {
                }
                column(PreprintedStub; PrintedStub)
                {
                }
                column(CheckNoCaption; CheckNoCaptionLbl)
                {
                }
                dataitem(PrintSettledLoop; Integer)
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 30;

                    column(NetAmt; NetAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalLineDiscLineDisc; TotalLineDiscount - LineDiscount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalLineAmtLineAmt; TotalLineAmount - LineAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TDSAmt; TDSAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalLineAmtLineAmt2; TotalLineAmount - LineAmount2 - TDSAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(LineAmt; LineAmount - TDSAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(LineDisc; LineDiscount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(LineAmtLineDisc; LineAmount + LineDiscount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(DocNo; DocNo)
                    {
                    }
                    column(DocDate; Format(DocDate))
                    {
                    }
                    column(CurrencyCode2; CurrencyCode2)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(CurrentLineAmt; LineAmount2 - TDSAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(ExtDocNo; ExtDocNo)
                    {
                    }
                    column(NetAmtCaption; NetAmtCaptionLbl)
                    {
                    }
                    column(DiscCaption; DiscCaptionLbl)
                    {
                    }
                    column(AmtCaption; AmtCaptionLbl)
                    {
                    }
                    column(DocNoCaption; DocNoCaptionLbl)
                    {
                    }
                    column(DocDateCaption; DocDateCaptionLbl)
                    {
                    }
                    column(CurrCodeCaption; CurrCodeCaptionLbl)
                    {
                    }
                    column(YourDocNoCaption; YourDocNoCaptionLbl)
                    {
                    }
                    column(TDSCaption; TDSCaptionLbl)
                    {
                    }
                    column(TransportCaption; TransportCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if not TestPrint then begin
                            if FoundLast then begin
                                if RemainingAmount <> 0 then begin
                                    DocType := DocTypeLbl;
                                    DocNo := '';
                                    ExtDocNo := '';
                                    DocDate := 0D;
                                    LineAmount := RemainingAmount;
                                    LineAmount2 := RemainingAmount;
                                    CurrentLineAmount := LineAmount2;
                                    LineDiscount := 0;
                                    RemainingAmount := 0;
                                end else
                                    CurrReport.Break();
                            end else
                                case ApplyMethod of
                                    ApplyMethod::OneLineOneEntry:
                                        begin
                                            case BalancingType of
                                                BalancingType::Customer:
                                                    GetAppliedAmtBasedOnBalancingType(BalancingType, ApplyMethod);
                                                BalancingType::Vendor:
                                                    GetAppliedAmtBasedOnBalancingType(BalancingType, ApplyMethod);
                                            end;
                                            RemainingAmount := RemainingAmount - LineAmount2;
                                            CurrentLineAmount := LineAmount2;
                                            FoundLast := true;
                                        end;
                                    ApplyMethod::OneLineID:
                                        begin
                                            case BalancingType of
                                                BalancingType::Customer:
                                                    begin
                                                        CustUpdateAmounts(CustLedgEntry, RemainingAmount);
                                                        FoundLast := (CustLedgEntry.Next() = 0) or (RemainingAmount <= 0);
                                                        if FoundLast and not FoundNegative then begin
                                                            CustLedgEntry.SetRange(Positive, false);
                                                            FoundLast := not CustLedgEntry.Find('-');
                                                            FoundNegative := true;
                                                        end;
                                                    end;
                                                BalancingType::Vendor:
                                                    begin
                                                        VendUpdateAmounts(VendLedgEntry, RemainingAmount);
                                                        FoundLast := (VendLedgEntry.Next() = 0) or (RemainingAmount <= 0);
                                                        if FoundLast and not FoundNegative then begin
                                                            VendLedgEntry.SetRange(Positive, false);
                                                            FoundLast := not VendLedgEntry.Find('-');
                                                            FoundNegative := true;
                                                        end;
                                                    end;
                                            end;
                                            RemainingAmount := RemainingAmount - LineAmount2;
                                            CurrentLineAmount := LineAmount2;
                                        end;
                                    ApplyMethod::MoreLinesOneEntry:
                                        begin
                                            CurrentLineAmount := GenJnlLine2.Amount;
                                            LineAmount2 := CurrentLineAmount;

                                            if GenJnlLine2."Applies-to ID" <> '' then
                                                Error(CHeckRepLbl);
                                            GenJnlLine2.TestField("Check Printed", false);
                                            GenJnlLine2.TestField("Bank Payment Type", GenJnlLine2."Bank Payment Type"::"Computer Check");
                                            if BankAcc2."Currency Code" <> GenJnlLine2."Currency Code" then
                                                Error(SamecurrencyLbl);
                                            if GenJnlLine2."Applies-to Doc. No." = '' then begin
                                                DocType := DocTypeLbl;
                                                DocNo := '';
                                                ExtDocNo := '';
                                                DocDate := 0D;
                                                LineAmount := CurrentLineAmount;
                                                LineDiscount := 0;
                                            end else
                                                case BalancingType of
                                                    BalancingType::"G/L Account":
                                                        begin
                                                            DocType := Format(GenJnlLine2."Document Type");
                                                            DocNo := GenJnlLine2."Document No.";
                                                            ExtDocNo := GenJnlLine2."External Document No.";
                                                            LineAmount := CurrentLineAmount;
                                                            LineDiscount := 0;
                                                        end;
                                                    BalancingType::Customer:
                                                        GetAppliedAmtBasedOnBalancingType(BalancingType, ApplyMethod);
                                                    BalancingType::Vendor:
                                                        GetAppliedAmtBasedOnBalancingType(BalancingType, ApplyMethod);
                                                    BalancingType::"Bank Account":
                                                        begin
                                                            DocType := Format(GenJnlLine2."Document Type");
                                                            DocNo := GenJnlLine2."Document No.";
                                                            ExtDocNo := GenJnlLine2."External Document No.";
                                                            LineAmount := CurrentLineAmount;
                                                            LineDiscount := 0;
                                                        end;
                                                end;
                                            FoundLast := GenJnlLine2.Next() = 0;
                                        end;
                                end;

                            TotalLineAmount := TotalLineAmount + LineAmount2;
                            TotalLineDiscount := TotalLineDiscount + LineDiscount;
                        end else begin
                            if FoundLast then
                                CurrReport.Break();
                            FoundLast := true;
                            DocType := DocType1Lbl;
                            DocNo := DocExtNoLbl;
                            ExtDocNo := DocExtNoLbl;
                            LineAmount := 0;
                            LineDiscount := 0;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not TestPrint then
                            if FirstPage then begin
                                FoundLast := true;
                                case ApplyMethod of
                                    ApplyMethod::OneLineOneEntry:
                                        FoundLast := false;
                                    ApplyMethod::OneLineID:
                                        case BalancingType of
                                            BalancingType::Customer:
                                                begin
                                                    CustLedgEntry.Reset();
                                                    CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                                                    CustLedgEntry.SetRange("Customer No.", BalancingNo);
                                                    CustLedgEntry.SetRange(Open, true);
                                                    CustLedgEntry.SetRange(Positive, true);
                                                    CustLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                                                    FoundLast := not CustLedgEntry.Find('-');
                                                    if FoundLast then begin
                                                        CustLedgEntry.SetRange(Positive, false);
                                                        FoundLast := not CustLedgEntry.Find('-');
                                                        FoundNegative := true;
                                                    end else
                                                        FoundNegative := false;
                                                end;
                                            BalancingType::Vendor:
                                                begin
                                                    VendLedgEntry.Reset();
                                                    VendLedgEntry.SetCurrentKey("Vendor No.", Open, Positive);
                                                    VendLedgEntry.SetRange("Vendor No.", BalancingNo);
                                                    VendLedgEntry.SetRange(Open, true);
                                                    VendLedgEntry.SetRange(Positive, true);
                                                    VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                                                    FoundLast := not VendLedgEntry.Find('-');
                                                    if FoundLast then begin
                                                        VendLedgEntry.SetRange(Positive, false);
                                                        FoundLast := not VendLedgEntry.Find('-');
                                                        FoundNegative := true;
                                                    end else
                                                        FoundNegative := false;
                                                end;
                                        end;
                                    ApplyMethod::MoreLinesOneEntry:
                                        FoundLast := false;
                                end;
                            end
                            else
                                FoundLast := false;

                        if DocNo = '' then
                            CurrencyCode2 := GenJnlLine."Currency Code";

                        if PrintedStub then
                            TotalText := ''
                        else
                            TotalText := TotalTExtLbl;

                        if GenJnlLine."Currency Code" <> '' then
                            NetAmount := StrSubstNo(NetAmtLbl, GenJnlLine."Currency Code")
                        else begin
                            GLSetup.Get();
                            NetAmount := StrSubstNo(NetAmtLbl, GLSetup."LCY Code");
                        end;
                    end;
                }
                dataitem(PrintCheck; Integer)
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 1;

                    column(CheckAmountText; CheckAmountText)
                    {
                    }
                    column(CheckDateText2; CheckDateText)
                    {
                    }
                    column(CommentLine2; DescriptionLine[2])
                    {
                    }
                    column(CommentLine1; DescriptionLine[1])
                    {
                    }
                    column(CheckToAddr6; CheckToAddr[1])
                    {
                    }
                    column(CheckToAddr2; CheckToAddr[2])
                    {
                    }
                    column(CheckToAddr4; CheckToAddr[4])
                    {
                    }
                    column(CheckToAddr3; CheckToAddr[3])
                    {
                    }
                    column(CheckToAddr5; CheckToAddr[5])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(CompanyAddr8; CompanyAddr[8])
                    {
                    }
                    column(CompanyAddr7; CompanyAddr[7])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(CheckNoText2; CheckNoText)
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(TotalLineAmount; TotalLineAmount - TDSAmount)
                    {
                        AutoFormatExpression = GenJnlLine."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(TotalText; TotalText)
                    {
                    }
                    column(VoidText; VoidText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Decimals: Decimal;
                        CheckLedgEntryAmount: Decimal;
                    begin
                        if not TestPrint then begin
                            if GLSetup."Activate Cheque No." then
                                GenJnlLine.TestField("Document No.");
                            CheckLedgEntry.Init();
                            CheckLedgEntry."Bank Account No." := BankAcc2."No.";
                            CheckLedgEntry."Posting Date" := GenJnlLine."Posting Date";
                            CheckLedgEntry."Document Type" := GenJnlLine."Document Type";
                            if not GLSetup."Activate Cheque No." then
                                CheckLedgEntry."Document No." := UseCheckNo
                            else begin
                                CheckLedgEntry."Document No." := GenJnlLine."Document No.";
                                CheckLedgEntry."Check No." := UseCheckNo;
                            end;
                            CheckLedgEntry.Description := GenJnlLine.Description;
                            CheckLedgEntry."Bank Payment Type" := GenJnlLine."Bank Payment Type";
                            CheckLedgEntry."Bal. Account Type" := BalancingType;
                            CheckLedgEntry."Bal. Account No." := BalancingNo;
                            if FoundLast then begin
                                if TotalLineAmount <= 0 then
                                    Error(
                                      TotAmtPosLbl,
                                      UseCheckNo, TotalLineAmount);
                                CheckLedgEntry."Entry Status" := CheckLedgEntry."Entry Status"::Printed;
                                CheckLedgEntry.Amount := TotalLineAmount - Abs(TDSAmount);
                            end else begin
                                CheckLedgEntry."Entry Status" := CheckLedgEntry."Entry Status"::Voided;
                                CheckLedgEntry.Amount := 0;
                            end;
                            if not GLSetup."Activate Cheque No." then
                                CheckLedgEntry."Check Date" := GenJnlLine."Posting Date"
                            else
                                if GenJnlLine."Cheque Date" <> 0D then
                                    CheckLedgEntry."Check Date" := GenJnlLine."Cheque Date"
                                else
                                    CheckLedgEntry."Check Date" := GenJnlLine."Posting Date";
                            CheckLedgEntry."Stale Cheque Expiry Date" :=
                                CalcDate(BankAcc2."Stale Cheque Stipulated Period", CheckLedgEntry."Check Date");
                            CheckLedgEntry."Check No." := UseCheckNo;
                            CheckManagement.InsertCheck(CheckLedgEntry, RecordId);

                            if FoundLast then begin
                                if BankAcc2."Currency Code" <> '' then
                                    Currency.Get(BankAcc2."Currency Code")
                                else
                                    Currency.InitRoundingPrecision();
                                CheckLedgEntryAmount := CheckLedgEntry.Amount;
                                Decimals := CheckLedgEntry.Amount - Round(CheckLedgEntry.Amount, 1, '<');
                                if StrLen(Format(Decimals)) < StrLen(Format(Currency."Amount Rounding Precision")) then
                                    if Decimals = 0 then
                                        CheckAmountText := Format(CheckLedgEntryAmount, 0, 0) +
                                          CopyStr(Format(0.01), 2, 1) +
                                          PadStr('', StrLen(Format(Currency."Amount Rounding Precision")) - 2, '0')
                                    else
                                        CheckAmountText := CopyStr((Format(CheckLedgEntryAmount, 0, 0) +
                                          PadStr('', StrLen(Format(Currency."Amount Rounding Precision")) - StrLen(Format(Decimals)), '0')), 1, 30)
                                else
                                    CheckAmountText := Format(CheckLedgEntryAmount, 0, 0);
                                FormatNoText(DescriptionLine, CheckLedgEntry.Amount, BankAcc2."Currency Code");
                                VoidText := '';
                            end else begin
                                Clear(CheckAmountText);
                                Clear(DescriptionLine);
                                TotalText := SubTotLbl;
                                DescriptionLine[1] := TotVoidLbl;
                                DescriptionLine[2] := DescriptionLine[1];
                                VoidText := NonNegoLbl;
                            end;
                        end else begin
                            CheckLedgEntry.Init();
                            CheckLedgEntry."Bank Account No." := BankAcc2."No.";
                            CheckLedgEntry."Posting Date" := GenJnlLine."Posting Date";
                            CheckLedgEntry."Document No." := UseCheckNo;
                            CheckLedgEntry.Description := TestPrintLbl;
                            CheckLedgEntry."Bank Payment Type" := "Bank Payment Type"::"Computer Check";
                            CheckLedgEntry."Entry Status" := CheckLedgEntry."Entry Status"::"Test Print";
                            if not GLSetup."Activate Cheque No." then
                                CheckLedgEntry."Check Date" := GenJnlLine."Posting Date"
                            else
                                if CheckLedgEntry."Check Date" <> 0D then
                                    CheckLedgEntry."Check Date" := GenJnlLine."Cheque Date"
                                else
                                    CheckLedgEntry."Check Date" := GenJnlLine."Posting Date";
                            CheckLedgEntry."Check No." := UseCheckNo;
                            CheckManagement.InsertCheck(CheckLedgEntry, RecordId);

                            CheckAmountText := CheckAmttextLbl;
                            DescriptionLine[1] := DescripLineLbl;
                            DescriptionLine[2] := DescriptionLine[1];
                            VoidText := NonNegoLbl;
                        end;
                        ChecksPrinted := ChecksPrinted + 1;
                        FirstPage := false;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if FoundLast then
                        CurrReport.Break();

                    UseCheckNo := IncStr(UseCheckNo);
                    if not TestPrint then
                        CheckNoText := UseCheckNo
                    else
                        CheckNoText := ChckNoLbl;
                end;

                trigger OnPostDataItem()
                var
                    RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
                begin
                    if not TestPrint then begin
                        if UseCheckNo <> GenJnlLine."Document No." then begin
                            GenJnlLine3.Reset();
                            GenJnlLine3.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                            GenJnlLine3.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                            GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                            GenJnlLine3.SetRange("Posting Date", GenJnlLine."Posting Date");
                            if not GLSetup."Activate Cheque No." then begin
                                GenJnlLine3.SetRange("Document No.", UseCheckNo);
                                if GenJnlLine3.Find('-') then
                                    GenJnlLine3.FieldError("Document No.", StrSubstNo(AlreadyLbl, UseCheckNo));
                            end else begin
                                GenJnlLine3.SetRange("Cheque No.", UseCheckNo);
                                if GenJnlLine3.Find('-') then
                                    GenJnlLine3.FieldError("Cheque No.", StrSubstNo(AlreadyLbl, UseCheckNo));
                            end;
                        end;

                        if ApplyMethod <> ApplyMethod::MoreLinesOneEntry then begin
                            GenJnlLine3 := GenJnlLine;
                            if not GLSetup."Activate Cheque No." then begin
                                GenJnlLine3.TestField("Posting No. Series", '');
                                GenJnlLine3."Document No." := UseCheckNo;
                                GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                if GenJnlLine."Cheque Date" = 0D then
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                            end else begin
                                GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                if GenJnlLine."Cheque Date" = 0D then
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                            end;
                            GenJnlLine3."Check Printed" := true;
                            GenJnlLine3.Modify();
                        end else begin
                            if GenJnlLine2.Find('-') then begin
                                HighestLineNo := GenJnlLine2."Line No.";
                                repeat
                                    RecordRestrictionMgt.CheckRecordHasUsageRestrictions(GenJnlLine2.RecordId);
                                    if GenJnlLine2."Line No." > HighestLineNo then
                                        HighestLineNo := GenJnlLine2."Line No.";
                                    GenJnlLine3 := GenJnlLine2;
                                    if not GLSetup."Activate Cheque No." then
                                        GenJnlLine3.TestField("Posting No. Series", '');
                                    GenJnlLine3."Bal. Account No." := '';
                                    GenJnlLine3."Bank Payment Type" := GenJnlLine3."Bank Payment Type"::" ";
                                    if not GLSetup."Activate Cheque No." then begin
                                        GenJnlLine3."Document No." := UseCheckNo;
                                        GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                        if GenJnlLine."Cheque Date" <> 0D then
                                            GenJnlLine3."Cheque Date" := GenJnlLine."Cheque Date"
                                        else
                                            GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                                    end else begin
                                        GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                        if GenJnlLine."Cheque Date" <> 0D then
                                            GenJnlLine3."Cheque Date" := GenJnlLine."Cheque Date"
                                        else
                                            GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                                    end;
                                    GenJnlLine3."Check Printed" := true;
                                    GenJnlLine3.Validate(Amount);
                                    GenJnlLine3.Modify();
                                until GenJnlLine2.Next() = 0;
                            end;

                            GenJnlLine3.Reset();
                            GenJnlLine3 := GenJnlLine;
                            GenJnlLine3.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                            GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                            GenJnlLine3."Line No." := HighestLineNo;
                            if GenJnlLine3.Next() = 0 then
                                GenJnlLine3."Line No." := HighestLineNo + 10000
                            else begin
                                while GenJnlLine3."Line No." = HighestLineNo + 1 do begin
                                    HighestLineNo := GenJnlLine3."Line No.";
                                    if GenJnlLine3.Next() = 0 then
                                        GenJnlLine3."Line No." := HighestLineNo + 20000;
                                end;
                                GenJnlLine3."Line No." := (GenJnlLine3."Line No." + HighestLineNo) div 2;
                            end;
                            GenJnlLine3.Init();
                            GenJnlLine3.Validate("Posting Date", GenJnlLine."Posting Date");
                            GenJnlLine3."Document Type" := GenJnlLine."Document Type";
                            if not GLSetup."Activate Cheque No." then begin
                                GenJnlLine3."Document No." := UseCheckNo;
                                GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                if GenJnlLine."Cheque Date" <> 0D then
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Cheque Date"
                                else
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                            end else begin
                                GenJnlLine3."Document No." := GenJnlLine."Document No.";
                                GenJnlLine3."Cheque No." := CopyStr(UseCheckNo, 1, 10);
                                if GenJnlLine."Cheque Date" <> 0D then
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Cheque Date"
                                else
                                    GenJnlLine3."Cheque Date" := GenJnlLine."Posting Date";
                            end;
                            GenJnlLine3."Account Type" := GenJnlLine3."Account Type"::"Bank Account";
                            GenJnlLine3.Validate("Account No.", BankAcc2."No.");
                            if BalancingType <> BalancingType::"G/L Account" then
                                GenJnlLine3.Description := StrSubstNo(BAlTypeNoLbl, SelectStr(BalancingType + 1, Text062Lbl), BalancingNo);
                            GenJnlLine3.Validate(Amount, -TotalLineAmount);
                            GenJnlLine3."Bank Payment Type" := GenJnlLine3."Bank Payment Type"::"Computer Check";
                            GenJnlLine3."Check Printed" := true;
                            GenJnlLine3."Source Code" := GenJnlLine."Source Code";
                            GenJnlLine3."Reason Code" := GenJnlLine."Reason Code";
                            GenJnlLine3."Allow Zero-Amount Posting" := true;
                            GenJnlLine3."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
                            GenJnlLine3."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
                            GenJnlLine3.Insert();
                            if CheckGenJournalBatchAndLineIsApproved(GenJnlLine) then
                                RecordRestrictionMgt.AllowRecordUsage(GenJnlLine3.RecordId);
                        end;
                    end;
                    BankAcc2."Last Check No." := UseCheckNo;
                    BankAcc2.Modify();
                    Clear(CheckManagement);
                end;

                trigger OnPreDataItem()
                begin
                    FirstPage := true;
                    FoundLast := false;
                    TotalLineAmount := 0;
                    TotalLineDiscount := 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                TaxBaseLibrary: Codeunit "Tax Base Library";
            begin
                if OneCheckPrVendor and ("Currency Code" <> '') and
                   ("Currency Code" <> Currency.Code)
                then begin
                    Currency.Get("Currency Code");
                    Currency.TestField("Conv. LCY Rndg. Debit Acc.");
                    Currency.TestField("Conv. LCY Rndg. Credit Acc.");
                end;
                JournalPostingDate := "Posting Date";
                if "Bank Payment Type" = "Bank Payment Type"::"Computer Check" then
                    TestField("Exported to Payment File", false);

                if not TestPrint then begin
                    if Amount = 0 then
                        CurrReport.Skip();

                    TestField("Bal. Account Type", "Bal. Account Type"::"Bank Account");
                    if "Bal. Account No." <> BankAcc2."No." then
                        CurrReport.Skip();

                    if ("Account No." <> '') and ("Bal. Account No." <> '') then begin
                        BalancingType := "Account Type";
                        BalancingNo := "Account No.";
                        RemainingAmount := Amount;
                        TaxBaseLibrary.GetTDSAmount(GenJnlLine, TDSAmount);
                        if OneCheckPrVendor then begin
                            ApplyMethod := ApplyMethod::MoreLinesOneEntry;
                            GenJnlLine2.Reset();
                            GenJnlLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                            GenJnlLine2.SetRange("Journal Template Name", "Journal Template Name");
                            GenJnlLine2.SetRange("Journal Batch Name", "Journal Batch Name");
                            GenJnlLine2.SetRange("Posting Date", "Posting Date");
                            GenJnlLine2.SetRange("Document No.", "Document No.");
                            GenJnlLine2.SetRange("Account Type", "Account Type");
                            GenJnlLine2.SetRange("Account No.", "Account No.");
                            GenJnlLine2.SetRange("Bal. Account Type", "Bal. Account Type");
                            GenJnlLine2.SetRange("Bal. Account No.", "Bal. Account No.");
                            GenJnlLine2.SetRange("Bank Payment Type", "Bank Payment Type");
                            GenJnlLine2.Find('-');
                            RemainingAmount := 0;
                        end else
                            if "Applies-to Doc. No." <> '' then
                                ApplyMethod := ApplyMethod::OneLineOneEntry
                            else
                                if "Applies-to ID" <> '' then
                                    ApplyMethod := ApplyMethod::OneLineID
                                else
                                    ApplyMethod := ApplyMethod::Payment;
                    end else
                        if "Account No." = '' then
                            FieldError("Account No.", MustLbl)
                        else
                            FieldError("Bal. Account No.", MustLbl);

                    Clear(CheckToAddr);
                    ContactText := '';
                    Clear(SalesPurchPerson);
                    case BalancingType of
                        BalancingType::"G/L Account":
                            CheckToAddr[1] := CopyStr(Description, 1, 50);
                        BalancingType::Customer:
                            begin
                                Cust.Get(BalancingNo);
                                if Cust."Privacy Blocked" then
                                    Error(Cust.GetPrivacyBlockedGenericErrorText(Cust));

                                if Cust.Blocked = Cust.Blocked::All then
                                    Error(FieldCapTableCapLbl, Cust.FieldCaption(Blocked), Cust.Blocked, Cust.TableCaption, Cust."No.");
                                Cust.Contact := '';
                                FormatAddr.Customer(CheckToAddr, Cust);
                                if BankAcc2."Currency Code" <> "Currency Code" then
                                    Error(SamecurrencyLbl);
                                if Cust."Salesperson Code" <> '' then begin
                                    ContactText := SalespersonLbl;
                                    SalesPurchPerson.Get(Cust."Salesperson Code");
                                end;
                            end;
                        BalancingType::Vendor:
                            begin
                                Vend.Get(BalancingNo);
                                if Vend."Privacy Blocked" then
                                    Error(Vend.GetPrivacyBlockedGenericErrorText(Vend));

                                if Vend.Blocked in [Vend.Blocked::All, Vend.Blocked::Payment] then
                                    Error(FieldCapTableCapLbl, Vend.FieldCaption(Blocked), Vend.Blocked, Vend.TableCaption, Vend."No.");
                                Vend.Contact := '';
                                FormatAddr.Vendor(CheckToAddr, Vend);
                                if BankAcc2."Currency Code" <> "Currency Code" then
                                    Error(SamecurrencyLbl);
                                if Vend."Purchaser Code" <> '' then begin
                                    ContactText := PurchaserLbl;
                                    SalesPurchPerson.Get(Vend."Purchaser Code");
                                end;
                            end;
                        BalancingType::"Bank Account":
                            begin
                                BankAcc.Get(BalancingNo);
                                BankAcc.TestField(Blocked, false);
                                BankAcc.Contact := '';
                                FormatAddr.BankAcc(CheckToAddr, BankAcc);
                                if BankAcc2."Currency Code" <> BankAcc."Currency Code" then
                                    Error(BankcurrencyLbl);
                                if BankAcc."Our Contact Code" <> '' then begin
                                    ContactText := ContactLbl;
                                    SalesPurchPerson.Get(BankAcc."Our Contact Code");
                                end;
                            end;
                    end;
                    if "Cheque Date" <> 0D then
                        CheckDateText := Format("Cheque Date", 0, 4)
                    else
                        CheckDateText := Format("Posting Date", 0, 4);
                end else begin
                    if ChecksPrinted > 0 then
                        CurrReport.Break();
                    BalancingType := BalancingType::Vendor;
                    BalancingNo := DocExtNoLbl;
                    Clear(CheckToAddr);
                    for i := 1 to 5 do
                        CheckToAddr[i] := CheckCompAddLbl;
                    ContactText := '';
                    Clear(SalesPurchPerson);
                    CheckNoText := ChckNoLbl;
                    CheckDateText := CheckDateLbl;
                end;
            end;

            trigger OnPreDataItem()
            begin
                Copy(VoidGenJnlLine);
                CompanyInfo.Get();
                if not TestPrint then begin
                    FormatAddr.Company(CompanyAddr, CompanyInfo);
                    BankAcc2.Get(BankAcc2."No.");
                    BankAcc2.TestField(Blocked, false);
                    Copy(VoidGenJnlLine);
                    SetRange("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                    SetRange("Check Printed", false);
                end else begin
                    Clear(CompanyAddr);
                    for i := 1 TO 5 do
                        CompanyAddr[i] := CheckCompAddLbl;
                end;
                ChecksPrinted := 0;

                SetRange("Account Type", "Account Type"::"Fixed Asset");
                if Find('-') then
                    FieldError("Account Type");
                SetRange("Account Type");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BankAccount; BankAcc2."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Account';
                        TableRelation = "Bank Account";
                        ToolTip = 'Specifies the bank account that the printed checks will be drawn from.';

                        trigger OnValidate()
                        begin
                            InputBankAccount();
                        end;
                    }
                    field(LastCheckNo; UseCheckNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Check No.';
                        ToolTip = 'Specifies the value of the Last Check No. field on the bank account card.';
                    }
                    field(OneCheckPerVendorPerDocumentNo; OneCheckPrVendor)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'One Check per Vendor per Document No.';
                        MultiLine = true;
                        ToolTip = 'Specifies if only one check is printed per vendor for each document number.';
                    }
                    field(ReprintChecks; PrintChecks)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reprint Checks';
                        ToolTip = 'Specifies if checks are printed again if you canceled the printing due to a problem.';
                    }
                    field(TestPrinting; TestPrint)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Test Print';
                        ToolTip = 'Specifies if you want to print the checks on blank paper before you print them on check forms.';
                    }
                    field(PreprintedStub; PrintedStub)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Preprinted Stub';
                        ToolTip = 'Specifies if you use check forms with preprinted stubs.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if BankAcc2."No." <> '' then
                if BankAcc2.Get(BankAcc2."No.") then
                    UseCheckNo := BankAcc2."Last Check No."
                else begin
                    BankAcc2."No." := '';
                    UseCheckNo := '';
                end;
        end;
    }

    labels
    {
    }


    trigger OnInitReport()
    begin
        GLSetup.Get();
    end;

    trigger OnPreReport()
    begin
        InitTextVariable();
    end;

    var
        CompanyInfo: Record "Company Information";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlLine3: Record "Gen. Journal Line";
        Cust: Record Customer;
        CustLedgEntry: Record "Cust. Ledger Entry";
        Vend: Record Vendor;
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAcc: Record "Bank Account";
        BankAcc2: Record "Bank Account";
        CheckLedgEntry: Record "Check Ledger Entry";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        FormatAddr: Codeunit "Format Address";
        CheckManagement: Codeunit CheckManagement;
        CompanyAddr: array[8] of Text[50];
        CheckToAddr: array[8] of Text[50];
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        BalancingType: Enum "Gen. Journal Account Type";
        TDSAmount: Decimal;
        BalancingNo: Code[20];
        ContactText: Text[30];
        CheckNoText: Text[30];
        CheckDateText: Text[30];
        CheckAmountText: Text[30];
        DescriptionLine: array[2] of Text[80];
        DocType: Text[30];
        DocNo: Text[30];
        ExtDocNo: Text[35];
        VoidText: Text[30];
        LineAmount: Decimal;
        LineDiscount: Decimal;
        TotalLineAmount: Decimal;
        TotalLineDiscount: Decimal;
        RemainingAmount: Decimal;
        CurrentLineAmount: Decimal;
        UseCheckNo: Code[20];
        FoundLast: Boolean;
        PrintChecks: Boolean;
        TestPrint: Boolean;
        FirstPage: Boolean;
        OneCheckPrVendor: Boolean;
        FoundNegative: Boolean;
        ApplyMethod: Option Payment,OneLineOneEntry,OneLineID,MoreLinesOneEntry;
        ChecksPrinted: Integer;
        HighestLineNo: Integer;
        PrintedStub: Boolean;
        TotalText: Text[10];
        JournalPostingDate: Date;
        DocDate: Date;
        i: Integer;
        CurrencyCode2: Code[10];
        NetAmount: Text[30];
        LineAmount2: Decimal;
        NotPreviewLbl: Label 'Preview is not allowed.';
        LastCheckLbl: Label 'Last Check No. must be filled in.';
        FilterLbl: Label 'Filters on %1 and %2 are not allowed.', Comment = '%1 = Line No. %2 = Document No.';
        CheckCompAddLbl: Label 'XXXXXXXXXXXXXXXX';
        MustLbl: Label 'must be entered.';
        SamecurrencyLbl: Label 'The Bank Account and the General Journal Line must have the same currency.';
        SalespersonLbl: Label 'Salesperson';
        PurchaserLbl: Label 'Purchaser';
        BankcurrencyLbl: Label 'Both Bank Accounts must have the same currency.';
        ContactLbl: Label 'Our Contact';
        DocExtNoLbl: Label 'XXXXXXXXXX';
        ChckNoLbl: Label 'XXXX';
        CheckDateLbl: Label 'XX.XXXXXXXXXX.XXXX';
        AlreadyLbl: Label '%1 already exists.', Comment = '%1 =UseCheckNo';
        BAlTypeNoLbl: Label 'Check for %1 %2', Comment = '%1 Balance Type %2 No.';
        DocTypeLbl: Label 'Payment';
        CHeckRepLbl: Label 'In the Check report, One Check per Vendor and Document No.\must not be activated when Applies-to ID is specified in the journal lines.';
        DocType1Lbl: Label 'XXX';
        TotalTExtLbl: Label 'Total';
        TotAmtPosLbl: Label 'The total amount of check %1 is %2. The amount must be positive.', Comment = '%1 Use Check No %2 Total Line Amt';
        TotVoidLbl: Label 'VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID';
        NonNegoLbl: Label 'NON-NEGOTIABLE';
        TestPrintLbl: Label 'Test print';
        CheckAmttextLbl: Label 'XXXX.XX';
        DescripLineLbl: Label 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        ZeroLbl: Label 'ZERO';
        HundreadLbl: Label 'HUNDRED';
        AndLbl: Label 'and';
        exceededStringErr: Label '%1 results in a written number that is too long.', Comment = '%1= AddText';
        DocTypeCustVendLbl: Label ' is already applied to %1 %2 for customer %3.', Comment = '%1 Doc Type %2 Customer NO. And %3 Vendor NO';
        OneLbl: Label 'ONE';
        TwoLbl: Label 'TWO';
        ThreeLbl: Label 'THREE';
        FourLbl: Label 'FOUR';
        FiveLbl: Label 'FIVE';
        SixLbl: Label 'SIX';
        SevenLbl: Label 'SEVEN';
        EightLbl: Label 'EIGHT';
        NineLbl: Label 'NINE';
        TenLbl: Label 'TEN';
        ElevenLbl: Label 'ELEVEN';
        TwelveLbl: Label 'TWELVE';
        ThirteenLbl: Label 'THIRTEEN';
        FourteenLbl: Label 'FOURTEEN';
        FifteenLbl: Label 'FIFTEEN';
        SixteenLbl: Label 'SIXTEEN';
        SeventeenLbl: Label 'SEVENTEEN';
        EighteenLbl: Label 'EIGHTEEN';
        NinteenLbl: Label 'NINETEEN';
        TwentyLbl: Label 'TWENTY';
        ThirtyLbl: Label 'THIRTY';
        FortyLbl: Label 'FORTY';
        FiftyLbl: Label 'FIFTY';
        SixtyLbl: Label 'SIXTY';
        SeventyLbl: Label 'SEVENTY';
        EightyLbl: Label 'EIGHTY';
        NinetyLbl: Label 'NINETY';
        ThousandLbl: Label 'THOUSAND';
        LakhLbl: Label 'LAKH';
        CroreLbl: Label 'CRORE';
        Text062Lbl: Label 'G/L Account,Customer,Vendor,Bank Account';
        NetAmtLbl: Label 'Net Amount %1', Comment = '%1 Gen Jrn Line Currency code';
        FieldCapTableCapLbl: Label '%1 must not be %2 for %3 %4.', Comment = '%1 Field Caption %2 Vend Blocked %3 Table Caption  %4 vend&Cust No.';
        SubTotLbl: Label 'Subtotal';
        CheckNoCaptionLbl: Label 'Check No.';
        NetAmtCaptionLbl: Label 'Net Amount';
        DiscCaptionLbl: Label 'Discount';
        AmtCaptionLbl: Label 'Amount';
        DocNoCaptionLbl: Label 'Document No.';
        DocDateCaptionLbl: Label 'Document Date';
        CurrCodeCaptionLbl: Label 'Currency Code';
        YourDocNoCaptionLbl: Label 'Your Doc. No.';
        TDSCaptionLbl: Label 'TDS';
        TransportCaptionLbl: Label 'Transport';

    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        CurrRec: Record Currency;
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
        TensDec: Integer;
        OnesDec: Integer;
    begin
        Clear(NoText);
        NoTextIndex := 1;
        NoText[1] := '****';

        if No < 1 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroLbl)
        else
            for Exponent := 4 DOWNTO 1 do begin
                PrintExponent := false;
                if No > 99999 then begin
                    Ones := No DIV (Power(100, Exponent - 1) * 10);
                    Hundreds := 0;
                end else begin
                    Ones := No DIV Power(1000, Exponent - 1);
                    Hundreds := Ones DIV 100;
                end;
                Tens := (Ones MOD 100) DIV 10;
                Ones := Ones MOD 10;
                if Hundreds > 0 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, HundreadLbl);
                end;
                if Tens >= 2 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    if Ones > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                end else
                    if (Tens * 10 + Ones) > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                if PrintExponent and (Exponent > 1) then
                    AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                if No > 99999 then
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(100, Exponent - 1) * 10
                else
                    No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(1000, Exponent - 1);
            end;

        if CurrencyCode <> '' then begin
            CurrRec.Get(CurrencyCode);
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ');
        end else
            AddToNoText(NoText, NoTextIndex, PrintExponent, 'RUPEES');

        AddToNoText(NoText, NoTextIndex, PrintExponent, AndLbl);

        TensDec := ((No * 100) MOD 100) DIV 10;
        OnesDec := (No * 100) MOD 10;
        if TensDec >= 2 then begin
            AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[TensDec]);
            if OnesDec > 0 then
                AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[OnesDec]);
        end else
            if (TensDec * 10 + OnesDec) > 0 then
                AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[TensDec * 10 + OnesDec])
            else
                AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroLbl);
        if (CurrencyCode <> '') then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ' + ' ONLY')
        else
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' PAISA ONLY');
    end;

    procedure ABSMin(Decimal1: Decimal; Decimal2: Decimal): Decimal
    begin
        if Abs(Decimal1) < Abs(Decimal2) then
            exit(Decimal1);
        exit(Decimal2);
    end;

    procedure InputBankAccount()
    begin
        if BankAcc2."No." <> '' then begin
            BankAcc2.Get(BankAcc2."No.");
            BankAcc2.TestField("Last Check No.");
            UseCheckNo := BankAcc2."Last Check No.";
        end;
    end;

    local procedure AddToNoText(
        var NoText: array[2] of Text[80];
        var NoTextIndex: Integer;
        var PrintExponent: Boolean;
        AddText: Text[30])
    begin
        PrintExponent := true;

        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(exceededStringErr, AddText);
        end;

        NoText[NoTextIndex] := CopyStr(DelChr(NoText[NoTextIndex] + ' ' + AddText, '<'), 1, 80);
    end;

    local procedure CustUpdateAmounts(var CustLedgEntry2: Record "Cust. Ledger Entry"; RemainingAmount2: Decimal)
    var
        AmountToApply: Decimal;
    begin
        if (ApplyMethod = ApplyMethod::OneLineOneEntry) or
           (ApplyMethod = ApplyMethod::MoreLinesOneEntry)
        then begin
            GenJnlLine3.Reset();
            GenJnlLine3.SetCurrentKey(
              "Account Type", "Account No.", "Applies-to Doc. Type", "Applies-to Doc. No.");
            GenJnlLine3.SetRange("Account Type", GenJnlLine3."Account Type"::Customer);
            GenJnlLine3.SetRange("Account No.", CustLedgEntry2."Customer No.");
            GenJnlLine3.SetRange("Applies-to Doc. Type", CustLedgEntry2."Document Type");
            GenJnlLine3.SetRange("Applies-to Doc. No.", CustLedgEntry2."Document No.");
            if ApplyMethod = ApplyMethod::OneLineOneEntry then
                GenJnlLine3.SetFilter("Line No.", '<>%1', GenJnlLine."Line No.")
            else
                GenJnlLine3.SetFilter("Line No.", '<>%1', GenJnlLine2."Line No.");
            if CustLedgEntry2."Document Type" <> CustLedgEntry2."Document Type"::" " then
                if GenJnlLine3.Find('-') then
                    GenJnlLine3.FieldError(
                      "Applies-to Doc. No.",
                      StrSubstNo(
                        DocTypeCustVendLbl,
                        CustLedgEntry2."Document Type", CustLedgEntry2."Document No.",
                        CustLedgEntry2."Customer No."));
        end;

        DocType := Format(CustLedgEntry2."Document Type");
        DocNo := CustLedgEntry2."Document No.";
        ExtDocNo := CustLedgEntry2."External Document No.";
        DocDate := CustLedgEntry2."Posting Date";
        CurrencyCode2 := CustLedgEntry2."Currency Code";

        CustLedgEntry2.CalcFields("Remaining Amount");

        LineAmount :=
          -ABSMin(
            CustLedgEntry2."Remaining Amount" -
            CustLedgEntry2."Remaining Pmt. Disc. Possible" -
            CustLedgEntry2."Accepted Payment Tolerance",
            CustLedgEntry2."Amount to Apply");
        LineAmount2 :=
          Round(ExchangeAmt(GenJnlLine."Currency Code", CurrencyCode2, LineAmount), Currency."Amount Rounding Precision");

        if ((CustLedgEntry2."Document Type" in [CustLedgEntry2."Document Type"::Invoice,
                                                CustLedgEntry2."Document Type"::"Credit Memo"]) and
            (CustLedgEntry2."Remaining Pmt. Disc. Possible" <> 0) and
            (CustLedgEntry2."Posting Date" <= CustLedgEntry2."Pmt. Discount Date")) or
           CustLedgEntry2."Accepted Pmt. Disc. Tolerance"
        then begin
            LineDiscount := -CustLedgEntry2."Remaining Pmt. Disc. Possible";
            if CustLedgEntry2."Accepted Payment Tolerance" <> 0 then
                LineDiscount := LineDiscount - CustLedgEntry2."Accepted Payment Tolerance";
        end else begin
            AmountToApply :=
              Round(-ExchangeAmt(
                  GenJnlLine."Currency Code", CurrencyCode2, CustLedgEntry2."Amount to Apply"), Currency."Amount Rounding Precision");
            if RemainingAmount2 >= AmountToApply then
                LineAmount2 := AmountToApply
            else begin
                LineAmount2 := RemainingAmount2;
                LineAmount := Round(ExchangeAmt(CurrencyCode2, GenJnlLine."Currency Code", LineAmount2), Currency."Amount Rounding Precision");
            end;
            LineDiscount := 0;
        end;
    end;

    local procedure VendUpdateAmounts(var VendLedgEntry2: Record "Vendor Ledger Entry"; RemainingAmount2: Decimal)
    begin
        if (ApplyMethod = ApplyMethod::OneLineOneEntry) or
           (ApplyMethod = ApplyMethod::MoreLinesOneEntry)
        then begin
            GenJnlLine3.Reset();
            GenJnlLine3.SetCurrentKey(
              "Account Type", "Account No.", "Applies-to Doc. Type", "Applies-to Doc. No.");
            GenJnlLine3.SetRange("Account Type", GenJnlLine3."Account Type"::Vendor);
            GenJnlLine3.SetRange("Account No.", VendLedgEntry2."Vendor No.");
            GenJnlLine3.SetRange("Applies-to Doc. Type", VendLedgEntry2."Document Type");
            GenJnlLine3.SetRange("Applies-to Doc. No.", VendLedgEntry2."Document No.");
            if ApplyMethod = ApplyMethod::OneLineOneEntry then
                GenJnlLine3.SetFilter("Line No.", '<>%1', GenJnlLine."Line No.")
            else
                GenJnlLine3.SetFilter("Line No.", '<>%1', GenJnlLine2."Line No.");
            if VendLedgEntry2."Document Type" <> VendLedgEntry2."Document Type"::" " then
                if GenJnlLine3.Find('-') then
                    GenJnlLine3.FieldError(
                      "Applies-to Doc. No.",
                      StrSubstNo(
                        DocTypeCustVendLbl,
                        VendLedgEntry2."Document Type", VendLedgEntry2."Document No.",
                        VendLedgEntry2."Vendor No."));
        end;

        DocType := Format(VendLedgEntry2."Document Type");
        DocNo := VendLedgEntry2."Document No.";
        ExtDocNo := VendLedgEntry2."External Document No.";
        DocDate := VendLedgEntry2."Posting Date";
        CurrencyCode2 := VendLedgEntry2."Currency Code";
        VendLedgEntry2.CalcFields("Remaining Amount");

        LineAmount :=
          -ABSMin(
            VendLedgEntry2."Remaining Amount" -
            VendLedgEntry2."Remaining Pmt. Disc. Possible" -
            VendLedgEntry2."Accepted Payment Tolerance",
            VendLedgEntry2."Amount to Apply");

        LineAmount2 :=
          Round(ExchangeAmt(GenJnlLine."Currency Code", CurrencyCode2, LineAmount), Currency."Amount Rounding Precision");

        if ((VendLedgEntry2."Document Type" in [VendLedgEntry2."Document Type"::Invoice,
                                                VendLedgEntry2."Document Type"::"Credit Memo"]) and
            (VendLedgEntry2."Remaining Pmt. Disc. Possible" <> 0) and
            (GenJnlLine."Posting Date" <= VendLedgEntry2."Pmt. Discount Date")) or
           VendLedgEntry2."Accepted Pmt. Disc. Tolerance"
        then begin
            LineDiscount := -VendLedgEntry2."Remaining Pmt. Disc. Possible";
            if VendLedgEntry2."Accepted Payment Tolerance" <> 0 then
                LineDiscount := LineDiscount - VendLedgEntry2."Accepted Payment Tolerance";
        end else begin
            LineAmount2 :=
              Round(
                -ExchangeAmt(
                  GenJnlLine."Currency Code", CurrencyCode2, VendLedgEntry2."Amount to Apply"), Currency."Amount Rounding Precision");

            if ApplyMethod <> ApplyMethod::OneLineID then
                if Abs(RemainingAmount2) < Abs(LineAmount2) then
                    LineAmount2 := RemainingAmount2;

            LineAmount :=
              Round(ExchangeAmt(CurrencyCode2, GenJnlLine."Currency Code", LineAmount2), Currency."Amount Rounding Precision");

            LineDiscount := 0;
        end;
    end;

    procedure InitTextVariable()
    begin
        OnesText[1] := OneLbl;
        OnesText[2] := TwoLbl;
        OnesText[3] := ThreeLbl;
        OnesText[4] := FourLbl;
        OnesText[5] := FiveLbl;
        OnesText[6] := SixLbl;
        OnesText[7] := SevenLbl;
        OnesText[8] := EightLbl;
        OnesText[9] := NineLbl;
        OnesText[10] := TenLbl;
        OnesText[11] := ElevenLbl;
        OnesText[12] := TwelveLbl;
        OnesText[13] := ThirteenLbl;
        OnesText[14] := FourteenLbl;
        OnesText[15] := FifteenLbl;
        OnesText[16] := SixteenLbl;
        OnesText[17] := SeventeenLbl;
        OnesText[18] := EighteenLbl;
        OnesText[19] := NinteenLbl;
        TensText[1] := '';
        TensText[2] := TwentyLbl;
        TensText[3] := ThirtyLbl;
        TensText[4] := FortyLbl;
        TensText[5] := FiftyLbl;
        TensText[6] := SixtyLbl;
        TensText[7] := SeventyLbl;
        TensText[8] := EightyLbl;
        TensText[9] := NinetyLbl;
        ExponentText[1] := '';
        ExponentText[2] := ThousandLbl;
        ExponentText[3] := LakhLbl;
        ExponentText[4] := CroreLbl;
    end;

    procedure InitializeRequest(BankAcc: Code[20]; LastCheckNo: Code[20]; NewOneCheckPrVend: Boolean; NewReprintChecks: Boolean; NewTestPrint: Boolean; NewPreprintedStub: Boolean)
    begin
        if BankAcc <> '' then
            if BankAcc2.Get(BankAcc) then begin
                UseCheckNo := LastCheckNo;
                OneCheckPrVendor := NewOneCheckPrVend;
                PrintChecks := NewReprintChecks;
                TestPrint := NewTestPrint;
                PrintedStub := NewPreprintedStub;
            end;
    end;

    local procedure ExchangeAmt(CurrencyCode: Code[10]; CurrencyCode2: Code[10]; Amount: Decimal) Amount2: Decimal
    begin
        if (CurrencyCode <> '') and (CurrencyCode2 = '') then
            Amount2 :=
              CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                JournalPostingDate, CurrencyCode, Amount, CurrencyExchangeRate.ExchangeRate(JournalPostingDate, CurrencyCode))
        else
            if (CurrencyCode = '') and (CurrencyCode2 <> '') then
                Amount2 :=
                  CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                    JournalPostingDate, CurrencyCode2, Amount, CurrencyExchangeRate.ExchangeRate(JournalPostingDate, CurrencyCode2))
            else
                if (CurrencyCode <> '') and (CurrencyCode2 <> '') and (CurrencyCode <> CurrencyCode2) then
                    Amount2 := CurrencyExchangeRate.ExchangeAmtFCYToFCY(JournalPostingDate, CurrencyCode2, CurrencyCode, Amount)
                else
                    Amount2 := Amount;
    end;

    local procedure CheckGenJournalBatchAndLineIsApproved(GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        exit(
          VerifyRecordIdIsApproved(GenJournalBatch.RecordId) or
          VerifyRecordIdIsApproved(GenJournalLine.RecordId));
    end;

    local procedure VerifyRecordIdIsApproved(RecordId: RecordID): Boolean
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", RecordId.TableNo);
        ApprovalEntry.SetRange("Record ID to Approve", RecordId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
        ApprovalEntry.SetRange("Related to Change", false);
        if ApprovalEntry.IsEmpty then
            exit(false);

        ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created);
        exit(ApprovalEntry.IsEmpty);
    end;

    local procedure GetAppliedAmtBasedOnBalancingType(BalancingType: Enum "Gen. Journal Account Type"; ApplyMethod: Option Payment,OneLineOneEntry,OneLineID,MoreLinesOneEntry)
    begin
        if ApplyMethod = ApplyMethod::OneLineOneEntry then begin
            if BalancingType = BalancingType::Customer then begin
                CustLedgEntry.Reset();
                CustLedgEntry.SetCurrentKey("Document No.");
                CustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                CustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                CustLedgEntry.SetRange("Customer No.", BalancingNo);
                CustLedgEntry.Find('-');
                CustUpdateAmounts(CustLedgEntry, RemainingAmount);
            end;
            if BalancingType = BalancingType::Vendor then begin
                VendLedgEntry.Reset();
                VendLedgEntry.SetCurrentKey("Document No.");
                VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                VendLedgEntry.SetRange("Vendor No.", BalancingNo);
                VendLedgEntry.Find('-');
                VendUpdateAmounts(VendLedgEntry, RemainingAmount);
            end;
        end;
        if ApplyMethod = ApplyMethod::MoreLinesOneEntry then begin
            if BalancingType = BalancingType::Customer then begin
                CustLedgEntry.Reset();
                CustLedgEntry.SetCurrentKey("Document No.");
                CustLedgEntry.SetRange("Document Type", GenJnlLine2."Applies-to Doc. Type");
                CustLedgEntry.SetRange("Document No.", GenJnlLine2."Applies-to Doc. No.");
                CustLedgEntry.SetRange("Customer No.", BalancingNo);
                CustLedgEntry.Find('-');
                CustUpdateAmounts(CustLedgEntry, CurrentLineAmount);
                LineAmount := CurrentLineAmount;
            end;
            if BalancingType = BalancingType::Vendor then begin
                VendLedgEntry.Reset();
                if GenJnlLine2."Source Line No." <> 0 then
                    VendLedgEntry.SetRange("Entry No.", GenJnlLine2."Source Line No.")
                else begin
                    VendLedgEntry.SetCurrentKey("Document No.");
                    VendLedgEntry.SetRange("Document Type", GenJnlLine2."Applies-to Doc. Type");
                    VendLedgEntry.SetRange("Document No.", GenJnlLine2."Applies-to Doc. No.");
                    VendLedgEntry.SetRange("Vendor No.", BalancingNo);
                end;
                VendLedgEntry.Find('-');
                VendUpdateAmounts(VendLedgEntry, CurrentLineAmount);
                LineAmount := CurrentLineAmount;
            end;
        end;
    end;
}
