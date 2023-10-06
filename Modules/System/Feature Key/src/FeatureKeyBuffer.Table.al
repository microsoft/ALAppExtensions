// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// This temporary table extends the "Feature Key" virtual table. The fields must be in sync across both tables. 
/// New fields are added from id = 100 upwards.
/// </summary>
table 2609 "Feature Key Buffer"
{
    Caption = 'Feature Key';
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Feature Key" = rm,
                  tabledata "Feature Data Update Status" = r,
                  tabledata "Feature Dependency" = r;

    fields
    {
        field(1; ID; Text[50])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(2; Enabled; Option)
        {
            Caption = 'Enabled';
            OptionCaption = 'None,All Users';
            OptionMembers = "None","All Users";

            trigger OnValidate()
            begin
                // FeatureManagementFacade.ValidateEnabled(Rec, FeatureDataUpdateStatus);
            end;
        }
        field(3; Description; Text[2048])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; "Learn More Link"; Text[2048])
        {
            Caption = 'Learn more';
            Editable = false;
        }
        field(5; "Mandatory By"; Text[2048])
        {
            Caption = 'Approximate mandatory date';
            Editable = false;
        }
        field(6; "Can Try"; Boolean)
        {
            Caption = 'Get started';
            Editable = false;
        }
        field(7; "Is One Way"; Boolean)
        {
            Caption = 'Is One Way';
            Editable = false;
        }
        field(8; "Data Update Required"; Boolean)
        {
            Caption = 'Data Update Required';
            Editable = false;
        }
        field(100; Index; Integer)
        {
            Caption = 'Index';
            Editable = false;
        }
        field(101; Indentation; Integer)
        {
            Caption = 'Indentation';
            Editable = false;
        }
        field(102; Parent; Boolean)
        {
            Caption = 'Parent';
            Editable = false;
        }
    }

    keys
    {
        key(PK; Index, ID)
        {
            Clustered = true;
        }
    }

    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        TryItOutLbl: Label 'Try it out';

    internal procedure DrillDownTryItOut()
    begin
        // FeatureManagementFacade.DrillDownTryItOut(Rec);
    end;

    internal procedure Refresh()
    begin
        // FeatureManagementFacade.Refresh(Rec, FeatureDataUpdateStatus);
    end;

    internal procedure ScheduleDataUpdate()
    begin
        // FeatureManagementFacade.Update(FeatureDataUpdateStatus);
    end;

    internal procedure ShowDataUpdateLog()
    begin
        FeatureManagementFacade.OnShowTaskLog(FeatureDataUpdateStatus);
    end;

    internal procedure CancelDataUpdateTask()
    begin
        FeatureManagementFacade.CancelTask(FeatureDataUpdateStatus, true);
    end;

    internal procedure GetDataUpdateSessionId(): Integer
    begin
        exit(FeatureDataUpdateStatus."Session ID");
    end;

    internal procedure GetDataUpdateStartDateTime(): DateTime
    begin
        exit(FeatureDataUpdateStatus."Start Date/Time");
    end;

    internal procedure GetDataUpdateStatus(): Enum "Feature Status"
    begin
        exit(FeatureDataUpdateStatus."Feature Status");
    end;

    internal procedure GetDataUpdateTaskId(): Guid
    begin
        exit(FeatureDataUpdateStatus."Task ID");
    end;

    internal procedure GetDataUpdateServerInstanceId(): Integer
    begin
        exit(FeatureDataUpdateStatus."Server Instance ID");
    end;

    internal procedure GetTryItOutMessage(): Text
    begin
        if "Can Try" then
            exit(TryItOutLbl);
        exit('');
    end;

    internal procedure UpdateVisibility(var ActionVisibility: Dictionary of [Text, Boolean])
    begin
        // FeatureManagementFacade.UpdateVisibility(Rec, FeatureDataUpdateStatus, ActionVisibility);
    end;
}