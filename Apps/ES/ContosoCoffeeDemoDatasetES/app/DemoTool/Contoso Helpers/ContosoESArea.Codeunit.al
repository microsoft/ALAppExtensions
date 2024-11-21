codeunit 10809 "Contoso ES Area"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Area" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertArea(Code: Code[10]; Text: Text[50]; PostCodePrefix: Code[20])
    var
        "Area": Record "Area";
        Exists: Boolean;
    begin
        if Area.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Area.Validate(Code, Code);
        Area.Validate(Text, Text);
        Area.Validate("Post Code Prefix", PostCodePrefix);

        if Exists then
            Area.Modify(true)
        else
            Area.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}