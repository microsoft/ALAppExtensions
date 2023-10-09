// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

using System.Reflection;

/// <summary>
/// Contains web services aggregated from Web Services and Tenant Web Services.
/// </summary>
table 9900 "Web Service Aggregate"
{
    Caption = 'Web Service Aggregate';
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;
    Access = Public;

    fields
    {
        field(3; "Object Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Object Type';
            OptionCaption = ',,,,,Codeunit,,,Page,Query';
            OptionMembers = ,,,,,"Codeunit",,,"Page","Query";
        }
        field(6; "Object ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Object ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("Object Type"));
        }
        field(9; "Service Name"; Text[240])
        {
            DataClassification = CustomerContent;
            Caption = 'Service Name';

            trigger OnValidate()
            var
                WebServiceManagementImpl: Codeunit "Web Service Management Impl.";
            begin
                WebServiceManagementImpl.AssertServiceNameIsValid("Service Name");
            end;
        }
        field(12; Published; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Published';
        }
        field(13; ExcludeFieldsOutsideRepeater; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Exclude Fields Outside of the Repeater';
        }
        field(14; ExcludeNonEditableFlowFields; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Exclude Non-Editable FlowFields';
        }
        field(15; "All Tenants"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'All Tenants';
        }
    }

    keys
    {
        key(Key1; "Object Type", "Service Name")
        {
            Clustered = true;
        }
        key(Key2; "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WebServiceManagementImpl: Codeunit "Web Service Management Impl.";
    begin
        WebServiceManagementImpl.DeleteWebService(Rec);
    end;

    trigger OnInsert()
    var
        WebServiceManagementImpl: Codeunit "Web Service Management Impl.";
    begin
        WebServiceManagementImpl.VerifyRecord(Rec);
        WebServiceManagementImpl.AssertUniquePublishedServiceName(Rec, xRec);
        WebServiceManagementImpl.AssertUniqueUnpublishedObject(Rec);
        WebServiceManagementImpl.InsertWebService(Rec);
    end;

    trigger OnModify()
    var
        WebServiceManagementImpl: Codeunit "Web Service Management Impl.";
    begin
        WebServiceManagementImpl.VerifyRecord(Rec);
        WebServiceManagementImpl.AssertUniquePublishedServiceName(Rec, xRec);
        WebServiceManagementImpl.ModifyWebService(Rec, xRec);
    end;

    trigger OnRename()
    var
        WebServiceManagementImpl: Codeunit "Web Service Management Impl.";
    begin
        WebServiceManagementImpl.AssertUniquePublishedServiceName(Rec, xRec);
        WebServiceManagementImpl.RenameWebService(Rec, xRec);
    end;
}