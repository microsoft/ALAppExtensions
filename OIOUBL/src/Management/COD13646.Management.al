// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13646 "OIOUBL-Management"
{
    var
        XmlFilterTxt: Label 'XML File(*.xml)|*.xml', Locked = true;

    procedure ExportXMLFile(DocNo: Code[20]; SourceFile: Text[1024]; FolderPath: Text);
    var
        FileManagement: Codeunit 419;
        OIOUBLFileEvents: Codeunit "OIOUBL-File Events";
        FilePath: Text;
        FileName: Text;
    begin
        FileName := STRSUBSTNO('%1.xml', DocNo);
        FolderPath := DelChr(FolderPath, '>', '\');

        OIOUBLFileEvents.FileCreated(SourceFile);

        if not ExportFileFromEvent(SourceFile) and FileManagement.CanRunDotNetOnClient() then begin
            FilePath := FileManagement.DownloadTempFile(SourceFile);
            FileManagement.CopyClientFile(FilePath, STRSUBSTNO('%1\%2', FolderPath, FileName), true);
        end else
            DOWNLOAD(SourceFile, '', FolderPath, XmlFilterTxt, FileName);
    end;

    procedure IsOIOUBLCheckRequired(GLN: Code[13]; CustomerNo: Code[20]): Boolean;
    var
        Customer: Record 18;
        DocumentSendingProfile: Record 60;
    begin
        if GLN = '' then
            exit(FALSE);

        if NOT Customer.GET(CustomerNo) then
            exit(FALSE);

        if DocumentSendingProfile.GET(Customer."Document Sending Profile") then
            exit(IsOIOUBLSendingProfile(DocumentSendingProfile));

        DocumentSendingProfile.SETRANGE(Default, TRUE);
        if DocumentSendingProfile.FindFirst() then
            exit(IsOIOUBLSendingProfile(DocumentSendingProfile));

        exit(FALSE);
    end;

    local procedure IsOIOUBLSendingProfile(DocumentSendingProfile: Record 60): Boolean;
    begin
        exit(
          (DocumentSendingProfile."Electronic Format" = 'OIOUBL') OR
          (DocumentSendingProfile."E-Mail Format" = 'OIOUBL') OR
          (DocumentSendingProfile."Disk Format" = 'OIOUBL'));
    end;

    local procedure ExportFileFromEvent(SourceFile: Text[1024]) IsExported: Boolean;
    var
        OutputBlob: Record TempBlob temporary;
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.BLOBImportFromServerFile(OutputBlob, SourceFile);
        OnBeforeExportFile(OutputBlob, IsExported);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportFile(var OutputBlob: Record TempBlob; var IsExported: Boolean);
    begin
    end;
}