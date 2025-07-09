// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 10497 "Create InventoryPostingSetupUS"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure UpdateInventoryPosting()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateLocation: Codeunit "Create Location";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateInvPostingGroup.Resale(), CreateUSGLAccounts.FinishedGoods(), '');
        ContosoPostingSetup.SetOverwriteData(false);
    end;
}
