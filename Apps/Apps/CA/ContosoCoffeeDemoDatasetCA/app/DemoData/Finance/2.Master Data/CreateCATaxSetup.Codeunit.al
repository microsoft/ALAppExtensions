// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 27049 "Create CA Tax Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
    begin
        ContosoCATax.InsertTaxSetup(true, CreateCATaxGroup.NonTaxable(), CreateCAGLAccounts.ProvincialSalesTax(), CreateCAGLAccounts.GSTHSTInputCredits(), CreateCAGLAccounts.GSTHSTInputCredits());
    end;
}
