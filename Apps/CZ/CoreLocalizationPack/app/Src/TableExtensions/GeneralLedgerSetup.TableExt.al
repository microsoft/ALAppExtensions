tableextension 11713 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    fields
    {
        field(11778; "Allow VAT Posting From CZL"; Date)
        {
            Caption = 'Allow VAT Posting From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Use VAT Date CZL");
            end;
        }
        field(11779; "Allow VAT Posting To CZL"; Date)
        {
            Caption = 'Allow VAT Posting To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Use VAT Date CZL");
            end;
        }
        field(11780; "Use VAT Date CZL"; Boolean)
        {
            Caption = 'Use VAT Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                PurchSetup: Record "Purchases & Payables Setup";
                ServiceSetup: Record "Service Mgt. Setup";
                GLEntry: Record "G/L Entry";
                ConfirmManagement: Codeunit "Confirm Management";
                InitVATDateQst: Label 'If you check field %1 you will let system post using %2 different from %3. Field %2 will be initialized from field %3 in all tables. It may take some time and you will not be able to undo this change after posting entries. Do you really want to continue?', Comment = '%1 = fieldcaption of Use VAT Date; %2 = fieldcaption of VAT Date; %3 = fieldcaption of Posting Date';
                CannotChangeFieldErr: Label 'You cannot change the contents of the %1 field because there are posted ledger entries.', Comment = '%1 = field caption';
                DisableVATDateQst: Label 'Are you sure you want to disable VAT Date functionality?';
            begin
                if "Use VAT Date CZL" then begin
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(InitVATDateQst, FieldCaption("Use VAT Date CZL"),
                      GLEntry.FieldCaption("VAT Date CZL"), GLEntry.FieldCaption("Posting Date")), true)
                    then
                        InitVATDateCZL()
                    else
                        "Use VAT Date CZL" := xRec."Use VAT Date CZL";
                end else begin
                    GLEntry.SetFilter("VAT Date CZL", '>0D');
                    if not GLEntry.IsEmpty() then
                        Error(CannotChangeFieldErr, FieldCaption("Use VAT Date CZL"));
                    if ConfirmManagement.GetResponseOrDefault(DisableVATDateQst, false) then begin
                        "Allow VAT Posting From CZL" := 0D;
                        "Allow VAT Posting To CZL" := 0D;
                        if SalesSetup.Get() then
                            SalesSetup."Default VAT Date CZL" := SalesSetup."Default VAT Date CZL"::"Posting Date";
                        if PurchSetup.Get() then
                            PurchSetup."Default VAT Date CZL" := PurchSetup."Default VAT Date CZL"::"Posting Date";
                        if ServiceSetup.Get() then
                            ServiceSetup."Default VAT Date CZL" := ServiceSetup."Default VAT Date CZL"::"Posting Date";
                    end else
                        "Use VAT Date CZL" := xRec."Use VAT Date CZL";
                end;
            end;
        }
        field(11781; "Do Not Check Dimensions CZL"; Boolean)
        {
            Caption = 'Do Not Check Dimensions';
            DataClassification = CustomerContent;
        }
        field(11782; "Check Posting Debit/Credit CZL"; Boolean)
        {
            Caption = 'Check Posting Debit/Credit';
            DataClassification = CustomerContent;
        }
        field(11783; "Mark Neg. Qty as Correct. CZL"; Boolean)
        {
            Caption = 'Mark Neg. Qty as Correction';
            DataClassification = CustomerContent;
        }
        field(11784; "Closed Per. Entry Pos.Date CZL"; Date)
        {
            Caption = 'Closed Period Entry Pos.Date';
            DataClassification = CustomerContent;
        }
        field(11785; "Rounding Date CZL"; Date)
        {
            Caption = 'Rounding Date';
            DataClassification = CustomerContent;
        }
        field(11786; "User Checks Allowed CZL"; Boolean)
        {
            Caption = 'User Checks Allowed';
            DataClassification = CustomerContent;
        }
    }

    procedure InitVATDateCZL()
    begin
        InitVATDateFromRecordCZL(Database::"G/L Entry");
        InitVATDateFromRecordCZL(Database::"Gen. Journal Line");
        InitVATDateFromRecordCZL(Database::"VAT Entry");
        InitVATDateFromRecordCZL(Database::"Sales Header");
        InitVATDateFromRecordCZL(Database::"Sales Invoice Header");
        InitVATDateFromRecordCZL(Database::"Sales Cr.Memo Header");
        InitVATDateFromRecordCZL(Database::"Sales Header Archive");
        InitVATDateFromRecordCZL(Database::"Purchase Header");
        InitVATDateFromRecordCZL(Database::"Purch. Inv. Header");
        InitVATDateFromRecordCZL(Database::"Purch. Cr. Memo Hdr.");
        InitVATDateFromRecordCZL(Database::"Purchase Header Archive");
        InitVATDateFromRecordCZL(Database::"Service Header");
        InitVATDateFromRecordCZL(Database::"Service Invoice Header");
        InitVATDateFromRecordCZL(Database::"Service Cr.Memo Header");
        InitVATDateFromRecordCZL(Database::"Cust. Ledger Entry");
        InitVATDateFromRecordCZL(Database::"Vendor Ledger Entry");
        InitVATDateFromRecordCZL(Database::"VAT Ctrl. Report Line CZL");
        OnAfterInitVATDateCZL();
    end;

    procedure InitVATDateFromRecordCZL(TableNo: Integer)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        PostingDateFieldRef: FieldRef;
        VATDateFieldRef: FieldRef;
    begin
        RecordRef.Open(TableNo);
        DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, 'VAT Date');
        DataTypeManagement.FindFieldByName(RecordRef, PostingDateFieldRef, 'Posting Date');
        VATDateFieldRef.SetRange(0D);
        PostingDateFieldRef.SetFilter('<>%1', 0D);
        if RecordRef.FindSet(true) then
            repeat
                VATDateFieldRef.Value := PostingDateFieldRef.Value;
                RecordRef.Modify();
            until RecordRef.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitVATDateCZL()
    begin
    end;
}
