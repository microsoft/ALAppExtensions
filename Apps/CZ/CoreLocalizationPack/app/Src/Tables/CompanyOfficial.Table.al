// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.EServices.OnlineMap;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.NoSeries;
using Microsoft.HumanResources.Employee;
using System.Email;

table 11793 "Company Official CZL"
{
    Caption = 'Company Official';
    DataCaptionFields = "No.";
    DrillDownPageId = "Company Official List CZL";
    LookupPageId = "Company Official List CZL";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    StatutoryReportingSetupCZL.Get();
                    NoSeriesManagement.TestManual(StatutoryReportingSetupCZL."Company Official Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "First Name"; Text[30])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(3; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }
        field(4; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(5; Initials; Text[30])
        {
            Caption = 'Initials';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Initials)) or ("Search Name" = '') then
                    "Search Name" := Initials;
            end;
        }
        field(6; "Job Title"; Text[30])
        {
            Caption = 'Job Title';
            DataClassification = CustomerContent;
        }
        field(7; "Search Name"; Code[250])
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(8; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(9; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(10; City; Text[30])
        {
            Caption = 'City';
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(11; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(12; County; Text[30])
        {
            Caption = 'County';
            CaptionClass = '5,1,' + "Country/Region Code";
            DataClassification = CustomerContent;
        }
        field(15; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(31; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(32; "Mobile Phone No."; Text[30])
        {
            Caption = 'Mobile Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(33; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
                EmailAddress: Text;
            begin
                EmailAddress := "E-Mail";
                MailManagement.ValidateEmailAddressField(EmailAddress);
                "E-Mail" := CopyStr(EmailAddress, 1, MaxStrLen("E-Mail"));
            end;
        }
        field(34; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
        }
        field(40; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(53; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(70; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.") then begin
                    "No." := xRec."No.";
                    "First Name" := Employee."First Name";
                    "Middle Name" := Employee."Middle Name";
                    "Last Name" := Employee."Last Name";
                    Initials := Employee.Initials;
                    "Job Title" := Employee."Job Title";
                    "Search Name" := Employee."Search Name";
                    Address := Employee.Address;
                    "Address 2" := Employee."Address 2";
                    City := Employee.City;
                    "Post Code" := Employee."Post Code";
                    County := Employee.County;
                    "Country/Region Code" := Employee."Country/Region Code";
                    "Phone No." := Employee."Phone No.";
                    "Mobile Phone No." := Employee."Mobile Phone No.";
                    "E-Mail" := Employee."E-Mail";
                    "Fax No." := Employee."Fax No.";
                    "Employee No." := Employee."No.";
                    "Privacy Blocked" := Employee."Privacy Blocked";
                    Image := Employee.Image;
                end;
            end;
        }
        field(140; Image; Media)
        {
            Caption = 'Image';
            ExtendedDatatype = Person;
            DataClassification = CustomerContent;
        }
        field(150; "Privacy Blocked"; Boolean)
        {
            Caption = 'Privacy Blocked';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; "Last Name", "First Name", "Middle Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "First Name", "Last Name", Initials, "Job Title")
        {
        }
        fieldgroup(Brick; "Last Name", "First Name", "Job Title", Image)
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            StatutoryReportingSetupCZL.Get();
            StatutoryReportingSetupCZL.TestField("Company Official Nos.");
            NoSeriesManagement.InitSeries(StatutoryReportingSetupCZL."Company Official Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    trigger OnRename()
    begin
        "Last Date Modified" := Today();
    end;

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        Employee: Record Employee;
        PostCode: Record "Post Code";
        CompanyOfficialCZL: Record "Company Official CZL";
        NoSeriesManagement: Codeunit NoSeriesManagement;

    procedure AssistEdit(OldCompanyOfficialCZL: Record "Company Official CZL"): Boolean
    begin
        CompanyOfficialCZL := Rec;
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.TestField("Company Official Nos.");
        if NoSeriesManagement.SelectSeries(StatutoryReportingSetupCZL."Company Official Nos.", OldCompanyOfficialCZL."No. Series", OldCompanyOfficialCZL."No. Series") then begin
            StatutoryReportingSetupCZL.Get();
            StatutoryReportingSetupCZL.TestField("Company Official Nos.");
            NoSeriesManagement.SetSeries(OldCompanyOfficialCZL."No.");
            Rec := CompanyOfficialCZL;
            exit(true);
        end;
    end;

    procedure FullName(): Text[100]
    begin
        if "Middle Name" = '' then
            exit("First Name" + ' ' + "Last Name");
        exit("First Name" + ' ' + "Middle Name" + ' ' + "Last Name");
    end;

    procedure DisplayMap()
    var
        OnlineMapSetup: Record "Online Map Setup";
        OnlineMapManagement: Codeunit "Online Map Management";
    begin
        if OnlineMapSetup.IsEmpty() then
            exit;
        OnlineMapManagement.MakeSelection(Database::"Company Official CZL", CopyStr(GetPosition(), 1, 1000));
    end;
}
