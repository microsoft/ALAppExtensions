// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;

table 6255 "Sust. ESG Range Period"
{
    Caption = 'ESG Range Period';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Sust. ESG Range Periods";
    DrillDownPageId = "Sust. ESG Range Periods";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Guid)
        {
            Caption = 'No.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Period Starting Date"; Date)
        {
            Caption = 'Period Starting Date';

            trigger OnValidate()
            begin
                if ("Period Starting Date" > "Period Ending Date") and ("Period Ending Date" <> 0D) then
                    Error(StartingDateCannotBeAfterEndingDateErr, FieldCaption("Period Starting Date"), FieldCaption("Period Ending Date"));
            end;
        }
        field(9; "Period Ending Date"; Date)
        {
            Caption = 'Period Ending Date';

            trigger OnValidate()
            begin
                Validate("Period Starting Date");
            end;
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Range Period")));
            ToolTip = 'Specifies that the Range Period is coupled to an period in Dataverse.';
        }
        field(30; "Range Period ID"; Guid)
        {
            Caption = 'Range Period ID';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        StartingDateCannotBeAfterEndingDateErr: Label '%1 cannot be after %2', Comment = '%1 = Starting Date, %2 = Ending Date';
}