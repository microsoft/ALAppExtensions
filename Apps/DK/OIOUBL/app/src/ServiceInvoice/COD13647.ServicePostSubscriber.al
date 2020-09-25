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