pageextension 13672 "OIOUBL-Service Mgt. Setup" extends "Service Mgt. Setup"
{
    layout
    {
        addafter(Numbering)
        {
            group("OIOUBL-Output paths")
            {
                Caption = 'OIOUBL Output paths';

                field("OIOUBL-Service Invoice Path"; "OIOUBL-Service Invoice Path")
                {
                    ApplicationArea = Service;
                    Caption = 'Service Invoice Path';
                    ToolTip = 'Specifies the path and name of the folder where you want to store the files for electronic invoices.';
                }

                field("OIOUBL-Service Cr. Memo Path"; "OIOUBL-Service Cr. Memo Path")
                {
                    ApplicationArea = Service;
                    Caption = 'Service Cr. Memo Path';
                    ToolTip = 'Specifies the path and name of the folder where you want to store the files for electronic credit memos.';
                }
            }
        }
    }
}