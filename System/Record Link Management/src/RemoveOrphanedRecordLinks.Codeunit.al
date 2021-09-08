// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit is created so that record links that have obsolete record ids can be deleted in a scheduled task.
/// </summary>
codeunit 459 "Remove Orphaned Record Links"
{
    Access = Public;

    trigger OnRun()
    var
        RecordLinkImpl: Codeunit "Record Link Impl.";
    begin
        RecordLinkImpl.RemoveOrphanedLinks();
    end;
}

