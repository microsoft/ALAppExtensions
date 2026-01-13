// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11480 "Create Posting Groups US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenProdPostingGroup();
        InsertGeneralPostingSetup();
        UpdateGeneralPostingSetup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(NoTaxPostingGroup(), NoTaxDescriptionLbl, '');
    end;

    local procedure InsertGeneralPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoTaxPostingGroup(), '', '', CreateUSGLAccounts.CostofMaterials(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItems(), '', '', '', '', '', CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NoTaxPostingGroup(), CreateUSGLAccounts.ResaleofGoods(), CreateGLAccount.ResaleItems(), CreateUSGLAccounts.CostofMaterials(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItems(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofMaterials(), '', '');
    end;

    local procedure UpdateGeneralPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateUSGLAccounts.CostofMaterials(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItems(), '', '', '', '', '', CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateUSGLAccounts.CostofMaterials(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItems(), '', '', '', '', '', CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateUSGLAccounts.ResaleofGoods(), CreateGLAccount.ResaleItems(), CreateUSGLAccounts.CostofMaterials(), CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItems(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateUSGLAccounts.SalesofServiceWork(), CreateUSGLAccounts.OtherExternalServices(), CreateUSGLAccounts.CostofLabor(), CreateUSGLAccounts.OtherExternalServices(), CreateUSGLAccounts.OtherExternalServices(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofLabor(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoTaxPostingGroup(): Code[20]
    begin
        exit(NoTaxTok);
    end;

    var
        NoTaxTok: Label 'NO TAX', MaxLength = 20;
        NoTaxDescriptionLbl: Label 'Miscellaneous without tax', MaxLength = 100;
}
