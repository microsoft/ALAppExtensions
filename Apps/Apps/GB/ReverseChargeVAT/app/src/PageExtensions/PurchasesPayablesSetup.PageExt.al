// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.Setup;

pageextension 10556 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
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
        modify("Domestic Vendors")
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
                field("Domestic Vendors GB"; Rec."Domestic Vendors GB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT Business Posting Group code for domestic UK vendors.';
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