// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

table 4592 "SOA KPI Entry"
{
    DataClassification = CustomerContent;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; "Record Type"; Option)
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of the record that we are tracking.';
            OptionMembers = " ","Sales Quote","Sales Order";
            OptionCaption = ' ,Sales Quote,Sales Order';
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the number of the record that we are tracking.';
        }
        field(3; "Amount Including Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            ToolTip = 'Specifies the amount of the record that we are tracking. The amount includes tax.';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the record that we are tracking';
            OptionMembers = " ","Active","Deleted","Converted to Order","Posted";
            OptionCaption = ' ,Active,Deleted,Converted to Order,Posted';
        }
        field(5; "Created by User ID"; Guid)
        {
            Caption = 'Created by Agent User ID';
            ToolTip = 'Specifies the user ID of the agent who created the record.';
        }
        field(6; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            ToolTip = 'Specifies the contact number of the record that we are tracking.';
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number of the record that we are tracking.';
        }
        field(8; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            ToolTip = 'Specifies the quote number from which the order was created.';
        }
        field(20; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            ToolTip = 'Specifies the name of the contact.';
            FieldClass = FlowField;
            CalcFormula = lookup(Contact.Name where("No." = field("Contact No.")));
        }
        field(21; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Specifies the name of the customer.';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(22; "Task ID"; BigInteger)
        {
            Caption = 'Task ID';
            ToolTip = 'Specifies the task ID of the agent.';
        }
    }

    keys
    {
        key(Key1; "Record Type", "No.")
        {
            Clustered = true;
        }
        key(Key2; "Status")
        {
        }
    }

    internal procedure OpenCard()
    var
        SalesHeader: Record "Sales Header";
    begin
        case Rec."Record Type" of
            Rec."Record Type"::"Sales Quote":
                begin
                    if SalesHeader.Get(SalesHeader."Document Type"::Quote, Rec."No.") then begin
                        Page.Run(Page::"Sales Quote", SalesHeader);
                        exit;
                    end;

                    if Rec.Status = Rec.Status::"Converted to Order" then
                        if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Quote No.") then begin
                            Page.Run(Page::"Sales Order", SalesHeader);
                            exit;
                        end;

                    Message(SalesQuoteDoesNotExistAnyMoreMsg);
                    exit;
                end;
            Rec."Record Type"::"Sales Order":
                begin
                    if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."No.") then begin
                        Page.Run(Page::"Sales Order", SalesHeader);
                        exit;
                    end;
                    Message(SalesOrderDoesNotExistAnyMoreMsg);
                    exit;
                end;
        end;

        Message(NotPossibleToViewTheRecordMsg);
    end;

    var
        SalesQuoteDoesNotExistAnyMoreMsg: Label 'The sales quote does not exist any more.';
        SalesOrderDoesNotExistAnyMoreMsg: Label 'The sales order does not exist any more.';
        NotPossibleToViewTheRecordMsg: Label 'It is not possible to view the record.';
}