// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

report 18929 "Day Book"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdlc/DayBook.rdl';
    Caption = 'Day Book';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = sorting("Posting Date", "Transaction No.");
            RequestFilterFields = "Posting Date", "Document No.", "Global Dimension 1 Code", "Global Dimension 2 Code";

            column(TodayFormatted; Format(TODAY(), 0, 4))
            {
            }
            column(Time; TIME())
            {
            }
            column(CompinfoName; CompanyInformation.Name)
            {
            }
            column(GetFilters; GETFILTERS())
            {
            }
            column(DebitAmount_GLEntry; "Debit Amount")
            {
            }
            column(CreditAmount_GLEntry; "Credit Amount")
            {
            }
            column(GLAccName; GLAccName)
            {
            }
            column(DocNo; DocNo)
            {
            }
            column(PostingDate_GLEntry; Format(PostingDate))
            {
            }
            column(SourceDesc; SourceDesc)
            {
            }
            column(EntryNo_GLEntry; "Entry No.")
            {
            }
            column(TransactionNo_GLEntry; "Transaction No.")
            {
            }
            column(DayBookCaption; DayBookCaptionLbl)
            {
            }
            column(DocumentNoCaption; DocumentNoCaptionLbl)
            {
            }
            column(AccountNameCaption; AccountNameCaptionLbl)
            {
            }
            column(DebitAmountCaption; DebitAmountCaptionLbl)
            {
            }
            column(CreditAmountCaption; CreditAmountCaptionLbl)
            {
            }
            column(VoucherTypeCaption; VoucherTypeCaptionLbl)
            {
            }
            column(DateCaption; DateCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(TransDebits; TransDebits)
            {
            }
            column(TransCredits; TransCredits)
            {
            }
            dataitem(PostedNarration; "Posted Narration")
            {
                DataItemLink = "Entry No." = field("Entry No.");
                DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                    order(ascending);

                column(Narration_PostedNarration; Narration)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not LineNarration then
                        CurrReport.Break();
                end;
            }
            dataitem(PostedNarration1; "Posted Narration")
            {
                DataItemLink = "Transaction No." = field("Transaction No.");
                DataItemTableView = sorting("Entry No.", "Transaction No.", "Line No.")
                                    where("Entry No." = filter(0));

                column(Narration_PostedNarration1; Narration)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not VoucherNarration then
                        CurrReport.Break();

                    GLEntry.SetCurrentKey("Posting Date", "Source Code", "Transaction No.");
                    GLEntry.SetRange(GLEntry."Posting Date", "G/L Entry"."Posting Date");
                    GLEntry.SetRange(GLEntry."Source Code", "G/L Entry"."Source Code");
                    GLEntry.SetRange(GLEntry."Transaction No.", "G/L Entry"."Transaction No.");
                    GLEntry.FindLast();
                    if not (GLEntry."Entry No." = "G/L Entry"."Entry No.") then
                        CurrReport.Break();
                end;
            }
            trigger OnPreDataItem()
            begin
                SetCurrentKey("Posting Date", "Source Code", "Transaction No.");
            end;

            trigger OnAfterGetRecord()
            begin
                DocNo := '';
                PostingDate := 0D;
                SourceDesc := '';

                GLAccName := FindGLAccName("Source Type", "Entry No.", "Source No.", "G/L Account No.");

                if TransNo = 0 then begin
                    TransNo := "Transaction No.";
                    DocNo := "Document No.";
                    PostingDate := "Posting Date";
                    if "Source Code" <> '' then begin
                        SourceCode.Get("Source Code");
                        SourceDesc := CopyStr(SourceCode.Description, 1, MaxStrLen(SourceDesc));
                    end;
                end else
                    if TransNo <> "Transaction No." then begin
                        TransNo := "Transaction No.";
                        DocNo := "Document No.";
                        PostingDate := "Posting Date";
                        if "Source Code" <> '' then begin
                            SourceCode.Get("Source Code");
                            SourceDesc := CopyStr(SourceCode.Description, 1, MaxStrLen(SourceDesc));
                        end;
                    end;

                if Amount > 0 then
                    TransDebits := TransDebits + Amount
                else
                    TransCredits := TransCredits - Amount;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Line Narration"; LineNarration)
                    {
                        Caption = 'Line Narration';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Place a check mark in this field if line narration is to be printed.';
                    }
                    field("Voucher Narration"; VoucherNarration)
                    {
                        Caption = 'Voucher Narration';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Place a check mark in this field if voucher narration is to be printed.';
                    }
                }
            }
        }
    }


    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GLEntry: Record "G/L Entry";
        SourceCode: Record "Source Code";
        GLAccName: Text[50];
        SourceDesc: Text[50];
        PostingDate: Date;
        LineNarration: Boolean;
        VoucherNarration: Boolean;
        DocNo: Code[20];
        TransNo: Integer;
        TransDebits: Decimal;
        TransCredits: Decimal;
        DayBookCaptionLbl: Label 'Day Book';
        DocumentNoCaptionLbl: Label 'Document No.';
        AccountNameCaptionLbl: Label 'Account Name';
        DebitAmountCaptionLbl: Label 'Debit Amount';
        CreditAmountCaptionLbl: Label 'Credit Amount';
        VoucherTypeCaptionLbl: Label 'Voucher Type';
        DateCaptionLbl: Label 'Date';
        TotalCaptionLbl: Label 'Total';

    procedure FindGLAccName(
        "Source Type": Enum "Gen. Journal Source Type";
        "Entry No.": Integer;
        "Source No.": Code[20];
        "G/L Account No.": Code[20]): Text[50]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccount: Record "Bank Account";
        FALedgerEntry: Record "FA Ledger Entry";
        FixedAsset: Record "Fixed Asset";
        GLAccount: Record "G/L Account";
        AccName: Text[50];
    begin
        case "Source Type" of
            "Source Type"::Vendor:
                if VendorLedgerEntry.Get("Entry No.") then begin
                    Vendor.Get("Source No.");
                    AccName := CopyStr(Vendor.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::Customer:
                if CustLedgerEntry.Get("Entry No.") then begin
                    Customer.Get("Source No.");
                    AccName := CopyStr(Customer.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::"Bank Account":
                if BankAccountLedgerEntry.Get("Entry No.") then begin
                    BankAccount.Get("Source No.");
                    AccName := CopyStr(BankAccount.Name, 1, MaxStrLen(AccName));
                end else begin
                    GLAccount.Get("G/L Account No.");
                    AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                end;
            "Source Type"::"Fixed Asset":
                begin
                    FALedgerEntry.Reset();
                    FALedgerEntry.SetRange("G/L Entry No.", "Entry No.");
                    if not FALedgerEntry.IsEmpty() then begin
                        FixedAsset.Get("Source No.");
                        AccName := CopyStr(FixedAsset.Description, 1, MaxStrLen(AccName));
                    end else begin
                        GLAccount.Get("G/L Account No.");
                        AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
                    end;
                end else begin
                GLAccount.Get("G/L Account No.");
                AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
            end;
                        GLAccount.Get("G/L Account No.");
                        AccName := CopyStr(GLAccount.Name, 1, MaxStrLen(AccName));
        end;
        exit(AccName);
    end;
}
