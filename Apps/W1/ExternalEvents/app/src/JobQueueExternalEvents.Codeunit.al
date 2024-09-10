namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using System.Threading;
using System.Azure.Identity;
using System.Environment;

codeunit 38507 "Job Queue External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', true, true)]
    local procedure OnAfterLogError(var JobQueueEntry: Record "Job Queue Entry"; var JobQueueLogEntry: Record "Job Queue Log Entry")
    var
        MicrosoftEntraTenantID: Text[250];
        EnvName: Text[250];
        JobQueueEntryUrl: Text[250];
        JobQueueLogEntryUrl: Text[250];
        JobQueueEntryWebClientUrl: Text[250];
        JobQueueEntryApiUrlTok: Label 'v2.0/companies(%1)/jobQueueEntries(%2)', Locked = true;
        JobQueueLogEntryApiUrlTok: Label 'v2.0/companies(%1)/jobQueueEntries(%2)/jobQueueLogEntries(%3)', Locked = true;
    begin
        MicrosoftEntraTenantID := CopyStr(AzureADTenant.GetAadTenantId(), 1, MaxStrLen(MicrosoftEntraTenantID));
        EnvName := CopyStr(EnvironmentInformation.GetEnvironmentName(), 1, MaxStrLen(EnvName));

        JobQueueEntryUrl := ExternalEventsHelper.CreateLink(JobQueueEntryApiUrlTok, JobQueueEntry.SystemId);
        JobQueueLogEntryUrl := ExternalEventsHelper.CreateLink(JobQueueLogEntryApiUrlTok, JobQueueEntry.SystemId, JobQueueLogEntry.SystemId);
        JobQueueEntryWebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Job Queue Entries", JobQueueEntry), 1, MaxStrLen(JobQueueEntryWebClientUrl));
        JobQueueTaskFailed(JobQueueEntry.SystemId, JobQueueLogEntry.SystemId, JobQueueEntryUrl, JobQueueLogEntryUrl, JobQueueEntryWebClientUrl, EnvName, MicrosoftEntraTenantID);
    end;

    [ExternalBusinessEvent('JobQueueTaskFailed', 'Job queue task failed', 'This business event is triggered when a task in job queue is failed.', EventCategory::"Job Queue", '1.0')]
    local procedure JobQueueTaskFailed(JobQueueEntrySystemId: Guid; JobQueueLogEntrySystemId: Guid; JobQueueEntryUrl: Text[250]; JobQueueLogEntryUrl: Text[250]; JobQueueEntryWebClientUrl: Text[250]; EnvironmentName: Text[250]; MicrosoftEntraTenantID: Text[250])
    begin
    end;

}