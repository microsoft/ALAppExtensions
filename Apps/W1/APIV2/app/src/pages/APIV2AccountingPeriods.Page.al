namespace Microsoft.API.V2;

using Microsoft.Foundation.Period;

page 30086 "APIV2 - Accounting Periods"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Accounting Period';
    EntitySetCaption = 'Accounting Periods';
    EntityName = 'accountingPeriod';
    EntitySetName = 'accountingPeriods';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    PageType = API;
    SourceTable = "Accounting Period";
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;
    AboutText = 'Exposes read-only accounting period data including starting dates, period names, fiscal year status, closure indicators, date locks, and average cost calculation settings. Enables external systems to retrieve and synchronize fiscal calendar definitions for reporting automation, consolidation, and period-end processing. Supports GET operations only, ensuring accurate alignment of financial periods across integrated platforms without permitting direct creation, modification, or deletion of records.';

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
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(newFiscalYear; Rec."New Fiscal Year")
                {
                    Caption = 'New Fiscal Year';
                }
                field(closed; Rec.Closed)
                {
                    Caption = 'Closed';
                }
                field(dateLocked; Rec."Date Locked")
                {
                    Caption = 'Date Locked';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }
}