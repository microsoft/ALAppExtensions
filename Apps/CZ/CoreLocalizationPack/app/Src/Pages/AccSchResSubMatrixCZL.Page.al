// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

page 31207 "Acc. Sch. Res. Sub. Matrix CZL"
{
    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Acc. Schedule Result Line CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a Row number for the account schedule line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the description of account schedule results.';
                }
                field(Field1; Value[1])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    ToolTip = 'Specifies the value of account schedule result subpage matrix';
                    Visible = Field1Visible;

                    trigger OnAssistEdit()
                    begin
                        if Matrix_ColumnSet[1] <> 0 then
                            MatrixLookUp(Matrix_ColumnSet[1]);
                    end;

                    trigger OnValidate()
                    begin
                        Value1OnAfterValidate();
                    end;
                }
                field(Field2; Value[2])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    ToolTip = 'Specifies the value of account schedule result subpage matrix';
                    Visible = Field2Visible;

                    trigger OnAssistEdit()
                    begin
                        if Matrix_ColumnSet[2] <> 0 then
                            MatrixLookUp(Matrix_ColumnSet[2]);
                    end;

                    trigger OnValidate()
                    begin
                        Value2OnAfterValidate();
                    end;
                }
                field(Field3; Value[3])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    ToolTip = 'Specifies the value of account schedule result subpage matrix';
                    Visible = Field3Visible;

                    trigger OnAssistEdit()
                    begin
                        if Matrix_ColumnSet[3] <> 0 then
                            MatrixLookUp(Matrix_ColumnSet[3])
                    end;

                    trigger OnValidate()
                    begin
                        Value3OnAfterValidate();
                    end;
                }
                field(Field4; Value[4])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    ToolTip = 'Specifies the value of account schedule result subpage matrix';
                    Visible = Field4Visible;

                    trigger OnAssistEdit()
                    begin
                        if Matrix_ColumnSet[4] <> 0 then
                            MatrixLookUp(Matrix_ColumnSet[4]);
                    end;

                    trigger OnValidate()
                    begin
                        Value4OnAfterValidate();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RecordFlag: Boolean;
    begin
        Clear(Value);
        AccScheduleResultValueCZL.Reset();
        AccScheduleResultValueCZL.SetRange("Result Code", Rec."Result Code");
        AccScheduleResultValueCZL.SetRange("Row No.", Rec."Line No.");
        AccScheduleResultValueCZL.SetFilter("Column No.", '%1..', Matrix_ColumnSet[1]);
        if AccScheduleResultValueCZL.FindSet() then
            for StackCounter := 1 to 4 do begin
                if StackCounter <> 1 then
                    if AccScheduleResultValueCZL.Next() = 0 then
                        RecordFlag := true;
                if (not RecordFlag) and CheckValueRule(Matrix_ColumnSet[StackCounter]) then
                    UpdateValue(AccScheduleResultValueCZL.Value, StackCounter);
            end;
    end;

    trigger OnInit()
    begin
        Field4Visible := true;
        Field3Visible := true;
        Field2Visible := true;
        Field1Visible := true;
    end;

    var
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
        Value: array[4] of Decimal;
        ShowOnlyChangedValues: Boolean;
        Matrix_ColumnSet: array[4] of Integer;
        StackCounter: Integer;
        MATRIX_CaptionSet: array[4] of Text[1024];
        Field1Visible: Boolean;
        Field2Visible: Boolean;
        Field3Visible: Boolean;
        Field4Visible: Boolean;
        MatrixErr: Label 'Matrix column does not exists.';

    procedure UpdateValue(CelValue: Decimal; Counter: Integer)
    begin
        if Counter <> 0 then
            Value[Counter] := CelValue;
    end;

    procedure MatrixLookUp(ColumnNo: Integer)
    begin
        AccScheduleResultHistCZL.SetRange("Result Code", Rec."Result Code");
        AccScheduleResultHistCZL.SetRange("Row No.", Rec."Line No.");
        AccScheduleResultHistCZL.SetRange("Column No.", ColumnNo);
        Page.Run(Page::"Acc. Schedule Result Hist. CZL", AccScheduleResultHistCZL)
    end;

    procedure UpdateRecordValue(ColumnNo: Integer; ColumnValue: Decimal)
    begin
        if AccScheduleResultValueCZL.Get(Rec."Result Code", Rec."Line No.", ColumnNo) then begin
            AccScheduleResultValueCZL.Validate(Value, ColumnValue);
            AccScheduleResultValueCZL.Modify();
        end else begin
            AccScheduleResultValueCZL.Init();
            AccScheduleResultValueCZL."Result Code" := Rec."Result Code";
            AccScheduleResultValueCZL."Row No." := Rec."Line No.";
            AccScheduleResultValueCZL."Column No." := ColumnNo;
            AccScheduleResultValueCZL.Validate(Value, ColumnValue);
            AccScheduleResultValueCZL.Insert();
        end;
    end;

    procedure CheckValueRule(ColumnNo: Integer): Boolean
    var
        CheckAccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
    begin
        if not ShowOnlyChangedValues then
            exit(true);

        CheckAccScheduleResultHistCZL.SetRange("Result Code", Rec."Result Code");
        CheckAccScheduleResultHistCZL.SetRange("Row No.", Rec."Line No.");
        CheckAccScheduleResultHistCZL.SetRange("Column No.", ColumnNo);
        exit(not CheckAccScheduleResultHistCZL.IsEmpty());
    end;

    procedure SetShowOnlyChangeValue(NewShowOnlyChangedValues: Boolean)
    begin
        ShowOnlyChangedValues := NewShowOnlyChangedValues;
        CurrPage.Update(false);
    end;

    procedure Load(NewColumnStack: array[4] of Integer; NewColumnName: array[4] of Text[1024])
    begin
        Clear(Matrix_ColumnSet);
        Clear(MATRIX_CaptionSet);
        CopyArray(Matrix_ColumnSet, NewColumnStack, 1);
        CopyArray(MATRIX_CaptionSet, NewColumnName, 1);

        Field1Visible := MATRIX_CaptionSet[1] <> '';
        Field2Visible := MATRIX_CaptionSet[2] <> '';
        Field3Visible := MATRIX_CaptionSet[3] <> '';
        Field4Visible := MATRIX_CaptionSet[4] <> '';
    end;

    local procedure Value1OnAfterValidate()
    begin
        if Matrix_ColumnSet[1] <> 0 then
            UpdateRecordValue(Matrix_ColumnSet[1], Value[1])
        else
            Error(MatrixErr);
    end;

    local procedure Value2OnAfterValidate()
    begin
        if Matrix_ColumnSet[2] <> 0 then
            UpdateRecordValue(Matrix_ColumnSet[2], Value[2])
        else
            Error(MatrixErr);
    end;

    local procedure Value3OnAfterValidate()
    begin
        if Matrix_ColumnSet[3] <> 0 then
            UpdateRecordValue(Matrix_ColumnSet[3], Value[3])
        else
            Error(MatrixErr);
    end;

    local procedure Value4OnAfterValidate()
    begin
        if Matrix_ColumnSet[4] <> 0 then
            UpdateRecordValue(Matrix_ColumnSet[4], Value[4])
        else
            Error(MatrixErr);
    end;
}
