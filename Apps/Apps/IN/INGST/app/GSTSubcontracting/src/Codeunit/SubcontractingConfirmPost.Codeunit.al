// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;

codeunit 18465 "Subcontracting Confirm-Post"
{
    TableNo = "Purchase Line";

    var
        NothingToPostErr: Label 'There is nothing to post.';
        SendPostQst: Label 'Do you want to post the %1?', Comment = '%1 = Document No';

    trigger OnRun()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        OnBeforeOnRun(Rec);

        if not Rec.Find() then
            Error(NothingToPostErr);

        PurchaseLine.Copy(Rec);
        Code(PurchaseLine);
        Rec := PurchaseLine;
    end;

    local procedure Code(var PurchaseLine: Record "Purchase Line")
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;

        OnBeforeConfirmSubcontractingPost(PurchaseLine, HideDialog, IsHandled);
        if IsHandled then
            exit;

        if not HideDialog then
            if not Confirm(SendPostQst, true, PurchaseLine."Document No.") then
                exit;

        Codeunit.Run(Codeunit::"Subcontracting Post", PurchaseLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmSubcontractingPost(var PurchaseLine: Record "Purchase Line"; var HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;
}
