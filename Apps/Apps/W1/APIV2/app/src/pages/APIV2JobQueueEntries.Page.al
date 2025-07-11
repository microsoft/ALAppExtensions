namespace Microsoft.API.V2;

using System.Threading;

page 30091 "APIV2 - Job Queue Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Job Queue Entry';
    EntitySetCaption = 'Job Queue Entries';
    Editable = false;
    EntityName = 'jobQueueEntry';
    EntitySetName = 'jobQueueEntries';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Job Queue Entry";
    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(jobQueueEntryId; Rec.ID)
                {
                    Caption = 'Job Queue Entry Id';
                }
                field(userId; Rec."User ID")
                {
                    Caption = 'User Id';
                }
                field(lastReadyState; Rec."Last Ready State")
                {
                    Caption = 'Last Ready State';
                }
                field(expirationDateTime; Rec."Expiration Date/Time")
                {
                    Caption = 'Expiration Date/Time';
                }
                field(earliestStartDateTime; Rec."Earliest Start Date/Time")
                {
                    Caption = 'Earliest Start Date/Time';
                }
                field(objectTypeToRun; Rec."Object Type to Run")
                {
                    Caption = 'Object Type to Run';
                }
                field(objectIdToRun; Rec."Object ID to Run")
                {
                    Caption = 'Object Id to Run';
                }
                field(objectCaptionToRun; Rec."Object Caption to Run")
                {
                    Caption = 'Object Caption to Run';
                }
                field(reportOutputType; Rec."Report Output Type")
                {
                    Caption = 'Report Output Type';
                }
                field(maxNumberAttemptsToRun; Rec."Maximum No. of Attempts to Run")
                {
                    Caption = 'Maximum No. of Attempts to Run';
                }
                field(numberOfAttemptsToRun; Rec."No. of Attempts to Run")
                {
                    Caption = 'No. of Attempts to Run';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(recordIdToProcess; Rec."Record ID to Process")
                {
                    Caption = 'Record Id to Process';
                }
                field(parameterString; Rec."Parameter String")
                {
                    Caption = 'Parameter String';
                }
                field(recurringJob; Rec."Recurring Job")
                {
                    Caption = 'Recurring Job';
                }
                field(numberOfMinutesBetweenRuns; Rec."No. of Minutes between Runs")
                {
                    Caption = 'No. of Minutes between Runs';
                }
                field(runOnMonday; Rec."Run on Mondays")
                {
                    Caption = 'Run on Mondays';
                }
                field(runOnTuesday; Rec."Run on Tuesdays")
                {
                    Caption = 'Run on Tuesdays';
                }
                field(runOnWednesday; Rec."Run on Wednesdays")
                {
                    Caption = 'Run on Wednesdays';
                }
                field(runOnThursday; Rec."Run on Thursdays")
                {
                    Caption = 'Run on Thursdays';
                }
                field(runOnFridays; Rec."Run on Fridays")
                {
                    Caption = 'Run on Fridays';
                }
                field(runOnSaturdays; Rec."Run on Saturdays")
                {
                    Caption = 'Run on Saturdays';
                }
                field(runOnSundays; Rec."Run on Sundays")
                {
                    Caption = 'Run on Sundays';
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'Starting Time';
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'Ending Time';
                }
                field(referenceStartingTime; Rec."Reference Starting Time")
                {
                    Caption = 'Reference Starting Time';
                }
                field(nextRunDateFormula; Rec."Next Run Date Formula")
                {
                    Caption = 'Next Run Date Formula';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(runInUserSession; Rec."Run in User Session")
                {
                    Caption = 'Run in User Session';
                }
                field(userSessionId; Rec."User Session ID")
                {
                    Caption = 'User Session Id';
                }
                field(jobQueueCategoryCode; Rec."Job Queue Category Code")
                {
                    Caption = 'Job Queue Category Code';
                }
                field(errorMessage; Rec."Error Message")
                {
                    Caption = 'Error Message';
                }
                field(userServiceInstanceId; Rec."User Service Instance ID")
                {
                    Caption = 'User Service Instance Id';
                }
                field(userSessionStarted; Rec."User Session Started")
                {
                    Caption = 'User Session Started';
                }

                field(notifyOnSuccess; Rec."Notify On Success")
                {
                    Caption = 'Notify On Success';
                }
                field(userLanguageId; Rec."User Language ID")
                {
                    Caption = 'User Language Id';
                }
                field(printerName; Rec."Printer Name")
                {
                    Caption = 'Printer Name';
                }
                field(reportRequestPageOptions; Rec."Report Request Page Options")
                {
                    Caption = 'Report Request Page Options';
                }
                field(rerunDelay; Rec."Rerun Delay (sec.)")
                {
                    Caption = 'Rerun Delay (sec.)';
                }
                field(systemTaskId; Rec."System Task ID")
                {
                    Caption = 'System Task Id';
                }
                field(scheduled; Rec.Scheduled)
                {
                    Caption = 'Scheduled';
                }
                field(manualRecurrence; Rec."Manual Recurrence")
                {
                    Caption = 'Manual Recurrence';
                }
                field(jobTimeOut; Rec."Job Timeout")
                {
                    Caption = 'Job Timeout';
                }
                field(priorityWithinCategory; Rec."Priority Within Category")
                {
                    Caption = 'Priority';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(jobQueueLogEntry; "APIV2 - Job Queue Log Entries")
                {
                    Caption = 'Job Queue Log Entries';
                    EntityName = 'jobQueueLogEntry';
                    EntitySetName = 'jobQueueLogEntries';
                    SubPageLink = ID = field(ID);
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Restart(var ActionContext: WebServiceActionContext)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Job Queue Entries");
        ActionContext.AddEntityKey(Rec.FieldNo(Id), Rec.SystemId);

        Rec.Restart();
        if Rec.Status = Rec.Status::Ready then
            ActionContext.SetResultCode(WebServiceActionResultCode::Updated)
        else
            ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}