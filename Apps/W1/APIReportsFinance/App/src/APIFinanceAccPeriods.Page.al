namespace Microsoft.API.FinancialManagement;

using Microsoft.Foundation.Period;

page 30300 "API Finance - Acc Periods"
{
    PageType = API;
    EntityCaption = 'Accounting Periods';
    EntityName = 'accountingPeriod';
    EntitySetName = 'accountingPeriods';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Accounting Period";
    ODataKeyFields = SystemId;
    SourceTableView = sorting("Starting Date");

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(endingDate; EndingDate)
                {
                    Caption = 'Ending Date';
                }
                field(newFiscalYear; Rec."New Fiscal Year")
                {
                    Caption = 'New Fiscal Year';
                }
                field(fiscalYearStartDate; FiscalYearStartDate)
                {
                    Caption = 'Fiscal Year Start Date';
                }
                field(fiscalYearEndDate; FiscalYearEndDate)
                {
                    Caption = 'Fiscal Year End Date';
                }
                field(closed; Rec.Closed)
                {
                    Caption = 'Closed';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        FiscalYearStartDate := Rec.GetFiscalYearStartDate(Rec."Starting Date");
        FiscalYearEndDate := Rec.GetFiscalYearEndDate(Rec."Starting Date");
        AccountingPeriod.SetLoadFields("Starting Date");
        AccountingPeriod.GetBySystemId(Rec.SystemId);
        if AccountingPeriod.Next() <> 0 then
            EndingDate := CalcDate('<-1D>', AccountingPeriod."Starting Date")
        else
            EndingDate := FiscalYearEndDate;
    end;

    var
        FiscalYearStartDate: Date;
        FiscalYearEndDate: Date;
        EndingDate: Date;
}
