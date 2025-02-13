namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

codeunit 139884 "Item Serv. Comm. Test"
{
    Subtype = Test;
    Access = Internal;

    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        Item: Record Item;
        ContractTestLibrary: Codeunit "Contract Test Library";
        AssignedItems: Page "Assigned Items";
        i: Integer;

    local procedure SetupServiceCommPackageAndServiceCommitmentItem(CreateServiceCommitmentItem: Boolean)
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        if CreateServiceCommitmentItem then
            ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
    end;

    [Test]
    [HandlerFunctions('ItemListModalPageHandler')]
    procedure AssignItemsToServCommPackage()
    begin
        SetupServiceCommPackageAndServiceCommitmentItem(false);
        ContractTestLibrary.UpdateServiceCommitmentPackageWithPriceGroup(ServiceCommitmentPackage, '');
        Commit(); // retain data after asserterror
        for i := 0 to 3 do begin
            ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type".FromInteger(i));
            case Item."Service Commitment Option" of
                Enum::"Item Service Commitment Type"::"Sales without Service Commitment",
                Enum::"Item Service Commitment Type"::"Invoicing Item":
                    asserterror AssignedItems.AssignItems(ServiceCommitmentPackage.Code);
                Enum::"Item Service Commitment Type"::"Sales with Service Commitment",
                Enum::"Item Service Commitment Type"::"Service Commitment Item":
                    begin
                        AssignedItems.AssignItems(ServiceCommitmentPackage.Code);
                        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
                        ServiceCommitmentPackage.TestField("Price Group");
                        ItemServCommitmentPackage.TestField("Price Group", ServiceCommitmentPackage."Price Group");
                    end;
            end;
        end;
    end;

    [Test]
    [HandlerFunctions('ItemServCommitmentPackagesPageHandler')]
    procedure AssignServCommPackageToItems()
    begin
        SetupServiceCommPackageAndServiceCommitmentItem(false);
        ContractTestLibrary.UpdateServiceCommitmentPackageWithPriceGroup(ServiceCommitmentPackage, '');
        Commit(); // retain data after asserterror
        for i := 0 to 3 do begin
            ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type".FromInteger(i));
            case Item."Service Commitment Option" of
                Enum::"Item Service Commitment Type"::"Sales without Service Commitment",
                Enum::"Item Service Commitment Type"::"Invoicing Item":
                    asserterror Item.OpenItemServCommitmentPackagesPage();
                Enum::"Item Service Commitment Type"::"Sales with Service Commitment",
                Enum::"Item Service Commitment Type"::"Service Commitment Item":
                    begin
                        Item.OpenItemServCommitmentPackagesPage();
                        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
                        ServiceCommitmentPackage.TestField("Price Group");
                        ItemServCommitmentPackage.TestField("Price Group", ServiceCommitmentPackage."Price Group");
                    end;
            end;
        end;
    end;

    [Test]
    [HandlerFunctions('ItemListModalPageHandler,ConfirmHandler')]
    procedure CheckServiceCommitmentOptionChange()
    begin
        SetupServiceCommPackageAndServiceCommitmentItem(true);
        AssignedItems.AssignItems(ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Sales without Service Commitment");
        asserterror ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
    end;

    [Test]
    [HandlerFunctions('ItemListModalPageHandler')]
    procedure DeleteServCommPackage()
    begin
        SetupServiceCommPackageAndServiceCommitmentItem(true);
        AssignedItems.AssignItems(ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.Delete(true);
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        asserterror ItemServCommitmentPackage.FindFirst();
    end;

    [ModalPageHandler]
    procedure ItemListModalPageHandler(var ItemList: TestPage "Item List")
    begin
        ItemList.GoToRecord(Item);
        ItemList.OK().Invoke();
    end;

    [PageHandler]
    procedure ItemServCommitmentPackagesPageHandler(var ItemServCommitmentPackages: TestPage "Item Serv. Commitment Packages")
    begin
        ItemServCommitmentPackages.Code.SetValue(ServiceCommitmentPackage.Code);
        ItemServCommitmentPackages.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure RemoveItemsFromServCommPackage()
    begin
        SetupServiceCommPackageAndServiceCommitmentItem(true);
        ItemServCommitmentPackage."Item No." := Item."No.";
        ItemServCommitmentPackage.Code := ServiceCommitmentPackage.Code;
        ItemServCommitmentPackage.Insert(false);
        ItemServCommitmentPackage.SetRecFilter();
        AssignedItems.RemoveItems(ItemServCommitmentPackage);
        asserterror ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}