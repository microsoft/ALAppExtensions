// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

page 27030 "DIOT Concepts"
{
    ApplicationArea = BasicMX;
    Caption = 'DIOT Concepts';
    Editable = true;
    PageType = List;
    SourceTable = "DIOT Concept";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Concept No."; Rec."Concept No.")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Concept Number';
                    ToolTip = 'Specifies the number of this concept.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of this concept.';
                }
                field("Column No."; Rec."Column No.")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Column Number';
                    ToolTip = 'Specifies the column number of this concept.';
                }
                field("Column Type"; Rec."Column Type")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Column Type';
                    ToolTip = 'Specifies the column type for this concept.';
                }
                field("Non-Deductible"; Rec."Non-Deductible")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Non-Deductible';
                    ToolTip = 'Specifies if this concept describes non-deductible VAT.';
                }
                field("Non-Deductible Pct"; Rec."Non-Deductible Pct")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Non-Deductible Percent';
                    ToolTip = 'Specifies the percentage of non-deductible VAT for this concept.';
                }
                field("VAT Links Count"; Rec."VAT Links Count")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'VAT Links Count';
                    ToolTip = 'Specifies how many VAT links exist for this concept.';
                    AssistEdit = false;
                    Lookup = false;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = (Rec."VAT Links Count" = 0) and (Rec."Column Type" <> Rec."Column Type"::None);

                    trigger OnDrillDown()
                    begin
                        if Rec."Column Type" <> Rec."Column Type"::None then
                            OpenLinksPage()
                        else
                            Error(ConceptDisabledErr);
                    end;
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Setup Links")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Setup Links';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Link a VAT posting setup to this concept.';
                Image = Setup;

                trigger OnAction()
                begin
                    OpenLinksPage();
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CloseAction = CloseAction::OK then
            if Rec.CheckLinksForConceptWithTypeNotNone() then
                if not ConfirmManagement.GetResponseOrDefault(NotAllLinksSetupMsg, true) then
                    exit(false);
    end;

    var
        ConceptDisabledErr: label 'The DIOT Concept is disabled. Do not add VAT Posting Setup Links to it or enable it first.';
        NotAllLinksSetupMsg: Label 'Some of the concepts that have Column Type not None do not have a link setup.\\Are you sure you have finished setting them up?';

    local procedure OpenLinksPage()
    var
        DIOTVATPostingSetupLink: Record "DIOT Concept Link";
    begin
        DIOTVATPostingSetupLink.SetRange("DIOT Concept No.", Rec."Concept No.");
        Page.RunModal(Page::"DIOT Concept Links", DIOTVATPostingSetupLink);
        CurrPage.Update();
    end;
}

