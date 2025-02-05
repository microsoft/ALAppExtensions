codeunit 5464 "Contoso Doc. Sending Profile"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Document Sending Profile" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertDocumentSendingProfile("Code": Code[20]; Description: Text[100]; Disk: Enum "Doc. Sending Profile Disk"; Default: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        Exists: Boolean;
    begin
        if DocumentSendingProfile.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DocumentSendingProfile.Validate(Code, Code);
        DocumentSendingProfile.Validate(Description, Description);
        DocumentSendingProfile.Validate(Disk, Disk);
        DocumentSendingProfile.Validate(Default, Default);

        if Exists then
            DocumentSendingProfile.Modify(true)
        else
            DocumentSendingProfile.Insert(true);
    end;
}