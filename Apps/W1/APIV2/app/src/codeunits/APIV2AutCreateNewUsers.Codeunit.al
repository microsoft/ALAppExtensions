codeunit 30004 "APIV2 - Aut. Create New Users"
{
    trigger OnRun()
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
    begin
        AzureADUserManagement.CreateNewUsersFromAzureAD();
    end;

    var
        APIV2JobQueueManagement: Codeunit "APIV2 - Job Queue Management";
        JobQueueDescriptionLbl: Label 'Create new users from Azure AD API job';
        JobQueueCategoryLbl: Label 'APIUSERJOB', Locked = true;


    procedure CreateNewUsersFromAzureADInBackground(): Guid
    var
    begin
        exit(APIV2JobQueueManagement.CreateAndScheduleBackgroundJob(Codeunit::"APIV2 - Aut. Create New Users", GetJobQueueCategory(), JobQueueDescriptionLbl));
    end;

    procedure IsJobScheduled(): Boolean
    begin
        exit(APIV2JobQueueManagement.IsJobScheduled(Codeunit::"APIV2 - Aut. Create New Users", GetJobQueueCategory(), JobQueueDescriptionLbl));
    end;

    local procedure GetJobQueueCategory(): Code[10]
    begin
        exit(JobQueueCategoryLbl);
    end;
}