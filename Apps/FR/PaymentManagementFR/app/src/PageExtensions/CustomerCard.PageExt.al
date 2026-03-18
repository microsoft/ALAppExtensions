// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Sales.Customer;

pageextension 10838 "Customer Card" extends "Customer Card"
{
    layout
    {
#if not CLEAN28
#pragma warning disable AL0432
        modify("Payment in progress (LCY)")
        {
            Visible = not FeatureEnabled;
        }
        modify("""Balance (LCY)"" - ""Payment in progress (LCY)""")
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Payment Balance (LCY)")
        {
            field("Payment in progress (LCY) FR"; Rec."Payment in progress (LCY) FR")
            {
                ApplicationArea = Basic, Suite;
                AutoFormatType = 1;
                AutoFormatExpression = Rec."Currency Code";
                ToolTip = 'Specifies the customer''s payments in progress.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
            }
            field("Net amount (LCY)"; Rec."Balance (LCY)" - Rec."Payment in progress (LCY) FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Net amount (LCY)';
                Editable = false;
                AutoFormatType = 1;
                AutoFormatExpression = Rec."Currency Code";
                ToolTip = 'Specifies the net amount in local currency.';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
            }
        }
    }
    actions
    {
#if not CLEAN28
#pragma warning disable AL0432
        modify("&Payment Addresses")
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter(Contact)
        {
            action("&Payment Addresses FR")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Payment Addresses';
                Image = Addresses;
                RunObject = Page "Payment Addresses FR";
                RunPageLink = "Account Type" = const(Customer),
                                  "Account No." = field("No.");
                ToolTip = 'View payment addresses for the customer.';
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