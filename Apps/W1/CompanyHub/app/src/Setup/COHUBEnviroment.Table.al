table 1152 "COHUB Enviroment"
{
    Access = Internal;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }

        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }

        field(5; "Privacy Blocked"; Boolean)
        {
            Caption = 'Privacy Blocked';
            DataClassification = CustomerContent;
        }

        field(6; Link; Text[2048])
        {
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                COHUBCore: Codeunit "COHUB Core";
            begin
                if Link <> '' then begin
                    COHUBCore.AppendRedirectedFromSignupUrl(Link);
                    COHUBCore.VerifyForDuplicates(Rec, Rec.Link);
                end;
            end;
        }

        field(7; "Group Code"; Code[20])
        {
            TableRelation = "COHUB Group".Code;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
        }

        field(20; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(21; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(22; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }

        field(23; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }

        field(24; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
            DataClassification = CustomerContent;
        }

        field(25; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }

        field(40; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
            DataClassification = CustomerContent;
        }

        field(41; "Contact Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(42; "Contact E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(103; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }

        field(104; "Include Demo Companies"; Boolean)
        {
            Caption = 'Include Demo Companies';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
            begin
                if not "Include Demo Companies" then begin
                    COHUBCompanyEndpoint.SetRange("Enviroment No.", Rec."No.");
                    COHUBCompanyEndpoint.SetRange("Evaulation Company", true);
                    COHUBCompanyEndpoint.DeleteAll(true);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        COHUBGroupCompanySummary: Record "COHUB Group Company Summary";
    begin
        COHUBGroupCompanySummary.SetRange("Enviroment No.", Rec."No.");
        COHUBGroupCompanySummary.DeleteAll(true);
    end;
}

