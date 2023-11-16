// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using System.IO;
using System.Utilities;

report 31203 "Exp. Acc. Sched. Res. Exc. CZL"
{
    Caption = 'Exp. Acc. Sched. Res. to Excel';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                Window: Dialog;
                RecNo: Integer;
                TotalRecNo: Integer;
                RowNo: Integer;
                ColumnNo: Integer;
            begin
                Window.Open(
                  AnalyzingDataTxt +
                  '@1@@@@@@@@@@@@@@@@@@@@@\');
                Window.Update(1, 0);
                AccScheduleResultLineCZL.SetRange("Result Code", AccScheduleResultHdrCZL."Result Code");
                AccScheduleResultColCZL.SetRange("Result Code", AccScheduleResultHdrCZL."Result Code");
                TotalRecNo := AccScheduleResultLineCZL.Count();
                RecNo := 0;

                TempExcelBuffer.DeleteAll();
                Clear(TempExcelBuffer);

                GeneralLedgerSetup.Get();

                RowNo := 1;
                EnterCell(RowNo, 1, CopyStr(AccScheduleResultHdrCZL.FieldCaption(Description), 1, 250), false, false, true);
                EnterCell(RowNo, 2, CopyStr(AccScheduleResultHdrCZL.Description, 1, 250), false, false, true);

                RowNo := RowNo + 1;
                EnterFilterInCell(
                  RowNo,
                  AccScheduleResultHdrCZL."Date Filter",
                  CopyStr(AccScheduleResultHdrCZL.FieldCaption("Date Filter"), 1, 100));

                RowNo := RowNo + 1;
                if UseAmtsInAddCurr then begin
                    if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
                        RowNo := RowNo + 1;
                        EnterFilterInCell(
                          RowNo,
                          GeneralLedgerSetup."Additional Reporting Currency",
                          CopyStr(Currency.TableCaption, 1, 100))
                    end;
                end else
                    if GeneralLedgerSetup."LCY Code" <> '' then begin
                        RowNo := RowNo + 1;
                        EnterFilterInCell(
                          RowNo,
                          GeneralLedgerSetup."LCY Code",
                          CopyStr(Currency.TableCaption, 1, 100));
                    end;

                RowNo := RowNo + 1;
                if AccScheduleResultLineCZL.FindSet() then begin
                    if AccScheduleResultColCZL.FindSet() then begin
                        RowNo := RowNo + 1;
                        ColumnNo := 1;
                        repeat
                            ColumnNo := ColumnNo + 1;
                            EnterCell(
                              RowNo,
                              ColumnNo,
                              AccScheduleResultColCZL."Column Header",
                              false,
                              false,
                              false);
                        until AccScheduleResultColCZL.Next() = 0;
                    end;
                    repeat
                        RecNo := RecNo + 1;
                        Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                        RowNo := RowNo + 1;
                        ColumnNo := 1;
                        EnterCell(
                          RowNo,
                          ColumnNo,
                          AccScheduleResultLineCZL.Description,
                          AccScheduleResultLineCZL.Bold,
                          AccScheduleResultLineCZL.Italic,
                          AccScheduleResultLineCZL.Underline);
                        if AccScheduleResultColCZL.FindSet() then
                            repeat
                                AccScheduleResultValueCZL.Get(
                                  AccScheduleResultHdrCZL."Result Code",
                                  AccScheduleResultLineCZL."Line No.",
                                  AccScheduleResultColCZL."Line No.");
                                ColumnValue := AccScheduleResultValueCZL.Value;
                                ColumnNo := ColumnNo + 1;
                                if ColumnValue <> 0 then
                                    EnterCell(
                                      RowNo,
                                      ColumnNo,
                                      Format(ColumnValue),
                                      AccScheduleResultLineCZL.Bold,
                                      AccScheduleResultLineCZL.Italic,
                                      AccScheduleResultLineCZL.Underline)
                                else
                                    EnterCell(
                                      RowNo,
                                      ColumnNo,
                                      '',
                                      AccScheduleResultLineCZL.Bold,
                                      AccScheduleResultLineCZL.Italic,
                                      AccScheduleResultLineCZL.Underline);
                            until AccScheduleResultColCZL.Next() = 0;
                    until AccScheduleResultLineCZL.Next() = 0;
                end;

                Window.Close();
                AccScheduleName.Get(AccScheduleResultHdrCZL."Acc. Schedule Name");
                TempExcelBuffer.CreateNewBook(AccScheduleName.Name);
                TempExcelBuffer.WriteSheet(AccScheduleName.Description, CompanyName, UserId);
                TempExcelBuffer.CloseBook();
                TempExcelBuffer.SetFriendlyFilename(StrSubstNo(TwoPlaceholdersTok, AccScheduleName.Name, AccScheduleName.Description));
                TempExcelBuffer.OpenExcel();
            end;
        }
    }

    var
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
        Currency: Record Currency;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UseAmtsInAddCurr: Boolean;
        ColumnValue: Decimal;
        AnalyzingDataTxt: Label 'Analyzing Data...\\';
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;

    procedure SetOptions(AccScheduleResultHeaderCode: Code[20]; UseAmtsInAddCurr2: Boolean)
    begin
        AccScheduleResultHdrCZL.Get(AccScheduleResultHeaderCode);

        UseAmtsInAddCurr := UseAmtsInAddCurr2;
    end;

    local procedure EnterFilterInCell(RowNo: Integer; "Filter": Text[250]; FieldName: Text[100])
    begin
        if Filter <> '' then begin
            EnterCell(RowNo, 1, FieldName, false, false, false);
            EnterCell(RowNo, 2, Filter, false, false, false);
        end;
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean)
    begin
        TempExcelBuffer.Init();
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.Insert();
    end;
}
