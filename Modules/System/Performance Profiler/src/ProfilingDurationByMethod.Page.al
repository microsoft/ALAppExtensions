// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A details page to be shown on drill-down of time spent aggregated by application object.
/// Shows the time spent aggregated per method name.
/// </summary>
page 1924 "Profiling Duration By Method"
{
    Caption = 'Application calls';
    PageType = ListPart;
    SourceTable = "Profiling Node";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    DataCaptionExpression = Rec."Object Type" + ' "' + Rec."Object Name" + '"';

    layout
    {
        area(Content)
        {
            repeater("Duration per line of code")
            {
                Editable = false;

                field("Method Name"; Rec."Method Name")
                {
                    ApplicationArea = All;
                    Caption = 'Method Name';
                    ToolTip = 'The name of the method in which the time was spent.';
                }
                field("Time Spent"; Rec."Self Time")
                {
                    ApplicationArea = All;
                    Caption = 'Time Spent';
                    ToolTip = 'The total time spent inside the method during the performance profiler recording.';
                }
                field("Sample Count"; Rec."Hit Count")
                {
                    ApplicationArea = All;
                    Caption = 'Sample Count';
                    ToolTip = 'The total number of samples in which the method was recorded.';
                }
            }
        }
    }

    internal procedure Initialize(AppObjectType: Text; AppObjectId: Integer)
    var
        ProfilingDataProcessor: Codeunit "Profiling Data Processor";
        TableViewFilter: Text;
    begin
        Rec.DeleteAll();
        TableViewFilter := 'WHERE(Object Type=Const(' + AppObjectType + '),Object ID=Const(' + Format(AppObjectId) + '))';
        Rec.SetCurrentKey("Object Type", "Object ID", "Method Name");
        ProfilingDataProcessor.GetSelfTimeAggregate(Rec, Enum::"Profiling Aggregation Type"::Method, TableViewFilter);

        Rec.SetCurrentKey("Self Time");
        Rec.Ascending(false);
        Rec.FindFirst();
    end;
}

