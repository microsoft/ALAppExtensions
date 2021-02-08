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