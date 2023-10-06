// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

report 11291 "SE Income statement"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/SEIncomestatement.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Income Statement - SE';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") WHERE("Income/Balance" = CONST("Income Statement"));
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
            column(Income_statementCaption; Income_statementCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(AccumulatedCaption; AccumulatedCaptionLbl)
            {
            }
            column(G_L_Account___No__Caption; FieldCaption("No."))
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(BudgetCaption; BudgetCaptionLbl)
            {
            }
            column(BalanceCaption_Control24; BalanceCaption_Control24Lbl)
            {
            }
            column(BudgetCaption_Control28; BudgetCaption_Control28Lbl)
            {
            }
            column(PeriodCaption; PeriodCaptionLbl)
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
                column(G_L_Account___Budgeted_Amount_; "G/L Account"."Budgeted Amount")
                {
                }
                column(G_L_Account___Budget_at_Date_; "G/L Account"."Budget at Date")
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
                column(G_L_Account___Budgeted_Amount__Control18; "G/L Account"."Budgeted Amount")
                {
                }
                column(G_L_Account___Budget_at_Date__Control22; "G/L Account"."Budget at Date")
                {
                }
                column(PADSTR_____G_L_Account__Indentation___2___G_L_Account__Name_Control15; PadStr('', "G/L Account".Indentation * 2) + "G/L Account".Name)
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
                CalcFields("Net Change", "Balance at Date", "Budgeted Amount", "Budget at Date");
                "Net Change" := -"Net Change";
                "Balance at Date" := -"Balance at Date";
                "Budgeted Amount" := -"Budgeted Amount";
                "Budget at Date" := -"Budget at Date";

                PrintOut := true;
                if ("Account Type" = "Account Type"::Posting) and not ViewAllAccounts then
                    if ("Net Change" = 0) and ("Balance at Date" = 0) and
                       ("Budgeted Amount" = 0) and ("Budget at Date" = 0)
                    then
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
        Income_statementCaptionLbl: Label 'Income statement';
        PageCaptionLbl: Label 'Page';
        AccumulatedCaptionLbl: Label 'Accumulated';
        NameCaptionLbl: Label 'Name';
        BalanceCaptionLbl: Label 'Balance';
        BudgetCaptionLbl: Label 'Budget';
        BalanceCaption_Control24Lbl: Label 'Balance';
        BudgetCaption_Control28Lbl: Label 'Budget';
        PeriodCaptionLbl: Label 'Period';
}

