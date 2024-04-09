// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

using Microsoft.Finance.VAT.Ledger;

codeunit 31130 "Conf. VAT Ent. Update Mgt. CZL"
{
    procedure GetResponseOrDefault(var TempVATEntry: Record "VAT Entry" temporary; DefaultResponse: Boolean): Boolean
    begin
        exit(GetResponseLocal(TempVATEntry, DefaultResponse));
    end;

    procedure GetResponse(var TempVATEntry: Record "VAT Entry" temporary): Boolean
    begin
        exit(GetResponseLocal(TempVATEntry, false));
    end;

    local procedure GetResponseLocal(var TempVATEntry: Record "VAT Entry" temporary; DefaultResponse: Boolean): Boolean
    var
        ConfirmVATEntriesUpdateCZL: Page "Confirm VAT Entries Update CZL";
    begin
        if not IsGuiAllowed() then
            exit(DefaultResponse);
        ConfirmVATEntriesUpdateCZL.Set(TempVATEntry);
        exit(ConfirmVATEntriesUpdateCZL.RunModal() = Action::Yes);
    end;

    local procedure IsGuiAllowed() GuiIsAllowed: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeGuiAllowed(GuiIsAllowed, IsHandled);
        if IsHandled then
            exit;
        exit(GuiAllowed());
    end;

    /// <summary>
    /// Raises an event to be able to change the return of IsGuiAllowed function. Used for testing.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGuiAllowed(var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
