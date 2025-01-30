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
            field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
            {
                Caption = 'Shortcut Dimension 1 Code';
            }
            field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
            {
                Caption = 'Shortcut Dimension 2 Code';
            }
            field(shortcutDimension3Code; Rec."Shortcut Dimension 3 Code")
            {
                Caption = 'Shortcut Dimension 3 Code';
            }
            field(shortcutDimension4Code; Rec."Shortcut Dimension 4 Code")
            {
                Caption = 'Shortcut Dimension 4 Code';
            }
            field(shortcutDimension5Code; Rec."Shortcut Dimension 5 Code")
            {
                Caption = 'Shortcut Dimension 5 Code';
            }
            field(shortcutDimension6Code; Rec."Shortcut Dimension 6 Code")
            {
                Caption = 'Shortcut Dimension 6 Code';
            }
            field(shortcutDimension7Code; Rec."Shortcut Dimension 7 Code")
            {
                Caption = 'Shortcut Dimension 7 Code';
            }
            field(shortcutDimension8Code; Rec."Shortcut Dimension 8 Code")
            {
                Caption = 'Shortcut Dimension 8 Code';
            }
        }
    }
}