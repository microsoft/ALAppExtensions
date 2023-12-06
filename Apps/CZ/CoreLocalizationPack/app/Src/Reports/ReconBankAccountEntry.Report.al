// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Reports;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Utilities;

report 11719 "Recon. Bank Account Entry CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ReconBankAccountEntry.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Reconcile Bank Account Entry';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Bank Account"; "Bank Account")
        {
            CalcFields = "Net Change (LCY)";
            RequestFilterFields = "No.", Name, "Date Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(gteFilter; Filter)
            {
            }
            column(Bank_Account__No__; "No.")
            {
            }
            column(Bank_Account_Name; Name)
            {
            }
            column(Bank_Account__Net_Change__LCY__; "Net Change (LCY)")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Reconcile_Bank_Account_EntryCaption; Reconcile_Bank_Account_EntryCaptionLbl)
            {
            }
            column(Bank_Account_Date_Filter; "Date Filter")
            {
            }
            column(gboShowDetail; ShowDetail)
            {
            }
            dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("No."), "Posting Date" = field("Date Filter");
                DataItemTableView = sorting("Bank Account No.", "Posting Date");
                column(Bank_Account_Ledger_Entry__Posting_Date_; "Posting Date")
                {
                }
                column(Bank_Account_Ledger_Entry__Document_Type_; "Document Type")
                {
                }
                column(Bank_Account_Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Bank_Account_Ledger_Entry_Description; Description)
                {
                }
                column(Bank_Account_Ledger_Entry__Amount__LCY__; "Amount (LCY)")
                {
                }
                column(Bank_Account_Ledger_Entry__Posting_Date_Caption; FieldCaption("Posting Date"))
                {
                }
                column(Bank_Account_Ledger_Entry__Document_No__Caption; FieldCaption("Document No."))
                {
                }
                column(Bank_Account_Ledger_Entry__Document_Type_Caption; FieldCaption("Document Type"))
                {
                }
                column(Bank_Account_Ledger_Entry_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Bank_Account_Ledger_Entry__Amount__LCY__Caption; FieldCaption("Amount (LCY)"))
                {
                }
                column(Bank_Account_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Bank_Account_Ledger_Entry_Bank_Account_No_; "Bank Account No.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    BankAccountPostingGroup.TestField("G/L Account No.");

                    if TempGLAccountNetChange.Get(GLAccNo) then begin
                        TempGLAccountNetChange."Net Change in Jnl." += "Amount (LCY)";
                        TempGLAccountNetChange.Modify();
                    end else begin
                        TempGLAccountNetChange.Init();
                        TempGLAccountNetChange."No." := GLAccNo;
                        TempGLAccountNetChange."Net Change in Jnl." := "Amount (LCY)";
                        TempGLAccountNetChange.Insert();
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if "Bank Acc. Posting Group" <> BankAccountPostingGroup.Code then
                    if BankAccountPostingGroup.Get("Bank Acc. Posting Group") then
                        GLAccNo := BankAccountPostingGroup."G/L Account No."
                    else begin
                        Clear(BankAccountPostingGroup);
                        Clear(GLAccNo);
                    end;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number);
            column(greGLAcc_FIELDCAPTION__Balance_at_Date__; GLAccount.FieldCaption("Balance at Date"))
            {
            }
            column(greGLAcc_FIELDCAPTION_Name_; GLAccount.FieldCaption(Name))
            {
            }
            column(greGLAcc_FIELDCAPTION__No___; GLAccount.FieldCaption("No."))
            {
            }
            column(greTBuffer__No__; TempGLAccountNetChange."No.")
            {
            }
            column(greTBuffer__Net_Change_in_Jnl__; TempGLAccountNetChange."Net Change in Jnl.")
            {
            }
            column(greGLAcc_Name; GLAccount.Name)
            {
            }
            column(greTBuffer__Net_Change_in_Jnl_____greGLAcc__Net_Change_; TempGLAccountNetChange."Net Change in Jnl." - GLAccount."Net Change")
            {
            }
            column(greGLAcc__Net_Change_; GLAccount."Net Change")
            {
            }
            column(greTBuffer__Net_Change_in_Jnl_____greGLAcc__Net_Change__Control1100170000; TempGLAccountNetChange."Net Change in Jnl." - GLAccount."Net Change")
            {
            }
            column(greGLAcc__Net_Change__Control1100170001; GLAccount."Net Change")
            {
            }
            column(greTBuffer__Net_Change_in_Jnl___Control1100170002; TempGLAccountNetChange."Net Change in Jnl.")
            {
            }
            column(General_Ledger_SpecificationCaption; General_Ledger_SpecificationCaptionLbl)
            {
            }
            column(greTBuffer__Net_Change_in_Jnl_____greGLAcc__Net_Change_Caption; TBuffer__Net_Change_in_Jnl_____greGLAcc__Net_Change_CaptionLbl)
            {
            }
            column(greGLAcc__Net_Change_Caption; GLAcc__Net_Change_CaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(Integer_Number; Number)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempGLAccountNetChange.FindSet()
                else
                    TempGLAccountNetChange.Next();

                GLAccount.Get(TempGLAccountNetChange."No.");
                GLAccount.CalcFields("Net Change");
            end;

            trigger OnPreDataItem()
            begin
                TempGLAccountNetChange.Reset();
                SetRange(Number, 1, TempGLAccountNetChange.Count);

                GLAccount.SetFilter("Date Filter", "Bank Account".GetFilter("Date Filter"));
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
                    field(ShowDetailField; ShowDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Detail';
                        ToolTip = 'Specifies when the detail is to be show';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        Filter := CopyStr("Bank Account".GetFilters, 1, MaxStrLen(Filter));
    end;

    var
#pragma warning disable AL0432
        TempGLAccountNetChange: Record "G/L Account Net Change" temporary;
#pragma warning restore AL0432
        GLAccount: Record "G/L Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        "Filter": Text[1024];
        ShowDetail: Boolean;
        GLAccNo: Code[20];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Reconcile_Bank_Account_EntryCaptionLbl: Label 'Reconcile Bank Account Entry';
        General_Ledger_SpecificationCaptionLbl: Label 'General Ledger Specification';
        TBuffer__Net_Change_in_Jnl_____greGLAcc__Net_Change_CaptionLbl: Label 'Difference';
        GLAcc__Net_Change_CaptionLbl: Label 'Balance at Date by GL';
        TotalCaptionLbl: Label 'Total';
}
