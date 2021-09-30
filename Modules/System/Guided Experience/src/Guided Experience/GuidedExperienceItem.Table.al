// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1990 "Guided Experience Item"
{
    Caption = 'Guided Experience Item';
    Access = Internal;

    fields
    {
        field(1; Code; Code[300])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Version; Integer)
        {
            Caption = 'Version';
            DataClassification = SystemMetadata;
        }
        field(3; "Object Type to Run"; Enum "Guided Experience Object Type")
        {
            Caption = 'Object Type to Run';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec.Link <> '' then
                    Error(ObjectAndLinkErr);
            end;
        }
        field(4; "Object ID to Run"; Integer)
        {
            Caption = 'Object ID to Run';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec.Link <> '' then
                    Error(ObjectAndLinkErr);
            end;
        }
        field(5; Link; Text[250])
        {
            Caption = 'External Link';
            DataClassification = OrganizationIdentifiableInformation;

            trigger OnValidate()
            begin
                if (Rec."Object ID to Run" <> 0) or (Rec."Object Type to Run" <> Rec."Object Type to Run"::Uninitialized) then
                    Error(LinkAndObjectErr);
            end;
        }
        field(6; Title; Text[2048])
        {
            Caption = 'Title';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(7; "Short Title"; Text[50])
        {
            Caption = 'Short Title';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(8; Description; Text[1024])
        {
            Caption = 'Description';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(9; "Expected Duration"; Integer)
        {
            Caption = 'Expected Duration';
            DataClassification = SystemMetadata;
        }
        field(10; "Extension ID"; Guid)
        {
            Caption = 'Extension';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(11; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("Published Application".Name where(ID = FIELD("Extension ID"), "Tenant Visible" = CONST(true)));
        }
        field(12; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = SystemMetadata;
        }
        field(13; "Guided Experience Type"; Enum "Guided Experience Type")
        {
            Caption = 'Guided Experience Type';
            DataClassification = SystemMetadata;
        }
        field(14; "Assisted Setup Group"; Enum "Assisted Setup Group")
        {
            Caption = 'Assisted Setup Group';
            DataClassification = SystemMetadata;
        }
        field(15; "Help Url"; Text[250])
        {
            Caption = 'Help Url';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(16; "Video Url"; Text[250])
        {
            Caption = 'Video Url';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(17; "Video Category"; Enum "Video Category")
        {
            Caption = 'Video Category';
            DataClassification = SystemMetadata;
        }
        field(18; "Manual Setup Category"; Enum "Manual Setup Category")
        {
            Caption = 'Manual Setup Category';
            DataClassification = SystemMetadata;
        }
        field(19; Keywords; Text[250])
        {
            Caption = 'Keywords';
            DataClassification = SystemMetadata;
        }
        field(20; Icon; Media)
        {
            Caption = 'Icon';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(21; "Spotlight Tour Type"; Enum "Spotlight Tour Type")
        {
            Caption = 'Spotlight Tour Type';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Code, Version)
        {
            Clustered = true;
        }
        key(Key2; "Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version)
        {
        }
        key(Key3; "Assisted Setup Group")
        {

        }
    }

    var
        ObjectAndLinkErr: Label 'You cannot populate the Object Type to Run or the Object ID to Run fields when the Link field is not empty.';
        LinkAndObjectErr: Label 'You cannot populate the Link field when the Object Type to Run and Object ID to Run fields fields are not empty.';
}