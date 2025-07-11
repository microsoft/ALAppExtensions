// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;

report 31243 "FA - Analysis G/L Account CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FAAnalysisGLAccount.rdl';
    Caption = 'FA - Analysis G/L Account';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = FixedAssets;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Account Type" = const(Posting));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter";
            CalcFields = "Net Change", "Debit Amount", "Credit Amount";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(GLAccount_No; "No.")
            {
            }
            column(GLAccount_Name; Name)
            {
            }
            column(GLAccount_NetChange; "Net Change")
            {
            }
            column(GLAccount_DebitAmount; "Debit Amount")
            {
            }
            column(GLAccount_CreditAmount; "Credit Amount")
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = field("No."), "Posting Date" = field("Date Filter"), "Global Dimension 1 Code" = field("Global Dimension 1 Filter"), "Global Dimension 2 Code" = field("Global Dimension 2 Filter");
                DataItemTableView = sorting("G/L Account No.", "Posting Date");
                PrintOnlyIfDetail = true;
                column(GLEntry_GLAccountNo; "G/L Account No.")
                {
                }
                dataitem("FA Ledger Entry"; "FA Ledger Entry")
                {
                    DataItemLink = "G/L Entry No." = field("Entry No."), "Posting Date" = field("Posting Date");
                    DataItemTableView = sorting("G/L Entry No.");
                    RequestFilterFields = "FA Posting Type";
                    column(FixedAsset_Description; FixedAsset.Description)
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_PostingDate; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_DocumentNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_DepreciationBookCode; "Depreciation Book Code")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_FANo; "FA No.")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_Description; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_FAPostingType; "FA Posting Type")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_Amount; Amount)
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_DebitAmount; "Debit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_CreditAmount; "Credit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_GlobalDimension1Code; "Global Dimension 1 Code")
                    {
                        IncludeCaption = true;
                    }
                    column(FALedgerEntry_GlobalDimension2Code; "Global Dimension 2 Code")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if not FixedAsset.Get("FA No.") then
                            Clear(FixedAsset);
                    end;
                }
            }

            trigger OnPreDataItem()
            var
                AccountNoErr: Label 'Enter %1.', Comment = '%1 = G/L Account TableCaption';
            begin
                if GetFilter("No.") = '' then
                    Error(AccountNoErr, TableCaption());
            end;
        }
    }

    labels
    {
        ReportNameLbl = 'Fixed Asset - Analysis G/L Account';
        PageLbl = 'Page';
        FADescriptionLbl = 'FA Description';
        TotalFALbl = 'Total Fixed Asset';
        TotalGLLbl = 'Total General Ledger';
    }

    var
        FixedAsset: Record "Fixed Asset";
}
