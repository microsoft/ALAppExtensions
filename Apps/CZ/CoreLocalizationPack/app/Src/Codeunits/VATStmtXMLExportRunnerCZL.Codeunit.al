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
        FileName := GetVATStatementXMLFormat(Rec).ExportToXMLFile(Rec);
    end;

    procedure ExportToXMLBlob(VATStatementName: Record "VAT Statement Name"; var TempBlob: Codeunit "Temp Blob")
    begin
        GetVATStatementXMLFormat(VATStatementName).ExportToXMLBlob(VATStatementName, TempBlob);
    end;

    local procedure GetVATStatementXMLFormat(VATStatementName: Record "VAT Statement Name"): Interface "VAT Statement Export CZL"
    begin
        exit(VATStatementName."XML Format CZL");
    end;
}
