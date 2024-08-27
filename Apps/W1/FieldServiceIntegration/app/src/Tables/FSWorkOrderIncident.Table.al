// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6618 "FS Work Order Incident"
{
    ExternalName = 'msdyn_workorderincident';
    TableType = CRM;
    Description = 'Specify work order incidents reported to you by the client. These are also referred to as problem codes.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; WorkOrderIncidentId; GUID)
        {
            ExternalName = 'msdyn_workorderincidentid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Shows the entity instances.';
            Caption = 'Work Order Incident';
            DataClassification = SystemMetadata;
        }
        field(2; CreatedOn; Datetime)
        {
            ExternalName = 'createdon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Shows the date and time when the record was created. The date and time are displayed in the time zone selected in Microsoft Dynamics 365 options.';
            Caption = 'Created On';
            DataClassification = SystemMetadata;
        }
        field(3; CreatedBy; GUID)
        {
            ExternalName = 'createdby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who created the record.';
            Caption = 'Created By';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(4; ModifiedOn; Datetime)
        {
            ExternalName = 'modifiedon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Shows the date and time when the record was last updated. The date and time are displayed in the time zone selected in Microsoft Dynamics 365 options.';
            Caption = 'Modified On';
            DataClassification = SystemMetadata;
        }
        field(5; ModifiedBy; GUID)
        {
            ExternalName = 'modifiedby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who modified the record.';
            Caption = 'Modified By';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(6; CreatedOnBehalfBy; GUID)
        {
            ExternalName = 'createdonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Shows who created the record on behalf of another user.';
            Caption = 'Created By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(7; ModifiedOnBehalfBy; GUID)
        {
            ExternalName = 'modifiedonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Shows who last updated the record on behalf of another user.';
            Caption = 'Modified By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(16; OwnerId; GUID)
        {
            ExternalName = 'ownerid';
            ExternalType = 'Owner';
            Description = 'Owner Id';
            Caption = 'Owner';
            DataClassification = SystemMetadata;
        }
        field(21; OwningBusinessUnit; GUID)
        {
            ExternalName = 'owningbusinessunit';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the business unit that owns the record';
            Caption = 'Owning Business Unit';
            TableRelation = "CRM Businessunit".BusinessUnitId;
            DataClassification = SystemMetadata;
        }
        field(22; OwningUser; GUID)
        {
            ExternalName = 'owninguser';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the user that owns the record.';
            Caption = 'Owning User';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(23; OwningTeam; GUID)
        {
            ExternalName = 'owningteam';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the team that owns the record.';
            Caption = 'Owning Team';
            TableRelation = "CRM Team".TeamId;
            DataClassification = SystemMetadata;
        }
        field(25; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Work Order Incident';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
            DataClassification = SystemMetadata;
        }
        field(27; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Work Order Incident';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
            DataClassification = SystemMetadata;
        }
        field(29; VersionNumber; BigInteger)
        {
            ExternalName = 'versionnumber';
            ExternalType = 'BigInt';
            ExternalAccess = Read;
            Description = 'Version Number';
            Caption = 'Version Number';
            DataClassification = SystemMetadata;
        }
        field(30; ImportSequenceNumber; Integer)
        {
            ExternalName = 'importsequencenumber';
            ExternalType = 'Integer';
            ExternalAccess = Insert;
            Description = 'Shows the sequence number of the import that created this record.';
            Caption = 'Import Sequence Number';
            DataClassification = SystemMetadata;
        }
        field(31; OverriddenCreatedOn; Date)
        {
            ExternalName = 'overriddencreatedon';
            ExternalType = 'DateTime';
            ExternalAccess = Insert;
            Description = 'Shows the date and time that the record was migrated.';
            Caption = 'Record Created On';
            DataClassification = SystemMetadata;
        }
        field(32; TimeZoneRuleVersionNumber; Integer)
        {
            ExternalName = 'timezoneruleversionnumber';
            ExternalType = 'Integer';
            Description = 'For internal use only.';
            Caption = 'Time Zone Rule Version Number';
            DataClassification = SystemMetadata;
        }
        field(33; UTCConversionTimeZoneCode; Integer)
        {
            ExternalName = 'utcconversiontimezonecode';
            ExternalType = 'Integer';
            Description = 'Shows the time zone code that was in use when the record was created.';
            Caption = 'UTC Conversion Time Zone Code';
            DataClassification = SystemMetadata;
        }
        field(34; Name; Text[100])
        {
            ExternalName = 'msdyn_name';
            ExternalType = 'String';
            Description = 'Enter the name of the custom entity.';
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(36; CustomerAsset; GUID)
        {
            ExternalName = 'msdyn_customerasset';
            ExternalType = 'Lookup';
            Description = 'Customer Asset related to this incident reported';
            Caption = 'Customer Asset';
            TableRelation = "FS Customer Asset".CustomerAssetId;
            DataClassification = SystemMetadata;
        }
        field(37; Description; BLOB)
        {
            ExternalName = 'msdyn_description';
            ExternalType = 'Memo';
            Description = 'Incident description';
            Caption = 'Description';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(38; EstimatedDuration; Integer)
        {
            ExternalName = 'msdyn_estimatedduration';
            ExternalType = 'Integer';
            Description = 'Shows the time estimated to resolve this incident.';
            Caption = 'Estimated Duration';
            DataClassification = SystemMetadata;
        }
        field(39; IncidentResolved; Boolean)
        {
            ExternalName = 'msdyn_incidentresolved';
            ExternalType = 'Boolean';
            Description = 'Shows if the incident has been resolved by one of its related tasks.';
            Caption = 'Incident Resolved';
            DataClassification = SystemMetadata;
        }
        field(42; InternalFlags; BLOB)
        {
            ExternalName = 'msdyn_internalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(43; IsMobile; Boolean)
        {
            ExternalName = 'msdyn_ismobile';
            ExternalType = 'Boolean';
            Caption = 'Is Mobile';
            DataClassification = SystemMetadata;
        }
        field(45; IsPrimary; Boolean)
        {
            ExternalName = 'msdyn_isprimary';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Is Primary';
            DataClassification = SystemMetadata;
        }
        field(47; ItemsPopulated; Boolean)
        {
            ExternalName = 'msdyn_itemspopulated';
            ExternalType = 'Boolean';
            Caption = 'Items Populated';
            DataClassification = SystemMetadata;
        }
        field(50; TasksPercentCompleted; Decimal)
        {
            ExternalName = 'msdyn_taskspercentcompleted';
            ExternalType = 'Double';
            Description = 'Shows the percent completed on associated tasks. This indicates the total of completed tasks, but not if the incident was resolved.';
            Caption = 'Tasks % Completed';
            DataClassification = SystemMetadata;
        }
        field(51; WorkOrder; GUID)
        {
            ExternalName = 'msdyn_workorder';
            ExternalType = 'Lookup';
            Description = 'Parent Work Order where incident was reported on';
            Caption = 'Work Order';
            TableRelation = "FS Work Order".WorkOrderId;
            DataClassification = SystemMetadata;
        }
        field(53; CustomerAssetName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset".Name where(CustomerAssetId = field(CustomerAsset)));
            ExternalName = 'msdyn_customerassetname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(56; WorkOrderName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order".Name where(WorkOrderId = field(WorkOrder)));
            ExternalName = 'msdyn_workordername';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(60; IncidentType; Guid)
        {
            ExternalName = 'msdyn_incidenttype';
            ExternalType = 'Lookup';
            Caption = 'Incident Type';
            TableRelation = "FS Incident Type".IncidentTypeId;
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; WorkOrderIncidentId)
        {
            Clustered = true;
        }
        key(Name; Name)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Name)
        {
        }
    }
}