// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Assembly.Document;
using Microsoft.CRM.Contact;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.Period;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Projects.Project.Planning;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.Utilities;

page 4410 "SOA Multi Items Availability"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Item Availability';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = Item;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            field(PreviewDisclaimer; PreviewDisclaimerLbl)
            {
                ShowCaption = false;
                Style = StrongAccent;
                trigger OnDrillDown()
                begin
                    Hyperlink(PreviewDisclaimerURLLbl);
                end;
            }
            group(Options)
            {
                Caption = 'Options';
                Visible = OptionsVisible;
                field(AnalysisPeriodType; AnalysisPeriodType)
                {
                    Caption = 'View by';
                    ToolTip = 'Specifies by which period amounts are displayed.';
                    Visible = not IsAgentSession;

                    trigger OnValidate()
                    begin
                        FindPeriod('');
                    end;
                }
                field(AnalysisAmountType; AnalysisAmountType)
                {
                    Caption = 'View as';
                    ToolTip = 'Specifies how amounts are displayed. Net Change: The net change in the balance for the selected period. Balance at Date: The balance as of the last day in the selected period.';
                    Visible = not IsAgentSession;

                    trigger OnValidate()
                    begin
                        FindPeriod('');
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Date Filter", DateFilter);
                        FindPeriod('');
                    end;
                }
                field(CustomerNo; CustomerNo)
                {
                    Caption = 'Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the customer number that will be used to calculate prices and discounts.';

                    trigger OnValidate()
                    var
                        Customer: Record Customer;
                    begin
                        ContactNo := '';
                        LocationFilter := '';

                        if Customer.Get(CustomerNo) then begin
                            LocationFilter := Customer.GetDefaultLocation();
                            if LocationFilter = '' then
                                LocationFilter := '''''';
                            Rec.SetFilter("Location Filter", '%1', LocationFilter);
                        end else
                            CustomerNo := '';

                        LanguageCode := GetLanguageCode(ContactNo, CustomerNo);

                        CurrPage.Update(false);
                    end;
                }
                field(ContactNo; ContactNo)
                {
                    Caption = 'Contact No.';
                    TableRelation = Contact;
                    ToolTip = 'Specifies the contact number that will be used to calculate prices and discounts.';

                    trigger OnValidate()
                    var
                        Contact: Record Contact;
                        Customer: Record Customer;
                    begin
                        CustomerNo := '';

                        if Contact.Get(ContactNo) then begin
                            if Contact.FindCustomer(Customer) then begin
                                CustomerNo := Customer."No.";
                                LocationFilter := Customer.GetDefaultLocation();
                                if LocationFilter = '' then
                                    LocationFilter := '''''';
                                Rec.SetFilter("Location Filter", '%1', LocationFilter);
                            end else begin
                                CustomerNo := '';
                                LocationFilter := '''''';
                            end;
                        end else
                            ContactNo := '';

                        LanguageCode := GetLanguageCode(ContactNo, CustomerNo);

                        CurrPage.Update(false);
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    Caption = 'Location Filter';
                    ToolTip = 'Specifies the location(-s) that will be used to filter the amounts in the window.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LocationList: Page "Location List";
                    begin
                        LocationList.LookupMode(true);
                        if LocationList.RunModal() = Action::LookupOK then begin
                            Text := LocationList.GetSelectionFilter();
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        LocationFilter := LocationFilter.ToUpper();
                        Rec.SetFilter("Location Filter", LocationFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(QuantityFilter; QuantityFilter)
                {
                    AutoFormatType = 0;
                    Caption = 'Quantity Filter';
                    ToolTip = 'Specifies the quantity filter that will be used to identify the available quantity.';
                    DecimalPlaces = 0 : 5;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(InUOM; InUOMCode)
                {
                    Caption = 'UOM Filter';
                    ToolTip = 'Specifies the unit of measure in which available quantity is calculated.';
                    TableRelation = "Unit of Measure";

                    trigger OnValidate()
                    var
                        UOM: Record "Unit of Measure";
                        SearchTerm: Text;
                    begin
                        if InUOMCode <> '' then begin
                            SearchTerm := StrSubstNo('@*%1*', InUOMCode);

                            UOM.FilterGroup(-1);
                            UOM.SetFilter(Code, SearchTerm);
                            UOM.SetFilter(Description, SearchTerm);
                            UOM.SetFilter("International Standard Code", SearchTerm);
                            if UOM.FindFirst() then
                                InUOMCode := UOM.Code
                            else
                                InUOMCode := '';
                        end;

                        CurrPage.Update(false);
                    end;
                }
                field(CalculateEarliestShipmentDate; CalculateEarliestShipmentDate)
                {
                    Caption = 'Calculate Earliest Shipment Date';
                    ToolTip = 'Specifies whether the earliest possible shipment date should be calculated for the requested quantity of currently unavailable items.';
                    Visible = not IsAgentSession;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies a number of the item.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the item.';
                    Visible = not IsAgentSession;
                }
                field(TranslatedDescription; TranslatedDescription)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies a translated description of the item.';
                    Visible = IsAgentSession;
                }
                field(Available; Available)
                {
                    Caption = 'Requested Quantity Available';
                    ToolTip = 'Specifies if the requested quantity is available in requested unit of measure.';
                    Visible = (not IsAgentSession) or (IsAgentSession and IncludeCapableToPromiseItems);
                }
                field(EarliestShipmentDate; EarliestShipmentDate)
                {
                    Caption = 'Earliest Shipment Date';
                    ToolTip = 'Specifies the earliest date the requested quantity will be available for shipment if ordered today.';
                    Visible = (not IsAgentSession) or (IsAgentSession and IncludeCapableToPromiseItems);
                }
                field(AvailabilityLevel; AvailabilityLevel)
                {
                    Caption = 'Availability Level';
                    ToolTip = 'Specifies the level of item availability.';
                    Visible = (not IsAgentSession) or (IsAgentSession and not IncludeCapableToPromiseItems);
                }
                field(UnitCost; UnitCost)
                {
                    AutoFormatType = 2;
                    AutoFormatExpression = CurrencyCode;
                    Caption = 'Unit Cost';
                    ToolTip = 'Specifies the unit cost of the item on the line.';
                    Visible = false;
                }
                field(UnitPrice; UnitPrice)
                {
                    AutoFormatType = 2;
                    AutoFormatExpression = CurrencyCode;
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the price for one unit on the line.';
                    Visible = not IsAgentSession;
                }
                field(DiscountPct; DiscountPct)
                {
                    AutoFormatType = 0;
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the discount percentage that can be granted for the item on the line.';
                    Visible = not IsAgentSession;
                }
                field(UnitPriceInclDiscount; UnitPriceInclDiscount)
                {
                    AutoFormatType = 2;
                    AutoFormatExpression = CurrencyCode;
                    Caption = 'Unit Price Including Discount';
                    ToolTip = 'Specifies the price for one unit on the line including discount.';
                }
                field(CurrencyCode; CurrencyCode)
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency code of the price on the line.';
                }
                field(MatchingItem; MatchingItem)
                {
                    Caption = 'Matching Item';
                    ToolTip = 'Specifies if the search result finds a matching item against the searched query or alternative items.';
                    Visible = IsAgentSession;
                }
                field(GrossRequirement; GrossRequirement)
                {
                    AutoFormatType = 0;
                    Caption = 'Gross Requirement';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the sum of the total demand for the item. The gross requirement consists of independent demand (which include sales orders, service orders, transfer orders, and demand forecasts) and dependent demand, which include production order components for planned, firm planned, and released production orders and requisition and planning worksheets lines.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowItemAvailLineList(0);
                    end;
                }
                field(ScheduledRcpt; ScheduledRcpt)
                {
                    AutoFormatType = 0;
                    Caption = 'Scheduled Receipt';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the sum of items from replenishment orders. This includes firm planned and released production orders, purchase orders, and transfer orders.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowItemAvailLineList(2);
                    end;
                }
                field(PlannedOrderRcpt; PlannedOrderRcpt)
                {
                    AutoFormatType = 0;
                    Caption = 'Planned Receipt';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity on planned production orders plus planning worksheet lines plus requisition worksheet lines.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowItemAvailLineList(1);
                    end;
                }
                field(Inventory; Rec.Inventory)
                {
                    Caption = 'Inventory';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the inventory level of an item.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        ItemAvailFormsMgt.ShowItemLedgerEntries(Item, false);
                    end;
                }
                field(ProjAvailableBalance; ProjAvailableBalance)
                {
                    AutoFormatType = 0;
                    Caption = 'Available Quantity (Base UOM)';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the item''s availability. This quantity includes all known supply and demand but does not include anticipated demand from demand forecasts or blanket sales orders or suggested supplies from planning or requisition worksheets.';
                    Visible = not IsAgentSession;

                    trigger OnDrillDown()
                    begin
                        ShowItemAvailLineList(4);
                    end;
                }
                field(ProjAvailableBalanceInUOM; ProjAvailableBalanceInUOM)
                {
                    AutoFormatType = 0;
                    Caption = 'Available Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the item''s availability recalculated in specified Unit on Measure.';
                    Visible = not IsAgentSession;
                }
                field(LineUOM; LineUOM)
                {
                    Caption = 'Unit Of Measure Code';
                    ToolTip = 'Specifies the item''s Unit of Measure code.';
                }
                field(LineUOMDescription; LineUOMDescription)
                {
                    Caption = 'Unit Of Measure';
                    ToolTip = 'Specifies the item''s Unit of Measure description.';
                    Visible = false;
                }
                field(QtyOnPurchOrder; Rec."Qty. on Purch. Order")
                {
                    Caption = 'Qty. on Purch. Order';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are inbound on purchase orders, meaning listed on outstanding purchase order lines.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        PurchAvailabilityMgt.ShowPurchLines(Item);
                    end;
                }
                field(QtyOnSalesOrder; Rec."Qty. on Sales Order")
                {
                    Caption = 'Qty. on Sales Order';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are allocated to sales orders, meaning listed on outstanding sales orders lines.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        SalesAvailabilityMgt.ShowSalesLines(Item);
                    end;
                }
                field(QtyOnJobOrder; Rec."Qty. on Job Order")
                {
                    Caption = 'Qty. on Project Order';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are allocated to projects, meaning listed on outstanding project planning lines. The field is automatically updated based on the Remaining Qty. field in the Project Planning Lines window.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        JobPlanningAvailabilityMgt.ShowJobPlanningLines(Item);
                    end;
                }
                field(TransOrdShipmentQty; Rec."Trans. Ord. Shipment (Qty.)")
                {
                    Caption = 'Trans. Ord. Shipment (Qty.)';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the items that remains to be shipped. The program calculates this quantity as the difference between the Quantity and the Quantity Shipped fields. It automatically updates the field each time you either update the Quantity or Quantity Shipped field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        TransferAvailabilityMgt.ShowTransLines(Item, Item.FieldNo("Trans. Ord. Shipment (Qty.)"));
                    end;
                }
                field(QtyOnAsmComponent; Rec."Qty. on Asm. Component")
                {
                    Caption = 'Qty. on Asm. Comp. Lines';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are allocated to assembly component orders.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        AssemblyAvailabilityMgt.ShowAsmCompLines(Item);
                    end;
                }
                field(QtyOnAssemblyOrder; Rec."Qty. on Assembly Order")
                {
                    Caption = 'Qty. on Assembly Order';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are allocated to assembly orders, which is how many are listed on outstanding assembly order headers.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        AssemblyAvailabilityMgt.ShowAsmOrders(Item);
                    end;
                }
                field(QtyInTransit; Rec."Qty. in Transit")
                {
                    Caption = 'Qty. in Transit';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the items that are currently in transit.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        TransferAvailabilityMgt.ShowTransLines(Item, Item.FieldNo("Qty. in Transit"));
                    end;
                }
                field(TransOrdReceiptQty; Rec."Trans. Ord. Receipt (Qty.)")
                {
                    Caption = 'Trans. Ord. Receipt (Qty.)';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the items that remain to be received but are not yet shipped. The program calculates this quantity as the difference between the Quantity and the Quantity Shipped fields. It automatically updates the field each time you either update the Quantity or Quantity Shipped field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        TransferAvailabilityMgt.ShowTransLines(Item, Item.FieldNo("Trans. Ord. Receipt (Qty.)"));
                    end;
                }
                field(ExpectedInventory; ExpectedInventory)
                {
                    AutoFormatType = 0;
                    Caption = 'Expected Inventory';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the item that is expected to be in inventory at the end of the period entered in the Date Filter field.';
                    Visible = false;
                }
                field(QtyAvailable; QtyAvailable)
                {
                    AutoFormatType = 0;
                    Caption = 'Available Inventory';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity of the item that is currently in inventory and not reserved for other demand.';
                    Visible = false;
                }
                field(ScheduledReceiptQty; Rec."Scheduled Receipt (Qty.)")
                {
                    Caption = 'Scheduled Receipt (Qty.)';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the item are scheduled for production orders. The program automatically calculates and updates the contents of the field, using the Remaining Quantity field on production order lines.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        ProdOrderAvailabilityMgt.ShowSchedReceipt(Item);
                    end;
                }
                field(QtyOnComponentLines; Rec."Qty. on Component Lines")
                {
                    Caption = 'Qty. on Component Lines';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the sum of items from planned production orders.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        ProdOrderAvailabilityMgt.ShowSchedNeed(Item);
                    end;
                }
                field(PlannedOrderReleases; PlannedOrderReleases)
                {
                    AutoFormatType = 0;
                    Caption = 'Planned Order Releases';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the sum of items from replenishment order proposals, which include planned production orders and planning or requisition worksheets lines, that are calculated according to the starting date in the planning worksheet and production order or the order date in the requisition worksheet. This sum is not included in the projected available inventory. However, it indicates which quantities should be converted from planned to scheduled receipts.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowItemAvailLineList(3);
                    end;
                }
                field(NetChange; Rec."Net Change")
                {
                    Caption = 'Net Change';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the net change in the inventory of the item during the period entered in the Date Filter field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Copy(Rec);
                        ItemAvailFormsMgt.ShowItemLedgerEntries(Item, true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(PreviousPeriod)
            {
                Caption = 'Previous Period';
                Image = PreviousRecord;
                ToolTip = 'Show the information based on the previous period. If you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    FindPeriod('<=');
                end;
            }
            action(NextPeriod)
            {
                Caption = 'Next Period';
                Image = NextRecord;
                ToolTip = 'Show the information based on the next period. If you set the View by field to Day, the date filter changes to the day after.';

                trigger OnAction()
                begin
                    FindPeriod('>=');
                end;
            }
            group("&Item")
            {
                Caption = '&Item';
                Image = Item;
                group(ItemAvailabilityBy)
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        Caption = 'Event';
                        Image = Event;
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        var
                            Item: Record Item;
                        begin
                            Item.Copy(Rec);
                            ItemAvailFormsMgt.ShowItemAvailabilityFromItem(Item, "Item Availability Type"::"Event");
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = field("No."),
                                      "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = field("Global Dimension 2 Filter"),
                                      "Location Filter" = field("Location Filter"),
                                      "Drop Shipment Filter" = field("Drop Shipment Filter"),
                                      "Variant Filter" = field("Variant Filter");
                        ToolTip = 'Show the projected quantity of the item over time according to time periods, such as day, week, or month.';
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = field("No."),
                                      "Global Dimension 1 Filter" = field("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = field("Global Dimension 2 Filter"),
                                      "Location Filter" = field("Location Filter"),
                                      "Drop Shipment Filter" = field("Drop Shipment Filter"),
                                      "Variant Filter" = field("Variant Filter");
                        ToolTip = 'View or edit the item''s variants. Instead of setting up each color of an item as a separate item, you can set up the various colors as variants of the item.';
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        var
                            Item: Record Item;
                        begin
                            Item.Copy(Rec);
                            ItemAvailFormsMgt.ShowItemAvailabilityFromItem(Item, "Item Availability Type"::BOM);
                        end;
                    }
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(PreviousPeriod_Promoted; PreviousPeriod) { }
                actionref(NextPeriod_Promoted; NextPeriod) { }
            }
        }
    }

    trigger OnInit()
    var
        SOASetup: Record "SOA Setup";
        SOAKPITrackAll: Codeunit "SOA - KPI Track All";
        AgentTaskID: BigInteger;
    begin
        AnalysisPeriodType := AnalysisPeriodType::Day;
        AnalysisAmountType := AnalysisAmountType::"Balance at Date";

        OptionsVisible := true;
        IsAgentSession := SOAKPITrackAll.IsOrderTakerAgentSession(AgentTaskID);

        if IsAgentSession then
            if SOASetup.FindLast() then begin
                OptionsVisible := SOASetup."Search Only Available Items";
                IncludeCapableToPromiseItems := SOASetup."Incl. Capable to Promise";
            end;

        OnAfterInitPage(CustomerNo, ContactNo, LocationFilter, CalculateEarliestShipmentDate);
    end;

    trigger OnOpenPage()
    var
        SOAKPITrackAll: Codeunit "SOA - KPI Track All";
        AgentTaskID: BigInteger;
        OriginalFilterGroup: Integer;
    begin
        LanguageCode := GetLanguageCode(ContactNo, CustomerNo);
        Rec.SetFilter("Location Filter", '%1', LocationFilter);
        Rec.SetRange("Drop Shipment Filter", false);
        Rec.SetRange("Variant Filter", '');
        if SOAKPITrackAll.IsOrderTakerAgentSession(AgentTaskID) then begin
            OriginalFilterGroup := Rec.FilterGroup();
            Rec.FilterGroup(-1);
            Rec.SetRange("No.", '<>*');
            Rec.FilterGroup(OriginalFilterGroup);
            if LocationFilter = '' then
                LocationFilter := '''''';
        end;

        FindPeriod('');
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindRecord(Rec, Which, CrossColumnSearchFilter, Found, QuantityFilter, InUOMCode, IsHandled, MatchingItem);
        if IsHandled then
            exit(Found);

        exit(Rec.Find(Which));
    end;

    trigger OnAfterGetRecord()
    var
        ItemTranslation: Record "Item Translation";
        Location: Record Location;
        SOAShipmentDateMgt: Codeunit "SOA Shipment Date Mgt.";
        LocationCode: Code[10];
    begin
        UnitCost := 0;
        UnitPrice := 0;
        DiscountPct := 0;
        UnitPriceInclDiscount := 0;
        EarliestShipmentDate := 0D;

        CalcAvailQuantities(GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ProjAvailableBalanceInUOM, ExpectedInventory, QtyAvailable);
        if CalcPrice() then;

        if Location.Get(LocationFilter) then
            LocationCode := Location.Code;

        if not Available and CalculateEarliestShipmentDate then begin
            SOAShipmentDateMgt.SetParamenters(Rec."No.", '', LocationCode, InUOMCode, WorkDate(), QuantityFilter);
            if SOAShipmentDateMgt.Run() then
                EarliestShipmentDate := SOAShipmentDateMgt.GetEarliestShipmentDate();

            if (EarliestShipmentDate <> 0D) and (EarliestShipmentDate <= Rec.GetRangeMax("Date Filter")) then begin
                Available := true;
                AvailabilityLevel := AvailabilityLevel::Available;
                EarliestShipmentDate := 0D;
            end;
        end;

        TranslatedDescription := Rec.Description;
        TranslatedDescription2 := Rec."Description 2";
        if LanguageCode <> '' then
            if ItemTranslation.Get(Rec."No.", '', LanguageCode) then begin
                TranslatedDescription := ItemTranslation.Description;
                TranslatedDescription2 := ItemTranslation."Description 2";
            end;
    end;

    var
        Calendar: Record Date;
        AssemblyAvailabilityMgt: Codeunit "Assembly Availability Mgt.";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        JobPlanningAvailabilityMgt: Codeunit "Job Planning Availability Mgt.";
        ProdOrderAvailabilityMgt: Codeunit "Prod. Order Availability Mgt.";
        PurchAvailabilityMgt: Codeunit "Purch. Availability Mgt.";
        SalesAvailabilityMgt: Codeunit "Sales Availability Mgt.";
        TransferAvailabilityMgt: Codeunit "Transfer Availability Mgt.";
        AnalysisAmountType: Enum "Analysis Amount Type";
        AnalysisPeriodType: Enum "Analysis Period Type";
        AvailabilityLevel: Enum "SOA Availability Level";
        CustomerNo, ContactNo : Code[20];
        InUOMCode, LineUOM, CurrencyCode, LanguageCode : Code[10];
        QuantityFilter, ExpectedInventory, QtyAvailable, PlannedOrderReleases, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, ProjAvailableBalance, ProjAvailableBalanceInUOM : Decimal;
        UnitCost, UnitPrice, UnitPriceInclDiscount, DiscountPct : Decimal;
        DateFilter, LocationFilter, CrossColumnSearchFilter, LineUOMDescription : Text;
        TranslatedDescription: Text[100];
        TranslatedDescription2: Text[50];
        EarliestShipmentDate: Date;
        Available, CalculateEarliestShipmentDate, OptionsVisible, IsAgentSession, IncludeCapableToPromiseItems, MatchingItem : Boolean;
        PreviewDisclaimerLbl: Label 'Item Availability page (preview). Learn more';
        PreviewDisclaimerURLLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2303848', Locked = true;
        PriceCheckDocNoLbl: Label 'SOA-PRICECHECK', Locked = true;

    local procedure ShowItemAvailLineList(What: Integer)
    var
        Item: Record Item;
    begin
        Item.Copy(Rec);
        ItemAvailFormsMgt.ShowItemAvailLineList(Item, What);
    end;

    local procedure FindPeriod(SearchText: Text[3])
    var
        PeriodPageMgt: Codeunit PeriodPageManagement;
    begin
        if Rec.GetFilter("Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", Rec.GetFilter("Date Filter"));
            if not PeriodPageMgt.FindDate('+', Calendar, AnalysisPeriodType) then
                PeriodPageMgt.FindDate('+', Calendar, "Analysis Period Type"::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodPageMgt.FindDate(SearchText, Calendar, AnalysisPeriodType);
        if AnalysisAmountType = AnalysisAmountType::"Net Change" then begin
            Rec.SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
            if Rec.GetRangeMin("Date Filter") = Rec.GetRangeMax("Date Filter") then
                Rec.SetRange("Date Filter", Rec.GetRangeMin("Date Filter"));
        end else
            Rec.SetRange("Date Filter", 0D, Calendar."Period End");
        DateFilter := Rec.GetFilter("Date Filter");
        CurrPage.Update(false);
    end;

    local procedure CalcAvailQuantities(var GrossRequirement2: Decimal; var PlannedOrderRcpt2: Decimal; var ScheduledRcpt2: Decimal; var PlannedOrderReleases2: Decimal; var ProjAvailableBalance2: Decimal; var ProjAvailableBalanceInUOM2: Decimal; var ExpectedInventory2: Decimal; var AvailableInventory: Decimal)
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        UnitOfMeasure: Record "Unit of Measure";
        SOAItemSearch: Codeunit "SOA Item Search";
        DummyQtyAvailable, SafetyStockQty : Decimal;
    begin
        if Rec.Type <> Rec.Type::Inventory then begin
            Available := true;
            AvailabilityLevel := AvailabilityLevel::Available;
            ProjAvailableBalance2 := 0;
            ProjAvailableBalanceInUOM2 := 0;
            exit;
        end;

        LineUOM := InUOMCode;
        if LineUOM = '' then
            LineUOM := Rec."Sales Unit of Measure";

        if UnitOfMeasure.Get(LineUOM) then
            LineUOMDescription := UnitOfMeasure.Description;

        // Copy the item to avoid potential modifying the original record in ItemAvailFormsMgt.CalcAvailQuantities
        Item.Copy(Rec);
        Item.SetFilter("Date Filter", DateFilter);
        Item.SetFilter("Location Filter", LocationFilter);
        Item.SetRange("Drop Shipment Filter", false);
        Item.SetRange("Variant Filter", '');

        ItemAvailFormsMgt.CalcAvailQuantities(Item, AnalysisAmountType = AnalysisAmountType::"Balance at Date",
            GrossRequirement2, PlannedOrderRcpt2, ScheduledRcpt2,
            PlannedOrderReleases2, ProjAvailableBalance2, ExpectedInventory2,
            DummyQtyAvailable, AvailableInventory);

        if ProjAvailableBalance2 <= 0 then
            ProjAvailableBalanceInUOM2 := ProjAvailableBalance2
        else
            ProjAvailableBalanceInUOM2 := SOAItemSearch.CalcProjAvailableBalanceInUOM(Rec, ProjAvailableBalance2, LineUOM);

        Available := (ProjAvailableBalanceInUOM2 > 0) and (ProjAvailableBalanceInUOM2 >= QuantityFilter);

        AvailabilityLevel := AvailabilityLevel::"Out of stock";
        if ProjAvailableBalance2 > 0 then begin
            AvailabilityLevel := AvailabilityLevel::Limited;

            if SKU.Get(LocationFilter, Item."No.", '') then
                SafetyStockQty := SKU."Safety Stock Quantity"
            else
                SafetyStockQty := Rec."Safety Stock Quantity";

            if ProjAvailableBalance2 > SafetyStockQty then
                AvailabilityLevel := AvailabilityLevel::Available;
        end;
    end;

    [TryFunction]
    local procedure CalcPrice()
    var
        GLSetup: Record "General Ledger Setup";
        Contact: Record Contact;
        Customer: Record Customer;
        CustTemplate: Record "Customer Templ.";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        NewCustTemplateCode: Code[20];
    begin
        if GLSetup.Get() then
            CurrencyCode := GLSetup."LCY Code";

        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := PriceCheckDocNoLbl;
        if CustomerNo = '' then begin
            if not Contact.Get(ContactNo) then
                Contact.Init(); //default type = company

            NewCustTemplateCode := Contact.FindNewCustomerTemplate();
            if NewCustTemplateCode = '' then begin
                CustTemplate.SetRange("Contact Type", Contact.Type);
                if not CustTemplate.FindFirst() then
                    exit;
            end else
                if not CustTemplate.Get(NewCustTemplateCode) then
                    exit;

            TempSalesHeader."Sell-to Customer Templ. Code" := CustTemplate.Code;
            TempSalesHeader."Bill-to Customer Templ. Code" := CustTemplate.Code;
            TempSalesHeader."Customer Price Group" := CustTemplate."Customer Price Group";
            TempSalesHeader."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
            TempSalesHeader."Allow Line Disc." := CustTemplate."Allow Line Disc.";
            TempSalesHeader."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
            TempSalesHeader."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
            TempSalesHeader."Tax Area Code" := CustTemplate."Tax Area Code";
            TempSalesHeader."Tax Liable" := CustTemplate."Tax Liable";
            TempSalesHeader."VAT Country/Region Code" := CustTemplate."Country/Region Code";
            TempSalesHeader."Customer Posting Group" := CustTemplate."Customer Posting Group";
            TempSalesHeader."Prices Including VAT" := CustTemplate."Prices Including VAT";
        end else begin
            if not Customer.Get(CustomerNo) then
                exit;

            TempSalesHeader."Sell-to Customer No." := CustomerNo;
            TempSalesHeader."Bill-to Customer No." := CustomerNo;
            TempSalesHeader."Customer Price Group" := Customer."Customer Price Group";
            TempSalesHeader."Customer Disc. Group" := Customer."Customer Disc. Group";
            TempSalesHeader."Allow Line Disc." := Customer."Allow Line Disc.";
            TempSalesHeader."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            TempSalesHeader."VAT Bus. Posting Group" := Customer."VAT Bus. Posting Group";
            TempSalesHeader."Tax Area Code" := Customer."Tax Area Code";
            TempSalesHeader."Tax Liable" := Customer."Tax Liable";
            TempSalesHeader."VAT Country/Region Code" := Customer."Country/Region Code";
            TempSalesHeader."Customer Posting Group" := Customer."Customer Posting Group";
            TempSalesHeader."Prices Including VAT" := Customer."Prices Including VAT";
        end;

        TempSalesHeader.Validate("Document Date", Calendar."Period End");
        TempSalesHeader.Validate("Order Date", Calendar."Period End");
        TempSalesHeader.Validate("Currency Code", Customer."Currency Code");
        TempSalesHeader.Insert(false);

        TempSalesLine."Document Type" := TempSalesHeader."Document Type";
        TempSalesLine."Document No." := TempSalesHeader."No.";
        TempSalesLine."System-Created Entry" := true;
        TempSalesLine.SetSalesHeader(TempSalesHeader);
        TempSalesLine.Validate(Type, TempSalesLine.Type::Item);
        TempSalesLine.Validate("No.", Rec."No.");
        TempSalesLine.Validate(Quantity, 1);
        if TempSalesLine."Unit of Measure Code" <> '' then
            TempSalesLine.Validate("Unit of Measure Code", Rec."Sales Unit of Measure");
        if InUOMCode <> '' then
            if ItemUnitOfMeasure.Get(Rec."No.", InUOMCode) then
                TempSalesLine.Validate("Unit of Measure Code", InUOMCode);
        UnitCost := TempSalesLine."Unit Cost";
        UnitPrice := TempSalesLine."Unit Price";
        DiscountPct := TempSalesLine."Line Discount %";
        UnitPriceInclDiscount := TempSalesLine."Line Amount";
        if TempSalesLine."Currency Code" <> '' then
            CurrencyCode := TempSalesLine."Currency Code";
    end;

    local procedure GetLanguageCode(ContNo: Code[20]; CustNo: Code[20]): Code[10]
    var
        Contact: Record Contact;
        Customer: Record Customer;
    begin
        if Contact.Get(ContNo) and (Contact."Language Code" <> '') then
            exit(Contact."Language Code");

        if Customer.Get(CustNo) and (Customer."Language Code" <> '') then
            exit(Customer."Language Code");
        exit('');
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeFindRecord(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; RequiredQuantity: Decimal; InUOMCode: Code[10]; var IsHandled: Boolean; var MatchingItem: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPage(var CustomerNo: Code[20]; var ContactNo: Code[20]; var LocationFilter: Text; var CalculateEarliestShipmentDate: Boolean)
    begin
    end;
}