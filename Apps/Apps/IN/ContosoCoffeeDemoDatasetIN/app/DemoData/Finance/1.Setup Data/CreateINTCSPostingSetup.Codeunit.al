// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19042 "Create IN TCS Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateINTCSNatureofCollection: Codeunit "Create IN TCS Nature of Coll.";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
    begin
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollection1H(), DMY2Date(1, 10, 2020), CreateINGLAccounts.TCSPayableH());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionA(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableA());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionB(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableB());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionC(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableC());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionD(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableD());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionE(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableE());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionF(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableF());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionG(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableG());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionH(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableH());
        ContosoINTaxSetup.InsertTCSPostingSetup(CreateINTCSNatureofCollection.NatureofCollectionI(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TCSPayableI());
    end;
}
