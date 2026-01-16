// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.Foundation.Company;
using Microsoft.WithholdingTax;

report 6787 "WHT Monthly Remittance Return"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WHTMonthlyRemittanceReturn.rdlc';
    Caption = 'Monthly Remittance Return WHT';

    dataset
    {
        dataitem("WHT Entry"; "Withholding Tax Entry")
        {
            DataItemTableView = sorting("Withholding Tax Revenue Type", "Posting Date") where("Transaction Type" = const(Purchase), "Withholding Tax %" = filter(<> 0));
            RequestFilterFields = "Withholding Tax Revenue Type", "Posting Date";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(FORMAT_USERID_; Format(UserId))
            {
            }
            column(CI__Industrial_Classification_; CI."Industrial Classification")
            {
            }
            column(CI__Phone_No__; CI."Phone No.")
            {
            }
            column(CI__Post_Code_; CI."Post Code")
            {
            }
            column(CI_Name; CI.Name)
            {
            }
            column(CI_Address; CI.Address)
            {
            }
            column(CI__VAT_Registration_No__; CI."VAT Registration No.")
            {
            }
            column(MonthName; MonthName)
            {
            }
            column(CI__RDO_Code_; CI."WHT RDO Code")
            {
            }
            column(WHT_Entry__WHT_Bus__Posting_Group_; "Wthldg. Tax Bus. Post. Group")
            {
            }
            column(WHT_Entry__WHT_Prod__Posting_Group_; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(WHT_Entry__WHT_Revenue_Type_; "Withholding Tax Revenue Type")
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
            column(WHT_Entry__WHT_Bus__Posting_Group__Control1500035; "Wthldg. Tax Bus. Post. Group")
            {
            }
            column(WHT_Entry__Base__LCY___Control1500036; "Base (LCY)")
            {
            }
            column(WHT____rcount; "Withholding Tax %" / rcount)
            {
            }
            column(ABS__Amount__LCY___; Abs("Amount (LCY)"))
            {
            }
            column(WHT_Entry__WHT_Revenue_Type__Control1500039; "Withholding Tax Revenue Type")
            {
            }
            column(WHT_Entry__WHT_Prod__Posting_Group__Control1500040; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(ABS__Amount__LCY____Control1500042; Abs("Amount (LCY)"))
            {
            }
            column(ABS__Amount__LCY____Control1500044; Abs("Amount (LCY)"))
            {
            }
            column(ABS__Amount__LCY____Control1500046; Abs("Amount (LCY)"))
            {
            }
            column(WHT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Telephone_NoCaption; Telephone_NoCaptionLbl)
            {
            }
            column(Zip_CodeCaption; Zip_CodeCaptionLbl)
            {
            }
            column(Line_of_BusinessCaption; Line_of_BusinessCaptionLbl)
            {
            }
            column(For_the_MonthCaption; For_the_MonthCaptionLbl)
            {
            }
            column(TIN_No_Caption; TIN_No_CaptionLbl)
            {
            }
            column(Withholding_agent_nameCaption; Withholding_agent_nameCaptionLbl)
            {
            }
            column(AddressCaption; AddressCaptionLbl)
            {
            }
            column(RDO_CodeCaption; RDO_CodeCaptionLbl)
            {
            }
            column(BIR_Form_No_____1601___ECaption; BIR_Form_No_____1601___ECaptionLbl)
            {
            }
            column(Monthly_Remittance_Return_of_Creditable_Income_Taxes_Withheld__Expanded_Caption; Monthly_Remittance_Return_of_Creditable_Income_Taxes_Withheld__Expanded_CaptionLbl)
            {
            }
            column(WHT_Entry__WHT_Bus__Posting_Group_Caption; FieldCaption("Wthldg. Tax Bus. Post. Group"))
            {
            }
            column(WHT_Entry__WHT_Prod__Posting_Group_Caption; FieldCaption("Wthldg. Tax Prod. Post. Group"))
            {
            }
            column(WHT_Entry__WHT_Revenue_Type_Caption; FieldCaption("Withholding Tax Revenue Type"))
            {
            }
            column(WHT_Entry__Base__LCY__Caption; FieldCaption("Base (LCY)"))
            {
            }
            column(WHT_Entry__WHT___Caption; FieldCaption("Withholding Tax %"))
            {
            }
            column(WHT_Entry__Amount__LCY__Caption; FieldCaption("Amount (LCY)"))
            {
            }
            column(Total_Tax_Required_to_be_withheld_or_remittedCaption; Total_Tax_Required_to_be_withheld_or_remittedCaptionLbl)
            {
            }
            column(Tax_Still_Due__Overremittance_Caption; Tax_Still_Due__Overremittance_CaptionLbl)
            {
            }
            column(Total_Amount_Still_Due__Overremittance_Caption; Total_Amount_Still_Due__Overremittance_CaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                WHTEntry1.Reset();
                WHTEntry1.Copy("WHT Entry");
                WHTEntry1.SetRange("Withholding Tax Revenue Type", "Withholding Tax Revenue Type");
                if WHTEntry1.FindFirst() then
                    rcount := WHTEntry1.Count();
                if rcount = 0 then
                    rcount := 1;
            end;

            trigger OnPreDataItem()
            begin
                LastFieldNo := FieldNo("Withholding Tax Revenue Type");
                SetRange("Transaction Type", "Transaction Type"::Purchase);
                if GetFilter("Posting Date") <> '' then
                    ForMonth := Date2DMY(GetRangeMin("Posting Date"), 2);

                case ForMonth of
                    1:
                        MonthName := 'January';
                    2:
                        MonthName := 'February';
                    3:
                        MonthName := 'March';
                    4:
                        MonthName := 'April';
                    5:
                        MonthName := 'May';
                    6:
                        MonthName := 'June';
                    7:
                        MonthName := 'July';
                    8:
                        MonthName := 'August';
                    9:
                        MonthName := 'September';
                    10:
                        MonthName := 'October';
                    11:
                        MonthName := 'November';
                    12:
                        MonthName := 'December';
                end;

                CI.Get();
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

    var
        CI: Record "Company Information";
        WHTEntry1: Record "Withholding Tax Entry";
        LastFieldNo: Integer;
        rcount: Integer;
        ForMonth: Integer;
        MonthName: Text[20];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Telephone_NoCaptionLbl: Label 'Telephone No';
        Zip_CodeCaptionLbl: Label 'Zip Code';
        Line_of_BusinessCaptionLbl: Label 'Line of Business';
        For_the_MonthCaptionLbl: Label 'For the Month';
        TIN_No_CaptionLbl: Label 'TIN No.';
        Withholding_agent_nameCaptionLbl: Label 'Withholding agent name';
        AddressCaptionLbl: Label 'Address';
        RDO_CodeCaptionLbl: Label 'RDO Code';
        BIR_Form_No_____1601___ECaptionLbl: Label 'BIR Form No.    1601 - E';
        Monthly_Remittance_Return_of_Creditable_Income_Taxes_Withheld__Expanded_CaptionLbl: Label 'Monthly Remittance Return of Creditable Income Taxes Withheld (Expanded)';
        Total_Tax_Required_to_be_withheld_or_remittedCaptionLbl: Label 'Total Tax Required to be withheld or remitted';
        Tax_Still_Due__Overremittance_CaptionLbl: Label 'Tax Still Due/(Overremittance)';
        Total_Amount_Still_Due__Overremittance_CaptionLbl: Label 'Total Amount Still Due/(Overremittance)';
}

