/// <summary>
/// Provides utility functions for creating and managing item references (cross-references) in test scenarios.
/// </summary>
codeunit 132225 "Library - Item Reference"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateItemReference(var ItemReference: Record "Item Reference"; ItemNo: Code[20]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20])
    begin
        CreateItemReferenceWithNo(
            ItemReference, LibraryUtility.GenerateRandomCode(ItemReference.FieldNo("Reference No."), DATABASE::"Item Reference"),
            ItemNo, ReferenceType, ReferenceTypeNo);
    end;

    procedure CreateItemReference(var ItemReference: Record "Item Reference"; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[50])
    begin
        ItemReference.Init();
        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Variant Code", VariantCode);
        ItemReference.Validate("Unit of Measure", UnitOfMeasureCode);
        ItemReference.Validate("Reference Type", ReferenceType);
        ItemReference.Validate("Reference Type No.", ReferenceTypeNo);
        ItemReference.Validate("Reference No.", ReferenceNo);
        ItemReference.Insert(true);
    end;

    procedure CreateItemReferenceWithNo(var ItemReference: Record "Item Reference"; ItemRefNo: Code[50]; ItemNo: Code[20]; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[20])
    begin
        ItemReference.Init();
        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Reference Type", ItemRefType);
        ItemReference.Validate("Reference Type No.", ItemRefTypeNo);
        ItemReference.Validate("Reference No.", ItemRefNo);
        ItemReference.Insert(true);
    end;

    procedure CreateItemReferenceWithNoAndDates(var ItemReference: Record "Item Reference"; ItemRefNo: Code[50]; ItemNo: Code[20]; ItemRefType: Enum "Item Reference Type"; ItemRefTypeNo: Code[20]; StartingDate: Date; EndingDate: Date)
    begin
        CreateItemReferenceWithNo(ItemReference, ItemRefNo, ItemNo, ItemRefType, ItemRefTypeNo);
        ItemReference.Validate("Starting Date", StartingDate);
        ItemReference.Validate("Ending Date", EndingDate);
        ItemReference.Modify(true);
    end;

#if not CLEAN26
    [Obsolete('Functionality is enabled permanently.', '23.0')]
    procedure EnableFeature(Bind: Boolean)
    begin
    end;
#endif

#if not CLEAN26
    [Obsolete('Functionality is enabled permanently.', '23.0')]
    procedure DisableFeature()
    begin
    end;
#endif
}
