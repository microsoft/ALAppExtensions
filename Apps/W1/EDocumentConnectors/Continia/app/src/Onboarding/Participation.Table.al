// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Email;
using Microsoft.Finance.VAT.Registration;
using Microsoft.Foundation.Address;

table 6391 Participation
{
    Access = Internal;
    Caption = 'Participation';
    DataClassification = CustomerContent;
    LookupPageId = Participations;
    Permissions = tabledata "Activated Net. Prof." = rimd;

    fields
    {
        field(1; Network; Enum "E-Delivery Network")
        {
            Caption = 'Network';
            ToolTip = 'Specifies the network name where the participation is in.';
        }
        field(2; "Identifier Type Id"; Guid)
        {
            Caption = 'Identifier Type';
            TableRelation = "Network Identifier".Id where(Network = field(Network));
        }
        field(3; "Identifier Value"; Code[50])
        {
            Caption = 'Identifier Value';
            ToolTip = 'Specifies the value of the identifier used to identify the company in the network.';
        }
        field(10; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the legal name of the company that you want to join to the network.';
        }
        field(11; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            ToolTip = 'Specifies the VAT registration number of the company that you want to join to the network.';

            trigger OnValidate()
            var
                VATRegNoFormat: Record "VAT Registration No. Format";
            begin
                "VAT Registration No." := UpperCase("VAT Registration No.");
                if "VAT Registration No." = xRec."VAT Registration No." then
                    exit;
                if not VATRegNoFormat.Test("VAT Registration No.", "Country/Region Code", '', Database::Participation) then
                    exit;
            end;
        }
        field(12; Address; Text[100])
        {
            Caption = 'Address';
            ToolTip = 'Specifies the legal address of the company that you want to join to the network.';
        }
        field(13; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            ToolTip = 'Specifies the legal post code of the company that you want to join to the network.';
        }
        field(14; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            ToolTip = 'Specifies the legal country code of the company that you want to join to the network. Must be stated in the ISO 3166-1 format.';

            trigger OnLookup()
            begin
                LookupCountryRegion();
                ValidateCountryRegion();
                Validate("VAT Registration No.");
            end;

            trigger OnValidate()
            begin
                ValidateCountryRegion();
                Validate("VAT Registration No.");
            end;
        }
        field(15; County; Text[30])
        {
            Caption = 'County';
            CaptionClass = '5,1,' + "Country/Region Code";
            ToolTip = 'Specifies the legal county of the company that you want to join to the network.';
        }
        field(16; "Your Name"; Text[100])
        {
            Caption = 'Your Name';
        }
        field(17; "Contact Name"; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the contact person in the company.';
        }
        field(18; "Contact Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
            ToolTip = 'Specifies the telephone number of the contact person in the company.';

            trigger OnValidate()
            var
                PhoneNumber: Text[30];
            begin
                PhoneNumber := DelChr("Contact Phone No.", '=', '0123456789+');
                if PhoneNumber <> '' then
                    Error(InvalidPhoneNoErr, "Contact Phone No.");
            end;
        }
        field(19; "Contact Email"; Text[80])
        {
            Caption = 'Email Address';
            ExtendedDatatype = EMail;
            ToolTip = 'Specifies the email address of the contact person in the company.';

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Contact Email" <> '' then
                    MailManagement.CheckValidEmailAddress("Contact Email");
            end;
        }
        field(20; "Publish in Registry"; Boolean)
        {
            Caption = 'Publish data in Registry';
        }
        field(21; "Registration Status"; Enum "Registration Status")
        {
            Caption = 'Registration Status';
            ToolTip = 'Specifies the registration status of the participation.';
        }
        field(22; "Signatory Name"; Text[100])
        {
            Caption = 'Signatory Name';
            ToolTip = 'Specifies the name of the company signatory.';
        }
        field(23; "Signatory Email"; Text[80])
        {
            Caption = 'Email Address';
            ToolTip = 'Specifies the email of the company signatory.';

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Signatory Email" <> '' then
                    MailManagement.CheckValidEmailAddress("Signatory Email");
            end;
        }
        field(30; Id; Guid)
        {
            Caption = 'ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier of the participation in the Continia Delivery Network.';
        }
        field(31; Created; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time when the participation was created.';
        }
        field(32; Updated; DateTime)
        {
            Caption = 'Updated Date-Time';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time when the participation was last updated.';
        }
        field(33; "Cdn Timestamp"; Text[250])
        {
            Caption = 'CDN Timestamp';
            DataClassification = SystemMetadata;
        }
        field(34; "Published in Registry"; Boolean)
        {
            Caption = 'Published in Registry';
            DataClassification = SystemMetadata;
        }
        field(40; "Identifier Scheme Id"; Text[50])
        {
            CalcFormula = lookup("Network Identifier"."Scheme Id" where(Id = field("Identifier Type Id")));
            Caption = 'Identifier Type';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the type of identifier used for the participation.';
        }
        field(50; "Partner Id"; Code[20])
        {
            Caption = 'Partner Id';
            Editable = false;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(Key1; Network, "Identifier Type Id", "Identifier Value")
        {
            Clustered = true;
        }
        key(Key2; Id) { }
    }

    internal procedure LookupCountryRegion()
    var
        CountryRegion: Record "Country/Region";
        CountriesRegions: Page "Countries/Regions";
    begin
        CountriesRegions.LookupMode := true;
        if CountriesRegions.RunModal() = Action::LookupOK then begin
            CountriesRegions.GetRecord(CountryRegion);
            "Country/Region Code" := CountryRegion."ISO Code";
        end;
    end;

    internal procedure ValidateCountryRegion()
    var
        CountryRegion: Record "Country/Region";
    begin
        if "Country/Region Code" = '' then
            exit;

#pragma warning disable AA0210
        CountryRegion.SetRange("ISO Code", "Country/Region Code");
#pragma warning restore AA0210
#pragma warning disable AA0175
        CountryRegion.FindFirst(); // Throws the standard error if not found.
#pragma warning restore AA0175
    end;

    internal procedure ValidateCdnStatus(Status: Text)
    begin
        case Status of
            'DraftEnum':
                Validate("Registration Status", "Registration Status"::Draft);
            'InProcessEnum', 'ApprovedEnum', 'SuspendedEnum', 'ErrorEnum':
                Validate("Registration Status", "Registration Status"::InProcess);
            'ConnectedEnum':
                Validate("Registration Status", "Registration Status"::Connected);
            'RejectedEnum':
                Validate("Registration Status", "Registration Status"::Rejected);
            'DisabledEnum':
                Validate("Registration Status", "Registration Status"::Disabled);
        end;
    end;

    internal procedure GetParticipApiStatusEnumValue(Suspended: Boolean): Text
    begin
        if Suspended then
            exit('SuspendedEnum');

        case "Registration Status" of
            "Registration Status"::Draft:
                exit('DraftEnum');
            "Registration Status"::InProcess:
                exit('InProcessEnum');
            "Registration Status"::Connected:
                exit('ConnectedEnum');
            "Registration Status"::Rejected:
                exit('RejectedEnum');
            "Registration Status"::Disabled:
                exit('DisabledEnum');
        end;
    end;

    internal procedure GetNetworkIdentifier() NetworkIdentifier: Record "Network Identifier"
    begin
        NetworkIdentifier.SetRange(Id, "Identifier Type Id");
        NetworkIdentifier.FindFirst();
        exit(NetworkIdentifier);
    end;

    trigger OnDelete()
    var
        ActivatedProfiles: Record "Activated Net. Prof.";
    begin
        ActivatedProfiles.SetRange(Network, Rec.Network);
        ActivatedProfiles.SetRange("Identifier Type Id", Rec."Identifier Type Id");
        ActivatedProfiles.SetRange("Identifier Value", Rec."Identifier Value");
        ActivatedProfiles.DeleteAll();
    end;

    var
        InvalidPhoneNoErr: Label 'The phone number "%1" is not valid', Comment = '%1 - Telephone number';
}