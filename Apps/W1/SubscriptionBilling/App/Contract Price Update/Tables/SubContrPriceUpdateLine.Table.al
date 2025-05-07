namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Sales.Document;

table 8004 "Sub. Contr. Price Update Line"
{
    Caption = 'Subscription Contract Price Update Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(3; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
        }
        field(4; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(5; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
        }
        field(6; "Partner Name"; Text[100])
        {
            Caption = 'Partner Name';
        }
        field(7; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
        }
        field(8; "Sub. Contract Description"; Text[100])
        {
            Caption = 'Subscription Contract Description';
        }
        field(9; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';
        }
        field(10; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';
        }
        field(11; "Old Price"; Decimal)
        {
            Caption = 'Old Price';
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(12; "New Price"; Decimal)
        {
            Caption = 'New Price';
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(13; "Additional Amount"; Decimal)
        {
            Caption = 'Additional Amount';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(14; "Old Amount"; Decimal)
        {
            Caption = 'Old Amount';
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(15; "New Amount"; Decimal)
        {
            Caption = 'New Amount';
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(16; "Old Calculation Base"; Decimal)
        {
            Caption = 'Old Calculation Base';
            MinValue = 0;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(17; "New Calculation Base"; Decimal)
        {
            Caption = 'New Calculation Base';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 2;
        }
        field(18; "Old Calculation Base %"; Decimal)
        {
            Caption = 'Old Calculation Base %';
            MinValue = 0;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(19; "New Calculation Base %"; Decimal)
        {
            Caption = 'New Calculation Base %';
            Editable = false;
            BlankZero = true;
        }
        field(20; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MinValue = 0;
            MaxValue = 100;
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(21; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MinValue = 0;
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(22; Quantity; Decimal)
        {
            Caption = 'Quantity';
            BlankZero = true;
        }
        field(23; "Next Price Update"; Date)
        {
            Caption = 'Next Price Update';
        }
        field(24; "Perform Update On"; Date)
        {
            Caption = 'Perform Update On';
        }
        field(100; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(101; "Price Update Template Code"; Code[20])
        {
            Caption = 'Price Update Template Code';
            TableRelation = "Price Update Template";
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; Partner, "Subscription Contract No.")
        {
        }
    }

    var
        NotificationSent: Boolean;

    internal procedure InitNewLine()
    begin
        Rec.Init();
        Rec."Entry No." := 0;
    end;

    internal procedure UpdateFromServiceCommitment(ServiceCommitment: Record "Subscription Line")
    begin
        ServiceCommitment.CalcFields("Subscription Description", Quantity);
        Rec."Subscription Header No." := ServiceCommitment."Subscription Header No.";
        Rec."Subscription Line Entry No." := ServiceCommitment."Entry No.";
        Rec."Subscription Description" := ServiceCommitment."Subscription Description";
        Rec."Subscription Line Description" := ServiceCommitment.Description;
        Rec.Partner := ServiceCommitment.Partner;
        Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
        Rec."Old Price" := ServiceCommitment.Price;
        Rec."Old Calculation Base" := ServiceCommitment."Calculation Base Amount";
        Rec."Old Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Old Amount" := ServiceCommitment.Amount;
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec.Quantity := ServiceCommitment.Quantity;
    end;

    internal procedure UpdateFromContract(ServicePartner: Enum "Service Partner"; ContractNo: Code[20])
    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
    begin
        if ContractNo = '' then
            exit;
        case ServicePartner of
            "Service Partner"::Customer:
                begin
                    CustomerContract.Get(ContractNo);
                    Rec."Sub. Contract Description" := CustomerContract."Description Preview";
                    Rec."Partner No." := CustomerContract."Sell-to Customer No.";
                    Rec."Partner Name" := CustomerContract."Sell-to Customer Name";
                end;
            "Service Partner"::Vendor:
                begin
                    VendorContract.Get(ContractNo);
                    Rec."Sub. Contract Description" := VendorContract."Description Preview";
                    Rec."Partner No." := VendorContract."Pay-to Vendor No.";
                    Rec."Partner Name" := VendorContract."Pay-to Name";
                end;
        end;
    end;

    internal procedure PriceUpdateLineExists(ServiceCommitment: Record "Subscription Line"): Boolean
    var
        ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line";
    begin
        ContractPriceUpdateLine.FilterOnServiceCommitment(ServiceCommitment."Entry No.");
        exit(not ContractPriceUpdateLine.IsEmpty());
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitmentEntryNo: Integer)
    begin
        Rec.SetRange("Subscription Line Entry No.", ServiceCommitmentEntryNo);
    end;

    internal procedure CalculateNewPrice()
    var
        Currency: Record Currency;
    begin
        Currency.InitRoundingPrecision();
        Rec."New Price" := Round(Rec."New Calculation Base" * Rec."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        Rec."New Amount" := Round((Rec."New Price" * Rec.Quantity), Currency."Amount Rounding Precision");
        Rec."Discount Amount" := Round(Rec."Discount %" * Rec."New Amount" / 100, Currency."Amount Rounding Precision");
        Rec."New Amount" := Rec."New Amount" - Rec."Discount Amount";
        Rec."Additional Amount" := Rec."New Amount" - Rec."Old Amount";
    end;

    internal procedure CalculateNewCalculationBaseAmount()
    var
        ServiceObject: Record "Subscription Header";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
    begin
        ServiceObject.Get(Rec."Subscription Header No.");
        case Rec.Partner of
            "Service Partner"::Customer:
                begin
                    ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", Rec."Perform Update On", '');
                    ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject, Rec."Perform Update On");
                    Rec."New Calculation Base" := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
                end;
            "Service Partner"::Vendor:
                if ServiceObject.IsItem() then
                    Rec."New Calculation Base" := ContractsItemManagement.CalculateUnitCost(ServiceObject."Source No.");
        end;
    end;

    internal procedure ShouldContractPriceUpdateLineBeInserted(): Boolean
    begin
        exit(Rec."New Calculation Base" > 0);
    end;

    internal procedure ShowContractPriceUpdateLineNotInsertedNotification()
    var
        ContractPriceUpdateLineNotCreatedNotification: Notification;
        AtLeastOneContractPriceUpdateLineIsNotCreatedMsg: Label 'At least one Price Update line has not been created because the price update would turn the price negative or equal to 0.';
    begin
        if NotificationSent then
            exit;
        ContractPriceUpdateLineNotCreatedNotification.Message(AtLeastOneContractPriceUpdateLineIsNotCreatedMsg);
        ContractPriceUpdateLineNotCreatedNotification.Scope := NotificationScope::LocalScope;
        ContractPriceUpdateLineNotCreatedNotification.Send();
        NotificationSent := true;
    end;

    internal procedure UpdatePerformUpdateOn(ServiceCommitment: Record "Subscription Line"; PerformUpdateOnDate: Date)
    var
        DateTimeManagement: Codeunit "Date Time Management";
        DateList: List of [Date];
    begin
        DateList.Add(ServiceCommitment."Next Billing Date");
        DateList.Add(ServiceCommitment."Next Price Update");
        DateList.Add(PerformUpdateOnDate);
        Rec."Perform Update On" := DateTimeManagement.GetMaxDate(DateList);
    end;
}
