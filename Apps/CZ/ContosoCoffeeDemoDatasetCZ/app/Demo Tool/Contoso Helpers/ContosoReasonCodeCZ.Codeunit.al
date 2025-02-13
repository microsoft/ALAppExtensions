codeunit 31213 "Contoso Reason Code CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Reason Code" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertReasonCode(Code: Code[20]; Description: Text[100])
    var
        ReasonCode: Record "Reason Code";
        Exists: Boolean;
    begin
        if ReasonCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReasonCode.Validate(Code, Code);
        ReasonCode.Validate("Description", Description);

        if Exists then
            ReasonCode.Modify(true)
        else
            ReasonCode.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}