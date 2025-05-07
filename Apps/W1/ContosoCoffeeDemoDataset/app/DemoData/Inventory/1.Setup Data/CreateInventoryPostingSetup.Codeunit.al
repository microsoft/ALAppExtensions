// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 5387 "Create Inventory Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateLocation: Codeunit "Create Location";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
    end;
}
