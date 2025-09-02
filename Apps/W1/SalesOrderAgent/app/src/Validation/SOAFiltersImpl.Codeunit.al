// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using System.Agents;

codeunit 4305 "SOA Filters Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Agent Task Message" = r;

    var
        ExcludeAllFilterTok: Label '<>*', Locked = true;

    internal procedure GetSecurityFiltersForCustomers(ContactsFilter: Text): Text
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SOAImpl: Codeunit "SOA Impl";
        ProcessedCustomers: List of [Text];
        CustomerFilter: Text;
    begin
        Contact.SetFilter("No.", ContactsFilter);

        if not Contact.FindSet() then begin
            Session.LogMessage('0000O31', NoContactsFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            exit(ExcludeAllFilterTok);
        end;

        repeat
            if Contact.FindCustomer(Customer) then
                if not ProcessedCustomers.Contains(Customer."No.") then begin
                    ProcessedCustomers.Add(Customer."No.");
                    CustomerFilter += '|' + Customer."No.";
                end;
        until Contact.Next() = 0;

        CustomerFilter := CustomerFilter.TrimStart('|');
        if CustomerFilter = '' then
            CustomerFilter := ExcludeAllFilterTok;
        exit(CustomerFilter);
    end;

    internal procedure GetSecurityFiltersForContacts(AgentTaskID: Integer): Text
    var
        ContactList: List of [Text];
        ContactFilter: Text;
        ContactNo: Text;
    begin
        GetContactsInvolvedInTask(AgentTaskID, ContactList);
        if ContactList.Count() = 0 then
            exit(ExcludeAllFilterTok);

        foreach ContactNo in ContactList do
            ContactFilter += '|' + ContactNo;

        exit(ContactFilter.TrimStart('|'));
    end;

    local procedure GetContactsInvolvedInTask(AgentTaskID: Integer; var ContactList: List of [Text])
    var
        AgentTaskMessage: Record "Agent Task Message";
        Contact: Record Contact;
        SOAImpl: Codeunit "SOA Impl";
        From: Text;
        ProcessedFromEmails: List of [Text];
    begin
        AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
        AgentTaskMessage.SetRange("Task ID", AgentTaskID);

        if not AgentTaskMessage.FindSet() then begin
            Session.LogMessage('0000O32', NoTaskMessagesFoundTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            exit;
        end;

        repeat
            From := GetSafeFromEmailFilter(AgentTaskMessage.From);
            if not ProcessedFromEmails.Contains(From) then begin
                ProcessedFromEmails.Add(From);
                Contact.SetFilter("E-Mail", From);
                Contact.ReadIsolation := IsolationLevel::ReadUncommitted;
                if Contact.FindSet() then
                    repeat
                        if not ContactList.Contains(Contact."No.") then
                            ContactList.Add(Contact."No.");
                    until Contact.Next() = 0;
            end;
        until AgentTaskMessage.Next() = 0;
    end;

    internal procedure GetExcludeAllFilter(): Text
    begin
        exit(ExcludeAllFilterTok);
    end;

    internal procedure ShowMissingContactNotification(FromEmail: Text; ContactName: Text)
    var
        MissingContactNotification: Notification;
    begin
        RecallMissingContactNotification(MissingContactNotification);
        MissingContactNotification.Message := StrSubstNo(MissingContactNotificationLbl, FromEmail);
        MissingContactNotification.AddAction(CreateContactLbl, Codeunit::"SOA Filters Impl.", 'CreateContactFromEmail');
        MissingContactNotification.AddAction(LearnMoreLbl, Codeunit::"SOA Filters Impl.", 'LearnMoreNotRegisteredEmail');
        MissingContactNotification.SetData('FromEmail', FromEmail);
        MissingContactNotification.SetData('ContactName', ContactName);
        MissingContactNotification.Send();
    end;

    procedure RecallMissingContactNotification()
    var
        MissingContactNotification: Notification;
    begin
        RecallMissingContactNotification(MissingContactNotification);
    end;

    local procedure RecallMissingContactNotification(MissingContactNotification: Notification)
    begin
        MissingContactNotification.Id := '1a55c794-3b65-44b7-b0d8-433a5c0c6a7f';
        if MissingContactNotification.Recall() then;
    end;

    procedure CreateContactFromEmail(MissingContactNotification: Notification)
    var
        FromEmail: Text;
        ContactName: Text;
    begin
        FromEmail := MissingContactNotification.GetData('FromEmail');
        ContactName := MissingContactNotification.GetData('ContactName');
        CreateContact(FromEmail, ContactName);
    end;

    internal procedure CreateContact(ContactEmail: Text; SenderName: Text)
    var
        ExistingContact: Record Contact;
        SOAFiltersImpl: Codeunit "SOA Filters Impl.";
        CreateContactPage: Page "SOA Create Contact";
        ContactEmailFilter: Text;
    begin
        if ContactEmail <> '' then begin
            ExistingContact.ReadIsolation := IsolationLevel::ReadUncommitted;
            ContactEmailFilter := SOAFiltersImpl.GetSafeFromEmailFilter(ContactEmail);
            ExistingContact.SetFilter("E-Mail", ContactEmailFilter);
            if ExistingContact.FindFirst() then
                if not Confirm(StrSubstNo(ContactAlreadyExistQst, ExistingContact."No.")) then
                    Error('')
                else begin
                    Page.Run(Page::"Contact Card", ExistingContact);
                    exit;
                end;
        end;

        CreateContactPage.SetGlobalVariables(SenderName, ContactEmail);
        Commit();
        CreateContactPage.RunModal();
    end;

    internal procedure LearnMoreNotRegisteredEmail(MissingContactNotification: Notification) //Add Action in ShowMissingContactNotification
    begin
        Hyperlink(SecurityFilteringDocumentationURLTxt);
    end;

    internal procedure GetSafeFromEmailFilter(FromEmail: Text): Text
    begin
        exit('''@' + LowerCase(FromEmail.TrimStart('"').TrimEnd('"').Trim()) + '''');
    end;

    var
        NoContactsFoundTxt: Label 'No contacts found for given email.', Locked = true;
        NoTaskMessagesFoundTxt: Label 'No agent task messages found for given task ID.', Locked = true;
        LearnMoreLbl: Label 'Learn more';
        CreateContactLbl: Label 'Create contact';
        SecurityFilteringDocumentationURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2298901', Locked = true;
        MissingContactNotificationLbl: Label 'A contact with email <%1> is not found. Without it, document access and creation are not possible.', Comment = '%1 - email address';
        ContactAlreadyExistQst: Label 'A contact with the same email already exists. Contact number is %1. Do you want to open it?', Comment = '%1 = Contact number';
}