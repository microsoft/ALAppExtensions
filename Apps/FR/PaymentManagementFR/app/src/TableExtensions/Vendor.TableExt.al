// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;
#pragma warning disable AA0232

using Microsoft.Purchases.Vendor;

tableextension 10835 Vendor extends Vendor
{
    fields
    {
        field(10861; "Payment in progress (LCY) FR"; Decimal)
        {
            CalcFormula = sum("Payment Line FR"."Amount (LCY)" where("Account Type" = const(Vendor),
                                                                   "Account No." = field("No."),
                                                                   "Copied To Line" = const(0),
                                                                   "Payment in Progress" = const(true)));
            Caption = 'Payment in progress (LCY)';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Editable = false;
            FieldClass = FlowField;
        }
    }
}