// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

using System.Utilities;

page 7286 "Item Info. From  File"
{
    Caption = 'Mapped & Selected column values in the file';
    PageType = List;
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    InherentPermissions = X;
    InherentEntitlements = X;
    SourceTable = Integer;
    SourceTableTemporary = true;
    SourceTableView = where(Number = filter(1 ..));
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Rep)
            {
                field(Id; Rec.Number)
                {
                    Caption = ' ';
                    ApplicationArea = All;
                    Visible = NoOfColumnsVisible > 10;
                    ToolTip = 'Specifies the line number.';
                }
                field(Column0; GetCellValue(Rec.Number, LeftMostColumnIndex))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex);
                    ApplicationArea = All;
                    Visible = ColumnVisible1;
                    StyleExpr = StyleExpression1;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column1; GetCellValue(Rec.Number, LeftMostColumnIndex + 1))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 1);
                    ApplicationArea = All;
                    Visible = ColumnVisible2;
                    StyleExpr = StyleExpression2;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column2; GetCellValue(Rec.Number, LeftMostColumnIndex + 2))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 2);
                    ApplicationArea = All;
                    Visible = ColumnVisible3;
                    StyleExpr = StyleExpression3;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Colum3; GetCellValue(Rec.Number, LeftMostColumnIndex + 3))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 3);
                    ApplicationArea = All;
                    Visible = ColumnVisible4;
                    StyleExpr = StyleExpression4;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column4; GetCellValue(Rec.Number, LeftMostColumnIndex + 4))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 4);
                    ApplicationArea = All;
                    Visible = ColumnVisible5;
                    StyleExpr = StyleExpression5;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column5; GetCellValue(Rec.Number, LeftMostColumnIndex + 5))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 5);
                    ApplicationArea = All;
                    Visible = ColumnVisible6;
                    StyleExpr = StyleExpression6;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column6; GetCellValue(Rec.Number, LeftMostColumnIndex + 6))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 6);
                    ApplicationArea = All;
                    Visible = ColumnVisible7;
                    StyleExpr = StyleExpression7;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column7; GetCellValue(Rec.Number, LeftMostColumnIndex + 7))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 7);
                    ApplicationArea = All;
                    Visible = ColumnVisible8;
                    StyleExpr = StyleExpression8;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column8; GetCellValue(Rec.Number, LeftMostColumnIndex + 8))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 8);
                    ApplicationArea = All;
                    Visible = ColumnVisible9;
                    StyleExpr = StyleExpression9;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
                field(Column9; GetCellValue(Rec.Number, LeftMostColumnIndex + 9))
                {
                    CaptionClass = '3,' + GetColumnHeading(LeftMostColumnIndex + 9);
                    ApplicationArea = All;
                    Visible = ColumnVisible10;
                    StyleExpr = StyleExpression10;
#pragma warning disable AA0219
                    ToolTip = 'This is a generated column and does not have a tooltip.';
#pragma warning restore AA0219
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Left)
            {
                Caption = 'Scroll Left';
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = PreviousRecord;
                Visible = NoOfColumnsVisible > 10;
                ToolTip = 'Scroll to the left to view more columns.';

                trigger OnAction()
                begin
                    if LeftMostColumnIndex > 1 then
                        LeftMostColumnIndex -= 1;
                end;
            }
            action(Right)
            {
                Caption = 'Scroll Right';
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = NextRecord;
                Visible = NoOfColumnsVisible > 10;
                ToolTip = 'Scroll to the right to view more columns.';

                trigger OnAction()
                begin
                    LeftMostColumnIndex += 1;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        LeftMostColumnIndex := 1;
    end;

    var
        GlobalFileHandlerResult: Codeunit "File Handler Result";
        GlobalFileContentAsTable: List of [List of [Text]];
        LeftMostColumnIndex: Integer;
        GlobalMappedColumns: List of [Integer];
        GlobalVisibleColumns: List of [Integer];
        GlobalCurrentColumn: Integer;
        NoOfColumnsVisible: Integer;
        CurrentColumnIsInMappedColumns: Boolean;
        ColumnVisible1, ColumnVisible2, ColumnVisible3, ColumnVisible4, ColumnVisible5, ColumnVisible6, ColumnVisible7, ColumnVisible8, ColumnVisible9, ColumnVisible10 : Boolean;
        ColumnVisible: array[10] of Boolean;
        StyleExpression1, StyleExpression2, StyleExpression3, StyleExpression4, StyleExpression5, StyleExpression6, StyleExpression7, StyleExpression8, StyleExpression9, StyleExpression10 : Text;
        StyleExpression: array[10] of Text;

    internal procedure ScrollLeft()
    begin
        if NoOfColumnsVisible <= 10 then
            exit;
        if LeftMostColumnIndex > 1 then
            LeftMostColumnIndex -= 1;
    end;

    internal procedure ScrollRight()
    var
        HeaderRow: List of [Text];
    begin
        if NoOfColumnsVisible <= 10 then
            exit;
        if GlobalFileContentAsTable.Count() > 0 then begin
            HeaderRow := GlobalFileContentAsTable.Get(1);
            if LeftMostColumnIndex + 5 <= HeaderRow.Count() then
                LeftMostColumnIndex += 1;
        end;
    end;

    internal procedure LoadData(Data: List of [List of [Text]]; FileHandlerResult: Codeunit "File Handler Result"; SelectedColumns: List of [Integer]; CurrentColumn: Integer)
    var
        SalesLineFromAttachment: Codeunit "Sales Line From Attachment";
        i: Integer;
        MaxDataRows: Integer;
    begin
        Clear(GlobalFileContentAsTable);
        Clear(GlobalMappedColumns);
        Clear(GlobalVisibleColumns);
        Clear(GlobalCurrentColumn);
        Clear(CurrentColumnIsInMappedColumns);
        Clear(ColumnVisible);
        Clear(StyleExpression);
        Clear(GlobalFileHandlerResult);
        NoOfColumnsVisible := 0;
        GlobalFileContentAsTable := Data;
        GlobalMappedColumns := SelectedColumns;
        GlobalCurrentColumn := CurrentColumn;
        GlobalFileHandlerResult := FileHandlerResult;

        CurrentColumnIsInMappedColumns := GlobalMappedColumns.Contains(GlobalCurrentColumn);
        NoOfColumnsVisible := NumberOfColumnsToShow();
        GlobalVisibleColumns := GlobalMappedColumns;
        GlobalVisibleColumns.Add(GlobalCurrentColumn);
        SetColumnVisibility();
        SetStyleExpressions();
        Clear(Rec);
        if GlobalFileHandlerResult.GetContainsHeaderRow() then
            MaxDataRows := Data.Count() - 1
        else
            MaxDataRows := Data.Count();

        if MaxDataRows > SalesLineFromAttachment.GetMaxRowsToShow() then
            MaxDataRows := SalesLineFromAttachment.GetMaxRowsToShow();
        for i := 1 to MaxDataRows do begin
            Rec.Number := i;
            Rec.Insert();
        end;
    end;

    local procedure NumberOfColumnsToShow(): Integer
    begin
        if CurrentColumnIsInMappedColumns then
            exit(GlobalMappedColumns.Count())
        else
            exit(GlobalMappedColumns.Count() + 1);
    end;

    local procedure GetColumnHeading(ColumnNumber: Integer): Text
    var
        ColumnName: Text;
        HeaderRow: List of [Text];
        ColumnIndex: Integer;
    begin
        if (GlobalFileContentAsTable.Count() > 0) and (ColumnNumber > 0) then begin
            if GlobalFileHandlerResult.GetContainsHeaderRow() then
                HeaderRow := GlobalFileContentAsTable.Get(1)
            else
                HeaderRow := GlobalFileHandlerResult.GetColumnNames();
            if ColumnNumber <= GlobalMappedColumns.Count then begin
                ColumnIndex := GlobalMappedColumns.Get(ColumnNumber);
                if ColumnIndex > 0 then
                    ColumnName := HeaderRow.Get(ColumnIndex);
            end;
        end;
        exit(ColumnName);
    end;

    local procedure GetCellValue(Row: Integer; Column: Integer): Text
    var
        ColumnValue: Text;
        RowValue: List of [Text];
        ColumnIndex: Integer;
    begin
        if GlobalFileHandlerResult.GetContainsHeaderRow() then
            Row := Row + 1;
        if Row <= GlobalFileContentAsTable.Count() then begin
            RowValue := GlobalFileContentAsTable.Get(Row);
            if Column <= GlobalMappedColumns.Count then begin
                ColumnIndex := GlobalMappedColumns.Get(Column);
                if ColumnIndex > 0 then
                    ColumnValue := RowValue.Get(ColumnIndex);
            end;
        end;
        exit(ColumnValue);
    end;

    local procedure SetColumnVisibility()
    var
        i: Integer;
        NoOfColumns: Integer;
    begin
        Clear(ColumnVisible);

        if NoOfColumnsVisible > 10 then
            NoOfColumns := 10
        else
            NoOfColumns := NoOfColumnsVisible;

        for i := 1 to NoOfColumns do
            ColumnVisible[i] := true;

        ColumnVisible1 := ColumnVisible[1];
        ColumnVisible2 := ColumnVisible[2];
        ColumnVisible3 := ColumnVisible[3];
        ColumnVisible4 := ColumnVisible[4];
        ColumnVisible5 := ColumnVisible[5];
        ColumnVisible6 := ColumnVisible[6];
        ColumnVisible7 := ColumnVisible[7];
        ColumnVisible8 := ColumnVisible[8];
        ColumnVisible9 := ColumnVisible[9];
        ColumnVisible10 := ColumnVisible[10];
    end;

    local procedure SetStyleExpressions()
    var
        Index: Integer;
    begin
        Clear(StyleExpression);

        Index := GlobalVisibleColumns.IndexOf(GlobalCurrentColumn);
        if CurrentColumnIsInMappedColumns then
            StyleExpression[Index] := 'Strong'
        else
            StyleExpression[Index] := 'Subordinate';

        StyleExpression1 := StyleExpression[1];
        StyleExpression2 := StyleExpression[2];
        StyleExpression3 := StyleExpression[3];
        StyleExpression4 := StyleExpression[4];
        StyleExpression5 := StyleExpression[5];
        StyleExpression6 := StyleExpression[6];
        StyleExpression7 := StyleExpression[7];
        StyleExpression8 := StyleExpression[8];
        StyleExpression9 := StyleExpression[9];
        StyleExpression10 := StyleExpression[10];
    end;
}