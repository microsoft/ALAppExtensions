// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;

report 31245 "Fixed Asset - Book Value 2 CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetBookValue2.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Book Value 02';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(MainHeadLineText; MainHeadLineText)
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(DeprBookText; DeprBookText)
            {
            }
            column(GroupCodeName; GroupCodeName)
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(No_FixedAsset; "No.")
            {
            }
            column(Description_FixedAsset; Description)
            {
            }
            column(HeadLineText1; HeadLineText[1])
            {
            }
            column(HeadLineText6; HeadLineText[6])
            {
            }
            column(HeadLineText7; HeadLineText[7])
            {
            }
            column(HeadLineText_1__Control7; HeadLineText[1])
            {
            }
            column(StartText; StartText)
            {
            }
            column(EndText; EndText)
            {
            }
            column(StartAmt1; StartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt1; NetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt1; DisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt1; TotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt1; ReclassStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt1; ReclassNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt1; ReclassDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt1; ReclassTotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(HeadLineText5; HeadLineText[5])
            {
            }
            column(StartText_Control23; StartText)
            {
            }
            column(BookValueAtStartingDate; BookValueAtStartingDate)
            {
                AutoFormatType = 1;
            }
            column(ReclassificationText; ReclassificationText)
            {
            }
            column(BudgetReport; BudgetReport)
            {
            }
            column(PrintDetails; PrintDetails)
            {
            }
            column(Reclassify; Reclassify)
            {
            }
            column(HeadLineText2; HeadLineText[2])
            {
            }
            column(HeadLineText_6__Control9; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control10; HeadLineText[7])
            {
            }
            column(HeadLineText_2__Control11; HeadLineText[2])
            {
            }
            column(StartText_Control25; StartText)
            {
            }
            column(EndText_Control31; EndText)
            {
            }
            column(StartAmt2; StartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt2; NetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt2; DisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt2; TotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt2; ReclassStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt2; ReclassNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt2; ReclassDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt2; ReclassTotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ShowSection02; ShowSection(0, 2))
            {
            }
            column(HeadLineText3; HeadLineText[3])
            {
            }
            column(HeadLineText_6__Control47; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control50; HeadLineText[7])
            {
            }
            column(HeadLineText_3__Control53; HeadLineText[3])
            {
            }
            column(StartText_Control45; StartText)
            {
            }
            column(EndText_Control56; EndText)
            {
            }
            column(StartAmt3; StartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt3; NetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt3; DisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt3; TotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt3; ReclassStartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt3; ReclassNetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt3; ReclassDisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt3; ReclassTotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ShowSection03; ShowSection(0, 3))
            {
            }
            column(HeadLineText4; HeadLineText[4])
            {
            }
            column(HeadLineText_6__Control70; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control71; HeadLineText[7])
            {
            }
            column(HeadLineText_4__Control72; HeadLineText[4])
            {
            }
            column(StartText_Control73; StartText)
            {
            }
            column(EndText_Control74; EndText)
            {
            }
            column(StartAmt4; StartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt4; NetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt4; DisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt4; TotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt4; ReclassStartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt4; ReclassNetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt4; ReclassDisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt4; ReclassTotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ShowSection04; ShowSection(0, 4))
            {
            }
            column(HeadLineText8; HeadLineText[8])
            {
            }
            column(HeadLineText_6__Control49; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control51; HeadLineText[7])
            {
            }
            column(HeadLineText_8__Control52; HeadLineText[8])
            {
            }
            column(StartText_Control54; StartText)
            {
            }
            column(EndText_Control55; EndText)
            {
            }
            column(StartAmt5; StartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt5; NetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt5; DisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt5; TotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt5; ReclassStartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt5; ReclassNetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt5; ReclassDisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt5; ReclassTotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ShowSection05; ShowSection(0, 5))
            {
            }
            column(HeadLineText9; HeadLineText[9])
            {
            }
            column(HeadLineText_6__Control218; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control219; HeadLineText[7])
            {
            }
            column(HeadLineText_9__Control220; HeadLineText[9])
            {
            }
            column(StartText_Control221; StartText)
            {
            }
            column(EndText_Control222; EndText)
            {
            }
            column(StartAmt6; StartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmt6; NetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmt6; DisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmt6; TotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassStartAmt6; ReclassStartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassNetChangeAmt6; ReclassNetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassDisposalAmt6; ReclassDisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmt6; ReclassTotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ShowSection06; ShowSection(0, 6))
            {
            }
            column(HeadLineText_5__Control79; HeadLineText[5])
            {
            }
            column(EndText_Control80; EndText)
            {
            }
            column(BookValueAtEndingDate; BookValueAtEndingDate)
            {
                AutoFormatType = 1;
            }
            column(GroupHeadLineText; GroupHeadLineText)
            {
            }
            column(HeadLineText_1__Control83; HeadLineText[1])
            {
            }
            column(HeadLineText_6__Control84; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control85; HeadLineText[7])
            {
            }
            column(HeadLineText_1__Control86; HeadLineText[1])
            {
            }
            column(StartText_Control87; StartText)
            {
            }
            column(EndText_Control88; EndText)
            {
            }
            column(GroupStartAmt1; GroupStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt1; GroupNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt1; GroupDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_1__Control92; TotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt1; ReclassGroupStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt1; ReclassGroupNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt1; ReclassGroupDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_1__Control189; ReclassTotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(HeadLineText_5__Control14; HeadLineText[5])
            {
            }
            column(StartText_Control16; StartText)
            {
            }
            column(BookValueAtStartingDate_Control26; BookValueAtStartingDate)
            {
                AutoFormatType = 1;
            }
            column(ReclassificationText_Control42; ReclassificationText)
            {
            }
            column(GroupTotals; GroupTotals)
            {
            }
            column(ShowSection12; ShowSection(1, 2))
            {
            }
            column(HeadLineText_2__Control93; HeadLineText[2])
            {
            }
            column(HeadLineText_6__Control94; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control95; HeadLineText[7])
            {
            }
            column(HeadLineText_2__Control96; HeadLineText[2])
            {
            }
            column(StartText_Control97; StartText)
            {
            }
            column(EndText_Control98; EndText)
            {
            }
            column(GroupStartAmt2; GroupStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt2; GroupNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt2; GroupDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_2__Control102; TotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt2; ReclassGroupStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt2; ReclassGroupNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt2; ReclassGroupDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_2__Control193; ReclassTotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ShowSection_1_2__Control369; ShowSection(1, 2))
            {
            }
            column(GroupTotals_Control370; GroupTotals)
            {
            }
            column(HeadLineText_3__Control103; HeadLineText[3])
            {
            }
            column(HeadLineText_6__Control104; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control105; HeadLineText[7])
            {
            }
            column(HeadLineText_3__Control106; HeadLineText[3])
            {
            }
            column(StartText_Control107; StartText)
            {
            }
            column(EndText_Control108; EndText)
            {
            }
            column(GroupStartAmt3; GroupStartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt3; GroupNetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt3; GroupDisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_3__Control112; TotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt3; ReclassGroupStartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt3; ReclassGroupNetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt3; ReclassGroupDisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_3__Control197; ReclassTotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(GroupTotals_Control381; GroupTotals)
            {
            }
            column(ShowSection13; ShowSection(1, 3))
            {
            }
            column(HeadLineText_4__Control113; HeadLineText[4])
            {
            }
            column(HeadLineText_6__Control114; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control115; HeadLineText[7])
            {
            }
            column(HeadLineText_4__Control116; HeadLineText[4])
            {
            }
            column(StartText_Control117; StartText)
            {
            }
            column(EndText_Control118; EndText)
            {
            }
            column(GroupStartAmt4; GroupStartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt4; GroupNetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt4; GroupDisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_4__Control122; TotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt4; ReclassGroupStartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt4; ReclassGroupNetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt4; ReclassGroupDisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_4__Control201; ReclassTotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(GroupTotals_Control391; GroupTotals)
            {
            }
            column(ShowSection14; ShowSection(1, 4))
            {
            }
            column(HeadLineText_8__Control232; HeadLineText[8])
            {
            }
            column(HeadLineText_6__Control233; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control234; HeadLineText[7])
            {
            }
            column(HeadLineText_8__Control235; HeadLineText[8])
            {
            }
            column(StartText_Control236; StartText)
            {
            }
            column(EndText_Control237; EndText)
            {
            }
            column(GroupStartAmt5; GroupStartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt5; GroupNetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt5; GroupDisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_5__Control241; TotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt5; ReclassGroupStartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt5; ReclassGroupNetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt5; ReclassGroupDisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_5__Control245; ReclassTotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(GroupTotals_Control401; GroupTotals)
            {
            }
            column(ShowSection15; ShowSection(1, 5))
            {
            }
            column(HeadLineText_9__Control246; HeadLineText[9])
            {
            }
            column(HeadLineText_6__Control247; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control248; HeadLineText[7])
            {
            }
            column(HeadLineText_9__Control249; HeadLineText[9])
            {
            }
            column(StartText_Control250; StartText)
            {
            }
            column(EndText_Control251; EndText)
            {
            }
            column(GroupStartAmt6; GroupStartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmt6; GroupNetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmt6; GroupDisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_6__Control255; TotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupStartAmt6; ReclassGroupStartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupNetChangeAmt6; ReclassGroupNetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassGroupDisposalAmt6; ReclassGroupDisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_6__Control259; ReclassTotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(GroupTotals_Control414; GroupTotals)
            {
            }
            column(ShowSection16; ShowSection(1, 6))
            {
            }
            column(HeadLineText_5__Control123; HeadLineText[5])
            {
            }
            column(EndText_Control124; EndText)
            {
            }
            column(BookValueAtEndingDate_Control125; BookValueAtEndingDate)
            {
                AutoFormatType = 1;
            }
            column(HeadLineText_1__Control127; HeadLineText[1])
            {
            }
            column(HeadLineText_6__Control128; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control129; HeadLineText[7])
            {
            }
            column(HeadLineText_1__Control130; HeadLineText[1])
            {
            }
            column(StartText_Control131; StartText)
            {
            }
            column(EndText_Control132; EndText)
            {
            }
            column(TotalStartAmt1; TotalStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt1; TotalNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt1; TotalDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_1__Control136; TotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt1; ReclassTotalStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt1; ReclassTotalNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt1; ReclassTotalDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_1__Control205; ReclassTotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(HeadLineText_5__Control27; HeadLineText[5])
            {
            }
            column(StartText_Control29; StartText)
            {
            }
            column(BookValueAtStartingDate_Control30; BookValueAtStartingDate)
            {
                AutoFormatType = 1;
            }
            column(ReclassificationText_Control46; ReclassificationText)
            {
            }
            column(ShowSection22; ShowSection(2, 2))
            {
            }
            column(HeadLineText_2__Control137; HeadLineText[2])
            {
            }
            column(HeadLineText_6__Control138; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control139; HeadLineText[7])
            {
            }
            column(HeadLineText_2__Control140; HeadLineText[2])
            {
            }
            column(StartText_Control141; StartText)
            {
            }
            column(EndText_Control142; EndText)
            {
            }
            column(TotalStartAmt2; TotalStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt2; TotalNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt2; TotalDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_2__Control146; TotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt2; ReclassTotalStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt2; ReclassTotalNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt2; ReclassTotalDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_2__Control209; ReclassTotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(ShowSection_2_2__Control433; ShowSection(2, 2))
            {
            }
            column(HeadLineText_3__Control147; HeadLineText[3])
            {
            }
            column(HeadLineText_6__Control148; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control149; HeadLineText[7])
            {
            }
            column(HeadLineText_3__Control150; HeadLineText[3])
            {
            }
            column(StartText_Control151; StartText)
            {
            }
            column(EndText_Control152; EndText)
            {
            }
            column(TotalStartAmt3; TotalStartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt3; TotalNetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt3; TotalDisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_3__Control156; TotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt3; ReclassTotalStartAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt3; ReclassTotalNetChangeAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt3; ReclassTotalDisposalAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_3__Control213; ReclassTotalEndingAmounts[3])
            {
                AutoFormatType = 1;
            }
            column(ShowSection23; ShowSection(2, 3))
            {
            }
            column(HeadLineText_4__Control157; HeadLineText[4])
            {
            }
            column(HeadLineText_6__Control158; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control159; HeadLineText[7])
            {
            }
            column(HeadLineText_4__Control160; HeadLineText[4])
            {
            }
            column(StartText_Control161; StartText)
            {
            }
            column(EndText_Control162; EndText)
            {
            }
            column(TotalStartAmt4; TotalStartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt4; TotalNetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt4; TotalDisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_4__Control166; TotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt4; ReclassTotalStartAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt4; ReclassTotalNetChangeAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt4; ReclassTotalDisposalAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_4__Control217; ReclassTotalEndingAmounts[4])
            {
                AutoFormatType = 1;
            }
            column(ShowSection24; ShowSection(2, 4))
            {
            }
            column(HeadLineText_8__Control272; HeadLineText[8])
            {
            }
            column(HeadLineText_6__Control273; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control274; HeadLineText[7])
            {
            }
            column(HeadLineText_8__Control275; HeadLineText[8])
            {
            }
            column(StartText_Control276; StartText)
            {
            }
            column(EndText_Control277; EndText)
            {
            }
            column(TotalStartAmt5; TotalStartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt5; TotalNetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_5__Control280; TotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt5; ReclassTotalStartAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt5; ReclassTotalNetChangeAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt5; ReclassTotalDisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_5__Control284; ReclassTotalEndingAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt5; TotalDisposalAmounts[5])
            {
                AutoFormatType = 1;
            }
            column(ShowSection25; ShowSection(2, 5))
            {
            }
            column(HeadLineText_9__Control3; HeadLineText[9])
            {
            }
            column(HeadLineText_6__Control15; HeadLineText[6])
            {
            }
            column(HeadLineText_7__Control261; HeadLineText[7])
            {
            }
            column(HeadLineText_9__Control262; HeadLineText[9])
            {
            }
            column(StartText_Control263; StartText)
            {
            }
            column(EndText_Control264; EndText)
            {
            }
            column(TotalStartAmt6; TotalStartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmt6; TotalNetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts_6__Control267; TotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalStartAmt6; ReclassTotalStartAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalNetChangeAmt6; ReclassTotalNetChangeAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalDisposalAmt6; ReclassTotalDisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ReclassTotalEndingAmounts_6__Control271; ReclassTotalEndingAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmt6; TotalDisposalAmounts[6])
            {
                AutoFormatType = 1;
            }
            column(ShowSection26; ShowSection(2, 6))
            {
            }
            column(HeadLineText_5__Control167; HeadLineText[5])
            {
            }
            column(EndText_Control168; EndText)
            {
            }
            column(BookValueAtEndingDate_Control169; BookValueAtEndingDate)
            {
                AutoFormatType = 1;
            }
            column(FAClassCode_FixedAsset; "FA Class Code")
            {
            }
            column(FASubclassCode_FixedAsset; "FA Subclass Code")
            {
            }
            column(FALocationCode_FixedAsset; "FA Location Code")
            {
            }
            column(CompofMainAsset_FixedAsset; "Component of Main Asset")
            {
            }
            column(GlobalDim1Code_FixedAsset; "Global Dimension 1 Code")
            {
            }
            column(GlobalDim2Code_FixedAsset; "Global Dimension 2 Code")
            {
            }
            column(FAPostingGroup_FixedAsset; "FA Posting Group")
            {
            }
            column(TaxDepreciationGroupCode_FixedAsset; "Tax Deprec. Group Code CZF")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not FADepreciationBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if SkipRecord() then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADepreciationBook."FA Posting Group" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("FA Posting Group"), "No.");
                if GroupTotals = GroupTotals::"Tax Depreciation Group" then
                    if "Tax Deprec. Group Code CZF" <> FADepreciationBook."Tax Deprec. Group Code CZF" then
                        Error(HasBeenModifiedInFAErr, FieldCaption("Tax Deprec. Group Code CZF"), "No.");
                BeforeAmount := 0;
                EndingAmount := 0;
                if BudgetReport then
                    BudgetDepreciation.Calculate(
                      "No.", GetStartingDate(StartingDate), EndingDate, DeprBookCode, BeforeAmount, EndingAmount);

                i := 0;
                while i < NumberOfTypes do begin
                    i := i + 1;
                    case i of
                        1:
                            PostingType := FADepreciationBook.FieldNo("Acquisition Cost");
                        2:
                            PostingType := FADepreciationBook.FieldNo(Depreciation);
                        3:
                            PostingType := FADepreciationBook.FieldNo("Write-Down");
                        4:
                            PostingType := FADepreciationBook.FieldNo(Appreciation);
                        5:
                            PostingType := FADepreciationBook.FieldNo("Custom 1");
                        6:
                            PostingType := FADepreciationBook.FieldNo("Custom 2");
                    end;
                    if StartingDate <= 00000101D then begin
                        StartAmounts[i] := 0;
                        ReclassStartAmounts[i] := 0;
                    end else begin
                        StartAmounts[i] :=
                          FAGeneralReport.CalcFAPostedAmount(
                            "No.", PostingType, Period1, StartingDate, EndingDate,
                            DeprBookCode, BeforeAmount, EndingAmount, false, true);
                        if Reclassify then
                            ReclassStartAmounts[i] :=
                              FAGeneralReport.CalcFAPostedAmount(
                                "No.", PostingType, Period1, StartingDate, EndingDate,
                                DeprBookCode, 0, 0, true, true);
                    end;
                    NetChangeAmounts[i] := FAGeneralReport.CalcFAPostedAmount("No.", PostingType, Period2, StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, true);
                    if Reclassify then
                        ReclassNetChangeAmounts[i] :=
                          FAGeneralReport.CalcFAPostedAmount(
                            "No.", PostingType, Period2, StartingDate, EndingDate,
                            DeprBookCode, 0, 0, true, true);

                    if GetPeriodDisposal() then begin
                        DisposalAmounts[i] := -(StartAmounts[i] + NetChangeAmounts[i]);
                        ReclassDisposalAmounts[i] := -(ReclassStartAmounts[i] + ReclassNetChangeAmounts[i]);
                    end else begin
                        DisposalAmounts[i] := 0;
                        ReclassDisposalAmounts[i] := 0;
                    end;
                end;

                for j := 1 to NumberOfTypes do begin
                    TotalEndingAmounts[j] := StartAmounts[j] + NetChangeAmounts[j] + DisposalAmounts[j];
                    if Reclassify then
                        ReclassTotalEndingAmounts[j] :=
                          ReclassStartAmounts[j] + ReclassNetChangeAmounts[j] + ReclassDisposalAmounts[j];
                end;
                BookValueAtEndingDate := 0;
                BookValueAtStartingDate := 0;
                for j := 1 to NumberOfTypes do begin
                    BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
                    BookValueAtStartingDate := BookValueAtStartingDate + StartAmounts[j];
                end;

                MakeGroupHeadLine();
                UpdateTotals();
                CreateGroupTotals();
            end;

            trigger OnPostDataItem()
            begin
                CreateTotals();
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotals::"FA Subclass":
                        SetCurrentKey("FA Subclass Code");
                    GroupTotals::"Main Asset":
                        SetCurrentKey("Component of Main Asset");
                    GroupTotals::"FA Location":
                        SetCurrentKey("FA Location Code");
                    GroupTotals::"Global Dimension 1":
                        SetCurrentKey("Global Dimension 1 Code");
                    GroupTotals::"Global Dimension 2":
                        SetCurrentKey("Global Dimension 2 Code");
                    GroupTotals::"FA Posting Group":
                        SetCurrentKey("FA Posting Group");
                    GroupTotals::"Tax Depreciation Group":
                        SetCurrentKey("Tax Deprec. Group Code CZF");
                end;
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
                    field(DeprBookCodeCZF; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';
                    }
                    field(StartingDateCZF; StartingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date';
                    }
                    field(EndingDateCZF; EndingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period.';
                    }
                    field(GroupTotalsCZF; GroupTotals)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group Totals';
                        ToolTip = 'Specifies a group type if you want the report to group the fixed assets and print group totals.';
                    }
                    field(PrintDetailsCZF; PrintDetails)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print per Fixed Asset';
                        ToolTip = 'Specifies if you want the report to print information separately for each fixed asset.';
                    }
                    field(BudgetReportCZF; BudgetReport)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Budget Report';
                        ToolTip = 'Specifies if you want the report to include calculated future depreciation (and thus, also a calculated future book value).';
                    }
                    field(IncludeReclassification; Reclassify)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Include Reclassification';
                        ToolTip = 'Specifies if you want the report to include acquisition cost and depreciation entries that are marked as reclassification entries. These entries are then printed in a separate column.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            GetDepreciationBookCode();
        end;
    }

    labels
    {
        PageLbl = 'Page';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        FAGeneralReport.ValidateDates(StartingDate, EndingDate);
        DepreciationBook.Get(DeprBookCode);
        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGeneralReport.SetFAPostingGroup("Fixed Asset", DepreciationBook.Code);
        if GroupTotals = GroupTotals::"Tax Depreciation Group" then
            FAGeneralReportCZF.SetFATaxDeprGroup("Fixed Asset", DepreciationBook.Code);
        FAGeneralReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        MainHeadLineText := ReportNameTxt;
        if BudgetReport then
            MainHeadLineText := StrSubstNo(TwoPlaceholdersTok, MainHeadLineText, BudgetReportTxt);
        DeprBookText := StrSubstNo(TwoPlaceholdersTok, DepreciationBook.TableCaption, DeprBookCode);
        NumberOfTypes := 6;
        MakeHeadLineText();
        MakeGroupTotalText();
        Period1 := Period1::"Before Starting Date";
        Period2 := Period2::"Net Change";
    end;

    var
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FAGeneralReport: Codeunit "FA General Report";
        FAGeneralReportCZF: Codeunit "FA General Report CZF";
        BudgetDepreciation: Codeunit "Budget Depreciation";
        DeprBookCode: Code[10];
        NumberOfTypes: Integer;
        MainHeadLineText, GroupHeadLineText, DeprBookText, GroupCodeName, GroupHeadLine, StartText, EndText : Text;
        GroupTotals: Enum "FA Analysis Group CZF";
        HeadLineText: array[10] of Text;
        StartAmounts, NetChangeAmounts, DisposalAmounts : array[6] of Decimal;
        GroupStartAmounts, GroupNetChangeAmounts, GroupDisposalAmounts : array[6] of Decimal;
        TotalStartAmounts, TotalNetChangeAmounts, TotalDisposalAmounts : array[6] of Decimal;
        ReclassStartAmounts, ReclassNetChangeAmounts, ReclassDisposalAmounts : array[6] of Decimal;
        ReclassGroupStartAmounts, ReclassGroupNetChangeAmounts, ReclassGroupDisposalAmounts : array[6] of Decimal;
        ReclassTotalStartAmounts, ReclassTotalNetChangeAmounts, ReclassTotalDisposalAmounts, ReclassTotalEndingAmounts : array[6] of Decimal;
        TotalEndingAmounts: array[7] of Decimal;
        BookValueAtStartingDate, BookValueAtEndingDate : Decimal;
        i, j : Integer;
        PostingType: Integer;
        Period1, Period2 : Option "Before Starting Date","Net Change","at Ending Date";
        StartingDate, EndingDate : Date;
        PrintDetails, BudgetReport, Reclassify : Boolean;
        ReclassificationText: Text;
        BeforeAmount, EndingAmount : Decimal;
        AcquisitionDate, DisposalDate : Date;
        ReportNameTxt: Label 'Fixed Asset - Book Value 02';
        BudgetReportTxt: Label '(Budget Report)';
        ReclassificationTxt: Label 'Reclassification';
        AdditionInPeriodTxt: Label 'Addition in Period';
        DisposalInPeriodTxt: Label 'Disposal in Period';
        GroupTotalTxt: Label 'Group Total';
        GroupTotalsTxt: Label 'Group Totals';
        HasBeenModifiedInFAErr: Label '%1 has been modified in fixed asset %2', Comment = '%1 = FieldCaption, %2 = Fixed Asset No.';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    local procedure SkipRecord(): Boolean
    begin
        AcquisitionDate := FADepreciationBook."Acquisition Date";
        DisposalDate := FADepreciationBook."Disposal Date";
        exit(
          "Fixed Asset".Inactive or
          (AcquisitionDate = 0D) or
          (AcquisitionDate > EndingDate) and (EndingDate > 0D) or
          (DisposalDate > 0D) and (DisposalDate < StartingDate))
    end;

    local procedure GetPeriodDisposal(): Boolean
    begin
        if DisposalDate > 0D then
            if (EndingDate = 0D) or (DisposalDate <= EndingDate) then
                exit(true);
        exit(false);
    end;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Class Code");
            GroupTotals::"FA Subclass":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Subclass Code");
            GroupTotals::"FA Location":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Location Code");
            GroupTotals::"Main Asset":
                GroupCodeName := "Fixed Asset".FieldCaption("Main Asset/Component");
            GroupTotals::"Global Dimension 1":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 1 Code");
            GroupTotals::"Global Dimension 2":
                GroupCodeName := "Fixed Asset".FieldCaption("Global Dimension 2 Code");
            GroupTotals::"FA Posting Group":
                GroupCodeName := "Fixed Asset".FieldCaption("FA Posting Group");
            GroupTotals::"Tax Depreciation Group":
                GroupCodeName := "Fixed Asset".FieldCaption("Tax Deprec. Group Code CZF");
        end;
        if GroupCodeName <> '' then
            GroupCodeName := StrSubstNo(TwoPlaceholdersTok, GroupTotalsTxt, GroupCodeName);
    end;

    local procedure MakeHeadLineText()
    begin
        EndText := Format(EndingDate);
        StartText := Format(StartingDate - 1);
        if Reclassify then
            ReclassificationText := ReclassificationTxt;

        HeadLineText[1] := FADepreciationBook.FieldCaption("Acquisition Cost");
        HeadLineText[2] := FADepreciationBook.FieldCaption(Depreciation);
        HeadLineText[3] := FADepreciationBook.FieldCaption("Write-Down");
        HeadLineText[4] := FADepreciationBook.FieldCaption(Appreciation);
        HeadLineText[5] := FADepreciationBook.FieldCaption("Book Value");
        HeadLineText[6] := AdditionInPeriodTxt;
        HeadLineText[7] := DisposalInPeriodTxt;
        HeadLineText[8] := FADepreciationBook.FieldCaption("Custom 1");
        HeadLineText[9] := FADepreciationBook.FieldCaption("Custom 2");
    end;

    local procedure MakeGroupHeadLine()
    begin
        for j := 1 to NumberOfTypes do begin
            GroupStartAmounts[j] := 0;
            GroupNetChangeAmounts[j] := 0;
            GroupDisposalAmounts[j] := 0;
            ReclassGroupStartAmounts[j] := 0;
            ReclassGroupNetChangeAmounts[j] := 0;
            ReclassGroupDisposalAmounts[j] := 0;
        end;
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := "Fixed Asset"."FA Class Code";
            GroupTotals::"FA Subclass":
                GroupHeadLine := "Fixed Asset"."FA Subclass Code";
            GroupTotals::"FA Location":
                GroupHeadLine := "Fixed Asset"."FA Location Code";
            GroupTotals::"Main Asset":
                begin
                    FixedAsset."Main Asset/Component" := FixedAsset."Main Asset/Component"::"Main Asset";
                    GroupHeadLine :=
                      StrSubstNo(TwoPlaceholdersTok, Format(FixedAsset."Main Asset/Component"), "Fixed Asset"."Component of Main Asset");
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := StrSubstNo(TwoPlaceholdersTok, GroupHeadLine, '*****');
                end;
            GroupTotals::"Global Dimension 1":
                GroupHeadLine := "Fixed Asset"."Global Dimension 1 Code";
            GroupTotals::"Global Dimension 2":
                GroupHeadLine := "Fixed Asset"."Global Dimension 2 Code";
            GroupTotals::"FA Posting Group":
                GroupHeadLine := "Fixed Asset"."FA Posting Group";
            GroupTotals::"Tax Depreciation Group":
                GroupHeadLine := "Fixed Asset"."Tax Deprec. Group Code CZF";
        end;
        if GroupHeadLine = '' then
            GroupHeadLine := '*****';
        GroupHeadLineText := StrSubstNo(TwoPlaceholdersTok, GroupTotalTxt, GroupHeadLine);
    end;

    local procedure UpdateTotals()
    begin
        for j := 1 to NumberOfTypes do begin
            GroupStartAmounts[j] := GroupStartAmounts[j] + StartAmounts[j];
            GroupNetChangeAmounts[j] := GroupNetChangeAmounts[j] + NetChangeAmounts[j];
            GroupDisposalAmounts[j] := GroupDisposalAmounts[j] + DisposalAmounts[j];
            TotalStartAmounts[j] := TotalStartAmounts[j] + StartAmounts[j];
            TotalNetChangeAmounts[j] := TotalNetChangeAmounts[j] + NetChangeAmounts[j];
            TotalDisposalAmounts[j] := TotalDisposalAmounts[j] + DisposalAmounts[j];
            if Reclassify then begin
                ReclassGroupStartAmounts[j] := ReclassGroupStartAmounts[j] + ReclassStartAmounts[j];
                ReclassGroupNetChangeAmounts[j] := ReclassGroupNetChangeAmounts[j] + ReclassNetChangeAmounts[j];
                ReclassGroupDisposalAmounts[j] := ReclassGroupDisposalAmounts[j] + ReclassDisposalAmounts[j];
                ReclassTotalStartAmounts[j] := ReclassTotalStartAmounts[j] + ReclassStartAmounts[j];
                ReclassTotalNetChangeAmounts[j] := ReclassTotalNetChangeAmounts[j] + ReclassNetChangeAmounts[j];
                ReclassTotalDisposalAmounts[j] := ReclassTotalDisposalAmounts[j] + ReclassDisposalAmounts[j];
            end;
        end;
    end;

    local procedure CreateGroupTotals()
    begin
        for j := 1 to NumberOfTypes do begin
            TotalEndingAmounts[j] := GroupStartAmounts[j] + GroupNetChangeAmounts[j] + GroupDisposalAmounts[j];
            if Reclassify then
                ReclassTotalEndingAmounts[j] :=
                  ReclassGroupStartAmounts[j] + ReclassGroupNetChangeAmounts[j] + ReclassGroupDisposalAmounts[j];
        end;
        BookValueAtEndingDate := 0;
        BookValueAtStartingDate := 0;
        for j := 1 to NumberOfTypes do begin
            BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
            BookValueAtStartingDate := BookValueAtStartingDate + GroupStartAmounts[j];
        end;
    end;

    local procedure CreateTotals()
    begin
        for j := 1 to NumberOfTypes do begin
            TotalEndingAmounts[j] := TotalStartAmounts[j] + TotalNetChangeAmounts[j] + TotalDisposalAmounts[j];
            if Reclassify then
                ReclassTotalEndingAmounts[j] :=
                  ReclassTotalStartAmounts[j] + ReclassTotalNetChangeAmounts[j] + ReclassTotalDisposalAmounts[j];
        end;
        BookValueAtEndingDate := 0;
        BookValueAtStartingDate := 0;
        for j := 1 to NumberOfTypes do begin
            BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
            BookValueAtStartingDate := BookValueAtStartingDate + TotalStartAmounts[j];
        end;
    end;

    local procedure GetStartingDate(StartingDate2: Date): Date
    begin
        if StartingDate2 <= 00000101D then
            exit(0D);

        exit(StartingDate2 - 1);
    end;

    local procedure ShowSection(Section: Option Body,GroupFooter,Footer; Type: Integer): Boolean
    begin
        case Section of
            Section::Body:
                exit(
                  PrintDetails and
                  ((StartAmounts[Type] <> 0) or
                   (NetChangeAmounts[Type] <> 0) or
                   (DisposalAmounts[Type] <> 0) or
                   (TotalEndingAmounts[Type] <> 0) or
                   (ReclassStartAmounts[Type] <> 0) or
                   (ReclassNetChangeAmounts[Type] <> 0) or
                   (ReclassDisposalAmounts[Type] <> 0) or
                   (ReclassTotalEndingAmounts[Type] <> 0)));
            Section::GroupFooter:
                exit(
                  (GroupTotals <> GroupTotals::" ") and
                  ((GroupStartAmounts[Type] <> 0) or
                   (GroupNetChangeAmounts[Type] <> 0) or
                   (GroupDisposalAmounts[Type] <> 0) or
                   (TotalEndingAmounts[Type] <> 0) or
                   (ReclassGroupStartAmounts[Type] <> 0) or
                   (ReclassGroupNetChangeAmounts[Type] <> 0) or
                   (ReclassGroupDisposalAmounts[Type] <> 0) or
                   (ReclassTotalEndingAmounts[Type] <> 0)));
            Section::Footer:
                exit(
                  (TotalStartAmounts[Type] <> 0) or
                  (TotalNetChangeAmounts[Type] <> 0) or
                  (TotalDisposalAmounts[Type] <> 0) or
                  (TotalEndingAmounts[Type] <> 0) or
                  (ReclassTotalStartAmounts[Type] <> 0) or
                  (ReclassTotalNetChangeAmounts[Type] <> 0) or
                  (ReclassTotalDisposalAmounts[Type] <> 0) or
                  (ReclassTotalEndingAmounts[Type] <> 0));
        end;
    end;

    procedure SetMandatoryFields(DepreciationBookCodeFrom: Code[10]; StartingDateFrom: Date; EndingDateFrom: Date)
    begin
        DeprBookCode := DepreciationBookCodeFrom;
        StartingDate := StartingDateFrom;
        EndingDate := EndingDateFrom;
    end;

    procedure SetTotalFields(GroupTotalsFrom: Enum "FA Analysis Group CZF"; PrintDetailsFrom: Boolean; BudgetReportFrom: Boolean; ReclassifyFrom: Boolean)
    begin
        GroupTotals := GroupTotalsFrom;
        PrintDetails := PrintDetailsFrom;
        BudgetReport := BudgetReportFrom;
        Reclassify := ReclassifyFrom;
    end;

    procedure GetDepreciationBookCode()
    begin
        if DeprBookCode = '' then begin
            FASetup.Get();
            DeprBookCode := FASetup."Default Depr. Book";
        end;
    end;
}
