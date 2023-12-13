// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;

codeunit 31476 "Calc. And Post VAT Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Report, Report::"Calc. and Post VAT Settl. CZL", 'OnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters', '', false, false)]
    local procedure FilterAdvancesOnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters(var VATEntry: Record "VAT Entry")
    begin
        if AdvanceNumberRun = 1 then
            VATEntry.SetFilter("Advance Letter No. CZZ", '=''''');
        if AdvanceNumberRun = 2 then
            VATEntry.SetFilter("Advance Letter No. CZZ", '<>''''');
    end;

    procedure SetAdvanceNumberRun(AdvanceNumberRunSet: Integer)
    begin
        AdvanceNumberRun := AdvanceNumberRunSet;
    end;

    var
        AdvanceNumberRun: Integer;
}
