// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.WithholdingTax;

codeunit 148320 "Library - Withholding Tax"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";

    procedure CreateWHTBusinessPostingGroup(var WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group")
    begin
        WHTBusinessPostingGroup.Init();
        WHTBusinessPostingGroup.Validate(Code, LibraryUtility.GenerateRandomCode(WHTBusinessPostingGroup.FieldNo(Code), Database::"Wthldg. Tax Bus. Post. Group"));
        WHTBusinessPostingGroup.Insert(true);
    end;

    procedure CreateWHTProductPostingGroup(var WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group")
    begin
        WHTProductPostingGroup.Init();
        WHTProductPostingGroup.Validate(Code, LibraryUtility.GenerateRandomCode(WHTProductPostingGroup.FieldNo(Code), Database::"Wthldg. Tax Prod. Post. Group"));
        WHTProductPostingGroup.Insert(true);
    end;

    procedure CreateWHTPostingSetup(var WHTPostingSetup: Record "Withholding Tax Posting Setup"; WHTBusinessPostingGroup: Code[20]; WHTProductPostingGroup: Code[20])
    begin
        WHTPostingSetup.Init();
        WHTPostingSetup.Validate("Wthldg. Tax Bus. Post. Group", WHTBusinessPostingGroup);
        WHTPostingSetup.Validate("Wthldg. Tax Prod. Post. Group", WHTProductPostingGroup);
        WHTPostingSetup.Insert(true);
    end;

    procedure CreateWHTRevenueTypes(var WHTRevenueTypes: Record "Withholding Tax Revenue Types")
    begin
        WHTRevenueTypes.Init();
        WHTRevenueTypes.Validate(
          Code, LibraryUtility.GenerateRandomCode(WHTRevenueTypes.FieldNo(Code), DATABASE::"Withholding Tax Revenue Types"));
        WHTRevenueTypes.Insert(true);
    end;

    procedure CreateWHTPostingSetupWithPayableGLAccounts(var WHTPostingSetup: Record "Withholding Tax Posting Setup")
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
        WHTRevenueTypes: Record "Withholding Tax Revenue Types";
    begin
        CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        CreateWHTProductPostingGroup(WHTProductPostingGroup);
        CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code);
        CreateWHTRevenueTypes(WHTRevenueTypes);

        WHTPostingSetup.Validate("Wthldg. Tax Calculation Rule", WHTPostingSetup."Wthldg. Tax Calculation Rule"::"Less than");
        WHTPostingSetup.Validate("Wthldg. Tax Min. Inv. Amount", 0);
        WHTPostingSetup.Validate("Withholding Tax %", LibraryRandom.RandDec(100, 2));
        WHTPostingSetup.Validate("Realized Withholding Tax Type", WHTPostingSetup."Realized Withholding Tax Type"::Payment);
        WHTPostingSetup.Validate("Payable Wthldg. Tax Acc. Code", LibraryERM.CreateGLAccountNo());
        WHTPostingSetup.Validate("Bal. Payable Account Type", WHTPostingSetup."Bal. Payable Account Type"::"G/L Account");
        WHTPostingSetup.Validate("Bal. Payable Account No.", LibraryERM.CreateGLAccountNo());
        WHTPostingSetup.Validate("Purch. Wthldg. Tax Adj. Acc No", LibraryERM.CreateGLAccountNo());
        WHTPostingSetup.Validate("Revenue Type", WHTRevenueTypes.Code);
        WHTPostingSetup.Modify(true);
    end;

    procedure CreateVendorWithBusPostingGroups(GenBusPostingGroupCode: Code[20]; VATBusPostingGroupCode: Code[20]; WHTBusPostingGroupCode: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(LibraryPurchase.CreateVendorWithBusPostingGroups(GenBusPostingGroupCode, VATBusPostingGroupCode));
        Vendor."Wthldg. Tax Bus. Post. Group" := WHTBusPostingGroupCode;
        Vendor.Modify();
        exit(Vendor."No.");
    end;

    procedure CreateItemNoWithPostingSetup(GenProdPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; WHTProdPostingGroupCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(LibraryInventory.CreateItemNoWithPostingSetup(GenProdPostingGroupCode, VATProdPostingGroupCode));
        Item."Wthldg. Tax Prod. Post. Group" := WHTProdPostingGroupCode;
        Item.Modify();
        exit(Item."No.");
    end;
}