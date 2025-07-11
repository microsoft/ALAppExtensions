// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.BankDocuments;

using Microsoft.Bank.Documents;
using Microsoft.DemoData.Localization;

codeunit 31486 "Create Search Rule CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SearchRuleCZB: Record "Search Rule CZB";
        ContosoBankDocumentsCZB: Codeunit "Contoso Bank Documents CZB";
    begin
        ContosoBankDocumentsCZB.InsertSearchRule(Default(), DefaultMatchingRulesLbl, true);
        if SearchRuleCZB.Get(Default()) then
            SearchRuleCZB.CreateDefaultLines();
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultTok);
    end;

    var
        DefaultTok: Label 'Default', MaxLength = 10;
        DefaultMatchingRulesLbl: Label 'Default matching rules', MaxLength = 100;
}
