pageextension 5021 "SD Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Language Code")
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