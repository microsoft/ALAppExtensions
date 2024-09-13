namespace Microsoft.SubscriptionBilling;

using System.IO;

table 8013 "Usage Data Import"
{
    Caption = 'Usage Data Import';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Imports";
    DrillDownPageId = "Usage Data Imports";
    Access = Internal;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            TableRelation = "Usage Data Supplier";
        }
        field(3; "Supplier Description"; Text[80])
        {
            Caption = 'Supplier Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Usage Data Supplier".Description where("No." = field("Supplier No.")));
        }
        field(4; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(5; "Processing Date"; Date)
        {
            Caption = 'Processing Date';
            Editable = false;
        }
        field(6; "Processing Step"; Enum "Processing Step")
        {
            Caption = 'Processing Step';
            Editable = false;
        }
        field(7; "Processing Status"; Enum "Processing Status")
        {
            Caption = 'Processing Status';
            Editable = false;

            trigger OnValidate()
            begin
                if "Processing Status" in ["Processing Status"::None, "Processing Status"::Ok] then
                    SetReason('');
                if "Processing Status" = "Processing Status"::None then
                    "Processing Date" := 0D
                else
                    "Processing Date" := WorkDate();
            end;
        }
        field(8; "Reason (Preview)"; Text[80])
        {
            Caption = 'Reason (Preview)';
            Editable = false;

            trigger OnLookup()
            begin
                ShowReason();
            end;
        }
        field(9; Reason; Blob)
        {
            Caption = 'Reason';
            Compressed = false;
        }
        field(10; "No. of Usage Data Blobs"; Integer)
        {
            Caption = 'No. of Usage Data Blobs';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Usage Data Blob" where("Usage Data Import Entry No." = field("Entry No.")));
        }
        field(11; "No. of Imported Lines"; Integer)
        {
            Caption = 'No. of Imported Lines';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Usage Data Generic Import" where("Usage Data Import Entry No." = field("Entry No.")));
        }
        field(12; "No. of Imported Line Errors"; Integer)
        {
            Caption = 'No. of Imported Line Errors';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Usage Data Generic Import" where("Usage Data Import Entry No." = field("Entry No."), "Processing Status" = const(Error)));
        }
        field(13; "No. of Usage Data Billing"; Integer)
        {
            Caption = 'No. of Usage Data Billing';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Usage Data Billing" where("Usage Data Import Entry No." = field("Entry No.")));
        }
        field(14; "No. of UD Billing Errors"; Integer)
        {
            Caption = 'No. of Usage Data Billing Errors';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Usage Data Billing" where("Usage Data Import Entry No." = field("Entry No."), "Processing Status" = const(Error)));
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        CheckAndDeleteUsageDataBilling();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", "Entry No.");
        UsageDataGenericImport.DeleteAll(false);
        UsageDataBlob.SetRange("Usage Data Import Entry No.", "Entry No.");
        UsageDataBlob.DeleteAll(false);
    end;

    internal procedure SetReason(ReasonText: Text)
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        if ReasonText = '' then begin
            Clear("Reason (Preview)");
            Clear(Reason);
        end else begin
            "Reason (Preview)" := CopyStr(ReasonText, 1, MaxStrLen("Reason (Preview)"));
            RRef.GetTable(Rec);
            TextManagement.WriteBlobText(RRef, FieldNo(Reason), ReasonText);
            RRef.SetTable(Rec);
        end;
    end;

    internal procedure DeleteUsageDataBillingLines()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        OnDeleteUsageDataBillingLines();

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", "Entry No.");
        UsageDataGenericImport.DeleteAll(true);
        CheckAndDeleteUsageDataBilling();

        Rec."Processing Status" := "Processing Status"::None;
        Rec."Processing Step" := "Processing Step"::None;
        Rec.SetReason('');
        Rec.Modify(false);
    end;

    local procedure CheckAndDeleteUsageDataBilling()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetRange("Usage Data Import Entry No.", Rec."Entry No.");
        UsageDataBilling.SetFilter("Document No.", '<>%1', '');
        if not UsageDataBilling.IsEmpty() then
            Error(UsageDataBillingWithInvoiceErr);

        UsageDataBilling.SetRange("Document No.");
        if not UsageDataBilling.IsEmpty() then
            UsageDataBilling.DeleteAll(true);
    end;

    internal procedure SetErrorReason(ErrorText: Text)
    begin
        Rec.Validate("Processing Status", Enum::"Processing Status"::Error);
        Rec.SetReason(ErrorText);
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

    internal procedure ImportFile(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataBlob: Record "Usage Data Blob";
        FileName: Text;
        InStream: InStream;
    begin
        FileName := '';
        UploadIntoStream(UsageDataTxt, '', FileManagement.GetToFilterText('CSV files (*.csv)|*.csv|Txt files (*.txt)|*.txt', UsageDataTxt), FileName, InStream);
        if FileName = '' then
            exit;

        if UsageDataImport."Entry No." <> 0 then begin
            UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
            UsageDataBlob.ImportFromFile(InStream, FileName);

            UsageDataImport.Validate("Processing Status", UsageDataImport."Processing Status"::None);
            UsageDataImport.Modify(false);
            Clear(FileName);
        end;
    end;

    internal procedure ProcessUsageDataImport(var UsageDataImport: Record "Usage Data Import"; ProcessingStep: Enum "Processing Step")
    var
        UsageDataImport2: Record "Usage Data Import";
    begin
        if UsageDataImport.FindSet(true) then
            repeat
                if UsageDataImport."Processing Status" = UsageDataImport."Processing Status"::Closed then
                    UsageDataImport.FieldError("Processing Status");
                UsageDataImport2 := UsageDataImport;
                UsageDataImport2."Processing Step" := ProcessingStep;
                UsageDataImport2.Modify(false);
                Commit();
                UsageDataImport2.SetRecFilter();

                OnBeforeProcessUsageDataImport(UsageDataImport2, ProcessingStep);
                case ProcessingStep of
                    "Processing Step"::"Create Imported Lines", "Processing Step"::"Process Imported Lines":
                        Codeunit.Run(Codeunit::"Process Usage Data Import", UsageDataImport2);
                    "Processing Step"::"Create Usage Data Billing":
                        Codeunit.Run(Codeunit::"Create Usage Data Billing", UsageDataImport2);
                    "Processing Step"::"Process Usage Data Billing":
                        Codeunit.Run(Codeunit::"Process Usage Data Billing", UsageDataImport2);
                end;
                OnAfterProcessUsageDataImport(UsageDataImport2, ProcessingStep);
            until UsageDataImport.Next() = 0;
    end;

    internal procedure CollectCustomerContractsAndCreateInvoices(var UsageDataImport: Record "Usage Data Import")
    var
        CustomerContractFilter: Text;
        CustomerContractLineFilter: Text;
    begin
        UsageDataImport.SetFilter("Processing Status", '<>%1', UsageDataImport."Processing Status"::Error);
        if UsageDataImport.FindSet() then
            repeat
                CollectCustomerContractsAndContractLines(UsageDataImport, CustomerContractFilter, CustomerContractLineFilter);
            until UsageDataImport.Next() = 0;
        CreateCustomerInvoices(CustomerContractFilter, CustomerContractLineFilter);
    end;

    internal procedure CollectVendorContractsAndCreateInvoices(var UsageDataImport: Record "Usage Data Import")
    var
        VendorContractFilter: Text;
        VendorContractLineFilter: Text;
    begin
        UsageDataImport.SetFilter("Processing Status", '<>%1', UsageDataImport."Processing Status"::Error);
        if UsageDataImport.FindSet() then
            repeat
                CollectVendorContractsAndContractLines(UsageDataImport, VendorContractFilter, VendorContractLineFilter);
            until UsageDataImport.Next() = 0;
        CreateVendorInvoices(VendorContractFilter, VendorContractLineFilter);
    end;

    local procedure CollectCustomerContractsAndContractLines(UsageDataImport: Record "Usage Data Import"; var CustomerContractFilter: Text; var CustomerContractLineFilter: Text)
    var
        UsageDataBilling: Record "Usage Data Billing";
        TextManagement: Codeunit "Text Management";
    begin
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.SetRange("Document No.", '');
        if UsageDataBilling.FindSet() then
            repeat
                if UsageDataBilling."Contract No." <> '' then
                    TextManagement.AppendText(CustomerContractFilter, Format(UsageDataBilling."Contract No."), '|');
                TextManagement.AppendText(CustomerContractLineFilter, Format(UsageDataBilling."Contract Line No."), '|');
            until UsageDataBilling.Next() = 0;
    end;

    local procedure CollectVendorContractsAndContractLines(UsageDataImport: Record "Usage Data Import"; var VendorContractFilter: Text; var VendorContractLineFilter: Text)
    var
        UsageDataBilling: Record "Usage Data Billing";
        TextManagement: Codeunit "Text Management";
    begin
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.SetRange(Partner, "Service Partner"::Vendor);
        UsageDataBilling.SetRange("Document No.", '');
        if UsageDataBilling.FindSet() then
            repeat
                if UsageDataBilling."Contract No." <> '' then
                    TextManagement.AppendText(VendorContractFilter, Format(UsageDataBilling."Contract No."), '|');
                TextManagement.AppendText(VendorContractLineFilter, Format(UsageDataBilling."Contract Line No."), '|');
            until UsageDataBilling.Next() = 0;
    end;

    local procedure CreateCustomerInvoices(CustomerContractFilter: Text; CustomerContractLineFilter: Text)
    var
        UsageBasedContrSubscribers: Codeunit "Usage Based Contr. Subscribers";
    begin
        if CustomerContractFilter = '' then
            exit;
        UsageBasedContrSubscribers.CreateContractInvoicesFromUsageDataImport(Enum::"Service Partner"::Customer, CustomerContractFilter, CustomerContractLineFilter, '');
    end;

    local procedure CreateVendorInvoices(VendorContractFilter: Text; VendorContractLineFilter: Text)
    var
        UsageBasedContrSubscribers: Codeunit "Usage Based Contr. Subscribers";
    begin
        if VendorContractFilter = '' then
            exit;
        UsageBasedContrSubscribers.CreateContractInvoicesFromUsageDataImport(Enum::"Service Partner"::Vendor, VendorContractFilter, VendorContractLineFilter, '');
    end;

    internal procedure ShowRelatedDocuments(var UsageDataImport: Record "Usage Data Import"; ServicePartner: Enum "Service Partner"; DocumentType: Option Contract,"Contract Invoices","Posted Contract Invoices")
    var
        UsageBasedBilling: Record "Usage Data Billing";
    begin
        if UsageDataImport.Count <> 1 then
            Error(OnlyOneRecordCanBeSelectedErr);
        if UsageDataImport.FindSet() then
            UsageBasedBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        if UsageBasedBilling.Count = 0 then
            Error(UsageBasedBillingDoesNotExistsErr);
        UsageBasedBilling.ShowRelatedDocuments(UsageBasedBilling, DocumentType, ServicePartner);
    end;

    [InternalEvent(false, false)]
    local procedure OnDeleteUsageDataBillingLines()
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeProcessUsageDataImport(var UsageDataImport: Record "Usage Data Import"; ProcessingStep: Enum "Processing Step")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterProcessUsageDataImport(var UsageDataImport: Record "Usage Data Import"; ProcessingStep: Enum "Processing Step")
    begin
    end;

    var
        FileManagement: Codeunit "File Management";
        UsageDataTxt: Label 'Import Usage Data';
        UsageDataBillingWithInvoiceErr: Label 'There are Usage Data Billings which are already in an Invoice.';
        OnlyOneRecordCanBeSelectedErr: Label 'You must choose one record.';
        UsageBasedBillingDoesNotExistsErr: Label 'Usage Based Billing does not exist.';
}
