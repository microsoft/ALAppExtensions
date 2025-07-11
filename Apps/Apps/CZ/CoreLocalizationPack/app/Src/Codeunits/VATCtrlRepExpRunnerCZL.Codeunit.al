// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 31104 "VAT Ctrl. Rep. Exp. Runner CZL"
{
    TableNo = "VAT Ctrl. Report Header CZL";

    trigger OnRun()
    var
        FileName: Text;
    begin
        VATControlReportExportCZL := Rec."VAT Control Report XML Format";
        FileName := VATControlReportExportCZL.ExportToXMLFile(Rec);
    end;

    procedure ExportToXMLBlob(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempBlob: Codeunit "Temp Blob")
    begin
        VATControlReportExportCZL := VATCtrlReportHeaderCZL."VAT Control Report XML Format";
        VATControlReportExportCZL.ExportToXMLBlob(VATCtrlReportHeaderCZL, TempBlob);
    end;

    var
        VATControlReportExportCZL: Interface "VAT Control Report Export CZL";
}
