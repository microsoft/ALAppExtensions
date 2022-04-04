// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to run an email address lookup.
/// </summary>
codeunit 8945 "Email Address Lookup"
{
    #region Events

    /// <summary>
    /// Event that allows subscribers to populate the list of "Suggested Email Addresses" in the Email Address Lookup.
    /// </summary>
    /// <param name="TableId">Table id of a related record.</param>
    /// <param name="SystemId">System id of a related record.</param>
    /// <param name="Address">Email Address record used to return suggested addresses.</param>
#pragma warning disable AA0072
    [IntegrationEvent(false, false)]
    internal procedure OnGetSuggestedAddresses(TableId: Integer; SystemId: Guid; var Address: Record "Email Address Lookup")
    begin
    end;
#pragma warning restore
    /// <summary>
    /// Event that retrieves email address information from a specified entity.
    /// </summary>
    /// <param name="Entity">Entity Type.</param>
    /// <param name="Address">Email Address record used to return addresses.</param>
    /// <param name="IsHandled">Boolean indicating whether the event has been handled.</param>
#pragma warning disable AA0072
    [IntegrationEvent(false, false)]
    internal procedure OnLookupAddressFromEntity(Entity: Enum "Email Address Entity"; var Address: Record "Email Address Lookup"; var IsHandled: Boolean)
    begin
    end;
#pragma warning restore
    #endregion

    /// <summary>
    /// Produces a string of email addresses from an Email Address record.
    /// </summary>
    /// <param name="Address">EmailAddress record used to create text.</param>
    /// <returns>A concatenated string of the email addresses.</returns>
    procedure GetSelectedSuggestionsAsText(var EmailAddressLookup: Record "Email Address Lookup"): Text
    begin
        exit(EmailAddressLookupImpl.GetSelectedSuggestionsAsText(EmailAddressLookup));
    end;

    var
        EmailAddressLookupImpl: Codeunit "Email Address Lookup Impl";
}