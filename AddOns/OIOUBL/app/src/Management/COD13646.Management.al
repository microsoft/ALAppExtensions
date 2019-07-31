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
        IsHandled: Boolean;
    begin
        FileName := STRSUBSTNO('%1.xml', DocNo);
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
          (DocumentSendingProfile."Electronic Format" = 'OIOUBL') OR
          (DocumentSendingProfile."E-Mail Format" = 'OIOUBL') OR
          (DocumentSendingProfile."Disk Format" = 'OIOUBL'));
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

    [IntegrationEvent(true, false)]
    local procedure OnExportXMLFileOnBeforeDownload(DocNo: Code[20]; SourceFile: Text; FolderPath: Text; var IsHandled: Boolean)
    begin
    end;
}