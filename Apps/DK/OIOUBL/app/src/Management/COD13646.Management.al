// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13646 "OIOUBL-Management"
{
    var
        FileManagement: Codeunit "File Management";
        OIOUBLFormatNameTxt: Label 'OIOUBL', Locked = true;
        InvoiceDocTypeTxt: Label 'Invoice';
        CrMemoDocTypeTxt: Label 'Credit Memo';
        XmlFilterTxt: Label 'XML File(*.xml)|*.xml', Locked = true;
        ZipArchiveFilterTxt: Label 'Zip File (*.zip)|*.zip', Locked = true;
        ZipArchiveSaveDialogTxt: Label 'Export OIOUBL archive';
        NonExistingDocumentFormatErr: Label 'The electronic document format %1 does not exist for the document type %2.';
        WrongFileNameErr: Label 'Wrong file name.';

    procedure ClearRecordExportBuffer()
    var
        RecordExportBuffer: Record "Record Export Buffer";
    begin
        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.DeleteAll();
    end;

    procedure ExportXMLFile(DocNo: Code[20]; SourceFile: Text[1024]; FolderPath: Text);
    var
        OIOUBLFileEvents: Codeunit "OIOUBL-File Events";
        FilePath: Text;
        FileName: Text;
        IsHandled: Boolean;
    begin
        FileName := STRSUBSTNO('%1.xml', DocNo);
        OnExportXMLFileOnAfterSetFileName(FileName, DocNo);
        if (FileName = '') or (StrPos(FileName, '\') > 0) then
            Error(WrongFileNameErr);
        FolderPath := DelChr(FolderPath, '>', '\');

        OIOUBLFileEvents.FileCreated(SourceFile);

        OnExportXMLFileOnBeforeDownload(DocNo, SourceFile, FolderPath, IsHandled);
        if IsHandled then
            exit;

        if FileManagement.IsLocalFileSystemAccessible() then begin
            FilePath := FileManagement.DownloadTempFile(SourceFile);
            FileManagement.CopyClientFile(FilePath, STRSUBSTNO('%1\%2', FolderPath, FileName), true);
        end else
            DOWNLOAD(SourceFile, '', FolderPath, XmlFilterTxt, FileName);
    end;

    procedure GetOIOUBLElectronicDocumentFormatCode(): Code[20];
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        ElectronicDocumentFormat.SetFilter(Code, OIOUBLFormatNameTxt);
        if ElectronicDocumentFormat.FindFirst() then
            exit(ElectronicDocumentFormat.Code);

        exit('');
    end;

    procedure GetDocumentExportPath(RecRef: RecordRef): Text[250];
    var
        SalesSetup: Record "Sales & Receivables Setup";
        ServiceSetup: Record "Service Mgt. Setup";
    begin
        SalesSetup.Get();
        ServiceSetup.Get();
        case RecRef.Number() of
            Database::"Sales Invoice Header":
                exit(SalesSetup."OIOUBL-Invoice Path");
            Database::"Sales Cr.Memo Header":
                exit(SalesSetup."OIOUBL-Cr. Memo Path");
            Database::"Service Invoice Header":
                exit(ServiceSetup."OIOUBL-Service Invoice Path");
            Database::"Service Cr.Memo Header":
                exit(ServiceSetup."OIOUBL-Service Cr. Memo Path");
            else
                exit('');
        end;
    end;

    procedure GetDocumentType(RecRef: RecordRef): Text[50];
    begin
        case RecRef.Number() of
            Database::"Sales Invoice Header", Database::"Service Invoice Header":
                exit(InvoiceDocTypeTxt);
            Database::"Sales Cr.Memo Header", Database::"Service Cr.Memo Header":
                exit(CrMemoDocTypeTxt);
            else
                exit('');
        end;
    end;

    procedure GetExportCodeunitID(DocumentVariant: Variant): Integer;
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        DocumentUsage: Option;
    begin
        ElectronicDocumentFormat.GetDocumentUsage(DocumentUsage, DocumentVariant);
        ElectronicDocumentFormat.SetFilter(Code, GetOIOUBLElectronicDocumentFormatCode());
        ElectronicDocumentFormat.SetRange(Usage, DocumentUsage);
        if ElectronicDocumentFormat.FindFirst() then
            exit(ElectronicDocumentFormat."Codeunit ID")
        else begin
            ElectronicDocumentFormat.Usage := DocumentUsage;
            Error(NonExistingDocumentFormatErr, OIOUBLFormatNameTxt, Format(ElectronicDocumentFormat.Usage));
        end;
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

    procedure IsOIOUBLSendingProfile(DocumentSendingProfile: Record 60): Boolean;
    begin
        exit(
          (DocumentSendingProfile."Electronic Format" = OIOUBLFormatNameTxt) OR
          (DocumentSendingProfile."E-Mail Format" = OIOUBLFormatNameTxt) OR
          (DocumentSendingProfile."Disk Format" = OIOUBLFormatNameTxt));
    end;

    procedure IsStandardExportCodeunitID(ExportCodeunitID: Integer): Boolean;
    begin
        exit(
          ExportCodeunitID in
            [Codeunit::"OIOUBL-Export Sales Invoice",
            Codeunit::"OIOUBL-Export Sales Cr. Memo",
            Codeunit::"OIOUBL-Export Service Invoice",
            Codeunit::"OIOUBL-Export Service Cr.Memo"]);
    end;

    procedure IsAllowedDocumentType(RecRef: RecordRef): Boolean;
    begin
        exit(
          RecRef.Number() in
            [Database::"Sales Invoice Header",
            Database::"Sales Cr.Memo Header",
            Database::"Service Invoice Header",
            Database::"Service Cr.Memo Header"]);
    end;

    procedure UpdateRecordExportBuffer(RecID: RecordID; ServerFilePath: Text[250]; ClientFileName: Text[250]);
    var
        RecordExportBuffer: Record "Record Export Buffer";
    begin
        if RecordExportBuffer.IsEmpty() then
            exit;

        RecordExportBuffer.SetRange(RecordID, RecID);
        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.SetFilter("Electronic Document Format", '');
        if RecordExportBuffer.FindFirst() then begin
            RecordExportBuffer.ServerFilePath := ServerFilePath;
            RecordExportBuffer.ClientFileName := ClientFileName;
            RecordExportBuffer."Electronic Document Format" := GetOIOUBLElectronicDocumentFormatCode();
            RecordExportBuffer.Modify();
        end;
    end;

    procedure WriteLogSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SegManagement: Codeunit SegManagement;
    begin
        if SegManagement.FindInteractTmplCode(4) = '' then
            exit;

        with SalesInvoiceHeader do
            if "Bill-to Contact No." <> '' then
                SegManagement.LogDocument(
                  4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                  "Campaign No.", "Posting Description", '')
            else
                SegManagement.LogDocument(
                  4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                  "Campaign No.", "Posting Description", '');
    end;

    procedure WriteLogSalesCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SegManagement: Codeunit SegManagement;
    begin
        if SegManagement.FindInteractTmplCode(6) = '' then
            exit;

        with SalesCrMemoHeader do
            SegManagement.LogDocument(
                            6, "No.", 0, 0, DATABASE::Customer, "Sell-to Customer No.", "Salesperson Code",
                            "Campaign No.", "Posting Description", '');
    end;

    procedure ZipMultipleXMLFilesInServerFolder(var RecordExportBuffer: Record "Record Export Buffer") ZipFilePath: Text;
    var
        OIOUBLFileEvents: Codeunit "OIOUBL-File Events";
        DataCompression: Codeunit "Data Compression";
        EntryTempBlob: Codeunit "Temp Blob";
        EntryFileInStream: InStream;
        ZipOutStream: OutStream;
        ZipFile: File;
    begin
        if RecordExportBuffer.IsEmpty() then
            exit;

        DataCompression.CreateZipArchive();
        RecordExportBuffer.FindSet();
        repeat
            FileManagement.BLOBImportFromServerFile(EntryTempBlob, RecordExportBuffer.ServerFilePath);
            EntryTempBlob.CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, RecordExportBuffer.ClientFileName);
            FileManagement.DeleteServerFile(RecordExportBuffer.ServerFilePath);
        until RecordExportBuffer.Next() = 0;

        ZipFilePath := FileManagement.ServerTempFileName('zip');
        ZipFile.WriteMode(true);
        ZipFile.Create(ZipFilePath);
        ZipFile.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();
        ZipFile.Close();

        OIOUBLFileEvents.FileCreated(ZipFilePath);
    end;

    procedure DownloadZipFile(ServerZipFilePath: Text; ClientZipFolder: Text; ClientZipFileName: Text);
    var
        TempBlob: Codeunit "Temp Blob";
        ZipInStream: InStream;
    begin
        if FileManagement.IsLocalFileSystemAccessible() then
            FileManagement.CopyServerFile(ServerZipFilePath, StrSubstNo('%1\%2', ClientZipFolder, ClientZipFileName), true)
        else begin
            FileManagement.BLOBImportFromServerFile(TempBlob, ServerZipFilePath);
            TempBlob.CreateInStream(ZipInStream);
            DownloadFromStream(ZipInStream, ZipArchiveSaveDialogTxt, ClientZipFolder, ZipArchiveFilterTxt, ClientZipFileName);
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnExportXMLFileOnBeforeDownload(DocNo: Code[20]; SourceFile: Text; FolderPath: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportXMLFileOnAfterSetFileName(var FileName: Text; DocNo: Code[20])
    begin
    end;
}
