// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

/// <summary>
/// The list showing call tree of methods that occured during the performance profiler recording.
/// </summary>
page 1921 "Profiling Call Tree"
{
    Caption = 'Call Tree';
    PageType = ListPart;
    SourceTable = "Profiling Node";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    InherentEntitlements = X;
    InherentPermissions = X;


    layout
    {
        area(Content)
        {
            repeater("Profiler Events")
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indentation;
                TreeInitialState = CollapseAll;
                Editable = false;

                field("Method Name"; Rec."Method Name")
                {
                    ApplicationArea = All;
                    Caption = 'Method Name';
                    ToolTip = 'Specifies the name of the method that was called.';
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the type of the application object.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    Tooltip = 'Specifies the name of the application object.';
                }
                field("Self Time"; Rec."Self Time")
                {
                    ApplicationArea = All;
                    Caption = 'Self Time';
                    Tooltip = 'Specifies the amount of time spent only in this method.';
                }
                field("Full Time"; Rec."Full Time")
                {
                    ApplicationArea = All;
                    Caption = 'Total Time';
                    Tooltip = 'Specifies the amount of time spent in this method and the methods it calls.';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'App Name';
                    Tooltip = 'Specifies the name of the app that the application object belongs to.';
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
        ProfilingDataProcessor.GetFullTimeAggregate(Rec, Enum::"Profiling Aggregation Type"::"None");
        Rec.FindFirst();
    end;
}

