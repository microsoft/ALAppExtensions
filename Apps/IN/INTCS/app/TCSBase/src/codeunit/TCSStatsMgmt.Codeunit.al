// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TaxEngine.UseCaseBuilder;

codeunit 18820 "TCS Stats Management"
{
    SingleInstance = true;

    var
        TCSStatsAmount: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document Stats Mgmt.", 'OnAfterFillTotalsByTaxType', '', false, false)]
    local procedure OnAfterFillTotalsByTaxType(TotalsByTaxType: Dictionary of [Code[20], Decimal])
    var
        TCSSetup: Record "TCS Setup";
    begin
        if not TCSSetup.Get() then
            exit;

        if TotalsByTaxType.ContainsKey(TCSSetup."Tax Type") then
            TCSStatsAmount += TotalsByTaxType.Get(TCSSetup."Tax Type");
    end;

    procedure GetTCSStatsAmount(): Decimal
    begin
        exit(TCSStatsAmount);
    end;

    procedure ClearSessionVariable()
    begin
        TCSStatsAmount := 0;
    end;
}
