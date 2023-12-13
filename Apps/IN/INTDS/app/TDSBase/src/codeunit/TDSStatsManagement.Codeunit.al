// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.UseCaseBuilder;

codeunit 18695 "TDS Stats Management"
{
    SingleInstance = true;

    var
        TDSStatsAmount: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document Stats Mgmt.", 'OnAfterFillTotalsByTaxType', '', false, false)]
    local procedure OnAfterFillTotalsByTaxType(TotalsByTaxType: Dictionary of [Code[20], Decimal])
    var
        TDSSetup: Record "TDS Setup";
    begin
        if not TDSSetup.Get() then
            exit;

        if TotalsByTaxType.ContainsKey(TDSSetup."Tax Type") then
            TDSStatsAmount += TotalsByTaxType.Get(TDSSetup."Tax Type");
    end;

    procedure GetTDSStatsAmount(): Decimal
    begin
        exit(TDSStatsAmount);
    end;

    procedure ClearSessionVariable()
    begin
        TDSStatsAmount := 0;
    end;
}
