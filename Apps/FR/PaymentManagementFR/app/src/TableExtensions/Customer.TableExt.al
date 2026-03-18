// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;
#pragma warning disable AA0232

using Microsoft.Sales.Customer;

tableextension 10832 Customer extends Customer
{
    fields
    {
        field(10861; "Payment in progress (LCY) FR"; Decimal)
        {
            CalcFormula = - sum("Payment Line FR"."Amount (LCY)" where("Account Type" = const(Customer),
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