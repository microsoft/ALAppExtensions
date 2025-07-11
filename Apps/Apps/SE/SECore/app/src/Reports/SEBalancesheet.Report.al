// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

report 11290 "SE Balance sheet"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/SEBalancesheet.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Balance Sheet - SE';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") WHERE("Income/Balance" = CONST("Balance Sheet"));
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(Period______PeriodText; 'Period: ' + PeriodText)
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(USERID; UserId)
            {
            }
            column(G_L_Account__TABLECAPTION__________RedovFilter; "G/L Account".TableCaption + ': ' + AccountFilter)
            {
            }
            column(G_L_Account_No_; "No.")
            {
            }
            column(Balance_sheetCaption; Balance_sheetCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(Balance_carried_forwardCaption; Balance_carried_forwardCaptionLbl)
            {
            }
            column(G_L_Account___No__Caption; FieldCaption("No."))
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(Balance_brought_forwardCaption; Balance_brought_forwardCaptionLbl)
            {
            }
            dataitem(EmptyRowCounter; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, "G/L Account"."No. of Blank Lines");
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(G_L_Account___No__; "G/L Account"."No.")
                {
                }
                column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__Name; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(G_L_Account___Net_Change_; "G/L Account"."Net Change")
                {
                }
                column(G_L_Account___Balance_at_Date_; "G/L Account"."Balance at Date")
                {
                }
                column(G_L_Account___Balance_at_Date___G_L_Account___Net_Change_; "G/L Account"."Balance at Date" - "G/L Account"."Net Change")
                {
                }
                column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__Name_Control26; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(G_L_Account___Net_Change__Control27; "G/L Account"."Net Change")
                {
                }
                column(G_L_Account___Balance_at_Date__Control29; "G/L Account"."Balance at Date")
                {
                }
                column(G_L_Account___Balance_at_Date___G_L_Account___Net_Change__Control33; "G/L Account"."Balance at Date" - "G/L Account"."Net Change")
                {
                }
                column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__Name_Control11; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(PrintOut; PrintOut)
                {
                }
                column(Integer_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not PrintOut then
                        CurrReport.Skip();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Net Change", "Balance at Date");

                PrintOut := true;
                if ("Account Type" = "Account Type"::Posting) and not ViewAllAccounts then
                    if ("Net Change" = 0) and ("Balance at Date" = 0) then
                        Clear(PrintOut);
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
                    field(ShowAllAccounts; ViewAllAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show all accounts';
                        ToolTip = 'Specifies whether to include accounts without balances.';
                    }
                }
            }
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
        AccountFilter := "G/L Account".GetFilters();
        PeriodText := "G/L Account".GetFilter("Date Filter");
    end;

    var
        AccountFilter: Text[250];
        PeriodText: Text[30];
        ViewAllAccounts: Boolean;
        PrintOut: Boolean;
        Balance_sheetCaptionLbl: Label 'Balance sheet';
        PageCaptionLbl: Label 'Page';
        BalanceCaptionLbl: Label 'Balance';
        Balance_carried_forwardCaptionLbl: Label 'Balance carried forward';
        NameCaptionLbl: Label 'Name';
        Balance_brought_forwardCaptionLbl: Label 'Balance brought forward';
}

