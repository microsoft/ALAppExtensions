// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

report 18027 "TDS Certificate Receivable GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/TDSCertificateReceivable.rdl';
    Caption = 'TDS Certificate Receivable';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
        {
            DataItemTableView = sorting("Customer No.")
                                where("TDS Certificate Receivable" = filter(1));
            RequestFilterFields = "Customer No.", "Document No.", "Certificate Received", "Posting Date";

            column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
            {
            }
            column(CompanyInfo_Name; CompanyInfo.Name)
            {
            }
            column(USERID; UserId())
            {
            }
            column(GETFILTERS; GetFilters())
            {
            }
            column(Report_on_TDS_Certificate_Receivable___Received_from_Customer________PostingDateFilter; 'Report on TDS Certificate Receivable / Received from Customer' + ' ' + PostingDateFilter)
            {
            }
            column(Cust__Ledger_Entry__Customer_No__; "Customer No.")
            {
            }
            column(Cust__Ledger_Entry__Document_Type_; "Document Type")
            {
            }
            column(Cust__Ledger_Entry__Document_No__; "Document No.")
            {
            }
            column(Cust__Ledger_Entry__Certificate_Received_; Format("Certificate Received"))
            {
            }
            column(Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_; Format("TDS Certificate Rcpt Date"))
            {
            }
            column(Cust__Ledger_Entry__TDS_Certificate_Amount_; "TDS Certificate Amount")
            {
            }
            column(Customer_Name; Customer.Name)
            {
            }
            column(Cust__Ledger_Entry__Certificate_No__; "Certificate No.")
            {
            }
            column(FinancialYear; FinancialYear)
            {
            }
            column(Customer_Address_________Customer__Address_2_; Customer.Address + ' ' + Customer."Address 2")
            {
            }
            column(Cust__Ledger_Entry__TDS_Receivable_Group_; "TDS Section Code")
            {
            }
            column(Cust__Ledger_Entry__Document_Date_; Format("Document Date"))
            {
            }
            column(Cust__Ledger_Entry_Entry_No_; "Entry No.")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Customer_No__Caption; FieldCaption("Customer No."))
            {
            }
            column(Cust__Ledger_Entry__Document_Type_Caption; FieldCaption("Document Type"))
            {
            }
            column(Cust__Ledger_Entry__Document_No__Caption; FieldCaption("Document No."))
            {
            }
            column(Cust__Ledger_Entry__Certificate_Received_Caption; Cust__Ledger_Entry__Certificate_Received_CaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_Caption; Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_CaptionLbl)
            {
            }
            column(Certificate_TDS_Amount__Rs__Caption; Certificate_TDS_Amount__Rs__CaptionLbl)
            {
            }
            column(Customer_NameCaption; Customer_NameCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Certificate_No__Caption; FieldCaption("Certificate No."))
            {
            }
            column(Financial_YearCaption; Financial_YearCaptionLbl)
            {
            }
            column(Customer_AddressCaption; Customer_AddressCaptionLbl)
            {
            }
            column(TDS_Cert__Receivable_GroupCaption; TDS_Cert__Receivable_GroupCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Document_Date_Caption; Cust__Ledger_Entry__Document_Date_CaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Customer.Get("Customer No.") then;
                if "Financial Year" = 0 then
                    FinancialYear := ''
                else
                    FinancialYear := Format("Financial Year");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {

            }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        if "Cust. Ledger Entry".GetFilter("Posting Date") <> '' then
            PostingDateFilter := ' for the period of ' +
                "Cust. Ledger Entry".GetFilter("Posting Date");
    end;

    var
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        FinancialYear: Text[30];
        PostingDateFilter: Text[150];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Cust__Ledger_Entry__Certificate_Received_CaptionLbl: Label 'Certificate Received';
        Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_CaptionLbl: Label 'TDS Certificate Rcpt Date';
        Certificate_TDS_Amount__Rs__CaptionLbl: Label 'Certificate TDS Amount (Rs.)';
        Customer_NameCaptionLbl: Label 'Customer Name';
        Financial_YearCaptionLbl: Label 'Financial Year';
        Customer_AddressCaptionLbl: Label 'Customer Address';
        TDS_Cert__Receivable_GroupCaptionLbl: Label 'TDS Section';
        Cust__Ledger_Entry__Document_Date_CaptionLbl: Label 'Document Date';
}
