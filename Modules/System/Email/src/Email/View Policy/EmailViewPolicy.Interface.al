// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The interface for a email view policy.
/// Email view policies decide the emails that a given User can view.
/// </summary>
interface "Email View Policy"
{
    /// <summary>
    /// Get sent emails that policy allow.
    /// </summary>
    /// <param name="SentEmails">The record to contain the sent emails.</param>
    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary);

    /// <summary>
    /// Get outbox email that policy allow.
    /// </summary>
    /// <param name="OutboxEmails">The record to contain the outbox emails.</param>
    procedure GetOutboxEmails(var OutboxEmails: Record "Email Outbox" temporary);

    /// <summary>
    /// Get sent emails that policy allow for a given entity.
    /// </summary>
    /// <param name="SourceTableId">Table id for the entity.</param>
    /// <param name="SentEmails">The record to contain the sent emails.</param>
    procedure GetSentEmails(SourceTableId: Integer; var SentEmails: Record "Sent Email" temporary);

    /// <summary>
    /// Get outbox emails that policy allow for a given entity.
    /// </summary>
    /// <param name="SourceTableId">Table id for the entity.</param>
    /// <param name="OutboxEmails">The record to contain the outbox emails.</param>
    procedure GetOutboxEmails(SourceTableId: Integer; var OutboxEmails: Record "Email Outbox" temporary);

    /// <summary>
    /// Get sent emails that policy allow for a given record.
    /// </summary>
    /// <param name="SourceTableId">Table id for the entity.</param>
    /// <param name="SourceSystemId">System id for the record.</param>
    /// <param name="SentEmails">The record to contain the sent emails.</param>
    procedure GetSentEmails(SourceTableId: Integer; SourceSystemId: Guid; var SentEmails: Record "Sent Email" temporary);

    /// <summary>
    /// Get outbox emails that policy allow for a given record.
    /// </summary>
    /// <param name="SourceTableId">Table id for the entity.</param>
    /// <param name="SourceSystemId">System id for the record.</param>
    /// <param name="OutboxEmails">The record to contain the outbox emails.</param>
    procedure GetOutboxEmails(SourceTableId: Integer; SourceSystemId: Guid; var OutboxEmails: Record "Email Outbox" temporary);

    /// <summary>
    /// Establish if User has access to sent email.
    /// </summary>
    /// <param name="SentEmail">Record in Sent Email</param>
    /// <returns>Returns true if User has access to view sent email.
    /// Otherwise false.</returns>
    procedure HasAccess(SentEmail: Record "Sent Email"): Boolean;

    /// <summary>
    /// Establish if User has access to email in outbox.
    /// </summary>
    /// <param name="OutboxEmail">Record in Email Outbox</param>
    /// <returns>Returns true if User has access to view sent email.
    /// Otherwise false.</returns>
    procedure HasAccess(OutboxEmail: Record "Email Outbox"): Boolean;
}