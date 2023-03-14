pageextension 5015 "SD Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("Qty. to Assign")
        {
            field("Service Transaction Type Code"; Rec."Service Transaction Type Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for a service transaction type.';
                Visible = EnableServTransType;
                ShowMandatory = Rec."Applicable For Serv. Decl.";
            }
            field("Applicable For Serv. Decl."; Rec."Applicable For Serv. Decl.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether an item or resource is applicable for a service declaration.';
                Visible = UseServDeclaration;
            }
        }
    }

    var
        UseServDeclaration: Boolean;
        EnableServTransType: Boolean;

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        UseServDeclaration := ServiceDeclarationMgt.IsFeatureEnabled();
        EnableServTransType := ServiceDeclarationMgt.IsServTransTypeEnabled();
    end;
}
