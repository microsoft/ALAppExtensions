namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

codeunit 139887 "Templates Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplateServiceCommitmentPackage: Record "Item Templ. Serv. Comm. Pack.";
        NonstockItem: Record "Nonstock Item";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryTemplates: Codeunit "Library - Templates";

    #region Tests

    [Test]
    procedure CheckIfItemTemplateFieldIsTransferredToItem()
    var
        i: Integer;
        ItemValueTxt: Label 'Item should have the same value for %1 as the Item Template.', Locked = true;
    begin
        // Check if new field is part of the item after creating from item template
        for i := 1 to 3 do begin
            LibraryTemplates.CreateItemTemplateWithData(ItemTempl);
            if i in [2, 3] then // Enum::"Item Service Commitment Type"::::"Service Commitment Item", Enum::"Item Service Commitment Type"::::"Invoicing Item"
                ItemTempl.Validate(Type, ItemTempl.Type::"Non-Inventory");
            ItemTempl.Validate("Service Commitment Option", Enum::"Item Service Commitment Type".FromInteger(i));
            ItemTempl.Modify(false);
            Item.Init();
            Item."No." := '';
            Item.Insert(true);
            ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl, true);
            Assert.AreEqual(ItemTempl."Service Commitment Option", Item."Service Commitment Option", StrSubstNo(ItemValueTxt, Item.FieldCaption("Service Commitment Option")));
        end;
    end;

    [Test]
    procedure CheckIfItemTemplatesServiceCommitmentPackagesAreDeletedFromItemTemplate()
    begin
        TestItemTemplatesServiceCommitmentPackagesAreDeletedFromItemTemplate("Item Service Commitment Type"::"Sales without Service Commitment");
        TestItemTemplatesServiceCommitmentPackagesAreDeletedFromItemTemplate("Item Service Commitment Type"::"Invoicing Item");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckItemServiceCommitmentPackageForItemCreatedFromNonstockItemUsingItemTemplate()
    begin
        // [GIVEN] Create service commitment package, item template, and assign service commitment packages to item template
        SetupItemTemplateServiceCommitmentPackage();
        // [WHEN] Create Item from catalog item
        TestItemCreatedFromNonstockItemUsingItemTemplate();
        ItemTempl.Validate("Service Commitment Option", "Item Service Commitment Type"::"Service Commitment Item");
        ItemTempl.Modify(false);
        TestItemCreatedFromNonstockItemUsingItemTemplate();
    end;

    [Test]
    procedure CheckItemServiceCommitmentPackageForCreatedItemUsingItemTemplate()
    var
        IsHandled: Boolean;
    begin
        // [GIVEN] Create service commitment package, item template, and assign service commitment packages to item template
        SetupItemTemplateServiceCommitmentPackage();
        // [WHEN] Create Item from item template
        ItemTemplMgt.CreateItemFromTemplate(Item, IsHandled, ItemTempl.Code);
        // [THEN] Check if Service commitment packages are assigned to item, and other fields from item template
        TestItemServiceCommitmentPackageFromItemTempl(Item."No.");
        Assert.AreEqual(ItemTempl."Service Commitment Option", Item."Service Commitment Option", 'Service Commitment Option from Item template is not transferred to Item.');

        Clear(Item);
        ItemTempl.Validate("Service Commitment Option", "Item Service Commitment Type"::"Service Commitment Item");
        ItemTempl.Modify(false);
        ItemTemplMgt.CreateItemFromTemplate(Item, IsHandled, ItemTempl.Code);
        Assert.AreEqual(ItemTempl."Service Commitment Option", Item."Service Commitment Option", 'Service Commitment Option from Item template is not transferred to Item.');

        Clear(Item);
        ItemTempl.Validate("Service Commitment Option", "Item Service Commitment Type"::"Invoicing Item");
        ItemTempl.Modify(false);
        ItemTemplMgt.CreateItemFromTemplate(Item, IsHandled, ItemTempl.Code);
        Assert.AreEqual(ItemTempl."Service Commitment Option", Item."Service Commitment Option", 'Service Commitment Option from Item template is not transferred to Item.');
    end;

    #endregion Tests

    #region Procedures

    local procedure InsertItemTemplateServiceCommitmentPackage()
    begin
        if ServiceCommitmentPackage.FindSet() then
            repeat
                ItemTemplateServiceCommitmentPackage.Init();
                ItemTemplateServiceCommitmentPackage.Validate(Code, ServiceCommitmentPackage.Code);
                ItemTemplateServiceCommitmentPackage.Validate("Item Template Code", ItemTempl.Code);
                ItemTemplateServiceCommitmentPackage.Validate(Standard, true);
                ItemTemplateServiceCommitmentPackage.Insert(false);
            until ServiceCommitmentPackage.Next() = 0;
    end;

    local procedure SetupItemTemplateServiceCommitmentPackage()
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentPackage.DeleteAll(true);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        LibraryTemplates.CreateItemTemplateWithData(ItemTempl);
        ItemTempl.Validate("Inventory Posting Group", '');
        ItemTempl.Validate(Type, "Item Type"::"Non-Inventory");
        ItemTempl.Validate("Service Commitment Option", "Item Service Commitment Type"::"Sales with Service Commitment");
        ItemTempl.Modify(false);
        InsertItemTemplateServiceCommitmentPackage();
        ItemTemplateServiceCommitmentPackage.Reset();
        ItemTemplateServiceCommitmentPackage.SetRange("Item Template Code", ItemTempl.Code);
        ItemTemplateServiceCommitmentPackage.FindSet();
    end;

    local procedure TestItemCreatedFromNonstockItemUsingItemTemplate()
    begin
        LibraryInventory.CreateNonStockItemWithItemTemplateCode(NonstockItem, ItemTempl.Code); // MessageHandler
        // [THEN] Check if Service commitment packages are assigned to item, and other fields from item template
        NonstockItem.Get(NonstockItem."Entry No.");
        Item.Get(NonstockItem."Item No.");
        TestItemServiceCommitmentPackageFromItemTempl(Item."No.");
        Assert.AreEqual(ItemTempl."Service Commitment Option", Item."Service Commitment Option", 'Service Commitment Option from Item template is not transferred to Item.');
    end;

    local procedure TestItemTemplatesServiceCommitmentPackagesAreDeletedFromItemTemplate(ServiceCommitmentOption: Enum "Item Service Commitment Type")
    begin
        // [GIVEN] Create service commitment package, item template, nonstock item and assigned service commitment packages to item template
        SetupItemTemplateServiceCommitmentPackage();
        // [WHEN] Change Service Commitment Option
        ItemTempl.Validate("Service Commitment Option", ServiceCommitmentOption);
        // [THEN] check if all the records are deleted
        ItemTemplateServiceCommitmentPackage.Reset();
        ItemTemplateServiceCommitmentPackage.SetRange("Item Template Code", ItemTempl.Code);
        Assert.RecordIsEmpty(ItemTemplateServiceCommitmentPackage);
    end;

    local procedure TestItemServiceCommitmentPackageFromItemTempl(ItemNo: Code[20])
    var
        ItemServiceCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        ItemTemplateServiceCommitmentPackage.SetRange("Item Template Code", ItemTempl.Code);
        ItemTemplateServiceCommitmentPackage.FindSet();
        repeat
            ItemServiceCommitmentPackage.Get(ItemNo, ItemTemplateServiceCommitmentPackage.Code);
            Assert.AreEqual(ItemTemplateServiceCommitmentPackage.Standard, ItemServiceCommitmentPackage.Standard, 'Service Commitment Package is not transferred to the Item.');
        until ItemTemplateServiceCommitmentPackage.Next() = 0;
    end;

    #endregion Procedures

    #region Handlers

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    #endregion Handlers
}
