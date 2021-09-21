// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to run an address book.
/// </summary>
codeunit 8945 "Address Book"
{
    #region Events

    /// <summary>
    /// Event that allows subscribers to populate the list of "Suggested Contacts" in the Addressbook
    /// </summary>
    /// <param name="SourceTableNo">Table number of a related record</param>
    /// <param name="SourceSystemID">SystemID of a related record</param>
    /// <param name="EmailAddress">EmailAddress record used to return addresses</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetSuggestedAddresses(SourceTableNo: Integer; SourceSystemID: Guid; var Address: Record Address)
    begin
    end;

    /// <summary>
    /// Event that retrieves contact information from a specified entity
    /// </summary>
    /// <param name="TableNo">Table number of entity</param>
    /// <param name="Address">Address record used to return addresses</param>
    /// <param name="IsHandled">Boolean indicating whether the event has been handled</param>
    [IntegrationEvent(false, false)]
    internal procedure OnLookupEmailAddressFromEntity(TableNo: Integer; var Address: Record Address; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Event that retrieves a list of entities (Contact, Customer, Vendor etc.) that the addressbook should be able to get information from
    /// </summary>
    /// <param name="EmailAddress">AddressEntity record used to return address entities</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetEmailAddressEntity(var AddressEntity: Record "Address Entity")
    begin
    end;
    #endregion

    /// <summary>
    /// Launches the addressbook and allows the user to select a recipient
    /// </summary>
    /// <param name="MessageID">Email Message ID</param>
    /// <param name="EmailAddress">EmailAddress record used to return addresses</param>
    procedure SelectRecipient(MessageID: Guid; var RecipientAddress: Record Address)
    begin
        AddressbookImpl.SelectRecipient(MessageID, RecipientAddress);
    end;

    /// <summary>
    /// Produces a string of email addresses from an Email Address record
    /// </summary>
    /// <returns>A concatenated string of the email addresses</returns>
    procedure GetEmailsFrom(var Address: Record Address): Text
    begin
        exit(AddressbookImpl.GetEmailsFrom(Address));
    end;

    var
        AddressbookImpl: Codeunit "Address Book Impl";
}