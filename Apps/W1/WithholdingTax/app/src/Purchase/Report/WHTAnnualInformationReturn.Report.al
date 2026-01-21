// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;
using System.Utilities;

report 6785 "WHT Annual Information Return"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WHTAnnualInformationReturn.rdlc';
    Caption = 'Annual Information Return Withholding Tax';

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(CI__Post_Code_; CI."Post Code")
            {
            }
            column(CI__Phone_No__; CI."Phone No.")
            {
            }
            column(CI__Industrial_Classification_; CI."Industrial Classification")
            {
            }
            column(CI_Address; CI.Address)
            {
            }
            column(CI_Name; CI.Name)
            {
            }
            column(CI__RDO_Code_; CI."WHT RDO Code")
            {
            }
            column(AmtNov; AmtNov)
            {
            }
            column(AmtDec; AmtDec)
            {
            }
            column(AmtOct; AmtOct)
            {
            }
            column(AmtSept; AmtSept)
            {
            }
            column(AmtAug; AmtAug)
            {
            }
            column(AmtJuly; AmtJuly)
            {
            }
            column(AmtJune; AmtJune)
            {
            }
            column(AmtMay; AmtMay)
            {
            }
            column(AmtApril; AmtApril)
            {
            }
            column(AmtMarch; AmtMarch)
            {
            }
            column(AmtFeb; AmtFeb)
            {
            }
            column(AmtJan; AmtJan)
            {
            }
            column(CI__VAT_Registration_No__; CI."VAT Registration No.")
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(DMY2DATE_1_1_CurrYear_; Format(DMY2Date(1, 1, CurrYear)))
            {
            }
            column(DMY2DATE_31_12_CurrYear_; Format(DMY2Date(31, 12, CurrYear)))
            {
            }
            column(Integer_Number; Number)
            {
            }
            column(Zip_CodeCaption; Zip_CodeCaptionLbl)
            {
            }
            column(Telephone_NoCaption; Telephone_NoCaptionLbl)
            {
            }
            column(BIR_Form_No____1604___ECaption; BIR_Form_No____1604___ECaptionLbl)
            {
            }
            column(DataItem1500006; Annual_Information_Return_of_Creditable_Income_Taxes_WithheldCaptionLbl)
            {
            }
            column(Line_of_BusinessCaption; Line_of_BusinessCaptionLbl)
            {
            }
            column(RDO_CodeCaption; RDO_CodeCaptionLbl)
            {
            }
            column(AddressCaption; AddressCaptionLbl)
            {
            }
            column(JANCaption; JANCaptionLbl)
            {
            }
            column(FEBCaption; FEBCaptionLbl)
            {
            }
            column(MARCaption; MARCaptionLbl)
            {
            }
            column(APRCaption; APRCaptionLbl)
            {
            }
            column(MAYCaption; MAYCaptionLbl)
            {
            }
            column(JUNCaption; JUNCaptionLbl)
            {
            }
            column(JULCaption; JULCaptionLbl)
            {
            }
            column(AUGCaption; AUGCaptionLbl)
            {
            }
            column(SEPTCaption; SEPTCaptionLbl)
            {
            }
            column(OCTCaption; OCTCaptionLbl)
            {
            }
            column(NOVCaption; NOVCaptionLbl)
            {
            }
            column(DECCaption; DECCaptionLbl)
            {
            }
            column(Withholding_agent_nameCaption; Withholding_agent_nameCaptionLbl)
            {
            }
            column(TIN_No_Caption; TIN_No_CaptionLbl)
            {
            }
            column(For_the_YearCaption; For_the_YearCaptionLbl)
            {
            }
            column(MonthCaption; MonthCaptionLbl)
            {
            }
            column(Date_of_RemittanceCaption; Date_of_RemittanceCaptionLbl)
            {
            }
            column(Name_of_Bank_Bank_Code__ROR_No__IF_ANYCaption; Name_of_Bank_Bank_Code__ROR_No__IF_ANYCaptionLbl)
            {
            }
            column(Taxes_WithHeldCaption; Taxes_WithHeldCaptionLbl)
            {
            }
            column(PenaltiesCaption; PenaltiesCaptionLbl)
            {
            }
            column(Total_Amount_RemittedCaption; Total_Amount_RemittedCaptionLbl)
            {
            }

            trigger OnPreDataItem()
            begin
                CI.Get();
                if ForYear > 1900 then begin
                    ForMonth := 1;
                    CurrYear := ForYear;
                end else
                    Error(EnterFullYearLbl);
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 1, CurrYear), DMY2Date(31, 1, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtJan := AmtJan + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 2, CurrYear), CalcDate('<CM>', DMY2Date(1, 2, CurrYear)));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtFeb := AmtFeb + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 3, CurrYear), DMY2Date(31, 3, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtMarch := AmtMarch + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 4, CurrYear), DMY2Date(30, 4, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtApril := AmtApril + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 5, CurrYear), DMY2Date(31, 5, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtMay := AmtMay + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 6, CurrYear), DMY2Date(30, 6, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtJune := AmtJune + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 7, CurrYear), DMY2Date(31, 7, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtJuly := AmtJuly + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 8, CurrYear), DMY2Date(31, 8, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtAug := AmtAug + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 9, CurrYear), DMY2Date(30, 9, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtSept := AmtSept + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 10, CurrYear), DMY2Date(31, 10, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtOct := AmtOct + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 11, CurrYear), DMY2Date(30, 11, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtNov := AmtNov + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
                WHTEntry1.Reset();
                WHTEntry1.SetFilter("Applies-to Entry No.", '<>0');
                WHTEntry1.SetRange("Transaction Type", WHTEntry1."Transaction Type"::Purchase);
                WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, 12, CurrYear), DMY2Date(31, 12, CurrYear));
                if WHTEntry1.FindSet() then
                    repeat
                        AmtDec := AmtDec + WHTEntry1."Amount (LCY)";
                    until WHTEntry1.Next() = 0;
            end;
        }
        dataitem("<WHTEntry3>"; "Withholding Tax Entry")
        {
            DataItemTableView = sorting("Bill-to/Pay-to No.", "Withholding Tax Revenue Type", "Wthldg. Tax Prod. Post. Group") order(ascending) where("Transaction Type" = const(Purchase), "Applies-to Entry No." = filter(<> 0), "Withholding Tax %" = const(0));
            column(WHT_Entry___WHT_Prod__Posting_Group_; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(WHT_Entry___Bill_to_Pay_to_No__; "Bill-to/Pay-to No.")
            {
            }
            column(WHT_Entry___WHT_Revenue_Type_; "Withholding Tax Revenue Type")
            {
            }
            column(WHTProdPostGrp; WHTProdPostGrp)
            {
            }
            column(WHTEntry3___WHT_Revenue_Type_; "Withholding Tax Revenue Type")
            {
            }
            column(WHTEntry3___Base__LCY__; "Base (LCY)")
            {
            }
            column(WHTEntry3___WHT_Prod__Posting_Group_; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(VendName; VendName)
            {
            }
            column(CI__VAT_Registration_No___Control1500060; CI."VAT Registration No.")
            {
            }
            column(i; i)
            {
            }
            column(WHTEntry3__Entry_No_; "Entry No.")
            {
            }
            column(WHT_Revenue_TypeCaption; WHT_Revenue_TypeCaptionLbl)
            {
            }
            column(Applied_AmountCaption; Applied_AmountCaptionLbl)
            {
            }
            column(Nature_of_Income_PaymentCaption; Nature_of_Income_PaymentCaptionLbl)
            {
            }
            column(Name_of_PayeeCaption; Name_of_PayeeCaptionLbl)
            {
            }
            column(TIN_No_Caption_Control1500054; TIN_No_Caption_Control1500054Lbl)
            {
            }
            column(Seq_NoCaption; Seq_NoCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Wthldg. Tax Prod. Post. Group" <> WHTProdPostGrp) or (ATC <> "Withholding Tax Revenue Type") or
                   (VendNo <> "Bill-to/Pay-to No.")
                then
                    i := i + 1;
                Vend.Get("Bill-to/Pay-to No.");
                VendName := Vend.Name;
                WHTProdPostGrp := "Wthldg. Tax Prod. Post. Group";
                ATC := "Withholding Tax Revenue Type";
                VendNo := "Bill-to/Pay-to No.";
            end;

            trigger OnPreDataItem()
            begin
                CI.Get();
                SetFilter("Posting Date", '%1..%2', DMY2Date(1, 1, CurrYear), DMY2Date(31, 12, CurrYear));
            end;
        }
        dataitem("WHT Entry"; "Withholding Tax Entry")
        {
            DataItemTableView = sorting("Bill-to/Pay-to No.", "Withholding Tax Revenue Type", "Wthldg. Tax Prod. Post. Group") where("Transaction Type" = const(Purchase), Base = filter(<> 0), "Withholding Tax %" = filter(<> 0));
            PrintOnlyIfDetail = false;
            column(WHT_Entry_Bill_to_Pay_to__No; "Bill-to/Pay-to No.")
            {
            }
            column(WHT_Entry_Revenue; "Withholding Tax Revenue Type")
            {
            }
            column(WHT_Entry_Posting; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(WHT_Entry__WHT_Bus__Posting_Group_; "Wthldg. Tax Bus. Post. Group")
            {
            }
            column(WHT_Entry__Base__LCY__; "Base (LCY)")
            {
            }
            column(WHT_Entry__WHT___; "Withholding Tax %")
            {
            }
            column(WHT_Entry__Amount__LCY__; "Amount (LCY)")
            {
            }
            column(WHT_Entry__Amount__LCY___Control1500080; "Amount (LCY)")
            {
            }
            column(WHT____rcount; "Withholding Tax %" / rcount)
            {
            }
            column(WHT_Entry__Base__LCY___Control1500082; "Base (LCY)")
            {
            }
            column(CI__VAT_Registration_No___Control1500083; CI."VAT Registration No.")
            {
            }
            column(VendName_Control1500084; VendName)
            {
            }
            column(WHT_Entry__WHT_Revenue_Type_; "Withholding Tax Revenue Type")
            {
            }
            column(WHT_Entry__WHT_Prod__Posting_Group_; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(j; j)
            {
            }
            column(WHT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(WHT_Entry__WHT_Revenue_Type_Caption; FieldCaption("Withholding Tax Revenue Type"))
            {
            }
            column(WHT_Entry__Base__LCY___Control1500082Caption; FieldCaption("Base (LCY)"))
            {
            }
            column(WHT____rcountCaption; WHT____rcountCaptionLbl)
            {
            }
            column(WHT_Entry__Amount__LCY___Control1500080Caption; FieldCaption("Amount (LCY)"))
            {
            }
            column(Seq_NoCaption_Control1500072; Seq_NoCaption_Control1500072Lbl)
            {
            }
            column(TIN_No_Caption_Control1500073; TIN_No_Caption_Control1500073Lbl)
            {
            }
            column(Name_of_PayeeCaption_Control1500074; Name_of_PayeeCaption_Control1500074Lbl)
            {
            }
            column(Nature_of_Income_PaymentCaption_Control1500075; Nature_of_Income_PaymentCaption_Control1500075Lbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Wthldg. Tax Prod. Post. Group" <> WHTProdPostGrp) or (ATC <> "Withholding Tax Revenue Type") or
                   (VendNo <> "Bill-to/Pay-to No.")
                then
                    j := j + 1;

                Vend.Get("Bill-to/Pay-to No.");
                VendName := Vend.Name;
                WHTProdPostGrp := "Wthldg. Tax Prod. Post. Group";
                ATC := "Withholding Tax Revenue Type";
                VendNo := "Bill-to/Pay-to No.";

                WHTEntry1.Reset();
                WHTEntry1.Copy("WHT Entry");
                WHTEntry1.SetRange("Wthldg. Tax Prod. Post. Group", "Wthldg. Tax Prod. Post. Group");
                WHTEntry1.SetRange("Bill-to/Pay-to No.", "Bill-to/Pay-to No.");
                WHTEntry1.SetRange("Withholding Tax Revenue Type", "Withholding Tax Revenue Type");
                if WHTEntry1.FindSet() then
                    rcount := WHTEntry1.Count();
                if rcount = 0 then
                    rcount := 1;
            end;

            trigger OnPreDataItem()
            begin
                LastFieldNo := FieldNo("Withholding Tax Revenue Type");
                SetFilter("Posting Date", '%1..%2', DMY2Date(1, 1, CurrYear), DMY2Date(31, 12, CurrYear));
                WHTProdPostGrp := '';
                ATC := '';
                VendNo := '';
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
                    field(ForYear; ForYear)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'For Year';
                        ToolTip = 'Specifies the year that the report applies to.';
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

    var
        CI: Record "Company Information";
        WHTEntry1: Record "Withholding Tax Entry";
        Vend: Record Vendor;
        LastFieldNo: Integer;
        rcount: Integer;
        ForMonth: Integer;
        AmtJan: Decimal;
        AmtFeb: Decimal;
        AmtMarch: Decimal;
        AmtApril: Decimal;
        AmtMay: Decimal;
        AmtJune: Decimal;
        AmtJuly: Decimal;
        AmtAug: Decimal;
        AmtSept: Decimal;
        AmtOct: Decimal;
        AmtNov: Decimal;
        AmtDec: Decimal;
        CurrYear: Integer;
        VendName: Text[30];
        ForYear: Integer;
        i: Integer;
        j: Integer;
        WHTProdPostGrp: Code[20];
        ATC: Code[10];
        VendNo: Code[20];
        EnterFullYearLbl: Label 'Enter the full year for which you want the report to be generated. Eg 2001';
        Zip_CodeCaptionLbl: Label 'Zip Code';
        Telephone_NoCaptionLbl: Label 'Telephone No';
        BIR_Form_No____1604___ECaptionLbl: Label 'BIR Form No.   1604 - E';
        Annual_Information_Return_of_Creditable_Income_Taxes_WithheldCaptionLbl: Label 'Annual Information Return of Creditable Income Taxes Withheld (Expanded)/Income Payments Exempt from Withholding Tax';
        Line_of_BusinessCaptionLbl: Label 'Line of Business';
        RDO_CodeCaptionLbl: Label 'RDO Code';
        AddressCaptionLbl: Label 'Address';
        JANCaptionLbl: Label 'JAN';
        FEBCaptionLbl: Label 'FEB';
        MARCaptionLbl: Label 'MAR';
        APRCaptionLbl: Label 'APR';
        MAYCaptionLbl: Label 'MAY';
        JUNCaptionLbl: Label 'JUN';
        JULCaptionLbl: Label 'JUL';
        AUGCaptionLbl: Label 'AUG';
        SEPTCaptionLbl: Label 'SEPT';
        OCTCaptionLbl: Label 'OCT';
        NOVCaptionLbl: Label 'NOV';
        DECCaptionLbl: Label 'DEC';
        Withholding_agent_nameCaptionLbl: Label 'Withholding agent name';
        TIN_No_CaptionLbl: Label 'TIN No.';
        For_the_YearCaptionLbl: Label 'For the Year';
        MonthCaptionLbl: Label 'Month';
        Date_of_RemittanceCaptionLbl: Label 'Date of Remittance';
        Name_of_Bank_Bank_Code__ROR_No__IF_ANYCaptionLbl: Label 'Name of Bank/Bank Code/ ROR No. IF ANY';
        Taxes_WithHeldCaptionLbl: Label 'Taxes WithHeld';
        PenaltiesCaptionLbl: Label 'Penalties';
        Total_Amount_RemittedCaptionLbl: Label 'Total Amount Remitted';
        WHT_Revenue_TypeCaptionLbl: Label 'WHT Revenue Type';
        Applied_AmountCaptionLbl: Label 'Applied Amount';
        Nature_of_Income_PaymentCaptionLbl: Label 'Nature of Income Payment';
        Name_of_PayeeCaptionLbl: Label 'Name of Payee';
        TIN_No_Caption_Control1500054Lbl: Label 'TIN No.';
        Seq_NoCaptionLbl: Label 'Seq No';
        WHT____rcountCaptionLbl: Label 'WHT %';
        Seq_NoCaption_Control1500072Lbl: Label 'Seq No';
        TIN_No_Caption_Control1500073Lbl: Label 'TIN No.';
        Name_of_PayeeCaption_Control1500074Lbl: Label 'Name of Payee';
        Nature_of_Income_PaymentCaption_Control1500075Lbl: Label 'Nature of Income Payment';
}

