namespace Microsoft.SubscriptionBilling;

using System.IO;
using Microsoft.Finance.GeneralLedger.Setup;

table 8018 "Usage Data Generic Import"
{
    Caption = 'Usage Data Generic Import';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Generic Import";
    DrillDownPageId = "Usage Data Generic Import";
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Usage Data Import Entry No."; Integer)
        {
            Caption = 'Usage Data Import Entry No.';
            TableRelation = "Usage Data Import";
        }
        field(3; "Processing Status"; Enum "Processing Status")
        {
            Caption = 'Processing Status';
            Editable = false;

            trigger OnValidate()
            begin
                if "Processing Status" = "Processing Status"::None then
                    SetReason('');
            end;
        }
        field(4; "Reason Preview"; Text[80])
        {
            Caption = 'Reason';
            Editable = false;

            trigger OnLookup()
            begin
                ShowReason();
            end;
        }
        field(5; Reason; Blob)
        {
            Caption = 'Reason';
            Compressed = false;
        }
        field(6; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
        }
        field(7; "Customer ID"; Text[80])
        {
            Caption = 'Customer ID';
            TableRelation = "Usage Data Supplier Reference"."Supplier Reference";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataSupplierReference: Record "Usage Data Supplier Reference";
                UsageDataSupplier: Record "Usage Data Supplier";
            begin
                UsageDataImport.SetRange("Entry No.", "Usage Data Import Entry No.");
                if UsageDataImport.FindFirst() then
                    if UsageDataSupplier.Get(UsageDataImport."Supplier No.") then begin
                        UsageDataSupplierReference.SetRange(Type, UsageDataSupplierReference.Type::Customer);
                        UsageDataSupplierReference.SetRange("Supplier No.", UsageDataSupplier."No.");
                        if Page.RunModal(0, UsageDataSupplierReference) = Action::LookupOK then
                            Validate("Customer ID", UsageDataSupplierReference."Supplier Reference");
                    end;
            end;

            trigger OnValidate()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataCustomer: Record "Usage Data Customer";
            begin
                if "Customer ID" = '' then
                    exit;

                if UsageDataImport.Get("Usage Data Import Entry No.") then begin
                    UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                    UsageDataCustomer.SetRange("Supplier Reference", "Customer ID");
                    if UsageDataCustomer.FindFirst() then
                        "Customer Name" := UsageDataCustomer."Customer Name";
                end;
            end;
        }
        field(8; "Customer Name"; Text[250])
        {
            Caption = 'Customer Name';

            trigger OnLookup()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataCustomer: Record "Usage Data Customer";
            begin
                UsageDataImport.Get("Usage Data Import Entry No.");
                UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                if Page.RunModal(0, UsageDataCustomer) = Action::LookupOK then
                    Validate("Customer ID", UsageDataCustomer."Supplier Reference");
            end;

            trigger OnValidate()
            var
                UsageDataCustomer: Record "Usage Data Customer";
                UsageDataImport: Record "Usage Data Import";
            begin
                if "Customer Name" = '' then begin
                    Validate("Customer ID", '');
                    exit;
                end;

                UsageDataImport.Get("Usage Data Import Entry No.");
                UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                UsageDataCustomer.SetFilter("Customer Name", '%1', '@' + Rec."Customer Name" + '*');
                if UsageDataCustomer.FindFirst() then
                    Validate("Customer ID", UsageDataCustomer."Supplier Reference");
            end;
        }
        field(9; "Invoice ID"; Text[36])
        {
            Caption = 'Invoice ID';
        }
        field(10; "Subscription ID"; Text[80])
        {
            Caption = 'Subscription Id';

            trigger OnLookup()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataSubscription: Record "Usage Data Subscription";
            begin
                UsageDataImport.Get("Usage Data Import Entry No.");
                UsageDataSubscription.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                if Page.RunModal(0, UsageDataSubscription) = Action::LookupOK then
                    Validate("Subscription ID", UsageDataSubscription."Supplier Reference");
            end;

            trigger OnValidate()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataSubscription: Record "Usage Data Subscription";
            begin
                if "Subscription ID" = '' then
                    exit;

                if UsageDataImport.Get("Usage Data Import Entry No.") then begin
                    UsageDataSubscription.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                    UsageDataSubscription.SetRange("Supplier Reference", "Subscription ID");
                    if UsageDataSubscription.FindFirst() then begin
                        if Rec."Subscription Name" = '' then
                            Rec."Subscription Name" := UsageDataSubscription."Customer Name";
                        if Rec."Product ID" = '' then
                            Rec."Product ID" := UsageDataSubscription."Product ID";
                        if Rec."Product Name" = '' then
                            Rec."Product Name" := UsageDataSubscription."Product Name";
                        if (Rec.Quantity = 0) and (CurrFieldNo <> 0) then
                            Rec.Quantity := UsageDataSubscription.Quantity;
                    end;
                end;
            end;
        }
        field(11; "Subscription Name"; Text[250])
        {
            Caption = 'Subscription Name';

            trigger OnLookup()
            var
                UsageDataImport: Record "Usage Data Import";
                UsageDataSubscription: Record "Usage Data Subscription";
            begin
                UsageDataImport.Get("Usage Data Import Entry No.");
                UsageDataSubscription.SetRange("Supplier No.", UsageDataImport."Supplier No.");
                if Page.RunModal(0, UsageDataSubscription) = Action::LookupOK then
                    Validate("Subscription ID", UsageDataSubscription."Supplier Reference");
            end;
        }
        field(12; "Subscription Description"; Text[250])
        {
            Caption = 'Subscription Description';
        }
        field(13; "Subscription Start Date"; Date)
        {
            Caption = 'Subscription Start Date';
        }
        field(14; "Subscription End Date"; Date)
        {
            Caption = 'Subscription End Date';
        }
        field(15; "Billing Period Start Date"; Date)
        {
            Caption = 'Billing Period Start Date';
        }
        field(16; "Billing Period End Date"; Date)
        {
            Caption = 'Billing Period End Date';
        }
        field(17; "Product ID"; Text[80])
        {
            Caption = 'Product Id';
        }
        field(18; "Product Name"; Text[100])
        {
            Caption = 'Product Name';
        }
        field(19; Cost; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(20; Price; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 6;
        }
        field(22; Discount; Decimal)
        {
            Caption = 'Discount';
            DecimalPlaces = 0 : 6;
        }
        field(23; Tax; Decimal)
        {
            Caption = 'Tax';
            DecimalPlaces = 0 : 6;
        }
        field(24; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 0 : 6;
        }
        field(25; Currency; Text[10])
        {
            Caption = 'Currency';
        }
        field(26; Unit; Text[30])
        {
            Caption = 'Unit';
        }
        field(27; "Cost Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Cost Amount';
        }

        field(50; Text1; Text[80])
        {
            Caption = 'Text1';
        }
        field(51; Text2; Text[80])
        {
            Caption = 'Text2';
        }
        field(52; Text3; Text[80])
        {
            Caption = 'Text3';
        }
        field(53; Decimal1; Decimal)
        {
            Caption = 'Decimal1';
        }
        field(54; Decimal2; Decimal)
        {
            Caption = 'Decimal2';
        }
        field(55; Decimal3; Decimal)
        {
            Caption = 'Decimal3';
        }
        field(1220; "Data Exch. Entry No."; Integer)
        {
            Caption = 'Data Exch. Entry No.';
            Editable = false;
            TableRelation = "Data Exch.";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        UsageDataImportEntryNo: Integer;
    begin
        if Evaluate(UsageDataImportEntryNo, GetFilter("Usage Data Import Entry No.")) then
            "Usage Data Import Entry No." := UsageDataImportEntryNo;
    end;

    trigger OnModify()
    begin
        InitRecord();
    end;

    internal procedure InitFromUsageDataImport(UsageDataImport: Record "Usage Data Import")
    begin
        Init();
        "Entry No." := 0;
        "Usage Data Import Entry No." := UsageDataImport."Entry No.";
    end;

    local procedure InitRecord()
    var
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataImport: Record "Usage Data Import";
        UsageDataCustomer: Record "Usage Data Customer";
    begin
        UsageDataImport.SetRange("Entry No.", "Usage Data Import Entry No.");
        if UsageDataImport.FindFirst() then
            if UsageDataSupplier.Get(UsageDataImport."Supplier No.") then
                if ("Customer ID" = '') or ("Customer Name" = '') then begin
                    UsageDataCustomer.Reset();
                    UsageDataCustomer.SetRange("Supplier No.", UsageDataSupplier."No.");
                    if UsageDataCustomer.FindFirst() then begin
                        if "Customer ID" = '' then
                            "Customer ID" := UsageDataCustomer."Supplier Reference";
                        if "Customer Name" = '' then
                            "Customer Name" := UsageDataCustomer."Customer Name";
                    end;
                end;
    end;

    internal procedure SetReason(ReasonText: Text)
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        if ReasonText = '' then begin
            Clear("Reason Preview");
            Clear(Reason);
        end else begin
            "Reason Preview" := CopyStr(ReasonText, 1, MaxStrLen("Reason Preview"));
            RRef.GetTable(Rec);
            TextManagement.WriteBlobText(RRef, FieldNo(Reason), ReasonText);
            RRef.SetTable(Rec);
        end;
    end;

    internal procedure ShowReason()
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        CalcFields(Reason);
        RRef.GetTable(Rec);
        TextManagement.ShowFieldText(RRef, FieldNo(Reason));
    end;

    internal procedure GetCurrencyCode(): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if UpperCase(Rec.Currency) <> GLSetup."LCY Code" then
            exit(Rec.Currency);
    end;

    internal procedure GetNextEntryNo(): Integer
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        if UsageDataGenericImport.FindLast() then;
        exit(UsageDataGenericImport."Entry No." + 1);
    end;
}
