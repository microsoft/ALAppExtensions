// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Service.History;
using System.IO;

codeunit 37360 "Exp. Serv.CrM. PEPPOL30 NO"
{
    TableNo = "Record Export Buffer";
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnRun()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        PeppolSetup: Record "PEPPOL 3.0 Setup";
        RecordRef: RecordRef;
        PEPPOL30Validation: Interface "PEPPOL30 Validation";
        OutStr: OutStream;
    begin
        RecordRef.Get(Rec.RecordID);
        RecordRef.SetTable(ServiceCrMemoHeader);

        PeppolSetup.GetSetup();
        PEPPOL30Validation := PeppolSetup."PEPPOL 3.0 Service Format";
        PEPPOL30Validation.ValidatePostedDocument(ServiceCrMemoHeader);

        Rec."File Content".CreateOutStream(OutStr);
        GenerateXMLFile(ServiceCrMemoHeader, OutStr, PeppolSetup."PEPPOL 3.0 Service Format");

        Rec.Modify(false);
    end;

    procedure GenerateXMLFile(VariantRec: Variant; var OutStr: OutStream; PEPPOL30Format: Enum "PEPPOL 3.0 Format")
    var
        SalesCrMemoPEPPOLBIS30NO: XMLport "Sales Cr.Memo - PEPPOL30 NO";
    begin
        SalesCrMemoPEPPOLBIS30NO.Initialize(VariantRec, PEPPOL30Format);
        SalesCrMemoPEPPOLBIS30NO.SetDestination(OutStr);
        SalesCrMemoPEPPOLBIS30NO.Export();
    end;
}
