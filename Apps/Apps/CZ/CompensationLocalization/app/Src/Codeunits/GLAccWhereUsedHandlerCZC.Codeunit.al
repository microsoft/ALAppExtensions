// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

codeunit 31371 "G/L Acc.Where-Used Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Compensations Setup CZC");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    begin
        if GLAccountWhereUsed."Table ID" = Database::"Compensations Setup CZC" then
            Page.Run(Page::"Compensations Setup CZC");
    end;
}
