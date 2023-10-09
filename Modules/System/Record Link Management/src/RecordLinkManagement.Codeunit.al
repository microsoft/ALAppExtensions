// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Utilities;

using System.Environment.Configuration;

/// <summary>
/// Exposes functionality to administer record links related to table records.
/// </summary>
codeunit 447 "Record Link Management"
{
    Access = Public;
    SingleInstance = true;

    var
        RecordLinkImpl: Codeunit "Record Link Impl.";

    /// <summary>
    /// Copies all the links from one record to the other and sets Notify to FALSE for them.
    /// </summary>
    /// <raises>OnAfterCopyLinks</raises>
    /// <param name="FromRecord">The source record from which links are copied.</param>
    /// <param name="ToRecord">The destination record to which links are copied.</param>
    procedure CopyLinks(FromRecord: Variant; ToRecord: Variant)
    begin
        RecordLinkImpl.CopyLinks(FromRecord, ToRecord);
    end;

    /// <summary>
    /// Writes the Note BLOB into the format the client code expects.
    /// </summary>
    /// <param name="RecordLink">The record link passed as a VAR to which the note is added.</param>
    /// <param name="Note">The note to be added.</param>
    procedure WriteNote(var RecordLink: Record "Record Link"; Note: Text)
    begin
        RecordLinkImpl.WriteNote(RecordLink, Note);
    end;

    /// <summary>
    /// Read the Note BLOB
    /// </summary>
    /// <param name="RecordLink">The record link from which the note is read.</param>
    /// <returns>The note as a text.</returns>
    procedure ReadNote(RecordLink: Record "Record Link"): Text
    begin
        exit(RecordLinkImpl.ReadNote(RecordLink));
    end;

    /// <summary>
    /// Removes all record links from all records in the RecVariant within current filters
    /// </summary>
    /// <param name="RecVariant">A filtered record. All record links associated with records within the filtered recordset will be deleted.</param>
    procedure RemoveLinks(RecVariant: Variant)
    begin
        RecordLinkImpl.RemoveLinks(RecVariant);
    end;

    /// <summary>
    /// Iterates over the record link table and removes those with obsolete record ids.
    /// </summary>
    procedure RemoveOrphanedLinks()
    begin
        RecordLinkImpl.RemoveOrphanedLinks();
    end;

#if not CLEAN23
    /// <summary>
    /// Integration event for before copying links.
    /// </summary>
    /// <param name="FromRecord">The source record from which links are copied.</param>
    /// <param name="ToRecord">The destination record to which links are copied.</param>
    /// <param name="SkipReset">Out parameter not used anymore. Obsolete.</param>
    [Obsolete('Not used anymore.', '23.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCopyLinks(FromRecord: Variant; ToRecord: Variant; var SkipReset: Boolean)
    begin
    end;
#endif

    /// <summary>
    /// Integration event for after copying links from one record to the other.
    /// </summary>
    /// <param name="FromRecord">The source record from which links are copied.</param>
    /// <param name="ToRecord">The destination record to which links are copied.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCopyLinks(FromRecord: Variant; ToRecord: Variant)
    begin
    end;
}

