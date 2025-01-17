namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Vendor;

codeunit 139889 "Item Reference Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    [Test]
    procedure TestItemReferenceSyncWithItemVendorOnValidate()
    begin
        Reset();
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
    procedure TestItemReferenceSyncWithItemVendorOnInsert()
    begin
        Reset();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemReference.Init();
        ItemReference.Validate("Item No.", Item."No.");
        ItemReference.Validate("Reference Type", Enum::"Item Reference Type"::Vendor);
        ItemReference.Validate("Reference Type No.", Vendor."No.");
        ItemReference.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemReference.Insert(true);

        ItemVendor.Get(Vendor."No.", ItemReference."Item No.", ItemReference."Variant Code");
        ItemVendor.TestField("Supplier Ref. Entry No.", ItemReference."Supplier Ref. Entry No.");
    end;

    [Test]
    procedure ExpectErrorOnValidateItemReferenceWithNonServiceCommitmentItem()
    begin
        Reset();
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
    procedure TestItemVendorSyncWithItemReferenceOnInsert()
    begin
        Reset();
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
        Reset();
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

    [Test]
    procedure ExpectErrorOnValidateItemVendorWithNonServiceCommitmentItem()
    begin
        Reset();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreateVendor(Vendor);
        CreateUsageDataSupplier();
        UsageBasedBTestLibrary.CreateUsageDataSupplierReference(UsageDataSupplierReference, UsageDataSupplier."No.", "Usage Data Reference Type"::Product);

        ItemVendor.Init();
        ItemVendor.Validate("Item No.", Item."No.");
        ItemVendor.Validate("Vendor No.", Vendor."No.");
        ItemVendor.Validate("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
        ItemVendor.Insert(true);
        asserterror Item.Validate("Service Commitment Option", Enum::"Item Service Commitment Type"::"Invoicing Item");
    end;

    [Test]
    procedure ExpectErrorOnChangeServiceCommitmentOption()
    begin
        Reset();
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

    procedure CreateUsageDataSupplier()
    begin
        UsageDataSupplier.Init();
        UsageDataSupplier."No." := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(UsageDataSupplier."No."));
        UsageDataSupplier.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataSupplier."No."));
        UsageDataSupplier.Insert(false);
    end;

    local procedure Reset()
    begin
        ClearAll();
        UsageDataSupplierReference.Reset();
        UsageDataSupplierReference.DeleteAll(false);
        UsageDataSupplier.Reset();
        UsageDataSupplier.DeleteAll(false);
        ItemVendor.Reset();
        ItemVendor.DeleteAll(false);
    end;

    procedure UpdateServiceCommitmentTemplateWithUsageBasedFields(var ServiceCommitmentTemplate: Record "Service Commitment Template"; UsageBasedPricing: Enum "Usage Based Pricing"; PricingUnitCostSurcharPerc: Decimal)
    begin
        ServiceCommitmentTemplate."Usage Based Billing" := true;
        ServiceCommitmentTemplate."Usage Based Pricing" := UsageBasedPricing;
        ServiceCommitmentTemplate."Pricing Unit Cost Surcharge %" := PricingUnitCostSurcharPerc;
        ServiceCommitmentTemplate.Modify(false);
    end;

    var
        Item: Record Item;
        Vendor: Record Vendor;
        ItemReference: Record "Item Reference";
        ItemVendor: Record "Item Vendor";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemReference: Codeunit "Library - Item Reference";
        LibraryPurchase: Codeunit "Library - Purchase";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
}
