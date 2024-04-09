// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;

codeunit 18448 "GST Stats Management"
{
    SingleInstance = true;

    var
        GSTStatsAmount: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document Stats Mgmt.", 'OnAfterFillTotalsByTaxType', '', false, false)]
    local procedure OnAfterFillTotalsByTaxType(TotalsByTaxType: Dictionary of [Code[20], Decimal])
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if TotalsByTaxType.ContainsKey(GSTSetup."GST Tax Type") then
            GSTStatsAmount += TotalsByTaxType.Get(GSTSetup."GST Tax Type");
    end;

    procedure GetGstStatsAmount(): Decimal
    begin
        exit(GSTStatsAmount);
    end;

    procedure ClearSessionVariable()
    begin
        GSTStatsAmount := 0;
    end;
}
