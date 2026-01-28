// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.WithholdingTax;

report 6790 "Withholding Tax Certificate"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WIthholdingTaxCertificate.rdlc';
    Caption = 'Withholding Tax Certificate';

    dataset
    {
        dataitem("WHT Entry"; "Withholding Tax Entry")
        {
            DataItemTableView = sorting("Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type") where("Document Type" = filter(Payment | Refund));
            RequestFilterFields = "Transaction Type", "Bill-to/Pay-to No.", "Original Document No.";
            column(Text1500000; Text1500000Lbl)
            {
            }
            column(CompanyAddr_5_; CompanyAddr[5])
            {
            }
            column(CompanyAddr_4_; CompanyAddr[4])
            {
            }
            column(CompanyAddr_3_; CompanyAddr[3])
            {
            }
            column(CompanyAddr_2_; CompanyAddr[2])
            {
            }
            column(CompanyAddr_1_; CompanyAddr[1])
            {
            }
            column(CompanyInfo__WHT_Registration_ID_; CompanyInfo."Withholding Tax Reg. ID")
            {
            }
            column(WHT_Entry__WHT_Certificate_No__; "Wthldg. Tax Certificate No.")
            {
            }
            column(PrintPayToVendor; PrintPayToVendor)
            {
            }
            column(VendAddr_7_; VendAddr[7])
            {
            }
            column(VendAddr_6_; VendAddr[6])
            {
            }
            column(VendAddr_5_; VendAddr[5])
            {
            }
            column(VendAddr_4_; VendAddr[4])
            {
            }
            column(VendAddr_3_; VendAddr[3])
            {
            }
            column(VendAddr_2_; VendAddr[2])
            {
            }
            column(VendAddr_1_; VendAddr[1])
            {
            }
            column(Vendor__WHT_Registration_ID_; Vendor."WHT Registered")
            {
            }
            column(PayToVendAddr_1_; PayToVendAddr[1])
            {
            }
            column(PayToVendAddr_7_; PayToVendAddr[7])
            {
            }
            column(PayToVendAddr_2_; PayToVendAddr[2])
            {
            }
            column(PayToVendAddr_4_; PayToVendAddr[4])
            {
            }
            column(PayToVendAddr_5_; PayToVendAddr[5])
            {
            }
            column(PayToVendAddr_6_; PayToVendAddr[6])
            {
            }
            column(PayToVendAddr_3_; PayToVendAddr[3])
            {
            }
            column(PayToVendor__WHT_Registration_ID_; PayToVendor."Withholding Tax Reg. ID")
            {
            }
            column(CheckBox3; CheckBox3)
            {
            }
            column(CheckBox2; CheckBox2)
            {
            }
            column(CheckBox2t; CheckBox2t)
            {
            }
            column(CheckBox1; CheckBox1)
            {
            }
            column(CheckBox53; CheckBox53)
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Report_Line_No_; "Wthldg. Tax Report Line No")
            {
            }
            column(CheckBox3t; CheckBox3t)
            {
            }
            column(CheckBox1s; CheckBox1s)
            {
            }
            column(WHT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(WHT_Registration_IDCaption; WHT_Registration_IDCaptionLbl)
            {
            }
            column(Certificate_of_tax_income_at_the_pointCaption; Certificate_of_tax_income_at_the_pointCaptionLbl)
            {
            }
            column(Rule_no_69_according_to_the_lawCaption; Rule_no_69_according_to_the_lawCaptionLbl)
            {
            }
            column(WHT_Cert__No_Caption; WHT_Cert__No_CaptionLbl)
            {
            }
            column(Tax_payer_at_the_pointCaption; Tax_payer_at_the_pointCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(AddressCaption; AddressCaptionLbl)
            {
            }
            column(vendorCaption; vendorCaptionLbl)
            {
            }
            column(NameCaption_Control1500024; NameCaption_Control1500024Lbl)
            {
            }
            column(AddressCaption_Control1500025; AddressCaption_Control1500025Lbl)
            {
            }
            column(WHT_Registration_IDCaption_Control1500026; WHT_Registration_IDCaption_Control1500026Lbl)
            {
            }
            column(Tax_payee_informationCaption; Tax_payee_informationCaptionLbl)
            {
            }
            column(NameCaption_Control1500036; NameCaption_Control1500036Lbl)
            {
            }
            column(AddressCaption_Control1500037; AddressCaption_Control1500037Lbl)
            {
            }
            column(WHT_Registration_IDCaption_Control1500038; WHT_Registration_IDCaption_Control1500038Lbl)
            {
            }
            column(Por_Ngor_Dor_3Caption; Por_Ngor_Dor_3CaptionLbl)
            {
            }
            column(Por_Ngor_Dor_2Caption; Por_Ngor_Dor_2CaptionLbl)
            {
            }
            column(Por_Ngor_Dor_2_KhorCaption; Por_Ngor_Dor_2_KhorCaptionLbl)
            {
            }
            column(Por_Ngor_Dor_1Caption; Por_Ngor_Dor_1CaptionLbl)
            {
            }
            column(Por_Ngor_Dor_53Caption; Por_Ngor_Dor_53CaptionLbl)
            {
            }
            column(SectionCaption; SectionCaptionLbl)
            {
            }
            column(in_the_form_ofCaption; in_the_form_ofCaptionLbl)
            {
            }
            column(Por_Ngor_Dor_1_Khor_SpecialCaption; Por_Ngor_Dor_1_Khor_SpecialCaptionLbl)
            {
            }
            column(Por_Ngor_Dor_3_KhorCaption; Por_Ngor_Dor_3_KhorCaptionLbl)
            {
            }
            column(Revenue_TypeCaption; Revenue_TypeCaptionLbl)
            {
            }
            column(AmountCaption; AmountCaptionLbl)
            {
            }
            column(WHT_AmountCaption; WHT_AmountCaptionLbl)
            {
            }
            column(DateCaption; DateCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if "Actual Vendor No." <> '' then
                    if "Actual Vendor No." <> "Bill-to/Pay-to No." then begin
                        Vendor.Get("Actual Vendor No.");
                        PrintPayToVendor := true;
                    end else begin
                        Vendor.Get("Bill-to/Pay-to No.");
                        PrintPayToVendor := false;
                    end;
                if "Transaction Type" = "Transaction Type"::Purchase then
                    PayToVendor.Get("Bill-to/Pay-to No.")
                else
                    PaytoCustomer.Get("Bill-to/Pay-to No.");
                FormatAddr.Vendor(VendAddr, Vendor);
                FormatAddr.Vendor(PayToVendAddr, PayToVendor);

                // WHT Report
                WHTPostingSetup.SetRange("Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Bus. Post. Group");
                WHTPostingSetup.SetRange("Wthldg. Tax Prod. Post. Group", "Wthldg. Tax Prod. Post. Group");
                if WHTPostingSetup.FindFirst() then
                    case WHTPostingSetup."Withholding Tax Report" of
                        WHTPostingSetup."Withholding Tax Report"::" ":
                            CheckBox1 := 'X';
                        WHTPostingSetup."Withholding Tax Report"::"Por Ngor Dor 1":
                            CheckBox2 := 'X';
                        WHTPostingSetup."Withholding Tax Report"::"Por Ngor Dor 2":
                            CheckBox3 := 'X';
                        WHTPostingSetup."Withholding Tax Report"::"Por Ngor Dor 3":
                            CheckBox53 := 'X';
                        WHTPostingSetup."Withholding Tax Report"::"Por Ngor Dor 53":
                            CheckBox55 := 'X';
                    end;
            end;

            trigger OnPreDataItem()
            begin
                GLSetup.Get();
                PurchSetup.Get();
                PurchSetup.TestField("Wthldg. Tax Certificate Nos.");
                CompanyInfo.Get();
                FormatAddr.Company(CompanyAddr, CompanyInfo);
                TotalAmountLCY := 0;
                TotalBaseLCY := 0;
                CheckBox1 := '';
                CheckBox2 := '';
                CheckBox3 := '';
                CheckBox53 := '';
                CheckBox55 := '';
            end;
        }
        dataitem("WHT Revenue Types"; "Withholding Tax Revenue Types")
        {
            DataItemTableView = sorting(Sequence);
            column(WHT_Revenue_Types_Description; Description)
            {
            }
            column(WHTAmountLCY; WHTAmountLCY)
            {
            }
            column(WHTBaseLCY; WHTBaseLCY)
            {
            }
            column(WHTDate; Format(WHTDate))
            {
            }
            column(TotalAmountLCY; TotalAmountLCY)
            {
            }
            column(TotalBaseLCY; TotalBaseLCY)
            {
            }
            column(AmtInWords_1______AmtInWords_2_; AmtInWords[1] + ' ' + AmtInWords[2])
            {
            }
            column(WHT_Revenue_Types_Code; Code)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(Amount_In_WordCaption; Amount_In_WordCaptionLbl)
            {
            }
            column(Provident_Fund_Permit_NumberCaption; Provident_Fund_Permit_NumberCaptionLbl)
            {
            }
            column(TotalCaption_Control1500077; TotalCaption_Control1500077Lbl)
            {
            }
            column(BahtCaption; BahtCaptionLbl)
            {
            }
            column(others__please_indicate_Caption; others__please_indicate_CaptionLbl)
            {
            }
            column(Deduct_tax_at_the_pointCaption; Deduct_tax_at_the_pointCaptionLbl)
            {
            }
            column(Issue_tax_foreverCaption; Issue_tax_foreverCaptionLbl)
            {
            }
            column(Issue_tax_only_onceCaption; Issue_tax_only_onceCaptionLbl)
            {
            }
            column(PayerCaption; PayerCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            var
                WithholdingTaxInvoiceMgmt: Codeunit "Withholding Tax Invoice Mgmt.";
                WHTManagement: Codeunit "Withholding Tax Mgmt.";
            begin
                if not "WHT Entry".FindFirst() then
                    CurrReport.Skip();
                WHTAmountLCY := 0;
                WHTBaseLCY := 0;
                WHTDate := 0D;
                WHTEntry2.CopyFilters("WHT Entry");
                WHTEntry2.SetRange("Withholding Tax Revenue Type", Code);
                WHTEntry2.SetRange("Document Type", WHTEntry2."Document Type"::Payment);
                if WHTEntry2.FindSet() then
                    repeat
                        WHTAmountLCY := WHTAmountLCY + WHTEntry2."Amount (LCY)";
                        WHTBaseLCY := WHTBaseLCY + WHTEntry2."Base (LCY)";
                        WHTDate := WHTEntry2."Posting Date";
                    until WHTEntry2.Next() = 0;
                if GLSetup."Round Amount Wthldg. Tax Calc" then
                    WHTAmountLCY := WHTManagement.RoundWithholdingTaxAmount(WHTAmountLCY);
                TotalAmountLCY := TotalAmountLCY + WHTAmountLCY;
                TotalBaseLCY := TotalBaseLCY + WHTBaseLCY;

                if GlobalLanguage = 1054 then begin
                    WithholdingTaxInvoiceMgmt.InitTextVariable();
                    WithholdingTaxInvoiceMgmt.FormatNoText(AmtInWords, TotalAmountLCY, "WHT Entry"."Currency Code");
                end;
            end;

            trigger OnPreDataItem()
            begin
                WHTEntry2.Reset();
                WHTEntry2.SetCurrentKey("Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type");
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
        if ("WHT Entry".GetFilter("Original Document No.") = '') or
           (("WHT Entry".GetFilter("Bill-to/Pay-to No.") = '') and
            ("WHT Entry".GetFilter("Actual Vendor No.") = ''))
        then
            Error(BillToVendorLbl);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        Vendor: Record Vendor;
        PurchSetup: Record "Purchases & Payables Setup";
        WHTEntry2: Record "Withholding Tax Entry";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        PaytoCustomer: Record Customer;
        PayToVendor: Record Vendor;
        FormatAddr: Codeunit "Format Address";
        TotalAmountLCY: Decimal;
        TotalBaseLCY: Decimal;
        WHTAmountLCY: Decimal;
        WHTBaseLCY: Decimal;
        WHTDate: Date;
        VendAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        AmtInWords: array[2] of Text[200];
        CheckBox1: Code[10];
        CheckBox2: Code[10];
        CheckBox1s: Code[10];
        CheckBox2t: Code[10];
        CheckBox3: Code[10];
        CheckBox3t: Code[10];
        CheckBox53: Code[10];
        CheckBox55: Code[10];
        PayToVendAddr: array[8] of Text[100];
        PrintPayToVendor: Boolean;
        BillToVendorLbl: Label 'Please enter Bill-to/Pay-to Vendor No. and Original Document No. ';
        Text1500000Lbl: Label 'Withholding Certificate';
        WHT_Registration_IDCaptionLbl: Label 'WHT Registration ID';
        Certificate_of_tax_income_at_the_pointCaptionLbl: Label 'Certificate of tax income at the point';
        Rule_no_69_according_to_the_lawCaptionLbl: Label ' Rule no.69 according to the law';
        WHT_Cert__No_CaptionLbl: Label 'WHT Cert. No.';
        Tax_payer_at_the_pointCaptionLbl: Label 'Tax payer at the point';
        NameCaptionLbl: Label 'Name';
        AddressCaptionLbl: Label 'Address';
        vendorCaptionLbl: Label 'Vendor';
        NameCaption_Control1500024Lbl: Label 'Name';
        AddressCaption_Control1500025Lbl: Label 'Address';
        WHT_Registration_IDCaption_Control1500026Lbl: Label 'WHT Registration ID';
        Tax_payee_informationCaptionLbl: Label 'Tax payee information';
        NameCaption_Control1500036Lbl: Label 'Name';
        AddressCaption_Control1500037Lbl: Label 'Address';
        WHT_Registration_IDCaption_Control1500038Lbl: Label 'WHT Registration ID';
        Por_Ngor_Dor_3CaptionLbl: Label 'Por Ngor Dor 3';
        Por_Ngor_Dor_2CaptionLbl: Label 'Por Ngor Dor 2';
        Por_Ngor_Dor_2_KhorCaptionLbl: Label 'Por Ngor Dor 2 Khor';
        Por_Ngor_Dor_1CaptionLbl: Label 'Por Ngor Dor 1';
        Por_Ngor_Dor_53CaptionLbl: Label 'Por Ngor Dor 53';
        SectionCaptionLbl: Label 'Section';
        in_the_form_ofCaptionLbl: Label 'In the form of.';
        Por_Ngor_Dor_1_Khor_SpecialCaptionLbl: Label 'Por Ngor Dor 1 Khor Special';
        Por_Ngor_Dor_3_KhorCaptionLbl: Label 'Por Ngor Dor 3 Khor';
        Revenue_TypeCaptionLbl: Label 'Revenue Type';
        AmountCaptionLbl: Label 'Amount';
        WHT_AmountCaptionLbl: Label 'WHT Amount';
        DateCaptionLbl: Label 'Date';
        TotalCaptionLbl: Label 'Total';
        Amount_In_WordCaptionLbl: Label 'Amount In Word';
        Provident_Fund_Permit_NumberCaptionLbl: Label 'Provident Fund Permit Number';
        TotalCaption_Control1500077Lbl: Label 'Total';
        BahtCaptionLbl: Label 'Baht';
        others__please_indicate_CaptionLbl: Label 'Others (please indicate)';
        Deduct_tax_at_the_pointCaptionLbl: Label 'Deduct tax at the point';
        Issue_tax_foreverCaptionLbl: Label 'Issue tax forever';
        Issue_tax_only_onceCaptionLbl: Label 'Issue tax only once';
        PayerCaptionLbl: Label 'Payer';
}

