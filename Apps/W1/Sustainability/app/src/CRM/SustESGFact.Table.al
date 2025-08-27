// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CRM;

using Microsoft.Integration.D365Sales;

table 6246 "Sust. ESG Fact"
{
    Caption = 'Fact';
    ExternalName = 'msdyn_esgfact';
    TableType = CRM;
    Description = 'Captures information for a specific fact';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ESGFactId; Guid)
        {
            ExternalName = 'msdyn_esgfactid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier for entity instances';
            Caption = 'Fact';
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
            Description = 'Status of the Fact';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
        }
        field(27; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Fact';
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
        field(34; Name; Text[500])
        {
            ExternalName = 'msdyn_name';
            ExternalType = 'String';
            Description = 'Name';
            Caption = 'Name';
        }
        field(37; Concept; Guid)
        {
            ExternalName = 'msdyn_concept';
            ExternalType = 'Lookup';
            Description = 'Concept';
            Caption = 'Concept';
            TableRelation = "Sust. Concept".ConceptId;
        }
        field(38; FactStatus; Option)
        {
            ExternalName = 'msdyn_factstatus';
            ExternalType = 'Picklist';
            Description = 'Fact status';
            Caption = 'Fact Status';
            InitValue = Draft;
            OptionMembers = Draft,SubmittedForApproval,Completed;
            OptionOrdinalValues = 419550000, 419550001, 419550002;
        }
        field(40; NumericValue; Decimal)
        {
            ExternalName = 'msdyn_numericvalue';
            ExternalType = 'Decimal';
            Description = 'Numeric Value';
            Caption = 'Numeric Value';
        }
        field(41; Period; Guid)
        {
            ExternalName = 'msdyn_period';
            ExternalType = 'Lookup';
            Description = 'Period';
            Caption = 'Period';
            TableRelation = "Sust. Range Period".RangePeriodId;
        }
        field(42; Precision; Integer)
        {
            ExternalName = 'msdyn_precision';
            ExternalType = 'Integer';
            Description = 'Decimals';
            Caption = 'Decimals';
        }
        field(43; TextValue; Blob)
        {
            ExternalName = 'msdyn_textvalue';
            ExternalType = 'Memo';
            Description = 'Text Value';
            Caption = 'Text Value';
            Subtype = Memo;
        }
        field(44; Unit; Guid)
        {
            ExternalName = 'msdyn_unit';
            ExternalType = 'Lookup';
            Description = 'Unit';
            Caption = 'Unit';
            TableRelation = "Sust. Unit".UnitId;
        }
        field(45; BooleanValue; Boolean)
        {
            ExternalName = 'msdyn_booleanvalue';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Boolean Value';
        }
        field(47; RichTextValue; Blob)
        {
            ExternalName = 'msdyn_richtextvalue';
            ExternalType = 'Memo';
            Description = '';
            Caption = 'Rich Text Value';
            Subtype = Memo;
        }
        field(48; Source; Option)
        {
            ExternalName = 'msdyn_source';
            ExternalType = 'Picklist';
            Description = 'Represents where the fact value came from';
            Caption = 'Source';
            InitValue = " ";
            OptionMembers = " ",BusinessCentral,CopilotGenerated,MicrosoftSustainabilityManager,SDSF;
            OptionOrdinalValues = -1, 419550000, 419550001, 419550002, 419550003;
        }
        field(50; AccuracyReviewed; Boolean)
        {
            ExternalName = 'msdyn_accuracyreviewed';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Reviewed For Accuracy';
        }
        field(52; CopilotGenerated; Boolean)
        {
            ExternalName = 'msdyn_copilotgenerated';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Found With Copilot';
        }
        field(54; OriginCorrelationId; Text[100])
        {
            ExternalName = 'msdyn_origincorrelationid';
            ExternalType = 'String';
            Description = 'An optional identifier to correlate record with data origin.';
            Caption = 'Origin Correlation ID';
        }
        field(55; FactGenerationPartialSuccess; Boolean)
        {
            ExternalName = 'msdyn_factgenerationpartialsuccess';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Fact Generation Partial Success';
        }
        field(60; PeriodName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sust. Range Period".Name where(RangePeriodId = field(Period)));
            ExternalName = 'msdyn_periodname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(65; ConceptName; Text[400])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sust. Concept".Name where(ConceptId = field(Concept)));
            ExternalName = 'msdyn_conceptname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(70; UnitName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sust. Unit".Name where(UnitId = field(Unit)));
            ExternalName = 'msdyn_unitname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
    }
    keys
    {
        key(PK; ESGFactId)
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