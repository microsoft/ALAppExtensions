// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeOnSales;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;
using Microsoft.Sales.Document;

codeunit 18787 "Sales Charge Group Management"
{
    TableNo = "Sales Line";

    var
        CanInsertChargeGroupLinesQst: label 'Do you want to insert Charge Group line(s) for Document: %1?', Comment = '%1 Document No.';

    trigger OnRun()
    var
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        OnBeforeOnRun(Rec, IsHandled);
        if IsHandled then
            exit;

        SalesLine.Copy(Rec);
        Code(SalesLine);
        Rec := SalesLine;
    end;

    local procedure Code(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        ChargeGroupManagement: Codeunit "Charge Group Management";
        IsHandled: Boolean;
    begin
        OnBeforeConfirmInsertChargeLines(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed then
            if not Confirm(CanInsertChargeGroupLinesQst, true, SalesLine."Document No.") then
                exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ChargeGroupManagement.InsertChargeItemOnLine(SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmInsertChargeLines(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;
}
