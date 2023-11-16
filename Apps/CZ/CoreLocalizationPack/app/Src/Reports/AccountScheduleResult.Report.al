// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

report 31202 "Account Schedule Result CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AccountScheduleResult.rdl';
    Caption = 'Account Schedule Result';

    dataset
    {
        dataitem(AccScheduleResultHdr; "Acc. Schedule Result Hdr. CZL")
        {
            column(AccSheduleResultHdr_ResultCode; "Result Code")
            {
            }
            dataitem(AccScheduleResultLine; "Acc. Schedule Result Line CZL")
            {
                DataItemLink = "Result Code" = field("Result Code");
                DataItemTableView = sorting("Result Code", "Line No.");
                column(AccScheduleName_Description; AccScheduleName.Description)
                {
                }
                column(AccScheduleResultHdr_DateFilter; AccScheduleResultHdr."Date Filter")
                {
                }
                column(AccScheduleResultHdr_ColumnLayoutName; AccScheduleResultHdr."Column Layout Name")
                {
                }
                column(AccScheduleName_Name; AccScheduleName.Name)
                {
                }
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
                {
                }
                column(AccScheduleResultHdr_Description; AccScheduleResultHdr.Description)
                {
                }
                column(Header_1; Header[1])
                {
                }
                column(Header_2; Header[2])
                {
                }
                column(Header_3; Header[3])
                {
                }
                column(Header_4; Header[4])
                {
                }
                column(Header_5; Header[5])
                {
                }
                column(ColumnValuesAsText_5; ColumnValuesAsText[5])
                {
                }
                column(ColumnValuesAsText_4; ColumnValuesAsText[4])
                {
                }
                column(ColumnValuesAsText_3; ColumnValuesAsText[3])
                {
                }
                column(ColumnValuesAsText_2; ColumnValuesAsText[2])
                {
                }
                column(ColumnValuesAsText_1; ColumnValuesAsText[1])
                {
                }
                column(AccScheduleResultLine_RowNo; "Row No.")
                {
                    IncludeCaption = true;
                }
                column(AccScheduleResultLine_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(AccScheduleResultLine_ResultCode; "Result Code")
                {
                }
                column(AccScheduleResultLine_LineNo; "Line No.")
                {
                }
                column(Hide_Line; Show = Show::No)
                {
                }
                column(Bold_Line; Bold)
                {
                }
                column(Italic_Line; Italic)
                {
                }
                column(UnderLine_Line; Underline)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(ColumnValuesAsText);
                    i := 0;

                    AccScheduleResultColCZL.SetRange("Result Code", "Result Code");
                    if AccScheduleResultColCZL.FindSet() then
                        repeat
                            i := i + 1;
                            if AccScheduleResultValueCZL.Get(
                                 AccScheduleResultHdr."Result Code",
                                 "Line No.",
                                 AccScheduleResultColCZL."Line No.")
                            then
                                if AccScheduleResultValueCZL.Value <> 0 then
                                    ColumnValuesAsText[i] := Format(AccScheduleResultValueCZL.Value);
                        until AccScheduleResultColCZL.Next() = 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                AccScheduleName.Get("Acc. Schedule Name");
                Clear(Header);
                i := 0;

                AccScheduleResultColCZL.SetRange("Result Code", "Result Code");
                if AccScheduleResultColCZL.FindSet() then
                    repeat
                        i := i + 1;
                        Header[i] := AccScheduleResultColCZL."Column Header";
                    until AccScheduleResultColCZL.Next() = 0;
            end;
        }
    }

    labels
    {
        PeriodLbl = 'Period';
        ColumnLayoutLbl = 'Column Layout';
        AccountScheduleLbl = 'Account Schedule';
        PageLbl = 'Page';
        ResultDescriptionbl = 'Result Description';
    }

    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
        ColumnValuesAsText: array[5] of Text[30];
        Header: array[5] of Text[50];
        i: Integer;
}
