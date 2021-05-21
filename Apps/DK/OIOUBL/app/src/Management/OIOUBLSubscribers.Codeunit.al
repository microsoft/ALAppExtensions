codeunit 13622 "OIOUBL-Subscribers"
{
    [Obsolete('Replaced by subscriber ExportCustomerDocumentsOnBeforeSendToDisk.','15.4')]
    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSend', '', false, false)]
    procedure ExportCustomerDocumentOnBeforeSend(VAR Sender: Record "Document Sending Profile"; ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; ToCust: Code[20]; DocName: Text[150]; CustomerFieldNo: Integer; DocumentNoFieldNo: Integer; VAR IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSendToDisk', '', false, false)]
    local procedure ExportCustomerDocumentsOnBeforeSendToDisk(var Sender: Record "Document Sending Profile"; ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; DocName: Text; ToCust: Code[20]; var IsHandled: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        OIOUBLExportSalesInvoice: Codeunit "OIOUBL-Export Sales Invoice";
        OIOUBLExportSalesCrMemo: Codeunit "OIOUBL-Export Sales Cr. Memo";
        OIOUBLExportServiceInvoice: Codeunit "OIOUBL-Export Service Invoice";
        OIOUBLExportServiceCrMemo: Codeunit "OIOUBL-Export Service Cr.Memo";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        ExportCodeunitID: Integer;
        IsStandardExportCodeunit: Boolean;
    begin
        if Sender.Disk <> Sender.Disk::"Electronic Document" then
            exit;

        if not OIOUBLManagement.IsOIOUBLSendingProfile(Sender) then
            exit;

        if not DataTypeManagement.GetRecordRef(RecordVariant, RecRef) then
            exit;

        if not OIOUBLManagement.IsAllowedDocumentType(RecRef) then
            exit;

        if RecRef.IsEmpty() then
            exit;

        ExportCodeunitID := OIOUBLManagement.GetExportCodeunitID(RecordVariant);
        IsStandardExportCodeunit := OIOUBLManagement.IsStandardExportCodeunitID(ExportCodeunitID);

        if not IsStandardExportCodeunit then begin
            OnBeforeRunNonStandardCodeunit(ExportCodeunitID, RecordVariant, IsHandled);
            if IsHandled then
                exit;

            Codeunit.Run(ExportCodeunitID, RecordVariant);
            IsHandled := true;
            exit;
        end;

        case RecRef.Number() of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.FindSet();
                    repeat
                        OIOUBLExportSalesInvoice.ExportXML(SalesInvoiceHeader);
                        OIOUBLManagement.WriteLogSalesInvoice(SalesInvoiceHeader);
                    until SalesInvoiceHeader.Next() = 0;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.FindSet();
                    repeat
                        OIOUBLExportSalesCrMemo.ExportXML(SalesCrMemoHeader);
                        OIOUBLManagement.WriteLogSalesCrMemo(SalesCrMemoHeader);
                    until SalesCrMemoHeader.Next() = 0;
                end;
            Database::"Service Invoice Header":
                begin
                    RecRef.SetTable(ServiceInvoiceHeader);
                    ServiceInvoiceHeader.FindSet();
                    repeat
                        OIOUBLExportServiceInvoice.ExportXML(ServiceInvoiceHeader);
                    until ServiceInvoiceHeader.Next() = 0;
                end;
            Database::"Service Cr.Memo Header":
                begin
                    RecRef.SetTable(ServiceCrMemoHeader);
                    ServiceCrMemoHeader.FindSet();
                    repeat
                        OIOUBLExportServiceCrMemo.ExportXML(ServiceCrMemoHeader);
                    until ServiceCrMemoHeader.Next() = 0;
                end;
            else
                exit;
        end;

        Commit();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Document Sending Profile", 'OnBeforeSendCustomerRecords', '', false, false)]
    procedure FillRecordExportBufferOnBeforeSendCustomerRecords(ReportUsage: Integer; RecordVariant: Variant; DocName: Text[150]; CustomerNo: Code[20]; DocumentNo: Code[20]; CustomerFieldNo: Integer; DocumentFieldNo: Integer; VAR Handled: Boolean)
    var
        RecordExportBuffer: Record "Record Export Buffer";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecordVariant);
        if RecRef.Count() <= 1 then
            exit;

        RecRef.FindSet();
        repeat
            RecordExportBuffer.Init();
            RecordExportBuffer.ID := 0;
            RecordExportBuffer.RecordID := RecRef.RecordId();
            RecordExportBuffer."OIOUBL-User ID" := CopyStr(UserId(), 1, MaxStrLen(RecordExportBuffer."OIOUBL-User ID"));
            RecordExportBuffer.Insert();
        until RecRef.Next() = 0;
        Commit();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnAfterSendCustomerRecords', '', false, false)]
    procedure SaveMultipleXMLFilesToZipOnAfterSendCustomerRecords(ReportUsage: Integer; RecordVariant: Variant; DocName: Text[150]; CustomerNo: Code[20]; DocumentNo: Code[20]; CustomerFieldNo: Integer; DocumentFieldNo: Integer)
    var
        RecordExportBuffer: Record "Record Export Buffer";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        RecRef: RecordRef;
        ServerZipFilePath: Text;
        ClientZipFilePath: Text;
        ClientZipFileName: Text;
    begin
        RecRef.GetTable(RecordVariant);
        if RecRef.Count() <= 1 then
            exit;

        RecordExportBuffer.Reset();
        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.SetRange("Electronic Document Format", OIOUBLManagement.GetOIOUBLElectronicDocumentFormatCode());
        RecordExportBuffer.SetFilter(ServerFilePath, '<>%1', '');
        RecordExportBuffer.SetFilter(ClientFileName, '<>%1', '');
        if RecordExportBuffer.IsEmpty() then begin
            OIOUBLManagement.ClearRecordExportBuffer();
            exit;
        end;
        ServerZipFilePath := OIOUBLManagement.ZipMultipleXMLFilesInServerFolder(RecordExportBuffer);
        OIOUBLManagement.ClearRecordExportBuffer();

        RecRef.FindFirst();
        ClientZipFilePath := OIOUBLManagement.GetDocumentExportPath(RecRef);
        ClientZipFileName :=
            ElectronicDocumentFormat.GetAttachmentFileName(
                ElectronicDocumentFormat.GetDocumentNo(RecRef), OIOUBLManagement.GetDocumentType(RecRef), 'zip');

        OIOUBLManagement.DownloadZipFile(ServerZipFilePath, ClientZipFilePath, ClientZipFileName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-Management", 'OnExportXMLFileOnBeforeDownload', '', false, false)]
    procedure CancelDownloadWhenZipOnExportXMLFileOnBeforeDownload(var Sender: Codeunit "OIOUBL-Management"; DocNo: Code[20]; SourceFile: Text; FolderPath: Text; var IsHandled: Boolean)
    var
        RecordExportBuffer: Record "Record Export Buffer";
    begin
        if RecordExportBuffer.IsEmpty() then
            exit;

        RecordExportBuffer.SetRange("OIOUBL-User ID", UserId());
        RecordExportBuffer.SetFilter(ServerFilePath, SourceFile);
        if not RecordExportBuffer.IsEmpty() then
            IsHandled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunNonStandardCodeunit(ExportCodeunitID: Integer; RecordVariant: Variant; var IsHandled: Boolean)
    begin
    end;

}