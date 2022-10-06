reportextension 31002 "Copy - VAT Posting Setup CZZ" extends "Copy - VAT Posting Setup"
{
    dataset
    {
        modify("VAT Posting Setup")
        {
            trigger OnBeforeAfterGetRecord()
            begin
                if AdvanceCZZ then begin
                    VATPostingSetup.Find();
                    "Sales Adv. Letter Account CZZ" := VATPostingSetup."Sales Adv. Letter Account CZZ";
                    "Sales Adv. Letter VAT Acc. CZZ" := VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ";
                    "Purch. Adv. Letter Account CZZ" := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                    "Purch. Adv.Letter VAT Acc. CZZ" := VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ";
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            modify(Copy)
            {
                trigger OnAfterValidate()
                begin
                    AdvanceCZZ := Selection = Selection::"All fields";
                end;
            }
            addlast(Options)
            {
                field(AdvanceCZZ; AdvanceCZZ)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Advance';
                    ToolTip = 'Specifies if the advance G/L accounts have to be copied.';

                    trigger OnValidate()
                    begin
                        Selection := Selection::"Selected fields";
                    end;
                }
            }
        }

        trigger OnOpenPage()
        begin
            AdvanceCZZ := Selection = Selection::"All fields";
        end;
    }

    var
        AdvanceCZZ: Boolean;
}