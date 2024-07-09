// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Setup;

page 11702 "Acc. Schedule File Mapping CZL"
{
    Caption = 'Accounting Schedule File Mapping';
    DataCaptionExpression = CurrentSchedName + ' - ' + CurrentColumnName;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Acc. Schedule Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CurrentSchedName; CurrentSchedName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Schedule Name';
                    Lookup = true;
                    LookupPageId = "Account Schedule Names";
                    ToolTip = 'Specifies the account schedule name.';
                    Editable = false;
                }
                field(CurrentColumnName; CurrentColumnName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Column Layout Name';
                    Lookup = true;
                    TableRelation = "Column Layout Name".Name;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';
                    Editable = false;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a number for the account schedule line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies text that will appear on the account schedule line.';
                }
                field("ColumnValues[1]"; ColumnValues[1])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[1];
                    ToolTip = 'Specifies the value of the column 1. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(1);
                        AfterValidate(1);
                    end;
                }
                field("ColumnValues[2]"; ColumnValues[2])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[2];
                    ToolTip = 'Specifies the value of the column 2. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(2);
                        AfterValidate(2);
                    end;
                }
                field("ColumnValues[3]"; ColumnValues[3])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[3];
                    ToolTip = 'Specifies the value of the column 3. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(3);
                        AfterValidate(3);
                    end;
                }
                field("ColumnValues[4]"; ColumnValues[4])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[4];
                    ToolTip = 'Specifies the value of the column 4. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(4);
                        AfterValidate(4);
                    end;
                }
                field("ColumnValues[5]"; ColumnValues[5])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[5];
                    ToolTip = 'Specifies the value of the column 5. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(5);
                        AfterValidate(5);
                    end;
                }
                field("ColumnValues[6]"; ColumnValues[6])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[6];
                    ToolTip = 'Specifies the value of the column 6. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(6);
                        AfterValidate(6);
                    end;
                }
                field("ColumnValues[7]"; ColumnValues[7])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[7];
                    ToolTip = 'Specifies the value of the column 7. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(7);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(7);
                        AfterValidate(7);
                    end;
                }
                field("ColumnValues[8]"; ColumnValues[8])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[8];
                    ToolTip = 'Specifies the value of the column 8. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(8);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(8);
                        AfterValidate(8);
                    end;
                }
                field("ColumnValues[9]"; ColumnValues[9])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[9];
                    ToolTip = 'Specifies the value of the column 9. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(9);
                        AfterValidate(9);
                    end;
                }
                field("ColumnValues[10]"; ColumnValues[10])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[10];
                    ToolTip = 'Specifies the value of the column 10. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(10);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(10);
                        AfterValidate(10);
                    end;
                }
                field("ColumnValues[11]"; ColumnValues[11])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[11];
                    ToolTip = 'Specifies the value of the column 11. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(11);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(11);
                        AfterValidate(11);
                    end;
                }
                field("ColumnValues[12]"; ColumnValues[12])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + ColumnCaptions[12];
                    ToolTip = 'Specifies the value of the column 12. Contend of the column depends on column layout name setup.';

                    trigger OnDrillDown()
                    begin
                        DrillDown(12);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateColumn(12);
                        AfterValidate(12);
                    end;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(ExportToExcel)
            {
                Caption = 'Export to Excel';
                Image = ExportToExcel;
                action(CreateNewDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create New Document';
                    Ellipsis = true;
                    Image = ExportToExcel;
                    ToolTip = 'Creates new Excel document.';

                    trigger OnAction()
                    var
                        AccScheduleExportFileCZL: Report "Acc. Schedule Export File CZL";
                    begin
                        AccScheduleName.Get(Rec."Schedule Name");
                        AccScheduleExportFileCZL.SetAccSchedName(CurrentSchedName);
                        AccScheduleExportFileCZL.SetColumnLayoutName(CurrentColumnName);
                        AccScheduleExportFileCZL.SetExportAction(0);
                        AccScheduleExportFileCZL.Run();
                    end;
                }
                action(UpdateExistingDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Update Existing Document';
                    Ellipsis = true;
                    Image = ExportToExcel;
                    ToolTip = 'Updates existing Excel document.';

                    trigger OnAction()
                    var
                        AccScheduleExportFileCZL: Report "Acc. Schedule Export File CZL";
                    begin
                        AccScheduleName.Get(Rec."Schedule Name");
                        AccScheduleExportFileCZL.SetAccSchedName(CurrentSchedName);
                        AccScheduleExportFileCZL.SetColumnLayoutName(CurrentColumnName);
                        AccScheduleExportFileCZL.SetExportAction(1);
                        AccScheduleExportFileCZL.Run();
                    end;
                }
                action(CreateFromTemplate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create from Template';
                    Ellipsis = true;
                    Image = ExportToExcel;
                    ToolTip = 'Creates from exisiting Excel template.';

                    trigger OnAction()
                    var
                        AccScheduleExportFileCZL: Report "Acc. Schedule Export File CZL";
                    begin
                        AccScheduleName.Get(Rec."Schedule Name");
                        AccScheduleExportFileCZL.SetAccSchedName(CurrentSchedName);
                        AccScheduleExportFileCZL.SetColumnLayoutName(CurrentColumnName);
                        AccScheduleExportFileCZL.SetExportAction(2);
                        AccScheduleExportFileCZL.Run();
                    end;
                }
            }
            action("Previous Column")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Previous Column';
                Image = PreviousRecord;
                ToolTip = 'Show the account schedule based on the previous column.';

                trigger OnAction()
                begin
                    AdjustColumnOffset(-1);
                end;
            }
            action("Next Column")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next Column';
                Image = NextRecord;
                ToolTip = 'Show the account schedule based on the next column.';

                trigger OnAction()
                begin
                    AdjustColumnOffset(1);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Previous Column_Promoted"; "Previous Column")
                {
                }
                actionref("Next Column_Promoted"; "Next Column")
                {
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        ColumnNo: Integer;
    begin
        Clear(ColumnValues);
        FirstAccScheduleFileMappingCZL.Reset();
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Name", CurrentSchedName);
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Line No.", Rec."Line No.");
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Column Layout Name", CurrentColumnName);

        if TempColumnLayout.FindSet() then
            repeat
                ColumnNo += 1;
                if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                    FirstAccScheduleFileMappingCZL.SetRange("Schedule Column No.", TempColumnLayout."Line No.");
                    if FirstAccScheduleFileMappingCZL.FindSet() then
                        if FirstAccScheduleFileMappingCZL.Count() > 1 then begin
                            repeat
                                ColumnValues[ColumnNo - ColumnOffset] := ColumnValues[ColumnNo - ColumnOffset] + '|' + FirstAccScheduleFileMappingCZL."Excel Cell"
                            until FirstAccScheduleFileMappingCZL.Next() = 0;
                            ColumnValues[ColumnNo - ColumnOffset] := DelChr(ColumnValues[ColumnNo - ColumnOffset], '<', '|')
                        end else
                            ColumnValues[ColumnNo - ColumnOffset] := FirstAccScheduleFileMappingCZL."Excel Cell";
                    ColumnLayout[ColumnNo - ColumnOffset] := TempColumnLayout;
                end;
            until TempColumnLayout.Next() = 0;
    end;

    trigger OnOpenPage()
    begin
        GeneralLedgerSetup.Get();
        if CurrentSchedName = '' then
            CurrentSchedName := SchedNameTxt;
        if CurrentColumnName = '' then
            CurrentColumnName := SchedNameTxt;
        AccSchedManagement.CopyColumnsToTemp(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.OpenSchedule(CurrentSchedName, Rec);
        AccSchedManagement.OpenColumns(CurrentColumnName, TempColumnLayout);
        UpdateColumnCaptions();
    end;

    var
        FirstAccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        SecondAccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        TempColumnLayout: Record "Column Layout" temporary;
        ColumnLayout: array[12] of Record "Column Layout";
        AccScheduleName: Record "Acc. Schedule Name";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccSchedManagement: Codeunit AccSchedManagement;
        CurrentSchedName: Code[10];
        CurrentColumnName: Code[10];
        ColumnValues: array[12] of Code[50];
        ColumnCaptions: array[12] of Text[80];
        ColumnOffset: Integer;
        SchedNameTxt: Label 'DEFAULT', MaxLength = 10;

    procedure SetAccSchedName(NewAccSchedName: Code[10])
    begin
        CurrentSchedName := NewAccSchedName;
    end;

    procedure SetColumnLayoutName(NewColumnLayoutName: Code[10])
    begin
        CurrentColumnName := NewColumnLayoutName;
    end;

    procedure ValidateColumn(ColumnNo: Integer)
    begin
        if ColumnValues[ColumnNo] <> '' then begin
            Clear(SecondAccScheduleFileMappingCZL);
            SecondAccScheduleFileMappingCZL.TestRowColumn(ColumnValues[ColumnNo]);
        end;
    end;

    procedure AfterValidate(ColumnNo: Integer)
    begin
        TempColumnLayout := ColumnLayout[ColumnNo];

        if ColumnValues[ColumnNo] <> '' then begin
            SecondAccScheduleFileMappingCZL.Init();
            SecondAccScheduleFileMappingCZL."Schedule Name" := CurrentSchedName;
            SecondAccScheduleFileMappingCZL."Schedule Line No." := Rec."Line No.";
            SecondAccScheduleFileMappingCZL."Schedule Column Layout Name" := CurrentColumnName;
            SecondAccScheduleFileMappingCZL."Schedule Column No." := TempColumnLayout."Line No.";
            SecondAccScheduleFileMappingCZL.Validate("Excel Cell", ColumnValues[ColumnNo]);
            if SecondAccScheduleFileMappingCZL.Insert() then;
        end;
    end;

    local procedure DrillDown(ColumnNo: Integer)
    begin
        TempColumnLayout := ColumnLayout[ColumnNo];
        FirstAccScheduleFileMappingCZL.Reset();
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Name", CurrentSchedName);
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Line No.", Rec."Line No.");
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Column Layout Name", CurrentColumnName);
        FirstAccScheduleFileMappingCZL.SetRange("Schedule Column No.", TempColumnLayout."Line No.");
        Page.RunModal(Page::"File Mapping CZL", FirstAccScheduleFileMappingCZL);
        CurrPage.Update(false);
    end;

    local procedure UpdateColumnCaptions()
    var
        ColumnNo: Integer;
        i: Integer;
    begin
        Clear(ColumnCaptions);
        if TempColumnLayout.FindSet() then
            repeat
                ColumnNo += 1;
                if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnCaptions)) then
                    ColumnCaptions[ColumnNo - ColumnOffset] := TempColumnLayout."Column Header";
            until (ColumnNo - ColumnOffset = ArrayLen(ColumnCaptions)) or (TempColumnLayout.Next() = 0);
        for i := ColumnNo - ColumnOffset + 1 to ArrayLen(ColumnCaptions) do
            ColumnCaptions[i] := '';
    end;

    local procedure AdjustColumnOffset(Delta: Integer)
    var
        OldColumnOffset: Integer;
    begin
        OldColumnOffset := ColumnOffset;
        ColumnOffset := ColumnOffset + Delta;
        if ColumnOffset + 12 > TempColumnLayout.Count() then
            ColumnOffset := TempColumnLayout.Count() - 12;
        if ColumnOffset < 0 then
            ColumnOffset := 0;
        if ColumnOffset <> OldColumnOffset then begin
            UpdateColumnCaptions();
            CurrPage.Update(false);
        end;
    end;
}
