// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Used to mock selected email accounts on Email Accounts page.
/// </summary>
codeunit 134697 "Email Accounts Selection Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    internal procedure SelectAccount(AccountId: Guid)
    begin
        SelectedAccounts.Add(AccountId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Account Impl.", 'OnAfterSetSelectionFilter', '', false, false)]
    local procedure SelectAccounts(var EmailAccount: Record "Email Account")
    var
        SelectionFilter: Text;
        AccountId: Guid;
    begin
        EmailAccount.Reset();

        foreach AccountId in SelectedAccounts do
            SelectionFilter := StrSubstNo('%1|%2', SelectionFilter, AccountId);

        SelectionFilter := DelChr(SelectionFilter, '<>', '|'); // remove trailing and leading pipes

        if SelectionFilter <> '' then
            EmailAccount.SetFilter("Account Id", SelectionFilter);
    end;

    var
        SelectedAccounts: List of [Guid];
}