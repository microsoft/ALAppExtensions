#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

codeunit 10843 "Payment Management Subscriber"
{
    ObsoleteReason = 'Feature Payment Management will be enabled by default in version 31.0.';
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '28.0';
#pragma warning restore AS0072

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management", OnBeforeRun, '', false, false)]
#pragma warning restore AL0432
    local procedure OnBeforeRun()
    var
        PaymentFeature: Codeunit "Payment Management Feature FR";
    begin
        if PaymentFeature.IsEnabled() then
            Error(UseCreatePaymentSlipFRCodeunitErr);
    end;

    var
        UseCreatePaymentSlipFRCodeunitErr: Label 'Use Payment Management FR app instead';
}
#endif