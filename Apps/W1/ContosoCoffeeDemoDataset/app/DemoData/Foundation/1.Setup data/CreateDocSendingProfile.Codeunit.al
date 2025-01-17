codeunit 5226 "Create Doc Sending Profile"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDocSendingProfile: Codeunit "Contoso Doc. Sending Profile";
    begin
        ContosoDocSendingProfile.InsertDocumentSendingProfile(DefaultDocumentSendingProfile(), DirectToFileLbl, Enum::"Doc. Sending Profile Disk"::PDF, true);
    end;

    procedure DefaultDocumentSendingProfile(): Code[20]
    begin
        exit(DirectFileLbl);
    end;

    var
        DirectFileLbl: label 'DIRECTFILE', MaxLength = 20;
        DirectToFileLbl: Label 'Direct to File', MaxLength = 100;
}