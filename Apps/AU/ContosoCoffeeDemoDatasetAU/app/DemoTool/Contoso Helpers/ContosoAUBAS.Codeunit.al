codeunit 17171 "Contoso AU BAS"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "BAS XML Field ID" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertBASXMLFieldID(XMLFieldID: Text[80]; FieldNo: Integer)
    var
        BASXMLFieldID: Record "BAS XML Field ID";
        Exists: Boolean;
    begin
        if BASXMLFieldID.Get(XMLFieldID) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;
        BASXMLFieldID.Validate("XML Field ID", XMLFieldID);
        BASXMLFieldID.Validate("Field No.", FieldNo);

        if Exists then
            BASXMLFieldID.Modify(true)
        else
            BASXMLFieldID.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}