// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Calculation;

pageextension 11757 "VAT Posting Setup Card CZL" extends "VAT Posting Setup Card"
{
    layout
    {
        modify("Non-Deductible VAT %")
        {
            Visible = false;
            Enabled = false;
        }
        modify("Allow Non-Deductible VAT")
        {
            ToolTip = 'Specifies whether the Non-Deductible VAT is considered for this particular combination of VAT business posting group and VAT product posting group. If the ''Allow'' value is used then the input VAT is reduced by the coefficient from ''Non-Deductible VAT Setup''. If the ''Do not apply'' value is used then the input VAT is not applied.';
        }
        addafter(Usage)
        {
            group(VATCtrlReportCZL)
            {
                Caption = 'VAT Control Report';
                field("VAT Rate CZL"; Rec."VAT Rate CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies typ of VAT rate - base, reduced or reduced 2.';
                }
                field("Ratio Coefficient CZL"; Rec."Ratio Coefficient CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies ratio coefficient.';
                }
                field("Corrections Bad Receivable CZL"; Rec."Corrections Bad Receivable CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the designation of the receivable for the purposes of VAT Control Report.';
                }
                field("Supplies Mode Code CZL"; Rec."Supplies Mode Code CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies supplies mode code from VAT layer. The setting is used in the VAT Control Report.';
                }
            }
        }
        addafter("Sales VAT Unreal. Account")
        {
            field("Sales VAT Curr. Exch. Acc CZL"; Rec."Sales VAT Curr. Exch. Acc CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the G/L account for clearing sales VAT due to the different exchange rate for VAT';
            }
        }
        addafter("Purch. VAT Unreal. Account")
        {
            field("Purch. VAT Curr. Exch. Acc CZL"; Rec."Purch. VAT Curr. Exch. Acc CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the G/L account for clearing purchase VAT due to the different exchange rate for VAT';
            }
        }
        addafter("EU Service")
        {
            field("Intrastat Service CZL"; Rec."Intrastat Service CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies if this combination of VAT business posting group and VAT product posting group is used to the intrastat journal.';
            }
        }
        addlast(General)
        {
            field("Reverse Charge Check CZL"; Rec."Reverse Charge Check CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies if the reverse charge will be checked';
            }
        }
        addlast(Sales)
        {
            field("VIES Sales CZL"; Rec."VIES Sales CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the option to include this posting setup in sales VIES declarations.';
            }
        }
        addlast(Purchases)
        {
            field("VIES Purchase CZL"; Rec."VIES Purchase CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the option to include this posting setup in the purchase VIES declarations.';
            }
            field("VAT LCY Corr. Rounding Acc.CZL"; Rec."VAT LCY Corr. Rounding Acc.CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account to which the VAT correction in LCY will be posted on documents in foreign currency, eg use an account for document rounding';
            }
            field("VAT Coeff. Corr. Account CZL"; Rec."VAT Coeff. Corr. Account CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account to be used to post for the VAT difference between the advance and settlement VAT coefficients at the end of the year.';
                Visible = NonDeductibleVATVisible;
            }
        }
    }

    trigger OnOpenPage()
    begin
        NonDeductibleVATVisible := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        NonDeductibleVATVisible: Boolean;
}
