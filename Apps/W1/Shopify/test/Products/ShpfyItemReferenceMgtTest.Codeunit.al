// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

codeunit 139602 "Shpfy Item Reference Mgt. Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateItemBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a barcode for an item and check if this bar code exists in the "Item Reference" table.

        // [GIVEN] Item."No."
        Item := ProductInitTest.CreateItem();
        // [GIVEN] VariantCode
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        // [GIVEN] UoM
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        // [GIVEN] BarCode
        BarCode := CopyStr(Any.AlphanumericText(MaxStrLen(BarCode)), 1, MaxStrLen(BarCode));

        // [WHEN] Invoke ItemReferenceMgt.CreateItemBarCode(Item."No."", VariantCode, UoM, BarCode)
        ItemReferenceMgt.CreateItemBarCode(Item."No.", VariantCode, UoM, BarCode);

        // [THEN] Find the Item Reference record with the barcode.
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", BarCode);
        LibraryAssert.RecordIsNotEmpty(ItemReference);

        if ItemReference.FindFirst() then begin
            // [THEN] ItemReference."Item No." = Item."No."
            LibraryAssert.AreEqual(Item."No.", ItemReference."Item No.", 'ItemReference."Item No." = ItemNo');

            // [THEN] Item Reference."Variant Code" = VariantCode
            LibraryAssert.AreEqual(VariantCode, ItemReference."Variant Code", 'Item Reference."Variant Code" = VariantCode');
        end;
    end;

    [Test]
    procedure UnitTestCreateItemReference()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        VendorNo: Code[20];
        VendorItemNo: Code[50];
    begin
        // [SCENARION] Create a vendor item no. reference for an item and check if this reference exists in the "Item Reference" table.

        // [GIVEN] Item."No."
        Item := ProductInitTest.CreateItem();
        // [GIVEN] VariantCode
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        // [GIVEN] UoM
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] VendorNo
        VendorNo := CopyStr(Any.AlphabeticText(MaxStrLen(VendorNo)), 1, MaxStrLen(VendorNo));
        // [GIVEN] VendorItemNo
        VendorItemNo := CopyStr(Any.AlphanumericText(MaxStrLen(VendorItemNo)), 1, MaxStrLen(VendorItemNo));

        // [WHEN] Invoke ItemReferenceMgt.CreateItemBarCode(Item."No."", VariantCode, UoM, BarCode)
        ItemReferenceMgt.CreateItemReference(Item."No.", VariantCode, UoM, "Item Reference Type"::Vendor, VendorNo, VendorItemNo);

        // [THEN] Find the Item Reference record with the VendorItemNo.
        ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference No.", VendorItemNo);
        LibraryAssert.RecordIsNotEmpty(ItemReference);

        if ItemReference.FindFirst() then begin
            // [THEN] ItemReference."Item No." = Item."No."
            LibraryAssert.AreEqual(Item."No.", ItemReference."Item No.", 'ItemReference."Item No." = ItemNo');

            // [THEN] Item Reference."Variant Code" = VariantCode
            LibraryAssert.AreEqual(VariantCode, ItemReference."Variant Code", 'Item Reference."Variant Code" = VariantCode');
        end;
    end;

    [Test]
    procedure UnitTestFindByBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        Result: boolean;
        FoundVariantCode: Code[10];
        UoM: Code[10];
        VariantCode: Code[10];
        FoundItemNo: Code[20];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a bar code reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ProductInitTest.CreateItem();
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        BarCode := CopyStr(Any.AlphabeticText(MaxStrLen(BarCode)), 1, MaxStrLen(BarCode));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Bar Code";
        ItemReference."Reference No." := BarCode;
        ItemReference.Insert();

        // [GIVEN] BarCode
        // [GIVEN] UoM
        // [GIVEN] FoundItemNo as output
        // [GIVEN] FoundVariantCode as output

        // [WHEN] Invoke ItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode);

        // [THEN] Result is true
        LibraryAssert.IsTrue(Result, 'Result = true');

        // [THEN] FoundItemNo = Item."No."
        LibraryAssert.AreEqual(Item."No.", FoundItemNo, 'FoundItemNo = Item."No."');

        // [THEN] FoundVariantCode = VariantCode
        LibraryAssert.AreEqual(VariantCode, FoundVariantCode, 'FoundVariantCode = VariantCode');
    end;

    [Test]
    procedure UnitTestFindByReference()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        Result: boolean;
        FoundVariantCode: Code[10];
        UoM: Code[10];
        VariantCode: Code[10];
        FoundItemNo: Code[20];
        ReferenceNo: Code[50];
    begin
        // [SCENARION] Create a vendor item reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ProductInitTest.CreateItem();
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        ReferenceNo := CopyStr(Any.AlphabeticText(MaxStrLen(ReferenceNo)), 1, MaxStrLen(ReferenceNo));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Vendor";
        ItemReference."Reference Type No." := CopyStr(Any.AlphabeticText(MaxStrLen(ItemReference."Reference Type No.")), 1, MaxStrLen(ItemReference."Reference Type No."));
        ItemReference."Reference No." := ReferenceNo;
        ItemReference.Insert();

        // [GIVEN] ReferenceNo
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] UoM
        // [GIVEN] FoundItemNo as output
        // [GIVEN] FoundVariantCode as output

        // [WHEN] Invoke ItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode);

        // [THEN] Result is true
        LibraryAssert.IsTrue(Result, 'Result = true');

        // [THEN] FoundItemNo = Item."No."
        LibraryAssert.AreEqual(Item."No.", FoundItemNo, 'FoundItemNo = Item."No."');

        // [THEN] FoundVariantCode = VariantCode
        LibraryAssert.AreEqual(VariantCode, FoundVariantCode, 'FoundVariantCode = VariantCode');
    end;

    [Test]
    procedure UnitTestGetItemBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        Result: Code[50];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a bar code reference for an item and check if get the bar code with the function GetItemBarcode.

        Item := ProductInitTest.CreateItem();
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        BarCode := CopyStr(Any.AlphabeticText(MaxStrLen(BarCode)), 1, MaxStrLen(BarCode));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Bar Code";
        ItemReference."Reference No." := BarCode;
        ItemReference.Insert();

        // [GIVEN] Item."No."
        // [GIVEN] VariantCode
        // [GIVEN] UoM

        // [WHEN] Invoke ItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := CopyStr(ItemReferenceMgt.GetItemBarcode(Item."No.", VariantCode, UoM), 1, MaxStrLen(Result));

        // [THEN] Result = BarCode
        LibraryAssert.AreEqual(BarCode, Result, 'Result = BarCode');
    end;

    [Test]
    procedure UnitTestGetItemReference()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        ReferenceNo: Code[50];
        Result: Code[50];
    begin
        // [SCENARION] Create a vendor item reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ProductInitTest.CreateItem();
        VariantCode := CopyStr(Any.AlphabeticText(MaxStrLen(VariantCode)), 1, MaxStrLen(VariantCode));
        UoM := CopyStr(Any.AlphabeticText(MaxStrLen(UoM)), 1, MaxStrLen(UoM));
        ReferenceNo := CopyStr(Any.AlphabeticText(MaxStrLen(ReferenceNo)), 1, MaxStrLen(ReferenceNo));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Vendor";
        ItemReference."Reference Type No." := CopyStr(Any.AlphabeticText(MaxStrLen(ItemReference."Reference Type No.")), 1, MaxStrLen(ItemReference."Reference Type No."));
        ItemReference."Reference No." := ReferenceNo;
        ItemReference.Insert();

        // [GIVEN] Item."No."
        // [GIVEN] VariantCode
        // [GIVEN] UoM
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] ItemReference."Reference Type No."

        // [WHEN] Invoke ItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ItemReferenceMgt.GetItemReference(Item."No.", VariantCode, UoM, "Item Reference Type"::Vendor, ItemReference."Reference Type No.");

        // [THEN] Result = ReferenceNo
        LibraryAssert.AreEqual(ReferenceNo, Result, 'Result = ReferenceNo');
    end;
}
