codeunit 11402 "Contoso Miscellaneous BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Area" = rim,
        tabledata "Export Protocol" = rim,
        tabledata "IBLC/BLWI Transaction Code" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertArea(Code: Code[10]; Description: Text[50])
    var
        AreaBE: Record "Area";
        Exists: Boolean;
    begin
        if AreaBE.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AreaBE.Validate(Code, Code);
        AreaBE.Validate(Text, Description);

        if Exists then
            AreaBE.Modify(true)
        else
            AreaBE.Insert(true);
    end;

    procedure InsertExportProtocol(Code: Code[20]; Description: Text[50]; CheckObjectID: Integer; ExportObjectID: Integer; ExportObjectType: Option; CodeExpenses: Option)
    var
        ExportProtocol: Record "Export Protocol";
        Exists: Boolean;
    begin
        if ExportProtocol.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ExportProtocol.Validate(Code, Code);
        ExportProtocol.Validate(Description, Description);
        if CheckObjectID <> 0 then
            ExportProtocol.Validate("Check Object ID", CheckObjectID);
        ExportProtocol.Validate("Export Object Type", ExportObjectType);
        ExportProtocol.Validate("Export Object ID", ExportObjectID);
        ExportProtocol.Validate("Code Expenses", CodeExpenses);

        if Exists then
            ExportProtocol.Modify(true)
        else
            ExportProtocol.Insert(true);
    end;

    procedure InsertIBLCBLWITransactionCode(TransactionCode: Code[3]; Description: Text[132])
    var
        IBLCBLWITransactionCode: Record "IBLC/BLWI Transaction Code";
        Exists: Boolean;
    begin
        if IBLCBLWITransactionCode.Get(TransactionCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IBLCBLWITransactionCode.Validate("Transaction Code", TransactionCode);
        IBLCBLWITransactionCode.Validate(Description, Description);

        if Exists then
            IBLCBLWITransactionCode.Modify(true)
        else
            IBLCBLWITransactionCode.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}