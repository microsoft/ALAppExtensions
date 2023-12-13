// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.IRS;
#if not CLEAN24
using Microsoft.Finance.VAT.Reporting;
#endif

report 14603 "IS IRS Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/ISIRSDetails.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'IRS Details';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("IS IRS Numbers"; "IS IRS Numbers")
        {
            DataItemTableView = sorting("IRS Number") order(ascending);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "IRS Number";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(Today; Today)
            {
            }
            column(DateFil; DateFil)
            {
            }
            column(IRSNumber_IRSNumbers; "IRS Number")
            {
            }
            column(Name_IRSNumbers; Name)
            {
            }
            column(NoCaption_GLAcc; "G/L Account".FieldCaption("No."))
            {
            }
            column(NameCaption_GLAcc; "G/L Account".FieldCaption(Name))
            {
            }
            column(BalanceAtDateCaption_GLAcc; "G/L Account".FieldCaption("Balance at Date"))
            {
            }
            column(IRSDetailsCaption; IRSDetailsCaptionLbl)
            {
            }
            column(EmptyStringCaption; EmptyStringCaptionLbl)
            {
            }
            column(ValueinIRSnumberlistCaption; ValueinIRSnumberlistCaptionLbl)
            {
            }
            column(GenPostTypeCaption_GLAcc; "G/L Account".FieldCaption("Gen. Posting Type"))
            {
            }
            column(GenProdPostGroupCaption_GLAcc; "G/L Account".FieldCaption("Gen. Prod. Posting Group"))
            {
            }
            dataitem("G/L Account"; "G/L Account")
            {
                CalcFields = "Balance at Date";
                DataItemLink = "IRS No." = field("IRS Number");
                DataItemTableView = sorting("No.") order(ascending) where("Account Type" = const(Posting));
                RequestFilterFields = "Date Filter";
                column(No_GLAcc; "No.")
                {
                }
                column(Name_GLAcc; Name)
                {
                }
                column(BalanceAtDate_GLAcc; "Balance at Date")
                {
                }
                column("Sum"; Sum)
                {
                }
                column(GenPostType_GLAcc; "Gen. Posting Type")
                {
                }
                column(GenProdPostGroup_GLAcc; "Gen. Prod. Posting Group")
                {
                }
                column(TotSum; TotSum)
                {
                }
                column(EmptyStringCaption1; EmptyStringCaption1Lbl)
                {
                }
                column(IRSNumber_GLAcc; "IRS No.")
                {
                }
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

    trigger OnPreReport()
    var
    begin
        DateFil := "G/L Account".GetFilter("Date Filter");
    end;

#if not CLEAN24
    trigger OnInitReport()
    var
        ISCoreAppSetup: Record "IS Core App Setup";
    begin
        if not ISCoreAppSetup.IsEnabled() then begin
            Report.Run(Report::"IRS Details");
            Error('');
        end;
    end;
#endif

    var
        "Sum": Decimal;
        TotSum: Decimal;
        DateFil: Text[30];
        IRSDetailsCaptionLbl: Label 'IRS Details';
        EmptyStringCaptionLbl: Label '--------------------------------------------------------------------------------';
        ValueinIRSnumberlistCaptionLbl: Label 'Value in IRS number list';
        EmptyStringCaption1Lbl: Label '------------------------------';
}

