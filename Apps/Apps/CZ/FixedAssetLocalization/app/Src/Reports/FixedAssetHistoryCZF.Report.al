// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.HumanResources.Employee;
using System.Utilities;

report 31251 "Fixed Asset History CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetHistory.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset History';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Header; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            PrintOnlyIfDetail = true;
            column(AtDate; StrSubstNo(AtDateLbl, Format(EndDate)))
            {
            }
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(GroupBy; GroupBy.AsInteger())
            {
            }
            column(GroupByText; GroupBy)
            {
            }
            column(NewPagePerGroup; NewPagePerGroup)
            {
            }
            dataitem(FAHistory; "FA History Entry CZF")
            {
                RequestFilterFields = "FA No.", Type, "New Value", "Old Value";
                column(FAHistory_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(FAHistory_Type; Type)
                {
                    IncludeCaption = true;
                }
                column(FAHistory_FANo; "FA No.")
                {
                    IncludeCaption = true;
                }
                column(FAHistory_OldValue; "Old Value")
                {
                    IncludeCaption = true;
                }
                column(FAHistory_NewValue; "New Value")
                {
                    IncludeCaption = true;
                }
                column(FAHistory_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(FAHistory_UserID; "User ID")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                begin
                    if GroupBy <> GroupBy::" " then
                        CurrReport.Break();
                end;
            }
            dataitem(FALocation; "FA Location")
            {
                DataItemTableView = sorting(Code);
                PrintOnlyIfDetail = true;
                column(FALoc_Code; Code)
                {
                }
                column(FALoc_Name; Name)
                {
                }
                dataitem(FALocationFA; "Fixed Asset")
                {
                    DataItemTableView = sorting("No.") order(descending);
                    PrintOnlyIfDetail = true;
                    dataitem(FALocationFAHistory; "FA History Entry CZF")
                    {
                        DataItemTableView = sorting("FA No.", "Entry No.") order(descending) where(Type = const("FA Location"));
                        column(FALocationFAHistory_FANo; "FA No.")
                        {
                        }
                        column(FALocationFAHistory_PostingDate; "Posting Date")
                        {
                        }
                        column(FALocationFAHistory_OldValue; "Old Value")
                        {
                        }
                        column(FALocationFAHistory_Description; Description)
                        {
                        }
                        column(FALocationFAHistory_SerialNo; SerialNo)
                        {
                        }
                        column(FALocationFAHistory_UserID; "User ID")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if FirstTime then begin
                                FAHistoryEntryCZF.Reset();
                                FAHistoryEntryCZF.CopyFilters(FAHistory);
                                FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"FA Location");
                                if FAHistory.GetFilter("Posting Date") = '' then
                                    FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);
                                FAHistoryEntryCZF.SetRange("FA No.", FALocationFA."No.");
                                ShowFirstHead := FindFirstFA(FALocation.Code);

                                FirstTime := false;

                                if CountPerGroup = 0 then begin
                                    if not ShowFirstHead then
                                        CountPerGroup := 0
                                    else begin
                                        CountPerGroup := CountPerGroup + 1;
                                        GroupCount := GroupCount + 1;
                                    end;
                                end else
                                    CountPerGroup := CountPerGroup + 1;
                            end;

                            if Disposal then begin
                                if not CheckCancel then
                                    CurrReport.Break();
                                CurrReport.Skip();
                            end;
                            if "Closed by Entry No." <> 0 then begin
                                CheckCancel := true;
                                CurrReport.Skip();
                            end;

                            if "New Value" <> FALocation.Code then
                                CurrReport.Break();

                            TestField("FA No.");
                            if FixedAsset3.Get("FA No.") then begin
                                Description := FixedAsset3.Description;
                                SerialNo := FixedAsset3."Serial No.";
                            end;

                            if FixedAssetNo <> "FA No." then begin
                                FixedAssetNo := "FA No.";
                                FAHistoryEntryCZF.Reset();
                                FAHistoryEntryCZF.CopyFilters(FAHistory);
                                if FAHistory.GetFilter("Posting Date") = '' then
                                    FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);

                                if FAHistory.GetFilter("Entry No.") = '' then begin
                                    FAHistoryEntryCZF.SetRange("Entry No.", "Entry No.");
                                    if not FAHistoryEntryCZF.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if FAHistory.GetFilter("Entry No.") <> Format("Entry No.") then
                                        CurrReport.Break();
                            end else
                                CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetFilter("FA No.", FALocationFA."No.");
                            SetRange("Posting Date", 0D, EndDate);
                            FirstTime := true;
                            ShowFirstHead := false;
                            CheckCancel := false;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        FAHistoryEntryCZF.Reset();
                        FAHistoryEntryCZF.SetFilter("FA No.", "No.");
                        FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"FA Location");
                        if not FAHistoryEntryCZF.FindFirst() then
                            CurrReport.Skip();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if FAHistory.GetFilter("FA No.") <> '' then
                            FAHistory.CopyFilter("FA No.", "No.");

                        CountPerGroup := 0;
                        FixedAssetNo := '';
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    FAHistoryEntryCZF.Reset();
                    FAHistoryEntryCZF.SetFilter("New Value", Code);
                    FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"FA Location");
                    if not FAHistoryEntryCZF.FindFirst() then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    if GroupBy <> GroupBy::"FA Location" then
                        CurrReport.Break();

                    if FAHistory.GetFilter("New Value") <> '' then
                        FAHistory.CopyFilter("New Value", Code);

                    GroupCount := 0;

                    FAHistoryEntryCZF.Reset();
                    FAHistoryEntryCZF.CopyFilters(FAHistory);
                    FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"FA Location");
                    if FAHistory.GetFilter("Posting Date") = '' then
                        FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);
                end;
            }
            dataitem(Employee; Employee)
            {
                DataItemTableView = sorting("No.");
                PrintOnlyIfDetail = true;
                column(Employee_No; "No.")
                {
                }
                column(Employee_FullName; FullName())
                {
                }
                dataitem(ResponsibleEmployeeFA; "Fixed Asset")
                {
                    DataItemTableView = sorting("No.") order(descending);
                    PrintOnlyIfDetail = true;
                    dataitem(EmployeeFAHistory; "FA History Entry CZF")
                    {
                        DataItemTableView = sorting("FA No.", "Entry No.") order(descending) where(Type = const("Responsible Employee"));
                        column(ResponsibleEmployeeFAHistory_FANo; "FA No.")
                        {
                        }
                        column(ResponsibleEmployeeFAHistory_Description; Description)
                        {
                        }
                        column(ResponsibleEmployeeFAHistory_SerialNo; SerialNo)
                        {
                        }
                        column(ResponsibleEmployeeFAHistory_PostingDate; "Posting Date")
                        {
                        }
                        column(ResponsibleEmployeeFAHistory_UserID; "User ID")
                        {
                        }
                        column(PreviousEmployee; PreviousEmployee)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if FirstTime then begin
                                FAHistoryEntryCZF.Reset();
                                FAHistoryEntryCZF.CopyFilters(FAHistory);
                                FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"Responsible Employee");
                                if FAHistory.GetFilter("Posting Date") = '' then
                                    FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);
                                FAHistoryEntryCZF.SetRange("FA No.", ResponsibleEmployeeFA."No.");
                                ShowFirstHead := FindFirstFA(Employee."No.");

                                FirstTime := false;

                                if CountPerGroup = 0 then begin
                                    if not ShowFirstHead then
                                        CountPerGroup := 0
                                    else begin
                                        CountPerGroup += 1;
                                        GroupCount += 1;
                                    end;
                                end else
                                    CountPerGroup += 1;
                            end;

                            if Disposal then begin
                                if not CheckCancel then
                                    CurrReport.Break();
                                CurrReport.Skip();
                            end;
                            if "Closed by Entry No." <> 0 then begin
                                CheckCancel := true;
                                CurrReport.Skip();
                            end;

                            if "New Value" <> Employee."No." then
                                CurrReport.Break();

                            TestField("FA No.");
                            if FixedAsset3.Get("FA No.") then begin
                                Description := FixedAsset3.Description;
                                SerialNo := FixedAsset3."Serial No.";
                            end;

                            if FixedAssetNo <> "FA No." then begin
                                FixedAssetNo := "FA No.";
                                FAHistoryEntryCZF.Reset();
                                FAHistoryEntryCZF.CopyFilters(FAHistory);
                                if FAHistory.GetFilter("Posting Date") = '' then
                                    FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);

                                if FAHistory.GetFilter("Entry No.") = '' then begin
                                    FAHistoryEntryCZF.SetRange("Entry No.", "Entry No.");
                                    if not FAHistoryEntryCZF.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if FAHistory.GetFilter("Entry No.") <> Format("Entry No.") then
                                        CurrReport.Break();
                            end else
                                CurrReport.Break();

                            if "Old Value" <> '' then begin
                                OldEmployee.Get("Old Value");
                                PreviousEmployee := "Old Value" + ' ' + OldEmployee.FullName();
                            end else
                                PreviousEmployee := '';
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetFilter("FA No.", ResponsibleEmployeeFA."No.");
                            SetRange("Posting Date", 0D, EndDate);

                            FirstTime := true;
                            ShowFirstHead := false;
                            CheckCancel := false;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        FAHistoryEntryCZF.Reset();
                        FAHistoryEntryCZF.SetFilter("FA No.", "No.");
                        FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"Responsible Employee");
                        if not FAHistoryEntryCZF.FindFirst() then
                            CurrReport.Skip();
                    end;

                    trigger OnPreDataItem()
                    begin
                        if FAHistory.GetFilter("FA No.") <> '' then
                            FAHistory.CopyFilter("FA No.", "No.");

                        CountPerGroup := 0;
                        FixedAssetNo := '';
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    FAHistoryEntryCZF.Reset();
                    FAHistoryEntryCZF.SetFilter("New Value", "No.");
                    FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"Responsible Employee");
                    if not FAHistoryEntryCZF.FindFirst() then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    if GroupBy <> GroupBy::"Responsible Employee" then
                        CurrReport.Break();

                    if FAHistory.GetFilter("New Value") <> '' then
                        FAHistory.CopyFilter("New Value", "No.");

                    GroupCount := 0;

                    FAHistoryEntryCZF.Reset();
                    FAHistoryEntryCZF.CopyFilters(FAHistory);
                    FAHistoryEntryCZF.SetRange(Type, FAHistoryEntryCZF.Type::"Responsible Employee");
                    if FAHistory.GetFilter("Posting Date") = '' then
                        FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);
                end;
            }
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
                    field(GroupByCZF; GroupBy)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Group By';
                        ToolTip = 'Specifies how fixed assets should be grouped.';

                        trigger OnValidate()
                        begin
                            CheckMarkEnable := GroupBy <> GroupBy::" ";
                        end;
                    }
                    field(NewPagePerGroupCZF; NewPagePerGroup)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'New Page Per Group';
                        Enabled = CheckMarkEnable;
                        ToolTip = 'Specifies if you want the report to print a new page for each group.';
                    }
                    field(EndDateCZF; EndDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'As of Date';
                        ToolTip = 'Specifies the date that the history will be based on in MMDDYY format.';
                    }
                }
            }
        }

        trigger OnInit()
        begin
            CheckMarkEnable := true;
        end;

        trigger OnOpenPage()
        begin
            if EndDate = 0D then
                EndDate := WorkDate();
            CheckMarkEnable := GroupBy <> GroupBy::" ";
        end;
    }

    labels
    {
        FAHistoryLbl = 'FA History';
        GroupByLbl = 'Group by';
        PageLbl = 'Page';
        NameLbl = 'Name';
        CodeLbl = 'Code';
        NoLbl = 'No.';
        DescriptionLbl = 'Description';
        SerialNoLbl = 'Serial No.';
        OldLocationLbl = 'Old Location';
        PreviousEmployeeLbl = 'Previous Employee';
        ChangeDateLbl = 'Change Date';
        FullNameLbl = 'Full Name';
    }

    var
        FixedAsset3: Record "Fixed Asset";
        FAHistoryEntryCZF: Record "FA History Entry CZF";
        OldEmployee: Record Employee;
        GroupBy: Enum "FA History Type CZF";
        EndDate: Date;
        FixedAssetNo: Code[20];
        Description, SerialNo : Text;
        NewPagePerGroup, FirstTime, ShowFirstHead, CheckCancel : Boolean;
        GroupCount, CountPerGroup : Integer;
        PreviousEmployee: Text;
        CheckMarkEnable: Boolean;
        AtDateLbl: Label 'As of %1', Comment = '%1 = Date';

    local procedure FindFA(FANo: Code[20]; FAType: Enum "FA History Type CZF"; No: Code[20]; EntryNo: Integer) OK: Boolean
    var
        DisposalCancelled: Boolean;
    begin
        FAHistoryEntryCZF.Reset();
        OK := false;
        DisposalCancelled := false;
        FAHistoryEntryCZF.SetCurrentKey("FA No.", Type, "Posting Date");
        FAHistoryEntryCZF.SetRange("FA No.", FANo);
        FAHistoryEntryCZF.SetRange(Type, FAType);
        FAHistoryEntryCZF.SetRange("Posting Date", 0D, EndDate);
        if FAHistoryEntryCZF.FindLast() then
            repeat
                if FAHistoryEntryCZF.Disposal then begin
                    if not DisposalCancelled then
                        exit;
                end else
                    DisposalCancelled := (FAHistoryEntryCZF."Closed by Entry No." <> 0);
                if not DisposalCancelled and
                   (FAHistoryEntryCZF."New Value" = No) and
                   (FAHistoryEntryCZF."Entry No." = EntryNo) and
                   (FAHistoryEntryCZF."New Value" <> '')
                then begin
                    OK := true;
                    exit;
                end;
                if not DisposalCancelled then
                    exit;
            until FAHistoryEntryCZF.Next(-1) = 0;
    end;

    procedure FindFirstFA(TypeCode: Code[20]) Found: Boolean
    var
        FAHistoryEntryCZF2: Record "FA History Entry CZF";
    begin
        FAHistoryEntryCZF2.CopyFilters(FAHistoryEntryCZF);
        Found := false;
        if FAHistoryEntryCZF2.FindSet() then
            repeat
                Found := FindFA(FAHistoryEntryCZF2."FA No.", FAHistoryEntryCZF2.Type, TypeCode, FAHistoryEntryCZF2."Entry No.");
            until Found or (FAHistoryEntryCZF2.Next() = 0);
    end;
}
