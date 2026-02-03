// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;
#if not CLEAN28
using Microsoft.Bank.Payment;
#endif

pageextension 10841 "Vendor Bank Account Card" extends "Vendor Bank Account Card"
{
    layout
    {
#if not CLEAN28
#pragma warning disable AL0432
        modify("Agency Code")
        {
            Visible = not FeatureEnabled;
        }
        modify("RIB Key")
        {
            Visible = not FeatureEnabled;
        }
        modify("RIB Checked")
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Bank Branch No.")
        {
            field("Agency Code FR"; Rec."Agency Code FR")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the five-number code of the agency of the bank, for example, 00300.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
            }
        }
        addafter("Bank Account No.")
        {
            field("RIB Key FR"; Rec."RIB Key FR")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the two-digit RIB key associated with the Bank Account No. RIB key value in range from 01 to 09 is represented in the single-digit form, without leading zero digit.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
            }
            field("RIB Checked FR"; Rec."RIB Checked FR")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Bank Account No. has been verified against the RIB Key.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
            }
        }
    }

#if not CLEAN28
    trigger OnOpenPage()
    var
        PaymentFeatureFR: Codeunit "Payment Management Feature FR";
    begin
        FeatureEnabled := PaymentFeatureFR.IsEnabled();
    end;

    var
        FeatureEnabled: Boolean;
#endif
}