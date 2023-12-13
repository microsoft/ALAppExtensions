// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

codeunit 31454 "G/L Acc.Where-Used Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Advance Letter Template CZZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        if GLAccountWhereUsed."Table ID" = Database::"Advance Letter Template CZZ" then begin
            AdvanceLetterTemplateCZZ.Code := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(AdvanceLetterTemplateCZZ.Code));
            Page.Run(0, AdvanceLetterTemplateCZZ);
        end;
    end;
}
