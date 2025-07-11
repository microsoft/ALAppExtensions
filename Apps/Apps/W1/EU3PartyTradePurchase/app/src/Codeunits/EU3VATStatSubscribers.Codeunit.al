// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;

codeunit 4885 "EU3 VAT Stat. Subscribers"
{
    Access = Internal;

    Permissions = tabledata "VAT Entry" = r,
                  tabledata "VAT Statement Line" = r;

    [EventSubscriber(ObjectType::Page, Page::"VAT Statement Preview Line", 'OnBeforeOpenPageVATEntryTotaling', '', false, false)]
    local procedure OnBeforeOpenPageVATEntryTotaling(var VATEntry: Record "VAT Entry"; var VATStatementLine: Record "VAT Statement Line"; var GLEntry: Record "G/L Entry")
    var
    begin
        Case VATStatementLine."EU 3 Party Trade" of
            VATStatementLine."EU 3 Party Trade"::EU3:
                VATEntry.SetRange("EU 3-Party Trade", true);
            VATStatementLine."EU 3 Party Trade"::"non-EU3":
                VATEntry.SetRange("EU 3-Party Trade", false);
            VATStatementLine."EU 3 Party Trade"::All:
                VATEntry.SetRange("EU 3-Party Trade");
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"VAT Statement", 'OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters', '', false, false)]
    local procedure OnCalcLineTotalOnVATEntryTotalingOnAfterVATEntrySetFilters(VATStmtLine: Record "VAT Statement Line"; var VATEntry: Record "VAT Entry"; Selection: Enum "VAT Statement Report Selection")
    var
    begin
        Case VATStmtLine."EU 3 Party Trade" of
            VATStmtLine."EU 3 Party Trade"::EU3:
                VATEntry.SetRange("EU 3-Party Trade", true);
            VATStmtLine."EU 3 Party Trade"::"non-EU3":
                VATEntry.SetRange("EU 3-Party Trade", false);
            VATStmtLine."EU 3 Party Trade"::All:
                VATEntry.SetRange("EU 3-Party Trade");
        end;
    end;
}