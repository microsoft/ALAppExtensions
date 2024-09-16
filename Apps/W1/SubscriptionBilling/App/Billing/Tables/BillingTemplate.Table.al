namespace Microsoft.SubscriptionBilling;

table 8060 "Billing Template"
{
    DataClassification = CustomerContent;
    Caption = 'Billing Template';
    LookupPageId = "Billing Templates";
    DrillDownPageId = "Billing Templates";
    Access = Internal;

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
        field(5; "Billing Date Formula"; DateFormula)
        {
            Caption = 'Billing Date Formula';
        }
        field(6; "Billing to Date Formula"; DateFormula)
        {
            Caption = 'Billing to Date Formula';
        }
        field(7; "My Suggestions Only"; Boolean)
        {
            Caption = 'My Suggestions Only';
        }
        field(9; "Group by"; Enum "Contract Billing Grouping")
        {
            Caption = 'Group by';
            InitValue = Contract;
        }
        field(10; "Filter"; Blob)
        {
            Caption = 'Filter';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    internal procedure EditFilter(FieldNumber: Integer): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
        RRef: RecordRef;
        FilterText: Text;
        DefaultFilterFields: array[10] of Integer;
        i: Integer;
    begin
        case FieldNumber of
            FieldNo(Filter):
                case Rec.Partner of
                    "Service Partner"::Customer:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, "Service Partner"::Customer);
                            RRef.Open(Database::"Customer Contract");
                        end;
                    "Service Partner"::Vendor:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, "Service Partner"::Vendor);
                            RRef.Open(Database::"Vendor Contract");
                        end;
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

    internal procedure ReadFilter(FieldNumber: Integer) FilterText: Text
    var
        IStream: InStream;
    begin
        case FieldNumber of
            FieldNo(Filter):
                begin
                    CalcFields(Filter);
                    Filter.CreateInStream(IStream, TextEncoding::UTF8);
                end;
        end;
        IStream.ReadText(FilterText);
    end;

    internal procedure WriteFilter(FieldNumber: Integer; FilterText: Text)
    var
        RRef: RecordRef;
        BlankView: Text;
        OStream: OutStream;
    begin
        case FieldNumber of
            FieldNo(Filter):
                begin
                    Clear(Filter);
                    case Rec.Partner of
                        "Service Partner"::Customer:
                            RRef.Open(Database::"Customer Contract");
                        "Service Partner"::Vendor:
                            RRef.Open(Database::"Vendor Contract");
                    end;
                    BlankView := RRef.GetView(false);
                    Filter.CreateOutStream(OStream, TextEncoding::UTF8);
                end;
        end;

        if FilterText <> BlankView then
            OStream.WriteText(FilterText);
        Modify();
    end;

    local procedure AddDefaultFilterFields(var DefaultFilterFields: array[10] of Integer; ServicePartner: Enum "Service Partner")
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        case ServicePartner of
            "Service Partner"::Customer:
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Billing Rhythm Filter");
                    DefaultFilterFields[2] := CustomerContract.FieldNo("Assigned User ID");
                    DefaultFilterFields[3] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[4] := CustomerContract.FieldNo("Salesperson Code");
                end;
            "Service Partner"::Vendor:
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Billing Rhythm Filter");
                    DefaultFilterFields[2] := CustomerContract.FieldNo("Assigned User ID");
                    DefaultFilterFields[3] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[4] := VendorContract.FieldNo("Purchaser Code");
                end;
        end;
    end;

    internal procedure IsPartnerCustomer(): Boolean
    begin
        exit(Rec.Partner = Rec.Partner::Customer);
    end;
}