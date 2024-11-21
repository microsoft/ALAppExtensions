codeunit 12207 "Contoso ABI CAB IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "ABI/CAB Codes" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertABICABCode(Abi: Code[5]; Cab: Code[5])
    var
        ABICABCodes: Record "ABI/CAB Codes";
        Exists: Boolean;
    begin
        if ABICABCodes.Get(Abi, Cab) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ABICABCodes.Validate(ABI, Abi);
        ABICABCodes.Validate(CAB, Cab);

        if Exists then
            ABICABCodes.Modify(true)
        else
            ABICABCodes.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}