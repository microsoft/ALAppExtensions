// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table stores feature data update status per company.
/// </summary>
table 2610 "Feature Data Update Status"
{
    DataPerCompany = false;

    fields
    {
        field(1; "Feature Key"; Text[50])
        {
            Caption = 'Feature Key';
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(3; "Data Update Required"; Boolean)
        {
            Caption = 'Data Update Required';
        }
        field(4; "Feature Status"; Enum "Feature Status")
        {
            Caption = 'Current Company Status';
        }
        field(5; "Start Date/Time"; DateTime)
        {
            Caption = 'Start Date/Time';

            trigger OnLookup()
            var
                FeatureManagementImpl: Codeunit "Feature Management Impl.";
            begin
                Validate("Start Date/Time", FeatureManagementImpl.LookupDateTime("Start Date/Time"));
            end;

            trigger OnValidate()
            begin
                if ("Start Date/Time" <> 0DT) and ("Start Date/Time" < CurrentDateTime) then
                    "Start Date/Time" := CurrentDateTime;
            end;
        }
        field(6; Confirmed; Boolean)
        {
            Caption = 'Confirmed';
            DataClassification = SystemMetadata;
        }
        field(7; "Task Id"; Guid)
        {
            Caption = 'Task Id';
            DataClassification = SystemMetadata;
        }
        field(8; "Session Id"; Integer)
        {
            Caption = 'Session Id';
            DataClassification = SystemMetadata;
        }
        field(9; "Server Instance Id"; Integer)
        {
            Caption = 'Server Instance Id';
            DataClassification = SystemMetadata;
        }
        field(10; "Background Task"; Boolean)
        {
            Caption = 'Background Task';

            trigger OnValidate()
            begin
                if "Background Task" then
                    Rec."Start Date/Time" := CurrentDateTime
                else
                    Clear(Rec."Start Date/Time");
            end;
        }
    }

    keys
    {
        key(PK; "Feature Key", "Company Name")
        { }
    }
}