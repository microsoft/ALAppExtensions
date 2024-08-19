// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Environment;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Integration;

codeunit 3001 "Agent Events"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", GetAgentTaskContext, '', true, true)]
    local procedure OnGetAgentTaskContext(var Context: JsonObject)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        Context.Add(CurrencyCodeTaskContextLbl, GeneralLedgerSetup."LCY Code");
        Context.Add(CurrencySymbolTaskContextLbl, GeneralLedgerSetup.GetCurrencySymbol());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", GetAgentTaskMessagePageId, '', true, true)]
    local procedure OnGetAgentTaskMessagePageId(var PageId: Integer)
    begin
        PageId := Page::"Agent Task Message Card";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", GetPageSummary, '', true, true)]
    local procedure OnGetGetPageSummary(PageId: Integer; Bookmark: Text; var Summary: Text)
    var
        PageSummaryProvider: Codeunit "Page Summary Provider";
    begin
        Summary := PageSummaryProvider.GetPageSummary(PageId, Bookmark);
    end;

    var
        CurrencyCodeTaskContextLbl: Label 'currencyCode', Locked = true;
        CurrencySymbolTaskContextLbl: Label 'currencySymbol', Locked = true;
}