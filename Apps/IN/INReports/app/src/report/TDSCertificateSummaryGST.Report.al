// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

report 18028 "TDS Certificate Summary GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/TDSCertificateSummary.rdl';
    Caption = 'TDS Certificate Summary';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
        {
            DataItemTableView = sorting("Customer No.")
                                where("Certificate Received" = filter(1));
            RequestFilterFields = "Customer No.", "Posting Date";

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
            column(Summary_of_TDS_Certificate_Received_from_Customer______PostingDateFilter; StrSubstNo(Summary_of_TDS_Certificate_Received_from_Customer_CaptionLbl, PostingDateFilter))
            {
            }
            column(Cust__Ledger_Entry__TDS_Certificate_Amount_; "TDS Certificate Amount")
            {
            }
            column(Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_; Format("TDS Certificate Rcpt Date"))
            {
            }
            column(Cust__Ledger_Entry__Certificate_No__; "Certificate No.")
            {
            }
            column(Cust__Ledger_Entry__TDS_Receivable_Group_; "TDS Section Code")
            {
            }
            column(Customer_Address_________Customer__Address_2_; Customer.Address + ' ' + Customer."Address 2")
            {
            }
            column(Customer_Name; Customer.Name)
            {
            }
            column(Cust__Ledger_Entry__Customer_No__; "Customer No.")
            {
            }
            column(FinancialYear; FinancialYear)
            {
            }
            column(TDSRCVGroupTotal; TDSRCVGroupTotal)
            {
            }
            column(TotalTDSAmount; TotalTDSAmount)
            {
            }
            column(TotalTDSAmount_Control1500022; TotalTDSAmount)
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
            column(TDS_Cert__Receivable_GroupCaption; TDS_Cert__Receivable_GroupCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Certificate_No__Caption; FieldCaption("Certificate No."))
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
            column(Customer_AddressCaption; Customer_AddressCaptionLbl)
            {
            }
            column(TDS_Cert__Received_Group_Total__Rs__Caption; TDS_Cert__Received_Group_Total__Rs__CaptionLbl)
            {
            }
            column(Financial_YearCaption; Financial_YearCaptionLbl)
            {
            }
            column(Total_Caption; Total_CaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if PreCertificateNo <> "Certificate No." then begin
                    PreCertificateNo := "Certificate No.";
                    if Customer.Get("Customer No.") then;

                    TotalTDSAmount := TotalTDSAmount + "TDS Certificate Amount";
                    if "Financial Year" = 0 then
                        FinancialYear := ''
                    else
                        FinancialYear := Format("Financial Year");

                    if LastTDSRcvGroup = '' then begin
                        LastTDSRcvGroup := Format("TDS Section Code");
                        TDSRCVGroupTotal := TDSRCVGroupTotal + "TDS Certificate Amount";
                        CustomerNo := "Customer No.";
                    end else
                        if (Format("TDS Section Code") = LastTDSRcvGroup) and ("Customer No." = CustomerNo) then begin
                            LastTDSRcvGroup := Format("TDS Section Code");
                            CustomerNo := "Customer No.";
                        end else
                            if (Format("TDS Section Code") = LastTDSRcvGroup) and ("Customer No." <> CustomerNo) then begin
                                TDSRCVGroupTotal := 0;
                                TDSRCVGroupTotal := TDSRCVGroupTotal + "TDS Certificate Amount";
                                LastTDSRcvGroup := Format("TDS Section Code");
                                CustomerNo := "Customer No.";
                            end else
                                TDSRCVGroupTotal := 0;

                    TDSRCVGroupTotal := TDSRCVGroupTotal + "TDS Certificate Amount";
                    LastTDSRcvGroup := Format("TDS Section Code");
                    CustomerNo := "Customer No.";
                end
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
        if "Cust. Ledger Entry".GetFilter("Cust. Ledger Entry"."Posting Date") <> '' then
            PostingDateFilter := ' for the period of ' + "Cust. Ledger Entry".GetFilter("Cust. Ledger Entry"."Posting Date");
    end;

    var
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        TotalTDSAmount: Decimal;
        TDSRCVGroupTotal: Decimal;
        LastTDSRcvGroup: Text[30];
        CustomerNo: Code[20];
        FinancialYear: Text[30];
        PostingDateFilter: Text[150];
        PreCertificateNo: Code[20];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        TDS_Cert__Receivable_GroupCaptionLbl: Label 'TDS Section';
        Cust__Ledger_Entry__TDS_Certificate_Rcpt_Date_CaptionLbl: Label 'TDS Certificate Rcpt Date';
        Certificate_TDS_Amount__Rs__CaptionLbl: Label 'Certificate TDS Amount (Rs.)';
        Customer_NameCaptionLbl: Label 'Customer Name';
        Customer_AddressCaptionLbl: Label 'Customer Address';
        TDS_Cert__Received_Group_Total__Rs__CaptionLbl: Label 'TDS Cert. Received Total (Rs.)';
        Financial_YearCaptionLbl: Label 'Financial Year';
        Total_CaptionLbl: Label 'Total ';
        Summary_of_TDS_Certificate_Received_from_Customer_CaptionLbl: Label 'Summary of TDS Certificate Received from Customer %1', Comment = '%1 will be replaced with the posting datefilter';
}
