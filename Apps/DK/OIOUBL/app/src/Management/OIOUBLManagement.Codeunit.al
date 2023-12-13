// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.CRM.Contact;
using Microsoft.CRM.Segment;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using Microsoft.Service.History;
using Microsoft.Service.Setup;
using System.IO;
using System.Utilities;

codeunit 13646 "OIOUBL-Management"
{
    var
        FileManagement: Codeunit "File Management";
        OIOUBLFormatNameTxt: Label 'OIOUBL', Locked = true;
        InvoiceDocTypeTxt: Label 'Invoice';
        CrMemoDocTypeTxt: Label 'Credit Memo';
        ZipArchiveFilterTxt: Label 'Zip File (*.zip)|*.zip', Locked = true;
        ZipArchiveSaveDialogTxt: Label 'Export OIOUBL archive';
        NonExistingDocumentFormatErr: Label 'The electronic document format %1 does not exist for the document type %2.', Comment = '%1 - OIOUBL, %2 - Enum "Electronic Document Format Usage"';
        WrongFileNameErr: Label 'Wrong file name.';
        FolderFileLbl: Label '%1\%2', Comment = '%1 - folder name, %2 - file name', Locked = true;
        AddXMLExtensionLbl: Label '%1.xml', Comment = '%1 - file name', Locked = true;

    procedure ClearRecordExportBuffer()
    var
        RecordExportBuffer: Record "Record Export Buffer";
    begin
        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.DeleteAll();
    end;

    procedure ExportXMLFile(DocNo: Code[20]; var TempBlob: Codeunit "Temp Blob"; FolderPath: Text; FileName: Text);
    var
        OIOUBLFileEvents: Codeunit "OIOUBL-File Events";
        IsHandled: Boolean;
    begin
        if FileName = '' then
            FileName := STRSUBSTNO(AddXMLExtensionLbl, DocNo);
        OnExportXMLFileOnAfterSetFileName(FileName, DocNo);
        if (FileName = '') or (StrPos(FileName, '\') > 0) then
            Error(WrongFileNameErr);
        FolderPath := DelChr(FolderPath, '>', '\');

        OIOUBLFileEvents.BlobCreated(TempBlob);
        OnExportXMLFileOnBeforeBLOBExport(DocNo, TempBlob, FileName, IsHandled);
        if IsHandled then
            exit;

        if FolderPath <> '' then
            FileName := StrSubstNo(FolderFileLbl, FolderPath, FileName);
        FileManagement.BLOBExport(TempBlob, FileName, true);
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
            ElectronicDocumentFormat.Usage := Enum::"Electronic Document Format Usage".FromInteger(DocumentUsage);
            Error(NonExistingDocumentFormatErr, OIOUBLFormatNameTxt, Format(ElectronicDocumentFormat.Usage));
        end;
    end;

    procedure IsOIOUBLCheckRequired(GLN: Code[13]; CustomerNo: Code[20]): Boolean;
    var
        Customer: Record "Customer";
        DocumentSendingProfile: Record "Document Sending Profile";
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

    procedure IsOIOUBLSendingProfile(DocumentSendingProfile: Record "Document Sending Profile") Result: Boolean;
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsOIOUBLSendingProfile(DocumentSendingProfile, Result, IsHandled);
        if IsHandled then
            exit(Result);

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


    procedure UpdateRecordExportBuffer(RecID: RecordID; var TempBlob: Codeunit "Temp Blob"; ClientFileName: Text[250]);
    var
        RecordExportBuffer: Record "Record Export Buffer";
    begin
        if RecordExportBuffer.IsEmpty() then
            exit;

        RecordExportBuffer.SetRange(RecordID, RecID);
        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.SetFilter("Electronic Document Format", '');
        if RecordExportBuffer.FindFirst() then begin
            RecordExportBuffer.SetFileContent(TempBlob);
            RecordExportBuffer.ClientFileName := ClientFileName;
            RecordExportBuffer."Electronic Document Format" := GetOIOUBLElectronicDocumentFormatCode();
            RecordExportBuffer.Modify();
        end;
    end;

    procedure WriteLogSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SegManagement: Codeunit SegManagement;
    begin
        if SegManagement.FindInteractionTemplateCode(4) = '' then
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
        if SegManagement.FindInteractionTemplateCode(6) = '' then
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
            RecordExportBuffer.GetFileContent(EntryTempBlob);
            EntryTempBlob.CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, RecordExportBuffer.ClientFileName);
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
        FileManagement.BLOBImportFromServerFile(TempBlob, ServerZipFilePath);
        TempBlob.CreateInStream(ZipInStream);
        DownloadFromStream(ZipInStream, ZipArchiveSaveDialogTxt, ClientZipFolder, ZipArchiveFilterTxt, ClientZipFileName);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeIsOIOUBLSendingProfile(DocumentSendingProfile: Record "Document Sending Profile"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnExportXMLFileOnBeforeBLOBExport(DocNo: Code[20]; var TempBlob: Codeunit "Temp Blob"; FileName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportXMLFileOnAfterSetFileName(var FileName: Text; DocNo: Code[20])
    begin
    end;

}
