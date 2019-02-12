// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13648 "OIOUBL-PostedSalesCreditMemo" extends "Posted Sales Credit Memo"
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
        addbefore(Customer)
        {
            group("OIOUBL-F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action(CreateElectronicInvoices)
                {
                    Caption = 'Create Electronic Credit Memo';
                    Tooltip = 'Create an electronic version of the current document.';
                    ApplicationArea = Basic, Suite;
                    Ellipsis = True;
                    Promoted = True;
                    Image = ElectronicDoc;
                    PromotedCategory = Process;

                    trigger OnAction();
                    var
                        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    begin
                        SalesCrMemoHeader := Rec;
                        SalesCrMemoHeader.SETRECFILTER();

                        REPORT.RUNMODAL(REPORT::"OIOUBL-Create Elec. Cr. Memos", TRUE, FALSE, SalesCrMemoHeader);
                    end;
                }
            }
        }
    }
}