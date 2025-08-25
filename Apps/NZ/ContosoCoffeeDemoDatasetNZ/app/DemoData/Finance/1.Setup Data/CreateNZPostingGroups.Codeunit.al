// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.DemoTool.Helpers;

codeunit 17121 "Create NZ Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    begin
        InsertGenProdPostingGroup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenBusinessPostingGroup(var Rec: Record "Gen. Business Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateNZVATPostingGroups: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec.Code of
            CreatePostingGroups.EUPostingGroup():
                Rec.Validate("Def. VAT Bus. Posting Group", CreateNZVATPostingGroups.MISC());
        end;
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreateVATPostingGroups.NoVAT(), MiscellaneousWithoutVatLbl, CreateVATPostingGroups.NoVAT());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure InsertGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreateVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreateVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreateVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    var
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}
