// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13647 "OIOUBL-Service-Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    procedure OIOUBLCheckOnBeforePostWithLines(var PassedServHeader: Record 5900; var PassedServLine: Record 5902; var PassedShip: Boolean; var PassedConsume: Boolean; var PassedInvoice: Boolean)
    var
        OIOXMLCheckServiceHeader: Codeunit "OIOUBL-Check Service Header";
    begin
        OIOXMLCheckServiceHeader.Run(PassedServHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSend', '', false, false)]
    procedure ExportServiceDocumentOnBeforeSend(VAR Sender: Record "Document Sending Profile"; ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; ToCust: Code[20]; DocName: Text[150]; CustomerFieldNo: Integer; DocumentNoFieldNo: Integer; VAR IsHandled: Boolean)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        OIOUBLExportServiceInvoice: Codeunit "OIOUBL-Export Service Invoice";
        OIOUBLExportServiceCrMemo: Codeunit "OIOUBL-Export Service Cr.Memo";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if Sender.Disk <> Sender.Disk::"Electronic Document" then
            exit;

        if not OIOUBLManagement.IsOIOUBLSendingProfile(Sender) then
            exit;

        if not DataTypeManagement.GetRecordRef(RecordVariant, RecRef) then
            exit;

        case RecRef.Number() of
            Database::"Service Invoice Header":
                begin
                    RecRef.SetTable(ServiceInvoiceHeader);
                    OIOUBLExportServiceInvoice.ExportXML(ServiceInvoiceHeader);
                end;
            Database::"Service Cr.Memo Header":
                begin
                    RecRef.SetTable(ServiceCrMemoHeader);
                    OIOUBLExportServiceCrMemo.ExportXML(ServiceCrMemoHeader);
                end;
            else
                exit;
        end;

        IsHandled := true;
    end;

    // TODO
    // [EventSubscriber(ObjectType::Codeunit,Codeunit::"Service-Post+Print",'OnBeforeExportServiceInvoice','',false,false)]
    // procedure OnBeforeExportServiceInvoice(var ServiceHeader : Record "Service Header";var ServInvHeader : Record "Service Invoice Header");
    // var
    //     OIOXMLExportServiceInvoice : Codeunit "OIOUBL-Export Service Invoice";
    // begin
    //     if ServiceHeader."OIOUBL-GLN" <> '' then
    //         if ServInvHeader.FIND('=') then
    //             OIOXMLExportServiceInvoice.RUN(ServInvHeader);
    // end; 

    // [EventSubscriber(ObjectType::Codeunit,Codeunit::"Service-Post+Print",'OnBeforeExportServiceCrMemo','',false,false)]
    // procedure OnBeforeExportServiceCrMemo(var ServiceHeader : Record "Service Header";var ServCrMemoHeader : Record "Service Cr.Memo Header");
    // var
    //     OIOXMLExportServiceCrMemo : Codeunit "OIOUBL-Export Service Cr.Memo";
    // begin
    //     if ServiceHeader."OIOUBL-GLN" <> '' then
    //         if ServCrMemoHeader.FIND('=') then
    //             OIOXMLExportServiceCrMemo.RUN(ServCrMemoHeader);
    // end; 
}