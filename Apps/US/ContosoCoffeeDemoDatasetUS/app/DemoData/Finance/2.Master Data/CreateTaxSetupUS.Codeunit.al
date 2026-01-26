// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11461 "Create Tax Setup US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        ContosoTaxUS.InsertTaxSetup(true, CreateTaxGroupUS.NonTaxable(), CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable());
    end;
}
