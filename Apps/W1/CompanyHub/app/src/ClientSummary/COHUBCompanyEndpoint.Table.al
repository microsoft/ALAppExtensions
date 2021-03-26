table 1153 "COHUB Company Endpoint"
{
    ReplicateData = false;
    DataPerCompany = false;
    Access = Internal;

    fields
    {
        field(1; "Enviroment No."; Code[20])
        {
            TableRelation = "COHUB Enviroment";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }
        field(3; "Company Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(6; "ODATA Company URL"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Company Display Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Assigned To"; Guid)
        {
            TableRelation = User."User Security ID";
            ValidateTableRelation = true;
            DataClassification = EndUserIdentifiableInformation;
        }

        field(50; "Evaulation Company"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Enviroment No.", "Company Name", "Assigned To")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        COHUBCompanyKPI: Record "COHUB Company KPI";
        COHUBGroupCompanySummary: Record "COHUB Group Company Summary";
        COHUBUserTask: Record "COHUB User Task";
    begin
        COHUBCompanyKPI.SetRange("Enviroment No.", Rec."Enviroment No.");
        COHUBCompanyKPI.SetRange("Company Name", Rec."Company Name");
        COHUBCompanyKPI.DeleteAll(true);

        COHUBGroupCompanySummary.SetRange("Enviroment No.", Rec."Enviroment No.");
        COHUBGroupCompanySummary.SetRange("Company Name", Rec."Company Name");
        COHUBGroupCompanySummary.DeleteAll(true);

        COHUBUserTask.SetRange("Enviroment No.", Rec."Enviroment No.");
        COHUBUserTask.SetRange("Company Name", Rec."Company Name");
        COHUBUserTask.DeleteAll(true);
    end;
}

