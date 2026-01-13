// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using System.Agents;

page 4404 "SOA Email Message"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Agent Task Message";
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    Caption = 'Sales Order Email Message';
    DataCaptionExpression = '';
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group("Email Details")
            {
                Caption = 'Email Details';

                grid("Email Details Grid")
                {
                    group(EmailDetailsGroup)
                    {
                        ShowCaption = false;
                        group(ReceivedGroup)
                        {
                            ShowCaption = false;
                            Visible = ReceivedDateTimeVisible;
                            field(ReceivedAt; SOAEmail."Received DateTime")
                            {
                                Caption = 'Received at';
                                ToolTip = 'Specifies the date and time when the message was received.';
                                Editable = false;
                            }
                        }
                        group(FromGroup)
                        {
                            ShowCaption = false;
                            Visible = FromGroupVisible;
                            field(MessageFrom; SOAEmail."Sender Address")
                            {
                                Caption = 'From';
                                ToolTip = 'Specifies the sender of the message.';
                                Editable = false;
                            }
                        }
                        group(ToGroup)
                        {
                            ShowCaption = false;
                            Visible = ToGroupVisible;

                            field(MessageTo; GlobalSendToAddress)
                            {
                                Caption = 'To';
                                ToolTip = 'Specifies the recipient of the message.';
                                Editable = false;
                            }
                        }
                        group(UnknownContact)
                        {
                            ShowCaption = false;
                            Visible = ((not ContactVisible) and (not CustomerVisible));
                            field(UnknownContactEmail; UnknownContactLbl)
                            {
                                Caption = 'Contact';
                                ToolTip = 'Specifies the contact name.';
                                Editable = false;
                                Style = Attention;

                                trigger OnDrillDown()
                                begin
                                    CreateContact();
                                end;
                            }
                        }
                        group(ContactInformation)
                        {
                            Visible = ContactVisible;
                            ShowCaption = false;
                            field(ContactName; GlobalContact.Name)
                            {
                                Caption = 'Contact';
                                ToolTip = 'Specifies the contact name.';
                                Editable = false;

                                trigger OnDrillDown()
                                begin
                                    Page.Run(Page::"Contact Card", GlobalContact);
                                end;
                            }
                        }
                        group(CustomerInformation)
                        {
                            ShowCaption = false;
                            Visible = CustomerVisible;
                            field(CustomerName; GlobalCustomer.Name)
                            {
                                Caption = 'Customer';
                                Editable = false;
                                ToolTip = 'Specifies the customer name.';

                                trigger OnDrillDown()
                                begin
                                    Page.Run(Page::"Customer Card", GlobalCustomer);
                                end;
                            }
                            group(BlockedInformation)
                            {
                                ShowCaption = false;
                                Visible = BlockedStatusVisible;
                                field(Blocked; GlobalCustomer.Blocked)
                                {
                                    Caption = 'Blocked';
                                    Editable = false;
                                    Style = Attention;
                                }
                            }
                        }
                        group(AttachmentsGroup)
                        {
                            Caption = 'Attachments';
                            Editable = false;
                            Visible = AttachmentsVisible;
                            ShowCaption = false;

                            field(AttachmentCountField; ShowAttachmentTxt)
                            {
                                ApplicationArea = All;
                                Caption = 'Attachments';
                                ToolTip = 'Specifies the number of attachments.';
                                Editable = false;
                                trigger OnDrillDown()
                                var
                                    SOAEmailAttachments: Page "SOA Email Attachments";
                                begin
                                    SOAEmailAttachments.LoadRecords(Rec);
                                    SOAEmailAttachments.RunModal();
                                    CurrPage.Update(false);
                                end;
                            }
                        }
                        group(RightGroup)
                        {
                            ShowCaption = false;

                            field(CreatedAt; Rec.SystemCreatedAt)
                            {
                                Importance = Additional;
                                Caption = 'Created at';
                                ToolTip = 'Specifies the date and time when the message was created.';
                            }
                            field(SentAt; SOAEmail."Sent DateTime")
                            {
                                Importance = Additional;
                                Caption = 'Sent at';
                                ToolTip = 'Specifies the date and time when the message was sent.';
                                Editable = false;
                                Visible = SentDateTimeVisible;
                            }
                            group(StatusGroup)
                            {
                                ShowCaption = false;
                                Visible = (Rec.Status <> Rec.Status::" ") and (Rec.Status <> Rec.Status::Draft);

                                field(Status; Rec.Status)
                                {
                                    Caption = 'Status';
                                    Editable = false;
                                }
                            }
                        }
                    }
                }
            }
            group(Message)
            {
                Caption = 'Message';
                Editable = IsMessageEditable;
                field(MessageText; GlobalMessageText)
                {
                    ShowCaption = false;
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = IsMessageEditable;

                    trigger OnValidate()
                    var
                        AgentMessage: Codeunit "Agent Message";
                    begin
                        AgentMessage.UpdateText(Rec, GlobalMessageText);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(PreviousMessages)
            {
                Caption = 'Previous Messages';
                Visible = PreviousMessagesVisible;
                Editable = false;

                field(PreviousMessageText; GlobalPreviousMessageText)
                {
                    ShowCaption = false;
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = false;

                    trigger OnValidate()
                    var
                        AgentMessage: Codeunit "Agent Message";
                    begin
                        AgentMessage.UpdateText(Rec, GlobalMessageText);
                        CurrPage.Update(false);
                    end;
                }
            }
            part(Attachments; "SOA Email Attachments")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Task ID" = field("Task ID");
                Editable = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    var
        EmailAddress: Text;
    begin
        UpdatePageCaption();
        UpdateEmailFields(EmailAddress);
        UpdateContactInformation(EmailAddress);
        CurrPage.Attachments.Page.LoadRecords(Rec);
    end;

    local procedure UpdateEmailFields(var EmailAddress: Text)
    var
        AgentMessage: Codeunit "Agent Message";
        SOATaskMessage: Codeunit "SOA Task Message";
        SOAEmailSetup: Codeunit "SOA Email Setup";
        AttachmentCount: Integer;
    begin
        GlobalMessageText := AgentMessage.GetText(Rec);
        GlobalPreviousMessageText := SOATaskMessage.GetPreviousText(Rec);
        PreviousMessagesVisible := GlobalPreviousMessageText <> '';
        IsMessageEditable := AgentMessage.IsEditable(Rec);
        AttachmentCount := SOAEmailSetup.GetNumberOfAttachments(Rec);
        ShowAttachmentTxt := StrSubstNo(ShowAttachmentLbl, AttachmentCount);
        AttachmentsVisible := AttachmentCount > 0;

        if not GetSOAEmail(Rec) then
            Clear(SOAEmail)
        else begin
            ReceivedDateTimeVisible := SOAEmail."Received DateTime" <> 0DT;
            SentDateTimeVisible := SOAEmail."Sent DateTime" <> 0DT;
        end;

        if Rec.Type = Rec.Type::Input then begin
            ToGroupVisible := false;
            FromGroupVisible := (Rec.Type = Rec.Type::Input) and (SOAEmail."Sender Address" <> '');
            EmailAddress := Rec.From;
            exit;
        end;

        if Rec.Type = Rec.Type::Output then begin
            FromGroupVisible := false;
            SOATaskMessage.GetSentMessageToAddress(Rec, GlobalSendToAddress);
            ToGroupVisible := (Rec.Type = Rec.Type::Output) and (GlobalSendToAddress <> '');
            EmailAddress := GlobalSendToAddress;
        end;
    end;

    local procedure UpdatePageCaption()
    begin
        if Rec.Type = Rec.Type::Output then
            CurrPage.Caption(OutgoingMessageTxt);

        if Rec.Type = Rec.Type::Input then
            CurrPage.Caption(IncomingMessageTxt);
    end;

    local procedure UpdateContactInformation(EmailAddress: Text)
    var
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
    begin
        ContactVisible := false;
        CustomerVisible := false;
        Clear(GlobalContact);
        Clear(GlobalCustomer);

        ContactVisible := FindContact(GlobalContact, EmailAddress);
        if ContactVisible then begin
            CustomerVisible := GlobalContact.FindCustomer(GlobalCustomer);
            BlockedStatusVisible := GlobalCustomer.Blocked <> GlobalCustomer.Blocked::" ";
        end;

        if GlobalContact.Name = GlobalCustomer.Name then
            ContactVisible := false;

        if (not ContactVisible) and (not CustomerVisible) then
            SOAFiltersImpl.ShowMissingContactNotification(EmailAddress, SOAEmail."Sender Name")
        else
            SOAFiltersImpl.RecallMissingContactNotification();
    end;

    local procedure FindContact(var Contact: Record Contact; EmailAddress: Text): Boolean
    var
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
    begin
        Contact.SetFilter("E-Mail", SOAFiltersImpl.GetSafeFromEmailFilter(EmailAddress));
        if not Contact.FindFirst() then
            exit(false);

        exit(true);
    end;

    local procedure GetSOAEmail(var AgentTaskMessage: Record "Agent Task Message"): Boolean
    begin
        SOAEmail.SetRange("Task ID", AgentTaskMessage."Task ID");
        SOAEmail.SetRange("Task Message ID", AgentTaskMessage.ID);
        exit(SOAEmail.FindFirst());
    end;

    local procedure CreateContact()
    var
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
        ContactEmail: Text;
    begin
        ContactEmail := GetContactEmail();
        SOAFiltersImpl.CreateContact(ContactEmail, SOAEmail."Sender Name");
    end;

    local procedure GetContactEmail(): Text
    var
        ContactEmail: Text;
    begin
        if Rec.Type = Rec.Type::Input then begin
            ContactEmail := SOAEmail."Sender Address";
            if ContactEmail = '' then
                ContactEmail := Rec.From;
        end;

        if Rec.Type = Rec.Type::Output then
            ContactEmail := GlobalSendToAddress;

        exit(ContactEmail);
    end;

    var
        GlobalContact: Record Contact;
        GlobalCustomer: Record Customer;
        SOAEmail: Record "SOA Email";
        ContactVisible: Boolean;
        CustomerVisible: Boolean;
        FromGroupVisible: Boolean;
        ToGroupVisible: Boolean;
        GlobalSendToAddress: Text;
        GlobalMessageText: Text;
        GlobalPreviousMessageText: Text;
        PreviousMessagesVisible: Boolean;
        IsMessageEditable: Boolean;
        ReceivedDateTimeVisible: Boolean;
        SentDateTimeVisible: Boolean;
        ShowAttachmentTxt: Text;
        AttachmentsVisible: Boolean;
        BlockedStatusVisible: Boolean;
        OutgoingMessageTxt: Label 'Outgoing email';
        IncomingMessageTxt: Label 'Incoming email';
        UnknownContactLbl: Label 'Unknown contact. Register the sender as a new contact.';
        ShowAttachmentLbl: Label 'Show attachments (%1)', Comment = '%1 = Attachment count';
}