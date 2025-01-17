// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

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

    procedure Reopen(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
        if VATCtrlReportHeaderCZL.Status = VATCtrlReportHeaderCZL.Status::Open then
            exit;
        VATCtrlReportHeaderCZL.Status := VATCtrlReportHeaderCZL.Status::Open;
        VATCtrlReportHeaderCZL.Modify(true);
    end;
}
