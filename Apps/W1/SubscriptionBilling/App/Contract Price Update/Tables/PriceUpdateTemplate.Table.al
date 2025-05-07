namespace Microsoft.SubscriptionBilling;

table 8003 "Price Update Template"
{
    Caption = 'Price Update Template';
    DataClassification = CustomerContent;
    DrillDownPageId = "Price Update Templates";
    LookupPageId = "Price Update Templates";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(3; Partner; Enum "Service Partner")
        {
            Caption = 'Partner';
        }
        field(4; "Subscription Contract Filter"; Blob)
        {
            Caption = 'Subscription Contract Filter';
        }
        field(5; "Subscription Line Filter"; Blob)
        {
            Caption = 'Subscription Line Filter';
        }
        field(6; "Subscription Filter"; Blob)
        {
            Caption = 'Subscription Filter';
        }
        field(7; "Price Update Method"; Enum "Price Update Method")
        {
            Caption = 'Price Update Method';
            trigger OnValidate()
            begin
                ThrowErrorIfUpdateValueNotZeroInCaseOfRecentItemPrices();
                ThrowErrorIfUpdateValueIsNegative();
            end;
        }
        field(8; "Update Value %"; Decimal)
        {
            Caption = 'Update Value %';
            BlankZero = true;
            trigger OnValidate()
            begin
                ThrowErrorIfUpdateValueNotZeroInCaseOfRecentItemPrices();
                ThrowErrorIfUpdateValueIsNegative();
            end;
        }
        field(9; "Perform Update on Formula"; DateFormula)
        {
            Caption = 'Perform Update on Formula';
        }
        field(10; InclContrLinesUpToDateFormula; DateFormula)
        {
            Caption = 'Include Subscription Contract Lines up to Date Formula';
        }
        field(11; "Price Binding Period"; DateFormula)
        {
            Caption = 'Price Binding Period';
        }
        field(12; "Group by"; Enum "Contract Billing Grouping")
        {
            Caption = 'Group by';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    local procedure ThrowErrorIfUpdateValueNotZeroInCaseOfRecentItemPrices()
    var
        UpdateValuePercMustBeZeroInCaseOfRecentItemPricesErr: Label 'Update value % has to be equal to 0. The price update is done by getting the current item prices instead of a percentage increase.';
    begin
        if not (Rec."Price Update Method" = "Price Update Method"::"Recent Item Prices") then
            exit;
        if Rec."Update Value %" = 0 then
            exit;
        Error(UpdateValuePercMustBeZeroInCaseOfRecentItemPricesErr);
    end;

    internal procedure ReadFilter(FieldNumber: Integer) FilterText: Text
    var
        IStream: InStream;
    begin
        case FieldNumber of
            FieldNo("Subscription Contract Filter"):
                begin
                    CalcFields("Subscription Contract Filter");
                    "Subscription Contract Filter".CreateInStream(IStream, TextEncoding::UTF8);
                end;
            FieldNo("Subscription Filter"):
                begin
                    CalcFields("Subscription Filter");
                    "Subscription Filter".CreateInStream(IStream, TextEncoding::UTF8);
                end;
            FieldNo("Subscription Line Filter"):
                begin
                    CalcFields("Subscription Line Filter");
                    "Subscription Line Filter".CreateInStream(IStream, TextEncoding::UTF8);
                end;
        end;
        IStream.ReadText(FilterText);
    end;

    internal procedure EditFilter(FieldNumber: Integer): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
        RRef: RecordRef;
        FilterText: Text;
        DefaultFilterFields: array[10] of Integer;
        i: Integer;
    begin
        case FieldNumber of
            FieldNo("Subscription Contract Filter"):
                case Rec.Partner of
                    "Service Partner"::Customer:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, Database::"Customer Subscription Contract");
                            RRef.Open(Database::"Customer Subscription Contract");
                        end;
                    "Service Partner"::Vendor:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, Database::"Vendor Subscription Contract");
                            RRef.Open(Database::"Vendor Subscription Contract");
                        end;
                end;
            FieldNo("Subscription Filter"):
                begin
                    AddDefaultFilterFields(DefaultFilterFields, Database::"Subscription Header");
                    RRef.Open(Database::"Subscription Header");
                end;
            FieldNo("Subscription Line Filter"):
                begin
                    AddDefaultFilterFields(DefaultFilterFields, Database::"Subscription Line");
                    RRef.Open(Database::"Subscription Line");
                end;

        end;

        FilterPageBuilder.AddTable(RRef.Caption, RRef.Number);
        FilterText := ReadFilter(FieldNumber);
        if FilterText <> '' then
            FilterPageBuilder.SetView(RRef.Caption, FilterText);

        for i := 1 to ArrayLen(DefaultFilterFields) do
            if DefaultFilterFields[i] <> 0 then
                FilterPageBuilder.AddFieldNo(RRef.Caption, DefaultFilterFields[i]);

        if FilterPageBuilder.RunModal() then begin
            RRef.SetView(FilterPageBuilder.GetView(RRef.Caption));
            FilterText := RRef.GetView(false);
            WriteFilter(FieldNumber, FilterText);
            exit(true);
        end;
    end;

    internal procedure WriteFilter(FieldNumber: Integer; FilterText: Text)
    var
        RRef: RecordRef;
        BlankView: Text;
        OStream: OutStream;
    begin
        case FieldNumber of
            FieldNo("Subscription Contract Filter"):
                begin
                    Clear("Subscription Contract Filter");
                    case Rec.Partner of
                        "Service Partner"::Customer:
                            RRef.Open(Database::"Customer Subscription Contract");
                        "Service Partner"::Vendor:
                            RRef.Open(Database::"Vendor Subscription Contract");
                    end;
                    BlankView := RRef.GetView(false);
                    "Subscription Contract Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
            FieldNo("Subscription Filter"):
                begin
                    Clear("Subscription Filter");
                    RRef.Open(Database::"Subscription Header");
                    BlankView := RRef.GetView(false);
                    "Subscription Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
            FieldNo("Subscription Line Filter"):
                begin
                    Clear("Subscription Line Filter");
                    RRef.Open(Database::"Subscription Line");
                    BlankView := RRef.GetView(false);
                    "Subscription Line Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
        end;

        if FilterText <> BlankView then
            OStream.WriteText(FilterText);
        Modify();
    end;

    local procedure AddDefaultFilterFields(var DefaultFilterFields: array[10] of Integer; TableID: Integer)
    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
    begin
        case TableID of
            Database::"Customer Subscription Contract":
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[2] := CustomerContract.FieldNo("Sell-to Customer No.");
                end;
            Database::"Vendor Subscription Contract":
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[2] := VendorContract.FieldNo("Buy-from Vendor No.");
                end;
            Database::"Subscription Header":
                begin
                    DefaultFilterFields[1] := ServiceObject.FieldNo(Type);
                    DefaultFilterFields[2] := ServiceObject.FieldNo("Source No.");
                end;
            Database::"Subscription Line":
                begin
                    DefaultFilterFields[1] := ServiceCommitment.FieldNo(Partner);
                    DefaultFilterFields[2] := ServiceCommitment.FieldNo("Subscription Contract No.");
                    DefaultFilterFields[3] := ServiceCommitment.FieldNo("Subscription Package Code");
                    DefaultFilterFields[4] := ServiceCommitment.FieldNo("Billing Rhythm");
                    DefaultFilterFields[5] := ServiceCommitment.FieldNo("Next Price Update");
                end;
        end;
    end;

    local procedure ThrowErrorIfUpdateValueIsNegative()
    var
        UpdateValueCannotBeNegativeErr: Label 'Calculation Base % cannot be negative.';
    begin
        if not (Rec."Price Update Method" = "Price Update Method"::"Calculation Base by %") then
            exit;
        if Rec."Update Value %" < 0 then
            Error(UpdateValueCannotBeNegativeErr);
    end;
}
