// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;

report 6786 "WHT Certificate Creditable tax"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'src\Purchase\Report\WHTCertificateCreditabletax.rdlc';
    Caption = 'Certificate of Creditable tax';

    dataset
    {
        dataitem("WHT Entry"; "Withholding Tax Entry")
        {
            DataItemTableView = sorting("Bill-to/Pay-to No.", "Withholding Tax Revenue Type", "Wthldg. Tax Prod. Post. Group") order(ascending) where("Transaction Type" = filter(Purchase));
            RequestFilterFields = "Bill-to/Pay-to No.", "Withholding Tax Revenue Type";
            column(USERID; UserId)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(CI__Post_Code_; CompanyInformation."Post Code")
            {
            }
            column(CI_Name; CompanyInformation.Name)
            {
            }
            column(VendName; VendName)
            {
            }
            column(VendPostCode; VendPostCode)
            {
            }
            column(CI_Address; CompanyInformation.Address)
            {
            }
            column(VendAddress; VendAddress)
            {
            }
            column(FORMAT_EndDate_; Format(EndDate))
            {
            }
            column(CI__VAT_Registration_No__; CompanyInformation."VAT Registration No.")
            {
            }
            column(VendTIN; VendTIN)
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(FORMAT_StartDate_; Format(StartDate))
            {
            }
            column(FirstMonthWHT_SecondMonthWHT_ThirdMonthWHT; FirstMonthWHT + SecondMonthWHT + ThirdMonthWHT)
            {
            }
            column(FirstMonth_SecondMonth_ThirdMonth; FirstMonth + SecondMonth + ThirdMonth)
            {
            }
            column(ThirdMonth; ThirdMonth)
            {
            }
            column(SecondMonth; SecondMonth)
            {
            }
            column(FirstMonth; FirstMonth)
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Revenue_Type_; "Withholding Tax Revenue Type")
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Prod__Posting_Group_; "Wthldg. Tax Prod. Post. Group")
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Bus__Posting_Group_; "Wthldg. Tax Bus. Post. Group")
            {
            }
            column(WHT_Entry__WHT_Entry___Bill_to_Pay_to_No__; "Bill-to/Pay-to No.")
            {
            }
            column(WHT_Entry__WHT_Entry___Transaction_Type_; "Transaction Type")
            {
            }
            column(DeclarationText; DeclarationIntroLbl + DeclarationStatementLbl)
            {
            }
            column(WHTTotal; WHTTotal)
            {
            }
            column(FirstMonthTotal_SecondMonthTotal_ThirdMonthTotal; FirstMonthTotal + SecondMonthTotal + ThirdMonthTotal)
            {
            }
            column(ThirdMonthTotal; ThirdMonthTotal)
            {
            }
            column(SecondMonthTotal; SecondMonthTotal)
            {
            }
            column(FirstMonthTotal; FirstMonthTotal)
            {
            }
            column(WHT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(Details_of_Monthly_Income_Payments_and_Tax_Withheld_for_the_QuarterCaption; Details_of_Monthly_Income_Payments_and_Tax_Withheld_for_the_QuarterCaptionLbl)
            {
            }
            column(BIR_Form_No_________2307Caption; BIR_Form_No_________2307CaptionLbl)
            {
            }
            column(Zip_CodeCaption; Zip_CodeCaptionLbl)
            {
            }
            column(Zip_CodeCaption_Control1500037; Zip_CodeCaption_Control1500037Lbl)
            {
            }
            column(AMOUNT_OF_INCOME_PAYMENTSCaption; AMOUNT_OF_INCOME_PAYMENTSCaptionLbl)
            {
            }
            column(Certificate_of_Creditable_Tax_Withheld_At_SourceCaption; Certificate_of_Creditable_Tax_Withheld_At_SourceCaptionLbl)
            {
            }
            column(Payee_InformationCaption; Payee_InformationCaptionLbl)
            {
            }
            column(Payor_InformationCaption; Payor_InformationCaptionLbl)
            {
            }
            column(To_DateCaption; To_DateCaptionLbl)
            {
            }
            column(TIN_No_Caption; TIN_No_CaptionLbl)
            {
            }
            column(Payor_s_NameCaption; Payor_s_NameCaptionLbl)
            {
            }
            column(TIN_No_Caption_Control1500052; TIN_No_Caption_Control1500052Lbl)
            {
            }
            column(Payee_s_NameCaption; Payee_s_NameCaptionLbl)
            {
            }
            column(AddressCaption; AddressCaptionLbl)
            {
            }
            column(AddressCaption_Control1500055; AddressCaption_Control1500055Lbl)
            {
            }
            column(From_DateCaption; From_DateCaptionLbl)
            {
            }
            column(Tax_Withheld_for_the_QuarterCaption; Tax_Withheld_for_the_QuarterCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(V3rd_Month_of_the_quarterCaption; V3rd_Month_of_the_quarterCaptionLbl)
            {
            }
            column(V2nd_Month_of_the_quarterCaption; V2nd_Month_of_the_quarterCaptionLbl)
            {
            }
            column(V1st_Month_of_the_quarterCaption; V1st_Month_of_the_quarterCaptionLbl)
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Revenue_Type_Caption; FieldCaption("Withholding Tax Revenue Type"))
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Prod__Posting_Group_Caption; FieldCaption("Wthldg. Tax Prod. Post. Group"))
            {
            }
            column(WHT_Entry__WHT_Entry___WHT_Bus__Posting_Group_Caption; FieldCaption("Wthldg. Tax Bus. Post. Group"))
            {
            }
            column(Title_Position_of_SignatoryCaption; Title_Position_of_SignatoryCaptionLbl)
            {
            }
            column(Payor_Payor_s_Authorized_RepresentativeCaption; Payor_Payor_s_Authorized_RepresentativeCaptionLbl)
            {
            }
            column(TotalCaption_Control1500088; TotalCaption_Control1500088Lbl)
            {
            }
            column(Payee_Payee_s_Authorized_RepresentativeCaption; Payee_Payee_s_Authorized_RepresentativeCaptionLbl)
            {
            }
            column(Date_SignedCaption; Date_SignedCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                FirstMonthWHT := 0;
                SecondMonthWHT := 0;
                ThirdMonthWHT := 0;
                FirstMonth := 0;
                SecondMonth := 0;
                ThirdMonth := 0;

                if "Actual Vendor No." <> '' then
                    Vend.Get("Actual Vendor No.")
                else
                    Vend.Get("Bill-to/Pay-to No.");

                VendName := Vend.Name;
                VendTIN := Vend."VAT Registration No.";
                VendAddress := Vend.Address;
                VendPostCode := Vend."Post Code";

                WHTEntry1.Reset();
                WHTEntry1.SetRange("Entry No.", "Entry No.");
                WHTEntry1.SetRange("Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Bus. Post. Group");
                WHTEntry1.SetRange("Wthldg. Tax Prod. Post. Group", "Wthldg. Tax Prod. Post. Group");
                WHTEntry1.SetRange("Withholding Tax Revenue Type", "Withholding Tax Revenue Type");
                if (StartDate <> 0D) and (EndDate <> 0D) then begin
                    if EndDate < CalcDate('<CM>', DMY2Date(1, ForMonth, CurrYear)) then
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth, CurrYear),
                          EndDate)
                    else
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth, CurrYear),
                          CalcDate('<CM>', DMY2Date(1, ForMonth, CurrYear)));
                end else
                    WHTEntry1.SetRange("Posting Date", "Posting Date");
                if WHTEntry1.FindFirst() then begin
                    FirstMonthWHT := WHTEntry1."Amount (LCY)";
                    FirstMonth := WHTEntry1."Base (LCY)";
                end;

                WHTEntry1.Reset();
                WHTEntry1.SetRange("Entry No.", "Entry No.");
                WHTEntry1.SetRange("Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Bus. Post. Group");
                WHTEntry1.SetRange("Wthldg. Tax Prod. Post. Group", "Wthldg. Tax Prod. Post. Group");
                WHTEntry1.SetRange("Withholding Tax Revenue Type", "Withholding Tax Revenue Type");
                if (StartDate <> 0D) and (EndDate <> 0D) then begin
                    if EndDate < CalcDate('<CM>', DMY2Date(1, ForMonth + 1, CurrYear)) then
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth + 1, CurrYear),
                          EndDate)
                    else
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth + 1, CurrYear),
                          CalcDate('<CM>', DMY2Date(1, ForMonth + 1, CurrYear)));
                    if WHTEntry1.FindFirst() then begin
                        SecondMonthWHT := WHTEntry1."Amount (LCY)";
                        SecondMonth := WHTEntry1."Base (LCY)";
                    end;
                end;

                WHTEntry1.Reset();
                WHTEntry1.SetRange("Entry No.", "Entry No.");
                WHTEntry1.SetRange("Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Bus. Post. Group");
                WHTEntry1.SetRange("Wthldg. Tax Prod. Post. Group", "Wthldg. Tax Prod. Post. Group");
                WHTEntry1.SetRange("Withholding Tax Revenue Type", "Withholding Tax Revenue Type");
                if (StartDate <> 0D) and (EndDate <> 0D) then begin
                    if EndDate < CalcDate('<CM>', DMY2Date(1, ForMonth + 2, CurrYear)) then
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth + 2, CurrYear),
                          EndDate)
                    else
                        WHTEntry1.SetFilter("Posting Date", '%1..%2', DMY2Date(1, ForMonth + 2, CurrYear),
                          CalcDate('<CM>', DMY2Date(1, ForMonth + 2, CurrYear)));
                    if WHTEntry1.FindFirst() then begin
                        ThirdMonthWHT := WHTEntry1."Amount (LCY)";
                        ThirdMonth := WHTEntry1."Base (LCY)";
                    end;
                end;
                FirstMonthTotal := FirstMonthTotal + FirstMonth;
                SecondMonthTotal := SecondMonthTotal + SecondMonth;
                ThirdMonthTotal := ThirdMonthTotal + ThirdMonth;
                WHTTotal := WHTTotal + FirstMonthWHT + SecondMonthWHT + ThirdMonthWHT;
            end;

            trigger OnPreDataItem()
            begin
                if WhtPostingSetup.Get() then
                    WhtPostingSetup.SetFilter(Sequence, '<>%1', 0);
                if GetFilter("Bill-to/Pay-to No.") = '' then
                    Error(PayToVendorFilterErr);
                if StartDate <> 0D then begin
                    ForMonth := Date2DMY(StartDate, 2);
                    CurrYear := Date2DMY(StartDate, 3);
                end else
                    if GetFilter("Posting Date") <> '' then begin
                        ForMonth := Date2DMY(GetRangeMin("Posting Date"), 2);
                        CurrYear := Date2DMY(GetRangeMin("Posting Date"), 3);
                    end;
                CompanyInformation.Get();
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
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the first date in the period from which posted entries in the consolidated company will be shown.';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date for the report.';
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
        WhtPostingSetup: Record "Withholding Tax Posting Setup";
        CompanyInformation: Record "Company Information";
        WHTEntry1: Record "Withholding Tax Entry";
        Vend: Record Vendor;
        ForMonth: Integer;
        FirstMonthWHT: Decimal;
        SecondMonthWHT: Decimal;
        ThirdMonthWHT: Decimal;
        CurrYear: Integer;
        FirstMonth: Decimal;
        SecondMonth: Decimal;
        ThirdMonth: Decimal;
        WHTTotal: Decimal;
        FirstMonthTotal: Decimal;
        SecondMonthTotal: Decimal;
        ThirdMonthTotal: Decimal;
        VendName: Text[30];
        VendAddress: Text[30];
        VendTIN: Text[30];
        VendPostCode: Text[30];
        PayToVendorFilterErr: Label 'Please enter the Pay to Vendor ID in the filter';
        DeclarationIntroLbl: Label 'We declare, under the penalties of perjury, that this certificate has been made in good faith, verified by me, and to the best of my knowledge and belief,';
        DeclarationStatementLbl: Label 'is true and correct, pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.';
        StartDate: Date;
        EndDate: Date;
        Details_of_Monthly_Income_Payments_and_Tax_Withheld_for_the_QuarterCaptionLbl: Label 'Details of Monthly Income Payments and Tax Withheld for the Quarter';
        BIR_Form_No_________2307CaptionLbl: Label 'BIR Form No.        2307';
        Zip_CodeCaptionLbl: Label 'Zip Code';
        Zip_CodeCaption_Control1500037Lbl: Label 'Zip Code';
        AMOUNT_OF_INCOME_PAYMENTSCaptionLbl: Label 'AMOUNT OF INCOME PAYMENTS';
        Certificate_of_Creditable_Tax_Withheld_At_SourceCaptionLbl: Label 'Certificate of Creditable Tax Withheld At Source';
        Payee_InformationCaptionLbl: Label 'Payee Information';
        Payor_InformationCaptionLbl: Label 'Payor Information';
        To_DateCaptionLbl: Label 'To Date';
        TIN_No_CaptionLbl: Label 'TIN No.';
        Payor_s_NameCaptionLbl: Label 'Payor''s Name';
        TIN_No_Caption_Control1500052Lbl: Label 'TIN No.';
        Payee_s_NameCaptionLbl: Label 'Payee''s Name';
        AddressCaptionLbl: Label 'Address';
        AddressCaption_Control1500055Lbl: Label 'Address';
        From_DateCaptionLbl: Label 'From Date';
        Tax_Withheld_for_the_QuarterCaptionLbl: Label 'Tax Withheld for the Quarter';
        TotalCaptionLbl: Label 'Total';
        V3rd_Month_of_the_quarterCaptionLbl: Label '3rd Month of the quarter';
        V2nd_Month_of_the_quarterCaptionLbl: Label '2nd Month of the quarter';
        V1st_Month_of_the_quarterCaptionLbl: Label '1st Month of the quarter';
        Title_Position_of_SignatoryCaptionLbl: Label 'Title/Position of Signatory';
        Payor_Payor_s_Authorized_RepresentativeCaptionLbl: Label 'Payor/Payor''s Authorized Representative';
        TotalCaption_Control1500088Lbl: Label 'Total';
        Payee_Payee_s_Authorized_RepresentativeCaptionLbl: Label 'Payee/Payee''s Authorized Representative';
        Date_SignedCaptionLbl: Label 'Date Signed';
}

