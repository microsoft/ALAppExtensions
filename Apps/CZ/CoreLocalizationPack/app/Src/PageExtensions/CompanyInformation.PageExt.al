pageextension 11700 "Company Information CZL" extends "Company Information"
{
    layout
    {
        addbefore("Bank Name")
        {
            field("Default Bank Account Code CZL"; Rec."Default Bank Account Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default bank account code for payment.';
            }
        }
        addafter("Bank Branch No.")
        {
            field("Bank Branch Name CZL"; Rec."Bank Branch Name CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bank branch name.';
            }
        }
        addlast(Payments)
        {
            field("Bank Account Format Check CZL"; Rec."Bank Account Format Check CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the bank account will be checked.';
            }
        }
        addafter("System Indicator")
        {
            group("Registration CZL")
            {
                Caption = 'Registration';
                field("Registration No. CZL"; Rec."Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number received from goverment.';
                    Importance = Promoted;
                }
            }
        }
        moveafter("Registration No. CZL"; "VAT Registration No.")
        addafter("VAT Registration No.")
        {
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the company.';
                Importance = Additional;
            }
        }
        modify("EORI Number")
        {
            Visible = true;
        }
    }
    actions
    {
#if CLEAN17
        addafter("System Settings")
        {
            group("Other CZL")
            {
                Caption = 'O&ther';
#else
#pragma warning disable AL0432
        addfirst("O&ther")
#pragma warning restore AL0432
        {
#endif
            action(OfficialsCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Officials';
                Image = Employee;
                RunObject = Page "Company Official List CZL";
                ToolTip = 'Contains the list of officials whitch represent the company.';
            }
            action(DocumentFootersCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Document Footers';
                Image = DocumentEdit;
                RunObject = Page "Document Footers CZL";
                ToolTip = 'Allows the setup of document footers for printout.';
            }
        }
#if CLEAN17
        }
    }
#else
    }
#endif
}
