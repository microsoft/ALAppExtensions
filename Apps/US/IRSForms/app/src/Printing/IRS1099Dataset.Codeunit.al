// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10055 "IRS 1099 Dataset"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        IRS1099FormStatementLineEmptyErr: Label 'There are no form statement lines for the selected form and period.';

    procedure Get1099Dataset(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; var IRS1099ReportLine: Record "IRS 1099 Report Line")
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
        LineNo: Integer;
    begin
        IRS1099ReportLine.Reset();
        IRS1099ReportLine.DeleteAll();
        LineNo := 0;
        IRS1099FormStatementLine.SetRange("Period No.", IRS1099FormDocHeader."Period No.");
        IRS1099FormStatementLine.SetRange("Form No.", IRS1099FormDocHeader."Form No.");
        if not IRS1099FormStatementLine.FindSet() then
            Error(IRS1099FormStatementLineEmptyErr);

        repeat
            IRS1099FormDocLine.SetView(IRS1099FormStatementLine."Record View String");
            SetDefaultFilters(IRS1099FormDocLine, IRS1099FormDocHeader);
            if IRS1099FormDocLine.FindSet() then begin
                IRS1099FormDocLine.CalcSums(Amount);
                if IRS1099FormStatementLine."Print Value Type" = IRS1099FormStatementLine."Print Value Type"::Amount then
                    Add1099ReportLine(IRS1099ReportLine, LineNo, IRS1099FormDocLine."Form Box No.", GetFormBoxDescription(IRS1099FormStatementLine, IRS1099FormDocLine), Format(GetSign(IRS1099FormStatementLine) * IRS1099FormDocLine.Amount, 0, 2))
                else
                    Add1099ReportLine(IRS1099ReportLine, LineNo, IRS1099FormDocLine."Form Box No.", GetFormBoxDescription(IRS1099FormStatementLine, IRS1099FormDocLine), 'Yes');
                LineNo += 1;
            end;
        until IRS1099FormStatementLine.Next() = 0;
    end;

    local procedure GetSign(IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line"): Decimal
    begin
        if IRS1099FormStatementLine."Print with" = IRS1099FormStatementLine."Print with"::"Opposite Sign" then
            exit(-1)
        else
            exit(1);
    end;

    local procedure SetDefaultFilters(var IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        IRS1099FormDocLine.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormDocLine.SetRange("Include In 1099", true);
    end;

    local procedure GetFormBoxDescription(IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line"; IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"): Text[250]
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
    begin
        if IRS1099FormStatementLine.Description <> '' then
            exit(IRS1099FormStatementLine.Description);
        IRS1099FormBox.SetRange("Period No.", IRS1099FormDocLine."Period No.");
        IRS1099FormBox.SetRange("Form No.", IRS1099FormDocLine."Form No.");
        IRS1099FormBox.SetRange("No.", IRS1099FormDocLine."Form Box No.");
        if IRS1099FormBox.FindFirst() then
            exit(IRS1099FormBox.Description);
    end;

    local procedure Add1099ReportLine(var IRS1099ReportLine: Record "IRS 1099 Report Line"; LineNo: Integer; BoxNo: Text; BoxDecription: Text; Value: Text)
    begin
        IRS1099ReportLine.Init();
        IRS1099ReportLine."Line No." := LineNo;
        IRS1099ReportLine.Name := CopyStr(BoxNo + ' - ' + BoxDecription, 1, 250);
        IRS1099ReportLine.Value := CopyStr(Value, 1, MaxStrLen(IRS1099ReportLine.Value));
        IRS1099ReportLine.Insert();
    end;
}
