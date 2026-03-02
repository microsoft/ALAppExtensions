// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Service.History;
using System.IO;

codeunit 37359 "Exp. Serv.Inv. PEPPOL30 NO"
{
    TableNo = "Record Export Buffer";
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnRun()
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        PeppolSetup: Record "PEPPOL 3.0 Setup";
        RecordRef: RecordRef;
        PEPPOL30Validation: Interface "PEPPOL30 Validation";
        OutStr: OutStream;
    begin
        RecordRef.Get(Rec.RecordID);
        RecordRef.SetTable(ServiceInvoiceHeader);

        PeppolSetup.GetSetup();
        PEPPOL30Validation := PeppolSetup."PEPPOL 3.0 Service Format";
        PEPPOL30Validation.ValidatePostedDocument(ServiceInvoiceHeader);

        Rec."File Content".CreateOutStream(OutStr);
        GenerateXMLFile(ServiceInvoiceHeader, OutStr, PeppolSetup."PEPPOL 3.0 Service Format");
        Rec.Modify(false);
    end;

    procedure GenerateXMLFile(VariantRec: Variant; var OutStr: OutStream; PEPPOL30Format: Enum "PEPPOL 3.0 Format")
    var
        SalesInvoicePEPPOLBIS30NO: XMLport "Sales Invoice - PEPPOL30 NO";
    begin
        SalesInvoicePEPPOLBIS30NO.Initialize(VariantRec, PEPPOL30Format);
        SalesInvoicePEPPOLBIS30NO.SetDestination(OutStr);
        SalesInvoicePEPPOLBIS30NO.Export();
    end;
}
