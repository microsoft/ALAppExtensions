// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Foundation.Company;

report 18869 "TCS Challan Register"
{
    DefaultLayout = RDLC;
    RDLCLayout = './TCSReturnAndSettlement/src/Challan-Register/report/rdlc/TCSChallanRegister.rdl';
    Caption = 'TCS Challan Register';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("TCS Challan Register"; "TCS Challan Register")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = Quarter, "Financial Year", "TCS Nature of Collection";

            column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo())
            {
            }
            column(USERID; UserID())
            {
            }
            column(TCS_Challan_Register__GETFILTERS; GetFilters())
            {
            }
            column(TCS_Challan_Register__Challan_No__; "Challan No.")
            {
            }
            column(TCS_Challan_Register__Challan_Date_; Format("Challan Date"))
            {
            }
            column(TCS_Challan_Register__BSR_Code_; "BSR Code")
            {
            }
            column(TCS_Challan_Register__TCS_Interest_Amount_; "TCS Interest Amount")
            {
            }
            column(TCS_Challan_Register__TCS_Others_; "TCS Others")
            {
            }
            column(TCS_Challan_Register__Paid_By_Book_Entry_; Format("Paid By Book Entry"))
            {
            }
            column(TCS_Challan_Register__Pay_TCS_Document_No__; "Pay TCS Document No.")
            {
            }
            column(TCS_Challan_Register__Total_TCS_Amount_; "Total TCS Amount")
            {
            }
            column(TCS_Challan_Register__Total_Surcharge_Amount_; "Total Surcharge Amount")
            {
            }
            column(Total_eCess_Amount_____Total_SHE_Cess_Amount__; ("Total eCess Amount" + "Total SHE Cess Amount"))
            {
            }
            column(ABS__Total_Invoice_Amount__; ABS("Total Invoice Amount"))
            {
            }
            column(TCS_Challan_Register__Check___DD_No__; "Check / DD No.")
            {
            }
            column(TCS_Challan_Register__TCS_Payment_Date_; "TCS Payment Date")
            {
            }
            column(TCS_Challan_Register__Bank_Name_; "Bank Name")
            {
            }
            column(TCS_Challan_Register__TCS_Interest_Amount__Control1500000; "TCS Interest Amount")
            {
            }
            column(TCS_Challan_Register__TCS_Others__Control1500007; "TCS Others")
            {
            }
            column(TCS_Challan_Register__Total_TCS_Amount__Control1500008; "Total TCS Amount")
            {
            }
            column(TCS_Challan_Register__Total_Surcharge_Amount__Control1500009; "Total Surcharge Amount")
            {
            }
            column(Total_eCess_Amount_____Total_SHE_Cess_Amount___Control1500010; ("Total eCess Amount" + "Total SHE Cess Amount"))
            {
                AutoCalcField = true;
            }
            column(InvoiceAmount; InvoiceAmount)
            {
            }
            column(TCS_Challan_Register_Entry_No_; "Entry No.")
            {
            }
            column(TCS_Challan_RegisterCaption; TCS_Challan_RegisterCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(TCS_Challan_Register__Challan_No__Caption; FieldCaption("Challan No."))
            {
            }
            column(TCS_Challan_Register__Challan_Date_Caption; TCS_Challan_Register__Challan_Date_CaptionLbl)
            {
            }
            column(TCS_Challan_Register__BSR_Code_Caption; FieldCaption("BSR Code"))
            {
            }
            column(TCS_Challan_Register__Bank_Name_Caption; FieldCaption("Bank Name"))
            {
            }
            column(TCS_Challan_Register__TCS_Interest_Amount_Caption; FieldCaption("TCS Interest Amount"))
            {
            }
            column(TCS_Challan_Register__TCS_Others_Caption; FieldCaption("TCS Others"))
            {
            }
            column(TCS_Challan_Register__Paid_By_Book_Entry_Caption; TCS_Challan_Register__Paid_By_Book_Entry_CaptionLbl)
            {
            }
            column(TCS_Challan_Register__Pay_TCS_Document_No__Caption; FieldCaption("Pay TCS Document No."))
            {
            }
            column(TCS_Challan_Register__Total_TCS_Amount_Caption; FieldCaption("Total TCS Amount"))
            {
            }
            column(TCS_Challan_Register__Total_Surcharge_Amount_Caption; FieldCaption("Total Surcharge Amount"))
            {
            }
            column(Total_eCess_AmountCaption; Total_eCess_AmountCaptionLbl)
            {
            }
            column(Total_Invoice_AmountCaption; Total_Invoice_AmountCaptionLbl)
            {
            }
            column(TCS_Challan_Register__TCS_Payment_Date_Caption; FieldCaption("TCS Payment Date"))
            {
            }
            column(TCS_Challan_Register__Check___DD_No__Caption; TCS_Challan_Register__Check___DD_No__CaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                InvoiceAmount += Abs("Total Invoice Amount");
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get();
            end;
        }
    }

    var
        CompanyInformation: Record "Company Information";
        InvoiceAmount: Decimal;
        TCS_Challan_RegisterCaptionLbl: Label 'TCS Challan Register';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        TCS_Challan_Register__Challan_Date_CaptionLbl: Label 'Challan Date';
        TCS_Challan_Register__Paid_By_Book_Entry_CaptionLbl: Label 'Paid By Book Entry';
        Total_eCess_AmountCaptionLbl: Label 'Total eCess Amount';
        Total_Invoice_AmountCaptionLbl: Label 'Total Invoice Amount';
        TCS_Challan_Register__Check___DD_No__CaptionLbl: Label 'Cheque No.';
        TotalCaptionLbl: Label 'Total';
}
