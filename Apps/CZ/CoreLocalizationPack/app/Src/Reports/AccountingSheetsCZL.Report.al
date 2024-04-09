// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif
using Microsoft.Foundation.Company;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.Security.User;
using System.Utilities;

report 11703 "Accounting Sheets CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AccountingSheets.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Accounting Sheets';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CommonData; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;
            column(GroupCaption; GroupCaption)
            {
            }
            column(LastDataItem; LastDataItem)
            {
            }
            column(SalesInvHdrExists; SalesInvHdrExists)
            {
            }
            column(SalesCrMemoHdrExists; SalesCrMemoHdrExists)
            {
            }
            column(PurchInvHdrExists; PurchInvHdrExists)
            {
            }
            column(PurchCrMemoHdrExists; PurchCrMemoHdrExists)
            {
            }
            column(GeneralDocExists; GeneralDocExists)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(GlobalDimension2CodeCaption; CaptionClassTranslate('1,1,2'))
            {
            }
            column(GlobalDimension1CodeCaption; CaptionClassTranslate('1,1,1'))
            {
            }
            trigger OnAfterGetRecord()
            begin
                GroupCaption := DescriptionTxt;
                if GroupGLAccounts then
                    GroupCaption := GLAccountNameTxt
            end;
        }
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(SalesInvoiceHeader_No; "No.")
            {
            }
            column(SalesInvoiceHeader_SelltoCustomerName; "Sell-to Customer Name")
            {
            }
            column(SalesInvoiceHeader_DueDate; Format("Due Date"))
            {
            }
            column(SalesInvoiceHeader_Amount; Amount)
            {
            }
            column(SalesInvoiceHeader_CurrencyCode; "Currency Code")
            {
            }
            column(SalesInvoiceHeader_PostingDate; "Posting Date")
            {
            }
            column(SalesInvoiceHeader_VATDate; "VAT Reporting Date")
            {
            }
            column(SalesInvoiceHeader_DocumentDate; "Document Date")
            {
            }
            column(SalesInvoiceHeader_FCYRate; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            dataitem(SalesInvoiceEntry; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    BufferGLEntry(SalesInvoiceEntry);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(SalesInvoiceBufferedEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(SalesInvoiceEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(SalesInvoiceEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(SalesInvoiceEntry_GlobalDimension2Code; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(SalesInvoiceEntry_GlobalDimension1Code; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(SalesInvoiceEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(SalesInvoiceEntry_UserName; UserSetup."User Name CZL")
                {
                }
                column(SalesInvoiceEntry_GroupText; GroupText)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GetUserSetup(TempGLEntry."User ID");
                    GroupText := GetGroupText(TempGLEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif  
            end;

            trigger OnPreDataItem()
            begin
                if not SalesInvoiceHeader.HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(SalesCrMemoHeader_No; "No.")
            {
            }
            column(SalesCrMemoHeader_DueDate; Format("Due Date"))
            {
            }
            column(SalesCrMemoHeader_SelltoCustomerName; "Sell-to Customer Name")
            {
            }
            column(SalesCrMemoHeader_Amount; Amount)
            {
            }
            column(SalesCrMemoHeader_CurrencyCode; "Currency Code")
            {
            }
            column(SalesCrMemoHeader_FCYRate; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(SalesCrMemoHeader_PostingDate; "Posting Date")
            {
            }
            column(SalesCrMemoHeader_VATDate; "VAT Reporting Date")
            {
            }
            column(SalesCrMemoHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(SalesCrMemoEntry; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    BufferGLEntry(SalesCrMemoEntry);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(SalesCrMemoBufferedEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(SalesCrMemoEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(SalesCrMemoEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(SalesCrMemoEntry_GlobalDimension2Code; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(SalesCrMemoEntry_GlobalDimension1Code; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(SalesCrMemoEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(SalesCrMemoEntry_UserName; UserSetup."User Name CZL")
                {
                }
                column(SalesCrMemoEntry_GroupText; GroupText)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GetUserSetup(TempGLEntry."User ID");
                    GroupText := GetGroupText(TempGLEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
            end;

            trigger OnPreDataItem()
            begin
                if not SalesCrMemoHeader.HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(PurchInvHeader_No; "No.")
            {
            }
            column(PurchInvHeader_DueDate; Format("Due Date"))
            {
            }
            column(PurchInvHeader_BuyfromVendorName; "Buy-from Vendor Name")
            {
            }
            column(PurchInvHeader_VendorInvoiceNo; "Vendor Invoice No.")
            {
            }
            column(PurchInvHeader_Amount; Amount)
            {
            }
            column(PurchInvHeader_CurrencyCode; "Currency Code")
            {
            }
            column(PurchInvHeader_FCYRate; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(PurchInvHeader_PostingDate; "Posting Date")
            {
            }
            column(PurchInvHeader_VATDate; "VAT Reporting Date")
            {
            }
            column(PurchInvHeader_DocumentDate; "Document Date")
            {
            }
            dataitem(PurchInvEntry; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    BufferGLEntry(PurchInvEntry);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(PurchInvBufferedEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(PurchInvEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(PurchInvEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(PurchInvEntry_GlobalDimension2Code; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(PurchInvEntry_GlobalDimension1Code; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(PurchInvEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(PurchInvEntry_UserName; UserSetup."User Name CZL")
                {
                }
                column(PurchInvEntry_GroupText; GroupText)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GetUserSetup(TempGLEntry."User ID");
                    GroupText := GetGroupText(TempGLEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
            end;

            trigger OnPreDataItem()
            begin
                if not PurchInvHeader.HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem(PurchCrMemoHdr; "Purch. Cr. Memo Hdr.")
        {
            CalcFields = Amount, "Amount Including VAT";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";
            column(PurchCrMemoHdr_No; "No.")
            {
            }
            column(PurchCrMemoHdr_DueDate; Format("Due Date"))
            {
            }
            column(PurchCrMemoHdr_BuyfromVendorName; "Buy-from Vendor Name")
            {
            }
            column(PurchCrMemoHdr_VendorCrMemoNo; "Vendor Cr. Memo No.")
            {
            }
            column(PurchCrMemoHdr_Amount; Amount)
            {
            }
            column(PurchCrMemoHdr_FCYRate; FCYRate)
            {
                DecimalPlaces = 5 : 5;
            }
            column(PurchCrMemoHdr_CurrencyCode; "Currency Code")
            {
            }
            column(PurchCrMemoHdr_PostingDate; "Posting Date")
            {
            }
            column(PurchCrMemoHdr_VATDate; "VAT Reporting Date")
            {
            }
            column(PurchCrMemoHdr_DocumentDate; "Document Date")
            {
            }
            dataitem(PurchCrMemoEntry; "G/L Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    BufferGLEntry(PurchCrMemoEntry);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(PurchCrMemoBufferedEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(PurchCrMemoEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(PurchCrMemoEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(PurchCrMemoEntry_GlobalDimension2Code; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(PurchCrMemoEntry_GlobalDimension1Code; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(PurchCrMemoEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(PurchCrMemoEntry_UserName; UserSetup."User Name CZL")
                {
                }
                column(PurchCrMemoEntry_GroupText; GroupText)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GetUserSetup(TempGLEntry."User ID");
                    GroupText := GetGroupText(TempGLEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                TempGLEntry.DeleteAll();

                FCYRate := 0;
                if ("Currency Code" <> '') and ("Currency Factor" <> 0) then
                    FCYRate := 1 / "Currency Factor";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
            end;

            trigger OnPreDataItem()
            begin
                if not PurchCrMemoHdr.HasFilter then
                    CurrReport.Break();
            end;
        }
        dataitem(GeneralDoc; "G/L Entry")
        {
            DataItemTableView = sorting("Document No.", "Posting Date");
            RequestFilterFields = "Document No.", "Posting Date";
            RequestFilterHeading = 'General Document';
            column(GeneralDoc_DocumentNo; "Document No.")
            {
            }
            dataitem(GeneralDocEntry; "G/L Entry")
            {
                DataItemLink = "Document No." = field("Document No.");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    BufferGLEntry(GeneralDocEntry);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", 1, LastGLEntry);
                end;
            }
            dataitem(GeneralDocBufferedEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(GeneralDocEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(GeneralDocEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(GeneralDocEntry_GlobalDimension2Code; TempGLEntry."Global Dimension 2 Code")
                {
                }
                column(GeneralDocEntry_GlobalDimension1Code; TempGLEntry."Global Dimension 1 Code")
                {
                }
                column(GeneralDocEntry_Description; TempGLEntry.Description)
                {
                }
                column(GeneralDocEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(GeneralDocEntry_PostingDate; Format(TempGLEntry."Posting Date"))
                {
                }
                column(GeneralDocEntry_UserName; UserSetup."User Name CZL")
                {
                }
                column(GeneralDocEntry_GroupText; GroupText)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();

                    GetUserSetup(TempGLEntry."User ID");
                    GroupText := GetGroupText(TempGLEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if LastDocNo <> "Document No." then begin
                    LastDocNo := "Document No.";
                    TempGLEntry.DeleteAll();
                end else
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not HasFilter then
                    CurrReport.Break();
                LastDocNo := '';
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
                    field(GroupGLAccountsField; GroupGLAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Group same G/L accounts';
                        ToolTip = 'Specifies if the same G/L accounts have to be group.';
                    }
                }
            }
        }
    }

    labels
    {
        SalesInvoiceLbl = '(Sales Invoice)';
        SalesCreditMemoLbl = '(Sales Credit Memo)';
        PurchaseInvoiceLbl = '(Purchase Invoice)';
        PurchaseCreditMemoLbl = '(Purchase Credit Memo)';
        GeneralDocumentLbl = '(General Document)';
        CustomerLbl = 'Customer';
        VendorLbl = 'Vendor';
        DateLbl = 'Date:';
        RateLbl = 'Rate';
        CreditAmountLbl = 'Credit Amount';
        DebitAmountLbl = 'Debit Amount';
        GLAccountLbl = 'G/L Account';
        FormalCorrectnessVerifiedByLbl = 'Formal Correctness Verified by:';
        FactualCorrectnessVerifiedByLbl = 'Factual Correctness Verified by :';
        PostedByLbl = 'Posted by :';
        ApprovedByLbl = 'Approved by :';
        ExternalNoLbl = 'External No.';
        DescriptionLbl = 'Description';
        PostingDateLbl = 'Posting Date';
        VATDateLbl = 'VAT Date';
        DocumentDateLbl = 'Document Date';
        DueDateLbl = 'Due Date';
        NoLbl = 'No.';
        AmountLbl = 'Amount';
        CurrencyCodeLbl = 'Currency Code';
        DocumentNoLbl = 'Document No.';
    }

    trigger OnInitReport()
    begin
        GroupGLAccounts := true;
        OnAfterOnInitReport(GroupGLAccounts);
    end;

    trigger OnPreReport()
    begin
        CompanyInformation.Get();

        GLEntry.Reset();
        if GLEntry.FindLast() then
            LastGLEntry := GLEntry."Entry No.";

        LastDataItem := GetLastDataItem();
        SalesInvHdrExists := not SalesInvoiceHeader.IsEmpty() and SalesInvoiceHeader.HasFilter();
        SalesCrMemoHdrExists := not SalesCrMemoHeader.IsEmpty() and SalesCrMemoHeader.HasFilter();
        PurchInvHdrExists := not PurchInvHeader.IsEmpty() and PurchInvHeader.HasFilter();
        PurchCrMemoHdrExists := not PurchCrMemoHdr.IsEmpty() and PurchCrMemoHdr.HasFilter();
        GeneralDocExists := not GeneralDoc.IsEmpty() and GeneralDoc.HasFilter();
    end;

    var
        CompanyInformation: Record "Company Information";
        UserSetup: Record "User Setup";
        TempGLEntry: Record "G/L Entry" temporary;
        GLEntry: Record "G/L Entry";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        LastDocNo: Code[20];
        FCYRate: Decimal;
        LastGLEntry: Integer;
        GroupCaption: Text;
        GroupText: Text;
        GLAccountNameTxt: Label 'G/L Account Name';
        DescriptionTxt: Label 'Description';

    protected var
        LastDataItem: Integer;
        GeneralDocExists: Boolean;
        GroupGLAccounts: Boolean;
        PurchInvHdrExists: Boolean;
        PurchCrMemoHdrExists: Boolean;
        SalesInvHdrExists: Boolean;
        SalesCrMemoHdrExists: Boolean;

    procedure GetLastDataItem(): Integer
    begin
        case true of
            not GeneralDoc.IsEmpty() and GeneralDoc.HasFilter():
                exit(5);
            not PurchCrMemoHdr.IsEmpty() and PurchCrMemoHdr.HasFilter():
                exit(4);
            not PurchInvHeader.IsEmpty() and PurchInvHeader.HasFilter():
                exit(3);
            not SalesCrMemoHeader.IsEmpty() and SalesCrMemoHeader.HasFilter():
                exit(2);
            not SalesInvoiceHeader.IsEmpty() and SalesInvoiceHeader.HasFilter():
                exit(1);
        end;
    end;

    local procedure BufferGLEntry(GLEntry: Record "G/L Entry")
    begin
        if GLEntry.Amount = 0 then
            exit;
        TempGLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
        TempGLEntry.SetRange("Global Dimension 1 Code", GLEntry."Global Dimension 1 Code");
        TempGLEntry.SetRange("Global Dimension 2 Code", GLEntry."Global Dimension 2 Code");
        TempGLEntry.SetRange("Job No.", GLEntry."Job No.");
        if TempGLEntry.FindFirst() and GroupGLAccounts then begin
            TempGLEntry."Debit Amount" += GLEntry."Debit Amount";
            TempGLEntry."Credit Amount" += GLEntry."Credit Amount";
            TempGLEntry.Modify();
        end else begin
            TempGLEntry.Init();
            TempGLEntry.TransferFields(GLEntry);
            TempGLEntry.Insert();
        end;
    end;

    local procedure GetUserSetup(UserCode: Code[50])
    begin
        if UserSetup."User ID" <> UserCode then
            if not UserSetup.Get(UserCode) then
                UserSetup.Init();
    end;

    local procedure GetGroupText(GLEntry: Record "G/L Entry"): Text
    var
        GLAccount: Record "G/L Account";
    begin
        if GroupGLAccounts then begin
            GLAccount.Get(GLEntry."G/L Account No.");
            exit(GLAccount.Name);
        end;
        exit(GLEntry.Description);
    end;

    procedure InitializeRequest(NewGroupGLAccounts: Boolean)
    begin
        GroupGLAccounts := NewGroupGLAccounts;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterOnInitReport(var GroupGLAccounts: Boolean)
    begin
    end;
}
