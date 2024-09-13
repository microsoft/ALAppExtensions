namespace Microsoft.SubscriptionBilling;

table 8007 "Overdue Service Commitments"
{
    DataClassification = CustomerContent;
    Caption = 'Overdue Service Commitments';
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(2; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(3; "Partner Name"; Text[100])
        {
            Caption = 'Partner Name';
        }
        field(4; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
        }
        field(5; "Contract Description"; Text[100])
        {
            Caption = 'Contract Description';
        }
        field(6; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';
        }
        field(7; "Next Billing Date"; Date)
        {
            Caption = 'Next Billing Date';
            Editable = false;
        }
        field(9; Price; Decimal)
        {
            Caption = 'Price';
        }
        field(10; "Service Amount"; Decimal)
        {
            Caption = 'Service Amount';
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(12; "Contract Type"; Code[10])
        {
            Caption = 'Contract Type';
        }
        field(13; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(14; "Service Start Date"; Date)
        {
            Caption = 'Service Start Date';
        }
        field(15; "Service End Date"; Date)
        {
            Caption = 'Service End Date';
        }
        field(16; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(17; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';
        }
        field(18; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
        }
        field(19; "Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    procedure FillAndCountOverdueServiceCommitments(): Integer
    var
        OverdueDate: Date;
    begin
        Rec.DeleteAll(false);
        OverdueDate := CalcOverdueDate();
        if OverdueDate = 0D then
            exit(0);

        FillOverdueCustomerServiceCommitments(OverdueDate);
        FillOverdueVendorServiceCommitments(OverdueDate);
        exit(Rec.Count());
    end;

    local procedure CalcOverdueDate(): Date
    var
        ServiceContractSetup: Record "Service Contract Setup";
        EmptyDateFormula: DateFormula;
    begin
        ServiceContractSetup.Get();
        if ServiceContractSetup."Overdue Date Formula" = EmptyDateFormula then
            exit(0D);

        exit(CalcDate(ServiceContractSetup."Overdue Date Formula", WorkDate()));
    end;

    local procedure FillOverdueCustomerServiceCommitments(OverdueDate: Date)
    var
        OverdueCustomerServComm: Query "Overdue Customer Serv. Comm.";
    begin
        Clear(OverdueCustomerServComm);
        OverdueCustomerServComm.SetFilter(NextBillingDate, '<%1', OverdueDate);
        OverdueCustomerServComm.SetRange(ContractLineClosed, false);
        if OverdueCustomerServComm.Open() then begin
            while OverdueCustomerServComm.Read() do begin
                Rec.Init();
                Rec."Line No." += 1;
                Rec.Partner := OverdueCustomerServComm.Partner;
                Rec."Partner Name" := OverdueCustomerServComm.PartnerName;
                Rec."Contract No." := OverdueCustomerServComm.ContractNo;
                Rec."Contract Description" := OverdueCustomerServComm.ContractDescription;
                Rec."Service Commitment Description" := OverdueCustomerServComm.ServCommDescription;
                Rec."Next Billing Date" := OverdueCustomerServComm.NextBillingDate;
                Rec."Quantity Decimal" := OverdueCustomerServComm.Quantity;
                Rec.Price := OverdueCustomerServComm.Price;
                Rec."Service Amount" := OverdueCustomerServComm.ServiceAmount;
                Rec."Item No." := OverdueCustomerServComm.ItemNo;
                Rec."Contract Type" := OverdueCustomerServComm.ContractType;
                Rec."Billing Rhythm" := OverdueCustomerServComm.BillingRhythm;
                Rec."Service Start Date" := OverdueCustomerServComm.ServiceStartDate;
                Rec."Service End Date" := OverdueCustomerServComm.ServiceEndDate;
                Rec."Service Object No." := OverdueCustomerServComm.ServiceObjectNo;
                Rec."Service Object Description" := OverdueCustomerServComm.ServiceObjectDescription;
                Rec."Discount %" := OverdueCustomerServComm.Discount;
                Rec.Insert(true);
            end;
            OverdueCustomerServComm.Close();
        end;
    end;

    local procedure FillOverdueVendorServiceCommitments(OverdueDate: Date)
    var
        OverdueVendorServComm: Query "Overdue Vendor Serv. Comm.";
    begin
        Clear(OverdueVendorServComm);
        OverdueVendorServComm.SetFilter(NextBillingDate, '<%1', OverdueDate);
        OverdueVendorServComm.SetRange(ContractLineClosed, false);
        if OverdueVendorServComm.Open() then begin
            while OverdueVendorServComm.Read() do begin
                Rec.Init();
                Rec."Line No." += 1;
                Rec.Partner := OverdueVendorServComm.Partner;
                Rec."Partner Name" := OverdueVendorServComm.PartnerName;
                Rec."Contract No." := OverdueVendorServComm.ContractNo;
                Rec."Contract Description" := OverdueVendorServComm.ContractDescription;
                Rec."Service Commitment Description" := OverdueVendorServComm.ServCommDescription;
                Rec."Next Billing Date" := OverdueVendorServComm.NextBillingDate;
                Rec."Quantity Decimal" := OverdueVendorServComm.Quantity;
                Rec.Price := OverdueVendorServComm.Price;
                Rec."Service Amount" := OverdueVendorServComm.ServiceAmount;
                Rec."Item No." := OverdueVendorServComm.ItemNo;
                Rec."Contract Type" := OverdueVendorServComm.ContractType;
                Rec."Billing Rhythm" := OverdueVendorServComm.BillingRhythm;
                Rec."Service Start Date" := OverdueVendorServComm.ServiceStartDate;
                Rec."Service End Date" := OverdueVendorServComm.ServiceEndDate;
                Rec."Service Object No." := OverdueVendorServComm.ServiceObjectNo;
                Rec."Service Object Description" := OverdueVendorServComm.ServiceObjectDescription;
                Rec."Discount %" := OverdueVendorServComm.Discount;
                Rec.Insert(true);
            end;
            OverdueVendorServComm.Close();
        end;
    end;
}