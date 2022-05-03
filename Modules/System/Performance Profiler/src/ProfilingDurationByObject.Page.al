// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The list showing the breakdown of time spent by application object on the performance profiler page.
/// </summary>
page 1923 "Profiling Duration By Object"
{
    Caption = 'Time Spent by Application Object';
    PageType = ListPart;
    SourceTable = "Profiling Node";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Duration per application object")
            {
                Editable = false;
                FreezeColumn = "Object Name";

                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'The type of the application object.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'The name of the application object.';
                }
                field("Time Spent"; Rec."Self Time")
                {
                    ApplicationArea = All;
                    Caption = 'Time Spent';
                    ToolTip = 'The amount of time spent in this application object.';

                    trigger OnDrillDown()
                    var
                        ProfilingDurationByMethod: Page "Profiling Duration By Method";
                    begin
                        ProfilingDurationByMethod.Initialize(Rec."Object Type", Rec."Object Id");
                        ProfilingDurationByMethod.RunModal();
                    end;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'App Name';
                    ToolTip = 'The name of the app that the application object belongs to.';
                }
            }
        }
    }


    trigger OnOpenPage()
    begin
        UpdateData();
    end;

    internal procedure UpdateData()
    var
        ProfilingDataProcessor: Codeunit "Profiling Data Processor";
    begin
        Rec.DeleteAll();
        Rec.SetCurrentKey("Object Type", "Object ID");
        ProfilingDataProcessor.GetSelfTimeAggregate(Rec, Enum::"Profiling Aggregation Type"::Object);
        Rec.SetCurrentKey("Self Time");
        Rec.Ascending(false);
        Rec.FindFirst();
    end;
}

