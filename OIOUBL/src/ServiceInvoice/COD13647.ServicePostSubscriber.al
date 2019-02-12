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
}