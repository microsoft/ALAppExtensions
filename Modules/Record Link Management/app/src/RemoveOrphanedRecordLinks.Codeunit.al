// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 459 "Remove Orphaned Record Links"
{
    // This codeunit is created so that records links that have obsolete record ids can be deleted in a scheduled task.


    trigger OnRun()
    var
        RecordLinkImpl: Codeunit "Record Link Impl.";
    begin
        RecordLinkImpl.RemoveOrphanedLinks();
    end;
}

