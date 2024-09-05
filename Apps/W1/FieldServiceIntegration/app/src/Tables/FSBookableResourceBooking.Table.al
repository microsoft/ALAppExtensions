// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6611 "FS Bookable Resource Booking"
{
    ExternalName = 'bookableresourcebooking';
    TableType = CRM;
    Description = 'Represents the line details of a resource booking.';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; BookableResourceBookingId; GUID)
        {
            ExternalName = 'bookableresourcebookingid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Unique identifier of the resource booking.';
            Caption = 'Bookable Resource Booking';
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
            Description = 'Type a name for the booking.';
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
        field(34; BookingType; Option)
        {
            ExternalName = 'bookingtype';
            ExternalType = 'Picklist';
            Description = 'Select whether the booking is solid or liquid. Solid bookings are firm and cannot be changed whereas liquid bookings can be changed.';
            Caption = 'Booking Type';
            InitValue = Solid;
            OptionMembers = Liquid,Solid;
            OptionOrdinalValues = 2, 1;
            DataClassification = SystemMetadata;
        }
        field(36; Duration; Integer)
        {
            ExternalName = 'duration';
            ExternalType = 'Integer';
            Description = 'Enter the duration of the booking.';
            Caption = 'Duration';
            DataClassification = SystemMetadata;
        }
        field(37; EndTime; Datetime)
        {
            ExternalName = 'endtime';
            ExternalType = 'DateTime';
            Description = 'Enter the end date and time of the booking.';
            Caption = 'End Time';
            DataClassification = SystemMetadata;
        }
        field(38; Header; GUID)
        {
            ExternalName = 'header';
            ExternalType = 'Lookup';
            Description = 'Shows the reference to the booking header record that represents the summary of bookings.';
            Caption = 'Header';
            TableRelation = "FS BookableResourceBookingHdr".BookableResourceBookingHeaderId;
            DataClassification = SystemMetadata;
        }
        field(39; Resource; GUID)
        {
            ExternalName = 'resource';
            ExternalType = 'Lookup';
            Description = 'Shows the resource that is booked.';
            Caption = 'Resource';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(40; StartTime; Datetime)
        {
            ExternalName = 'starttime';
            ExternalType = 'DateTime';
            Description = 'Enter the start date and time of the booking.';
            Caption = 'Start Time';
            DataClassification = SystemMetadata;
        }
        field(41; StateCode; Option)
        {
            ExternalName = 'statecode';
            ExternalType = 'State';
            ExternalAccess = Modify;
            Description = 'Status of the Bookable Resource Booking';
            Caption = 'Status';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 0, 1;
            DataClassification = SystemMetadata;
        }
        field(43; StatusCode; Option)
        {
            ExternalName = 'statuscode';
            ExternalType = 'Status';
            Description = 'Reason for the status of the Bookable Resource Booking';
            Caption = 'Status Reason';
            InitValue = " ";
            OptionMembers = " ",Active,Inactive;
            OptionOrdinalValues = -1, 1, 2;
            DataClassification = SystemMetadata;
        }
        field(45; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            Description = 'Exchange rate for the currency associated with the bookableresourcebooking with respect to the base currency.';
            Caption = 'ExchangeRate';
            DataClassification = SystemMetadata;
        }
        field(46; TransactionCurrencyId; GUID)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            Description = 'Exchange rate for the currency associated with the BookableResourceBooking with respect to the base currency.';
            Caption = 'Currency';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
            DataClassification = SystemMetadata;
        }
        field(47; ResourceName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(Resource)));
            ExternalName = 'resourcename';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(48; HeaderName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS BookableResourceBookingHdr".Name where(BookableResourceBookingHeaderId = field(Header)));
            ExternalName = 'headername';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(51; ActualArrivalTime; Datetime)
        {
            ExternalName = 'msdyn_actualarrivaltime';
            ExternalType = 'DateTime';
            Description = 'Shows the time that work started.';
            Caption = 'Actual Arrival Time';
            DataClassification = SystemMetadata;
        }
        field(52; ActualTravelDuration; Integer)
        {
            ExternalName = 'msdyn_actualtravelduration';
            ExternalType = 'Integer';
            Description = 'Shows the total travel duration. Calculated based on the difference between the Bookable Resource Booking''s start time and actual arrival time.';
            Caption = 'Actual Travel Duration';
            DataClassification = SystemMetadata;
        }
        field(53; AllowOverlapping; Boolean)
        {
            ExternalName = 'msdyn_allowoverlapping';
            ExternalType = 'Boolean';
            Description = 'Allow the time of this booking to be displayed on the schedule assistant as available.';
            Caption = 'Allow Overlapping';
            DataClassification = SystemMetadata;
        }
        field(56; BookingMethod; Option)
        {
            ExternalName = 'msdyn_bookingmethod';
            ExternalType = 'Picklist';
            Description = 'Shows the method used to create this booking.';
            Caption = 'Booking Method';
            InitValue = Manual;
            OptionMembers = ResourceSchedulingOptimization,"System-AgreementSchedule",ScheduleBoard,Mobile,Manual,ScheduleAssistant;
            OptionOrdinalValues = 192350000, 690970005, 690970001, 690970002, 690970003, 690970004;
            DataClassification = SystemMetadata;
        }
        field(59; CascadeCrewChanges; Boolean)
        {
            ExternalName = 'msdyn_cascadecrewchanges';
            ExternalType = 'Boolean';
            Description = 'Defines whether changing any of the following fields (Start Time, End Time, Status) should cascade the changes to other bookings on this requirement that have the same start and end time.';
            Caption = 'Cascade Crew Changes';
            DataClassification = SystemMetadata;
        }
        field(61; AcceptCascadeCrewChanges; Boolean)
        {
            ExternalName = 'msdyn_acceptcascadecrewchanges';
            ExternalType = 'Boolean';
            Description = 'Defines whether this booking accepts changes propagated as cascading changes';
            Caption = 'Accept Cascade Crew Changes';
            DataClassification = SystemMetadata;
        }
        field(63; effort; Decimal)
        {
            ExternalName = 'msdyn_effort';
            ExternalType = 'Decimal';
            Description = 'Capacity that needs to take from resource capacity';
            Caption = 'Capacity';
            DataClassification = SystemMetadata;
        }
        field(64; EstimatedArrivalTime; Datetime)
        {
            ExternalName = 'msdyn_estimatedarrivaltime';
            ExternalType = 'DateTime';
            Description = 'Estimated Arrival Time';
            Caption = 'Estimated Arrival Time';
            DataClassification = SystemMetadata;
        }
        field(65; EstimatedTravelDuration; Integer)
        {
            ExternalName = 'msdyn_estimatedtravelduration';
            ExternalType = 'Integer';
            Description = 'Estimated Travel Duration';
            Caption = 'Estimated Travel Duration';
            DataClassification = SystemMetadata;
        }
        field(66; URSInternalFlags; BLOB)
        {
            ExternalName = 'msdyn_ursinternalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(67; Latitude; Decimal)
        {
            ExternalName = 'msdyn_latitude';
            ExternalType = 'Double';
            Description = '';
            Caption = 'Latitude';
            DataClassification = SystemMetadata;
        }
        field(68; Longitude; Decimal)
        {
            ExternalName = 'msdyn_longitude';
            ExternalType = 'Double';
            Description = '';
            Caption = 'Longitude';
            DataClassification = SystemMetadata;
        }
        field(69; MilesTraveled; Decimal)
        {
            ExternalName = 'msdyn_milestraveled';
            ExternalType = 'Double';
            Description = 'In this field you can enter the total miles the resource drove to the job site';
            Caption = 'Miles Traveled';
            DataClassification = SystemMetadata;
        }
        field(71; ResourceGroup; GUID)
        {
            ExternalName = 'msdyn_resourcegroup';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Resource associated with Resource Booking';
            Caption = 'Resource Group';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(74; WorkLocation; Option)
        {
            ExternalName = 'msdyn_worklocation';
            ExternalType = 'Picklist';
            Description = '';
            Caption = 'Work Location';
            InitValue = " ";
            OptionMembers = " ",Onsite,Facility,LocationAgnostic;
            OptionOrdinalValues = -1, 690970000, 690970001, 690970002;
            DataClassification = SystemMetadata;
        }
        field(78; ResourceGroupName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(ResourceGroup)));
            ExternalName = 'msdyn_resourcegroupname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(82; BaseTravelDuration; Integer)
        {
            ExternalName = 'msdyn_basetravelduration';
            ExternalType = 'Integer';
            Description = 'The Base travel duration indicates the travel time without traffic';
            Caption = 'Base Travel Duration';
            DataClassification = SystemMetadata;
        }
        field(83; requirementgroupset; Text[40])
        {
            ExternalName = 'msdyn_requirementgroupset';
            ExternalType = 'String';
            Description = 'Requirement Group Set';
            Caption = 'Requirement Group Set';
            DataClassification = SystemMetadata;
        }
        field(84; TravelTimeCalculationType; Option)
        {
            ExternalName = 'msdyn_traveltimecalculationtype';
            ExternalType = 'Picklist';
            Description = 'Travel Time Calculation';
            Caption = 'Travel Time Calculation';
            InitValue = BingMapsWithoutHistoricalTraffic;
            OptionMembers = BingMapsWithoutHistoricalTraffic,BingMapsWithHistoricalTraffic,CustomMapProvider,Approximate;
            OptionOrdinalValues = 192350000, 192350001, 192350002, 192350003;
            DataClassification = SystemMetadata;
        }
        field(87; InternalFlags; BLOB)
        {
            ExternalName = 'msdyn_internalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(88; OfflineTimestamp; Datetime)
        {
            ExternalName = 'msdyn_offlinetimestamp';
            ExternalType = 'DateTime';
            Description = 'Internal Use. This field is used to capture the time when the Booking was updated on mobile offline.';
            Caption = 'Offline Timestamp';
            DataClassification = SystemMetadata;
        }
        field(89; PreventTimestampCreation; Boolean)
        {
            ExternalName = 'msdyn_preventtimestampcreation';
            ExternalType = 'Boolean';
            Description = 'Prevents time stamp creation if the time stamp was already created on a mobile device.';
            Caption = 'Prevent Timestamp Creation';
            DataClassification = SystemMetadata;
        }
        field(91; Signature; BLOB)
        {
            ExternalName = 'msdyn_signature';
            ExternalType = 'Memo';
            Description = 'This field is used for capturing signature on Mobile (using the Pen Control)';
            Caption = 'Signature';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(92; SlotText; BLOB)
        {
            ExternalName = 'msdyn_slottext';
            ExternalType = 'Memo';
            Description = 'Shows the automatically generated text of the time slot on the schedule board.';
            Caption = 'Slot Text';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(93; TotalBillableDuration; Integer)
        {
            ExternalName = 'msdyn_totalbillableduration';
            ExternalType = 'Integer';
            Description = 'Shows the total billable duration. If you leave this field blank the system automatically determines the billable duration by calculating the resource journal details.';
            Caption = 'Total Billable Duration';
            DataClassification = SystemMetadata;
        }
        field(94; TotalBreakDuration; Integer)
        {
            ExternalName = 'msdyn_totalbreakduration';
            ExternalType = 'Integer';
            Description = 'Shows the total break duration. If you leave this field blank the system automatically determines the break duration by calculating the resource journal details.';
            Caption = 'Total Break Duration';
            DataClassification = SystemMetadata;
        }
        field(95; TotalCost; Decimal)
        {
            ExternalName = 'msdyn_totalcost';
            ExternalType = 'Money';
            Description = 'Shows the total cost for this booking.';
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;
        }
        field(96; totalcost_Base; Decimal)
        {
            ExternalName = 'msdyn_totalcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Value of the Total Cost in base currency.';
            Caption = 'Total Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(97; TotalDurationInProgress; Integer)
        {
            ExternalName = 'msdyn_totaldurationinprogress';
            ExternalType = 'Integer';
            Description = 'Shows the total duration that this booking was in progress.';
            Caption = 'Total Duration In Progress';
            DataClassification = SystemMetadata;
        }
        field(98; TravelTimeRescheduling; Boolean)
        {
            ExternalName = 'msdyn_traveltimerescheduling';
            ExternalType = 'Boolean';
            Description = '';
            Caption = 'Travel Time Rescheduling (Deprecated)';
            DataClassification = SystemMetadata;
        }
        field(100; WorkOrder; GUID)
        {
            ExternalName = 'msdyn_workorder';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Work Order associated with Resource Booking.';
            Caption = 'Work Order';
            TableRelation = "FS Work Order".WorkOrderId;
            DataClassification = SystemMetadata;
        }
        field(102; WorkOrderName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order".Name where(WorkOrderId = field(WorkOrder)));
            ExternalName = 'msdyn_workordername';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(103; Crew; GUID)
        {
            ExternalName = 'msdyn_crew';
            ExternalType = 'Lookup';
            Description = 'This field is populated by the Field Service solution to define to which crew a booking is connected.';
            Caption = 'Crew';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(104; CrewMemberType; Option)
        {
            ExternalName = 'msdyn_crewmembertype';
            ExternalType = 'Picklist';
            Description = 'Crew Member Type';
            Caption = 'Crew Member Type';
            InitValue = " ";
            OptionMembers = " ",Leader,Member,None;
            OptionOrdinalValues = -1, 192350000, 192350001, 192350002;
            DataClassification = SystemMetadata;
        }
        field(106; QuickNoteAction; Option)
        {
            ExternalName = 'msdyn_quickNoteAction';
            ExternalType = 'Picklist';
            Description = 'Internal For Quick note pcf control actions';
            Caption = 'Quick note actions';
            InitValue = None;
            OptionMembers = None,Text,Photo,Video,Audio,File;
            OptionOrdinalValues = 100000000, 100000001, 100000002, 100000003, 100000004, 100000005;
            DataClassification = SystemMetadata;
        }
        field(108; CrewName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(Crew)));
            ExternalName = 'msdyn_crewname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(110; BookingStatus; Guid)
        {
            ExternalName = 'bookingstatus';
            ExternalType = 'Lookup';
            ExternalAccess = Read;
            Description = 'Unique identifier of the booking status.';
            Caption = 'Booking Status';
            TableRelation = "FS Booking Status".BookingStatusId;
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; BookableResourceBookingId)
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