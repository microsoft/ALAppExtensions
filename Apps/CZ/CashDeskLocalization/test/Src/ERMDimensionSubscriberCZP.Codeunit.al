codeunit 148075 "ERM Dimension Subscriber CZP"
{
    var
        LibraryDimension: Codeunit "Library - Dimension";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnGetLocalTablesWithDimSetIDValidationIgnored', '', false, false)]
    local procedure GetCountOfLocalTablesWithDimSetIDValidationIgnored(var CountOfTablesIgnored: Integer)
    begin
        // Specifies how many tables with "Dimension Set ID" field related to "Dimension Set Entry" table should not have OnValidate trigger which updates shortcut dimensions
        CountOfTablesIgnored += 2;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal', '', false, false)]
    local procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        // Verifies local tables with "Dimension Set ID" field related to "Dimension Set Entry" and OnValidate trigger which updates shortcut dimensions
        LibraryDimension.VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(
          TempAllObj, CashDocumentHeaderCZP, CashDocumentHeaderCZP.FieldNo("Dimension Set ID"),
          CashDocumentHeaderCZP.FieldNo("Shortcut Dimension 1 Code"), CashDocumentHeaderCZP.FieldNo("Shortcut Dimension 2 Code"),
          DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
        LibraryDimension.VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(
          TempAllObj, CashDocumentLineCZP, CashDocumentLineCZP.FieldNo("Dimension Set ID"),
          CashDocumentLineCZP.FieldNo("Shortcut Dimension 1 Code"), CashDocumentLineCZP.FieldNo("Shortcut Dimension 2 Code"),
          DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnGetTableNosWithGlobalDimensionCode', '', false, false)]
    local procedure AddingLocalTable(var TableBuffer: Record "Integer" temporary)
    begin
        AddTable(TableBuffer, Database::"Cash Desk Event CZP");
    end;

    local procedure AddTable(var TempInteger: Record "Integer" temporary; TableID: Integer)
    begin
        if not TempInteger.Get(TableID) then begin
            TempInteger.Number := TableID;
            TempInteger.Insert();
        end;
    end;
}
