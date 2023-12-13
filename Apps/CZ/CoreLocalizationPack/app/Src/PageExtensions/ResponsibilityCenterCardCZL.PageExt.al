// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

pageextension 31101 "Responsibility Center Card CZL" extends "Responsibility Center Card"
{
    layout
    {
        addafter(Communication)
        {
            group(PaymentsCZL)
            {
                Caption = 'Payments';

                field("Default Bank Account Code CZL"; Rec."Default Bank Account Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default bank account code for payment.';
                }
            }
        }
    }
}
