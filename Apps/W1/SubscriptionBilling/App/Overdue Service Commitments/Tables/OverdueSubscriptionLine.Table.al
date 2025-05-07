namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

table 8007 "Overdue Subscription Line"
{
    DataClassification = CustomerContent;
    Caption = 'Overdue Subscription Line';
    TableType = Temporary;

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
        field(4; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if (Partner = const(Customer)) "Customer Subscription Contract" else
            if (Partner = const(Vendor)) "Vendor Subscription Contract";
        }
        field(5; "Sub. Contract Description"; Text[100])
        {
            Caption = 'Subscription Contract Description';
        }
        field(6; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';
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
        field(10; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            ObsoleteReason = 'Replaced by field Source No.';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            TableRelation = Item;
        }
        field(12; "Subscription Contract Type"; Code[10])
        {
            Caption = 'Subscription Contract Type';
            TableRelation = "Subscription Contract Type";
        }
        field(13; "Billing Rhythm"; DateFormula)
        {
            Caption = 'Billing Rhythm';
        }
        field(14; "Subscription Line Start Date"; Date)
        {
            Caption = 'Subscription Line Start Date';
        }
        field(15; "Subscription Line End Date"; Date)
        {
            Caption = 'Subscription Line End Date';
        }
        field(16; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
        }
        field(17; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';
        }
        field(18; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
        }
        field(19; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(8007; "Source Type"; Enum "Service Object Type")
        {
            Caption = 'Source Type';
        }
        field(8008; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    internal procedure CountOverdueServiceCommitments(): Integer
    var
        ServiceCommitment: Record "Subscription Line";
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
        ServiceContractSetup: Record "Subscription Contract Setup";
        EmptyDateFormula: DateFormula;
    begin
        ServiceContractSetup.Get();
        if ServiceContractSetup."Overdue Date Formula" = EmptyDateFormula then
            exit(0D);

        exit(CalcDate(ServiceContractSetup."Overdue Date Formula", WorkDate()));
    end;

    internal procedure FillOverdueServiceCommitments()
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
        ServiceCommitment: Record "Subscription Line";
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
    begin
        ServiceCommitment.SetFilter("Next Billing Date", '<%1', OverdueDate);
        ServiceCommitment.SetRange(Closed, false);
        ServiceCommitment.SetAutoCalcFields("Subscription Description", "Source Type", "Source No.", Quantity);
        if ServiceCommitment.FindSet() then
            repeat
                Rec.Init();
                Rec."Line No." += 1;
                Rec.Partner := ServiceCommitment.Partner;
                Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
                case Rec.Partner of
                    Rec.Partner::Customer:
                        if CustomerContract.Get(Rec."Subscription Contract No.") then begin
                            Rec."Partner Name" := CustomerContract."Ship-to Name";
                            Rec."Sub. Contract Description" := CustomerContract."Description Preview";
                            Rec."Subscription Contract Type" := CustomerContract."Contract Type";
                        end;
                    Rec.Partner::Vendor:
                        if VendorContract.Get(Rec."Subscription Contract No.") then begin
                            Rec."Partner Name" := VendorContract."Buy-from Vendor Name";
                            Rec."Sub. Contract Description" := VendorContract."Description Preview";
                            Rec."Subscription Contract Type" := VendorContract."Contract Type";
                        end;
                end;
                Rec."Subscription Line Description" := ServiceCommitment.Description;
                Rec."Next Billing Date" := ServiceCommitment."Next Billing Date";
                Rec.Quantity := ServiceCommitment.Quantity;
                Rec.Price := ServiceCommitment.Price;
                Rec.Amount := ServiceCommitment.Amount;
                Rec."Source Type" := ServiceCommitment."Source Type";
                Rec."Source No." := ServiceCommitment."Source No.";
                Rec."Billing Rhythm" := ServiceCommitment."Billing Rhythm";
                Rec."Subscription Line Start Date" := ServiceCommitment."Subscription Line Start Date";
                Rec."Subscription Line End Date" := ServiceCommitment."Subscription Line End Date";
                Rec."Subscription Header No." := ServiceCommitment."Subscription Header No.";
                Rec."Subscription Description" := ServiceCommitment."Subscription Description";
                Rec."Discount %" := ServiceCommitment."Discount %";
                Rec.Insert(false);
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure OpenServiceObjectCard()
    var
        ServiceObject: Record "Subscription Header";
    begin
        ServiceObject.OpenServiceObjectCard("Subscription Header No.");
    end;
}