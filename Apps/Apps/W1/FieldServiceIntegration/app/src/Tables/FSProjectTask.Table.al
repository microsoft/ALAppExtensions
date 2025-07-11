// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

#pragma warning disable AS0130
#pragma warning disable PTE0025
table 6615 "FS Project Task"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    ExternalName = 'bcbi_projecttask';
    TableType = CRM;
    Description = 'An entity for storing the Microsoft Dynamics 365 Business Central project task.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ProjectTaskId; GUID)
        {
            ExternalName = 'bcbi_projecttaskid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier for entity instances.';
            Caption = 'Business Central Project Task';
            DataClassification = SystemMetadata;
        }
        field(2; CreatedOn; Datetime)
        {
            ExternalName = 'createdon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was created.';
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
            TableRelation = "CRM SystemUser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(4; ModifiedOn; Datetime)
        {
            ExternalName = 'modifiedon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was modified.';
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
            TableRelation = "CRM SystemUser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(6; CreatedOnBehalfBy; GUID)
        {
            ExternalName = 'createdonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who created the record.';
            Caption = 'Created By (Delegate)';
            TableRelation = "CRM SystemUser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(7; ModifiedOnBehalfBy; GUID)
        {
            ExternalName = 'modifiedonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who modified the record.';
            Caption = 'Modified By (Delegate)';
            TableRelation = "CRM SystemUser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(8; CreatedByName; Text[200])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("CRM SystemUser".FullName where(SystemUserId = field(CreatedBy)));
            ExternalName = 'createdbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(10; CreatedOnBehalfByName; Text[200])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("CRM SystemUser".FullName where(SystemUserId = field(CreatedOnBehalfBy)));
            ExternalName = 'createdonbehalfbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(12; ModifiedByName; Text[200])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("CRM Systemuser".FullName where(SystemUserId = field(ModifiedBy)));
            ExternalName = 'modifiedbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(14; ModifiedOnBehalfByName; Text[200])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("CRM Systemuser".FullName where(SystemUserId = field(ModifiedOnBehalfBy)));
            ExternalName = 'modifiedonbehalfbyname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(18; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Business Central Project Task';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
            DataClassification = SystemMetadata;
        }
        field(20; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Business Central Project Task';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
            DataClassification = SystemMetadata;
        }
        field(22; VersionNumber; BigInteger)
        {
            ExternalName = 'versionnumber';
            ExternalType = 'BigInt';
            ExternalAccess = Read;
            Description = 'Version Number';
            Caption = 'Version Number';
            DataClassification = SystemMetadata;
        }
        field(23; ImportSequenceNumber; Integer)
        {
            ExternalName = 'importsequencenumber';
            ExternalType = 'Integer';
            ExternalAccess = Insert;
            Description = 'Sequence number of the import that created this record.';
            Caption = 'Import Sequence Number';
            DataClassification = SystemMetadata;
        }
        field(24; OverriddenCreatedOn; Date)
        {
            ExternalName = 'overriddencreatedon';
            ExternalType = 'DateTime';
            ExternalAccess = Insert;
            Description = 'Date and time that the record was migrated.';
            Caption = 'Record Created On';
            DataClassification = SystemMetadata;
        }
        field(25; TimeZoneRuleVersionNumber; Integer)
        {
            ExternalName = 'timezoneruleversionnumber';
            ExternalType = 'Integer';
            Description = 'For internal use only.';
            Caption = 'Time Zone Rule Version Number';
            DataClassification = SystemMetadata;
        }
        field(26; UTCConversionTimeZoneCode; Integer)
        {
            ExternalName = 'utcconversiontimezonecode';
            ExternalType = 'Integer';
            Description = 'Time zone code that was in use when the record was created.';
            Caption = 'UTC Conversion Time Zone Code';
            DataClassification = SystemMetadata;
        }
        field(27; Description; Text[250])
        {
            ExternalName = 'bcbi_projecttaskdescription';
            ExternalType = 'String';
            Description = 'Business Central Project Task Description';
            Caption = 'Business Central Project Task Description';
            DataClassification = SystemMetadata;
        }
        field(28; ProjectNumber; Text[250])
        {
            ExternalName = 'bcbi_projectnumber';
            ExternalType = 'String';
            Description = 'Business Central Project Number';
            Caption = 'Business Central Project Number';
            DataClassification = SystemMetadata;
        }
        field(29; ProjectTaskNumber; Text[250])
        {
            ExternalName = 'bcbi_projecttasknumber';
            ExternalType = 'String';
            Description = 'Business Central Project Task Number';
            Caption = 'Business Central Project Task Number';
            DataClassification = SystemMetadata;
        }
        field(30; ProjectDescription; Text[250])
        {
            ExternalName = 'bcbi_projectdescription';
            ExternalType = 'String';
            Description = 'Business Central Project Description';
            Caption = 'Business Central Project Description';
            DataClassification = SystemMetadata;
        }
        field(31; ServiceAccountId; GUID)
        {
            ExternalName = 'bcbi_serviceaccountid';
            ExternalType = 'Lookup';
            Description = 'Account to be serviced';
            Caption = 'Service Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(32; BillingAccountId; GUID)
        {
            ExternalName = 'bcbi_billingaccountid';
            ExternalType = 'Lookup';
            Description = 'Account to be billed';
            Caption = 'Billing Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(33; CompanyId; GUID)
        {
            ExternalName = 'bcbi_companyid';
            ExternalType = 'Lookup';
            Description = 'The unique identifier of the company associated with the project task.';
            Caption = 'Company';
            TableRelation = "CDS Company".CompanyId;
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; ProjectTaskId)
        {
            Clustered = true;
        }
        key(Name; Description)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {
        }
    }
}