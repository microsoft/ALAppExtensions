#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

#pragma warning disable AL0432
pageextension 10845 "View/Edit Payment Line" extends "View/Edit Payment Line"
#pragma warning restore AL0432
{
    trigger OnOpenPage()
    var
        PaymentFeature: Codeunit "Payment Management Feature FR";
    begin
        if PaymentFeature.IsEnabled() then
            Error(UseLookEditPaymentLineFRPageErr);
    end;

    var
        UseLookEditPaymentLineFRPageErr: Label 'Use Payment Management FR app instead';
}
#endif