namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30415 "API IC Incoming Notification"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyIncomingNotification';
    EntitySetName = 'intercompanyIncomingNotification';
    EntityCaption = 'Intercompany Incoming Notification';
    EntitySetCaption = 'Intercompany Incoming Notification';
    SourceTable = "IC Incoming Notification";
    DelayedInsert = true;
    Extensible = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Operation ID";

    layout
    {
        area(Content)
        {
            repeater(notificationInfo)
            {
                field(id; Rec."Operation ID")
                {
                    Caption = 'Id';
                }
                field(sourceICPartnerCode; Rec."Source IC Partner Code")
                {
                    Caption = 'Source Intercompany Partner Code';
                }
                field(targetICPartnerCode; Rec."Target IC Partner Code")
                {
                    Caption = 'Target Intercompany Partner Code';
                }
                field(notifiedDateTime; Rec."Notified DateTime")
                {
                    Caption = 'Notified DateTime';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ICDataExchangeAPI: Codeunit "IC Data Exchange API";
    begin
        ICDataExchangeAPI.InsertICIncomingNotification(Rec);
    end;
}