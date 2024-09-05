// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6622 "FS Work Order Type"
{
    ExternalName = 'msdyn_workordertype';
    TableType = CRM;
    Description = 'Create different work order types to reflect the different types of work that your company offers. Work Order types are used to control various settings on a work order.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; WorkOrderTypeId; GUID)
        {
            ExternalName = 'msdyn_workordertypeid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Shows the entity instances.';
            Caption = 'Work Order Type';
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
            Description = 'Status of the Work Order Type';
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
            Description = 'Reason for the status of the Work Order Type';
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
            Description = 'Type the name of the work order type.';
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(35; IncidentRequired; Boolean)
        {
            ExternalName = 'msdyn_incidentrequired';
            ExternalType = 'Boolean';
            Description = 'Select whether work orders of this type require an incident to be recorded on the work order.';
            Caption = 'Incident Required';
            DataClassification = SystemMetadata;
        }
        field(37; PriceList; GUID)
        {
            ExternalName = 'msdyn_pricelist';
            ExternalType = 'Lookup';
            Description = 'Default Price List to be used on Work Orders linked to this Work Order Type. Please review the help for further details on Price Lists';
            Caption = 'Price List';
            TableRelation = "CRM Pricelevel".PriceLevelId;
            DataClassification = SystemMetadata;
        }
        field(38; Taxable; Boolean)
        {
            ExternalName = 'msdyn_taxable';
            ExternalType = 'Boolean';
            Description = 'Select whether work orders of this type are taxable.';
            Caption = 'Taxable';
            DataClassification = SystemMetadata;
        }
        field(40; Code; Text[10])
        {
            ExternalName = 'bcbi_code';
            ExternalType = 'String';
            Description = 'Type the code of the work order type.';
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(41; IntegrateToService; Boolean)
        {
            ExternalName = 'bcbi_integratetoservice';
            ExternalType = 'Boolean';
            Description = 'Select whether work orders of this type are integrated to service.';
            Caption = 'Integrate To Service';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; workordertypeId)
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