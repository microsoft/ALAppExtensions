// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;

codeunit 13424 "Create Bank Account FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -1447200, PostCodeLbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, PostCodeLbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var

        PostCodeLbl: Label '80100', MaxLength = 20, Locked = true;
}
