// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Customer;

pageextension 31052 "Customer Card CZZ" extends "Customer Card"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = false;
        }
    }

    actions
    {
        modify("Prepa&yment Percentages")
        {
            Visible = false;
        }
        addlast(creation)
        {
            action(NewSalesAdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';
                ToolTip = 'Create sales advance letter.';
                ApplicationArea = Basic, Suite;
                Image = NewDocument;

                trigger OnAction()
                var
                    AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                begin
                    AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
                    if Page.RunModal(0, AdvanceLetterTemplateCZZ) <> Action::LookupOK then
                        Error('');

                    AdvanceLetterTemplateCZZ.TestField("Advance Letter Document Nos.");
                    SalesAdvLetterHeaderCZZ.Init();
                    SalesAdvLetterHeaderCZZ."Advance Letter Code" := AdvanceLetterTemplateCZZ.Code;
                    SalesAdvLetterHeaderCZZ."No. Series" := AdvanceLetterTemplateCZZ."Advance Letter Document Nos.";
                    SalesAdvLetterHeaderCZZ.Insert(true);
                    SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", Rec."No.");
                    SalesAdvLetterHeaderCZZ.Modify(true);

                    Page.Run(Page::"Sales Advance Letter CZZ", SalesAdvLetterHeaderCZZ);
                end;
            }
        }
        addlast(Category_Category4)
        {
            actionref(NewSalesAdvanceLetterCZZ_Promoted; NewSalesAdvanceLetterCZZ)
            {
            }
        }
    }
}
