pageextension 13676 "OIOUBL-Service Invoice" extends "Service Invoice"
{
    layout
    {
        addafter("Contact Name")
        {
            field("OIOUBL-Contact Role"; "OIOUBL-Contact Role")
            {
                Tooltip = 'Specifies the role of the contact person at the customer.';
                ApplicationArea = Service;
            }
        }

        addafter("Assigned User ID")
        {
            field("Your Reference"; "Your Reference")
            {
                Tooltip = 'Specifies Your Reference.';
                ApplicationArea = Service;
            }
        }

        addafter("Bill-to Contact")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                Tooltip = 'Specifies the GLN location number for the customer.';
                ApplicationArea = Service;
            }
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer.';
                ApplicationArea = Service;

                trigger OnValidate();
                begin
                    CurrPage.ServLines.PAGE.UpdateForm(true);
                end;
            }
            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                Tooltip = 'Specifies the profile that the customer requires for electronic documents.';
                ApplicationArea = Service;
            }
        }
    }
}