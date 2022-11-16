pageextension 5023 "SD Sales Return Order" extends "Sales Return Order"
{
    layout
    {
        addafter("Area")
        {
            field("Applicable For Serv. Decl."; Rec."Applicable For Serv. Decl.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether a document is applicable for a service declaration.';
                Visible = UseServDeclaration;
            }
        }
    }

    var
        UseServDeclaration: Boolean;

    trigger OnOpenPage()
    var
        ServiceDeclarationMgt: Codeunit "Service Declaration Mgt.";
    begin
        UseServDeclaration := ServiceDeclarationMgt.IsFeatureEnabled();
    end;
}