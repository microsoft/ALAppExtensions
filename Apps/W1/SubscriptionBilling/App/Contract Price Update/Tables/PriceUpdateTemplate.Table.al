namespace Microsoft.SubscriptionBilling;

table 8003 "Price Update Template"
{
    Caption = 'Price Update Template';
    DataClassification = CustomerContent;
    DrillDownPageId = "Price Update Templates";
    LookupPageId = "Price Update Templates";
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
        field(4; "Contract Filter"; Blob)
        {
            Caption = 'Contract Filter';
        }
        field(5; "Service Commitment Filter"; Blob)
        {
            Caption = 'Service Commitment Filter';
        }
        field(6; "Service Object Filter"; Blob)
        {
            Caption = 'Service Object Filter';
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
            Caption = 'Include Contract Lines up to Date Formula';
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
            FieldNo("Contract Filter"):
                begin
                    CalcFields("Contract Filter");
                    "Contract Filter".CreateInStream(IStream, TextEncoding::UTF8);
                end;
            FieldNo("Service Object Filter"):
                begin
                    CalcFields("Service Object Filter");
                    "Service Object Filter".CreateInStream(IStream, TextEncoding::UTF8);
                end;
            FieldNo("Service Commitment Filter"):
                begin
                    CalcFields("Service Commitment Filter");
                    "Service Commitment Filter".CreateInStream(IStream, TextEncoding::UTF8);
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
            FieldNo("Contract Filter"):
                case Rec.Partner of
                    "Service Partner"::Customer:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, Database::"Customer Contract");
                            RRef.Open(Database::"Customer Contract");
                        end;
                    "Service Partner"::Vendor:
                        begin
                            AddDefaultFilterFields(DefaultFilterFields, Database::"Vendor Contract");
                            RRef.Open(Database::"Vendor Contract");
                        end;
                end;
            FieldNo("Service Object Filter"):
                begin
                    AddDefaultFilterFields(DefaultFilterFields, Database::"Service Object");
                    RRef.Open(Database::"Service Object");
                end;
            FieldNo("Service Commitment Filter"):
                begin
                    AddDefaultFilterFields(DefaultFilterFields, Database::"Service Commitment");
                    RRef.Open(Database::"Service Commitment");
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
            FieldNo("Contract Filter"):
                begin
                    Clear("Contract Filter");
                    case Rec.Partner of
                        "Service Partner"::Customer:
                            RRef.Open(Database::"Customer Contract");
                        "Service Partner"::Vendor:
                            RRef.Open(Database::"Vendor Contract");
                    end;
                    BlankView := RRef.GetView(false);
                    "Contract Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
            FieldNo("Service Object Filter"):
                begin
                    Clear("Service Object Filter");
                    RRef.Open(Database::"Service Object");
                    BlankView := RRef.GetView(false);
                    "Service Object Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
            FieldNo("Service Commitment Filter"):
                begin
                    Clear("Service Commitment Filter");
                    RRef.Open(Database::"Service Commitment");
                    BlankView := RRef.GetView(false);
                    "Service Commitment Filter".CreateOutStream(OStream, TextEncoding::UTF8);
                end;
        end;

        if FilterText <> BlankView then
            OStream.WriteText(FilterText);
        Modify();
    end;

    local procedure AddDefaultFilterFields(var DefaultFilterFields: array[10] of Integer; TableID: Integer)
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
    begin
        case TableID of
            Database::"Customer Contract":
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[2] := CustomerContract.FieldNo("Sell-to Customer No.");
                end;
            Database::"Vendor Contract":
                begin
                    DefaultFilterFields[1] := CustomerContract.FieldNo("Contract Type");
                    DefaultFilterFields[2] := VendorContract.FieldNo("Buy-from Vendor No.");
                end;
            Database::"Service Object":
                DefaultFilterFields[1] := ServiceObject.FieldNo("Item No.");
            Database::"Service Commitment":
                begin
                    DefaultFilterFields[1] := ServiceCommitment.FieldNo(Partner);
                    DefaultFilterFields[2] := ServiceCommitment.FieldNo("Contract No.");
                    DefaultFilterFields[3] := ServiceCommitment.FieldNo("Package Code");
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
