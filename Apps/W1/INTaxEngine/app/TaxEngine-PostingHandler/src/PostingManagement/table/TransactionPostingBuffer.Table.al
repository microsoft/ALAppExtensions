table 20336 "Transaction Posting Buffer"
{
    Caption = 'Transaction Posting Buffer';
    DataClassification = EndUserIdentifiableInformation;
    TableType = Temporary;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }

        field(3; "Account No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Account No.';
        }
        field(5; "Tax Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax ID';
        }
        field(6; Amount; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount';
        }
        field(7; "Gen. Bus. Posting Group"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(8; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(9; "Component ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Component ID';
        }
        field(10; "Dimension Set ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Dimension Set ID';
        }
        field(11; "Tax Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Record ID';
        }
        field(12; "Currency Code"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }
        field(13; "Currency Factor"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Currency Factor';
        }
        field(14; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(15; "Skip Posting"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Skip Posting';
        }
        field(16; "G/L Entry No"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'G/L Entry No.';
        }
        field(17; "Group ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Group ID';
        }
        field(18; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
        }
        field(19; "Posted Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Posted Document No.';
        }
        field(20; "Posted Document Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Posted Document Line No.';
        }
        field(21; "Reverse Charge"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Reverse Charge';
        }
        field(22; "Reverse Charge G/L Account"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Reverse Charge G/L Account';
        }
        field(23; "G/L Entry Transaction No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'G/L Entry Transaction No.';
        }
        field(24; "Amount (LCY)"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount (LCY)';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin

        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;
}