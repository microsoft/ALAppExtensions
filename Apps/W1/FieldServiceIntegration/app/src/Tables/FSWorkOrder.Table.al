// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6617 "FS Work Order"
{
    ExternalName = 'msdyn_workorder';
    TableType = CRM;
    Description = 'Work orders store all information about the job performed for an account. Stores incident details, resource, expenses, tasks, communications, billing and more';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; WorkOrderId; GUID)
        {
            ExternalName = 'msdyn_workorderid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Shows the entity instances.';
            Caption = 'WO Number';
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
            Description = 'Status of the Work Order';
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
            Description = 'Reason for the status of the Work Order';
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
            Caption = 'Work Order Number';
            DataClassification = SystemMetadata;
        }
        field(35; ProcessId; GUID)
        {
            ExternalName = 'processid';
            ExternalType = 'Uniqueidentifier';
            Description = 'Shows the ID of the process associated with the entity.';
            Caption = 'Process Id';
            DataClassification = SystemMetadata;
        }
        field(36; StageId; GUID)
        {
            ExternalName = 'stageid';
            ExternalType = 'Uniqueidentifier';
            Description = 'Shows the ID of the stage where the entity is located.';
            Caption = 'Stage Id';
            DataClassification = SystemMetadata;
        }
        field(37; TraversedPath; Text[1250])
        {
            ExternalName = 'traversedpath';
            ExternalType = 'String';
            Description = 'Shows a comma-separated list of string values representing the unique identifiers of stages in a business process flow instance in the order that they occur.';
            Caption = 'Traversed Path';
            DataClassification = SystemMetadata;
        }
        field(38; Address1; Text[250])
        {
            ExternalName = 'msdyn_address1';
            ExternalType = 'String';
            Caption = 'Street 1';
            DataClassification = SystemMetadata;
        }
        field(39; Address2; Text[250])
        {
            ExternalName = 'msdyn_address2';
            ExternalType = 'String';
            Caption = 'Street 2';
            DataClassification = SystemMetadata;
        }
        field(40; Address3; Text[250])
        {
            ExternalName = 'msdyn_address3';
            ExternalType = 'String';
            Caption = 'Street 3';
            DataClassification = SystemMetadata;
        }
        field(41; AddressName; Text[250])
        {
            ExternalName = 'msdyn_addressname';
            ExternalType = 'String';
            Caption = 'Address Name';
            DataClassification = SystemMetadata;
        }
        field(43; AutoNumbering; Text[100])
        {
            ExternalName = 'msdyn_autonumbering';
            ExternalType = 'String';
            Description = 'Internal field used to generate the next name upon entity creation. It is optionally copied to the msdyn_name field.';
            Caption = 'Auto-Numbering';
            DataClassification = SystemMetadata;
        }
        field(44; BillingAccount; GUID)
        {
            ExternalName = 'msdyn_billingaccount';
            ExternalType = 'Lookup';
            Description = 'Account to be billed. If a billing account has been set on service account it will be populated by default. Otherwise, the billing account will be the same as the service account.';
            Caption = 'Billing Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(45; BookingSummary; BLOB)
        {
            ExternalName = 'msdyn_bookingsummary';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Booking Summary';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(46; ChildIndex; Integer)
        {
            ExternalName = 'msdyn_childindex';
            ExternalType = 'Integer';
            Caption = 'Child Index';
            DataClassification = SystemMetadata;
        }
        field(47; City; Text[80])
        {
            ExternalName = 'msdyn_city';
            ExternalType = 'String';
            Caption = 'City';
            DataClassification = SystemMetadata;
        }
        field(48; ClosedBy; GUID)
        {
            ExternalName = 'msdyn_closedby';
            ExternalType = 'Lookup';
            Description = 'The user that last closed this work order';
            Caption = 'Closed By';
            TableRelation = "CRM Systemuser".SystemUserId;
            DataClassification = SystemMetadata;
        }
        field(49; Country; Text[80])
        {
            ExternalName = 'msdyn_country';
            ExternalType = 'String';
            Caption = 'Country/Region';
            DataClassification = SystemMetadata;
        }
        field(50; CustomerAsset; GUID)
        {
            ExternalName = 'msdyn_customerasset';
            ExternalType = 'Lookup';
            Description = 'Customer Asset related to this incident reported';
            Caption = 'Primary Incident Customer Asset';
            TableRelation = "FS Customer Asset".CustomerAssetId;
            DataClassification = SystemMetadata;
        }
        field(51; DateWindowEnd; Date)
        {
            ExternalName = 'msdyn_datewindowend';
            ExternalType = 'DateTime';
            Caption = 'Date Window End';
            DataClassification = SystemMetadata;
        }
        field(52; DateWindowStart; Date)
        {
            ExternalName = 'msdyn_datewindowstart';
            ExternalType = 'DateTime';
            Caption = 'Date Window Start';
            DataClassification = SystemMetadata;
        }
        field(53; EstimateSubtotalAmount; Decimal)
        {
            ExternalName = 'msdyn_estimatesubtotalamount';
            ExternalType = 'Money';
            Description = 'Enter the summary of total estimated billing amount for this work order';
            Caption = 'Estimate Subtotal Amount';
            DataClassification = SystemMetadata;
        }
        field(54; TransactionCurrencyId; GUID)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            Description = 'Unique identifier of the currency associated with the entity.';
            Caption = 'Currency';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
            DataClassification = SystemMetadata;
        }
        field(56; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            Description = 'Shows the exchange rate for the currency associated with the entity with respect to the base currency.';
            Caption = 'Exchange Rate';
            DataClassification = SystemMetadata;
        }
        field(57; EstimateSubtotalAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_estimatesubtotalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate subtotal amount in the base currency.';
            Caption = 'Estimate Subtotal Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(58; FollowUpNote; BLOB)
        {
            ExternalName = 'msdyn_followupnote';
            ExternalType = 'Memo';
            Description = 'Indicate the details of the follow up work';
            Caption = 'Follow Up Note (Deprecated)';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(59; FollowUpRequired; Boolean)
        {
            ExternalName = 'msdyn_followuprequired';
            ExternalType = 'Boolean';
            Description = 'Allows indication if follow up work is required for a work order.';
            Caption = 'Follow Up Required (Deprecated)';
            DataClassification = SystemMetadata;
        }
        field(61; Instructions; BLOB)
        {
            ExternalName = 'msdyn_instructions';
            ExternalType = 'Memo';
            Description = 'Shows instructions for booked resources. By default, this information is taken from the work order instructions field on the service account.';
            Caption = 'Instructions';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(62; InternalFlags; BLOB)
        {
            ExternalName = 'msdyn_internalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(63; IsFollowUp; Boolean)
        {
            ExternalName = 'msdyn_isfollowup';
            ExternalType = 'Boolean';
            Caption = 'Is FollowUp (Deprecated)';
            DataClassification = SystemMetadata;
        }
        field(65; IsMobile; Boolean)
        {
            ExternalName = 'msdyn_ismobile';
            ExternalType = 'Boolean';
            Caption = 'Is Mobile';
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
        field(69; MapControl; Text[100])
        {
            ExternalName = 'msdyn_mapcontrol';
            ExternalType = 'String';
            ExternalAccess = Read;
            Description = '';
            Caption = 'This field should only be used to load the custom map control';
            DataClassification = SystemMetadata;
        }
        field(70; OpportunityId; GUID)
        {
            ExternalName = 'msdyn_opportunityid';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Opportunity associated with Work Order.';
            Caption = 'Opportunity';
            TableRelation = "CRM Opportunity".OpportunityId;
            DataClassification = SystemMetadata;
        }
        field(71; ParentWorkOrder; GUID)
        {
            ExternalName = 'msdyn_parentworkorder';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Work Order associated with Work Order.';
            Caption = 'Parent Work Order';
            TableRelation = "FS Work Order".WorkOrderId;
            DataClassification = SystemMetadata;
        }
        field(72; PostalCode; Text[20])
        {
            ExternalName = 'msdyn_postalcode';
            ExternalType = 'String';
            Caption = 'Postal Code';
            DataClassification = SystemMetadata;
        }
        field(73; PreferredResource; GUID)
        {
            ExternalName = 'msdyn_preferredresource';
            ExternalType = 'Lookup';
            Description = 'The customer Preferred Resource to work on this job. Should be taken into consideration while scheduling resources';
            Caption = 'Preferred Resource (Deprecated)';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(74; PriceList; GUID)
        {
            ExternalName = 'msdyn_pricelist';
            ExternalType = 'Lookup';
            Description = 'Price List that controls pricing for products / services added to this work order. By default the system will use the Price List specified on the account';
            Caption = 'Price List';
            TableRelation = "CRM Pricelevel".PriceLevelId;
            DataClassification = SystemMetadata;
        }
        field(75; PrimaryIncidentDescription; BLOB)
        {
            ExternalName = 'msdyn_primaryincidentdescription';
            ExternalType = 'Memo';
            Description = 'Incident description';
            Caption = 'Primary Incident Description';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(76; PrimaryIncidentEstimatedDuration; Integer)
        {
            ExternalName = 'msdyn_primaryincidentestimatedduration';
            ExternalType = 'Integer';
            Description = 'Shows the time estimated to resolve this incident.';
            Caption = 'Primary Incident Estimated Duration';
            DataClassification = SystemMetadata;
        }
        field(79; ReportedByContact; GUID)
        {
            ExternalName = 'msdyn_reportedbycontact';
            ExternalType = 'Lookup';
            Description = 'The contact that reported this Work Order';
            Caption = 'Reported By Contact';
            TableRelation = "CRM Contact".ContactId;
            DataClassification = SystemMetadata;
        }
        field(80; ServiceAccount; GUID)
        {
            ExternalName = 'msdyn_serviceaccount';
            ExternalType = 'Lookup';
            Description = 'Account to be serviced';
            Caption = 'Service Account';
            TableRelation = "CRM Account".AccountId;
            DataClassification = SystemMetadata;
        }
        field(81; ServiceRequest; GUID)
        {
            ExternalName = 'msdyn_servicerequest';
            ExternalType = 'Lookup';
            Description = 'Case of which this work order originates from';
            Caption = 'Case';
            TableRelation = "CRM Incident".IncidentId;
            DataClassification = SystemMetadata;
        }
        field(83; StateOrProvince; Text[50])
        {
            ExternalName = 'msdyn_stateorprovince';
            ExternalType = 'String';
            Caption = 'State Or Province';
            DataClassification = SystemMetadata;
        }
        field(84; SubStatus; GUID)
        {
            ExternalName = 'msdyn_substatus';
            ExternalType = 'Lookup';
            Description = 'Work Order subsstatus';
            Caption = 'Substatus';
            TableRelation = "FS Work Order Substatus".WorkOrderSubstatusId;
            DataClassification = SystemMetadata;
        }
        field(85; SubtotalAmount; Decimal)
        {
            ExternalName = 'msdyn_subtotalamount';
            ExternalType = 'Money';
            Description = 'Enter the summary of subtotal billing amount excluding tax for this work order.';
            Caption = 'Subtotal Amount';
            DataClassification = SystemMetadata;
        }
        field(86; SubTotalAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_subtotalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the subtotal amount in the base currency.';
            Caption = 'Subtotal Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(87; SupportContact; GUID)
        {
            ExternalName = 'msdyn_supportcontact';
            ExternalType = 'Lookup';
            Description = 'A support contact can be specified so that the individual working on the work order has someone to contact for assistance.';
            Caption = 'Support Contact';
            TableRelation = "FS Bookable Resource".BookableResourceId;
            DataClassification = SystemMetadata;
        }
        field(88; SystemStatus; Option)
        {
            ExternalName = 'msdyn_systemstatus';
            ExternalType = 'Picklist';
            Description = 'Tracks the current system status.';
            Caption = 'System Status';
            InitValue = " ";
            OptionMembers = " ",Unscheduled,Scheduled,InProgress,Completed,Posted,Canceled;
            OptionOrdinalValues = -1, 690970000, 690970001, 690970002, 690970003, 690970004, 690970005;
            DataClassification = SystemMetadata;
        }
        field(90; Taxable; Boolean)
        {
            ExternalName = 'msdyn_taxable';
            ExternalType = 'Boolean';
            Description = 'Shows whether sales tax is to be charged for this work order.';
            Caption = 'Taxable';
            DataClassification = SystemMetadata;
        }
        field(93; TimeClosed; Datetime)
        {
            ExternalName = 'msdyn_timeclosed';
            ExternalType = 'DateTime';
            Description = 'Enter the time this work order was last closed.';
            Caption = 'Closed On';
            DataClassification = SystemMetadata;
        }
        field(94; TimeFromPromised; Datetime)
        {
            ExternalName = 'msdyn_timefrompromised';
            ExternalType = 'DateTime';
            Description = 'Enter the starting range of the time promised to the account that incidents will be resolved.';
            Caption = 'Time From Promised';
            DataClassification = SystemMetadata;
        }
        field(97; TimeToPromised; Datetime)
        {
            ExternalName = 'msdyn_timetopromised';
            ExternalType = 'DateTime';
            Description = 'Enter the ending range of the time promised to the account that incidents will be resolved.';
            Caption = 'Time To Promised';
            DataClassification = SystemMetadata;
        }
        field(98; TimeWindowEnd; Datetime)
        {
            ExternalName = 'msdyn_timewindowend';
            ExternalType = 'DateTime';
            Caption = 'Time Window End';
            DataClassification = SystemMetadata;
        }
        field(99; TimeWindowStart; Datetime)
        {
            ExternalName = 'msdyn_timewindowstart';
            ExternalType = 'DateTime';
            Caption = 'Time Window Start';
            DataClassification = SystemMetadata;
        }
        field(100; TotalAmount; Decimal)
        {
            ExternalName = 'msdyn_totalamount';
            ExternalType = 'Money';
            Description = 'Enter the summary of total billing amount for this work order.';
            Caption = 'Total Amount';
            DataClassification = SystemMetadata;
        }
        field(101; TotalAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_totalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the total amount in the base currency.';
            Caption = 'Total Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(102; TotalSalesTax; Decimal)
        {
            ExternalName = 'msdyn_totalsalestax';
            ExternalType = 'Money';
            Description = 'Enter the summary of total sales tax charged for this work order.';
            Caption = 'Total Sales Tax';
            DataClassification = SystemMetadata;
        }
        field(103; TotalSalesTax_Base; Decimal)
        {
            ExternalName = 'msdyn_totalsalestax_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the total sales tax in the base currency.';
            Caption = 'Total Sales Tax (Base)';
            DataClassification = SystemMetadata;
        }
        field(105; WorkLocation; Option)
        {
            ExternalName = 'msdyn_worklocation';
            ExternalType = 'Picklist';
            Caption = 'Work Location';
            InitValue = Onsite;
            OptionMembers = Onsite,Facility,LocationAgnostic;
            OptionOrdinalValues = 690970000, 690970001, 690970002;
            DataClassification = SystemMetadata;
        }
        field(109; WorkOrderSummary; BLOB)
        {
            ExternalName = 'msdyn_workordersummary';
            ExternalType = 'Memo';
            Description = 'Type a summary description of the job.';
            Caption = 'Work Order Summary';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(110; WorkOrderType; GUID)
        {
            ExternalName = 'msdyn_workordertype';
            ExternalType = 'Lookup';
            Description = 'Work Order Type';
            Caption = 'Work Order Type';
            TableRelation = "FS Work Order Type".WorkOrderTypeId;
            DataClassification = SystemMetadata;
        }
        field(115; PreferredResourceName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(PreferredResource)));
            ExternalName = 'msdyn_preferredresourcename';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(116; SupportContactName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource".Name where(BookableResourceId = field(SupportContact)));
            ExternalName = 'msdyn_supportcontactname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(121; CustomerAssetName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset".Name where(CustomerAssetId = field(CustomerAsset)));
            ExternalName = 'msdyn_customerassetname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(128; ParentWorkOrderName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order".Name where(WorkOrderId = field(ParentWorkOrder)));
            ExternalName = 'msdyn_parentworkordername';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(129; SubStatusName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order Substatus".Name where(WorkOrderSubstatusId = field(SubStatus)));
            ExternalName = 'msdyn_substatusname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(130; WorkOrderTypeName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order Type".Name where(WorkOrderTypeId = field(WorkOrderType)));
            ExternalName = 'msdyn_workordertypename';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(138; completedon; Datetime)
        {
            ExternalName = 'msdyn_completedon';
            ExternalType = 'DateTime';
            Description = 'When Bookings are used on a Work Order, this field is auto-populated based on the latest End Time from the related Bookings. Otherwise, this field is populated based on the change of System Status.';
            Caption = 'Completed On';
            DataClassification = SystemMetadata;
        }
        field(139; CostNTEPercent; Integer)
        {
            ExternalName = 'msdyn_costntepercent';
            ExternalType = 'Integer';
            Description = 'Indicates the percentage proximity or overage of the work order cost based on applied Cost not-to-exceed (rounded up to the nearest whole number).';
            Caption = 'Cost not-to-exceed';
            DataClassification = SystemMetadata;
        }
        field(140; firstarrivedon; Datetime)
        {
            ExternalName = 'msdyn_firstarrivedon';
            ExternalType = 'DateTime';
            Description = 'When Bookings are used on a Work Order, this field is auto-populated based on the earliest Actual Arrival Time from the related Bookings.';
            Caption = 'First Arrived On';
            DataClassification = SystemMetadata;
        }
        field(142; NotToExceedCostAmount; Decimal)
        {
            ExternalName = 'msdyn_nottoexceedcostamount';
            ExternalType = 'Money';
            Description = 'The value of not-to-exceed cost for the work order in base currency.';
            Caption = 'Cost not-to-exceed';
            DataClassification = SystemMetadata;
        }
        field(143; NotToExceedCostAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_nottoexceedcostamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Value of the Cost not-to-exceed in base currency.';
            Caption = 'Cost not-to-exceed (Base)';
            DataClassification = SystemMetadata;
        }
        field(144; NotToExceedPriceAmount; Decimal)
        {
            ExternalName = 'msdyn_nottoexceedpriceamount';
            ExternalType = 'Money';
            Description = 'The value of not-to-exceed price for the work order in base currency.';
            Caption = 'Price not-to-exceed';
            DataClassification = SystemMetadata;
        }
        field(145; NotToExceedPriceAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_nottoexceedpriceamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Value of the Price not-to-exceed in base currency.';
            Caption = 'Price not-to-exceed (Base)';
            DataClassification = SystemMetadata;
        }
        field(146; PhoneNumber; Text[250])
        {
            ExternalName = 'msdyn_phoneNumber';
            ExternalType = 'String';
            Caption = 'Customer Phone Number';
            DataClassification = SystemMetadata;
        }
        field(147; PriceNTEPercent; Integer)
        {
            ExternalName = 'msdyn_pricentepercent';
            ExternalType = 'Integer';
            Description = 'Indicates the percentage proximity or overage of the work order price based on applied Price not-to-exceed (rounded up to the nearest whole number).';
            Caption = 'Price not-to-exceed';
            DataClassification = SystemMetadata;
        }
        field(149; ProductsServicesCost; Decimal)
        {
            ExternalName = 'msdyn_productsservicescost';
            ExternalType = 'Money';
            Description = 'The total actual cost of the products and services';
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;
        }
        field(150; ProductsServicesCost_Base; Decimal)
        {
            ExternalName = 'msdyn_productsservicescost_base';
            ExternalType = 'Money';
            Description = 'Value of the Total Cost in base currency.';
            Caption = 'Total Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(151; ProductsServicesEstimatedCost; Decimal)
        {
            ExternalName = 'msdyn_productsservicesestimatedcost';
            ExternalType = 'Money';
            Description = 'The total estimated cost of the products and services';
            Caption = 'Total Estimated Cost';
            DataClassification = SystemMetadata;
        }
        field(152; ProductsServicesEstimatedCost_Base; Decimal)
        {
            ExternalName = 'msdyn_productsservicesestimatedcost_base';
            ExternalType = 'Money';
            Description = 'Value of the Total Estimated Cost in base currency.';
            Caption = 'Total Estimated Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(153; TotalEstimatedAfterTaxPrice; Decimal)
        {
            ExternalName = 'msdyn_totalestimatedaftertaxprice';
            ExternalType = 'Money';
            Description = 'The estimated price after adding tax to the subtotal';
            Caption = 'Total Estimated After Tax Price';
            DataClassification = SystemMetadata;
        }
        field(154; TotalEstimatedAfterTaxPrice_Base; Decimal)
        {
            ExternalName = 'msdyn_totalestimatedaftertaxprice_base';
            ExternalType = 'Money';
            Description = 'Value of the Total Estimated After Tax Price in base currency.';
            Caption = 'Total Estimated After Tax Price (Base)';
            DataClassification = SystemMetadata;
        }
        field(155; TotalEstimatedDuration; Integer)
        {
            ExternalName = 'msdyn_totalestimatedduration';
            ExternalType = 'Integer';
            Description = 'Calculated from the estimated duration of Work Order Incidents and Work Order Service Tasks not related to a Work Order Incident on the Work Order. Intended to be read-only.';
            Caption = 'Total Estimated Duration';
            DataClassification = SystemMetadata;
        }
        field(162; DisplayAddress; Text[2048])
        {
            ExternalName = 'msdyn_displayaddress';
            ExternalType = 'String';
            ExternalAccess = Read;
            Description = 'Combined address field suitable for display';
            Caption = 'Display Address';
            DataClassification = SystemMetadata;
        }
        field(163; ProjectTask; GUID)
        {
            ExternalName = 'bcbi_businesscentralprojecttask';
            ExternalType = 'Lookup';
            Description = 'Business Central Project Task';
            Caption = 'Business Central Project Task';
            TableRelation = "FS Project Task".ProjectTaskId;
            DataClassification = SystemMetadata;
        }
        field(164; CompanyId; GUID)
        {
            ExternalName = 'bcbi_company';
            ExternalType = 'Lookup';
            Description = 'Business Central Company';
            Caption = 'Company Id';
            TableRelation = "CDS Company".CompanyId;
            DataClassification = SystemMetadata;
        }
        field(165; "Integrate to Service"; Boolean)
        {
            ExternalName = 'bcbi_integratetoervice';
            ExternalType = 'Boolean';
            Caption = 'Integrate to Service';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; WorkOrderId)
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