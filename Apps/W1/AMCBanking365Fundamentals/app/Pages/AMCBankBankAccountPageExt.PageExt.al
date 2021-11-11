pageextension 20111 "AMC Bank Bank Account Page Ext" extends "Bank Account List"
{
    ContextSensitiveHelpPage = '304';

    actions
    {
        addAfter("C&ontact")
        {
            action(AMCShowServicePage)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'AMC Bank Page';
                Image = SignUp;
                Promoted = true;
                ToolTip = 'Calls the AMC Bank Myaccount Page to be able to setup further informations for the bank accounts. External webpage will be opened by this button.';
                PromotedCategory = Category6;
                PromotedOnly = true;
                trigger OnAction();
                begin
                    AMCBankServiceRequestMgt.ShowServiceLinkPage('myaccount', true);
                end;
            }
        }
    }

    var
        AMCBankServiceRequestMgt: codeunit "AMC Bank Service Request Mgt.";

}