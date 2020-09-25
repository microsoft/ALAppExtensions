page 27030 "DIOT Concepts"
{
    ApplicationArea = Basic, Suite;
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
                field("Concept No."; "Concept No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Concept Number';
                    ToolTip = 'Specifies the number of this concept.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of this concept.';
                }
                field("Column No."; "Column No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Column Number';
                    ToolTip = 'Specifies the column number of this concept.';
                }
                field("Column Type"; "Column Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Column Type';
                    ToolTip = 'Specifies the column type for this concept.';
                }
                field("Non-Deductible"; "Non-Deductible")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Non-Deductible';
                    ToolTip = 'Specifies if this concept describes non-deductible VAT.';
                }
                field("Non-Deductible Pct"; "Non-Deductible Pct")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Non-Deductible Percent';
                    ToolTip = 'Specifies the percentage of non-deductible VAT for this concept.';
                }
                field("VAT Links Count"; "VAT Links Count")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Links Count';
                    ToolTip = 'Specifies how many VAT links exist for this concept.';
                    AssistEdit = false;
                    Lookup = false;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = ("VAT Links Count" = 0) and ("Column Type" <> "Column Type"::None);

                    trigger OnDrillDown()
                    begin
                        if "Column Type" <> "Column Type"::None then
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
            if CheckLinksForConceptWithTypeNotNone() then
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
        DIOTVATPostingSetupLink.SetRange("DIOT Concept No.", "Concept No.");
        Page.RunModal(Page::"DIOT Concept Links", DIOTVATPostingSetupLink);
        CurrPage.Update();
    end;
}

