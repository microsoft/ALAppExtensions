namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Vendor;

codeunit 139889 "Item Reference Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemVendor: Record "Item Vendor";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        Vendor: Record Vendor;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemReference: Codeunit "Library - Item Reference";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";

    #region Tests

    [Test]
    procedure ExpectErrorOnChangeServiceCommitmentOption()
    begin
        Initialize();
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemVendor.Init();
        ItemVendor.Validate("Item No.", Item."No.");
        ItemVendor.Validate("Vendor No.", Vendor."No.");
        ItemVendor.Insert(true);
        asserterror ItemVendor.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
    end;

    [Test]
    procedure ExpectErrorOnValidateItemReferenceWithNonServiceCommitmentItem()
    begin
        Initialize();
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemReference.Init();
        ItemReference.Validate("Item No.", Item."No.");
        ItemReference.Validate("Reference Type", Enum::"Item Reference Type"::Vendor);
        ItemReference.Validate("Reference Type No.", Vendor."No.");
        asserterror ItemReference.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
    end;

    [Test]
    procedure ExpectErrorOnValidateItemVendorWithNonServiceCommitmentItem()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemVendor.Init();
        ItemVendor.Validate("Item No.", Item."No.");
        ItemVendor.Validate("Vendor No.", Vendor."No.");
        ItemVendor.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemVendor.Insert(true);
        asserterror Item.Validate("Subscription Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
    end;

    [Test]
    procedure TestItemReferenceSyncWithItemVendorOnValidate()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        LibraryItemReference.CreateItemReference(ItemReference, Item."No.", Enum::"Item Reference Type"::Vendor, Vendor."No.");
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);
        ItemReference.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemReference.Modify(true);
        ItemVendor.Get(Vendor."No.", ItemReference."Item No.", ItemReference."Variant Code");
        ItemVendor.TestField("Supplier Ref. Entry No.", ItemReference."Supplier Ref. Entry No.");
    end;

    [Test]
    procedure TestItemVendorSyncWithItemReferenceOnInsert()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemVendor.Init();
        ItemVendor.Validate("Item No.", Item."No.");
        ItemVendor.Validate("Vendor No.", Vendor."No.");
        ItemVendor.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemVendor.Insert(true);

        ItemReference.FindLast();
        ItemReference.TestField("Supplier Ref. Entry No.", ItemReference."Supplier Ref. Entry No.");
    end;

    [Test]
    procedure TestItemVendorSyncWithItemReferenceOnValidate()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemVendor.Init();
        ItemVendor.Validate("Item No.", Item."No.");
        ItemVendor.Validate("Vendor No.", Vendor."No.");
        ItemVendor.Insert(true);
        ItemVendor.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemVendor.Modify(false);

        ItemReference.FindLast();
        ItemReference.TestField("Supplier Ref. Entry No.", ItemReference."Supplier Ref. Entry No.");
    end;

    #endregion Tests

    #region Procedures

    local procedure CreateUsageDataSupplier()
    begin
        UsageDataSupplier.Init();
        UsageDataSupplier."No." := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(UsageDataSupplier."No."));
        UsageDataSupplier.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataSupplier."No."));
        UsageDataSupplier.Insert(false);
    end;

    local procedure Initialize()
    begin
        ClearAll();
        UsageDataSupplierReference.Reset();
        UsageDataSupplierReference.DeleteAll(false);
        UsageDataSupplier.Reset();
        UsageDataSupplier.DeleteAll(false);
        ItemVendor.Reset();
        ItemVendor.DeleteAll(false);
    end;

    #endregion Procedures

}
