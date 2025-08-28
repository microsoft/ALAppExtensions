// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.D365Sales;

table 6245 "Sust. Concept"
{
    Caption = 'Concept';
    ExternalName = 'msdyn_concept';
    TableType = CRM;
    Description = 'Captures information for a specific concept';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ConceptId; Guid)
        {
            ExternalName = 'msdyn_conceptid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier for entity instances';
            Caption = 'Concept';
        }
        field(2; CreatedOn; DateTime)
        {
            ExternalName = 'createdon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was created.';
            Caption = 'Created On';
        }
        field(3; CreatedBy; Guid)
        {
            ExternalName = 'createdby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who created the record.';
            Caption = 'Created By';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(4; ModifiedOn; DateTime)
        {
            ExternalName = 'modifiedon';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'Date and time when the record was modified.';
            Caption = 'Modified On';
        }
        field(5; ModifiedBy; Guid)
        {
            ExternalName = 'modifiedby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the user who modified the record.';
            Caption = 'Modified By';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(6; CreatedOnBehalfBy; Guid)
        {
            ExternalName = 'createdonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who created the record.';
            Caption = 'Created By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(7; ModifiedOnBehalfBy; Guid)
        {
            ExternalName = 'modifiedonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who modified the record.';
            Caption = 'Modified By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(16; OwnerId; Guid)
        {
            ExternalName = 'ownerid';
            ExternalType = 'Owner';
            Description = 'Owner Id';
            Caption = 'Owner';
        }
        field(21; OwningBusinessUnit; Guid)
        {
            ExternalName = 'owningbusinessunit';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the business unit that owns the record';
            Caption = 'Owning Business Unit';
            TableRelation = "CRM Businessunit".BusinessUnitId;
        }
        field(22; OwningUser; Guid)
        {
            ExternalName = 'owninguser';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the user that owns the record.';
            Caption = 'Owning User';
            TableRelation = "CRM Systemuser".SystemUserId;
        }
        field(23; OwningTeam; Guid)
        {
            ExternalName = 'owningteam';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the team that owns the record.';
            Caption = 'Owning Team';
            TableRelation = "CRM Team".TeamId;
        }
        field(25; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Concept';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
        }
        field(27; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Concept';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
        }
        field(29; VersionNumber; BigInteger)
        {
            ExternalName = 'versionnumber';
            ExternalType = 'BigInt';
            ExternalAccess = Read;
            Description = 'Version Number';
            Caption = 'Version Number';
        }
        field(30; ImportSequenceNumber; Integer)
        {
            ExternalName = 'importsequencenumber';
            ExternalType = 'Integer';
            ExternalAccess = Insert;
            Description = 'Sequence number of the import that created this record.';
            Caption = 'Import Sequence Number';
        }
        field(31; OverriddenCreatedOn; Date)
        {
            ExternalName = 'overriddencreatedon';
            ExternalType = 'DateTime';
            ExternalAccess = Insert;
            Description = 'Date and time that the record was migrated.';
            Caption = 'Record Created On';
        }
        field(32; TimeZoneRuleVersionNumber; Integer)
        {
            ExternalName = 'timezoneruleversionnumber';
            ExternalType = 'Integer';
            Description = 'For internal use only.';
            Caption = 'Time Zone Rule Version Number';
        }
        field(33; UTCConversionTimeZoneCode; Integer)
        {
            ExternalName = 'utcconversiontimezonecode';
            ExternalType = 'Integer';
            Description = 'Time zone code that was in use when the record was created.';
            Caption = 'UTC Conversion Time Zone Code';
        }
        field(34; Name; Text[400])
        {
            ExternalName = 'msdyn_name';
            ExternalType = 'String';
            Description = 'Name';
            Caption = 'Name';
        }
        field(35; OverwriteTime; Datetime)
        {
            ExternalName = 'overwritetime';
            ExternalType = 'DateTime';
            ExternalAccess = Read;
            Description = 'For internal use only.';
            Caption = 'Record Overwrite Time';
        }
        field(36; SolutionId; Guid)
        {
            ExternalName = 'solutionid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Read;
            Description = 'Unique identifier of the associated solution.';
            Caption = 'Solution';
        }
        field(38; ComponentState; Option)
        {
            ExternalName = 'componentstate';
            ExternalType = 'Picklist';
            ExternalAccess = Read;
            Description = 'For internal use only.';
            Caption = 'Component State';
            InitValue = " ";
            OptionMembers = " ",Published,Unpublished,Deleted,DeletedUnpublished;
            OptionOrdinalValues = -1, 0, 1, 2, 3;
        }
        field(40; ComponentIdUnique; Guid)
        {
            ExternalName = 'componentidunique';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Read;
            Description = 'For internal use only.';
            Caption = 'Row Id Unique';
        }
        field(41; IsManaged; Boolean)
        {
            ExternalName = 'ismanaged';
            ExternalType = 'Boolean';
            ExternalAccess = Read;
            Description = 'Indicates whether the solution component is part of a managed solution.';
            Caption = 'Is Managed';
        }
        field(44; ConceptDataType; Option)
        {
            ExternalName = 'msdyn_conceptdatatype';
            ExternalType = 'Picklist';
            Description = 'Concept data type';
            Caption = 'Concept Data Type';
            InitValue = " ";
            OptionMembers = " ",Numeric,Text,Boolean,RichText;
            OptionOrdinalValues = -1, 419550000, 419550001, 579800001, 579800002;
        }
        field(46; ConceptDataTypeText; Text[100])
        {
            ExternalName = 'msdyn_conceptdatatypetext';
            ExternalType = 'String';
            Description = 'Concept data type (text)';
            Caption = 'Concept Data Type (Text)';
        }
        field(47; Documentation; Blob)
        {
            ExternalName = 'msdyn_documentation';
            ExternalType = 'Memo';
            Description = 'Documentation or reference to the concept';
            Caption = 'Documentation';
            Subtype = Memo;
        }
        field(48; DocumentationLink; Text[2048])
        {
            ExternalName = 'msdyn_documentationlink';
            ExternalType = 'String';
            Description = 'Documentation link';
            Caption = 'Documentation Link';
        }
        field(49; Label; Text[100])
        {
            ExternalName = 'msdyn_label';
            ExternalType = 'String';
            Description = 'Label';
            Caption = 'Label';
        }
        field(51; DisplayName; Text[400])
        {
            ExternalName = 'msdyn_displayname';
            ExternalType = 'String';
            Description = '';
            Caption = 'Display Name';
        }
        field(52; Source; Option)
        {
            ExternalName = 'msdyn_source';
            ExternalType = 'Picklist';
            Description = '';
            Caption = 'Source';
            InitValue = Custom;
            OptionMembers = Default,Custom,RequiredForCopilot,Demo;
            OptionOrdinalValues = 502640000, 502640001, 502640002, 502640003;
        }
        field(54; OriginCorrelationId; Text[100])
        {
            ExternalName = 'msdyn_origincorrelationid';
            ExternalType = 'String';
            Description = 'An optional identifier to correlate record with data origin.';
            Caption = 'Origin Correlation ID';
        }
    }
    keys
    {
        key(PK; ConceptId)
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