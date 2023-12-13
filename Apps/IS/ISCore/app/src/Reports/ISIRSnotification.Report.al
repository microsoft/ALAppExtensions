// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Utilities;
using Microsoft.Foundation.Company;
#if not CLEAN24
using Microsoft.Finance.VAT.Reporting;
#endif

report 14608 "IS IRS notification"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/ISIRSnotification.rdlc';
    Caption = 'IRS notification';
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(TodayFormatted; LowerCase(Format(Today, 0, 4)))
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoAddress; CompanyInfo.Address)
            {
            }
            column(CompanyInfoPostCodeAndCity; CompanyInfo."Post Code" + ' ' + CompanyInfo.City)
            {
            }
            column(CompanyInfoRegNo; 'Kt. ' + CompanyInfo."Registration No.")
            {
            }
            column(TaxAuthoritiesCaption; TaxAuthoritiesCaptionLbl)
            {
            }
            column(AddrOfTaxAuthoritiesCaption; AddrOfTaxAuthoritiesCaptionLbl)
            {
            }
            column(ZipCodeOfTaxAuthoritiesCaption; ZipCodeOfTaxAuthoritiesCaptionLbl)
            {
            }
            column(IssueOfSingleCopyInvoicesCaption; IssueOfSingleCopyInvoicesCaptionLbl)
            {
            }
            column(NotificationThatTheCompanyCaption; NotificationThatTheCompanyCaptionLbl)
            {
            }
            column(InvInAccordanceCaption; InvInAccordanceCaptionLbl)
            {
            }
            column(VersionOfNavisionCaption; VersionOfNavisionCaptionLbl)
            {
            }
            column(ManagerCaption; ManagerCaptionLbl)
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

    trigger OnInitReport()
#if not CLEAN24
    var
        ISCoreAppSetup: Record "IS Core App Setup";
#endif
    begin
        CompanyInfo.Get();
#if not CLEAN24
        if not ISCoreAppSetup.IsEnabled() then begin
            Report.Run(Report::"IRS notification");
            Error('');
        end;
#endif
    end;

    var
        CompanyInfo: Record "Company Information";
        TaxAuthoritiesCaptionLbl: Label 'Tax authorities';
        AddrOfTaxAuthoritiesCaptionLbl: Label 'Address of tax authorities';
        ZipCodeOfTaxAuthoritiesCaptionLbl: Label 'Zip code of tax authorities';
        IssueOfSingleCopyInvoicesCaptionLbl: Label 'Issue of single copy invoices';
        NotificationThatTheCompanyCaptionLbl: Label 'Notification that the company';
        InvInAccordanceCaptionLbl: Label 'intents to utilize the possibility to issue single copy invoices in accordance with IS regulation no. 598/1999';
        VersionOfNavisionCaptionLbl: Label 'It is also confirmed that the company uses a version of Navision that complies with the regulation.';
        ManagerCaptionLbl: Label 'Manager';
}

