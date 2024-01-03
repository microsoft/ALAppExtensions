namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.Setup;

page 30414 "API - IC Setup"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanySetup';
    EntitySetName = 'intercompanySetup';
    EntityCaption = 'Intercompany Setup';
    EntitySetCaption = 'Intercompany Setup';
    SourceTable = "IC Setup";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'Intercompany Partner Code';
                }
                field(icInboxType; Rec."IC Inbox Type")
                {
                    Caption = 'Intercompany Inbox Type';
                }
                field(icInboxTypeIndex; IcInboxTypeIndex)
                {
                    Caption = 'Intercompany Inbox Type Index';
                }
                field(icInboxDetails; Rec."IC Inbox Details")
                {
                    Caption = 'Intercompany Inbox Details';
                }
                field(defaultICGeneralJournalTemplate; Rec."Default IC Gen. Jnl. Template")
                {
                    Caption = 'Default Intercompany General Journal Template';
                }
                field(defaultICGeneralJournalBatch; Rec."Default IC Gen. Jnl. Batch")
                {
                    Caption = 'Default Intercompany General Journal Batch';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IcInboxTypeIndex := Rec."IC Inbox Type";
    end;

    var
        IcInboxTypeIndex: Integer;
}