// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.HumanResources.Payables;

using Microsoft.Bank.Setup;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.ReceivablesPayables;

tableextension 11790 "Employee Ledger Entry CZL" extends "Employee Ledger Entry"
{
    fields
    {
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
    }

    procedure CollectSuggestedApplicationCZL(var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CrossApplicationBufferCZL));
    end;

    procedure CollectSuggestedApplicationCZL(CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CalledFrom, CrossApplicationBufferCZL));
    end;

    procedure CalcSuggestedAmountToApplyCZL(): Decimal
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CalcSuggestedAmountToApply(Rec));
    end;

    procedure DrillDownSuggestedAmountToApplyCZL()
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        CrossApplicationMgtCZL.DrillDownSuggestedAmountToApply(Rec);
    end;

    procedure GetPayablesAccNoCZL(): Code[20]
    var
        EmployeePostingGroup: Record "Employee Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetPayablesAccountNoCZL(Rec, GLAccountNo, IsHandled);
        if IsHandled then
            exit(GLAccountNo);

        TestField("Employee Posting Group");
        EmployeePostingGroup.Get("Employee Posting Group");
        EmployeePostingGroup.TestField("Payables Account");
        exit(EmployeePostingGroup.GetPayablesAccount());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPayablesAccountNoCZL(EmployeeLedgerEntry: Record "Employee Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
