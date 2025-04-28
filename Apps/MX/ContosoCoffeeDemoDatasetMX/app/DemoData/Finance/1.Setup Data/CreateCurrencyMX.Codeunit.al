// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;

codeunit 14109 "Create Currency MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Record Currency;
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Currency.FindSet() then
            repeat
                Currency.Validate("Unrealized Gains Acc.", CreateGLAccount.UnrealizedFxGains());
                Currency.Validate("Unrealized Losses Acc.", CreateGLAccount.UnrealizedFxLosses());
                Currency.Modify(true);
            until Currency.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        if Rec.Code = CreateCurrency.GBP() then
            Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
    end;
}
