// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using System.Utilities;

report 11728 "Cash Desk Book CZP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CashDeskBook.rdl';
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Desk Book';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CashDeskCZP; "Cash Desk CZP")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter";
            column(CashDesk_No; "No.")
            {
                IncludeCaption = true;
            }
            column(CashDesk_Name; Name)
            {
                IncludeCaption = true;
            }
            column(CashDesk_Currency_Code; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CashDeskFilter; CashDeskFilter)
            {
            }
            column(BalanceToDate; BalanceToDate)
            {
            }
            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);
                column(Integer_Number; Number)
                {
                }
                column(TempCashDocHeader_Payment_Purpose; TempCashDocumentHeaderCZP."Payment Purpose")
                {
                }
                column(TempCashDocHeader_External_Document_No; TempCashDocumentHeaderCZP."External Document No.")
                {
                }
                column(TempCashDocHeader_Posting_Date; TempCashDocumentHeaderCZP."Posting Date")
                {
                }
                column(TempCashDocHeader_No; TempCashDocumentHeaderCZP."No.")
                {
                }
                column(Balance; Balance)
                {
                }
                column(Payment; Payment)
                {
                }
                column(Receipt; Receipt)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempCashDocumentHeaderCZP.FindSet()
                    else
                        TempCashDocumentHeaderCZP.Next();

                    case TempCashDocumentHeaderCZP."Document Type" of
                        TempCashDocumentHeaderCZP."Document Type"::Receipt:
                            begin
                                Receipt := TempCashDocumentHeaderCZP."Released Amount";
                                Payment := 0;
                            end;
                        TempCashDocumentHeaderCZP."Document Type"::Withdrawal:
                            begin
                                Payment := TempCashDocumentHeaderCZP."Released Amount";
                                Receipt := 0;
                            end;
                    end;
                    Balance += Receipt - Payment;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, TempCashDocumentHeaderCZP.Count());

                    case Sorting of
                        Sorting::PostingDate:
                            TempCashDocumentHeaderCZP.SetCurrentKey("Cash Desk No.", "Posting Date");
                        Sorting::CashDeskNo:
                            TempCashDocumentHeaderCZP.SetCurrentKey("Cash Desk No.", "No.");
                    end;
                    Balance := BalanceToDate;
                end;
            }

            trigger OnAfterGetRecord()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
                CashDeskCZP2: Record "Cash Desk CZP";
            begin
                CashDeskManagementCZP.CheckCashDesk(CashDeskCZP."No.");
                if "Currency Code" = '' then
                    "Currency Code" := GeneralLedgerSetup."LCY Code";

                CashDeskCZP2.Get("No.");
                CashDeskCZP2.SetFilter("Date Filter", '..%1', CalcDate('<-1D>', GetRangeMin("Date Filter")));
                BalanceToDate := CashDeskCZP2.CalcBalance();

                TempCashDocumentHeaderCZP.DeleteAll();
                CashDocumentHeaderCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
                CashDocumentHeaderCZP.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', GetRangeMin("Date Filter")));
                CopyFilter("Date Filter", CashDocumentHeaderCZP."Posting Date");
                if CashDocumentHeaderCZP.FindSet() then
                    repeat
                        TempCashDocumentHeaderCZP.Init();
                        TempCashDocumentHeaderCZP.TransferFields(CashDocumentHeaderCZP);
                        TempCashDocumentHeaderCZP."Released Amount" := CashDocumentHeaderCZP."Released Amount";
                        TempCashDocumentHeaderCZP.Insert();
                    until CashDocumentHeaderCZP.Next() = 0;

                PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                PostedCashDocumentHdrCZP.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', GetRangeMin("Date Filter")));
                CopyFilter("Date Filter", PostedCashDocumentHdrCZP."Posting Date");
                if PostedCashDocumentHdrCZP.FindSet() then
                    repeat
                        TempCashDocumentHeaderCZP.Init();
                        TempCashDocumentHeaderCZP.TransferFields(PostedCashDocumentHdrCZP);
                        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT");
                        TempCashDocumentHeaderCZP."Released Amount" := PostedCashDocumentHdrCZP."Amount Including VAT";
                        TempCashDocumentHeaderCZP.Insert();
                    until PostedCashDocumentHdrCZP.Next() = 0;
            end;

            trigger OnPreDataItem()
            var
                TwoPlaceholdersTok: Label '%1: %2', Comment = '%1 = TableCaption, %2 = GetFilters', Locked = true;
            begin
                if GetFilter("Date Filter") = '' then
                    Error(EmptyDateFilterErr);
                if GetFilters() <> '' then
                    CashDeskFilter := StrSubstNo(TwoPlaceholdersTok, TableCaption(), GetFilters());
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
                    field(SortingCZP; Sorting)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sorting';
                        OptionCaption = 'Posting Date,Cash Desk No.';
                        ToolTip = 'Specifies the method by which the entries are sorted on the report.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            CashDeskCZP.SetRange("Date Filter", WorkDate());
        end;
    }

    labels
    {
        ReportNameLbl = 'Cash Desk Book';
        ReportDescriptionLbl = '(Posted and Unposted Released Documents)';
        PageLbl = 'Page';
        InitialConditionLbl = 'Initial Condition:';
        DocumentNoLbl = 'Document No.';
        PostingDateLbl = 'Posting Date';
        ExternalDocumentNoLbl = 'External Document No.';
        DescriptionLbl = 'Description';
        PaymentLbl = 'Payment';
        ReceiptLbl = 'Receipt';
        BalanceLbl = 'Balance';
        TotalLbl = 'Total';
        DateLbl = 'Date';
        CashierSignLbl = 'Cashier Sign';
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddress, CompanyInformation);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        CompanyInformation: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        BalanceToDate, Balance, Receipt, Payment : Decimal;
        CashDeskFilter: Text;
        Sorting: Option PostingDate,CashDeskNo;
        CompanyAddress: array[8] of Text[150];
        EmptyDateFilterErr: Label 'Set up Date Filter.';

    protected var
        TempCashDocumentHeaderCZP: Record "Cash Document Header CZP" temporary;
}
