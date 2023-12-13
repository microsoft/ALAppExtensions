// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.CostAccounting.Budget;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Enums;
using System.IO;
using System.Utilities;

report 11776 "Acc. Schedule Export File CZL"
{
    Caption = 'Account Schedule Export File';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Acc. Schedule Name"; "Acc. Schedule Name")
        {
            DataItemTableView = sorting(Name);
            dataitem("Acc. Schedule Line"; "Acc. Schedule Line")
            {
                DataItemLink = "Schedule Name" = field(Name);
                DataItemTableView = sorting("Schedule Name", "Line No.");

                trigger OnAfterGetRecord()
                var
                    i: Integer;
                begin
                    for i := 1 to MaxColumnsDisplayed do begin
                        ColumnValuesDisplayed[i] := 0;
                        ColumnValuesAsText[i] := '';
                    end;

                    CalcColumns();
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter("Date Filter", DateFilter);
                    SetFilter("G/L Budget Filter", GLBudgetFilter);
                    SetFilter("Cost Budget Filter", CostBudgetFilter);
                    SetFilter("Business Unit Filter", BusinessUnitFilter);
                    SetFilter("Dimension 1 Filter", Dim1Filter);
                    SetFilter("Dimension 2 Filter", Dim2Filter);
                    SetFilter("Dimension 3 Filter", Dim3Filter);
                    SetFilter("Dimension 4 Filter", Dim4Filter);
                end;
            }

            trigger OnPreDataItem()
            var
                InStr: InStream;
                OutStr: OutStream;
                Sheet2: Text[250];
            begin
                SetRange(Name, AccSchedName);
                AccScheduleFileMappingCZL.Reset();
                AccScheduleFileMappingCZL.SetRange("Schedule Name", AccSchedName);
                AccScheduleFileMappingCZL.SetRange("Schedule Column Layout Name", ColumnLayoutName);
                if AccScheduleFileMappingCZL.IsEmpty() then
                    Error(MappingEmptyErr);

                case ExportAction of
                    ExportAction::CreateNew:
                        TempExcelBuffer.CreateNewBook(ColumnLayoutName);
                    ExportAction::UpdateExisting:
                        begin
                            FileName := FileManagement.BLOBImport(TempBlob, ExcelExtensionTok);
                            if FileName = '' then
                                Error(SelectWorksheetErr);
                            TempBlob.CreateInStream(InStr);
                            Sheet2 := TempExcelBuffer.SelectSheetsNameStream(InStr);
                            if Sheet2 = '' then
                                Error(SelectSheetErr)
                            else
                                SheetName := Sheet2;
                            TempBlob.CreateInStream(InStr);
                            TempExcelBuffer.UpdateBookStream(InStr, SheetName, true);
                        end;
                    ExportAction::FromTemplate:
                        begin
                            ExcelTemplateCZL.Get(ExcelTemplateCode);
                            ExcelTemplateCZL.TestField(Blocked, false);
                            ExcelTemplateCZL.TestField(Sheet);
                            ExcelTemplateCZL.CalcFields(Template);
                            ExcelTemplateCZL.Template.CreateInStream(InStr);
                            TempBlob.CreateOutStream(OutStr);
                            CopyStream(OutStr, Instr);
                            SheetName := ExcelTemplateCZL.Sheet;
                            TempBlob.CreateInStream(InStr);
                            TempExcelBuffer.UpdateBookStream(InStr, SheetName, true);
                        end;
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if "Analysis View Name" <> '' then
                    AnalysisView.Get("Analysis View Name")
                else begin
                    AnalysisView.Init();
                    AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
                    AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
                end;
            end;

            trigger OnPostDataItem()
            var
                OutStr: OutStream;
                ToFileName: Text;
            begin
                TempExcelBuffer.WriteSheet('', CompanyName(), UserId());
                TempExcelBuffer.CloseBook();
                TempBlob.CreateOutStream(OutStr);
                TempExcelBuffer.SaveToStream(OutStr, true);
                ToFileName := AccSchedName + ExcelExtensionTok;
                FileManagement.BLOBExport(TempBlob, ToFileName, true);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AccSchedNameCZL; AccSchedName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Acc. Schedule Name';
                        TableRelation = "Acc. Schedule Name";
                        ToolTip = 'Specifies the name of the account schedule to be shown in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            EntrdSchedName: Text[10];
                        begin
                            EntrdSchedName := CopyStr(Text, 1, 10);
                            if AccSchedManagement.LookupName(AccSchedName, EntrdSchedName) then
                                Text := EntrdSchedName;
                        end;

                        trigger OnValidate()
                        begin
                            AccSchedManagement.CheckName(AccSchedName);
                            AccScheduleName.Get(AccSchedName);
                            if AccScheduleName."Analysis View Name" <> '' then
                                AnalysisView.Get(AccScheduleName."Analysis View Name")
                            else begin
                                Clear(AnalysisView);
                                AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
                                AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
                            end;
                        end;
                    }
                    field(ColumnLayoutNameCZL; ColumnLayoutName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Column Layout Name';
                        Lookup = true;
                        TableRelation = "Column Layout Name".Name;
                        ToolTip = 'Specifies the name of the column layout that you want to use in the window.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            EntrdColumnName: Text[10];
                        begin
                            EntrdColumnName := CopyStr(Text, 1, 10);
                            if AccSchedManagement.LookupColumnName(ColumnLayoutName, EntrdColumnName) then
                                ColumnLayoutName := EntrdColumnName;
                        end;

                        trigger OnValidate()
                        begin
                            AccSchedManagement.CheckColumnName(ColumnLayoutName);
                        end;
                    }
                    field(ExcelTemplateCodeCZL; ExcelTemplateCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Excel Template';
                        TableRelation = "Excel Template CZL";
                        ToolTip = 'Specifies the excel template for the account schedule export.';
                        Visible = TemplateIsVisible;

                        trigger OnValidate()
                        begin
                            ValidateExcelTemplateCode();
                        end;
                    }
                }
                group(Filters)
                {
                    Caption = 'Filters';
                    field(DateFilterCZL; DateFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Date Filter';
                        ToolTip = 'Specifies the date filter for G/L accounts entries.';

                        trigger OnValidate()
                        begin
                            "Acc. Schedule Line".SetFilter("Date Filter", DateFilter);
                            DateFilter := "Acc. Schedule Line".GetFilter("Date Filter");
                        end;
                    }
                    field(GLBudgetFilterCZL; GLBudgetFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Budget Filter';
                        TableRelation = "G/L Budget Name".Name;
                        ToolTip = 'Specifies a general ledger budget filter for the report.';

                        trigger OnValidate()
                        begin
                            "Acc. Schedule Line".SetFilter("G/L Budget Filter", GLBudgetFilter);
                            GLBudgetFilter := "Acc. Schedule Line".GetFilter("G/L Budget Filter");
                        end;
                    }
                    field(CostBudgetFilterCZL; CostBudgetFilter)
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Budget Filter';
                        TableRelation = "Cost Budget Name".Name;
                        ToolTip = 'Specifies a cost budget filter for the report.';

                        trigger OnValidate()
                        begin
                            "Acc. Schedule Line".SetFilter("Cost Budget Filter", CostBudgetFilter);
                            CostBudgetFilter := "Acc. Schedule Line".GetFilter("Cost Budget Filter");
                        end;
                    }
                    field(BusinessUnitFilterCZL; BusinessUnitFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Business Unit Filter';
                        LookupPageId = "Business Unit List";
                        TableRelation = "Business Unit";
                        ToolTip = 'Specifies a business unit filter for the report.';

                        trigger OnValidate()
                        begin
                            "Acc. Schedule Line".SetFilter("Business Unit Filter", BusinessUnitFilter);
                            BusinessUnitFilter := "Acc. Schedule Line".GetFilter("Business Unit Filter");
                        end;
                    }
                }
                group("Dimension Filters")
                {
                    Caption = 'Dimension Filters';
                    field(Dim1FilterCZL; Dim1Filter)
                    {
                        ApplicationArea = Basic, Suite;
                        CaptionClass = PageGetCaptionClass(1);
                        Caption = 'Dimension 1 Filter';
                        Enabled = Dim1FilterEnable;
                        ToolTip = 'Specifies the filter for dimension 1.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(DimensionValue.LookUpDimFilter(AnalysisView."Dimension 1 Code", Text));
                        end;
                    }
                    field(Dim2FilterCZL; Dim2Filter)
                    {
                        ApplicationArea = Basic, Suite;
                        CaptionClass = PageGetCaptionClass(2);
                        Caption = 'Dimension 2 Filter';
                        Enabled = Dim2FilterEnable;
                        ToolTip = 'Specifies the filter for dimension 2.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(DimensionValue.LookUpDimFilter(AnalysisView."Dimension 2 Code", Text));
                        end;
                    }
                    field(Dim3FilterCZL; Dim3Filter)
                    {
                        ApplicationArea = Basic, Suite;
                        CaptionClass = PageGetCaptionClass(3);
                        Caption = 'Dimension 3 Filter';
                        Enabled = Dim3FilterEnable;
                        ToolTip = 'Specifies the filter for dimension 3.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(DimensionValue.LookUpDimFilter(AnalysisView."Dimension 3 Code", Text));
                        end;
                    }
                    field(Dim4FilterCZL; Dim4Filter)
                    {
                        ApplicationArea = Basic, Suite;
                        CaptionClass = PageGetCaptionClass(4);
                        Caption = 'Dimension 4 Filter';
                        Enabled = Dim4FilterEnable;
                        ToolTip = 'Specifies the filter for dimension 4.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(DimensionValue.LookUpDimFilter(AnalysisView."Dimension 4 Code", Text));
                        end;
                    }
                }
                group(Show)
                {
                    Caption = 'Show';
                    field(UseAmtsInAddCurrCZL; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        ToolTip = 'Specifies when the amounts in additional reporting currency is to be show.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            GeneralLedgerSetup.Get();
            if AccSchedNameHidden <> '' then
                AccSchedName := AccSchedNameHidden;
            if ColumnLayoutNameHidden <> '' then
                ColumnLayoutName := ColumnLayoutNameHidden;
            if AccSchedName <> '' then
                if not AccScheduleName.Get(AccSchedName) then
                    AccSchedName := '';
            if AccSchedName = '' then
                if AccScheduleName.FindFirst() then
                    AccSchedName := AccScheduleName.Name;
            if AccScheduleName."Analysis View Name" <> '' then
                AnalysisView.Get(AccScheduleName."Analysis View Name")
            else begin
                AnalysisView."Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
                AnalysisView."Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
            end;

            UpdateEnabledControls();
        end;
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        TempExcelBuffer.DeleteAll();
        InitAccSched();
    end;

    var
        AccScheduleName: Record "Acc. Schedule Name";
        TempColumnLayout: Record "Column Layout" temporary;
        AnalysisView: Record "Analysis View";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
        ExcelTemplateCZL: Record "Excel Template CZL";
        DimensionValue: Record "Dimension Value";
        AccSchedManagement: Codeunit AccSchedManagement;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        AccSchedName: Code[10];
        AccSchedNameHidden: Code[10];
        ColumnLayoutName: Code[10];
        ColumnLayoutNameHidden: Code[10];
        ExcelTemplateCode: Code[20];
        ShowError: Option "None","Division by Zero","Period Error",Both;
        DateFilter: Text;
        CostBudgetFilter: Text;
        GLBudgetFilter: Text;
        BusinessUnitFilter: Text;
        Dim1Filter: Text;
        Dim1FilterEnable: Boolean;
        Dim2Filter: Text;
        Dim2FilterEnable: Boolean;
        Dim3Filter: Text;
        Dim3FilterEnable: Boolean;
        Dim4Filter: Text;
        Dim4FilterEnable: Boolean;
        ColumnValuesDisplayed: array[100] of Decimal;
        ColumnValuesAsText: array[100] of Text[30];
        MaxColumnsDisplayed: Integer;
        UseAmtsInAddCurr: Boolean;
        FileName: Text;
        SheetName: Text[250];
        DivideByZeroTxt: Label '* ERROR *';
        NotAvailableTxt: Label 'Not Available';
        MappingEmptyErr: Label 'XLS mapping is empty.';
        ExcelExtensionTok: Label '.xlsx', Locked = true;
        SelectWorksheetErr: Label 'Select Worksheet to update';
        SelectSheetErr: Label 'Select Sheet to update';
        TemplateIsVisible: Boolean;
        ExportAction: Option CreateNew,UpdateExisting,FromTemplate;

    local procedure InitAccSched()
    begin
        MaxColumnsDisplayed := ArrayLen(ColumnValuesDisplayed);
        AccSchedManagement.CopyColumnsToTemp(ColumnLayoutName, TempColumnLayout);
    end;

    procedure SetAccSchedName(NewAccSchedName: Code[10])
    begin
        AccSchedNameHidden := NewAccSchedName;
    end;

    procedure SetColumnLayoutName(ColLayoutName: Code[10])
    begin
        ColumnLayoutNameHidden := ColLayoutName;
    end;

    local procedure CalcColumns() NonZero: Boolean
    var
        i: Integer;
    begin
        NonZero := false;
        TempColumnLayout.SetRange(TempColumnLayout."Column Layout Name", ColumnLayoutName);
        i := 0;
        if TempColumnLayout.FindSet() then
            repeat
                if TempColumnLayout.Show <> TempColumnLayout.Show::Never then begin
                    i += 1;
                    ColumnValuesDisplayed[i] :=
                      AccSchedManagement.CalcCell("Acc. Schedule Line", TempColumnLayout, UseAmtsInAddCurr);
                    if AccSchedManagement.GetDivisionError() then
                        if ShowError in [ShowError::"Division by Zero", ShowError::Both] then
                            ColumnValuesAsText[i] := DivideByZeroTxt
                        else
                            ColumnValuesAsText[i] := ''
                    else
                        if AccSchedManagement.GetPeriodError() then
                            if ShowError in [ShowError::"Period Error", ShowError::Both] then
                                ColumnValuesAsText[i] := NotAvailableTxt
                            else
                                ColumnValuesAsText[i] := ''
                        else begin
                            NonZero := NonZero or (ColumnValuesDisplayed[i] <> 0);
                            ColumnValuesAsText[i] :=
                              FormatCellAsText(TempColumnLayout, ColumnValuesDisplayed[i], false);
                        end;
                end;

                AccScheduleFileMappingCZL.Reset();
                AccScheduleFileMappingCZL.SetRange("Schedule Name", "Acc. Schedule Line"."Schedule Name");
                AccScheduleFileMappingCZL.SetRange("Schedule Line No.", "Acc. Schedule Line"."Line No.");
                AccScheduleFileMappingCZL.SetRange("Schedule Column Layout Name", TempColumnLayout."Column Layout Name");
                AccScheduleFileMappingCZL.SetRange("Schedule Column No.", TempColumnLayout."Line No.");
                if AccScheduleFileMappingCZL.FindSet() then
                    repeat
                        AddTempExcelBuffer(AccScheduleFileMappingCZL."Excel Row No.",
                          AccScheduleFileMappingCZL."Excel Column No.",
                          ColumnValuesAsText[i],
                          AccScheduleFileMappingCZL.Split,
                          AccScheduleFileMappingCZL.Offset);
                    until AccScheduleFileMappingCZL.Next() = 0;
            until (i >= MaxColumnsDisplayed) or (TempColumnLayout.Next() = 0);
    end;

    local procedure AddTempExcelBuffer(Line: Integer; Column: Integer; Value: Text[250]; Split: Option " ",Right,Left; Offset: Integer)
    var
        i: Integer;
        BufferOffset: Integer;
    begin
        if (Line = 0) or (Column = 0) then
            exit;

        BufferOffset := 0;
        case Split of
            Split::" ":
                begin
                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", Line);
                    TempExcelBuffer.Validate("Column No.", Column);
                    TempExcelBuffer."Cell Value as Text" := Value;
                    if not TempExcelBuffer.Insert() then
                        TempExcelBuffer.Modify();
                end;
            Split::Right:
                for i := 1 to StrLen(Value) do begin
                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", Line);
                    TempExcelBuffer.Validate("Column No.", Column + BufferOffset);
                    TempExcelBuffer."Cell Value as Text" := CopyStr(Value, i, 1);
                    if not TempExcelBuffer.Insert() then
                        TempExcelBuffer.Modify();
                    BufferOffset += Offset;
                end;
            Split::Left:
                for i := StrLen(Value) downto 1 do begin
                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", Line);
                    TempExcelBuffer.Validate("Column No.", Column - BufferOffset);
                    TempExcelBuffer."Cell Value as Text" := CopyStr(Value, i, 1);
                    if not TempExcelBuffer.Insert() then
                        TempExcelBuffer.Modify();
                    BufferOffset += Offset;
                end;
        end;
    end;

    local procedure PageGetCaptionClass(DimNo: Integer): Text[250]
    begin
        exit(AnalysisView.GetCaptionClassCZL(DimNo));
    end;

    local procedure UpdateEnabledControls()
    begin
        Dim1FilterEnable := AnalysisView."Dimension 1 Code" <> '';
        Dim2FilterEnable := AnalysisView."Dimension 2 Code" <> '';
        Dim3FilterEnable := AnalysisView."Dimension 3 Code" <> '';
        Dim4FilterEnable := AnalysisView."Dimension 4 Code" <> '';
    end;

    local procedure ValidateExcelTemplateCode()
    begin
        if ExcelTemplateCode <> '' then
            ExcelTemplateCZL.Get(ExcelTemplateCode);
        UpdateEnabledControls();
    end;

    procedure SetExportAction(NewExportAction: Option CreateNew,UpdateExisting,FromTemplate)
    begin
        ExportAction := NewExportAction;
        TemplateIsVisible := ExportAction = ExportAction::FromTemplate;
    end;

    local procedure FormatCellAsText(var ColumnLayout2: Record "Column Layout"; Value: Decimal; CalcAddCurr: Boolean) ValueAsText: Text[30]
    begin
        ValueAsText := FormatAmount(Value, ColumnLayout2."Rounding Factor", CalcAddCurr);

        if (ValueAsText <> '') and
           (ColumnLayout2."Column Type" = ColumnLayout2."Column Type"::Formula) and
           (StrPos(ColumnLayout2.Formula, '%') > 1)
        then
            ValueAsText := CopyStr(ValueAsText + '%', 1, 30);
    end;

    local procedure FormatAmount(Value: Decimal; RoundingFactor: Enum "Analysis Rounding Factor"; AddCurrency: Boolean): Text[30]
    var
        MatrixManagement: Codeunit "Matrix Management";
    begin
        Value := MatrixManagement.RoundAmount(Value, RoundingFactor);
        exit(Format(Value, 0, MatrixManagement.FormatRoundingFactor(RoundingFactor, AddCurrency)));
    end;
}
