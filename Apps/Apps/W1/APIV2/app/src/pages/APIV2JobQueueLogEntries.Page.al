namespace Microsoft.API.V2;

using System.Threading;

page 30090 "APIV2 - Job Queue Log Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Job Queue Log Entry';
    EntitySetCaption = 'Job Queue Log Entries';
    Editable = false;
    EntityName = 'jobQueueLogEntry';
    EntitySetName = 'jobQueueLogEntries';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Job Queue Log Entry";
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
                field(startDateTime; Rec."Start Date/Time")
                {
                    Caption = 'Start Date/Time';
                }
                field(endDateTime; Rec."End Date/Time")
                {
                    Caption = 'End Date/Time';
                }
                field(objectIdToRun; Rec."Object ID to Run")
                {
                    Caption = 'Object Id to Run';
                }
                field(objectTypeToRun; Rec."Object Type to Run")
                {
                    Caption = 'Object Type to Run';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(errorMessage; Rec."Error Message")
                {
                    Caption = 'Error Message';
                }
                field(jobQueueCategoryCode; Rec."Job Queue Category Code")
                {
                    Caption = 'Job Queue Category Code';
                }
                field(errorCallStack; Rec."Error Call Stack")
                {
                    Caption = 'Error Call Stack';
                }
                field(parameterString; Rec."Parameter String")
                {
                    Caption = 'Parameter String';
                }
                field(systemTaskId; Rec."System Task Id")
                {
                    Caption = 'System Task Id';
                }
                field(userSessionId; Rec."User Session ID")
                {
                    Caption = 'User Session Id';
                }
                field(userServiceInstanceId; Rec."User Service Instance ID")
                {
                    Caption = 'User Service Instance Id';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }
}