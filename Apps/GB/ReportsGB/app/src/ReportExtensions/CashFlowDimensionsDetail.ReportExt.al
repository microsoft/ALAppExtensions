// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CashFlow.Reports;

using Microsoft.CashFlow.Forecast;

reportextension 10589 "Cash Flow Dimensions - Detail" extends "Cash Flow Dimensions - Detail"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/CashFlowDimensionsDetail.rdlc';
#endif
    dataset
    {
        add("Analysis View")
        {
            column(USER_ID; UserId)
            {
            }
            column(FORMAT__TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(EmptyLinesPrint; PrintEmptyLines)
            {
            }
        }
        add(Level1)
        {
            column(Number_Level1; Number)
            {
            }
        }
        add(Level2)
        {
            column(Number_Level2; Number)
            {
            }
        }
        add(Level3)
        {
            column(TempCFLedgEntry__CashFlow_Account_No____Control15; TempCFForecastEntry."Cash Flow Account No.")
            {
            }
            column(Number_Level3; Number)
            {
            }
        }
        add(Level4)
        {
            column(TempCFLedgEntry__CashFlow_Account_No____Control32; TempCFForecastEntry."Cash Flow Account No.")
            {
            }
            column(Number_Level4; Number)
            {
            }
        }
        add(Level5)
        {
            column(TempCFLedgEntry_Amount__Control53; TempCFForecastEntry."Amount (LCY)")
            {
            }
            column(TempCFLedgEntry_Description__Control54; TempCFForecastEntry.Description)
            {
            }
            column(TempCFLedgEntry__Document_No____Control55; TempCFForecastEntry."Document No.")
            {
            }
            column(TempCFLedgEntry__CashFlow_Date___Control56; TempCFForecastEntry."Cash Flow Date")
            {
            }
            column(TempCFLedgEntry__CashFlow_Account_No____Control57; TempCFForecastEntry."Cash Flow Account No.")
            {
            }
            column(Number_Level5; Number)
            {
            }
        }
        add(Level4e)
        {
            column(DimCode__4__Control41; DimCode[4])
            {
            }
            column(DimValCode__4__Control39; DimValCode[4])
            {
            }
            column(DimValName__4__Control38; DimValName[4])
            {
            }
            column(Number_Level4e; Number)
            {
            }
        }
        add(Level3e)
        {
            column(DimCode__3__Control44; DimCode[3])
            {
            }
            column(DimValCode__3__Control58; DimValCode[3])
            {
            }
            column(DimValName__3__Control60; DimValName[3])
            {
            }
            column(Number_Level3e; Number)
            {
            }
        }
        add(Level2e)
        {
            column(DimCode__2__Control63; DimCode[2])
            {
            }
            column(DimValCode__2__Control64; DimValCode[2])
            {
            }
            column(DimValName__2__Control65; DimValName[2])
            {
            }
            column(Number_Level2e; Number)
            {
            }
        }
        add(Level1e)
        {
            column(DimValName__1__Control70; DimValName[1])
            {
            }
            column(DimValCode__1__Control69; DimValCode[1])
            {
            }
            column(DimCode__1__Control68; DimCode[1])
            {
            }
            column(Number_Level1e; Number)
            {
            }
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Cash Flow Dimensions - Detail GB localization';
            LayoutFile = './src/ReportExtensions/CashFlowDimensionsDetail.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        TempCFForecastEntry: Record "Cash Flow Forecast Entry" temporary;
        DimCode: array[4] of Text[30];
        DimValCode: array[4] of Code[20];
        DimValName: array[4] of Text[100];
        PrintEmptyLines: Boolean;

    procedure SetPrintEmptyLines(Print_EmptyLines: Boolean)
    begin
        PrintEmptyLines := Print_EmptyLines;
    end;

    procedure SetTempCFForecastEntry(NewTempCFForecastEntry: Record "Cash Flow Forecast Entry")
    begin
        TempCFForecastEntry := NewTempCFForecastEntry;
    end;

    procedure SetDim_Code_ValCode_ValName(Dim_Code: Text[30]; Dim_ValCode: Code[20]; Dim_ValName: Text[100]; Level: Integer)
    begin
        DimCode[Level] := Dim_Code;
        DimValCode[Level] := Dim_ValCode;
        DimValName[Level] := Dim_ValName;
    end;
}
