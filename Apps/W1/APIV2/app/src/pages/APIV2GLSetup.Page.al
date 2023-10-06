namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Setup;

page 30087 "APIV2 - G/L Setup"
{
    APIVersion = 'v2.0';
    EntityCaption = 'General Ledger Setup';
    EntitySetCaption = 'General Ledger Setup';
    EntityName = 'generalLedgerSetup';
    EntitySetName = 'generalLedgerSetup';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    PageType = API;
    SourceTable = "General Ledger Setup";
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            field(id; Rec.SystemId)
            {
                Caption = 'Id';
            }
            field(allowPostingFrom; Rec."Allow Posting From")
            {
                Caption = 'Allow Posting From';
            }
            field(allowPostingTo; Rec."Allow Posting To")
            {
                Caption = 'Allow Posting To';
            }
            field(additionalReportingCurrency; Rec."Additional Reporting Currency")
            {
                Caption = 'Additional Reporting Currency';
            }
            field(localCurrencyCode; Rec."LCY Code")
            {
                Caption = 'Local Currency Code';
            }
            field(localCurrencySymbol; Rec."Local Currency Symbol")
            {
                Caption = 'Local Currency Symbol';
            }
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                Caption = 'Last Modified Date';
            }
            field(allowQueryFromConsolidation; Rec."Allow Query From Consolid.")
            {
                Caption = 'Allow Query From Consolidation';
            }
        }
    }
}