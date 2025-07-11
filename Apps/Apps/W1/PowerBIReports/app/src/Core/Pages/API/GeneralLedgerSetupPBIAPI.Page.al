namespace Microsoft.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Setup;

#pragma warning disable AS0125
#pragma warning disable AS0030
page 36956 "General Ledger Setup - PBI API"
#pragma warning restore AS0030
#pragma warning restore AS0125
{
    PageType = API;
    Caption = 'General Ledger Setup';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'generalLedgerSetup';
    EntitySetName = 'generalLedgerSetups';
    SourceTable = "General Ledger Setup";
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {

                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {

                }
                field(shortcutDimension3Code; Rec."Shortcut Dimension 3 Code")
                {

                }
                field(shortcutDimension4Code; Rec."Shortcut Dimension 4 Code")
                {

                }
                field(shortcutDimension5Code; Rec."Shortcut Dimension 5 Code")
                {

                }
                field(shortcutDimension6Code; Rec."Shortcut Dimension 6 Code")
                {

                }
                field(shortcutDimension7Code; Rec."Shortcut Dimension 7 Code")
                {

                }
                field(shortcutDimension8Code; Rec."Shortcut Dimension 8 Code")
                {

                }
                field(localCurrencyCode; Rec."LCY Code")
                {

                }
            }
        }
    }
}