#pragma implicitwith disable
codeunit 31103 "VAT Ctrl. Report Release CZL"
{
    TableNo = "VAT Ctrl. Report Header CZL";

    trigger OnRun()
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if Rec.Status = Rec.Status::Released then
            exit;

        Rec.TestField("No.");
        Rec.TestField(Year);
        Rec.TestField("Period No.");
        Rec.TestField("Start Date");
        Rec.TestField("End Date");

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", Rec."No.");
        if VATCtrlReportLineCZL.IsEmpty() then
            Error(LinesNotExistErr, Rec."No.");
        VATCtrlReportLineCZL.FindSet();
        repeat
            VATCtrlReportLineCZL.TestField("VAT Ctrl. Report Section Code");
        until VATCtrlReportLineCZL.Next() = 0;

        Rec.Status := Rec.Status::Released;
        Rec.Modify(true);
    end;

    var
        LinesNotExistErr: Label 'There is nothing to release for VAT Control Report No. %1.', Comment = '%1 = VAT Control Report No.';

    procedure Reopen(var VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL")
    begin
        if VATCtrlReportHeader.Status = VATCtrlReportHeader.Status::Open then
            exit;
        VATCtrlReportHeader.Status := VATCtrlReportHeader.Status::Open;
        VATCtrlReportHeader.Modify(true);
    end;
}
