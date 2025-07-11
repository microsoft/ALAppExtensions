// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Capacity;

using System.Security.User;

codeunit 11702 "User Handler CZA"
{
    Access = Internal;
    Permissions = TableData "Capacity Ledger Entry" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User", OnRenameUserOnBeforeProcessField, '', false, false)]
    local procedure OnRenameUserOnBeforeProcessField(TableID: Integer; OldUserName: Code[50]; NewUserName: Code[50]; CompanyName: Text[30]; var IsHandled: Boolean)
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
    begin
        if TableID <> Database::"Capacity Ledger Entry" then
            exit;

        if not CapacityLedgerEntry.ReadPermission() then
            exit;

        IsHandled := true;

        CapacityLedgerEntry.ChangeCompany(CompanyName);
        CapacityLedgerEntry.SetRange("User ID CZA", OldUserName);
        if CapacityLedgerEntry.FindSet(true) then
            repeat
                CapacityLedgerEntry."User ID CZA" := NewUserName;
                CapacityLedgerEntry.Modify();
            until CapacityLedgerEntry.Next() = 0;
    end;
}