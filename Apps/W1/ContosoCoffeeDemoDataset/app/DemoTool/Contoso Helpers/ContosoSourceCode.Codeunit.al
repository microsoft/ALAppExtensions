codeunit 5173 "Contoso Source Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Source Code" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertSourceCode(Code: Text; Description: Text)
    var
        SourceCode: Record "Source Code";
        Exists: Boolean;
    begin
        if SourceCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SourceCode.Validate(Code, Code);
        SourceCode.Validate(Description, Description);

        if Exists then
            SourceCode.Modify(true)
        else
            SourceCode.Insert(true);
    end;
}