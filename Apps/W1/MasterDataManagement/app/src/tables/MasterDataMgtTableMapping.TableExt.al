namespace Microsoft.Integration.MDM;

using System.Threading;
using Microsoft.Integration.SyncEngine;

tableextension 7235 MasterDataMgtTableMapping extends "Integration Table Mapping"
{
    fields
    {
        field(7234; "Overwrite Local Change"; Boolean)
        {
            Caption = 'Overwrite Local Change';

            trigger OnValidate()
            begin
                if "Overwrite Local Change" then
                    if not Confirm(OverwriteLocalChangesQst) then
                        Error('');
            end;
        }
        field(7235; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Enabled,Disabled';
            OptionMembers = Enabled,Disabled;

            trigger OnValidate()
            var
                JobQueueEntry: Record "Job Queue Entry";
            begin
                JobQueueEntry.LockTable();
                JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                JobQueueEntry.SetFilter("Object ID to Run", '%1|%2|%3', Codeunit::"Integration Synch. Job Runner", Codeunit::"Int. Uncouple Job Runner", Codeunit::"Int. Coupling Job Runner");
                JobQueueEntry.SetRange("Record ID to Process", Rec.RecordId());
                if JobQueueEntry.FindSet() then
                    repeat
                        if Status = Status::Disabled then
                            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold")
                        else
                            JobQueueEntry.Restart();
                    until JobQueueEntry.Next() = 0;
                Commit();
            end;
        }
    }

    var
        OverwriteLocalChangesQst: Label 'This will make the synchronization engine overwrite any local changes that are done on this table. \\To enable this setting only for chosen fields, choose the Synchronization Fields action. \\Do you want to continue and enable it for the table?';
}