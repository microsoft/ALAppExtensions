// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an overview of all e-mail that were sent out in a ListPart.
/// </summary>
page 8888 "Sent Emails List Part"
{
    PageType = ListPart;
    Caption = 'Sent Emails';
    UsageCategory = None;
    SourceTable = "Sent Email";
    SourceTableTemporary = true;
    Permissions = tabledata "Sent Email" = rd;
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = true;

    layout
    {
        area(Content)
        {
            repeater(SentEmails)
            {
                field(Desc; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the email that was sent.';

                    trigger OnDrillDown()
                    begin
                        EmailViewer.Open(Rec);
                    end;
                }

                field(ConnectorType; Rec.Connector)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the type of email extension that was used to send the email.';
                }

                field(DateTimeSent; Rec."Date Time Sent")
                {
                    Caption = 'Sent';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time the email was sent.';
                }

                field(Sender; Rec.Sender)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Business Central user who sent this email.';
                }

                field(SentFrom; Rec."Sent From")
                {
                    ApplicationArea = All;
                    Caption = 'Sent From';
                    ToolTip = 'Specifies the email address that this email was sent from.';

                    trigger OnDrillDown()
                    begin
                        ShowAccountInformation();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditAndSend)
            {
                ApplicationArea = All;
                Caption = 'Edit and Send';
                ToolTip = 'Edit and send the email.';
                Image = Email;
                Enabled = not NoSentEmails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    EmailViewer.EditAndSend(Rec)
                end;
            }

            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    EmailViewer.RefreshSentMailForUser(EmailAccountId, NewerThanDate, SourceTableID, SourceSystemID, Rec);
                    CurrPage.Update(false);
                    NoSentEmails := Rec.IsEmpty();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        HasSourceRecord := EmailImpl.HasSourceRecord(Rec."Message Id");
    end;

    trigger OnDeleteRecord(): Boolean
    var
        SentEmail: Record "Sent Email";
    begin
        if SentEmail.Get(Rec.Id) then
            SentEmail.Delete(true);

        HasSourceRecord := false;
    end;

    local procedure ShowAccountInformation()
    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        EmailConnector: Interface "Email Connector";
    begin
        if not EmailAccountImpl.IsValidConnector(Rec.Connector) then
            Error(EmailConnectorHasBeenUninstalledMsg);

        EmailConnector := Rec.Connector;
        EmailConnector.ShowAccountInformation(Rec."Account Id");
    end;

    /// <summary>
    /// Loads the relevant sent emails.
    /// </summary>
    procedure Load()
    begin
        EmailImpl.GetSentEmails(EmailAccountId, NewerThanDate, SourceTableID, SourceSystemID, Rec);
        Rec.SetCurrentKey("Date Time Sent");
        NoSentEmails := Rec.IsEmpty();
        Rec.Ascending(false);
    end;

    /// <summary>
    /// Set date filter for sent emails.
    /// </summary>
    /// <param name="NewDate">Earliest date to include sent emails from.</param>
    procedure SetNewerThan(NewDate: DateTime)
    begin
        NewerThanDate := NewDate;
    end;

    /// <summary>
    /// Set filter for related record on sent emails.
    /// </summary>
    /// <param name="TableID">The entity table.</param>
    /// <param name="SystemID">A record to filter on.</param>
    procedure SetRelatedRecord(TableID: Integer; SystemID: Guid)
    begin
        SourceTableID := TableID;
        SourceSystemID := SystemID;
    end;

    /// <summary>
    /// Set filter for related record on sent emails.
    /// </summary>
    /// <param name="RecordVariant">Source record.</param>
    procedure SetRelatedRecord(RecordVariant: Variant)
    var
        EmailImpl: Codeunit "Email Impl";
        RecordRef: RecordRef;
    begin
        if EmailImpl.GetRecordRef(RecordVariant, RecordRef) then
            SetRelatedRecord(RecordRef.Number, RecordRef.Field(RecordRef.SystemIdNo).Value);
    end;

    var
        EmailViewer: Codeunit "Email Viewer";
        EmailImpl: Codeunit "Email Impl";
        NewerThanDate: DateTime;
        EmailAccountId, SourceSystemID : Guid;
        SourceTableID: Integer;
        [InDataSet]
        HasSourceRecord: Boolean;
        NoSentEmails: Boolean;
        EmailConnectorHasBeenUninstalledMsg: Label 'The email extension that was used to send this email has been uninstalled. To view information about the email account, you must reinstall the extension.';
}