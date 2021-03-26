codeunit 148078 "ERM Dimension Subscriber CZC"
{
    var
        LibraryDimension: Codeunit "Library - Dimension";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnGetLocalTablesWithDimSetIDValidationIgnored', '', false, false)]
    local procedure GetCountOfLocalTablesWithDimSetIDValidationIgnored(var CountOfTablesIgnored: Integer)
    begin
        // Specifies how many tables with "Dimension Set ID" field related to "Dimension Set Entry" table should not have OnValidate trigger which updates shortcut dimensions
        CountOfTablesIgnored += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal', '', false, false)]
    local procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        // Verifies local tables with "Dimension Set ID" field related to "Dimension Set Entry" and OnValidate trigger which updates shortcut dimensions
        LibraryDimension.VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(
          TempAllObj, CompensationLineCZC, CompensationLineCZC.FieldNo("Dimension Set ID"),
          CompensationLineCZC.FieldNo("Shortcut Dimension 1 Code"), CompensationLineCZC.FieldNo("Shortcut Dimension 2 Code"),
          DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
    end;
}
