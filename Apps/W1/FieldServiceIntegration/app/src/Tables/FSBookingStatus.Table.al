// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6627 "FS Booking Status"
{
    ExternalName = 'bookingstatus';
    TableType = CRM;
    Description = 'Booking Status in CRM.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; BookingStatusId; GUID)
        {
            ExternalName = 'bookingstatusid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Read;
            Description = 'Unique identifier of the booking state.';
            Caption = 'Booking Status Id';
            DataClassification = SystemMetadata;
        }
        field(2; CreatedOn; Datetime)
        {
            ExternalName = 'CreatedOn';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was created.';
            Caption = 'Created On';
            DataClassification = SystemMetadata;
        }
        field(3; CreatedBy; GUID)
        {
            ExternalName = 'CreatedBy';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who created the record.';
            Caption = 'Created By';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(4; ModifiedOn; Datetime)
        {
            ExternalName = 'ModifiedOn';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was modified.';
            Caption = 'Modified On';
            DataClassification = SystemMetadata;
        }
        field(5; ModifiedBy; GUID)
        {
            ExternalName = 'ModifiedBy';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who modified the record.';
            Caption = 'Modified By';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(10; Name; Text[100])
        {
            ExternalName = 'name';
            ExternalType = 'String';
            Description = 'Type the name of the booking status.';
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(11; FieldServiceStatus; Option)
        {
            ExternalName = 'msdyn_fieldservicestatus';
            ExternalType = 'Picklist';
            Description = 'Status in Field Service.';
            OptionMembers = "",Scheduled,Traveling," On Break","In Progress",Completed,Canceled;
            OptionOrdinalValues = -1, 690970000, 690970001, 690970002, 690970003, 690970004, 690970005;
            Caption = 'Field Service Status';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; BookingStatusId)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Name)
        {
        }
    }
}