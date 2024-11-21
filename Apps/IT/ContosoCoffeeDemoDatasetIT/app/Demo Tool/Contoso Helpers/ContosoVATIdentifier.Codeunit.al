codeunit 12220 "Contoso VAT Identifier"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "ABI/CAB Codes" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVATIdentifier(Code: Code[20]; Description: Text[50])
    var
        VATIdentifier: Record "VAT Identifier";
        Exists: Boolean;
    begin
        if VATIdentifier.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATIdentifier.Validate(Code, Code);
        VATIdentifier.Validate(Description, Description);

        if Exists then
            VATIdentifier.Modify(true)
        else
            VATIdentifier.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}