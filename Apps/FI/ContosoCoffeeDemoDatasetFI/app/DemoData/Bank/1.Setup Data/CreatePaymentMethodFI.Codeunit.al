// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;
using Microsoft.DemoData.Finance;

codeunit 13423 "Create Payment Method FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertPaymentMethod(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreatePaymentMethod.Cash():
                ValidateRecordFields(Rec, CreateGLAccount.Cash());
        end;
    end;

    local procedure ValidateRecordFields(var PaymentMethod: Record "Payment Method"; BalAccountNo: Code[20])
    begin
        PaymentMethod.Validate("Bal. Account No.", BalAccountNo);
    end;
}
