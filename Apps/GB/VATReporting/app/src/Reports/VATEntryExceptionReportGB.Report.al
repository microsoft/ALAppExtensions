// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;

report 10545 "VAT Entry Exception Report GB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/Layouts/VATEntryExceptionReportGB.rdlc';
    Caption = 'VAT Entry Exception Report';

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = sorting(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Reporting Date");
            RequestFilterFields = "VAT Reporting Date", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(USERID; UserId)
            {
            }
            column(VAT_Entry__TABLENAME__________VATEntryFilter; "VAT Entry".TableName + ': ' + VATEntryFilter)
            {
            }
            column(VATEntryFilter; VATEntryFilter)
            {
            }
            column(Manual_Word; Manual_WordLbl)
            {
            }
            column(VAT_Entry_Type; Type)
            {
            }
            column(VAT_Entry__VAT_Reporting_Date_; Format("VAT Reporting Date"))
            {
            }
            column(VAT_Entry__Document_Type_; "Document Type")
            {
            }
            column(VAT_Entry__Document_No__; "Document No.")
            {
            }
            column(VAT_Entry__External_Document_No__; "External Document No.")
            {
            }
            column(VAT_Entry__VAT_Calculation_Type_; "VAT Calculation Type")
            {
            }
            column(VAT_Entry__VAT_Bus__Posting_Group_; "VAT Bus. Posting Group")
            {
            }
            column(VAT_Entry__VAT_Prod__Posting_Group_; "VAT Prod. Posting Group")
            {
            }
            column(VAT_Entry_Base; Base)
            {
                AutoFormatType = 1;
            }
            column(VAT_Entry__VAT_Base_Discount___; "VAT Base Discount %")
            {
            }
            column(VAT_Entry_Amount; Amount)
            {
                AutoFormatType = 1;
            }
            column(Manual_VAT_Difference; "VAT Difference")
            {
            }
            column(ErrorText; ErrorText)
            {
            }
            column(Total_for___FIELDNAME_Type_______FORMAT_Type_; 'Total for ' + FieldName(Type) + ' ' + Format(Type))
            {
            }
            column(VAT_Entry_Base_Control50; Base)
            {
                AutoFormatType = 1;
            }
            column(VAT_Entry_Amount_Control51; Amount)
            {
                AutoFormatType = 1;
            }
            column(VAT_Entry__VAT_Difference_; "VAT Difference")
            {
            }
            column(VAT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(VAT_Entry_Exception_ReportCaption; VAT_Entry_Exception_ReportCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(VAT_Entry__VAT_Reporting_Date_Caption; VAT_Entry__VAT_Reporting_Date_CaptionLbl)
            {
            }
            column(VAT_Entry__Document_Type_Caption; FieldCaption("Document Type"))
            {
            }
            column(VAT_Entry__Document_No__Caption; FieldCaption("Document No."))
            {
            }
            column(VAT_Entry__External_Document_No__Caption; FieldCaption("External Document No."))
            {
            }
            column(VAT_Entry__VAT_Calculation_Type_Caption; FieldCaption("VAT Calculation Type"))
            {
            }
            column(VAT_Entry__VAT_Bus__Posting_Group_Caption; FieldCaption("VAT Bus. Posting Group"))
            {
            }
            column(VAT_Entry__VAT_Prod__Posting_Group_Caption; FieldCaption("VAT Prod. Posting Group"))
            {
            }
            column(VAT_Entry_BaseCaption; FieldCaption(Base))
            {
            }
            column(VAT_Entry__VAT_Base_Discount___Caption; FieldCaption("VAT Base Discount %"))
            {
            }
            column(VAT_Entry_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Manual_VAT_DifferenceCaption; FieldCaption("VAT Difference"))
            {
            }
            column(VAT_Entry_TypeCaption; FieldCaption(Type))
            {
            }

            trigger OnAfterGetRecord()
            begin
                if "VAT Entry".Type = "VAT Entry".Type::Settlement then
                    CurrReport.Skip();

                PrintErrorLine := false;
                ErrorText := '';
                if CheckVATBaseDiscount then
                    if "VAT Base Discount %" > MaxVATBaseDiscount then begin
                        AddErrorText(
                          ErrorText,
                          FieldCaption("VAT Base Discount %") +
                          ' > ' + Format(MaxVATBaseDiscount));
                        PrintErrorLine := true;
                    end;

                if CheckManualVATDifference then
                    if Abs("VAT Difference") > MaxManualVATDifference then begin
                        AddErrorText(
                          ErrorText,
                          FieldCaption("VAT Difference") +
                          ' > ' + Format(MaxManualVATDifference));
                        PrintErrorLine := true;
                    end;

                if not TempVATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
                    SetupVATCalculationType := SetupVATCalculationType::Missing
                else
                    SetupVATCalculationType := TempVATPostingSetup."VAT Calculation Type".AsInteger();

                if CheckVATCalculationTypes then
                    if "VAT Calculation Type".AsInteger() <> SetupVATCalculationType then begin
                        AddErrorText(
                          ErrorText,
                          Text1041001Txt + FieldCaption("VAT Calculation Type") +
                          Text1041002Txt + Format(SetupVATCalculationType));
                        PrintErrorLine := true;
                    end;

                if CheckVATRate then begin
                    Base := Base * (1 - "VAT Base Discount %" / 100);
                    if Base <> 0 then begin
                        CalculatedVATRate := Amount * 100 / Base;
                        if
                           (Abs(CalculatedVATRate - TempVATPostingSetup."VAT %") > MaxVATRateDifference) and
                           (SetupVATCalculationType <> SetupVATCalculationType::"Reverse Charge VAT")
                        then begin
                            AddErrorText(
                              ErrorText,
                              TempVATPostingSetup.FieldCaption("VAT %") + Text1041002Txt +
                              Format(Round(CalculatedVATRate, 0.00001)) +
                              Text1041003Txt + Format(TempVATPostingSetup."VAT %"));
                            PrintErrorLine := true;
                        end;
                    end else
                        if Amount <> 0 then begin
                            AddErrorText(
                              ErrorText,
                              FieldName(Base) + Text1041004Txt +
                              FieldName(Amount) + Text1041005Txt);
                            PrintErrorLine := true;
                        end;
                end;

                if not PrintErrorLine then
                    CurrReport.Skip();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Check:")
                    {
                        Caption = 'Check:';
                        field(VATBaseDiscount; CheckVATBaseDiscount)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'VAT Base Discount';
                            ToolTip = 'Specifies that you want to print the VAT base discount amount over the maximum selected value in the maximum VAT Base Discount field.';
                        }
                        field(ManualVATDifference; CheckManualVATDifference)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Manual VAT Difference';
                            ToolTip = 'Specifies that you want to print the manual VAT difference over the maximum amount in the VAT Difference (LCY) field, by placing a check mark in the check box.';
                        }
                        field(VATCalculationTypes; CheckVATCalculationTypes)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'VAT Calculation Types';
                            ToolTip = 'Specifies that you want to check VAT calculation type, by placing a check mark in the check box.';
                        }
                        field(VATRate; CheckVATRate)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'VAT Rate';
                            ToolTip = 'Specifies that you want to check the VAT rate for that particular journal line, by placing a check mark in the check box.';
                        }
                    }
                    group("Maximum:")
                    {
                        Caption = 'Maximum:';
                        field("Max VAT Base Discount"; MaxVATBaseDiscount)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'VAT Base Discount %';
                            MaxValue = 100;
                            MinValue = 0;
                            ToolTip = 'Specifies a percentage discount value that you enter in this field, if you have placed a checkmark in the VAT Base Discount checkbox.';
                            AutoFormatType = 0;
                        }
                        field("Max Manual VAT Difference "; MaxManualVATDifference)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Manual VAT Difference';
                            ToolTip = 'Specifies that you want to print the manual VAT difference over the maximum amount in the VAT Difference (LCY) field, by placing a check mark in the check box.';
                            AutoFormatType = 1;
                            AutoFormatExpression = '';
                        }
                        field("Max VAT Rate Difference "; MaxVATRateDifference)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'VAT Rate % Difference';
                            DecimalPlaces = 1 : 5;
                            MaxValue = 100;
                            MinValue = 0;
                            ToolTip = 'Specifies that you want to check the maximum VAT rate difference, by placing a check mark in the check box.';
                            AutoFormatType = 0;
                        }
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

    trigger OnInitReport()
    begin
        GLSetup.Get();
        MaxVATBaseDiscount := GLSetup."VAT Tolerance %";
        MaxManualVATDifference := GLSetup."Max. VAT Difference Allowed";
        if MaxVATRateDifference = 0 then
            MaxVATRateDifference := 0.1;
    end;

    trigger OnPreReport()
    begin
        VATEntryFilter := "VAT Entry".GetFilters();

        if
           not CheckVATBaseDiscount and
           not CheckManualVATDifference and
           not CheckVATCalculationTypes and
           not CheckVATRate
        then
            Error(Text1041000Txt);

        if VATPostingSetup.Find('-') then
            repeat
                TempVATPostingSetup := VATPostingSetup;
                TempVATPostingSetup.Insert();
            until VATPostingSetup.Next() = 0;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        TempVATPostingSetup: Record "VAT Posting Setup" temporary;
        VATEntryFilter: Text;
        ErrorText: Text;
        CheckVATBaseDiscount: Boolean;
        CheckManualVATDifference: Boolean;
        CheckVATCalculationTypes: Boolean;
        CheckVATRate: Boolean;
        PrintErrorLine: Boolean;
        MaxVATBaseDiscount: Decimal;
        MaxManualVATDifference: Decimal;
        MaxVATRateDifference: Decimal;
        CalculatedVATRate: Decimal;
        SetupVATCalculationType: Option "Normal VAT","Reverse Charge VAT","Full VAT",,,Missing;
        Text1041000Txt: Label 'No checking selected.', Comment = '%1=';
        Text1041001Txt: Label 'Setup ';
        Text1041002Txt: Label ' is ';
        Text1041003Txt: Label ' compared to setup ';
        Text1041004Txt: Label ' is 0 and ';
        Text1041005Txt: Label ' is <> 0';
        Manual_WordLbl: Label 'Manual';
        VAT_Entry_Exception_ReportCaptionLbl: Label 'VAT Entry Exception Report';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        VAT_Entry__VAT_Reporting_Date_CaptionLbl: Label 'VAT Reporting Date';

    local procedure AddErrorText(var NewErrorText: Text; ErrorText2: Text)
    begin
        if NewErrorText <> '' then
            NewErrorText := NewErrorText + ', ' + ErrorText2
        else
            NewErrorText := ErrorText2;
    end;
}