// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

using System.Utilities;

page 6263 "Sust. Item Mat. Composition"
{
    Caption = 'Item Material Composition';
    PageType = ListPlus;
    SourceTable = "Sust. Item Mat. Comp. Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the item material composition.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the batch unit of measure.';
                    ShowMandatory = true;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the item material composition.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the last date that was modified.';
                }
            }
            part(ItemMatCompLine; "Sust. Item Mat. Comp. Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Item Material Composition No." = field("No.");
                SubPageView = sorting("Item Material Composition No.", "Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Copy Material Composition")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Copy Material Composition';
                    Ellipsis = true;
                    Image = CopyBOM;
                    ToolTip = 'Copy an existing item material composition to quickly create a similar Material Composition.';

                    trigger OnAction()
                    var
                        ItemMatCompHeader: Record "Sust. Item Mat. Comp. Header";
                        ItemMaterialCompCopy: Codeunit "Sust. Item Mat. Comp.-Copy";
                    begin
                        Rec.TestField("No.");
                        if Page.RunModal(0, ItemMatCompHeader) = Action::LookupOK then
                            ItemMaterialCompCopy.CopyItemMatComposition(ItemMatCompHeader."No.", Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Copy Material Composition_Promoted"; "Copy Material Composition")
                {
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not CurrPage.Editable() then
            exit(true);

        if IsNullGuid(Rec.SystemId) then
            exit(true);

        if Rec.Status in [Rec.Status::Certified, Rec.Status::Closed] then
            exit(true);

        if Rec."Unit of Measure Code" = '' then
            exit(true);

        if not Rec.ItemMaterialCompositionExist() then
            exit(true);

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(CertifyQst, CurrPage.Caption), false) then
            exit(false);

        exit(true);
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        CertifyQst: Label 'The %1 has not been certified. Are you sure you want to exit?', Comment = '%1 = page caption (Item Material Composition)';
}