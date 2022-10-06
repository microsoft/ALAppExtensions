reportextension 11700 "Copy - VAT Posting Setup CZL" extends "Copy - VAT Posting Setup"
{
    dataset
    {
        modify("VAT Posting Setup")
        {
            trigger OnBeforeAfterGetRecord()
            begin
                if VATSetup or VIESCZL then begin
                    VATPostingSetup.Find();
                    "VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                    "EU Service" := VATPostingSetup."EU Service";
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
                    VIESCZL := Selection = Selection::"All fields";
                end;
            }
            addlast(Options)
            {
                field(VIESCZL; VIESCZL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VIES';
                    ToolTip = 'Specifies if vies fields will be copied';

                    trigger OnValidate()
                    begin
                        Selection := Selection::"Selected fields";
                    end;
                }
            }
        }

        trigger OnOpenPage()
        begin
            VIESCZL := Selection = Selection::"All fields";
        end;
    }

    var
        VIESCZL: Boolean;
}