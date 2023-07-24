tableextension 11713 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    fields
    {
        modify("VAT Reporting Date Usage")
        {
            trigger OnAfterValidate()
            var
                GLEntry: Record "G/L Entry";
                ConfirmManagement: Codeunit "Confirm Management";
                InitVATDateQst: Label 'If you check field %1 you will let system post using %2 different from %3. Field %2 will be initialized from field %3 in all tables. It may take some time and you will not be able to undo this change after posting entries. Do you really want to continue?', Comment = '%1 = fieldcaption of Use VAT Date; %2 = fieldcaption of VAT Date; %3 = fieldcaption of Posting Date';
                CannotChangeFieldErr: Label 'You cannot change the contents of the %1 field because there are posted ledger entries.', Comment = '%1 = field caption';
                DisableVATDateQst: Label 'Are you sure you want to disable VAT Date functionality?';
                VATDateUsageEnabledErr: Label 'The Enabled option allows editing VAT Reporting Date in the VAT Entries which is not in line with Czech functionality. Use the Enabled (Prevent modification) option.';
            begin
#if not CLEAN22
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    exit;
#endif
                if "VAT Reporting Date Usage" = "VAT Reporting Date Usage"::Enabled then
                    Error(VATDateUsageEnabledErr);
                if ("VAT Reporting Date Usage" <> "VAT Reporting Date Usage"::Disabled) and
                   (xRec."VAT Reporting Date Usage" = xRec."VAT Reporting Date Usage"::Disabled)
                then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(InitVATDateQst, FieldCaption("VAT Reporting Date Usage"),
                        GLEntry.FieldCaption("VAT Reporting Date"), GLEntry.FieldCaption("Posting Date")), true)
                    then
                        InitVATDateCZL()
                    else
                        "VAT Reporting Date Usage" := xRec."VAT Reporting Date Usage";

                if ("VAT Reporting Date Usage" = "VAT Reporting Date Usage"::Disabled) and
                   ("VAT Reporting Date Usage" <> xRec."VAT Reporting Date Usage")
                then begin
                    GLEntry.SetFilter("VAT Reporting Date", '>%1', 0D);
                    if not GLEntry.IsEmpty() then
                        Error(CannotChangeFieldErr, FieldCaption("VAT Reporting Date Usage"));
                    if ConfirmManagement.GetResponseOrDefault(DisableVATDateQst, false) then begin
                        "VAT Reporting Date" := "VAT Reporting Date"::"Posting Date";
                        "Allow VAT Posting From CZL" := 0D;
                        "Allow VAT Posting To CZL" := 0D;
                    end else
                        "VAT Reporting Date Usage" := xRec."VAT Reporting Date Usage";
                end;
            end;
        }
        field(11778; "Allow VAT Posting From CZL"; Date)
        {
            Caption = 'Allow VAT Posting From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestIsVATDateEnabledCZL();
            end;
        }
        field(11779; "Allow VAT Posting To CZL"; Date)
        {
            Caption = 'Allow VAT Posting To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestIsVATDateEnabledCZL();
            end;
        }
        field(11780; "Use VAT Date CZL"; Boolean)
        {
            Caption = 'Use VAT Date';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by VAT Reporting Date.';
#if not CLEAN22
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
                ReplaceVATDateMgtCZL.TestIsNotEnabled();
                if "Use VAT Date CZL" then begin
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(InitVATDateQst, FieldCaption("Use VAT Date CZL"),
                      GLEntry.FieldCaption("VAT Date CZL"), GLEntry.FieldCaption("Posting Date")), true)
                    then
                        InitVATDateCZL()
                    else
                        "Use VAT Date CZL" := xRec."Use VAT Date CZL";
                end else begin
                    GLEntry.SetFilter("VAT Date CZL", '>%1', 0D);
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
#endif
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
        field(31085; "Shared Account Schedule CZL"; Code[10])
        {
            Caption = 'Shared Account Schedule';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Name";
        }
        field(31086; "Acc. Schedule Results Nos. CZL"; Code[20])
        {
            Caption = 'Acc. Schedule Results Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(31090; "Def. Orig. Doc. VAT Date CZL"; Enum "Default Orig.Doc. VAT Date CZL")
        {
            Caption = 'Default Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }
#if not CLEAN22
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";

#endif
    procedure InitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"G/L Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Gen. Journal Line");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Posted Gen. Journal Line");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"VAT Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Invoice Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Cr.Memo Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Header Archive");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purchase Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Inv. Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Cr. Memo Hdr.");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purchase Header Archive");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Invoice Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Cr.Memo Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Cust. Ledger Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Vendor Ledger Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"VAT Ctrl. Report Line CZL");
        OnAfterInitVATDateCZL();
    end;

    procedure TestIsVATDateEnabledCZL()
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            TestField("Use VAT Date CZL");
#pragma warning restore AL0432
#endif
        if "VAT Reporting Date Usage" = "VAT Reporting Date Usage"::Disabled then
            FieldError("VAT Reporting Date Usage");
    end;

    procedure UpdateOriginalDocumentVATDateCZL(NewDate: Date; DefaultOrigDocVATDate: Enum "Default Orig.Doc. VAT Date CZL"; var OriginalDocumentVATDate: Date)
    begin
        if ("Def. Orig. Doc. VAT Date CZL" = DefaultOrigDocVATDate) then
            OriginalDocumentVATDate := NewDate;
    end;

    procedure GetOriginalDocumentVATDateCZL(PostingDate: Date; VATDate: Date; DocumentDate: Date): Date
    begin
        Get();
        case "Def. Orig. Doc. VAT Date CZL" of
            "Def. Orig. Doc. VAT Date CZL"::Blank:
                exit(0D);
            "Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                exit(PostingDate);
            "Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                exit(VATDate);
            "Def. Orig. Doc. VAT Date CZL"::"Document Date":
                exit(DocumentDate);
        end;
        exit(PostingDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitVATDateCZL()
    begin
    end;
}
