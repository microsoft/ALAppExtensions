// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 11786 "VAT Stmt XML Export Runner CZL"
{
    TableNo = "VAT Statement Name";

    trigger OnRun()
    var
        FileName: Text;
    begin
        GetVATStatementXMLFormat(Rec);
        FileName := VATStatementExportCZL.ExportToXMLFile(Rec);
    end;

    procedure ExportToXMLBlob(VATStatementName: Record "VAT Statement Name"; var TempBlob: Codeunit "Temp Blob")
    begin
        GetVATStatementXMLFormat(VATStatementName);
        VATStatementExportCZL.ExportToXMLBlob(VATStatementName, TempBlob);
    end;

    local procedure GetVATStatementXMLFormat(VATStatementName: Record "VAT Statement Name")
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.Get(VATStatementName."Statement Template Name");
        VATStatementExportCZL := VATStatementTemplate."XML Format CZL";
    end;

    var
        VATStatementExportCZL: Interface "VAT Statement Export CZL";
}
