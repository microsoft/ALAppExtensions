// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;

codeunit 19001 "Create IN Currency"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrency(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        case Rec.Code of
            CreateCurrency.GBP():
                begin
                    ValidateRecordFields(Rec, '', '');
                    Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
                end
            else
                ValidateRecordFields(Rec, '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record Currency; UnrealizedGainsAcc: Code[20]; UnrealizedLossesAcc: Code[20])
    begin
        Currency.Validate("Unrealized Gains Acc.", UnrealizedGainsAcc);
        Currency.Validate("Unrealized Losses Acc.", UnrealizedLossesAcc);
    end;
}
