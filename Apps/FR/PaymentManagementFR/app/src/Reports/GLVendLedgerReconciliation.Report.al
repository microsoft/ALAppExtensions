// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Vendor;

report 10844 "GL/Vend Ledger Reconciliation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/GLVendLedgerReconciliation.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'GL/Vend. Ledger Reconciliation';
    Permissions = TableData "G/L Account Net Change" = rimd;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter";
            column(USERID; UserId)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(FirstNo; FirstNo)
            {
            }
            column(LastNo; LastNo)
            {
            }
            column(Vendor__No__; "No.")
            {
            }
            column(Vendor_Name; Name)
            {
            }
            column(TotalDebit; TotalDebit)
            {
            }
            column(TotalCredit; TotalCredit)
            {
            }
            column(TotalDebit_TotalCredit; TotalDebit - TotalCredit)
            {
            }
            column(General_Vendor_ledger_reconciliationCaption; General_Vendor_ledger_reconciliationCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(G_L_Entry__Debit_Amount_Caption; "G/L Entry".FieldCaption("Debit Amount"))
            {
            }
            column(G_L_Entry__Credit_Amount_Caption; "G/L Entry".FieldCaption("Credit Amount"))
            {
            }
            column(G_L_Entry_AmountCaption; "G/L Entry".FieldCaption(Amount))
            {
            }
            column(G_L_Entry_DescriptionCaption; "G/L Entry".FieldCaption(Description))
            {
            }
            column(G_L_Entry__Document_No__Caption; "G/L Entry".FieldCaption("Document No."))
            {
            }
            column(G_L_Entry__Document_Type_Caption; "G/L Entry".FieldCaption("Document Type"))
            {
            }
            column(G_L_Entry__G_L_Account_No__Caption; "G/L Entry".FieldCaption("G/L Account No."))
            {
            }
            column(G_L_Entry__Posting_Date_Caption; G_L_Entry__Posting_Date_CaptionLbl)
            {
            }
            column(General_AmountCaption; General_AmountCaptionLbl)
            {
            }
            dataitem("Vendor Posting Group"; "Vendor Posting Group")
            {
                DataItemTableView = sorting(Code);
                PrintOnlyIfDetail = true;
                column(TotalDebit_TotalCredit_Control1120015; TotalDebit - TotalCredit)
                {
                }
                column(TotalCredit_Control1120014; TotalCredit)
                {
                }
                column(TotalDebit_Control1120013; TotalDebit)
                {
                }
                column(Vendor_Posting_Group_Code; Code)
                {
                }
                column(Vendor_Posting_Group_Payables_Account; "Payables Account")
                {
                }
                column(Total_amount_for_the_vendorCaption; Total_amount_for_the_vendorCaptionLbl)
                {
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemLink = "G/L Account No." = field("Payables Account");
                    DataItemTableView = sorting("G/L Account No.", "Source Type", "Source No.") where(Amount = filter(<> 0));
                    column(G_L_Entry__Debit_Amount_; "Debit Amount")
                    {
                    }
                    column(G_L_Entry__Credit_Amount_; "Credit Amount")
                    {
                    }
                    column(G_L_Entry_Amount; Amount)
                    {
                    }
                    column(G_L_Entry__Posting_Date_; Format("Posting Date"))
                    {
                    }
                    column(G_L_Entry_Description; Description)
                    {
                    }
                    column(G_L_Entry__Document_Type_; "Document Type")
                    {
                    }
                    column(G_L_Entry__Document_No__; "Document No.")
                    {
                    }
                    column(G_L_Entry__G_L_Account_No__; "G/L Account No.")
                    {
                    }
                    column(G_L_Entry__Debit_Amount__Control1120036; "Debit Amount")
                    {
                    }
                    column(G_L_Entry__Credit_Amount__Control1120037; "Credit Amount")
                    {
                    }
                    column(G_L_Entry_Amount_Control1120038; Amount)
                    {
                    }
                    column(G_L_Entry_Entry_No_; "Entry No.")
                    {
                    }
                    column(Total_amount_for_the_general_ledgerCaption; Total_amount_for_the_general_ledgerCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("Bal. Account Type" = "Bal. Account Type"::Vendor) and ("Bal. Account No." = Vendor."No.") then
                            CurrReport.Skip();
                        TotalDebit := TotalDebit + "Debit Amount";
                        TotalCredit := TotalCredit + "Credit Amount";
                        GLAccountNetChange.Get("G/L Account No.");
                        GLAccountNetChange."Net Change in Jnl." += Amount;
                        GLAccountNetChange.Modify();
                        HavingDetail := true;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Source Type", "Source Type"::Vendor);
                        SetRange("Source No.", Vendor."No.");
                        SetRange("Posting Date", Vendor.GetRangeMin("Date Filter"), Vendor.GetRangeMax("Date Filter"));
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TempPostingBuffer);
                    TempPostingBuffer."Account Type" := TempPostingBuffer."Account Type"::"G/L Account";
                    TempPostingBuffer."Account No." := "Payables Account";
                    if not TempPostingBuffer.Insert() then
                        CurrReport.Skip();
                    Clear(GLAccountNetChange);
                    GLAccountNetChange."No." := "Payables Account";
                    if not GLAccountNetChange.Insert() then;
                end;

                trigger OnPostDataItem()
                begin
                    TempPostingBuffer.DeleteAll();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TotalDebit := 0;
                TotalCredit := 0;
                HavingDetail := false;
            end;

            trigger OnPreDataItem()
            begin
                Clear(TotalDebit);
                Clear(TotalCredit);
                Vendor.FindFirst();
                FirstNo := "No.";
                Vendor.FindLast();
                LastNo := "No.";
            end;
        }
        dataitem("G/L Account Net Change"; "G/L Account Net Change")
        {
            column(HavingDetail; HavingDetail)
            {
            }
            column(GL_Account_Net_Change; "Net Change in Jnl.")
            {
            }
            column(GL_Account_No; "No.")
            {
            }
            column(General_amount_for_the_general_ledgerCaption; General_amount_for_the_general_ledgerCaptionLbl)
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        GLAccountNetChange.DeleteAll();
    end;

    var
        TempPostingBuffer: Record "Payment Post. Buffer FR" temporary;
        GLAccountNetChange: Record "G/L Account Net Change";
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        FirstNo: Code[20];
        LastNo: Code[20];
        HavingDetail: Boolean;
        General_Vendor_ledger_reconciliationCaptionLbl: Label 'General/Vendor ledger reconciliation';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        G_L_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        General_AmountCaptionLbl: Label 'General Amount';
        Total_amount_for_the_vendorCaptionLbl: Label 'Total amount for the vendor';
        Total_amount_for_the_general_ledgerCaptionLbl: Label 'Total amount for the general ledger';
        General_amount_for_the_general_ledgerCaptionLbl: Label 'General amount for the general ledger';
}
