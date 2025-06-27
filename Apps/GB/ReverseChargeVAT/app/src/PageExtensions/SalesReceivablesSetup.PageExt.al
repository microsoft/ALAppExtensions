// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Setup;

pageextension 10557 "Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
#if not CLEAN27
#pragma warning disable AL0432
        modify("Reverse Charge")
#pragma warning restore  AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify("Reverse Charge VAT Posting Gr.")
#pragma warning restore  AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify("Domestic Customers")
#pragma warning restore  AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify("Invoice Wording")
#pragma warning restore  AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#endif
        addafter("Background Posting")
        {
            group("Reverse Charge GB")
            {
                Caption = 'Reverse Charge';
#if not CLEAN27
                Visible = IsNewFeatureEnabled;
                Enabled = IsNewFeatureEnabled;
#endif
                field("Reverse Charge VAT Post. Gr."; Rec."Reverse Charge VAT Post. Gr.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT Business Posting Group code for reverse charge VAT.';
#if not CLEAN27
                    Visible = IsNewFeatureEnabled;
                    Enabled = IsNewFeatureEnabled;
#endif
                }
                field("Domestic Customers GB"; Rec."Domestic Customers GB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT Business Posting Group code for domestic UK customers.';
#if not CLEAN27
                    Visible = IsNewFeatureEnabled;
                    Enabled = IsNewFeatureEnabled;
#endif
                }
                field("Invoice Wording GB"; Rec."Invoice Wording GB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the text that is printed on the invoice indicating that the invoice is a reverse charge transaction.';
#if not CLEAN27
                    Visible = IsNewFeatureEnabled;
                    Enabled = IsNewFeatureEnabled;
#endif
                }
            }
        }
    }

#if not CLEAN27
    var
        IsNewFeatureEnabled: Boolean;
#endif

#if not CLEAN27
    trigger OnOpenPage()
    var
        ReverseChargeVAT: Codeunit "Reverse Charge VAT GB";
    begin
        IsNewFeatureEnabled := ReverseChargeVAT.IsEnabled();
    end;
#endif
}