namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.Consolidation;

page 30301 "API Finance - Business Unit"
{
    PageType = API;
    EntityCaption = 'Business Unit';
    EntityName = 'businessUnit';
    EntitySetName = 'businessUnits';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Business Unit";
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemID)
                {
                    Caption = 'Id';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Company Name';
                }
                field(consolidate; Rec.Consolidate)
                {
                    Caption = 'Consolidate';
                }
                field(consolidationPercentage; Rec."Consolidation %")
                {
                    Caption = 'Consolidation %';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
                field(lastRun; Rec."Last Run")
                {
                    Caption = 'Last Run';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
                part(generalLedgerAccount; "API Finance - GL Account")
                {
                    Caption = 'GL Accounts';
                    Multiplicity = Many;
                    EntityName = 'generalLedgerAccount';
                    EntitySetName = 'generalLedgerAccounts';
                    SubPageLink = "Business Unit Filter" = field(Code);
                }
            }
        }
    }
}