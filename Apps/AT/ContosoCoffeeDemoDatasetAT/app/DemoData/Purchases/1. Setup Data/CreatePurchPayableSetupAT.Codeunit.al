// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoData.Foundation;
using Microsoft.Purchases.Setup;

codeunit 11168 "Create Purch. Payable Setup AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeriesAT: Codeunit "Create No. Series AT";
    begin
        UpdatePurchasePayableSetup(CreateNoSeriesAT.PurchaseDeliveryReminder(), CreateNoSeriesAT.PurchaseIssueDeliveryReminder());
    end;

    local procedure UpdatePurchasePayableSetup(DeliveryReminderNos: Code[20]; IssuedDeliveryReminderNos: Code[20])
    var
        PurchPayableSetup: Record "Purchases & Payables Setup";
    begin
        if PurchPayableSetup.Get() then begin
            PurchPayableSetup.Validate("Delivery Reminder Nos.", DeliveryReminderNos);
            PurchPayableSetup.Validate("Issued Delivery Reminder Nos.", IssuedDeliveryReminderNos);
            PurchPayableSetup.Modify(true);
        end;
    end;
}
