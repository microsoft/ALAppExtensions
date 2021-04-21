table 18318 "GST Credit Adjustment Journal"
{
    Caption = 'GST Credit Adjustment Journal';

    fields
    {
        field(1; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Registration Nos.";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Vendor;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Document Type"; Enum "Adjustment Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
        field(8; "Total GST Amount"; Decimal)
        {
            Caption = 'Total GST Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Total GST Credit Amount"; Decimal)
        {
            Caption = 'Total GST Credit Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Nature of Adjustment"; Enum "Credit Adjustment Type")
        {
            Caption = 'Nature of Adjustment';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Nature of Adjustment" <> "Nature of Adjustment"::" ") and
                    ("Nature of Adjustment" <> "Selected Nature of Adjustment")
                then
                    Error(NatureofAdjErr, "Selected Nature of Adjustment");
            end;
        }
        field(16; "Adjustment %"; Decimal)
        {
            Caption = 'Adjustment %';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Adjustment %");
                if "Document Type" = "Document Type"::"Credit Memo" then begin
                    "Adjustment Amount" := Abs(("Total GST Credit Amount" * "Adjustment %") / 100);
                    "Total GST Amount" := ("Total GST Credit Amount" * "Adjustment %") / 100;
                end;

                if "Document Type" = "Document Type"::Invoice then begin
                    "Adjustment Amount" := ("Total GST Credit Amount" * "Adjustment %") / 100;
                    "Total GST Amount" := "Adjustment Amount";
                end;

                if "Adjustment %" > "Available Adjustment %" then
                    Error(
                        AdjustmentPercGreaterErr,
                        "Adjustment %",
                        "Available Adjustment %",
                        "Document No.");
            end;
        }
        field(17; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Adjustment Amount");
                "Adjustment %" := Abs(("Adjustment Amount" * 100) / "Total GST Credit Amount");
                if "Document Type" = "Document Type"::Invoice then
                    "Total GST Amount" := "Adjustment Amount";
                if "Document Type" = "Document Type"::"Credit Memo" then
                    "Total GST Amount" := -Abs("Adjustment Amount");
                if "Adjustment Amount" > "Available Adjustment Amount" then
                    Error(
                        AdjustmentAmtGreaterErr,
                        "Adjustment Amount",
                        "Available Adjustment Amount",
                        "Document No.");
            end;
        }
        field(18; "Adjustment Posting Date"; Date)
        {
            Caption = 'Adjustment Posting Date';
            DataClassification = CustomerContent;
        }
        field(19; "Adjust Document No."; Code[20])
        {
            Caption = 'Adjust Document No.';
            DataClassification = CustomerContent;
        }
        field(20; "Selected Nature of Adjustment"; Enum "Credit Adjustment Type")
        {
            Caption = 'Selected Nature of Adjustment';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = CustomerContent;
        }
        field(22; Type; Enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                TypeText: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
                TypeVal: Text;
            begin
                TypeVal := Format(Type);
                Evaluate(Typetext, TypeVal);
                CreateDim(
                  DimMgt.TypeToTableID3(Typetext), "No.");
            end;
        }
        field(24; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Gen. Business Posting Group";
        }
        field(25; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
        }
        field(26; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
        field(28; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(31; "Available Adjustment %"; Decimal)
        {
            Caption = 'Available Adjustment %';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Available Adjustment Amount"; Decimal)
        {
            Caption = 'Available Adjustment Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "GST Registration No.", "Document Type", "Document No.", "Document Line No.")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
        NatureofAdjErr: Label 'Nature of Adjustment can be Blank or %1 only.', Comment = '%1 = Option';
        Text051Qst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        AdjustmentAmtGreaterErr: Label 'Adjustment Amount %1 must not be greater than Available Adjustment Amount %2 in Document No. %3.', Comment = '%1 = Adjustment Amount %2 = Available Adjustment Amount  %3 = Document No.';
        AdjustmentPercGreaterErr: Label 'Adjustment Percentage %1 must not be greater than Available Adjustment Percentage %2 in Document No. %3.', Comment = '%1 = Adjustment Percentage %2 = Available Adjustment Percentage  %3 = Document No.';
        DimensionSetDocMsg: Label '%1,%2', comment = '%1=Document Type,%2= No.';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify();

        if OldDimSetID <> "Dimension Set ID" then
            Modify();
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(DimensionSetDocMsg, "Document Type", "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
              TableID,
              No,
              SourceCodeSetup.Purchases,
              "Shortcut Dimension 1 Code",
              "Shortcut Dimension 2 Code",
              "Dimension Set ID",
              0);

        DimMgt.UpdateGlobalDimFromDimSetID(
            "Dimension Set ID",
            "Shortcut Dimension 1 Code",
            "Shortcut Dimension 2 Code");
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        NewDimSetID: Integer;
    begin
        if NewParentDimSetID = OldParentDimSetID then
            exit;
        if not Confirm(Text051Qst) then
            exit;
        if FindSet() then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID("Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if "Dimension Set ID" <> NewDimSetID then begin
                    "Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      "Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                    Modify();
                end;
            until Next() = 0;
    end;
}