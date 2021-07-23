// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8944 "Address Book Impl"
{

    procedure SelectRecipient(MessageID: Guid; var RecipientAddressRecord: Record Address)
    var
        EmailRelatedRecord: Record "Email Related Record";
        Addressbook: Codeunit "Address Book";
        EmailAddressPage: Page "Email Address";
    begin
        // Get Suggested Email Addresses
        EmailRelatedRecord.SetRange("Email Message Id", MessageID);
        if EmailRelatedRecord.FindSet() then
            repeat
                Addressbook.OnGetSuggestedAddresses(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", RecipientAddressRecord);
            until EmailRelatedRecord.Next() = 0;

        if RecipientAddressRecord.IsEmpty() then
            EmailAddressLookup(RecipientAddressRecord);

        // Open Addressbook in Lookupmode 
        EmailAddressPage.LookupMode(true);
        EmailAddressPage.InsertAddresses(RecipientAddressRecord);
        RecipientAddressRecord.DeleteAll();
        if EmailAddressPage.RunModal() <> Action::LookupOK then
            exit;

        // Return selected addresses
        EmailAddressPage.GetSelectedAddresses(RecipientAddressRecord);
    end;

    procedure GetEmailsFrom(var EmailAddress: Record Address) Recipients: Text
    begin
        if (StrLen(Recipients) > 0) and (not Recipients.EndsWith(';')) then
            Recipients += ';';
        if EmailAddress.FindSet() then
            repeat
                Recipients += EmailAddress."E-Mail Address" + ';';
            until EmailAddress.Next() = 0;
    end;

    procedure EmailAddressLookup(var EmailAddressRecord: Record Address): Boolean
    var
        RetrievedEmailAddress: Record Address;
        AddressEntity: Record "Address Entity";
        Addressbook: Codeunit "Address Book";
        EmailAddressEntityPage: Page "Email Address Entity";
        IsHandled: Boolean;
    begin
        // Retrieve and select entity
        Addressbook.OnGetEmailAddressEntity(AddressEntity);
        EmailAddressEntityPage.LookupMode(true);
        EmailAddressEntityPage.InsertAddresses(AddressEntity);
        if EmailAddressEntityPage.RunModal() <> Action::LookupOK then
            exit;
        AddressEntity.DeleteAll();

        // Look up email address from chosen entity  
        EmailAddressEntityPage.GetSelectedAddresses(AddressEntity);
        Addressbook.OnLookupEmailAddressFromEntity(AddressEntity.SourceTable, RetrievedEmailAddress, IsHandled);

        if IsHandled then
            if StrLen(RetrievedEmailAddress."E-Mail Address") = 0 then
                Message(NoEmailAddressMsg)
            else
                if EmailAddressRecord.Get(RetrievedEmailAddress."E-Mail Address") then
                    Message(EmailAddressDuplicateMsg)
                else begin
                    EmailAddressRecord.TransferFields(RetrievedEmailAddress);
                    EmailAddressRecord.Insert();
                end;
        exit(IsHandled);
    end;

    var
        NoEmailAddressMsg: Label 'Record had no email address';
        EmailAddressDuplicateMsg: Label 'Email Address already added';
}