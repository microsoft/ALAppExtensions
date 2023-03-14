pageextension 5017 "Serv. Decl. Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Time Sheet Approver User ID")
        {
            field("Service Transaction Type Code"; Rec."Service Transaction Type Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for a service transaction type.';
                Visible = EnableServTransType;
            }
            field("Exclude From Service Decl."; Rec."Exclude From Service Decl.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether a resource must be excluded from the service declaration.';
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
