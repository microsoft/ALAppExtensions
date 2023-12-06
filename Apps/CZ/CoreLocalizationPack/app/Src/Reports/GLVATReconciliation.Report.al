// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

report 11793 "G/L VAT Reconciliation CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GLVATReconciliation.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L VAT Reconciliation';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(GLAccFilter; GLAccFilter)
            {
            }
            column(GLAccount__No__; "No.")
            {
            }
            column(GLAccount_Name; Name)
            {
            }
            column(GLEntry__VAT_Amount_; "G/L Entry"."VAT Amount")
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = field("No.");
                DataItemTableView = sorting("G/L Account No.", "Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
                RequestFilterFields = "Posting Date", "VAT Date CZL";
#pragma warning restore AL0432
#else
                RequestFilterFields = "Posting Date", "VAT Reporting Date";
#endif
                column(GLEntry_Posting_Date_; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_VAT_Date_; "VAT Reporting Date")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Document_Type_; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Document_No__; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Gen__Posting_Type_; "Gen. Posting Type")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Gen__Bus__Posting_Group_; "Gen. Bus. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Gen__Prod__Posting_Group_; "Gen. Prod. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_VAT_Amount; "VAT Amount")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Entry_No; "Entry No.")
                {
                    IncludeCaption = true;
                }
                trigger OnAfterGetRecord()
                begin
#if not CLEAN22
#pragma warning disable AL0432
                    if not IsReplaceVATDateEnabled() then
                        "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
                    if DifferentOnly and ("Posting Date" = "VAT Reporting Date") then
                        CurrReport.Skip();
                end;
            }
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
                    field(DifferentOnlyCZL; DifferentOnly)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Different VAT and Posting Dates Only';
                        MultiLine = true;
                        ToolTip = 'Specifies when the different vat and posting dates only is to be show.';
                    }
                }
            }
        }
    }
    labels
    {
        ReportCaptionLbl = 'G/L VAT Reconciliation';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        AccountNoLbl = 'Account No.';
    }
    trigger OnPreReport()
    begin
        if "G/L Account".GetFilters() <> '' then
            GLAccFilter := "G/L Account".Tablecaption() + ': ' + "G/L Account".GetFilters();
#if not CLEAN22
#pragma warning disable AL0432
        if "G/L Entry".IsReplaceVATDateEnabled() then begin
            "G/L Entry".CopyFilter("VAT Date CZL", "G/L Entry"."VAT Reporting Date");
            "G/L Entry".SetRange("VAT Date CZL");
        end;
#pragma warning restore AL0432
#endif
    end;

    var
        GLAccFilter: Text;
        DifferentOnly: Boolean;
}
