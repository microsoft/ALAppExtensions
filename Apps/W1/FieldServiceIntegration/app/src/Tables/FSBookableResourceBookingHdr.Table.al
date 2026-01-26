// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

#pragma warning disable AS0130
#pragma warning disable PTE0025
table 6612 "FS BookableResourceBookingHdr"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    ExternalName = 'bookableresourcebookingheader';
    TableType = CRM;
    Description = 'Reservation entity representing the summary of the associated resource bookings.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; BookableResourceBookingHeaderId; GUID)
        {
            ExternalName = 'bookableresourcebookingheaderid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier of the resource booking header.';
            Caption = 'Bookable Resource Booking Header';
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
            TableRelation = "CRM Systemuser".SystemUserId;
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
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(6; CreatedOnBehalfBy; GUID)
        {
            ExternalName = 'createdonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who created the record.';
            Caption = 'Created By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(7; ModifiedOnBehalfBy; GUID)
        {
            ExternalName = 'modifiedonbehalfby';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the delegate user who modified the record.';
            Caption = 'Modified By (Delegate)';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(15; OwnerId; GUID)
        {
            ExternalName = 'ownerid';
            ExternalType = 'Owner';
            Description = 'Owner Id';
            Caption = 'Owner';
            DataClassification = SystemMetadata;
        }
        field(20; OwningBusinessUnit; GUID)
        {
            ExternalName = 'owningbusinessunit';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the business unit that owns the record';
            Caption = 'Owning Business Unit';
            TableRelation = "CRM Businessunit".BusinessUnitId;
            DataClassification = SystemMetadata;
        }
        field(21; OwningUser; GUID)
        {
            ExternalName = 'owninguser';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the user that owns the record.';
            Caption = 'Owning User';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(22; OwningTeam; GUID)
        {
            ExternalName = 'owningteam';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier for the team that owns the record.';
            Caption = 'Owning Team';
            TableRelation = "CRM Team".TeamId;
            DataClassification = SystemMetadata;
        }
        field(24; VersionNumber; BigInteger)
        {
            ExternalName = 'versionnumber';
            ExternalType = 'BigInt';
            ExternalAccess = Read;
            Description = 'Version Number';
            Caption = 'Version Number';
            DataClassification = SystemMetadata;
        }
        field(25; ImportSequenceNumber; Integer)
        {
            ExternalName = 'importsequencenumber';
            ExternalType = 'Integer';
            ExternalAccess = Insert;
            Description = 'Sequence number of the import that created this record.';
            Caption = 'Import Sequence Number';
            DataClassification = SystemMetadata;
        }
        field(26; OverriddenCreatedOn; Date)
        {
            ExternalName = 'overriddencreatedon';
            ExternalType = 'DateTime';
            ExternalAccess = Insert;
            Description = 'Date and time that the record was migrated.';
            Caption = 'Record Created On';
            DataClassification = SystemMetadata;
        }
        field(27; TimeZoneRuleVersionNumber; Integer)
        {
            ExternalName = 'timezoneruleversionnumber';
            ExternalType = 'Integer';
            Description = 'For internal use only.';
            Caption = 'Time Zone Rule Version Number';
            DataClassification = SystemMetadata;
        }
        field(28; UTCConversionTimeZoneCode; Integer)
        {
            ExternalName = 'utcconversiontimezonecode';
            ExternalType = 'Integer';
            Description = 'Time zone code that was in use when the record was created.';
            Caption = 'UTC Conversion Time Zone Code';
            DataClassification = SystemMetadata;
        }
        field(29; Name; Text[100])
        {
            ExternalName = 'name';
            ExternalType = 'String';
            Description = 'The name of the booking summary.';
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(30; ProcessId; GUID)
        {
            ExternalName = 'processid';
            ExternalType = 'Uniqueidentifier';
            Description = 'Contains the id of the process associated with the entity.';
            Caption = 'Process Id';
            DataClassification = SystemMetadata;
        }
        field(31; StageId; GUID)
        {
            ExternalName = 'stageid';
            ExternalType = 'Uniqueidentifier';
            Description = 'Contains the id of the stage where the entity is located.';
            Caption = '(Deprecated) Stage Id';
            DataClassification = SystemMetadata;
        }
        field(32; TraversedPath; Text[1250])
        {
            ExternalName = 'traversedpath';
            ExternalType = 'String';
            Description = 'A comma separated list of string values representing the unique identifiers of stages in a Business Process Flow Instance in the order that they occur.';
            Caption = '(Deprecated) Traversed Path';
            DataClassification = SystemMetadata;
        }
        field(33; Duration; Integer)
        {
            ExternalName = 'duration';
            ExternalType = 'Integer';
            Description = 'Shows the aggregate duration of the linked bookings.';
            Caption = 'Duration';
            DataClassification = SystemMetadata;
        }
        field(34; EndTime; Datetime)
        {
            ExternalName = 'endtime';
            ExternalType = 'DateTime';
            Description = 'Shows the end date and time of the booking summary.';
            Caption = 'End Time';
            DataClassification = SystemMetadata;
        }
        field(35; StartTime; Datetime)
        {
            ExternalName = 'starttime';
            ExternalType = 'DateTime';
            Description = 'Shows the start date and time of the booking summary.';
            Caption = 'Start Time';
            DataClassification = SystemMetadata;
        }
        field(36; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Bookable Resource Booking Header';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
            DataClassification = SystemMetadata;
        }
        field(38; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Bookable Resource Booking Header';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
            DataClassification = SystemMetadata;
        }
        field(40; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            Description = 'Exchange rate for the currency associated with the bookableresourcebookingheader with respect to the base currency.';
            Caption = 'ExchangeRate';
            DataClassification = SystemMetadata;
            AutoFormatType = 0;
        }
        field(41; TransactionCurrencyId; GUID)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            Description = 'Exchange rate for the currency associated with the BookableResourceBookingHeader with respect to the base currency.';
            Caption = 'Currency';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
            DataClassification = SystemMetadata;
        }
        field(43; BookableResourceId; GUID)
        {
            ExternalName = 'msdyn_bookableresourceid';
            ExternalType = 'Lookup';
            Description = 'Bookable Resource';
            Caption = 'Bookable Resource';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(45; BookingType; Option)
        {
            ExternalName = 'msdyn_bookingtype';
            ExternalType = 'Picklist';
            Description = 'Select whether the booking is solid or liquid. Solid bookings are firm and cannot be changed whereas liquid bookings can be changed.';
            Caption = 'Booking Type';
            InitValue = Solid;
            OptionMembers = Solid,Liquid;
            OptionOrdinalValues = 1, 2;
            DataClassification = SystemMetadata;
        }
        field(48; BookableResourceIdName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(BookableResourceId)));
            ExternalName = 'msdyn_bookableresourceidname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
    }
    keys
    {
        key(PK; BookableResourceBookingHeaderId)
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