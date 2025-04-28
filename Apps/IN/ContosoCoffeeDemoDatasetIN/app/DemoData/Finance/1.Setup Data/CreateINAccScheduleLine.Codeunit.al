// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.FinancialReports;

codeunit 19005 "Create IN Acc. Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Name", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleName(var Rec: Record "Acc. Schedule Name")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        case Rec.Name of
            CreateAccountScheduleName.BalanceSheetSummarized():
                Rec.Validate(Description, BalanceSheetSummarisedLbl);
            CreateAccountScheduleName.IncomeStatementSummarized():
                Rec.Validate(Description, IncomeStatementSummarisedLbl);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        if (Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance()) and (Rec."Line No." = 90000) then
            Rec.Validate(Description, IncomeBeforeInterestAndVATLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Financial Report", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFinancialReport(var Rec: Record "Financial Report")
    var
        CreateFinancialReport: Codeunit "Create Financial Report";
    begin
        case Rec.Name of
            CreateFinancialReport.BalanceSheetSummarized():
                Rec.Validate(Description, BalanceSheetSummarisedLbl);
            CreateFinancialReport.IncomeStatementSummarized():
                Rec.Validate(Description, IncomeStatementSummarisedLbl);
        end;
    end;

    var
        IncomeBeforeInterestAndVATLbl: Label 'Income before Interest and VAT', MaxLength = 100;
        BalanceSheetSummarisedLbl: Label 'Balance Sheet Summarised', MaxLength = 80;
        IncomeStatementSummarisedLbl: Label 'Income Statement Summarised', MaxLength = 80;
}
