namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Threading;
using System.Environment;
using System.Security.User;

codeunit 6412 "ForNAV Peppol Job Queue"
{
    Access = Internal;
    trigger OnRun()
    begin
        ProcessEntries();
    end;

    local procedure ProcessEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Enqueue: Codeunit "Job Queue - Enqueue";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Job Queue Category Code", GetForNAVCategoryCode());
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        JobQueueEntry.SetFilter(Status, '', JobQueueEntry.Status::"On Hold", JobQueueEntry.Status::Ready, JobQueueEntry.Status::Waiting, JobQueueEntry.Status::Error);
        if JobQueueEntry.FindSet() then
            repeat
                case JobQueueEntry.Status of
                    JobQueueEntry.Status::Error:
                        JobQueueEntry.Restart();
                    else
                        Enqueue.Run(JobQueueEntry);
                end;
            until JobQueueEntry.Next() = 0;
    end;

    internal procedure SetupJobQueue()
    begin
        SetupJobQueueCategory();
        SetupJobQueueEntry();
    end;

    local procedure SetupJobQueueCategory()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueDescriptionLbl: Label 'ForNAV Job Queue', Locked = true;
    begin
        if JobQueueCategory.Get(GetForNAVCategoryCode()) then
            exit;

        JobQueueCategory.Code := GetForNAVCategoryCode();
        JobQueueCategory.Description := CopyStr(JobQueueDescriptionLbl, 1, MaxStrLen(JobQueueCategory.Description));
        JobQueueCategory.Insert();
    end;

    local procedure SetupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Enqueue: Codeunit "Job Queue - Enqueue";
        EnvironmentInformation: Codeunit "Environment Information";
        JobQueueDescriptionLbl: Label 'Used by ForNAV to process incoming e-documents', Locked = true;
    begin
        JobQueueEntry.SetRange("Job Queue Category Code", GetForNAVCategoryCode());
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"ForNAV Peppol Job Queue");
        if JobQueueEntry.FindFirst() then begin
            Enqueue.Run(JobQueueEntry);
            exit;
        end;

        JobQueueEntry."Object ID to Run" := Codeunit::"ForNAV Peppol Job Queue";
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Job Queue Category Code" := GetForNAVCategoryCode();
        JobQueueEntry.Description := CopyStr(JobQueueDescriptionLbl, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);

        JobQueueEntry."No. of Minutes between Runs" := EnvironmentInformation.IsSaaSInfrastructure() ? 1 : 60;
        Enqueue.Run(JobQueueEntry);
    end;

    internal procedure GetForNAVCategoryCode() Result: Code[10]
    var
        JobQueueCategoryLbl: Label 'ForNAV', Locked = true;
    begin
        Result := CopyStr(JobQueueCategoryLbl, 1, MaxStrLen(Result));
    end;

    procedure ProcessEntriesIfSuper()
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if UserPermissions.IsSuper(UserSecurityId()) then begin
            ProcessEntries();
            SelectLatestVersion();
        end;
    end;
}