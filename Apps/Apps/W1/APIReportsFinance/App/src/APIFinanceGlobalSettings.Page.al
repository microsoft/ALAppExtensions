namespace Microsoft.API.FinancialManagement;

using System.Environment;
using Microsoft.Finance.GeneralLedger.Setup;

page 30306 "API Finance - Global Settings"
{
    PageType = API;
    EntityCaption = 'Global Settings';
    EntityName = 'globalSettings';
    EntitySetName = 'globalSettings';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(company; Company.SystemId)
                {
                    Caption = 'id';
                }

                field(companyName; Company.Name)
                {
                    Caption = 'Company Name';
                }
                field(additionalReportingCurrency; GeneralLedgerSetup."Additional Reporting Currency")
                {
                    Caption = 'Additional Reporting Currency';
                }
                field(localCurrencyCode; GeneralLedgerSetup."LCY Code")
                {
                    Caption = 'Local Currency Code';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Company.Get();
        GeneralLedgerSetup.Get();
    end;

    var
        Company: Record Company;
        GeneralLedgerSetup: Record "General Ledger Setup";
}