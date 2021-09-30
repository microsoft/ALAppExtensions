// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table that combines the settings defined by platform and application
/// </summary>
table 9172 "User Settings"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = SystemMetadata;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
        }
        field(3; Initialized; Boolean)
        {
            Caption = 'Initialized';
            DataClassification = SystemMetadata;
        }
        field(9; "Profile ID"; Code[30])
        {
            Caption = 'Profile ID';
            TableRelation = "All Profile"."Profile ID";
            DataClassification = SystemMetadata;
        }
        field(10; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
        }
        field(11; Scope; Option)
        {
            Caption = 'Scope';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
            DataClassification = SystemMetadata;
        }
        field(12; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            DataClassification = SystemMetadata;
        }
        field(15; Company; Text[30])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
            DataClassification = SystemMetadata;
        }
        field(27; "Locale ID"; Integer)
        {
            Caption = 'Locale ID';
            DataClassification = SystemMetadata;
        }
        field(30; "Time Zone"; Text[180])
        {
            Caption = 'Time Zone';
            DataClassification = SystemMetadata;
        }
        field(32; "Work Date"; Date)
        {
            Caption = 'Work Date';
            DataClassification = SystemMetadata;
        }
        field(34; "Last Login"; DateTime)
        {
            Caption = 'Last Login Info';
            DataClassification = SystemMetadata;
        }
        field(100; "Teaching Tips"; Boolean)
        {
            Caption = 'Teaching Tips';
            DataClassification = SystemMetadata;
        }
    }
}