namespace Microsoft.Finance.Analysis.StatisticalAccount;

using System.Environment.Configuration;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;
using Microsoft.Finance.AllocationAccount;

codeunit 2625 "Stat. Acc. Demo Data"
{
    trigger OnRun()
    begin
        if not CanSetupDemoData() then
            exit;

        InsertDemoData();
    end;

    internal procedure ShowSetupNotification()
    var
        StatisticalAccount: Record "Statistical Account";
        MyNotifications: Record "My Notifications";
        SetupNotification: Notification;
        ShowSetupNotificationGuid: Guid;
    begin
        if not CanSetupDemoData() then
            exit;

        if not StatisticalAccount.IsEmpty() then
            exit;

        ShowSetupNotificationGuid := 'e00eaa38-a8b2-44c7-b332-1319f2082b96';
        if not MyNotifications.IsEnabled(ShowSetupNotificationGuid) then
            exit;

        SetupNotification.Id := ShowSetupNotificationGuid;
        SetupNotification.Recall();
        SetupNotification.Message(ShowSetupNotificationTxt);
        SetupNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        SetupNotification.AddAction(SetupDemoDataTxt, Codeunit::"Stat. Acc. Demo Data", 'InsertDemoDataNotification');
        SetupNotification.Send();
    end;

    internal procedure CleanupDemoData()
    var
        StatisticalAccount: Record "Statistical Account";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        FinancialReport: Record "Financial Report";
        AllocationAccount: Record "Allocation Account";
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        RevenuePerEmpAccScheduleLine: Record "Acc. Schedule Line";
    begin
        if not CanSetupDemoData() then
            Error(CompanyMustBeDemoCompanyErr);

        if not Confirm(CleanupDemoDataQst) then
            exit;

        StatisticalAccount.DeleteAll(false);
        StatisticalLedgerEntry.DeleteAll(false);
        StatisticalAccJournalLine.DeleteAll(false);

        if AllocationAccount.Get(OfficeSpaceAllocationAccountNoLbl) then
            AllocationAccount.Delete(true);

        AllocAccountDistribution.SetRange("Allocation Account No.", OfficeSpaceAllocationAccountNoLbl);
        AllocAccountDistribution.DeleteAll();

        if AllocationAccount.Get(EmployeesAllocationAccountNoLbl) then
            AllocationAccount.Delete(true);

        AllocAccountDistribution.SetRange("Allocation Account No.", EmployeesAllocationAccountNoLbl);
        AllocAccountDistribution.DeleteAll();

        if FinancialReport.Get(RevenuePerEmployeeNameLbl) then
            FinancialReport.Delete(true);

        RevenuePerEmpAccScheduleLine.SetRange("Schedule Name", RevenuePerEmployeeNameLbl);
        RevenuePerEmpAccScheduleLine.DeleteAll();
    end;

    internal procedure InsertDemoDataNotification(HostNotification: Notification)
    begin
        InsertDemoData();
    end;

    internal procedure InsertDemoData()
    begin
        InsertBasicDemoData();
        Commit();
        InsertAllocationAccounts();
        Commit();
        CreateOrReplaceFinancialReport();
        Message(DemoDataSetupCompleteMsg);
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    local procedure InsertBasicDemoData()
    begin
        InsertStatisticalAccounts();
        InsertStatisticalAccountData();
    end;

    local procedure InsertStatisticalAccounts()
    var
        StatisticalAccount: Record "Statistical Account";
    begin
        if not StatisticalAccount.Get(EmployeesLbl) then begin
            StatisticalAccount."No." := EmployeesLbl;
            StatisticalAccount.Name := EmployeesNameLbl;
            StatisticalAccount.Insert();
        end;

        if not StatisticalAccount.Get(OfficeSpaceLbl) then begin
            StatisticalAccount."No." := OfficeSpaceLbl;
            StatisticalAccount.Name := OfficeSpaceNameLbl;
            StatisticalAccount.Insert();
        end;
    end;

    local procedure InsertAllocationAccounts()
    var
        AllocationAccount: Record "Allocation Account";
        StatisticalAccount: Record "Statistical Account";
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Dimension Code", OfficeDimensionCodeLbl);
        if not DimensionValue.FindSet() then
            exit;

        if DimensionValue."Global Dimension No." = 0 then
            exit;

        if StatisticalAccount.Get(OfficeSpaceLbl) then
            if not AllocationAccount.Get(OfficeSpaceAllocationAccountNoLbl) then begin
                AllocationAccount."No." := OfficeSpaceAllocationAccountNoLbl;
                AllocationAccount.Name := OfficeSpaceAllocationAccountNameLbl;
                AllocationAccount."Account Type" := AllocationAccount."Account Type"::Variable;
                InsertAllocationAccountDepartmentLines(DimensionValue, AllocationAccount, StatisticalAccount);
                AllocationAccount.Insert();
            end;


        if StatisticalAccount.Get(EmployeesLbl) then
            if not AllocationAccount.Get(EmployeesAllocationAccountNoLbl) then begin
                DimensionValue.FindSet();
                AllocationAccount."No." := EmployeesAllocationAccountNoLbl;
                AllocationAccount.Name := EmployeesAllocationAccountNameLbl;
                AllocationAccount."Account Type" := AllocationAccount."Account Type"::Variable;
                InsertAllocationAccountDepartmentLines(DimensionValue, AllocationAccount, StatisticalAccount);
                AllocationAccount.Insert();
            end;
    end;

    local procedure InsertAllocationAccountDepartmentLines(var DimensionValue: Record "Dimension Value"; var AllocationAccount: Record "Allocation Account"; var StatisticalAccount: Record "Statistical Account")
    var
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        CurrentLineNo: Integer;
    begin
        CurrentLineNo := 0;
        repeat
            CurrentLineNo += 10000;
            Clear(AllocAccountDistribution);
            AllocAccountDistribution."Allocation Account No." := AllocationAccount."No.";
            AllocAccountDistribution."Line No." := CurrentLineNo;
            AllocAccountDistribution."Account Type" := AllocAccountDistribution."Account Type"::Variable;
            AllocAccountDistribution."Destination Account Type" := AllocAccountDistribution."Destination Account Type"::"Inherit from Parent";
            AllocAccountDistribution."Breakdown Account Type" := AllocAccountDistribution."Breakdown Account Type"::"Statistical Account";
            AllocAccountDistribution."Breakdown Account Number" := StatisticalAccount."No.";
            SetDimensionFilter(AllocAccountDistribution, DimensionValue);
            AllocAccountDistribution."Dimension Set ID" := GetDimensionSetID(DimensionValue);
            AllocAccountDistribution.Insert();
        until DimensionValue.Next() = 0;
    end;

    local procedure SetDimensionFilter(var AllocAccountDistribution: Record "Alloc. Account Distribution"; var DimensionValue: Record "Dimension Value")
    begin
        case DimensionValue."Global Dimension No." of
            1:
                AllocAccountDistribution."Dimension 1 Filter" := DimensionValue.Code;
            2:
                AllocAccountDistribution."Dimension 2 Filter" := DimensionValue.Code;
            3:
                AllocAccountDistribution."Dimension 3 Filter" := DimensionValue.Code;
            4:
                AllocAccountDistribution."Dimension 4 Filter" := DimensionValue.Code;
            5:
                AllocAccountDistribution."Dimension 5 Filter" := DimensionValue.Code;
            6:
                AllocAccountDistribution."Dimension 6 Filter" := DimensionValue.Code;
            7:
                AllocAccountDistribution."Dimension 7 Filter" := DimensionValue.Code;
            8:
                AllocAccountDistribution."Dimension 8 Filter" := DimensionValue.Code;
        end;
    end;

    local procedure InsertStatisticalAccountData()
    begin
        InsertEmployeeLedgerEntryData();
        InsertOfficeSpaceLedgerEntriesDemoData();
    end;

    local procedure InsertEmployeeLedgerEntryData()
    var
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        DimensionValue: Record "Dimension Value";
        FirstDimensionValue: Record "Dimension Value";
        SecondDimensionValue: Record "Dimension Value";
        ThirdDimensionValue: Record "Dimension Value";
        StatAccPostBatch: Codeunit "Stat. Acc. Post. Batch";
        DefaultJournalBatchName: Code[10];
        CurrentDate: Date;
        FirstDimensionSetID: Integer;
        SecondDimensionSetID: Integer;
        ThirdDimensionSetID: Integer;
        LineNo: Integer;
    begin
        DimensionValue.SetRange("Dimension Code", OfficeDimensionCodeLbl);
        if not DimensionValue.FindSet() then
            exit;

        FirstDimensionValue := DimensionValue;
        FirstDimensionSetID := GetDimensionSetID(DimensionValue);

        if DimensionValue.Next() <> 0 then begin
            SecondDimensionValue := DimensionValue;
            SecondDimensionSetID := GetDimensionSetID(DimensionValue)
        end;

        if DimensionValue.Next() <> 0 then begin
            DimensionValue.Next();
            ThirdDimensionValue := DimensionValue;
            ThirdDimensionSetID := GetDimensionSetID(DimensionValue)
        end;
        CurrentDate := WorkDate();

        // Create initial counts
        DefaultJournalBatchName := '';
        StatisticalAccJournalLine.SelectJournal(DefaultJournalBatchName);
        LineNo += 10000;
        StatisticalAccJournalLine."Posting Date" := CalcDate('<-119D>', CurrentDate);
        StatisticalAccJournalLine."Journal Batch Name" := DefaultJournalBatchName;
        StatisticalAccJournalLine."Line No." := LineNo;
        StatisticalAccJournalLine.Amount := 30;
        StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
        StatisticalAccJournalLine.Description := StrSubstNo(EmployeesInitialCountLbl, FirstDimensionValue.Code);
        StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
        StatisticalAccJournalLine.Insert();

        if SecondDimensionValue.Code <> FirstDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-92D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 10;
            StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(EmployeesInitialCountLbl, SecondDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", SecondDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        if SecondDimensionValue.Code <> ThirdDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-58D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 23;
            StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(EmployeesInitialCountLbl, ThirdDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", ThirdDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        if SecondDimensionValue.Code <> FirstDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-33D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 4;
            StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(EmployeesHiredLbl, SecondDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", SecondDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        LineNo += 10000;
        StatisticalAccJournalLine."Posting Date" := CalcDate('<-15D>', CurrentDate);
        StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
        StatisticalAccJournalLine."Line No." := LineNo;
        StatisticalAccJournalLine.Amount := 14;
        StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
        StatisticalAccJournalLine.Description := StrSubstNo(EmployeesHiredLbl, FirstDimensionValue.Code);
        StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
        StatisticalAccJournalLine.Insert();

        LineNo += 10000;
        StatisticalAccJournalLine."Posting Date" := CalcDate('<-1D>', CurrentDate);
        StatisticalAccJournalLine."Journal Batch Name" := DefaultJournalBatchName;
        StatisticalAccJournalLine."Line No." := LineNo;
        StatisticalAccJournalLine.Amount := -11;
        StatisticalAccJournalLine."Statistical Account No." := EmployeesLbl;
        StatisticalAccJournalLine.Description := StrSubstNo(EmployeesReductionLbl, FirstDimensionValue.Code);
        StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
        StatisticalAccJournalLine.Insert();

        // Post lines
        StatisticalAccJournalBatch.Get('', StatisticalAccJournalLine."Journal Batch Name");
        StatAccPostBatch.SetDoNotShowUI(true);
        StatisticalAccJournalLine.Reset();

        StatisticalAccJournalLine.SetRange("Journal Batch Name", DefaultJournalBatchName);
        StatAccPostBatch.Run(StatisticalAccJournalLine);
    end;

    local procedure InsertOfficeSpaceLedgerEntriesDemoData()
    var
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        DimensionValue: Record "Dimension Value";
        FirstDimensionValue: Record "Dimension Value";
        SecondDimensionValue: Record "Dimension Value";
        ThirdDimensionValue: Record "Dimension Value";
        StatAccPostBatch: Codeunit "Stat. Acc. Post. Batch";
        DefaultJournalBatchName: Code[10];
        FirstDimensionSetID: Integer;
        SecondDimensionSetID: Integer;
        ThirdDimensionSetID: Integer;
        LineNo: Integer;
        CurrentDate: Date;
    begin
        CurrentDate := WorkDate();

        DimensionValue.SetRange("Dimension Code", OfficeDimensionCodeLbl);
        if not DimensionValue.FindSet() then
            exit;

        FirstDimensionValue := DimensionValue;
        FirstDimensionSetID := GetDimensionSetID(DimensionValue);

        if DimensionValue.Next() <> 0 then begin
            SecondDimensionValue := DimensionValue;
            SecondDimensionSetID := GetDimensionSetID(DimensionValue)
        end;

        if DimensionValue.Next() <> 0 then begin
            DimensionValue.Next();
            ThirdDimensionValue := DimensionValue;
            ThirdDimensionSetID := GetDimensionSetID(DimensionValue)
        end;

        // Create ledger entries
        DefaultJournalBatchName := '';
        StatisticalAccJournalLine.SelectJournal(DefaultJournalBatchName);
        LineNo += 10000;
        StatisticalAccJournalLine."Posting Date" := CalcDate('<-95D>', CurrentDate);
        StatisticalAccJournalLine."Journal Batch Name" := DefaultJournalBatchName;
        StatisticalAccJournalLine."Line No." := LineNo;
        StatisticalAccJournalLine.Amount := 450;
        StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
        StatisticalAccJournalLine.Description := StrSubstNo(OfficesMainBuildingLbl, FirstDimensionValue.Code);
        StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
        StatisticalAccJournalLine.Insert();

        if SecondDimensionValue.Code <> FirstDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-66D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 380;
            StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(OfficesMainBuildingLbl, SecondDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", SecondDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        if SecondDimensionValue.Code <> ThirdDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-45D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 1440;
            StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(OfficesMainBuildingLbl, ThirdDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", ThirdDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        if SecondDimensionValue.Code <> FirstDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-23D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 130;
            StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(OfficesExpansionLbl, SecondDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", SecondDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        LineNo += 10000;
        StatisticalAccJournalLine."Posting Date" := CalcDate('<-17D>', CurrentDate);
        StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
        StatisticalAccJournalLine."Line No." := LineNo;
        StatisticalAccJournalLine.Amount := 420;
        StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
        StatisticalAccJournalLine.Description := StrSubstNo(OfficesExpansionLbl, FirstDimensionValue.Code);
        StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
        StatisticalAccJournalLine.Insert();

        if SecondDimensionValue.Code <> FirstDimensionValue.Code then begin
            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-7D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := 40;
            StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(OfficesClosedAddedToLbl, SecondDimensionValue.Code, FirstDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", SecondDimensionSetID);
            StatisticalAccJournalLine.Insert();

            LineNo += 10000;
            StatisticalAccJournalLine."Posting Date" := CalcDate('<-7D>', CurrentDate);
            StatisticalAccJournalLine."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
            StatisticalAccJournalLine."Line No." := LineNo;
            StatisticalAccJournalLine.Amount := -40;
            StatisticalAccJournalLine."Statistical Account No." := OfficeSpaceLbl;
            StatisticalAccJournalLine.Description := StrSubstNo(OfficesClosedAddedToLbl, SecondDimensionValue.Code, FirstDimensionValue.Code);
            StatisticalAccJournalLine.Validate("Dimension Set ID", FirstDimensionSetID);
            StatisticalAccJournalLine.Insert();
        end;

        // Post lines
        StatisticalAccJournalBatch.Get('', StatisticalAccJournalLine."Journal Batch Name");
        StatAccPostBatch.SetDoNotShowUI(true);
        StatisticalAccJournalLine.Reset();

        StatisticalAccJournalLine.SetRange("Journal Batch Name", DefaultJournalBatchName);
        StatAccPostBatch.Run(StatisticalAccJournalLine);
    end;

    local procedure GetDimensionSetID(DimensionValue: Record "Dimension Value"): Integer
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        TempDimensionSetEntry."Dimension Code" := DimensionValue."Dimension Code";
        TempDimensionSetEntry."Dimension Value Code" := DimensionValue.Code;
        TempDimensionSetEntry."Dimension Value ID" := DimensionValue."Dimension Value ID";
        TempDimensionSetEntry.Insert();
        exit(DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
    end;

    internal procedure CanSetupDemoData(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit(false);

        exit(CompanyInformation."Demo Company");
    end;

    local procedure CreateOrReplaceFinancialReport()
    var
        FinancialReport: Record "Financial Report";
        AccScheduleLine: Record "Acc. Schedule Line";
        RevenuePerEmpAccScheduleName: Record "Acc. Schedule Name";
        RevenuePerEmpAccScheduleLine: Record "Acc. Schedule Line";
        RevenuePerEmpFinancialReport: Record "Financial Report";
        LastRowCopied: Boolean;
    begin
        if not FinancialReport.Get(RevenueNameLbl) then
            exit;

        if RevenuePerEmpFinancialReport.Get(RevenuePerEmployeeNameLbl) then
            RevenuePerEmpFinancialReport.Delete();

        RevenuePerEmpFinancialReport.TransferFields(FinancialReport);
        RevenuePerEmpFinancialReport.Name := RevenuePerEmployeeNameLbl;
        RevenuePerEmpFinancialReport.Description := RevenuePerEmployeeDescriptionLbl;
        RevenuePerEmpFinancialReport.Insert();

        RevenuePerEmpAccScheduleLine.SetRange("Schedule Name", RevenuePerEmployeeNameLbl);
        RevenuePerEmpAccScheduleLine.DeleteAll();

        if RevenuePerEmpAccScheduleName.Get(RevenuePerEmployeeNameLbl) then
            RevenuePerEmpAccScheduleName.Delete();

        RevenuePerEmpAccScheduleName.Name := RevenuePerEmployeeNameLbl;
        RevenuePerEmpAccScheduleName.Description := RevenuePerEmployeeDescriptionLbl;
        RevenuePerEmpAccScheduleName."Analysis View Name" := '';
        RevenuePerEmpAccScheduleName.Insert();

        AccScheduleLine.SetRange("Schedule Name", RevenueNameLbl);
        AccScheduleLine.FindSet();
        repeat
            RevenuePerEmpAccScheduleLine.TransferFields(AccScheduleLine, true);
            RevenuePerEmpAccScheduleLine."Schedule Name" := RevenuePerEmployeeNameLbl;
            RevenuePerEmpAccScheduleLine.Insert();
            LastRowCopied := AccScheduleLine."Row No." = '15';
        until (AccScheduleLine.Next() = 0) or LastRowCopied;

        InsertBlankAccScheduleLine(RevenuePerEmpAccScheduleLine);
        RevenuePerEmpAccScheduleLine.Init();
        RevenuePerEmpAccScheduleLine."Line No." += 10000;
        RevenuePerEmpAccScheduleLine."Totaling Type" := RevenuePerEmpAccScheduleLine."Totaling Type"::"Statistical Account";
        RevenuePerEmpAccScheduleLine.Totaling := EmployeesLbl;
        RevenuePerEmpAccScheduleLine."Row No." := '20';
        RevenuePerEmpAccScheduleLine.Description := NumberOfEmployeesLbl;
        RevenuePerEmpAccScheduleLine."Row Type" := RevenuePerEmpAccScheduleLine."Row Type"::"Balance at Date";
        RevenuePerEmpAccScheduleLine.Bold := true;
        RevenuePerEmpAccScheduleLine.Insert();

        InsertBlankAccScheduleLine(RevenuePerEmpAccScheduleLine);
        RevenuePerEmpAccScheduleLine.Init();
        RevenuePerEmpAccScheduleLine."Line No." += 10000;
        RevenuePerEmpAccScheduleLine."Totaling Type" := RevenuePerEmpAccScheduleLine."Totaling Type"::"Formula";
        RevenuePerEmpAccScheduleLine.Totaling := '15/20';
        RevenuePerEmpAccScheduleLine.Description := RevenuePerEmployeeDescriptionLbl;
        RevenuePerEmpAccScheduleLine.Bold := true;
        RevenuePerEmpAccScheduleLine."Show Opposite Sign" := true;
        RevenuePerEmpAccScheduleLine.Insert();

        RevenuePerEmpFinancialReport.Find();
        RevenuePerEmpFinancialReport."Financial Report Row Group" := RevenuePerEmpAccScheduleName.Name;
        RevenuePerEmpFinancialReport."Financial Report Column Group" := PeriodsLbl;
        RevenuePerEmpFinancialReport.Modify();
    end;

    local procedure InsertBlankAccScheduleLine(var AccScheduleLine: Record "Acc. Schedule Line")
    begin
        AccScheduleLine.Init();
        AccScheduleLine."Line No." += 10000;
        AccScheduleLine.Insert();
    end;

    var

        OfficeDimensionCodeLbl: Label 'DEPARTMENT';
        EmployeesLbl: Label 'EMPLOYEES';
        EmployeesNameLbl: Label 'Number of Employees';
        OfficeSpaceLbl: Label 'OFFICESPACE';
        OfficeSpaceNameLbl: Label 'Office/prod space in m2';
        OfficesMainBuildingLbl: Label 'Main building offices - %1.', Comment = '%1 the value of the dimension, e.g. PROD, ADM...';
        OfficesExpansionLbl: Label 'Expansion of %1.', Comment = '%1 the value of the dimension, e.g. PROD, ADM...';
        OfficesClosedAddedToLbl: Label 'Closed of %1, added to %2.', Comment = '%1 and %2 the value of the dimension, e.g. PROD, ADM...';
        CompanyMustBeDemoCompanyErr: Label 'To delete the data you must be in a company that has Demo Company set in the Company Information table.';
        DemoDataSetupCompleteMsg: Label 'The setup was completed successfully.';
        EmployeesInitialCountLbl: Label 'Initial headcount of %1.', Comment = '%1 the value of the dimension, e.g. PROD, ADM...';
        EmployeesHiredLbl: Label 'Hired for %1.', Comment = '%1 the value of the dimension, e.g. PROD, ADM...';
        EmployeesReductionLbl: Label 'Headcount reduction for %1.', Comment = '%1 the value of the dimension, e.g. PROD, ADM...';
        CleanupDemoDataQst: Label 'This action will delete all setup data. Do you want to continue?';
        ShowSetupNotificationTxt: Label 'There is no demonstrational data available. Would you like to create the demonstrational data?';
        SetupDemoDataTxt: Label 'Create demonstrational data.';
        RevenueNameLbl: Label 'REVENUE';
        RevenuePerEmployeeNameLbl: Label 'REV_EMPL';
        RevenuePerEmployeeDescriptionLbl: Label 'Revenue per Employee';
        NumberOfEmployeesLbl: Label 'Number of Employees';
        OfficeSpaceAllocationAccountNoLbl: Label 'OFFICE SPACE DEP';
        OfficeSpaceAllocationAccountNameLbl: Label 'Distribute the cost per department office space';
        EmployeesAllocationAccountNoLbl: Label 'EMPL HEADCOUNT DEP';
        EmployeesAllocationAccountNameLbl: Label 'Distribute cost per department employee headcount';
        PeriodsLbl: Label 'PERIODS';
}