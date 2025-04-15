// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 17146 "Create NZ Gen. Journ. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
    begin
        ContosoGeneralLedger.InsertGeneralJournalTemplate(PostDated(), PostDatedChecksLbl, Enum::"Gen. Journal Template Type"::"Post Dated", Page::"General Journal", '', false);
        UpdateSourceCodeOnGenJournalTemplate(PostDated());
    end;

    local procedure UpdateSourceCodeOnGenJournalTemplate(TemplateName: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        SourceCodeSetup.Get();

        if GenJournalTemplate.Get(TemplateName) then begin
            GenJournalTemplate.Validate("Source Code", SourceCodeSetup."General Journal");
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure PostDated(): Code[10]
    begin
        exit(PostDatedTok);
    end;

    var
        PostDatedChecksLbl: Label 'Post Dated Checks', MaxLength = 80;
        PostDatedTok: Label 'POSTDATED', MaxLength = 10;
}
