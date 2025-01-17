// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

#pragma warning disable AS0130
#pragma warning disable PTE0025
table 6613 "FS Customer Asset"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    ExternalName = 'msdyn_customerasset';
    TableType = CRM;
    Description = 'Specify Customer Asset.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; CustomerAssetId; GUID)
        {
            ExternalName = 'msdyn_customerassetid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Shows the entity instances.';
            Caption = 'Customer Asset';
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
            Description = 'Status of the Customer Asset';
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
            Description = 'Reason for the status of the Customer Asset';
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
        field(36; Account; GUID)
        {
            ExternalName = 'msdyn_account';
            ExternalType = 'Lookup';
            Description = 'Parent Customer of this Asset';
            Caption = 'Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(37; CustomerAssetCategory; GUID)
        {
            ExternalName = 'msdyn_customerassetcategory';
            ExternalType = 'Lookup';
            Description = 'The category of the customer asset';
            Caption = 'Category';
            TableRelation = "FS Customer Asset Category".CustomerAssetCategoryId;
            DataClassification = SystemMetadata;
        }
        field(38; Latitude; Decimal)
        {
            ExternalName = 'msdyn_latitude';
            ExternalType = 'Double';
            Description = '';
            Caption = 'Latitude';
            DataClassification = SystemMetadata;
        }
        field(39; Longitude; Decimal)
        {
            ExternalName = 'msdyn_longitude';
            ExternalType = 'Double';
            Description = '';
            Caption = 'Longitude';
            DataClassification = SystemMetadata;
        }
        field(40; MasterAsset; GUID)
        {
            ExternalName = 'msdyn_masterasset';
            ExternalType = 'Lookup';
            Description = 'Top-Level Asset, (if this asset is a sub asset)';
            Caption = 'Top-Level Asset';
            TableRelation = "FS Customer Asset".CustomerAssetId;
            DataClassification = SystemMetadata;
        }
        field(41; ParentAsset; GUID)
        {
            ExternalName = 'msdyn_parentasset';
            ExternalType = 'Lookup';
            Description = 'Parent Asset';
            Caption = 'Parent Asset';
            TableRelation = "FS Customer Asset".CustomerAssetId;
            DataClassification = SystemMetadata;
        }
        field(42; Product; GUID)
        {
            ExternalName = 'msdyn_product';
            ExternalType = 'Lookup';
            Description = 'Reference to Product associated with this Asset';
            Caption = 'Product';
            TableRelation = "CRM Product".ProductId;
            DataClassification = SystemMetadata;
        }
        field(46; MasterAssetName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset".Name where(CustomerAssetId = field(MasterAsset)));
            ExternalName = 'msdyn_masterassetname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(47; ParentAssetName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset".Name where(CustomerAssetId = field(ParentAsset)));
            ExternalName = 'msdyn_parentassetname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(48; CustomerAssetCategoryName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset Category".Name where(CustomerAssetCategoryId = field(CustomerAssetCategory)));
            ExternalName = 'msdyn_customerassetcategoryname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(50; DeviceId; Text[100])
        {
            ExternalName = 'msdyn_deviceid';
            ExternalType = 'String';
            Description = 'Device ID used to register with the IoT provider. This will not be used if there are two or more connected devices for this asset. This value will be updated based on the connected devices.';
            Caption = 'Device ID';
            DataClassification = SystemMetadata;
        }
        field(52; LastCommandSentTime; Date)
        {
            ExternalName = 'msdyn_lastcommandsenttime';
            ExternalType = 'DateTime';
            Description = 'The timestamp of the last command sent for any of the connected devices for this asset.';
            Caption = 'Last Command Sent Time';
            DataClassification = SystemMetadata;
        }
        field(53; RegistrationStatus; Option)
        {
            ExternalName = 'msdyn_registrationstatus';
            ExternalType = 'Picklist';
            Description = 'A status field that denotes whether all the devices connected to this asset are registered with the IoT provider.';
            Caption = 'Registration Status';
            InitValue = " ";
            OptionMembers = " ",Unknown,Unregistered,InProgress,Registered,Error;
            OptionOrdinalValues = -1, 192350000, 192350001, 192350002, 192350003, 192350004;
            DataClassification = SystemMetadata;
        }
        field(56; Alert; Boolean)
        {
            ExternalName = 'msdyn_alert';
            ExternalType = 'Boolean';
            ExternalAccess = Read;
            Description = 'If active parent alerts exist for the customer asset';
            Caption = 'Active or in-progress alerts';
            DataClassification = SystemMetadata;
        }
        field(58; AlertCount; Integer)
        {
            ExternalName = 'msdyn_alertcount';
            ExternalType = 'Integer';
            ExternalAccess = Read;
            Description = 'Count of parent alerts for this customer asset';
            Caption = 'Alert Count';
            DataClassification = SystemMetadata;
        }
        field(59; AalertCount_Date; Datetime)
        {
            ExternalName = 'msdyn_alertcount_date';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Last Updated time of rollup field Alert Count.';
            Caption = 'Alert Count (Last Updated On)';
            DataClassification = SystemMetadata;
        }
        field(60; AlertCount_State; Integer)
        {
            ExternalName = 'msdyn_alertcount_state';
            ExternalType = 'Integer';
            ExternalAccess = Read;
            Description = 'State of rollup field Alert Count.';
            Caption = 'Alert Count (State)';
            DataClassification = SystemMetadata;
        }
        field(61; LastAlertTime; Datetime)
        {
            ExternalName = 'msdyn_lastalerttime';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = '';
            Caption = 'Last active alert time';
            DataClassification = SystemMetadata;
        }
        field(62; LastAlertTime_Date; Datetime)
        {
            ExternalName = 'msdyn_lastalerttime_date';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Last Updated time of rollup field Last active alert time.';
            Caption = 'Last active alert time (Last Updated On)';
            DataClassification = SystemMetadata;
        }
        field(63; LastAlertTime_State; Integer)
        {
            ExternalName = 'msdyn_lastalerttime_state';
            ExternalType = 'Integer';
            ExternalAccess = Read;
            Description = 'State of rollup field Last active alert time.';
            Caption = 'Last active alert time (State)';
            DataClassification = SystemMetadata;
        }
        field(64; AssetTag; Text[100])
        {
            ExternalName = 'msdyn_assettag';
            ExternalType = 'String';
            Description = '';
            Caption = 'Asset Tag';
            DataClassification = SystemMetadata;
        }
        field(66; WorkOrderProduct; GUID)
        {
            ExternalName = 'msdyn_workorderproduct';
            ExternalType = 'Lookup';
            Description = 'Indicates a link to the Work Order Product from where this Asset was auto created by the system.';
            Caption = 'Work Order Product';
            TableRelation = "FS Work Order Product".WorkOrderProductId;
            DataClassification = SystemMetadata;
        }
        field(67; WorkOrderProductName; Text[200])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order Product".Name where(WorkOrderProductId = field(WorkOrderProduct)));
            ExternalName = 'msdyn_workorderproductname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(68; CompanyId; GUID)
        {
            ExternalName = 'bcbi_company';
            ExternalType = 'Lookup';
            Description = 'Business Central Company';
            Caption = 'Company Id';
            TableRelation = "CDS Company".CompanyId;
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; customerassetId)
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