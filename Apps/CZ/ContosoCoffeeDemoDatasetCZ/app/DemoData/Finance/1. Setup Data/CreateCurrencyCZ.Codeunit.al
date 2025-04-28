// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;

codeunit 31198 "Create Currency CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCurrency();
    end;

    local procedure UpdateCurrency()
    var
        Currency: Record Currency;
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        if Currency.FindSet() then
            repeat
                Currency.Validate("Unrealized Gains Acc.", CreateGLAccountCZ.ExchangeGainsUnrealized());
                Currency.Validate("Realized Gains Acc.", CreateGLAccountCZ.ExchangeGainsRealized());
                Currency.Validate("Unrealized Losses Acc.", CreateGLAccountCZ.ExchangeLossesUnrealized());
                Currency.Validate("Realized Losses Acc.", CreateGLAccountCZ.ExchangeLossesRealized());
                Currency.Modify();
            until Currency.Next() = 0;
    end;
}
