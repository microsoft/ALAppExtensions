// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 10877 "Create Inv. Posting Setup FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure UpdateInventoryPosting()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateInvPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateLocation: Codeunit "Create Location";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateInvPostingGroup.Resale(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim());
        ContosoPostingSetup.SetOverwriteData(false);
    end;
}
