// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reconciliation;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using System.Utilities;

page 31196 "Inv. G/L Reconciliation CZL"
{
    AdditionalSearchTerms = 'general ledger reconcile inventory';
    ApplicationArea = Basic, Suite;
    Caption = 'Inventory - G/L Reconciliation Enhanced';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = "Dimension Code Buffer";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    begin
                        InventoryReportHeader.SetFilter("Posting Date Filter", DateFilter);
                        DateFilter := InventoryReportHeader.GetFilter("Posting Date Filter");
                        DateFilterOnAfterValidate();
                    end;
                }
                field(ItemFilter; ItemFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Filter';
                    ToolTip = 'Specifies which items the information is shown for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        ItemList: Page "Item List";
                    begin
                        Item.SetRange(Type, Item.Type::Inventory);
                        ItemList.SetTableView(Item);
                        ItemList.LookupMode := true;
                        if ItemList.RunModal() = ACTION::LookupOK then begin
                            ItemList.GetRecord(Item);
                            Text := Item."No.";
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        TestWarning();
                        ItemFilterOnAfterValidate();
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = Location;
                    Caption = 'Location Filter';
                    ToolTip = 'Specifies which item locations the information is shown for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Location: Record Location;
                        Locations: Page "Location List";
                    begin
                        Locations.SetTableView(Location);
                        Locations.LookupMode := true;
                        if Locations.RunModal() = ACTION::LookupOK then begin
                            Locations.GetRecord(Location);
                            Text := Location.Code;
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        TestWarning();
                        LocationFilterOnAfterValidate();
                    end;
                }
                field(Show; ShowWarning)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Warning';
                    Editable = ShowEditable;
                    ToolTip = 'Specifies that a messages will be shown in the Warning field of the grid if there are any discrepancies between the inventory totals and G/L totals. If you choose the Warning field, the program gives you more information on what the warning means.';

                    trigger OnValidate()
                    begin
                        ShowWarningOnAfterValidate();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Show Matrix")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Show Matrix';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'View the data overview according to the selected filters and options.';

                trigger OnAction()
                var
                    MatrixForm: Page "Inv. - G/L Recon. Matrix CZL";
                    i: Integer;
                begin
                    Clear(MatrixForm);
                    Clear(MatrixRecords);
                    Clear(MATRIX_CaptionSet);

                    if InventoryReportHeader."Column Option" = InventoryReportHeader."Line Option"::"Balance Sheet" then begin
                        if (ItemFilter = '') and (LocationFilter = '') then begin
                            if ShowWarning then
                                ColIntegerLine.SetRange(Number, 1, 10)
                            else
                                ColIntegerLine.SetRange(Number, 1, 9)
                        end else
                            ColIntegerLine.SetRange(Number, 1, 7)
                    end else
                        if InventoryReportHeader."Column Option" = InventoryReportHeader."Line Option"::"Income Statement" then
                            if (ItemFilter = '') and (LocationFilter = '') then begin
                                if ShowWarning then
                                    ColIntegerLine.SetRange(Number, 1, 19)
                                else
                                    ColIntegerLine.SetRange(Number, 1, 18)
                            end else
                                ColIntegerLine.SetRange(Number, 1, 16);
                    i := 1;

                    if FindRec(InventoryReportHeader."Column Option", MatrixRecords[i], '-', false) then begin
                        MATRIX_CaptionSet[i] := MatrixRecords[i].Name;
                        i := i + 1;
                        while NextRec(InventoryReportHeader."Column Option", MatrixRecords[i], 1, false) <> 0 do begin
                            MATRIX_CaptionSet[i] := MatrixRecords[i].Name;
                            i := i + 1;
                        end;
                    end;
                    if ShowWarning then
                        MATRIX_CurrentNoOfColumns := i
                    else
                        MATRIX_CurrentNoOfColumns := i - 1;

                    MatrixForm.Load(MATRIX_CaptionSet, MatrixRecords, MATRIX_CurrentNoOfColumns, ShowWarning,
                      DateFilter, ItemFilter, LocationFilter);
                    MatrixForm.RunModal();
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if InventoryReportHeader."Line Option" = InventoryReportHeader."Line Option"::"Balance Sheet" then begin
            if (ItemFilter = '') and (LocationFilter = '') then begin
                if ShowWarning then
                    RowIntegerLine.SetRange(Number, 1, 10)
                else
                    RowIntegerLine.SetRange(Number, 1, 9)
            end else
                RowIntegerLine.SetRange(Number, 1, 7)
        end else
            if InventoryReportHeader."Line Option" = InventoryReportHeader."Line Option"::"Income Statement" then
                if (ItemFilter = '') and (LocationFilter = '') then begin
                    if ShowWarning then
                        RowIntegerLine.SetRange(Number, 1, 19)
                    else
                        RowIntegerLine.SetRange(Number, 1, 18)
                end else
                    RowIntegerLine.SetRange(Number, 1, 16);
        exit(FindRec(InventoryReportHeader."Line Option", Rec, Which, true));
    end;

    trigger OnInit()
    begin
        ShowEditable := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(NextRec(InventoryReportHeader."Line Option", Rec, Steps, true));
    end;

    trigger OnOpenPage()
    begin
        GeneralLedgerSetup.Get();
        TestWarning();
        InventoryReportHeader.SetFilter("Item Filter", ItemFilter);
        InventoryReportHeader.SetFilter("Location Filter", LocationFilter);
        InventoryReportHeader.SetFilter("Posting Date Filter", DateFilter);
        InventoryReportHeader."Show Warning" := ShowWarning;

        if (LineDimCode = '') and (ColumnDimCode = '') then begin
            LineDimCode := IncomeStatementTxt;
            ColumnDimCode := BalanceSheetTxt;
        end;
        InventoryReportHeader."Line Option" := DimCodeToOption(LineDimCode);
        InventoryReportHeader."Column Option" := DimCodeToOption(ColumnDimCode);
    end;

    var
        MatrixRecords: array[32] of Record "Dimension Code Buffer";
        GeneralLedgerSetup: Record "General Ledger Setup";
        InventoryReportHeader: Record "Inventory Report Header";
        TempInventoryReportEntry: Record "Inventory Report Entry" temporary;
        RowIntegerLine: Record "Integer";
        ColIntegerLine: Record "Integer";
        MATRIX_CaptionSet: array[32] of Text[100];
        MATRIX_CurrentNoOfColumns: Integer;
        LineDimCode: Text[20];
        ColumnDimCode: Text[20];
        DateFilter: Text;
        ItemFilter: Code[250];
        LocationFilter: Code[250];
        IncomeStatementTxt: Label 'Income Statement';
        BalanceSheetTxt: Label 'Balance Sheet';
        ShowWarning: Boolean;
        ShowEditable: Boolean;

    local procedure DimCodeToOption(DimCode: Text[30]): Integer
    begin
        case DimCode of
            BalanceSheetTxt:
                exit(0);
            IncomeStatementTxt:
                exit(1);
            else
                exit(-1);
        end;
    end;

    local procedure FindRec(DimOption: Option "Balance Sheet","Income Statement"; var DimensionCodeBuffer: Record "Dimension Code Buffer"; Which: Text; IsRow: Boolean): Boolean
    var
        Found: Boolean;
    begin
        case DimOption of
            DimOption::"Balance Sheet",
          DimOption::"Income Statement":
                if IsRow then begin
                    if Evaluate(RowIntegerLine.Number, DimensionCodeBuffer.Code) then;
                    Found := RowIntegerLine.Find(Which);
                    if Found then
                        CopyDimValueToBuf(RowIntegerLine, DimensionCodeBuffer, IsRow);
                end else begin
                    if Evaluate(ColIntegerLine.Number, DimensionCodeBuffer.Code) then;
                    Found := ColIntegerLine.Find(Which);
                    if Found then
                        CopyDimValueToBuf(ColIntegerLine, DimensionCodeBuffer, IsRow);
                end;
        end;
        exit(Found);
    end;

    local procedure NextRec(DimOption: Option "Balance Sheet","Income Statement"; var DimensionCodeBuffer: Record "Dimension Code Buffer"; Steps: Integer; IsRow: Boolean): Integer
    var
        ResultSteps: Integer;
    begin
        case DimOption of
            DimOption::"Balance Sheet",
          DimOption::"Income Statement":
                if IsRow then begin
                    if Evaluate(RowIntegerLine.Number, DimensionCodeBuffer.Code) then;
                    ResultSteps := RowIntegerLine.Next(Steps);
                    if ResultSteps <> 0 then
                        CopyDimValueToBuf(RowIntegerLine, DimensionCodeBuffer, IsRow);
                end else begin
                    if Evaluate(ColIntegerLine.Number, DimensionCodeBuffer.Code) then;
                    ResultSteps := ColIntegerLine.Next(Steps);
                    if ResultSteps <> 0 then
                        CopyDimValueToBuf(ColIntegerLine, DimensionCodeBuffer, IsRow);
                end;
        end;
        exit(ResultSteps);
    end;

    local procedure CopyDimValueToBuf(var TheDimValueInteger: Record "Integer"; var DimensionCodeBuffer: Record "Dimension Code Buffer"; IsRow: Boolean)
    begin
        case true of
            ((InventoryReportHeader."Line Option" = InventoryReportHeader."Line Option"::"Balance Sheet") and IsRow) or
          ((InventoryReportHeader."Column Option" = InventoryReportHeader."Column Option"::"Balance Sheet") and not IsRow):
                case TheDimValueInteger.Number of
                    1:
                        InsertRow('1', CopyStr(TempInventoryReportEntry.FieldCaption(Inventory), 1, 80), 0, false, DimensionCodeBuffer);
                    2:
                        InsertRow('2', CopyStr(TempInventoryReportEntry.FieldCaption("Inventory (Interim)"), 1, 80), 0, false, DimensionCodeBuffer);
                    3:
                        InsertRow('3', CopyStr(TempInventoryReportEntry.FieldCaption("WIP Inventory"), 1, 80), 0, false, DimensionCodeBuffer);
                    4:
                        InsertRow('4', CopyStr(TempInventoryReportEntry.FieldCaption("Consumption CZL"), 1, 80), 0, false, DimensionCodeBuffer);
                    5:
                        InsertRow('5', CopyStr(TempInventoryReportEntry.FieldCaption("Change In Inv.Of WIP CZL"), 1, 80), 0, false, DimensionCodeBuffer);
                    6:
                        InsertRow('6', CopyStr(TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL"), 1, 80), 0, false, DimensionCodeBuffer);
                    7:
                        InsertRow('7', CopyStr(TempInventoryReportEntry.FieldCaption(Total), 1, 80), 0, true, DimensionCodeBuffer);
                    8:
                        InsertRow('8', CopyStr(TempInventoryReportEntry.FieldCaption("G/L Total"), 1, 80), 0, true, DimensionCodeBuffer);
                    9:
                        InsertRow('9', CopyStr(TempInventoryReportEntry.FieldCaption(Difference), 1, 80), 0, true, DimensionCodeBuffer);
                    10:
                        InsertRow('10', CopyStr(TempInventoryReportEntry.FieldCaption(Warning), 1, 80), 0, true, DimensionCodeBuffer);
                end;
            ((InventoryReportHeader."Line Option" = InventoryReportHeader."Line Option"::"Income Statement") and IsRow) or
          ((InventoryReportHeader."Column Option" = InventoryReportHeader."Column Option"::"Income Statement") and not IsRow):
                case TheDimValueInteger.Number of
                    1:
                        InsertRow('1', CopyStr(TempInventoryReportEntry.FieldCaption("Inventory To WIP"), 1, 80), 0, false, DimensionCodeBuffer);
                    2:
                        InsertRow('2', CopyStr(TempInventoryReportEntry.FieldCaption("WIP To Interim"), 1, 80), 0, false, DimensionCodeBuffer);
                    3:
                        InsertRow('3', CopyStr(TempInventoryReportEntry.FieldCaption("COGS (Interim)"), 1, 80), 0, false, DimensionCodeBuffer);
                    4:
                        InsertRow('4', CopyStr(TempInventoryReportEntry.FieldCaption("Direct Cost Applied"), 1, 80), 0, false, DimensionCodeBuffer);
                    5:
                        InsertRow('5', CopyStr(TempInventoryReportEntry.FieldCaption("Overhead Applied"), 1, 80), 0, false, DimensionCodeBuffer);
                    6:
                        InsertRow('6', CopyStr(TempInventoryReportEntry.FieldCaption("Inventory Adjmt."), 1, 80), 0, false, DimensionCodeBuffer);
                    7:
                        InsertRow('7', CopyStr(TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"), 1, 80), 0, false, DimensionCodeBuffer);
                    8:
                        InsertRow('8', CopyStr(TempInventoryReportEntry.FieldCaption(COGS), 1, 80), 0, false, DimensionCodeBuffer);
                    9:
                        InsertRow('9', CopyStr(TempInventoryReportEntry.FieldCaption("Inv. Rounding Adj. CZL"), 1, 80), 0, false, DimensionCodeBuffer);
                    10:
                        InsertRow('10', CopyStr(TempInventoryReportEntry.FieldCaption("Purchase Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    11:
                        InsertRow('11', CopyStr(TempInventoryReportEntry.FieldCaption("Material Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    12:
                        InsertRow('12', CopyStr(TempInventoryReportEntry.FieldCaption("Capacity Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    13:
                        InsertRow('13', CopyStr(TempInventoryReportEntry.FieldCaption("Subcontracted Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    14:
                        InsertRow('14', CopyStr(TempInventoryReportEntry.FieldCaption("Capacity Overhead Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    15:
                        InsertRow('15', CopyStr(TempInventoryReportEntry.FieldCaption("Mfg. Overhead Variance"), 1, 80), 0, false, DimensionCodeBuffer);
                    16:
                        InsertRow('16', CopyStr(TempInventoryReportEntry.FieldCaption(Total), 1, 80), 0, true, DimensionCodeBuffer);
                    17:
                        InsertRow('17', CopyStr(TempInventoryReportEntry.FieldCaption("G/L Total"), 1, 80), 0, true, DimensionCodeBuffer);
                    18:
                        InsertRow('18', CopyStr(TempInventoryReportEntry.FieldCaption(Difference), 1, 80), 0, true, DimensionCodeBuffer);
                    19:
                        InsertRow('19', CopyStr(TempInventoryReportEntry.FieldCaption(Warning), 1, 80), 0, true, DimensionCodeBuffer);
                end;
        end
    end;

    local procedure InsertRow(Code1: Code[10]; Name1: Text[80]; Indentation1: Integer; Bold1: Boolean; var DimensionCodeBuffer: Record "Dimension Code Buffer")
    begin
        DimensionCodeBuffer.Init();
        DimensionCodeBuffer.Code := Code1;
        DimensionCodeBuffer.Name := CopyStr(Name1, 1, MaxStrLen(DimensionCodeBuffer.Name));
        DimensionCodeBuffer.Indentation := Indentation1;
        DimensionCodeBuffer."Show in Bold" := Bold1;
    end;

    local procedure TestWarning()
    begin
        ShowEditable := true;
        if ShowWarning then begin
            if (ItemFilter <> '') or (LocationFilter <> '') then begin
                ShowWarning := false;
                ShowEditable := false;
            end;
        end else
            if (ItemFilter <> '') or (LocationFilter <> '') then begin
                ShowWarning := false;
                ShowEditable := false;
            end;
    end;

    local procedure LocationFilterOnAfterValidate()
    begin
        InventoryReportHeader.SetFilter("Location Filter", LocationFilter);
        CurrPage.Update();
    end;

    local procedure DateFilterOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure ItemFilterOnAfterValidate()
    begin
        InventoryReportHeader.SetFilter("Item Filter", ItemFilter);
        CurrPage.Update();
    end;

    local procedure ShowWarningOnAfterValidate()
    begin
        InventoryReportHeader."Show Warning" := ShowWarning;
        CurrPage.Update();
    end;
}
