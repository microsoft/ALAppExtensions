namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Sales.Document;

table 8004 "Contract Price Update Line"
{
    Caption = 'Contract Price Update Line';
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(3; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
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
        field(7; "Contract No."; Code[20])
        {
            Caption = 'Contract';
        }
        field(8; "Contract Description"; Text[100])
        {
            Caption = 'Contract Description';
        }
        field(9; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
        }
        field(10; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
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
        field(13; "Additional Service Amount"; Decimal)
        {
            Caption = 'Additional Service Amount';
            Editable = false;
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(14; "Old Service Amount"; Decimal)
        {
            Caption = 'Old Service Amount';
            BlankZero = true;
            AutoFormatType = 1;
        }
        field(15; "New Service Amount"; Decimal)
        {
            Caption = 'New Service Amount';
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
        key(SK1; Partner, "Contract No.")
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

    internal procedure UpdateFromServiceCommitment(ServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitment.CalcFields("Service Object Description", "Quantity Decimal");
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        Rec."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        Rec."Service Object Description" := ServiceCommitment."Service Object Description";
        Rec."Service Commitment Description" := ServiceCommitment.Description;
        Rec.Partner := ServiceCommitment.Partner;
        Rec."Contract No." := ServiceCommitment."Contract No.";
        Rec."Old Price" := ServiceCommitment.Price;
        Rec."Old Calculation Base" := ServiceCommitment."Calculation Base Amount";
        Rec."Old Calculation Base %" := ServiceCommitment."Calculation Base %";
        Rec."Old Service Amount" := ServiceCommitment."Service Amount";
        Rec."Discount %" := ServiceCommitment."Discount %";
        Rec."Discount Amount" := ServiceCommitment."Discount Amount";
        Rec.Quantity := ServiceCommitment."Quantity Decimal";
    end;

    internal procedure UpdateFromContract(ServicePartner: Enum "Service Partner"; ContractNo: Code[20])
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        if ContractNo = '' then
            exit;
        case ServicePartner of
            "Service Partner"::Customer:
                begin
                    CustomerContract.Get(ContractNo);
                    Rec."Contract Description" := CustomerContract."Description Preview";
                    Rec."Partner No." := CustomerContract."Sell-to Customer No.";
                    Rec."Partner Name" := CustomerContract."Sell-to Customer Name";
                end;
            "Service Partner"::Vendor:
                begin
                    VendorContract.Get(ContractNo);
                    Rec."Contract Description" := VendorContract."Description Preview";
                    Rec."Partner No." := VendorContract."Pay-to Vendor No.";
                    Rec."Partner Name" := VendorContract."Pay-to Name";
                end;
        end;
    end;

    internal procedure PriceUpdateLineExists(ServiceCommitment: Record "Service Commitment"): Boolean
    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
    begin
        ContractPriceUpdateLine.FilterOnServiceCommitment(ServiceCommitment."Entry No.");
        exit(not ContractPriceUpdateLine.IsEmpty());
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitmentEntryNo: Integer)
    begin
        Rec.SetRange("Service Commitment Entry No.", ServiceCommitmentEntryNo);
    end;

    internal procedure CalculateNewPrice()
    var
        Currency: Record Currency;
    begin
        Currency.InitRoundingPrecision();
        Rec."New Price" := Round(Rec."New Calculation Base" * Rec."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        Rec."New Service Amount" := Round((Rec."New Price" * Rec.Quantity), Currency."Amount Rounding Precision");
        Rec."Additional Service Amount" := Rec."New Service Amount" - Rec."Old Service Amount";
        Rec."Discount Amount" := Rec."Discount %" * Rec."New Service Amount";
    end;

    internal procedure CalculateNewCalculationBaseAmount()
    var
        ServiceObject: Record "Service Object";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ContractsItemManagement: Codeunit "Contracts Item Management";
    begin
        ServiceObject.Get(Rec."Service Object No.");
        case Rec.Partner of
            "Service Partner"::Customer:
                begin
                    ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", Rec."Perform Update On", '');
                    ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject."Item No.", ServiceObject."Quantity Decimal", Rec."Perform Update On");
                    Rec."New Calculation Base" := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
                end;
            "Service Partner"::Vendor:
                Rec."New Calculation Base" := ContractsItemManagement.CalculateUnitCost(ServiceObject."Item No.");
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

    internal procedure UpdatePerformUpdateOn(ServiceCommitment: Record "Service Commitment"; PerformUpdateOnDate: Date)
    begin
        if (ServiceCommitment."Next Billing Date" <= PerformUpdateOnDate) or ServiceCommitment.UnpostedDocumentExists() then
            Rec."Perform Update On" := PerformUpdateOnDate
        else
            Rec."Perform Update On" := ServiceCommitment."Next Billing Date";
    end;
}
