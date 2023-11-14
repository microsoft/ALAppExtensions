// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;

codeunit 31059 "Release VIES Declaration CZL"
{
    TableNo = "VIES Declaration Header CZL";

    trigger OnRun()
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        if Rec.Status = Rec.Status::Released then
            exit;

        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.TestField("VIES Number of Lines");

        Rec.TestField("VAT Registration No.");
        Rec.TestField("Document Date");
        Rec.TestField(Year);
        Rec.TestField("Period No.");
        if Rec."Declaration Type" <> Rec."Declaration Type"::Normal then
            Rec.TestField("Corrected Declaration No.");

        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", Rec."No.");
        if VIESDeclarationLineCZL.IsEmpty() then
            Error(NothingToReleaseErr, Rec."No.");
        VIESDeclarationLineCZL.FindSet();
        PageNo := 1;
        LineNo := 0;
        repeat
            CheckLine(Rec, VIESDeclarationLineCZL);
            LineNo += 1;
            if LineNo = StatutoryReportingSetupCZL."VIES Number of Lines" + 1 then begin
                LineNo := 1;
                PageNo += 1;
            end;
            VIESDeclarationLineCZL."Report Page Number" := PageNo;
            VIESDeclarationLineCZL."Report Line Number" := LineNo;
            VIESDeclarationLineCZL.Modify();
        until VIESDeclarationLineCZL.Next() = 0;

        Rec.Status := Rec.Status::Released;
        Rec.Modify(true);
    end;

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        PageNo: Integer;
        LineNo: Integer;
        NothingToReleaseErr: Label 'There is nothing to release for VIES declaration %1.', Comment = '%1 = No.';

    procedure Reopen(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        if VIESDeclarationHeaderCZL.Status = VIESDeclarationHeaderCZL.Status::Open then
            exit;

        VIESDeclarationHeaderCZL.Status := VIESDeclarationHeaderCZL.Status::Open;
        VIESDeclarationHeaderCZL.Modify(true);
    end;

    local procedure CheckLine(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; VIESDeclarationLineCZL: Record "VIES Declaration Line CZL")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckLine(VIESDeclarationHeaderCZL, VIESDeclarationLineCZL, IsHandled);
        if IsHandled then
            exit;

        VIESDeclarationLineCZL.TestField("Country/Region Code");
        VIESDeclarationLineCZL.TestField("VAT Registration No.");
        if IsLineAmountCheckingEnabled(VIESDeclarationHeaderCZL, VIESDeclarationLineCZL) then
            VIESDeclarationLineCZL.TestField("Amount (LCY)");
    end;

    local procedure IsLineAmountCheckingEnabled(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; VIESDeclarationLineCZL: Record "VIES Declaration Line CZL") IsEnabled: Boolean
    begin
        IsEnabled := VIESDeclarationHeaderCZL."Declaration Type" <> VIESDeclarationHeaderCZL."Declaration Type"::Normal;
        OnAfterIsLineAmountCheckingEnabled(VIESDeclarationHeaderCZL, VIESDeclarationLineCZL, IsEnabled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLine(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsLineAmountCheckingEnabled(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var IsEnabled: Boolean)
    begin
    end;
}
