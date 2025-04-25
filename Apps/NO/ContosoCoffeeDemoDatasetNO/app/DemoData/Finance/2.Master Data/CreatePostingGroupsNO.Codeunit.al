// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 10708 "Create Posting Groups NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenPostingGroup();
        InsertGenBusinessPostingGroup();
    end;

    local procedure InsertGenPostingGroup()
    var
        CreateVATPostingGroupsNO: Codeunit "Create VAT Posting Groups NO";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVatPostingGroup(), NoVatDescriptionLbl, CreateVATPostingGroupsNO.Without());

        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.FreightPostingGroup(), FreightDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.MiscPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RawMatPostingGroup(), RawMatDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RetailPostingGroup(), RetailDescriptionLbl, CreateVATPostingGroupsNO.High());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.ServicesPostingGroup(), ServicesDescriptionLbl, CreateVATPostingGroupsNO.Low());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupsNO: Codeunit "Create VAT Posting Groups NO";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(CustDom(), CustDomDesLbl, CreateVATPostingGroupsNO.CUSTHIGH());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(CustFor(), CustForDesLbl, CreateVATPostingGroupsNO.CUSTNOVAT());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(VendDom(), VendDomDesLbl, CreateVATPostingGroupsNO.VENDHIGH());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(VendFor(), VendForDesLbl, CreateVATPostingGroupsNO.VENDNOVAT());
    end;

    procedure CustDom(): Code[20]
    begin
        exit(CustDomTok);
    end;

    procedure CustFor(): Code[20]
    begin
        exit(CustForTok);
    end;

    procedure VendDom(): Code[20]
    begin
        exit(VendDomTok);
    end;

    procedure VendFor(): Code[20]
    begin
        exit(VendForTok);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVatPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), NoVatPostingGroup(), CreateGLAccount.SalesRawMaterialsDom(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustDom(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), NoVatPostingGroup(), CreateGLAccount.SalesRawMaterialsDom(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CustFor(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), NoVatPostingGroup(), '', CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), CreatePostingGroups.RetailPostingGroup(), '', CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendDom(), CreatePostingGroups.ServicesPostingGroup(), '', CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), NoVatPostingGroup(), '', CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), CreatePostingGroups.RetailPostingGroup(), '', CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(VendFor(), CreatePostingGroups.ServicesPostingGroup(), '', CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoVatPostingGroup(): Code[20]
    begin
        exit(NoVatTok);
    end;

    var
        NoVatTok: Label 'NO VAT', Locked = true, MaxLength = 20;
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        FreightDescriptionLbl: Label 'Freight, etc.', MaxLength = 100;
        MiscDescriptionLbl: Label 'Miscellaneous with VAT', MaxLength = 100;
        RawMatDescriptionLbl: Label 'Raw Materials', MaxLength = 100;
        RetailDescriptionLbl: Label 'Retail', MaxLength = 100;
        ServicesDescriptionLbl: Label 'Resources, etc.', MaxLength = 100;
        CustDomTok: Label 'CUSTDOM', MaxLength = 20;
        CustDomDesLbl: Label 'Domestic customers', MaxLength = 100;
        CustForTok: Label 'CUSTFOR', MaxLength = 20;
        CustForDesLbl: Label 'Foreign customers', MaxLength = 100;
        VendDomTok: Label 'VENDDOM', MaxLength = 20;
        VendDomDesLbl: Label 'Domestic vendors', MaxLength = 100;
        VendForTok: Label 'VENDFOR', MaxLength = 20;
        VendForDesLbl: Label 'Foreign vendors', MaxLength = 100;
}
