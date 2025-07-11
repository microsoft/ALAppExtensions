// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;
using Microsoft.Integration.Dataverse;

#pragma warning disable AS0130, PTE0025
table 6610 "FS Bookable Resource"
#pragma warning restore AS0130, PTE0025
{
    ExternalName = 'bookableresource';
    TableType = CRM;
    Description = 'Resource that has capacity which can be allocated to work.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; BookableResourceId; GUID)
        {
            ExternalName = 'bookableresourceid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier of the resource.';
            Caption = 'Bookable Resource';
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
            Description = 'Type the name of the resource.';
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
        field(33; AccountId; GUID)
        {
            ExternalName = 'accountid';
            ExternalType = 'Lookup';
            Description = 'Select the account that represents this resource.';
            Caption = 'Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(35; ContactId; GUID)
        {
            ExternalName = 'contactid';
            ExternalType = 'Lookup';
            Description = 'Select the contact that represents this resource.';
            Caption = 'Contact';
            TableRelation = "CRM Contact".ContactId;
            DataClassification = SystemMetadata;
        }
        field(36; ResourceType; Option)
        {
            ExternalName = 'resourcetype';
            ExternalType = 'Picklist';
            ExternalAccess = Insert;
            Description = 'Select whether the resource is a user, equipment, contact, account, generic resource or a group of resources.';
            Caption = 'Resource Type';
            InitValue = User;
            OptionMembers = Generic,Contact,User,Equipment,Account,Crew,Facility,Pool;
            OptionOrdinalValues = 1, 2, 3, 4, 5, 6, 7, 8;
            DataClassification = SystemMetadata;
        }
        field(38; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Bookable Resource';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
            DataClassification = SystemMetadata;
        }
        field(40; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Bookable Resource';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
            DataClassification = SystemMetadata;
        }
        field(42; TimeZone; Integer)
        {
            ExternalName = 'timezone';
            ExternalType = 'Integer';
            Description = 'Specifies the timezone for the resource''s working hours.';
            Caption = 'Time Zone';
            DataClassification = SystemMetadata;
        }
        field(43; UserId; GUID)
        {
            ExternalName = 'userid';
            ExternalType = 'Lookup';
            ExternalAccess = Insert;
            Description = 'Select the user who represents this resource.';
            Caption = 'User';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(44; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            Description = 'Exchange rate for the currency associated with the bookableresource with respect to the base currency.';
            Caption = 'ExchangeRate';
            DataClassification = SystemMetadata;
            AutoFormatType = 0;
        }
        field(45; TransactionCurrencyId; GUID)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            Description = 'Exchange rate for the currency associated with the BookableResource with respect to the base currency.';
            Caption = 'Currency';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
            DataClassification = SystemMetadata;
        }
        field(56; DeriveCapacity; Boolean)
        {
            ExternalName = 'msdyn_derivecapacity';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Derive Capacity From Group Members';
            DataClassification = SystemMetadata;
        }
        field(58; DisplayOnScheduleAssistant; Boolean)
        {
            ExternalName = 'msdyn_displayonscheduleassistant';
            ExternalType = 'Boolean';
            Description = 'Specify if this resource should be enabled for availablity search.';
            Caption = 'Enable for Availability Search';
            DataClassification = SystemMetadata;
        }
        field(60; DisplayOnScheduleBoard; Boolean)
        {
            ExternalName = 'msdyn_displayonscheduleboard';
            ExternalType = 'Boolean';
            Description = 'Specify if this resource should be displayed on the schedule board.';
            Caption = 'Display On Schedule Board';
            DataClassification = SystemMetadata;
        }
        field(62; EndLocation; Option)
        {
            ExternalName = 'msdyn_endlocation';
            ExternalType = 'Picklist';
            Description = 'Shows the default ending location type when booking daily schedules for this resource.';
            Caption = 'End Location';
            InitValue = LocationAgnostic;
            OptionMembers = LocationAgnostic,ResourceAddress,OrganizationalUnitAddress;
            OptionOrdinalValues = 690970002, 690970000, 690970001;
            DataClassification = SystemMetadata;
        }
        field(64; GenericType; Option)
        {
            ExternalName = 'msdyn_generictype';
            ExternalType = 'Picklist';
            Description = '';
            Caption = 'Generic Type (Deprecated)';
            InitValue = " ";
            OptionMembers = " ",ServiceCenter;
            OptionOrdinalValues = -1, 690970000;
            DataClassification = SystemMetadata;
        }
        field(67; PrimaryEMail; Text[100])
        {
            ExternalName = 'msdyn_primaryemail';
            ExternalType = 'String';
            Description = '';
            Caption = 'Primary Email';
            DataClassification = SystemMetadata;
        }
        field(68; StartLocation; Option)
        {
            ExternalName = 'msdyn_startlocation';
            ExternalType = 'Picklist';
            Description = 'Shows the default starting location type when booking daily schedules for this resource.';
            Caption = 'Start Location';
            InitValue = LocationAgnostic;
            OptionMembers = LocationAgnostic,ResourceAddress,OrganizationalUnitAddress;
            OptionOrdinalValues = 690970002, 690970000, 690970001;
            DataClassification = SystemMetadata;
        }
        field(70; TargetUtilization; Integer)
        {
            ExternalName = 'msdyn_targetutilization';
            ExternalType = 'Integer';
            Description = 'Shows the target utilization for the resource.';
            Caption = 'Target Utilization';
            DataClassification = SystemMetadata;
        }
        field(72; EnableAppointments; Option)
        {
            ExternalName = 'msdyn_enableappointments';
            ExternalType = 'Picklist';
            Description = 'Enable appointments to display on the new schedule board and be considered in availability search for resources.';
            Caption = 'Include Appointments';
            InitValue = Yes;
            OptionMembers = No,Yes;
            OptionOrdinalValues = 192350000, 192350001;
            DataClassification = SystemMetadata;
        }
        field(74; EnableOutlookSchedules; Option)
        {
            ExternalName = 'msdyn_enableoutlookschedules';
            ExternalType = 'Picklist';
            Description = 'This only applies when directly calling the API. It does not apply when the Book button is clicked on the Schedule Board or on any schedulable entity.';
            Caption = 'Include Outlook Free/Busy in Search Resource Availability API';
            InitValue = Yes;
            OptionMembers = No,Yes;
            OptionOrdinalValues = 192350000, 192350001;
            DataClassification = SystemMetadata;
        }
        field(76; BookingsToDrip; Integer)
        {
            ExternalName = 'msdyn_bookingstodrip';
            ExternalType = 'Integer';
            Description = 'The number of bookings to drip on the Mobile . This field is disabled/enabled based on Enable Drip Scheduling field';
            Caption = 'Bookings To Drip';
            DataClassification = SystemMetadata;
        }
        field(77; EnabledForFieldServiceMobile; Boolean)
        {
            ExternalName = 'msdyn_enabledforfieldservicemobile';
            ExternalType = 'Boolean';
            Description = 'Set this field to Yes if this resource requires access to the legacy Field Service Mobile application.';
            Caption = 'Enable for Field Service Mobile (legacy Xamarin app)';
            DataClassification = SystemMetadata;
        }
        field(79; EnableDripScheduling; Boolean)
        {
            ExternalName = 'msdyn_enabledripscheduling';
            ExternalType = 'Boolean';
            Description = 'Enables drip scheduling on the mobile app.';
            Caption = 'Enable Drip Scheduling';
            DataClassification = SystemMetadata;
        }
        field(81; HourlyRate; Decimal)
        {
            ExternalName = 'msdyn_hourlyrate';
            ExternalType = 'Money';
            Description = '';
            Caption = 'Hourly Rate';
            DataClassification = SystemMetadata;
            AutoFormatType = 2;
            AutoFormatExpression = GetCurrencyCode();
        }
        field(82; HourlyRate_Base; Decimal)
        {
            ExternalName = 'msdyn_hourlyrate_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Value of the Hourly Rate in base currency.';
            Caption = 'Hourly Rate (Base)';
            DataClassification = SystemMetadata;
            AutoFormatType = 2;
            AutoFormatExpression = GetBaseCurrencyCode();
        }
        field(83; TimeOffApprovalRequired; Boolean)
        {
            ExternalName = 'msdyn_timeoffapprovalrequired';
            ExternalType = 'Boolean';
            Description = 'Specifies if approval required for Time Off Requests.';
            Caption = 'Time Off Approval Required';
            DataClassification = SystemMetadata;
        }
        field(87; CrewStrategy; Option)
        {
            ExternalName = 'msdyn_crewstrategy';
            ExternalType = 'Picklist';
            Description = 'Crew Strategy';
            Caption = 'Crew Strategy';
            InitValue = " ";
            OptionMembers = " ",CrewLeaderManagement,"CrewMemberSelf-Management","CascadeAndAcceptCascadeCompletely(NotRecommended)";
            OptionOrdinalValues = -1, 192350001, 192350002, 192350000;
            DataClassification = SystemMetadata;
        }
        field(89; InternalFlags; BLOB)
        {
            ExternalName = 'msdyn_internalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(90; Latitude; Decimal)
        {
            ExternalName = 'msdyn_latitude';
            ExternalType = 'Double';
            Description = 'The location latitude.';
            Caption = 'Latitude';
            DataClassification = SystemMetadata;
            AutoFormatType = 0;
        }
        field(91; Longitude; Decimal)
        {
            ExternalName = 'msdyn_longitude';
            ExternalType = 'Double';
            Description = 'The location longitude.';
            Caption = 'Longitude';
            DataClassification = SystemMetadata;
            AutoFormatType = 0;
        }
        field(92; LocationTimestamp; Datetime)
        {
            ExternalName = 'msdyn_locationtimestamp';
            ExternalType = 'DateTime';
            Description = 'The location timestamp.';
            Caption = 'Location Timestamp';
            DataClassification = SystemMetadata;
        }
        field(93; CompanyId; GUID)
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
        key(PK; BookableResourceId)
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

    local procedure GetCurrencyCode(): Code[10]
    var
        CRMSyncHelper: Codeunit "CRM Synch. Helper";
    begin
        exit(CRMSyncHelper.GetNavCurrencyCode(Rec.TransactionCurrencyId));
    end;

    local procedure GetBaseCurrencyCode(): Code[10]
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        CRMSyncHelper: Codeunit "CRM Synch. Helper";
    begin
        CRMConnectionSetup.Get();
        exit(CRMSyncHelper.GetNavCurrencyCode(CRMConnectionSetup.BaseCurrencyId));
    end;
}