// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

table 6619 "FS Work Order Product"
{
    ExternalName = 'msdyn_workorderproduct';
    TableType = CRM;
    Description = 'In this entity you record all the products proposed and used for a work order';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; WorkOrderProductId; GUID)
        {
            ExternalName = 'msdyn_workorderproductid';
            ExternalType = 'Uniqueidentifier';
            ExternalAccess = Insert;
            Description = 'Shows the entity instances.';
            Caption = 'Work Order Product';
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
            Description = 'Status of the Work Order Product';
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
            Description = 'Reason for the status of the Work Order Product';
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
        field(34; Name; Text[200])
        {
            ExternalName = 'msdyn_name';
            ExternalType = 'String';
            Description = 'Enter the name of the custom entity.';
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(35; AdditionalCost; Decimal)
        {
            ExternalName = 'msdyn_additionalcost';
            ExternalType = 'Money';
            Description = 'Enter any additional costs associated with this product. The values are manually entered. Note: additional cost is not unit dependent.';
            Caption = 'Additional Cost';
            DataClassification = SystemMetadata;
        }
        field(36; TransactionCurrencyId; GUID)
        {
            ExternalName = 'transactioncurrencyid';
            ExternalType = 'Lookup';
            Description = 'Unique identifier of the currency associated with the entity.';
            Caption = 'Currency';
            TableRelation = "CRM Transactioncurrency".TransactionCurrencyId;
            DataClassification = SystemMetadata;
        }
        field(38; ExchangeRate; Decimal)
        {
            ExternalName = 'exchangerate';
            ExternalType = 'Decimal';
            ExternalAccess = Read;
            Description = 'Shows the exchange rate for the currency associated with the entity with respect to the base currency.';
            Caption = 'Exchange Rate';
            DataClassification = SystemMetadata;
        }
        field(39; additionalcost_Base; Decimal)
        {
            ExternalName = 'msdyn_additionalcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the additional cost in the base currency.';
            Caption = 'Additional Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(40; WarehouseId; GUID)
        {
            ExternalName = 'msdyn_warehouse';
            ExternalType = 'Lookup';
            Description = 'Unique identifier of the warehouse associated with the entity.';
            Caption = 'Warehouse';
            TableRelation = "FS Warehouse".WarehouseId;
            DataClassification = SystemMetadata;
        }
        field(41; Allocated; Boolean)
        {
            ExternalName = 'msdyn_allocated';
            ExternalType = 'Boolean';
            Caption = 'Allocated';
            DataClassification = SystemMetadata;
        }
        field(43; Booking; GUID)
        {
            ExternalName = 'msdyn_booking';
            ExternalType = 'Lookup';
            Description = 'The booking where this product was added';
            Caption = 'Booking';
            TableRelation = "FS Bookable Resource Booking".BookableResourceBookingId;
            DataClassification = SystemMetadata;
        }
        field(44; CommissionCosts; Decimal)
        {
            ExternalName = 'msdyn_commissioncosts';
            ExternalType = 'Money';
            Description = 'Enter the commission costs associated with this product. The value is manually specified and isn''t automatically calculated.';
            Caption = 'Commission Costs';
            DataClassification = SystemMetadata;
        }
        field(45; commissioncosts_Base; Decimal)
        {
            ExternalName = 'msdyn_commissioncosts_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the commission costs in the base currency.';
            Caption = 'Commission Costs (Base)';
            DataClassification = SystemMetadata;
        }
        field(46; CustomerAsset; GUID)
        {
            ExternalName = 'msdyn_customerasset';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Customer Asset associated with Work Order Product.';
            Caption = 'Customer Asset';
            TableRelation = "FS Customer Asset".CustomerAssetId;
            DataClassification = SystemMetadata;
        }
        field(47; Description; BLOB)
        {
            ExternalName = 'msdyn_description';
            ExternalType = 'Memo';
            Description = 'Enter the description of the product as presented to the customer. The value defaults to the description defined on the product.';
            Caption = 'Description';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(48; DisableEntitlement; Boolean)
        {
            ExternalName = 'msdyn_disableentitlement';
            ExternalType = 'Boolean';
            Description = 'Choose whether to disable entitlement selection for this work order product.';
            Caption = 'Disable Entitlement';
            DataClassification = SystemMetadata;
        }
        field(50; DiscountAmount; Decimal)
        {
            ExternalName = 'msdyn_discountamount';
            ExternalType = 'Money';
            Description = 'Specify any discount amount on this product. Note: If you enter a discount amount you cannot enter a discount %';
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(51; DiscountAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_discountamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the discount amount in the base currency.';
            Caption = 'Discount Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(52; DiscountPercent; Decimal)
        {
            ExternalName = 'msdyn_discountpercent';
            ExternalType = 'Float';
            Description = 'Specify any discount % on this product. Note: If you enter a discount % it will overwrite the discount $';
            Caption = 'Discount %';
            DataClassification = SystemMetadata;
        }
        field(54; EstimateDiscountAmount; Decimal)
        {
            ExternalName = 'msdyn_estimatediscountamount';
            ExternalType = 'Money';
            Description = 'Enter a discount amount on the subtotal amount. Note: If you enter a discount amount you cannot enter a discount %';
            Caption = 'Estimate Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(55; EstimateDiscountAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_estimatediscountamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate discount amount in the base currency.';
            Caption = 'Estimate Discount Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(56; EstimateDiscountPercent; Decimal)
        {
            ExternalName = 'msdyn_estimatediscountpercent';
            ExternalType = 'Float';
            Description = 'Enter a discount % on the subtotal amount. Note: If you enter a discount % it will overwrite the discount $';
            Caption = 'Estimate Discount %';
            DataClassification = SystemMetadata;
        }
        field(57; EstimateQuantity; Decimal)
        {
            ExternalName = 'msdyn_estimatequantity';
            ExternalType = 'Float';
            Description = 'Enter the estimated required quantity of this product.';
            Caption = 'Estimate Quantity';
            DataClassification = SystemMetadata;
        }
        field(58; EstimateSubtotal; Decimal)
        {
            ExternalName = 'msdyn_estimatesubtotal';
            ExternalType = 'Money';
            Description = 'Shows the total amount for this product, excluding discounts.';
            Caption = 'Estimate Subtotal';
            DataClassification = SystemMetadata;
        }
        field(59; EstimateSubtotal_Base; Decimal)
        {
            ExternalName = 'msdyn_estimatesubtotal_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate subtotal in the base currency.';
            Caption = 'Estimate Subtotal (Base)';
            DataClassification = SystemMetadata;
        }
        field(60; EstimateTotalAmount; Decimal)
        {
            ExternalName = 'msdyn_estimatetotalamount';
            ExternalType = 'Money';
            Description = 'Shows the estimated total amount of this product, including discounts.';
            Caption = 'Estimate Total Amount';
            DataClassification = SystemMetadata;
        }
        field(61; EstimateTotalAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_estimatetotalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate total amount in the base currency.';
            Caption = 'Estimate Total Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(62; EstimateTotalCost; Decimal)
        {
            ExternalName = 'msdyn_estimatetotalcost';
            ExternalType = 'Money';
            Description = 'Shows the estimated total cost of this product.';
            Caption = 'Estimate Total Cost';
            DataClassification = SystemMetadata;
        }
        field(63; EtimateTotalCost_Base; Decimal)
        {
            ExternalName = 'msdyn_estimatetotalcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate total cost in the base currency.';
            Caption = 'Estimate Total Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(64; EstimateUnitAmount; Decimal)
        {
            ExternalName = 'msdyn_estimateunitamount';
            ExternalType = 'Money';
            Description = 'Shows the estimated sale amount per unit.';
            Caption = 'Estimate Unit Amount';
            DataClassification = SystemMetadata;
        }
        field(65; EstimateUnitAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_estimateunitamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate unit amount in the base currency.';
            Caption = 'Estimate Unit Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(66; EstimateUnitCost; Decimal)
        {
            ExternalName = 'msdyn_estimateunitcost';
            ExternalType = 'Money';
            Description = 'Shows the estimated cost amount per unit.';
            Caption = 'Estimate Unit Cost';
            DataClassification = SystemMetadata;
        }
        field(67; EstimateUnitCost_Base; Decimal)
        {
            ExternalName = 'msdyn_estimateunitcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the estimate unit cost in the base currency.';
            Caption = 'Estimate Unit Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(68; InternalDescription; BLOB)
        {
            ExternalName = 'msdyn_internaldescription';
            ExternalType = 'Memo';
            Description = 'Enter any internal notes you want to track on this product.';
            Caption = 'Internal Description';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(69; InternalFlags; BLOB)
        {
            ExternalName = 'msdyn_internalflags';
            ExternalType = 'Memo';
            Description = 'For internal use only.';
            Caption = 'Internal Flags';
            Subtype = Memo;
            DataClassification = SystemMetadata;
        }
        field(70; LineOrder; Integer)
        {
            ExternalName = 'msdyn_lineorder';
            ExternalType = 'Integer';
            Description = '';
            Caption = 'Line Order';
            DataClassification = SystemMetadata;
        }
        field(71; LineStatus; Option)
        {
            ExternalName = 'msdyn_linestatus';
            ExternalType = 'Picklist';
            Description = 'Enter the current status of the line, estimate or used.';
            Caption = 'Line Status';
            InitValue = Estimated;
            OptionMembers = Estimated,Used;
            OptionOrdinalValues = 690970000, 690970001;
            DataClassification = SystemMetadata;
        }
        field(73; PriceList; GUID)
        {
            ExternalName = 'msdyn_pricelist';
            ExternalType = 'Lookup';
            Description = 'Price List that determines the pricing for this product';
            Caption = 'Price List';
            TableRelation = "CRM Pricelevel".PriceLevelId;
            DataClassification = SystemMetadata;
        }
        field(74; Product; GUID)
        {
            ExternalName = 'msdyn_product';
            ExternalType = 'Lookup';
            Description = 'Product to use';
            Caption = 'Product';
            TableRelation = "CRM Product".ProductId;
            DataClassification = SystemMetadata;
        }
        field(76; QtyToBill; Decimal)
        {
            ExternalName = 'msdyn_qtytobill';
            ExternalType = 'Float';
            Description = 'Enter the quantity you wish to bill the customer for. By default, this will default to the same value as "Quantity."';
            Caption = 'Quantity To Bill';
            DataClassification = SystemMetadata;
        }
        field(77; Quantity; Decimal)
        {
            ExternalName = 'msdyn_quantity';
            ExternalType = 'Float';
            Description = 'Shows the actual quantity of the product.';
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(78; Subtotal; Decimal)
        {
            ExternalName = 'msdyn_subtotal';
            ExternalType = 'Money';
            Description = 'Enter the total amount excluding discounts.';
            Caption = 'Subtotal';
            DataClassification = SystemMetadata;
        }
        field(79; Subtotal_Base; Decimal)
        {
            ExternalName = 'msdyn_subtotal_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the subtotal in the base currency.';
            Caption = 'Subtotal (Base)';
            DataClassification = SystemMetadata;
        }
        field(80; Taxable; Boolean)
        {
            ExternalName = 'msdyn_taxable';
            ExternalType = 'Boolean';
            Description = 'Specify if product is taxable. If you do not wish to charge tax set this field to No.';
            Caption = 'Taxable';
            DataClassification = SystemMetadata;
        }
        field(82; TotalAmount; Decimal)
        {
            ExternalName = 'msdyn_totalamount';
            ExternalType = 'Money';
            Description = 'Enter the total amount charged to the customer.';
            Caption = 'Total Amount';
            DataClassification = SystemMetadata;
        }
        field(83; TotalAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_totalamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the total amount in the base currency.';
            Caption = 'Total Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(84; TotalCost; Decimal)
        {
            ExternalName = 'msdyn_totalcost';
            ExternalType = 'Money';
            Description = 'Shows the total cost of this product. This is calculated by (Unit Cost * Units) + Additional Cost + Commission Costs.';
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;
        }
        field(85; TotalCost_Base; Decimal)
        {
            ExternalName = 'msdyn_totalcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the total cost in the base currency.';
            Caption = 'Total Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(86; Unit; GUID)
        {
            ExternalName = 'msdyn_unit';
            ExternalType = 'Lookup';
            Description = 'The unit that determines the pricing and final quantity for this product';
            Caption = 'Unit';
            TableRelation = "CRM Uom".UoMId;
            DataClassification = SystemMetadata;
        }
        field(87; UnitAmount; Decimal)
        {
            ExternalName = 'msdyn_unitamount';
            ExternalType = 'Money';
            Description = 'Enter the amount you want to charge the customer per unit. By default, this is calculated based on the selected price list. The amount can be changed.';
            Caption = 'Unit Amount';
            DataClassification = SystemMetadata;
        }
        field(88; UnitAmount_Base; Decimal)
        {
            ExternalName = 'msdyn_unitamount_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the unit amount in the base currency.';
            Caption = 'Unit Amount (Base)';
            DataClassification = SystemMetadata;
        }
        field(89; UnitCost; Decimal)
        {
            ExternalName = 'msdyn_unitcost';
            ExternalType = 'Money';
            Description = 'Shows the actual cost per unit.';
            Caption = 'Unit Cost';
            DataClassification = SystemMetadata;
        }
        field(90; UnitCost_Base; Decimal)
        {
            ExternalName = 'msdyn_unitcost_base';
            ExternalType = 'Money';
            ExternalAccess = Read;
            Description = 'Shows the value of the unit cost in the base currency.';
            Caption = 'Unit Cost (Base)';
            DataClassification = SystemMetadata;
        }
        field(92; WorkOrder; GUID)
        {
            ExternalName = 'msdyn_workorder';
            ExternalType = 'Lookup';
            Description = 'Unique identifier for Work Order associated with Work Order Product.';
            Caption = 'Work Order';
            TableRelation = "FS Work Order".WorkOrderId;
            DataClassification = SystemMetadata;
        }
        field(93; WorkOrderIncident; GUID)
        {
            ExternalName = 'msdyn_workorderincident';
            ExternalType = 'Lookup';
            Description = 'The Incident related to this product';
            Caption = 'Work Order Incident';
            TableRelation = "FS Work Order Incident".WorkOrderIncidentId;
            DataClassification = SystemMetadata;
        }
        field(94; BookingName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Bookable Resource Booking".Name where(BookableResourceBookingId = field(Booking)));
            ExternalName = 'msdyn_bookingname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(97; CustomerAssetName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Customer Asset".Name where(CustomerAssetId = field(CustomerAsset)));
            ExternalName = 'msdyn_customerassetname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(100; WorkOrderName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order".Name where(WorkOrderId = field(WorkOrder)));
            ExternalName = 'msdyn_workordername';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(101; WorkOrderIncidentName; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("FS Work Order Incident".Name where(WorkOrderIncidentId = field(WorkOrderIncident)));
            ExternalName = 'msdyn_workorderincidentname';
            ExternalType = 'String';
            ExternalAccess = Read;
        }
        field(105; ProjectTask; GUID)
        {
            ExternalName = 'bcbi_projecttask';
            ExternalType = 'Lookup';
            Description = 'Business Central Project Task';
            Caption = 'External Project';
            TableRelation = "FS Project Task".ProjectTaskId;
            DataClassification = SystemMetadata;
        }
        field(106; WorkOrderStatus; Option)
        {
            ExternalName = 'bcbi_workorderstatus';
            ExternalType = 'Picklist';
            Description = 'The status of the work order';
            Caption = 'Work Order Status';
            InitValue = " ";
            OptionMembers = " ",Unscheduled,Scheduled,InProgress,Completed,Posted,Canceled;
            OptionOrdinalValues = -1, 690970000, 690970001, 690970002, 690970003, 690970004, 690970005;
            DataClassification = SystemMetadata;
        }
        field(108; CompanyId; GUID)
        {
            ExternalName = 'bcbi_company';
            ExternalType = 'Lookup';
            Description = 'Business Central Company';
            Caption = 'Company Id';
            TableRelation = "CDS Company".CompanyId;
            DataClassification = SystemMetadata;
        }
        field(111; QuantityConsumed; Decimal)
        {
            ExternalName = 'bcbi_quantityconsumed';
            ExternalType = 'Float';
            Description = 'Quantity consumed in Dynamics 365 Business Central';
            Caption = 'Quantity Consumed';
        }
        field(112; QuantityInvoiced; Decimal)
        {
            ExternalName = 'bcbi_quantityinvoiced';
            ExternalType = 'Float';
            Description = 'Quantity invoiced in Dynamics 365 Business Central. When this value is different than 0, you can no longer edit the work order product.';
            Caption = 'Quantity Invoiced';
        }
        field(113; QuantityShipped; Decimal)
        {
            ExternalName = 'bcbi_quantityshipped';
            ExternalType = 'Float';
            Description = 'Quantity shipped in Dynamics 365 Business Central. When this value is different than 0, you can no longer edit the work order product.';
            Caption = 'Quantity Shipped';
        }
    }
    keys
    {
        key(PK; workorderproductId)
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