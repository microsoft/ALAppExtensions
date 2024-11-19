codeunit 11087 "Contoso DE Post Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Post Code" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertPostCode(Code: Code[20]; City: Text[30]; CountryRegionCode: Code[10]; County: Code[10])
    var
        PostCode: Record "Post Code";
        Exists: Boolean;
    begin
        if PostCode.Get(Code, City) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PostCode.Code := Code;
        PostCode.City := City;
        PostCode."Search City" := City;
        PostCode."Country/Region Code" := CountryRegionCode;
        PostCode.County := County;

        if Exists then
            PostCode.Modify(true)
        else
            PostCode.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}