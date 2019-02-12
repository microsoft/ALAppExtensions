// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13680 "OIOUBL-Posted Service Cr Memo" extends "Posted Service Credit memo"
{
    layout
    {
        addafter("Contact Name")
        {
            field("OIOUBL-Contact Role"; "OIOUBL-Contact Role")
            {
                Tooltip = 'Specifies the role of the contact person at the customer.';
                Editable = False;
                ApplicationArea = Service;
            }
        }

        addafter("Responsibility Center")
        {
            field("Your Reference"; "Your Reference")
            {
                Tooltip = 'Specifies the customer''s reference.';
                ApplicationArea = Service;
                Editable = False;
            }
        }

        addafter("Bill-to Contact")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                Tooltip = 'Specifies the GLN location number for the customer, based on the GLN field in the original sales order.';
                ApplicationArea = Service;
                Editable = False;
            }
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the invoice to.';
                ApplicationArea = Service;
                Editable = False;
            }
            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                Tooltip = 'Specifies the profile that this customer requires for electronic documents.';
                ApplicationArea = Service;
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
                    Caption = 'Create Electronic Credit Memo';
                    Tooltip = 'Create an electronic version of the current document.';
                    ApplicationArea = Service;
                    Ellipsis = True;
                    Promoted = True;
                    Image = ElectronicDoc;
                    PromotedCategory = Process;

                    trigger OnAction();
                    var
                        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
                    begin
                        ServiceCrMemoHeader := Rec;
                        ServiceCrMemoHeader.SETRECFILTER();

                        REPORT.RUNMODAL(REPORT::"OIOUBL-Create Elec Srv Cr Memo", TRUE, FALSE, ServiceCrMemoHeader);
                    end;
                }
            }
        }
    }
}