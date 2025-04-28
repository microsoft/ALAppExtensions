// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Vendor;
using Microsoft.DemoData.Finance;

codeunit 10715 "Create Vendor Posting Group NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGroup(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateVendorPostingGroup.Domestic(),
            CreateVendorPostingGroup.EU(),
            CreateVendorPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccount.DeliveryExpensesRetail(), CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentToleranceGranted());
        end;
    end;

    local procedure ValidateRecordFields(var VendorPostingGroup: Record "Vendor Posting Group"; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; PaymentToleranceDebitAcc: Code[20])
    begin
        VendorPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        VendorPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
    end;
}
