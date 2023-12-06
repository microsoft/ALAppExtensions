// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Security.User;

page 31206 "Acc. Sched. Res. Overview CZL"
{
    Caption = 'Acc. Schedule Results Overview';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Acc. Schedule Result Hdr. CZL";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Result Code"; Rec."Result Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the result code of account schedule results.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of account schedule results.';
                }
                field("Date Filter"; Rec."Date Filter")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date filter of account schedule results.';
                }
                field("Acc. Schedule Name"; Rec."Acc. Schedule Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the account schedule.';
                }
                field("Column Layout Name"; Rec."Column Layout Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';
                }
            }
            part(SubForm; "Acc. Sch. Res. Sub. Matrix CZL")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Result Code" = field("Result Code");
            }
            group("Dimension Filters")
            {
                Caption = 'Dimension Filters';
                field("Dimension 1 Filter"; Rec."Dimension 1 Filter")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies dimensions which was used by account schedule results creating.';
                }
                field("Dimension 2 Filter"; Rec."Dimension 2 Filter")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies dimensions which was used by account schedule results creating.';
                }
                field("Dimension 3 Filter"; Rec."Dimension 3 Filter")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies dimensions which was used by account schedule results creating.';
                }
                field("Dimension 4 Filter"; Rec."Dimension 4 Filter")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies dimensions which was used by account schedule results creating.';
                }
            }
            group(Options)
            {
                Caption = 'Options';
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user associated with the entry.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Result Date"; Rec."Result Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the created date of account schedule results.';
                }
                field("Result Time"; Rec."Result Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the created time of account schedule results.';
                }
                field(ShowOnlyChangedValues; ShowOnlyChangedValues)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Only Changed Values';
                    ToolTip = 'Specifies when the only changed values are to be show';

                    trigger OnValidate()
                    begin
                        ShowOnlyChangedValuesOnAfterValidate();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'Functions';
                action(Print)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Allows print the account schedule results.';

                    trigger OnAction()
                    var
                        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
                    begin
                        AccScheduleResultHdrCZL := Rec;
                        AccScheduleResultHdrCZL.SetRecFilter();
                        Report.RunModal(Report::"Account Schedule Result CZL", true, false, AccScheduleResultHdrCZL);
                    end;
                }
                action("Export to Excel")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export to Excel';
                    Ellipsis = true;
                    Image = ExportToExcel;
                    ToolTip = 'Allows the account schedule results export to excel.';

                    trigger OnAction()
                    var
                        ExpAccSchedResExcCZL: Report "Exp. Acc. Sched. Res. Exc. CZL";
                    begin
                        ExpAccSchedResExcCZL.SetOptions(Rec."Result Code", false);
                        ExpAccSchedResExcCZL.Run();
                    end;
                }
            }
            action("Next Set")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Go to the next set of the account schedule results.';

                trigger OnAction()
                begin
                    MATRIX_SetWanted := MATRIX_SetWanted::Next;
                    UpdateColumnSet();
                    CurrPage.SubForm.PAGE.Load(MATRIX_ColumnSet, MATRIX_ColumnCaption);
                end;
            }
            action("Previous Set")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous set of the account schedule results.';

                trigger OnAction()
                begin
                    MATRIX_SetWanted := MATRIX_SetWanted::Previous;
                    UpdateColumnSet();
                    CurrPage.SubForm.PAGE.Load(MATRIX_ColumnSet, MATRIX_ColumnCaption);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if xRec."Result Code" <> Rec."Result Code" then
            MATRIX_SetWanted := MATRIX_SetWanted::Initial;
        UpdateColumnSet();
        CurrPage.SubForm.PAGE.Load(MATRIX_ColumnSet, MATRIX_ColumnCaption);
    end;

    var
        ShowOnlyChangedValues: Boolean;
        MATRIX_SetWanted: Option Initial,Next,Previous,Same;
        StackCounter: Integer;
        MATRIX_ColumnSet: array[4] of Integer;
        MATRIX_ColumnCaption: array[4] of Text[1024];

    procedure UpdateColumnSet()
    var
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        AccScheduleResultColCZL.Reset();
        AccScheduleResultColCZL.SetRange("Result Code", Rec."Result Code");

        case MATRIX_SetWanted of
            MATRIX_SetWanted::Initial:
                begin
                    MATRIX_SetWanted := MATRIX_SetWanted::Same;
                    if AccScheduleResultColCZL.FindSet() then begin
                        Clear(MATRIX_ColumnSet);
                        ClearMATRIX_ColumnCaption();
                        for StackCounter := 1 to 4 do begin
                            MATRIX_ColumnSet[StackCounter] := AccScheduleResultColCZL."Line No.";
                            MATRIX_ColumnCaption[StackCounter] := GetColumnName(MATRIX_ColumnSet[StackCounter]);
                            if AccScheduleResultColCZL.Next() = 0 then
                                exit;
                        end;
                    end;
                end;
            MATRIX_SetWanted::Next:
                begin
                    MATRIX_SetWanted := MATRIX_SetWanted::Same;
                    if MATRIX_ColumnSet[4] <> 0 then
                        AccScheduleResultColCZL.SetFilter("Line No.", '%1..', MATRIX_ColumnSet[4])
                    else
                        exit;
                    if AccScheduleResultColCZL.FindSet() then
                        for StackCounter := 1 to 4 do begin
                            if AccScheduleResultColCZL.Next() = 0 then
                                exit;
                            if (StackCounter = 1) and (AccScheduleResultColCZL."Line No." <> MATRIX_ColumnSet[4]) then begin
                                Clear(MATRIX_ColumnSet);
                                ClearMATRIX_ColumnCaption();
                            end;
                            MATRIX_ColumnSet[StackCounter] := AccScheduleResultColCZL."Line No.";
                            MATRIX_ColumnCaption[StackCounter] := GetColumnName(MATRIX_ColumnSet[StackCounter]);
                        end;
                end;
            MATRIX_SetWanted::Previous:
                begin
                    MATRIX_SetWanted := MATRIX_SetWanted::Same;
                    if MATRIX_ColumnSet[1] <> 0 then
                        AccScheduleResultColCZL.SetFilter("Line No.", '..%1', MATRIX_ColumnSet[1])
                    else
                        exit;
                    if AccScheduleResultColCZL.FindSet() then begin
                        repeat
                        until AccScheduleResultColCZL.Next() = 0;
                        AccScheduleResultColCZL.Next(-4);
                    end;
                    if AccScheduleResultColCZL."Line No." <> MATRIX_ColumnSet[1] then begin
                        Clear(MATRIX_ColumnSet);
                        ClearMATRIX_ColumnCaption();
                        for StackCounter := 1 to 4 do begin
                            MATRIX_ColumnSet[StackCounter] := AccScheduleResultColCZL."Line No.";
                            MATRIX_ColumnCaption[StackCounter] := GetColumnName(MATRIX_ColumnSet[StackCounter]);
                            if AccScheduleResultColCZL.Next() = 0 then
                                exit;
                        end;
                    end;
                end;
        end;
    end;

    procedure GetColumnName(ColumnNo: Integer): Text[1024]
    var
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        AccScheduleResultColCZL.SetRange("Result Code", Rec."Result Code");
        AccScheduleResultColCZL.SetRange("Line No.", ColumnNo);
        if AccScheduleResultColCZL.FindFirst() then
            exit(AccScheduleResultColCZL."Column Header");
        exit('');
    end;

    procedure ClearMATRIX_ColumnCaption()
    var
        i: Integer;
    begin
        for i := 1 to 4 do
            MATRIX_ColumnCaption[i] := '';
    end;

    local procedure ShowOnlyChangedValuesOnAfterValidate()
    begin
        CurrPage.SubForm.Page.SetShowOnlyChangeValue(ShowOnlyChangedValues);
    end;
}
