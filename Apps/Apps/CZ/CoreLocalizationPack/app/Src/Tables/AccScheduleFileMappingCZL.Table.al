// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using System.Utilities;

table 11751 "Acc. Schedule File Mapping CZL"
{
    Caption = 'Accounting Schedule File Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(3; "Schedule Name"; Code[10])
        {
            Caption = 'Schedule Name';
            TableRelation = "Acc. Schedule Name";
            DataClassification = CustomerContent;
        }
        field(4; "Schedule Line No."; Integer)
        {
            Caption = 'Schedule Line No.';
            TableRelation = "Acc. Schedule Line"."Line No." where("Schedule Name" = field("Schedule Name"));
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(5; "Schedule Column Layout Name"; Code[10])
        {
            Caption = 'Schedule Column Layout Name';
            TableRelation = "Column Layout Name".Name;
            DataClassification = CustomerContent;
        }
        field(6; "Schedule Column No."; Integer)
        {
            Caption = 'Schedule Column No.';
            TableRelation = "Column Layout"."Line No." where("Column Layout Name" = field("Schedule Column Layout Name"));
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(8; "Excel Cell"; Code[50])
        {
            Caption = 'Excel Cell';
            CharAllowed = '09,R,C';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Excel Cell" <> '' then begin
                    TestRowColumn("Excel Cell");
                    AccScheduleFileMappingCZL.Reset();
                    AccScheduleFileMappingCZL.SetRange("Schedule Name", "Schedule Name");
                    AccScheduleFileMappingCZL.SetRange("Schedule Column Layout Name", "Schedule Column Layout Name");
                    AccScheduleFileMappingCZL.SetRange("Excel Cell", "Excel Cell");
                    AccScheduleFileMappingCZL.SetFilter("Schedule Line No.", '<>%1', "Schedule Line No.");
                    if AccScheduleFileMappingCZL.FindFirst() then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DuplicateQst, AccScheduleFileMappingCZL."Schedule Line No.", AccScheduleFileMappingCZL."Schedule Column No."), true) then
                            Error('');
                    AccScheduleFileMappingCZL.SetRange("Schedule Line No.");
                    AccScheduleFileMappingCZL.SetFilter("Schedule Column No.", '<>%1', "Schedule Column No.");
                    if AccScheduleFileMappingCZL.FindFirst() then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DuplicateQst, AccScheduleFileMappingCZL."Schedule Line No.", AccScheduleFileMappingCZL."Schedule Column No."), true) then
                            Error('');

                    Evaluate("Excel Row No.", CopyStr("Excel Cell", 2, Cpos - 2));
                    Evaluate("Excel Column No.", CopyStr("Excel Cell", Cpos + 1, StrLen("Excel Cell")));
                end else begin
                    "Excel Row No." := 0;
                    "Excel Column No." := 0;
                end;
            end;
        }
        field(10; "Excel Row No."; Integer)
        {
            Caption = 'Excel Row No.';
            Editable = false;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(11; "Excel Column No."; Integer)
        {
            Caption = 'Excel Column No.';
            Editable = false;
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(20; Split; Option)
        {
            Caption = 'Split';
            OptionCaption = ' ,Right,Left';
            OptionMembers = " ",Right,Left;
            DataClassification = CustomerContent;
        }
        field(21; Offset; Integer)
        {
            Caption = 'Offset';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Schedule Name", "Schedule Line No.", "Schedule Column Layout Name", "Schedule Column No.", "Excel Cell")
        {
            Clustered = true;
        }
    }
    var
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        CellFormatErr: Label 'Cell value must be on format RxCy.';
        DuplicateQst: Label 'There is the same cell value in line %1 and column %2.\Continue?', Comment = '%1 = Line, %2 = Column';
        Cpos: Integer;
        RowTok: Label 'R', Locked = true;
        ColumnTok: Label 'C', Locked = true;

    procedure TestRowColumn(Cell: Code[50])
    begin
        if CopyStr(Cell, 1, 1) <> RowTok then
            Error(CellFormatErr);
        Cpos := StrPos(Cell, ColumnTok);
        if Cpos < 3 then
            Error(CellFormatErr);
    end;
}
