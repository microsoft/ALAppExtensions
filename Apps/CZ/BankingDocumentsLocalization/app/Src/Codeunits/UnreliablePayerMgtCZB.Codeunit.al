// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Purchases.Vendor;

codeunit 31347 "Unreliable Payer Mgt. CZB"
{
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";

    procedure ImportUnreliablePayerStatusForPaymentOrder(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Boolean
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        Vendor: Record Vendor;
    begin
        if not GetUnreliablePayerServiceSetup() then
            exit(false);

        SetPaymentOrderLineFilter(PaymentOrderHeaderCZB, PaymentOrderLineCZB);
        if not PaymentOrderLineCZB.FindSet() then
            exit(false);

        UnreliablePayerMgtCZL.ClearVATRegNoList();
        repeat
            Vendor.Get(PaymentOrderLineCZB."No.");
            if Vendor.IsUnreliablePayerCheckPossibleCZL() then
                UnreliablePayerMgtCZL.AddVATRegNoToList(Vendor."VAT Registration No.");
        until PaymentOrderLineCZB.Next() = 0;
        if UnreliablePayerMgtCZL.GetVATRegNoCount() = 0 then
            exit(false);

        exit(UnreliablePayerMgtCZL.ImportUnrPayerStatus(false));
    end;

    procedure GetUnreliablePayerServiceSetup(): Boolean
    begin
        if not UnrelPayerServiceSetupCZL.Get() then begin
            UnrelPayerServiceSetupCZL.Init();
            UnreliablePayerMgtCZL.SetDefaultUnreliablePayerServiceURL(UnrelPayerServiceSetupCZL);
            UnrelPayerServiceSetupCZL.Enabled := false;
            UnrelPayerServiceSetupCZL.Insert();
        end;
        exit(UnrelPayerServiceSetupCZL.Enabled);
    end;

    local procedure SetPaymentOrderLineFilter(PaymentOrderHeader: Record "Payment Order Header CZB"; var PaymentOrderLineCZB: Record "Payment Order Line CZB")
    begin
        PaymentOrderLineCZB.Reset();
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeader."No.");
        PaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type::Vendor);
        PaymentOrderLineCZB.SetRange("Skip Payment", false);
    end;

    procedure NotifyUnreliablePayerServiceSetup()
    var
        UnreliablePayerServiceSetupNotification: Notification;
        UnreliablePayerServiceSetupNotSetTxt: Label 'Unreliable Payer Service is not set.';
        SetUpTxt: Label 'Set Up';
    begin
        if GetUnreliablePayerServiceSetup() then
            exit;

        UnreliablePayerServiceSetupNotification.Message := UnreliablePayerServiceSetupNotSetTxt;
        UnreliablePayerServiceSetupNotification.Scope := NotificationScope::LocalScope;
        UnreliablePayerServiceSetupNotification.AddAction(SetUpTxt, Codeunit::"Unreliable Payer Mgt. CZB", 'OpenUnreliablePayerServiceSetup');
        UnreliablePayerServiceSetupNotification.Send();
    end;

    procedure OpenUnreliablePayerServiceSetup(UnreliablePayerServiceSetupNotification: Notification)
    begin
        Page.Run(Page::"Unrel. Payer Service Setup CZL");
    end;
}
