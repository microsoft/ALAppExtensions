// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8944 "Email Address Lookup Impl"
{
    Access = Internal;

    procedure GetSelectedSuggestionsAsText(var Address: Record "Email Address Lookup"): Text
    var
        Recipients: Text;
    begin
        if Address.FindSet() then
            repeat
                Recipients += Address."E-Mail Address" + ';';
            until Address.Next() = 0;
        exit(Recipients);
    end;

    procedure LookupEmailAddress(Entity: Enum "Email Address Entity"; var Addresses: Record "Email Address Lookup"): Boolean
    var
        EmailAddressSuggestions: Record "Email Address Lookup";
        EmailAddressLookup: Codeunit "Email Address Lookup";
        IsHandled: Boolean;
    begin
        EmailAddressLookup.OnLookupAddressFromEntity(Entity, EmailAddressSuggestions, IsHandled);
        if not EmailAddressSuggestions.FindSet() then
            exit(false);

        if IsHandled then begin
            repeat
                if StrLen(EmailAddressSuggestions."E-Mail Address") = 0 then
                    Message(StrSubstNo(NoEmailAddressMsg, EmailAddressSuggestions.Name))
                else
                    if Addresses.Get(EmailAddressSuggestions."E-Mail Address", EmailAddressSuggestions."Entity type") then
                        Message(StrSubstNo(EmailAddressDuplicateMsg, EmailAddressSuggestions."E-Mail Address"))
                    else begin
                        Addresses.TransferFields(EmailAddressSuggestions);
                        Addresses.Insert();
                    end;
            until EmailAddressSuggestions.Next() = 0;
            exit(IsHandled);
        end;
    end;

    var
        NoEmailAddressMsg: Label '%1 has no email address stored', Comment = '%1 suggested address';
        EmailAddressDuplicateMsg: Label 'Email address %1 already added', Comment = '%1 email address';
}