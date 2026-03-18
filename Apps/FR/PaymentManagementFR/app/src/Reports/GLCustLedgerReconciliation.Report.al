// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Sales.Customer;

report 10841 "GL/Cust Ledger Reconciliation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/GLCustLedgerReconciliation.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'GL/Cust. Ledger Reconciliation';
    Permissions = TableData "G/L Account Net Change" = rimd;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
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
            column(LastNo; LastNo)
            {
            }
            column(FirstNo; FirstNo)
            {
            }
            column(Customer__No__; "No.")
            {
            }
            column(Customer_Name; Name)
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
            column(General_Customer_ledger_reconciliationCaption; General_Customer_ledger_reconciliationCaptionLbl)
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
            dataitem("Customer Posting Group"; "Customer Posting Group")
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
                column(Customer_Posting_Group_Code; Code)
                {
                }
                column(Customer_Posting_Group_Receivables_Account; "Receivables Account")
                {
                }
                column(Total_amount_for_the_customerCaption; Total_amount_for_the_customerCaptionLbl)
                {
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemLink = "G/L Account No." = field("Receivables Account");
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
                        if ("Bal. Account Type" = "Bal. Account Type"::Customer) and ("Bal. Account No." = Customer."No.") then
                            CurrReport.Skip();
                        TotalDebit := TotalDebit + "Debit Amount";
                        TotalCredit := TotalCredit + "Credit Amount";
                        GLAccountNetChange.Get("G/L Account No.");
                        GLAccountNetChange."Net Change in Jnl." += Amount;
                        GLAccountNetChange.Modify();
                        HavingNoDetail := false;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Source Type", "Source Type"::Customer);
                        SetRange("Source No.", Customer."No.");
                        SetRange("Posting Date", Customer.GetRangeMin("Date Filter"), Customer.GetRangeMax("Date Filter"));
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(TempPostingBuffer);
                    TempPostingBuffer."Account Type" := TempPostingBuffer."Account Type"::"G/L Account";
                    TempPostingBuffer."Account No." := "Receivables Account";
                    if not TempPostingBuffer.Insert() then
                        CurrReport.Skip();
                    Clear(GLAccountNetChange);
                    GLAccountNetChange."No." := "Receivables Account";
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
                HavingNoDetail := true;
            end;

            trigger OnPreDataItem()
            begin
                Clear(TotalDebit);
                Clear(TotalCredit);
                Customer.FindFirst();
                FirstNo := "No.";
                Customer.FindLast();
                LastNo := "No.";
            end;
        }
        dataitem("G/L Account Net Change"; "G/L Account Net Change")
        {
            column(HavingNoDetail; HavingNoDetail)
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
        HavingNoDetail: Boolean;
        General_Customer_ledger_reconciliationCaptionLbl: Label 'General/Customer ledger reconciliation';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        G_L_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        General_AmountCaptionLbl: Label 'General Amount';
        Total_amount_for_the_customerCaptionLbl: Label 'Total amount for the customer';
        Total_amount_for_the_general_ledgerCaptionLbl: Label 'Total amount for the general ledger';
        General_amount_for_the_general_ledgerCaptionLbl: Label 'General amount for the general ledger';
}