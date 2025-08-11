// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Threading;

table 30137 "Shpfy Initial Import Line"
{
    Access = Internal;
    Caption = 'Shopfiy Initial Import Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Name; Code[20])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(2; "Dependency Filter"; Text[250])
        {
            Caption = 'Dependency Filter';
            DataClassification = SystemMetadata;
        }
        field(3; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = SystemMetadata;
        }
        field(4; "Job Status"; Option)
        {
            Caption = 'Job Status';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Success,In Process,Error';
            OptionMembers = " ",Success,"In Process",Error;
        }
        field(5; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                JobQueueEntry: Record "Job Queue Entry";
            begin
                if not IsNullGuid("Job Queue Entry ID") then
                    if JobQueueEntry.Get("Job Queue Entry ID") then
                        SetJobQueueEntryStatus(JobQueueEntry.Status)
                    else
                        SetJobQueueEntryStatus(JobQueueEntry.Status::Error);
            end;
        }
        field(6; "Job Queue Entry Status"; Option)
        {
            Caption = 'Job Queue Entry Status';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Ready,In Process,Error,On Hold,Finished';
            OptionMembers = " ",Ready,"In Process",Error,"On Hold",Finished;

            trigger OnValidate()
            begin
                if "Job Queue Entry Status" = "Job Queue Entry Status"::"In Process" then
                    "Session ID" := SessionId()
                else
                    "Session ID" := 0;

                UpdateJobStatus();
            end;
        }
        field(7; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(8; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            DataClassification = SystemMetadata;
        }
        field(9; "Demo Import"; Boolean)
        {
            Caption = 'Demo Import';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    local procedure UpdateJobStatus()
    begin
        case "Job Queue Entry Status" of
            "Job Queue Entry Status"::" ", "Job Queue Entry Status"::"On Hold", "Job Queue Entry Status"::Ready:
                "Job Status" := "Job Status"::" ";
            "Job Queue Entry Status"::"In Process":
                "Job Status" := "Job Status"::"In Process";
            "Job Queue Entry Status"::Error:
                "Job Status" := "Job Status"::"Error";
            "Job Queue Entry Status"::Finished:
                "Job Status" := "Job Status"::Success;
        end;
    end;

    internal procedure SetJobQueueEntryStatus(Status: Option)
    begin
        // shift the options to have an undefined state ' ' as 0.
        Validate("Job Queue Entry Status", Status + 1);
    end;
}