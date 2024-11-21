codeunit 17150 "Contoso AU County"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata County = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCounty(Name: Text[30]; Description: Text[30])
    var
        County: Record County;
        Exists: Boolean;
    begin
        if County.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        County.Validate(Name, Name);
        County.Validate(Description, Description);

        if Exists then
            County.Modify(true)
        else
            County.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}