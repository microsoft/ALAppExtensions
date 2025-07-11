namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.DataExchange;

page 30425 "API IC Outgoing Notification"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyOutgoingNotification';
    EntitySetName = 'intercompanyOutgoingNotification';
    EntityCaption = 'Intercompany Outgoing Notification';
    EntitySetCaption = 'Intercompany Outgoing Notification';
    SourceTable = "IC Outgoing Notification";
    DelayedInsert = true;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Operation ID";
    Permissions = tabledata "IC Outgoing Notification" = m;

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
                part(ICInboxTransactions; "API Buf IC Inbox Transaction")
                {
                    Caption = 'Intercompany Inbox Transactions';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxTransaction';
                    EntitySetName = 'bufferIntercompanyInboxTransactions';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxJnlLine; "API Buf IC Inbox Jnl Line")
                {
                    Caption = 'Intercompany Inbox Journal Lines';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxJournalLine';
                    EntitySetName = 'bufferIntercompanyInboxJournalLines';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxPurchaseHeader; "API Buf IC Inbox Purch Header")
                {
                    Caption = 'Intercompany Inbox Purchase Headers';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxPurchaseHeader';
                    EntitySetName = 'bufferIntercompanyInboxPurchaseHeaders';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxPurchaseLine; "API Buf IC Inbox Purchase Line")
                {
                    Caption = 'Intercompany Inbox Purchase Lines';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxPurchaseLine';
                    EntitySetName = 'bufferIntercompanyInboxPurchaseLines';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxSalesHeader; "API Buf IC Inbox Sales Header")
                {
                    Caption = 'Intercompany Inbox Sales Headers';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxSalesHeader';
                    EntitySetName = 'bufferIntercompanyInboxSalesHeaders';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxSalesLines; "API Buf IC Inbox Sales Line")
                {
                    Caption = 'Intercompany Inbox Sales Lines';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInboxSalesLine';
                    EntitySetName = 'bufferIntercompanyInboxSalesLines';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInOutJournalLineDimension; "API Buf IC InOut Jnl Line Dim")
                {
                    Caption = 'Intercompany Inbox';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyInOutJournalLineDimension';
                    EntitySetName = 'bufferIntercompanyInOutJournalLineDimensions';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICDocumentDimension; "API Buf IC Document Dimension")
                {
                    Caption = 'Intercompany Inbox Document Dimension';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyDocumentDimension';
                    EntitySetName = 'bufferIntercompanyDocumentDimensions';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
                part(ICInboxCommentLines; "API Buf IC Comment Lines")
                {
                    Caption = 'Intercompany Inbox';
                    Multiplicity = Many;
                    EntityName = 'bufferIntercompanyCommentLine';
                    EntitySetName = 'bufferIntercompanyCommentLines';
                    SubPageLink = "Operation ID" = field("Operation ID");
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure SyncronizationCompleted(var ActionContext: WebServiceActionContext)
    var
        ICDataExchangeAPI: Codeunit "IC Data Exchange API";
    begin
        Rec.Status := Rec.Status::"Scheduled for deletion";
        Rec.SetErrorMessage('');
        Rec.Modify(true);
        ICDataExchangeAPI.CleanupICOutgoingNotification(Rec);
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"API IC Outgoing Notification");
        ActionContext.AddEntityKey(Rec.FieldNo("Operation ID"), Rec."Operation ID");
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        IdFilter: Text;
    begin
        if not LinesLoaded then begin
            IdFilter := Rec.GetFilter(Rec."Operation ID");
            if (IdFilter = '') then
                error(IDShouldBeSpecifiedErr);

            if not Rec.FindFirst() then
                exit(false);

            LinesLoaded := true;
            exit(true);
        end;

        exit(true);
    end;

    var
        LinesLoaded: Boolean;
        IDShouldBeSpecifiedErr: Label 'Operation ID should be specified';
}