// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8944 "Email Address Lookup Impl"
{
    Access = Internal;

    procedure GetSelectedSuggestionsAsText(var EmailAddressLookup: Record "Email Address Lookup"): Text
    var
        Recipients: Text;
    begin
        if EmailAddressLookup.FindSet() then
            repeat
                Recipients += EmailAddressLookup."E-Mail Address" + ';';
            until EmailAddressLookup.Next() = 0;
        exit(Recipients);
    end;

    procedure LookupEmailAddress(Entity: Enum "Email Address Entity"; var EmailAddressLookupRec: Record "Email Address Lookup"): Boolean
    var
        EmailAddressLookupSuggestions: Record "Email Address Lookup";
        EmailAddressLookup: Codeunit "Email Address Lookup";
        IsHandled: Boolean;
    begin
        EmailAddressLookup.OnLookupAddressFromEntity(Entity, EmailAddressLookupSuggestions, IsHandled);
        if not EmailAddressLookupSuggestions.FindSet() then
            exit(false);

        if IsHandled then begin
            repeat
                if StrLen(EmailAddressLookupSuggestions."E-Mail Address") = 0 then
                    Message(StrSubstNo(NoEmailAddressMsg, EmailAddressLookupSuggestions.Name))
                else
                    if EmailAddressLookupRec.Get(EmailAddressLookupSuggestions."E-Mail Address", EmailAddressLookupSuggestions."Entity type") then
                        Message(StrSubstNo(EmailAddressDuplicateMsg, EmailAddressLookupSuggestions."E-Mail Address"))
                    else begin
                        EmailAddressLookupRec.TransferFields(EmailAddressLookupSuggestions);
                        EmailAddressLookupRec.Insert();
                    end;
            until EmailAddressLookupSuggestions.Next() = 0;
            exit(IsHandled);
        end;
    end;

    var
        NoEmailAddressMsg: Label '%1 has no email address stored', Comment = '%1 suggested address';
        EmailAddressDuplicateMsg: Label 'Email address %1 already added', Comment = '%1 email address';
}