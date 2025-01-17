namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

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
            TableRelation = if (Partner = const(Customer)) "Customer Contract" else
            if (Partner = const(Vendor)) "Vendor Contract";
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
            TableRelation = Item;
        }
        field(12; "Contract Type"; Code[10])
        {
            Caption = 'Contract Type';
            TableRelation = "Contract Type";
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

    procedure CountOverdueServiceCommitments(): Integer
    var
        ServiceCommitment: Record "Service Commitment";
        OverdueDate: Date;
    begin
        OverdueDate := CalcOverdueDate();
        if OverdueDate = 0D then
            exit(0);

        ServiceCommitment.SetFilter("Next Billing Date", '<%1', OverdueDate);
        ServiceCommitment.SetRange(Closed, false);
        exit(ServiceCommitment.Count());
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

    procedure FillOverdueServiceCommitments()
    var
        OverdueDate: Date;
    begin
        DeleteAll(false);
        OverdueDate := CalcOverdueDate();
        if OverdueDate = 0D then
            exit;

        FillOverdueServiceCommitments(OverdueDate);
    end;

    local procedure FillOverdueServiceCommitments(OverdueDate: Date)
    var
        ServiceCommitment: Record "Service Commitment";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        ServiceCommitment.SetFilter("Next Billing Date", '<%1', OverdueDate);
        ServiceCommitment.SetRange(Closed, false);
        ServiceCommitment.SetAutoCalcFields("Service Object Description", "Item No.", "Quantity Decimal");
        if ServiceCommitment.FindSet() then
            repeat
                Rec.Init();
                Rec."Line No." += 1;
                Rec.Partner := ServiceCommitment.Partner;
                Rec."Contract No." := ServiceCommitment."Contract No.";
                case Rec.Partner of
                    Rec.Partner::Customer:
                        if CustomerContract.Get(Rec."Contract No.") then begin
                            Rec."Partner Name" := CustomerContract."Ship-to Name";
                            Rec."Contract Description" := CustomerContract."Description Preview";
                            Rec."Contract Type" := CustomerContract."Contract Type";
                        end;
                    Rec.Partner::Vendor:
                        if VendorContract.Get(Rec."Contract No.") then begin
                            Rec."Partner Name" := VendorContract."Buy-from Vendor Name";
                            Rec."Contract Description" := VendorContract."Description Preview";
                            Rec."Contract Type" := VendorContract."Contract Type";
                        end;
                end;
                Rec."Service Commitment Description" := ServiceCommitment.Description;
                Rec."Next Billing Date" := ServiceCommitment."Next Billing Date";
                Rec."Quantity Decimal" := ServiceCommitment."Quantity Decimal";
                Rec.Price := ServiceCommitment.Price;
                Rec."Service Amount" := ServiceCommitment."Service Amount";
                Rec."Item No." := ServiceCommitment."Item No.";
                Rec."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
                Rec."Service Start Date" := ServiceCommitment."Service Start Date";
                Rec."Service End Date" := ServiceCommitment."Service End Date";
                Rec."Service Object No." := ServiceCommitment."Service Object No.";
                Rec."Service Object Description" := ServiceCommitment."Service Object Description";
                Rec."Discount %" := ServiceCommitment."Discount %";
                Rec.Insert(false);
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure OpenServiceObjectCard()
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.OpenServiceObjectCard("Service Object No.");
    end;
}