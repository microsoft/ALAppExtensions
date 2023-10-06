// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Media;
using System.Globalization;
using System.Apps;

table 1803 "Assisted Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Assisted Setup';
    ReplicateData = false;
    ObsoleteState = Removed;
    ObsoleteTag = '23.0';
    ObsoleteReason = 'The Assisted Setup module and its objects have been consolidated in the Guided Experience module. Use the Guided Experience Item table instead.';

    fields
    {
        field(1; "Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Page ID';
        }
        field(2; Name; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(3; "Order"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Order';
            ObsoleteState = Removed;
            ObsoleteReason = 'Order cannot be determined at compile time because the extensions that add to the table are unknown and can insert records in any order.';
            ObsoleteTag = '19.0';
        }
        field(4; Status; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Status';
            OptionCaption = 'Not Completed,Completed,Not Started,Seen,Watched,Read, ';
            OptionMembers = "Not Completed",Completed,"Not Started",Seen,Watched,Read," ";
            ObsoleteState = Removed;
            ObsoleteReason = 'Only option used is Complete- new boolean field with that name created.';
            ObsoleteTag = '19.0';
        }
        field(5; Visible; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Visible';
            ObsoleteState = Removed;
            ObsoleteReason = 'Only those setup records that are visible should be added.';
            ObsoleteTag = '19.0';
        }
        field(6; Parent; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent';
            ObsoleteState = Removed;
            ObsoleteReason = 'Hierarchy is removed. Instead the Group Name is populated for each record.';
            ObsoleteTag = '19.0';
        }
        field(7; "Video Url"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Video Url';
        }
        field(8; Icon; Media)
        {
            DataClassification = SystemMetadata;
            Caption = 'Icon';
        }
        field(9; "Item Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Item Type';
            InitValue = "Setup and Help";
            OptionCaption = ' ,Group,Setup and Help';
            OptionMembers = " ",Group,"Setup and Help";
            ObsoleteState = Removed;
            ObsoleteReason = 'No group type items anymore. Use the Group Name field instead.';
            ObsoleteTag = '19.0';
        }
        field(10; Featured; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Featured';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used in any UI component.';
            ObsoleteTag = '19.0';
        }
        field(11; "Help Url"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Help Url';
        }
        field(12; "Assisted Setup Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Assisted Setup Page ID';
            ObsoleteState = Removed;
            ObsoleteReason = 'Redundant field- duplication of Page ID field.';
            ObsoleteTag = '19.0';
        }
        field(13; "Tour Id"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Tour Id';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used in any UI component.';
            ObsoleteTag = '19.0';
        }
        field(14; "Video Status"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Video Status';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not needed to track if user has seen video.';
            ObsoleteTag = '19.0';
        }
        field(15; "Help Status"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Help Status';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not needed to track if user has seen help.';
            ObsoleteTag = '19.0';
        }
        field(16; "Tour Status"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Tour Status';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used in any UI component.';
            ObsoleteTag = '19.0';
        }
        field(19; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; "Extension Name"; Text[250])
        {
            Caption = 'Extension Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Published Application".Name where(ID = field("App ID"), "Tenant Visible" = const(true)));
            Editable = false;
        }
        field(21; "Group Name"; Enum "Assisted Setup Group")
        {
            DataClassification = SystemMetadata;
            Caption = 'Group';
            Editable = false;
        }
        field(22; Completed; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Completed';
            Editable = false;
        }
        field(23; "Video Category"; Enum "Video Category")
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(24; Description; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Page ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Translation: Codeunit Translation;
    begin
        Translation.Delete(Rec);
    end;
}

