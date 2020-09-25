// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13646 "OIOUBL-Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Contact No.")
        {
            field("OIOUBL-Sell-to Contact Phone No."; "OIOUBL-Sell-to Contact Phone No.")
            {
                Caption = 'Contact Phone No.';
                Tooltip = 'Specifies the telephone number of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
            field("OIOUBL-Sell-to Contact Fax No."; "OIOUBL-Sell-to Contact Fax No.")
            {
                Caption = 'Contact Fax No.';
                Tooltip = 'Specifies the fax number of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
            field("OIOUBL-Sell-to Contact E-Mail"; "OIOUBL-Sell-to Contact E-Mail")
            {
                Caption = 'Contact E-Mail';
                Tooltip = 'Specifies the email address of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
            field("OIOUBL-Sell-to Contact Role"; "OIOUBL-Sell-to Contact Role")
            {
                Caption = 'Contact Role';
                Tooltip = 'Specifies the role of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
        }

        addafter("Bill-to Contact")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                Tooltip = 'Specifies the GLN location number for the customer, based on the GLN field in the original sales order.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the invoice to.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                Tooltip = 'Specifies the profile that this customer requires for electronic documents.';
                ApplicationArea = Basic, Suite;
                Editable = False;
            }
        }
    }

    actions
    {
        addbefore(SendCustom)
        {
            group("OIOUBL-F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action(CreateElectronicInvoices)
                {
                    Caption = 'Create Electronic Invoice';
                    Tooltip = 'Create an electronic version of the current document.';
                    ApplicationArea = Basic, Suite;
                    Ellipsis = True;
                    Promoted = True;
                    Image = ElectronicDoc;
                    PromotedCategory = Process;

                    trigger OnAction();
                    var
                        SalesInvHeader: Record "Sales Invoice Header";
                    begin
                        SalesInvHeader := Rec;
                        SalesInvHeader.SETRECFILTER();

                        REPORT.RUNMODAL(REPORT::"OIOUBL-Create Elec. Invoices", TRUE, FALSE, SalesInvHeader);
                    end;
                }
            }
        }
    }
}