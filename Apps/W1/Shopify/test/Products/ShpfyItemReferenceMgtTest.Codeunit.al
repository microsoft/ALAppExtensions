codeunit 139602 "Shpfy Item Reference Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateItemBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a barcode for an item and check if this bar code exists in the "Item Reference" table.

        // [GIVEN] Item."No."
        Item := ShpfyProductInitTest.CreateItem();
        // [GIVEN] VariantCode
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        // [GIVEN] UoM
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        // [GIVEN] BarCode
        BarCode := Any.AlphanumericText(MaxStrLen(BarCode));

        // [WHEN] Invoke ShpfyItemReferenceMgt.CreateItemBarCode(Item."No."", VariantCode, UoM, BarCode)
        ShpfyItemReferenceMgt.CreateItemBarCode(Item."No.", VariantCode, UoM, BarCode);

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
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        VendorNo: Code[20];
        VendorItemNo: Code[50];
    begin
        // [SCENARION] Create a vendor item no. reference for an item and check if this reference exists in the "Item Reference" table.

        // [GIVEN] Item."No."
        Item := ShpfyProductInitTest.CreateItem();
        // [GIVEN] VariantCode
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        // [GIVEN] UoM
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] VendorNo
        VendorNo := Any.AlphabeticText(MaxStrLen(VendorNo));
        // [GIVEN] VendorItemNo
        VendorItemNo := Any.AlphanumericText(MaxStrLen(VendorItemNo));

        // [WHEN] Invoke ShpfyItemReferenceMgt.CreateItemBarCode(Item."No."", VariantCode, UoM, BarCode)
        ShpfyItemReferenceMgt.CreateItemReference(Item."No.", VariantCode, UoM, "Item Reference Type"::Vendor, VendorNo, VendorItemNo);

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
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        Result: boolean;
        FoundVariantCode: Code[10];
        UoM: Code[10];
        VariantCode: Code[10];
        FoundItemNo: Code[20];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a bar code reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ShpfyProductInitTest.CreateItem();
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        BarCode := Any.AlphabeticText(MaxStrLen(BarCode));
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

        // [WHEN] Invoke ShpfyItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ShpfyItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode);

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
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        Result: boolean;
        FoundVariantCode: Code[10];
        UoM: Code[10];
        VariantCode: Code[10];
        FoundItemNo: Code[20];
        ReferenceNo: Code[50];
    begin
        // [SCENARION] Create a vendor item reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ShpfyProductInitTest.CreateItem();
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        ReferenceNo := Any.AlphabeticText(MaxStrLen(ReferenceNo));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Vendor";
        ItemReference."Reference Type No." := Any.AlphabeticText(MaxStrLen(ItemReference."Reference Type No."));
        ItemReference."Reference No." := ReferenceNo;
        ItemReference.Insert();

        // [GIVEN] ReferenceNo
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] UoM
        // [GIVEN] FoundItemNo as output
        // [GIVEN] FoundVariantCode as output

        // [WHEN] Invoke ShpfyItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ShpfyItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode);

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
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        Result: Code[50];
        BarCode: Code[50];
    begin
        // [SCENARION] Create a bar code reference for an item and check if get the bar code with the function GetItemBarcode.

        Item := ShpfyProductInitTest.CreateItem();
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        BarCode := Any.AlphabeticText(MaxStrLen(BarCode));
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

        // [WHEN] Invoke ShpfyItemReferenceMgt.FindByBarCode(BarCode, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ShpfyItemReferenceMgt.GetItemBarcode(Item."No.", VariantCode, UoM);

        // [THEN] Result = BarCode
        LibraryAssert.AreEqual(BarCode, Result, 'Result = BarCode');
    end;

    [Test]
    procedure UnitTestGetItemReference()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        UoM: Code[10];
        VariantCode: Code[10];
        ReferenceNo: Code[50];
        Result: Code[50];
    begin
        // [SCENARION] Create a vendor item reference for an item and check if this reference exists in the "Item Reference" table.

        Item := ShpfyProductInitTest.CreateItem();
        VariantCode := Any.AlphabeticText(MaxStrLen(VariantCode));
        UoM := Any.AlphabeticText(MaxStrLen(UoM));
        ReferenceNo := Any.AlphabeticText(MaxStrLen(ReferenceNo));
        ItemReference.Init();
        ItemReference."Item No." := Item."No.";
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UoM;
        ItemReference."Reference Type" := "Item Reference Type"::"Vendor";
        ItemReference."Reference Type No." := Any.AlphabeticText(MaxStrLen(ItemReference."Reference Type No."));
        ItemReference."Reference No." := ReferenceNo;
        ItemReference.Insert();

        // [GIVEN] Item."No."
        // [GIVEN] VariantCode
        // [GIVEN] UoM
        // [GIVEN] "Item Reference Type"::Vendor
        // [GIVEN] ItemReference."Reference Type No."

        // [WHEN] Invoke ShpfyItemReferenceMgt.FindByReference(ReferenceNo, "Item Reference Type"::Vendor, UoM, FoundItemNo, FoundVariantCode) and store the result in Result
        Result := ShpfyItemReferenceMgt.GetItemReference(Item."No.", VariantCode, UoM, "Item Reference Type"::Vendor, ItemReference."Reference Type No.");

        // [THEN] Result = ReferenceNo
        LibraryAssert.AreEqual(ReferenceNo, Result, 'Result = ReferenceNo');
    end;
}