// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reconciliation;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Globalization;
using System.Utilities;

page 31197 "Inv. - G/L Recon. Matrix CZL"
{
    Caption = 'Inventory - G/L Reconciliation Enhanced';
    DataCaptionExpression = GetCaption();
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Dimension Code Buffer";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = TotalEmphasize;
                    ToolTip = 'Specifies the name.';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    Style = Strong;
                    StyleExpr = TotalEmphasize;
                    Visible = Field1Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    Style = Strong;
                    StyleExpr = TotalEmphasize;
                    Visible = Field2Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    Style = Strong;
                    StyleExpr = TotalEmphasize;
                    Visible = Field3Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    Style = Strong;
                    StyleExpr = true;
                    Visible = Field4Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    Style = Strong;
                    StyleExpr = true;
                    Visible = Field5Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    Style = Strong;
                    StyleExpr = true;
                    Visible = Field6Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    Style = Strong;
                    StyleExpr = true;
                    Visible = Field7Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    Visible = Field8Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    Visible = Field9Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    Visible = Field10Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    Visible = Field11Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    Visible = Field12Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[13];
                    Visible = Field13Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[14];
                    Visible = Field14Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[15];
                    Visible = Field15Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[16];
                    Visible = Field16Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[17];
                    Visible = Field17Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[18];
                    Visible = Field18Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[19];
                    Visible = Field19Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[20];
                    Visible = Field20Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[21];
                    Visible = Field21Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[22];
                    Visible = Field22Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[23];
                    Visible = Field23Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[24];
                    Visible = Field24Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[25];
                    Visible = Field25Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[26];
                    Visible = Field26Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[27];
                    Visible = Field27Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[28];
                    Visible = Field28Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[29];
                    Visible = Field29Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[30];
                    Visible = Field30Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(30);
                    end;
                }
                field(Field31; MATRIX_CellData[31])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[31];
                    Visible = Field31Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(31);
                    end;
                }
                field(Field32; MATRIX_CellData[32])
                {
                    ApplicationArea = Basic, Suite;
                    CaptionClass = '3,' + MATRIX_CaptionSet[32];
                    Visible = Field32Visible;
                    ToolTip = 'Specifies the Matrix Cell value.';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(32);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        while MATRIX_CurrentColumnOrdinal < MATRIX_CurrentNoOfMatrixColumn do begin
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
            MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
        end;
    end;

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
        Field32Visible := true;
        Field31Visible := true;
        Field30Visible := true;
        Field29Visible := true;
        Field28Visible := true;
        Field27Visible := true;
        Field26Visible := true;
        Field25Visible := true;
        Field24Visible := true;
        Field23Visible := true;
        Field22Visible := true;
        Field21Visible := true;
        Field20Visible := true;
        Field19Visible := true;
        Field18Visible := true;
        Field17Visible := true;
        Field16Visible := true;
        Field15Visible := true;
        Field14Visible := true;
        Field13Visible := true;
        Field12Visible := true;
        Field11Visible := true;
        Field10Visible := true;
        Field9Visible := true;
        Field8Visible := true;
        Field7Visible := true;
        Field6Visible := true;
        Field5Visible := true;
        Field4Visible := true;
        Field3Visible := true;
        Field2Visible := true;
        Field1Visible := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(NextRec(InventoryReportHeader."Line Option", Rec, Steps, true));
    end;

    trigger OnOpenPage()
    begin
        GeneralLedgerSetup.Get();

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

        GetInventoryReport.SetReportHeader(InventoryReportHeader);
        GetInventoryReport.Run(TempInventoryReportEntry);
        SetVisible();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        InventoryReportHeader: Record "Inventory Report Header";
        TempInventoryReportEntry: Record "Inventory Report Entry" temporary;
        RowIntegerLine: Record "Integer";
        ColIntegerLine: Record "Integer";
        MatrixRecords: array[32] of Record "Dimension Code Buffer";
        GetInventoryReport: Codeunit "Get Inventory Report";
        LineDimCode: Text[20];
        ColumnDimCode: Text[20];
        DateFilter: Text;
        ItemFilter: Text;
        LocationFilter: Text;
        CellAmount: Decimal;
        GLSetupRead: Boolean;
        MATRIX_CurrentNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[32] of Text[250];
        MATRIX_CaptionSet: array[32] of Text[80];
        Field1Visible: Boolean;
        Field2Visible: Boolean;
        Field3Visible: Boolean;
        Field4Visible: Boolean;
        Field5Visible: Boolean;
        Field6Visible: Boolean;
        Field7Visible: Boolean;
        Field8Visible: Boolean;
        Field9Visible: Boolean;
        Field10Visible: Boolean;
        Field11Visible: Boolean;
        Field12Visible: Boolean;
        Field13Visible: Boolean;
        Field14Visible: Boolean;
        Field15Visible: Boolean;
        Field16Visible: Boolean;
        Field17Visible: Boolean;
        Field18Visible: Boolean;
        Field19Visible: Boolean;
        Field20Visible: Boolean;
        Field21Visible: Boolean;
        Field22Visible: Boolean;
        Field23Visible: Boolean;
        Field24Visible: Boolean;
        Field25Visible: Boolean;
        Field26Visible: Boolean;
        Field27Visible: Boolean;
        Field28Visible: Boolean;
        Field29Visible: Boolean;
        Field30Visible: Boolean;
        Field31Visible: Boolean;
        Field32Visible: Boolean;
        TotalEmphasize: Boolean;
        IncomeStatementTxt: Label 'Income Statement';
        BalanceSheetTxt: Label 'Balance Sheet';
        ShowWarning: Boolean;
        ExpectedCostSetupTxt: Label 'Expected Cost Setup';
        PostCosttoGLTxt: Label 'Post Cost to G/L';
        CompressionTxt: Label 'Compression';
        PostingGroupTxt: Label 'Posting Group';
        DirectPostingTxt: Label 'Direct Posting';
        PostingDateTxt: Label 'Posting Date';
        ClosedFiscalYearTxt: Label 'Closed Fiscal Year';
        SimilarAccountsTxt: Label 'Similar Accounts';
        DeletedAccountsTxt: Label 'Deleted Accounts';
        NotSetupExpectedCostTxt: Label 'The program is not set up to use expected cost posting. Therefore, inventory interim G/L accounts are empty and this causes a difference between inventory and G/L totals.';
        CostAmountsNotPostedTxt: Label 'Some of the cost amounts in the inventory ledger have not yet been posted to the G/L. You must run the Post Cost to G/L batch job to reconcile the ledgers.';
        EntriesCompressedTxt: Label 'Some inventory or G/L entries have been date compressed.';
        ReassigningAccountsTxt: Label 'You have possibly restructured your chart of accounts by re-assigning inventory related accounts in the General or Inventory Posting Setup.';
        PostedDirectlyTxt: Label 'Some inventory costs have been posted directly to a G/L account, bypassing the inventory subledger.';
        DiscrepancybetweenTxt: Label 'There is a discrepancy between the posting date of the value entry and the associated G/L entry within the reporting period.';
        PostedInClosedFiscalYearTxt: Label 'Some of the cost amounts are posted in a closed fiscal year. Therefore, the inventory related totals are different from their related G/L accounts in the income statement.';
        PossiblyDefinedTxt: Label 'You have possibly defined one G/L account for different inventory transactions.';
        PossiblyRestructuredTxt: Label 'You have possibly restructured your chart of accounts by deleting one or more inventory related G/L accounts.';
        ValuesTok: Label '%1 %2 %3 %4', locked = true;
        FormatTok: Label '<Sign><Integer Thousand><Decimals,3>', Locked = true;

    local procedure DimCodeToOption(DimCode: Text[30]): Integer
    begin
        case DimCode of
            '':
                exit(-1);
            BalanceSheetTxt:
                exit(0);
            IncomeStatementTxt:
                exit(1);
            else
                exit(-1);
        end;
    end;

    local procedure FindRec(DimOption: Option "Balance Sheet","Income Statement"; var DimensionCodebuffer: Record "Dimension Code Buffer"; Which: Text; IsRow: Boolean): Boolean
    var
        Found: Boolean;
    begin
        case DimOption of
            DimOption::"Balance Sheet",
          DimOption::"Income Statement":
                if IsRow then begin
                    if Evaluate(RowIntegerLine.Number, DimensionCodebuffer.Code) then;
                    Found := RowIntegerLine.Find(Which);
                    if Found then
                        CopyDimValueToBuf(RowIntegerLine, DimensionCodebuffer, IsRow);
                end else begin
                    if Evaluate(ColIntegerLine.Number, DimensionCodebuffer.Code) then;
                    Found := ColIntegerLine.Find(Which);
                    if Found then
                        CopyDimValueToBuf(ColIntegerLine, DimensionCodebuffer, IsRow);
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

    local procedure Calculate(MATRIX_ColumnOrdinal: Integer) Amount: Decimal
    begin
        GetGLSetup();
        case true of
            TempInventoryReportEntry.FieldCaption("G/L Total") in [Rec.Name, MatrixRecords[MATRIX_ColumnOrdinal].Name]:
                TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::"G/L Account");
            TempInventoryReportEntry.FieldCaption(Difference) in [Rec.Name, MatrixRecords[MATRIX_ColumnOrdinal].Name],
          TempInventoryReportEntry.FieldCaption(Warning) in [Rec.Name, MatrixRecords[MATRIX_ColumnOrdinal].Name]:
                TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::" ");
            else
                TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::Item);
        end;
        case InventoryReportHeader."Line Option" of
            InventoryReportHeader."Line Option"::"Balance Sheet",
          InventoryReportHeader."Line Option"::"Income Statement":
                case Rec.Name of
                    TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"), TempInventoryReportEntry.FieldCaption(Difference):
                        case MatrixRecords[MATRIX_ColumnOrdinal].Name of
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.CalcSums(Inventory);
                                    Amount := TempInventoryReportEntry.Inventory;
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.CalcSums("WIP Inventory");
                                    Amount := TempInventoryReportEntry."WIP Inventory";
                                end;
                            TempInventoryReportEntry.FieldCaption("Inventory (Interim)"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Inventory (Interim)");
                                    Amount := TempInventoryReportEntry."Inventory (Interim)";
                                end;
                            TempInventoryReportEntry.FieldCaption("Consumption CZL"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Consumption CZL");
                                    Amount := -TempInventoryReportEntry."Consumption CZL";
                                end;
                            TempInventoryReportEntry.FieldCaption("Change In Inv.Of WIP CZL"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Change In Inv.Of WIP CZL");
                                    Amount := -TempInventoryReportEntry."Change In Inv.Of WIP CZL";
                                end;
                            TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Change In Inv.Of Product CZL");
                                    Amount := -TempInventoryReportEntry."Change In Inv.Of Product CZL";
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("COGS (Interim)"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption("Inventory (Interim)"),
                                                                        TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("COGS (Interim)");
                            Amount := TempInventoryReportEntry."COGS (Interim)";
                        end else
                            Amount := 0;

                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied"):
                        case MatrixRecords[MATRIX_ColumnOrdinal].Name of
                            TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"), TempInventoryReportEntry.FieldCaption(Difference):
                                begin
                                    TempInventoryReportEntry.CalcSums("Direct Cost Applied");
                                    Amount := TempInventoryReportEntry."Direct Cost Applied";
                                end;
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.CalcSums("Direct Cost Applied Actual");
                                    Amount := TempInventoryReportEntry."Direct Cost Applied Actual";
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Direct Cost Applied WIP");
                                    Amount := TempInventoryReportEntry."Direct Cost Applied WIP";
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("Overhead Applied"):
                        case MatrixRecords[MATRIX_ColumnOrdinal].Name of
                            TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"), TempInventoryReportEntry.FieldCaption(Difference):
                                begin
                                    TempInventoryReportEntry.CalcSums("Overhead Applied");
                                    Amount := TempInventoryReportEntry."Overhead Applied";
                                end;
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.CalcSums("Overhead Applied Actual");
                                    Amount := TempInventoryReportEntry."Overhead Applied Actual";
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.CalcSums("Overhead Applied WIP");
                                    Amount := TempInventoryReportEntry."Overhead Applied WIP";
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("Inventory Adjmt."):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Inventory Adjmt.");
                            Amount := TempInventoryReportEntry."Inventory Adjmt.";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Inv. Rounding Adj. CZL"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in
                          [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"), TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Inv. Rounding Adj. CZL");
                            Amount := TempInventoryReportEntry."Inv. Rounding Adj. CZL";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("Inventory (Interim)"), TempInventoryReportEntry.FieldCaption(Difference)]
                       then begin
                            TempInventoryReportEntry.CalcSums("Invt. Accrual (Interim)");
                            Amount := TempInventoryReportEntry."Invt. Accrual (Interim)";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption(COGS):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums(COGS);
                            Amount := TempInventoryReportEntry.COGS;
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Purchase Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                       then begin
                            TempInventoryReportEntry.CalcSums("Purchase Variance");
                            Amount := TempInventoryReportEntry."Purchase Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Material Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Material Variance");
                            Amount := TempInventoryReportEntry."Material Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Capacity Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Capacity Variance");
                            Amount := TempInventoryReportEntry."Capacity Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Subcontracted Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Subcontracted Variance");
                            Amount := TempInventoryReportEntry."Subcontracted Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Capacity Overhead Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Capacity Overhead Variance");
                            Amount := TempInventoryReportEntry."Capacity Overhead Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Mfg. Overhead Variance"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Mfg. Overhead Variance");
                            Amount := TempInventoryReportEntry."Mfg. Overhead Variance";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied Actual"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Direct Cost Applied Actual");
                            Amount := TempInventoryReportEntry."Direct Cost Applied Actual";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied WIP"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption("WIP Inventory"), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Direct Cost Applied WIP");
                            Amount := TempInventoryReportEntry."Direct Cost Applied WIP";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Overhead Applied WIP"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption("WIP Inventory"), TempInventoryReportEntry.FieldCaption(Difference)]
                        then begin
                            TempInventoryReportEntry.CalcSums("Overhead Applied WIP");
                            Amount := TempInventoryReportEntry."Overhead Applied WIP";
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("Inventory To WIP"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption("WIP Inventory"),
                                                                        TempInventoryReportEntry.FieldCaption(Inventory),
                                                                        TempInventoryReportEntry.FieldCaption("Consumption CZL"),
                                                                        TempInventoryReportEntry.FieldCaption("Change In Inv.Of WIP CZL"),
                                                                        TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL")]
                        then begin
                            TempInventoryReportEntry.CalcSums("Consumption CZL");
                            if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption("Consumption CZL") then
                                Amount := TempInventoryReportEntry."Consumption CZL"
                            else begin
                                TempInventoryReportEntry.CalcSums("Inventory To WIP");
                                Amount := TempInventoryReportEntry."Inventory To WIP";
                                if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption(Inventory), TempInventoryReportEntry.FieldCaption("Change In Inv.Of WIP CZL")] then
                                    Amount := -Amount
                                else
                                    if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL") then
                                        Amount := Amount - TempInventoryReportEntry."Consumption CZL";
                            end;
                        end else
                            Amount := 0;
                    TempInventoryReportEntry.FieldCaption("WIP To Interim"):
                        if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                        TempInventoryReportEntry.FieldCaption("WIP Inventory"),
                                                                        TempInventoryReportEntry.FieldCaption("Inventory (Interim)"),
                                                                        TempInventoryReportEntry.FieldCaption("Change In Inv.Of WIP CZL"),
                                                                        TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL")]
                        then begin
                            TempInventoryReportEntry.CalcSums("WIP To Interim");
                            Amount := TempInventoryReportEntry."WIP To Interim";
                            if MatrixRecords[MATRIX_ColumnOrdinal].Name in [TempInventoryReportEntry.FieldCaption("WIP Inventory"),
                                                                            TempInventoryReportEntry.FieldCaption("Change In Inv.Of Product CZL")]
                            then
                                Amount := -Amount;
                        end else
                            Amount := 0;
                end;
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GeneralLedgerSetup.Get();
        GLSetupRead := true;
    end;

    local procedure GetWarningText(TheField: Text[80]; ShowType: Option ReturnAsText,ShowAsMessage): Text[250]
    begin
        if TempInventoryReportEntry."Expected Cost Posting Warning" then
            if TheField in [TempInventoryReportEntry.FieldCaption("Inventory (Interim)"),
                            TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"),
                            TempInventoryReportEntry.FieldCaption("COGS (Interim)"),
                            TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"),
                            TempInventoryReportEntry.FieldCaption("WIP Inventory")]
            then begin
                if ShowType = ShowType::ReturnAsText then
                    exit(ExpectedCostSetupTxt);
                exit(NotSetupExpectedCostTxt);
            end;
        if TempInventoryReportEntry."Cost is Posted to G/L Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(PostCosttoGLTxt);
            exit(CostAmountsNotPostedTxt);
        end;
        if TempInventoryReportEntry."Compression Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(CompressionTxt);
            exit(EntriesCompressedTxt);
        end;
        if TempInventoryReportEntry."Posting Group Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(PostingGroupTxt);
            exit(ReassigningAccountsTxt);
        end;
        if TempInventoryReportEntry."Direct Postings Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(DirectPostingTxt);
            exit(PostedDirectlyTxt);
        end;
        if TempInventoryReportEntry."Posting Date Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(PostingDateTxt);
            exit(DiscrepancybetweenTxt);
        end;
        if TempInventoryReportEntry."Closing Period Overlap Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(ClosedFiscalYearTxt);
            exit(PostedInClosedFiscalYearTxt);
        end;
        if TempInventoryReportEntry."Similar Accounts Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(SimilarAccountsTxt);
            exit(PossiblyDefinedTxt);
        end;
        if TempInventoryReportEntry."Deleted G/L Accounts Warning" then begin
            if ShowType = ShowType::ReturnAsText then
                exit(DeletedAccountsTxt);
            exit(PossiblyRestructuredTxt);
        end;
    end;

    local procedure ShowWarningText(ShowType: Option ReturnAsText,ShowAsMessage; MATRIX_ColumnOrdinal: Integer): Text[250]
    var
        Text: Text[250];
    begin
        case Rec.Name of
            TempInventoryReportEntry.FieldCaption(Warning):
                case MatrixRecords[MATRIX_ColumnOrdinal].Name of
                    TempInventoryReportEntry.FieldCaption(Inventory):
                        if TempInventoryReportEntry.Inventory <> 0 then
                            Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption(Inventory), 1, 80), ShowType);
                    TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                        if TempInventoryReportEntry."WIP Inventory" <> 0 then
                            Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("WIP Inventory"), 1, 80), ShowType);
                    TempInventoryReportEntry.FieldCaption("Inventory (Interim)"):
                        if TempInventoryReportEntry."Inventory (Interim)" <> 0 then
                            Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Inventory (Interim)"), 1, 80), ShowType);
                end;
            TempInventoryReportEntry.FieldCaption("COGS (Interim)"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."COGS (Interim)" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("COGS (Interim)"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Direct Cost Applied"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Direct Cost Applied" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Direct Cost Applied"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Overhead Applied"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Overhead Applied" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Overhead Applied"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Inventory Adjmt."):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Inventory Adjmt." <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Inventory Adjmt."), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Invt. Accrual (Interim)" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption(COGS):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry.COGS <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption(COGS), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Purchase Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Purchase Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Purchase Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Material Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Material Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Material Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Capacity Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Capacity Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Capacity Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Subcontracted Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Subcontracted Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Subcontracted Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Capacity Overhead Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Capacity Overhead Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Capacity Overhead Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Mfg. Overhead Variance"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Mfg. Overhead Variance" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Mfg. Overhead Variance"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Direct Cost Applied Actual"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Direct Cost Applied Actual" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Direct Cost Applied Actual"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Direct Cost Applied WIP"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Direct Cost Applied WIP" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Direct Cost Applied WIP"), 1, 80), ShowType);
            TempInventoryReportEntry.FieldCaption("Overhead Applied WIP"):
                if MatrixRecords[MATRIX_ColumnOrdinal].Name = TempInventoryReportEntry.FieldCaption(Warning) then
                    if TempInventoryReportEntry."Overhead Applied WIP" <> 0 then
                        Text := GetWarningText(CopyStr(TempInventoryReportEntry.FieldCaption("Overhead Applied WIP"), 1, 80), ShowType);
        end;

        if ShowType = ShowType::ReturnAsText then
            exit(Text);
        Message(Text);
    end;

    local procedure GetCaption(): Text[250]
    var
        ObjectTranslation: Record "Object Translation";
        SourceTableName: Text[100];
        LocationTableName: Text[100];
    begin
        SourceTableName := '';
        LocationTableName := '';
        if ItemFilter <> '' then
            SourceTableName := CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Table, 27), 1, MaxStrLen(SourceTableName));
        if LocationFilter <> '' then
            LocationTableName := CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Table, 14), 1, MaxStrLen(LocationTableName));
        exit(StrSubstNo(ValuesTok, SourceTableName, ItemFilter, LocationTableName, LocationFilter));
    end;

    procedure Load(MatrixColumns1: array[32] of Text[100]; var MatrixRecords1: array[32] of Record "Dimension Code Buffer"; CurrentNoOfMatrixColumns: Integer; ShowWarningLocal: Boolean; DateFilterLocal: Text; ItemFilterLocal: Text; LocationFilterLocal: Text)
    begin
        CopyArray(MATRIX_CaptionSet, MatrixColumns1, 1);
        CopyArray(MatrixRecords, MatrixRecords1, 1);
        MATRIX_CurrentNoOfMatrixColumn := CurrentNoOfMatrixColumns;
        ShowWarning := ShowWarningLocal;
        DateFilter := DateFilterLocal;
        ItemFilter := ItemFilterLocal;
        LocationFilter := LocationFilterLocal;
    end;

    local procedure MATRIX_OnDrillDown(MATRIX_ColumnOrdinal: Integer)
    begin
        GetGLSetup();

        if TempInventoryReportEntry.FieldCaption(Warning) = MATRIX_CaptionSet[MATRIX_ColumnOrdinal] then begin
            ShowWarningText(1, MATRIX_ColumnOrdinal);
            exit;
        end;

        TempInventoryReportEntry.Reset();
        if TempInventoryReportEntry.FieldCaption("G/L Total") in [MATRIX_CaptionSet[MATRIX_ColumnOrdinal], Rec.Name] then
            TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::"G/L Account")
        else
            TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::Item);

        TempInventoryReportEntry.SetFilter("Posting Date Filter", InventoryReportHeader.GetFilter("Posting Date Filter"));
        TempInventoryReportEntry.SetFilter("Location Filter", InventoryReportHeader.GetFilter("Location Filter"));

        if TempInventoryReportEntry.FieldCaption(Warning) in [Rec.Name, MATRIX_CaptionSet[MATRIX_ColumnOrdinal]] then begin
            ShowWarningText(1, MATRIX_ColumnOrdinal);
            exit;
        end;

        case InventoryReportHeader."Line Option" of
            InventoryReportHeader."Line Option"::"Balance Sheet",
          InventoryReportHeader."Line Option"::"Income Statement":
                case Rec.Name of
                    TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"):
                        case MATRIX_CaptionSet[MATRIX_ColumnOrdinal] of
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.SetFilter(Inventory, '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry.Inventory);
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.SetFilter("WIP Inventory", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."WIP Inventory");
                                end;
                            TempInventoryReportEntry.FieldCaption("Inventory (Interim)"):
                                begin
                                    TempInventoryReportEntry.SetFilter("Inventory (Interim)", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Inventory (Interim)");
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("COGS (Interim)"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("Inventory (Interim)")]
                        then begin
                            TempInventoryReportEntry.SetFilter("COGS (Interim)", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."COGS (Interim)");
                        end;
                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied"):
                        case MATRIX_CaptionSet[MATRIX_ColumnOrdinal] of
                            TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"):
                                begin
                                    TempInventoryReportEntry.SetFilter("Direct Cost Applied", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Direct Cost Applied");
                                end;
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.SetFilter("Direct Cost Applied Actual", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Direct Cost Applied Actual");
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.SetFilter("Direct Cost Applied WIP", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Direct Cost Applied WIP");
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("Overhead Applied"):
                        case MATRIX_CaptionSet[MATRIX_ColumnOrdinal] of
                            TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"):
                                begin
                                    TempInventoryReportEntry.SetFilter("Overhead Applied", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Overhead Applied");
                                end;
                            TempInventoryReportEntry.FieldCaption(Inventory):
                                begin
                                    TempInventoryReportEntry.SetFilter("Overhead Applied Actual", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Overhead Applied Actual");
                                end;
                            TempInventoryReportEntry.FieldCaption("WIP Inventory"):
                                begin
                                    TempInventoryReportEntry.SetFilter("Overhead Applied WIP", '<>%1', 0);
                                    PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Overhead Applied WIP");
                                end;
                        end;
                    TempInventoryReportEntry.FieldCaption("Inventory Adjmt."):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Inventory Adjmt.", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Inventory Adjmt.");
                        end;
                    TempInventoryReportEntry.FieldCaption("Invt. Accrual (Interim)"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("Inventory (Interim)")]
                        then begin
                            TempInventoryReportEntry.SetFilter("Invt. Accrual (Interim)", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Invt. Accrual (Interim)");
                        end;
                    TempInventoryReportEntry.FieldCaption(COGS):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter(COGS, '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry.COGS);
                        end;
                    TempInventoryReportEntry.FieldCaption("Purchase Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Purchase Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Purchase Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Material Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Material Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Material Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Capacity Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Capacity Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Capacity Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Subcontracted Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Subcontracted Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Subcontracted Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Capacity Overhead Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Capacity Overhead Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Capacity Overhead Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Mfg. Overhead Variance"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Mfg. Overhead Variance", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Mfg. Overhead Variance");
                        end;
                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied Actual"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Direct Cost Applied Actual", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Direct Cost Applied Actual");
                        end;
                    TempInventoryReportEntry.FieldCaption("Direct Cost Applied WIP"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("WIP Inventory")]
                        then begin
                            TempInventoryReportEntry.SetFilter("Direct Cost Applied WIP", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Direct Cost Applied WIP");
                        end;
                    TempInventoryReportEntry.FieldCaption("Overhead Applied WIP"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption(Total), TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("WIP Inventory")]
                        then begin
                            TempInventoryReportEntry.SetFilter("Overhead Applied WIP", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Overhead Applied WIP");
                        end;
                    TempInventoryReportEntry.FieldCaption("Inventory To WIP"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("WIP Inventory"), TempInventoryReportEntry.FieldCaption(Inventory)]
                        then begin
                            TempInventoryReportEntry.SetFilter("Inventory To WIP", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."Inventory To WIP");
                        end;
                    TempInventoryReportEntry.FieldCaption("WIP To Interim"):
                        if MATRIX_CaptionSet[MATRIX_ColumnOrdinal] in [TempInventoryReportEntry.FieldCaption("G/L Total"),
                                                                       TempInventoryReportEntry.FieldCaption("WIP Inventory"),
                                                                       TempInventoryReportEntry.FieldCaption("Inventory (Interim)")]
                        then begin
                            TempInventoryReportEntry.SetFilter("WIP To Interim", '<>%1', 0);
                            PAGE.Run(0, TempInventoryReportEntry, TempInventoryReportEntry."WIP To Interim");
                        end;
                end;
        end;
        TempInventoryReportEntry.Reset();
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal: Integer)
    begin
        CellAmount := Calculate(MATRIX_ColumnOrdinal);
        if CellAmount <> 0 then
            MATRIX_CellData[MATRIX_ColumnOrdinal] := Format(CellAmount, 0, FormatTok)
        else
            MATRIX_CellData[MATRIX_ColumnOrdinal] := '';

        TotalEmphasize := Rec."Show in Bold";

        if TempInventoryReportEntry.FieldCaption(Warning) in [Rec.Name, MatrixRecords[MATRIX_ColumnOrdinal].Name] then begin
            TempInventoryReportEntry.SetRange(Type, TempInventoryReportEntry.Type::" ");
            if TempInventoryReportEntry.FindFirst() then;
            case InventoryReportHeader."Line Option" of
                InventoryReportHeader."Line Option"::"Balance Sheet",
              InventoryReportHeader."Line Option"::"Income Statement":
                    MATRIX_CellData[MATRIX_ColumnOrdinal] := ShowWarningText(0, MATRIX_ColumnOrdinal);
            end;
        end;
    end;

    procedure SetVisible()
    begin
        Field1Visible := MATRIX_CaptionSet[1] <> '';
        Field2Visible := MATRIX_CaptionSet[2] <> '';
        Field3Visible := MATRIX_CaptionSet[3] <> '';
        Field4Visible := MATRIX_CaptionSet[4] <> '';
        Field5Visible := MATRIX_CaptionSet[5] <> '';
        Field6Visible := MATRIX_CaptionSet[6] <> '';
        Field7Visible := MATRIX_CaptionSet[7] <> '';
        Field8Visible := MATRIX_CaptionSet[8] <> '';
        Field9Visible := MATRIX_CaptionSet[9] <> '';
        Field10Visible := MATRIX_CaptionSet[10] <> '';
        Field11Visible := MATRIX_CaptionSet[11] <> '';
        Field12Visible := MATRIX_CaptionSet[12] <> '';
        Field13Visible := MATRIX_CaptionSet[13] <> '';
        Field14Visible := MATRIX_CaptionSet[14] <> '';
        Field15Visible := MATRIX_CaptionSet[15] <> '';
        Field16Visible := MATRIX_CaptionSet[16] <> '';
        Field17Visible := MATRIX_CaptionSet[17] <> '';
        Field18Visible := MATRIX_CaptionSet[18] <> '';
        Field19Visible := MATRIX_CaptionSet[19] <> '';
        Field20Visible := MATRIX_CaptionSet[20] <> '';
        Field21Visible := MATRIX_CaptionSet[21] <> '';
        Field22Visible := MATRIX_CaptionSet[22] <> '';
        Field23Visible := MATRIX_CaptionSet[23] <> '';
        Field24Visible := MATRIX_CaptionSet[24] <> '';
        Field25Visible := MATRIX_CaptionSet[25] <> '';
        Field26Visible := MATRIX_CaptionSet[26] <> '';
        Field27Visible := MATRIX_CaptionSet[27] <> '';
        Field28Visible := MATRIX_CaptionSet[28] <> '';
        Field29Visible := MATRIX_CaptionSet[29] <> '';
        Field30Visible := MATRIX_CaptionSet[30] <> '';
        Field31Visible := MATRIX_CaptionSet[31] <> '';
        Field32Visible := MATRIX_CaptionSet[32] <> '';
    end;
}
