// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;
#if not CLEAN24
using Microsoft.Finance.GeneralLedger.Reports;
#endif

report 14605 "IS Trial Balance - IRS Number"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/ISTrialBalanceIRSNumber.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Trial Balance - IRS Number';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(PeriodText; 'Period:  ' + PeriodText)
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLFilter; "G/L Account".TableName + ': ' + GLFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(TrialBalanceIRSNumberCaption; TrialBalanceIRSNumberCaptionLbl)
            {
            }
            column(PageNoCaption; PageNoCaptionLbl)
            {
            }
            column(NetChangeCaption; NetChangeCaptionLbl)
            {
            }
            column(StatusCaption; StatusCaptionLbl)
            {
            }
            column(NoCaption_GLAcc; FieldCaption("No."))
            {
            }
            column(GLAccNameCaption; GLAccNameCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(IRSNumberCaption; IRSNumberCaptionLbl)
            {
            }
            dataitem(BlankLineCounter; "Integer")
            {
                DataItemTableView = sorting(Number);

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, "G/L Account"."No. of Blank Lines");
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(No_GLAcc; "G/L Account"."No.")
                {
                }
                column(GLAccName; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(NetChange_GLAcc; "G/L Account"."Net Change")
                {
                }
                column(NegativeNetChange_GLAcc; -"G/L Account"."Net Change")
                {
                }
                column(BalanceAtDate_GLAcc; "G/L Account"."Balance at Date")
                {
                }
                column(NegativeBalanceAtDate_GLAcc; -"G/L Account"."Balance at Date")
                {
                }
                column(IRSNumber_GLAcc; "G/L Account"."IRS No.")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Net Change", "Balance at Date");
            end;
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

    trigger OnPreReport()
    begin
        GLFilter := "G/L Account".GetFilters();
        PeriodText := "G/L Account".GetFilter("Date Filter");
    end;

#if not CLEAN24
    trigger OnInitReport()
    var
        ISCoreAppSetup: Record "IS Core App Setup";
    begin
        if not ISCoreAppSetup.IsEnabled() then begin
            Report.Run(Report::"Trial Balance - IRS Number");
            Error('');
        end;
    end;
#endif

    var
        GLFilter: Text[250];
        PeriodText: Text[30];
        TrialBalanceIRSNumberCaptionLbl: Label 'Trial Balance - IRS Number';
        PageNoCaptionLbl: Label 'Page';
        NetChangeCaptionLbl: Label 'Net Change';
        StatusCaptionLbl: Label 'Status';
        GLAccNameCaptionLbl: Label 'Name';
        DebitCaptionLbl: Label 'Debit';
        CreditCaptionLbl: Label 'Credit';
        IRSNumberCaptionLbl: Label 'IRS Number';
}

