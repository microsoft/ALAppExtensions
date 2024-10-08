// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System;
using System.Email;
using Microsoft.Finance.VAT.Registration;
using Microsoft.Foundation.Address;

table 6391 "Participation"
{
    Caption = 'Participation';
    DataClassification = CustomerContent;
    LookupPageId = "Participations";

    fields
    {
        field(1; Network; Enum "Network")
        {
            Caption = 'Network';
        }
        field(2; "Identifier Type ID"; Guid)
        {
            Caption = 'Identifier Type';
            TableRelation = "Network Identifier"."CDN GUID" where(Network = field(Network));
        }
        field(3; "Identifier Value"; Code[50])
        {
            Caption = 'Identifier Value';
        }
        field(10; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
        }
        field(11; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';

            trigger OnValidate()
            var
                VATRegNoFormat: Record "VAT Registration No. Format";
            begin
                "VAT Registration No." := UpperCase("VAT Registration No.");
                if "VAT Registration No." = xRec."VAT Registration No." then
                    exit;
                if not VATRegNoFormat.Test("VAT Registration No.", "Country/Region Code", '', Database::"Participation") then
                    exit;
            end;
        }
        field(12; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(13; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
        }
        field(14; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';

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
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
        }
        field(16; "Your Name"; Text[100])
        {
            Caption = 'Your Name';
        }
        field(17; "Contact Name"; Text[100])
        {
            Caption = 'Contact Name';
        }
        field(18; "Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            ExtendedDatatype = PhoneNo;

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
            Caption = 'Contact Email';
            ExtendedDatatype = EMail;

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
        }
        field(22; "Signatory Name"; Text[100])
        {
            Caption = 'Signatory Name';
        }
        field(23; "Signatory Email"; Text[80])
        {
            Caption = 'Signatory Email';

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Signatory Email" <> '' then
                    MailManagement.CheckValidEmailAddress("Signatory Email");
            end;
        }
        field(30; "CDN GUID"; Guid)
        {
            Caption = 'CDN GUID';
            DataClassification = SystemMetadata;
        }
        field(31; Created; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = SystemMetadata;
        }
        field(32; Updated; DateTime)
        {
            Caption = 'Updated Date-Time';
            DataClassification = SystemMetadata;
        }
        field(33; "CDN Timestamp"; Text[250])
        {
            Caption = 'CDN Timestamp';
            DataClassification = SystemMetadata;
        }
        field(34; "Published in Registry"; Boolean)
        {
            Caption = 'Published in Registry';
            DataClassification = SystemMetadata;
        }
        field(40; "Identifier Scheme ID"; Text[50])
        {
            Caption = 'Identifier Type';
            FieldClass = FlowField;
            CalcFormula = lookup("Network Identifier"."Scheme ID" where("CDN GUID" = field("Identifier Type ID")));
            Editable = false;
        }
        field(50; "Partner ID"; Code[20])
        {
            Caption = 'Partner ID';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Network, "Identifier Type ID", "Identifier Value")
        {
            Clustered = true;
        }
        key(Key2; "CDN GUID")
        {
        }
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

        CountryRegion.SetRange("ISO Code", "Country/Region Code");
        CountryRegion.FindFirst(); // Throws the standard error if not found.
    end;

    internal procedure ValidateCDNStatus(CDNStatus: Text)
    begin
        case CDNStatus of
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
        NetworkIdentifier.SetRange("CDN GUID", "Identifier Type ID");
        NetworkIdentifier.FindFirst();
        exit(NetworkIdentifier);
    end;

    trigger OnDelete()
    var
        ActivatedProfiles: Record "Activated Net. Prof.";
    begin
        ActivatedProfiles.SetRange(Network, Rec.Network);
        ActivatedProfiles.SetRange("Identifier Type ID", Rec."Identifier Type ID");
        ActivatedProfiles.SetRange("Identifier Value", Rec."Identifier Value");
        ActivatedProfiles.DeleteAll();
    end;

    var
        InvalidPhoneNoErr: Label 'The phone number "%1" is not valid', Comment = '%1 - Telephone number';
}