// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

codeunit 6789 "Withholding Tax Event Handler"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", OnShowExtensionPage, '', false, false)]
    local procedure OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        WithholdingTaxPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        case GLAccountWhereUsed."Table ID" of
            Database::"Withholding Tax Posting Setup":
                begin
                    WithholdingTaxPostingSetup."Wthldg. Tax Bus. Post. Group" := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(WithholdingTaxPostingSetup."Wthldg. Tax Bus. Post. Group"));
                    WithholdingTaxPostingSetup."Wthldg. Tax Prod. Post. Group" := CopyStr(GLAccountWhereUsed."Key 2", 1, MaxStrLen(WithholdingTaxPostingSetup."Wthldg. Tax Prod. Post. Group"));
                    Page.Run(Page::"Withholding Tax Posting Setup", WithholdingTaxPostingSetup);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", OnAfterFillTableBuffer, '', false, false)]
    local procedure OnAfterFillTableBuffer(var TableBuffer: Record Integer)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        AddCountryTables(TableBuffer);
    end;

    local procedure AddCountryTables(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        TableBuffer.Reset();
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Withholding Tax Posting Setup");
    end;

    local procedure CheckWithholdingTaxDisabled(): Boolean
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Enable Withholding Tax" then
            exit(true);

        exit(false);
    end;
}