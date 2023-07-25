table 2632 "Statistical Account"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "Statistical Account List";
    LookupPageId = "Statistical Account List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(6; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(7; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(28; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(29; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(30; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
#pragma warning disable AA0232
        field(31; "Balance at Date"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Statistical Ledger Entry".Amount where("Statistical Account No." = field("No."),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance at Date';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore AA0232
        field(32; "Net Change"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Statistical Ledger Entry".Amount where("Statistical Account No." = field("No."),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field("Date Filter"),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Net Change';
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; Balance; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Statistical Ledger Entry".Amount where("Statistical Account No." = field("No."),
                                                        "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                                                        "Posting Date" = field(upperlimit("Date Filter")),
                                                        "Dimension Set ID" = field("Dimension Set ID Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(400; "Dimension Set ID Filter"; Integer)
        {
            Caption = 'Dimension Set ID Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        StatisticalLedgerEntry.SetRange("Statistical Account No.", Rec."No.");
        if StatisticalLedgerEntry.IsEmpty() then
            exit;

        if not Confirm(DeleteStatAccQst) then
            Error('');

        if Confirm(DeleteStatAccSecondQst) then
            Error('');

        StatisticalLedgerEntry.DeleteAll();
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then begin
            DimensionManagement.SaveDefaultDim(DATABASE::"Statistical Account", "No.", FieldNumber, ShortcutDimCode);
            Modify();
        end;
    end;


    procedure GetFeatureTelemetryName(): Text
    begin
        exit('Statistical Accounts');
    end;

    var
        DeleteStatAccQst: Label 'There are ledger entries connected with this account. Deleting the account will permanently delete the ledger entries.\\Do you want to continue?';
        DeleteStatAccSecondQst: Label 'You will not be able to restore the ledger entries.\\Do you want to cancel the operation?';
}